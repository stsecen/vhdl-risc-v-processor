library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity register_file is
    port (

        i_clk: in std_logic;
        i_regwrite : in std_logic;

        i_rs1 : in std_logic_vector(RLEN_1 downto 0);
        i_rs2 : in std_logic_vector(RLEN_1 downto 0);
        i_rd : in std_logic_vector(RLEN_1 downto 0);

        i_wrdata : in std_logic_vector(XLEN_1 downto 0);

        o_data1 : out std_logic_vector(XLEN_1 downto 0);
        o_data2 : out std_logic_vector(XLEN_1 downto 0)

    );
end entity register_file;

architecture behavioral of register_file is
    type regfile is array (0 to XLEN_1) of std_logic_vector(XLEN_1 downto 0);
    signal r_rf : regfile := (others => (others => '0'));
    signal s_data1, s_data2 : std_logic_vector(XLEN_1 downto 0) := (others => '0');

begin

    register_file: process(i_clk)
    begin
        if (rising_edge(i_clk)) then 
            s_data1 <= r_rf(to_integer(unsigned(i_rs1)));
            s_data2 <= r_rf(to_integer(unsigned(i_rs2)));
                if (i_RegWrite = '1') then
                    if (i_rd /= "00000") then 
                        r_rf(to_integer(unsigned(i_rd))) <= i_wrdata;
                    end if;
                end if;
        end if;
    end process register_file;
    
    o_data1 <= s_data1;
    o_data2 <= s_data2;
    
end architecture behavioral;