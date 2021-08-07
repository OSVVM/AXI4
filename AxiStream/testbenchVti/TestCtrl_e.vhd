--
--  File Name:         TestCtrl_e.vhd
--  Design Unit Name:  TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Test transaction source
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    05/2018   2018.05    Initial revision
--    01/2020   2020.01    Updated license notice
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2018 - 2020 by SynthWorks Design Inc.  
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
  
library OSVVM ; 
  context OSVVM.OsvvmContext ; 
  use osvvm.ScoreboardPkg_slv.all ;

library osvvm_AXI4 ;
    context osvvm_AXI4.AxiStreamContext ;

entity TestCtrl is
  generic ( 
    ID_LEN       : integer ;
    DEST_LEN     : integer ;
    USER_LEN     : integer 
  ) ;
  port (
      -- Global Signal Interface
      nReset             : In    std_logic 
  ) ;
  -- Connect transaction interfaces using external names
  alias StreamTxRec is <<signal ^.Transmitter_1.TransRec : StreamRecType>> ;
  alias StreamRxRec is <<signal ^.Receiver_1.TransRec    : StreamRecType>> ;
  
  -- Derive AXI interface properties from the StreamTxRec
  constant DATA_WIDTH : integer := StreamTxRec.DataToModel'length ; 
  constant DATA_BYTES : integer := DATA_WIDTH/8 ; 
  
  -- Simplifying access to Burst FIFOs using aliases
  alias TxBurstFifo : ScoreboardIdType is StreamTxRec.BurstFifo ; 
  alias RxBurstFifo : ScoreboardIdType is StreamRxRec.BurstFifo ;
  
end entity TestCtrl ;
