--
--  File Name:         Axi4LiteMonitor.vhd
--  Design Unit Name:  Axi4LiteMonitor
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      AXI Lite Monitor dummy model
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    09/2017   2017       Initial revision
--    01/2020   2020.01    Updated license notice
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2019 - 2020 by SynthWorks Design Inc.  
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

  use work.Axi4InterfaceCommonPkg.all ;
  use work.Axi4LiteInterfacePkg.all ; 
  use work.Axi4CommonPkg.all ; 

entity Axi4LiteMonitor is
port (
  -- Globals
  Clk         : in   std_logic ;
  nReset      : in   std_logic ;

  -- AXI Master Functional Interface
  AxiBus      : in    Axi4LiteRecType 
) ;
   
end entity Axi4LiteMonitor ;
architecture Monitor of Axi4LiteMonitor is

--  alias    AB : AxiBus'subtype is AxiBus ; 
--  alias    AW is AB.WriteAddress ;
--  alias    WD is AB.WriteData ; 
--  alias    WR is AB.WriteResponse ; 
--  alias    AR is AB.ReadAddress ; 
--  alias    RD is AB.ReadData ;

  constant MODEL_INSTANCE_NAME : string     := PathTail(to_lower(Axi4LiteMonitor'PATH_NAME)) ;
  signal ModelID, ProtocolID, DataCheckID, BusFailedID : AlertLogIDType ; 
  
  
begin

    

end architecture Monitor ;
