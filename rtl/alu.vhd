library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity alu is
    port (
        
        i_a : in std_logic_vector(XLEN_1 downto 0);
        i_b : in std_logic_vector(XLEN_1 downto 0);
        i_alu_op  : in std_logic_vector(3 downto 0);

        o_result : out std_logic_vector(XLEN_1 downto 0)
    );
end entity alu;

architecture behavioral of alu is
    
begin
    
    alunit: process(i_a, i_b, i_alu_op)
    begin
        case i_alu_op is
            when ALU_AND =>
                o_result <= (i_a and i_b); 
            when ALU_OR =>
                o_result <= (i_a or i_b);
            when ALU_XOR =>
                o_result <= (i_a xor i_b); 
            when ALU_ADD =>
                o_result <= std_logic_vector(signed(i_a) + signed(i_b)); 
            when ALU_SUB =>
                o_result <= std_logic_vector(signed(i_a) - signed(i_b)); 
            when ALU_USUB =>
                o_result <= std_logic_vector(unsigned(i_a) - unsigned(i_b));
            when ALU_SLT =>
                if  (signed(i_a) < signed(i_b)) then 
                    o_result <= (0 => '1', others => '0');
                else
                    o_result <= (others => '0');
                end if;
            when ALU_SLTU =>
                if  (unsigned(i_a) < unsigned(i_b)) then 
                    o_result <= (0 => '1', others => '0');
                else
                    o_result <= (others => '0');
                end if;
            when ALU_SLL =>
                o_result <= std_logic_vector(shift_left(unsigned(i_a), to_integer(unsigned(i_b(4 downto 0)))));
            when ALU_SRL =>
                o_result <= std_logic_vector(shift_right(unsigned(i_a), to_integer(unsigned(i_b(4 downto 0)))));
            when ALU_SRA =>
                o_result <= std_logic_vector(shift_right(signed(i_a), to_integer(unsigned(i_b(4 downto 0)))));
            when others =>
                o_result <= (others => '0');
        end case;        
    end process alunit;
    
    
end architecture behavioral;