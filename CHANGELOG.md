# AXI4 Verification Component Change Log

| Revision  | Revision Date  |  Release Summary | 
------------|----------------|----------- 
| 2022.05   | May 2022       |  Updated FIFOs so they are Search => PRIVATE
| 2022.04   | April 2022     |  Updated AxiMemory Burst Reads - see details below
| 2022.03   | March 2022     |  Updated calls to NewID for AlertLogID and FIFOs
|           |                |  Rebuilt Axi4Lite for Axi4 FULL so it will run on GHDL
| 2022.02   | February 2022  |  Added to_hxstring, Axi4Memory for MemoryPkg search by NAME, <see below>.
| 2022.01   | January 2022   |  Added test cases to support testing of AddressBus and Stream MIT burst patterns
| 2021.09   | September 2021 |  Minor bug fix to Axi4Subordinate.  Updates to testbenches to support writing YAML files
| 2021.08   | August 2021    |  Updated AXI4 naming.  Changed Axi4Master to Axi4Manager and Axi4Responder to Axi4Subordinate.
| 2021.06   | June 2021      |  Updated Axi4Master[Vti], AxiStreamXX[Vti], Axi4Memory[Vti]
|           |                |  for new Burst Fifo and Memory data structures
| 2021.03   | March 2021     |  Minor updates to scripts for case sensitivity on Linux
| 2021.02   | February 2021  |  Added TRANSMIT_VALID_DELAY_CYCLES to AxiStreamTransmitter
| 2020.12   | December 2020  |  More Bursting and Virtual Transaction Interfaces.
| 2020.10   | October 2020   |  Added Bursting to AxiStream. 
| 2020.07   | July 2020      |  Major:  Axi4Lite, Axi4(Full) w/ Bursting, AddressBusTransactionPkg, Responder
| 2020.02   | February 2020  |  Initial version of AddressBusTransactionPkg.
| 2018.04   | April 2018     |  Initial public release

## 2022.05 May 2022
- Updated FIFOs so they are Search => PRIVATE.  Was only problematic in generate loops.

## 2022.04 April 2022
- AxiMemory(Vti) - Updated Burst Reads s.t. there is one clock (was one delta) between data accesses.
- Fixes AXI Read Burst starting when Write Burst to same location has started but not completed.

## 2022.03 March 2022
- Axi4Lite - Rebaselined against Axi4 FULL - now works with GHDL.
- All - Updated calls to NewID for AlertLogID and FIFOs.
- AxiStream - SendBurst without TLast - SendBurst(XXX, "0"). Suitable for sending packets with TestCtrl idles.
- AxiStream - Update TxSTrb and TxKeep at start and end. 

## 2022.02 February 2022
- Axi4LiteMaster - Added SET_MODEL_OPTIONS
- Axi4Options - SetAxi4LiteInterfaceDefault, GetAxi4LiteInterfaceDefault supports Axi4LiteMaster
- to_hxstring - Axi4Manager, Vti, Axi4Memory, Vti, Axi4Subordinate, Vti, AxiStreamReceiver, Vti, AxiStreamTransmitter, Vti
- Axi4Memory, Vti - Added Search => NAME
- AxiStreamOptionsPkg - RECEIVE_READY_WAIT_FOR_GET
- AxiStreamReceiver, Vti - WaitForGet, don't send TReady until have a Get transaction

## 2022.01 January 2022
- Added Test Cases to support testing of AddressBus and Stream MIT burst patterns
- Moved MODEL_INSTANCE_NAME in Axi4+ and AxiStream+ to entity declaration region
- Added check to Axi4Stream+ in CheckBurst for BurstLen vs Expected BurstLen
- AxiStreamReceiver+ added GotBurst transaction

## 2021.09 September 2021
- Minor bug fix to Axi4Subordinate.  
- Updates to testbenches to support writing YAML files.
- Minor updates to support compilation in Cadence Xcelium.

## 2021.08 August 2021
- Updated AXI4 naming to Axi4Manager and Axi4Subordinate to match ARM updated naming

## 2021.06 June 2021
- Updated Axi4Master, AxiStreamTransmitter, AxiStreamReceiver for new Burst data structures
- Updated Axi4Memory for new Memory data structures
- Updated all for GHDL support.

## 2021.03 March 2021
- Minor script update for case sensitivity on Linux

## 2020.12 December 2020
- Added Word Based Bursting to Axi4Master. 
- Added Virtual Transaction Interfaces (VTI) to Axi4 (full) verification components.
- Added VTI to AxiStream verification components.
- Not Done:  Axi4Lite and UART VTI and Bursting.

## 2020.10 October 2020
### AxiStream
Added Byte and Word based bursting to AxiStream.
Supports bursting User field with Data.

## 2020.07 July 2020

### AXI4 Common
Updated to support OSVVM Model Independent Transactions for AddressBusses.
See OSVVM-Common repository, file Common/src/AddressBusTransactionPkg.vhd

### AXI4
First public release.

### Axi4Lite
Name Responder replaced Slave in all naming.
Hence, Axi4LiteResponder_Transactor.vhd replaced Axi4LiteSlave_Transactor.vhd.

Port names, Axi4Bus replaced Axi4LiteBus.
This is needed for compatibility with Axi4 full models.

In record structure in Axi4LiteInterface package,
the redundant abbreviations AW, W, B, AR, R were 
removed.   A long version of the name that is more 
understandable is in the next layer of the record
structure.   This impacts connecting the Axi4Lite
interface to your designs.   

The packages Axi4LiteMasterTransactionPkg.vhd and
Axi4LiteMasterTransactionPkg.vhd have been replaced
by OSVVM-Common:   Common/src/AddressBusTransactionpkg.

### AxiStream
Updated to use OSVVM Model Independent Transactions for Streaming.
See OSVVM-Common  Common/src/StreamTransactionPkg.vhd
 
## Copyright and License
Copyright (C) 2006-2020 by [SynthWorks Design Inc.](http://www.synthworks.com/)   
Copyright (C) 2020 by [OSVVM contributors](CONTRIBUTOR.md)   

This file is part of OSVVM.

    Licensed under Apache License, Version 2.0 (the "License")
    You may not use this file except in compliance with the License.
    You may obtain a copy of the License at

  [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
