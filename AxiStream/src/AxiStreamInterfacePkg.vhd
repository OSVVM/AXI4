--
--  File Name:         AxiStreamInterfacePkg.vhd
--  Design Unit Name:  AxiStreamInterfacePkg
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
--    04/2021   2021.04    Initial revision
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2021 by SynthWorks Design Inc.  
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
  

package AxiStreamInterfacePkg is 

  type AxiStreamRecType is record
    -- AXI Master Functional Interface
    TValid    : std_logic ;
    TReady    : std_logic ; 
    TID       : std_logic_vector ; 
    TDest     : std_logic_vector ; 
    TUser     : std_logic_vector ; 
    TData     : std_logic_vector ; 
    TStrb     : std_logic_vector ; 
    TKeep     : std_logic_vector ; 
    TLast     : std_logic ; 
  end record AxiStreamRecType ; 
  
  view AxiStreamTxView of AxiStreamRecType is
    TValid    : out ;
    TReady    : in  ;
    TID       : out ;
    TDest     : out ;
    TUser     : out ;
    TData     : out ;
    TStrb     : out ;
    TKeep     : out ;
    TLast     : out ;
  end view AxiStreamTxView ;

  alias AxiStreamRxView is AxiStreamTxView'converse ;

end package AxiStreamInterfacePkg ;


  

