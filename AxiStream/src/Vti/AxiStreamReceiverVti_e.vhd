--
--  File Name:         AxiStreamReceiverVti_e.vhd
--  Design Unit Name:  AxiStreamReceiverVti
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      AXI Stream Master Model
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    07/2024   2024.07    Added OsvvmVcInit barrier before starting to receive.
--    03/2024   2024.03    Updated SafeResize to use ModelID
--    05/2023   2023.05    Updated methods for Randomized delays
--    04/2023   2023.04    Update delays on TReady to be randomized
--    10/2022   2022.10    Changed enum value PRIVATE to PRIVATE_NAME due to VHDL-2019 keyword conflict.
--    05/2022   2022.05    Updated FIFOs so they are Search => PRIVATE
--    03/2022   2022.03    Updated calls to NewID for AlertLogID and FIFOs
--    02/2022   2022.02    WaitForGet, don't send TReady until have a Get transaction
--                         Replaced to_hstring to to_hxstring
--    01/2022   2022.01    Moved MODEL_INSTANCE_NAME and MODEL_NAME to entity declarative region
--                         Added GotBurst transaction Y check for BurstLen vs Expected BurstLen in CheckBurst
--    07/2021   2021.07    All FIFOs and Scoreboards now use the New Scoreboard/FIFO capability
--    06/2021   2021.06    Updated Burst FIFOs.
--    02/2021   2021.02    Added MultiDriver Detect.  Updated Generics.
--    12/2020   2020.12    Created Virtual Transaction Interface from AxiStreamReceiver.vhd
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2018 - 2024 by SynthWorks Design Inc.
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
  use osvvm.ScoreboardPkg_slv.all ;

library osvvm_common ;
  context osvvm_common.OsvvmCommonContext ;

  use work.AxiStreamOptionsPkg.all ;
  use work.Axi4CommonPkg.all ;
  use work.AxiStreamTbPkg.all ;

entity AxiStreamReceiverVti is
  generic (
    MODEL_ID_NAME  : string :="" ;
    INIT_ID        : std_logic_vector := "" ;
    INIT_DEST      : std_logic_vector := "" ;
    INIT_USER      : std_logic_vector := "" ;
    INIT_LAST      : natural := 0 ;
    tperiod_Clk    : time := 10 ns ;

    DEFAULT_DELAY  : time := maximum(tperiod_Clk/10, std.env.resolution_limit) ;

    tpd_Clk_TReady : time := DEFAULT_DELAY
  ) ;
  port (
    -- Globals
    Clk       : in  std_logic ;
    nReset    : in  std_logic ;

    -- AXI Master Functional Interface
    TValid    : in  std_logic ;
    TReady    : out std_logic ;
    TID       : in  std_logic_vector ;
    TDest     : in  std_logic_vector ;
    TUser     : in  std_logic_vector ;
    TData     : in  std_logic_vector ;
    TStrb     : in  std_logic_vector ;
    TKeep     : in  std_logic_vector ;
    TLast     : in  std_logic
  ) ;

  -- Derive AXI interface properties from interface signals
  constant AXI_STREAM_DATA_WIDTH   : integer := TData'length ;
  constant AXI_STREAM_PARAM_WIDTH  : integer := TID'length + TDest'length + TUser'length + 1 ;

  -- Testbench Transaction Interface
  -- Access via external names
  signal TransRec  : StreamRecType (
    DataToModel   (AXI_STREAM_DATA_WIDTH-1  downto 0),
    DataFromModel (AXI_STREAM_DATA_WIDTH-1  downto 0),
    ParamToModel  (AXI_STREAM_PARAM_WIDTH-1 downto 0),
    ParamFromModel(AXI_STREAM_PARAM_WIDTH-1 downto 0)
  ) ;

  -- Use MODEL_ID_NAME Generic if set, otherwise,
  -- use model instance label (preferred if set as entityname_1)
  constant MODEL_INSTANCE_NAME : string :=
    IfElse(MODEL_ID_NAME'length > 0, MODEL_ID_NAME,
      to_lower(PathTail(AxiStreamReceiverVti'PATH_NAME))) ;

end entity AxiStreamReceiverVti ;
