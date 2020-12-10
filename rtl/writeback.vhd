library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity writeback is
    port (
        i_clk : in std_logic;

        i_wb_rd_address : in std_logic_vector(RLEN_1 downto 0);
        i_load_data : in std_logic_vector(XLEN_1 downto 0);
        i_alu_result : in std_logic_vector(XLEN_1 downto 0);

        i_memtoreg : in std_logic;
        i_regwrite : in std_logic; 

        o_regwrite : out std_logic;
        o_wb_data : out std_logic_vector(XLEN_1 downto 0);
        o_wb_rd_address : out std_logic_vector(RLEN_1 downto 0)

    );
end entity writeback;

architecture behavioral of writeback is
    
    signal s_writeback_data : std_logic_vector(XLEN_1 downto 0);

begin
    
    wb_mux: process(i_memtoreg, i_alu_result,i_load_data)
    begin
        if (i_memtoreg = '0') then 
            s_writeback_data <= i_alu_result; --> register-register operations 
        elsif (i_memtoreg = '1') then
            s_writeback_data <= i_load_data;  --> load instructions 
        else  
            s_writeback_data <= (others => '0');
        end if; 
    end process wb_mux;
    
    writeback_stage: process(i_clk)
    begin
        if rising_edge(i_clk) then
                o_regwrite <= i_regwrite;
                o_wb_data <= s_writeback_data;
                o_wb_rd_address <= i_wb_rd_address;
        end if;
    end process writeback_stage;
    
end architecture behavioral;