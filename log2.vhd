package log2 is
  function log2ceil(x : natural) return natural;
  function log2floor(x : natural) return natural;
end log2;

package body log2 is

  function log2ceil(x : natural) return natural is
  begin
    for i in 0 to 32 loop
      if 2**i > x then
        return i;
      end if;
    end loop;
    return 32;
  end function;

  function log2floor(x : natural) return natural is
  begin
    for i in 1 to 33 loop
      if 2**i > x then
        return i-1;
      end if;
    end loop;
    return 32;
  end function;

end log2;
