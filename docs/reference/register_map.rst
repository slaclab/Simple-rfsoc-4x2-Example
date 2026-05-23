Application Register Map
========================

The application exposes a two-level AXI-Lite crossbar hierarchy. A PS-facing
top-level crossbar in
:repo:`firmware/targets/SimpleRfSoc4x2Example/hdl/SimpleRfSoc4x2Example.vhd`
decodes the upper bits of the application address window into three slaves
(platform core, RFDC, application). The application-level crossbar in
:repo:`firmware/shared/rtl/Application.vhd` further decodes into the ring
buffer and DAC signal generator slaves.

Top-level crossbar
------------------

Sourced from
:repo:`firmware/targets/SimpleRfSoc4x2Example/hdl/SimpleRfSoc4x2Example.vhd`.

.. list-table::
   :header-rows: 1
   :widths: 30 30 40

   * - Index constant
     - Slave
     - Notes
   * - ``HW_INDEX_C = 0``
     - ``AxiSocUltraPlusCore`` + SysMon
     - Platform core (DMA engine, AXI-Lite bridge to PS, SysMon).
   * - ``RFDC_INDEX_C = 1``
     - ``RfDataConverter``
     - Wraps the Xilinx RFDC IP core; generates ``dspClk``.
   * - ``APP_INDEX_C = 2``
     - ``Application``
     - Application logic; second-level crossbar.

The crossbar is built from the surf ``genAxiLiteConfig`` macro:

.. code-block:: vhdl

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) :=
      genAxiLiteConfig(NUM_AXIL_MASTERS_C, APP_ADDR_OFFSET_C, 31, 28);

Application crossbar
--------------------

Sourced from :repo:`firmware/shared/rtl/Application.vhd`.

.. list-table::
   :header-rows: 1
   :widths: 30 30 40

   * - Index constant
     - Slave
     - Notes
   * - ``RING_INDEX_C = 0``
     - ``AppRingBuffer``
     - ADC/DAC capture ring buffers; DMA inbound path.
   * - ``DAC_SIG_INDEX_C = 1``
     - ``SigGen`` (``DacSigGen``)
     - RAM-based DAC waveform generator.

The Application-level configuration uses 28 address bits and 24 decode bits:

.. code-block:: vhdl

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) :=
      genAxiLiteConfig(NUM_AXIL_MASTERS_C, AXIL_BASE_ADDR_G, 28, 24);

Pattern: genAxiLiteConfig
-------------------------

The ``genAxiLiteConfig(NUM_MASTERS, BASE_ADDR, ADDR_BITS, DECODE_BITS)`` macro
generates the ``MASTERS_CONFIG_G`` array consumed by ``surf.AxiLiteCrossbar``.
It evenly partitions the address window starting at ``BASE_ADDR``, sized by
``ADDR_BITS``, with each slave receiving ``2**DECODE_BITS`` bytes of address
space. For the platform-level macro definition and the ``AxiLitePkg`` package
that hosts it, see :hub:`reference/register_map.html`.

Sample bus dimensions
---------------------

The RFDC and Application exchange samples over a 256-bit parallel bus carrying
16 samples per ``dspClk`` cycle. The bus width is fixed by the
:doc:`app_pkg` constant ``SAMPLE_PER_CYCLE_C = 16``; the sample width is 16-bit
signed integer per channel.

* ADC bus: ``dspAdc : Slv256Array(3 downto 0)`` — 4 channels.
* DAC bus: ``dspDac : Slv256Array(1 downto 0)`` — 2 channels.

For the platform-level ``Slv256Array`` type definition (declared in
``surf.StdRtlPkg``) and the broader sample-bus convention used across SLAC
RFSoC platforms, see :hub:`reference/register_map.html`.
