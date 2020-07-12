--
--  File Name:         Axi4Memory.vhd
--  Design Unit Name:  Axi4Memory
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Simple AXI Lite Slave Tansactor Model
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    01/2020   2020.06    Derived from Axi4Slave.vhd
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

  use work.Axi4OptionsTypePkg.all ;
  use work.Axi4InterfacePkg.all ;
  use work.Axi4CommonPkg.all ;
  use work.Axi4Pkg.all ;

entity Axi4Memory is
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
  TransRec    : inout AddressBusTransactionRecType ;

  -- AXI Slave Interface
  AxiBus      : inout Axi4RecType
) ;
end entity Axi4Memory ;

architecture MemoryResponder of Axi4Memory is

  alias    AxiAddr is AxiBus.WriteAddress.AWAddr ;
  alias    AxiData is AxiBus.WriteData.WData ;
  constant AXI_ADDR_WIDTH : integer := AxiAddr'length ;
  constant AXI_DATA_WIDTH : integer := AxiData'length ;
  constant AXI_DATA_BYTE_WIDTH  : integer := AXI_DATA_WIDTH / 8 ;
  constant AXI_BYTE_ADDR_WIDTH  : integer := integer(ceil(log2(real(AXI_DATA_BYTE_WIDTH)))) ; 


--!! Move IfElse to ConditionalPkg in OSVVM library
  constant MODEL_INSTANCE_NAME : string :=
    -- use MODEL_ID_NAME Generic if set, otherwise use instance label (preferred if set as entityname_1)
    IfElse(MODEL_ID_NAME /= "", MODEL_ID_NAME, PathTail(to_lower(Axi4Memory'PATH_NAME))) ;

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
  InitAxi4Rec (AxiBusRec => AxiBus ) ;


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
    variable WaitClockCycles  : integer ;
    variable Address          : AxiAddr'subtype ;
    variable Data             : AxiData'subtype ;
    variable ExpectedData     : AxiData'subtype ;
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
      when WAIT_CLOCK =>
        WaitClockCycles := FromTransaction(TransRec.DataToModel) ;
        wait for (WaitClockCycles * tperiod_Clk) - 1 ns ;
        wait until Clk = '1' ;

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
        Address    := FromTransaction(TransRec.Address) ;
        Data       := FromTransaction(TransRec.DataToModel) ;
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
        Address    := FromTransaction(TransRec.Address) ;
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
        
        TransRec.DataFromModel <= ToTransaction(Data) ;
        
        if IsReadCheck(TransRec.Operation) then
          ExpectedData := FromTransaction(TransRec.DataToModel) ;
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
    alias    AB : AxiBus'subtype is AxiBus ; 
    alias    AW is AB.WriteAddress ;
  begin
    AW.AWReady <= '0' ;
    WaitForClock(Clk, 2) ;  -- Initialize

    WriteAddressOperation : loop
      ---------------------
      DoAxiReadyHandshake (
      ---------------------
        Clk                     => Clk,
        Valid                   => AW.AWValid,
        Ready                   => AW.AWReady,
        ReadyBeforeValid        => WriteAddressReadyBeforeValid,
        ReadyDelayCycles        => WriteAddressReadyDelayCycles * tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_AWReady
      ) ;
      
--!9 Resolve Level
      Log(ModelID,
        "Write Address." &
        "  AWAddr: "    & to_hstring(AW.AWAddr) &
        "  AWProt: "    & to_string (AW.AWProt) &
        "  AWLen: "     & to_string (AW.AWLen) & 
        "  AWSize: "    & to_string (AW.AWSize) & 
        "  AWBurst: "   & to_string (AW.AWBurst) & 
        "  AWID: "      & to_string (AW.AWID) & 
        "  AWUser: "    & to_string (AW.AWUser) & 
        "  Operation# " & to_string (WriteAddressReceiveCount + 1),
        DEBUG
      ) ;

      -- Send Address Information to WriteHandler
      WriteAddressFifo.push(AW.AWAddr & AW.AWLen & AW.AWProt & AW.AWSize & AW.AWBurst & AW.AWID & AW.AWUser ) ;

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
    alias    AB : AxiBus'subtype is AxiBus ; 
    alias    WD is AB.WriteData ; 
  begin
    WD.WReady <= '0' ;
    WaitForClock(Clk, 2) ;  -- Initialize

    WriteDataOperation : loop
      ---------------------
      DoAxiReadyHandshake(
      ---------------------
        Clk                     => Clk,
        Valid                   => WD.WValid,
        Ready                   => WD.WReady,
        ReadyBeforeValid        => WriteDataReadyBeforeValid,
        ReadyDelayCycles        => WriteDataReadyDelayCycles * tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_WReady
      ) ;


      -- Send to WriteHandler
      WriteDataFifo.push(WD.WData & WD.WStrb) ;

--!! Add AXI Full Information
--!9 Resolve Level
      Log(ModelID,
        "Write Data." &
        "  WData: "  & to_hstring(WD.WData) &
        "  WStrb: "  & to_string(WD.WStrb) &
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
    variable LWD : AxiBus.WriteData'subtype ;  
    
    variable BurstLen         : integer ; 
    variable ByteAddressBits  : integer ; 
    variable BytesPerTransfer : integer ; 
    variable TransferAddress, MemoryAddress : LAW.AWAddr'subtype ;
    variable ByteData         : std_logic_vector(7 downto 0) ;
  begin
    -- Find Write Address and Data transaction
    if WriteAddressFifo.empty then
      WaitForToggle(WriteAddressReceiveCount) ;
    end if ;
    (LAW.AWAddr, LAW.AWLen, LAW.AWProt, LAW.AWSize, LAW.AWBurst, LAW.AWID, LAW.AWUser) := WriteAddressFifo.pop ;
    
    if LAW.AWLen'length > 0 then
      BurstLen := to_integer(LAW.AWLen) + 1 ; 
    else
      BurstLen := 1 ; 
    end if ;

    if LAW.AWSize'length > 0 then
      ByteAddressBits := to_integer(LAW.AWSize) ;
      BytesPerTransfer    := 2 ** ByteAddressBits ;
    else
      ByteAddressBits := AXI_BYTE_ADDR_WIDTH ;
      BytesPerTransfer    := AXI_DATA_BYTE_WIDTH ;
    end if ;

    -- first word in a burst or single word transfer
    TransferAddress  := LAW.AWAddr(LAW.AWAddr'left downto ByteAddressBits) & (ByteAddressBits downto 1 => '0') ;
    -- GetWordAddr(Addr, BytesPerTransfer) ;
    MemoryAddress    := TransferAddress(LAW.AWAddr'left downto AXI_BYTE_ADDR_WIDTH) & (AXI_BYTE_ADDR_WIDTH downto 1 => '0') ;
    -- GetWordAddr(TransferAddress, AXI_BYTE_ADDR_WIDTH) ;
    
--!3 Delay before first word - burst vs. single word
    
    -- Burst transfers
    BurstLoop : for i in 1 to BurstLen loop 
      -- Wait for Data
      if WriteDataFifo.empty then
        WaitForToggle(WriteDataReceiveCount) ;
      end if ;
      (LWD.WData, LWD.WStrb) := WriteDataFifo.pop ;

      if i = 1 then 
        Log(ModelID,
          "Slave Memory Write." &
          "  AWAddr: "    & to_hstring(LAW.AWAddr) &
          "  AWProt: "    & to_string (LAW.AWProt) &
          "  WData: "     & to_hstring(LWD.WData) &
          "  WStrb: "     & to_string (LWD.WStrb) &
          "  Operation# " & to_string (WriteReceiveCount),
          INFO
        ) ;
      end if ; 
      
      -- Memory is byte oriented.  Access as Bytes
      for i in 0 to AXI_DATA_BYTE_WIDTH-1 loop 
        if LWD.WStrb(i) = '1' then 
          ByteData := LWD.WData((8*i + 7)  downto 8*i) ;
          Memory.MemWrite(MemoryAddress + i, ByteData) ;
        end if ; 
      end loop ;
      
--!5        GetNextBurstAddress(Address, BurstType) ;  -- to support Wrap addressing
      TransferAddress := TransferAddress + BytesPerTransfer ;  
      MemoryAddress    := TransferAddress(LAW.AWAddr'left downto AXI_BYTE_ADDR_WIDTH) & (AXI_BYTE_ADDR_WIDTH downto 1 => '0') ;
      -- GetWordAddr(TransferAddress, AXI_BYTE_ADDR_WIDTH) ;

      --!3 Delay between burst words - burst vs. single word

    end loop BurstLoop ;
  
--!3 Delay after last word - burst vs. single word

--!9 Get response from Params
--!9 Does response vary with Address?
--!! Only one response per burst cycle.  Last cycle of a burst only
    WriteResponseFifo.push(AXI4_RESP_OKAY & LAW.AWID & LAW.AWUser) ;
    increment(WriteReceiveCount) ;
    wait for 0 ns ;
  end process WriteHandler ;


  ------------------------------------------------------------
  -- WriteResponseHandler
  --   Receive and Check Write Responses
  ------------------------------------------------------------
  WriteResponseHandler : process
    alias    AB : AxiBus'subtype is AxiBus ; 
    alias    WR is AB.WriteResponse ; 
    variable Local : AxiBus.WriteResponse'subtype ;
  begin
    -- initialize
    WR.BValid <= '0' ;
    WR.BResp  <= (Local.BResp'range => '0') ; 
    WR.BID    <= (Local.BID'range => '0') ; 
    WR.BUser  <= (Local.BUser'range => '0') ; 

    WriteResponseLoop : loop
      -- Find Transaction
      if WriteResponseFifo.Empty then
        WaitForToggle(WriteReceiveCount) ;
      end if ;
      (Local.BResp, Local.BID, Local.BUser) := WriteResponseFifo.pop ;

      -- Do Transaction
      WR.BResp  <= Local.BResp  after tpd_Clk_BResp ;
      WR.BID    <= Local.BID    after tpd_Clk_BID ;
      WR.BUser  <= Local.BUser  after tpd_Clk_BUser ;

      Log(ModelID,
        "Write Response." &
        "  BResp: "  & to_hstring(Local.BResp) &
        "  BID: "    & to_hstring(Local.BID) &
        "  BUser: "  & to_hstring(Local.BUser) &
        "  Operation# " & to_string(WriteResponseDoneCount + 1),
        DEBUG
      ) ;

      ---------------------
      DoAxiValidHandshake (
      ---------------------
        Clk            =>  Clk,
        Valid          =>  WR.BValid,
        Ready          =>  WR.BReady,
        tpd_Clk_Valid  =>  tpd_Clk_BValid,
        AlertLogID     =>  BusFailedID,
        TimeOutMessage =>  "Write Response # " & to_string(WriteResponseDoneCount + 1),
        TimeOutPeriod  =>  WriteResponseReadyTimeOut * tperiod_Clk
      ) ;

      -- State after operation
      WR.BResp  <= not Local.BResp  after tpd_Clk_BResp ;
      WR.BID    <= not Local.BID    after tpd_Clk_BID ;
      WR.BUser  <= not Local.BUser  after tpd_Clk_BUser ;

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
    alias    AB : AxiBus'subtype is AxiBus ; 
    alias    AR is AB.ReadAddress ; 
  begin
    -- Initialize
    AR.ARReady <= '0' ;
    WaitForClock(Clk, 2) ;  -- Initialize

    ReadAddressOperation : loop
      ---------------------
      DoAxiReadyHandshake (
      ---------------------
        Clk                     => Clk,
        Valid                   => AR.ARValid,
        Ready                   => AR.ARReady,
        ReadyBeforeValid        => ReadAddressReadyBeforeValid,
        ReadyDelayCycles        => ReadAddressReadyDelayCycles * tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_ARReady
      ) ;
      
--!9 Resolve Level
      Log(ModelID,
        "Read Address." &
        "  ARAddr: "    & to_hstring(AR.ARAddr) &
        "  ARProt: "    & to_string (AR.ARProt) &
        "  ARLen: "     & to_string (AR.ARLen) & 
        "  ARSize: "    & to_string (AR.ARSize) & 
        "  ARBurst: "   & to_string (AR.ARBurst) & 
        "  ARID: "      & to_string (AR.ARID) & 
        "  ARUser: "    & to_string (AR.ARUser) & 
        "  Operation# " & to_string (ReadAddressReceiveCount+1), 
        DEBUG
      ) ;
      
      -- Send Address Information to ReadHandler
      ReadAddressFifo.push(AR.ARAddr & AR.ARLen & AR.ARProt & AR.ARSize & AR.ARBurst & AR.ARID & AR.ARUser ) ;

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
    variable LRD : AxiBus.ReadData'subtype ; 
    
    variable BurstLen         : integer ; 
    variable ByteAddressBits  : integer ; 
    variable BytesPerTransfer : integer ; 
    variable MemoryAddress, TransferAddress : LAR.ARAddr'subtype ;
    variable ByteData         : std_logic_vector(7 downto 0) ;
  begin
    if ReadAddressFifo.Empty then
      WaitForToggle(ReadAddressReceiveCount) ;
    end if ;
    (LAR.ARAddr, LAR.ARLen, LAR.ARProt, LAR.ARSize, LAR.ARBurst, LAR.ARID, LAR.ARUser) := ReadAddressFifo.pop ;
    
--!6 Add delay to access memory by type of address: Single Word, First Burst, Burst, Last Burst

    if LAR.ARLen'length > 0 then
      BurstLen := to_integer(LAR.ARLen) + 1 ; 
    else
      BurstLen := 1 ; 
    end if ;

    if LAR.ARSize'length > 0 then
      ByteAddressBits   := to_integer(LAR.ARSize) ;
      BytesPerTransfer    := 2 ** ByteAddressBits ;
    else
      ByteAddressBits := AXI_BYTE_ADDR_WIDTH ;
      BytesPerTransfer    := AXI_DATA_BYTE_WIDTH ;
    end if ;

    -- first word in a burst or single word transfer
    TransferAddress  := LAR.ARAddr(LAR.ARAddr'left downto ByteAddressBits) & (ByteAddressBits downto 1 => '0') ;
    -- GetWordAddr(Addr, BytesPerTransfer) ;
    MemoryAddress    := TransferAddress(LAR.ARAddr'left downto AXI_BYTE_ADDR_WIDTH) & (AXI_BYTE_ADDR_WIDTH downto 1 => '0') ;
    -- GetWordAddr(TransferAddress, AXI_BYTE_ADDR_WIDTH) ;

    LRD.RLast := '0' ;
    BurstLoop : for i in 1 to BurstLen loop 
      -- Memory is byte oriented.  Access as Bytes
      for i in 0 to AXI_DATA_BYTE_WIDTH-1 loop 
        Memory.MemRead(MemoryAddress + i, ByteData) ;
        LRD.RData((8*i + 7)  downto 8*i) := ByteData ; 
      end loop ;

      if i = 1 then 
        Log(ModelID,
          "Slave Memory Read." &
          "  ARAddr: "    & to_hstring(LAR.ARAddr) &
          "  ARProt: "    & to_string (LAR.ARProt) &
          "  RData: "     & to_hstring(LRD.RData) &
          "  Operation# " & to_string (ReadDataRequestCount),
          INFO
        ) ;
      end if ; 

--!5        GetNextBurstAddress(TransferAddress, BurstType) ;  -- to support Wrap 
      TransferAddress := TransferAddress + BytesPerTransfer ;  
      MemoryAddress    := TransferAddress(TransferAddress'left downto AXI_BYTE_ADDR_WIDTH) & (AXI_BYTE_ADDR_WIDTH downto 1 => '0') ;
      -- GetWordAddr(TransferAddress, AXI_BYTE_ADDR_WIDTH) ;
      
      if i = BurstLen then
        LRD.RLast := '1' ; 
      end if ; 
      ReadDataFifo.push(LRD.RData & LRD.RLast & AXI4_RESP_OKAY & LAR.ARID & LAR.ARUser) ;
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
    alias    AB : AxiBus'subtype is AxiBus ; 
    alias    RD is AB.ReadData ;
    variable Local : AxiBus.ReadData'subtype ;
  begin
    -- initialize
    RD.RValid <= '0' ;
    RD.RData  <= (Local.RData'range => '0') ; 
    RD.RResp  <= (Local.RResp'range => '0') ; 
    RD.RID    <= (Local.RID'range => '0') ; 
    RD.RUser  <= (Local.RUser'range => '0') ; 
    RD.RLast  <= '0' ; 

    ReadDataLoop : loop
      if ReadDataFifo.Empty then
        WaitForToggle(ReadDataRequestCount) ;
      end if ;
      (Local.RData, Local.RLast, Local.RResp, Local.RID, Local.RUser) := ReadDataFifo.pop ;

      -- Transaction Values
      RD.RData  <= Local.RData  after tpd_Clk_RDATA ;
      RD.RResp  <= Local.RResp  after tpd_Clk_RResp ;
      RD.RID    <= Local.RID    after tpd_Clk_RID ;
      RD.RUser  <= Local.RUser  after tpd_Clk_RUser ;
      RD.RLast  <= Local.RLast  after tpd_Clk_RLast ; 

--!9 Resolve Level
      Log(ModelID,
        "Read Data." &
        "  RData: "     & to_hstring(Local.RData) &
        "  RResp: "     & to_hstring(Local.RResp) &
        "  RID: "       & to_hstring(Local.RID) &
        "  RUser: "     & to_hstring(Local.RUser) &
        "  Operation# " & to_string(ReadDataDoneCount + 1),
        DEBUG
      ) ;

      ---------------------
      DoAxiValidHandshake (
      ---------------------
        Clk            =>  Clk,
        Valid          =>  RD.RValid,
        Ready          =>  RD.RReady,
        tpd_Clk_Valid  =>  tpd_Clk_RValid,
        AlertLogID     =>  BusFailedID,
        TimeOutMessage =>  "Read Data # " & to_string(ReadDataDoneCount + 1),
        TimeOutPeriod  =>  ReadDataReadyTimeOut * tperiod_Clk
      ) ;

      -- State after operation
      RD.RData  <= not Local.RData  after tpd_Clk_RDATA ;
      RD.RResp  <= not Local.RResp  after tpd_Clk_RResp ;
      RD.RID    <= Local.RID    after tpd_Clk_RID ;
      RD.RUser  <= Local.RUser  after tpd_Clk_RUser ;
      RD.RLast  <= not Local.RLast  after tpd_Clk_RLast ; 

      -- Signal completion
      Increment(ReadDataDoneCount) ;
      wait for 0 ns ; 
    end loop ReadDataLoop ;
  end process ReadDataHandler ;

end architecture MemoryResponder ;
