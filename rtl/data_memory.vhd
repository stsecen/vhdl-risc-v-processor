		--> data _ memory 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;
use work.functions.all;

entity data_memory is
	generic(
        MEMORY_SIZE : positive := 1024;
        DATA_SIZE : positive := 32
        );
	port(
		i_clk : in std_logic;
		i_rst : in std_logic;

		i_wb_address : in  std_logic_vector(log2(MEMORY_SIZE) - 1 downto 0);
		i_wb_data : in  std_logic_vector(DATA_SIZE-1 downto 0);
		i_wb_cyc : in  std_logic;
		i_wb_stb : in  std_logic;
		i_wb_we : in  std_logic;
		i_wb_sel : in std_logic_vector(DATA_SIZE/8-1 downto 0);
		
        o_wb_data : out std_logic_vector(DATA_SIZE-1 downto 0);
		o_wb_ack : out std_logic
	);
end entity data_memory;

architecture behavioral of data_memory is

	type memory is array(0 to (MEMORY_SIZE / 4) - 1) of std_logic_vector(DATA_SIZE-1 downto 0);
    signal r_memory : memory := (others => (others => '0'));
    
   signal s_byte_0 : std_logic_vector(7 downto 0) := (others => '0');
   signal s_byte_1 : std_logic_vector(7 downto 0) := (others => '0');
   signal s_byte_2 : std_logic_vector(7 downto 0) := (others => '0');
   signal s_byte_3 : std_logic_vector(7 downto 0) := (others => '0');

	type state_type is (st_idle, st_ack );
	signal state : state_type;

	signal s_ack : std_logic;

begin

	WISHBONE_BUS: process(i_clk)
	begin
		if rising_edge(i_clk) then
            if i_rst = '1' then 
                s_ack <= '0';
                state <= st_idle;
			else
				if i_wb_cyc = '1' then
					case state is
						when st_idle =>
                            if i_wb_stb = '1' and i_wb_we= '1' then

                                if i_wb_sel(0) = '1' then
                                    s_byte_0 <= i_wb_data(7 downto 0);
                                end if;
                                
                                if i_wb_sel(1) = '1' then
                                    s_byte_1<= i_wb_data(15 downto 8);
                                end if;
                                
                                if i_wb_sel(2) = '1' then
                                    s_byte_2 <= i_wb_data(23 downto 16);
                                end if;
                                
                                if i_wb_sel(3) = '1' then
                                    s_byte_3 <= i_wb_data(31 downto 24);
                                end if;

                                r_memory(to_integer(unsigned(i_wb_address))) <= s_byte_3 & s_byte_2 & s_byte_1 & s_byte_0;

								s_ack <= '1';
                                state <= st_ack;
                                
							elsif i_wb_stb = '1' then
								o_wb_data <= r_memory(to_integer(unsigned(i_wb_address(i_wb_address'left downto 0))));
								s_ack <= '1';
                                state <= st_ack;
                            else 
                                state <= st_idle;
                                s_ack <= '0';
							end if;
						when st_ack =>
							if i_wb_stb = '0' then
								s_ack <= '0';
								state <= st_idle;
							end if;
					end case;
				else
					state <= st_idle;
					s_ack <= '0';
				end if;
			end if;
		end if;
    end process WISHBONE_BUS;
    
    o_wb_ack <= s_ack and i_wb_stb;

end architecture behavioral;	