##############################################################################
## This file is part of 'Simple-10GbE-RUDP-KCU105-Example'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'Simple-10GbE-RUDP-KCU105-Example', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

##############################
# Get variables and procedures
##############################
source -quiet $::env(RUCKUS_DIR)/vivado_env_var.tcl
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

######################################################
# Bypass the debug chipscope generation via return cmd
# ELSE ... comment out the return to include chipscope
######################################################
return

############################
## Open the synthesis design
############################
open_run synth_1

###############################
## Set the name of the ILA core
###############################
set ilaName u_ila_0

##################
## Create the core
##################
CreateDebugCore ${ilaName}

#######################
## Set the record depth
#######################
set_property C_DATA_DEPTH 8192 [get_debug_cores ${ilaName}]

#################################
## Set the clock for the ILA core
#################################
SetDebugCoreClk ${ilaName} {U_Hardware/U_I2C_CLK104/axilClk}

#######################
## Set the debug Probes
#######################

ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/axilReadMaster[araddr][*]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/axilWriteMaster[awaddr][*]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/axilWriteMaster[wdata][*]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/r[axilReadSlave][rdata][*]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/r[axilReadSlave][rresp][*]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/r[axilWriteSlave][bresp][*]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/r[regIn][i2cAddr][*]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/r[regIn][regAddr][*]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/r[regIn][regAddrSize][*]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/r[regIn][regDataSize][*]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/r[regIn][regWrData][*]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/r[sdoMuxSel][*]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/r[state][*]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/regOut[regFailCode][*]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/regOut[regRdData][*]}

ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/axilReadMaster[arvalid]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/axilReadMaster[rready]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/axilRst}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/axilWriteMaster[awvalid]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/axilWriteMaster[bready]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/axilWriteMaster[wvalid]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/i2co[scloen]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/i2co[sdaoen]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/r[axilReadSlave][arready]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/r[axilReadSlave][rvalid]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/r[axilWriteSlave][awready]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/r[axilWriteSlave][bvalid]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/r[axilWriteSlave][wready]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/r[regIn][busReq]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/r[regIn][endianness]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/r[regIn][regAddrSkip]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/r[regIn][regOp]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/r[regIn][regReq]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/r[regIn][repeatStart]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/r[regIn][tenbit]}
# ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/readEnable}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/regOut[regAck]}
ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/regOut[regFail]}
# ConfigProbe ${ilaName} {U_Hardware/U_I2C_CLK104/writeEnable}

##########################
## Write the port map file
##########################
WriteDebugProbes ${ilaName}
