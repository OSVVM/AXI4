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
--    09/2017   2017       Initial revision
--    01/2020   2020.01    Updated license notice
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
  

package Axi4InterfacePkg is 
  subtype  Axi4RespType is std_logic_vector(1 downto 0) ;
  constant AXI4_RESP_OKAY   : Axi4RespType := "00" ;
  constant AXI4_RESP_EXOKAY : Axi4RespType := "01" ; -- Not for Lite
  constant AXI4_RESP_SLVERR : Axi4RespType := "10" ;
  constant AXI4_RESP_DECERR : Axi4RespType := "11" ;
  constant AXI4_RESP_INIT   : Axi4RespType := "ZZ" ;

  subtype Axi4ProtType is std_logic_vector(2 downto 0) ;
  --  [0] 0 Unprivileged access
  --      1 Privileged access
  --  [1] 0 Secure access
  --      1 Non-secure access
  --  [2] 0 Data access
  --      1 Instruction access
  constant AXI4_PROT_INIT   : Axi4ProtType := "ZZZ" ;

  -- AXI Write Address Channel
  type Axi4WriteAddressRecType is record
    -- AXI4 Lite
    AWAddr      : std_logic_vector ; 
    AWProt      : Axi4ProtType ;
    AWValid     : std_logic ; 
    AWReady     : std_logic ; 
    -- AXI4 Full
    -- User Config - AXI recommended 3:0 for master, 7:0 at slave
    AWID        : std_logic_vector ; 
    -- BurstLength = AxLen+1.  AXI4: 7:0,  AXI3: 3:0
    AWLen       : std_logic_vector(7 downto 0) ; 
    -- #Bytes in transfer = 2**AxSize
    AWSize      : std_logic_vector(2 downto 0) ; 
    -- AxBurst Binary Encoded (Fixed, Incr, Wrap, NotDefined)
    AWBurst     : std_logic_vector(1 downto 0) ; 
    AWLock      : std_logic ;
    -- AxCache One-hot (Write-Allocate, Read-Allocate, Modifiable, Bufferable)
    AWCache     : std_logic_vector(3 downto 0) ;
    AWQOS       : std_logic_vector(3 downto 0) ;
    AWRegion    : std_logic_vector(7 downto 0) ;
    AWUser      : std_logic_vector ; -- User Config
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
    WData       : std_logic_vector ; 
    WStrb       : std_logic_vector ; 
    WValid      : std_logic ; 
    WReady      : std_logic ; 
    -- AXI 4 Full
    WLast       : std_logic ;
    WUser       : std_logic_vector ;
    -- AXI3
    WID         : std_logic_vector ;
  end record Axi4WriteDataRecType ; 
  
  function InitAxi4WriteDataRec (
    WriteData : Axi4WriteDataRecType ;
    InitVal   : std_logic := 'Z'
  ) return Axi4WriteDataRecType ;

-- Add VHDL-2018 modes here

  
  -- AXI Write Response Channel
  type Axi4WriteResponseRecType is record
    -- AXI4 Lite
    BValid      : std_logic ; 
    BReady      : std_logic ; 
    BResp       : Axi4RespType ; 
    -- AXI 4 Full
    BID         : std_logic_vector ;
    BUser       : std_logic_vector ;
  end record Axi4WriteResponseRecType ; 
  
  function InitAxi4WriteResponseRec(
    WriteResponse : Axi4WriteResponseRecType ;
    InitVal   : std_logic := 'Z'
  ) return Axi4WriteResponseRecType ;
  
-- Add VHDL-2018 modes here

  
  -- AXI Read Address Channel
  type Axi4ReadAddressRecType is record
    -- AXI4 Lite
    ARAddr      : std_logic_vector ; 
    ARProt      : Axi4ProtType ; 
    ARValid     : std_logic ; 
    ARReady     : std_logic ; 
    -- AXI 4 Full
    -- User Config - AXI recommended 3:0 for master, 7:0 at slave
    ARID        : std_logic_vector ; 
    -- BurstLength = AxLen+1.  AXI4: 7:0,  AXI3: 3:0
    ARLen       : std_logic_vector(7 downto 0) ; 
    -- #Bytes in transfer = 2**AxSize
    ARSize      : std_logic_vector(2 downto 0) ; 
    -- AxBurst Binary Encoded (Fixed, Incr, Wrap, NotDefined)
    ARBurst     : std_logic_vector(1 downto 0) ; 
    ARLock      : std_logic ;
    -- AxCache One-hot (Write-Allocate, Read-Allocate, Modifiable, Bufferable)
    ARCache     : std_logic_vector(3 downto 0) ;
    ARQOS       : std_logic_vector(3 downto 0) ;
    ARRegion    : std_logic_vector(7 downto 0) ;
    ARUser      : std_logic_vector ; -- User Config
  end record Axi4ReadAddressRecType ; 
  
  function InitAxi4ReadAddressRec (
    ReadAddress : Axi4ReadAddressRecType ;
    InitVal   : std_logic := 'Z'
  ) return Axi4ReadAddressRecType ;

-- Add VHDL-2018 modes here

  -- AXI Read Data Channel
  type Axi4ReadDataRecType is record
    -- AXI4 Lite
    RData       : std_logic_vector ; 
    RResp       : Axi4RespType ;
    RValid      : std_logic ; 
    RReady      : std_logic ; 
    -- AXI 4 Full
    RID       : std_logic_vector ;
    RLast     : std_logic ;
    RUser     : std_logic_vector ;
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
--    WriteAddress( AWAddr(open), AWID(0 downto 1), AWUser(0 downto 1) ),
--    WriteData( WData(open), WStrb(open), WUser(0 downto 1), WID(0 downto 1) ),  -- WID only AXI3
--    WriteResponse( BID(0 downto 1), BUser(0 downto 1) ),
--    ReadAddress( ARAddr(open), ARID(0 downto 1), ARUser(0 downto 1) ),
--    ReadData( RData(open), RID(0 downto 1), RUser(0 downto 1) )
--  ) ;
--   alias Axi4LiteRecType is Axi4BaseRecType ; 

-- -- Axi4 Record, Axi4 full elements are null arrays  
-- subtype Axi4RecType is Axi4BaseRecType( 
--   WriteAddress ( AWAddr(open), AWID(7 downto 0), AWUser(7 downto 0) ),
--   WriteData    ( WData(open), WStrb(open), WUser(7 downto 0), WID(7 downto 0) ),  -- WID only AXI3
--   WriteResponse( BID(7 downto 0), BUser(7 downto 0) ),
--   ReadAddress  ( ARAddr(open), ARID(7 downto 0), ARUser(7 downto 0) ),
--   ReadData     ( RData(open), RID(7 downto 0), RUser(7 downto 0) )
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
      AWAddr   => (WriteAddress.AWAddr'range => InitVal), 
      AWProt   => (WriteAddress.AWProt'range => InitVal),
      AWValid  => InitVal, 
      AWReady  => InitVal, 
      -- AXI 4 Full
      AWID     => (WriteAddress.AWID'range => InitVal),
      AWLen    => (WriteAddress.AWLen'range => InitVal), 
      AWSize   => (WriteAddress.AWSize'range => InitVal), 
      AWBurst  => (WriteAddress.AWBurst'range => InitVal), 
      AWLock   => InitVal,
      AWCache  => (WriteAddress.AWCache'range => InitVal),
      AWQOS    => (WriteAddress.AWQOS'range => InitVal),
      AWRegion => (WriteAddress.AWRegion'range => InitVal),
      AWUser   => (WriteAddress.AWUser'range => InitVal)
    ) ;
  end function InitAxi4WriteAddressRec ; 

  function InitAxi4WriteDataRec (
    WriteData : Axi4WriteDataRecType ;
    InitVal   : std_logic := 'Z'
  ) return Axi4WriteDataRecType is
    constant DataWidth : integer := WriteData.WData'length ; 
  begin
    return (
      -- AXI4 Lite
      WData   => (DataWidth-1 downto 0 => InitVal),  
      WStrb   => ((DataWidth/8)-1 downto 0 => InitVal),
      WValid  => InitVal,
      WReady  => InitVal,
      -- AXI 4 Full
      WLast   => InitVal,
      WUser   => (WriteData.WUser'range => InitVal),
      -- AXI3
      WID     => (WriteData.WID'range => InitVal)
    ) ;
  end function InitAxi4WriteDataRec ; 

  function InitAxi4WriteResponseRec(
    WriteResponse : Axi4WriteResponseRecType ;
    InitVal   : std_logic := 'Z'
  ) return Axi4WriteResponseRecType is
  begin
    return (
      -- AXI4 Lite
      BResp   => (WriteResponse.BResp'range =>InitVal),  
      BValid  => InitVal,
      BReady  => InitVal,
      -- AXI 4 Full
      BID     => (WriteResponse.BID'range => InitVal),
      BUser   => (WriteResponse.BUser'range => InitVal)

    ) ;
  end function InitAxi4WriteResponseRec ; 

  function InitAxi4ReadAddressRec (
    ReadAddress : Axi4ReadAddressRecType ;
    InitVal   : std_logic := 'Z'
  ) return Axi4ReadAddressRecType is
  begin
    return (
      -- AXI4 Lite
      ARAddr  => (ReadAddress.ARAddr'range => InitVal), 
      ARProt  => (ReadAddress.ARProt'range => InitVal),
      ARValid => InitVal, 
      ARReady => InitVal, 
      -- AXI 4 Full
      ARID     => (ReadAddress.ARID'range => InitVal),
      ARLen    => (ReadAddress.ARLen'range => InitVal), 
      ARSize   => (ReadAddress.ARSize'range => InitVal), 
      ARBurst  => (ReadAddress.ARBurst'range => InitVal), 
      ARLock   => InitVal,
      ARCache  => (ReadAddress.ARCache'range => InitVal),
      ARQOS    => (ReadAddress.ARQOS'range => InitVal),
      ARRegion => (ReadAddress.ARRegion'range => InitVal),
      ARUser   => (ReadAddress.ARUser'range => InitVal)
    ) ;
  end function InitAxi4ReadAddressRec ; 

  function InitAxi4ReadDataRec (
    ReadData : Axi4ReadDataRecType ;
    InitVal   : std_logic := 'Z'
  ) return Axi4ReadDataRecType is
  begin
    return (
      -- AXI4 Lite
      RData   => (ReadData.RData'range => InitVal),  
      RResp   => (ReadData.RResp'range => InitVal),  
      RValid  => InitVal,
      RReady  => InitVal,
      -- AXI 4 Full
      RID     => (ReadData.RID'range => InitVal),
      RLast   => InitVal,
      RUser   => (ReadData.RUser'range => InitVal)

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

  

