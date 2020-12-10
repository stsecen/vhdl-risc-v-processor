-- Standard integer multiplication
-- and division instruction extension
-- which is named "M" and contains
-- instructions that multiply or divide
-- RV32M Standard Extension for Integer Multiply and Divide

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mul_unit is
 port
 (
     i_rs1: in std_logic_vector(31 downto 0); -- multiplicand
     i_rs2: in std_logic_vector(31 downto 0); -- multiplier
     --i_clk: in std_logic; 
     i_mul_op: in std_logic_vector(2 downto 0);
     --o_busy: out std_logic; 
     o_divisor_zero : out std_logic;
     o_result: out std_logic_vector(31 downto 0)
 );
end entity mul_unit;
architecture behaviorel of mul_unit is
    signal s_rs1 : std_logic_vector(31 downto 0);
    signal s_rs2 : std_logic_vector(31 downto 0);
    signal s_mul_op : std_logic_vector(2 downto 0);
    signal s_divisor_zero : std_logic;
    signal s_result : std_logic_vector(65 downto 0);
    signal s_real_result :  std_logic_vector(31 downto 0);
    
begin
        s_rs1 <= i_rs1;
        s_rs2 <= i_rs2;
        s_mul_op <= i_mul_op;
        
 
       with s_rs2 select
            s_divisor_zero <= '1' when x"00000000",
                              '0' when others;

        
        process(s_rs1, s_rs2, s_mul_op)
        begin
        
        s_result <= (others => '0');
        s_real_result <= (others => '0');
        
        case s_mul_op is
            when "000" => --MUL
                s_result(63 downto 0) <= std_logic_vector( (unsigned(s_rs1)*unsigned(s_rs2) ));
                s_real_result <= s_result(31 downto 0);
                
            when "001" => --MULH
                s_result(63 downto 0) <= std_logic_vector(signed(s_rs1)*signed(s_rs2));
                s_real_result <= s_result(63 downto 32);
                
            when "010" => --MULHU
                s_result(63 downto 0) <= std_logic_vector(unsigned(s_rs1)*unsigned(s_rs2));
                s_real_result <= s_result(63 downto 32);
                
            when "011" => --MULHSU
                if( s_rs1(31) = '1' )then
                    s_result <= std_logic_vector('1'&(unsigned(s_rs1))*('0'&unsigned(s_rs2)));
                    s_real_result <= s_result(64 downto 33);
                else
                    s_result <= std_logic_vector('0'&(unsigned(s_rs1))*('0'&unsigned(s_rs2)));
                    s_real_result <= s_result(64 downto 33);
                end if;
            
            when "100" => -- DIV
                if s_divisor_zero = '1' then
                    s_real_result <= x"00000000";
                else
                    s_real_result <= std_logic_vector(signed(s_rs1)/signed(s_rs2));
                end if;
            
            when "101" => -- DIVU
                if s_divisor_zero = '1' then
                    s_real_result <= x"00000000";
                else
                    s_real_result <= std_logic_vector(unsigned(s_rs1)/unsigned(s_rs2));
                end if;
            
            when "110" => --REM
                if s_divisor_zero = '1' then
                    s_real_result <= x"00000000";
                else
                    s_real_result <= std_logic_vector(signed(s_rs1) rem to_integer(unsigned(s_rs2)));
                end if;
            
            when "111" => -- REMU
                if s_divisor_zero = '1' then
                    s_real_result <= x"00000000";
                else
                    s_real_result <= std_logic_vector(unsigned(s_rs1) rem to_integer(unsigned(s_rs2)));
                end if;
            
            when others =>
            s_real_result <= (others => '0');
            end case;
            
        end process;
        o_result <= s_real_result;
        o_divisor_zero <= s_divisor_zero;
 end architecture behaviorel;