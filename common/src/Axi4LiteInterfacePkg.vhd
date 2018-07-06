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
--    Date       Version    Description
--    09/2017:   2017       Initial revision
--
--
-- Copyright 2017 SynthWorks Design Inc 
-- 
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--     http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
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
    AWValid     : std_logic ; 
    AWReady     : std_logic ; 
    AWAddr      : std_logic_vector ; 
    AWProt      : Axi4ProtType ;
  end record Axi4LiteWriteAddressRecType ; 
  
  function InitAxi4LiteWriteAddressRec (AddrWidth : natural ) return Axi4LiteWriteAddressRecType ;
  
--
--!TODO Add VHDL-2018 mode declarations here
-- Comment out for now, also include `ifdef for language revision
--
  
  -- AXI Write Data Channel
  type Axi4LiteWriteDataRecType is record
    WValid      : std_logic ; 
    WReady      : std_logic ; 
    WData       : std_logic_vector ; 
    WStrb       : std_logic_vector ; 
  end record Axi4LiteWriteDataRecType ; 
  
  function InitAxi4LiteWriteDataRec (DataWidth : natural ) return Axi4LiteWriteDataRecType ;

-- Add VHDL-2018 modes here

  

  -- AXI Write Response Channel
  type Axi4LiteWriteResponseRecType is record
    BValid      : std_logic ; 
    BReady      : std_logic ; 
    BResp       : Axi4RespType ; 
  end record Axi4LiteWriteResponseRecType ; 
  
  function InitAxi4LiteWriteResponseRec return Axi4LiteWriteResponseRecType ;
  
-- Add VHDL-2018 modes here

  
  -- AXI Read Address Channel
  type Axi4LiteReadAddressRecType is record
    ARValid     : std_logic ; 
    ARReady     : std_logic ; 
    ARAddr      : std_logic_vector ; 
    ARProt      : Axi4ProtType ; 
  end record Axi4LiteReadAddressRecType ; 
  
  function InitAxi4LiteReadAddressRec (AddrWidth : natural) return Axi4LiteReadAddressRecType ;

-- Add VHDL-2018 modes here

  -- AXI Read Data Channel
  type Axi4LiteReadDataRecType is record
    RValid      : std_logic ; 
    RReady      : std_logic ; 
    RData       : std_logic_vector ; 
    RResp       : Axi4RespType ;
  end record Axi4LiteReadDataRecType ; 
  
  function InitAxi4LiteReadDataRec (DataWidth : natural ) return Axi4LiteReadDataRecType ;
  
-- Add VHDL-2018 modes here
  
  type Axi4LiteRecType is record
    WriteAddress   : Axi4LiteWriteAddressRecType ; 
    WriteData      : Axi4LiteWriteDataRecType ; 
    WriteResponse  : Axi4LiteWriteResponseRecType ; 
    ReadAddress    : Axi4LiteReadAddressRecType ; 
    ReadData       : Axi4LiteReadDataRecType ; 
  end record Axi4LiteRecType ; 
  
  function InitAxi4LiteRec (AddrWidth : natural ; DataWidth : natural ) return Axi4LiteRecType ;
  procedure InitAxi4LiteRec (signal AxiBusRec : out Axi4LiteRecType ) ;
  
end package Axi4LiteInterfacePkg ;
package body Axi4LiteInterfacePkg is 

-- add function bodies here
  function InitAxi4LiteWriteAddressRec (AddrWidth : natural ) return Axi4LiteWriteAddressRecType is
  begin
    return (
      AWValid => 'Z', 
      AWReady => 'Z', 
      AWAddr  => (AddrWidth-1 downto 0 => 'Z'), 
      AWProt  => (others => 'Z')
    ) ;
  end function InitAxi4LiteWriteAddressRec ; 

  function InitAxi4LiteWriteDataRec (DataWidth : natural ) return Axi4LiteWriteDataRecType is
  begin
    return (
      WValid  => 'Z',
      WReady  => 'Z',
      WData   => (DataWidth-1 downto 0 => 'Z'),  
      WStrb   => ((DataWidth/8)-1 downto 0 => 'Z') 
    ) ;
  end function InitAxi4LiteWriteDataRec ; 

  function InitAxi4LiteWriteResponseRec return Axi4LiteWriteResponseRecType is
  begin
    return (
      BValid  => 'Z',
      BReady  => 'Z',
      BResp   => AXI4_RESP_INIT  
    ) ;
  end function InitAxi4LiteWriteResponseRec ; 

  function InitAxi4LiteReadAddressRec (AddrWidth : natural ) return Axi4LiteReadAddressRecType is
  begin
    return (
      ARValid => 'Z', 
      ARReady => 'Z', 
      ARAddr  => (AddrWidth-1 downto 0 => 'Z'), 
      ARProt  => (others => 'Z')
    ) ;
  end function InitAxi4LiteReadAddressRec ; 

  function InitAxi4LiteReadDataRec (DataWidth : natural ) return Axi4LiteReadDataRecType is
  begin
    return (
      RValid  => 'Z',
      RReady  => 'Z',
      RData   => (DataWidth-1 downto 0 => 'Z'),  
      RResp   => AXI4_RESP_INIT  
    ) ;
  end function InitAxi4LiteReadDataRec ; 
  
  function InitAxi4LiteRec (AddrWidth : natural ; DataWidth : natural ) return Axi4LiteRecType is
  begin
    return ( 
      WriteAddress   => InitAxi4LiteWriteAddressRec(AddrWidth),
      WriteData      => InitAxi4LiteWriteDataRec(DataWidth),
      WriteResponse  => InitAxi4LiteWriteResponseRec, 
      ReadAddress    => InitAxi4LiteReadAddressRec(AddrWidth),
      ReadData       => InitAxi4LiteReadDataRec(DataWidth)
    ) ;
  end function InitAxi4LiteRec ; 

  procedure InitAxi4LiteRec (signal AxiBusRec : out Axi4LiteRecType ) is
    constant AXI_ADDR_WIDTH : integer := AxiBusRec.WriteAddress.AWAddr'length ; 
    constant AXI_DATA_WIDTH : integer := AxiBusRec.WriteData.WData'length ;
  begin
    AxiBusRec <= InitAxi4LiteRec(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) ;
  end procedure InitAxi4LiteRec ;

end package body Axi4LiteInterfacePkg ; 

  

