#-----------------------------------------------------------------------------
# This file is part of the 'SPACE SMURF RFSOC'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'SPACE SMURF RFSOC', including this file, may be
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

rogue.Version.minVersion('5.16.0')

class Root(pr.Root):
    def __init__(self,
                 ip          = '10.0.0.10', # ETH Host Name (or IP address)
                 top_level   = '',
                 defaultFile = '',
                 lmkConfig   = 'config/lmk/HexRegisterValues.txt',
                 lmxConfig   = 'config/lmx/HexRegisterValues.txt',
                 **kwargs):

        # Pass custom value to parent via super function
        super().__init__(**kwargs)

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
        self.dataWriter = pr.utilities.fileio.StreamWriter()
        self.add(self.dataWriter)

        ##################################################################################
        ##                              Register Access
        ##################################################################################

        if ip != None:
            # Start a TCP Bridge Client, Connect remote server at 'ethReg' ports 9000 & 9001.
            self.memMap = rogue.interfaces.memory.TcpClient(ip,9000)
        else:
            self.memMap = rogue.hardware.axi.AxiMemMap('/dev/axi_memory_map')

        # Add RfSoC4x2 PS hardware control
        self.add(rfsoc_hw.Hardware(
            memBase    = self.memMap,
        ))

        # Added the RFSoC device
        self.add(rfsoc.RFSoC4x2(
            memBase    = self.memMap,
            offset     = 0x04_0000_0000, # Full 40-bit address space
            expand     = True,
        ))

        self.add(pr.LocalVariable(
            name         = 'SwTimer',
            mode         = 'RO',
            localGet     = self.SwTimerCmd,
            pollInterval = 1,
            hidden       = True,
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

    def SwTimerCmd(self):
        # Useful pointers
        gpio = self.Hardware.GpioPs

        # Rogue class alive LED strobing
        gpio.PS_LED0_OUT.set(gpio.PS_LED1_OUT.value())
        gpio.PS_LED1_OUT.set(gpio.PS_LED0_OUT.value() ^ 0x1)

    def start(self,**kwargs):
        super(Root, self).start(**kwargs)

        # Useful pointers
        lmk       = self.Hardware.Lmk
        lmx       = [self.Hardware.Lmx[0],self.Hardware.Lmx[1]]
        rfdc      = self.RFSoC4x2.RfDataConverter
        dacSigGen = self.RFSoC4x2.Application.DacSigGen

        # Check for default file path
        if (self.defaultFile is not None) :

            # Update all SW remote registers
            self.ReadAll()

            # Initialize the SPI bridge
            self.Hardware.SpiBridge.Init()

            # Load the Default YAML file
            print(f'Loading path={self.defaultFile} Default Configuration File...')
            self.LoadConfig(self.defaultFile)
            self.ReadAll()

            # Seems like 1st time after power up that need to load twice
            for i in range(2):

                # Configure the LMK for 4-wire SPI
                lmk.enable.set(True)
                lmk.LmkReg_0x0000.set(value=0x90,verify=False) # 4-wire SPI + RESET
                lmk.LmkReg_0x0000.set(value=0x10,verify=False) # 4-wire SPI
                lmk.LmkReg_0x014A.set(value=0x06,verify=False) # RESET/GPO as open drain
                lmk.LmkReg_0x016E.set(value=0x3B,verify=False) # STATUS_LD2 = SPI readback

                # Load the LMK configuration from the TICS Pro software HEX export
                lmk.PwrDwnLmkChip()
                lmk.PwrUpLmkChip()
                lmk.LoadCodeLoaderHexFile(self.lmkConfig)
                lmk.Init()
                lmk.LmkReg_0x016E.set(value=0x13,verify=False) # STATUS_LD2 = PLL2 DLD
                lmk.enable.set(False)

                # Load the LMX configuration from the TICS Pro software HEX export
                for j in range(2):
                    lmx[j].enable.set(True)
                    lmx[j].DataBlock.set(value=0x002410,index=0, write=True) # MUXOUT_LD_SEL=readback
                    lmx[j].LoadCodeLoaderHexFile(self.lmxConfig)
                    lmx[j].DataBlock.set(value=0x002414,index=0, write=True) # MUXOUT_LD_SEL=LockDetect
                    lmx[j].enable.set(False)

                # Reset the RF Data Converter
                print(f'Resetting RF Data Converter...')
                rfdc.Reset.set(0x1)
                for i in [0,2]: # Only ADC/DAC.TILE[0] and ADC/DAC.TILE[2]
                    rfdc.adcTile[i].RestartSM.set(0x1)
                    while rfdc.adcTile[i].pllLocked.get() != 0x1:
                        time.sleep(0.1)
                    rfdc.dacTile[i].RestartSM.set(0x1)
                    while rfdc.dacTile[i].pllLocked.get() != 0x1:
                        time.sleep(0.1)

            # Wait for DSP Clock to be stable
            time.sleep(1.0)

            # Load the waveform data into DacSigGen
            csvFile = dacSigGen.CsvFilePath.get()
            if csvFile != '':
                if self.top_level != '':
                    dacSigGen.CsvFilePath.set(f'{self.top_level}/{csvFile}')
                dacSigGen.LoadCsvFile()

            # Update all SW remote registers
            self.ReadAll()

    ##################################################################################
