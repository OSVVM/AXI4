--
--  File Name:         Axi4Memory.vhd
--  Design Unit Name:  Axi4Memory
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
--    10/2025   2025.10    Split entity and architecture to support 2019 interfaces
--                         Moved MODEL_INSTANCE_NAME and LOCAL_MEMORY_NAME to architecture 
--    09/2024   2024.09    Updated ClassifyUnimplementedOperation.  Added DEBUG log for LOCAL_MEMORY_NAME
--    07/2024   2024.07    Shortened AlertLog and data structure names for better printing
--    03/2024   2024.03    Updated SafeResize to use ModelID
--    01/2024   2024.01    Updated Params to use singleton data structure
--    09/2023   2023.09    Unimplemented transactions handled with ClassifyUnimplementedOperation
--    05/2023   2023.05    Adding Randomization of Valid and Ready timing   
--    10/2022   2022.10    Changed enum value PRIVATE to PRIVATE_NAME due to VHDL-2019 keyword conflict.   
--    05/2022   2022.05    Updated FIFOs so they are Search => PRIVATE
--    03/2022   2022.03    Updated calls to NewID for AlertLogID and FIFOs
--    02/2022   2022.02    Replaced to_hstring with to_hxstring
--                         Added Search by NAME to NewID.
--    01/2022   2022.01    Moved MODEL_INSTANCE_NAME and MODEL_NAME to entity declarative region
--    07/2021   2021.07    All FIFOs and Scoreboards now use the New Scoreboard/FIFO capability 
--    06/2021   2021.06    GHDL support + new memory data structure  
--    02/2021   2021.02    Added MultiDriver Detect.  Updated Generics.   
--    06/2020   2020.06    Derived from Axi4Subordinate.vhd
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2020 - 2024 by SynthWorks Design Inc.
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

library osvvm_Axi4 ; 
  context osvvm_Axi4.Axi4Context ; 

entity Axi4Memory is
generic (
  MODEL_ID_NAME   : string := "" ;
  MEMORY_NAME     : string := "" ;
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

  -- AXI Subordinate Interface
  AxiBus      : inout Axi4RecType ;

  -- Testbench Transaction Interface
  TransRec    : inout AddressBusRecType
) ;

  -- Derive AXI interface properties from the AxiBus
  constant AXI_ADDR_WIDTH : integer := AxiBus.WriteAddress.Addr'length ;
  constant AXI_DATA_WIDTH : integer := AxiBus.WriteData.Data'length ;
      
  constant MODEL_NAME : string := "Axi4Memory" ;

end entity Axi4Memory ;

