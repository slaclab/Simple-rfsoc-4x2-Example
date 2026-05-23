Top-Level RTL Entity
====================

The top-level firmware target is ``SimpleRfSoc4x2Example`` (architecture
``top_level``). The full source lives in
:repo:`firmware/targets/SimpleRfSoc4x2Example/hdl/SimpleRfSoc4x2Example.vhd`.

Entity surface
--------------

The entity is the top FPGA target loaded by the Processing System at boot. It
maps physical board I/O to internal AXI buses and three clock domains:

* **System ports:** ``userLed`` (4-bit status LEDs).
* **RF data converter ports:** ADC differential clock and data
  (``adcClkP/N``, ``adcP/N``); DAC differential clock and data
  (``dacClkP/N``, ``dacP/N``); SYSREF and PL clock differential pairs.
* **SYSMON ports:** ``vPIn``, ``vNIn``.

Build-time generics are ``TPD_G`` (propagation-delay convention from surf) and
``BUILD_INFO_G`` (build metadata struct populated by ruckus).

Instantiated blocks
-------------------

.. list-table::
   :header-rows: 1
   :widths: 25 35 40

   * - Block
     - Source
     - Role
   * - ``AxiSocUltraPlusCore``
     - submodule (platform core)
     - Platform core: DMA engine, AXI-Lite bridge to PS, SysMon.
   * - ``RfDataConverter``
     - :repo:`firmware/shared/rtl/RfDataConverter.vhd`
     - Wraps the Xilinx RFDC IP; generates ``dspClk`` from the ``plClk`` PLL.
   * - ``Application``
     - :repo:`firmware/shared/rtl/Application.vhd`
     - Top-level application logic; second-level AXI-Lite crossbar.

The top-level AXI-Lite crossbar splits the application address window across
the three blocks at indices ``HW_INDEX_C = 0``, ``RFDC_INDEX_C = 1``, and
``APP_INDEX_C = 2`` (see :doc:`register_map`).

Clock domains
-------------

.. list-table::
   :header-rows: 1
   :widths: 20 25 55

   * - Clock
     - Frequency
     - Role
   * - ``axilClk``
     - 100 MHz
     - Register access (PS-facing AXI-Lite); also drives ``auxClk`` /
       ``appClk`` inputs of the platform core.
   * - ``dspClk``
     - 312.5 MHz
     - DSP / DAC sample bus (``Slv256Array``, 16 samples per cycle).
   * - ``adcClock``
     - 416.667 MHz
     - RFDC ADC output.

All cross-domain crossings use surf ``Synchronizer`` or ``Ssr12ToSsr16Gearbox``
primitives; the three domains are declared as asynchronous groups in the XDC.
For the platform-level CDC philosophy, see
:hub:`explanation/architecture.html#clock-domains`.

Async clock groups (XDC)
------------------------

The XDC declares the three PLL outputs as asynchronous clock groups so the
Vivado timing engine does not attempt to close timing across domains:

.. code-block:: text

   create_clock -name plClkP -period  2.0 [get_ports {plClkP}]

   set_clock_groups -asynchronous \
       -group [get_clocks -of_objects [get_pins U_Core/REAL_CPU.U_CPU/U_Pll/PllGen.U_Pll/CLKOUT0]] \
       -group [get_clocks -of_objects [get_pins U_Core/REAL_CPU.U_CPU/U_Pll/PllGen.U_Pll/CLKOUT1]] \
       -group [get_clocks -of_objects [get_pins U_RFDC/U_Pll/PllGen.U_Pll/CLKOUT0]] \
       -group [get_clocks -of_objects [get_pins U_RFDC/U_Pll/PllGen.U_Pll/CLKOUT1]]

Sourced from
:repo:`firmware/targets/SimpleRfSoc4x2Example/hdl/SimpleRfSoc4x2Example.xdc`.
