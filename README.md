# Simple-rfsoc-4x2-Example

Reference application for the SLAC RFSoC SoC platform on the RealDigital RFSoC 4x2 board (Xilinx ZU48DR).

**Application docs:** https://slaclab.github.io/Simple-rfsoc-4x2-Example/

**Shared workflow docs (clone, FW build, Yocto, SD card, Rogue install/launch, remote bitstream update):** https://slaclab.github.io/axi-soc-ultra-plus-core/

## Board-specific deltas

- **Target directory:** `firmware/targets/SimpleRfSoc4x2Example/`
- **Default DHCP IP convention:** `10.0.0.10` (used in remote-update and GUI launch examples on the docs site)
- **Board:** RealDigital RFSoC 4x2; FPGA part: `xczu48dr-ffvg1517-2-e`; firmware version: `v3.2.0.0` (`PRJ_VERSION = 0x03020000`)
- **Conda env (SLAC AFS):** `rogue_v6.12.0`
- **RFSoC 4x2-specific Yocto notes:** none beyond the shared procedure (the bare-metal-vs-Docker, build-output redirection, host-package prereqs all live on the hub).
