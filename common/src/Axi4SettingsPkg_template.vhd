--
--  File Name:         Axi4SettingsPkg_default.vhd
--  Design Unit Name:  Axi4SettingsPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email        :  jim@synthworks.com
--
--  Description:
--     AXI4 Settings are used for AXI4 Full and Lite
--     Establishes default values that can be overridden in either
--        OsvvmSettingsDirectory/Axi4Settings
--
--  Developed for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  TigardOr  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Version    Description
--    2026.08    Initial
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2026 by SynthWorks Design Inc.
--
--  Licensed under the Apache LicenseVersion 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      https://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writingsoftware
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KINDeither express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
--

library osvvm ;
context osvvm.OsvvmContext ;

library osvvm_common ;
context osvvm_common.OsvvmCommonContext ; -- Address Bus Transactions

library ieee ;
use ieee.std_logic_1164.all ;

use work.Axi4InterfaceCommonPkg.all ;

package body Axi4SettingsPkg is

  constant AXI4_DEFAULT_tperiod_Clk                               : time   := ${AXI4_DEFAULT_tperiod_Clk} ;
  constant AXI4_DEFAULT_DELAY                                     : time   := ${AXI4_DEFAULT_DELAY} ;

  -- AXI Interface Settings
  constant AXI4_DEFAULT_FIFO_BURST_MODE                           : AddressBusFifoBurstModeType := ${AXI4_DEFAULT_FIFO_BURST_MODE} ;
  constant AXI4_DEFAULT_AWBURST                                   : std_logic_vector := ${AXI4_DEFAULT_AWBURST} ;
  constant AXI4_DEFAULT_BRESP                                     : std_logic_vector := ${AXI4_DEFAULT_BRESP} ;
  constant AXI4_DEFAULT_ARBURST                                   : std_logic_vector := ${AXI4_DEFAULT_ARBURST} ;
  constant AXI4_DEFAULT_RRESP                                     : std_logic_vector := ${AXI4_DEFAULT_RRESP} ;

  constant AXI4_DEFAULT_CHECK_BID                                : boolean := ${AXI4_DEFAULT_CHECK_BID} ;
  constant AXI4_DEFAULT_CHECK_RID                                : boolean := ${AXI4_DEFAULT_CHECK_RID} ;

  -- AXI4 Model Options
  -- Ready timeout
  constant AXI4_DEFAULT_WRITE_ADDRESS_READY_TIME_OUT              : integer := ${AXI4_DEFAULT_WRITE_ADDRESS_READY_TIME_OUT} ;
  constant AXI4_DEFAULT_WRITE_DATA_READY_TIME_OUT                 : integer := ${AXI4_DEFAULT_WRITE_DATA_READY_TIME_OUT} ;
  constant AXI4_DEFAULT_WRITE_RESPONSE_READY_TIME_OUT             : integer := ${AXI4_DEFAULT_WRITE_RESPONSE_READY_TIME_OUT} ; -- S
  constant AXI4_DEFAULT_READ_ADDRESS_READY_TIME_OUT               : integer := ${AXI4_DEFAULT_READ_ADDRESS_READY_TIME_OUT} ;
  constant AXI4_DEFAULT_READ_DATA_READY_TIME_OUT                  : integer := ${AXI4_DEFAULT_READ_DATA_READY_TIME_OUT} ; -- S

  -- Ready Controls
  constant AXI4_DEFAULT_WRITE_ADDRESS_READY_BEFORE_VALID          : boolean := ${AXI4_DEFAULT_WRITE_ADDRESS_READY_BEFORE_VALID} ; -- S
  constant AXI4_DEFAULT_WRITE_DATA_READY_BEFORE_VALID             : boolean := ${AXI4_DEFAULT_WRITE_DATA_READY_BEFORE_VALID} ; -- S
  constant AXI4_DEFAULT_WRITE_RESPONSE_READY_BEFORE_VALID         : boolean := ${AXI4_DEFAULT_WRITE_RESPONSE_READY_BEFORE_VALID} ;
  constant AXI4_DEFAULT_READ_ADDRESS_READY_BEFORE_VALID           : boolean := ${AXI4_DEFAULT_READ_ADDRESS_READY_BEFORE_VALID} ; -- S
  constant AXI4_DEFAULT_READ_DATA_READY_BEFORE_VALID              : boolean := ${AXI4_DEFAULT_READ_DATA_READY_BEFORE_VALID} ;

  -- Ready Delay
  constant AXI4_DEFAULT_WRITE_ADDRESS_READY_DELAY_CYCLES          : integer := ${AXI4_DEFAULT_WRITE_ADDRESS_READY_DELAY_CYCLES} ;  -- S
  constant AXI4_DEFAULT_WRITE_DATA_READY_DELAY_CYCLES             : integer := ${AXI4_DEFAULT_WRITE_DATA_READY_DELAY_CYCLES} ;  -- S
  constant AXI4_DEFAULT_WRITE_RESPONSE_READY_DELAY_CYCLES         : integer := ${AXI4_DEFAULT_WRITE_RESPONSE_READY_DELAY_CYCLES} ;
  constant AXI4_DEFAULT_READ_ADDRESS_READY_DELAY_CYCLES           : integer := ${AXI4_DEFAULT_READ_ADDRESS_READY_DELAY_CYCLES} ;  -- S
  constant AXI4_DEFAULT_READ_DATA_READY_DELAY_CYCLES              : integer := ${AXI4_DEFAULT_READ_DATA_READY_DELAY_CYCLES} ;

  -- Valid Timeouts
  constant AXI4_DEFAULT_WRITE_RESPONSE_VALID_TIME_OUT             : integer := ${AXI4_DEFAULT_WRITE_RESPONSE_VALID_TIME_OUT} ;
  constant AXI4_DEFAULT_READ_DATA_VALID_TIME_OUT                  : integer := ${AXI4_DEFAULT_READ_DATA_VALID_TIME_OUT} ;

  -- Valid Delays
  constant AXI4_DEFAULT_WRITE_ADDRESS_VALID_DELAY_CYCLES          : integer := ${AXI4_DEFAULT_WRITE_ADDRESS_VALID_DELAY_CYCLES} ;
  constant AXI4_DEFAULT_WRITE_DATA_VALID_DELAY_CYCLES             : integer := ${AXI4_DEFAULT_WRITE_DATA_VALID_DELAY_CYCLES} ;
  constant AXI4_DEFAULT_WRITE_DATA_VALID_BURST_DELAY_CYCLES       : integer := ${AXI4_DEFAULT_WRITE_DATA_VALID_BURST_DELAY_CYCLES} ;
  constant AXI4_DEFAULT_WRITE_RESPONSE_VALID_DELAY_CYCLES         : integer := ${AXI4_DEFAULT_WRITE_RESPONSE_VALID_DELAY_CYCLES} ;  -- S
  constant AXI4_DEFAULT_READ_ADDRESS_VALID_DELAY_CYCLES           : integer := ${AXI4_DEFAULT_READ_ADDRESS_VALID_DELAY_CYCLES} ;
  constant AXI4_DEFAULT_READ_DATA_VALID_DELAY_CYCLES              : integer := ${AXI4_DEFAULT_READ_DATA_VALID_DELAY_CYCLES} ;  -- S
  constant AXI4_DEFAULT_READ_DATA_VALID_BURST_DELAY_CYCLES        : integer := ${AXI4_DEFAULT_READ_DATA_VALID_BURST_DELAY_CYCLES} ;  -- S

  -- Write Data Filtering - Subordinate Only
  constant AXI4_DEFAULT_WRITE_DATA_FILTER_UNDRIVEN                : boolean := ${AXI4_DEFAULT_WRITE_DATA_FILTER_UNDRIVEN} ;
  constant AXI4_DEFAULT_WRITE_DATA_UNDRIVEN_VALUE                 : std_logic := ${AXI4_DEFAULT_WRITE_DATA_UNDRIVEN_VALUE} ;

end package body Axi4SettingsPkg ;
