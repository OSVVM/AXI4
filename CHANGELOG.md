# AXI4 Verification Component Change Log

| Revision  | Revision Date |  Release Summary | 
------------|---------------|----------- 
| 2021.06   | June 2021     |  Updated Axi4Master[Vti], AxiStreamXX[Vti], Axi4Memory[Vti]
|           |               |  for new Burst Fifo and Memory data structures
| 2021.03   | March 2021    |  Minor updates to scripts for case sensitivity on Linux
| 2021.02   | February 2021 |  Added TRANSMIT_VALID_DELAY_CYCLES to AxiStreamTransmitter
| 2020.12   | December 2020 |  More Bursting and Virtual Transaction Interfaces.
| 2020.10   | October 2020  |  Added Bursting to AxiStream. 
| 2020.07   | July 2020     |  Major:  Axi4Lite, Axi4(Full) w/ Bursting, AddressBusTransactionPkg, Responder
| 2020.02   | February 2020 |  Initial version of AddressBusTransactionPkg.
| 2018.04   | April 2018    |  Initial public release


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
