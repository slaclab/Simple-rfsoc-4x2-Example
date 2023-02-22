##############################################################################
## This file is part of 'ATLAS RD53 FMC DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'ATLAS RD53 FMC DEV', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

# Get variables and procedures
source -quiet $::env(RUCKUS_DIR)/vivado_env_var.tcl
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Remove all the .hdf/.bit files in the image directory
set list [glob -directory $::env(IMAGES_DIR) *.gz]
foreach pntr ${list} {
   exec rm -rf ${pntr}
}
