library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

package functions is

    function log2(input : in natural) return natural;
    function nop(input : in std_logic) return std_logic_vector;
    function ha_sum( a: std_logic; b: std_logic) return std_logic;
    function ha_cout(a: std_logic; b: std_logic) return std_logic;
    function fa_sum(a: std_logic; b: std_logic; c_in: std_logic) return std_logic;
    function fa_cout(a: std_logic; b: std_logic; c_in: std_logic) return std_logic;



end package functions;


package body functions is

function log2(input : in natural) return natural is
    variable result : natural := 0;
    variable temp : natural := input;
begin
    while temp > 1 loop
        result := result + 1;
        temp := temp / 2;
    end loop;
    return result;
end function log2;

function nop(input : in std_logic) return std_logic_vector is
    variable result : std_logic_vector(XLEN_1 downto 0) := (31 downto 5 => '0') & b"10011"; -->addi x0, x0, 0.

begin 
    if (input = '1') then 
        result :=  (31 downto 5 => '0') & b"10011";
    else 
        result := (others => '0');
    end if; 
    return result;
end function nop;

function ha_sum( a: std_logic; b: std_logic) return std_logic is
begin
	return a xor b;
end function ha_sum;

function ha_cout(a: std_logic; b: std_logic) return std_logic is
begin
	return a and b;
end function ha_cout;
	
function fa_sum(a: std_logic; b: std_logic; c_in: std_logic) return std_logic is
begin
	return a xor b xor c_in;
end function fa_sum;

function fa_cout(a: std_logic; b: std_logic; c_in: std_logic) return std_logic is
begin
	return (a and b) or (a and c_in) or (b and c_in);
end function fa_cout;

end package body functions;