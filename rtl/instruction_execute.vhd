library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;
use work.components.all;



entity instruction_execute is
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
        o_hazard : out std_logic;

        --> csr
        
        i_exception_cause : in std_logic_vector(5 downto 0);
        i_csr_op : in std_logic_vector(1 downto 0);
        

    );
end entity instruction_execute;

architecture behavioral of instruction_execute is
    
    signal s_data1 : std_logic_vector(XLEN_1 downto 0);
    signal s_data2 : std_logic_vector(XLEN_1 downto 0);

    signal s_alu_sub_result : std_logic_vector(XLEN_1 downto 0);
    signal s_alu_calculated_adrress : std_logic_vector(XLEN_1 downto 0);
    signal s_result : std_logic_vector(XLEN_1 downto 0);

    signal s_rs1_data : std_logic_vector(XLEN_1 downto 0);
    signal s_rs2_data : std_logic_vector(XLEN_1 downto 0);
    signal s_pc : std_logic_vector(XLEN_1 downto 0);

    signal s_imm : std_logic_vector(XLEN_1 downto 0);

    signal s_forward_rs1 : std_logic_vector(XLEN_1 downto 0);
    signal s_forward_rs2 : std_logic_vector(XLEN_1 downto 0);

    signal s_jump : std_logic; 
    signal s_branch_need : std_logic; 
    signal s_jump_target : std_logic_vector(XLEN_1 downto 0);

    signal s_forward_a : std_logic_vector(1 downto 0);
    signal s_forward_b : std_logic_vector(1 downto 0);
    
    signal s_rs1_addr : std_logic_vector(RLEN_1 downto 0);
    signal s_rs2_addr : std_logic_vector(RLEN_1 downto 0);
    signal s_rd_addr : std_logic_vector(RLEN_1 downto 0);
    signal s_forward : std_logic_vector(3 downto 0);

    signal s_branch_op : std_logic_vector(2 downto 0);
    signal s_store_op : std_logic_vector(1 downto 0);
    signal s_load_op : std_logic_vector(2 downto 0);
    signal s_regwrite : std_logic;
    signal s_alu_op : std_logic_vector(3 downto 0);
    signal s_alu_src : std_logic_vector(2 downto 0); 
    
    signal s_hazard : std_logic;

    signal s_mult_result : std_logic_vector(31 downto 0);
    signal s_alu_result : std_logic_vector(31 downto 0);
    signal s_divisor_zero : std_logic;

    signal s_next_instruction_misalign : std_logic;
    signal s_invalid : std_logic;
    signal s_exception : std_logic;

begin

    execute_stage: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if  i_flush = '1' then 
                o_regwrite <= '0';
				s_branch_op <= NO_BRANCH;
                s_store_op <= NO_MEM;
                s_load_op <= LOAD_NOP;
                s_alu_op <= ALU_INVALID;
                s_alu_src <= ALU_SRC_INVALID;
                o_mem_en <= '0';
            elsif i_stall = '1' then 
                o_mem_en <= '0';
            else
                s_pc <= i_pc; 
                s_rs1_data <= i_rs1_data;
                s_rs2_data <= i_rs2_data;
                s_rd_addr <= i_decode_rd_address;
                s_rs1_addr <= i_decode_rs1_address;
                s_rs2_addr <= i_decode_rs2_address;
                s_alu_op <= i_alu_op;
                s_branch_op <= i_branch_op;
                s_alu_src <= i_alu_src;
                s_store_op <= i_store_op;
                s_load_op <= i_load_op;
                s_imm <= i_imm;
                s_exception <= i_exception;
                o_memread <= i_memread;
                o_memtoreg <= i_memtoreg;
                o_regwrite <= i_regwrite;
                o_mem_en <= '1';
            end if; 

        end if;
    end process execute_stage;

    alumux: component alu_mux 
        port map(
            i_data1 => s_forward_rs1,
            i_data2 => s_forward_rs2,
            i_pc => s_pc,
            i_imm => s_imm,
            i_alu_src => s_alu_src,
            o_data1 => s_data1,
            o_data2 => s_data2
        );

    alunit: component alu
        port map(
            i_a => s_data1,
            i_b => s_data2,
            i_alu_op => s_alu_op,
            o_result => s_alu_result
        );

        mul_gen : if MULT_EN generate
        begin 
            m_extensions: component mul_unit 
                port map(
                    i_rs1 => s_data1,
                    i_rs2 => s_data2,
                    i_mul_op => i_mul_op,
                    o_divisor_zero => s_divisor_zero,
                    o_result => s_mult_result
                );
        end generate;

        mul_no_gen : if not MULT_EN generate
            signal s_no_mult : std_logic_vector(31 downto 0);
        begin 
            s_no_mult <= (others => '0' );
            s_divisor_zero <= '0';
        end generate; 
        
        mult_alu_mux: process(i_mult_en,s_mult_result,s_alu_result)
        begin
            if( i_mult_en = '1' and MULT_EN ) then 
                s_result <= s_mult_result;
            else 
                s_result <= s_alu_result;
            end if; 
        end process ;

    s_alu_calculated_adrress <= s_result;
    s_alu_sub_result <= s_result;

    bu: component branch_unit 
        port map(
            i_jal => i_jal,
            i_jalr => i_jalr,
            i_branch_op => s_branch_op,
            i_alu_sub => s_alu_sub_result,
            
            i_pc => s_pc,
            i_rs1 => s_forward_rs1,
            i_offset => s_imm,
    
            o_branch_need => s_branch_need,
            o_branch_target => s_jump_target
        );

    lsu: component load_store_unit 
        port map(
            i_rs2 => s_forward_rs2,
            i_store_op => s_store_op,
            i_load_op => s_load_op,
            i_address => s_alu_calculated_adrress,
            o_wb_we => o_wb_we,
            o_wb_sel => o_wb_sel,
            o_address => o_address,
            o_data => o_store_data,
            o_load_type => o_load_type
        );

    forward: component forwarding_unit 
        port map(
            i_ex_mem_register_rd => i_mem_rd_address,
            i_mem_wb_register_rd => i_writeback_rd_address,
            
            i_ex_mem_regwrite => i_mem_regwrite,
            i_mem_wb_regwrite => i_writeback_regwrite,

            i_id_ex_register_rs1 => s_rs1_addr,
            i_id_ex_register_rs2 => s_rs2_addr,
    
            o_forward_a => s_forward_a, 
            o_forward_b => s_forward_b             
        );

        s_forward <= s_forward_a & s_forward_b;

    forwarding_op: process(s_forward,s_rs1_data,s_rs2_data,i_rd_data_writeback,i_rd_data_mem)
    begin
        case s_forward is
            when "0000" =>
                s_forward_rs1 <= s_rs1_data;
                s_forward_rs2 <= s_rs2_data;
            when "0001" => 
                s_forward_rs1 <= s_rs1_data;
                s_forward_rs2 <= i_rd_data_writeback;
            when "0010" =>
                s_forward_rs1 <= s_rs1_data;
                s_forward_rs2 <= i_rd_data_mem;
            when "0100" =>
                s_forward_rs1 <= i_rd_data_writeback;
                s_forward_rs2 <= s_rs2_data;
            when "0101" => 
                s_forward_rs1 <= i_rd_data_writeback;
                s_forward_rs2 <= i_rd_data_writeback;
            when "0110" =>
                s_forward_rs1 <= i_rd_data_writeback;
                s_forward_rs2 <= i_rd_data_mem;
            when "1000" =>
                s_forward_rs1 <= i_rd_data_mem;
                s_forward_rs2 <= s_rs2_data;
            when "1001" => 
                s_forward_rs1 <= i_rd_data_mem;
                s_forward_rs2 <= i_rd_data_writeback;
            when "1010" =>
                s_forward_rs1 <= i_rd_data_mem;
                s_forward_rs2 <= i_rd_data_mem;
            when others =>
                s_forward_rs1 <= s_rs1_data;
                s_forward_rs2 <= s_rs2_data; 

        end case;
        
    end process forwarding_op;
    
    o_result <= s_result;
    o_branch_need <= s_branch_need;
    o_branch_target <= s_jump_target;
    o_mem_rd_address <= s_rd_addr;

    hazard_detect: process(i_writeback_rd_address, s_rs1_addr, s_rs2_addr, s_load_op, i_mem_rd_address)
    begin
        if (
            (s_load_op /= LOAD_NOP and (i_mem_rd_address = s_rs1_addr or i_mem_rd_address = s_rs2_addr))
            or
            (s_load_op /= LOAD_NOP and (i_writeback_rd_address = s_rs2_addr or i_writeback_rd_address = s_rs1_addr))
        ) then 
            s_hazard <= '1';
        else 
            s_hazard <= '0';
        end if;
    end process hazard_detect;

    o_hazard <= s_hazard;
    
    branch_misalign: process(s_branch_need,s_jump_target)
    begin
        if (s_branch_need = '1') then 
            if (s_jump_target(1 downto 0) /= "00") then
                s_next_instruction_misalign <= '1';
            else    
                s_next_instruction_misalign <= '0';
            end if;
        else
            s_next_instruction_misalign <= '0';
        end if;
    end process branch_misalign;

    exception_cause: process(s_next_instruction_misalign,s_divisor_zero,s_exception)
    begin 
        if (s_next_instruction_misalign = '1' or s_divisor_zero = '1' or s_exception = '1') then 
            s_invalid <= '1';
        else 
            s_invalid <= '0';
        end if;
    end process exception_cause;
    
    o_invalid <= s_invalid;

end architecture behavioral;