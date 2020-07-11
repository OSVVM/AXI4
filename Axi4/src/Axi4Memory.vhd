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

    alias  AWAddr    : std_logic_vector is AxiBus.WriteAddress.AWAddr ;
    alias  AWProt    : Axi4ProtType     is AxiBus.WriteAddress.AWProt ;
    alias  AWValid   : std_logic        is AxiBus.WriteAddress.AWValid ;
    alias  AWReady   : std_logic        is AxiBus.WriteAddress.AWReady ;
    -- Axi4 Full
    alias  AWID      : std_logic_vector is AxiBus.WriteAddress.AWID ;
    alias  AWLen     : std_logic_vector is AxiBus.WriteAddress.AWLen ;
    alias  AWSize    : std_logic_vector is AxiBus.WriteAddress.AWSize ;
    alias  AWBurst   : std_logic_vector is AxiBus.WriteAddress.AWBurst ;
    alias  AWLock    : std_logic        is AxiBus.WriteAddress.AWLock ;
    alias  AWCache   : std_logic_vector is AxiBus.WriteAddress.AWCache ;
    alias  AWQOS     : std_logic_vector is AxiBus.WriteAddress.AWQOS ;
    alias  AWRegion  : std_logic_vector is AxiBus.WriteAddress.AWRegion ;
    alias  AWUser    : std_logic_vector is AxiBus.WriteAddress.AWUser ;

    -- Write Data
    alias  WData     : std_logic_vector is AxiBus.WriteData.WData ;
    alias  WStrb     : std_logic_vector is AxiBus.WriteData.WStrb ;
    alias  WValid    : std_logic        is AxiBus.WriteData.WValid ;
    alias  WReady    : std_logic        is AxiBus.WriteData.WReady ;
    -- AXI4 Full
    alias  WLast     : std_logic        is AxiBus.WriteData.WLast ;
    alias  WUser     : std_logic_vector is AxiBus.WriteData.WUser ;
    -- AXI3
    alias  WID       : std_logic_vector is AxiBus.WriteData.WID ;

    -- Write Response
    alias  BResp     : Axi4RespType     is AxiBus.WriteResponse.BResp ;
    alias  BValid    : std_logic        is AxiBus.WriteResponse.BValid ;
    alias  BReady    : std_logic        is AxiBus.WriteResponse.BReady ;
    -- AXI4 Full
    alias  BID       : std_logic_vector is AxiBus.WriteResponse.BID ;
    alias  BUser     : std_logic_vector is AxiBus.WriteResponse.BUser ;

    -- Read Address
    alias  ARAddr    : std_logic_vector is AxiBus.ReadAddress.ARAddr ;
    alias  ARProt    : Axi4ProtType     is AxiBus.ReadAddress.ARProt ;
    alias  ARValid   : std_logic        is AxiBus.ReadAddress.ARValid ;
    alias  ARReady   : std_logic        is AxiBus.ReadAddress.ARReady ;
    -- Axi4 Full
    alias  ARID      : std_logic_vector is AxiBus.ReadAddress.ARID ;
    -- BurstLength = AxLen+1.  AXI4: 7:0,  AXI3: 3:0
    alias  ARLen     : std_logic_vector is AxiBus.ReadAddress.ARLen ;
    -- #Bytes in transfer = 2**AxSize
    alias  ARSize    : std_logic_vector is AxiBus.ReadAddress.ARSize ;
    -- AxBurst = (Fixed, Incr, Wrap, NotDefined)
    alias  ARBurst   : std_logic_vector is AxiBus.ReadAddress.ARBurst ;
    alias  ARLock    : std_logic is AxiBus.ReadAddress.ARLock ;
    -- AxCache One-hot (Write-Allocate, Read-Allocate, Modifiable, Bufferable)
    alias  ARCache   : std_logic_vector is AxiBus.ReadAddress.ARCache  ;
    alias  ARQOS     : std_logic_vector is AxiBus.ReadAddress.ARQOS    ;
    alias  ARRegion  : std_logic_vector is AxiBus.ReadAddress.ARRegion ;
    alias  ARUser    : std_logic_vector is AxiBus.ReadAddress.ARUser   ;

    -- Read Data
    alias  RData     : std_logic_vector is AxiBus.ReadData.RData ;
    alias  RResp     : Axi4RespType     is AxiBus.ReadData.RResp ;
    alias  RValid    : std_logic        is AxiBus.ReadData.RValid ;
    alias  RReady    : std_logic        is AxiBus.ReadData.RReady ;
    -- AXI4 Full
    alias  RID       : std_logic_vector is AxiBus.ReadData.RID   ;
    alias  RLast     : std_logic        is AxiBus.ReadData.RLast ;
    alias  RUser     : std_logic_vector is AxiBus.ReadData.RUser ;

end entity Axi4Memory ;

architecture MemoryResponder of Axi4Memory is

  constant AXI_ADDR_WIDTH       : integer := AWAddr'length ;
  constant AXI_DATA_WIDTH       : integer := WData'length ;
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
    variable Address          : AWAddr'subtype ;
    variable Data             : WData'subtype ;
    variable ExpectedData     : WData'subtype ;
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
  begin
    AWReady <= '0' ;
    WaitForClock(Clk, 2) ;  -- Initialize

    WriteAddressOperation : loop
      ---------------------
      DoAxiReadyHandshake (
      ---------------------
        Clk                     => Clk,
        Valid                   => AWValid,
        Ready                   => AWReady,
        ReadyBeforeValid        => WriteAddressReadyBeforeValid,
        ReadyDelayCycles        => WriteAddressReadyDelayCycles * tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_AWReady
      ) ;
      
--   AWAddr   - Used 
--   AWProt   - Unused 
--   -- AXI4 Full
--   AWLen    - (AWLen + 1) transfers in a burst - max 256 for INCR, 16 for others 
--   AWSize   - # Bytes in word of transfer = 2**AWSize.  Model requires to match Data'length
--   AWBurst  -- Burst Type. Fixed (no address change), Increment (simple linear), Wrap
--            -- Currently supported: Increment
--            -- Wrap Burst AWLen = 2, 4, 8, 16
--   AWID     - Used to generate BID 
--   AWUser   - By Default generates user in BUser, BUser also from settings 
--   AWLock   - Unused -- need by arbiters
--   AWCache  - Unused - Memory Type 
--   AWQOS    - Unused 
--   AWRegion - Unused 

--!9 Resolve Level
      Log(ModelID,
        "Write Address." &
        "  AWAddr: "    & to_hstring(AWAddr) &
        "  AWProt: "    & to_string (AWProt) &
        "  AWLen: "     & to_string (AWLen) & 
        "  AWSize: "    & to_string (AWSize) & 
        "  AWBurst: "   & to_string (AWBurst) & 
        "  AWID: "      & to_string (AWID) & 
        "  AWUser: "    & to_string (AWUser) & 
        "  Operation# " & to_string (WriteAddressReceiveCount + 1),
        DEBUG
      ) ;

      -- Send Address Information to WriteHandler
      WriteAddressFifo.push(AWAddr & AWProt & AWLen & AWSize & AWBurst & AWID & AWUser ) ;

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
  begin
    WReady <= '0' ;
    WaitForClock(Clk, 2) ;  -- Initialize

    WriteDataOperation : loop
      ---------------------
      DoAxiReadyHandshake(
      ---------------------
        Clk                     => Clk,
        Valid                   => WValid,
        Ready                   => WReady,
        ReadyBeforeValid        => WriteDataReadyBeforeValid,
        ReadyDelayCycles        => WriteDataReadyDelayCycles * tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_WReady
      ) ;


      -- Send to WriteHandler
      WriteDataFifo.push(WData & WStrb) ;

--!! Add AXI Full Information
--!9 Resolve Level
      Log(ModelID,
        "Write Data." &
        "  WData: "  & to_hstring(WData) &
        "  WStrb: "  & to_string(WStrb) &
        "  Operation# " & to_string(WriteDataReceiveCount + 1),
        DEBUG
      ) ;

      -- Signal completion
      increment(WriteDataReceiveCount) ;
      
--!9 Delay between accepting words determined by type of write address: Single Word, First Burst, Burst, Last Burst

    end loop WriteDataOperation ;
  end process WriteDataHandler ;


  ------------------------------------------------------------
  --  WriteHandler
  --    Collect Write Address and Data transactions
  ------------------------------------------------------------
  WriteHandler : process
    variable Addr  : AWAddr'subtype ;
    variable Prot  : AWProt'subtype ;
    variable Len   : AWLen'subtype ; 
    variable Size  : AWSize'subtype ; 
    variable Burst : AWBurst'subtype ; 
    variable ID    : AWID'subtype ; 
    variable User  : AWUser'subtype ; 
    variable Data  : WData'subtype ;
    variable Strb  : WStrb'subtype ;
    variable BurstLen         : integer ; 
    variable ByteAddressBits  : integer ; 
    variable BytesPerTransfer : integer ; 
    variable TransferAddress, MemoryAddress : AWAddr'subtype ;
    variable ByteData         : std_logic_vector(7 downto 0) ;
  begin
    -- Find Write Address and Data transaction
    if WriteAddressFifo.empty then
      WaitForToggle(WriteAddressReceiveCount) ;
    end if ;
    (Addr, Prot, Len, Size, Burst, ID, User) := WriteAddressFifo.pop ;
    
    if Len'length > 0 then
      BurstLen := to_integer(Len) + 1 ; 
    else
      BurstLen := 1 ; 
    end if ;

    if Size'length > 0 then
      ByteAddressBits := to_integer(Size) ;
      BytesPerTransfer    := 2 ** ByteAddressBits ;
    else
      ByteAddressBits := AXI_BYTE_ADDR_WIDTH ;
      BytesPerTransfer    := AXI_DATA_BYTE_WIDTH ;
    end if ;

    -- first word in a burst or single word transfer
    TransferAddress  := Addr(Addr'left downto ByteAddressBits) & (ByteAddressBits downto 1 => '0') ;
    -- GetWordAddr(Addr, BytesPerTransfer) ;
    MemoryAddress    := TransferAddress(Addr'left downto AXI_BYTE_ADDR_WIDTH) & (AXI_BYTE_ADDR_WIDTH downto 1 => '0') ;
    -- GetWordAddr(TransferAddress, AXI_BYTE_ADDR_WIDTH) ;
    
--!3 Delay before first word - burst vs. single word
    
    -- Burst transfers
    BurstLoop : for i in 1 to BurstLen loop 
      -- Wait for Data
      if WriteDataFifo.empty then
        WaitForToggle(WriteDataReceiveCount) ;
      end if ;
      (Data, Strb) := WriteDataFifo.pop ;

      if i = 1 then 
        Log(ModelID,
          "Slave Memory Write." &
          "  AWAddr: "    & to_hstring(Addr) &
          "  AWProt: "    & to_string (Prot) &
          "  WData: "     & to_hstring(Data) &
          "  WStrb: "     & to_string (Strb) &
          "  Operation# " & to_string (WriteReceiveCount),
          INFO
        ) ;
      end if ; 
      
      -- Memory is byte oriented.  Access as Bytes
      for i in 0 to AXI_DATA_BYTE_WIDTH-1 loop 
        if Strb(i) = '1' then 
          ByteData := Data((8*i + 7)  downto 8*i) ;
          Memory.MemWrite(MemoryAddress + i, ByteData) ;
        end if ; 
      end loop ;
      
--!5        GetNextBurstAddress(Address, BurstType) ;  -- to support Wrap addressing
      TransferAddress := TransferAddress + BytesPerTransfer ;  
      MemoryAddress    := TransferAddress(Addr'left downto AXI_BYTE_ADDR_WIDTH) & (AXI_BYTE_ADDR_WIDTH downto 1 => '0') ;
      -- GetWordAddr(TransferAddress, AXI_BYTE_ADDR_WIDTH) ;

      --!3 Delay between burst words - burst vs. single word

    end loop BurstLoop ;
  
--!3 Delay after last word - burst vs. single word

--!9 Get response from Params
--!9 Does response vary with Address?
--!! Only one response per burst cycle.  Last cycle of a burst only
    WriteResponseFifo.push(AXI4_RESP_OKAY & ID & User) ;
    increment(WriteReceiveCount) ;
    wait for 0 ns ;
  end process WriteHandler ;


  ------------------------------------------------------------
  -- WriteResponseHandler
  --   Receive and Check Write Responses
  ------------------------------------------------------------
  WriteResponseHandler : process
    variable Resp : BResp'subtype ;
    variable ID   : BID'subtype ;
    variable User : BUser'subtype ; 
  begin
    -- initialize
    BValid <= '0' ;
    BResp  <= (BResp'range => '0') ;
    BID    <= (BID'range => '0') ;
    BUser  <= (BUser'range => '0') ;

    WriteResponseLoop : loop
      -- Find Transaction
      if WriteResponseFifo.Empty then
        WaitForToggle(WriteReceiveCount) ;
      end if ;
      (Resp, ID, User) := WriteResponseFifo.pop ;

      -- Do Transaction
      BResp  <= Resp  after tpd_Clk_BResp ;
      BID    <= ID    after tpd_Clk_BID ;
      BUser  <= User  after tpd_Clk_BUser ;

      Log(ModelID,
        "Write Response." &
        "  BResp: "  & to_hstring(Resp) &
        "  BID: "    & to_hstring(ID) &
        "  BUser: "  & to_hstring(User) &
        "  Operation# " & to_string(WriteResponseDoneCount + 1),
        DEBUG
      ) ;

      ---------------------
      DoAxiValidHandshake (
      ---------------------
        Clk            =>  Clk,
        Valid          =>  BValid,
        Ready          =>  BReady,
        tpd_Clk_Valid  =>  tpd_Clk_BValid,
        AlertLogID     =>  BusFailedID,
        TimeOutMessage =>  "Write Response # " & to_string(WriteResponseDoneCount + 1),
        TimeOutPeriod  =>  WriteResponseReadyTimeOut * tperiod_Clk
      ) ;

      -- State after operation
      BResp  <= not Resp  after tpd_Clk_BResp ;
      BID    <= not ID    after tpd_Clk_BID ;
      BUser  <= not User  after tpd_Clk_BUser ;

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
  begin
    -- Initialize
    ARReady <= '0' ;
    WaitForClock(Clk, 2) ;  -- Initialize

    ReadAddressOperation : loop
      ---------------------
      DoAxiReadyHandshake (
      ---------------------
        Clk                     => Clk,
        Valid                   => ARValid,
        Ready                   => ARReady,
        ReadyBeforeValid        => ReadAddressReadyBeforeValid,
        ReadyDelayCycles        => ReadAddressReadyDelayCycles * tperiod_Clk,
        tpd_Clk_Ready           => tpd_Clk_ARReady
      ) ;
      
--!9 Resolve Level
      Log(ModelID,
        "Read Address." &
        "  ARAddr: "    & to_hstring(ARAddr) &
        "  ARProt: "    & to_string (ARProt) &
        "  ARLen: "     & to_string (ARLen) & 
        "  ARSize: "    & to_string (ARSize) & 
        "  ARBurst: "   & to_string (ARBurst) & 
        "  ARID: "      & to_string (ARID) & 
        "  ARUser: "    & to_string (ARUser) & 
        "  Operation# " & to_string (ReadAddressReceiveCount+1), 
        DEBUG
      ) ;
      
      -- Send Address Information to ReadHandler
      ReadAddressFifo.push(ARAddr & ARProt & ARLen & ARSize & ARBurst & ARID & ARUser ) ;

    -- Signal completion
      increment(ReadAddressReceiveCount) ;
--      ReadAddressReceiveCount <= ReadAddressReceiveCount + BurstCount ; 

--?6 Add delay between accepting addresses determined by type of address: Single Word, First Burst, Burst, Last Burst

    end loop ReadAddressOperation ;
  end process ReadAddressHandler ;


  ------------------------------------------------------------
  --  ReadHandler
  --    Accesses Memory
  --    Introduces cycle delays due to accessing memory
  ------------------------------------------------------------
  ReadHandler : process
    variable Addr  : ARAddr'subtype ;
    variable Prot  : ARProt'subtype ;
    variable Len   : ARLen'subtype ; 
    variable Size  : ARSize'subtype ; 
    variable Burst : ARBurst'subtype ; 
    variable ID    : ARID'subtype ; 
    variable User  : ARUser'subtype ; 
    variable Data  : RData'subtype ;
    variable Last  : RLast'subtype ;
    variable BurstLen         : integer ; 
    variable ByteAddressBits  : integer ; 
    variable BytesPerTransfer : integer ; 
    variable MemoryAddress, TransferAddress : ARAddr'subtype ;
    variable ByteData         : std_logic_vector(7 downto 0) ;
  begin
    if ReadAddressFifo.Empty then
      WaitForToggle(ReadAddressReceiveCount) ;
    end if ;
    (Addr, Prot, Len, Size, Burst, ID, User) := ReadAddressFifo.pop ;
    
--!6 Add delay to access memory by type of address: Single Word, First Burst, Burst, Last Burst

    if Len'length > 0 then
      BurstLen := to_integer(Len) + 1 ; 
    else
      BurstLen := 1 ; 
    end if ;

    if Size'length > 0 then
      ByteAddressBits   := to_integer(Size) ;
      BytesPerTransfer    := 2 ** ByteAddressBits ;
    else
      ByteAddressBits := AXI_BYTE_ADDR_WIDTH ;
      BytesPerTransfer    := AXI_DATA_BYTE_WIDTH ;
    end if ;

    -- first word in a burst or single word transfer
    TransferAddress  := Addr(Addr'left downto ByteAddressBits) & (ByteAddressBits downto 1 => '0') ;
    -- GetWordAddr(Addr, BytesPerTransfer) ;
    MemoryAddress    := TransferAddress(Addr'left downto AXI_BYTE_ADDR_WIDTH) & (AXI_BYTE_ADDR_WIDTH downto 1 => '0') ;
    -- GetWordAddr(TransferAddress, AXI_BYTE_ADDR_WIDTH) ;

    Last := '0' ;
    BurstLoop : for i in 1 to BurstLen loop 
      -- Memory is byte oriented.  Access as Bytes
      for i in 0 to AXI_DATA_BYTE_WIDTH-1 loop 
        Memory.MemRead(MemoryAddress + i, ByteData) ;
        Data((8*i + 7)  downto 8*i) := ByteData ; 
      end loop ;

      if i = 1 then 
        Log(ModelID,
          "Slave Memory Read." &
          "  ARAddr: "    & to_hstring(Addr) &
          "  ARProt: "    & to_string (Prot) &
          "  RData: "     & to_hstring(Data) &
          "  Operation# " & to_string (ReadDataRequestCount),
          INFO
        ) ;
      end if ; 

--!5        GetNextBurstAddress(TransferAddress, BurstType) ;  -- to support Wrap 
      TransferAddress := TransferAddress + BytesPerTransfer ;  
      MemoryAddress    := TransferAddress(Addr'left downto AXI_BYTE_ADDR_WIDTH) & (AXI_BYTE_ADDR_WIDTH downto 1 => '0') ;
      -- GetWordAddr(TransferAddress, AXI_BYTE_ADDR_WIDTH) ;
      
      if i = BurstLen then
        Last := '1' ; 
      end if ; 
      ReadDataFifo.push(Data & Last & AXI4_RESP_OKAY & ID & User) ;
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
    variable Data : RData'subtype ;
    variable Resp : RResp'subtype ;
    variable ID   : RID'subtype ;
    variable User : RUser'subtype ; 
    variable Last : RLast'subtype ; 
  begin
    -- initialize
    RValid <= '0' ;
    RData  <= (RData'range => '0') ;
    RResp  <= (RResp'range => '0') ;
    RID    <= (RID'range => '0') ;
    RUser  <= (RUser'range => '0') ;
    RLast  <= '0' ;

    ReadDataLoop : loop
      if ReadDataFifo.Empty then
        WaitForToggle(ReadDataRequestCount) ;
      end if ;
      (Data, Last, Resp, ID, User) := ReadDataFifo.pop ;

      -- Transaction Values
      RData  <= Data  after tpd_Clk_RDATA ;
      RResp  <= Resp  after tpd_Clk_RResp ;
      RID    <= ID    after tpd_Clk_RID ;
      RUser  <= User  after tpd_Clk_RUser ;
      RLast  <= Last  after tpd_Clk_RLast ; 

--!9 Resolve Level
      Log(ModelID,
        "Read Data." &
        "  RData: "     & to_hstring(Data) &
        "  RResp: "     & to_hstring(Resp) &
        "  RID: "       & to_hstring(ID) &
        "  RUser: "     & to_hstring(User) &
        "  Operation# " & to_string(ReadDataDoneCount + 1),
        DEBUG
      ) ;

      ---------------------
      DoAxiValidHandshake (
      ---------------------
        Clk            =>  Clk,
        Valid          =>  RValid,
        Ready          =>  RReady,
        tpd_Clk_Valid  =>  tpd_Clk_RValid,
        AlertLogID     =>  BusFailedID,
        TimeOutMessage =>  "Read Data # " & to_string(ReadDataDoneCount + 1),
        TimeOutPeriod  =>  ReadDataReadyTimeOut * tperiod_Clk
      ) ;

      -- State after operation
      RData  <= not Data  after tpd_Clk_RDATA ;
      RResp  <= not Resp  after tpd_Clk_RResp ;
      RID    <= ID    after tpd_Clk_RID ;
      RUser  <= User  after tpd_Clk_RUser ;
      RLast  <= not Last  after tpd_Clk_RLast ; 

      -- Signal completion
      Increment(ReadDataDoneCount) ;
      wait for 0 ns ; 
    end loop ReadDataLoop ;
  end process ReadDataHandler ;

end architecture MemoryResponder ;
