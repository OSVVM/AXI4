--
--  File Name:         Axi4LiteMemory.vhd
--  Design Unit Name:  Axi4LiteMemory
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Simple AXI Lite Responder Tansactor Model
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    01/2020   2020.06    Derived from Axi4Responder.vhd
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
  use osvvm.ScoreboardPkg_slv.all ;

library osvvm_common ;
  context osvvm_common.OsvvmCommonContext ;

  use work.Axi4OptionsPkg.all ;
  use work.Axi4LiteInterfacePkg.all ;
  use work.Axi4CommonPkg.all ;
  use work.Axi4ModelPkg.all ;

entity Axi4LiteMemory is
generic (
  MODEL_ID_NAME   : string :="" ;
  tperiod_Clk     : time := 10 ns ;

  tpd_Clk_AWReady : time := 2 ns ;

  tpd_Clk_WReady  : time := 2 ns ;

  tpd_Clk_BValid  : time := 2 ns ;
  tpd_Clk_BResp   : time := 2 ns ;
  tpd_Clk_BID     : time := 2 ns ;
  tpd_Clk_BUser   : time := 2 ns ;

  tpd_Clk_ARReady : time := 2 ns ;

  tpd_Clk_RValid  : time := 2 ns ;
  tpd_Clk_RData   : time := 2 ns ;
  tpd_Clk_RResp   : time := 2 ns ;
  tpd_Clk_RID     : time := 2 ns ;
  tpd_Clk_RUser   : time := 2 ns ;
  tpd_Clk_RLast   : time := 2 ns
) ;
port (
  -- Globals
  Clk         : in   std_logic ;
  nReset      : in   std_logic ;

  -- Testbench Transaction Interface
  TransRec    : inout AddressBusRecType ;

  -- AXI Responder Interface
  AxiBus      : inout Axi4LiteRecType
) ;
end entity Axi4LiteMemory ;

architecture MemoryResponder of Axi4LiteMemory is

  alias    AxiAddr is AxiBus.WriteAddress.Addr ;
  alias    AxiData is AxiBus.WriteData.Data ;
  constant AXI_ADDR_WIDTH : integer := AxiAddr'length ;
  constant AXI_DATA_WIDTH : integer := AxiData'length ;
  constant AXI_DATA_BYTE_WIDTH  : integer := AXI_DATA_WIDTH / 8 ;
  constant AXI_BYTE_ADDR_WIDTH  : integer := integer(ceil(log2(real(AXI_DATA_BYTE_WIDTH)))) ;
  constant AXI_STRB_WIDTH : integer := AXI_DATA_WIDTH/8 ;


--!! Move IfElse to ConditionalPkg in OSVVM library
  constant MODEL_INSTANCE_NAME : string :=
    -- use MODEL_ID_NAME Generic if set, otherwise use instance label (preferred if set as entityname_1)
    IfElse(MODEL_ID_NAME /= "", MODEL_ID_NAME, PathTail(to_lower(Axi4LiteMemory'PATH_NAME))) ;

  signal ModelID, BusFailedID, DataCheckID : AlertLogIDType ;

  -- Address = ByteAddress.  Data = Byte.
  shared variable Memory : MemoryPType ;


  shared variable WriteAddressFifo     : osvvm.ScoreboardPkg_slv.ScoreboardPType ;
  shared variable WriteDataFifo        : osvvm.ScoreboardPkg_slv.ScoreboardPType ;
  shared variable WriteResponseFifo    : osvvm.ScoreboardPkg_slv.ScoreboardPType ;

  shared variable ReadAddressFifo      : osvvm.ScoreboardPkg_slv.ScoreboardPType ;
  shared variable ReadDataFifo         : osvvm.ScoreboardPkg_slv.ScoreboardPType ;

  -- Setup so that if no configuration is done, accept transactions
  signal WriteAddressExpectCount     : integer := 0 ;
  signal WriteDataExpectCount        : integer := 0 ;

  signal WriteAddressReceiveCount    : integer := 0 ;
  signal WriteDataReceiveCount       : integer := 0 ;
  signal WriteReceiveCount           : integer := 0 ;
  signal WriteResponseDoneCount      : integer := 0 ;

  signal ReadAddressReceiveCount     : integer := 0 ;

  signal ReadDataRequestCount        : integer := 0 ;
  signal ReadDataDoneCount           : integer := 0 ;


--!! Refactor s.t. these come from Params
  signal WriteResponseReadyTimeOut, ReadDataReadyTimeOut : integer := 25 ;

  signal WriteAddressReadyBeforeValid  : boolean := TRUE ;
  signal WriteAddressReadyDelayCycles  : integer := 0 ;
  signal WriteDataReadyBeforeValid     : boolean := TRUE ;
  signal WriteDataReadyDelayCycles     : integer := 0 ;
  signal ReadAddressReadyBeforeValid   : boolean := TRUE ;
  signal ReadAddressReadyDelayCycles   : integer := 0 ;


  shared variable Params : ModelParametersPType ;

begin

  ------------------------------------------------------------
  -- Turn off drivers not being driven by this model
  ------------------------------------------------------------
  InitAxi4LiteRec (AxiBusRec => AxiBus ) ;


  ------------------------------------------------------------
  --  Initialize AlertLogIDs
  ------------------------------------------------------------
  InitalizeAlertLogIDs : process
    variable ID : AlertLogIDType ;
  begin
    -- Alerts
    ID           := GetAlertLogID(MODEL_INSTANCE_NAME) ;
    ModelID      <= ID ;
    BusFailedID  <= GetAlertLogID(MODEL_INSTANCE_NAME & ": No response", ID ) ;
    DataCheckID  <= GetAlertLogID(MODEL_INSTANCE_NAME & ": Data Check", ID ) ;

    -- Use model ID as AlertLogID as only message is FIFO Empty while Read failure
    WriteAddressFifo.SetAlertLogID (ID);
    WriteDataFifo.SetAlertLogID    (ID);
    WriteResponseFifo.SetAlertLogID(ID);
    ReadAddressFifo.SetAlertLogID  (ID);
    ReadDataFifo.SetAlertLogID     (ID);

    -- Set Names for the FIFO so reporting identifies which FIFO has the issue.
    WriteAddressFifo.SetName (MODEL_INSTANCE_NAME & ": WriteAddressFIFO");
    WriteDataFifo.SetName    (MODEL_INSTANCE_NAME & ": WriteDataFifo");
    WriteResponseFifo.SetName(MODEL_INSTANCE_NAME & ": WriteResponseFifo");
    ReadAddressFifo.SetName  (MODEL_INSTANCE_NAME & ": ReadAddressFifo");
    ReadDataFifo.SetName     (MODEL_INSTANCE_NAME & ": ReadDataFifo");
    wait ;
  end process InitalizeAlertLogIDs ;


  ------------------------------------------------------------
  --  Initialize Model Options
  ------------------------------------------------------------
  InitalizeOptions : process
  begin
    InitAxiOptions (
      Params => Params
    ) ;
    wait ;
  end process InitalizeOptions ;


  ------------------------------------------------------------
  --  Initialize Memory
  ------------------------------------------------------------
  InitalizeMemory : process
  begin
    Memory.MemInit (
      AddrWidth  => AXI_ADDR_WIDTH,  -- Address is byte address
      DataWidth  => 8                -- Memory is byte oriented
    ) ;
    wait ;
  end process InitalizeMemory ;


  ------------------------------------------------------------
  --  Transaction Dispatcher
  --    Handles transactions between TestCtrl and Model
  ------------------------------------------------------------
  TransactionDispatcher : process
--!GHDL    variable Address          : AxiAddr'subtype ;
--!GHDL    variable Data             : AxiData'subtype ;
--!GHDL    variable ExpectedData     : AxiData'subtype ;
    variable Address          : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data             : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;
    variable ExpectedData     : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;
    variable ByteData         : std_logic_vector(7 downto 0) ;
    variable DataWidth        : integer ;
    variable NumBytes         : integer ;
  begin
    WaitForTransaction(
       Clk      => Clk,
       Rdy      => TransRec.Rdy,
       Ack      => TransRec.Ack
    ) ;

    case TransRec.Operation is
      when WAIT_FOR_CLOCK =>
        WaitForClock(Clk, TransRec.IntToModel) ;

      when GET_ALERTLOG_ID =>
        TransRec.IntFromModel <= integer(ModelID) ;
        wait until Clk = '1' ;

      when GET_TRANSACTION_COUNT =>
        TransRec.IntFromModel <= WriteAddressReceiveCount + ReadAddressReceiveCount ;
        wait until Clk = '1' ;

      when GET_WRITE_TRANSACTION_COUNT =>
        TransRec.IntFromModel <= WriteAddressReceiveCount ;
        wait until Clk = '1' ;

      when GET_READ_TRANSACTION_COUNT =>
        TransRec.IntFromModel <= ReadAddressReceiveCount ;
        wait until Clk = '1' ;

      when WRITE_OP =>
        -- Back door Write access to memory.  Completes without time passing.
        Address    := SafeResize(TransRec.Address, Address'length) ;
        Data       := SafeResize(TransRec.DataToModel, Data'length) ;
        DataWidth  := TransRec.DataWidth ;
        NumBytes   := DataWidth / 8 ;

--!9        -- Do checks  Is address appropriate for NumBytes
--        AlignCheckWriteData (ModelID, Data, Strb, TransRec.DataWidth, ByteAddr) ;

        -- Memory is byte oriented.  Access as Bytes
        for i in 0 to NumBytes-1 loop
          ByteData := Data((8*i + 7)  downto 8*i) ;
          Memory.MemWrite(Address + i, ByteData) ;
        end loop ;

      when READ_OP | READ_CHECK =>
        -- Back door Read access to memory.  Completes without time passing.
        Address    := SafeResize(TransRec.Address, Address'length) ;
--        ByteAddr   := CalculateAxiByteAddress(Address, AXI_BYTE_ADDR_WIDTH);
        Data       := (others => '0') ;
        DataWidth  := TransRec.DataWidth ;
        NumBytes   := DataWidth / 8 ;

--!9        -- Do checks  Is address appropriate for NumBytes
--??  What if 32 bit read, but address is byte oriented??
--??  ERROR, or OK & return unaddressed bytes as X?

        -- Memory is byte oriented.  Access as Bytes
        for i in 0 to NumBytes-1 loop
          Memory.MemRead(Address + i, ByteData) ;
          Data((8*i + 7)  downto 8*i) := ByteData ;
        end loop ;

        TransRec.DataFromModel <= SafeResize(Data, TransRec.DataFromModel'length) ;

        if IsReadCheck(TransRec.Operation) then
          ExpectedData := SafeResize(TransRec.DataToModel, ExpectedData'length) ;
          AffirmIf( DataCheckID, Data = ExpectedData,
            "Read Address: " & to_hstring(Address) &
            "  Data: " & to_hstring(Data) &
            "  Expected: " & to_hstring(ExpectedData),
            IsLogEnabled(ModelID, INFO) ) ;
        else
--!! TODO:  Change format to Address, Data Transaction #, Read Data
          Log( ModelID,
            "Read Address: " & to_hstring(Address) &
            "  Data: " & to_hstring(Data),
            INFO
          ) ;
        end if ;

      when SET_MODEL_OPTIONS =>
        Params.Set(TransRec.Options, TransRec.IntToModel) ;

      when GET_MODEL_OPTIONS =>
        TransRec.IntFromModel <= Params.Get(TransRec.Options) ;

      when others =>
        Alert(ModelID, "Unimplemented Transaction", FAILURE) ;
        wait for 0 ns ;
    end case ;

    -- Wait for 1 delta cycle, required if a wait is not in all case branches above
    wait for 0 ns ;

  end process TransactionDispatcher ;


  ------------------------------------------------------------
  --  WriteAddressHandler
  --    Execute Write Address Transactions
  ------------------------------------------------------------
  WriteAddressHandler : process
--!GHDL    alias    AB : AxiBus'subtype is AxiBus ;
--!GHDL    alias    AW is AB.WriteAddress ;
    alias AW : Axi4LiteWriteAddressRecType(Addr(AXI_ADDR_WIDTH-1 downto 0)) is AxiBus.WriteAddress ;
  begin
    AW.Ready <= '0' ;
    WaitForClock(Clk, 2) ;  -- Initialize

    WriteAddressOperation : loop
      ---------------------
      DoAxiReadyHandshake (
      ---------------------
        Clk                     => Clk,
        Valid                   => AW.Valid,
        Ready                   => AW.Ready,
        ReadyBeforeValid        => WriteAddressReadyBeforeValid,
        ReadyDelayCycles        => WriteAddressReadyDelayCycles * tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_AWReady
      ) ;

--!9 Resolve Level
      Log(ModelID,
        "Write Address." &
        "  AWAddr: "    & to_hstring(AW.Addr) &
        "  AWProt: "    & to_string (AW.Prot) &
        "  Operation# " & to_string (WriteAddressReceiveCount + 1),
        DEBUG
      ) ;

      -- Send Address Information to WriteHandler
      WriteAddressFifo.push(AW.Addr & AW.Prot) ;

      -- Signal completion
      increment(WriteAddressReceiveCount) ;
      wait for 0 ns ;

--?6 Add delay between accepting addresses determined by type of address: Single Word, First Burst, Burst, Last Burst

    end loop WriteAddressOperation ;
  end process WriteAddressHandler ;


  ------------------------------------------------------------
  --  WriteDataHandler
  --    Execute Write Data Transactions
  ------------------------------------------------------------
  WriteDataHandler : process
--!GHDL    alias    AB : AxiBus'subtype is AxiBus ;
--!GHDL    alias    WD is AB.WriteData ;
    alias WD : Axi4LiteWriteDataRecType(Data (AXI_DATA_WIDTH-1 downto 0),   Strb(AXI_STRB_WIDTH-1 downto 0) ) is AxiBus.WriteData ; 
  begin
    WD.Ready <= '0' ;
    WaitForClock(Clk, 2) ;  -- Initialize

    WriteDataOperation : loop
      ---------------------
      DoAxiReadyHandshake(
      ---------------------
        Clk                     => Clk,
        Valid                   => WD.Valid,
        Ready                   => WD.Ready,
        ReadyBeforeValid        => WriteDataReadyBeforeValid,
        ReadyDelayCycles        => WriteDataReadyDelayCycles * tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_WReady
      ) ;


      -- Send to WriteHandler
      WriteDataFifo.push(WD.Data & WD.Strb) ;

--!! Add AXI Full Information
--!9 Resolve Level
      Log(ModelID,
        "Write Data." &
        "  WData: "     & to_hstring(WD.Data) &
        "  WStrb: "     & to_string (WD.Strb) &
        "  Operation# " & to_string (WriteDataReceiveCount + 1),
        DEBUG
      ) ;

      -- Signal completion
      increment(WriteDataReceiveCount) ;

--!9 Delay between accepting words determined by type of write address: Single Word, First Burst, Burst, Last Burst

    end loop WriteDataOperation ;
    wait ; -- remove "no wait" warning
  end process WriteDataHandler ;


  ------------------------------------------------------------
  --  WriteHandler
  --    Collect Write Address and Data transactions
  ------------------------------------------------------------
  WriteHandler : process
--!GHDL    variable LAW : AxiBus.WriteAddress'subtype ;
--!GHDL    variable LWD : AxiBus.WriteData'subtype ;
    variable LAW : Axi4LiteWriteAddressRecType(Addr(AXI_ADDR_WIDTH-1 downto 0) );
    variable LWD : Axi4LiteWriteDataRecType(Data (AXI_DATA_WIDTH-1 downto 0),   Strb(AXI_STRB_WIDTH-1 downto 0) ) ;

    variable BurstLen         : integer ;
    variable ByteAddressBits  : integer ;
    variable BytesPerTransfer : integer ;
--!GHDL    variable TransferAddress, MemoryAddress : LAW.Addr'subtype ;
    variable TransferAddress, MemoryAddress : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
    variable ByteData         : std_logic_vector(7 downto 0) ;
  begin
    -- Find Write Address and Data transaction
    if WriteAddressFifo.empty then
      WaitForToggle(WriteAddressReceiveCount) ;
    end if ;
    (LAW.Addr, LAW.Prot) := WriteAddressFifo.pop ;

    BurstLen := 1 ; 

    ByteAddressBits   := AXI_BYTE_ADDR_WIDTH ;
    BytesPerTransfer  := AXI_DATA_BYTE_WIDTH ;

    -- first word in a burst or single word transfer
    TransferAddress  := LAW.Addr(LAW.Addr'left downto ByteAddressBits) & (ByteAddressBits downto 1 => '0') ;
    -- GetWordAddr(Addr, BytesPerTransfer) ;
    MemoryAddress    := TransferAddress(LAW.Addr'left downto AXI_BYTE_ADDR_WIDTH) & (AXI_BYTE_ADDR_WIDTH downto 1 => '0') ;
    -- GetWordAddr(TransferAddress, AXI_BYTE_ADDR_WIDTH) ;

--!3 Delay before first word - burst vs. single word

    -- Wait for Data
    if WriteDataFifo.empty then
      WaitForToggle(WriteDataReceiveCount) ;
    end if ;
    (LWD.Data, LWD.Strb) := WriteDataFifo.pop ;

    Log(ModelID,
      "Memory Write." &
      "  AWAddr: "    & to_hstring(LAW.Addr) &
      "  AWProt: "    & to_string (LAW.Prot) &
      "  WData: "     & to_hstring(LWD.Data) &
      "  WStrb: "     & to_string (LWD.Strb) &
      "  Operation# " & to_string (WriteReceiveCount),
      INFO
    ) ;

    -- Memory is byte oriented.  Access as Bytes
    for i in 0 to AXI_DATA_BYTE_WIDTH-1 loop
      if LWD.Strb(i) = '1' then
        ByteData := LWD.Data((8*i + 7)  downto 8*i) ;
        Memory.MemWrite(MemoryAddress + i, ByteData) ;
      end if ;
    end loop ;

--!5        GetNextBurstAddress(Address, BurstType) ;  -- to support Wrap addressing
    TransferAddress := TransferAddress + BytesPerTransfer ;
    MemoryAddress    := TransferAddress(LAW.Addr'left downto AXI_BYTE_ADDR_WIDTH) & (AXI_BYTE_ADDR_WIDTH downto 1 => '0') ;
    -- GetWordAddr(TransferAddress, AXI_BYTE_ADDR_WIDTH) ;

    --!3 Delay between burst words - burst vs. single word


--!3 Delay after last word - burst vs. single word

--!9 Get response from Params
--!9 Does response vary with Address?
--!! Only one response per burst cycle.  Last cycle of a burst only
    WriteResponseFifo.push(AXI4_RESP_OKAY) ;
    increment(WriteReceiveCount) ;
    wait for 0 ns ;
  end process WriteHandler ;


  ------------------------------------------------------------
  -- WriteResponseHandler
  --   Receive and Check Write Responses
  ------------------------------------------------------------
  WriteResponseHandler : process
--!GHDL    alias    AB : AxiBus'subtype is AxiBus ;
--!GHDL    alias    WR is AB.WriteResponse ;
    alias WR : Axi4LiteWriteResponseRecType is AxiBus.WriteResponse ;
    
--!GHDL    variable Local : AxiBus.WriteResponse'subtype ;
    variable Local : Axi4LiteWriteResponseRecType ;
  begin
    -- initialize
    WR.Valid <= '0' ;
    WR.Resp  <= (Local.Resp'range => '0') ;

    WriteResponseLoop : loop
      -- Find Transaction
      if WriteResponseFifo.Empty then
        WaitForToggle(WriteReceiveCount) ;
      end if ;
      Local.Resp := WriteResponseFifo.pop ;

      -- Do Transaction
      WR.Resp  <= Local.Resp  after tpd_Clk_BResp ;

      Log(ModelID,
        "Write Response." &
        "  BResp: "  & to_hstring(Local.Resp) &
        "  Operation# " & to_string(WriteResponseDoneCount + 1),
        DEBUG
      ) ;

      ---------------------
      DoAxiValidHandshake (
      ---------------------
        Clk            =>  Clk,
        Valid          =>  WR.Valid,
        Ready          =>  WR.Ready,
        tpd_Clk_Valid  =>  tpd_Clk_BValid,
        AlertLogID     =>  BusFailedID,
        TimeOutMessage =>  "Write Response # " & to_string(WriteResponseDoneCount + 1),
        TimeOutPeriod  =>  WriteResponseReadyTimeOut * tperiod_Clk
      ) ;

      -- State after operation
      WR.Resp  <= not Local.Resp  after tpd_Clk_BResp ;

      -- Signal completion
      Increment(WriteResponseDoneCount) ;
      wait for 0 ns ;

--!9 response delay based on type of write address: Single Word, First Burst, Burst, Last Burst

    end loop WriteResponseLoop ;
  end process WriteResponseHandler ;


  ------------------------------------------------------------
  --  ReadAddressHandler
  --    Execute Read Address Transactions
  --    Handles addresses as received, adds appropriate interface characterists
  ------------------------------------------------------------
  ReadAddressHandler : process
--!GHDL    alias    AB : AxiBus'subtype is AxiBus ;
--!GHDL    alias    AR is AB.ReadAddress ;
    alias AR : Axi4LiteReadAddressRecType(Addr(AXI_ADDR_WIDTH-1 downto 0) ) is AxiBus.ReadAddress ;
  begin
    -- Initialize
    AR.Ready <= '0' ;
    WaitForClock(Clk, 2) ;  -- Initialize

    ReadAddressOperation : loop
      ---------------------
      DoAxiReadyHandshake (
      ---------------------
        Clk                     => Clk,
        Valid                   => AR.Valid,
        Ready                   => AR.Ready,
        ReadyBeforeValid        => ReadAddressReadyBeforeValid,
        ReadyDelayCycles        => ReadAddressReadyDelayCycles * tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_ARReady
      ) ;

--!9 Resolve Level
      Log(ModelID,
        "Read Address." &
        "  ARAddr: "    & to_hstring(AR.Addr) &
        "  ARProt: "    & to_string (AR.Prot) &
        "  Operation# " & to_string (ReadAddressReceiveCount+1),
        DEBUG
      ) ;

      -- Send Address Information to ReadHandler
      ReadAddressFifo.push(AR.Addr & AR.Prot) ;

    -- Signal completion
      increment(ReadAddressReceiveCount) ;
--      ReadAddressReceiveCount <= ReadAddressReceiveCount + BurstCount ;

--?6 Add delay between accepting addresses determined by type of address: Single Word, First Burst, Burst, Last Burst

    end loop ReadAddressOperation ;
    wait ; -- remove "no wait" warning
  end process ReadAddressHandler ;


  ------------------------------------------------------------
  --  ReadHandler
  --    Accesses Memory
  --    Introduces cycle delays due to accessing memory
  ------------------------------------------------------------
  ReadHandler : process
--!GHDL    variable LAR : AxiBus.ReadAddress'subtype ;
--!GHDL    variable LRD : AxiBus.ReadData'subtype ;
    variable LAR : Axi4LiteReadAddressRecType(Addr(AXI_ADDR_WIDTH-1 downto 0) );
    variable LRD : Axi4LiteReadDataRecType(Data (AXI_DATA_WIDTH-1 downto 0)) ; 

    variable BurstLen         : integer ;
    variable ByteAddressBits  : integer ;
    variable BytesPerTransfer : integer ;
    variable MemoryAddress, TransferAddress : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable ByteData         : std_logic_vector(7 downto 0) ;
  begin
    if ReadAddressFifo.Empty then
      WaitForToggle(ReadAddressReceiveCount) ;
    end if ;
    (LAR.Addr, LAR.Prot) := ReadAddressFifo.pop ;

--!6 Add delay to access memory by type of address: Single Word, First Burst, Burst, Last Burst

    BurstLen := 1 ;

    ByteAddressBits   := AXI_BYTE_ADDR_WIDTH ;
    BytesPerTransfer  := AXI_DATA_BYTE_WIDTH ;

    -- first word in a burst or single word transfer
    TransferAddress  := LAR.Addr(LAR.Addr'left downto ByteAddressBits) & (ByteAddressBits downto 1 => '0') ;
    -- GetWordAddr(Addr, BytesPerTransfer) ;
    MemoryAddress    := TransferAddress(LAR.Addr'left downto AXI_BYTE_ADDR_WIDTH) & (AXI_BYTE_ADDR_WIDTH downto 1 => '0') ;
    -- GetWordAddr(TransferAddress, AXI_BYTE_ADDR_WIDTH) ;

    -- Memory is byte oriented.  Access as Bytes
    for i in 0 to AXI_DATA_BYTE_WIDTH-1 loop
      Memory.MemRead(MemoryAddress + i, ByteData) ;
      LRD.Data((8*i + 7)  downto 8*i) := ByteData ;
    end loop ;

    Log(ModelID,
      "Memory Read." &
      "  ARAddr: "    & to_hstring(LAR.Addr) &
      "  ARProt: "    & to_string (LAR.Prot) &
      "  RData: "     & to_hstring(LRD.Data) &
      "  Operation# " & to_string (ReadDataRequestCount),
      INFO
    ) ;

--!5        GetNextBurstAddress(TransferAddress, BurstType) ;  -- to support Wrap
    TransferAddress := TransferAddress + BytesPerTransfer ;
    MemoryAddress    := TransferAddress(TransferAddress'left downto AXI_BYTE_ADDR_WIDTH) & (AXI_BYTE_ADDR_WIDTH downto 1 => '0') ;
    -- GetWordAddr(TransferAddress, AXI_BYTE_ADDR_WIDTH) ;

    ReadDataFifo.push(LRD.Data & AXI4_RESP_OKAY) ;
    increment(ReadDataRequestCount) ;
    wait for 0 ns ;
  end process ReadHandler ;


  ------------------------------------------------------------
  --  ReadDataHandler
  --    Create Read Data Response Transactions
  --    All delays at this point are due to AXI Read Data interface operations
  ------------------------------------------------------------
  ReadDataHandler : process
--!GHDL    alias    AB : AxiBus'subtype is AxiBus ;
--!GHDL    alias    RD is AB.ReadData ;
    alias RD : Axi4LiteReadDataRecType(Data (AXI_DATA_WIDTH-1 downto 0)) is AxiBus.ReadData ;
--!GHDL    variable Local : AxiBus.ReadData'subtype ;
    variable Local : Axi4LiteReadDataRecType(Data (AXI_DATA_WIDTH-1 downto 0)) ; 
  begin
    -- initialize
    RD.Valid <= '0' ;
    RD.Data  <= (Local.Data'range => '0') ;
    RD.Resp  <= (Local.Resp'range => '0') ;

    ReadDataLoop : loop
      if ReadDataFifo.Empty then
        WaitForToggle(ReadDataRequestCount) ;
      end if ;
      (Local.Data, Local.Resp) := ReadDataFifo.pop ;

      -- Transaction Values
      RD.Data  <= Local.Data  after tpd_Clk_RDATA ;
      RD.Resp  <= Local.Resp  after tpd_Clk_RResp ;

--!9 Resolve Level
      Log(ModelID,
        "Read Data." &
        "  RData: "     & to_hstring(Local.Data) &
        "  RResp: "     & to_hstring(Local.Resp) &
        "  Operation# " & to_string(ReadDataDoneCount + 1),
        DEBUG
      ) ;

      ---------------------
      DoAxiValidHandshake (
      ---------------------
        Clk            =>  Clk,
        Valid          =>  RD.Valid,
        Ready          =>  RD.Ready,
        tpd_Clk_Valid  =>  tpd_Clk_RValid,
        AlertLogID     =>  BusFailedID,
        TimeOutMessage =>  "Read Data # " & to_string(ReadDataDoneCount + 1),
        TimeOutPeriod  =>  ReadDataReadyTimeOut * tperiod_Clk
      ) ;

      -- State after operation
      RD.Data  <= not Local.Data  after tpd_Clk_RDATA ;
      RD.Resp  <= not Local.Resp  after tpd_Clk_RResp ;

      -- Signal completion
      Increment(ReadDataDoneCount) ;
      wait for 0 ns ;
    end loop ReadDataLoop ;
  end process ReadDataHandler ;

end architecture MemoryResponder ;
