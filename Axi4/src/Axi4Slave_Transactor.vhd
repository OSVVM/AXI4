--
--  File Name:         Axi4Slave_Transactor.vhd
--  Design Unit Name:  Axi4Slave
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
  context osvvm.OsvvmContext ;
  use osvvm.ScoreboardPkg_slv.all ;

library OSVVM_Common ;
  context OSVVM_Common.OsvvmCommonContext ; 

  use work.Axi4OptionsTypePkg.all ;
--  use work.Axi4SlaveOptionsTypePkg.all ;
--  use work.Axi4SlaveTransactionPkg.all ;
  use work.Axi4InterfacePkg.all ;
  use work.Axi4Pkg.all ;
--  use work.Axi4MasterPkg.all ;
  use work.Axi4CommonPkg.all ;
  
entity Axi4Slave is
generic (
  MODEL_ID_NAME   : string :="" ;
  tperiod_Clk     : time := 10 ns ;

  tpd_Clk_AWReady : time := 2 ns ;

  tpd_Clk_WReady  : time := 2 ns ;

  tpd_Clk_BValid  : time := 2 ns ;
  tpd_Clk_BResp   : time := 2 ns ;

  tpd_Clk_ARReady : time := 2 ns ;

  tpd_Clk_RValid  : time := 2 ns ;
  tpd_Clk_RData   : time := 2 ns ;
  tpd_Clk_RResp   : time := 2 ns
) ;
port (
  -- Globals
  Clk         : in   std_logic ;
  nReset      : in   std_logic ;

  -- Testbench Transaction Interface
  TransRec    : inout AddressBusTransactionRecType ;

  -- AXI Master Functional Interface
  AxiBus      : inout Axi4RecType
) ;

  -- Entity Declaration region - continues in architecture
  -- These aliases make the record signals available by their short name
    -- Write Address
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
end entity Axi4Slave ;

architecture SlaveTransactor of Axi4Slave is

  constant AXI_ADDR_WIDTH : integer := AWAddr'length ;
  constant AXI_DATA_WIDTH : integer := WData'length ;
  constant AXI_DATA_BYTE_WIDTH : integer := AXI_DATA_WIDTH / 8 ;
  constant AXI_BYTE_ADDR_WIDTH : integer := integer(ceil(log2(real(AXI_DATA_BYTE_WIDTH)))) ; 

  constant MODEL_INSTANCE_NAME : string :=
    -- use MODEL_ID_NAME Generic if set, otherwise use instance label (preferred if set as entityname_1)
    IfElse(MODEL_ID_NAME /= "", MODEL_ID_NAME, PathTail(to_lower(Axi4Slave'PATH_NAME))) ;

  signal ModelID, ProtocolID, DataCheckID, BusFailedID : AlertLogIDType ;

  shared variable WriteAddressFifo     : osvvm.ScoreboardPkg_slv.ScoreboardPType ;
  shared variable WriteDataFifo        : osvvm.ScoreboardPkg_slv.ScoreboardPType ;
  shared variable WriteTransactionFifo : osvvm.ScoreboardPkg_slv.ScoreboardPType ;
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


  signal WriteResponseReadyTimeOut, ReadDataReadyTimeOut : integer := 25 ;

  signal WriteAddressReadyBeforeValid  : boolean := TRUE ;
  signal WriteAddressReadyDelayCycles  : integer := 0 ;
  signal WriteDataReadyBeforeValid     : boolean := TRUE ;
  signal WriteDataReadyDelayCycles     : integer := 0 ;
  signal ReadAddressReadyBeforeValid   : boolean := TRUE ;
  signal ReadAddressReadyDelayCycles   : integer := 0 ;

  signal ModelWProt  : Axi4ProtType := (others => '0') ;
  signal ModelRProt  : Axi4ProtType := (others => '0') ;

  signal ModelWResp  : Axi4RespType := to_Axi4RespType(OKAY) ;
  signal ModelRResp  : Axi4RespType := to_Axi4RespType(OKAY) ;

begin

  ------------------------------------------------------------
  -- Turn off drivers not being driven by this model
  ------------------------------------------------------------
  InitAxi4Rec (AxiBusRec => AxiBus ) ;


  ------------------------------------------------------------
  --  Initialize AlertLogIDs
  ------------------------------------------------------------
  Initalize : process
    variable ID : AlertLogIDType ;
  begin
    -- Transaction Interface
--    TransRec.AxiAddrWidth   <= AWAddr'length ;
--    TransRec.AxiDataWidth   <= WData'length ;

    -- Alerts
    ID                      := GetAlertLogID(MODEL_INSTANCE_NAME) ;
    ModelID                 <= ID ;
--    TransRec.AlertLogID     <= GetAlertLogID(MODEL_INSTANCE_NAME & ": Transaction", ID ) ;
    ProtocolID              <= GetAlertLogID(MODEL_INSTANCE_NAME & ": Protocol Error", ID ) ;
    DataCheckID             <= GetAlertLogID(MODEL_INSTANCE_NAME & ": Data Check", ID ) ;
    BusFailedID             <= GetAlertLogID(MODEL_INSTANCE_NAME & ": No response", ID ) ;

    -- FIFOS.  FIFOS share main ID as they only generate errors if the model uses them wrong
    WriteAddressFifo.SetAlertLogID(ID);
    WriteAddressFifo.SetName(     MODEL_INSTANCE_NAME & ": WriteAddressFIFO");
    WriteDataFifo.SetAlertLogID(ID);
    WriteDataFifo.SetName(        MODEL_INSTANCE_NAME & ": WriteDataFifo");
    WriteTransactionFifo.SetAlertLogID(ID);
    WriteTransactionFifo.SetName( MODEL_INSTANCE_NAME & ": WriteTransactionFifo");
    WriteResponseFifo.SetAlertLogID(ID);
    WriteResponseFifo.SetName(    MODEL_INSTANCE_NAME & ": WriteResponseFifo");

    ReadAddressFifo.SetAlertLogID(ID);
    ReadAddressFifo.SetName(      MODEL_INSTANCE_NAME & ": ReadAddressFifo");
    ReadDataFifo.SetAlertLogID(ID);
    ReadDataFifo.SetName(         MODEL_INSTANCE_NAME & ": ReadDataFifo");
    wait ;
  end process Initalize ;


  ------------------------------------------------------------
  --  Transaction Dispatcher
  --    Handles transactions between TestCtrl and Model
  ------------------------------------------------------------
  TransactionDispatcher : process
    variable WaitClockCycles     : integer ;
    variable WriteAddr           : AWAddr'subtype ;
    variable WriteProt           : AWProt'subtype ;
    variable FoundWriteAddress   : boolean := FALSE ; 
    variable WriteAvailable      : boolean := FALSE ; 
    
    variable WriteData           : WData'subtype ;
    variable WriteStrb           : WStrb'subtype ;
    variable WriteLast           : WLast'subtype ;
    variable WriteUser           : WUser'subtype ;
    variable WriteID             : WID'subtype ;
    variable ExpectedWStrb       : WStrb'subtype ; 
    variable WriteByteCount      : integer ; 
    variable WriteByteAddress    : integer ; 
    variable FoundLastWriteData  : boolean := FALSE ; 

    variable WriteResp           : BResp'subtype ;
    
    variable ReadAddr            : ARAddr'subtype ;
    variable ReadProt            : ARProt'subtype ;
    variable ReadAvailable       : boolean := FALSE ; 
    
    variable ReadData            : RData'subtype ;
    variable ReadResp            : RResp'subtype ;
    
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

      when WRITE_OP | WRITE_ADDRESS | WRITE_DATA |
           ASYNC_WRITE | ASYNC_WRITE_ADDRESS | ASYNC_WRITE_DATA =>

        if (IsTryWriteAddress(TransRec.Operation) and WriteAddressFifo.empty) or
           (IsTryWriteData(TransRec.Operation)    and WriteDataFifo.empty) then 
          WriteAvailable         := FALSE ; 
          TransRec.BoolFromModel <= FALSE ; 
        else 
          WriteAvailable         := TRUE ; 
          TransRec.BoolFromModel <= TRUE ; 
        end if ;
        
        if WriteAvailable and IsWriteAddress(TransRec.Operation) then
          -- Find Write Address transaction
          if WriteAddressFifo.empty then
            WaitForToggle(WriteAddressReceiveCount) ;
          end if ;
          
          (WriteAddr, WriteProt) := WriteAddressFifo.pop ;
          TransRec.Address        <= ToTransaction(WriteAddr) ;
          FoundWriteAddress := TRUE ; 

          AlertIf(ModelID, TransRec.AddrWidth /= AXI_ADDR_WIDTH, "SlaveGetWrite, Address length does not match", FAILURE) ;
          -- Check WProt
          AlertIfNotEqual(ModelID, WriteProt, ModelWProt, "SlaveGetWrite, WProt", ERROR) ;
        end if ;

        if WriteAvailable and IsWriteData(TransRec.Operation) then
          -- Find Write Data transaction
          if WriteDataFifo.empty then
            WaitForToggle(WriteDataReceiveCount) ;
          end if ;
          
          (WriteData, WriteStrb, WriteLast, WriteUser, WriteID) := WriteDataFifo.pop ;
-- Adjust handling for Byte Location?   
-- Requires updating tests.
          TransRec.DataFromModel  <= ToTransaction(Extend(WriteData, TransRec.DataFromModel'length)) ;
          if WriteLast = '1' then 
            FoundLastWriteData := TRUE ;
            WriteResponseFifo.push(ModelWResp) ;
          end if ; 
          
-- Works for SlaveGetWriteData - but only if access is correct sized, but not SlaveGetWrite          
--          -- Check WStrb  
--          ByteCount := TransRec.DataWidth / 8 ;
--          WriteByteAddress := TransRec.AddrWidth mod AXI_BYTE_ADDR_WIDTH ; 
--          ExpectedWStrb := CalculateAxiWriteStrobe(WriteByteAddress, ByteCount, AXI_DATA_BYTE_WIDTH) ;
--          AlertIfNotEqual(ModelID, WriteStrb, ExpectedWStrb, "SlaveGetWrite, WStrb", ERROR) ;

          -- Check Data Size
          AlertIf(ModelID, TransRec.DataWidth > AXI_DATA_WIDTH, "SlaveGetWrite, Expected Data length to large", FAILURE) ;
          AlertIf(ModelID, TransRec.DataWidth mod 8 /= 0, 
            "SlaveGetWrite, Expected Data not on a byte boundary." & 
            "DataWidth: " & to_string(TransRec.DataWidth), 
            FAILURE) ;
        end if ;

-- Update s.t. only sent when WLast = '1'
        -- Appropriate when 
        if FoundWriteAddress and FoundLastWriteData then
          increment(WriteReceiveCount) ;
          FoundWriteAddress  := TRUE ;
          FoundLastWriteData := TRUE ; 
        end if ; 

--    -- Log this operation
--    Log(ModelID,
--      "Write Operation." &
--      "  AWAddr: "    & to_hstring(WriteAddr) &
--      "  AWProt: "    & to_string(WriteProt) &
--      "  WData: "     & to_hstring(WriteData) &
--      "  WStrb: "     & to_string(WriteStrb) &
--      "  Operation# " & to_string(WriteReceiveCount),
--      DEBUG
--    ) ;

        wait for 0 ns ;


      when READ_OP | READ_ADDRESS | READ_DATA | 
           ASYNC_READ | ASYNC_READ_ADDRESS | ASYNC_READ_DATA =>
           
        if (IsTryReadAddress(TransRec.Operation) and ReadAddressFifo.empty) then 
          ReadAvailable          := FALSE ; 
          TransRec.BoolFromModel <= FALSE ; 
        else 
          ReadAvailable          := TRUE ; 
          TransRec.BoolFromModel <= TRUE ; 
        end if ;

        if ReadAvailable and IsReadAddress(TransRec.Operation) then
          -- Expect Read Address Cycle
          if ReadAddressFifo.empty then
            WaitForToggle(ReadAddressReceiveCount) ;
          end if ;
          (ReadAddr, ReadProt) := ReadAddressFifo.pop ;
          TransRec.Address        <= ToTransaction(ReadAddr) ;
          AlertIf(ModelID, TransRec.AddrWidth /= AXI_ADDR_WIDTH, "Slave Read, Address length does not match", FAILURE) ;
  --!TODO Add Check here for actual PROT vs expected (ModelRProt)
  --        TransRec.Prot           <= to_integer(ReadProt) ;
        end if ; 
        
        if ReadAvailable and IsReadData(TransRec.Operation) then

          -- Push Read Data Response Values
          -- Get Read Data Response Values
          ReadData := FromTransaction(TransRec.DataToModel) ;
          ReadDataFifo.push(ReadData & ModelRResp) ;

          -- Data Sizing Checks
          AlertIf(ModelID, TransRec.DataWidth > AXI_DATA_WIDTH, "Slave Read, Data length to large", FAILURE) ;
          AlertIf(ModelID, TransRec.DataWidth mod 8 /= 0, "Slave Read, Data not on a byte boundary", FAILURE) ;
  --!TODO replace with data width checking here
  --        variable ByteCount : integer ;
  --        ByteCount := TransRec.DataWidth / 8 ;
  --        Check ReadStrb and Byte Count to make sure they correlate
          Increment(ReadDataRequestCount) ;
          
          -- Currently all ReadData Operations are Async
          -- Add blocking until completion here
        end if ; 

        wait for 0 ns ;

      when SET_MODEL_OPTIONS =>
        -- Set Model Options
--        case TransRec.Options is
--        case Axi4OptionsType'val(TransRec.Options) is
--          -- Slave Ready TimeOut Checks
--          when WRITE_RESPONSE_READY_TIME_OUT =>       WriteResponseReadyTimeOut     <= TransRec.IntToModel ;
--          when READ_DATA_READY_TIME_OUT =>            ReadDataReadyTimeOut          <= TransRec.IntToModel ;
--          -- Slave Ready Before Valid
--          when WRITE_ADDRESS_READY_BEFORE_VALID =>    WriteAddressReadyBeforeValid  <= TransRec.BoolToModel ;
--          when WRITE_DATA_READY_BEFORE_VALID =>       WriteDataReadyBeforeValid     <= TransRec.BoolToModel ;
--          when READ_ADDRESS_READY_BEFORE_VALID =>     ReadAddressReadyBeforeValid   <= TransRec.BoolToModel ;
--          -- Slave Ready Delay Cycles
--          when WRITE_ADDRESS_READY_DELAY_CYCLES =>    WriteAddressReadyDelayCycles  <= TransRec.IntToModel ;
--          when WRITE_DATA_READY_DELAY_CYCLES =>       WriteDataReadyDelayCycles     <= TransRec.IntToModel ;
--          when READ_ADDRESS_READY_DELAY_CYCLES =>     ReadAddressReadyDelayCycles   <= TransRec.IntToModel ;
--          -- Slave PROT Settings
--          when WRITE_PROT =>                          ModelWProt <= to_slv(TransRec.IntToModel, ModelWProt'length) ;
--          when READ_PROT =>                           ModelRProt  <= to_slv(TransRec.IntToModel, ModelRProt'length) ;
--          -- Slave RESP Settings
--          when WRITE_RESPONSE_RESP =>                 ModelWResp <= to_slv(TransRec.IntToModel, ModelWResp'length) ;
--          when READ_DATA_RESP =>                      ModelRResp  <= to_slv(TransRec.IntToModel, ModelRResp'length) ;
--          --
--          -- The End -- Done
--          when others =>
--            Alert(ModelID, "Unimplemented Option", FAILURE) ;
--        end case ;
        wait for 0 ns ;
        
      when GET_MODEL_OPTIONS =>
--        -- Set Model Options
--        case Axi4OptionsType'val(TransRec.Options) is
--          case TransRec.Options is
--          -- Slave Ready TimeOut Checks
--          when WRITE_RESPONSE_READY_TIME_OUT =>       TransRec.IntFromModel  <= WriteResponseReadyTimeOut ;
--          when READ_DATA_READY_TIME_OUT =>            TransRec.IntFromModel  <= ReadDataReadyTimeOut ;
--          -- Slave Ready Before Valid
--          when WRITE_ADDRESS_READY_BEFORE_VALID =>    TransRec.BoolFromModel <= WriteAddressReadyBeforeValid ;
--          when WRITE_DATA_READY_BEFORE_VALID =>       TransRec.BoolFromModel <= WriteDataReadyBeforeValid    ;
--          when READ_ADDRESS_READY_BEFORE_VALID =>     TransRec.BoolFromModel <= ReadAddressReadyBeforeValid  ;
--          -- Slave Ready Delay Cycles
--          when WRITE_ADDRESS_READY_DELAY_CYCLES =>    TransRec.IntFromModel  <= WriteAddressReadyDelayCycles ;
--          when WRITE_DATA_READY_DELAY_CYCLES =>       TransRec.IntFromModel  <= WriteDataReadyDelayCycles    ;
--          when READ_ADDRESS_READY_DELAY_CYCLES =>     TransRec.IntFromModel  <= ReadAddressReadyDelayCycles  ;
--          -- Slave PROT Settings
--          when WRITE_PROT =>                          TransRec.IntFromModel <= to_integer(ModelWProt) ;
--          when READ_PROT =>                           TransRec.IntFromModel <= to_integer(ModelRProt ) ;
--          -- Slave RESP Settings
--          when WRITE_RESPONSE_RESP =>                 TransRec.IntFromModel <= to_integer(ModelWResp) ;
--          when READ_DATA_RESP =>                      TransRec.IntFromModel <= to_integer(ModelRResp) ;
--          --
--          -- The End -- Done
--          when others =>
--            Alert(ModelID, "Unimplemented Option", FAILURE) ;
--        end case ;
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
        tpd_Clk_Ready           => tpd_Clk_AWReady, 
        AlertLogID              => BusFailedID,
        TimeOutMessage          => "Write Address # " & to_string(WriteAddressReceiveCount + 1)
      ) ;

      -- capture address, prot
      WriteAddressFifo.push(AWAddr & AWProt) ;

      -- Log this operation
      Log(ModelID,
        "Write Address." &
        "  AWAddr: "  & to_hstring(AWAddr) &
        "  AWProt: "  & to_string(AWProt) &
        "  Operation# " & to_string(WriteAddressReceiveCount + 1),
        INFO
      ) ;

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
        tpd_Clk_Ready           => tpd_Clk_WReady,
        AlertLogID              => BusFailedID,
        TimeOutMessage          => "Write Data # " & to_string(WriteDataReceiveCount + 1)
      ) ;

      -- capture Data, wstrb
-- Planned Upgrade, Axi4Lite always sets WLast to 1      
      WriteDataFifo.push(WData & WStrb & WLast & WUser) ;

      -- Log this operation
      Log(ModelID,
        "Write Data." &
        "  WData: "  & to_hstring(WData) &
        "  WStrb: "  & to_string(WStrb) &
        "  Operation# " & to_string(WriteDataReceiveCount + 1),
        INFO
      ) ;

      -- Signal completion
      increment(WriteDataReceiveCount) ;
      wait for 0 ns ;
    end loop WriteDataOperation ;
  end process WriteDataHandler ;


  ------------------------------------------------------------
  -- WriteResponseHandler
  --   Receive and Check Write Responses
  ------------------------------------------------------------
  WriteResponseHandler : process
    variable localResp : BResp'subtype ;
  begin
    -- initialize
    BValid <= '0' ;
    BResp  <= (BResp'range => '0') ;

    WriteResponseLoop : loop
      -- Find Transaction
--! Done always less than Receive, change to just "="
--! ">" will break due to roll over if there are more than 2**30 transfers
      if WriteResponseDoneCount >= WriteReceiveCount then
        WaitForToggle(WriteReceiveCount) ;
      end if ;
      if not WriteResponseFifo.Empty then
        localResp := WriteResponseFifo.pop ;
      else
       localResp := AXI4_RESP_OKAY ;
      end if ;

      -- Do Transaction
      BResp  <= localResp  after tpd_Clk_BResp ;

      Log(ModelID,
        "Write Response." &
        "  BResp: "  & to_hstring(localResp) &
        "  Operation# " & to_string(WriteResponseDoneCount + 1),
        INFO
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
      BResp  <= not localResp after tpd_Clk_BResp ;

      -- Signal completion
      Increment(WriteResponseDoneCount) ;
      wait for 0 ns ;
    end loop WriteResponseLoop ;
  end process WriteResponseHandler ;


  ------------------------------------------------------------
  --  ReadAddressHandler
  --    Execute Read Address Transactions
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
        tpd_Clk_Ready           => tpd_Clk_ARReady,
        AlertLogID              => BusFailedID,
        TimeOutMessage          => "Read Address # " & to_string(ReadAddressReceiveCount + 1)
      ) ;

      -- capture address, prot
      ReadAddressFifo.push(ARAddr & ARProt) ;
      increment(ReadAddressReceiveCount) ;
      wait for 0 ns ;

      Log(ModelID,
        "Read Address." &
        "  ARAddr: "  & to_hstring(ARAddr) &
        "  ARProt: "  & to_string(ARProt) &
        "  Operation# " & to_string(ReadAddressReceiveCount), -- adjusted for delay of ReadAddressReceiveCount
        INFO
      ) ;
    end loop ReadAddressOperation ;
  end process ReadAddressHandler ;


  ------------------------------------------------------------
  --  ReadDataHandler
  --    Receive Read Data Transactions
  ------------------------------------------------------------
  ReadDataHandler : process
    variable ReadData  : RData'subtype ;
    variable ReadResp  : RResp'subtype ;
  begin
    -- initialize
    RValid <= '0' ;
    RData  <= (RData'range => '0') ;
    RResp  <= (RResp'range => '0') ;

    ReadDataLoop : loop
      -- Start a Read Data Response Transaction after receiving a read address
      if ReadAddressReceiveCount <= ReadDataDoneCount then
        WaitForToggle(ReadAddressReceiveCount) ;
      end if ;

      if ReadDataFifo.Empty then
        WaitForToggle(ReadDataRequestCount) ;
      end if ;

      (ReadData, ReadResp) := ReadDataFifo.pop ;

--      -- Find Response if available
--      if not ReadDataFifo.Empty then
--        (ReadData, ReadResp) := ReadDataFifo.pop ;
--      else
--        ReadData := to_slv(ReadAddressReceiveCount, RData'length) ;
--        ReadResp := AXI4_RESP_OKAY ;
--      end if ;

      -- Transaction Values
      RData  <= ReadData  after tpd_Clk_RDATA ;
      RResp  <= ReadResp  after tpd_Clk_RResp ;

      Log(ModelID,
        "Read Data." &
        "  RData: "  & to_hstring(ReadData) &
        "  RResp: "  & to_hstring(ReadResp) &
        "  Operation# " & to_string(ReadDataDoneCount + 1),
        INFO
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
      RValid <= '0' after tpd_Clk_RValid ;
      RData  <= not ReadData after tpd_clk_RData ;
      RResp  <= not ReadResp after tpd_Clk_RResp ;

      -- Signal completion
      Increment(ReadDataDoneCount) ;
      wait for 0 ns ;
    end loop ReadDataLoop ;
  end process ReadDataHandler ;

end architecture SlaveTransactor ;
