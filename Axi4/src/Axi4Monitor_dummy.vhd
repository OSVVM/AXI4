--
--  File Name:         Axi4Monitor.vhd
--  Design Unit Name:  Axi4Monitor
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
  use work.Axi4InterfacePkg.all ; 
  use work.Axi4CommonPkg.all ; 

entity Axi4Monitor is
port (
  -- Globals
  Clk         : in   std_logic ;
  nReset      : in   std_logic ;

  -- AXI Manager Functional Interface
  AxiBus      : in    Axi4RecType 
) ;
   
end entity Axi4Monitor ;
architecture Monitor of Axi4Monitor is

--  alias    AB : AxiBus'subtype is AxiBus ; 
--  alias    AW is AxiBus.WriteAddress ;
--  alias    WD is AxiBus.WriteData ; 
--  alias    WR is AxiBus.WriteResponse ; 
--  alias    AR is AxiBus.ReadAddress ; 
--  alias    RD is AxiBus.ReadData ;

  constant MODEL_INSTANCE_NAME : string     := PathTail(to_lower(Axi4Monitor'PATH_NAME)) ;
  signal ModelID, ProtocolID, DataCheckID, BusFailedID : AlertLogIDType ; 
  
  
begin

    

end architecture Monitor ;
