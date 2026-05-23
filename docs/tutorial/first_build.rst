First Build
===========

This tutorial is the verified end-to-end build procedure for the
``Simple-rfsoc-4x2-Example`` firmware on the RealDigital RFSoC 4x2 board
(FPGA part ``xczu48dr-ffvg1517-2-e``, firmware version ``v3.2.0.0`` /
``PRJ_VERSION = 0x03020000``). It documents only the commands that differ
between this board and the platform-shared workflow; for host-prep details,
build-output redirection, the bare-metal-vs-Docker decision, and the
serial-console snippet — all of which are board-agnostic — sections below
deep-link to the corresponding anchors in the platform docs site
(:hub:`tutorial/first_soc_bringup.html`).

.. admonition:: Reference toolchain

   This walkthrough was authored against:

   - **Vivado:** ``v2025.2`` (64-bit)
   - **OS:** Ubuntu 22.04 LTS (x86_64)
   - **Firmware version:** ``v3.2.0.0`` (``PRJ_VERSION = 0x03020000``)
   - **Target FPGA part:** ``xczu48dr-ffvg1517-2-e``
   - **Conda env:** ``rogue_v6.12.0``

   Approximate end-to-end build time on a typical Linux build host with the
   firmware tree on local-disk storage: **~60 min** total — firmware (~17 min)
   plus Yocto (~45 min).

Output filenames embed the build timestamp, the building user's username,
and the current git short-SHA, following the schema
``<TargetName>-<PRJ_VERSION>-<YYYYMMDDHHMMSS>-<user>-<git-short-SHA>``. The
``<full-name>`` placeholder is used below wherever the exact filename is
build-specific.

Clone
-----

Install `git-lfs <https://git-lfs.com>`_ in your shell profile (one-time per
environment) before cloning, so any LFS-tracked binaries are fetched correctly:

.. code-block:: bash

   git lfs install

Clone the repository with all submodules:

.. code-block:: bash

   git clone --recursive https://github.com/slaclab/Simple-rfsoc-4x2-Example.git

The ``--recursive`` flag initialises the
:repo:`firmware/submodules/surf`,
:repo:`firmware/submodules/axi-soc-ultra-plus-core`,
:repo:`firmware/submodules/ruckus`, and
:repo:`firmware/submodules/aes-stream-drivers` submodules in one step. Omitting
it leaves the firmware build unable to find the required RTL and TCL sources.

Setup environment
-----------------

Source the Vivado 2025.2 environment, then activate the ``rogue_v6.12.0`` conda
environment:

.. code-block:: bash

   source firmware/vivado_setup.sh
   source software/setup_env_slac.sh

The first script sets ``PATH``, ``LD_LIBRARY_PATH``, and the Xilinx licence
server variables required by ``make``. The second activates the
``rogue_v6.12.0`` conda environment used by the Python control layer.

For host-package prerequisites, the non-SLAC Vivado/conda install path, Yocto
host-package list, and the build-output redirection step required before the
Yocto build, see :hub:`tutorial/first_soc_bringup.html#setup-environment`.

Firmware build
--------------

Change into the target directory and run ``make``:

.. code-block:: bash

   source firmware/vivado_setup.sh
   cd firmware/targets/SimpleRfSoc4x2Example/
   make

**Approximate timing:** ~17 min on a typical Linux build host with Vivado 2025.2.

After a successful build, the ``.bit`` and ``.xsa`` artifacts are written to
``firmware/targets/SimpleRfSoc4x2Example/images/`` using the schema
``SimpleRfSoc4x2Example-0x03020000-<YYYYMMDDHHMMSS>-<user>-<git-short-SHA>``:

.. code-block:: text

   firmware/targets/SimpleRfSoc4x2Example/images/SimpleRfSoc4x2Example-0x03020000-<YYYYMMDDHHMMSS>-<user>-<git-short-SHA>.bit   (~33 MiB)
   firmware/targets/SimpleRfSoc4x2Example/images/SimpleRfSoc4x2Example-0x03020000-<YYYYMMDDHHMMSS>-<user>-<git-short-SHA>.xsa   (~3 MiB)

.. note::

   Your filename will differ — the build embeds the build timestamp, your
   username, and the current git short-SHA. ``PRJ_VERSION = 0x03020000``
   corresponds to firmware version ``v3.2.0.0`` and is tracked in
   :repo:`firmware/targets/shared_version.mk`.

To review Vivado results in GUI mode after a successful build:

.. code-block:: bash

   make gui

For the platform-level firmware-build narrative (Vivado strategy, log locations,
common build failures), see :hub:`tutorial/first_soc_bringup.html#firmware-build`.

Yocto build
-----------

The Yocto build produces the embedded Linux boot images (``BOOT.BIN``,
``image.ub``, ``boot.scr``, ``system.bit``) that run on the RFSoC Processing
System. From the target directory, pass the ``.xsa`` file produced by the
firmware build to ``BuildYoctoProject.sh``:

.. code-block:: bash

   cd firmware/targets/SimpleRfSoc4x2Example/
   ./BuildYoctoProject.sh -f images/SimpleRfSoc4x2Example-0x03020000-<YYYYMMDDHHMMSS>-<user>-<git-short-SHA>.xsa

**Approximate timing:** ~45 min on a typical Linux build host with the firmware
tree on local-disk storage (~7200 bitbake tasks).

After a successful build, the boot images are in
``firmware/build/YoctoProjects/SimpleRfSoc4x2Example/linux/`` and a packaged
tarball is also produced at
``firmware/targets/SimpleRfSoc4x2Example/images/<full-name>.linux.tar.gz``.

For the bare-metal-vs-Docker decision, the Yocto host-package list, the
Dockerfile defect callout, and the deploy-path layout, see
:hub:`tutorial/first_soc_bringup.html#yocto-build`.

SD card
-------

Once the Yocto build is complete, write the boot images to an SD card. The
verified procedure — covering both the manual mount-and-copy recipe and the
scripted ``CreateDiskImage.sh`` path
(:hub:`how-to/sd_card_imaging.html`) — is documented on the platform
docs site at :hub:`tutorial/first_soc_bringup.html#sd-card`. The four files to
copy live under
``firmware/build/YoctoProjects/SimpleRfSoc4x2Example/linux/``
(``BOOT.BIN``, ``image.ub``, ``boot.scr``, ``system.bit``).

Boot
----

1. Power down the RFSoC 4x2 board.
2. Confirm the mode slide switch is in the **SD** (not JTAG) position.
3. Insert the SD card written in the previous step.
4. Power up the board.
5. Confirm the board is reachable on the default DHCP IP ``10.0.0.10``:

   .. code-block:: bash

      ping 10.0.0.10

For the serial-console snippet (USB-to-serial bridge, baud rate, terminal
program selection on Linux/Windows) and troubleshooting steps for boot or
network failures, see :hub:`tutorial/first_soc_bringup.html#boot`.

Run the Rogue GUI
-----------------

Once the board is reachable on the network, launch the PyDM GUI from the host:

.. code-block:: bash

   python software/scripts/devGui.py --ip 10.0.0.10

This connects to the on-board ZMQ server, builds the PyRogue device tree, and
opens the default PyDM dashboard.

For installing Rogue on a non-SLAC host, see :hub:`how-to/rogue_install.html`.
For the platform-level GUI launch how-to (advanced flags, alternative entry
points, headless operation), see :hub:`how-to/rogue_gui_launch.html`.

Next steps
----------

- Update the bitstream on a running board without rebooting:
  :hub:`how-to/remote_bitstream_update.html`.
- Flash the boot images to QSPI for SD-cardless boot:
  :hub:`how-to/qspi_flash.html`.
- Recover from a bricked QSPI image using XSCT JTAG boot mode:
  :hub:`how-to/xsct_boot_mode.html`.
