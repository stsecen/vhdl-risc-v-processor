library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity alu_mux is
    port (
        
        --> inputs 
        i_data1 : in std_logic_vector(XLEN_1 downto 0);
        i_data2 : in std_logic_vector(XLEN_1 downto 0);
        i_pc    : in std_logic_vector(XLEN_1 downto 0);
        i_imm   : in std_logic_vector(XLEN_1 downto 0);


        --> control signal 
        i_alu_src : in std_logic_vector(2 downto 0);

        --> output signal 
        o_data1 : out std_logic_vector(XLEN_1 downto 0);
        o_data2 : out std_logic_vector(XLEN_1 downto 0)
        
        
    );
end entity alu_mux;

architecture behavioral of alu_mux is
    
    signal s_zero : std_logic_vector(XLEN_1 downto 0) := (others => '0');
    signal s_four : std_logic_vector(XLEN_1 downto 0) := (2 => '1', others => '0'); 

begin
    
    alu_src: process(i_data1,i_data2,i_pc,i_imm,i_alu_src,s_zero,s_four)
    begin
        case i_alu_src is
            when ALU_SRC_LUI =>
                o_data1 <= s_zero; 
                o_data2 <= i_imm;
            when ALU_SRC_AUIPC =>
                o_data1 <= i_pc; 
                o_data2 <= i_imm;
            when ALU_SRC_JAL =>
                o_data1 <= s_four; 
                o_data2 <= i_pc;
            when ALU_SRC_ARTH =>
                o_data1 <= i_data1; 
                o_data2 <= i_data2;
            when ALU_SRC_IMM =>
                o_data1 <= i_data1; 
                o_data2 <= i_imm;
            when others =>
                o_data1 <= s_zero; 
                o_data2 <= s_zero;
        end case;
    end process alu_src;
    
end architecture behavioral;