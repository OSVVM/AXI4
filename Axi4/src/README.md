# README.md for AXI4/src
This directory contains the sources for the VHDL-2019 AXI4 Full implementation.
If you need to update the behavior of any version (VHDL-2019 or Vti), 
only edit the architectures in this directory.  Architectures for Vti
and VHDL-2009 are generated from these. Note that "_e" indicates the 
file is contains the entity and "_a" indicates the file contains the 
architecture.

Axi4Manager_e.vhd
Axi4Manager_a.vhd
Axi4Subordinate_e.vhd    
Axi4Subordinate_a.vhd
Axi4Memory_e.vhd 
Axi4Memory_a.vhd 

To generate the other architectures, add the following to your OsvvmSettingsLocal.tcl.
For more on the OsvvmSettingsLocal.tcl file, see Documentation/OsvvmSettings_user_guide.pdf
    variable OsvvmDevDeriveArchitectures "true" in OsvvmSettingsLocal.tcl