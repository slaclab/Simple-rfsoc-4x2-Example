-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: RfDataConverter Module
-------------------------------------------------------------------------------
-- This file is part of 'SPACE SMURF RFSOC'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'SPACE SMURF RFSOC', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiStreamPkg.all;
use surf.AxiLitePkg.all;
use surf.SsiPkg.all;

library work;
use work.AppPkg.all;

library axi_soc_ultra_plus_core;
use axi_soc_ultra_plus_core.AxiSocUltraPlusPkg.all;

entity RfDataConverter is
   generic (
      TPD_G            : time := 1 ns;
      AXIL_BASE_ADDR_G : slv(31 downto 0));
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
      -- ADC/DAC Interface (dspClk domain)
      dspClk          : out sl;
      dspRst          : out sl;
      dspAdc          : out Slv256Array(3 downto 0);
      dspDac          : in  Slv256Array(1 downto 0);
      -- AXI-Lite Interface (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType);
end RfDataConverter;

architecture mapping of RfDataConverter is

COMPONENT RfDataConverterIpCore
  PORT (
    adc0_clk_p : IN STD_LOGIC;
    adc0_clk_n : IN STD_LOGIC;
    clk_adc0 : OUT STD_LOGIC;
    adc2_clk_p : IN STD_LOGIC;
    adc2_clk_n : IN STD_LOGIC;
    clk_adc2 : OUT STD_LOGIC;
    dac0_clk_p : IN STD_LOGIC;
    dac0_clk_n : IN STD_LOGIC;
    clk_dac0 : OUT STD_LOGIC;
    dac2_clk_p : IN STD_LOGIC;
    dac2_clk_n : IN STD_LOGIC;
    clk_dac2 : OUT STD_LOGIC;
    s_axi_aclk : IN STD_LOGIC;
    s_axi_aresetn : IN STD_LOGIC;
    s_axi_awaddr : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    s_axi_awvalid : IN STD_LOGIC;
    s_axi_awready : OUT STD_LOGIC;
    s_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_wvalid : IN STD_LOGIC;
    s_axi_wready : OUT STD_LOGIC;
    s_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_bvalid : OUT STD_LOGIC;
    s_axi_bready : IN STD_LOGIC;
    s_axi_araddr : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    s_axi_arvalid : IN STD_LOGIC;
    s_axi_arready : OUT STD_LOGIC;
    s_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_rvalid : OUT STD_LOGIC;
    s_axi_rready : IN STD_LOGIC;
    irq : OUT STD_LOGIC;
    sysref_in_p : IN STD_LOGIC;
    sysref_in_n : IN STD_LOGIC;
    vin0_01_p : IN STD_LOGIC;
    vin0_01_n : IN STD_LOGIC;
    vin0_23_p : IN STD_LOGIC;
    vin0_23_n : IN STD_LOGIC;
    vin2_01_p : IN STD_LOGIC;
    vin2_01_n : IN STD_LOGIC;
    vin2_23_p : IN STD_LOGIC;
    vin2_23_n : IN STD_LOGIC;
    vout00_p : OUT STD_LOGIC;
    vout00_n : OUT STD_LOGIC;
    vout20_p : OUT STD_LOGIC;
    vout20_n : OUT STD_LOGIC;
    m0_axis_aresetn : IN STD_LOGIC;
    m0_axis_aclk : IN STD_LOGIC;
    m00_axis_tdata : OUT STD_LOGIC_VECTOR(191 DOWNTO 0);
    m00_axis_tvalid : OUT STD_LOGIC;
    m00_axis_tready : IN STD_LOGIC;
    m02_axis_tdata : OUT STD_LOGIC_VECTOR(191 DOWNTO 0);
    m02_axis_tvalid : OUT STD_LOGIC;
    m02_axis_tready : IN STD_LOGIC;
    m2_axis_aresetn : IN STD_LOGIC;
    m2_axis_aclk : IN STD_LOGIC;
    m20_axis_tdata : OUT STD_LOGIC_VECTOR(191 DOWNTO 0);
    m20_axis_tvalid : OUT STD_LOGIC;
    m20_axis_tready : IN STD_LOGIC;
    m22_axis_tdata : OUT STD_LOGIC_VECTOR(191 DOWNTO 0);
    m22_axis_tvalid : OUT STD_LOGIC;
    m22_axis_tready : IN STD_LOGIC;
    s0_axis_aresetn : IN STD_LOGIC;
    s0_axis_aclk : IN STD_LOGIC;
    s00_axis_tdata : IN STD_LOGIC_VECTOR(255 DOWNTO 0);
    s00_axis_tvalid : IN STD_LOGIC;
    s00_axis_tready : OUT STD_LOGIC;
    s2_axis_aresetn : IN STD_LOGIC;
    s2_axis_aclk : IN STD_LOGIC;
    s20_axis_tdata : IN STD_LOGIC_VECTOR(255 DOWNTO 0);
    s20_axis_tvalid : IN STD_LOGIC;
    s20_axis_tready : OUT STD_LOGIC
  );
END COMPONENT;

   signal rfdcAdc   : Slv192Array(3 downto 0) := (others => (others => '0'));
   signal rfdcValid : slv(3 downto 0)         := (others => '0');
   signal rfdcDac   : Slv256Array(1 downto 0) := (others => (others => '0'));

   signal adc      : Slv192Array(3 downto 0) := (others => (others => '0'));
   signal adcValid : slv(3 downto 0)         := (others => '0');

   signal refClk   : sl := '0';
   signal axilRstL : sl := '0';

   signal rfdcClk  : sl := '0';
   signal rfdcRst  : sl := '1';
   signal rfdcRstL : sl := '0';

   signal dspClock  : sl := '0';
   signal dspReset  : sl := '1';
   signal dspResetL : sl := '0';

begin

   U_IpCore : RfDataConverterIpCore
      port map (
         -- Clock Ports
         adc0_clk_p      => adcClkP(0),
         adc0_clk_n      => adcClkN(0),
         adc2_clk_p      => adcClkP(1),
         adc2_clk_n      => adcClkN(1),
         clk_adc0        => refClk,
         clk_adc2        => open,
         dac0_clk_p      => dacClkP(0),
         dac0_clk_n      => dacClkN(0),
         dac2_clk_p      => dacClkP(1),
         dac2_clk_n      => dacClkN(1),
         clk_dac0        => open,
         clk_dac2        => open,
         -- AXI-Lite Ports
         s_axi_aclk      => axilClk,
         s_axi_aresetn   => axilRstL,
         s_axi_awaddr    => axilWriteMaster.awaddr(17 downto 0),
         s_axi_awvalid   => axilWriteMaster.awvalid,
         s_axi_awready   => axilWriteSlave.awready,
         s_axi_wdata     => axilWriteMaster.wdata,
         s_axi_wstrb     => axilWriteMaster.wstrb,
         s_axi_wvalid    => axilWriteMaster.wvalid,
         s_axi_wready    => axilWriteSlave.wready,
         s_axi_bresp     => axilWriteSlave.bresp,
         s_axi_bvalid    => axilWriteSlave.bvalid,
         s_axi_bready    => axilWriteMaster.bready,
         s_axi_araddr    => axilReadMaster.araddr(17 downto 0),
         s_axi_arvalid   => axilReadMaster.arvalid,
         s_axi_arready   => axilReadSlave.arready,
         s_axi_rdata     => axilReadSlave.rdata,
         s_axi_rresp     => axilReadSlave.rresp,
         s_axi_rvalid    => axilReadSlave.rvalid,
         s_axi_rready    => axilReadMaster.rready,
         -- Misc. Ports
         irq             => open,
         sysref_in_p     => sysRefP,
         sysref_in_n     => sysRefN,
         -- ADC Ports
         vin0_01_p       => adcP(0),
         vin0_01_n       => adcN(0),
         vin0_23_p       => adcP(1),
         vin0_23_n       => adcN(1),
         vin2_01_p       => adcP(2),
         vin2_01_n       => adcN(2),
         vin2_23_p       => adcP(3),
         vin2_23_n       => adcN(3),
         -- DAC Ports
         vout00_p        => dacP(0),
         vout00_n        => dacN(0),
         vout20_p        => dacP(1),
         vout20_n        => dacN(1),
         -- ADC[1:0] AXI Stream Interface
         m0_axis_aresetn => rfdcRstL,
         m0_axis_aclk    => rfdcClk,
         m00_axis_tdata  => rfdcAdc(0),
         m00_axis_tvalid => rfdcValid(0),
         m00_axis_tready => '1',
         m02_axis_tdata  => rfdcAdc(1),
         m02_axis_tvalid => rfdcValid(1),
         m02_axis_tready => '1',
         -- ADC[3:2] AXI Stream Interface
         m2_axis_aresetn => rfdcRstL,
         m2_axis_aclk    => rfdcClk,
         m20_axis_tdata  => rfdcAdc(2),
         m20_axis_tvalid => rfdcValid(2),
         m20_axis_tready => '1',
         m22_axis_tdata  => rfdcAdc(3),
         m22_axis_tvalid => rfdcValid(3),
         m22_axis_tready => '1',
         -- DAC[0] AXI Stream Interface
         s0_axis_aresetn => dspResetL,
         s0_axis_aclk    => dspClock,
         s00_axis_tdata  => rfdcDac(0),
         s00_axis_tvalid => '1',
         s00_axis_tready => open,
         -- DAC[1] AXI Stream Interface
         s2_axis_aresetn => dspResetL,
         s2_axis_aclk    => dspClock,
         s20_axis_tdata  => rfdcDac(1),
         s20_axis_tvalid => '1',
         s20_axis_tready => open);

   U_Pll : entity surf.ClockManagerUltraScale
      generic map(
         TPD_G             => TPD_G,
         TYPE_G            => "PLL",
         INPUT_BUFG_G      => false,
         FB_BUFG_G         => true,
         RST_IN_POLARITY_G => '1',
         NUM_CLOCKS_G      => 2,
         -- MMCM attributes
         CLKIN_PERIOD_G    => 3.2,      -- 312.5 MHz
         CLKFBOUT_MULT_G   => 4,        -- 1.25 GHz = 4 x 312.5 MHz
         CLKOUT0_DIVIDE_G  => 3,        -- 416.667 MHz = 1.25GHz/3
         CLKOUT1_DIVIDE_G  => 4)        -- 312.5 MHz = 1.25GHz/4
      port map(
         -- Clock Input
         clkIn     => refClk,
         rstIn     => axilRst,
         -- Clock Outputs
         clkOut(0) => rfdcClk,
         clkOut(1) => dspClock,
         -- Reset Outputs
         rstOut(0) => rfdcRst,
         rstOut(1) => dspReset);

   axilRstL  <= not(axilRst);
   rfdcRstL  <= not(rfdcRst);
   dspResetL <= not(dspReset);

   dspClk <= dspClock;
   dspRst <= dspReset;

   process(rfdcClk)
   begin
      -- Help with making timing
      if rising_edge(rfdcClk) then
         adc      <= rfdcAdc   after TPD_G;
         adcValid <= rfdcValid after TPD_G;
      end if;
   end process;

   process(dspClock)
   begin
      -- Help with making timing
      if rising_edge(dspClock) then
         rfdcDac <= dspDac after TPD_G;
      end if;
   end process;

   GEN_VEC :
   for i in 3 downto 0 generate

      --------------
      -- ADC Gearbox
      --------------
      U_Gearbox_ADC : entity surf.AsyncGearbox
         generic map (
            TPD_G              => TPD_G,
            SLAVE_WIDTH_G      => 192,
            MASTER_WIDTH_G     => 256,
            EN_EXT_CTRL_G      => false,
            -- Async FIFO generics
            FIFO_MEMORY_TYPE_G => "block",
            FIFO_ADDR_WIDTH_G  => 8)
         port map (
            -- Slave Interface
            slaveClk    => rfdcClk,
            slaveRst    => rfdcRst,
            slaveData   => adc(i),
            slaveValid  => adcValid(i),
            slaveReady  => open,
            -- Master Interface
            masterClk   => dspClock,
            masterRst   => dspReset,
            masterData  => dspAdc(i),
            masterValid => open,
            masterReady => '1');

   end generate GEN_VEC;

end mapping;