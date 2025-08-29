#!/usr/bin/env python3
#-----------------------------------------------------------------------------
# This file is part of the 'Simple-rfsoc-4x2-Example'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'Simple-rfsoc-4x2-Example', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------
# This script is used when the software/script/devGui.py being ran in guiType=None
#-----------------------------------------------------------------------------
import setupLibPaths # setup the runtime PYTHONPATH paths

import os
import argparse

import pyrogue.pydm
import axi_soc_ultra_plus_core.rfsoc_utility.pydm

if __name__ == "__main__":

#################################################################

    # Set the argument parser
    parser = argparse.ArgumentParser()

    # Convert str to bool
    argBool = lambda s: s.lower() in ['true', 't', 'yes', '1']

    # Add arguments
    parser.add_argument(
        "--serverList",
        type     = str,
        required = False,
        default  = 'localhost:9099',
        help     = "ZeroMQ server's hostname(or IP address):port",
    )

    # Get the arguments
    args = parser.parse_args()

    #################################################################

    pyrogue.pydm.runPyDM(
        serverList = args.serverList,
        ui         = f'{os.path.dirname(axi_soc_ultra_plus_core.rfsoc_utility.__file__)}/gui/GuiTop.py',
    )

    #################################################################
