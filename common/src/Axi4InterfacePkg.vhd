--
--  File Name:         Axi4InterfacePkg.vhd
--  Design Unit Name:  Axi4InterfacePkg
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Defines types, constants, and subprograms to support the Axi4 interface to DUT
--      These are currently only intended for testbench models.
--      When VHDL-2018 intefaces gain popular support, these will be changed to support them. 
--          
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    03/2022   2022.03    Factored out of Axi4InterfaceCommonPkg
--    01/2020   2020.01    Updated license notice
--    09/2017   2017       Initial revision
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2017 - 2022 by SynthWorks Design Inc.  
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
  
use work.Axi4InterfaceCommonPkg.all ;

package Axi4InterfacePkg is 
  -- AXI Write Address Channel
  type Axi4WriteAddressRecType is record
    -- AXI4 Lite
    Addr      : std_logic_vector ; 
    Prot      : Axi4ProtType ;
    Valid     : std_logic ; 
    Ready     : std_logic ; 
    -- AXI4 Full
    -- User Config - AXI recommended 3:0 for master, 7:0 at slave
    ID        : std_logic_vector ; 
    -- BurstLength = AxLen+1.  AXI4: 7:0,  AXI3: 3:0
    Len       : std_logic_vector(7 downto 0) ; 
    -- #Bytes in transfer = 2**AxSize
    Size      : std_logic_vector(2 downto 0) ; 
    -- AxBurst Binary Encoded (Fixed, Incr, Wrap, NotDefined)
    Burst     : std_logic_vector(1 downto 0) ; 
    Lock      : std_logic ;
    -- AxCache One-hot (Write-Allocate, Read-Allocate, Modifiable, Bufferable)
    Cache     : std_logic_vector(3 downto 0) ;
    QOS       : std_logic_vector(3 downto 0) ;
    Region    : std_logic_vector(3 downto 0) ;
    User      : std_logic_vector ; -- User Config
  end record Axi4WriteAddressRecType ; 
  
  function InitAxi4WriteAddressRec (
    WriteAddress  : in Axi4WriteAddressRecType ;
    InitVal       : std_logic := 'Z'
  ) return Axi4WriteAddressRecType ;
    
--
--!TODO Add VHDL-2018 mode declarations here
-- Comment out for now, also include `ifdef for language revision
--
  
  -- AXI Write Data Channel
  type Axi4WriteDataRecType is record
    -- AXI4 Lite
    Data       : std_logic_vector ; 
    Strb       : std_logic_vector ; 
    Valid      : std_logic ; 
    Ready      : std_logic ; 
    -- AXI 4 Full
    Last       : std_logic ;
    User       : std_logic_vector ;
    -- AXI3
    ID         : std_logic_vector ;
  end record Axi4WriteDataRecType ; 
  
  function InitAxi4WriteDataRec (
    WriteData : Axi4WriteDataRecType ;
    InitVal   : std_logic := 'Z'
  ) return Axi4WriteDataRecType ;

-- Add VHDL-2018 modes here

  
  -- AXI Write Response Channel
  type Axi4WriteResponseRecType is record
    -- AXI4 Lite
    Valid      : std_logic ; 
    Ready      : std_logic ; 
    Resp       : Axi4RespType ; 
    -- AXI 4 Full
    ID         : std_logic_vector ;
    User       : std_logic_vector ;
  end record Axi4WriteResponseRecType ; 
  
  function InitAxi4WriteResponseRec(
    WriteResponse : Axi4WriteResponseRecType ;
    InitVal   : std_logic := 'Z'
  ) return Axi4WriteResponseRecType ;
  
-- Add VHDL-2018 modes here

  
  -- AXI Read Address Channel
  type Axi4ReadAddressRecType is record
    -- AXI4 Lite
    Addr      : std_logic_vector ; 
    Prot      : Axi4ProtType ; 
    Valid     : std_logic ; 
    Ready     : std_logic ; 
    -- AXI 4 Full
    -- User Config - AXI recommended 3:0 for master, 7:0 at slave
    ID        : std_logic_vector ; 
    -- BurstLength = AxLen+1.  AXI4: 7:0,  AXI3: 3:0
    Len       : std_logic_vector(7 downto 0) ; 
    -- #Bytes in transfer = 2**AxSize
    Size      : std_logic_vector(2 downto 0) ; 
    -- AxBurst Binary Encoded (Fixed, Incr, Wrap, NotDefined)
    Burst     : std_logic_vector(1 downto 0) ; 
    Lock      : std_logic ;
    -- AxCache One-hot (Write-Allocate, Read-Allocate, Modifiable, Bufferable)
    Cache     : std_logic_vector(3 downto 0) ;
    QOS       : std_logic_vector(3 downto 0) ;
    Region    : std_logic_vector(3 downto 0) ;
    User      : std_logic_vector ; -- User Config
  end record Axi4ReadAddressRecType ; 
  
  function InitAxi4ReadAddressRec (
    ReadAddress : Axi4ReadAddressRecType ;
    InitVal   : std_logic := 'Z'
  ) return Axi4ReadAddressRecType ;

-- Add VHDL-2018 modes here

  -- AXI Read Data Channel
  type Axi4ReadDataRecType is record
    -- AXI4 Lite
    Data       : std_logic_vector ; 
    Resp       : Axi4RespType ;
    Valid      : std_logic ; 
    Ready      : std_logic ; 
    -- AXI 4 Full
    Last       : std_logic ;
    User       : std_logic_vector ;
    ID         : std_logic_vector ;
  end record Axi4ReadDataRecType ; 
  
  function InitAxi4ReadDataRec (
    ReadData : Axi4ReadDataRecType ;
    InitVal   : std_logic := 'Z'
  ) return Axi4ReadDataRecType ;

  
-- Add VHDL-2018 modes here
  
  type Axi4BaseRecType is record
    WriteAddress   : Axi4WriteAddressRecType ; 
    WriteData      : Axi4WriteDataRecType ; 
    WriteResponse  : Axi4WriteResponseRecType ; 
    ReadAddress    : Axi4ReadAddressRecType ; 
    ReadData       : Axi4ReadDataRecType ; 
  end record Axi4BaseRecType ; 
  
  -- Axi4RecType with sized elements
  -- Get From Above

  -- Axi4 Record, Axi4 full elements are null arrays  
--  subtype Axi4LiteRecType is Axi4BaseRecType( 
--    WriteAddress ( Addr(open), ID(0 downto 1), User(0 downto 1) ),
--    WriteData    ( Data(open), Strb(open), User(0 downto 1), ID(0 downto 1) ),  -- ID only AXI3
--    WriteResponse( ID(0 downto 1), User(0 downto 1) ),
--    ReadAddress  ( Addr(open), ID(0 downto 1), User(0 downto 1) ),
--    ReadData     ( Data(open), ID(0 downto 1), User(0 downto 1) )
--  ) ;
--   alias Axi4LiteRecType is Axi4BaseRecType ; 

-- -- Axi4 Record, Axi4 full elements are null arrays  
-- subtype Axi4RecType is Axi4BaseRecType( 
--   WriteAddress ( Addr(open), ID(7 downto 0), User(7 downto 0) ),
--   WriteData    ( Data(open), Strb(open), User(7 downto 0), ID(7 downto 0) ),  -- ID only AXI3
--   WriteResponse( ID(7 downto 0), User(7 downto 0) ),
--   ReadAddress  ( Addr(open), ID(7 downto 0), User(7 downto 0) ),
--   ReadData     ( Data(open), ID(7 downto 0), User(7 downto 0) )
-- ) ;
 
  alias Axi4RecType is Axi4BaseRecType ; 
  
  function InitAxi4Rec (
    AxiBusRec : in Axi4RecType ;
    InitVal   : std_logic := 'Z'
  ) return Axi4RecType ;
  
  procedure InitAxi4Rec (
    signal AxiBusRec : inout Axi4RecType ;
    InitVal          : std_logic := 'Z'
  ) ;
  
end package Axi4InterfacePkg ;
package body Axi4InterfacePkg is 

  function InitAxi4WriteAddressRec (
    WriteAddress  : in Axi4WriteAddressRecType ;
    InitVal       : std_logic := 'Z'
  ) return Axi4WriteAddressRecType is
  begin
    return (
      -- AXI4 Lite
      Addr   => (WriteAddress.Addr'range => InitVal), 
      Prot   => (WriteAddress.Prot'range => InitVal),
      Valid  => InitVal, 
      Ready  => InitVal, 
      -- AXI 4 Full
      ID     => (WriteAddress.ID'range => InitVal),
      Len    => (WriteAddress.Len'range => InitVal), 
      Size   => (WriteAddress.Size'range => InitVal), 
      Burst  => (WriteAddress.Burst'range => InitVal), 
      Lock   => InitVal,
      Cache  => (WriteAddress.Cache'range => InitVal),
      QOS    => (WriteAddress.QOS'range => InitVal),
      Region => (WriteAddress.Region'range => InitVal),
      User   => (WriteAddress.User'range => InitVal)
    ) ;
  end function InitAxi4WriteAddressRec ; 

  function InitAxi4WriteDataRec (
    WriteData : Axi4WriteDataRecType ;
    InitVal   : std_logic := 'Z'
  ) return Axi4WriteDataRecType is
    constant DataWidth : integer := WriteData.Data'length ; 
  begin
    return (
      -- AXI4 Lite
      Data   => (DataWidth-1 downto 0 => InitVal),  
      Strb   => ((DataWidth/8)-1 downto 0 => InitVal),
      Valid  => InitVal,
      Ready  => InitVal,
      -- AXI 4 Full
      Last   => InitVal,
      User   => (WriteData.User'range => InitVal),
      -- AXI3
      ID     => (WriteData.ID'range => InitVal)
    ) ;
  end function InitAxi4WriteDataRec ; 

  function InitAxi4WriteResponseRec(
    WriteResponse : Axi4WriteResponseRecType ;
    InitVal   : std_logic := 'Z'
  ) return Axi4WriteResponseRecType is
  begin
    return (
      -- AXI4 Lite
      Resp   => (WriteResponse.Resp'range =>InitVal),  
      Valid  => InitVal,
      Ready  => InitVal,
      -- AXI 4 Full
      ID     => (WriteResponse.ID'range => InitVal),
      User   => (WriteResponse.User'range => InitVal)

    ) ;
  end function InitAxi4WriteResponseRec ; 

  function InitAxi4ReadAddressRec (
    ReadAddress : Axi4ReadAddressRecType ;
    InitVal   : std_logic := 'Z'
  ) return Axi4ReadAddressRecType is
  begin
    return (
      -- AXI4 Lite
      Addr   => (ReadAddress.Addr'range => InitVal), 
      Prot   => (ReadAddress.Prot'range => InitVal),
      Valid  => InitVal, 
      Ready  => InitVal, 
      -- AXI 4 Full
      ID     => (ReadAddress.ID'range => InitVal),
      Len    => (ReadAddress.Len'range => InitVal), 
      Size   => (ReadAddress.Size'range => InitVal), 
      Burst  => (ReadAddress.Burst'range => InitVal), 
      Lock   => InitVal,
      Cache  => (ReadAddress.Cache'range => InitVal),
      QOS    => (ReadAddress.QOS'range => InitVal),
      Region => (ReadAddress.Region'range => InitVal),
      User   => (ReadAddress.User'range => InitVal)
    ) ;
  end function InitAxi4ReadAddressRec ; 

  function InitAxi4ReadDataRec (
    ReadData : Axi4ReadDataRecType ;
    InitVal   : std_logic := 'Z'
  ) return Axi4ReadDataRecType is
  begin
    return (
      -- AXI4 Lite
      Data   => (ReadData.Data'range => InitVal),  
      Resp   => (ReadData.Resp'range => InitVal),  
      Valid  => InitVal,
      Ready  => InitVal,
      -- AXI 4 Full
      ID     => (ReadData.ID'range => InitVal),
      Last   => InitVal,
      User   => (ReadData.User'range => InitVal)
    ) ;
  end function InitAxi4ReadDataRec ; 
    
  function InitAxi4Rec (
    AxiBusRec : in Axi4RecType ;
    InitVal   : std_logic := 'Z'
  ) return Axi4RecType is
  begin
    return ( 
      WriteAddress   => InitAxi4WriteAddressRec(AxiBusRec.WriteAddress, InitVal),
      WriteData      => InitAxi4WriteDataRec(AxiBusRec.WriteData, InitVal),
      WriteResponse  => InitAxi4WriteResponseRec(AxiBusRec.WriteResponse, InitVal), 
      ReadAddress    => InitAxi4ReadAddressRec(AxiBusRec.ReadAddress, InitVal),
      ReadData       => InitAxi4ReadDataRec(AxiBusRec.ReadData, InitVal)
    ) ;
  end function InitAxi4Rec ; 

  procedure InitAxi4Rec (
    signal AxiBusRec : inout Axi4RecType ;
    InitVal          : std_logic := 'Z'
  ) is
  begin
    AxiBusRec <= InitAxi4Rec(AxiBusRec, InitVal) ;
  end procedure InitAxi4Rec ;

end package body Axi4InterfacePkg ; 

  

