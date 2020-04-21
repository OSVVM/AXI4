--
--  File Name:         Axi4LiteInterfacePkg.vhd
--  Design Unit Name:  Axi4LiteInterfacePkg
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Defines types, constants, and subprograms to support the Axi4Lite interface to DUT
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
  

package Axi4LiteInterfacePkg is 
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
  type Axi4LiteWriteAddressRecType is record
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
  end record Axi4LiteWriteAddressRecType ; 
  
  function InitAxi4LiteWriteAddressRec (WriteAddress : in Axi4LiteWriteAddressRecType ) return Axi4LiteWriteAddressRecType ;
    
--
--!TODO Add VHDL-2018 mode declarations here
-- Comment out for now, also include `ifdef for language revision
--
  
  -- AXI Write Data Channel
  type Axi4LiteWriteDataRecType is record
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
  end record Axi4LiteWriteDataRecType ; 
  
  function InitAxi4LiteWriteDataRec (WriteData : Axi4LiteWriteDataRecType ) return Axi4LiteWriteDataRecType ;

-- Add VHDL-2018 modes here

  
  -- AXI Write Response Channel
  type Axi4LiteWriteResponseRecType is record
    -- AXI4 Lite
    BValid      : std_logic ; 
    BReady      : std_logic ; 
    BResp       : Axi4RespType ; 
    -- AXI 4 Full
    BID         : std_logic_vector ;
    BUser       : std_logic_vector ;
  end record Axi4LiteWriteResponseRecType ; 
  
  function InitAxi4LiteWriteResponseRec(WriteResponse : Axi4LiteWriteResponseRecType) return Axi4LiteWriteResponseRecType ;
  
-- Add VHDL-2018 modes here

  
  -- AXI Read Address Channel
  type Axi4LiteReadAddressRecType is record
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
  end record Axi4LiteReadAddressRecType ; 
  
  
  function InitAxi4LiteReadAddressRec (ReadAddress : Axi4LiteReadAddressRecType ) return Axi4LiteReadAddressRecType ;

-- Add VHDL-2018 modes here

  -- AXI Read Data Channel
  type Axi4LiteReadDataRecType is record
    -- AXI4 Lite
    RData       : std_logic_vector ; 
    RResp       : Axi4RespType ;
    RValid      : std_logic ; 
    RReady      : std_logic ; 
    -- AXI 4 Full
    RID       : std_logic_vector ;
    RLast     : std_logic ;
    RUser     : std_logic_vector ;
  end record Axi4LiteReadDataRecType ; 
  
  function InitAxi4LiteReadDataRec (ReadData : Axi4LiteReadDataRecType ) return Axi4LiteReadDataRecType ;

  
-- Add VHDL-2018 modes here
  
  type Axi4RecType is record
    WriteAddress   : Axi4LiteWriteAddressRecType ; 
    WriteData      : Axi4LiteWriteDataRecType ; 
    WriteResponse  : Axi4LiteWriteResponseRecType ; 
    ReadAddress    : Axi4LiteReadAddressRecType ; 
    ReadData       : Axi4LiteReadDataRecType ; 
  end record Axi4RecType ; 
  
  -- Axi4RecType with sized elements
  -- Get From Above

  -- Axi4Lite Record, Axi4 full elements are null arrays  
  subtype Axi4LiteRecType is Axi4RecType( 
    WriteAddress( AWID(0 downto 1), AWUser(0 downto 1) ),
    WriteData( WUser(0 downto 1), WID(0 downto 1) ),  -- WID only AXI3
    WriteResponse( BID(0 downto 1), BUser(0 downto 1) ),
    ReadAddress( ARID(0 downto 1), ARUser(0 downto 1) ),
    ReadData( RID(0 downto 1), RUser(0 downto 1) )
  ) ;
  
  function InitAxi4LiteRec (AxiBusRec : in Axi4LiteRecType) return Axi4LiteRecType ;
  procedure InitAxi4LiteRec (signal AxiBusRec : out Axi4LiteRecType ) ;
  
end package Axi4LiteInterfacePkg ;
package body Axi4LiteInterfacePkg is 

  function InitAxi4LiteWriteAddressRec (WriteAddress : in Axi4LiteWriteAddressRecType ) return Axi4LiteWriteAddressRecType is
  begin
    return (
      -- AXI4 Lite
      AWAddr   => (WriteAddress.AWAddr'range => 'Z'), 
      AWProt   => (WriteAddress.AWProt'range => 'Z'),
      AWValid  => 'Z', 
      AWReady  => 'Z', 
      -- AXI 4 Full
      AWID     => (WriteAddress.AWID'range => 'Z'),
      AWLen    => (WriteAddress.AWLen'range => 'Z'), 
      AWSize   => (WriteAddress.AWSize'range => 'Z'), 
      AWBurst  => (WriteAddress.AWBurst'range => 'Z'), 
      AWLock   => 'Z',
      AWCache  => (WriteAddress.AWCache'range => 'Z'),
      AWQOS    => (WriteAddress.AWQOS'range => 'Z'),
      AWRegion => (WriteAddress.AWRegion'range => 'Z'),
      AWUser   => (WriteAddress.AWUser'range => 'Z')
    ) ;
  end function InitAxi4LiteWriteAddressRec ; 

  function InitAxi4LiteWriteDataRec (WriteData : Axi4LiteWriteDataRecType ) return Axi4LiteWriteDataRecType is
    constant DataWidth : integer := WriteData.WData'length ; 
  begin
    return (
      -- AXI4 Lite
      WData   => (DataWidth-1 downto 0 => 'Z'),  
      WStrb   => ((DataWidth/8)-1 downto 0 => 'Z'),
      WValid  => 'Z',
      WReady  => 'Z',
      -- AXI 4 Full
      WLast   => 'Z',
      WUser   => (WriteData.WUser'range => 'Z'),
      -- AXI3
      WID     => (WriteData.WID'range => 'Z')
    ) ;
  end function InitAxi4LiteWriteDataRec ; 

  function InitAxi4LiteWriteResponseRec(WriteResponse : Axi4LiteWriteResponseRecType) return Axi4LiteWriteResponseRecType is
  begin
    return (
      -- AXI4 Lite
      BResp   => (WriteResponse.BResp'range => 'Z'),  
      BValid  => 'Z',
      BReady  => 'Z',
      -- AXI 4 Full
      BID     => (WriteResponse.BID'range => 'Z'),
      BUser   => (WriteResponse.BUser'range => 'Z')

    ) ;
  end function InitAxi4LiteWriteResponseRec ; 

  function InitAxi4LiteReadAddressRec (ReadAddress : Axi4LiteReadAddressRecType ) return Axi4LiteReadAddressRecType is
  begin
    return (
      -- AXI4 Lite
      ARAddr  => (ReadAddress.ARAddr'range => 'Z'), 
      ARProt  => (ReadAddress.ARProt'range => 'Z'),
      ARValid => 'Z', 
      ARReady => 'Z', 
      -- AXI 4 Full
      ARID     => (ReadAddress.ARID'range => 'Z'),
      ARLen    => (ReadAddress.ARLen'range => 'Z'), 
      ARSize   => (ReadAddress.ARSize'range => 'Z'), 
      ARBurst  => (ReadAddress.ARBurst'range => 'Z'), 
      ARLock   => 'Z',
      ARCache  => (ReadAddress.ARCache'range => 'Z'),
      ARQOS    => (ReadAddress.ARQOS'range => 'Z'),
      ARRegion => (ReadAddress.ARRegion'range => 'Z'),
      ARUser   => (ReadAddress.ARUser'range => 'Z')
    ) ;
  end function InitAxi4LiteReadAddressRec ; 

  function InitAxi4LiteReadDataRec (ReadData : Axi4LiteReadDataRecType ) return Axi4LiteReadDataRecType is
  begin
    return (
      -- AXI4 Lite
      RData   => (ReadData.RData'range => 'Z'),  
      RResp   => (ReadData.RResp'range => 'Z'),  
      RValid  => 'Z',
      RReady  => 'Z',
      -- AXI 4 Full
      RID     => (ReadData.RID'range => 'Z'),
      RLast   => 'Z',
      RUser   => (ReadData.RUser'range => 'Z')

    ) ;
  end function InitAxi4LiteReadDataRec ; 
    
  function InitAxi4LiteRec (AxiBusRec : in Axi4LiteRecType) return Axi4LiteRecType is
  begin
    return ( 
      WriteAddress   => InitAxi4LiteWriteAddressRec(AxiBusRec.WriteAddress),
      WriteData      => InitAxi4LiteWriteDataRec(AxiBusRec.WriteData),
      WriteResponse  => InitAxi4LiteWriteResponseRec(AxiBusRec.WriteResponse), 
      ReadAddress    => InitAxi4LiteReadAddressRec(AxiBusRec.ReadAddress),
      ReadData       => InitAxi4LiteReadDataRec(AxiBusRec.ReadData)
    ) ;
  end function InitAxi4LiteRec ; 

  procedure InitAxi4LiteRec (signal AxiBusRec : out Axi4LiteRecType ) is
  begin
    AxiBusRec <= InitAxi4LiteRec(AxiBusRec) ;
  end procedure InitAxi4LiteRec ;

end package body Axi4LiteInterfacePkg ; 

  

