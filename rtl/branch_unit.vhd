library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity branch_unit is
    port (
        i_jal : in std_logic;
        i_jalr : in std_logic;
        i_branch_op : in std_logic_vector(2 downto 0);
        i_alu_sub : in std_logic_vector(XLEN_1 downto 0);
        
        i_pc : in std_logic_vector(XLEN_1 downto 0);
        i_rs1 : in std_logic_vector(XLEN_1 downto 0);
        i_offset : in std_logic_vector(XLEN_1 downto 0); 

        o_branch_need : out std_logic;
        o_branch_target : out std_logic_vector(XLEN_1 downto 0)
    );
end entity branch_unit;

architecture Behavioral of branch_unit is
    signal s_alu_sub : unsigned(31 downto 0);
    signal s_branch_target : std_logic_vector(31 downto 0);
    signal s_jalr_target : std_logic_vector(31 downto 0);
    signal s_branch_need : std_logic := '0';
begin
    
    s_alu_sub <= unsigned(i_alu_sub);
    o_branch_need <= s_branch_need and (i_jal or i_jalr);
    o_branch_target <= std_logic_vector(s_branch_target); 
    s_jalr_target <= std_logic_vector(signed(i_rs1) + signed(i_offset)) and x"FFFFFFFE";
    
    comparison: process(i_branch_op, s_alu_sub)
    begin   
        case  i_branch_op is
            when BEQ => 
                if (s_alu_sub = 0) then 
                    s_branch_need <= '1';
                else 
                    s_branch_need <= '0';
                end if;
            when BNE =>
                if (s_alu_sub /= 0) then 
                    s_branch_need <= '1';
                else 
                    s_branch_need <= '0';
                end if;
            when BLT =>
                if (s_alu_sub(31) = '1') then 
                    s_branch_need <= '1';
                else 
                    s_branch_need <= '0';
                end if;
            when BGE =>
                if (s_alu_sub(31) = '0') then 
                    s_branch_need <= '1';
                else 
                    s_branch_need <= '0';
                end if;
            when BLTU =>
                if (s_alu_sub < 0) then 
                    s_branch_need <= '1';
                else 
                    s_branch_need <= '0';
                end if;
            when BGEU =>
                if (s_alu_sub > 0 or s_alu_sub = 0) then 
                    s_branch_need <= '1';
                else 
                    s_branch_need <= '0';
                end if;
            when others =>
                s_branch_need <= '0';
        
        end case;
    end process comparison;
    
    branch_target: process(s_jalr_target,s_branch_need, i_jal, i_pc, i_offset, i_jalr, i_rs1)
    begin
        if (s_branch_need = '1' or i_jal = '1') then 
            s_branch_target <= std_logic_vector((signed(i_pc) + signed(i_offset)));
        elsif (i_jalr = '1') then 
            s_branch_target <= (s_jalr_target);
        else 
            s_branch_target <= std_logic_vector(to_unsigned(4, 32) + unsigned((i_pc)));
        end if; 
    end process branch_target;
    
end architecture Behavioral;