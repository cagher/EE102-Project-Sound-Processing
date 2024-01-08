library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;
use IEEE.numeric_std.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

package normsqfind is



function normsq(n1: std_logic_vector(63 downto 0)) return std_logic_vector;



end package;

package body normsqfind is

function normsq(n1: std_logic_vector(63 downto 0)) return std_logic_vector is

variable normsquare : std_logic_vector(63 downto 0);
begin
normsquare := (n1(31 downto 0) * n1(31 downto 0)) + (n1(63 downto 32) * n1 (63 downto 32));
return normsquare;
end normsq;



end package body;

