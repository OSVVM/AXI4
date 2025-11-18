--
--  File Name:         Axi4ManagerVti.vhd
--  Design Unit Name:  Axi4ManagerVti
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      AXI Full Manager Model
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    07/2024   2024.07    Shortened AlertLog and data structure names for better printing
--    03/2024   2024.03    Updated SafeResize to use ModelID
--    01/2024   2024.01    Updated Params to use singleton data structure
--    09/2023   2023.09    Unimplemented transactions handled with ClassifyUnimplementedOperation
--    05/2023   2023.05    Adding Randomization of Valid and Ready timing   
--    12/2022   2022.12    Updated read check to use MetaMatch.   
--    10/2022   2022.10    Changed enum value PRIVATE to PRIVATE_NAME due to VHDL-2019 keyword conflict.   
--    05/2022   2022.05    Updated FIFOs so they are Search => PRIVATE
--    03/2022   2022.03    Updated calls to NewID for AlertLogID and FIFOs
--    02/2022   2022.02    Replaced to_hstring with to_hxstring
--    01/2022   2022.01    Moved MODEL_INSTANCE_NAME and MODEL_NAME to entity declarative region
--    07/2021   2021.07    All FIFOs and Scoreboards now use the New Scoreboard/FIFO capability 
--    06/2021   2021.06    GHDL support + New Burst FIFOs 
--    02/2021   2021.02    Added MultiDriver Detect.  Added Valid Delays.  Updated Generics.   
--    12/2020   2020.12    Added Burst Word Mode.  Refactored code.  Added VTI
--    07/2020   2020.07    Created Axi4 FULL from Axi4Lite
--    01/2020   2020.01    Updated license notice
--    04/2018   2018.04    First Release
--    09/2017   2017       Initial revision
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2017 - 2023 by SynthWorks Design Inc.
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
  use work.Axi4ModelPkg.all ;
  use work.Axi4InterfaceCommonPkg.all ;
  use work.Axi4InterfacePkg.all ;
  use work.Axi4CommonPkg.all ;

entity Axi4ManagerVti is
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
  AxiBus      : view Axi4ManagerView of Axi4RecType 
) ;

  -- Derive AXI interface properties from the AxiBus
  constant AXI_ADDR_WIDTH      : integer := AxiBus.WriteAddress.Addr'length ;
  constant AXI_DATA_WIDTH      : integer := AxiBus.WriteData.Data'length ;
  
  -- Testbench Transaction Interface
  -- Access via external names
  signal TransRec : AddressBusRecType (
          Address      (AXI_ADDR_WIDTH-1 downto 0),
          DataToModel  (AXI_DATA_WIDTH-1 downto 0),
          DataFromModel(AXI_DATA_WIDTH-1 downto 0)
        ) ;

  constant MODEL_NAME : string := "Axi4ManagerVti" ;

end entity Axi4ManagerVti ;
