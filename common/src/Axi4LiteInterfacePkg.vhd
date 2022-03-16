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

package Axi4LiteInterfacePkg is 
  -- AXI Write Address Channel
  type Axi4LiteWriteAddressRecType is record
    Valid     : std_logic ; 
    Ready     : std_logic ; 
    Addr      : std_logic_vector ; 
    Prot      : Axi4ProtType ;
  end record Axi4LiteWriteAddressRecType ; 
  
  function InitAxi4LiteWriteAddressRec (AW : Axi4LiteWriteAddressRecType; InitVal : std_logic := 'Z' ) return Axi4LiteWriteAddressRecType ;
  
--
--!TODO Add VHDL-2018 mode declarations here
-- Comment out for now, also include `ifdef for language revision
--
  
  -- AXI Write Data Channel
  type Axi4LiteWriteDataRecType is record
    Valid      : std_logic ; 
    Ready      : std_logic ; 
    Data       : std_logic_vector ; 
    Strb       : std_logic_vector ; 
  end record Axi4LiteWriteDataRecType ; 
  
  function InitAxi4LiteWriteDataRec (WD : Axi4LiteWriteDataRecType; InitVal : std_logic := 'Z' ) return Axi4LiteWriteDataRecType ;

-- Add VHDL-2018 modes here

  -- AXI Write Response Channel
  type Axi4LiteWriteResponseRecType is record
    Valid      : std_logic ; 
    Ready      : std_logic ; 
    Resp       : Axi4RespType ; 
  end record Axi4LiteWriteResponseRecType ; 
  
  function InitAxi4LiteWriteResponseRec(InitVal : std_logic := 'Z') return Axi4LiteWriteResponseRecType ;
  
-- Add VHDL-2018 modes here

  
  -- AXI Read Address Channel
  type Axi4LiteReadAddressRecType is record
    Valid     : std_logic ; 
    Ready     : std_logic ; 
    Addr      : std_logic_vector ; 
    Prot      : Axi4ProtType ; 
  end record Axi4LiteReadAddressRecType ; 
  
  function InitAxi4LiteReadAddressRec (AR : Axi4LiteReadAddressRecType; InitVal : std_logic := 'Z' ) return Axi4LiteReadAddressRecType ;

-- Add VHDL-2018 modes here

  -- AXI Read Data Channel
  type Axi4LiteReadDataRecType is record
    Valid      : std_logic ; 
    Ready      : std_logic ; 
    Data       : std_logic_vector ; 
    Resp       : Axi4RespType ;
  end record Axi4LiteReadDataRecType ; 
  
  function InitAxi4LiteReadDataRec (RD : Axi4LiteReadDataRecType; InitVal : std_logic := 'Z' ) return Axi4LiteReadDataRecType ;
  
-- Add VHDL-2018 modes here
  
  type Axi4LiteRecType is record
    WriteAddress   : Axi4LiteWriteAddressRecType ; 
    WriteData      : Axi4LiteWriteDataRecType ; 
    WriteResponse  : Axi4LiteWriteResponseRecType ; 
    ReadAddress    : Axi4LiteReadAddressRecType ; 
    ReadData       : Axi4LiteReadDataRecType ; 
  end record Axi4LiteRecType ; 
  
  function  InitAxi4LiteRec (AxiBusRec : Axi4LiteRecType; InitVal : std_logic := 'Z') return Axi4LiteRecType ;
  procedure InitAxi4LiteRec (signal AxiBusRec : inout Axi4LiteRecType ) ;
  
end package Axi4LiteInterfacePkg ;
package body Axi4LiteInterfacePkg is 

-- add function bodies here
  function InitAxi4LiteWriteAddressRec (AW : Axi4LiteWriteAddressRecType; InitVal : std_logic := 'Z' ) return Axi4LiteWriteAddressRecType is
  begin
    return (
      Valid => InitVal, 
      Ready => InitVal, 
      Addr  => (AW.Addr'range  => InitVal), 
      Prot  => (others         => InitVal)
    ) ;
  end function InitAxi4LiteWriteAddressRec ; 

  function InitAxi4LiteWriteDataRec (WD : Axi4LiteWriteDataRecType; InitVal : std_logic := 'Z' ) return Axi4LiteWriteDataRecType is
  begin
    return (
      Valid  => InitVal,
      Ready  => InitVal,
      Data   => (WD.Data'range  => InitVal),  
      Strb   => (WD.Strb'range  => InitVal) 
    ) ;
  end function InitAxi4LiteWriteDataRec ; 

  function InitAxi4LiteWriteResponseRec(InitVal : std_logic := 'Z') return Axi4LiteWriteResponseRecType is
  begin
    return (
      Valid  => InitVal,
      Ready  => InitVal,
      Resp   => (others => InitVal)  
    ) ;
  end function InitAxi4LiteWriteResponseRec ; 

  function InitAxi4LiteReadAddressRec (AR : Axi4LiteReadAddressRecType; InitVal : std_logic := 'Z' ) return Axi4LiteReadAddressRecType is
  begin
    return (
      Valid => InitVal, 
      Ready => InitVal, 
      Addr  => (AR.Addr'range  => InitVal), 
      Prot  => (others         => InitVal)
    ) ;
  end function InitAxi4LiteReadAddressRec ; 

  function InitAxi4LiteReadDataRec (RD : Axi4LiteReadDataRecType; InitVal : std_logic := 'Z' ) return Axi4LiteReadDataRecType is
  begin
    return (
      Valid  => InitVal,
      Ready  => InitVal,
      Data   => (RD.Data'range  => InitVal),  
      Resp   => (others         => InitVal)  
    ) ;
  end function InitAxi4LiteReadDataRec ; 
    
  function InitAxi4LiteRec (AxiBusRec : Axi4LiteRecType; InitVal : std_logic := 'Z') return Axi4LiteRecType is
  begin
    return ( 
      WriteAddress   => InitAxi4LiteWriteAddressRec( AxiBusRec.WriteAddress,   InitVal),
      WriteData      => InitAxi4LiteWriteDataRec(    AxiBusRec.WriteData,      InitVal),
      WriteResponse  => InitAxi4LiteWriteResponseRec(                          InitVal), 
      ReadAddress    => InitAxi4LiteReadAddressRec(  AxiBusRec.ReadAddress,    InitVal),
      ReadData       => InitAxi4LiteReadDataRec(     AxiBusRec.ReadData,       InitVal)
    ) ;
  end function InitAxi4LiteRec ; 


  procedure InitAxi4LiteRec (signal AxiBusRec : inout Axi4LiteRecType ) is
  begin
    AxiBusRec <= InitAxi4LiteRec(AxiBusRec, 'Z') ;
  end procedure InitAxi4LiteRec ;

end package body Axi4LiteInterfacePkg ; 

  

