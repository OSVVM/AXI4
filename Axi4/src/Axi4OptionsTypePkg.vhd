--
--  File Name:         Axi4OptionsTypePkg.vhd
--  Design Unit Name:  Axi4OptionsTypePkg
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Defines types, constants, and subprograms used by
--      OSVVM Address Bus Transaction Based Models (aka: TBM, TLM, VVC)
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    01/2020   2020.02    Refactored from Axi4MasterTransactionPkg.vhd
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
  use ieee.math_real.all ;

library osvvm ;
    context osvvm.OsvvmContext ;
    
library OSVVM_Common ;
    context OSVVM_Common.OsvvmCommonContext ; 

use work.Axi4InterfacePkg.all ; 


package Axi4OptionsTypePkg is

  type Axi4UnresolvedOptionsType is (
    -- AXI4 Model Options
    -- Ready timeout
    WRITE_ADDRESS_READY_TIME_OUT,
    WRITE_DATA_READY_TIME_OUT,
    WRITE_RESPONSE_READY_TIME_OUT,      -- S
    READ_ADDRESS_READY_TIME_OUT,
    READ_DATA_READY_TIME_OUT,           -- S
    
    -- Ready Controls
    WRITE_ADDRESS_READY_BEFORE_VALID,   -- S
    WRITE_DATA_READY_BEFORE_VALID,      -- S
    WRITE_RESPONSE_READY_BEFORE_VALID,
    READ_ADDRESS_READY_BEFORE_VALID,    -- S
    READ_DATA_READY_BEFORE_VALID,
    
    -- Ready Controls
    WRITE_ADDRESS_READY_DELAY_CYCLES,   -- S
    WRITE_DATA_READY_DELAY_CYCLES,      -- S
    WRITE_RESPONSE_READY_DELAY_CYCLES,
    READ_ADDRESS_READY_DELAY_CYCLES,    -- S
    READ_DATA_READY_DELAY_CYCLES,

    -- Valid Timeouts 
    WRITE_RESPONSE_VALID_TIME_OUT,
    READ_DATA_VALID_TIME_OUT,
    
-- AXI Interface Settings    
    -- AXI
--    AWADDR,
    AWPROT,
--    AWVALID,
--    AWREADY,
    -- Axi4 Full
    AWID,
--    AWLEN,
    AWSIZE,
    AWBURST,
    AWLOCK,
    AWCACHE,
    AWQOS,
    AWREGION,
    AWUSER,

    -- Write Data
--    WDATA,
--    WSTRB,
--    WVALID,
--    WREADY,
    -- AXI4 Full
    WLAST,
    WUSER,
    -- AXI3
    WID,

    -- Write Response
    BRESP,
--    BVALID,
--    BREADY,
    -- AXI4 Full
    BID,
    BUSER,

    -- Read Address
--    ARADDR,
    ARPROT,
--    ARVALID,
--    ARREADY,
    -- Axi4 Full
    ARID,
    -- BURSTLength = AxLen+1.  AXI4,
--    ARLEN,
    -- #Bytes in transfer = 2**AxSize
    ARSIZE,
    -- AxBURST = (Fixed, Incr, Wrap, NotDefined)
    ARBURST,
    ARLOCK,
    -- AxCACHE One-hot (Write-Allocate, Read-Allocate, Modifiable, Bufferable)
    ARCACHE,
    ARQOS,
    ARREGION,
    ARUSER,

    -- Read DATA
--    RDATA,
    RRESP,
--    RVALID,
--    RREADY,
    -- AXI4 Full
    RID,
    RLAST,
    RUSER,
    --
    -- The End -- Done
    THE_END
  ) ;
  type Axi4UnresolvedOptionsVectorType is array (natural range <>) of Axi4UnresolvedOptionsType ;
  -- alias resolved_max is maximum[ Axi4UnresolvedOptionsVectorType return Axi4UnresolvedOptionsType] ;
  function resolved_max(A : Axi4UnresolvedOptionsVectorType) return Axi4UnresolvedOptionsType ;

  subtype Axi4OptionsType is resolved_max Axi4UnresolvedOptionsType ;
  
  type AxiParamsType is array (Axi4OptionsType range <>) of integer ; 

--! Need init Parms for default values - many parms all init with ignore values & 
--! call via named association

  ------------------------------------------------------------
  function IsAxiParameter (
  -----------------------------------------------------------
    constant Operation     : in Axi4OptionsType
  ) return boolean ;

  ------------------------------------------------------------
  function IsAxiInterface (
  -----------------------------------------------------------
    constant Operation     : in Axi4OptionsType
  ) return boolean ;
  
  ------------------------------------------------------------
  procedure SetAxiOption (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    constant OpVal         : in    boolean  
  ) ; 
  
  ------------------------------------------------------------
  procedure SetAxiOption (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    constant OpVal         : in    integer  
  ) ; 
  
  ------------------------------------------------------------
  procedure SetAxiOption (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    constant OpVal         : in    std_logic_vector  
  ) ; 
  
  ------------------------------------------------------------
  procedure GetAxiOption (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    variable OpVal         : out   boolean  
  ) ; 
  
  ------------------------------------------------------------
  procedure GetAxiOption (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    variable OpVal         : out   integer  
  ) ; 

  ------------------------------------------------------------
  procedure GetAxiOption (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    variable OpVal         : out   std_logic_vector  
  ) ;  
    
  ------------------------------------------------------------
  procedure InitAxiOptions (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType --;
--    signal   AxiBus        : In    Axi4BaseRecType 
  ) ;

  ------------------------------------------------------------
  procedure SetAxiParameter (
  -----------------------------------------------------------
    variable AxiBus        : out Axi4BaseRecType ;
    constant Operation     : in  Axi4OptionsType ;
    constant OpVal         : in  integer  
  ) ;
  
  ------------------------------------------------------------
  function GetAxiParameter (
  -----------------------------------------------------------
    constant AxiBus        : in  Axi4BaseRecType ;
    constant Operation     : in  Axi4OptionsType 
  ) return integer ;
  
  --
  --  Extensions to support model customizations
  -- 
--!! Need GetModelOptions  
  ------------------------------------------------------------
  procedure SetModelOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut AddressBusTransactionRecType ;
    constant Option      : In    Axi4OptionsType ;
    constant OptVal      : In    boolean
  ) ;

  ------------------------------------------------------------
  procedure SetModelOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut AddressBusTransactionRecType ;
    constant Option      : In    Axi4OptionsType ;
    constant OptVal      : In    integer
  ) ;

  ------------------------------------------------------------
  procedure SetModelOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut AddressBusTransactionRecType ;
    constant Option      : In    Axi4OptionsType ;
    constant OptVal      : In    std_logic_vector
  ) ;


end package Axi4OptionsTypePkg ;

-- /////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////

package body Axi4OptionsTypePkg is

  function resolved_max(A : Axi4UnresolvedOptionsVectorType) return Axi4UnresolvedOptionsType is
  begin
    return maximum(A) ;
  end function resolved_max ;
  
  ------------------------------------------------------------
  function IsAxiParameter (
  -----------------------------------------------------------
    constant Operation     : in Axi4OptionsType
  ) return boolean is
  begin
    return (Operation < AWPROT) ;
  end function IsAxiParameter ;

  ------------------------------------------------------------
  function IsAxiInterface (
  -----------------------------------------------------------
    constant Operation     : in Axi4OptionsType
  ) return boolean is
  begin
    return (Operation >= AWPROT) ;
  end function IsAxiInterface ;
   
  ------------------------------------------------------------
  procedure SetAxiOption (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    constant OpVal         : in    boolean  
  ) is
  begin
    Params.Set(Axi4OptionsType'POS(Operation), OpVal) ;
  end procedure SetAxiOption ; 
 
  ------------------------------------------------------------
  procedure SetAxiOption (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    constant OpVal         : in    integer  
  ) is
  begin
    Params.Set(Axi4OptionsType'POS(Operation), OpVal) ;
  end procedure SetAxiOption ; 
  
  ------------------------------------------------------------
  procedure SetAxiOption (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    constant OpVal         : in    std_logic_vector  
  ) is
  begin
    Params.Set(Axi4OptionsType'POS(Operation), OpVal) ;
  end procedure SetAxiOption ; 
  
  ------------------------------------------------------------
  procedure GetAxiOption (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    variable OpVal         : out   boolean  
  ) is
  begin
    OpVal := Params.Get(Axi4OptionsType'POS(Operation)) ;
  end procedure GetAxiOption ; 
  
  ------------------------------------------------------------
  procedure GetAxiOption (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    variable OpVal         : out   integer  
  ) is
  begin
    OpVal := Params.Get(Axi4OptionsType'POS(Operation)) ;
  end procedure GetAxiOption ; 
  
  ------------------------------------------------------------
  procedure GetAxiOption (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType ;
    constant Operation     : in    Axi4OptionsType ;
    variable OpVal         : out   std_logic_vector  
  ) is
  begin
    OpVal := Params.Get(Axi4OptionsType'POS(Operation), OpVal'length) ;
  end procedure GetAxiOption ; 
  
  ------------------------------------------------------------
  procedure InitAxiOptions (
  -----------------------------------------------------------
    variable Params        : InOut ModelParametersPType --;
--    signal   AxiBus        : In    Axi4BaseRecType 
  ) is
  begin
    -- Size the Data structure, such that it creates 1 parameter for each option
    Params.Init(1 + Axi4OptionsType'POS(READ_DATA_VALID_TIME_OUT)) ;
    
    -- AXI4 Model Options
    -- Ready timeout
    SetAxiOption(Params, WRITE_ADDRESS_READY_TIME_OUT,       25 ) ; 
    SetAxiOption(Params, WRITE_DATA_READY_TIME_OUT,          25 ) ; 
    SetAxiOption(Params, WRITE_RESPONSE_READY_TIME_OUT,      25 ) ; -- S
    SetAxiOption(Params, READ_ADDRESS_READY_TIME_OUT,        25 ) ; 
    SetAxiOption(Params, READ_DATA_READY_TIME_OUT,           25 ) ; -- S
    
    -- Ready Controls
    SetAxiOption(Params, WRITE_ADDRESS_READY_BEFORE_VALID,   TRUE) ; -- S
    SetAxiOption(Params, WRITE_DATA_READY_BEFORE_VALID,      TRUE) ; -- S
    SetAxiOption(Params, WRITE_RESPONSE_READY_BEFORE_VALID,  TRUE) ; 
    SetAxiOption(Params, READ_ADDRESS_READY_BEFORE_VALID,    TRUE) ; -- S
    SetAxiOption(Params, READ_DATA_READY_BEFORE_VALID,       TRUE) ; 
    
    -- Ready Controls
    SetAxiOption(Params, WRITE_ADDRESS_READY_DELAY_CYCLES,   0) ;  -- S
    SetAxiOption(Params, WRITE_DATA_READY_DELAY_CYCLES,      0) ;  -- S
    SetAxiOption(Params, WRITE_RESPONSE_READY_DELAY_CYCLES,  0) ;  
    SetAxiOption(Params, READ_ADDRESS_READY_DELAY_CYCLES,    0) ;  -- S
    SetAxiOption(Params, READ_DATA_READY_DELAY_CYCLES,       0) ;  

    -- Valid Timeouts 
    SetAxiOption(Params, WRITE_RESPONSE_VALID_TIME_OUT,      25) ; 
    SetAxiOption(Params, READ_DATA_VALID_TIME_OUT,           25) ; 

--    -- AXI Interface Settings    
--    -- Set all AXI bus parameters to 0 and Size them to match the corresponding AXI Bus signal.
--    -- Write Address
--    SetAxiOption(Params, AWPROT,    to_slv(0, AxiBus.WriteAddress.AWProt'length)) ;
--    SetAxiOption(Params, AWID,      to_slv(0, AxiBus.WriteAddress.AWID'length)) ;
--    SetAxiOption(Params, AWSIZE,    to_slv(0, AxiBus.WriteAddress.AWSize'length)) ;
--    SetAxiOption(Params, AWBURST,   to_slv(0, AxiBus.WriteAddress.AWBurst'length)) ;
--    SetAxiOption(Params, AWLOCK,    to_slv(0, 1)) ;
--    SetAxiOption(Params, AWCACHE,   to_slv(0, AxiBus.WriteAddress.AWCache'length)) ;
--    SetAxiOption(Params, AWQOS,     to_slv(0, AxiBus.WriteAddress.AWRegion'length)) ;
--    SetAxiOption(Params, AWREGION,  to_slv(0, AxiBus.WriteAddress.AWSize'length)) ;
--    SetAxiOption(Params, AWUSER,    to_slv(0, AxiBus.WriteAddress.AWUser'length)) ;
--    -- Write Data
--    SetAxiOption(Params, WLAST,     to_slv(0, 1)) ;
--    SetAxiOption(Params, WUSER,     to_slv(0, AxiBus.WriteData.WUser'length)) ;
--    SetAxiOption(Params, WID,       to_slv(0, AxiBus.WriteData.WID'length)) ;
--    -- Write Response
--    SetAxiOption(Params, BRESP,     to_slv(0, AxiBus.WriteResponse.BResp'length)) ;
--    SetAxiOption(Params, BID,       to_slv(0, AxiBus.WriteResponse.BID'length)) ;
--    SetAxiOption(Params, BUSER,     to_slv(0, AxiBus.WriteResponse.BUser'length)) ;
--    -- Read Address
--    SetAxiOption(Params, ARPROT,            to_slv(0, AxiBus.ReadAddress.ARProt'length)) ;
--    SetAxiOption(Params, ARID,      to_slv(0, AxiBus.ReadAddress.ARID'length)) ;
--    SetAxiOption(Params, ARSIZE,    to_slv(0, AxiBus.ReadAddress.ARSize'length)) ;
--    SetAxiOption(Params, ARBURST,   to_slv(0, AxiBus.ReadAddress.ARBurst'length)) ;
--    SetAxiOption(Params, ARLOCK,    to_slv(0, 1)) ;
--    SetAxiOption(Params, ARCACHE,   to_slv(0, AxiBus.ReadAddress.ARCache'length)) ;
--    SetAxiOption(Params, ARQOS,     to_slv(0, AxiBus.ReadAddress.ARQOS'length)) ;
--    SetAxiOption(Params, ARREGION,  to_slv(0, AxiBus.ReadAddress.ARRegion'length)) ;
--    SetAxiOption(Params, ARUSER,    to_slv(0, AxiBus.ReadAddress.ARUser'length)) ;
--    -- Read Data
--    SetAxiOption(Params, RRESP,     to_slv(0, AxiBus.ReadData.RResp'length)) ;
--    SetAxiOption(Params, RID,       to_slv(0, AxiBus.ReadData.RID'length)) ;
--    SetAxiOption(Params, RLAST,     to_slv(0, 1)) ;
--    SetAxiOption(Params, RUSER,     to_slv(0, AxiBus.ReadData.RUser'length)) ;
  end procedure InitAxiOptions ; 

 
  ------------------------------------------------------------
  procedure SetAxiParameter (
  -----------------------------------------------------------
    variable AxiBus        : out Axi4BaseRecType ;
    constant Operation     : in  Axi4OptionsType ;
    constant OpVal         : in  integer  
  ) is
  begin
    case Operation is
      -- AXI
      when AWPROT =>       AxiBus.WriteAddress.AWProt   := to_slv(OpVal, AxiBus.WriteAddress.AWProt'length) ;
        
      -- AXI4 Full
      when AWID =>         AxiBus.WriteAddress.AWID     := to_slv(OpVal, AxiBus.WriteAddress.AWID'length) ;
      when AWSIZE =>       AxiBus.WriteAddress.AWSize   := to_slv(OpVal, AxiBus.WriteAddress.AWSize'length) ;
      when AWBURST =>      AxiBus.WriteAddress.AWBurst  := to_slv(OpVal, AxiBus.WriteAddress.AWBurst'length) ;
      when AWLOCK =>       AxiBus.WriteAddress.AWLock   := '1' when OpVal mod 2 = 1 else '0' ; 
      when AWCACHE =>      AxiBus.WriteAddress.AWCache  := to_slv(OpVal, AxiBus.WriteAddress.AWCache'length) ;
      when AWQOS =>        AxiBus.WriteAddress.AWQOS    := to_slv(OpVal, AxiBus.WriteAddress.AWQOS'length) ;
      when AWREGION =>     AxiBus.WriteAddress.AWRegion := to_slv(OpVal, AxiBus.WriteAddress.AWRegion'length) ;
      when AWUSER =>       AxiBus.WriteAddress.AWUser   := to_slv(OpVal, AxiBus.WriteAddress.AWUser'length) ;

      -- Write Data:  AXI
      -- AXI4 Full
      when WLAST =>        AxiBus.WriteData.WLast       := '1' when OpVal mod 2 = 1 else '0' ;
      when WUSER =>        AxiBus.WriteData.WUser       := to_slv(OpVal, AxiBus.WriteData.WUser'length) ;
                                                        
      -- AXI3                                           
      when WID =>          AxiBus.WriteData.WID         := to_slv(OpVal, AxiBus.WriteData.WID'length) ; 
              
      -- Write Response:  AXI
      when BRESP =>        AxiBus.WriteResponse.BResp   := to_slv(OpVal, AxiBus.WriteResponse.BResp'length) ;
                                                        
      -- AXI4 Full                                      
      when BID =>          AxiBus.WriteResponse.BID     := to_slv(OpVal, AxiBus.WriteResponse.BID'length) ;
      when BUSER =>        AxiBus.WriteResponse.BUser   := to_slv(OpVal, AxiBus.WriteResponse.BUser'length) ; 
                                                        
      -- Read Address:  AXI
      when ARPROT =>       AxiBus.ReadAddress.ARProt    := to_slv(OpVal, AxiBus.ReadAddress.ARProt'length) ;
        
      -- AXI4 Full
      when ARID =>         AxiBus.ReadAddress.ARID      := to_slv(OpVal, AxiBus.ReadAddress.ARID'length) ;
      when ARSIZE =>       AxiBus.ReadAddress.ARSize    := to_slv(OpVal, AxiBus.ReadAddress.ARSize'length) ;
      when ARBURST =>      AxiBus.ReadAddress.ARBurst   := to_slv(OpVal, AxiBus.ReadAddress.ARBurst'length) ;
      when ARLOCK =>       AxiBus.ReadAddress.ARLock    := '1' when OpVal mod 2 = 1 else '0' ;
      when ARCACHE =>      AxiBus.ReadAddress.ARCache   := to_slv(OpVal, AxiBus.ReadAddress.ARCache'length) ;
      when ARQOS =>        AxiBus.ReadAddress.ARQOS     := to_slv(OpVal, AxiBus.ReadAddress.ARQOS'length) ;
      when ARREGION =>     AxiBus.ReadAddress.ARRegion  := to_slv(OpVal, AxiBus.ReadAddress.ARRegion'length) ;
      when ARUSER =>       AxiBus.ReadAddress.ARUser    := to_slv(OpVal, AxiBus.ReadAddress.ARUser'length) ;

      -- Read Data: AXI
      when RRESP =>         AxiBus.ReadData.RResp       := to_slv(OpVal, AxiBus.ReadData.RResp'length) ;
        
      -- AXI4 Full
      when RID =>           AxiBus.ReadData.RID         := to_slv(OpVal, AxiBus.ReadData.RID'length) ; 
      when RLAST =>         AxiBus.ReadData.RLast       := '1' when OpVal mod 2 = 1 else '0' ;
      when RUSER =>         AxiBus.ReadData.RUser       := to_slv(OpVal, AxiBus.ReadData.RUser'length) ; 

      -- The End -- Done
      when others =>
        Alert("Unknown model option", FAILURE) ;
        
    end case ; 
  end procedure SetAxiParameter ;
  
  ------------------------------------------------------------
  function GetAxiParameter (
  -----------------------------------------------------------
    constant AxiBus        : in  Axi4BaseRecType ;
    constant Operation     : in  Axi4OptionsType 
  ) return integer is
  begin
    case Operation is
      -- Write Address
      -- AXI
      when AWPROT =>             return to_integer(AxiBus.WriteAddress.AWProt);
                       
      -- AXI4 Full            
      when AWID =>               return to_integer(AxiBus.WriteAddress.AWID    ) ;
      when AWSIZE =>             return to_integer(AxiBus.WriteAddress.AWSize  ) ;
      when AWBURST =>            return to_integer(AxiBus.WriteAddress.AWBurst ) ;
      when AWLOCK =>             return to_integer(AxiBus.WriteAddress.AWLock  ) ;
      when AWCACHE =>            return to_integer(AxiBus.WriteAddress.AWCache ) ;
      when AWQOS =>              return to_integer(AxiBus.WriteAddress.AWQOS   ) ;
      when AWREGION =>           return to_integer(AxiBus.WriteAddress.AWRegion) ;
      when AWUSER =>             return to_integer(AxiBus.WriteAddress.AWUser  ) ;
                       
      -- Write Data             
      -- AXI4 Full            
      when WLAST =>              return to_integer(AxiBus.WriteData.WLast) ;    
      when WUSER =>              return to_integer(AxiBus.WriteData.WUser) ;    
                       
      -- AXI3            
      when WID =>                return to_integer(AxiBus.WriteData.WID) ;      
                          
      -- Write Response            
      when BRESP =>              return to_integer(AxiBus.WriteResponse.BResp) ;    
                       
      -- AXI4 Full            
      when BID =>                return to_integer(AxiBus.WriteResponse.BID  ) ;    
      when BUSER =>              return to_integer(AxiBus.WriteResponse.BUser) ;    
                       
      -- Read Address            
      when ARPROT =>             return to_integer(AxiBus.ReadAddress.ARProt) ;   
                       
      -- AXI4 Full            
      when ARID =>               return to_integer(AxiBus.ReadAddress.ARID    ) ; 
      when ARSIZE =>             return to_integer(AxiBus.ReadAddress.ARSize  ) ; 
      when ARBURST =>            return to_integer(AxiBus.ReadAddress.ARBurst ) ; 
      when ARLOCK =>             return to_integer(AxiBus.ReadAddress.ARLock  ) ; 
      when ARCACHE =>            return to_integer(AxiBus.ReadAddress.ARCache ) ; 
      when ARQOS =>              return to_integer(AxiBus.ReadAddress.ARQOS   ) ; 
      when ARREGION =>           return to_integer(AxiBus.ReadAddress.ARRegion) ; 
      when ARUSER =>             return to_integer(AxiBus.ReadAddress.ARUser  ) ; 
                       
      -- Read Data            
      when RRESP =>              return to_integer(AxiBus.ReadData.RResp) ;   
                       
      -- AXI4 Full            
      when RID =>                return to_integer(AxiBus.ReadData.RID   ) ;
      when RLAST =>              return to_integer(AxiBus.ReadData.RLast ) ;   
      when RUSER =>              return to_integer(AxiBus.ReadData.RUser ) ;

      -- The End -- Done
      when others =>
--        Alert(ModelID, "Unknown model option", FAILURE) ;
        Alert("Unknown model option", FAILURE) ;
        return integer'left ; 
        
    end case ; 
  end function GetAxiParameter ;
  
  --
  --  Extensions to support model customizations
  -- 
  ------------------------------------------------------------
  procedure SetModelOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut AddressBusTransactionRecType ;
    constant Option      : In    Axi4OptionsType ;
    constant OptVal      : In    boolean
  ) is
  begin
    SetModelOptions(TransRec, Axi4OptionsType'POS(Option), OptVal) ;
  end procedure SetModelOptions ;

  ------------------------------------------------------------
  procedure SetModelOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut AddressBusTransactionRecType ;
    constant Option      : In    Axi4OptionsType ;
    constant OptVal      : In    integer
  ) is
  begin
    SetModelOptions(TransRec, Axi4OptionsType'POS(Option), OptVal) ;
  end procedure SetModelOptions ;

  ------------------------------------------------------------
  procedure SetModelOptions (
  ------------------------------------------------------------
    signal   TransRec    : InOut AddressBusTransactionRecType ;
    constant Option      : In    Axi4OptionsType ;
    constant OptVal      : In    std_logic_vector
  ) is
  begin
    SetModelOptions(TransRec, Axi4OptionsType'POS(Option), OptVal) ;
  end procedure SetModelOptions ;
  
end package body Axi4OptionsTypePkg ;