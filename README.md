# AXI4 Verification Component Library
The AXI Verification Component Library implements
verification components for:  
  - [AXI4](https://github.com/osvvm/AXI4#readme)
    - Manager with bursting
    - Memory Subordinate with bursting
    - Transaction Subordinate - no bursting
  - [AXI4 Lite](https://github.com/osvvm/AXI4#readme)
    - Manager
    - Memory Subordinate
    - Transaction Subordinate 
  - [AXI Stream](https://github.com/osvvm/AXI4#readme)
    - Transmitter
    - Receiver


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
         
## Release History
For the release history see, [CHANGELOG.md](CHANGELOG.md)

## Learning OSVVM
You can find an overview of OSVVM at [osvvm.github.io](https://osvvm.github.io).
Alternately you can find our pdf documentation at 
[OSVVM Documentation Repository](https://github.com/OSVVM/Documentation#readme).

You can also learn OSVVM by taking the class, [Advanced VHDL Verification and Testbenches - OSVVM&trade; BootCamp](https://synthworks.com/vhdl_testbench_verification.htm)

## Download OSVVM Libraries
OSVVM is available as either a git repository 
[OsvvmLibraries](https://github.com/osvvm/OsvvmLibraries) 
or zip file from [osvvm.org Downloads Page](https://osvvm.org/downloads).

On GitHub, all OSVVM libraries are a submodule of the repository OsvvmLibraries. Download all OSVVM libraries using git clone with the “–recursive” flag: 
```    
  $ git clone --recursive https://github.com/osvvm/OsvvmLibraries
```
        
## Run The Demos
A great way to get oriented with OSVVM is to run the demos.
For directions on running the demos, see [OSVVM Scripts](https://github.com/osvvm/OSVVM-Scripts#readme).

## Participating and Project Organization 
The OSVVM project welcomes your participation with either 
issue reports or pull requests.

You can find the project [Authors here](AUTHORS.md) and
[Contributors here](CONTRIBUTORS.md).

### AXI4/common/src
Contains packages shared by Axi4, Axi4Lite, and AxiStream.
   * Axi4LiteInterfacePkg.vhd
      * Defines Axi4Lite Interface record
   * Axi4InterfacePkg.vhd
      * Defines Axi4 Full Interface record
   * Axi4InterfaceCommonPkg.vhd
      * Defines RESP and PROT values for Axi4 Full and Lite
   * Axi4CommonPkg.vhd
      * Used by Axi4, Axi4Lite, and AxiStream
      * Defines procedures to handle ready and valid signaling 
   * Axi4ModelPkg.vhd
      * Used by Axi4 and Axi4Lite
      * Defines handling for Axi4 Bus interface
   * Axi4OptionsPkg.vhd
      * Used by Axi4 and Axi4Lite
      * Transaction extensions for AXI4 bus interface
      * Used in conjunction with AddressBusTransactionpkg 
   * Axi4VersionCompatibilityPkg.vhd
      * Used by testbenches that used earlier versions of Axi4 and Axi4Lite verification components
      * Used to minimize changes made to the AXI4

For current compile order see AXI4/common/common.pro.

### AXI4/Axi4/src
AXI4 Full verification components.
Uses OSVVM Model Independent Transactions for Address Busses.
See OSVVM-Common repository, files
Common/src/AddressBusTransactionpkg.vhd and 
Common/src/AddressBusResponderTransactionPkg.vhd

   * Packages with component declarations for verification components
      * Axi4ComponentPkg.vhd - All AXI4 CTI Components
      * Axi4ComponentVtiPkg.vhd - All AXI4 VTI Components
   * Axi4Context.vhd
      * References all packages required to use the AXI4 verification components
   * Axi4Manager.vhd and Axi4ManagerVti.vhd
      * AXI4 Manager verification component with bursting
   * Axi4Monitor_dummy.vhd
   * Axi4Subordinate.vhd and Axi4SubordinateVti.vhd
      * AXI4 Subordinate verification component
      * Currently does not support bursting
   * Axi4Memory.vhd and Axi4MemoryVti.vhd
      * AXI4 Memory Subordinate verification component with bursting

For current compile order see AXI4/Axi4/Axi4.pro.

### AXI4/Axi4Lite/src 
AXI4 Lite verification components.
Uses OSVVM Model Independent Transactions for AddressBusses.
See OSVVM-Common repository, files Common/src/AddressBusTransactionpkg.vhd and 
Common/src/AddressBusResponderTransactionPkg.vhd

   * Axi4LiteComponentPkg.vhd 
      * Packages with component declarations for verification components
   * Axi4LiteContext.vhd
      * References all packages required to use the AXI4Lite verification components
   * Axi4LiteManager.vhd
      * AXI4 Manager verification component
   * Axi4LiteMonitor_dummy.vhd
   * Axi4LiteSubordinate.vhd
      * AXI4 Subordinate verification component
   * Axi4LiteMemory.vhd
      * AXI4 Memory verification component

For current compile order see AXI4/Axi4Lite/Axi4Lite.pro.

### AXI4/AxiStream/src 
AxiStream Transmitter and Receiver verification components. 
Uses OSVVM Model Independent Transactions for Streaming.
See OSVVM-Common repository, file Common/src/StreamTransactionPkg.vhd

   * AxiStreamOptionsPkg.vhd
      * Transaction extensions for AxiStream interface
      * Used in conjunction with StreamTransactionpkg 
   * AxiStreamTransmitter.vhd and AxiStreamTransmitterVti.vhd
      * AXI4 Transmitter verification component
   * AxiStreamReceiver.vhd and AxiStreamReceiverVti.vhd
      * AXI4 Receiver verification component
   * AxiStreamComponentPkg.vhd
      * Packages with component declarations for verification components
   * AxiStreamContext.vhd
      * References all packages required to use the AxiStream verification components

For current compile order see AXI4/AxiStream/AxiStream.pro.

## More Information on OSVVM

**OSVVM Forums and Blog:**     [http://www.osvvm.org/](http://www.osvvm.org/)   
**Gitter:** [https://gitter.im/OSVVM/Lobby](https://gitter.im/OSVVM/Lobby)  
**Documentation:** [osvvm.github.io](https://osvvm.github.io)    
**Documentation:** [PDF Documentation](https://github.com/OSVVM/Documentation)  

## Copyright and License
Copyright (C) 2006-2022 by [SynthWorks Design Inc.](http://www.synthworks.com/)  
Copyright (C) 2022 by [OSVVM Authors](AUTHORS.md)   

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
