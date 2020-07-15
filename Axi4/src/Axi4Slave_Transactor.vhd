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
  use work.Axi4InterfacePkg.all ;
  use work.Axi4Pkg.all ;
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
end entity Axi4Slave ;

architecture SlaveTransactor of Axi4Slave is

  alias    AxiAddr is AxiBus.WriteAddress.AWAddr ;
  alias    AxiData is AxiBus.WriteData.WData ;
  constant AXI_ADDR_WIDTH : integer := AxiAddr'length ;
  constant AXI_DATA_WIDTH : integer := AxiData'length ;
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
    variable AxiLocal    : AxiBus'subtype ; 
    alias    LAW is AxiLocal.WriteAddress ; 
    alias    LWD is AxiLocal.WriteData ; 
    alias    LWR is AxiLocal.WriteResponse ; 
    alias    LAR is AxiLocal.ReadAddress ; 
    alias    LRD is AxiLocal.ReadData ;
    
    variable WaitClockCycles     : integer ;
    alias WriteAddr           is LAW.AWAddr ;
    alias WriteProt           is LAW.AWProt ;

    variable FoundWriteAddress   : boolean := FALSE ; 
    variable WriteAvailable      : boolean := FALSE ; 
    
    alias WriteData           is LWD.WData ;
    alias WriteStrb           is LWD.WStrb ;
    alias WriteLast           is LWD.WLast ;
    alias WriteUser           is LWD.WUser ;
    alias WriteID             is LWD.WID ;
--    alias ExpectedWStrb       is LWD.WStrb ; 
    variable WriteByteCount      : integer ; 
    variable WriteByteAddress    : integer ; 
    variable FoundLastWriteData  : boolean := FALSE ; 

--    alias WriteResp           is LWR.BResp ;
    
    alias ReadAddr            is LAR.ARAddr ;
    alias ReadProt            is LAR.ARProt ;
    variable ReadAvailable       : boolean := FALSE ; 
    
    alias ReadData            is LRD.RData ;
--    alias ReadResp            is LRD.RResp ;
    
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
        case Axi4OptionsType'val(TransRec.Options) is
          -- Slave Ready TimeOut Checks
          when WRITE_RESPONSE_READY_TIME_OUT =>       WriteResponseReadyTimeOut     <= TransRec.IntToModel ;
          when READ_DATA_READY_TIME_OUT =>            ReadDataReadyTimeOut          <= TransRec.IntToModel ;
          -- Slave Ready Before Valid
          when WRITE_ADDRESS_READY_BEFORE_VALID =>    WriteAddressReadyBeforeValid  <= TransRec.BoolToModel ;
          when WRITE_DATA_READY_BEFORE_VALID =>       WriteDataReadyBeforeValid     <= TransRec.BoolToModel ;
          when READ_ADDRESS_READY_BEFORE_VALID =>     ReadAddressReadyBeforeValid   <= TransRec.BoolToModel ;
          -- Slave Ready Delay Cycles
          when WRITE_ADDRESS_READY_DELAY_CYCLES =>    WriteAddressReadyDelayCycles  <= TransRec.IntToModel ;
          when WRITE_DATA_READY_DELAY_CYCLES =>       WriteDataReadyDelayCycles     <= TransRec.IntToModel ;
          when READ_ADDRESS_READY_DELAY_CYCLES =>     ReadAddressReadyDelayCycles   <= TransRec.IntToModel ;
          -- Slave PROT Settings
          when AWPROT =>                              ModelWProt <= to_slv(TransRec.IntToModel, ModelWProt'length) ;
          when ARPROT =>                              ModelRProt  <= to_slv(TransRec.IntToModel, ModelRProt'length) ;
          -- Slave RESP Settings
          when BRESP =>                               ModelWResp <= to_slv(TransRec.IntToModel, ModelWResp'length) ;
          when RRESP =>                               ModelRResp  <= to_slv(TransRec.IntToModel, ModelRResp'length) ;
          --
          -- The End -- Done
          when others =>
            Alert(ModelID, "Unimplemented Option", FAILURE) ;
        end case ;
        wait for 0 ns ;
        
      when GET_MODEL_OPTIONS =>
        -- Set Model Options
        case Axi4OptionsType'val(TransRec.Options) is
          -- Slave Ready TimeOut Checks
          when WRITE_RESPONSE_READY_TIME_OUT =>       TransRec.IntFromModel  <= WriteResponseReadyTimeOut ;
          when READ_DATA_READY_TIME_OUT =>            TransRec.IntFromModel  <= ReadDataReadyTimeOut ;
          -- Slave Ready Before Valid
          when WRITE_ADDRESS_READY_BEFORE_VALID =>    TransRec.BoolFromModel <= WriteAddressReadyBeforeValid ;
          when WRITE_DATA_READY_BEFORE_VALID =>       TransRec.BoolFromModel <= WriteDataReadyBeforeValid    ;
          when READ_ADDRESS_READY_BEFORE_VALID =>     TransRec.BoolFromModel <= ReadAddressReadyBeforeValid  ;
          -- Slave Ready Delay Cycles
          when WRITE_ADDRESS_READY_DELAY_CYCLES =>    TransRec.IntFromModel  <= WriteAddressReadyDelayCycles ;
          when WRITE_DATA_READY_DELAY_CYCLES =>       TransRec.IntFromModel  <= WriteDataReadyDelayCycles    ;
          when READ_ADDRESS_READY_DELAY_CYCLES =>     TransRec.IntFromModel  <= ReadAddressReadyDelayCycles  ;
          -- Slave PROT Settings
          when AWPROT =>                              TransRec.IntFromModel <= to_integer(ModelWProt) ;
          when ARPROT =>                              TransRec.IntFromModel <= to_integer(ModelRProt ) ;
          -- Slave RESP Settings
          when BRESP =>                               TransRec.IntFromModel <= to_integer(ModelWResp) ;
          when RRESP =>                               TransRec.IntFromModel <= to_integer(ModelRResp) ;
          --
          -- The End -- Done
          when others =>
            Alert(ModelID, "Unimplemented Option", FAILURE) ;
        end case ;
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
        tpd_Clk_Ready           => tpd_Clk_AWReady, 
        AlertLogID              => BusFailedID,
        TimeOutMessage          => "Write Address # " & to_string(WriteAddressReceiveCount + 1)
      ) ;

      -- capture address, prot
      WriteAddressFifo.push(AW.AWAddr & AW.AWProt) ;

      -- Log this operation
      Log(ModelID,
        "Write Address." &
        "  AWAddr: "  & to_hstring(AW.AWAddr) &
        "  AWProt: "  & to_string(AW.AWProt) &
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
        tpd_Clk_Ready           => tpd_Clk_WReady,
        AlertLogID              => BusFailedID,
        TimeOutMessage          => "Write Data # " & to_string(WriteDataReceiveCount + 1)
      ) ;

      -- capture Data, wstrb
-- Planned Upgrade, Axi4Lite always sets WLast to 1      
      WriteDataFifo.push(WD.WData & WD.WStrb & WD.WLast & WD.WUser) ;

      -- Log this operation
      Log(ModelID,
        "Write Data." &
        "  WData: "  & to_hstring(WD.WData) &
        "  WStrb: "  & to_string(WD.WStrb) &
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
    alias    AB : AxiBus'subtype is AxiBus ; 
    alias    WR is AB.WriteResponse ; 
    variable Local : AxiBus.WriteResponse'subtype ;
--    alias localResp  is Local.BResp ;
  begin
    -- initialize
    WR.BValid <= '0' ;
    WR.BResp  <= (WR.BResp'range => '0') ;

    WriteResponseLoop : loop
      -- Find Transaction
--! Done always less than Receive, change to just "="
--! ">" will break due to roll over if there are more than 2**30 transfers
      if WriteResponseDoneCount >= WriteReceiveCount then
        WaitForToggle(WriteReceiveCount) ;
      end if ;
      if not WriteResponseFifo.Empty then
        Local.BResp := WriteResponseFifo.pop ;
      else
       Local.BResp := AXI4_RESP_OKAY ;
      end if ;

      -- Do Transaction
      WR.BResp  <= Local.BResp  after tpd_Clk_BResp ;

      Log(ModelID,
        "Write Response." &
        "  BResp: "  & to_hstring(Local.BResp) &
        "  Operation# " & to_string(WriteResponseDoneCount + 1),
        INFO
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
      WR.BResp  <= not Local.BResp after tpd_Clk_BResp ;

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
        tpd_Clk_Ready           => tpd_Clk_ARReady,
        AlertLogID              => BusFailedID,
        TimeOutMessage          => "Read Address # " & to_string(ReadAddressReceiveCount + 1)
      ) ;

      -- capture address, prot
      ReadAddressFifo.push(AR.ARAddr & AR.ARProt) ;
      increment(ReadAddressReceiveCount) ;
      wait for 0 ns ;

      Log(ModelID,
        "Read Address." &
        "  ARAddr: "  & to_hstring(AR.ARAddr) &
        "  ARProt: "  & to_string(AR.ARProt) &
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
    alias    AB : AxiBus'subtype is AxiBus ; 
    alias    RD is AB.ReadData ;
    variable Local : AxiBus.ReadData'subtype ;
--    alias ReadData  is Local.RData ;
--    alias ReadResp  is Local.RResp ;
  begin
    -- initialize
    RD.RValid <= '0' ;
    RD.RData  <= (RD.RData'range => '0') ;
    RD.RResp  <= (RD.RResp'range => '0') ;

    ReadDataLoop : loop
      -- Start a Read Data Response Transaction after receiving a read address
      if ReadAddressReceiveCount <= ReadDataDoneCount then
        WaitForToggle(ReadAddressReceiveCount) ;
      end if ;

      if ReadDataFifo.Empty then
        WaitForToggle(ReadDataRequestCount) ;
      end if ;

      (Local.RData, Local.RResp) := ReadDataFifo.pop ;

--      -- Find Response if available
--      if not ReadDataFifo.Empty then
--        (Local.RData, Local.RResp) := ReadDataFifo.pop ;
--      else
--        Local.RData := to_slv(ReadAddressReceiveCount, RData'length) ;
--        Local.RResp := AXI4_RESP_OKAY ;
--      end if ;

      -- Transaction Values
      RD.RData  <= Local.RData  after tpd_Clk_RDATA ;
      RD.RResp  <= Local.RResp  after tpd_Clk_RResp ;

      Log(ModelID,
        "Read Data." &
        "  RData: "  & to_hstring(Local.RData) &
        "  RResp: "  & to_hstring(Local.RResp) &
        "  Operation# " & to_string(ReadDataDoneCount + 1),
        INFO
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
      RD.RValid <= '0' after tpd_Clk_RValid ;
      RD.RData  <= not Local.RData after tpd_clk_RData ;
      RD.RResp  <= not Local.RResp after tpd_Clk_RResp ;

      -- Signal completion
      Increment(ReadDataDoneCount) ;
      wait for 0 ns ;
    end loop ReadDataLoop ;
  end process ReadDataHandler ;

end architecture SlaveTransactor ;
