--
--  File Name:         AxiStreamDut.vhd
--  Design Unit Name:  AxiStreamDut
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--     DUT pass thru for AxiStream VC testing 
--     Used to demonstrate DUT connections
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    01/2023   2023.01    Initial
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2023 by SynthWorks Design Inc.
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
  use ieee.math_real.all ;

library osvvm ;
  context osvvm.OsvvmContext ;

entity AxiStreamDut is
  port (
    -- AXI Transmitter Functional Interface
    TxTValid    : out std_logic ;
    TxTReady    : in  std_logic ;
    TxTID       : out std_logic_vector ;
    TxTDest     : out std_logic_vector ;
    TxTUser     : out std_logic_vector ;
    TxTData     : out std_logic_vector ;
    TxTStrb     : out std_logic_vector ;
    TxTKeep     : out std_logic_vector ;
    TxTLast     : out std_logic ;

    -- AXI Receiver Functional Interface
    RxTValid    : in  std_logic ;
    RxTReady    : out std_logic ;
    RxTID       : in  std_logic_vector ;
    RxTDest     : in  std_logic_vector ;
    RxTUser     : in  std_logic_vector ;
    RxTData     : in  std_logic_vector ;
    RxTStrb     : in  std_logic_vector ;
    RxTKeep     : in  std_logic_vector ;
    RxTLast     : in  std_logic 
  ) ;
end entity AxiStreamDut ;
architecture DUT of AxiStreamDut is
begin

  TxTValid    <= RxTValid;
  RxTReady    <= TxTReady;
  TxTID       <= RxTID   ;
  TxTDest     <= RxTDest ;
  TxTUser     <= RxTUser ;
  TxTData     <= RxTData ;
  TxTStrb     <= RxTStrb ;
  TxTKeep     <= RxTKeep ;
  TxTLast     <= RxTLast ;

end architecture DUT ;
