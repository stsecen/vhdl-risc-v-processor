--> instruction stage <--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity instruction_fetch is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;

        --> instruction memory connections
        i_instruction_memory_data : in std_logic_vector(XLEN_1 downto 0); --> 32-bit instruction 
        o_instruction_memory_address : out std_logic_vector(XLEN_1 downto 0); --> its program counter value. 
        
        --> control input
        i_stall : in std_logic;
        i_flush : in std_logic;
        i_branch : in std_logic;

        --> program counter mux input
        i_branch_target : in std_logic_vector(XLEN_1 downto 0);

        --> outputs 

        o_instruction    : out std_logic_vector(31 downto 0);
		o_pc : out std_logic_vector(31 downto 0);
		o_instruction_ready   : out std_logic

    );
end entity instruction_fetch;

architecture behavioral of instruction_fetch is

    signal s_pc: std_logic_vector(31 downto 0);
	signal s_pc_next: std_logic_vector(31 downto 0);
    signal s_cancel: std_logic;
    
begin
    
    set_pc: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_flush or i_rst) = '1' then 
                s_pc <= PC_RESET_ADDRESS;
                s_cancel <= '0';
            elsif i_stall =  '0' then
                if i_branch = '1'  then
                    s_cancel <= '1';
                    s_pc <= s_pc_next;
                elsif s_cancel = '1'  then
                    s_cancel <= '0';
                else
                    s_pc <= s_pc_next;
                end if;
            end if;
        end if;
    end process set_pc;

    calc_next_pc: process(i_stall, i_branch, i_branch_target, s_pc, s_cancel)
    begin
        if i_branch = '1' then 
            s_pc_next <= i_branch_target; --> branch target is next value of pc 
        elsif  i_stall = '0' and s_cancel = '0' then
            s_pc_next <= std_logic_vector(unsigned(s_pc) + 4);
        else
            s_pc_next <= s_pc; --> if any stall or cancel process occur then pc value is stayed old value. 
        end if;
    end process calc_next_pc;

    o_instruction_memory_address <= s_pc_next;
    o_instruction <= i_instruction_memory_data;
    o_pc <= s_pc_next;
    o_instruction_ready <= not(i_stall) and not(s_cancel);

end architecture behavioral; 