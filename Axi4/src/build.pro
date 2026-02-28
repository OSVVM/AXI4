#  File Name:         Axi4.pro
#  Revision:          STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      jim@synthworks.com
#
#
#  Description:
#        Script to compile the Axi4 models  
#
#  Developed for:
#        SynthWorks Design Inc.
#        VHDL Training Classes
#        11898 SW 128th Ave.  Tigard, Or  97223
#        http://www.SynthWorks.com
#
#  Revision History:
#    Date      Version    Description
#    10/2025   2025.10    Added Axi4InterfaceModeViewPkg
#     1/2020   2020.01    Updated Licenses to Apache
#     1/2019   2019.01    Compile Script for OSVVM
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2019 - 2025 by SynthWorks Design Inc.  
#  
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#  
#      https://www.apache.org/licenses/LICENSE-2.0
#  
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
library osvvm_axi4

# build packages 
analyze Axi4InterfacePkg.vhd
if {$::osvvm::VhdlVersion >= 2019 && $::osvvm::Supports2019Interface}  {
  analyze Axi4InterfaceModeViewPkg.vhd
  analyze Axi4ComponentPkg.vhd
  analyze Vti/Axi4ComponentVtiPkg.vhd
} else {
  analyze deprecated/Axi4InterfaceModeViewPkg.vhd  ;# Empty package
  analyze deprecated/Axi4ComponentPkg.vhd  
  analyze Vti/deprecated/Axi4ComponentVtiPkg.vhd
}

# build context 
analyze Axi4Context.vhd

# Create derivative architectures for verification components if architecture is updated
if {$::osvvm::OsvvmDevDeriveArchitectures} {
  if {[FileModified Axi4Manager_a.vhd] > [FileModified deprecated/Axi4Manager_a.vhd]} {
    ::osvvm::MakeArch Axi4Manager
  }
  if {[FileModified Axi4Memory_a.vhd] > [FileModified deprecated/Axi4Memory_a.vhd]} {
    ::osvvm::MakeArch Axi4Memory
  }
  if {[FileModified Axi4Subordinate_a.vhd] > [FileModified deprecated/Axi4Subordinate_a.vhd]} {
    ::osvvm::MakeArch Axi4Subordinate
  }
}

# build Verification Components
if {$::osvvm::VhdlVersion >= 2019 && $::osvvm::Supports2019Interface}  {
  analyze Axi4Manager_e.vhd
  analyze Axi4Manager_a.vhd
  analyze Axi4Memory_e.vhd
  analyze Axi4Memory_a.vhd
  analyze Axi4Subordinate_e.vhd
  analyze Axi4Subordinate_a.vhd
  
  # for XSIM, VTI not supported in 2024.2 - they analyze OK though
  analyze Vti/Axi4ManagerVti_e.vhd
  analyze Vti/Axi4ManagerVti_a.vhd
  analyze Vti/Axi4MemoryVti_e.vhd
  analyze Vti/Axi4MemoryVti_a.vhd
  analyze Vti/Axi4SubordinateVti_e.vhd
  analyze Vti/Axi4SubordinateVti_a.vhd

} else {
  analyze deprecated/Axi4Manager_e.vhd  
  analyze deprecated/Axi4Manager_a.vhd  
  analyze deprecated/Axi4Memory_e.vhd
  analyze deprecated/Axi4Memory_a.vhd
  analyze deprecated/Axi4Subordinate_e.vhd
  analyze deprecated/Axi4Subordinate_a.vhd

  # for XSIM, VTI not supported in 2024.2 - they analyze OK though
  analyze Vti/deprecated/Axi4ManagerVti_e.vhd
  analyze Vti/deprecated/Axi4ManagerVti_a.vhd
  analyze Vti/deprecated/Axi4MemoryVti_e.vhd
  analyze Vti/deprecated/Axi4MemoryVti_a.vhd
  analyze Vti/deprecated/Axi4SubordinateVti_e.vhd
  analyze Vti/deprecated/Axi4SubordinateVti_a.vhd
}

analyze Axi4Monitor_dummy.vhd
analyze Axi4PassThru.vhd
analyze Axi4GenericSignalsPkg.vhd
