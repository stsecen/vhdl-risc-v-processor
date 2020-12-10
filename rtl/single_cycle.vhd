library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity single_cycle is
    port (
        i_clk : in std_logic; 
        i_rst : in std_logic;

        i_instruction : in std_logic_vector(XLEN_1 downto 0);
        i_data1 : in std_logic_vector(XLEN_1 downto 0);
        i_data2 : in std_logic_vector(XLEN_1 downto 0);

        o_data : out std_logic_vector(XLEN_1 downto 0);
        o_alu_op : out std_logic_vector(3 downto 0)
        
    );
end entity single_cycle;

architecture behavioral of single_cycle is
    signal s_pc : std_logic_vector(XLEN_1 downto 0) := (others => '0');
    signal s_pc_next : std_logic_vector(XLEN_1 downto 0);
    signal s_instruction : std_logic_vector(XLEN_1 downto 0);
    signal s_opcode, s_funct7 : std_logic_vector(6 downto 0);
    signal s_funct3 : std_logic_vector(2 downto 0);
    signal s_rs1, s_rs2, s_rd : std_logic_vector(RLEN_1 downto 0);
    signal s_imm : std_logic_vector(XLEN_1 downto 0);

    signal s_jal,s_jalr,s_memread,s_regwrite,s_memtoreg : std_logic;
    signal s_branch_op, s_load_op, s_alu_src : std_logic_vector(2 downto 0);
    signal s_alu_op : std_logic_vector(3 downto 0);
    signal s_store_op : std_logic_vector(1 downto 0);

    signal s_data1,s_data2 : std_logic_vector(XLEN_1 downto 0);
    signal s_alu_result : std_logic_vector(XLEN_1 downto 0);
    signal s_branch_need: std_logic;


begin

    ---------------------
    --****************---
    --> FETCH STAGE <--
    --****************---
    ---------------------
    pc: entity work.program_counter(behavioral)
        port map(
        i_clk => i_clk,
        i_rst => i_rst,
        i_pc => s_pc,
        o_pc => s_pc_next
        );

        s_instruction <= i_instruction;
        s_funct3 <= s_instruction(14 downto 12);
        s_funct7 <= s_instruction(31 downto 25);
        s_opcode <= s_instruction(6 downto 0);

    ---------------------
    --****************---
    --> DECODE STAGE <--
    --****************---
    ---------------------

        s_rs2 <= s_instruction(24 downto 20);
        s_rs1 <= s_instruction(19 downto 15);
        s_rd <= s_instruction(11 downto 7);
    
    rg: entity work.register_file(behavioral)
        port map(
            i_clk => i_clk ,
            i_regwrite => s_regwrite , 
            i_rs1 => s_rs1,
            i_rs2 => s_rs2,
            i_rd => s_rd,
            i_wrdata => s_alu_result,
            o_data1 => open,
            o_data2 => open
        );
    
    se: entity work.sign_extension(behavioral)
        port map(
            i_instruction => s_instruction,
            o_immediate => s_imm 

        );
    
    cu:  entity work.control_unit(behavioral)
        port map(
            i_opcode => s_opcode,
            i_funct3 => s_funct3,
            i_funct7 => s_funct7, 
            o_jal => s_jal, 
            o_jalr => s_jalr,
            o_branch_op => s_branch_op, 
            o_memread => open,
            o_store_op => s_store_op, 
            o_load_op => s_load_op,
            o_alu_op => s_alu_op, 
            o_alu_src => s_alu_src, 
            o_memtoreg => open,
            o_regwrite => s_regwrite 

        );

    ---------------------
    --*****************--
    --> EXECUTE STAGE <--
    --*****************--
    ---------------------
    
    alumux: entity work.alu_mux(behavioral)
        port map(
            i_data1 => i_data1,
            i_data2 => i_data2,
            i_pc => s_pc_next,
            i_imm => s_imm,
            i_alu_src => s_alu_src,
            o_data1 => s_data1,
            o_data2 => s_data2

        );
    
    aluu: entity work.alu(behavioral)
        port map(
            i_a => s_data1,
            i_b => s_data2,
            i_alu_op => s_alu_op,
            o_result => s_alu_result
        );
    
    bu: entity work.branch_unit(behavioral)
        port map(
            i_jal => s_jal, 
            i_jalr => s_jalr,
            i_branch_op => s_branch_op,
            i_alu_sub => s_alu_result,

            i_pc => s_pc_next,
            i_rs1 => i_data1, 
            i_offset => s_imm, 
            o_branch_need => s_branch_need,
            o_branch_target => s_pc
        );
    
    lsu: entity work.load_store_unit(behavioral)
        port map(
            i_rs2 => i_data2, 
            i_store_op => s_store_op,
            i_load_op => s_load_op,
            i_address => s_alu_result,

            o_wb_we => open,
            o_wb_sel => open,
            o_address => open,
            o_data => open,
            o_load_type => open
        );

        o_data <= s_alu_result;
        o_alu_op <= s_alu_op;
    ---------------------
    --*****************--
    --> MEMORY STAGE <--
    --*****************--
    ---------------------

    ---------------------
    --*****************--
       --> WB STAGE <--
    --*****************--
    ---------------------
    
end architecture behavioral;