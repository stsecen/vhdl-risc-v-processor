library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants.all;

entity csr is
    port (
    
        i_clk : in std_logic;
        i_rst : in std_logic; 
        i_invalid_instruction : in std_logic;

        i_rs1_address : in std_logic_vector(RLEN_1 downto 0);
        i_rd_address : in std_logic_vector(RLEN_1 downto 0);
        i_csr_op : in std_logic_vector(1 downto 0);
        i_instruction_invalid : in std_logic;

        i_exception_cause : in std_logic_vector(5 downto 0);
        i_execption_inst_misaling : in std_logic_vector(XLEN_1 downto 0);
        i_exception_ie : in std_logic;
        i_exception_ie1 : in std_logic; 

        i_rs1_data : in std_logic_vector(XLEN_1 downto 0);
        i_current_instruction : in std_logic_vector(XLEN_1 downto 0);

        o_csr_data_out : out std_logic_vector(XLEN_1 downto 0)
        
    );
end entity csr;

architecture behavioral of csr is

    signal s_csr_address : std_logic_vector(11 downto 0);
    signal s_csr_bit_select : std_logic_vector(31 downto 0);
    signal s_csr_read : std_logic_vector(31 downto 0);
    signal s_csr_write : std_logic_vector(31 downto 0);
    signal s_nothing : std_logic_vector(31 downto 0);

    signal s_timer : unsigned(63 downto 0);
    -- timer signals 
    signal s_mtime : std_logic_vector(31 downto 0);
    signal s_mtimeh : std_logic_vector(31 downto 0);
    signal s_mtimecmp : std_logic_vector(31 downto 0);

    --> exception cause signal 
    signal s_mcause : std_logic_vector(5 downto 0) := (others => '0');
    signal s_mstatus : std_logic_vector(XLEN_1 downto 0) := (others => '0');
    signal s_mtvec : std_logic_vector(XLEN_1-2 downto 0) := (others => '0');
    signal s_mip, s_mie : std_logic_vector(XLEN_1 downto 0) := (others => '0');
    signal s_mscratch : std_logic_vector(XLEN_1 downto 0) := (others => '0');
    signal s_mepc : std_logic_vector(XLEN_1 downto 0) := (others => '0');
    signal s_mtval : std_logic_vector(XLEN_1 downto 0) := (others => '0');

    signal s_csr_read_out : std_logic_vector(31 downto 0);
    signal s_data_read_out : std_logic_vector(31 downto 0);
    signal s_read_csr : std_logic;
    signal s_write_csr : std_logic;

begin
    
    s_csr_address <= i_current_instruction(31 downto 20);
    s_csr_bit_select <= i_rs1_data;


    timer: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                s_timer <= (others => '0');
            else 
                s_timer <= s_timer + 1; 
            end if;     
        end if;
    end process timer;

    s_mtime <= std_logic_vector(s_timer(31 downto 0));
    s_mtimeh <= std_logic_vector(s_timer(63 downto 32));

    csr_read: process(i_clk)
    begin
        if rising_edge(i_clk) then
                case s_csr_address is
                    when CSR_MVENDORID =>
                    s_data_read_out <= (others => '0');
                    when CSR_MARCHID =>
                    s_csr_read_out <= (others => '0');
                    when CSR_MIMPID =>
                    s_csr_read_out <= (others => '0');
                    when CSR_MHARTID =>
                    s_csr_read_out <= (others => '0');
                    when CSR_MSTATUS =>
                    s_csr_read_out <= s_mstatus; 
                    when CSR_MISA =>
                    s_csr_read_out <= x"20001100";
                    when CSR_MIE => 
                    s_csr_read_out <= s_mie;
                    when CSR_MTVEC =>
                    s_csr_read_out <= s_mtvec & "00";
                    when CSR_MSCRATCH =>
                    s_csr_read_out <= s_mscratch;
                    when CSR_MEPC =>
                    s_csr_read_out <= s_mepc;
                    when CSR_MCAUSE =>
                    s_csr_read_out <= s_mcause & x"000000" & "00";
                    when CSR_MTVAL =>
                    s_csr_read_out <= s_mtval;
                    when CSR_MIP =>
                    s_csr_read_out <= s_mip;
                    when CSR_TIME =>
                    s_csr_read_out <= s_mtime;
                    when CSR_TIMEH =>
                    s_csr_read_out <= s_mtimeh;    
                    when CSR_MTIMECMP =>
                    s_csr_read_out <= s_mtimecmp;
                    when others =>
                    s_csr_read_out <= (others => '0');                        
                end case;
                
        end if;
    end process csr_read;

    csr_alu: process(i_csr_op,i_rd_address,i_rs1_data,i_rs1_address,s_csr_read_out, s_csr_bit_select)
    begin
        case i_csr_op is
            when CSR_READ_WRITE =>
                if (i_rd_address = "00000") then
                    s_read_csr <= '0';
                    s_write_csr <= '1';
                else 
                    s_read_csr <= '1';
                    s_write_csr <= '1';
                end if; 
            s_csr_write <= i_rs1_data;
            
            when CSR_READ_CLEAR => 
                if (i_rs1_address = "00000") then 
                    s_read_csr <= '1';
                    s_write_csr <= '0';
                else 
                    s_read_csr <= '1';
                    s_write_csr <= '1';
                end if;

                s_csr_write <= s_csr_read_out and not s_csr_bit_select;
            
            when CSR_READ_SET =>

                if (i_rs1_address = "00000") then 
                    s_read_csr <= '1';
                    s_write_csr <= '0';
                else 
                    s_read_csr <= '1';
                    s_write_csr <= '1';
                end if;

                s_csr_write <= s_csr_read_out or s_csr_bit_select;

            when CSR_NONE => 
                s_read_csr <= '1';
                s_write_csr <= '0';
                s_csr_write <= s_csr_read_out;
        
            when others =>
                s_read_csr <= '0';
                s_write_csr <= '0';
                s_csr_write <= (others => '0');
                 
        end case;
        
    end process csr_alu;
    

    csr_write: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                s_mtimecmp <= (others => '0');
                s_mtvec <= (others => '0');
                s_mtval <= (others => '0');
                s_mepc <= (others => '0');
                s_mie <= (others => '0');
                s_mip <= (others => '0');
                
            else 
                if (i_instruction_invalid = '1') then
                    s_mcause <= i_exception_cause;
                    s_mtval <= i_execption_inst_misaling;
                    s_mstatus(3) <= i_exception_ie;
                    s_mstatus(7) <= i_exception_ie1;
                end if;
                
                if (s_write_csr = '1') then 
                    case s_csr_address is
                        when CSR_MSTATUS =>
                            s_mstatus(3) <= s_csr_write(3); 
                            s_mstatus(7) <= s_csr_write(7);
                        when CSR_MEPC =>
                            s_mepc <= s_csr_write;
                        when CSR_MTVEC =>
                            s_mtvec <= s_csr_write(31 downto 2);
                        when CSR_MSCRATCH =>
                            s_mscratch <= s_csr_write;
                        when CSR_MIP => 
                            s_mip <= s_csr_write;
                        when CSR_MTIMECMP =>
                            s_mtimecmp <= s_csr_write;
                        when others =>
                            s_nothing <= (others => '-');
                    end case; 
                end if;
            end if;
        end if;
    end process csr_write;


    o_csr_data_out <= s_csr_read_out;
end architecture behavioral;