--> memory stage <--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

entity memory_stage is
    port (
        i_clk : in std_logic;

        i_stall : in std_logic;

        --> destination registers input 
        i_regwrite : in std_logic; 
        i_mem_rd_address : in std_logic_vector(RLEN_1 downto 0);
        i_alu_result : in std_logic_vector(XLEN_1 downto 0);

        --> memory control signals 
        i_memread : in std_logic;
        i_memtoreg : in std_logic;
        i_load_op : in std_logic_vector(2 downto 0); 

        --> load signals 
        i_dmem_data : in std_logic_vector(XLEN_1 downto 0);     
        
        --> output signals 

        o_load_rd_data : out std_logic_vector(XLEN_1 downto 0); 
        o_alu_result : out std_logic_vector(XLEN_1 downto 0);
        o_mem_rd_address : out std_logic_vector(RLEN_1 downto 0);
        o_regwrite : out std_logic;
        o_memtoreg : out std_logic;
        o_writeback_en : out std_logic        

    );
end entity memory_stage;

architecture behavioral of memory_stage is
    
    signal s_loading_data : std_logic_vector(XLEN_1 downto 0);

begin

    loading: process(i_memread, i_load_op, i_dmem_data, i_regwrite, i_alu_result)
    begin
        if (i_memread = '1') then  --> load instructions operations 
            if (i_load_op = LOAD_LB) then 
                if ( i_dmem_data(7) = '1') then 
                    s_loading_data <= x"111111" & i_dmem_data(7 downto 0);
                else 
                    s_loading_data <= x"000000" & i_dmem_data(7 downto 0);
                end if; 
            elsif (i_load_op = LOAD_LH) then 
                if (i_dmem_data(15) = '1') then 
                    s_loading_data <=  x"1111" & i_dmem_data(15 downto 0);
                else 
                    s_loading_data <= x"0000" & i_dmem_data(15 downto 0);
                end if; 
            elsif (i_load_op = LOAD_LBU) then
                s_loading_data <= x"000000" & i_dmem_data(7 downto 0);
            elsif (i_load_op = LOAD_LHU) then
                s_loading_data <= x"0000" & i_dmem_data(15 downto 0);
            elsif (i_load_op = LOAD_LW) then
                s_loading_data <= i_dmem_data; 
            else 
                s_loading_data <= (others => '0');
            end if; 
        elsif (i_memread = '0' and i_regwrite = '1') then 
            s_loading_data <= i_alu_result; --> garatueed the register-register or register-imm operations 
        else
            s_loading_data <= (others => '0');
        end if; 

    end process loading;
    
    
    st_memory_register: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_stall = '0') then
                o_load_rd_data <=  s_loading_data;
                o_regwrite <= i_regwrite; 
                o_alu_result <= i_alu_result;
                o_mem_rd_address <= i_mem_rd_address;
                o_memtoreg <= i_memtoreg;
                o_writeback_en <= '1';
            else 
                o_writeback_en <= '0';
                o_regwrite <= '0'; 
            end if;
        end if;
    end process st_memory_register;

    
end architecture behavioral;