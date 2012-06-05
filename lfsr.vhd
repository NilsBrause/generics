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

entity lfsr is
  generic (
    bits : natural);
  port (
    clk    : in  std_logic;
    reset  : in  std_logic;
    output : out std_logic_vector(bits-1 downto 0));
end lfsr;

architecture behav of lfsr is

  signal srin  : std_logic := '0';
  signal srout : std_logic_vector(bits-1 downto 0) := (others => '0');
  signal to_xnor : std_logic_vector(5 downto 0) := (others => '0');
  
begin  -- behav

  srin <= to_xnor(0) xnor to_xnor(1) xnor to_xnor(2)
          xnor to_xnor(3) xnor to_xnor(4)  xnor to_xnor(5);

  shift_reg_1: entity work.shift_reg
    generic map (
      bits => bits)
    port map (
      clk          => clk,
      reset        => reset,
      load         => '0',
      serial_in    => srin,
      parallel_in  => (others => '0'),
      serial_out   => open,
      parallel_out => srout,
      enable       => '1');
  
  -- http://www.xilinx.com/support/documentation/application_notes/xapp210.pdf

  to_xnor(0) <= srout(bits-1);

  n1: if bits = 1 generate
    to_xnor(1) <= '0';
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n1;

  n2: if bits = 2 generate
    to_xnor(1) <= srout(0);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n2;
  
  n3: if bits = 3 generate
    to_xnor(1) <= srout(1);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n3;
  
  n4: if bits = 4 generate
    to_xnor(1) <= srout(2);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n4;
  
  n5: if bits = 5 generate
    to_xnor(1) <= srout(2);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n5;
  
  n6: if bits = 6 generate
    to_xnor(1) <= srout(4);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n6;
  
  n7: if bits = 7 generate
    to_xnor(1) <= srout(5);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n7;
  
  n8: if bits = 8 generate
    to_xnor(1) <= srout(5);
    to_xnor(2) <= srout(4);
    to_xnor(3) <= srout(3);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n8;
  
  n9: if bits = 9 generate
    to_xnor(1) <= srout(4);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n9;
  
  n10: if bits = 10 generate
    to_xnor(1) <= srout(6);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n10;
  
  n11: if bits = 11 generate
    to_xnor(1) <= srout(8);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n11;
  
  n12: if bits = 12 generate
    to_xnor(1) <= srout(5);
    to_xnor(2) <= srout(3);
    to_xnor(3) <= srout(0);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n12;
  
  n13: if bits = 13 generate
    to_xnor(1) <= srout(3);
    to_xnor(2) <= srout(2);
    to_xnor(3) <= srout(0);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n13;
  
  n14: if bits = 14 generate
    to_xnor(1) <= srout(4);
    to_xnor(2) <= srout(2);
    to_xnor(3) <= srout(0);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n14;
  
  n15: if bits = 15 generate
    to_xnor(1) <= srout(13);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n15;
  
  n16: if bits = 16 generate
    to_xnor(1) <= srout(14);
    to_xnor(2) <= srout(12);
    to_xnor(3) <= srout(13);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n16;
  
  n17: if bits = 17 generate
    to_xnor(1) <= srout(13);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n17;
  
  n18: if bits = 18 generate
    to_xnor(1) <= srout(10);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n18;
  
  n19: if bits = 19 generate
    to_xnor(1) <= srout(5);
    to_xnor(2) <= srout(1);
    to_xnor(3) <= srout(0);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n19;
  
  n20: if bits = 20 generate
    to_xnor(1) <= srout(16);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n20;
  
  n21: if bits = 21 generate
    to_xnor(1) <= srout(18);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n21;
  
  n22: if bits = 22 generate
    to_xnor(1) <= srout(20);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n22;
  
  n23: if bits = 23 generate
    to_xnor(1) <= srout(17);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n23;
  
  n24: if bits = 24 generate
    to_xnor(1) <= srout(22);
    to_xnor(2) <= srout(21);
    to_xnor(3) <= srout(16);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n24;
  
  n25: if bits = 25 generate
    to_xnor(1) <= srout(21);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n25;
  
  n26: if bits = 26 generate
    to_xnor(1) <= srout(5);
    to_xnor(2) <= srout(1);
    to_xnor(3) <= srout(0);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n26;
  
  n27: if bits = 27 generate
    to_xnor(1) <= srout(4);
    to_xnor(2) <= srout(1);
    to_xnor(3) <= srout(0);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n27;
  
  n28: if bits = 28 generate
    to_xnor(1) <= srout(24);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n28;
  
  n29: if bits = 29 generate
    to_xnor(1) <= srout(26);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n29;
  
  n30: if bits = 30 generate
    to_xnor(1) <= srout(5);
    to_xnor(2) <= srout(3);
    to_xnor(3) <= srout(0);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n30;
  
  n31: if bits = 31 generate
    to_xnor(1) <= srout(27);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n31;
  
  n32: if bits = 32 generate
    to_xnor(1) <= srout(21);
    to_xnor(2) <= srout(1);
    to_xnor(3) <= srout(0);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n32;
  
  n33: if bits = 33 generate
    to_xnor(1) <= srout(19);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n33;
  
  n34: if bits = 34 generate
    to_xnor(1) <= srout(26);
    to_xnor(2) <= srout(1);
    to_xnor(3) <= srout(0);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n34;
  
  n35: if bits = 35 generate
    to_xnor(1) <= srout(32);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n35;
  
  n36: if bits = 36 generate
    to_xnor(1) <= srout(24);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n36;
  
  n37: if bits = 37 generate
    to_xnor(1) <= srout(36);
    to_xnor(2) <= srout(4);
    to_xnor(3) <= srout(3);
    to_xnor(4) <= srout(2);
    to_xnor(5) <= srout(1);
  end generate n37;
  
  n38: if bits = 38 generate
    to_xnor(1) <= srout(5);
    to_xnor(2) <= srout(4);
    to_xnor(3) <= srout(0);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n38;
  
  n39: if bits = 39 generate
    to_xnor(1) <= srout(34);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n39;
  
  n40: if bits = 40 generate
    to_xnor(1) <= srout(37);
    to_xnor(2) <= srout(20);
    to_xnor(3) <= srout(18);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n40;
  
  n41: if bits = 41 generate
    to_xnor(1) <= srout(37);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n41;
  
  n42: if bits = 42 generate
    to_xnor(1) <= srout(40);
    to_xnor(2) <= srout(19);
    to_xnor(3) <= srout(18);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n42;
  
  n43: if bits = 43 generate
    to_xnor(1) <= srout(41);
    to_xnor(2) <= srout(37);
    to_xnor(3) <= srout(36);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n43;
  
  n44: if bits = 44 generate
    to_xnor(1) <= srout(42);
    to_xnor(2) <= srout(17);
    to_xnor(3) <= srout(16);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n44;
  
  n45: if bits = 45 generate
    to_xnor(1) <= srout(43);
    to_xnor(2) <= srout(41);
    to_xnor(3) <= srout(40);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n45;
  
  n46: if bits = 46 generate
    to_xnor(1) <= srout(44);
    to_xnor(2) <= srout(25);
    to_xnor(3) <= srout(24);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n46;
  
  n47: if bits = 47 generate
    to_xnor(1) <= srout(41);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n47;
  
  n48: if bits = 48 generate
    to_xnor(1) <= srout(46);
    to_xnor(2) <= srout(20);
    to_xnor(3) <= srout(19);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n48;
  
  n49: if bits = 49 generate
    to_xnor(1) <= srout(39);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n49;
  
  n50: if bits = 50 generate
    to_xnor(1) <= srout(48);
    to_xnor(2) <= srout(23);
    to_xnor(3) <= srout(22);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n50;
  
  n51: if bits = 51 generate
    to_xnor(1) <= srout(49);
    to_xnor(2) <= srout(35);
    to_xnor(3) <= srout(34);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n51;
  
  n52: if bits = 52 generate
    to_xnor(1) <= srout(48);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n52;
  
  n53: if bits = 53 generate
    to_xnor(1) <= srout(51);
    to_xnor(2) <= srout(37);
    to_xnor(3) <= srout(36);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n53;
  
  n54: if bits = 54 generate
    to_xnor(1) <= srout(52);
    to_xnor(2) <= srout(17);
    to_xnor(3) <= srout(16);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n54;
  
  n55: if bits = 55 generate
    to_xnor(1) <= srout(30);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n55;
  
  n56: if bits = 56 generate
    to_xnor(1) <= srout(54);
    to_xnor(2) <= srout(34);
    to_xnor(3) <= srout(33);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n56;
  
  n57: if bits = 57 generate
    to_xnor(1) <= srout(49);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n57;
  
  n58: if bits = 58 generate
    to_xnor(1) <= srout(38);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n58;
  
  n59: if bits = 59 generate
    to_xnor(1) <= srout(57);
    to_xnor(2) <= srout(37);
    to_xnor(3) <= srout(36);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n59;
  
  n60: if bits = 60 generate
    to_xnor(1) <= srout(58);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n60;
  
  n61: if bits = 61 generate
    to_xnor(1) <= srout(59);
    to_xnor(2) <= srout(45);
    to_xnor(3) <= srout(44);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n61;
  
  n62: if bits = 62 generate
    to_xnor(1) <= srout(60);
    to_xnor(2) <= srout(5);
    to_xnor(3) <= srout(4);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n62;
  
  n63: if bits = 63 generate
    to_xnor(1) <= srout(61);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n63;
  
  n64: if bits = 64 generate
    to_xnor(1) <= srout(62);
    to_xnor(2) <= srout(60);
    to_xnor(3) <= srout(59);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n64;
  
  n65: if bits = 65 generate
    to_xnor(1) <= srout(46);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n65;
  
  n66: if bits = 66 generate
    to_xnor(1) <= srout(64);
    to_xnor(2) <= srout(56);
    to_xnor(3) <= srout(55);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n66;
  
  n67: if bits = 67 generate
    to_xnor(1) <= srout(65);
    to_xnor(2) <= srout(57);
    to_xnor(3) <= srout(56);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n67;
  
  n68: if bits = 68 generate
    to_xnor(1) <= srout(58);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n68;
  
  n69: if bits = 69 generate
    to_xnor(1) <= srout(66);
    to_xnor(2) <= srout(41);
    to_xnor(3) <= srout(39);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n69;
  
  n70: if bits = 70 generate
    to_xnor(1) <= srout(68);
    to_xnor(2) <= srout(54);
    to_xnor(3) <= srout(53);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n70;
  
  n71: if bits = 71 generate
    to_xnor(1) <= srout(64);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n71;
  
  n72: if bits = 72 generate
    to_xnor(1) <= srout(65);
    to_xnor(2) <= srout(24);
    to_xnor(3) <= srout(18);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n72;
  
  n73: if bits = 73 generate
    to_xnor(1) <= srout(47);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n73;
  
  n74: if bits = 74 generate
    to_xnor(1) <= srout(72);
    to_xnor(2) <= srout(58);
    to_xnor(3) <= srout(57);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n74;
  
  n75: if bits = 75 generate
    to_xnor(1) <= srout(73);
    to_xnor(2) <= srout(64);
    to_xnor(3) <= srout(63);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n75;
  
  n76: if bits = 76 generate
    to_xnor(1) <= srout(74);
    to_xnor(2) <= srout(40);
    to_xnor(3) <= srout(39);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n76;
  
  n77: if bits = 77 generate
    to_xnor(1) <= srout(75);
    to_xnor(2) <= srout(46);
    to_xnor(3) <= srout(45);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n77;
  
  n78: if bits = 78 generate
    to_xnor(1) <= srout(76);
    to_xnor(2) <= srout(58);
    to_xnor(3) <= srout(57);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n78;
  
  n79: if bits = 79 generate
    to_xnor(1) <= srout(69);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n79;
  
  n80: if bits = 80 generate
    to_xnor(1) <= srout(78);
    to_xnor(2) <= srout(42);
    to_xnor(3) <= srout(41);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n80;
  
  n81: if bits = 81 generate
    to_xnor(1) <= srout(76);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n81;
  
  n82: if bits = 82 generate
    to_xnor(1) <= srout(78);
    to_xnor(2) <= srout(46);
    to_xnor(3) <= srout(43);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n82;
  
  n83: if bits = 83 generate
    to_xnor(1) <= srout(81);
    to_xnor(2) <= srout(37);
    to_xnor(3) <= srout(36);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n83;
  
  n84: if bits = 84 generate
    to_xnor(1) <= srout(70);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n84;
  
  n85: if bits = 85 generate
    to_xnor(1) <= srout(83);
    to_xnor(2) <= srout(57);
    to_xnor(3) <= srout(56);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n85;
  
  n86: if bits = 86 generate
    to_xnor(1) <= srout(84);
    to_xnor(2) <= srout(73);
    to_xnor(3) <= srout(72);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n86;
  
  n87: if bits = 87 generate
    to_xnor(1) <= srout(73);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n87;
  
  n88: if bits = 88 generate
    to_xnor(1) <= srout(86);
    to_xnor(2) <= srout(16);
    to_xnor(3) <= srout(15);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n88;
  
  n89: if bits = 89 generate
    to_xnor(1) <= srout(50);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n89;
  
  n90: if bits = 90 generate
    to_xnor(1) <= srout(88);
    to_xnor(2) <= srout(71);
    to_xnor(3) <= srout(70);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n90;
  
  n91: if bits = 91 generate
    to_xnor(1) <= srout(89);
    to_xnor(2) <= srout(7);
    to_xnor(3) <= srout(6);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n91;
  
  n92: if bits = 92 generate
    to_xnor(1) <= srout(90);
    to_xnor(2) <= srout(79);
    to_xnor(3) <= srout(78);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n92;
  
  n93: if bits = 93 generate
    to_xnor(1) <= srout(90);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n93;
  
  n94: if bits = 94 generate
    to_xnor(1) <= srout(72);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n94;
  
  n95: if bits = 95 generate
    to_xnor(1) <= srout(83);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n95;
  
  n96: if bits = 96 generate
    to_xnor(1) <= srout(93);
    to_xnor(2) <= srout(48);
    to_xnor(3) <= srout(46);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n96;
  
  n97: if bits = 97 generate
    to_xnor(1) <= srout(90);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n97;
  
  n98: if bits = 98 generate
    to_xnor(1) <= srout(86);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n98;
  
  n99: if bits = 99 generate
    to_xnor(1) <= srout(96);
    to_xnor(2) <= srout(53);
    to_xnor(3) <= srout(51);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n99;
  
  n100: if bits = 100 generate
    to_xnor(1) <= srout(62);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n100;
  
  n101: if bits = 101 generate
    to_xnor(1) <= srout(99);
    to_xnor(2) <= srout(94);
    to_xnor(3) <= srout(93);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n101;
  
  n102: if bits = 102 generate
    to_xnor(1) <= srout(100);
    to_xnor(2) <= srout(35);
    to_xnor(3) <= srout(34);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n102;
  
  n103: if bits = 103 generate
    to_xnor(1) <= srout(93);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n103;
  
  n104: if bits = 104 generate
    to_xnor(1) <= srout(102);
    to_xnor(2) <= srout(93);
    to_xnor(3) <= srout(92);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n104;
  
  n105: if bits = 105 generate
    to_xnor(1) <= srout(88);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n105;
  
  n106: if bits = 106 generate
    to_xnor(1) <= srout(90);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n106;
  
  n107: if bits = 107 generate
    to_xnor(1) <= srout(104);
    to_xnor(2) <= srout(43);
    to_xnor(3) <= srout(41);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n107;
  
  n108: if bits = 108 generate
    to_xnor(1) <= srout(76);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n108;
  
  n109: if bits = 109 generate
    to_xnor(1) <= srout(107);
    to_xnor(2) <= srout(102);
    to_xnor(3) <= srout(101);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n109;
  
  n110: if bits = 110 generate
    to_xnor(1) <= srout(108);
    to_xnor(2) <= srout(97);
    to_xnor(3) <= srout(96);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n110;
  
  n111: if bits = 111 generate
    to_xnor(1) <= srout(100);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n111;
  
  n112: if bits = 112 generate
    to_xnor(1) <= srout(109);
    to_xnor(2) <= srout(68);
    to_xnor(3) <= srout(66);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n112;
  
  n113: if bits = 113 generate
    to_xnor(1) <= srout(103);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n113;
  
  n114: if bits = 114 generate
    to_xnor(1) <= srout(112);
    to_xnor(2) <= srout(32);
    to_xnor(3) <= srout(31);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n114;
  
  n115: if bits = 115 generate
    to_xnor(1) <= srout(113);
    to_xnor(2) <= srout(100);
    to_xnor(3) <= srout(99);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n115;
  
  n116: if bits = 116 generate
    to_xnor(1) <= srout(114);
    to_xnor(2) <= srout(45);
    to_xnor(3) <= srout(44);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n116;
  
  n117: if bits = 117 generate
    to_xnor(1) <= srout(114);
    to_xnor(2) <= srout(98);
    to_xnor(3) <= srout(96);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n117;
  
  n118: if bits = 118 generate
    to_xnor(1) <= srout(84);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n118;
  
  n119: if bits = 119 generate
    to_xnor(1) <= srout(110);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n119;
  
  n120: if bits = 120 generate
    to_xnor(1) <= srout(112);
    to_xnor(2) <= srout(8);
    to_xnor(3) <= srout(1);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n120;
  
  n121: if bits = 121 generate
    to_xnor(1) <= srout(102);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n121;
  
  n122: if bits = 122 generate
    to_xnor(1) <= srout(120);
    to_xnor(2) <= srout(62);
    to_xnor(3) <= srout(61);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n122;
  
  n123: if bits = 123 generate
    to_xnor(1) <= srout(120);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n123;
  
  n124: if bits = 124 generate
    to_xnor(1) <= srout(86);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n124;
  
  n125: if bits = 125 generate
    to_xnor(1) <= srout(123);
    to_xnor(2) <= srout(17);
    to_xnor(3) <= srout(16);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n125;
  
  n126: if bits = 126 generate
    to_xnor(1) <= srout(124);
    to_xnor(2) <= srout(89);
    to_xnor(3) <= srout(88);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n126;
  
  n127: if bits = 127 generate
    to_xnor(1) <= srout(125);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n127;
  
  n128: if bits = 128 generate
    to_xnor(1) <= srout(125);
    to_xnor(2) <= srout(100);
    to_xnor(3) <= srout(98);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n128;
  
  n129: if bits = 129 generate
    to_xnor(1) <= srout(123);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n129;
  
  n130: if bits = 130 generate
    to_xnor(1) <= srout(126);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n130;
  
  n131: if bits = 131 generate
    to_xnor(1) <= srout(129);
    to_xnor(2) <= srout(83);
    to_xnor(3) <= srout(82);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n131;
  
  n132: if bits = 132 generate
    to_xnor(1) <= srout(102);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n132;
  
  n133: if bits = 133 generate
    to_xnor(1) <= srout(131);
    to_xnor(2) <= srout(81);
    to_xnor(3) <= srout(80);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n133;
  
  n134: if bits = 134 generate
    to_xnor(1) <= srout(76);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n134;
  
  n135: if bits = 135 generate
    to_xnor(1) <= srout(123);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n135;
  
  n136: if bits = 136 generate
    to_xnor(1) <= srout(134);
    to_xnor(2) <= srout(10);
    to_xnor(3) <= srout(9);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n136;
  
  n137: if bits = 137 generate
    to_xnor(1) <= srout(115);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n137;
  
  n138: if bits = 138 generate
    to_xnor(1) <= srout(136);
    to_xnor(2) <= srout(130);
    to_xnor(3) <= srout(129);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n138;
  
  n139: if bits = 139 generate
    to_xnor(1) <= srout(135);
    to_xnor(2) <= srout(133);
    to_xnor(3) <= srout(130);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n139;
  
  n140: if bits = 140 generate
    to_xnor(1) <= srout(110);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n140;
  
  n141: if bits = 141 generate
    to_xnor(1) <= srout(139);
    to_xnor(2) <= srout(109);
    to_xnor(3) <= srout(108);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n141;
  
  n142: if bits = 142 generate
    to_xnor(1) <= srout(120);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n142;
  
  n143: if bits = 143 generate
    to_xnor(1) <= srout(141);
    to_xnor(2) <= srout(122);
    to_xnor(3) <= srout(121);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n143;
  
  n144: if bits = 144 generate
    to_xnor(1) <= srout(142);
    to_xnor(2) <= srout(74);
    to_xnor(3) <= srout(73);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n144;
  
  n145: if bits = 145 generate
    to_xnor(1) <= srout(92);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n145;
  
  n146: if bits = 146 generate
    to_xnor(1) <= srout(144);
    to_xnor(2) <= srout(86);
    to_xnor(3) <= srout(85);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n146;
  
  n147: if bits = 147 generate
    to_xnor(1) <= srout(145);
    to_xnor(2) <= srout(109);
    to_xnor(3) <= srout(108);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n147;
  
  n148: if bits = 148 generate
    to_xnor(1) <= srout(120);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n148;
  
  n149: if bits = 149 generate
    to_xnor(1) <= srout(147);
    to_xnor(2) <= srout(39);
    to_xnor(3) <= srout(38);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n149;
  
  n150: if bits = 150 generate
    to_xnor(1) <= srout(96);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n150;
  
  n151: if bits = 151 generate
    to_xnor(1) <= srout(147);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n151;
  
  n152: if bits = 152 generate
    to_xnor(1) <= srout(150);
    to_xnor(2) <= srout(86);
    to_xnor(3) <= srout(85);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n152;
  
  n153: if bits = 153 generate
    to_xnor(1) <= srout(151);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n153;
  
  n154: if bits = 154 generate
    to_xnor(1) <= srout(151);
    to_xnor(2) <= srout(26);
    to_xnor(3) <= srout(24);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n154;
  
  n155: if bits = 155 generate
    to_xnor(1) <= srout(153);
    to_xnor(2) <= srout(123);
    to_xnor(3) <= srout(122);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n155;
  
  n156: if bits = 156 generate
    to_xnor(1) <= srout(154);
    to_xnor(2) <= srout(40);
    to_xnor(3) <= srout(39);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n156;
  
  n157: if bits = 157 generate
    to_xnor(1) <= srout(155);
    to_xnor(2) <= srout(130);
    to_xnor(3) <= srout(129);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n157;
  
  n158: if bits = 158 generate
    to_xnor(1) <= srout(156);
    to_xnor(2) <= srout(131);
    to_xnor(3) <= srout(130);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n158;
  
  n159: if bits = 159 generate
    to_xnor(1) <= srout(127);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n159;
  
  n160: if bits = 160 generate
    to_xnor(1) <= srout(158);
    to_xnor(2) <= srout(141);
    to_xnor(3) <= srout(140);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n160;
  
  n161: if bits = 161 generate
    to_xnor(1) <= srout(142);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n161;
  
  n162: if bits = 162 generate
    to_xnor(1) <= srout(160);
    to_xnor(2) <= srout(74);
    to_xnor(3) <= srout(73);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n162;
  
  n163: if bits = 163 generate
    to_xnor(1) <= srout(161);
    to_xnor(2) <= srout(103);
    to_xnor(3) <= srout(102);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n163;
  
  n164: if bits = 164 generate
    to_xnor(1) <= srout(162);
    to_xnor(2) <= srout(150);
    to_xnor(3) <= srout(149);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n164;
  
  n165: if bits = 165 generate
    to_xnor(1) <= srout(163);
    to_xnor(2) <= srout(134);
    to_xnor(3) <= srout(133);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n165;
  
  n166: if bits = 166 generate
    to_xnor(1) <= srout(164);
    to_xnor(2) <= srout(127);
    to_xnor(3) <= srout(126);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n166;
  
  n167: if bits = 167 generate
    to_xnor(1) <= srout(160);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n167;
  
  n168: if bits = 168 generate
    to_xnor(1) <= srout(165);
    to_xnor(2) <= srout(152);
    to_xnor(3) <= srout(150);
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate n168;

  ninf: if bits >= 169 generate
    to_xnor(1) <= srout(bits-2);
    to_xnor(2) <= '0';
    to_xnor(3) <= '0';
    to_xnor(4) <= '0';
    to_xnor(5) <= '0';
  end generate ninf;
  
  output <= srout(bits-1 downto 0) when reset = '1' else (others => '0');
    
end behav;
