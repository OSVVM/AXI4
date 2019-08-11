--
--  File Name:         AxiStreamTbPkg.vhd
--  Design Unit Name:  AxiStreamTbPkg
--  OSVVM Release:     OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Defines types, constants, and subprograms used by
--      OSVVM Axi4 Transaction Based Models (aka: TBM, TLM, VVC)
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date       Version    Description
--    2018.05    2018.05    Initial revision released as AxiStreamTransactionPkg
--
 public release
--      Copyright (c) 2018 - 2019 by SynthWorks Design Inc.  All rights reserved.
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
  use ieee.math_real.all ;

  use std.textio.all ;

library OSVVM ; 
  context OSVVM.OsvvmContext ;  

library osvvm_vip ; 
  context osvvm_vip.OsvvmVipContext ;  
  
package AxiStreamTbPkg is 

  ------------------------------------------------------------
  -- UART Data and Error Injection Settings for Transaction Support
  ------------------------------------------------------------
  subtype  UartTb_DataType is std_logic_vector(7 downto 0) ;
  subtype  UartTb_ErrorModeType is std_logic_vector(3 downto 1) ;


  ------------------------------------------------------------
  -- UART Transaction Record derived from StreamRecType
  ------------------------------------------------------------
  subtype UartRecType is StreamRecType (
    DataToModel   (UartTb_DataType'range), 
    ErrorToModel  (UartTb_ErrorModeType'range), 
    DataFromModel (UartTb_DataType'range), 
    ErrorFromModel(UartTb_ErrorModeType'range) 
  ) ;


  ------------------------------------------------------------
  -- UART Options
  ------------------------------------------------------------
  type UartOptionType is (SET_PARITY_MODE, SET_STOP_BITS, SET_DATA_BITS, SET_BAUD);

  ------------------------------------------------------------
  -- Constants for UART ParityMode, StopBits, DataBits, and Baud
  ------------------------------------------------------------
  ------------------------------------------------------------
  subtype  UartTb_BaudType is time_max ; 
  ------------------------------------------------------------
  constant UARTTB_TIME_BASE         : time := 1 ns ;
  constant UART_BAUD_PERIOD_250K    : time := 4000 ns ;
  constant UART_BAUD_PERIOD_125K    : time := 8000 ns ;
  constant UART_BAUD_PERIOD_115200  : time := 8680 ns ;
  constant UART_BAUD_PERIOD_56K     : time := 8680 ns  * 2 ;
  constant UART_BAUD_PERIOD_28_8K   : time := 8680 ns  * 4 ;
  
  constant BAUD_BINS : CovBinType := GenBin(UART_BAUD_PERIOD_250K/1 ns) & GenBin(UART_BAUD_PERIOD_125K/1 ns) &GenBin(UART_BAUD_PERIOD_115200/1 ns) & GenBin(UART_BAUD_PERIOD_56K/1 ns) & GenBin(UART_BAUD_PERIOD_28_8K/1 ns) ; 

  ------------------------------------------------------------
  subtype  UartTb_DataBitsType is integer_max ; 
  ------------------------------------------------------------
  constant UARTTB_DATA_BITS_5   : UartTb_DataBitsType := 5 ; 
  constant UARTTB_DATA_BITS_6   : UartTb_DataBitsType := 6 ; 
  constant UARTTB_DATA_BITS_7   : UartTb_DataBitsType := 7 ; 
  constant UARTTB_DATA_BITS_8   : UartTb_DataBitsType := 8 ; 
  
  constant DATA_BITS_BINS : CovBinType := GenBin(UARTTB_DATA_BITS_5) & GenBin(UARTTB_DATA_BITS_6) & GenBin(UARTTB_DATA_BITS_7) & GenBin(UARTTB_DATA_BITS_8) ; 

  ------------------------------------------------------------
  subtype  UartTb_ParityModeType is integer_max ; 
  ------------------------------------------------------------
  constant UARTTB_PARITY_NONE   : UartTb_ParityModeType := 0 ; 
  constant UARTTB_PARITY_ODD    : UartTb_ParityModeType := 1 ; 
  constant UARTTB_PARITY_EVEN   : UartTb_ParityModeType := 3 ; 
  constant UARTTB_PARITY_ONE    : UartTb_ParityModeType := 5 ; 
  constant UARTTB_PARITY_ZERO   : UartTb_ParityModeType := 7 ; 

  constant PARITY_MODE_BINS : CovBinType := GenBin(UARTTB_PARITY_NONE) & 
           GenBin(UARTTB_PARITY_ODD) & GenBin(UARTTB_PARITY_EVEN) & 
           GenBin(UARTTB_PARITY_ONE) & GenBin(UARTTB_PARITY_ZERO) ; 

  ------------------------------------------------------------
  subtype UartTb_StopBitsType   is integer_max ; 
  ------------------------------------------------------------
  constant UARTTB_STOP_BITS_1   : integer := 1 ; 
  constant UARTTB_STOP_BITS_2   : integer := 2 ; 
  
  constant STOP_BITS_BINS : CovBinType := GenBin(UARTTB_STOP_BITS_1) & GenBin(UARTTB_STOP_BITS_2) ; 


  ------------------------------------------------------------
  -- UART Scoreboard Support
  ------------------------------------------------------------
  ------------------------------------------------------------
  type UartStimType is record 
  ------------------------------------------------------------
    Data     : std_logic_vector(7 downto 0) ; 
    Error    : UartTb_ErrorModeType ; 
  end record ; 

  ------------------------------------------------------------
  function to_string (
  ------------------------------------------------------------
    constant  rec             : in    UartStimType 
  ) return string ; 

  ------------------------------------------------------------
  function Match (
  ------------------------------------------------------------
    constant  Actual          : in    UartStimType ;
    constant  Expected        : in    UartStimType
  ) return boolean ; 

  
  ------------------------------------------------------------
  -- UART Model Transactions
  ------------------------------------------------------------
  ------------------------------------------------------------
  -- SetUartBaud: 
  procedure SetUartBaud (
  ------------------------------------------------------------
    signal    TransactionRec : inout StreamRecType ;
    constant  Baud           : UartTb_BaudType 
  ) ; 

  ------------------------------------------------------------
  -- SetUartNumDataBits: 
  procedure SetUartNumDataBits (
  ------------------------------------------------------------
    signal    TransactionRec : inout StreamRecType ;
    constant  NumDataBits    : UartTb_DataBitsType 
  ) ; 

  ------------------------------------------------------------
  -- SetParityMode: 
  procedure SetUartParityMode (
  ------------------------------------------------------------
    signal    TransactionRec : inout StreamRecType ;
    constant  ParityMode     : UartTb_ParityModeType 
  ) ; 

  ------------------------------------------------------------
  -- SetUartNumStopBits: 
  procedure SetUartNumStopBits (
  ------------------------------------------------------------
    signal    TransactionRec : inout StreamRecType ;
    constant  NumStopBits    : UartTb_StopBitsType 
  ) ; 

  ------------------------------------------------------------
  -- SetUartState: 
  procedure SetUartState (
  ------------------------------------------------------------
    signal    TransactionRec : inout StreamRecType ;
    constant  Baud           : UartTb_BaudType       := UART_BAUD_PERIOD_115200 ;
    constant  DataBits       : UartTb_DataBitsType   := UARTTB_DATA_BITS_8 ;
    constant  ParityMode     : UartTb_ParityModeType := UARTTB_PARITY_EVEN ;
    constant  StopBits       : UartTb_StopBitsType   := UARTTB_STOP_BITS_1 
  ) ; 
  
  
  ------------------------------------------------------------
  -- UART Model Support
  ------------------------------------------------------------  
  ------------------------------------------------------------
  function CalcParity (
  ------------------------------------------------------------
    constant  Data       : in std_logic_vector ;
    constant  ParityMode : in UartTb_ParityModeType := UARTTB_PARITY_EVEN 
  ) return std_logic ; 


  ------------------------------------------------------------
  -- CheckBaud:  Parameter Check
  impure function CheckBaud (
  ------------------------------------------------------------
    constant  AlertLogID  : in AlertLogIDType ; 
    constant  baud        : in time ;
    constant  StatusMsgOn : in boolean := FALSE 
  ) return time ; 
  
  ------------------------------------------------------------
  -- CheckNumDataBits:  Parameter Check
  impure function CheckNumDataBits (
  ------------------------------------------------------------
    constant  AlertLogID  : in AlertLogIDType ; 
    constant  NumDataBits : in UartTb_DataBitsType ;
    constant  StatusMsgOn : in boolean := FALSE 
  ) return UartTb_DataBitsType ; 

  ------------------------------------------------------------
  -- CheckParityMode:  Parameter Check
  impure function CheckParityMode (
  ------------------------------------------------------------
    constant  AlertLogID  : in AlertLogIDType ; 
    constant  ParityMode  : in UartTb_ParityModeType ;
    constant  StatusMsgOn : in boolean := FALSE 
  ) return UartTb_ParityModeType ; 

  ------------------------------------------------------------
  -- CheckNumStopBits:  Parameter Check
  impure function CheckNumStopBits (
  ------------------------------------------------------------
    constant  AlertLogID  : in AlertLogIDType ; 
    constant  NumStopBits : in UartTb_StopBitsType ;
    constant  StatusMsgOn : in boolean := FALSE 
  ) return UartTb_StopBitsType ; 

  ------------------------------------------------------------
  -- Deprecated transaction procedures from the past
  ------------------------------------------------------------
  alias UartSend is  Send [UartRecType, std_logic_vector, boolean] ;
  alias UartSend is  Send [UartRecType, std_logic_vector, std_logic_vector, boolean] ;
  alias UartGet is   Get  [UartRecType, std_logic_vector, boolean] ;
  alias UartGet is   Get  [UartRecType, std_logic_vector, std_logic_vector, boolean] ;
  alias UartCheck is Check[UartRecType, std_logic_vector, boolean] ;
  alias UartCheck is Check[UartRecType, std_logic_vector, std_logic_vector, boolean] ;
  alias NoOp is      WaitForClock[UartRecType, natural] ;

end AxiStreamTbPkg ;

package body AxiStreamTbPkg is 

  ------------------------------------------------------------
  -- UART Scoreboard Support 
  ------------------------------------------------------------
  ------------------------------------------------------------
  function to_string (
  ------------------------------------------------------------
    constant  rec       : in    UartStimType 
  ) return string is 
  begin
    return "Data = " & to_hstring(rec.Data) & 
           ", Parity Error: " & to_string( rec.Error(UARTTB_PARITY_INDEX)) &
           ", Stop Error: " & to_string( rec.Error(UARTTB_STOP_INDEX)) &
           ", Break Error: " & to_string( rec.Error(UARTTB_BREAK_INDEX)) ;
  end function to_string ; 
  
  ------------------------------------------------------------
  function Match (
  ------------------------------------------------------------
    constant  Actual      : in    UartStimType ;
    constant  Expected    : in    UartStimType
  ) return boolean is 
  begin
    if Expected.Error(UARTTB_BREAK_INDEX) = '1' then 
      return Actual.Error(UARTTB_BREAK_INDEX) = '1' ;
    else 
      return Actual.Data = Expected.Data and Actual.Error = Expected.Error ; 
    end if ; 
  end function Match ; 
  
  
  ------------------------------------------------------------
  -- UART Model Transactions
  ------------------------------------------------------------
  ------------------------------------------------------------
  -- SetUartBaud: 
  procedure SetUartBaud (
  ------------------------------------------------------------
    signal    TransactionRec : inout StreamRecType ;
    constant  Baud           : UartTb_BaudType 
  ) is 
  begin
    SetOption(TransactionRec, UartOptionType'pos(SET_BAUD), Baud) ;
  end procedure SetUartBaud ; 

  ------------------------------------------------------------
  -- SetUartNumDataBits: 
  procedure SetUartNumDataBits (
  ------------------------------------------------------------
    signal    TransactionRec : inout StreamRecType ;
    constant  NumDataBits    : UartTb_DataBitsType 
  ) is 
  begin
    SetOption(TransactionRec, UartOptionType'pos(SET_DATA_BITS), NumDataBits) ;
  end procedure SetUartNumDataBits ; 

  ------------------------------------------------------------
  -- SetParityMode: 
  procedure SetUartParityMode (
  ------------------------------------------------------------
    signal    TransactionRec : inout StreamRecType ;
    constant  ParityMode     : UartTb_ParityModeType 
  ) is 
  begin
    SetOption(TransactionRec, UartOptionType'pos(SET_PARITY_MODE), ParityMode) ;
  end procedure SetUartParityMode ; 

  ------------------------------------------------------------
  -- SetUartNumStopBits: 
  procedure SetUartNumStopBits (
  ------------------------------------------------------------
    signal    TransactionRec : inout StreamRecType ;
    constant  NumStopBits    : UartTb_StopBitsType 
  ) is 
  begin
    SetOption(TransactionRec, UartOptionType'pos(SET_STOP_BITS), NumStopBits) ;
  end procedure SetUartNumStopBits ; 

  ------------------------------------------------------------
  -- SetUartState: 
  procedure SetUartState (
  ------------------------------------------------------------
    signal    TransactionRec : inout StreamRecType ;
    constant  Baud           : UartTb_BaudType       := UART_BAUD_PERIOD_115200 ;
    constant  DataBits       : UartTb_DataBitsType   := UARTTB_DATA_BITS_8 ;
    constant  ParityMode     : UartTb_ParityModeType := UARTTB_PARITY_EVEN ;
    constant  StopBits       : UartTb_StopBitsType   := UARTTB_STOP_BITS_1 
  ) is 
  begin
    SetUartBaud       (TransactionRec, Baud      ) ;
    SetUartNumDataBits(TransactionRec, DataBits  ) ;
    SetUartParityMode (TransactionRec, ParityMode) ; 
    SetUartNumStopBits(TransactionRec, StopBits  ) ;
  end procedure SetUartState ; 
  
  
  ------------------------------------------------------------
  -- UART Model Support
  ------------------------------------------------------------
  ------------------------------------------------------------
  function CalcParity (
  ------------------------------------------------------------
    constant  Data       : in std_logic_vector ;
    constant  ParityMode : in UartTb_ParityModeType := UARTTB_PARITY_EVEN 
  ) return std_logic is 
  begin
    case ParityMode is
      when UARTTB_PARITY_ODD  =>  return not (xor Data) ;
      when UARTTB_PARITY_EVEN =>  return xor Data ; 
      when UARTTB_PARITY_ONE  =>  return '1' ; 
      when UARTTB_PARITY_ZERO =>  return '0' ;
      when others =>              return '-' ;
    end case ; 
  end function CalcParity ; 


  ------------------------------------------------------------
  -- CheckBaud:  Parameter Check
  impure function CheckBaud (
  ------------------------------------------------------------
    constant  AlertLogID  : in AlertLogIDType ; 
    constant  baud        : in time ;
    constant  StatusMsgOn : in boolean := FALSE 
  ) return time is 
    variable ResultBaud : time ;
  begin
    if baud <= 0 sec then
      Alert(AlertLogID, 
        "Unsupported baud = " & to_string(baud) & ". Using UART_BAUD_PERIOD_125K", ERROR) ;
      ResultBaud := UART_BAUD_PERIOD_125K ; 
    else
      log(AlertLogID, "Baud set to " & to_string(baud, 1 ns), INFO, StatusMsgOn) ;
      ResultBaud := Baud ; 
    end if ; 
    return ResultBaud ; 
  end function CheckBaud ; 

  ------------------------------------------------------------
  -- CheckNumDataBits:  Parameter Check
  impure function CheckNumDataBits (
  ------------------------------------------------------------
    constant  AlertLogID  : in AlertLogIDType ; 
    constant  NumDataBits : in UartTb_DataBitsType ;
    constant  StatusMsgOn : in boolean := FALSE 
  ) return UartTb_DataBitsType is 
    variable ResultNumDataBits : UartTb_DataBitsType ;
  begin
    ResultNumDataBits := NumDataBits ; 
    case NumDataBits is
      when UARTTB_DATA_BITS_5 =>   log(AlertLogID, "NumDataBits set to UARTTB_DATA_BITS_5", INFO, StatusMsgOn) ;
      when UARTTB_DATA_BITS_6  =>  log(AlertLogID, "NumDataBits set to UARTTB_DATA_BITS_6", INFO, StatusMsgOn) ;
      when UARTTB_DATA_BITS_7 =>   log(AlertLogID, "NumDataBits set to UARTTB_DATA_BITS_7", INFO, StatusMsgOn) ;
      when UARTTB_DATA_BITS_8  =>  log(AlertLogID, "NumDataBits set to UARTTB_DATA_BITS_8", INFO, StatusMsgOn) ;
      when others => 
        Alert(AlertLogID, 
          "Unsupported NumDataBits = " & to_string(NumDataBits) & ". Using UARTTB_DATA_BITS_8", ERROR) ;
        ResultNumDataBits := UARTTB_DATA_BITS_8 ; 
    end case ; 
    return ResultNumDataBits ; 
  end function CheckNumDataBits ; 

  ------------------------------------------------------------
  -- CheckParityMode:  Parameter Check
  impure function CheckParityMode (
  ------------------------------------------------------------
    constant  AlertLogID  : in AlertLogIDType ; 
    constant  ParityMode  : in UartTb_ParityModeType ;
    constant  StatusMsgOn : in boolean := FALSE 
  ) return UartTb_ParityModeType is 
    variable ResultParityMode : UartTb_ParityModeType ;
  begin
    ResultParityMode := ParityMode ; 
    case ParityMode is
      when UARTTB_PARITY_NONE =>  log(AlertLogID, "ParityMode set to UARTTB_PARITY_NONE", INFO, StatusMsgOn) ;
      when UARTTB_PARITY_ODD  =>  log(AlertLogID, "ParityMode set to UARTTB_PARITY_ODD",  INFO, StatusMsgOn) ;
      when UARTTB_PARITY_EVEN =>  log(AlertLogID, "ParityMode set to UARTTB_PARITY_EVEN", INFO, StatusMsgOn) ; 
      when UARTTB_PARITY_ONE  =>  log(AlertLogID, "ParityMode set to UARTTB_PARITY_ONE",  INFO, StatusMsgOn) ;
      when UARTTB_PARITY_ZERO =>  log(AlertLogID, "ParityMode set to UARTTB_PARITY_ZERO", INFO, StatusMsgOn) ;
      when others => 
        Alert(AlertLogID, 
          "Unsupported ParityMode = " & to_string(ParityMode) & ". Using EVEN PARITY", ERROR) ;
        ResultParityMode := UARTTB_PARITY_EVEN ; 
    end case ; 
    return ResultParityMode ; 
  end function CheckParityMode ; 

  ------------------------------------------------------------
  -- CheckNumStopBits:  Parameter Check
  impure function CheckNumStopBits (
  ------------------------------------------------------------
    constant  AlertLogID  : in AlertLogIDType ; 
    constant  NumStopBits : in UartTb_StopBitsType ;
    constant  StatusMsgOn : in boolean := FALSE 
  ) return UartTb_StopBitsType is 
    variable ResultNumStopBits : UartTb_StopBitsType ;
  begin
    ResultNumStopBits := NumStopBits ; 
    case NumStopBits is
      when UARTTB_STOP_BITS_1 =>   log(AlertLogID, "NumStopBits set to UARTTB_STOP_BITS_1", INFO, StatusMsgOn) ;
      when UARTTB_STOP_BITS_2  =>  log(AlertLogID, "NumStopBits set to UARTTB_STOP_BITS_2", INFO, StatusMsgOn) ;
      when others => 
        Alert(AlertLogID, 
          "Unsupported NumStopBits = " & to_string(NumStopBits) & ". Using UARTTB_STOP_BITS_1", ERROR) ;
        ResultNumStopBits := UARTTB_STOP_BITS_1 ; 
    end case ; 
    return ResultNumStopBits ; 
  end function CheckNumStopBits ; 

end AxiStreamTbPkg ;
