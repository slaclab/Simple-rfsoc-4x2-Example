#-----------------------------------------------------------------------------
# This file is part of the 'Simple-rfsoc-4x2-Example'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'Simple-rfsoc-4x2-Example', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import pyrogue as pr

import axi_soc_ultra_plus_core.rfsoc_utility as rfsoc_utility

class Application(pr.Device):
    def __init__(self,**kwargs):
        super().__init__(**kwargs)

        self.add(rfsoc_utility.AppRingBuffer(
            offset   = 0x00_000000,
            numAdcCh = 4, # Must match NUM_ADC_CH_G config
            numDacCh = 2, # Must match NUM_DAC_CH_G config
            # expand   = True,
        ))

        self.add(rfsoc_utility.SigGen(
            name         = 'DacSigGen',
            offset       = 0x01_000000,
            numCh        = 2,  # Must match NUM_CH_G config
            ramWidth     = 10, # Must match RAM_ADDR_WIDTH_G config
            smplPerCycle = 16, # Must match SAMPLE_PER_CYCLE_G config
            expand       = True,
        ))
