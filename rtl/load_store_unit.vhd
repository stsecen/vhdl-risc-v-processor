library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity load_store_unit is
    port (
        
        i_rs2 : in std_logic_vector(XLEN_1 downto 0);
        
        i_store_op : in std_logic_vector(1 downto 0); --> store instructions
        i_load_op : in  std_logic_vector(2 downto 0); --> load  instructions 

        i_address : in  std_logic_vector(XLEN_1 downto 0); --> memory adress which calculated in ALU 
        
        o_wb_we : out std_logic;
        o_wb_sel : out std_logic_vector(3 downto 0);
        o_address : out std_logic_vector(XLEN_1 downto 0);
        o_data : out std_logic_vector(XLEN_1 downto 0);
        o_load_type : out  std_logic_vector(2 downto 0)
    );
end entity load_store_unit;

architecture behavioral of load_store_unit is
    
    signal s_b0, s_b1, s_b2, s_b3 : std_logic_vector(7 downto 0) := (others => '0');

begin
    
    s_b0 <= i_rs2(7 downto 0);
    s_b1 <= i_rs2(15 downto 8);
    s_b2 <= i_rs2(23 downto 16);
    s_b3 <= i_rs2(31 downto 24);
    o_address <= i_address(31 downto 2) & "00"; 
    o_load_type <= i_load_op;
     
    store: process(i_store_op, i_address, s_b3, s_b2, s_b1, s_b0)
    begin
        o_wb_sel <= "0000";
        case i_store_op is
            when STORE_BYTE =>
                if (s_b0(7) = '1') then 
                    o_data <= x"111111" & s_b0;
                else 
                    o_data <= x"000000" & s_b0;
                end if;
                
                if ( i_address(1 downto 0) = "00") then 
                    o_wb_sel <= "0001";
                elsif ( i_address(1 downto 0) = "01" ) then
                    o_wb_sel <= "0010";
                elsif ( i_address(1 downto 0) = "10" ) then
                    o_wb_sel <= "0100";
                elsif ( i_address(1 downto 0) = "11" ) then
                    o_wb_sel <= "1000";
                end if;
                o_wb_we <= '1';
            when STORE_HALF =>
                if (s_b1(7) = '1') then
                    o_data <= x"1111" & s_b1 & s_b0;
                else 
                    o_data <= x"0000" & s_b1 & s_b0;
                end if;

                if ( i_address(1 downto 0) = "00") then 
                    o_wb_sel <= "0011";
                elsif ( i_address(1 downto 0) = "01" ) then
                    o_wb_sel <= "1100";
                end if;
                o_wb_we <= '1';
            when STORE_WORD =>
                    o_data <= s_b3 &s_b2 & s_b1 & s_b0;
                    o_wb_sel <= "1111";
                    o_wb_we <= '1';
            when others =>
                o_data <= (others => '0');
                o_wb_sel <= "0000";
                o_wb_we <= '0';
        end case;
        
    end process store;    
     
end architecture behavioral;