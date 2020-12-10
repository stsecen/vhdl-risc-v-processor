library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;
use work.components.all;

entity top_module is
    generic (
        TEST_ENABLE : boolean := true
    );
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;

        o_alu_test : out std_logic_vector(XLEN_1 downto 0);
        o_test : out std_logic_vector(XLEN_1 downto 0)
        
    );
end entity top_module;

architecture behavioral of top_module is
    
    signal s_instruction : std_logic_vector(XLEN_1 downto 0);
    signal s_pc : std_logic_vector(XLEN_1 downto 0);
    signal s_address : std_logic_vector(XLEN_1 downto 0);
    signal s_data_out : std_logic_vector(XLEN_1 downto 0);
    signal s_data_in : std_logic_vector(XLEN_1 downto 0);
    signal s_datamem_we : std_logic; 
    signal s_datamem_ack : std_logic;

begin

    cpu_core : component core 
        port map(

            i_clk => i_clk,
            i_rst => i_rst,
            i_instruction => s_instruction,
            o_instruction_address => s_pc,
            o_datamem_address => s_address,
            o_datamem_store_data => s_data_out,     
            i_datamem_load_data => s_data_in,
            i_datamem_ack => s_datamem_ack,
            o_wb_we => s_datamem_we,
            o_alu_result => o_alu_test

        );

    imem_bram : component instruction_memory_bram
        port map(
            i_clk => i_clk,
            i_instruction_address => s_pc,
            o_instruction => s_instruction
        );

    dmem_bram : component data_memory_bram
        port map(
            
            i_clk => i_clk, 
            i_datamem_we => s_datamem_we,
            i_datamem_address => s_address,
            i_datamem_store_data => s_data_out,
            o_datamem_load_data => s_data_in,
            o_datamem_ack => s_datamem_ack

        );

    ram_test: if TEST_ENABLE generate 
        signal s_cnt : integer range 0 to 4096 := 4096;
    begin 
        data_mem: process(i_clk)
        begin
            if rising_edge(i_clk) then
                s_address <= std_logic_vector(to_unsigned(s_cnt,32));
                s_cnt <= s_cnt - 1; 
                if s_cnt = 0 then 
                    s_address <= (others => '0');
                end if;
            end if;
        end process data_mem;
        o_test <= s_data_in; 
    end generate ram_test;

    ram_not_test: if not TEST_ENABLE generate 
        o_test <= (others => 'Z');
    end generate ram_not_test;
    
end architecture behavioral;