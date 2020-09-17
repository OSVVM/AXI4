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
  impure function GetAxiParameter (
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
--    SetAxiOption(Params, AWPROT,    to_slv(0, AxiBus.WriteAddress.Prot'length)) ;
--    SetAxiOption(Params, AWID,      to_slv(0, AxiBus.WriteAddress.ID'length)) ;
--    SetAxiOption(Params, AWSIZE,    to_slv(0, AxiBus.WriteAddress.Size'length)) ;
--    SetAxiOption(Params, AWBURST,   to_slv(0, AxiBus.WriteAddress.Burst'length)) ;
--    SetAxiOption(Params, AWLOCK,    to_slv(0, 1)) ;
--    SetAxiOption(Params, AWCACHE,   to_slv(0, AxiBus.WriteAddress.Cache'length)) ;
--    SetAxiOption(Params, AWQOS,     to_slv(0, AxiBus.WriteAddress.Region'length)) ;
--    SetAxiOption(Params, AWREGION,  to_slv(0, AxiBus.WriteAddress.Size'length)) ;
--    SetAxiOption(Params, AWUSER,    to_slv(0, AxiBus.WriteAddress.User'length)) ;
--    -- Write Data
--    SetAxiOption(Params, WLAST,     to_slv(0, 1)) ;
--    SetAxiOption(Params, WUSER,     to_slv(0, AxiBus.WriteData.User'length)) ;
--    SetAxiOption(Params, WID,       to_slv(0, AxiBus.WriteData.ID'length)) ;
--    -- Write Response
--    SetAxiOption(Params, BRESP,     to_slv(0, AxiBus.WriteResponse.Resp'length)) ;
--    SetAxiOption(Params, BID,       to_slv(0, AxiBus.WriteResponse.ID'length)) ;
--    SetAxiOption(Params, BUSER,     to_slv(0, AxiBus.WriteResponse.User'length)) ;
--    -- Read Address
--    SetAxiOption(Params, ARPROT,    to_slv(0, AxiBus.ReadAddress.Prot'length)) ;
--    SetAxiOption(Params, ARID,      to_slv(0, AxiBus.ReadAddress.ID'length)) ;
--    SetAxiOption(Params, ARSIZE,    to_slv(0, AxiBus.ReadAddress.Size'length)) ;
--    SetAxiOption(Params, ARBURST,   to_slv(0, AxiBus.ReadAddress.Burst'length)) ;
--    SetAxiOption(Params, ARLOCK,    to_slv(0, 1)) ;
--    SetAxiOption(Params, ARCACHE,   to_slv(0, AxiBus.ReadAddress.Cache'length)) ;
--    SetAxiOption(Params, ARQOS,     to_slv(0, AxiBus.ReadAddress.QOS'length)) ;
--    SetAxiOption(Params, ARREGION,  to_slv(0, AxiBus.ReadAddress.Region'length)) ;
--    SetAxiOption(Params, ARUSER,    to_slv(0, AxiBus.ReadAddress.User'length)) ;
--    -- Read Data
--    SetAxiOption(Params, RRESP,     to_slv(0, AxiBus.ReadData.Resp'length)) ;
--    SetAxiOption(Params, RID,       to_slv(0, AxiBus.ReadData.ID'length)) ;
--    SetAxiOption(Params, RLAST,     to_slv(0, 1)) ;
--    SetAxiOption(Params, RUSER,     to_slv(0, AxiBus.ReadData.User'length)) ;
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
      when AWPROT =>       AxiBus.WriteAddress.Prot   := to_slv(OpVal, AxiBus.WriteAddress.Prot'length) ;
        
      -- AXI4 Full
      when AWID =>         AxiBus.WriteAddress.ID     := to_slv(OpVal, AxiBus.WriteAddress.ID'length) ;
      when AWSIZE =>       AxiBus.WriteAddress.Size   := to_slv(OpVal, AxiBus.WriteAddress.Size'length) ;
      when AWBURST =>      AxiBus.WriteAddress.Burst  := to_slv(OpVal, AxiBus.WriteAddress.Burst'length) ;
      when AWLOCK =>       AxiBus.WriteAddress.Lock   := '1' when OpVal mod 2 = 1 else '0' ;
      when AWCACHE =>      AxiBus.WriteAddress.Cache  := to_slv(OpVal, AxiBus.WriteAddress.Cache'length) ;
      when AWQOS =>        AxiBus.WriteAddress.QOS    := to_slv(OpVal, AxiBus.WriteAddress.QOS'length) ;
      when AWREGION =>     AxiBus.WriteAddress.Region := to_slv(OpVal, AxiBus.WriteAddress.Region'length) ;
      when AWUSER =>       AxiBus.WriteAddress.User   := to_slv(OpVal, AxiBus.WriteAddress.User'length) ;

      -- Write Data:  AXI
      -- AXI4 Full
      when WLAST =>        AxiBus.WriteData.Last       := '1' when OpVal mod 2 = 1 else '0' ;
      when WUSER =>        AxiBus.WriteData.User       := to_slv(OpVal, AxiBus.WriteData.User'length) ;
                                                       
      -- AXI3                                          
      when WID =>          AxiBus.WriteData.ID         := to_slv(OpVal, AxiBus.WriteData.ID'length) ; 
              
      -- Write Response:  AXI
      when BRESP =>        AxiBus.WriteResponse.Resp   := to_slv(OpVal, AxiBus.WriteResponse.Resp'length) ;
                                                       
      -- AXI4 Full                                     
      when BID =>          AxiBus.WriteResponse.ID     := to_slv(OpVal, AxiBus.WriteResponse.ID'length) ;
      when BUSER =>        AxiBus.WriteResponse.User   := to_slv(OpVal, AxiBus.WriteResponse.User'length) ; 
                                                        
      -- Read Address:  AXI
      when ARPROT =>       AxiBus.ReadAddress.Prot    := to_slv(OpVal, AxiBus.ReadAddress.Prot'length) ;
        
      -- AXI4 Full
      when ARID =>         AxiBus.ReadAddress.ID      := to_slv(OpVal, AxiBus.ReadAddress.ID'length) ;
      when ARSIZE =>       AxiBus.ReadAddress.Size    := to_slv(OpVal, AxiBus.ReadAddress.Size'length) ;
      when ARBURST =>      AxiBus.ReadAddress.Burst   := to_slv(OpVal, AxiBus.ReadAddress.Burst'length) ;
      when ARLOCK =>       AxiBus.ReadAddress.Lock    := '1' when OpVal mod 2 = 1 else '0' ;
      when ARCACHE =>      AxiBus.ReadAddress.Cache   := to_slv(OpVal, AxiBus.ReadAddress.Cache'length) ;
      when ARQOS =>        AxiBus.ReadAddress.QOS     := to_slv(OpVal, AxiBus.ReadAddress.QOS'length) ;
      when ARREGION =>     AxiBus.ReadAddress.Region  := to_slv(OpVal, AxiBus.ReadAddress.Region'length) ;
      when ARUSER =>       AxiBus.ReadAddress.User    := to_slv(OpVal, AxiBus.ReadAddress.User'length) ;

      -- Read Data: AXI
      when RRESP =>         AxiBus.ReadData.Resp       := to_slv(OpVal, AxiBus.ReadData.Resp'length) ;
        
      -- AXI4 Full
      when RID =>           AxiBus.ReadData.ID         := to_slv(OpVal, AxiBus.ReadData.ID'length) ; 
      when RLAST =>         AxiBus.ReadData.Last       := '1' when OpVal mod 2 = 1 else '0' ;
      when RUSER =>         AxiBus.ReadData.User       := to_slv(OpVal, AxiBus.ReadData.User'length) ; 

      -- The End -- Done
      when others =>
        Alert("Unknown model option", FAILURE) ;
        
    end case ; 
  end procedure SetAxiParameter ;
  
  ------------------------------------------------------------
  impure function GetAxiParameter (
  -----------------------------------------------------------
    constant AxiBus        : in  Axi4BaseRecType ;
    constant Operation     : in  Axi4OptionsType 
  ) return integer is
  begin
    case Operation is
      -- Write Address
      -- AXI
      when AWPROT =>             return to_integer(AxiBus.WriteAddress.Prot);
                       
      -- AXI4 Full            
      when AWID =>               return to_integer(AxiBus.WriteAddress.ID    ) ;
      when AWSIZE =>             return to_integer(AxiBus.WriteAddress.Size  ) ;
      when AWBURST =>            return to_integer(AxiBus.WriteAddress.Burst ) ;
      when AWLOCK =>             return to_integer(AxiBus.WriteAddress.Lock  ) ;
      when AWCACHE =>            return to_integer(AxiBus.WriteAddress.Cache ) ;
      when AWQOS =>              return to_integer(AxiBus.WriteAddress.QOS   ) ;
      when AWREGION =>           return to_integer(AxiBus.WriteAddress.Region) ;
      when AWUSER =>             return to_integer(AxiBus.WriteAddress.User  ) ;
                       
      -- Write Data             
      -- AXI4 Full            
      when WLAST =>              return to_integer(AxiBus.WriteData.Last) ;    
      when WUSER =>              return to_integer(AxiBus.WriteData.User) ;    
                       
      -- AXI3            
      when WID =>                return to_integer(AxiBus.WriteData.ID) ;      
                          
      -- Write Response            
      when BRESP =>              return to_integer(AxiBus.WriteResponse.Resp) ;    
                       
      -- AXI4 Full            
      when BID =>                return to_integer(AxiBus.WriteResponse.ID  ) ;    
      when BUSER =>              return to_integer(AxiBus.WriteResponse.User) ;    
                       
      -- Read Address            
      when ARPROT =>             return to_integer(AxiBus.ReadAddress.Prot) ;   
                       
      -- AXI4 Full            
      when ARID =>               return to_integer(AxiBus.ReadAddress.ID    ) ; 
      when ARSIZE =>             return to_integer(AxiBus.ReadAddress.Size  ) ; 
      when ARBURST =>            return to_integer(AxiBus.ReadAddress.Burst ) ; 
      when ARLOCK =>             return to_integer(AxiBus.ReadAddress.Lock  ) ; 
      when ARCACHE =>            return to_integer(AxiBus.ReadAddress.Cache ) ; 
      when ARQOS =>              return to_integer(AxiBus.ReadAddress.QOS   ) ; 
      when ARREGION =>           return to_integer(AxiBus.ReadAddress.Region) ; 
      when ARUSER =>             return to_integer(AxiBus.ReadAddress.User  ) ; 
                       
      -- Read Data            
      when RRESP =>              return to_integer(AxiBus.ReadData.Resp) ;   
                       
      -- AXI4 Full            
      when RID =>                return to_integer(AxiBus.ReadData.ID   ) ;
      when RLAST =>              return to_integer(AxiBus.ReadData.Last ) ;   
      when RUSER =>              return to_integer(AxiBus.ReadData.User ) ;

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