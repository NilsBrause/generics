-- Copyright (c) 2012-2017, Nils Christopher Brause
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

--! Maximum detector

--! The maximum detector receives a set of number-value pairs and gives out the
--! the number of the highest value and the value itself.
entity maximum is
  generic (
    value_bits : natural;
    num_bits   : natural);
  port (
    clk         : in  std_logic;        --! clock input
    reset       : in  std_logic;        --! asynchronous reset (active low)
    input_value : in  std_logic_vector(value_bits-1 downto 0);  --! value
    input_num   : in  std_logic_vector(num_bits-1 downto 0);  --! number
    input_valid : in  std_logic;        --! value and number are valid
    input_last  : in  std_logic;        --! last value-number pair
    exclude0    : in  std_logic_vector(num_bits-1 downto 0);  --! excluded num0
    exclude1    : in  std_logic_vector(num_bits-1 downto 0);  --! excluded num1
    exclude2    : in  std_logic_vector(num_bits-1 downto 0);  --! excluded num2
    exclude3    : in  std_logic_vector(num_bits-1 downto 0);  --! excluded num3
    exclude4    : in  std_logic_vector(num_bits-1 downto 0);  --! excluded num4
    exclude5    : in  std_logic_vector(num_bits-1 downto 0);  --! excluded num5
    exclude6    : in  std_logic_vector(num_bits-1 downto 0);  --! excluded num6
    exclude7    : in  std_logic_vector(num_bits-1 downto 0);  --! excluded num7
    maximum     : out std_logic_vector(num_bits-1 downto 0);  --! max. number
    max_value   : out std_logic_vector(value_bits-1 downto 0);  --! max. value
    new_maximum : out std_logic);       --! maximum computation finished
end entity maximum;

architecture behav of maximum is

  signal max_val_in    : std_logic_vector(value_bits-1 downto 0);
  signal max_val_out   : std_logic_vector(value_bits-1 downto 0);
  signal max_num_in    : std_logic_vector(num_bits-1 downto 0);
  signal max_num_out   : std_logic_vector(num_bits-1 downto 0);
  signal last          : std_logic;
  signal done          : std_logic;
  signal found_new_max : std_logic;

begin  -- architecture behav

  found_new_max <= '1' when unsigned(input_value) > unsigned(max_val_out)
                   and input_valid = '1'
                   and input_num /= exclude0
                   and input_num /= exclude1
                   and input_num /= exclude2
                   and input_num /= exclude3
                   and input_num /= exclude4
                   and input_num /= exclude5
                   and input_num /= exclude6
                   and input_num /= exclude7
                   else '0';

  max_val_in <= input_value when found_new_max = '1' else
                (others => '0') when unsigned(input_num) = 0 else
                max_val_out;
  
  max_num_in <= input_num when found_new_max = '1' else
                (others => '0') when unsigned(input_num) = 0 else
                max_num_out;
  
  reg_val: entity work.reg
    generic map (
      bits => value_bits)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => max_val_in,
      data_out => max_val_out);

  reg_num: entity work.reg
    generic map (
      bits => num_bits)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => max_num_in,
      data_out => max_num_out);

  last <= input_last and input_valid;

  -- 'done' asserts just after the last number-value pair.
  reg1_last: entity work.reg1
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => last,
      data_out => done);
  
  reg1_new_max: entity work.reg1
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => done,
      data_out => new_maximum);
  
  reg_val2: entity work.reg
    generic map (
      bits => value_bits)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => done,
      data_in  => max_val_out,
      data_out => max_value);

  reg_num2: entity work.reg
    generic map (
      bits => num_bits)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => done,
      data_in  => max_num_out,
      data_out => maximum);

end architecture behav;
