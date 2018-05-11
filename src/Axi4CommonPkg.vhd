--
--  File Name:         Axi4CommonPkg.vhd
--  Design Unit Name:  Axi4CommonPkg
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Defines procedures to support Valid and Ready handshaking
--      
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date       Version    Description
--    09/2017:   2017       Initial revision
--
--
-- Copyright 2017 SynthWorks Design Inc 
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
  
library osvvm ; 
    context osvvm.OsvvmContext ; 
  
package Axi4CommonPkg is 

  ------------------------------------------------------------
  procedure DoAxiValidHandshake (
  ------------------------------------------------------------
    signal   Clk                    : in    std_logic ; 
    signal   Valid                  : out   std_logic ; 
    signal   Ready                  : in    std_logic ; 
    constant tpd_Clk_Valid          : in    time ;
    constant AlertLogID             : in    AlertLogIDType := ALERTLOG_DEFAULT_ID; 
    constant TimeOutMessage         : in    string := "" ; 
    constant TimeOutPeriod          : in    time := time'right
  ) ;

  ------------------------------------------------------------
  procedure DoAxiReadyHandshake (
  ------------------------------------------------------------
    signal   Clk                    : in    std_logic ; 
    signal   Valid                  : in    std_logic ; 
    signal   Ready                  : inout std_logic ; 
    constant ReadyBeforeValid       : in    boolean ; 
    constant ReadyDelayCycles       : in    time ; 
    constant tpd_Clk_Ready          : in    time ;
    constant AlertLogID             : in    AlertLogIDType := ALERTLOG_DEFAULT_ID; 
    constant TimeOutMessage         : in    string := "" ; 
    constant TimeOutPeriod          : in    time := time'right
  ) ;
  
  ------------------------------------------------------------
  function CalculateAxiByteAddress (
  -- Fetch the address and data the slave sees for a write 
  ------------------------------------------------------------
    constant Address       : In  std_logic_vector ;
    constant MaxBytes      : In  integer 
  ) return integer ; 

  ------------------------------------------------------------
  function CalculateAxiWriteStrobe (
  -- Fetch the address and data the slave sees for a write 
  ------------------------------------------------------------
    constant ByteAddr      : In  integer ;
    constant NumberOfBytes : In  integer ; 
    constant MaxBytes      : In  integer 
  ) return std_logic_vector ; 
  
  ------------------------------------------------------------
  procedure AlignAxiWriteData (
  -- Shift Data to Align it. 
  ------------------------------------------------------------
    variable Data          : InOut std_logic_vector ;
    constant ByteAddr      : In    integer  
  ) ; 
  
  ------------------------------------------------------------
  procedure AlignAxiReadData (
  -- Shift Data Right and MASK unused bytes. 
  ------------------------------------------------------------
    variable Data          : InOut std_logic_vector ;
    constant ByteAddr      : In    integer ; 
    constant DataBytes     : In    integer  
  ) ;   
  
end package Axi4CommonPkg ;

-- /////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////

package body Axi4CommonPkg is 

  ------------------------------------------------------------
  procedure DoAxiValidHandshake (
  ------------------------------------------------------------
    signal   Clk                    : in    std_logic ; 
    signal   Valid                  : out   std_logic ; 
    signal   Ready                  : in    std_logic ; 
    constant tpd_Clk_Valid          : in    time ;
    constant AlertLogID             : in    AlertLogIDType := ALERTLOG_DEFAULT_ID; 
    constant TimeOutMessage         : in    string := "" ; 
    constant TimeOutPeriod          : in    time := time'right
  ) is
  begin 
    
    Valid <= '1' after tpd_Clk_Valid ;
    wait on Clk until Clk = '1' and Ready = '1' for TimeOutPeriod ;
    
    Valid <= '0' after tpd_Clk_Valid ;

    -- Check for TimeOut
    AlertIf(
      AlertLogID, 
      Ready /= '1', 
      TimeOutMessage & ".   Ready: " & to_string(Ready) & "  Expected: 1",
      FAILURE
    ) ;
  end procedure DoAxiValidHandshake ;

  ------------------------------------------------------------
  procedure DoAxiReadyHandshake (
  ------------------------------------------------------------
    signal   Clk                    : in    std_logic ; 
    signal   Valid                  : in    std_logic ; 
    signal   Ready                  : inout std_logic ; 
    constant ReadyBeforeValid       : in    boolean ; 
    constant ReadyDelayCycles       : in    time ; 
    constant tpd_Clk_Ready          : in    time ;
    constant AlertLogID             : in    AlertLogIDType := ALERTLOG_DEFAULT_ID; 
    constant TimeOutMessage         : in    string := "" ; 
    constant TimeOutPeriod          : in    time := time'right
  ) is
  begin 
    
    if ReadyBeforeValid then
      Ready <= transport '1' after ReadyDelayCycles + tpd_Clk_Ready ;
    end if ;  
    
    -- Wait to Receive Transaction
    wait on Clk until Clk = '1' and Valid = '1' for TimeOutPeriod ;
    
    -- Check for TimeOut
    AlertIf(
      AlertLogID, 
      Valid /= '1', 
      TimeOutMessage & ".   Valid: " & to_string(Valid) & "  Expected: 1",
      FAILURE
    ) ;

    if not ReadyBeforeValid then 
      Ready <= '1' after ReadyDelayCycles + tpd_Clk_Ready ;
    end if ; 
    
    -- If ready not signaled yet, find ready at a rising edge of clk
    if Ready /= '1' then
      wait on Clk until Clk = '1' and Ready = '1' ;
    end if ; 

    -- State after operation
    Ready <= '0' after tpd_Clk_Ready ;
  end procedure DoAxiReadyHandshake ;
  
  ------------------------------------------------------------
  function CalculateAxiByteAddress (
  -- Fetch the address and data the slave sees for a write 
  ------------------------------------------------------------
    constant Address       : In  std_logic_vector ;
    constant MaxBytes      : In  integer 
  ) return integer is
    alias    aAddr         : std_logic_vector(Address'length downto 1) is Address ; 
    constant NumAddrBits   : integer := integer(round(Log2(real(MaxBytes)))) ; 
  begin 
    return to_integer(aAddr(NumAddrBits downto 1) ) ;
  end function CalculateAxiByteAddress ; 

  ------------------------------------------------------------
  function CalculateAxiWriteStrobe (
  -- Fetch the address and data the slave sees for a write 
  ------------------------------------------------------------
    constant ByteAddr      : In  integer ;
    constant NumberOfBytes : In  integer ; 
    constant MaxBytes      : In  integer 
  ) return std_logic_vector is
    variable WriteStrobe   : std_logic_vector(MaxBytes downto 1) := (others => '0') ; 
  begin
    -- Calculate Initial WriteStrobe based on number of bytes
    WriteStrobe(NumberOfBytes downto 1) := (others => '1') ;
        
    -- Adjust WriteStrobe for Address
    return WriteStrobe(MaxBytes - ByteAddr downto 1) & (ByteAddr downto 1 => '0') ;
  end function CalculateAxiWriteStrobe ; 
  
  ------------------------------------------------------------
  procedure AlignAxiWriteData (
  -- Shift Data to Align it. 
  ------------------------------------------------------------
    variable Data          : InOut std_logic_vector ;
    constant ByteAddr      : In    integer  
  ) is
    alias    aData         : std_logic_vector(Data'length-1 downto 0) is Data ; 
  begin    
      Data := aData(Data'length - ByteAddr*8 - 1 downto 0) & (ByteAddr*8 downto 1 => '0') ; 
  end procedure AlignAxiWriteData ; 
  
  ------------------------------------------------------------
  procedure AlignAxiReadData (
  -- Shift Data Right and MASK unused bytes. 
  ------------------------------------------------------------
    variable Data          : InOut std_logic_vector ;
    constant ByteAddr      : In    integer ; 
    constant DataBytes     : In    integer  
  ) is
    alias    aData   : std_logic_vector(Data'length-1 downto 0) is Data ; 
    variable Mask    : std_logic_vector(Data'length-1 downto 0) ;
  begin    
      Data := (ByteAddr*8 downto 1 => '0') & aData(Data'length - 1 downto ByteAddr*8) ; 
      Mask := (Data'length-1 downto DataBytes*8 => '0') & (DataBytes*8 - 1 downto 0 => '1') ;
      Data := Mask and Data ; 
  end procedure AlignAxiReadData ; 
end package body Axi4CommonPkg ; 

  

