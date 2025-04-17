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
import setupLibPaths
import simple_rfsoc_4x2_example

import os
import sys
import argparse
import importlib
import rogue
import pyrogue
import axi_soc_ultra_plus_core.rfsoc_utility.pydm

if __name__ == "__main__":

#################################################################

    # Set the argument parser
    parser = argparse.ArgumentParser()

    # Convert str to bool
    argBool = lambda s: s.lower() in ['true', 't', 'yes', '1']

    # Add arguments
    parser.add_argument(
        "--ip",
        type     = str,
        required = True,
        help     = "ETH Host Name (or IP address)",
    )

    parser.add_argument(
        "--pollEn",
        type     = argBool,
        required = False,
        default  = True,
        help     = "Enable auto-polling",
    )

    parser.add_argument(
        "--initRead",
        type     = argBool,
        required = False,
        default  = True,
        help     = "Enable read all variables at start",
    )

    parser.add_argument(
        "--defaultFile",
        type     = str,
        required = False,
        # default  = None,
        default  = 'config/defaults.yml',
        help     = "Sets the default YAML configuration file to be loaded at the root.start()",
    )

    parser.add_argument(
        "--guiType",
        type     = str,
        required = False,
        default  = 'PyDM',
        help     = "Sets the GUI type (PyDM or None)",
    )

    parser.add_argument(
        "--zmqSrvPort",
        type     = int,
        required = False,
        default  = 9099,
        help     = "Zeromq server port (set to zero if you want it dynamic)",
    )

    # Get the arguments
    args = parser.parse_args()

    #################################################################

    with simple_rfsoc_4x2_example.Root(
        ip          = args.ip,
        pollEn      = args.pollEn,
        initRead    = args.initRead,
        defaultFile = args.defaultFile,
        zmqSrvPort  = args.zmqSrvPort,
    ) as root:

        ######################
        # Development PyDM GUI
        ######################
        if (args.guiType == 'PyDM'):
            axi_soc_ultra_plus_core.rfsoc_utility.pydm.runPyDM(
                serverList = root.zmqServer.address,
                ui       = f'{os.path.dirname(axi_soc_ultra_plus_core.rfsoc_utility.__file__)}/gui/GuiTop.py',
                sizeX    = 800,
                sizeY    = 800,
                numAdcCh = 4,
                numDacCh = 2,
            )

        #################
        # No GUI
        #################
        elif (args.guiType == 'None'):
            print("Running without GUI...")
            pyrogue.waitCntrlC()

        ####################
        # Undefined GUI type
        ####################
        else:
            raise ValueError("Invalid GUI type (%s)" % (args.guiType) )

    #################################################################
