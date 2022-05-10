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
--      Simple AXI Full Memory Subordinate Model
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    05/2022   2022.05    Updated FIFOs so they are Search => PRIVATE
--    03/2022   2022.03    Rederived from the 2022.02 version of Axi4 Full Memory
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
  use work.Axi4InterfaceCommonPkg.all ;
  use work.Axi4LiteInterfacePkg.all ;
  use work.Axi4CommonPkg.all ;
  use work.Axi4ModelPkg.all ;

entity Axi4LiteMemory is
generic (
  MODEL_ID_NAME   : string := "" ;
  MEMORY_NAME     : string := "" ;
  tperiod_Clk     : time   := 10 ns ;

  DEFAULT_DELAY   : time   := 1 ns ; 

  tpd_Clk_AWReady : time   := DEFAULT_DELAY ;

  tpd_Clk_WReady  : time   := DEFAULT_DELAY ;

  tpd_Clk_BValid  : time   := DEFAULT_DELAY ;
  tpd_Clk_BResp   : time   := DEFAULT_DELAY ;

  tpd_Clk_ARReady : time   := DEFAULT_DELAY ;

  tpd_Clk_RValid  : time   := DEFAULT_DELAY ;
  tpd_Clk_RData   : time   := DEFAULT_DELAY ;
  tpd_Clk_RResp   : time   := DEFAULT_DELAY 
) ;
port (
  -- Globals
  Clk         : in   std_logic ;
  nReset      : in   std_logic ;

  -- AXI Subordinate Interface
  AxiBus      : inout Axi4LiteRecType ;

  -- Testbench Transaction Interface
  TransRec    : inout AddressBusRecType
) ;

  -- Model Configuration
  -- Access via transactions or external name
  shared variable Params : ModelParametersPType ;
  
  -- Derive AXI interface properties from the AxiBus
  constant AXI_ADDR_WIDTH : integer := AxiBus.WriteAddress.Addr'length ;
  constant AXI_DATA_WIDTH : integer := AxiBus.WriteData.Data'length ;
  
  -- Derive ModelInstance label from path_name
  constant MODEL_INSTANCE_NAME : string :=
    -- use MODEL_ID_NAME Generic if set, otherwise use instance label (preferred if set as entityname_1)
    IfElse(MODEL_ID_NAME /= "", MODEL_ID_NAME, PathTail(to_lower(Axi4LiteMemory'PATH_NAME))) ;

  -- Memory Data Structure, Access via MemoryName
  constant LOCAL_MEMORY_NAME : string := 
    IfElse(MEMORY_NAME /= "", MEMORY_NAME, to_lower(Axi4LiteMemory'PATH_NAME) & ":memory") ;
    
  constant MODEL_NAME : string := "Axi4LiteMemory" ;

end entity Axi4LiteMemory ;

architecture MemorySubordinate of Axi4LiteMemory is
  constant AXI_DATA_BYTE_WIDTH  : integer := AXI_DATA_WIDTH / 8 ;
  constant AXI_BYTE_ADDR_WIDTH  : integer := integer(ceil(log2(real(AXI_DATA_BYTE_WIDTH)))) ;

  signal ModelID, BusFailedID, DataCheckID : AlertLogIDType ;

  constant MemoryID : MemoryIDType := NewID(
      Name       => LOCAL_MEMORY_NAME, 
      AddrWidth  => AXI_ADDR_WIDTH,  -- Address is byte address
      DataWidth  => 8,               -- Memory is byte oriented
      Search     => NAME
    ) ; 

  signal WriteAddressFifo     : osvvm.ScoreboardPkg_slv.ScoreboardIDType ;
  signal WriteDataFifo        : osvvm.ScoreboardPkg_slv.ScoreboardIDType ;
  signal WriteResponseFifo    : osvvm.ScoreboardPkg_slv.ScoreboardIDType ;
  
  signal ReadAddressFifo      : osvvm.ScoreboardPkg_slv.ScoreboardIDType ;
  signal ReadDataFifo         : osvvm.ScoreboardPkg_slv.ScoreboardIDType ;

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
    ID           := NewID(MODEL_INSTANCE_NAME) ;
    ModelID      <= ID ;
    BusFailedID  <= NewID("No response", ID ) ;
    DataCheckID  <= NewID("Data Check", ID ) ;

    -- FIFOs get an AlertLogID with NewID, however, it does not print in ReportAlerts (due to DoNotReport)
    --   FIFOS only generate usage type errors 
    WriteAddressFifo    <= NewID("WriteAddressFIFO",   ID, ReportMode => DISABLED, Search => PRIVATE);
    WriteDataFifo       <= NewID("WriteDataFifo",      ID, ReportMode => DISABLED, Search => PRIVATE);
    WriteResponseFifo   <= NewID("WriteResponseFifo",  ID, ReportMode => DISABLED, Search => PRIVATE);
    ReadAddressFifo     <= NewID("ReadAddressFifo",    ID, ReportMode => DISABLED, Search => PRIVATE);
    ReadDataFifo        <= NewID("ReadDataFifo",       ID, ReportMode => DISABLED, Search => PRIVATE);
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
  --  Transaction Dispatcher
  --    Handles transactions between TestCtrl and Model
  ------------------------------------------------------------
  TransactionDispatcher : process
    variable Address          : std_logic_vector(AxiBus.WriteAddress.Addr'range) ;
    variable Data             : std_logic_vector(AxiBus.WriteData.Data'range) ;
    variable ExpectedData     : std_logic_vector(AxiBus.WriteData.Data'range) ;
    variable ByteData         : std_logic_vector(7 downto 0) ;
    variable DataWidth        : integer ;
    variable NumBytes         : integer ;
    variable Count            : integer ;
    variable Axi4Option       : Axi4OptionsType ;
    variable Axi4OptionVal    : integer ; 
  begin
    WaitForTransaction(
       Clk      => Clk,
       Rdy      => TransRec.Rdy,
       Ack      => TransRec.Ack
    ) ;

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

      when GET_TRANSACTION_COUNT =>
        TransRec.IntFromModel <= integer(TransRec.Rdy) ;

      when GET_WRITE_TRANSACTION_COUNT =>
        TransRec.IntFromModel <= WriteAddressReceiveCount ;

      when GET_READ_TRANSACTION_COUNT =>
        TransRec.IntFromModel <= ReadAddressReceiveCount ;

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
          MemWrite(MemoryID, Address + i, ByteData) ;
        end loop ;

      when READ_OP | READ_CHECK =>
        -- Back door Read access to memory.  Completes without time passing.
        Address    := SafeResize(TransRec.Address, Address'length) ;
--        ByteAddr   := CalculateByteAddress(Address, AXI_BYTE_ADDR_WIDTH);
        Data       := (others => '0') ;
        DataWidth  := TransRec.DataWidth ;
        NumBytes   := DataWidth / 8 ;

--!9        -- Do checks  Is address appropriate for NumBytes
--??  What if 32 bit read, but address is byte oriented??
--??  ERROR, or OK & return unaddressed bytes as X?

        -- Memory is byte oriented.  Access as Bytes
        for i in 0 to NumBytes-1 loop
          MemRead(MemoryID, Address + i, ByteData) ;
          Data((8*i + 7)  downto 8*i) := ByteData ;
        end loop ;

        TransRec.DataFromModel <= SafeResize(Data, TransRec.DataFromModel'length) ;

        if IsReadCheck(TransRec.Operation) then
          ExpectedData := SafeResize(TransRec.DataToModel, ExpectedData'length) ;
          AffirmIf( DataCheckID, Data = ExpectedData,
            "Read Address: " & to_hxstring(Address) &
            "  Data: " & to_hxstring(Data) &
            "  Expected: " & to_hxstring(ExpectedData),
            IsLogEnabled(ModelID, INFO) ) ;
        else
--!! TODO:  Change format to Address, Data Transaction #, Read Data
          Log( ModelID,
            "Read Address: " & to_hxstring(Address) &
            "  Data: " & to_hxstring(Data),
            INFO
          ) ;
        end if ;

      when SET_MODEL_OPTIONS =>
        Axi4Option := Axi4OptionsType'val(TransRec.Options) ;
        if IsAxiParameter(Axi4Option) then
          SetAxi4Parameter(Params, Axi4Option, TransRec.IntToModel) ;
        else
          case Axi4Option is
            -- RESP Settings
            when BRESP =>                ModelBResp <= to_slv(TransRec.IntToModel, ModelBResp'length) ;
            when RRESP =>                ModelRResp <= to_slv(TransRec.IntToModel, ModelRResp'length) ;
            --
            -- The End -- Done
            when others =>        
              Alert(ModelID, "SetOptions, Unimplemented Option: " & to_string(Axi4OptionsType'val(TransRec.Options)), FAILURE) ;
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
            --
            -- The End -- Done
            when others =>              
              Alert(ModelID, "GetOptions, Unimplemented Option: " & to_string(Axi4OptionsType'val(TransRec.Options)), FAILURE) ;
          end case ;
        end if ;

        when MULTIPLE_DRIVER_DETECT =>
          Alert(ModelID, "Multiple Drivers on Transaction Record." & 
                         "  Transaction # " & to_string(TransRec.Rdy), FAILURE) ;

      when others =>
          Alert(ModelID, "Unimplemented Transaction: " & to_string(TransRec.Operation), FAILURE) ;
    end case ;

    -- Wait for 1 delta cycle, required if a wait is not in all case branches above
    wait for 0 ns ;

  end process TransactionDispatcher ;


  ------------------------------------------------------------
  --  WriteAddressHandler
  --    Execute Write Address Transactions
  ------------------------------------------------------------
  WriteAddressHandler : process
    alias    AW : AxiBus.WriteAddress'subtype is AxiBus.WriteAddress ;
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
        Valid                   => AxiBus.WriteAddress.Valid,
        Ready                   => AxiBus.WriteAddress.Ready,
        ReadyBeforeValid        => WriteAddressReadyBeforeValid,
        ReadyDelayCycles        => WriteAddressReadyDelayCycles * tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_AWReady
      ) ;

      Log(ModelID,
        "Write Address." &
        "  AWAddr: "    & to_hxstring(AW.Addr) &
        "  AWProt: "    & to_string (AW.Prot) &
        "  Operation# " & to_string (WriteAddressReceiveCount + 1),
        DEBUG
      ) ;

      -- Send Address Information to WriteHandler
      push(WriteAddressFifo, AW.Addr & AW.Prot) ;

      -- Signal completion
      increment(WriteAddressReceiveCount) ;
      wait for 0 ns ;

    end loop WriteAddressOperation ;
  end process WriteAddressHandler ;


  ------------------------------------------------------------
  --  WriteDataHandler
  --    Execute Write Data Transactions
  ------------------------------------------------------------
  WriteDataHandler : process
    alias    WD : AxiBus.WriteData'subtype is AxiBus.WriteData ;
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
        Valid                   => AxiBus.WriteData.Valid,
        Ready                   => AxiBus.WriteData.Ready,
        ReadyBeforeValid        => WriteDataReadyBeforeValid,
        ReadyDelayCycles        => WriteDataReadyDelayCycles * tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_WReady
      ) ;

      -- Send to WriteHandler
      push(WriteDataFifo, WD.Data & WD.Strb) ;

--!! Add AXI Full Information
--!9 Resolve Level
      Log(ModelID,
        "Write Data." &
        "  WData: "  & to_hxstring(WD.Data) &
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
    variable LAW : AxiBus.WriteAddress'subtype ;
    alias AW : AxiBus.WriteAddress'subtype is AxiBus.WriteAddress ;
    variable LWD : AxiBus.WriteData'subtype ;
    alias    WD  : AxiBus.WriteData'subtype is AxiBus.WriteData ;
    variable BurstLen         : integer ;
    variable ByteAddressBits  : integer ;
    variable BytesPerTransfer : integer ;
    variable TransferAddress, MemoryAddress : std_logic_vector(LAW.Addr'range) ;
    variable ByteData         : std_logic_vector(7 downto 0) ;
  begin
    wait for 0 ns ; -- Allow WriteAddressFifo to initialize
    
    WriteHandlerLoop : loop 
      -- Find Write Address and Data transaction
      if empty(WriteAddressFifo) then
        WaitForToggle(WriteAddressReceiveCount) ;
      end if ;
      (LAW.Addr, LAW.Prot) := pop(WriteAddressFifo) ;

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
      if empty(WriteDataFifo) then
        WaitForToggle(WriteDataReceiveCount) ;
      end if ;
      (LWD.Data, LWD.Strb) := pop(WriteDataFifo) ;

      Log(ModelID,
        "Memory Write." &
        "  AWAddr: "    & to_hxstring(LAW.Addr) &
        "  AWProt: "    & to_string (LAW.Prot) &
        "  WData: "     & to_hxstring(LWD.Data) &
        "  WStrb: "     & to_string (LWD.Strb) &
        "  Operation# " & to_string (WriteReceiveCount),
        INFO
      ) ;

      -- Memory is byte oriented.  Access as Bytes
      for j in 0 to AXI_DATA_BYTE_WIDTH-1 loop
        if LWD.Strb(j) = '1' then
          ByteData := LWD.Data((8*j + 7)  downto 8*j) ;
          MemWrite(MemoryID, MemoryAddress + j, ByteData) ;
        end if ;
      end loop ;

  --!9 Get response from Params
  --!9 Does response vary with Address?
  --!! Only one response per burst cycle.  Last cycle of a burst only
      push(WriteResponseFifo, ModelBResp) ;
      increment(WriteReceiveCount) ;
      wait for 0 ns ;
    end loop WriteHandlerLoop ; 
  end process WriteHandler ;


  ------------------------------------------------------------
  -- WriteResponseHandler
  --   Receive and Check Write Responses
  ------------------------------------------------------------
  WriteResponseHandler : process
    alias    WR    : AxiBus.WriteResponse'subtype is AxiBus.WriteResponse ;
    variable Local : AxiBus.WriteResponse'subtype ;
    
    variable WriteResponseReadyTimeOut : integer := 25 ;
  begin
    -- initialize
    WR.Valid <= '0' ;
    WR.Resp  <= (Local.Resp'range => '0') ;
    wait for 0 ns ; -- Allow WriteResponseFifo to initialize

    WriteResponseLoop : loop
      -- Find Transaction
      if empty(WriteResponseFifo) then
        WaitForToggle(WriteReceiveCount) ;
      end if ;
      Local.Resp := pop(WriteResponseFifo) ;

      WaitForClock(Clk, integer'(Params.Get(Axi4OptionsType'POS(WRITE_RESPONSE_VALID_DELAY_CYCLES)))) ; 

      -- Do Transaction
      WR.Resp  <= Local.Resp  after tpd_Clk_BResp ;

      Log(ModelID,
        "Write Response." &
        "  BResp: "  & to_hxstring(Local.Resp) &
        "  Operation# " & to_string(WriteResponseDoneCount + 1),
        DEBUG
      ) ;

      GetAxi4Parameter(Params, WRITE_RESPONSE_READY_TIME_OUT, WriteResponseReadyTimeOut) ;

      ---------------------
      DoAxiValidHandshake (
      ---------------------
        Clk            =>  Clk,
        Valid          =>  AxiBus.WriteResponse.Valid,
        Ready          =>  AxiBus.WriteResponse.Ready,
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
    alias    AR : AxiBus.ReadAddress'subtype is AxiBus.ReadAddress ;
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
        Valid                   => AxiBus.ReadAddress.Valid,
        Ready                   => AxiBus.ReadAddress.Ready,
        ReadyBeforeValid        => ReadAddressReadyBeforeValid,
        ReadyDelayCycles        => ReadAddressReadyDelayCycles * tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_ARReady
      ) ;

--!9 Resolve Level
      Log(ModelID,
        "Read Address." &
        "  ARAddr: "    & to_hxstring(AR.Addr) &
        "  ARProt: "    & to_string (AR.Prot) &
        "  Operation# " & to_string (ReadAddressReceiveCount+1),
        DEBUG
      ) ;

      -- Send Address Information to ReadHandler
      push(ReadAddressFifo, AR.Addr & AR.Prot) ;

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
    variable LAR : AxiBus.ReadAddress'subtype ;
    alias    AR  : AxiBus.ReadAddress'subtype is AxiBus.ReadAddress ;
    variable LRD : AxiBus.ReadData'subtype ;
    alias    RD  : AxiBus.ReadData'subtype is AxiBus.ReadData ;

    variable BurstLen         : integer ;
    variable ByteAddressBits  : integer ;
    variable BytesPerTransfer : integer ;
    variable MemoryAddress, TransferAddress : std_logic_vector(LAR.Addr'length-1 downto 0) ;
    variable ByteData         : std_logic_vector(7 downto 0) ;
  begin
    wait for 0 ns ; -- Allow ReadAddressFifo to initialize

    ReadHandlerLoop : loop 
      if empty(ReadAddressFifo) then
        WaitForToggle(ReadAddressReceiveCount) ;
      end if ;
      (LAR.Addr, LAR.Prot) := pop(ReadAddressFifo) ;

  --!6 Add delay to access memory by type of address: Single Word, First Burst, Burst, Last Burst

      BurstLen := 1 ;
      ByteAddressBits   := AXI_BYTE_ADDR_WIDTH ;
      BytesPerTransfer  := AXI_DATA_BYTE_WIDTH ;

      -- first word in a burst or single word transfer
      TransferAddress  := LAR.Addr(LAR.Addr'left downto ByteAddressBits) & (ByteAddressBits downto 1 => '0') ;
      MemoryAddress    := TransferAddress(LAR.Addr'left downto AXI_BYTE_ADDR_WIDTH) & (AXI_BYTE_ADDR_WIDTH downto 1 => '0') ;

      -- Memory is byte oriented.  Access as Bytes
      for i in 0 to AXI_DATA_BYTE_WIDTH-1 loop
        MemRead(MemoryID, MemoryAddress + i, ByteData) ;
        LRD.Data((8*i + 7)  downto 8*i) := ByteData ;
      end loop ;

      Log(ModelID,
        "Memory Read." &
        "  ARAddr: "    & to_hxstring(LAR.Addr) &
        "  ARProt: "    & to_string (LAR.Prot) &
        "  RData: "     & to_hxstring(LRD.Data) &
        "  Operation# " & to_string (ReadDataRequestCount),
        INFO
      ) ;

      push(ReadDataFifo, LRD.Data & ModelRResp) ;
      increment(ReadDataRequestCount) ;
      wait for 0 ns ;

    end loop ReadHandlerLoop ;
  end process ReadHandler ;


  ------------------------------------------------------------
  --  ReadDataHandler
  --    Create Read Data Response Transactions
  --    All delays at this point are due to AXI Read Data interface operations
  ------------------------------------------------------------
  ReadDataHandler : process
    alias    RD    : AxiBus.ReadData'subtype is AxiBus.ReadData ;
    variable Local : AxiBus.ReadData'subtype ;
    variable ReadDataReadyTimeOut : integer := 25 ;
    variable NewTransfer : std_logic := '1' ; 
  begin
    -- initialize
    RD.Valid <= '0' ;
    RD.Data  <= (Local.Data'range => '0') ;
    RD.Resp  <= (Local.Resp'range => '0') ;
    wait for 0 ns ; -- Allow ReadDataFifo to initialize

    ReadDataLoop : loop
      if empty(ReadDataFifo) then
        WaitForToggle(ReadDataRequestCount) ;
      end if ;
      (Local.Data, Local.Resp) := pop(ReadDataFifo) ;

      WaitForClock(Clk, integer'(Params.Get(Axi4OptionsType'POS(READ_DATA_VALID_DELAY_CYCLES)))) ; 

      -- Transaction Values
      RD.Data  <= Local.Data  after tpd_Clk_RDATA ;
      RD.Resp  <= Local.Resp  after tpd_Clk_RResp ;

--!9 Resolve Level
      Log(ModelID,
        "Read Data." &
        "  RData: "     & to_hxstring(Local.Data) &
        "  RResp: "     & to_hxstring(Local.Resp) &
        "  Operation# " & to_string(ReadDataDoneCount + 1),
        DEBUG
      ) ;

      GetAxi4Parameter(Params, READ_DATA_READY_TIME_OUT, ReadDataReadyTimeOut) ;

      ---------------------
      DoAxiValidHandshake (
      ---------------------
        Clk            =>  Clk,
        Valid          =>  AxiBus.ReadData.Valid,
        Ready          =>  AxiBus.ReadData.Ready,
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

end architecture MemorySubordinate ;
