--
--  File Name:         AxiStreamOptionsTypePkg.vhd
--  Design Unit Name:  AxiStreamOptionsTypePkg
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Defines types, constants, and subprograms used by
--      OSVVM Axi Stream Transaction Based Models (aka: TBM, TLM, VVC)
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    05/2018   2018.05    Initial revision
--    01/2020   2020.01    Updated license notice
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2018 - 2020 by SynthWorks Design Inc.  
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
    
library OSVVM_Common ;
    context OSVVM_Common.OsvvmCommonContext ; 
    
package AxiStreamOptionsTypePkg is

  -- Model AXI Lite Operations
  type AxiStreamUnresolvedOptionsType is (
    TRANSMIT_READY_TIME_OUT,
    RECEIVE_READY_BEFORE_VALID,
    RECEIVE_READY_DELAY_CYCLES,
    SET_ID,
    SET_DEST,
    SET_USER,
    END_PARAMS,
    THE_END
  ) ;

  type AxiStreamUnresolvedOptionsVectorType is array (natural range <>) of AxiStreamUnresolvedOptionsType ;
  -- alias resolved_max is maximum[ AxiStreamUnresolvedOptionsVectorType return AxiStreamUnresolvedOptionsType] ;
  function resolved_max(A : AxiStreamUnresolvedOptionsVectorType) return AxiStreamUnresolvedOptionsType ;

  subtype AxiStreamOptionsType is resolved_max AxiStreamUnresolvedOptionsType ;
  
  type AxiParamsType is array (AxiStreamOptionsType range <>) of integer ; 

--! Need init Parms for default values - many parms all init with ignore values & 
--! call via named association

  ------------------------------------------------------------
  function IsAxiParameter (
  -----------------------------------------------------------
    constant Operation     : in AxiStreamOptionsType
  ) return boolean ;

  ------------------------------------------------------------
  function IsAxiInterface (
  -----------------------------------------------------------
    constant Operation     : in AxiStreamOptionsType
  ) return boolean ;
  
  ------------------------------------------------------------
  procedure SetAxiOption (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    AxiStreamOptionsType ;
    constant OpVal         : in    boolean  
  ) ; 
  
  ------------------------------------------------------------
  procedure SetAxiOption (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    AxiStreamOptionsType ;
    constant OpVal         : in    integer  
  ) ; 
  
  ------------------------------------------------------------
  procedure SetAxiOption (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    AxiStreamOptionsType ;
    constant OpVal         : in    std_logic_vector  
  ) ; 
  
  ------------------------------------------------------------
  procedure GetAxiOption (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    AxiStreamOptionsType ;
    variable OpVal         : out   boolean  
  ) ; 
  
  ------------------------------------------------------------
  procedure GetAxiOption (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    AxiStreamOptionsType ;
    variable OpVal         : out   integer  
  ) ; 

  ------------------------------------------------------------
  procedure GetAxiOption (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    AxiStreamOptionsType ;
    variable OpVal         : out   std_logic_vector  
  ) ;  
    
--  ------------------------------------------------------------
--  procedure InitAxiOptions (
--  -----------------------------------------------------------
--    variable Params        : InOut ModelParametersPType --;
----    signal   AxiBus        : In    AxiStreamBaseRecType 
--  ) ;
--
--  ------------------------------------------------------------
--  procedure SetAxiParameter (
--  -----------------------------------------------------------
--    variable AxiBus        : out AxiStreamBaseRecType ;
--    constant Operation     : in  AxiStreamOptionsType ;
--    constant OpVal         : in  integer  
--  ) ;
--  
--  ------------------------------------------------------------
--  function GetAxiParameter (
--  -----------------------------------------------------------
--    constant AxiBus        : in  AxiStreamBaseRecType ;
--    constant Operation     : in  AxiStreamOptionsType 
--  ) return integer ;
  
  --
  --  Extensions to support model customizations
  -- 
--!! Need GetModelOptions  
  ------------------------------------------------------------
  procedure SetModelOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut StreamRecType ;
    constant Option      : In    AxiStreamOptionsType ;
    constant OptVal      : In    boolean
  ) ;

  ------------------------------------------------------------
  procedure SetModelOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut StreamRecType ;
    constant Option      : In    AxiStreamOptionsType ;
    constant OptVal      : In    integer
  ) ;

  ------------------------------------------------------------
  procedure SetModelOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut StreamRecType ;
    constant Option      : In    AxiStreamOptionsType ;
    constant OptVal      : In    std_logic_vector
  ) ;


end package AxiStreamOptionsTypePkg ;

-- /////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////

package body AxiStreamOptionsTypePkg is

  function resolved_max(A : AxiStreamUnresolvedOptionsVectorType) return AxiStreamUnresolvedOptionsType is
  begin
    return maximum(A) ;
  end function resolved_max ;
  
  ------------------------------------------------------------
  function IsAxiParameter (
  -----------------------------------------------------------
    constant Operation     : in AxiStreamOptionsType
  ) return boolean is
  begin
    return (Operation < END_PARAMS) ;
  end function IsAxiParameter ;

  ------------------------------------------------------------
  function IsAxiInterface (
  -----------------------------------------------------------
    constant Operation     : in AxiStreamOptionsType
  ) return boolean is
  begin
    return (Operation >= END_PARAMS) ;
  end function IsAxiInterface ;
   
  ------------------------------------------------------------
  procedure SetAxiOption (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    AxiStreamOptionsType ;
    constant OpVal         : in    boolean  
  ) is
  begin
    Params.Set(AxiStreamOptionsType'POS(Operation), OpVal) ;
  end procedure SetAxiOption ; 
 
  ------------------------------------------------------------
  procedure SetAxiOption (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    AxiStreamOptionsType ;
    constant OpVal         : in    integer  
  ) is
  begin
    Params.Set(AxiStreamOptionsType'POS(Operation), OpVal) ;
  end procedure SetAxiOption ; 
  
  ------------------------------------------------------------
  procedure SetAxiOption (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    AxiStreamOptionsType ;
    constant OpVal         : in    std_logic_vector  
  ) is
  begin
    Params.Set(AxiStreamOptionsType'POS(Operation), OpVal) ;
  end procedure SetAxiOption ; 
  
  ------------------------------------------------------------
  procedure GetAxiOption (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    AxiStreamOptionsType ;
    variable OpVal         : out   boolean  
  ) is
  begin
    OpVal := Params.Get(AxiStreamOptionsType'POS(Operation)) ;
  end procedure GetAxiOption ; 
  
  ------------------------------------------------------------
  procedure GetAxiOption (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    AxiStreamOptionsType ;
    variable OpVal         : out   integer  
  ) is
  begin
    OpVal := Params.Get(AxiStreamOptionsType'POS(Operation)) ;
  end procedure GetAxiOption ; 
  
  ------------------------------------------------------------
  procedure GetAxiOption (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    AxiStreamOptionsType ;
    variable OpVal         : out   std_logic_vector  
  ) is
  begin
    OpVal := Params.Get(AxiStreamOptionsType'POS(Operation), OpVal'length) ;
  end procedure GetAxiOption ; 
  
--   ------------------------------------------------------------
--   procedure InitAxiStreamOptions (
--   -----------------------------------------------------------
--     variable Params        : InOut ModelParametersPType --;
-- --    signal   AxiBus        : In    AxiStreamBaseRecType 
--   ) is
--   begin
--    -- Size the Data structure, such that it creates 1 parameter for each option
--    Params.Init(1 + AxiStreamOptionsType'POS(READ_DATA_VALID_TIME_OUT)) ;
--    
--    -- AxiStream Model Options
--    -- Ready timeout
--    SetAxiOption(Params, WRITE_ADDRESS_READY_TIME_OUT,       25 ) ; 
--    SetAxiOption(Params, WRITE_DATA_READY_TIME_OUT,          25 ) ; 
--    SetAxiOption(Params, WRITE_RESPONSE_READY_TIME_OUT,      25 ) ; -- S
--    SetAxiOption(Params, READ_ADDRESS_READY_TIME_OUT,        25 ) ; 
--    SetAxiOption(Params, READ_DATA_READY_TIME_OUT,           25 ) ; -- S
--    
--    -- Ready Controls
--    SetAxiOption(Params, WRITE_ADDRESS_READY_BEFORE_VALID,   TRUE) ; -- S
--    SetAxiOption(Params, WRITE_DATA_READY_BEFORE_VALID,      TRUE) ; -- S
--    SetAxiOption(Params, WRITE_RESPONSE_READY_BEFORE_VALID,  TRUE) ; 
--    SetAxiOption(Params, READ_ADDRESS_READY_BEFORE_VALID,    TRUE) ; -- S
--    SetAxiOption(Params, READ_DATA_READY_BEFORE_VALID,       TRUE) ; 
--    
--    -- Ready Controls
--    SetAxiOption(Params, WRITE_ADDRESS_READY_DELAY_CYCLES,   0) ;  -- S
--    SetAxiOption(Params, WRITE_DATA_READY_DELAY_CYCLES,      0) ;  -- S
--    SetAxiOption(Params, WRITE_RESPONSE_READY_DELAY_CYCLES,  0) ;  
--    SetAxiOption(Params, READ_ADDRESS_READY_DELAY_CYCLES,    0) ;  -- S
--    SetAxiOption(Params, READ_DATA_READY_DELAY_CYCLES,       0) ;  
--
--    -- Valid Timeouts 
--    SetAxiOption(Params, WRITE_RESPONSE_VALID_TIME_OUT,      25) ; 
--    SetAxiOption(Params, READ_DATA_VALID_TIME_OUT,           25) ; 
-- 
--  end procedure InitAxiOptions ; 

 
--  ------------------------------------------------------------
--  procedure SetAxiParameter (
--  -----------------------------------------------------------
--    variable AxiBus        : out AxiStreamBaseRecType ;
--    constant Operation     : in  AxiStreamOptionsType ;
--    constant OpVal         : in  integer  
--  ) is
--  begin
--    case Operation is
--     -- Read Data: AXI
--     when RRESP =>         AxiBus.ReadData.RResp       := to_slv(OpVal, AxiBus.ReadData.RResp'length) ;
--       
--     -- AxiStream Full
--     when RID =>           AxiBus.ReadData.RID         := to_slv(OpVal, AxiBus.ReadData.RID'length) ; 
--     when RLAST =>         AxiBus.ReadData.RLast       := '1' when OpVal mod 2 = 1 else '0' ;
--     when RUSER =>         AxiBus.ReadData.RUser       := to_slv(OpVal, AxiBus.ReadData.RUser'length) ; 
--
--     -- The End -- Done
--     when others =>
--       Alert("Unknown model option", FAILURE) ;
--        
--    end case ; 
--  end procedure SetAxiParameter ;
  
--  ------------------------------------------------------------
--  function GetAxiParameter (
--  -----------------------------------------------------------
--    constant AxiBus        : in  AxiStreamBaseRecType ;
--    constant Operation     : in  AxiStreamOptionsType 
--  ) return integer is
--  begin
--    case Operation is
--                      
--      -- Read Data            
--      when RRESP =>              return to_integer(AxiBus.ReadData.RResp) ;   
--                       
--      -- AxiStream Full            
--      when RID =>                return to_integer(AxiBus.ReadData.RID   ) ;
--      when RLAST =>              return to_integer(AxiBus.ReadData.RLast ) ;   
--      when RUSER =>              return to_integer(AxiBus.ReadData.RUser ) ;
--
--      -- The End -- Done
--      when others =>
----        Alert(ModelID, "Unknown model option", FAILURE) ;
--        Alert("Unknown model option", FAILURE) ;
--        return integer'left ; 
--        
--    end case ; 
--  end function GetAxiParameter ;
  
  --
  --  Extensions to support model customizations
  -- 
  ------------------------------------------------------------
  procedure SetModelOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut StreamRecType ;
    constant Option      : In    AxiStreamOptionsType ;
    constant OptVal      : In    boolean
  ) is
  begin
    SetModelOptions(TransRec, AxiStreamOptionsType'POS(Option), OptVal) ;
  end procedure SetModelOptions ;

  ------------------------------------------------------------
  procedure SetModelOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut StreamRecType ;
    constant Option      : In    AxiStreamOptionsType ;
    constant OptVal      : In    integer
  ) is
  begin
    SetModelOptions(TransRec, AxiStreamOptionsType'POS(Option), OptVal) ;
  end procedure SetModelOptions ;

  ------------------------------------------------------------
  procedure SetModelOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut StreamRecType ;
    constant Option      : In    AxiStreamOptionsType ;
    constant OptVal      : In    std_logic_vector
  ) is
  begin
    SetModelOptions(TransRec, AxiStreamOptionsType'POS(Option), OptVal) ;
  end procedure SetModelOptions ;
  

end package body AxiStreamOptionsTypePkg ;