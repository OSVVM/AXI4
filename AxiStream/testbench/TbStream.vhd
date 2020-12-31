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
--    05/2018   2018.05    Initial revision
--    01/2020   2020.01    Updated license notice
--    10/2020   2020.10    Updated name to be TbStream.vhd in conjunction with Model Indepenedent Transactions
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2018 - 2020 by SynthWorks Design Inc.  
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

  signal Clk       : std_logic ;
  signal nReset    : std_logic ;
  
  constant AXI_DATA_WIDTH   : integer := 32 ;
  constant AXI_BYTE_WIDTH   : integer := AXI_DATA_WIDTH/8 ; 
  constant TID_MAX_WIDTH    : integer := 8 ;
  constant TDEST_MAX_WIDTH  : integer := 4 ;
  constant TUSER_MAX_WIDTH  : integer := 4 ;

  constant INIT_ID     : std_logic_vector(TID_MAX_WIDTH-1 downto 0)   := (others => '0') ; 
  constant INIT_DEST   : std_logic_vector(TDEST_MAX_WIDTH-1 downto 0) := (others => '0') ; 
  constant INIT_USER   : std_logic_vector(TUSER_MAX_WIDTH-1 downto 0) := (others => '0') ; 
  
  signal TValid    : std_logic ;
  signal TReady    : std_logic ; 
  signal TID       : std_logic_vector(TID_MAX_WIDTH-1 downto 0) ; 
  signal TDest     : std_logic_vector(TDEST_MAX_WIDTH-1 downto 0) ; 
  signal TUser     : std_logic_vector(TUSER_MAX_WIDTH-1 downto 0) ; 
  signal TData     : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ; 
  signal TStrb     : std_logic_vector(AXI_BYTE_WIDTH-1 downto 0) ; 
  signal TKeep     : std_logic_vector(AXI_BYTE_WIDTH-1 downto 0) ; 
  signal TLast     : std_logic ; 
  
  constant AXI_PARAM_WIDTH : integer := TID_MAX_WIDTH + TDEST_MAX_WIDTH + TUSER_MAX_WIDTH + 1 ;

  signal StreamTxRec, StreamRxRec : StreamRecType(
      DataToModel   (AXI_DATA_WIDTH-1  downto 0),
      DataFromModel (AXI_DATA_WIDTH-1  downto 0),
      ParamToModel  (AXI_PARAM_WIDTH-1 downto 0),
      ParamFromModel(AXI_PARAM_WIDTH-1 downto 0)
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

  -- create Clock 
  Osvvm.TbUtilPkg.CreateClock ( 
    Clk        => Clk, 
    Period     => Tperiod_Clk 
  )  ; 
  
  -- create nReset 
  Osvvm.TbUtilPkg.CreateReset ( 
    Reset       => nReset,
    ResetActive => '0',
    Clk         => Clk,
    Period      => 7 * tperiod_Clk,
    tpd         => tpd
  ) ;
  
  Transmitter_1 : AxiStreamTransmitter 
    generic map (
      INIT_ID        => INIT_ID  , 
      INIT_DEST      => INIT_DEST, 
      INIT_USER      => INIT_USER, 
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
      TValid    => TValid,
      TReady    => TReady,
      TID       => TID   ,
      TDest     => TDest ,
      TUser     => TUser ,
      TData     => TData ,
      TStrb     => TStrb ,
      TKeep     => TKeep ,
      TLast     => TLast ,

      -- Testbench Transaction Interface
      TransRec  => StreamTxRec
    ) ;
  
  Receiver_1 : AxiStreamReceiver
    generic map (
      tperiod_Clk    => tperiod_Clk,
      INIT_ID        => INIT_ID  , 
      INIT_DEST      => INIT_DEST, 
      INIT_USER      => INIT_USER, 
      INIT_LAST      => 0,

      tpd_Clk_TReady => tpd  
    ) 
    port map (
      -- Globals
      Clk       => Clk,
      nReset    => nReset,
      
      -- AXI Stream Interface
      TValid    => TValid,
      TReady    => TReady,
      TID       => TID   ,
      TDest     => TDest ,
      TUser     => TUser ,
      TData     => TData ,
      TStrb     => TStrb ,
      TKeep     => TKeep ,
      TLast     => TLast ,

      -- Testbench Transaction Interface
      TransRec  => StreamRxRec
    ) ;
  
  
  TestCtrl_1 : TestCtrl
  generic map ( 
    ID_LEN       => TID'length,
    DEST_LEN     => TDest'length,
    USER_LEN     => TUser'length
  ) 
  port map ( 
    -- Globals
    nReset       => nReset,
    
    -- Testbench Transaction Interfaces
    StreamTxRec  => StreamTxRec, 
    StreamRxRec  => StreamRxRec  
  ) ; 

end architecture TestHarness ;