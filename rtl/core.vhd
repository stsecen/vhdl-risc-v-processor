library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;
use work.components.all;

entity core is
    generic(
        MULT_EN : boolean := FALSE
    );
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;

        --> intruction memory connections 
        i_instruction : in std_logic_vector(XLEN_1 downto 0);
        o_instruction_address : out std_logic_vector(XLEN_1 downto 0);


        --> data memory connections 
        o_datamem_address : out std_logic_vector(XLEN_1 downto 0);
        o_datamem_store_data : out std_logic_vector(XLEN_1 downto 0);
        
        i_datamem_load_data : in std_logic_vector(XLEN_1 downto 0);
        i_datamem_ack : in std_logic;
        
        o_wb_we : out std_logic;
        
        --> instruction invalid need exceptions 
        o_invalid : out std_logic;

        --> alu_result for verification 
        o_alu_result : out std_logic_vector(XLEN_1 downto 0)


    );
end entity core;

architecture behavioral of core is

    signal s_stall_if, s_stall_id, s_stall_ex, s_stall_mem : std_logic;
    signal s_flush_if, s_flush_id, s_flush_ex : std_logic;
    
    --> if signals 
        --> inputs
        signal s_instruction_in : std_logic_vector(XLEN_1 downto 0);
        signal s_branch_target_in : std_logic_vector(XLEN_1 downto 0);
        signal s_branch_need_in : std_logic;

        --> outputs
        signal s_instruction_out : std_logic_vector(XLEN_1 downto 0);
        signal s_pc_out : std_logic_vector(XLEN_1 downto 0);
        signal s_instruction_ready_out : std_logic;
        signal s_instruction_address_out : std_logic_vector(XLEN_1 downto 0);

    --> id signals 
        --> inputs 
        signal s_instruction_id_in : std_logic_vector(XLEN_1 downto 0);
        signal s_pc_id_in : std_logic_vector(XLEN_1 downto 0);
        signal s_instruction_ready_in : std_logic;
        signal s_writeback_rd_address_in : std_logic_vector(RLEN_1 downto 0);
        signal s_rd_data_in : std_logic_vector(XLEN_1 downto 0);
        signal s_regwrite_in : std_logic; 

        --> outputs 
        --> datas
        signal s_rs1data_id : std_logic_vector(XLEN_1 downto 0);
        signal s_rs2data_id : std_logic_vector(XLEN_1 downto 0);
        signal s_immediate_id : std_logic_vector(XLEN_1 downto 0);
        --> address
        signal s_rs1_address : std_logic_vector(RLEN_1 downto 0);
        signal s_rs2_address : std_logic_vector(RLEN_1 downto 0);
        signal s_rd_address : std_logic_vector(RLEN_1 downto 0);
        signal s_pc_id_out : std_logic_vector(XLEN_1 downto 0);

        --> control signals 
        signal s_alu_op_id : std_logic_vector(3 downto 0);
        signal s_store_op_id : std_logic_vector(1 downto 0);
        signal s_load_op_id : std_logic_vector(2 downto 0);
        signal s_branch_op_id : std_logic_vector(2 downto 0);
        signal s_alu_src_id : std_logic_vector(2 downto 0);
        signal s_jalr_id, s_jal_id, s_memread_id, s_regwrite_id, s_memtoreg_id : std_logic;
        signal s_mul_op_id : std_logic_vector(2 downto 0);

        signal s_exception_id : std_logic;
        signal s_exception_cause_id : std_logic_vector(5 downto 0);
        signal s_csr_op_id : std_logic_vector(1 downto 0);
        signal s_mult_en_id : std_logic;

        --> hazard signal
        signal s_jump_detect : std_logic;
        signal s_execute_en : std_logic;

    --> ex signals
        --> inputs 
        --> registers signals 
        signal s_rs1data_ex : std_logic_vector(XLEN_1 downto 0);
        signal s_rs2data_ex : std_logic_vector(XLEN_1 downto 0);
        signal s_rd_data_mem_ex : std_logic_vector(XLEN_1 downto 0);
        signal s_rd_data_writeback_ex : std_logic_vector(XLEN_1 downto 0);
        signal s_imm_ex : std_logic_vector(XLEN_1 downto 0);
        signal s_pc_ex : std_logic_vector(XLEN_1 downto 0);

        --> control signals 
        signal s_alu_op_ex : std_logic_vector(3 downto 0);
        signal s_branch_op_ex : std_logic_vector(2 downto 0);
        signal s_jalr_ex, s_jal_ex, s_memtoreg_ex, s_regwrite_ex, s_memread_ex : std_logic;
        signal s_alu_src_ex : std_logic_vector(2 downto 0);
        signal s_load_op_ex : std_logic_vector(2 downto 0);
        signal s_store_op_ex : std_logic_vector(1 downto 0);
        

        --> register address 
        signal s_id_rs1_address : std_logic_vector(RLEN_1 downto 0);
        signal s_id_rs2_address : std_logic_vector(RLEN_1 downto 0);
        signal s_id_rd_address : std_logic_vector(RLEN_1 downto 0);
        signal s_mem_rd_address : std_logic_vector(RLEN_1 downto 0);
        signal s_writeback_rd_address : std_logic_vector(RLEN_1 downto 0);

        --> forwarding control signal 
        signal s_writeback_regwrite : std_logic;

        --> outputs 
        --> branch unit 
        signal s_branch_need_out : std_logic;
        signal s_branch_target_out : std_logic_vector(XLEN_1 downto 0);
        --> alu_result
        signal s_alu_result : std_logic_vector(XLEN_1 downto 0);
        --> load_store_unit signal
        signal s_wb_we : std_logic;
        signal s_wb_sel : std_logic_vector(3 downto 0);
        signal s_address : std_logic_vector(XLEN_1 downto 0);
        signal s_store_data : std_logic_vector(XLEN_1 downto 0);
        signal s_load_type : std_logic_vector(2 downto 0);

        --> control signals buffer
        signal s_memread_ex_out : std_logic;
        signal s_regwrite_ex_out : std_logic;
        signal s_memtoreg_ex_out : std_logic;
        signal s_mem_en : std_logic;
        signal s_hazard : std_logic;

    --> mem signals 
        --> outputs 
        signal s_load_rd_data_out : std_logic_vector(XLEN_1 downto 0);
        signal s_mem_alu_result : std_logic_vector(XLEN_1 downto 0);
        signal s_mem_rd_address_out : std_logic_vector(RLEN_1 downto 0);
        signal s_mem_regwrite_out : std_logic;
        signal s_mem_memtoreg_out : std_logic;



        

    
    begin

    --> intruction memory connections 
    s_instruction_in <= i_instruction;
    o_instruction_address <= s_instruction_address_out;
    --> intruction memory connections ends here 

    --> branch unit connections 
    s_branch_need_in <= s_branch_need_out;
    s_branch_target_in <= s_branch_target_out; 

    --> if pipeline hazard signals 
    s_stall_if <= s_stall_id;
    s_flush_if <= s_branch_need_out and not(s_stall_if);

    if_stage: component instruction_fetch  
    port map(

        i_clk => i_clk,
        i_rst => i_rst,
        i_instruction_memory_data   => s_instruction_in, 
        i_stall => s_stall_if,
        i_flush => s_flush_if,
        i_branch => s_branch_need_in,
        i_branch_target => s_branch_target_in, 
        o_instruction => s_instruction_out,     
        o_pc => s_pc_out,
        o_instruction_ready => s_instruction_ready_out,
        o_instruction_memory_address => s_instruction_address_out

    );
    
    --> instruction and pc connection
    s_instruction_id_in <= s_instruction_out;
    s_pc_id_in <= s_pc_out;
    s_instruction_ready_in <= s_instruction_ready_out;
    
    --> register file writing inputs 
    s_writeback_rd_address_in <= s_writeback_rd_address;
    s_regwrite_in <= s_writeback_regwrite; 
    s_rd_data_in <= s_rd_data_writeback_ex; 

    --> pipeline control signals 
    s_stall_id <= s_stall_ex;
    s_flush_id <= s_branch_need_out and not(s_stall_id);
    
    id_stage: component instruction_decode 
    port map(
            
        i_clk => i_clk,
        i_flush => s_flush_id,
        i_stall => s_stall_id,
        i_instruction =>  s_instruction_id_in,
        i_instruction_address => s_pc_id_in,
        i_instruction_ready =>  s_instruction_ready_in,
        i_writeback_rd_adress => s_writeback_rd_address_in,
        i_wb_data =>  s_rd_data_in,
        i_regwrite => s_regwrite_in,
        o_regwrite => s_regwrite_id,
        o_rs1data =>  s_rs1data_id,
        o_rs2data =>  s_rs2data_id,
        o_jal =>  s_jal_id,
        o_jalr => s_jalr_id,
        o_branch_op => s_branch_op_id,
        o_memread =>  s_memread_id,
        o_store_op => s_store_op_id,
        o_load_op =>  s_load_op_id,
        o_alu_op =>  s_alu_op_id,
        o_alu_src =>  s_alu_src_id,
        o_mul_op => s_mul_op_id,
        o_memtoreg => s_memtoreg_id,
        o_exception => s_exception_id,
        o_exception_cause => s_exception_cause_id,
        o_csr_op => s_csr_op_id,
        o_pc => s_pc_id_out,
        o_ex_address_rs1 => s_rs1_address,
        o_ex_address_rs2 => s_rs2_address,
        o_ex_address_rd => s_rd_address,
        o_mult_en => s_mult_en_id,
        o_immediate => s_immediate_id,
        o_jump_detect => s_jump_detect,
        o_execute_en => s_execute_en

    );

    s_stall_ex <= s_hazard or s_stall_mem;
    s_flush_ex <= s_branch_need_out and not(s_stall_ex);
    
    ex_stage: component instruction_execute
    generic map(
        MULT_EN => MULT_EN
    )
    port map(

        i_clk => i_clk,
        i_flush => s_flush_ex,
        i_stall => s_stall_ex,
        i_rs1_data => s_rs1data_id,
        i_rs2_data => s_rs2data_id,
        i_rd_data_mem => s_load_rd_data_out,
        i_rd_data_writeback => s_rd_data_writeback_ex,
        i_imm => s_immediate_id, 
        i_pc => s_pc_id_out,
        i_alu_op => s_alu_op_id,
        i_branch_op => s_branch_op_id,
        i_jalr => s_jalr_id,
        i_jal => s_jal_id,
        i_load_op => s_load_op_id,
        i_store_op => s_store_op_id,
        i_alu_src => s_alu_src_id,
        i_memtoreg => s_memtoreg_id,
        i_regwrite => s_regwrite_id,
        i_memread => s_memread_id,
        i_mult_en => s_mult_en_id,
        i_mul_op => s_mul_op_id,
        i_exception => s_exception_id,
        i_exception_cause => s_exception_cause_id,
        i_csr_op => s_csr_op_id,
        i_decode_rs1_address => s_rs1_address,
        i_decode_rs2_address => s_rs2_address,
        i_decode_rd_address => s_rd_address,
        i_mem_rd_address => s_mem_rd_address_out,
        i_writeback_rd_address => s_writeback_rd_address,
        i_mem_regwrite => s_mem_regwrite_out,
        i_writeback_regwrite => s_writeback_regwrite,
        o_mem_rd_address => s_mem_rd_address,
        o_branch_need => s_branch_need_out,
        o_branch_target => s_branch_target_out, 
        o_result => s_alu_result,
        o_wb_we => o_wb_we,
        o_wb_sel => s_wb_sel,
        o_address => s_address,
        o_store_data => s_store_data, 
        o_load_type => s_load_op_ex,
        o_mem_en => s_mem_en,
        o_memread => s_memread_ex_out,
        o_regwrite => s_regwrite_ex_out,
        o_memtoreg => s_memtoreg_ex_out,
        o_hazard => s_hazard,
        o_invalid => o_invalid
        
    );

    s_stall_mem <= not(i_datamem_ack) and s_mem_en;

    mem_stage: component memory_stage
    port map(

        i_clk => i_clk,
        i_stall => s_stall_mem,
        i_regwrite => s_regwrite_ex_out,
        i_mem_rd_address => s_mem_rd_address,
        i_alu_result => s_alu_result,
        i_memread => s_memread_ex_out,
        i_memtoreg => s_memtoreg_ex_out,
        i_load_op => s_load_op_ex,
        i_dmem_data => i_datamem_load_data,
        o_load_rd_data => s_load_rd_data_out,
        o_alu_result => s_mem_alu_result,
        o_mem_rd_address => s_mem_rd_address_out,
        o_regwrite => s_mem_regwrite_out,
        o_memtoreg => s_mem_memtoreg_out

    );

    wb_stage: component writeback 
    port map(
        i_clk => i_clk, 
        i_wb_rd_address => s_mem_rd_address_out,
        i_load_data => s_load_rd_data_out,
        i_alu_result => s_mem_alu_result,
        i_memtoreg => s_mem_memtoreg_out,
        i_regwrite => s_mem_regwrite_out,    
        o_regwrite => s_writeback_regwrite,
        o_wb_data => s_rd_data_writeback_ex,
        o_wb_rd_address => s_writeback_rd_address
    );
    
    --> outputs 
    o_alu_result <= s_alu_result;  
    o_datamem_address <= s_address;
    o_datamem_store_data <= s_store_data;

end architecture behavioral;