--
--  File Name:         Axi4LiteMonitor.vhd
--  Design Unit Name:  Axi4LiteMonitor
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      AXI Lite Monitor dummy model
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    09/2017   2017       Initial revision
--    01/2020   2020.01    Updated license notice
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2019 - 2020 by SynthWorks Design Inc.  
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

----------------------------------------------------------------------------
-- SEDA Extra Code: VHDL-2019 PROTECTED TYPES PACKAGE FOR AXI4-LiteMonitor
-- Author  : graeme.jessiman@siemens.com 
-- Date    : Jan 2025
-- Version : 1.0
----------------------------------------------------------------------------
library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

library modelsim_lib;
    use modelsim_lib.transactions.all;

package axi4lite_monitor_pkg is



  type axi4lite_monitor_t is protected

    --------------------------------------
    -- AXI4 Lite Write Channel Procedures
	--------------------------------------
    procedure start_wr_transaction;
    procedure add_wr_address_attrs(wr_addr  : std_logic_vector(31 downto 0); wr_prot : std_logic_vector(2 downto 0));
    procedure add_wr_data_attrs(wr_data     : std_logic_vector(31 downto 0); wr_strb : std_logic_vector(3 downto 0));
    procedure add_wr_response_attrs(wr_resp : std_logic_vector(1 downto 0));
    procedure end_wr_transaction;

    --------------------------------------
    -- AXI4 Lite Read Channel Procedures
	--------------------------------------
    procedure start_rd_transaction;
    procedure add_rd_address_attrs(rd_addr : std_logic_vector(31 downto 0); rd_prot : std_logic_vector(2 downto 0));
    procedure add_rd_data_attrs(rd_data    : std_logic_vector(31 downto 0); rd_resp : std_logic_vector(1 downto 0));
    procedure end_rd_transaction;

    --------------------------------------
    -- FIFO Write/Read Methods
	--------------------------------------
    procedure push_write_fifo(l_ptr : TrTransaction);
    impure function  pop_write_fifo return TrTransaction;
    impure function  peek_write_fifo(f_index : integer) return TrTransaction;

    procedure push_read_fifo(l_ptr : TrTransaction);
    impure function  pop_read_fifo return TrTransaction;
    impure function  peek_read_fifo(l_ptr : TrTransaction) return TrTransaction;

  end protected axi4lite_monitor_t;

end package axi4lite_monitor_pkg;







package body axi4lite_monitor_pkg is

  type axi4lite_monitor_t is protected body

    -- Transaction Pointer FIFO
    type fifo_array is array (9 downto 0) of TrTransaction;
	variable write_ptr_fifo : fifo_array;
	variable read_ptr_fifo  : fifo_array;
	variable wr_fifo_index  : integer range 0 to 9 := 0;
	variable rd_fifo_index  : integer range 0 to 9 := 0;
 
    procedure push_write_fifo(l_ptr : TrTransaction) is
	begin
	   write_ptr_fifo(wr_fifo_index) := l_ptr;
	   wr_fifo_index := wr_fifo_index + 1;
	end procedure push_write_fifo;

    impure function peek_write_fifo(f_index : integer) return TrTransaction is
	  variable local_ptr : TrTransaction;
	begin
	   local_ptr  := write_ptr_fifo(f_index);
	   return local_ptr;
	end function peek_write_fifo;
	
    impure function pop_write_fifo return TrTransaction is
	  variable local_ptr : TrTransaction;
	begin
	   local_ptr  := write_ptr_fifo(0);
	   write_ptr_fifo(8 DOWNTO 0) := write_ptr_fifo(9 DOWNTO 1);
	   wr_fifo_index := wr_fifo_index - 1;
	   return local_ptr;
	end function pop_write_fifo;


    procedure push_read_fifo(l_ptr : TrTransaction) is
	begin
	   read_ptr_fifo(rd_fifo_index) := l_ptr;
	   rd_fifo_index := rd_fifo_index + 1;
	end procedure push_read_fifo;

    impure function peek_read_fifo(l_ptr : TrTransaction) return TrTransaction is
	  variable local_ptr : TrTransaction;
	begin
	   local_ptr  := read_ptr_fifo(l_ptr);
	   return local_ptr;
	end function peek_read_fifo;
	
    impure function pop_read_fifo return TrTransaction is
	  variable local_ptr : TrTransaction;
	begin
	   -- Read oldest entry in the FIFO
	   local_ptr  := read_ptr_fifo(0);
	   -- Shift all FIFO entries down 1 location
	   read_ptr_fifo(8 DOWNTO 0) := read_ptr_fifo(9 DOWNTO 1);
	   rd_fifo_index := rd_fifo_index - 1;
	   return local_ptr;
	end function pop_read_fifo;


    -- Variable declarations for the TXN stream
    variable axi4lite_wr_stream : TrStream := create_transaction_stream("AXI4Lite_Write_Stream");
    variable axi4lite_rd_stream : TrStream := create_transaction_stream("AXI4Lite_Read_Stream");

    variable wr_tr1, wr_tr2, wr_tr3, wr_tr4, wr_tr5, wr_tr6, wr_tr7, wr_tr8, wr_tr9 : TrTransaction := 0;
    variable rd_tr1, rd_tr2, rd_tr3, rd_tr4, rd_tr5, rd_tr6, rd_tr7, rd_tr8, rd_tr9 : TrTransaction := 0;
    variable curr_tr    : TrTransaction := 0;
    variable curr_rd_tr : TrTransaction := 0;
    variable wr_txn_cnt : integer := 1;
    variable rd_txn_cnt : integer := 1;
    variable t : time := 0 ns;

 
    -- TXN creation procedure
    procedure start_wr_transaction is
    begin
	  case (wr_txn_cnt) IS
	    when 1 => wr_tr1 := begin_transaction(axi4lite_wr_stream, "Write");
		          curr_tr := wr_tr1;
		when 2 => wr_tr2 := begin_transaction(axi4lite_wr_stream, "Write");
		          curr_tr := wr_tr2;
	    when 3 => wr_tr3 := begin_transaction(axi4lite_wr_stream, "Write");
		          curr_tr := wr_tr3;
	    when 4 => wr_tr4 := begin_transaction(axi4lite_wr_stream, "Write");
		          curr_tr := wr_tr4;
	    when 5 => wr_tr5 := begin_transaction(axi4lite_wr_stream, "Write");
		          curr_tr := wr_tr5;
	    when 6 => wr_tr6 := begin_transaction(axi4lite_wr_stream, "Write");
		          curr_tr := wr_tr6;
	    when 7 => wr_tr7 := begin_transaction(axi4lite_wr_stream, "Write");
		          curr_tr := wr_tr7;
	    when 8 => wr_tr8 := begin_transaction(axi4lite_wr_stream, "Write");
		          curr_tr := wr_tr8;
	    when others => wr_tr9 := begin_transaction(axi4lite_wr_stream, "Write");
		               curr_tr := wr_tr9;
	  end case;

      -- Store write transaction pointer in FIFO
	  push_write_fifo(curr_tr);
	  
	  add_color(curr_tr, "blue");

	  report "%%%%%%% : Called start_wr_transaction :: WR_CNT=" & integer'image(wr_txn_cnt) severity note;	  
      if (wr_txn_cnt < 9) then
         wr_txn_cnt := wr_txn_cnt +1;
      end if;	     
	  
	end procedure start_wr_transaction;
	



    -- TXN add Write Addr Channel values
    procedure add_wr_address_attrs(wr_addr : std_logic_vector(31 downto 0); wr_prot : std_logic_vector(2 downto 0)) is
    begin
      add_attribute(curr_tr, wr_addr, "Addr");
      add_attribute(curr_tr, wr_prot, "Prot");
	  report "%%%%%%% : TXN : Adding Write Address Ch Values :: WR_CNT=" & integer'image(wr_txn_cnt) severity note;
    end procedure add_wr_address_attrs;

    -- TXN add Write Data Channel values
    procedure add_wr_data_attrs(wr_data : std_logic_vector(31 downto 0); wr_strb : std_logic_vector(3 downto 0)) is
    begin
      add_attribute(curr_tr, wr_data, "Data");
      add_attribute(curr_tr, wr_strb, "Strb");
	  report "%%%%%%% : TXN : Adding Write Data Ch Values :: WR_CNT=" & integer'image(wr_txn_cnt) severity note;
    end procedure add_wr_data_attrs;

    -- TXN add Write Response Channel values
    procedure add_wr_response_attrs(wr_resp : std_logic_vector(1 downto 0)) is
	  variable local_ptr : TrTransaction;
    begin
      local_ptr := peek_write_fifo(0);
      add_attribute(local_ptr, wr_resp, "Resp");
      --add_attribute(curr_tr, curr_tr, "curr_wr_txn");
      --add_attribute(curr_tr, wr_txn_cnt, "wr_txn_cnt");
	  report "%%%%%%% : TXN : Adding Write Response Ch Values :: WR_CNT=" & integer'image(wr_txn_cnt) severity note;
    end procedure add_wr_response_attrs;

    -- TXN completion procedure
    procedure end_wr_transaction is
	  variable local_ptr : TrTransaction;
    begin
	  -- retrieve oldest pointer from Write FIFO
	  local_ptr := pop_write_fifo;
	  
      end_transaction(local_ptr);
      free_transaction(local_ptr);

	  report "%%%%%%% : TXN : Ending Current TXN :: WR_CNT=" & integer'image(wr_txn_cnt) severity note;

      if (wr_txn_cnt > 0) then
         wr_txn_cnt := wr_txn_cnt -1;
		 --curr_tr := 0;
      end if;		 
    end procedure end_wr_transaction;









    procedure start_rd_transaction is
    begin
	  case (rd_txn_cnt) IS
	    when 1 => rd_tr1 := begin_transaction(axi4lite_rd_stream, "Read");
		          curr_rd_tr := rd_tr1;
		when 2 => rd_tr2 := begin_transaction(axi4lite_rd_stream, "Read");
		          curr_rd_tr := rd_tr2;
	    when 3 => rd_tr3 := begin_transaction(axi4lite_rd_stream, "Read");
		          curr_rd_tr := rd_tr3;
	    when 4 => rd_tr4 := begin_transaction(axi4lite_rd_stream, "Read");
		          curr_rd_tr := rd_tr4;
	    when 5 => rd_tr5 := begin_transaction(axi4lite_rd_stream, "Read");
		          curr_rd_tr := rd_tr5;
	    when 6 => rd_tr6 := begin_transaction(axi4lite_rd_stream, "Read");
		          curr_rd_tr := rd_tr6;
	    when 7 => rd_tr7 := begin_transaction(axi4lite_rd_stream, "Read");
		          curr_rd_tr := rd_tr7;
	    when 8 => rd_tr8 := begin_transaction(axi4lite_rd_stream, "Read");
		          curr_rd_tr := rd_tr8;
	    when others => rd_tr9 := begin_transaction(axi4lite_rd_stream, "Read");
		               curr_rd_tr := rd_tr9;
	  end case;

      -- Store read transaction pointer in FIFO
	  push_read_fifo(curr_rd_tr);
	  
	  add_color(curr_rd_tr, "green");

	  report "%%%%%%% : Called start_rd_transaction :: RD_CNT=" & integer'image(rd_txn_cnt) & ":: CURR_RD_TR: " & integer'image(curr_rd_tr)  severity note;	  
 	  
      if (rd_txn_cnt < 9) then
         rd_txn_cnt := rd_txn_cnt +1;
         report "%%%%%%% : Incremented rx_txn_cnt =" & integer'image(rd_txn_cnt) & ":: CURR_RD_TR: " & integer'image(curr_rd_tr)  severity note;	  
      end if;
	  
    end procedure start_rd_transaction;
	
	
    -- TXN add Read Addr Channel values
    procedure add_rd_address_attrs(rd_addr : std_logic_vector(31 downto 0); rd_prot : std_logic_vector(2 downto 0)) is
    begin
      add_attribute(curr_rd_tr, rd_addr, "Addr");
      add_attribute(curr_rd_tr, rd_prot, "Prot");
	  report "%%%%%%% : TXN : Adding Read Address Ch Values :: RD_CNT=" & integer'image(rd_txn_cnt) & ":: CURR_RD_TR: " & integer'image(curr_rd_tr) severity note;
    end procedure add_rd_address_attrs;

    -- TXN add Read Data Channel values
    procedure add_rd_data_attrs(rd_data : std_logic_vector(31 downto 0); rd_resp : std_logic_vector(1 downto 0)) is
    begin
      add_attribute(curr_rd_tr, rd_data, "Data");
      add_attribute(curr_rd_tr, rd_resp, "Resp");
	  report "%%%%%%% : TXN : Adding Read Data Ch Values :: RD_CNT=" & integer'image(rd_txn_cnt) & ":: CURR_RD_TR: " & integer'image(curr_rd_tr) severity note;		  
    end procedure add_rd_data_attrs;

    -- TXN completion procedure
    procedure end_rd_transaction is
	  variable local_ptr : TrTransaction;
    begin
	  -- retrieve oldest pointer from Read FIFO
	  local_ptr := pop_read_fifo;
	  
      end_transaction(local_ptr);
      free_transaction(local_ptr);
	  report "%%%%%%% : TXN : Ending Current Rd TXN :: RD_CNT=" & integer'image(rd_txn_cnt) & ":: CURR_RD_TR: " & integer'image(curr_rd_tr) severity note;
      if (rd_txn_cnt > 0) then
         rd_txn_cnt := rd_txn_cnt -1;
         report "%%%%%%% : Decremented rx_txn_cnt =" & integer'image(rd_txn_cnt) & ":: CURR_RD_TR: " & integer'image(curr_rd_tr) severity note;	  
		 --curr_rd_tr := 0;
      end if;	 
    end procedure end_rd_transaction;
    
	
	
  end protected body axi4lite_monitor_t;

end package body axi4lite_monitor_pkg;
----------------------------------------------------------------------------
----------------------------------------------------------------------------




library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;

library osvvm ;
    context osvvm.OsvvmContext ;

--SEDA New Code
library modelsim_lib;
    use modelsim_lib.transactions.all;

  use work.Axi4InterfaceCommonPkg.all ;
  use work.Axi4LiteInterfacePkg.all ; 
  use work.Axi4CommonPkg.all ; 
  use work.axi4lite_monitor_pkg.all;

entity Axi4LiteMonitor is
port (
  -- Globals
  Clk         : in   std_logic ;
  nReset      : in   std_logic ;

  -- AXI Master Functional Interface
  AxiBus      : in    Axi4LiteRecType 
) ;
   
end entity Axi4LiteMonitor ;
architecture Monitor of Axi4LiteMonitor is

--  alias    AB : AxiBus'subtype is AxiBus ; 
--  alias    AW is AB.WriteAddress ;
--  alias    WD is AB.WriteData ; 
--  alias    WR is AB.WriteResponse ; 
--  alias    AR is AB.ReadAddress ; 
--  alias    RD is AB.ReadData ;

  constant MODEL_INSTANCE_NAME : string     := PathTail(to_lower(Axi4LiteMonitor'PATH_NAME)) ;
  signal ModelID, ProtocolID, DataCheckID, BusFailedID : AlertLogIDType ; 
    -- SEDA New Code  
  signal wr_addr : std_logic_vector(31 downto 0);  
  signal wr_prot : std_logic_vector(2 downto 0);  

  signal wr_data : std_logic_vector(31 downto 0);  
  signal wr_strb : std_logic_vector(3 downto 0);  

  signal wr_resp : std_logic_vector(1 downto 0);  

  signal rd_addr : std_logic_vector(31 downto 0);  
  signal rd_prot : std_logic_vector(2 downto 0); 
  signal rd_data : std_logic_vector(31 downto 0);  
  signal rd_resp : std_logic_vector(1 downto 0);  
  
  -- VHDL 2019 shared variable of protected type
  shared variable axi4_lite_monitor : axi4lite_monitor_t;


begin

  -- Write Address Channel monitoring
 process (Clk, nReset)
 begin
  if (nReset = '0') then
      wr_addr <= (others => '0');
      wr_prot <= (others => '0');
  elsif falling_edge(Clk) then
      if (AxiBus.WriteAddress.Ready = '1' AND AxiBus.WriteAddress.Valid = '1') then
         wr_addr <= AxiBus.WriteAddress.Addr;
         wr_prot <= AxiBus.WriteAddress.Prot;
         -- Add captured address & prot values to TXN
	     axi4_lite_monitor.start_wr_transaction;
		 axi4_lite_monitor.add_wr_address_attrs(AxiBus.WriteAddress.Addr, AxiBus.WriteAddress.Prot);
      end if;
  end if;
 end process;

  -- Write Data Channel monitoring
 process (Clk, nReset)
 begin
  if (nReset = '0') then
      wr_data <= (others => '0');
      wr_strb <= (others => '0');
  elsif falling_edge(Clk) then
      if (AxiBus.WriteData.Ready = '1' AND AxiBus.WriteData.Valid = '1') then
         wr_data <= AxiBus.Writedata.Data;
         wr_strb <= AxiBus.WriteData.Strb;
         -- Add captured Write Data channel values to TXN
		 axi4_lite_monitor.add_wr_data_attrs(AxiBus.Writedata.Data, AxiBus.WriteData.Strb);
      end if;
  end if;
 end process;


  -- Write Response Channel monitoring
 process (Clk, nReset)
 begin
  if (nReset = '0') then
      wr_resp <= (others => '0');
  elsif falling_edge(Clk) then
      if (AxiBus.WriteResponse.Ready = '1' AND AxiBus.WriteResponse.Valid = '1') then
         wr_resp <= AxiBus.WriteResponse.Resp;
         -- Add captured Write Resp channel values to TXN
		 axi4_lite_monitor.add_wr_response_attrs(AxiBus.WriteResponse.Resp);
		 axi4_lite_monitor.end_wr_transaction;
      end if;
  end if;
 end process;
  

  -- Read Address Channel monitoring
 process (Clk, nReset)
 begin
  if (nReset = '0') then
      rd_addr <= (others => '0');
      rd_prot <= (others => '0');
  elsif falling_edge(Clk) then
      if (AxiBus.ReadAddress.Ready = '1' AND AxiBus.ReadAddress.Valid = '1') then
         rd_addr <= AxiBus.ReadAddress.Addr;
         rd_prot <= AxiBus.ReadAddress.Prot;
         -- Add captured data & resp values to TXN
         -- Add captured data & resp values to TXN
	     axi4_lite_monitor.start_rd_transaction;
		 axi4_lite_monitor.add_rd_address_attrs(AxiBus.ReadAddress.Addr, AxiBus.ReadAddress.Prot);
      end if;
  end if;
 end process;  
 
 
   -- Read Data Channel monitoring
 process (Clk, nReset)
 begin
  if (nReset = '0') then
      rd_data <= (others => '0');
      rd_resp <= (others => '0');
  elsif falling_edge(Clk) then
      if (AxiBus.ReadData.Ready = '1' AND AxiBus.ReadData.Valid = '1') then
         rd_data <= AxiBus.ReadData.Data;
         rd_resp <= AxiBus.ReadData.Resp;
         -- Add captured Read Data channel values to TXN
		 axi4_lite_monitor.add_rd_data_attrs(AxiBus.Readdata.Data, AxiBus.ReadData.Resp);
		 axi4_lite_monitor.end_rd_transaction;
      end if;
  end if;
 end process;

end architecture Monitor ;
