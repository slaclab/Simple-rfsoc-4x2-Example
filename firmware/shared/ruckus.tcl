# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load submodule code
loadRuckusTcl $::env(TOP_DIR)/submodules/surf
loadRuckusTcl $::env(TOP_DIR)/submodules/axi-soc-ultra-plus-core/hardware/RealDigitalRfSoC4x2

# Load RTL code
loadSource -dir  "$::DIR_PATH/rtl"

# Load IP cores
loadIpCore -dir "$::DIR_PATH/ip"

# Updating the impl_1 strategy
set_property strategy Performance_ExplorePostRoutePhysOpt [get_runs impl_1]
