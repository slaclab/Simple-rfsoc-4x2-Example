-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Top Level Firmware Target
-------------------------------------------------------------------------------
-- This file is part of 'axi-pcie-core'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'axi-pcie-core', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiStreamPkg.all;
use surf.AxiLitePkg.all;

library work;
use work.AppPkg.all;

library axi_soc_ultra_plus_core;
use axi_soc_ultra_plus_core.AxiSocUltraPlusPkg.all;

entity SimpleRfSoc4x2Example is
   generic (
      TPD_G        : time := 1 ns;
      BUILD_INFO_G : BuildInfoType);
   port (
      -- RF DATA CONVERTER Ports
      adcClkP   : in    slv(1 downto 0);
      adcClkN   : in    slv(1 downto 0);
      adcP      : in    slv(3 downto 0);
      adcN      : in    slv(3 downto 0);
      dacClkP   : in    slv(1 downto 0);
      dacClkN   : in    slv(1 downto 0);
      dacP      : out   slv(1 downto 0);
      dacN      : out   slv(1 downto 0);
      sysRefP   : in    sl;
      sysRefN   : in    sl;
      -- SYSMON Ports
      vPIn      : in    sl;
      vNIn      : in    sl);
end SimpleRfSoc4x2Example;

architecture top_level of SimpleRfSoc4x2Example is

   constant HW_INDEX_C   : natural := 0;
   constant RFDC_INDEX_C : natural := 1;
   constant APP_INDEX_C  : natural := 2;

   constant NUM_AXIL_MASTERS_C : positive := 3;

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXIL_MASTERS_C, APP_ADDR_OFFSET_C, 31, 28);

   signal dmaClk          : sl;
   signal dmaRst          : sl;
   signal dmaBuffGrpPause : slv(7 downto 0);
   signal dmaObMasters    : AxiStreamMasterArray(DMA_SIZE_C-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal dmaObSlaves     : AxiStreamSlaveArray(DMA_SIZE_C-1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
   signal dmaIbMasters    : AxiStreamMasterArray(DMA_SIZE_C-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal dmaIbSlaves     : AxiStreamSlaveArray(DMA_SIZE_C-1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

   signal axilClk         : sl;
   signal axilRst         : sl;
   signal axilWriteMaster : AxiLiteWriteMasterType;
   signal axilWriteSlave  : AxiLiteWriteSlaveType;
   signal axilReadMaster  : AxiLiteReadMasterType;
   signal axilReadSlave   : AxiLiteReadSlaveType;

   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_DECERR_C);
   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C);

   signal dspClk : sl;
   signal dspRst : sl;
   signal dspAdc : Slv256Array(3 downto 0);
   signal dspDac : Slv256Array(1 downto 0);

begin

   ------------------------------
   -- User's AXI-Lite Clock/Reset
   ------------------------------
   U_axilClk : entity surf.ClockManagerUltraScale
      generic map(
         TPD_G             => TPD_G,
         TYPE_G            => "PLL",
         INPUT_BUFG_G      => false,
         FB_BUFG_G         => true,
         RST_IN_POLARITY_G => '1',
         NUM_CLOCKS_G      => 1,
         -- MMCM attributes
         CLKIN_PERIOD_G    => 4.0,      -- 250 MHz
         CLKFBOUT_MULT_G   => 4,        -- 1.0GHz = 4 x 250 MHz
         CLKOUT0_DIVIDE_G  => 10)       -- 100MHz = 1.0GHz/10
      port map(
         -- Clock Input
         clkIn     => dmaClk,
         rstIn     => dmaRst,
         -- Clock Outputs
         clkOut(0) => axilClk,
         -- Reset Outputs
         rstOut(0) => axilRst);

   -----------------------
   -- Common Platform Core
   -----------------------
   U_Core : entity axi_soc_ultra_plus_core.AxiSocUltraPlusCore
      generic map (
         TPD_G             => TPD_G,
         BUILD_INFO_G      => BUILD_INFO_G,
         EXT_AXIL_MASTER_G => false,
         DMA_SIZE_G        => DMA_SIZE_C)
      port map (
         ------------------------
         --  Top Level Interfaces
         ------------------------
         -- DMA Interfaces  (dmaClk domain)
         dmaClk          => dmaClk,
         dmaRst          => dmaRst,
         dmaBuffGrpPause => dmaBuffGrpPause,
         dmaObMasters    => dmaObMasters,
         dmaObSlaves     => dmaObSlaves,
         dmaIbMasters    => dmaIbMasters,
         dmaIbSlaves     => dmaIbSlaves,
         -- Application AXI-Lite Interfaces [0x80000000:0xFFFFFFFF] (appClk domain)
         appClk          => axilClk,
         appRst          => axilRst,
         appReadMaster   => axilReadMaster,
         appReadSlave    => axilReadSlave,
         appWriteMaster  => axilWriteMaster,
         appWriteSlave   => axilWriteSlave,
         -- SYSMON Ports
         vPIn            => vPIn,
         vNIn            => vNIn);

   ---------------------
   -- AXI-Lite Crossbar
   ---------------------
   U_XBAR : entity surf.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_AXIL_MASTERS_C,
         MASTERS_CONFIG_G   => AXIL_CONFIG_C)
      port map (
         axiClk              => axilClk,
         axiClkRst           => axilRst,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         mAxiWriteMasters    => axilWriteMasters,
         mAxiWriteSlaves     => axilWriteSlaves,
         mAxiReadMasters     => axilReadMasters,
         mAxiReadSlaves      => axilReadSlaves);

   --------------------
   -- RF DATA CONVERTER
   --------------------
   U_RFDC : entity work.RfDataConverter
      generic map (
         TPD_G            => TPD_G,
         AXIL_BASE_ADDR_G => AXIL_CONFIG_C(RFDC_INDEX_C).baseAddr)
      port map (
         -- RF DATA CONVERTER Ports
         adcClkP         => adcClkP,
         adcClkN         => adcClkN,
         adcP            => adcP,
         adcN            => adcN,
         dacClkP         => dacClkP,
         dacClkN         => dacClkN,
         dacP            => dacP,
         dacN            => dacN,
         sysRefP         => sysRefP,
         sysRefN         => sysRefN,
         -- ADC/DAC Interface (dspClk domain)
         dspClk          => dspClk,
         dspRst          => dspRst,
         dspAdc          => dspAdc,
         dspDac          => dspDac,
         -- AXI-Lite Interface (axilClk domain)
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilWriteMaster => axilWriteMasters(RFDC_INDEX_C),
         axilWriteSlave  => axilWriteSlaves(RFDC_INDEX_C),
         axilReadMaster  => axilReadMasters(RFDC_INDEX_C),
         axilReadSlave   => axilReadSlaves(RFDC_INDEX_C));

   --------------
   -- Application
   --------------
   U_App : entity work.Application
      generic map (
         TPD_G            => TPD_G,
         AXIL_BASE_ADDR_G => AXIL_CONFIG_C(APP_INDEX_C).baseAddr)
      port map (
         -- DMA Interface (dmaClk domain)
         dmaClk          => dmaClk,
         dmaRst          => dmaRst,
         dmaIbMaster     => dmaIbMasters(0),
         dmaIbSlave      => dmaIbSlaves(0),
         -- ADC/DAC Interface (dspClk domain)
         dspClk          => dspClk,
         dspRst          => dspRst,
         dspAdc          => dspAdc,
         dspDac          => dspDac,
         -- AXI-Lite Interface (axilClk domain)
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilWriteMaster => axilWriteMasters(APP_INDEX_C),
         axilWriteSlave  => axilWriteSlaves(APP_INDEX_C),
         axilReadMaster  => axilReadMasters(APP_INDEX_C),
         axilReadSlave   => axilReadSlaves(APP_INDEX_C));

   ----------------------
   --- Loopback Debugging
   ----------------------
   dmaIbMasters(1) <= dmaObMasters(1);
   dmaObSlaves(1)  <= dmaIbSlaves(1);

end top_level;
