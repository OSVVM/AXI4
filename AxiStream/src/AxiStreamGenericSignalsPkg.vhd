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
--  Usage:
--  
--
--  Developed by/for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Latest standard version available at:
--        http://www.SynthWorks.com/downloads
--
--  Revision History:      
--    Date      Version    Description
--    01/2010   2019.01    Initial Revision
--
--
--  Copyright (c) 2019 by SynthWorks Design Inc.  All rights reserved.
--
--  Verbatim copies of this source file may be used and
--  distributed without restriction.
--
--  This source file is free software; you can redistribute it
--  and/or modify it under the terms of the ARTISTIC License
--  as published by The Perl Foundation; either version 2.0 of
--  the License, or (at your option) any later version.
--
--  This source is distributed in the hope that it will be
--  useful, but WITHOUT ANY WARRANTY; without even the implied
--  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
--  PURPOSE. See the Artistic License for details.
--
--  You should have received a copy of the license with this source.
--  If not download it from,
--     http://www.perlfoundation.org/artistic_license_2_0
--
--

library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;

library osvvm ;
    context osvvm.OsvvmContext ;

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
  
  constant DEFAULT_ID     : std_logic_vector(TID_MAX_WIDTH-1 downto 0)   := (others => '0') ; 
  constant DEFAULT_DEST   : std_logic_vector(TDEST_MAX_WIDTH-1 downto 0) := (others => '0') ; 
  constant DEFAULT_USER   : std_logic_vector(TUSER_MAX_WIDTH-1 downto 0) := (others => '0') ; 
  

  --! Issue:  with multiple interfaces, need to use a selected name with package
  --!         PackageInstanceName.TValid
  signal TValid    : std_logic ;
  signal TReady    : std_logic ; 
  signal TID       : std_logic_vector(TID_MAX_WIDTH-1 downto 0) ; 
  signal TDest     : std_logic_vector(TDEST_MAX_WIDTH-1 downto 0) ; 
  signal TUser     : std_logic_vector(TUSER_MAX_WIDTH-1 downto 0) ; 
  signal TData     : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ; 
  signal TStrb     : std_logic_vector(AXI_BYTE_WIDTH-1 downto 0) ; 
  signal TKeep     : std_logic_vector(AXI_BYTE_WIDTH-1 downto 0) ; 
  signal TLast     : std_logic ; 

  -- Testbench Transaction Interface
  subtype TransactionRecType is AxiStreamTransactionRecType(
    DataToModel(AXI_DATA_WIDTH-1 downto 0),
    DataFromModel(AXI_DATA_WIDTH-1 downto 0)
  ) ;  
  signal TransRec : TransactionRecType ;
end package AxiStreamGenericSignalsPkg ;

