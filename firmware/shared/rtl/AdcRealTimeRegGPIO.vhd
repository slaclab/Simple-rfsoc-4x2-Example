library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
entity AdcRealTimeRegGPIO is
   generic (
      TPD_G              : time             := 1 ns;
      RST_ASYNC_G        : boolean          := false);
   port (
      -- AXI-Lite Interface
      axiClk         : in    sl;
      axiRst         : in    sl;
      axiReadMaster  : in    AxiLiteReadMasterType;
      axiReadSlave   : out   AxiLiteReadSlaveType;
      axiWriteMaster : in    AxiLiteWriteMasterType;
      axiWriteSlave  : out   AxiLiteWriteSlaveType;

      -- ADC Real-Time Ports
      -- axilClk domain ports
      adcClearOv     : out   slv(3 downto 0);
      adcClearOr     : out   slv(3 downto 0);

      -- async clk domain ports
      adcCmOvVolt    : in slv(3 downto 0);
      adcCmUnVolt    : in slv(3 downto 0);
      adcDatOvfl     : in slv(3 downto 0);
      adcOvVolt      : in slv(3 downto 0);
      adcOvRange     : in slv(3 downto 0);
      
      -- ADC Clk_x ports
      clk_adc0       : in sl;
      adcPlEvent_0   : out sl;
      adcOvThresh1_0 : in sl;
      adcOvThresh2_0 : in sl;

      clk_adc1       : in sl;
      adcPlEvent_1   : out sl;
      adcOvThresh1_1 : in sl;
      adcOvThresh2_1 : in sl;

      clk_adc2       : in sl;
      adcPlEvent_2   : out sl;
      adcOvThresh1_2 : in sl;
      adcOvThresh2_2 : in sl;
      
      clk_adc3       : in sl;
      adcPlEvent_2   : out sl;
      adcPlEvent_3   : out sl;
      adcOvThresh1_3 : in sl
      );

end AdcRealTimeRegGPIO;
architecture rtl of AdcRealTimeRegGPIO is
   type RegType is record
      adcClearOv       : slv(3 downto 0);
      adcClearOr       : slv(3 downto 0);
      adcCmOvVolt      : slv(3 downto 0);
      adcCmUnVolt      : slv(3 downto 0);
      adcDatOvfl       : slv(3 downto 0);
      adcOvVolt        : slv(3 downto 0);
      adcOvRange       : slv(3 downto 0);
      adcPlEvent_0     : sl;
      adcOvThresh1_0   : sl;
      adcOvThresh2_0   : sl;
      adcPlEvent_1     : sl;
      adcOvThresh1_1   : sl;
      adcOvThresh2_1   : sl;
      adcPlEvent_2     : sl;
      adcOvThresh1_2   : sl;
      adcOvThresh2_2   : sl;
      adcPlEvent_3     : sl;
      adcPlEvent_3     : sl;
      adcOvThresh1_3   : sl;
      axiReadSlave     : AxiLiteReadSlaveType;
      axiWriteSlave    : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      adcClearOv     => '0000',
      adcClearOr     => '0000',
      adcCmOvVolt    => '0000',
      adcCmUnVolt    => '0000',
      adcDatOvfl     => '0000',
      adcOvVolt      => '0000',
      adcOvRange     => '0000',
      adcPlEvent_0   => '0',
      adcOvThresh1_0 => '0',
      adcOvThresh2_0 => '0',
      adcPlEvent_1   => '0',
      adcOvThresh1_1 => '0',
      adcOvThresh2_1 => '0',
      adcPlEvent_2   => '0',
      adcOvThresh1_2 => '0',
      adcOvThresh2_2 => '0',
      adcPlEvent_3   => '0',
      adcPlEvent_3   => '0',
      adcOvThresh1_3 => '0',
      axiReadSlave   => AXI_LITE_READ_SLAVE_INIT_C,
      axiWriteSlave  => AXI_LITE_WRITE_SLAVE_INIT_C);

   signal r                : RegType := REG_INIT_C;
   signal rin              : RegType;
   signal adcPlEvent_0Sync : sl;
   signal adcPlEvent_1Sync : sl;
   signal adcPlEvent_2Sync : sl;
   signal adcPlEvent_3Sync : sl;

begin
   U_sync_adc_0 : entity surf.SynchronizerVector
      generic map (
         TPD_G   => TPD_G,
         RST_ASYNC_G => RST_ASYNC_G,
         WIDTH_G => 3)
      port map (
         clk         => clk_adc0,
         -- Data in
         dataIn   => adcPlEvent_0,
         -- Data out
         dataOut  => adcPlEvent_0Sync);

   U_sync_adc_1 : entity surf.SynchronizerVector
      generic map (
         TPD_G   => TPD_G,
         RST_ASYNC_G => RST_ASYNC_G,
         WIDTH_G => 3)
      port map (
         clk         => clk_adc1,
         -- Data in
         dataIn   => adcPlEvent_1,
         -- Data out
         dataOut  => adcPlEvent_1Sync);

   U_sync_adc_2 : entity surf.SynchronizerVector
      generic map (
         TPD_G   => TPD_G,
         RST_ASYNC_G => RST_ASYNC_G,
         WIDTH_G => 3)
      port map (
         clk         => clk_adc2,
         -- Data in
         dataIn   => adcPlEvent_2,
         -- Data out
         dataOut  => adcPlEvent_2Sync);

   U_sync_adc_3 : entity surf.SynchronizerVector
      generic map (
         TPD_G   => TPD_G,
         RST_ASYNC_G => RST_ASYNC_G,
         WIDTH_G => 3)
      port map (
         clk         => clk_adc3,
         -- Data in
         dataIn   => adcPlEvent_3,
         -- Data out
         dataOut  => adcPlEvent_3Sync);




   comb : process (axiWriteMaster, axiReadMaster, axiRst) is
      variable v      : RegType;
      variable axilEp : AxiLiteEndpointType;
   begin
      -- Latch the current value
      v := r;
      -- Reset strobes
      v.clrA := '0';
      v.clrB := '0';
         
      ------------------------
      -- AXI-Lite Transactions
      ------------------------
      -- Determine the transaction type
      axiSlaveWaitTxn(axilEp, axiWriteMaster, axiReadMaster, v.axiWriteSlave, v.axiReadSlave);
      -- read only registers
      axiSlaveRegisterR(axilEp, x"00", 0, adcCmOvVolt_0);
      axiSlaveRegisterR(axilEp, x"00", 1, adcCmOvVolt_1);
      axiSlaveRegisterR(axilEp, x"00", 2, adcCmOvVolt_2);
      axiSlaveRegisterR(axilEp, x"00", 3, adcCmOvVolt_3);

      axiSlaveRegisterR(axilEp, x"04", 0, adcCmUnVolt_0);
      axiSlaveRegisterR(axilEp, x"04", 1, adcCmUnVolt_1);
      axiSlaveRegisterR(axilEp, x"04", 2, adcCmUnVolt_2);
      axiSlaveRegisterR(axilEp, x"04", 3, adcCmUnVolt_3);

      axiSlaveRegisterR(axilEp, x"08", 0, adcDatOvfl_0);
      axiSlaveRegisterR(axilEp, x"08", 1, adcDatOvfl_1);
      axiSlaveRegisterR(axilEp, x"08", 2, adcDatOvfl_2);
      axiSlaveRegisterR(axilEp, x"08", 3, adcDatOvfl_3);

      axiSlaveRegisterR(axilEp, x"0C", 0, adcOvVolt_0);
      axiSlaveRegisterR(axilEp, x"0C", 1, adcOvVolt_1);
      axiSlaveRegisterR(axilEp, x"0C", 2, adcOvVolt_2);
      axiSlaveRegisterR(axilEp, x"0C", 3, adcOvVolt_3);     

      axiSlaveRegisterR(axilEp, x"10", 0, adcOvRange_0);
      axiSlaveRegisterR(axilEp, x"10", 1, adcOvRange_1);
      axiSlaveRegisterR(axilEp, x"10", 2, adcOvRange_2);
      axiSlaveRegisterR(axilEp, x"10", 3, adcOvRange_3);  
      
      axiSlaveRegisterR(axilEp, x"18", 0, adcOvThresh1_0);
      axiSlaveRegisterR(axilEp, x"18", 1, adcOvThresh1_1);
      axiSlaveRegisterR(axilEp, x"18", 2, adcOvThresh1_2);
      axiSlaveRegisterR(axilEp, x"18", 3, adcOvThresh1_3);  
            
      axiSlaveRegisterR(axilEp, x"1C", 0, adcOvThresh2_0);
      axiSlaveRegisterR(axilEp, x"1C", 1, adcOvThresh2_1);
      axiSlaveRegisterR(axilEp, x"1C", 2, adcOvThresh2_2);
      axiSlaveRegisterR(axilEp, x"1C", 3, adcOvThresh2_3);
      
      -- write only registers
      axiSlaveRegister(axilEp, x"14", 0, adcPlEvent_0Sync);
      axiSlaveRegister(axilEp, x"14", 1, adcPlEvent_1Sync);
      axiSlaveRegister(axilEp, x"14", 2, adcPlEvent_2Sync);
      axiSlaveRegister(axilEp, x"14", 3, adcPlEvent_3Sync);

      axiSlaveRegister(axilEp, x"04", 0, v.clrA);
      axiSlaveRegister(axilEp, x"08", 0, v.clrB);
      -- Close the transaction
      axiSlaveDefault(axilEp, v.axiWriteSlave, v.axiReadSlave, AXI_RESP_DECERR_C);
      --------
      -- Reset
      --------
      if (RST_ASYNC_G = false and axiRst = '1') then
         v := REG_INIT_C;
      end if;
      -- Register the variable for next clock cycle
      rin <= v;
      -- Outputs
      axiReadSlave   <= r.axiReadSlave;
      axiWriteSlave  <= r.axiWriteSlave;
      clrA     <= r.clrA;
      clrB <= r.clrB;
   end process comb;
   seq : process (axiClk, axiRst) is
   begin
      if (RST_ASYNC_G and axiRst = '1') then
         r <= REG_INIT_C after TPD_G;
      elsif rising_edge(axiClk) then
         r <= rin after TPD_G;
      end if;
   end process seq;
end architecture rtl;
