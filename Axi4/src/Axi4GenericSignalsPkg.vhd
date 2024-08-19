--
--  File Name:         Axi4GenericSignalsPkg.vhd
--  Design Unit Name:  Axi4GenericSignalsPkg
--  Revision:          STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--
--  Description
--      Signal Declarations for AXI4 Interface
--
--  Developed by/for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:      
--    Date      Version    Description
--    08/2024   2024.09    Initial Revision
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2024 by SynthWorks Design Inc.  
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

library osvvm ;
    context osvvm.OsvvmContext ;

library osvvm_axi4 ;
    context osvvm_Axi4.Axi4Context ;
    
package Axi4GenericSignalsPkg is
  generic (
    constant AXI_ADDR_WIDTH   : integer := 32 ; 
    constant AXI_DATA_WIDTH   : integer := 32 ; 
    constant AXI_ID_WIDTH     : integer := 8 ;
    constant AXI_USER_WIDTH   : integer := 8 
  ) ; 
  
  constant AXI_STRB_WIDTH : integer := AXI_DATA_WIDTH/8 ;
  
  signal TransRec  : AddressBusRecType (
          Address      (AXI_ADDR_WIDTH-1 downto 0),
          DataToModel  (AXI_DATA_WIDTH-1 downto 0),
          DataFromModel(AXI_DATA_WIDTH-1 downto 0)
        ) ;


  signal   AxiBus : Axi4RecType(
    WriteAddress(
      Addr(AXI_ADDR_WIDTH-1 downto 0),
      ID  (AXI_ID_WIDTH-1   downto 0),
      User(AXI_USER_WIDTH-1 downto 0)
    ),
    WriteData   (
      Data(AXI_DATA_WIDTH-1 downto 0),
      Strb(AXI_STRB_WIDTH-1 downto 0),
      User(AXI_ID_WIDTH-1   downto 0),
      ID  (AXI_USER_WIDTH-1 downto 0)
    ),
    WriteResponse(
      ID  (AXI_ID_WIDTH-1   downto 0),
      User(AXI_USER_WIDTH-1 downto 0)
    ),
    ReadAddress (
      Addr(AXI_ADDR_WIDTH-1 downto 0),
      ID  (AXI_ID_WIDTH-1   downto 0),
      User(AXI_USER_WIDTH-1 downto 0)
    ),
    ReadData    (
      Data(AXI_DATA_WIDTH-1 downto 0),
      ID  (AXI_ID_WIDTH-1   downto 0),
      User(AXI_USER_WIDTH-1 downto 0)
    )
  ) ;
  
  -- AXI Write Address Channel
  alias AwAddr   is AxiBus.WriteAddress.Addr ;
  alias AwProt   is AxiBus.WriteAddress.Prot ;
  alias AwValid  is AxiBus.WriteAddress.Valid ;
  alias AwReady  is AxiBus.WriteAddress.Ready ;
  alias AwID     is AxiBus.WriteAddress.ID ;
  alias AwLen    is AxiBus.WriteAddress.Len ;
  alias AwSize   is AxiBus.WriteAddress.Size ;
  alias AwBurst  is AxiBus.WriteAddress.Burst ;
  alias AwLock   is AxiBus.WriteAddress.Lock ;
  alias AwCache  is AxiBus.WriteAddress.Cache ;
  alias AwQOS    is AxiBus.WriteAddress.QOS ;
  alias AwRegion is AxiBus.WriteAddress.Region ;
  alias AwUser   is AxiBus.WriteAddress.User ;

  -- AXI Write Data Channel
  alias WData    is AxiBus.WriteData.Data ;  
  alias WStrb    is AxiBus.WriteData.Strb ;  
  alias WValid   is AxiBus.WriteData.Valid ; 
  alias WReady   is AxiBus.WriteData.Ready ; 
  alias WLast    is AxiBus.WriteData.Last ;
  alias WUser    is AxiBus.WriteData.User ;
  alias WID      is AxiBus.WriteData.ID ;

  -- AXI Write Response Channel
  alias BValid   is AxiBus.WriteResponse.Valid ; 
  alias BReady   is AxiBus.WriteResponse.Ready ; 
  alias BResp    is AxiBus.WriteResponse.Resp ;  
  alias BID      is AxiBus.WriteResponse.ID ;
  alias BUser    is AxiBus.WriteResponse.User ;

  -- AXI Read Address Channel
  alias ArAddr   is AxiBus.ReadAddress.Addr ;
  alias ArProt   is AxiBus.ReadAddress.Prot ;
  alias ArValid  is AxiBus.ReadAddress.Valid ;
  alias ArReady  is AxiBus.ReadAddress.Ready ;
  alias ArID     is AxiBus.ReadAddress.ID ;
  alias ArLen    is AxiBus.ReadAddress.Len ;
  alias ArSize   is AxiBus.ReadAddress.Size ;
  alias ArBurst  is AxiBus.ReadAddress.Burst ;
  alias ArLock   is AxiBus.ReadAddress.Lock ;
  alias ArCache  is AxiBus.ReadAddress.Cache ;
  alias ArQOS    is AxiBus.ReadAddress.QOS ;
  alias ArRegion is AxiBus.ReadAddress.Region ;
  alias ArUser   is AxiBus.ReadAddress.User ;

  -- AXI Read Data Channel
  alias RData    is AxiBus.ReadData.Data ;  
  alias RResp    is AxiBus.ReadData.Resp ;
  alias RValid   is AxiBus.ReadData.Valid ; 
  alias RReady   is AxiBus.ReadData.Ready ; 
  alias RLast    is AxiBus.ReadData.Last ;
  alias RUser    is AxiBus.ReadData.User ;   
  alias RID      is AxiBus.ReadData.ID ;
end package Axi4GenericSignalsPkg ;

