
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.constants.all;

entity data_memory_bram is

port(
    i_clk  : in  std_logic;

    i_datamem_we   : in  std_logic;
    i_datamem_address : in  std_logic_vector(XLEN_1 downto 0);
    i_datamem_store_data  : in  std_logic_vector(XLEN_1 downto 0);
    o_datamem_load_data : out std_logic_vector(XLEN_1 downto 0);
    o_datamem_ack : out std_logic
);
end entity data_memory_bram;

architecture behavioral of data_memory_bram is
    type ram_type is array(0 to 2**12) of std_logic_vector(XLEN_1 downto 0);
    signal RAM : ram_type := (others => (others => '0'));
begin

    process(i_clk) is
    begin
        if rising_edge(i_clk) then
            if i_datamem_we = '1' then
                RAM(to_integer(unsigned(i_datamem_address))) <= i_datamem_store_data;
                o_datamem_ack <= '1';
            end if;
            o_datamem_load_data <= RAM(to_integer(unsigned(i_datamem_address)));
            o_datamem_ack <= '1';
        end if;
    end process;
    

end behavioral;