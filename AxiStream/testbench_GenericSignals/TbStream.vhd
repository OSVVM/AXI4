--
--  File Name:         TbStream.vhd
--  Design Unit Name:  TbStream
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Top level testbench for AxiStreamTransmitter and AxiStreamReceiver
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    09/2024   2024.09    Added Local package instances to TbStream.vhd from testbench
--    07/2024   2024.07    Updated CreateClock
--    01/2023   2023.01    Added DUT (pass thru)
--    10/2020   2020.10    Updated name to be TbStream.vhd in conjunction with Model Indepenedent Transactions
--    01/2020   2020.01    Updated license notice
--    05/2018   2018.05    Initial revision
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2018 - 2024 by SynthWorks Design Inc.  
--  
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--  
--      https://www.apache.org/licenses/LICENSE-2.0
--  
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
--  
library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;

library osvvm ;
    context osvvm.OsvvmContext ;
    
library osvvm_AXI4 ;
    context osvvm_AXI4.AxiStreamContext ;
    
entity TbStream is
end entity TbStream ; 
architecture TestHarness of TbStream is

  constant tperiod_Clk : time := 10 ns ; 
  constant tpd         : time := 2 ns ; 

  signal Clk       : std_logic := '1' ;
  signal nReset    : std_logic ;
  
  
    package TX is new OSVVM_AXI4.AxiStreamGenericSignalsPkg
    generic map (
      AXI_DATA_WIDTH   =>  32 , 
      TID_MAX_WIDTH    =>  8 ,
      TDEST_MAX_WIDTH  =>  4 ,
      TUSER_MAX_WIDTH  =>  4 
    ) ;

  package RX is new OSVVM_AXI4.AxiStreamGenericSignalsPkg
    generic map (
      AXI_DATA_WIDTH   =>  32 , 
      TID_MAX_WIDTH    =>  8 ,
      TDEST_MAX_WIDTH  =>  4 ,
      TUSER_MAX_WIDTH  =>  4 
    ) ;

  component TestCtrl is
    generic ( 
      ID_LEN       : integer ;
      DEST_LEN     : integer ;
      USER_LEN     : integer 
    ) ;
    port (
      -- Global Signal Interface
      nReset          : In    std_logic ;

      -- Transaction Interfaces
      StreamTxRec     : inout StreamRecType ;
      StreamRxRec     : inout StreamRecType 
    ) ;
  end component TestCtrl ;

  
begin

  DUT : entity work.AxiStreamDut 
    port map (
      -- DUT Transmitter connects to Testbench RX VC
      TxTValid    =>   RX.TValid,
      TxTReady    =>   RX.TReady,
      TxTID       =>   RX.TID   ,
      TxTDest     =>   RX.TDest ,
      TxTUser     =>   RX.TUser ,
      TxTData     =>   RX.TData ,
      TxTStrb     =>   RX.TStrb ,
      TxTKeep     =>   RX.TKeep ,
      TxTLast     =>   RX.TLast ,

      -- DUT Rece iver connects to Testbench TX VC
      RxTValid    =>   TX.TValid,
      RxTReady    =>   TX.TReady,
      RxTID       =>   TX.TID   ,
      RxTDest     =>   TX.TDest ,
      RxTUser     =>   TX.TUser ,
      RxTData     =>   TX.TData ,
      RxTStrb     =>   TX.TStrb ,
      RxTKeep     =>   TX.TKeep ,
      RxTLast     =>   TX.TLast 
    ) ;

  -- create Clock 
  Osvvm.ClockResetPkg.CreateClock ( 
    Clk        => Clk, 
    Period     => Tperiod_Clk
  )  ; 
  
  -- create nReset 
  Osvvm.ClockResetPkg.CreateReset ( 
    Reset       => nReset,
    ResetActive => '0',
    Clk         => Clk,
    Period      => 7 * tperiod_Clk,
    tpd         => tpd
  ) ;
  
  Transmitter_1 : AxiStreamTransmitter 
    generic map (
      INIT_ID        => TX.INIT_ID  , 
      INIT_DEST      => TX.INIT_DEST, 
      INIT_USER      => TX.INIT_USER, 
      INIT_LAST      => 0,

      tperiod_Clk    => tperiod_Clk,

      tpd_Clk_TValid => tpd, 
      tpd_Clk_TID    => tpd, 
      tpd_Clk_TDest  => tpd, 
      tpd_Clk_TUser  => tpd, 
      tpd_Clk_TData  => tpd, 
      tpd_Clk_TStrb  => tpd, 
      tpd_Clk_TKeep  => tpd, 
      tpd_Clk_TLast  => tpd 
    ) 
    port map (
      -- Globals
      Clk       => Clk,
      nReset    => nReset,
      
      -- AXI Stream Interface
      -- From TB Transmitter to DUT Receiver
      TValid    => TX.TValid,
      TReady    => TX.TReady,
      TID       => TX.TID   ,
      TDest     => TX.TDest ,
      TUser     => TX.TUser ,
      TData     => TX.TData ,
      TStrb     => TX.TStrb ,
      TKeep     => TX.TKeep ,
      TLast     => TX.TLast ,

      -- Testbench Transaction Interface
      TransRec  => TX.TransRec
    ) ;
  
  Receiver_1 : AxiStreamReceiver
    generic map (
      tperiod_Clk    => tperiod_Clk,
      INIT_ID        => RX.INIT_ID  , 
      INIT_DEST      => RX.INIT_DEST, 
      INIT_USER      => RX.INIT_USER, 
      INIT_LAST      => 0,

      tpd_Clk_TReady => tpd  
    ) 
    port map (
      -- Globals
      Clk       => Clk,
      nReset    => nReset,
      
      -- AXI Stream Interface
      -- From TB Receiver to DUT Transmitter
      TValid    => RX.TValid,
      TReady    => RX.TReady,
      TID       => RX.TID   ,
      TDest     => RX.TDest ,
      TUser     => RX.TUser ,
      TData     => RX.TData ,
      TStrb     => RX.TStrb ,
      TKeep     => RX.TKeep ,
      TLast     => RX.TLast ,

      -- Testbench Transaction Interface
      TransRec  => RX.TransRec
    ) ;
  
  
  TestCtrl_1 : TestCtrl
  generic map ( 
    ID_LEN       => TX.TID'length,
    DEST_LEN     => TX.TDest'length,
    USER_LEN     => TX.TUser'length
  ) 
  port map ( 
    -- Globals
    nReset       => nReset,
    
    -- Testbench Transaction Interfaces
    StreamTxRec  => Tx.TransRec, 
    StreamRxRec  => RX.TransRec  
  ) ; 

end architecture TestHarness ;