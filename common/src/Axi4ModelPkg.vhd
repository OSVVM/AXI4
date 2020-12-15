--
--  File Name:         Axi4ModelPkg.vhd
--  Design Unit Name:  Axi4ModelPkg
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
--    Date      Version    Description
--    09/2017   2017       Initial revision
--    01/2020   2020.01    Updated license notice
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
    use osvvm.AlertLogPkg.all ; 
    use osvvm.ResolutionPkg.all ; 
    
library osvvm_common ; 
  context osvvm_common.OsvvmCommonContext ;
    
use work.Axi4InterfacePkg.all ; 
  
package Axi4ModelPkg is 

  --                                     00    01      10      11
  type  Axi4UnresolvedRespEnumType is (OKAY, EXOKAY, SLVERR, DECERR) ;
  type Axi4UnresolvedRespVectorEnumType is array (natural range <>) of Axi4UnresolvedRespEnumType ;
  -- alias resolved_max is maximum[ Axi4UnresolvedRespVectorEnumType return Axi4UnresolvedRespEnumType] ;
  -- Maximum is implicitly defined for any array type in VHDL-2008.   Function resolved_max is a fall back.
  function resolved_max ( s : Axi4UnresolvedRespVectorEnumType) return Axi4UnresolvedRespEnumType ;
  subtype Axi4RespEnumType is resolved_max Axi4UnresolvedRespEnumType ;

  function from_Axi4RespType (a: Axi4RespType) return Axi4RespEnumType ;
  function to_Axi4RespType (a: Axi4RespEnumType) return Axi4RespType ;
  
  ------------------------------------------------------------
  function CalculateAxiByteAddress (
  -- Fetch the address and data the slave sees for a write 
  ------------------------------------------------------------
    constant Address         : In  std_logic_vector ;
    constant AddrBitsPerWord : In  integer 
  ) return integer ; 

  ------------------------------------------------------------
  function CalculateAxiBurstLen(
  ------------------------------------------------------------
    constant NumBytes       : In  integer ; 
    constant ByteAddress    : In  integer ; 
    constant ByteWidth      : In  integer 
  ) return integer ;

  ------------------------------------------------------------
  function CalculateAxiWriteStrobe (
  ------------------------------------------------------------
    constant ByteAddr      : In  integer ;
    constant NumberOfBytes : In  integer ; 
    constant MaxBytes      : In  integer 
  ) return std_logic_vector ; 

  ------------------------------------------------------------
  function CalculateAxiWriteStrobe (
  ------------------------------------------------------------
    constant Data          : In  std_logic_vector 
  ) return std_logic_vector ;

  ------------------------------------------------------------
  procedure AlignAxiWriteData (
  -- Shift Data to Align it. 
  ------------------------------------------------------------
    variable Data          : InOut std_logic_vector ;
    constant ByteAddr      : In    integer  
  ) ; 

  ------------------------------------------------------------
  function AlignAxiWriteData (
  -- Shift Data to Align it. 
  ------------------------------------------------------------
    constant Data          : In    std_logic_vector ;
    constant DataWidth     : In    integer ;
    constant ByteAddr      : In    integer 
  ) return std_logic_vector ; 

  ------------------------------------------------------------
  procedure FilterUndrivenAxiData (
  ------------------------------------------------------------
    variable Data          : InOut std_logic_vector ;
    variable Strb          : In    std_logic_vector ;
    constant DefaultData   : In    std_logic 
  ) ;

  ------------------------------------------------------------
  procedure CheckDataIsBytes (
  -- Check AXI Write Data Width - BYTE and < WordWidth adjusted for ByteAddr 
  ------------------------------------------------------------
    constant ModelID         : In    AlertLogIDType ; 
    constant TransferNumber  : In    integer ; 
    constant WriteDataWidth  : In    integer  
  ) ; 
  
  ------------------------------------------------------------
  procedure CheckDataWidth (
  -- Check AXI Write Data Width - BYTE and < WordWidth adjusted for ByteAddr 
  ------------------------------------------------------------
    constant ModelID         : In    AlertLogIDType ; 
    constant TransferNumber  : In    integer ; 
    constant WriteDataWidth  : In    integer ; 
    constant WriteByteAddr   : In    integer ;
    constant MaxDataBits     : In    integer 
  ) ;

-- deprecated
  ------------------------------------------------------------
  procedure CheckWriteDataWidth (
  -- Check AXI Write Data Width - BYTE and < WordWidth adjusted for ByteAddr 
  ------------------------------------------------------------
    constant ModelID         : In    AlertLogIDType ; 
    constant TransferNumber  : In    integer ; 
    constant WriteDataWidth  : In    integer ; 
    constant WriteByteAddr   : In    integer ;
    constant MaxDataBits     : In    integer 
  ) ; 

-- deprecated
  ------------------------------------------------------------
  procedure AlignCheckWriteData (
  -- Align Write Data and Check Widths 
  ------------------------------------------------------------
    constant ModelID         : In    AlertLogIDType ; 
    variable WriteData       : InOut std_logic_vector ;
    variable WriteStrb       : InOut std_logic_vector ;
    constant WriteDataWidth  : In    integer ; 
    constant WriteByteAddr   : In    integer 
  ) ;

-- deprecated?? 
  ------------------------------------------------------------
  procedure GetWriteBurstData (
  ------------------------------------------------------------
    variable WriteBurstFifo  : InOut osvvm.ScoreboardPkg_slv.ScoreboardPType ;
    variable WriteData       : InOut std_logic_vector ;
    variable WriteStrb       : InOut std_logic_vector ;
    constant BytesInTransfer : In    integer ; 
    constant ByteAddr        : In    Integer := 0 
  ) ;

-- Local Only??
  ------------------------------------------------------------
  procedure PopWriteBurstByteData (
  -- Get Byte Data from Burst Data.   
  -- Fill in WriteData and WriteStrb based on ByteAddress and BytesToSend
  -- WriteData must have WriteStrb'length bytes
  ------------------------------------------------------------
    variable WriteBurstFifo  : InOut osvvm.ScoreboardPkg_slv.ScoreboardPType ;
    variable WriteData       : Out   std_logic_vector ;
    variable WriteStrb       : Out   std_logic_vector ;
    variable BytesToSend     : InOut integer ; 
    constant ByteAddress     : In    Integer := 0 
  ) ;

  ------------------------------------------------------------
  procedure PopWriteBurstData (
  ------------------------------------------------------------
    variable WriteBurstFifo  : InOut osvvm.ScoreboardPkg_slv.ScoreboardPType ;
    constant BurstFifoMode   : In    AddressBusFifoBurstModeType ;
    variable WriteData       : Out   std_logic_vector ;
    variable WriteStrb       : Out   std_logic_vector ;
    variable BytesToSend     : InOut integer ; 
    constant ByteAddress     : In    integer := 0 
  ) ;

-- Local Only??
  ------------------------------------------------------------
  procedure PushReadBurstByteData (
  -- Push Burst Data into Byte Burst FIFO.   
  ------------------------------------------------------------
    variable ReadBurstFifo  : InOut osvvm.ScoreboardPkg_slv.ScoreboardPType ;
    variable ReadData       : InOut std_logic_vector ;
    variable BytesToReceive : InOut integer ; 
    constant ByteAddress    : In    integer := 0 
  ) ;

  ------------------------------------------------------------
  procedure PushReadBurstData (
  -- Push Burst Data into Byte Burst FIFO.   
  ------------------------------------------------------------
    variable ReadBurstFifo  : InOut osvvm.ScoreboardPkg_slv.ScoreboardPType ;
    constant BurstFifoMode  : In    AddressBusFifoBurstModeType ;
    variable ReadData       : InOut std_logic_vector ;
    variable BytesToReceive : InOut integer ; 
    constant ByteAddress    : In    integer := 0 
  ) ;

  ------------------------------------------------------------
  procedure AlignAxiReadData (
  -- Shift Data Right and MASK unused bytes. 
  ------------------------------------------------------------
    variable Data          : InOut std_logic_vector ;
    constant ByteAddr      : In    integer ; 
    constant DataBytes     : In    integer  
  ) ;

  ------------------------------------------------------------
  procedure AxiReadDataAlignCheck (
  -- Align Read Data and Check Widths 
  ------------------------------------------------------------
    constant ModelID         : In    AlertLogIDType ; 
    variable ReadData        : InOut std_logic_vector ;
    constant ReadDataWidth   : In    integer ; 
    constant ReadAddress     : In    std_logic_vector ;
    constant MaxDataBytes    : In    integer ;
    constant MaxAddrBits     : In    integer     
  ) ;

end package Axi4ModelPkg ;

-- /////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////

package body Axi4ModelPkg is
 
  function resolved_max ( s : Axi4UnresolvedRespVectorEnumType) return Axi4UnresolvedRespEnumType is
  begin
    return maximum(s) ;
  end function resolved_max ; 

  ------------------------------------------------------------
  type TbRespType_indexby_Integer is array (integer range <>) of Axi4RespEnumType;
  constant RESP_TYPE_TB_TABLE : TbRespType_indexby_Integer := (
      0   => OKAY,
      1   => EXOKAY,
      2   => SLVERR,
      3   => DECERR
    ) ;
  function from_Axi4RespType (a: Axi4RespType) return Axi4RespEnumType is
  begin
    return RESP_TYPE_TB_TABLE(to_integer(a)) ;
  end function from_Axi4RespType ;
  
  ------------------------------------------------------------
  type RespType_indexby_TbRespType is array (Axi4RespEnumType) of Axi4RespType;
  constant TB_TO_RESP_TYPE_TABLE : RespType_indexby_TbRespType := (
      OKAY     => "00",
      EXOKAY   => "01",
      SLVERR   => "10",
      DECERR   => "11"
    ) ;
  function to_Axi4RespType (a: Axi4RespEnumType) return Axi4RespType is
  begin
    return TB_TO_RESP_TYPE_TABLE(a) ; -- replace with lookup table
  end function to_Axi4RespType ;

   
  ------------------------------------------------------------
  function CalculateAxiByteAddress (
  ------------------------------------------------------------
    constant Address         : In  std_logic_vector ;
    constant AddrBitsPerWord : In  integer 
  ) return integer is
    alias    aAddr         : std_logic_vector(Address'length downto 1) is Address ; 
  begin 
    return to_integer(aAddr(AddrBitsPerWord downto 1) ) ;
  end function CalculateAxiByteAddress ; 
  
  ------------------------------------------------------------
  function CalculateAxiBurstLen(
  ------------------------------------------------------------
    constant NumBytes       : In  integer ; 
    constant ByteAddress    : In  integer ; 
    constant ByteWidth      : In  integer 
  ) return integer is
    variable BytesInFirstTransfer : integer ; 
    variable BytesAfterFirstTransfer : integer ; 
  begin
    BytesInFirstTransfer := ByteWidth - ByteAddress ; 
    if BytesInFirsttransfer  > NumBytes then
      return 0 ; -- only one word in transfer
    else
      BytesAfterFirstTransfer := NumBytes - BytesInFirstTransfer ;
      return 0 + integer(ceil(real(BytesAfterFirstTransfer)/real(ByteWidth))) ; 
    end if ; 
  end function CalculateAxiBurstLen ; 

  ------------------------------------------------------------
  function CalculateAxiWriteStrobe (
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
    -- replace by sll? WriteStrobe sll ByteAddr 
    return WriteStrobe(MaxBytes - ByteAddr downto 1) & (ByteAddr downto 1 => '0') ;
  end function CalculateAxiWriteStrobe ; 
  
  ------------------------------------------------------------
  function CalculateAxiWriteStrobe (
  ------------------------------------------------------------
    constant Data          : In  std_logic_vector 
  ) return std_logic_vector is
    variable WriteStrobe : std_logic_vector(Data'length/8-1 downto 0) := (others => '0') ; 
    alias aData : std_logic_vector(Data'length-1 downto 0) is Data ; 
  begin
    for i in WriteStrobe'reverse_range loop
      if aData(i*8) /= 'U' then 
        WriteStrobe(i) := '1' ;
      end if ; 
    end loop ;
    return WriteStrobe ;
  end function CalculateAxiWriteStrobe ; 
  
  ------------------------------------------------------------
  procedure AlignAxiWriteData (
  ------------------------------------------------------------
    variable Data          : InOut std_logic_vector ;
    constant ByteAddr      : In    integer  
  ) is
    alias aData : std_logic_vector(Data'length-1 downto 0) is Data ; 
  begin    
  -- Deprecate this and Use "Data sll ByteAddr * 8" instead of calling this?
      Data := aData(Data'length - ByteAddr*8 - 1 downto 0) & (ByteAddr*8 downto 1 => '0') ; 
  end procedure AlignAxiWriteData ; 

  ------------------------------------------------------------
  function AlignAxiWriteData (
  ------------------------------------------------------------
    constant Data          : In    std_logic_vector ;
    constant DataWidth     : In    integer ;
    constant ByteAddr      : In    integer 
  ) return std_logic_vector is
    alias    aData         : std_logic_vector(Data'length-1 downto 0) is Data ; 
    variable result        : std_logic_vector(Data'length-1 downto 0) := (others => 'U') ; 
  begin    
    result(DataWidth + ByteAddr*8 - 1 downto ByteAddr*8) := aData(DataWidth-1 downto 0) ;
    return result ; 
  end function AlignAxiWriteData ; 

  ------------------------------------------------------------
  procedure FilterUndrivenAxiData (
  ------------------------------------------------------------
    variable Data          : InOut std_logic_vector ;
    variable Strb          : In    std_logic_vector ;
    constant DefaultData   : In    std_logic 
  ) is
    alias aData : std_logic_vector(Data'length-1 downto 0) is Data ; 
    alias aStrb : std_logic_vector(Strb'length-1 downto 0) is Strb ; 
  begin
    for i in aStrb'range loop
      if aStrb(i) = '0' then 
        aData(i*8+7 downto i*8) := (others => DefaultData) ;
      end if ; 
    end loop ; 
  end procedure FilterUndrivenAxiData ; 
  
  ------------------------------------------------------------
  procedure CheckDataIsBytes (
  -- Check AXI Write Data Width - BYTE and < WordWidth adjusted for ByteAddr 
  ------------------------------------------------------------
    constant ModelID         : In    AlertLogIDType ; 
    constant TransferNumber  : In    integer ; 
    constant WriteDataWidth  : In    integer  
  ) is
  begin
    -- Check:  Byte Oriented 
    AlertIf(ModelID, WriteDataWidth mod 8 /= 0, 
      "Master Write, Data not on a byte boundary." & 
      "  DataWidth: " & to_string(WriteDataWidth) & 
      "  TransferNumber: " & to_string(TransferNumber), 
      FAILURE) ;
  end procedure CheckDataIsBytes ; 
  
  ------------------------------------------------------------
  procedure CheckDataWidth (
  -- Check AXI Write Data Width - BYTE and < WordWidth adjusted for ByteAddr 
  ------------------------------------------------------------
    constant ModelID         : In    AlertLogIDType ; 
    constant TransferNumber  : In    integer ; 
    constant WriteDataWidth  : In    integer ; 
    constant WriteByteAddr   : In    integer ;
    constant MaxDataBits     : In    integer 
  ) is
  begin
    -- Check: WriteDataWidth + WriteByteAddr*8 <= MaxDataBits
    AlertIf(ModelID, WriteDataWidth + WriteByteAddr*8 > MaxDataBits, 
      "Master Write, Data length too large." & 
      "  WriteByteAddr: " & to_string(WriteByteAddr) & " * 8" & 
      "  + WriteDataWidth: " & to_string(WriteDataWidth) & 
      "  > MaxDataBits: " & to_string(MaxDataBits) & 
      "  TransferNumber: " & to_string(TransferNumber),
      FAILURE) ;
    end procedure CheckDataWidth ; 
  
  ------------------------------------------------------------
  procedure CheckWriteDataWidth (
  -- Check AXI Write Data Width - BYTE and < WordWidth adjusted for ByteAddr 
  ------------------------------------------------------------
    constant ModelID         : In    AlertLogIDType ; 
    constant TransferNumber  : In    integer ; 
    constant WriteDataWidth  : In    integer ; 
    constant WriteByteAddr   : In    integer ;
    constant MaxDataBits     : In    integer 
  ) is
  begin
    -- Check:  Byte Oriented 
    AlertIf(ModelID, WriteDataWidth mod 8 /= 0, 
      "Master Write, Data not on a byte boundary." & 
      "  DataWidth: " & to_string(WriteDataWidth) & 
      "  TransferNumber: " & to_string(TransferNumber), 
      FAILURE) ;
      
    -- Check: WriteDataWidth + WriteByteAddr*8 <= MaxDataBits
    AlertIf(ModelID, WriteDataWidth + WriteByteAddr*8 > MaxDataBits, 
      "Master Write, Data length too large." & 
      "  WriteByteAddr: " & to_string(WriteByteAddr) & " * 8" & 
      "  + WriteDataWidth: " & to_string(WriteDataWidth) & 
      "  > MaxDataBits: " & to_string(MaxDataBits) & 
      "  TransferNumber: " & to_string(TransferNumber),
      FAILURE) ;
  end procedure CheckWriteDataWidth ; 

  ------------------------------------------------------------
  procedure AlignCheckWriteData (
  -- Align Write Data and Check Widths 
  ------------------------------------------------------------
    constant ModelID         : In    AlertLogIDType ; 
    variable WriteData       : InOut std_logic_vector ;
    variable WriteStrb       : InOut std_logic_vector ;
    constant WriteDataWidth  : In    integer ; 
    constant WriteByteAddr   : In    integer 
  ) is
    constant MAX_DATA_BYTES : integer := WriteStrb'length ; 
    variable BytesInTransfer : integer ; 
  begin
    -- Calculate BytesInTransfer
    BytesInTransfer := WriteDataWidth / 8 ;

    -- Check:  Byte Oriented 
    AlertIf(ModelID, WriteDataWidth mod 8 /= 0, 
      "Master Write, Data not on a byte boundary." & 
      "  DataWidth: " & to_string(WriteDataWidth), 
      FAILURE) ;
    -- Check:  BytesInTransfer <= MAX_DATA_BYTES - WriteByteAddr
    AlertIf(ModelID, BytesInTransfer > MAX_DATA_BYTES - WriteByteAddr, 
      "Master Write, Data length too large." & 
      "  Data: " & to_hstring(WriteData) & 
      "  ByteAddr: " & to_string(WriteByteAddr) & 
      "  BytesInTransfer: " & to_string(BytesInTransfer), 
      FAILURE) ;

    -- Calculate WStrb and Align WData
    WriteStrb  := CalculateAxiWriteStrobe(WriteByteAddr, BytesInTransfer, MAX_DATA_BYTES) ; 
    if WriteByteAddr /= 0 then 
      AlignAxiWriteData(WriteData, WriteByteAddr) ; 
    end if ; 
  end procedure AlignCheckWriteData ; 
  
  ------------------------------------------------------------
  procedure GetWriteBurstData (
  ------------------------------------------------------------
    variable WriteBurstFifo  : InOut osvvm.ScoreboardPkg_slv.ScoreboardPType ;
    variable WriteData       : InOut std_logic_vector ;
    variable WriteStrb       : InOut std_logic_vector ;
    constant BytesInTransfer : In    integer ; 
    constant ByteAddr        : In    Integer := 0 
  ) is
    alias aWriteData : std_logic_vector(WriteData'length-1 downto 0) is WriteData ; 
    alias aWriteStrb : std_logic_vector(WriteStrb'length-1 downto 0) is WriteStrb ;
    variable DataBitOffset : integer := ByteAddr * 8 ; 
  begin
    aWriteData := (others => '0') ;
    aWriteStrb := (others => '0') ;
    -- First Byte is put in right side of word
    for i in 0 to BytesInTransfer - 1 loop
       aWriteData(DataBitOffset+7 downto DataBitOffset) := WriteBurstFifo.Pop ; 
       aWriteStrb(i+ByteAddr) := '1' ; 
       DataBitOffset := DataBitOffset + 8 ; 
    end loop ; 
  end procedure GetWriteBurstData ; 
  
  ------------------------------------------------------------
  -- Local
  procedure PopWriteBurstByteData (
  ------------------------------------------------------------
    variable WriteBurstFifo  : InOut osvvm.ScoreboardPkg_slv.ScoreboardPType ;
    variable WriteData       : Out   std_logic_vector ;
    variable WriteStrb       : Out   std_logic_vector ;
    variable BytesToSend     : InOut integer ; 
    constant ByteAddress     : In    integer := 0 
  ) is
    constant DataLeft : integer := WriteData'length-1; 
    alias aWriteData : std_logic_vector(DataLeft downto 0) is WriteData ; 
    alias aWriteStrb : std_logic_vector(WriteStrb'length-1 downto 0) is WriteStrb ;
    variable DataIndex    : integer := ByteAddress * 8 ; 
    variable StrbIndex    : integer := ByteAddress ; 
  begin
    aWriteData := (others => 'U') ;
    aWriteStrb := (others => '0') ;
    -- First Byte is put in right side of word
    PopByte : while DataIndex <= DataLeft loop  
      aWriteData(DataIndex+7 downto DataIndex) := WriteBurstFifo.Pop ; 
      if aWriteData(DataIndex) /= 'U' then 
        aWriteStrb(StrbIndex) := '1' ; 
      end if ; 
      BytesToSend := BytesToSend - 1 ; 
      exit when BytesToSend = 0 ; 
      DataIndex := DataIndex + 8 ; 
      StrbIndex := StrbIndex + 1 ; 
    end loop PopByte ;
  end procedure PopWriteBurstByteData ; 

  ------------------------------------------------------------
  -- Local
  procedure PopWriteBurstWordData (
  ------------------------------------------------------------
    variable WriteBurstFifo  : InOut osvvm.ScoreboardPkg_slv.ScoreboardPType ;
    variable WriteData       : Out   std_logic_vector ;
    variable WriteStrb       : Out   std_logic_vector ;
    constant ByteAddress     : In    integer := 0 
  ) is
    alias aWriteData : std_logic_vector(WriteData'length-1 downto 0) is WriteData ; 
    alias aWriteStrb : std_logic_vector(WriteStrb'length-1 downto 0) is WriteStrb ;
    variable DataIndex    : integer := 0 ; 
  begin
    aWriteData := WriteBurstFifo.pop ; 
    aWriteStrb := (others => '0') ; 
    
    for i in 0 to ByteAddress-1 loop 
      aWriteData(DataIndex + 7 downto DataIndex) := (others => 'U') ; 
      DataIndex := DataIndex + 8 ; 
    end loop ; 
    
    for i in ByteAddress to WriteStrb'length-1 loop 
      if aWriteData(DataIndex) = 'U' then 
        aWriteStrb(i) := '1' ; 
      end if ; 
      DataIndex := DataIndex + 8 ;
    end loop ;
  end procedure PopWriteBurstWordData ; 
  
  ------------------------------------------------------------
  procedure PopWriteBurstData (
  ------------------------------------------------------------
    variable WriteBurstFifo  : InOut osvvm.ScoreboardPkg_slv.ScoreboardPType ;
    constant BurstFifoMode   : In    AddressBusFifoBurstModeType ;
    variable WriteData       : Out   std_logic_vector ;
    variable WriteStrb       : Out   std_logic_vector ;
    variable BytesToSend     : InOut integer ; 
    constant ByteAddress     : In    integer := 0 
  ) is
  begin
    case BurstFifoMode is
      when ADDRESS_BUS_BURST_BYTE_MODE => 
        PopWriteBurstByteData(WriteBurstFifo, WriteData, WriteStrb, BytesToSend, ByteAddress) ;
        
      when ADDRESS_BUS_BURST_WORD_MODE => 
        PopWriteBurstWordData(WriteBurstFifo, WriteData, WriteStrb, ByteAddress) ;

      when others => 
        -- Already checked, this should never happen
        Alert("PopWriteBurstData: BurstFifoMode Invalid Mode: " & to_string(BurstFifoMode), FAILURE) ;
        
    end case ; 
  end procedure PopWriteBurstData ; 

  ------------------------------------------------------------
  procedure PushReadBurstByteData (
  -- Push Burst Data into Byte Burst FIFO.   
  ------------------------------------------------------------
    variable ReadBurstFifo  : InOut osvvm.ScoreboardPkg_slv.ScoreboardPType ;
    variable ReadData       : InOut std_logic_vector ;
    variable BytesToReceive : InOut integer ; 
    constant ByteAddress    : In    integer := 0 
  ) is
    constant DataLeft : integer := ReadData'length-1; 
    alias aReadData : std_logic_vector(DataLeft downto 0) is ReadData ; 
    variable DataIndex    : integer := ByteAddress * 8 ; 
    variable StrbIndex    : integer := ByteAddress ; 
  begin
    -- First Byte is put in right side of word
    PushByte : while DataIndex <= DataLeft loop  
      ReadBurstFifo.push(aReadData(DataIndex+7 downto DataIndex)) ;
      BytesToReceive := BytesToReceive - 1 ; 
      exit when BytesToReceive = 0 ; 
      DataIndex := DataIndex + 8 ; 
    end loop PushByte ;
  end procedure PushReadBurstByteData ; 

  ------------------------------------------------------------
  procedure PushReadBurstData (
  -- Push Burst Data into Byte Burst FIFO.   
  ------------------------------------------------------------
    variable ReadBurstFifo  : InOut osvvm.ScoreboardPkg_slv.ScoreboardPType ;
    constant BurstFifoMode  : In    AddressBusFifoBurstModeType ;
    variable ReadData       : InOut std_logic_vector ;
    variable BytesToReceive : InOut integer ; 
    constant ByteAddress    : In    integer := 0 
  ) is
  begin
    case BurstFifoMode is
      when ADDRESS_BUS_BURST_BYTE_MODE => 
        PushReadBurstByteData(ReadBurstFifo, ReadData, BytesToReceive, ByteAddress) ;
        
      when ADDRESS_BUS_BURST_WORD_MODE => 
        ReadBurstFifo.Push(ReadData) ; 

      when others => 
        -- Already checked, this should never happen
        Alert("PushReadBurstData: BurstFifoMode Invalid Mode: " & to_string(BurstFifoMode), FAILURE) ;
    end case ; 
  end procedure PushReadBurstData ; 


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
  
  ------------------------------------------------------------
  procedure AxiReadDataAlignCheck (
  -- Align Read Data and Check Widths 
  ------------------------------------------------------------
    constant ModelID         : In    AlertLogIDType ; 
    variable ReadData        : InOut std_logic_vector ;
    constant ReadDataWidth   : In    integer ; 
    constant ReadAddress     : In    std_logic_vector ;
    constant MaxDataBytes    : In    integer ;
    constant MaxAddrBits     : In    integer     
  ) is
    variable ReadByteCount : integer ; 
    variable ReadByteAddr  : integer ; 
  begin
    ReadByteAddr  :=  CalculateAxiByteAddress(ReadAddress, MaxAddrBits);
    ReadByteCount := ReadDataWidth / 8 ;
    -- Check Transaction Data Size
    AlertIf(ModelID, ReadDataWidth mod 8 /= 0, "Master Read, Data not on a byte boundary", FAILURE) ;
    -- Validate Bytes written not more than MaxDataBytes
    AlertIf(ModelID, ReadByteCount > MaxDataBytes, "Master Read, Data length too large", FAILURE) ;
    
    if ReadByteCount /= MaxDataBytes then 
      AlertIf(ModelID, MaxDataBytes - ReadByteAddr < ReadByteCount, 
        "Master Read, Byte Address (" & to_string(ReadByteAddr) & ") " & 
        "not consistent with number of bytes expected (" & to_string(ReadByteCount) & " )", 
        FAILURE) ; 
      AlignAxiReadData(ReadData, ReadByteAddr, ReadByteCount) ; 
    end if ; 
  end procedure AxiReadDataAlignCheck ; 

end package body Axi4ModelPkg ; 