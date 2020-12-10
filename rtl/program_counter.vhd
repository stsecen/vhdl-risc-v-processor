--> Program counter => The register containing the address of the instruction in the program being executed.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work; 
use work.constants.all;

entity program_counter is
    port (
        --> clock and reset signal for program counter.
        i_clk : in std_logic;
        i_rst : in std_logic;
        --> inputs signals. 
        i_pc : in std_logic_vector(XLEN_1 downto 0);
        --> output signal for next program counter value for selecting address for next instruction.
        o_pc : out std_logic_vector(XLEN_1 downto 0)
        
    );
end entity program_counter;

architecture behavioral of program_counter is
    
    signal s_pc_next : unsigned(XLEN_1 downto 0) := (others => '0');
    signal s_cnt : integer range 0 to 1 := 0; 
    
begin
    
    o_pc <= std_logic_vector(s_pc_next);

    pc_register: process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            s_pc_next <= (others => '0');
            s_cnt <= 0;
        elsif rising_edge(i_clk) then
            if s_cnt = 0 then 
                s_pc_next <= (others => '0');
                s_cnt <= 1;
            else 
                s_pc_next <= unsigned(i_pc);
            end if;
        end if;
    end process pc_register;
end architecture behavioral;