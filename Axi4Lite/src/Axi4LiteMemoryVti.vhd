--
--  File Name:         Axi4LiteMemoryVti.vhd
--  Design Unit Name:  Axi4LiteMemoryVti
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Simple AXI Full Memory Subordinate Model
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    06/2025   2025.06    VTI as an instance of the PBI
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2025 by SynthWorks Design Inc.
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
  use ieee.math_real.all ;

library osvvm ;
  context osvvm.OsvvmContext ;
  use osvvm.ScoreboardPkg_slv.all ;

library osvvm_common ;
  context osvvm_common.OsvvmCommonContext ;

  use work.Axi4OptionsPkg.all ;
  use work.Axi4InterfaceCommonPkg.all ;
  use work.Axi4LiteInterfacePkg.all ;
  use work.Axi4CommonPkg.all ;
  use work.Axi4ModelPkg.all ;

  use work.Axi4LiteComponentPkg.all ;

entity Axi4LiteMemoryVti is
generic (
  MODEL_ID_NAME   : string := "" ;
  MEMORY_NAME     : string := "" ;
  tperiod_Clk     : time   := 10 ns ;

  DEFAULT_DELAY   : time   := 1 ns ; 

  tpd_Clk_AWReady : time   := DEFAULT_DELAY ;

  tpd_Clk_WReady  : time   := DEFAULT_DELAY ;

  tpd_Clk_BValid  : time   := DEFAULT_DELAY ;
  tpd_Clk_BResp   : time   := DEFAULT_DELAY ;

  tpd_Clk_ARReady : time   := DEFAULT_DELAY ;

  tpd_Clk_RValid  : time   := DEFAULT_DELAY ;
  tpd_Clk_RData   : time   := DEFAULT_DELAY ;
  tpd_Clk_RResp   : time   := DEFAULT_DELAY 
) ;
port (
  -- Globals
  Clk         : in   std_logic ;
  nReset      : in   std_logic ;

  -- AXI Subordinate Interface
  AxiBus      : inout Axi4LiteRecType 
) ;

  -- Derive AXI interface properties from the AxiBus
  constant AXI_ADDR_WIDTH : integer := AxiBus.WriteAddress.Addr'length ;
  constant AXI_DATA_WIDTH : integer := AxiBus.WriteData.Data'length ;
  
  -- VTI Testbench Transaction Interface
  -- Access via external names
  signal TransRec : AddressBusRecType (
    Address      (AXI_ADDR_WIDTH-1 downto 0),
    DataToModel  (AXI_DATA_WIDTH-1 downto 0),
    DataFromModel(AXI_DATA_WIDTH-1 downto 0)
  ) ;

  -- Derive ModelInstance label from path_name
  constant MODEL_INSTANCE_NAME : string :=
    -- use MODEL_ID_NAME Generic if set, otherwise use instance label (preferred if set as entityname_1)
    IfElse(MODEL_ID_NAME /= "", MODEL_ID_NAME, PathTail(to_lower(Axi4LiteMemoryVti'PATH_NAME))) ;

  -- Memory Data Structure, Access via MemoryName
  constant LOCAL_MEMORY_NAME : string := 
    IfElse(MEMORY_NAME /= "", MEMORY_NAME, MODEL_INSTANCE_NAME & ":memory") ;
--    IfElse(MEMORY_NAME /= "", MEMORY_NAME, to_lower(Axi4LiteMemoryVti'PATH_NAME) & ":memory") ;
    
end entity Axi4LiteMemoryVti ;

architecture MemorySubordinate of Axi4LiteMemoryVti is
begin

  Axi4LiteMemory_1 : Axi4LiteMemory
  generic map (
    MODEL_ID_NAME   => MODEL_INSTANCE_NAME,
    MEMORY_NAME     => LOCAL_MEMORY_NAME,
    tperiod_Clk     => tperiod_Clk,

    DEFAULT_DELAY   => DEFAULT_DELAY,

    tpd_Clk_AWReady => tpd_Clk_AWReady,

    tpd_Clk_WReady  => tpd_Clk_WReady,

    tpd_Clk_BValid  => tpd_Clk_BValid,
    tpd_Clk_BResp   => tpd_Clk_BResp,

    tpd_Clk_ARReady => tpd_Clk_ARReady,

    tpd_Clk_RValid  => tpd_Clk_RValid,
    tpd_Clk_RData   => tpd_Clk_RData,
    tpd_Clk_RResp   => tpd_Clk_RResp  
  )   
  port map (
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- AXI Manager Functional Interface
    AxiBus      => AxiBus,

    -- Testbench Transaction Interface
    TransRec    => TransRec
  ) ;
  
end architecture MemorySubordinate ;
