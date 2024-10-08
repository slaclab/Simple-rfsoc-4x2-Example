-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: RfDataConverter Module
-------------------------------------------------------------------------------
-- This file is part of 'Simple-rfsoc-4x2-Example'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'Simple-rfsoc-4x2-Example', including this file,
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
      adcClkP         : in  slv(1 downto 0);
      adcClkN         : in  slv(1 downto 0);
      adcP            : in  slv(3 downto 0);
      adcN            : in  slv(3 downto 0);
      dacClkP         : in  slv(1 downto 0);
      dacClkN         : in  slv(1 downto 0);
      dacP            : out slv(1 downto 0);
      dacN            : out slv(1 downto 0);
      sysRefP         : in  sl;
      sysRefN         : in  sl;
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
      axilReadSlave   : out AxiLiteReadSlaveType;
      -- ADC Real-Time Signal Interface Ports
       -- adcClk domain
      adcPlEvent      : in  slv(3 downto 0);
      adcOvThresh1    : out slv(3 downto 0);
      adcOvThresh2    : out slv(3 downto 0);
      -- axilClk domain
      adcClearOv      : in slv(3 downto 0);
      adcClearOr      : in slv(3 downto 0);
      -- async
      adcCmOvVolt     : out slv(3 downto 0);
      adcCmUnVolt     : out slv(3 downto 0);
      adcDatOvfl      : out slv(3 downto 0);
      adcOvVolt       : out slv(3 downto 0);
      adcOvRange      : out slv(3 downto 0));
end RfDataConverter;

architecture mapping of RfDataConverter is

   component RfDataConverterIpCore
      port (
         adc0_clk_p               : in  std_logic;
         adc0_clk_n               : in  std_logic;
         clk_adc0                 : out std_logic;
         adc2_clk_p               : in  std_logic;
         adc2_clk_n               : in  std_logic;
         clk_adc2                 : out std_logic;
         dac0_clk_p               : in  std_logic;
         dac0_clk_n               : in  std_logic;
         clk_dac0                 : out std_logic;
         dac2_clk_p               : in  std_logic;
         dac2_clk_n               : in  std_logic;
         clk_dac2                 : out std_logic;
         s_axi_aclk               : in  std_logic;
         s_axi_aresetn            : in  std_logic;
         s_axi_awaddr             : in  std_logic_vector(17 downto 0);
         s_axi_awvalid            : in  std_logic;
         s_axi_awready            : out std_logic;
         s_axi_wdata              : in  std_logic_vector(31 downto 0);
         s_axi_wstrb              : in  std_logic_vector(3 downto 0);
         s_axi_wvalid             : in  std_logic;
         s_axi_wready             : out std_logic;
         s_axi_bresp              : out std_logic_vector(1 downto 0);
         s_axi_bvalid             : out std_logic;
         s_axi_bready             : in  std_logic;
         s_axi_araddr             : in  std_logic_vector(17 downto 0);
         s_axi_arvalid            : in  std_logic;
         s_axi_arready            : out std_logic;
         s_axi_rdata              : out std_logic_vector(31 downto 0);
         s_axi_rresp              : out std_logic_vector(1 downto 0);
         s_axi_rvalid             : out std_logic;
         s_axi_rready             : in  std_logic;
         irq                      : out std_logic;
         sysref_in_p              : in  std_logic;
         sysref_in_n              : in  std_logic;
         vin0_01_p                : in  std_logic;
         vin0_01_n                : in  std_logic;
         vin0_23_p                : in  std_logic;
         vin0_23_n                : in  std_logic;
         vin2_01_p                : in  std_logic;
         vin2_01_n                : in  std_logic;
         vin2_23_p                : in  std_logic;
         vin2_23_n                : in  std_logic;
         vout00_p                 : out std_logic;
         vout00_n                 : out std_logic;
         vout20_p                 : out std_logic;
         vout20_n                 : out std_logic;
         adc00_pl_event           : in  std_logic;
         adc00_datapath_overflow  : out std_logic;
         adc02_pl_event           : in  std_logic;
         adc02_datapath_overflow  : out std_logic;
         adc20_pl_event           : in  std_logic;
         adc20_datapath_overflow  : out std_logic;
         adc22_pl_event           : in  std_logic;
         adc22_datapath_overflow  : out std_logic; 
         adc0_01_over_voltage     : out std_logic;
         adc0_01_clear_ov         : in std_logic;
         adc0_01_clear_or         : in std_logic;
         adc0_01_over_range       : out std_logic;
         adc0_01_over_threshold1  : out std_logic;
         adc0_01_over_threshold2  : out std_logic;
         adc0_01_cm_over_voltage  : out std_logic;
         adc0_01_cm_under_voltage : out std_logic;
         adc0_23_over_voltage     : out std_logic;
         adc0_23_clear_ov         : in std_logic;
         adc0_23_clear_or         : in std_logic;
         adc0_23_over_range       : out std_logic;
         adc0_23_over_threshold1  : out std_logic;
         adc0_23_over_threshold2  : out std_logic;
         adc0_23_cm_over_voltage  : out std_logic;
         adc0_23_cm_under_voltage : out std_logic;
         adc2_01_over_voltage     : out std_logic;
         adc2_01_clear_ov         : in std_logic;
         adc2_01_clear_or         : in std_logic;
         adc2_01_over_range       : out std_logic;
         adc2_01_over_threshold1  : out std_logic;
         adc2_01_over_threshold2  : out std_logic;
         adc2_01_cm_over_voltage  : out std_logic;
         adc2_01_cm_under_voltage : out std_logic;
         adc2_23_over_voltage     : out std_logic;
         adc2_23_clear_ov         : in std_logic;
         adc2_23_clear_or         : in std_logic;
         adc2_23_over_range       : out std_logic;
         adc2_23_over_threshold1  : out std_logic;
         adc2_23_over_threshold2  : out std_logic;
         adc2_23_cm_over_voltage  : out std_logic;
         adc2_23_cm_under_voltage : out std_logic;
         m0_axis_aresetn          : in  std_logic;
         m0_axis_aclk             : in  std_logic;
         m00_axis_tdata           : out std_logic_vector(191 downto 0);
         m00_axis_tvalid          : out std_logic;
         m00_axis_tready          : in  std_logic;
         m02_axis_tdata           : out std_logic_vector(191 downto 0);
         m02_axis_tvalid          : out std_logic;
         m02_axis_tready          : in  std_logic;
         m2_axis_aresetn          : in  std_logic;
         m2_axis_aclk             : in  std_logic;
         m20_axis_tdata           : out std_logic_vector(191 downto 0);
         m20_axis_tvalid          : out std_logic;
         m20_axis_tready          : in  std_logic;
         m22_axis_tdata           : out std_logic_vector(191 downto 0);
         m22_axis_tvalid          : out std_logic;
         m22_axis_tready          : in  std_logic;
         s0_axis_aresetn          : in  std_logic;
         s0_axis_aclk             : in  std_logic;
         s00_axis_tdata           : in  std_logic_vector(255 downto 0);
         s00_axis_tvalid          : in  std_logic;
         s00_axis_tready          : out std_logic;
         s2_axis_aresetn          : in  std_logic;
         s2_axis_aclk             : in  std_logic;
         s20_axis_tdata           : in  std_logic_vector(255 downto 0);
         s20_axis_tvalid          : in  std_logic;
         s20_axis_tready          : out std_logic
         );
   end component;

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
         -- ADC Tile 0, Converters [1:0] Real-Time Interface
         adc00_pl_event  => adcPlEvent(0),
         adc00_datapath_overflow => adcDatOvfl(0),
         adc0_01_over_voltage => adcOvVolt(0),
         adc0_01_clear_ov => adcClearOv(0),
         adc0_01_clear_or => adcClearOr(0),
         adc0_01_over_range => adcOvRange(0),
         adc0_01_over_threshold1 => adcOvThresh1(0),
         adc0_01_over_threshold2 => adcOvThresh2(0),
         adc0_01_cm_over_voltage => adcCmOvVolt(0),
         adc0_01_cm_under_voltage => adcCmUnVolt(0),
         -- ADC Tile 1, Converters [3:2] Real-Time Interface
         adc02_pl_event  => adcPlEvent(1),
         adc02_datapath_overflow => adcDatOvfl(1),
         adc0_23_over_voltage => adcOvVolt(1),
         adc0_23_clear_ov => adcClearOv(1),
         adc0_23_clear_or => adcClearOr(1),
         adc0_23_over_range => adcOvRange(1),
         adc0_23_over_threshold1 => adcOvThresh1(1),
         adc0_23_over_threshold2 => adcOvThresh2(1),
         adc0_23_cm_over_voltage => adcCmOvVolt(1),
         adc0_23_cm_under_voltage => adcCmUnVolt(1),
         -- ADC Tile 2, Converters [1:0] Real-Time Interface
         adc20_pl_event  => adcPlEvent(2),
         adc20_datapath_overflow => adcDatOvfl(2),
         adc2_01_over_voltage => adcOvVolt(2),
         adc2_01_clear_ov => adcClearOv(2),
         adc2_01_clear_or => adcClearOr(2),
         adc2_01_over_range => adcOvRange(2),
         adc2_01_over_threshold1 => adcOvThresh1(2),
         adc2_01_over_threshold2 => adcOvThresh2(2),
         adc2_01_cm_over_voltage => adcCmOvVolt(2),
         adc2_01_cm_under_voltage => adcCmUnVolt(2),
         -- ADC Tile 3, Converters [3:2] Real-Time Interface
         adc22_pl_event  => adcPlEvent(3),
         adc22_datapath_overflow => adcDatOvfl(3),
         adc2_23_over_voltage => adcOvVolt(3),
         adc2_23_clear_ov => adcClearOv(3),
         adc2_23_clear_or => adcClearOr(3),
         adc2_23_over_range => adcOvRange(3),
         adc2_23_over_threshold1 => adcOvThresh1(3),
         adc2_23_over_threshold2 => adcOvThresh2(3),
         adc2_23_cm_over_voltage => adcCmOvVolt(3),
         adc2_23_cm_under_voltage => adcCmUnVolt(3),            
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
         -----------------------------------------
         -- Reserve Order to match PCB silkscreen:
         -----------------------------------------
         -- DAC_A = CH[0] = DAC_VOUT0_230
         -- DAC_B = CH[1] = DAC_VOUT0_228
         -----------------------------------------
         rfdcDac(0) <= dspDac(1) after TPD_G;
         rfdcDac(1) <= dspDac(0) after TPD_G;
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
            -----------------------------------------
            -- Reserve Order to match PCB silkscreen:
            -----------------------------------------
            -- ADC_A = CH[0] = ADC_VIN_I23_226
            -- ADC_B = CH[1] = ADC_VIN_I01_226
            -- ADC_C = CH[2] = ADC_VIN_I23_224
            -- ADC_D = CH[3] = ADC_VIN_I01_224
            -----------------------------------------
            slaveData   => adc(3-i),
            slaveValid  => adcValid(3-i),
            slaveReady  => open,
            -- Master Interface
            masterClk   => dspClock,
            masterRst   => dspReset,
            masterData  => dspAdc(i),
            masterValid => open,
            masterReady => '1');

   end generate GEN_VEC;

end mapping;
