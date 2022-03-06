--
--  File Name:         TestCtrl_e.vhd
--  Design Unit Name:  TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Test transaction source
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    09/2017   2017.09    Initial revision
--    05/2019   2019.05    Added context reference
--    01/2020   2020.01    Updated license notice
--    12/2020   2020.12    Updated port names
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2017 - 2020 by SynthWorks Design Inc.  
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
  
library OSVVM ; 
  context OSVVM.OsvvmContext ; 

library osvvm_Axi4 ;
  context osvvm_Axi4.Axi4LiteContext ; 

entity TestCtrl is
  port (
    -- Global Signal Interface
    Clk            : In    std_logic ;
    nReset         : In    std_logic ;

    -- Transaction Interfaces
    ManagerRec     : inout AddressBusRecType ;
    SubordinateRec : inout AddressBusRecType 

  ) ;
    constant AXI_ADDR_WIDTH : integer := ManagerRec.Address'length ; 
    constant AXI_DATA_WIDTH : integer := ManagerRec.DataToModel'length ;  

-- Not currently used in the Axi4Lite model - future use for Axi4Lite Burst Emulation modes    
--  alias WriteBurstFifo is <<variable .TbAxi4.Master_1.WriteBurstFifo : osvvm.ScoreboardPkg_slv.ScoreboardPType>> ;
--  alias ReadBurstFifo  is <<variable .TbAxi4.Master_1.ReadBurstFifo  : osvvm.ScoreboardPkg_slv.ScoreboardPType>> ;
end entity TestCtrl ;
