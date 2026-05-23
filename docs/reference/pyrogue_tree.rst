PyRogue Device Tree
===================

The application's PyRogue device tree mirrors the AXI-Lite crossbar hierarchy
in RTL. Each ``pr.Device`` carries an ``offset`` relative to its parent. The
values below are sourced from
:repo:`firmware/python/simple_rfsoc_4x2_example/_Root.py`,
:repo:`firmware/python/simple_rfsoc_4x2_example/_RFSoC.py`, and
:repo:`firmware/python/simple_rfsoc_4x2_example/_Application.py`.

Hierarchy
---------

* ``Root`` (``pr.Root``, see :repo:`firmware/python/simple_rfsoc_4x2_example/_Root.py`)

  * ``Hardware`` (RealDigital RFSoC 4x2 PS hardware control)
  * ``Rfdc`` (RFDC API interface, platform-provided)
  * ``RFSoC`` (offset ``0x04_0000_0000``,
    see :repo:`firmware/python/simple_rfsoc_4x2_example/_RFSoC.py`)

    * ``AxiSocCore`` (offset ``0x0000_0000``, platform core)
    * ``Application`` (offset ``0xA000_0000``,
      see :repo:`firmware/python/simple_rfsoc_4x2_example/_Application.py`)

      * ``AppRingBuffer`` (offset ``0x00_000000``)
      * ``DacSigGen`` (offset ``0x01_000000``, ``SigGen`` instance)
      * ``DacSigGenLoader`` (host-side waveform loader)

  * ``adcProcessor[0..3]``, ``dacProcessor[0..1]`` (host-side
    ``RingBufferProcessor`` instances; see :hub:`reference/pyrogue_api.html`)
  * ``DataWriter`` (``pr.utilities.fileio.StreamWriter``)

The ``Application`` device declares its children with ``offset`` values that
match the RTL Application crossbar (see :doc:`register_map`):

.. code-block:: python

   self.add(rfsoc_utility.AppRingBuffer(
       offset   = 0x00_000000,
       numAdcCh = 4, # Must match NUM_ADC_CH_G config
       numDacCh = 2, # Must match NUM_DAC_CH_G config
   ))

   self.add(rfsoc_utility.SigGen(
       name         = 'DacSigGen',
       offset       = 0x01_000000,
       numCh        = 2,  # Must match NUM_CH_G config
       ramWidth     = 10, # Must match RAM_ADDR_WIDTH_G config
       smplPerCycle = 16, # Must match SAMPLE_PER_CYCLE_G config
   ))

The ``smplPerCycle = 16`` parameter mirrors the RTL ``SAMPLE_PER_CYCLE_C``
constant declared in :doc:`app_pkg`.

Startup sequence
----------------

``Root.start()`` (in
:repo:`firmware/python/simple_rfsoc_4x2_example/_Root.py`) executes the
following ordered sequence after the base ``pr.Root.start()`` runs:

1. TCP connection setup (memory map + RFDC + ring-buffer streams).
2. Stream wiring (ADC/DAC ring buffer paths chained to ``DataWriter`` and to
   per-channel host-side processors via ``>>``).
3. User-logic reset (``RFSoC.AxiSocCore.UserRst()``).
4. LMK/LMX clock chip initialization (``Hardware.InitClock``).
5. DSP-clock-stable wait (``RFSoC.AxiSocCore.DspRstWait()``).
6. Application enable (``RFSoC.Application.enable.set(True)``) — only after
   the DSP clock is stable.
7. RFDC initialization and MTS sync (``Rfdc.Init()`` and ``Rfdc.Mts.*``).
8. Default YAML configuration load (``LoadConfig``).
9. DacSigGen waveform load (CSV file or ``LoadSingleTones`` fallback).

The ``Application`` device is constructed with ``enabled=False`` and is
deliberately enabled only after step 5. Bypassing this order leaves the
application reading registers in an unknown clock state.

For platform-level PyRogue patterns — the ``AxiSocCore`` interface, the
``Rfdc`` API, and the host-side ``RingBufferProcessor`` stream pipeline — see
:hub:`reference/pyrogue_api.html`.

Public package surface
----------------------

The ``simple_rfsoc_4x2_example`` package exposes its public classes via a
wildcard re-export pattern in
:repo:`firmware/python/simple_rfsoc_4x2_example/__init__.py`:

.. code-block:: python

   from simple_rfsoc_4x2_example._Application import *
   from simple_rfsoc_4x2_example._RFSoC       import *
   from simple_rfsoc_4x2_example._Root        import *

Private implementation files are underscore-prefixed (``_Application.py``,
``_RFSoC.py``, ``_Root.py``); ``__init__.py`` is the public face.
