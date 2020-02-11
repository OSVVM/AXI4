# AXI4
AXI4 Verification IP (AXI4, AXI4-Lite, AXI4-Stream)

Models

**Axi4LiteMaster.vhd**

  AXI-Lite 4 Master Model
  
  **Note this model depends on library osvvm_common**
  
**Axi4LiteSlave_Transactor.vhd**

  Interacts with the master model via transactions in the testbench

**Axi4LiteMonitor_dummy.vhd**

Currently a place holder for an AXI-Lite 4 Monitor

## Release History
Date        Revision    Comments
- Feb-2020 - **2020.02**   Refactored master transaction package s.t. 
                           it now uses common package from osvvm_common    
- Apr-2018 - **2018.04**   Initial public release    