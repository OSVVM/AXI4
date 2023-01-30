--
--  File Name:         Axi4LitePassThru.vhd
--  Design Unit Name:  Axi4LitePassThru
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--     DUT pass thru for Axi4 VC testing 
--     Used to demonstrate DUT connections
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    01/2023   2023.01    Initial
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2023 by SynthWorks Design Inc.
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

  use work.Axi4InterfaceCommonPkg.all ;
  use work.Axi4InterfacePkg.all ;

entity Axi4LitePassThru is
  port (
  -- AXI Manager Interface 
    -- AXI Write Address Channel
    mAwAddr       : out   std_logic_vector ; 
    mAwProt       : out   Axi4ProtType ;
    mAwValid      : out   std_logic ; 
    mAwReady      : in    std_logic ; 

    -- AXI Write Data Channel
    mWData        : out   std_logic_vector ; 
    mWStrb        : out   std_logic_vector ; 
    mWValid       : out   std_logic ; 
    mWReady       : in    std_logic ; 

    -- AXI Write Response Channel
    mBValid       : in    std_logic ; 
    mBReady       : out   std_logic ; 
    mBResp        : in    Axi4RespType ; 
  
    -- AXI Read Address Channel
    mArAddr       : out   std_logic_vector ; 
    mArProt       : out   Axi4ProtType ;
    mArValid      : out   std_logic ; 
    mArReady      : in    std_logic ; 

    -- AXI Read Data Channel
    mRData        : in    std_logic_vector ; 
    mRResp        : in    Axi4RespType ;
    mRValid       : in    std_logic ; 
    mRReady       : out   std_logic ; 


  -- AXI Subordinate Interface 
    -- AXI Write Address Channel
    sAwAddr       : in    std_logic_vector ; 
    sAwProt       : in    Axi4ProtType ;
    sAwValid      : in    std_logic ; 
    sAwReady      : out   std_logic ; 

    -- AXI Write Data Channel
    sWData        : in    std_logic_vector ; 
    sWStrb        : in    std_logic_vector ; 
    sWValid       : in    std_logic ; 
    sWReady       : out   std_logic ; 

    -- AXI Write Response Channel
    sBValid       : out   std_logic ; 
    sBReady       : in    std_logic ; 
    sBResp        : out   Axi4RespType ; 
  
  
    -- AXI Read Address Channel
    sArAddr       : in    std_logic_vector ; 
    sArProt       : in    Axi4ProtType ;
    sArValid      : in    std_logic ; 
    sArReady      : out   std_logic ; 

    -- AXI Read Data Channel
    sRData        : out   std_logic_vector ; 
    sRResp        : out   Axi4RespType ;
    sRValid       : out   std_logic ; 
    sRReady       : in    std_logic  
  ) ;
end entity Axi4LitePassThru ;

architecture FeedThru of Axi4LitePassThru is


begin

    -- AXI Write Address Channel
    mAwAddr       <= sAwAddr   ;
    mAwProt       <= sAwProt   ;
    mAwValid      <= sAwValid  ;
    sAwReady      <= mAwReady  ;

    -- AXI Write Data Channel
    mWData        <= sWData  ;
    mWStrb        <= sWStrb  ;
    mWValid       <= sWValid ;
    sWReady       <= mWReady ;

    -- AXI Write Response Channel
    sBValid       <= mBValid ;
    mBReady       <= sBReady ;
    sBResp        <= mBResp  ;
  
    -- AXI Read Address Channel
    mArAddr       <= sArAddr   ;
    mArProt       <= sArProt   ;
    mArValid      <= sArValid  ;
    sArReady      <= mArReady  ;

    -- AXI Read Data Channel
    sRData        <= mRData  ; 
    sRResp        <= mRResp  ;
    sRValid       <= mRValid ;
    mRReady       <= sRReady ;

end architecture FeedThru ;
