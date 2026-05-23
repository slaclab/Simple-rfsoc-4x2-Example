AppPkg Constants
================

The ``AppPkg`` package declares application-wide VHDL constants tying RTL
generics to PyRogue parameters. The values below are sourced verbatim from
:repo:`firmware/shared/rtl/AppPkg.vhd`.

.. list-table::
   :header-rows: 1
   :widths: 25 25 50

   * - Constant
     - Value
     - Description
   * - ``SAMPLE_PER_CYCLE_C``
     - ``16``
     - Samples per ``dspClk`` cycle on the 256-bit ``Slv256Array`` sample bus.
       Linked to the PyRogue parameter ``smplPerCycle``. Changing this value
       requires synchronized RTL and Python updates.
   * - ``DMA_SIZE_C``
     - ``2``
     - Number of DMA lanes. Lane 0 carries ADC/DAC ring buffer data;
       lane 1 is hard-wired loopback for debug.
   * - ``AXIL_CLK_FREQ_C``
     - ``100.0E+6`` (Hz)
     - AXI-Lite clock frequency, register-access domain.
   * - ``AXIL_CLK_PERIOD_C``
     - ``1.0/AXIL_CLK_FREQ_C`` (s)
     - Derived AXI-Lite clock period.

Package declaration excerpt:

.. code-block:: vhdl

   package AppPkg is

      constant SAMPLE_PER_CYCLE_C : positive := 16;

      -------------------------------------------------
      -- DMA[lane=0].inbound  = ADC/DAC ring buffers
      -- DMA[lane=1]          = loopback debugging
      -------------------------------------------------
      constant DMA_SIZE_C : positive := 2;

      constant AXIL_CLK_FREQ_C   : real := 100.0E+6;               -- Units of Hz
      constant AXIL_CLK_PERIOD_C : real := (1.0/AXIL_CLK_FREQ_C);  -- Units of seconds

   end package AppPkg;

See :repo:`firmware/shared/rtl/AppPkg.vhd` for the full source.

For the platform-level ``Slv256Array`` type definition and the ``surf``
standard packages that ``AppPkg`` imports, see
:hub:`reference/register_map.html`.
