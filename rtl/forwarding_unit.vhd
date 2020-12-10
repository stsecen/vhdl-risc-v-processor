--> forwarding unit 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity forwarding_unit is
    port (
        
        i_ex_mem_register_rd    : in std_logic_vector(4 downto 0);
        i_mem_wb_register_rd    : in std_logic_vector(4 downto 0);
        
        i_ex_mem_regwrite       : in std_logic; 
        i_mem_wb_regwrite       : in std_logic;

        i_id_ex_register_rs1    : in std_logic_vector(4 downto 0);
        i_id_ex_register_rs2    : in std_logic_vector(4 downto 0);

        o_forward_a             : out std_logic_vector(1 downto 0);
        o_forward_b             : out std_logic_vector(1 downto 0)
                
    );
end entity forwarding_unit;

architecture behavioral of forwarding_unit is
    
begin
    
    forwarding: process(i_ex_mem_register_rd,
                        i_mem_wb_register_rd,
                        i_ex_mem_regwrite,
                        i_mem_wb_regwrite,
                        i_id_ex_register_rs1,
                        i_id_ex_register_rs2)
    begin
            
        if (i_ex_mem_regwrite = '1' and i_ex_mem_register_rd = i_id_ex_register_rs1 and i_id_ex_register_rs1 /= b"00000") then 
            o_forward_a <= "10"; --> forward from memory stage, the first alu operand is forwarded from the prior alu result.
        elsif (i_mem_wb_regwrite = '1' and i_mem_wb_register_rd = i_id_ex_register_rs1 and i_id_ex_register_rs1 /= b"00000") then 
            o_forward_a <= "01"; --> forward from writeback stage, the first alu operand is forwarded from data memory or an earlier alu result. 
        else
            o_forward_a <= "00"; --> no forwarding, the first alu operand comes from the register file.
        end if;

        if (i_ex_mem_regwrite = '1' and i_ex_mem_register_rd = i_id_ex_register_rs2 and i_id_ex_register_rs2  /= "00000") then
            o_forward_b <= "10"; --> forward from memory stage, the second alu operand is forwarded from the prior alu result.
        elsif (i_mem_wb_regwrite = '1' and i_mem_wb_register_rd = i_id_ex_register_rs2 and i_id_ex_register_rs2 /= "00000") then
            o_forward_b <= "01"; --> forward from writeback stage, the second alu operand is forwarded from data memory or an earlier alu result.
        else
            o_forward_b <= "00"; --> no forwarding, the second alu operand comes from the register file.
        end if;

    end process forwarding;
        
    
end architecture behavioral; 