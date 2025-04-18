#-----------------------------------------------------------------------------
# This file is part of the 'Simple-rfsoc-4x2-Example'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'Simple-rfsoc-4x2-Example', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import time

import rogue
import rogue.interfaces.stream as stream
import rogue.utilities.fileio
import rogue.hardware.axi
import rogue.interfaces.memory

import pyrogue as pr
import pyrogue.protocols
import pyrogue.utilities.fileio
import pyrogue.utilities.prbs

import simple_rfsoc_4x2_example              as rfsoc
import axi_soc_ultra_plus_core.rfsoc_utility as rfsoc_utility
import axi_soc_ultra_plus_core.hardware.RealDigitalRfSoC4x2 as rfsoc_hw
import axi_soc_ultra_plus_core as soc_core

rogue.Version.minVersion('6.5.0')

class Root(pr.Root):
    def __init__(self,
            ip          = '10.0.0.10', # ETH Host Name (or IP address)
            top_level   = '',
            defaultFile = '',
            lmkConfig   = 'config/lmk/HexRegisterValues.txt',
            lmxConfig   = 'config/lmx/HexRegisterValues.txt',
            zmqSrvPort  = 9099, # Set to zero if dynamic (instead of static)
            **kwargs):
        super().__init__(timeout=5.0,**kwargs)

        #################################################################

        self.zmqServer = pyrogue.interfaces.ZmqServer(root=self, addr='127.0.0.1', port=zmqSrvPort)
        self.addInterface(self.zmqServer)

        #################################################################

        # Local Variables
        self.top_level   = top_level
        if self.top_level != '':
            self.defaultFile = f'{top_level}/{defaultFile}'
            self.lmkConfig   = f'{top_level}/{lmkConfig}'
            self.lmxConfig   = f'{top_level}/{lmxConfig}'
        else:
            self.defaultFile = defaultFile
            self.lmkConfig   = lmkConfig
            self.lmxConfig   = lmxConfig

        # File writer
        self.dataWriter = pr.utilities.fileio.StreamWriter(name='DataWriter')
        self.add(self.dataWriter)

        ##################################################################################
        ##                              Register Access
        ##################################################################################

        if ip != None:
            # Check if we can ping the device and TCP socket not open
            soc_core.connectionTest(ip)
            # Start a TCP Bridge Client, Connect remote server at 'ethReg' ports 9000 & 9001.
            self.memMap = rogue.interfaces.memory.TcpClient(ip,9000)
        else:
            self.memMap = rogue.hardware.axi.AxiMemMap('/dev/axi_memory_map')

        # Add RfSoC4x2 PS hardware control
        self.add(rfsoc_hw.Hardware(
            memBase    = self.memMap,
        ))

        # Add the RFDC API interface
        self.memRfdc = rogue.interfaces.memory.TcpClient(ip,9002)
        self.add(rfsoc_utility.Rfdc(
            memBase = self.memRfdc,
        ))

        # Added the RFSoC device
        self.add(rfsoc.RFSoC(
            memBase    = self.memMap,
            offset     = 0x04_0000_0000, # Full 40-bit address space
            expand     = True,
        ))

        ##################################################################################
        ##                              Data Path
        ##################################################################################

        # Create rogue stream arrays
        if ip != None:
            self.ringBufferAdc = [stream.TcpClient(ip,10000+2*(i+0))  for i in range(4)]
            self.ringBufferDac = [stream.TcpClient(ip,10000+2*(i+16)) for i in range(2)]
        else:
            self.ringBufferAdc = [rogue.hardware.axi.AxiStreamDma('/dev/axi_stream_dma_0', i+0,  True) for i in range(4)]
            self.ringBufferDac = [rogue.hardware.axi.AxiStreamDma('/dev/axi_stream_dma_0', 16+i, True) for i in range(2)]
        self.adcRateDrop   = [stream.RateDrop(True,1.0) for i in range(4)]
        self.dacRateDrop   = [stream.RateDrop(True,1.0) for i in range(2)]
        self.adcProcessor  = [rfsoc_utility.RingBufferProcessor(name=f'AdcProcessor[{i}]',sampleRate=5.0E+9) for i in range(4)]
        self.dacProcessor  = [rfsoc_utility.RingBufferProcessor(name=f'DacProcessor[{i}]',sampleRate=5.0E+9) for i in range(2)]

        # Connect the rogue stream arrays: ADC Ring Buffer Path
        for i in range(4):
            self.ringBufferAdc[i] >> self.dataWriter.getChannel(i+0)
            self.ringBufferAdc[i] >> self.adcRateDrop[i] >> self.adcProcessor[i]
            self.add(self.adcProcessor[i])

        # Connect the rogue stream arrays: DAC Ring Buffer Path
        for i in range(2):
            self.ringBufferDac[i] >> self.dataWriter.getChannel(i+16)
            self.ringBufferDac[i] >> self.dacRateDrop[i] >> self.dacProcessor[i]
            self.add(self.dacProcessor[i])

    ##################################################################################

    def start(self,**kwargs):
        super(Root, self).start(**kwargs)

        # Useful pointers
        dacSigGen = self.RFSoC.Application.DacSigGen

        print('Issuing a reset to the user logic')
        self.RFSoC.AxiSocCore.UserRst()

        # Initialize the LMK/LMX Clock chips
        self.Hardware.InitClock(lmkConfig=self.lmkConfig,lmxConfig=[self.lmxConfig])

        print('Wait for DSP Clock to be stable')
        self.RFSoC.AxiSocCore.DspRstWait()

        # Enable application after DSP clock stable has been configured
        self.RFSoC.Application.enable.set(True)
        self.ReadAll()

        # Initialize the RF Data Converter
        self.Rfdc.Init()

        # MTS Sync the RF Data Converter
        self.Rfdc.Mst.AdcTiles.set(0x5)
        self.Rfdc.Mst.DacTiles.set(0x5)
        self.Rfdc.Mst.AdcRefTile.set(0x2)
        self.Rfdc.Mst.DacRefTile.set(0x2)
        self.Rfdc.Mst.SysRefConfig.set(1)
        self.Rfdc.Mst.SyncAdcTiles()
        self.Rfdc.Mst.SyncDacTiles()

        # Load the Default YAML file
        print(f'Loading path={self.defaultFile} Default Configuration File...')
        self.LoadConfig(self.defaultFile)
        self.ReadAll()

        # Load the waveform data into DacSigGen
        csvFile = dacSigGen.CsvFilePath.get()
        if csvFile != '':
            if self.top_level != '':
                dacSigGen.CsvFilePath.set(f'{self.top_level}/{csvFile}')
            dacSigGen.LoadCsvFile()
        else:
            self.RFSoC.Application.DacSigGenLoader.LoadSingleTones()

    ##################################################################################
