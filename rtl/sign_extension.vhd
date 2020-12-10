library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all; 

entity sign_extension is
    port (

        i_instruction : in std_logic_vector(XLEN_1 downto 0);
        o_immediate : out std_logic_vector(XLEN_1 downto 0)
        
    );
end entity sign_extension;

architecture behavioral of sign_extension is

    signal s_opcode : std_logic_vector(6 downto 0) := (others => '0');
    signal s_immediate : std_logic_vector(XLEN_1 downto 0) := (others => '0');

begin
    
    s_opcode <= i_instruction(6 downto 0);

    extension: process(s_opcode, i_instruction)
    begin

        s_immediate <= (others => '0');

        case s_opcode is

            when OPCODE_LUI =>

                s_immediate <= i_instruction(31 downto 12) & X"000";

            when OPCODE_AUIPC =>

                s_immediate <= i_instruction(31 downto 12) & X"000";

            when OPCODE_JALR =>

                if i_instruction(31) = '1' then
                    s_immediate <= X"FFFFF" & i_instruction(31 downto 20);
                else
                    s_immediate <= X"00000" & i_instruction(31 downto 20);
                end if;

            when OPCODE_JAL =>    

                if i_instruction(31) = '1' then
                    s_immediate <= X"111" & i_instruction(19 downto 12) & i_instruction(20) & i_instruction(30 downto 21) & '0';
                else
                    s_immediate <= X"000" & i_instruction(19 downto 12) & i_instruction(20) & i_instruction(30 downto 21) & '0';
                end if;

            when OPCODE_BRANCH =>

                if (i_instruction(31) = '1') then
                    s_immediate <= X"FFFFF" & i_instruction(7) & i_instruction(30 downto 25) & i_instruction(11 downto 8) & '0';
                else
                    s_immediate <= X"00000" & i_instruction(7) & i_instruction(30 downto 25) & i_instruction(11 downto 8) & '0';
                end if;

            when OPCODE_LOAD =>

                if (i_instruction(31) = '1') then
                    s_immediate <= X"FFFF"& "1111" & i_instruction(31 downto 20);
                else
                    s_immediate <= X"0000" & "0000" & i_instruction(31 downto 20);
                end if;

            when OPCODE_STORE =>

                if i_instruction(31) = '1' then
                    s_immediate <= X"FFFF" & "1111" & i_instruction(31 downto 25) & i_instruction(11 downto 7);
                else
                    s_immediate <= X"0000" & "0000" & i_instruction(31 downto 25) & i_instruction(11 downto 7);
                end if;

            when OPCODE_IMM =>

                if i_instruction(31) = '1' then
                    s_immediate <= X"FFFFF" & i_instruction(31 downto 20);
                else
                    s_immediate <= X"00000" & i_instruction(31 downto 20);
                end if;  

            when others =>

                s_immediate <= (others => '0');

        end case;
        
    end process extension;
    
    o_immediate <= s_immediate;
    
end architecture behavioral;