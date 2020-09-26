# AXI4 Verification Component Library
The AXI Verification Component Library implements
verification components for:  
 - [AXI4](https://github.com/osvvm/AXI4)
   - Master with bursting
   - Memory Slave with bursting
 - [AXI4 Lite](https://github.com/osvvm/AXI4)
   - Master
   - Transaction Slave 
 - [AXI Stream](https://github.com/osvvm/AXI4)
   - Transmitter
   - Receiver

  [Documentation for the OSVVM Verification Component libraries can be found here](https://github.com/OSVVM/Documentation)

## Testbenches are Included 

Testbenches are in the Git repository, so you can 
run a simulation and see a live example 
of how to use the models.

## AXI Project Structure
   * AXI4
      * Common
         * src
      * Axi4
         * src
         * testbench
      * Axi4Lite
         * src
         * testbench
      * AxiStream
         * src
         * testbench
         
### Building Depencencies
Before building this project, you must build the following libraries in order
   * [OSVVM utility library](https://github.com/osvvm/osvvm) 
   * [OSVVM Common Library](https://github.com/osvvm/OSVVM-Common)   

See the [OSVVM Verification Script Library](https://github.com/osvvm/OSVVM-Scripts) 
for a simple way to build the OSVVM libraries.

### AXI4/common/src
Contains packages shared by Axi4, Axi4Lite, and AxiStream.
   * Axi4LiteInterfacePkg.vhd
      * Defines Axi4Lite Interface record
   * Axi4InterfacePkg.vhd
      * Defines Axi4 Full Interface record
   * Axi4CommonPkg.vhd
      * Used by Axi4, Axi4Lite, and AxiStream
      * Defines procedures to handle ready and valid signaling 
   * Axi4ModelPkg.vhd
      * Used by Axi4 and Axi4Lite
      * Defines handling for Axi4 Bus interface
   * Axi4OptionsTypePkg.vhd
      * Used by Axi4 and Axi4Lite
      * Transaction extensions for AXI4 bus interface
      * Used in conjunction with AddressBusTransactionpkg 
   * Axi4VersionCompatibilityPkg.vhd
      * Used by testbenches that used earlier versions of Axi4 and Axi4Lite verification components
      * Used to minimize changes made to the AXI4

For current compile order see AXI4/common/common.pro.

### AXI4/Axi4/src
AXI4 Full verification components.
Uses OSVVM Model Independent Transactions for AddressBusses.
See OSVVM-Common repository, files
Common/src/AddressBusTransactionpkg.vhd and 
Common/src/AddressBusResponderTransactionPkg.vhd

   * Packages with component declarations for verification components
      * Axi4MasterComponentPkg.vhd
      * Axi4ResponderComponentPkg.vhd
      * Axi4MemoryComponentPkg.vhd
      * Axi4MonitorComponentPkg.vhd
   * Axi4Context.vhd
      * References all packages required to use the AXI4 verification components
   * Axi4Master.vhd
      * AXI4 Master verification component with bursting
   * Axi4Monitor_dummy.vhd
   * Axi4Responder_Transactor.vhd
      * AXI4 Responder verification component
     * Currently does not support bursting
   * Axi4Memory.vhd
      * AXI4 Memory verification component with bursting

For current compile order see AXI4/Axi4/Axi4.pro.

### AXI4/Axi4Lite/src 
AXI4 Lite verification components.
For current compile order see AXI4/Axi4/Axi4.pro.
Note that the long term plan is that the AXI4 Full models
will be able to run in an Axi4Lite mode.   

Uses OSVVM Model Independent Transactions for AddressBusses.
See OSVVM-Common repository, files Common/src/AddressBusTransactionpkg.vhd and 
Common/src/AddressBusResponderTransactionPkg.vhd

   * Packages with component declarations for verification components
      * Axi4LiteMasterComponentPkg.vhd
      * Axi4LiteResponderComponentPkg.vhd
      * Axi4LiteMemoryComponentPkg.vhd
      * Axi4LiteMonitorComponentPkg.vhd
   * Axi4LiteContext.vhd
      * References all packages required to use the AXI4Lite verification components
   * Axi4LiteMaster.vhd
      * AXI4 Master verification component
   * Axi4LiteMonitor_dummy.vhd
   * Axi4LiteResponder_Transactor.vhd
      * AXI4 Responder verification component
   * Axi4LiteMemory.vhd
      * AXI4 Memory verification component

### AXI4/AxiStream/src 
AxiStream Transmitter and Receiver verification components. 
Uses OSVVM Model Independent Transactions for Streaming,
See OSVVM-Common repository, file Common/src/StreamTransactionPkg.vhd

   * AxiStreamOptionsTypePkg.vhd
      * Transaction extensions for AxiStream interface
      * Used in conjunction with StreamTransactionpkg 
   * AxiStreamTransmitter.vhd
      * AXI4 Transmitter verification component
   * AxiStreamReceiver.vhd
      * AXI4 Receiver verification component
   * AxiStreamComponentPkg.vhd
      * Packages with component declarations for verification components
   * AxiStreamContext.vhd
      * References all packages required to use the AxiStream verification components

For current compile order see AXI4/AxiStream/AxiStream.pro.

## Release History
For the release history see, [CHANGELOG.md](CHANGELOG.md)

## Downloading the libraries

The library [OSVVM-Libraries](https://github.com/osvvm/OsvvmLibraries) 
contains all of the OSVVM libraries as submodules.
Download the entire OSVVM model library using git clone with the "--recursive" flag:  
        `$ git clone --recursive https://github.com/osvvm/OsvvmLibraries`

## Participating and Project Organization 

The OSVVM project welcomes your participation with either 
issue reports or pull requests.
For details on [how to participate see](https://opensource.ieee.org/osvvm/OsvvmLibraries/-/blob/master/CONTRIBUTING.md)

You can find the project [Authors here](AUTHORS.md) and
[Contributors here](CONTRIBUTORS.md).

## More Information on OSVVM

**OSVVM Forums and Blog:**     [http://www.osvvm.org/](http://www.osvvm.org/)   
**SynthWorks OSVVM Blog:** [http://www.synthworks.com/blog/osvvm/](http://www.synthworks.com/blog/osvvm/)    
**Gitter:** [https://gitter.im/OSVVM/Lobby](https://gitter.im/OSVVM/Lobby)  
**Documentation:** [Documentation for the OSVVM libraries can be found here](https://github.com/OSVVM/Documentation)

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
