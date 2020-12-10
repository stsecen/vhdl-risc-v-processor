library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;
use work.components.all;

entity instruction_decode is
    port (
        
        i_clk : in std_logic; 

        --> pipeline hazards signals 
        i_flush : in std_logic;
        i_stall : in std_logic;

        --> intstruction mem??ry inputs
		i_instruction   : in std_logic_vector(31 downto 0);
		i_instruction_address : in std_logic_vector(31 downto 0);
        i_instruction_ready   : in std_logic;
        
        --> register_file signals 
        i_writeback_rd_adress : in std_logic_vector(RLEN_1 downto 0);
        o_rs1data   : out std_logic_vector(XLEN_1 downto 0);
        o_rs2data   : out std_logic_vector(XLEN_1 downto 0);
        i_wb_data   : in std_logic_vector(XLEN_1 downto 0); --> ??????????????*
        i_regwrite  : in std_logic;
        o_regwrite  : out std_logic; --> =?????????????????????????*

        --> control unit signal

        o_jal   : out std_logic;
        o_jalr  : out std_logic;
        o_branch_op : out std_logic_vector(2 downto 0);
        o_memread   : out std_logic;
        o_store_op  : out std_logic_vector(1 downto 0);
        o_load_op   : out std_logic_vector(2 downto 0);
        o_alu_op    : out std_logic_vector(3 downto 0);
        o_alu_src   : out std_logic_vector(2 downto 0);
        o_mul_op    : out std_logic_vector(2 downto 0);
        o_memtoreg  : out std_logic;


        --> decoding instrution adress 
        o_pc : out std_logic_vector(XLEN_1 downto 0);

        --> forwarding unit signals
        o_ex_address_rs1 : out std_logic_vector(RLEN_1 downto 0);
        o_ex_address_rs2 : out std_logic_vector(RLEN_1 downto 0);
        o_ex_address_rd  : out std_logic_vector(RLEN_1 downto 0);

        --> sing extension output 
        o_immediate : out std_logic_vector(XLEN_1 downto 0);

        o_mult_en : out std_logic;
        o_jump_detect : out std_logic;
        o_execute_en : out std_logic;


        --> csr 

        o_exception : out std_logic; 
        o_exception_cause : out std_logic_vector(5 downto 0);
        o_csr_op : out std_logic_vector(1 downto 0)





    );
end entity instruction_decode;


architecture behavioral of instruction_decode is
    
    signal s_instruction,s_pc : std_logic_vector(XLEN_1 downto 0);
    signal s_funct3 : std_logic_vector(2 downto 0);
    signal s_rs1,s_rs2,s_rd : std_logic_vector(RLEN_1 downto 0);
    signal s_jalr, s_jal, s_exception,s_mult_en : std_logic;
    signal s_rs1data,s_rs2data : std_logic_vector(XLEN_1 downto 0);
    signal s_opcode, s_funct7 : std_logic_vector(6 downto 0);
    signal s_funct12 : std_logic_vector(11 downto 0);
    signal s_exception_cause : std_logic_vector(5 downto 0);
    signal s_csr_op : std_logic_vector(1 downto 0);

begin
    
    s_rs2 <= s_instruction(24 downto 20);
    s_rs1 <= s_instruction(19 downto 15);
    s_rd <= s_instruction(11 downto 7);
    s_funct3 <= s_instruction(14 downto 12);
    s_opcode <= s_instruction(6 downto 0);
    s_funct7 <= s_instruction(31 downto 25);
    s_funct12 <= s_instruction(31 downto 20);

    
    decode_register: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_flush = '1' then 
                s_instruction <= NOP;
                o_execute_en <= '0';
                s_pc <= (others => '0');
            elsif i_stall = '1' or i_instruction_ready = '0' then
                o_execute_en <= '0';
            else
                s_instruction <= i_instruction;
                s_pc <= i_instruction_address;
                o_execute_en <= '1';
            end if;    
        end if;
    end process decode_register;

    o_pc <= s_pc;
    

    rfile: component register_file
        port map(
            i_clk => i_clk, 
            i_regwrite => i_regwrite, 
            i_rs1 => s_rs1,
            i_rs2 => s_rs2,
            i_rd => i_writeback_rd_adress,
            i_wrdata => i_wb_data,

            o_data1 => s_rs1data,
            o_data2 => s_rs2data
        );

    control: component control_unit 
        port map(
            i_opcode => s_opcode,
            i_funct3 => s_funct3,
            i_funct7 => s_funct7, 
            i_funct12 => s_funct12,
            o_jal => s_jal,
            o_jalr => s_jalr,
            o_branch_op => o_branch_op,
            o_memread => o_memread,
            o_store_op => o_store_op,
            o_load_op => o_load_op,
            o_alu_op => o_alu_op,
            o_alu_src => o_alu_src,
            o_mul_op => o_mul_op,
            o_memtoreg => o_memtoreg,
            o_regwrite => o_regwrite,
            o_csr_op => o_csr_op,
            o_exception => s_exception,
            o_exception_cause => o_exception_cause
        );
    
    imm_gen: component sign_extension
        port map(
            i_instruction => s_instruction,
            o_immediate => o_immediate
        );

    mult_en: process(s_opcode,s_exception,s_funct7)
        begin
            if (s_opcode = OPCODE_ARTH and s_exception = '0') then 
                if(s_funct7 = F7_MULT) then
                    s_mult_en <= '1';
                else
                    s_mult_en <= '0';
                end if;
            else 
                s_mult_en <= '0';
            end if;
        end process; 

        o_ex_address_rs1 <= s_rs1;
        o_ex_address_rs2 <= s_rs2;
        o_ex_address_rd <= s_rd;
        o_jump_detect <= s_jal or s_jalr;
        o_jalr <= s_jalr;
        o_jal <= s_jal; 
        o_rs1data <= s_rs1data;
        o_rs2data <= s_rs2data;
        o_exception <= s_exception;
        o_mult_en <= s_mult_en;

end architecture behavioral;