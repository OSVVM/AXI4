# AXI4
AXI4 Verification IP (AXI4, AXI4-Lite, AXI4-Stream)

Models

**Axi4LiteMaster.vhd**

  AXI-Lite 4 Master Models
  Current action list
  - Add Byte Enables
  - Add variations to Ready signaling - independent vs dependent on Valid
  - non-blocking MasterWrite and MasterRead operations
  
**Axi4LiteSlave_Transactor.vhd**

  Interacts with the master model via transactions in the testbench

**Axi4LiteMonitor_dummy.vhd**

Currently a place holder for an AXI-Lite 4 Monitor

## Release History
Date        Revision    Comments
- Apr-2018 - **2018.04**   Initial public release    