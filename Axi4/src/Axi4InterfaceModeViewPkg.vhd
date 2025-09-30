--
--  File Name:         Axi4InterfaceModeViewPkg.vhd
--  Design Unit Name:  Axi4InterfaceModeViewPkg
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Define mode views for AXI4 Interfcae
--          
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    10/2025   2025.10    Initial revision
--
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
  
library osvvm ;
    context osvvm.OsvvmContext ;

use work.Axi4InterfacePkg.all ;

package Axi4InterfaceModeViewPkg is 
  -- AXI Write Address Channel
  view Axi4WriteAddressManagerView of Axi4WriteAddressRecType is
    Addr      : out ; 
    Prot      : out ;
    Valid     : out ; 
    Ready     : in ; 
    -- AXI4 Full
    -- User Config - AXI recommended 3:0 for Manager, 7:0 at slave
    ID        : out ; 
    -- BurstLength = AxLen+1.  AXI4: 7:0,  AXI3: 3:0
    Len       : out ; 
    -- #Bytes in transfer = 2**AxSize
    Size      : out ; 
    -- AxBurst Binary Encoded (Fixed, Incr, Wrap, NotDefined)
    Burst     : out ; 
    Lock      : out ;
    -- AxCache One-hot (Write-Allocate, Read-Allocate, Modifiable, Bufferable)
    Cache     : out ;
    QOS       : out ; 
    Region    : out ; 
    User      : out ; 
  end view Axi4WriteAddressManagerView ;

  alias Axi4WriteAddressSubordinateView is Axi4WriteAddressManagerView'converse ;


  -- AXI Write Data Channel
  view Axi4WriteDataManagerView of Axi4WriteDataRecType is
    -- AXI4 Lite
    Data       : out ;  
    Strb       : out ;  
    Valid      : out ; 
    Ready      : in ; 
    -- AXI 4 Full 
    Last       : out ; 
    User       : out ; 
    -- AXI3
    ID         : out ; 
  end view Axi4WriteDataManagerView ;

  alias Axi4WriteDataSubordinateView is Axi4WriteDataManagerView'converse ;


  -- AXI Write Response Channel  
  view Axi4WriteResponseManagerView of Axi4WriteResponseRecType is
    -- AXI4 Lite
    Valid      : in ;
    Ready      : out ;
    Resp       : in ;
    -- AXI 4 Fulli
    ID         : in ;
    User       : in ;
  end view Axi4WriteResponseManagerView ;

  alias Axi4WriteResponseSubordinateView is Axi4WriteResponseManagerView'converse ;


  -- AXI Read Address Channel
  view Axi4ReadAddressManagerView of Axi4ReadAddressRecType is
    -- AXI4 Lite
    Addr      : out ;
    Prot      : out ;
    Valid     : out ;
    Ready     : in ;
    -- AXI 4 Full
    -- User Config - AXI recommended 3:0 for Manager, 7:0 at slave
    ID        : out ; 
    -- BurstLength = AxLen+1.  AXI4: 7:0,  AXI3: 3:0
    Len       : out ; 
    -- #Bytes in transfer = 2**AxSize
    Size      : out ; 
    -- AxBurst Binary Encoded (Fixed, Incr, Wrap, NotDefined)
    Burst     : out ;  
    Lock      : out ; 
    -- AxCache One-hot (Write-Allocate, Read-Allocate, Modifiable, Bufferable)
    Cache     : out ;
    QOS       : out ;
    Region    : out ;
    User      : out ;
  end view Axi4ReadAddressManagerView ;
  
  alias Axi4ReadAddressSubordinateView is Axi4ReadAddressManagerView'converse ;


  -- AXI Read Data Channel
  view Axi4ReadDataManagerView of Axi4ReadDataRecType is
    -- AXI4 Lite
    Data       : in ; 
    Resp       : in ; 
    Valid      : in ; 
    Ready      : out ; 
    -- AXI 4 Full
    Last       : in ;
    User       : in ;
    ID         : in ;
  end view Axi4ReadDataManagerView ;

  alias Axi4ReadDataSubordinateView is Axi4ReadDataManagerView'converse ;
 

  -- AXI Bus with the 5 separate channels
  view Axi4ManagerView of Axi4RecType is
    WriteAddress   : view Axi4WriteAddressManagerView ; 
    WriteData      : view Axi4WriteDataManagerView ; 
    WriteResponse  : view Axi4WriteResponseManagerView ; 
    ReadAddress    : view Axi4ReadAddressManagerView ; 
    ReadData       : view Axi4ReadDataManagerView ; 
  end view Axi4ManagerView ;

  alias Axi4SubordinateView is Axi4ManagerView'converse ;
  
end package Axi4InterfaceModeViewPkg ; 

  

