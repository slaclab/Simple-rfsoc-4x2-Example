# Load RUCKUS environment and library
source $::env(RUCKUS_PROC_TCL)

# Load common ruckus.tcl files
loadRuckusTcl $::env(TOP_DIR)/shared

# Load local source Code and constraints
loadSource      -dir "$::DIR_PATH/hdl"
loadConstraints -dir "$::DIR_PATH/hdl"

set_property top {AxiStreamPkgTb} [get_filesets sim_1]
