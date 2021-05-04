--
--  File Name:         Axi4MemorySharedVti.vhd
--  Design Unit Name:  Axi4MemorySharedVti
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      AXI Memory Model
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    05/2021   2021.05    Initial
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2021 by SynthWorks Design Inc.
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

  use work.Axi4InterfacePkg.all ;
  use work.Axi4ComponentPkg.all ; 

entity Axi4MemorySharedVti is
generic (
  MODEL_ID_NAME   : string := "" ;
  tperiod_Clk     : time   := 10 ns ;

  DEFAULT_DELAY   : time   := 1 ns ; 

  tpd_Clk_AWReady : time   := DEFAULT_DELAY ;

  tpd_Clk_WReady  : time   := DEFAULT_DELAY ;

  tpd_Clk_BValid  : time   := DEFAULT_DELAY ;
  tpd_Clk_BResp   : time   := DEFAULT_DELAY ;
  tpd_Clk_BID     : time   := DEFAULT_DELAY ;
  tpd_Clk_BUser   : time   := DEFAULT_DELAY ;

  tpd_Clk_ARReady : time   := DEFAULT_DELAY ;

  tpd_Clk_RValid  : time   := DEFAULT_DELAY ;
  tpd_Clk_RData   : time   := DEFAULT_DELAY ;
  tpd_Clk_RResp   : time   := DEFAULT_DELAY ;
  tpd_Clk_RID     : time   := DEFAULT_DELAY ;
  tpd_Clk_RUser   : time   := DEFAULT_DELAY ;
  tpd_Clk_RLast   : time   := DEFAULT_DELAY
) ;
port (
  -- Globals
  Clk         : in   std_logic ;
  nReset      : in   std_logic ;
  
  -- AXI Responder Interface
  AxiBus1      : view Axi4ResponderView of Axi4BaseRecType ;
  AxiBus2      : view Axi4ResponderView of Axi4BaseRecType ;
  AxiBus3      : view Axi4ResponderView of Axi4BaseRecType ;
  AxiBus4      : view Axi4ResponderView of Axi4BaseRecType 
) ;

  -- Memory Data Structure
  -- Access via transactions or external name
  shared variable Memory : MemoryPType ;

  -- Virtual Transaction Interface (VTI) for Axi4MemoryExternal_1
  constant AXI1_ADDR_WIDTH : integer := AxiBus1.WriteAddress.Addr'length ;
  constant AXI1_DATA_WIDTH : integer := AxiBus1.WriteData.Data'length ;
  -- Access via external name
  signal TransRec1 : AddressBusRecType (
          Address      (AXI1_ADDR_WIDTH-1 downto 0),
          DataToModel  (AXI1_DATA_WIDTH-1 downto 0),
          DataFromModel(AXI1_DATA_WIDTH-1 downto 0)
        ) ;

  -- Virtual Transaction Interface (VTI) for Axi4MemoryExternal_2
  constant AXI2_ADDR_WIDTH : integer := AxiBus2.WriteAddress.Addr'length ;
  constant AXI2_DATA_WIDTH : integer := AxiBus2.WriteData.Data'length ;
  -- Access via external name
  signal TransRec2 : AddressBusRecType (
          Address      (AXI2_ADDR_WIDTH-1 downto 0),
          DataToModel  (AXI2_DATA_WIDTH-1 downto 0),
          DataFromModel(AXI2_DATA_WIDTH-1 downto 0)
        ) ;

  -- Virtual Transaction Interface (VTI) for Axi4MemoryExternal_3
  constant AXI3_ADDR_WIDTH : integer := AxiBus3.WriteAddress.Addr'length ;
  constant AXI3_DATA_WIDTH : integer := AxiBus3.WriteData.Data'length ;
  -- Access via external name
  signal TransRec3 : AddressBusRecType (
          Address      (AXI3_ADDR_WIDTH-1 downto 0),
          DataToModel  (AXI3_DATA_WIDTH-1 downto 0),
          DataFromModel(AXI3_DATA_WIDTH-1 downto 0)
        ) ;

  -- Virtual Transaction Interface (VTI) for Axi4MemoryExternal_4
  constant AXI4_ADDR_WIDTH : integer := AxiBus4.WriteAddress.Addr'length ;
  constant AXI4_DATA_WIDTH : integer := AxiBus4.WriteData.Data'length ;
  -- Access via external name
  signal TransRec4 : AddressBusRecType (
          Address      (AXI4_ADDR_WIDTH-1 downto 0),
          DataToModel  (AXI4_DATA_WIDTH-1 downto 0),
          DataFromModel(AXI4_DATA_WIDTH-1 downto 0)
        ) ;
end entity Axi4MemorySharedVti ;

architecture Structural of Axi4MemorySharedVti is

begin

  Axi4MemoryExternal_1 : Axi4MemoryExternal 
  port map (
    -- Globals
    Clk         => Clk, 
    nReset      => nReset, 
    
    -- Memory Interface
    Memory      => Memory, 

    -- AXI Responder Interface
    AxiBus      => AxiBus1,

    -- Testbench Transaction Interface
    TransRec    => TransRec1
  ) ;
  
  Axi4MemoryExternal_2 : Axi4MemoryExternal 
  port map (
    -- Globals
    Clk         => Clk, 
    nReset      => nReset, 
    
    -- Memory Interface
    Memory      => Memory, 

    -- AXI Responder Interface
    AxiBus      => AxiBus2,

    -- Testbench Transaction Interface
    TransRec    => TransRec2
  ) ;
  
  Axi4MemoryExternal_3 : Axi4MemoryExternal 
  port map (
    -- Globals
    Clk         => Clk, 
    nReset      => nReset, 
    
    -- Memory Interface
    Memory      => Memory, 

    -- AXI Responder Interface
    AxiBus      => AxiBus3,

    -- Testbench Transaction Interface
    TransRec    => TransRec3
  ) ;

end architecture Structural ;
