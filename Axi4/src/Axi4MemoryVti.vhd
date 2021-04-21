--
--  File Name:         Axi4MemoryVti.vhd
--  Design Unit Name:  Axi4MemoryVti
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      AXI Memory Model
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    04/2021   2021.04    VHDL-2019 Interfaces
--    02/2021   2021.02    Added MultiDriver Detect.  Updated Generics.   
--    12/2020   2020.12    Added VTI based on Axi4Memory.vhd
--    01/2020   2020.06    Derived from Axi4Responder.vhd
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2020 - 2021 by SynthWorks Design Inc.
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
  use work.Axi4InterfacePkg.all ;
  use work.Axi4CommonPkg.all ;
  use work.Axi4ModelPkg.all ;

entity Axi4MemoryVti is
generic (
  MODEL_ID_NAME   : string := "" ;
  tperiod_Clk     : time   := 10 ns ;

  DEFAULT_DELAY   : time   := 1 ns ; 

  tpd_Clk_AWReady : time   := DEFAULT_DELAY ;

  tpd_Clk_WReady  : time   := DEFAULT_DELAY ;

  tpd_Clk_BValid  : time   := DEFAULT_DELAY ;
  tpd_Clk_BResp   : time   := DEFAULT_DELAY ;
  tpd_Clk_BID     : time   := DEFAULT_DELAY ;
  tpd_Clk_BUser   : time   := DEFAULT_DELAY ;

  tpd_Clk_ARReady : time   := DEFAULT_DELAY ;

  tpd_Clk_RValid  : time   := DEFAULT_DELAY ;
  tpd_Clk_RData   : time   := DEFAULT_DELAY ;
  tpd_Clk_RResp   : time   := DEFAULT_DELAY ;
  tpd_Clk_RID     : time   := DEFAULT_DELAY ;
  tpd_Clk_RUser   : time   := DEFAULT_DELAY ;
  tpd_Clk_RLast   : time   := DEFAULT_DELAY
) ;
port (
  -- Globals
  Clk         : in   std_logic ;
  nReset      : in   std_logic ;

  -- AXI Responder Interface
  AxiBus      : view Axi4ResponderView of Axi4BaseRecType 
) ;

  -- Memory Data Structure
  -- Access via transactions or external name
  shared variable Memory : MemoryPType ;

  -- Model Configuration
  -- Access via transactions or external name
  shared variable Params : ModelParametersPType ;
  
  -- Derive AXI interface properties from the AxiBus
  alias    AxiAddr is AxiBus.WriteAddress.Addr ;
  alias    AxiData is AxiBus.WriteData.Data ;
  constant AXI_ADDR_WIDTH : integer := AxiAddr'length ;
  constant AXI_DATA_WIDTH : integer := AxiData'length ;

  -- Testbench Transaction Interface
  -- Access via external names
  signal TransRec : AddressBusRecType (
          Address      (AXI_ADDR_WIDTH-1 downto 0),
          DataToModel  (AXI_DATA_WIDTH-1 downto 0),
          DataFromModel(AXI_DATA_WIDTH-1 downto 0)
        ) ;
        
end entity Axi4MemoryVti ;

architecture MemoryResponder of Axi4MemoryVti is

  constant AXI_DATA_BYTE_WIDTH  : integer := AXI_DATA_WIDTH / 8 ;
  constant AXI_BYTE_ADDR_WIDTH  : integer := integer(ceil(log2(real(AXI_DATA_BYTE_WIDTH)))) ;


--!! Move IfElse to ConditionalPkg in OSVVM library
  constant MODEL_INSTANCE_NAME : string :=
    -- use MODEL_ID_NAME Generic if set, otherwise use instance label (preferred if set as entityname_1)
    IfElse(MODEL_ID_NAME /= "", MODEL_ID_NAME, PathTail(to_lower(Axi4MemoryVti'PATH_NAME))) ;

  signal ModelID, BusFailedID, DataCheckID : AlertLogIDType ;


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


  -- A hack of a way to set the parameters for now.
  signal ModelBResp  : Axi4RespType := to_Axi4RespType(OKAY) ;
  signal ModelRResp  : Axi4RespType := to_Axi4RespType(OKAY) ;
  
  alias  AxiBUser is AxiBus.WriteResponse.User ;
  alias  AxiBID   is AxiBus.WriteResponse.ID ;
  signal ModelBUSER  : std_logic_vector(AxiBUser'length - 1 downto 0) := (others => '0') ;
  signal ModelBID    : std_logic_vector(AxiBID'length - 1 downto 0) := (others => '0') ;

  alias  AxiRUser is AxiBus.WriteResponse.User ;
  alias  AxiRID   is AxiBus.WriteResponse.ID ;
  signal ModelRUSER  : std_logic_vector(AxiRUser'length - 1 downto 0) := (others => '0') ;
  signal ModelRID    : std_logic_vector(AxiRID'length - 1 downto 0) := (others => '0') ;


begin

  ------------------------------------------------------------
  -- Turn off drivers not being driven by this model
  ------------------------------------------------------------
--  InitAxi4Rec (AxiBusRec => AxiBus ) ;


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
    variable Address          : std_logic_vector(AxiAddr'range) ;
    variable Data             : std_logic_vector(AxiData'range) ;
    variable ExpectedData     : std_logic_vector(AxiData'range) ;
    variable ByteData         : std_logic_vector(7 downto 0) ;
    variable DataWidth        : integer ;
    variable NumBytes         : integer ;
    variable Count            : integer ;
    variable TransactionCount : integer := 0 ; 
    variable Axi4Option       : Axi4OptionsType ;
    variable Axi4OptionVal    : integer ; 
  begin
    WaitForTransaction(
       Clk      => Clk,
       Rdy      => TransRec.Rdy,
       Ack      => TransRec.Ack
    ) ;
    TransactionCount := TransactionCount + 1 ; 

    case TransRec.Operation is
      when WAIT_FOR_TRANSACTION =>
        -- Wait for either next write or read access of memory to complete
        Count := WriteAddressReceiveCount + ReadAddressReceiveCount ;
        wait until (WriteAddressReceiveCount + ReadAddressReceiveCount) = Count + 1 ;

      when WAIT_FOR_WRITE_TRANSACTION =>
        -- Wait for next write to memory to complete
        Count := WriteAddressReceiveCount ;
        wait until WriteAddressReceiveCount = Count + 1 ;

      when WAIT_FOR_READ_TRANSACTION =>
        -- Wait for next read from memory to complete
        Count := ReadAddressReceiveCount ;
        wait until ReadAddressReceiveCount = Count + 1 ;

      when WAIT_FOR_CLOCK =>
        WaitForClock(Clk, TransRec.IntToModel) ;

      when GET_ALERTLOG_ID =>
        TransRec.IntFromModel <= integer(ModelID) ;
        wait for 0 ns ;

      when GET_TRANSACTION_COUNT =>
        TransRec.IntFromModel <= WriteAddressReceiveCount + ReadAddressReceiveCount ;
        wait for 0 ns ;

      when GET_WRITE_TRANSACTION_COUNT =>
        TransRec.IntFromModel <= WriteAddressReceiveCount ;
        wait for 0 ns ;

      when GET_READ_TRANSACTION_COUNT =>
        TransRec.IntFromModel <= ReadAddressReceiveCount ;
        wait for 0 ns ;

      when WRITE_OP =>
        -- Back door Write access to memory.  Completes without time passing.
        Address    := FromTransaction(TransRec.Address, Address'length) ;
        Data       := FromTransaction(TransRec.DataToModel, Data'length) ;
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
        Address    := FromTransaction(TransRec.Address, Address'length) ;
--        ByteAddr   := CalculateByteAddress(Address, AXI_BYTE_ADDR_WIDTH);
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

        TransRec.DataFromModel <= ToTransaction(Data, TransRec.DataFromModel'length) ;

        if IsReadCheck(TransRec.Operation) then
          ExpectedData := FromTransaction(TransRec.DataToModel, ExpectedData'length) ;
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
--!!        Params.Set(TransRec.Options, TransRec.IntToModel) ;
        Axi4Option := Axi4OptionsType'val(TransRec.Options) ;
        if IsAxiParameter(Axi4Option) then
          SetAxi4Parameter(Params, Axi4Option, TransRec.IntToModel) ;
        else
          case Axi4Option is
            -- RESP Settings
            when BRESP =>                ModelBResp <= to_slv(TransRec.IntToModel, ModelBResp'length) ;
            when RRESP =>                ModelRResp <= to_slv(TransRec.IntToModel, ModelRResp'length) ;
            -- ID Settings
            when BID =>                  ModelBID <= to_slv(TransRec.IntToModel, ModelBID'length) ;
            when RID =>                  ModelRID <= to_slv(TransRec.IntToModel, ModelRID'length) ;
            -- User Settings
            when BUSER =>                ModelBUser <= to_slv(TransRec.IntToModel, ModelBUser'length) ;
            when RUSER =>                ModelRUser <= to_slv(TransRec.IntToModel, ModelRUser'length) ;
            --
            -- The End -- Done
            when others =>               Alert(ModelID, "Unimplemented Option", FAILURE) ;
          end case ;
        end if ;

      when GET_MODEL_OPTIONS =>
--!!        TransRec.IntFromModel <= Params.Get(TransRec.Options) ;
        Axi4Option := Axi4OptionsType'val(TransRec.Options) ;
        if IsAxiParameter(Axi4Option) then
          GetAxi4Parameter(Params, Axi4Option, Axi4OptionVal) ;
          TransRec.IntFromModel <= Axi4OptionVal ;
        else
          case Axi4Option is
            -- RESP Settings
            when BRESP =>                TransRec.IntFromModel <= to_integer(ModelBResp) ;
            when RRESP =>                TransRec.IntFromModel <= to_integer(ModelRResp) ;
            -- ID Settings
            when BID =>                  TransRec.IntFromModel <= to_integer(ModelBID) ;
            when RID =>                  TransRec.IntFromModel <= to_integer(ModelRID) ;
            -- User Settings
            when BUSER =>                TransRec.IntFromModel <= to_integer(ModelBUser) ;
            when RUSER =>                TransRec.IntFromModel <= to_integer(ModelRUser) ;
            --
            -- The End -- Done
            when others =>               Alert(ModelID, "Unimplemented Option", FAILURE) ;
          end case ;
        end if ;

      when MULTIPLE_DRIVER_DETECT =>
        Alert(ModelID, "Axi4MemoryVti: Multiple Drivers on Transaction Record." & 
                       "  Transaction # " & to_string(TransactionCount), FAILURE) ;
        wait for 0 ns ;  

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
    alias    AW is AxiBus.WriteAddress ;
    variable WriteAddressReadyBeforeValid  : boolean := TRUE ;
    variable WriteAddressReadyDelayCycles  : integer := 0 ;
  begin
    AW.Ready <= '0' ;
    WaitForClock(Clk, 2) ;  -- Initialize

    WriteAddressOperation : loop
      GetAxi4Parameter(Params, WRITE_ADDRESS_READY_BEFORE_VALID, WriteAddressReadyBeforeValid) ;
      GetAxi4Parameter(Params, WRITE_ADDRESS_READY_DELAY_CYCLES, WriteAddressReadyDelayCycles) ;
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
        "  AWLen: "     & to_string (AW.Len) &
        "  AWSize: "    & to_string (AW.Size) &
        "  AWBurst: "   & to_string (AW.Burst) &
        "  AWID: "      & to_string (AW.ID) &
        "  AWUser: "    & to_string (AW.User) &
        "  Operation# " & to_string (WriteAddressReceiveCount + 1),
        DEBUG
      ) ;

      -- Send Address Information to WriteHandler
      WriteAddressFifo.push(AW.Addr & AW.Len & AW.Prot & AW.Size & AW.Burst & AW.ID & AW.User ) ;

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
    alias    WD is AxiBus.WriteData ;
    variable WriteDataReadyBeforeValid     : boolean := TRUE ;
    variable WriteDataReadyDelayCycles     : integer := 0 ;
  begin
    WD.Ready <= '0' ;
    WaitForClock(Clk, 2) ;  -- Initialize

    WriteDataOperation : loop
      GetAxi4Parameter(Params, WRITE_DATA_READY_BEFORE_VALID, WriteDataReadyBeforeValid) ;
      GetAxi4Parameter(Params, WRITE_DATA_READY_DELAY_CYCLES, WriteDataReadyDelayCycles) ;
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
        "  WData: "  & to_hstring(WD.Data) &
        "  WStrb: "  & to_string(WD.Strb) &
        "  Operation# " & to_string(WriteDataReceiveCount + 1),
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
--!!GHDL    variable LAW : AxiBus.WriteAddress'subtype ;
    alias AW is AxiBus.WriteAddress ;
    variable LAW : Axi4WriteAddressRecType (
                          Addr(AW.Addr'range),
                          ID(AW.ID'range),
                          User(AW.User'range)
                        ) ;
--!!GHDL    variable LWD : AxiBus.WriteData'subtype ;
    alias WD is AxiBus.WriteData ;
    variable LWD : Axi4WriteDataRecType (
                      Data(WD.Data'range),
                      Strb(WD.Strb'range),
                      User(WD.User'range),
                      ID(WD.ID'range)
                    ) ;

    variable BurstLen         : integer ;
    variable ByteAddressBits  : integer ;
    variable BytesPerTransfer : integer ;
    variable TransferAddress, MemoryAddress : std_logic_vector(LAW.Addr'range) ;
    variable ByteData         : std_logic_vector(7 downto 0) ;
  begin
    -- Find Write Address and Data transaction
    if WriteAddressFifo.empty then
      WaitForToggle(WriteAddressReceiveCount) ;
    end if ;
    (LAW.Addr, LAW.Len, LAW.Prot, LAW.Size, LAW.Burst, LAW.ID, LAW.User) := WriteAddressFifo.pop ;

    if LAW.Len'length > 0 then
      BurstLen := to_integer(LAW.Len) + 1 ;
    else
      BurstLen := 1 ;
    end if ;

    if LAW.Size'length > 0 then
      ByteAddressBits   := to_integer(LAW.Size) ;
      BytesPerTransfer  := 2 ** ByteAddressBits ;
    else
      ByteAddressBits   := AXI_BYTE_ADDR_WIDTH ;
      BytesPerTransfer  := AXI_DATA_BYTE_WIDTH ;
    end if ;

    -- first word in a burst or single word transfer
    TransferAddress  := LAW.Addr(LAW.Addr'left downto ByteAddressBits) & (ByteAddressBits downto 1 => '0') ;
    -- GetWordAddr(Addr, BytesPerTransfer) ;
    MemoryAddress    := TransferAddress(LAW.Addr'left downto AXI_BYTE_ADDR_WIDTH) & (AXI_BYTE_ADDR_WIDTH downto 1 => '0') ;
    -- GetWordAddr(TransferAddress, AXI_BYTE_ADDR_WIDTH) ;

--!3 Delay before first word - burst vs. single word

    -- Burst transfers
    BurstLoop : for i in 1 to BurstLen loop
      -- Wait for Data
      if WriteDataFifo.empty then
        WaitForToggle(WriteDataReceiveCount) ;
      end if ;
      (LWD.Data, LWD.Strb) := WriteDataFifo.pop ;

      if i = 1 then
        Log(ModelID,
          "Memory Write." &
          "  AWAddr: "    & to_hstring(LAW.Addr) &
          "  AWProt: "    & to_string (LAW.Prot) &
          "  WData: "     & to_hstring(LWD.Data) &
          "  WStrb: "     & to_string (LWD.Strb) &
          "  Operation# " & to_string (WriteReceiveCount),
          INFO
        ) ;
      end if ;

      -- Memory is byte oriented.  Access as Bytes
      for j in 0 to AXI_DATA_BYTE_WIDTH-1 loop
        if LWD.Strb(j) = '1' then
          ByteData := LWD.Data((8*j + 7)  downto 8*j) ;
          Memory.MemWrite(MemoryAddress + j, ByteData) ;
        end if ;
      end loop ;

--!5        GetNextBurstAddress(Address, BurstType) ;  -- to support Wrap addressing
      TransferAddress := TransferAddress + BytesPerTransfer ;
      MemoryAddress   := TransferAddress(LAW.Addr'left downto AXI_BYTE_ADDR_WIDTH) & (AXI_BYTE_ADDR_WIDTH downto 1 => '0') ;
      -- GetWordAddr(TransferAddress, AXI_BYTE_ADDR_WIDTH) ;

      --!3 Delay between burst words - burst vs. single word

    end loop BurstLoop ;

--!3 Delay after last word - burst vs. single word

--!9 Get response from Params
--!9 Does response vary with Address?
--!! Only one response per burst cycle.  Last cycle of a burst only
    WriteResponseFifo.push(ModelBResp & LAW.ID & LAW.User) ;
    increment(WriteReceiveCount) ;
    wait for 0 ns ;
  end process WriteHandler ;


  ------------------------------------------------------------
  -- WriteResponseHandler
  --   Receive and Check Write Responses
  ------------------------------------------------------------
  WriteResponseHandler : process
    alias    WR is AxiBus.WriteResponse ;
--!!GHDL    variable Local : AxiBus.WriteResponse'subtype ;
    variable Local : Axi4WriteResponseRecType (
                          ID(WR.ID'range),
                          User(WR.User'range)
                        ) ;
    variable WriteResponseReadyTimeOut : integer := 25 ;
  begin
    -- initialize
    WR.Valid <= '0' ;
    WR.Resp  <= (Local.Resp'range => '0') ;
    WR.ID    <= (Local.ID'range => '0') ;
    WR.User  <= (Local.User'range => '0') ;

    WriteResponseLoop : loop
      -- Find Transaction
      if WriteResponseFifo.Empty then
        WaitForToggle(WriteReceiveCount) ;
      end if ;
      (Local.Resp, Local.ID, Local.User) := WriteResponseFifo.pop ;

      WaitForClock(Clk, integer'(Params.Get(Axi4OptionsType'POS(WRITE_RESPONSE_VALID_DELAY_CYCLES)))) ; 

      -- Do Transaction
      WR.Resp  <= Local.Resp  after tpd_Clk_BResp ;
      WR.ID    <= Local.ID    after tpd_Clk_BID ;
      WR.User  <= Local.User  after tpd_Clk_BUser ;

      Log(ModelID,
        "Write Response." &
        "  BResp: "  & to_hstring(Local.Resp) &
        "  BID: "    & to_hstring(Local.ID) &
        "  BUser: "  & to_hstring(Local.User) &
        "  Operation# " & to_string(WriteResponseDoneCount + 1),
        DEBUG
      ) ;

      GetAxi4Parameter(Params, WRITE_RESPONSE_READY_TIME_OUT, WriteResponseReadyTimeOut) ;

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
      WR.ID    <= not Local.ID    after tpd_Clk_BID ;
      WR.User  <= not Local.User  after tpd_Clk_BUser ;

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
    alias    AR is AxiBus.ReadAddress ;
    variable ReadAddressReadyBeforeValid   : boolean := TRUE ;
    variable ReadAddressReadyDelayCycles   : integer := 0 ;
  begin
    -- Initialize
    AR.Ready <= '0' ;
    WaitForClock(Clk, 2) ;  -- Initialize

    ReadAddressOperation : loop
      GetAxi4Parameter(Params, READ_ADDRESS_READY_BEFORE_VALID, ReadAddressReadyBeforeValid) ;
      GetAxi4Parameter(Params, READ_ADDRESS_READY_DELAY_CYCLES, ReadAddressReadyDelayCycles) ;
  
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
        "  ARLen: "     & to_string (AR.Len) &
        "  ARSize: "    & to_string (AR.Size) &
        "  ARBurst: "   & to_string (AR.Burst) &
        "  ARID: "      & to_string (AR.ID) &
        "  ARUser: "    & to_string (AR.User) &
        "  Operation# " & to_string (ReadAddressReceiveCount+1),
        DEBUG
      ) ;

      -- Send Address Information to ReadHandler
      ReadAddressFifo.push(AR.Addr & AR.Len & AR.Prot & AR.Size & AR.Burst & AR.ID & AR.User ) ;

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
--!!GHDL    variable LAR : AxiBus.ReadAddress'subtype ;
    alias    AR is AxiBus.ReadAddress ;
    variable LAR : Axi4ReadAddressRecType (
                          Addr(AR.Addr'range),
                          ID(AR.ID'range),
                          User(AR.User'range)
                        ) ;
--!!GHDL    variable LRD : AxiBus.ReadData'subtype ;
    alias    RD is AxiBus.ReadData ;
    variable LRD : Axi4ReadDataRecType (
                      Data(RD.Data'range),
                      User(RD.User'range),
                      ID(RD.ID'range)
                    );

    variable BurstLen         : integer ;
    variable ByteAddressBits  : integer ;
    variable BytesPerTransfer : integer ;
    variable MemoryAddress, TransferAddress : std_logic_vector(LAR.Addr'length-1 downto 0) ;
    variable ByteData         : std_logic_vector(7 downto 0) ;
  begin
    if ReadAddressFifo.Empty then
      WaitForToggle(ReadAddressReceiveCount) ;
    end if ;
    (LAR.Addr, LAR.Len, LAR.Prot, LAR.Size, LAR.Burst, LAR.ID, LAR.User) := ReadAddressFifo.pop ;

--!6 Add delay to access memory by type of address: Single Word, First Burst, Burst, Last Burst

    if LAR.Len'length > 0 then
      BurstLen := to_integer(LAR.Len) + 1 ;
    else
      BurstLen := 1 ;
    end if ;

    if LAR.Size'length > 0 then
      ByteAddressBits   := to_integer(LAR.Size) ;
      BytesPerTransfer    := 2 ** ByteAddressBits ;
    else
      ByteAddressBits := AXI_BYTE_ADDR_WIDTH ;
      BytesPerTransfer    := AXI_DATA_BYTE_WIDTH ;
    end if ;

    -- first word in a burst or single word transfer
    TransferAddress  := LAR.Addr(LAR.Addr'left downto ByteAddressBits) & (ByteAddressBits downto 1 => '0') ;
    -- GetWordAddr(Addr, BytesPerTransfer) ;
    MemoryAddress    := TransferAddress(LAR.Addr'left downto AXI_BYTE_ADDR_WIDTH) & (AXI_BYTE_ADDR_WIDTH downto 1 => '0') ;
    -- GetWordAddr(TransferAddress, AXI_BYTE_ADDR_WIDTH) ;

    LRD.Last := '0' ;
    BurstLoop : for i in 1 to BurstLen loop
      -- Memory is byte oriented.  Access as Bytes
      for i in 0 to AXI_DATA_BYTE_WIDTH-1 loop
        Memory.MemRead(MemoryAddress + i, ByteData) ;
        LRD.Data((8*i + 7)  downto 8*i) := ByteData ;
      end loop ;

      if i = 1 then
        Log(ModelID,
          "Memory Read." &
          "  ARAddr: "    & to_hstring(LAR.Addr) &
          "  ARProt: "    & to_string (LAR.Prot) &
          "  RData: "     & to_hstring(LRD.Data) &
          "  Operation# " & to_string (ReadDataRequestCount),
          INFO
        ) ;
      end if ;

--!5        GetNextBurstAddress(TransferAddress, BurstType) ;  -- to support Wrap
      TransferAddress := TransferAddress + BytesPerTransfer ;
      MemoryAddress    := TransferAddress(TransferAddress'left downto AXI_BYTE_ADDR_WIDTH) & (AXI_BYTE_ADDR_WIDTH downto 1 => '0') ;
      -- GetWordAddr(TransferAddress, AXI_BYTE_ADDR_WIDTH) ;

      if i = BurstLen then
        LRD.Last := '1' ;
      end if ;
      ReadDataFifo.push(LRD.Data & LRD.Last & ModelRResp & LAR.ID & LAR.User) ;
      increment(ReadDataRequestCount) ;
      wait for 0 ns ;

    end loop BurstLoop ;

  end process ReadHandler ;


  ------------------------------------------------------------
  --  ReadDataHandler
  --    Create Read Data Response Transactions
  --    All delays at this point are due to AXI Read Data interface operations
  ------------------------------------------------------------
  ReadDataHandler : process
    alias    RD is AxiBus.ReadData ;
--!!GHDL    variable Local : AxiBus.ReadData'subtype ;
    variable Local : Axi4ReadDataRecType (
                      Data(RD.Data'range),
                      User(RD.User'range),
                      ID(RD.ID'range)
                    );
    variable ReadDataReadyTimeOut : integer := 25 ;
    variable NewTransfer : std_logic := '1' ; 
  begin
    -- initialize
    RD.Valid <= '0' ;
    RD.Data  <= (Local.Data'range => '0') ;
    RD.Resp  <= (Local.Resp'range => '0') ;
    RD.ID    <= (Local.ID'range => '0') ;
    RD.User  <= (Local.User'range => '0') ;
    RD.Last  <= '0' ;

    ReadDataLoop : loop
      if ReadDataFifo.Empty then
        WaitForToggle(ReadDataRequestCount) ;
      end if ;
      (Local.Data, Local.Last, Local.Resp, Local.ID, Local.User) := ReadDataFifo.pop ;

      if NewTransfer then
        WaitForClock(Clk, integer'(Params.Get(Axi4OptionsType'POS(READ_DATA_VALID_DELAY_CYCLES)))) ; 
--      elsif Burst then 
      else 
        WaitForClock(Clk, integer'(Params.Get(Axi4OptionsType'POS(READ_DATA_VALID_BURST_DELAY_CYCLES)))) ; 
      end if ; 
      
      NewTransfer := Local.Last ; -- Last is '1' for burst end and single word transfers

      -- Transaction Values
      RD.Data  <= Local.Data  after tpd_Clk_RDATA ;
      RD.Resp  <= Local.Resp  after tpd_Clk_RResp ;
      RD.ID    <= Local.ID    after tpd_Clk_RID ;
      RD.User  <= Local.User  after tpd_Clk_RUser ;
      RD.Last  <= Local.Last  after tpd_Clk_RLast ;

--!9 Resolve Level
      Log(ModelID,
        "Read Data." &
        "  RData: "     & to_hstring(Local.Data) &
        "  RResp: "     & to_hstring(Local.Resp) &
        "  RID: "       & to_hstring(Local.ID) &
        "  RUser: "     & to_hstring(Local.User) &
        "  Operation# " & to_string(ReadDataDoneCount + 1),
        DEBUG
      ) ;

      GetAxi4Parameter(Params, READ_DATA_READY_TIME_OUT, ReadDataReadyTimeOut) ;

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
      RD.ID    <= Local.ID    after tpd_Clk_RID ;
      RD.User  <= Local.User  after tpd_Clk_RUser ;
      RD.Last  <= not Local.Last  after tpd_Clk_RLast ;

      -- Signal completion
      Increment(ReadDataDoneCount) ;
      wait for 0 ns ;
    end loop ReadDataLoop ;
  end process ReadDataHandler ;

end architecture MemoryResponder ;
