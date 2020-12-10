library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;
use work.functions.all;

package components is
    
    component alu_mux is
        port (
        
            --> inputs 
            i_data1 : in std_logic_vector(XLEN_1 downto 0);
            i_data2 : in std_logic_vector(XLEN_1 downto 0);
            i_pc    : in std_logic_vector(XLEN_1 downto 0);
            i_imm   : in std_logic_vector(XLEN_1 downto 0);
    
    
            --> control signal 
            i_alu_src : in std_logic_vector(2 downto 0);
    
            --> output signal 
            o_data1 : out std_logic_vector(XLEN_1 downto 0);
            o_data2 : out std_logic_vector(XLEN_1 downto 0)
            
            
        ); 
    end component alu_mux;

    component alu is 
        port (
        
        i_a : in std_logic_vector(XLEN_1 downto 0);
        i_b : in std_logic_vector(XLEN_1 downto 0);
        i_alu_op  : in std_logic_vector(3 downto 0);

        o_result : out std_logic_vector(XLEN_1 downto 0)
        );
    end component alu;


    component branch_unit is
        port (
            i_jal : in std_logic;
            i_jalr : in std_logic;
            i_branch_op : in std_logic_vector(2 downto 0);
            i_alu_sub : in std_logic_vector(XLEN_1 downto 0);
            
            i_pc : in std_logic_vector(XLEN_1 downto 0);
            i_rs1 : in std_logic_vector(XLEN_1 downto 0);
            i_offset : in std_logic_vector(XLEN_1 downto 0); 
    
            o_branch_need : out std_logic;
            o_branch_target : out std_logic_vector(XLEN_1 downto 0)
        );
    end component branch_unit;

    component control_unit is
        port (
            i_opcode : in std_logic_vector(6 downto 0);
            i_funct3 : in std_logic_vector(2 downto 0);
            i_funct7 : in std_logic_vector(6 downto 0);
            i_funct12 : in std_logic_vector(11 downto 0);
    
            --> branch controls signal 
            o_jal : out std_logic;
            o_jalr : out std_logic;
            o_branch_op : out std_logic_vector(2 downto 0);
    
            --> memory control signal 
            o_memread : out std_logic;
            o_store_op : out std_logic_vector(1 downto 0);
            o_load_op : out std_logic_vector(2 downto 0);
    
            --> alu control signal 
            o_alu_op : out std_logic_vector(3 downto 0);
            o_alu_src : out std_logic_vector(2 downto 0);
            o_mul_op : out std_logic_vector(2 downto 0);

            --> register control signal
            o_memtoreg : out std_logic; 
            o_regwrite : out std_logic;
    
            --> ex
            o_exception : out std_logic; 
            o_exception_cause : out std_logic_vector(5 downto 0);
            o_csr_op : out std_logic_vector(1 downto 0)
    
        );
    end component control_unit;

    component forwarding_unit is
        port (
            
            i_ex_mem_register_rd    : in std_logic_vector(4 downto 0);
            i_mem_wb_register_rd    : in std_logic_vector(4 downto 0);
            
            i_ex_mem_regwrite       : in std_logic; 
            i_mem_wb_regwrite       : in std_logic;
    
            i_id_ex_register_rs1    : in std_logic_vector(4 downto 0);
            i_id_ex_register_rs2    : in std_logic_vector(4 downto 0);
    
            o_forward_a             : out std_logic_vector(1 downto 0);
            o_forward_b             : out std_logic_vector(1 downto 0)
            
        );
    end component forwarding_unit;

    component load_store_unit is
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
    end component load_store_unit;

    component program_counter is
        port (
            --> clock and reset signal for program counter.
            i_clk : in std_logic;
            i_rst : in std_logic;
            --> inputs signals. 
            i_pc : in std_logic_vector(XLEN_1 downto 0);
            --> output signal for next program counter value for selecting address for next instruction.
            o_pc : out std_logic_vector(XLEN_1 downto 0)
            
        );
    end component program_counter;

    component register_file is
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
    end component register_file;

    component sign_extension is
        port (
    
            i_instruction : in std_logic_vector(XLEN_1 downto 0);
            o_immediate : out std_logic_vector(XLEN_1 downto 0)
            
        );
    end component sign_extension;

    component instruction_fetch is
        port (
            i_clk : in std_logic;
            i_rst : in std_logic;
    
            --> instruction memory connections
            i_instruction_memory_data : in std_logic_vector(XLEN_1 downto 0); --> 32-bit instruction 
            o_instruction_memory_address : out std_logic_vector(XLEN_1 downto 0); --> its program counter value. 
            
            --> control input
            i_stall : in std_logic;
            i_flush : in std_logic;
            i_branch : in std_logic;
    
            --> program counter mux input
            i_branch_target : in std_logic_vector(XLEN_1 downto 0);
    
            --> outputs 
    
            o_instruction    : out std_logic_vector(31 downto 0);
            o_pc : out std_logic_vector(31 downto 0);
            o_instruction_ready   : out std_logic
    
        );
    end component instruction_fetch;

    component instruction_decode is
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
            o_exception : out std_logic; 
            o_exception_cause : out std_logic_vector(5 downto 0);
            o_csr_op : out std_logic_vector(1 downto 0);
    
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
            o_execute_en : out std_logic
    
        );
    end component instruction_decode;

    component instruction_execute is
        generic(
            MULT_EN : boolean 
        );
        port (
    
            i_clk : in std_logic; 
    
            --> pipeline hazards signals 
            i_flush : in std_logic;
            i_stall : in std_logic;
    
            --> register_file outputs 
            i_rs1_data : in std_logic_vector(XLEN_1 downto 0);
            i_rs2_data : in std_logic_vector(XLEN_1 downto 0);
            i_rd_data_mem : in std_logic_vector(XLEN_1 downto 0);
            i_rd_data_writeback : in std_logic_vector(XLEN_1 downto 0);
    
            --> immediate value
            i_imm : in std_logic_vector(XLEN_1 downto 0);
            --> program counter value 
            i_pc : in std_logic_vector(XLEN_1 downto 0);
    
            --> control_signal 
            i_alu_op : in std_logic_vector(3 downto 0); 
            i_branch_op : in std_logic_vector(2 downto 0);
            i_jalr : in std_logic;
            i_jal : in std_logic;
            i_load_op : in std_logic_vector(2 downto 0);
            i_store_op  : in std_logic_vector(1 downto 0);
            i_alu_src : in std_logic_vector(2 downto 0);
            i_memtoreg : in std_logic;
            i_regwrite : in std_logic;
            i_memread : in std_logic; 
            i_mult_en : in std_logic;
            i_mul_op : in std_logic_vector(2 downto 0);
    
            i_exception : in std_logic;
    
            --> register address 
            i_decode_rs1_address : in std_logic_vector(RLEN_1 downto 0);
            i_decode_rs2_address : in std_logic_vector(RLEN_1 downto 0);
            i_decode_rd_address : in std_logic_vector(RLEN_1 downto 0);
            i_mem_rd_address : in std_logic_vector(RLEN_1 downto 0); 
            i_writeback_rd_address : in std_logic_vector(RLEN_1 downto 0);    
            --> for forwarding control signal 
            i_mem_regwrite : in std_logic;
            i_writeback_regwrite : in std_logic; 
    
            i_exception_cause : in std_logic_vector(5 downto 0);
            i_csr_op : in std_logic_vector(1 downto 0);
            --> outputs 
    
            o_mem_rd_address  : out std_logic_vector(RLEN_1 downto 0);
    
            --> branch_unit outputs
    
            o_branch_need : out std_logic;
            o_branch_target : out std_logic_vector(XLEN_1 downto 0);
    
            --> alu outputs for register operation 
            o_result : out std_logic_vector(XLEN_1 downto 0);
    
            --> load store unit output
            o_wb_we : out std_logic;
            o_wb_sel : out std_logic_vector(3 downto 0);
            o_address : out std_logic_vector(XLEN_1 downto 0);
            o_store_data : out std_logic_vector(XLEN_1 downto 0); --> for store instrutions 
            o_load_type : out std_logic_vector(2 downto 0);
    
            --> memory stages signal 
            o_memread : out std_logic; 
            o_regwrite : out std_logic;
            o_memtoreg : out std_logic;
            o_mem_en : out std_logic;
            o_invalid : out std_logic;
            o_hazard : out std_logic
            
    
        );
    end component instruction_execute;

    component memory_stage is
        port (
            i_clk : in std_logic;
    
            i_stall : in std_logic;
    
            --> destination registers input 
            i_regwrite : in std_logic; 
            i_mem_rd_address : in std_logic_vector(RLEN_1 downto 0);
            i_alu_result : in std_logic_vector(XLEN_1 downto 0);
    
            --> memory control signals 
            i_memread : in std_logic;
            i_memtoreg : in std_logic;
            i_load_op : in std_logic_vector(2 downto 0); 
    
            --> load signals 
            i_dmem_data : in std_logic_vector(XLEN_1 downto 0);     
            --> output signals 
    
            o_load_rd_data : out std_logic_vector(XLEN_1 downto 0); 
            o_alu_result : out std_logic_vector(XLEN_1 downto 0);
            o_mem_rd_address : out std_logic_vector(RLEN_1 downto 0);
            o_regwrite : out std_logic;
            o_memtoreg : out std_logic;
            o_writeback_en : out std_logic        
    
        );
    end component memory_stage;


    component writeback is
        port (
            i_clk : in std_logic;
    
            i_wb_rd_address : in std_logic_vector(RLEN_1 downto 0);
            i_load_data : in std_logic_vector(XLEN_1 downto 0);
            i_alu_result : in std_logic_vector(XLEN_1 downto 0);
    
            i_memtoreg : in std_logic;
            i_regwrite : in std_logic; 
    
            o_regwrite : out std_logic;
            o_wb_data : out std_logic_vector(XLEN_1 downto 0);
            o_wb_rd_address : out std_logic_vector(RLEN_1 downto 0)
    
        );
    end component writeback;


    component data_memory is
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
    end component data_memory;

    component core is
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
            --> alu_result for verification 
            o_alu_result : out std_logic_vector(XLEN_1 downto 0)
    
    
        );
    end component core;

    component data_memory_bram is

        port(
            i_clk  : in  std_logic;
        
            i_datamem_we   : in  std_logic;
            i_datamem_address : in  std_logic_vector(XLEN_1 downto 0);
            i_datamem_store_data  : in  std_logic_vector(XLEN_1 downto 0);
            o_datamem_load_data : out std_logic_vector(XLEN_1 downto 0);
            o_datamem_ack : out std_logic
        );
    end component data_memory_bram;

    component instruction_memory_bram is

        port(
            i_clk  : in  std_logic;
        
            i_instruction_address  : in  std_logic_vector(XLEN_1 downto 0);
            o_instruction : out std_logic_vector(XLEN_1 downto 0)
        );
    end component instruction_memory_bram; 

    component mc2020gtu is
        port (
            i_clk : in std_logic;
            i_rst : in std_logic;
    
            o_alu_test : out std_logic_vector(XLEN_1 downto 0);
            o_test : out std_logic_vector(XLEN_1 downto 0)
            
        );
    end component mc2020gtu;

    component mul_unit is
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
    end component mul_unit;
    

end package components;