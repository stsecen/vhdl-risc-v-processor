library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity instruction_memory_bram is

port(
    i_clk  : in  std_logic;

    i_instruction_address  : in  std_logic_vector(XLEN_1 downto 0);
    o_instruction : out std_logic_vector(XLEN_1 downto 0)
);
end entity instruction_memory_bram;

architecture behavioral of instruction_memory_bram is
    type ram_type is array(0 to 2**10) of std_logic_vector(XLEN_1 downto 0);
    signal RAM : ram_type := (others => (others => '0'));
begin

    process(i_clk) is
    begin
        if rising_edge(i_clk) then
            o_instruction <= RAM(to_integer(unsigned(i_instruction_address)));
        end if;
    end process;

end behavioral;