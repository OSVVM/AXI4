--
--  File Name:         Axi4Manager.vhd
--  Design Unit Name:  Axi4Manager
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Entity for AXI Full Manager Model
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    10/2025   2025.10    Split entity from architecture to support 2019 interfaces
--                         Most modification information in architecture.
--    01/2020   2020.01    Updated license notice
--    04/2018   2018.04    First Release
--    09/2017   2017       Initial revision
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2017 - 2025 by SynthWorks Design Inc.
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

-- library osvvm_common ;
--   context osvvm_common.OsvvmCommonContext ;
-- 
--   use work.Axi4OptionsPkg.all ;
--   use work.Axi4ModelPkg.all ;
--   use work.Axi4InterfaceCommonPkg.all ;
--   use work.Axi4InterfacePkg.all ;
--   use work.Axi4CommonPkg.all ;
--   use work.Axi4InterfaceModeViewPkg.all ;

entity Axi4Manager is
generic (
  MODEL_ID_NAME    : string := "" ;
  tperiod_Clk      : time   := 10 ns ;
  
  DEFAULT_DELAY    : time   := 1 ns ; 

  tpd_Clk_AWAddr   : time   := DEFAULT_DELAY ;
  tpd_Clk_AWProt   : time   := DEFAULT_DELAY ;
  tpd_Clk_AWValid  : time   := DEFAULT_DELAY ;
  -- AXI4 Full
  tpd_clk_AWLen    : time   := DEFAULT_DELAY ;
  tpd_clk_AWID     : time   := DEFAULT_DELAY ;
  tpd_clk_AWSize   : time   := DEFAULT_DELAY ;
  tpd_clk_AWBurst  : time   := DEFAULT_DELAY ;
  tpd_clk_AWLock   : time   := DEFAULT_DELAY ;
  tpd_clk_AWCache  : time   := DEFAULT_DELAY ;
  tpd_clk_AWQOS    : time   := DEFAULT_DELAY ;
  tpd_clk_AWRegion : time   := DEFAULT_DELAY ;
  tpd_clk_AWUser   : time   := DEFAULT_DELAY ;

  tpd_Clk_WValid   : time   := DEFAULT_DELAY ;
  tpd_Clk_WData    : time   := DEFAULT_DELAY ;
  tpd_Clk_WStrb    : time   := DEFAULT_DELAY ;
  -- AXI4 Full
  tpd_Clk_WLast    : time   := DEFAULT_DELAY ;
  tpd_Clk_WUser    : time   := DEFAULT_DELAY ;
  -- AXI3
  tpd_Clk_WID      : time   := DEFAULT_DELAY ;

  tpd_Clk_BReady   : time   := DEFAULT_DELAY ;

  tpd_Clk_ARValid  : time   := DEFAULT_DELAY ;
  tpd_Clk_ARProt   : time   := DEFAULT_DELAY ;
  tpd_Clk_ARAddr   : time   := DEFAULT_DELAY ;
  -- AXI4 Full
  tpd_clk_ARLen    : time   := DEFAULT_DELAY ;
  tpd_clk_ARID     : time   := DEFAULT_DELAY ;
  tpd_clk_ARSize   : time   := DEFAULT_DELAY ;
  tpd_clk_ARBurst  : time   := DEFAULT_DELAY ;
  tpd_clk_ARLock   : time   := DEFAULT_DELAY ;
  tpd_clk_ARCache  : time   := DEFAULT_DELAY ;
  tpd_clk_ARQOS    : time   := DEFAULT_DELAY ;
  tpd_clk_ARRegion : time   := DEFAULT_DELAY ;
  tpd_clk_ARUser   : time   := DEFAULT_DELAY ;

  tpd_Clk_RReady   : time   := DEFAULT_DELAY
) ;
port (
  -- Globals
  Clk         : in   std_logic ;
  nReset      : in   std_logic ;

  -- AXI Manager Functional Interface
  AxiBus      : view Axi4ManagerView of Axi4RecType ;

  -- Testbench Transaction Interface
  TransRec    : view AddressBusVerificationComponentView of AddressBusRecType  
) ;

  -- Derive AXI interface properties from the AxiBus
  constant AXI_ADDR_WIDTH      : integer := AxiBus.WriteAddress.Addr'length ;
  constant AXI_DATA_WIDTH      : integer := AxiBus.WriteData.Data'length ;
  
  -- Derive ModelInstance label from path_name
  constant MODEL_INSTANCE_NAME : string :=
    -- use MODEL_ID_NAME Generic if set, otherwise use instance label (preferred if set as entityname_1)
    IfElse(MODEL_ID_NAME /= "", MODEL_ID_NAME, to_lower(PathTail(Axi4Manager'PATH_NAME))) ;

  constant MODEL_NAME : string := "Axi4Manager" ;
  
end entity Axi4Manager ;