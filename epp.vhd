-- Copyright (c) 2012, Nils Christopher Brause
-- All rights reserved.
-- 
-- Permission to use, copy, modify, and/or distribute this software for any
-- purpose with or without fee is hereby granted, provided that the above
-- copyright notice and this permission notice appear in all copies.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
-- WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
-- MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
-- ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
-- WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
-- ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
-- OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
-- 
-- The views and conclusions contained in the software and documentation are
-- those of the authors and should not be interpreted as representing official
-- policies, either expressed or implied, of the Max Planck Institute for
-- Gravitational Physics (Albert Einstein Institute).

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity epp is
  port (
    clk        : in    std_logic;
    reset      : in    std_logic;
    epp_nwrite : in    std_logic;
    epp_ndata  : in    std_logic;
    epp_naddr  : in    std_logic;
    epp_nwait  : out   std_logic;
    epp_data   : inout std_logic_vector(7 downto 0);
    epp_dir    : out   std_logic;
    data_in    : in    std_logic_vector(7 downto 0);
    data_out   : out   std_logic_vector(7 downto 0);
    addr       : out   std_logic_vector(7 downto 0);
    wr         : out   std_logic);
end entity epp;

architecture behav of epp is

  type state_t is (idle, ready, data_write, data_write2, addr_write, addr_write2, addr_read, addr_read2, data_read, data_read2, waitfor);
  
  signal state : state_t;
  signal next_state : state_t;

  signal epp_nwrite_int : std_logic := '0';
  signal epp_ndata_int : std_logic := '0';
  signal epp_naddr_int : std_logic := '0';

  signal addr_tmp : std_logic_vector(7 downto 0);
  signal data_tmp : std_logic_vector(7 downto 0);
  signal new_addr : std_logic_vector(7 downto 0);

  signal data_in_rev  : std_logic_vector(7 downto 0);
  signal addr_tmp_rev : std_logic_vector(7 downto 0);
  signal epp_data_rev : std_logic_vector(7 downto 0);

begin  -- architecture behav

  reg_nwrite: entity work.reg1
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => epp_nwrite,
      data_out => epp_nwrite_int);

  reg_ndata: entity work.reg1
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => epp_ndata,
      data_out => epp_ndata_int);

  reg_naddr: entity work.reg1
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => epp_naddr,
      data_out => epp_naddr_int);

  reg_addr: entity work.reg
    generic map (
      bits => 8)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => new_addr,
      data_out => addr_tmp);

  bitreverse_1: entity work.bitreverse
    generic map (
      bits => 8)
    port map (
      input  => addr_tmp,
      output => addr_tmp_rev);

  bitreverse_2: entity work.bitreverse
    generic map (
      bits => 8)
    port map (
      input  => data_in,
      output => data_in_rev);

  bitreverse_3: entity work.bitreverse
    generic map (
      bits => 8)
    port map (
      input  => epp_data,
      output => epp_data_rev);
  
  state_transition: process(clk, reset) is
  begin
    if reset = '0' then
      state <= idle;
    elsif rising_edge(clk) then  -- rising clock edge
      state <= next_state;
    end if;
  end process state_transition;

  epp_nwait <= '1' when state = idle or state = data_write2 or state = addr_write2 or state = data_read or state = addr_read else
               '0';
  
  epp_data <= data_in_rev when state = data_read  else
              addr_tmp_rev when state = addr_read else
              (others => 'Z');

  epp_dir <= '1' when state = data_read or state = addr_read else
             '0';
  
  new_addr <= epp_data_rev when state = addr_write else
              (others => '0') when reset = '0' else
              std_logic_vector(unsigned(addr_tmp)+1) when state = data_read2 else
              addr_tmp;
  addr <= addr_tmp;

  data_tmp <= epp_data_rev when state = data_write else
              (others => '0') when reset = '0' else
              data_tmp;

  data_out <= data_tmp;
              
  wr <= '1' when state = data_write2 else
        '0';

  next_state <= idle when reset = '0' else
                ready when (state = idle and reset = '1') else
                
                data_write when (state = ready and epp_ndata_int = '0' and epp_nwrite_int = '0') else
                data_write2 when state = data_write else
                ready when (state = data_write2 and epp_ndata_int = '1') else
                
                addr_write when (state = ready and epp_naddr_int = '0' and epp_nwrite_int = '0') else
                addr_write2 when state = addr_write else
                ready when (state = addr_write2 and epp_naddr_int = '1') else
                
                data_read when (state = ready and epp_ndata_int = '0' and epp_nwrite_int = '1') else
                data_read2 when (state = data_read and epp_ndata_int = '1') else
                ready when state = data_read2 else

                addr_read when (state = ready and epp_naddr_int = '0' and epp_nwrite_int = '1') else
                addr_read2 when (state = addr_read and epp_naddr_int = '1') else
                ready when state = addr_read2 else
                
                state;
                
end architecture behav;
