##############################################################################
## This file is part of 'Example Project Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'Example Project Firmware', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_axilClk/PllGen.U_Pll/CLKOUT0]] -group [get_clocks -of_objects [get_pins U_RFDC/U_Pll/PllGen.U_Pll/CLKOUT1]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_RFDC/U_Pll/PllGen.U_Pll/CLKOUT0]] -group [get_clocks -of_objects [get_pins U_RFDC/U_Pll/PllGen.U_Pll/CLKOUT1]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_Core/REAL_CPU.U_CPU/U_Pll/PllGen.U_Pll/CLKOUT0]] -group [get_clocks -of_objects [get_pins U_axilClk/PllGen.U_Pll/CLKOUT0]]
