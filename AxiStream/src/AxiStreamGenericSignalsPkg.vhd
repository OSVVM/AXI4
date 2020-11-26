--
--  File Name:         AxiStreamGenericSignalsPkg.vhd
--  Design Unit Name:  AxiStreamGenericSignalsPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--
--  Description
--      Context Declaration for OSVVM packages
--
--  Developed by/for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:      
--    Date      Version    Description
--    01/2010   2019.01    Initial Revision
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

library osvvm ;
    context osvvm.OsvvmContext ;

library osvvm_common ;
  context osvvm_common.OsvvmCommonContext ;

library osvvm_axi4 ;
    context osvvm_axi4.AxiStreamContext ;
    
package AxiStreamGenericSignalsPkg is
  generic (
    constant AXI_DATA_WIDTH   : integer := 32 ; 
    constant AXI_BYTE_WIDTH   : integer := AXI_DATA_WIDTH/8 ; 
    constant TID_MAX_WIDTH    : integer := 8 ;
    constant TDEST_MAX_WIDTH  : integer := 4 ;
    constant TUSER_MAX_WIDTH  : integer := 1 * AXI_BYTE_WIDTH 
  ) ; 
  
  constant INIT_ID     : std_logic_vector(TID_MAX_WIDTH-1 downto 0)   := (others => '0') ; 
  constant INIT_DEST   : std_logic_vector(TDEST_MAX_WIDTH-1 downto 0) := (others => '0') ; 
  constant INIT_USER   : std_logic_vector(TUSER_MAX_WIDTH-1 downto 0) := (others => '0') ; 
  
  constant AXI_PARAM_WIDTH : integer := TID_MAX_WIDTH + TDEST_MAX_WIDTH + TUSER_MAX_WIDTH + 1 ;

  --! Issue:  with multiple interfaces, need to use a selected name with package
  --!         PackageInstanceName.TValid
  --!         Interesting in that it works just like a record - except you cannot collectively refer to them
  signal TValid    : std_logic ;
  signal TReady    : std_logic ; 
  signal TID       : std_logic_vector(TID_MAX_WIDTH-1 downto 0) ; 
  signal TDest     : std_logic_vector(TDEST_MAX_WIDTH-1 downto 0) ; 
  signal TUser     : std_logic_vector(TUSER_MAX_WIDTH-1 downto 0) ; 
  signal TData     : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ; 
  signal TStrb     : std_logic_vector(AXI_BYTE_WIDTH-1 downto 0) ; 
  signal TKeep     : std_logic_vector(AXI_BYTE_WIDTH-1 downto 0) ; 
  signal TLast     : std_logic ; 

--  -- Testbench Transaction Interface
--  subtype TransactionRecType is StreamRecType(
--    DataToModel   (AXI_DATA_WIDTH-1  downto 0),
--    DataFromModel (AXI_DATA_WIDTH-1  downto 0),
--    ParamToModel  (AXI_PARAM_WIDTH-1 downto 0),
--    ParamFromModel(AXI_PARAM_WIDTH-1 downto 0)
--  ) ;  
--  signal TransRec : TransactionRecType ;
end package AxiStreamGenericSignalsPkg ;

