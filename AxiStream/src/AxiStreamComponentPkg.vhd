--
--  File Name:         AxiStreamComponentPkg.vhd
--  Design Unit Name:  AxiStreamComponentPkg
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Package with component declarations for AxiStreamTransmitter and AxiStreamReceiver
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    06/2021   2021.06    Added DEFAULT_DELAY generic
--    01/2020   2020.01    Updated license notice
--    05/2018   2018.05    Initial revision
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2018 - 2021 by SynthWorks Design Inc.  
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
  use osvvm.ScoreboardPkg_slv.all ;
  
library osvvm_common ;
  context osvvm_common.OsvvmCommonContext ;

  use work.AxiStreamOptionsPkg.all ; 
  use work.Axi4CommonPkg.all ; 
    
package AxiStreamComponentPkg is

  component AxiStreamTransmitter is
    generic (
      MODEL_ID_NAME  : string :="" ;
      INIT_ID        : std_logic_vector := "" ; 
      INIT_DEST      : std_logic_vector := "" ; 
      INIT_USER      : std_logic_vector := "" ; 
      INIT_LAST      : natural := 0 ; 
      
      tperiod_Clk    : time := 10 ns ;
      
      DEFAULT_DELAY  : time := 1 ns ; 

      tpd_Clk_TValid : time := DEFAULT_DELAY ; 
      tpd_Clk_TID    : time := DEFAULT_DELAY ; 
      tpd_Clk_TDest  : time := DEFAULT_DELAY ; 
      tpd_Clk_TUser  : time := DEFAULT_DELAY ; 
      tpd_Clk_TData  : time := DEFAULT_DELAY ; 
      tpd_Clk_TStrb  : time := DEFAULT_DELAY ; 
      tpd_Clk_TKeep  : time := DEFAULT_DELAY ; 
      tpd_Clk_TLast  : time := DEFAULT_DELAY 
    ) ;
    port (
      -- Globals
      Clk       : in  std_logic ;
      nReset    : in  std_logic ;
      
      -- AXI Transmitter Functional Interface
      TValid    : out std_logic ;
      TReady    : in  std_logic ; 
      TID       : out std_logic_vector ; 
      TDest     : out std_logic_vector ; 
      TUser     : out std_logic_vector ; 
      TData     : out std_logic_vector ; 
      TStrb     : out std_logic_vector ; 
      TKeep     : out std_logic_vector ; 
      TLast     : out std_logic ; 

      -- Testbench Transaction Interface
      TransRec  : inout StreamRecType 
    ) ;
  end component AxiStreamTransmitter ;
  
  component AxiStreamTransmitterVti is
    generic (
      MODEL_ID_NAME  : string :="" ;
      INIT_ID        : std_logic_vector := "" ; 
      INIT_DEST      : std_logic_vector := "" ; 
      INIT_USER      : std_logic_vector := "" ; 
      INIT_LAST      : natural := 0 ; 
      
      tperiod_Clk    : time := 10 ns ;
      
      DEFAULT_DELAY  : time := 1 ns ; 

      tpd_Clk_TValid : time := DEFAULT_DELAY ; 
      tpd_Clk_TID    : time := DEFAULT_DELAY ; 
      tpd_Clk_TDest  : time := DEFAULT_DELAY ; 
      tpd_Clk_TUser  : time := DEFAULT_DELAY ; 
      tpd_Clk_TData  : time := DEFAULT_DELAY ; 
      tpd_Clk_TStrb  : time := DEFAULT_DELAY ; 
      tpd_Clk_TKeep  : time := DEFAULT_DELAY ; 
      tpd_Clk_TLast  : time := DEFAULT_DELAY 
    ) ;
    port (
      -- Globals
      Clk       : in  std_logic ;
      nReset    : in  std_logic ;
      
      -- AXI Transmitter Functional Interface
      TValid    : out std_logic ;
      TReady    : in  std_logic ; 
      TID       : out std_logic_vector ; 
      TDest     : out std_logic_vector ; 
      TUser     : out std_logic_vector ; 
      TData     : out std_logic_vector ; 
      TStrb     : out std_logic_vector ; 
      TKeep     : out std_logic_vector ; 
      TLast     : out std_logic 
    ) ;
  end component AxiStreamTransmitterVti ;

  component AxiStreamReceiver is
    generic (
      MODEL_ID_NAME  : string :="" ;
      INIT_ID        : std_logic_vector := "" ; 
      INIT_DEST      : std_logic_vector := "" ; 
      INIT_USER      : std_logic_vector := "" ; 
      INIT_LAST      : natural := 0 ; 
      tperiod_Clk    : time := 10 ns ;
    
      tpd_Clk_TReady : time := 1 ns  
    ) ;
    port (
      -- Globals
      Clk       : in  std_logic ;
      nReset    : in  std_logic ;
      
      -- AXI Transmitter Functional Interface
      TValid    : in  std_logic ;
      TReady    : out std_logic ; 
      TID       : in  std_logic_vector ; 
      TDest     : in  std_logic_vector ; 
      TUser     : in  std_logic_vector ; 
      TData     : in  std_logic_vector ; 
      TStrb     : in  std_logic_vector ; 
      TKeep     : in  std_logic_vector ; 
      TLast     : in  std_logic ; 

      -- Testbench Transaction Interface
      TransRec  : inout StreamRecType 
    ) ;
  end component AxiStreamReceiver ;
  
  component AxiStreamReceiverVti is
    generic (
      MODEL_ID_NAME  : string :="" ;
      INIT_ID        : std_logic_vector := "" ; 
      INIT_DEST      : std_logic_vector := "" ; 
      INIT_USER      : std_logic_vector := "" ; 
      INIT_LAST      : natural := 0 ; 
      tperiod_Clk    : time := 10 ns ;
    
      tpd_Clk_TReady : time := 1 ns  
    ) ;
    port (
      -- Globals
      Clk       : in  std_logic ;
      nReset    : in  std_logic ;
      
      -- AXI Transmitter Functional Interface
      TValid    : in  std_logic ;
      TReady    : out std_logic ; 
      TID       : in  std_logic_vector ; 
      TDest     : in  std_logic_vector ; 
      TUser     : in  std_logic_vector ; 
      TData     : in  std_logic_vector ; 
      TStrb     : in  std_logic_vector ; 
      TKeep     : in  std_logic_vector ; 
      TLast     : in  std_logic  
    ) ;
  end component AxiStreamReceiverVti ;


end package AxiStreamComponentPkg ;