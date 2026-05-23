Architecture Overview
=====================

This page describes the application-specific topology of
``Simple-rfsoc-4x2-Example`` on the RealDigital RFSoC 4x2 board
(Xilinx ZU48DR). It covers what is unique to this application: the
4-channel ADC capture path, the 2-channel DAC output path, the
ring-buffer DMA model, the three local clock domains, and the startup
discipline that ties RTL and PyRogue together.

For platform-level RFSoC architecture (clock-domain CDC philosophy,
DMA platform model, AXI-Lite hierarchy in general), see
:hub:`explanation/architecture.html`.

Topology
--------

The application is built around the Xilinx RFDC IP wrapped by
``RfDataConverter``, an ``AppRingBuffer`` block for capture and
loopback, and a RAM-based ``SigGen`` for DAC waveforms. Data movement
is split across two DMA lanes:

* **4-channel ADC capture path:** RFDC -> ``AppRingBuffer`` ->
  DMA lane 0 -> host TCP stream. Per-channel ring buffers are armed,
  triggered, and read back via PyRogue.
* **2-channel DAC output path:** DAC waveform RAM in ``SigGen`` ->
  RFDC -> physical DAC pins. Loopback samples are also captured back
  into ``AppRingBuffer`` for closed-loop debug.
* **Ring-buffer DMA model with** ``DMA_SIZE_C = 2``: lane 0 carries
  the ADC and DAC ring-buffer data; lane 1 is hard-wired loopback for
  debug. See :doc:`../reference/app_pkg` for the constants and
  :doc:`../reference/rtl_top_entity` for the entity surface.

Clock domains
-------------

Three asynchronous clock domains drive this application:

.. list-table::
   :header-rows: 1
   :widths: 20 25 55

   * - Clock
     - Frequency
     - Role
   * - ``axilClk``
     - 100 MHz
     - Register access (PS-facing AXI-Lite); also drives the platform
       core's ``auxClk`` / ``appClk`` inputs.
   * - ``dspClk``
     - 312.5 MHz
     - DSP and DAC sample bus (``Slv256Array``, 16 samples per cycle).
   * - ``adcClock``
     - 416.667 MHz
     - RFDC ADC output.

All three are declared as asynchronous clock groups in the XDC, so
Vivado's timing engine does not attempt to close timing across them.
CDC crossings between any two domains use surf primitives
(``Synchronizer`` for control/status, ``Ssr12ToSsr16Gearbox`` for the
ADC sample bus). For the platform-level CDC philosophy and the hub's
treatment of clock-group declarations, see
:hub:`explanation/architecture.html#clock-domains`. Concrete signal
names and the XDC excerpt live in :doc:`../reference/rtl_top_entity`.

DMA model
---------

The application uses two DMA lanes (``DMA_SIZE_C = 2`` in
:doc:`../reference/app_pkg`):

* **Lane 0** carries the ADC and DAC ring-buffer streams between the
  ``AppRingBuffer`` block and the host. The PyRogue ``Root`` wires
  this lane to per-channel ``RingBufferProcessor`` consumers and to
  the data-writer file sink.
* **Lane 1** is a hard-wired loopback used for DMA debug; the host
  pushes a frame down lane 1 and reads the same frame back, which
  exercises the DMA engine independently of the RFDC and ring-buffer
  logic.

Adding lanes is a coordinated change: ``DMA_SIZE_C`` in
:repo:`firmware/shared/rtl/AppPkg.vhd` and the stream wiring in
:repo:`firmware/python/simple_rfsoc_4x2_example/_Root.py` must be
updated together. For the platform-level DMA model (engine, AXI
Stream framing, host TCP-bridge convention), see
:hub:`explanation/architecture.html#dma-model`.

Sample bus
----------

The parallel sample bus between RFDC and ``Application`` is a
``Slv256Array``: 16 samples * 16 bits = 256 bits per channel per
``dspClk`` cycle. The ``SAMPLE_PER_CYCLE_C`` constant in
:doc:`../reference/app_pkg` ties the RTL generics
(``ADC_SAMPLE_PER_CYCLE_G``, ``DAC_SAMPLE_PER_CYCLE_G``,
``SAMPLE_PER_CYCLE_G``) to the PyRogue ``smplPerCycle`` parameter.
The 16-sample width is fixed for this application; changing it
requires synchronized RTL and Python updates. The PyRogue offsets and
register addresses tied to this bus are documented in
:doc:`../reference/register_map`.

Startup discipline
------------------

The application's PyRogue ``Application`` device is instantiated with
``enabled=False`` and is only enabled after the ``dspClk`` is stable.
The ``Root.start()`` method enforces the order: clock chip
initialization, DSP-reset wait, RFDC initialization, MTS sync, YAML
config load, and finally the SigGen waveform load. Bypassing this
sequence (for example, enabling ``Application`` before ``dspClk`` is
running, or loading the SigGen waveform before MTS sync) is a known
anti-pattern; registers that depend on ``dspClk`` will read back
zero or DECERR.
