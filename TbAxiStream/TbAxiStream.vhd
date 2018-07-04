--
--  File Name:         TbAxiStream.vhd
--  Design Unit Name:  TbAxiStream
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Simple AXI Lite Master Model
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date       Version    Description
--    05/2018:   2018.05       Initial revision
--
--
-- Copyright 2018 SynthWorks Design Inc
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;

library osvvm ;
    context osvvm.OsvvmContext ;
    
  use work.Axi4CommonPkg.all ; 
  use work.AxiStreamTransactionPkg.all ; 

entity TbAxiStream is
end entity TbAxiStream ; 
architecture TestHarness of TbAxiStream is
  constant AXI_DATA_WIDTH   : integer := 32 ; 
  constant AXI_BYTE_WIDTH   : integer := AXI_DATA_WIDTH/8 ; 
  constant TID_MAX_WIDTH    : integer := 8 ;
  constant TDEST_MAX_WIDTH  : integer := 4 ;
  constant TUSER_MAX_WIDTH  : integer := 1 * AXI_BYTE_WIDTH ;
  
  constant DEFAULT_ID     : std_logic_vector(TID_MAX_WIDTH-1 downto 0) := B"0000_0000" ; 
  constant DEFAULT_DEST   : std_logic_vector(TDEST_MAX_WIDTH-1 downto 0) := "0000" ; 
  constant DEFAULT_USER   : std_logic_vector(TUSER_MAX_WIDTH-1 downto 0) := "0000" ; 

  constant tperiod_Clk : time := 10 ns ; 
  constant tpd         : time := 2 ns ; 

  signal Clk       : std_logic ;
  signal nReset    : std_logic ;
  
  signal TValid    : std_logic ;
  signal TReady    : std_logic ; 
  signal TID       : std_logic_vector(TID_MAX_WIDTH-1 downto 0) ; 
  signal TDest     : std_logic_vector(TDEST_MAX_WIDTH-1 downto 0) ; 
  signal TUser     : std_logic_vector(TUSER_MAX_WIDTH-1 downto 0) ; 
  signal TData     : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ; 
  signal TStrb     : std_logic_vector(AXI_BYTE_WIDTH-1 downto 0) ; 
  signal TKeep     : std_logic_vector(AXI_BYTE_WIDTH-1 downto 0) ; 
  signal TLast     : std_logic ; 

  -- Testbench Transaction Interface
  subtype TransactionRecType is AxiStreamTransactionRecType(
    DataToModel(SizeOfTransaction(AXI_DATA_WIDTH)-1 downto 0),
    DataFromModel(SizeOfTransaction(AXI_DATA_WIDTH)-1 downto 0)
  ) ;  
  signal AxiStreamMasterTransRec : TransactionRecType ;
  signal AxiStreamSlaveTransRec : TransactionRecType ;
  

  component AxiStreamMaster is
    generic (
      DEFAULT_ID     : std_logic_vector ; 
      DEFAULT_DEST   : std_logic_vector ; 
      DEFAULT_USER   : std_logic_vector ; 

      tperiod_Clk     : time := 10 ns ;
      
      tpd_Clk_TValid : time := 2 ns ; 
      tpd_Clk_TID    : time := 2 ns ; 
      tpd_Clk_TDest  : time := 2 ns ; 
      tpd_Clk_TUser  : time := 2 ns ; 
      tpd_Clk_TData  : time := 2 ns ; 
      tpd_Clk_TStrb  : time := 2 ns ; 
      tpd_Clk_TKeep  : time := 2 ns ; 
      tpd_Clk_TLast  : time := 2 ns 
    ) ;
    port (
      -- Globals
      Clk       : in  std_logic ;
      nReset    : in  std_logic ;
      
      -- AXI Master Functional Interface
      TValid    : out std_logic ;
      TReady    : in  std_logic ; 
      TID       : out std_logic_vector ; 
      TDest     : out std_logic_vector ; 
      TUser     : out std_logic_vector ; 
      TData     : out std_logic_vector ; 
      TStrb     : out std_logic_vector ; 
      TKeep     : out std_logic_vector ; 
      TLast     : out std_logic ; 

      -- Testbench Transaction Interface
      TransRec  : inout AxiStreamTransactionRecType 
    ) ;
  end component AxiStreamMaster ;
  
  component AxiStreamSlave is
    generic (
      DEFAULT_ID     : std_logic_vector ; 
      DEFAULT_DEST   : std_logic_vector ; 
      DEFAULT_USER   : std_logic_vector ; 

      tperiod_Clk     : time := 10 ns ;
      
      tpd_Clk_TReady : time := 2 ns  
    ) ;
    port (
      -- Globals
      Clk       : in  std_logic ;
      nReset    : in  std_logic ;
      
      -- AXI Master Functional Interface
      TValid    : in  std_logic ;
      TReady    : out std_logic ; 
      TID       : in  std_logic_vector ; 
      TDest     : in  std_logic_vector ; 
      TUser     : in  std_logic_vector ; 
      TData     : in  std_logic_vector ; 
      TStrb     : in  std_logic_vector ; 
      TKeep     : in  std_logic_vector ; 
      TLast     : in  std_logic ; 

      -- Testbench Transaction Interface
      TransRec  : inout AxiStreamTransactionRecType 
    ) ;
  end component AxiStreamSlave ;

  component TestCtrl is
    port (
      -- Global Signal Interface
      Clk                       : In    std_logic ;
      nReset                    : In    std_logic ;

      -- Transaction Interfaces
      AxiStreamMasterTransRec   : inout AxiStreamTransactionRecType ;
      AxiStreamSlaveTransRec    : inout AxiStreamTransactionRecType 

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
  
  AxiStreamMaster_1 : AxiStreamMaster 
    generic map (
      DEFAULT_ID     => DEFAULT_ID  , 
      DEFAULT_DEST   => DEFAULT_DEST, 
      DEFAULT_USER   => DEFAULT_USER, 

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
      TransRec  => AxiStreamMasterTransRec
    ) ;
  
  AxiStreamSlave_1 : AxiStreamSlave
    generic map (
      DEFAULT_ID     => DEFAULT_ID  , 
      DEFAULT_DEST   => DEFAULT_DEST, 
      DEFAULT_USER   => DEFAULT_USER, 

      tperiod_Clk    => tperiod_Clk,

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
      TransRec  => AxiStreamSlaveTransRec
    ) ;
  
  
  TestCtrl_1 : TestCtrl
  port map ( 
    -- Globals
    Clk                      => Clk,
    nReset                   => nReset,
    
    -- Testbench Transaction Interfaces
    AxiStreamMasterTransRec  => AxiStreamMasterTransRec, 
    AxiStreamSlaveTransRec   => AxiStreamSlaveTransRec  
  ) ; 

end architecture TestHarness ;