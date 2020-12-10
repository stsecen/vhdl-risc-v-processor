library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity control_unit is
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
end entity control_unit;

architecture behavioral of control_unit is

    signal s_opcode : std_logic_vector(6 downto 0);
    signal s_funct3 : std_logic_vector(2 downto 0);
    signal s_funct7 : std_logic_vector(6 downto 0);
    signal s_jal : std_logic;
    signal s_jalr : std_logic;
    signal s_branch_op : std_logic_vector(2 downto 0);
    signal s_funct12 : std_logic_vector(11 downto 0);

    --> memory control signal 
    signal s_memread : std_logic;
    signal s_store_op : std_logic_vector(1 downto 0);
    signal s_load_op : std_logic_vector(2 downto 0);
    --> alu control signal 
    signal s_alu_op : std_logic_vector(3 downto 0);
    signal s_alu_src : std_logic_vector(2 downto 0);
    signal s_mul_op : std_logic_vector(2 downto 0);
    --> register control signal
    signal s_memtoreg : std_logic; 
    signal s_regwrite : std_logic;

    -->exception signal 
    signal s_exception : std_logic;
    signal s_exception_cause : std_logic_vector(5 downto 0);
    signal s_csr_op : std_logic_vector(1 downto 0);


begin
    s_opcode <= i_opcode;
    s_funct7 <= i_funct7;
    s_funct3 <= i_funct3;
    s_funct12 <= i_funct12; 

control: process(s_opcode,s_funct3,s_funct7,s_funct12)
begin

    s_jal <= '0';
    s_jalr <= '0';
    s_branch_op <= NO_BRANCH; 
    s_store_op <= NO_MEM; 
    s_alu_op <= ALU_INVALID;
    s_alu_src <= ALU_SRC_LUI; --> immediate + x0
    s_load_op <= LOAD_NOP;
    s_regwrite <= '0';
    s_memtoreg <= '0';
    s_memread <= '0';
    s_mul_op <= ALU_MUL; 
    s_exception <= '0';
    s_exception_cause <= MCAUSE_NONE;
    s_csr_op <= CSR_NONE;

    case s_opcode is
    
        when OPCODE_LUI =>

            s_jal <= '0';
            s_jalr <= '0';
            s_branch_op <= NO_BRANCH; 
            s_store_op <= NO_MEM; 
            s_alu_op <= ALU_ADD;
            s_alu_src <= ALU_SRC_LUI; --> immediate + x0

            s_load_op <= LOAD_NOP;
            s_regwrite <= '1';
            s_memtoreg <= '0';
            s_memread <= '0';

            s_exception <= '0';
            s_exception_cause <= MCAUSE_NONE;
            s_csr_op <= CSR_NONE;
            s_mul_op <= ALU_MUL; 

            

        when OPCODE_AUIPC =>

            s_jal <= '0';
            s_jalr <= '0';
            s_branch_op <= NO_BRANCH; 
            s_store_op <= NO_MEM; 
            s_alu_op <= ALU_ADD;

            s_alu_src <= ALU_SRC_AUIPC; --> pc + imm 

            s_load_op <= LOAD_NOP;
            s_regwrite <= '1';
            s_memtoreg <= '0';
            s_memread <= '0';

            s_exception <= '0';
            s_exception_cause <= MCAUSE_NONE;
            s_csr_op <= CSR_NONE;
            s_mul_op <= ALU_MUL; 



        when OPCODE_JALR =>
        
            s_jal <= '0';
            s_jalr <= '1';
            s_branch_op <= NO_BRANCH; 
            s_store_op <= NO_MEM; 
            s_alu_op <= ALU_ADD; 
            s_alu_src <= ALU_SRC_JAL; --> pc + 4; 
            
            s_load_op <= LOAD_NOP;
            s_regwrite <= '1';
            s_memtoreg <= '0';
            s_memread <= '0';

            s_exception <= '0';
            s_exception_cause <= MCAUSE_NONE;
            s_csr_op <= CSR_NONE;
            s_mul_op <= ALU_MUL; 


        
        when OPCODE_JAL =>

            s_jal <= '1';
            s_jalr <= '0';
            s_branch_op <= NO_BRANCH; 
            s_store_op <= NO_MEM; 
            s_alu_op <= ALU_ADD; 
            s_alu_src <= ALU_SRC_JAL; --> pc + 4; 
            s_load_op <= LOAD_NOP;
            s_regwrite <= '1';
            s_memtoreg <= '0';
            s_memread <= '0';

            s_exception <= '0';
            s_exception_cause <= MCAUSE_NONE;
            s_csr_op <= CSR_NONE;
            s_mul_op <= ALU_MUL; 



        when OPCODE_BRANCH =>

            s_jal <= '0';
            s_jalr <= '0';
            s_store_op <= NO_MEM; 
            s_alu_src <= ALU_SRC_ARTH; --> rs1 -rs2 
            s_memtoreg <= '0';
            s_load_op <= LOAD_NOP;
            s_regwrite <= '0';
            s_memread <= '0';
            s_mul_op <= ALU_MUL; 


            if (s_funct3  = F3_BRANCH_BEQ) then 
                s_branch_op <= BEQ;
                s_alu_op <= ALU_SUB; 
                s_exception <= '0';
                s_exception_cause <= MCAUSE_NONE;
                s_csr_op <= CSR_NONE;

            elsif (s_funct3 = F3_BRANCH_BNE) then
                s_branch_op <= BNE;
                s_alu_op <= ALU_SUB; 
                s_exception <= '0';
                s_exception_cause <= MCAUSE_NONE;
                s_csr_op <= CSR_NONE;

            elsif (s_funct3  = F3_BRANCH_BLT) then
                s_branch_op <= BLT;
                s_alu_op <= ALU_SUB; 
                s_exception <= '0';
                s_exception_cause <= MCAUSE_NONE;
                s_csr_op <= CSR_NONE;

            elsif (s_funct3  = F3_BRANCH_BGE) then
                s_branch_op <= BGE;
                s_alu_op <= ALU_SUB; 
                s_exception <= '0';
                s_exception_cause <= MCAUSE_NONE;
                s_csr_op <= CSR_NONE;

            elsif (s_funct3  = F3_BRANCH_BLTU) then
                s_branch_op <= BLTU;
                s_alu_op <= ALU_USUB; 
                s_exception <= '0';
                s_exception_cause <= MCAUSE_NONE;
                s_csr_op <= CSR_NONE;

            elsif (s_funct3 = F3_BRANCH_BGEU) then
                s_branch_op <= BGEU;
                s_alu_op <= ALU_USUB; 
                s_exception <= '0';
                s_exception_cause <= MCAUSE_NONE;
                s_csr_op <= CSR_NONE;

            else
                s_branch_op <= NO_BRANCH;
                s_alu_op <= ALU_INVALID;
                s_exception <= '1';
                s_exception_cause <= MCAUSE_ILLEGAL_INSTR;
                s_csr_op <= CSR_NONE;
            end if;
        
        when OPCODE_STORE =>
            s_jal <= '0';
            s_jalr <= '0';
            s_branch_op <= NO_BRANCH;

            s_alu_op <= ALU_ADD; 
            s_alu_src <= ALU_SRC_IMM; --> rs1 + imm 

            s_load_op <= LOAD_NOP;
            s_regwrite <= '0';
            s_memtoreg <= '0';
            s_memread <= '1';
            s_mul_op <= ALU_MUL; 


            if (s_funct3 = F3_STORE_SB) then 
                s_store_op <= STORE_BYTE;
                s_exception <= '0';
                s_exception_cause <= MCAUSE_NONE;
                s_csr_op <= CSR_NONE;
            elsif (s_funct3 = F3_STORE_SH) then
                s_store_op <= STORE_HALF;
                s_exception <= '0';
                s_exception_cause <= MCAUSE_NONE;
                s_csr_op <= CSR_NONE;
            elsif (s_funct3 = F3_STORE_SW) then 
                s_store_op <= STORE_WORD;
                s_exception <= '0';
                s_exception_cause <= MCAUSE_NONE;
                s_csr_op <= CSR_NONE;
            else
                s_store_op <= NO_MEM;
                s_exception <= '1';
                s_exception_cause <= MCAUSE_ILLEGAL_INSTR;
                s_csr_op <= CSR_NONE;
            end if;
        
        when OPCODE_LOAD =>
            s_jal <= '0';
            s_jalr <= '0';
            s_branch_op <= NO_BRANCH;
            s_regwrite <= '0';
            s_memtoreg <= '1';
            s_store_op <= NO_MEM;
            s_alu_src <= ALU_SRC_IMM;
            s_alu_op <= ALU_ADD;
            s_memread <= '0';
            s_mul_op <= ALU_MUL; 


            if (s_funct3 = F3_LOAD_LB) then
                s_load_op <= LOAD_LB;
                s_exception <= '0';
                s_exception_cause <= MCAUSE_NONE;
                s_csr_op <= CSR_NONE;
            elsif (s_funct3 = F3_LOAD_LH) then 
                s_load_op <= LOAD_LH;
                s_exception <= '0';
                s_exception_cause <= MCAUSE_NONE;
                s_csr_op <= CSR_NONE;
            elsif (s_funct3 = F3_LOAD_LW) then 
                s_load_op <= LOAD_LW;
                s_exception <= '0';
                s_exception_cause <= MCAUSE_NONE;
                s_csr_op <= CSR_NONE;
            elsif (s_funct3 = F3_LOAD_LBU) then 
                s_load_op <= LOAD_LBU;
                s_exception <= '0';
                s_exception_cause <= MCAUSE_NONE;
                s_csr_op <= CSR_NONE;
            elsif (s_funct3 = F3_LOAD_LHU) then 
                s_load_op <= LOAD_LHU;
                s_exception <= '0';
                s_exception_cause <= MCAUSE_NONE;
                s_csr_op <= CSR_NONE;
            else 
                s_load_op <= LOAD_NOP;
                s_exception <= '1';
                s_exception_cause <= MCAUSE_ILLEGAL_INSTR;
                s_csr_op <= CSR_NONE;
            end if; 

        when OPCODE_IMM =>
            s_jal <= '0';
            s_jalr <= '0';
            s_branch_op <= NO_BRANCH;
            s_load_op <= LOAD_NOP;
            s_regwrite <= '1';
            s_memtoreg <= '0';
            s_store_op <= NO_MEM;
            s_alu_src <= ALU_SRC_IMM;
            s_memread <= '0';
            s_mul_op <= ALU_MUL; 


            if (s_funct3 = F3_IMM_ADDI) then 
                s_alu_op <= ALU_ADD;
                s_exception <= '0';
                s_exception_cause <= MCAUSE_NONE;
                s_csr_op <= CSR_NONE;
            
            elsif (s_funct3 = F3_IMM_SLTI) then 
                s_alu_op <= ALU_SLT;
                s_exception <= '0';
                s_exception_cause <= MCAUSE_NONE;
                s_csr_op <= CSR_NONE;
            
            elsif (s_funct3 = F3_IMM_SLTIU) then 
                s_alu_op <= ALU_SLTU;
                s_exception <= '0';
                s_exception_cause <= MCAUSE_NONE;
                s_csr_op <= CSR_NONE;
            
            elsif (s_funct3 = F3_IMM_XORI) then
                s_alu_op <= ALU_XOR;
                s_exception <= '0';
                s_exception_cause <= MCAUSE_NONE;
                s_csr_op <= CSR_NONE;
            
            elsif (s_funct3 = F3_IMM_ORI) then 
                s_alu_op <= ALU_OR;
                s_exception <= '0';
                s_exception_cause <= MCAUSE_NONE;
                s_csr_op <= CSR_NONE;
            
            elsif (s_funct3 = F3_IMM_ANDI) then
                s_alu_op <= ALU_AND;
                s_exception <= '0';
                s_exception_cause <= MCAUSE_NONE;
                s_csr_op <= CSR_NONE;
            
            elsif (s_funct3 = F3_IMM_SLLI) then
                s_alu_op <= ALU_SLL;
                s_exception <= '0';
                s_exception_cause <= MCAUSE_NONE;
                s_csr_op <= CSR_NONE;
            
            elsif (s_funct3 = F3_IMM_SRLI) then

                if( s_funct7 = F7_OPIMM_SRLI ) then
                    s_alu_op <= ALU_SRL;
                    s_exception <= '0';
                    s_exception_cause <= MCAUSE_NONE;
                    s_csr_op <= CSR_NONE;
 
                elsif (s_funct7 = F7_OPIMM_SRAI) then 
                    s_alu_op <= ALU_SRA;
                    s_exception <= '0';
                    s_exception_cause <= MCAUSE_NONE;
                    s_csr_op <= CSR_NONE;

                else
                    s_alu_op <= ALU_INVALID;
                    s_exception <= '1';
                    s_exception_cause <= MCAUSE_NONE;
                    s_csr_op <= CSR_NONE;

                end if; 
            else 
                s_alu_op <= ALU_INVALID;
                s_exception <= '1';
                s_exception_cause <= MCAUSE_NONE;
                s_csr_op <= CSR_NONE;
            end if;

        when OPCODE_ARTH =>
            s_jal <= '0';
            s_jalr <= '0';
            s_branch_op <= NO_BRANCH;
            s_load_op <= LOAD_NOP;
            s_regwrite <= '1';
            s_memtoreg <= '0';
            s_store_op <= NO_MEM;
            s_alu_src <= ALU_SRC_ARTH;
            s_memread <= '0';


            if(s_funct7 = F7_OP_SLT) then 
                if (s_funct3 = F3_ARTH_ADD) then 
                    s_alu_op <= ALU_ADD;
                    s_exception <= '0';
                    s_exception_cause <= MCAUSE_NONE;
                    s_csr_op <= CSR_NONE;
                elsif (s_funct3 = F3_ARTH_SLL) then
                    s_alu_op <= ALU_SLL;
                    s_exception <= '0';
                    s_exception_cause <= MCAUSE_NONE;
                    s_csr_op <= CSR_NONE;
                elsif (s_funct3 = F3_ARTH_SLT) then
                    s_alu_op <= ALU_SLT;
                    s_exception <= '0';
                    s_exception_cause <= MCAUSE_NONE;
                    s_csr_op <= CSR_NONE;
                elsif (s_funct3 = F3_ARTH_SLTU) then
                    s_alu_op <= ALU_SLTU;
                    s_exception <= '0';
                    s_exception_cause <= MCAUSE_NONE;
                    s_csr_op <= CSR_NONE;
                elsif (s_funct3 = F3_ARTH_XOR) then
                    s_alu_op <= ALU_XOR;
                    s_exception <= '0';
                    s_exception_cause <= MCAUSE_NONE;
                    s_csr_op <= CSR_NONE;
                elsif (s_funct3 = F3_ARTH_SRL) then
                    s_alu_op <= ALU_SRL;
                    s_exception <= '0';
                    s_exception_cause <= MCAUSE_NONE;
                    s_csr_op <= CSR_NONE;
                elsif (s_funct3 = F3_ARTH_OR) then
                    s_alu_op <= ALU_OR;
                    s_exception <= '0';
                    s_exception_cause <= MCAUSE_NONE;
                    s_csr_op <= CSR_NONE;
                elsif (s_funct3 = F3_ARTH_AND) then
                    s_alu_op <= ALU_AND;
                    s_exception <= '0';
                    s_exception_cause <= MCAUSE_NONE;
                    s_csr_op <= CSR_NONE;
                else
                    s_alu_op <= ALU_INVALID;
                    s_exception <= '1';
                    s_exception_cause <=MCAUSE_ILLEGAL_INSTR;
                end if; 
            elsif (s_funct7 = F7_OP_SUB) then
                if (s_funct3 = F3_ARTH_SUB) then 
                    s_alu_op <= ALU_SUB;
                    s_exception <= '0';
                    s_exception_cause <= MCAUSE_NONE;
                    s_csr_op <= CSR_NONE;
                    
                elsif (s_funct3 = F3_ARTH_SRA) then
                    s_alu_op <= ALU_SRA;
                    s_exception <= '0';
                    s_exception_cause <= MCAUSE_NONE;
                    s_csr_op <= CSR_NONE;
                else
                    s_alu_op <= ALU_INVALID;
                    s_exception <= '1';
                    s_exception_cause <= MCAUSE_ILLEGAL_INSTR;
                    s_csr_op <= CSR_NONE;
                end if;
            


            --> multipication 
            elsif(s_funct7 = F7_MULT) then 
                    s_alu_op <= ALU_INVALID;

                if (s_funct3 = F3_MULT_MUL) then 
                    s_mul_op <= ALU_MUL; 
                    s_exception <= '0';
                    s_exception_cause <= MCAUSE_NONE;
                    s_csr_op <= CSR_NONE;
                    
                elsif (s_funct3 = F3_MULT_MULH) then
                    s_mul_op <= ALU_MULH;
                    s_exception <= '0';
                    s_exception_cause <= MCAUSE_NONE;
                    s_csr_op <= CSR_NONE;

                elsif (s_funct3 = F3_MULT_MULHSU) then
                    s_mul_op <= ALU_MULHSU;
                    s_exception <= '0';
                    s_exception_cause <= MCAUSE_NONE;
                    s_csr_op <= CSR_NONE;

                elsif (s_funct3 = F3_MULT_MULHU) then
                    s_mul_op <= ALU_MULHU;
                    s_exception <= '0';
                    s_exception_cause <= MCAUSE_NONE;
                    s_csr_op <= CSR_NONE;

                elsif (s_funct3 = F3_MULT_DIV) then
                    s_mul_op <= ALU_DIV;
                    s_exception <= '0';
                    s_exception_cause <= MCAUSE_NONE;
                    s_csr_op <= CSR_NONE;

                elsif (s_funct3 = F3_MULT_DIVU) then
                    s_mul_op <= ALU_DIVU;
                    s_exception <= '0';
                    s_exception_cause <= MCAUSE_NONE;
                    s_csr_op <= CSR_NONE;

                elsif (s_funct3 = F3_MULT_REM) then
                    s_mul_op <= ALU_REM;
                    s_exception <= '0';
                    s_exception_cause <= MCAUSE_NONE;
                    s_csr_op <= CSR_NONE;

                elsif (s_funct3 = F3_MULT_REMU) then
                    s_mul_op <= ALU_REMU;
                    s_exception <= '0';
                    s_exception_cause <= MCAUSE_NONE;
                    s_csr_op <= CSR_NONE;

                else
                    s_mul_op <= ALU_MUL;
                    s_exception <= '0';
                    s_exception_cause <= MCAUSE_ILLEGAL_INSTR;
                    s_csr_op <= CSR_NONE;
                end if; 
            

            else
                s_alu_op <= ALU_INVALID;
                s_mul_op <= ALU_MUL; 
                s_exception <= '1';
                s_exception_cause <= MCAUSE_ILLEGAL_INSTR;
                s_csr_op <= CSR_NONE;
            end if; 


        when OPCODE_SYSTEM => 

            s_jal <= '0';
            s_jalr <= '0';
            s_load_op <= LOAD_NOP;
            s_regwrite <= '0';
            s_memtoreg <= '0';
            s_store_op <= NO_MEM;
            s_alu_src <= ALU_SRC_INVALID;
            s_memread <= '0';
            s_mul_op <= ALU_MUL;
            s_alu_op <= ALU_INVALID;

            
            if (s_funct3 = "000") then 
                if(s_funct12 = x"000") then 
                    s_exception <= '1';
                    s_exception_cause <= MCAUSE_MCODE_ECALL;
                    s_branch_op <= NO_BRANCH;
                elsif(s_funct12 = x"001") then 
                    s_exception <= '1';
                    s_exception_cause <= MCAUSE_BREAKPOINT;
                    s_branch_op <= NO_BRANCH;
                else 
                    s_exception <= '1';
                    s_exception_cause <=MCAUSE_ILLEGAL_INSTR;
                    s_branch_op <= NO_BRANCH;
                end if; 

            elsif (s_funct3 = F3_CSRRW or s_funct3 = F3_CSRRWI) then 
                s_csr_op <= CSR_READ_WRITE;
                s_exception <= '0';
                s_exception_cause <= MCAUSE_NONE;
            elsif(s_funct3 = F3_CSRRS or s_funct3 = F3_CSRRSI) then 
                s_csr_op <= CSR_READ_SET; 
                s_exception <= '0';
                s_exception_cause <= MCAUSE_NONE; 
            elsif(s_funct3 = F3_CSRRC or s_funct3 = F3_CSRRCI) then  
                s_csr_op <= CSR_READ_CLEAR; 
                s_exception <= '0';
                s_exception_cause <= MCAUSE_NONE;
            else 
                s_csr_op <= CSR_NONE;
                s_exception <= '1';
                s_exception_cause <= MCAUSE_ILLEGAL_INSTR;
            end if; 


        when others =>
            s_jal <= '0';
            s_jalr <= '0';
            s_branch_op <= NO_BRANCH; 
            s_store_op <= NO_MEM; 
            s_alu_op <= ALU_INVALID;
            s_alu_src <= ALU_SRC_LUI; --> immediate + x0
            s_load_op <= LOAD_NOP;
            s_regwrite <= '0';
            s_memtoreg <= '0';
            s_memread <= '0';
            s_csr_op <= CSR_NONE;
            s_exception <= '1';
            s_exception_cause <= MCAUSE_ILLEGAL_INSTR;
            s_mul_op <= ALU_MUL;

            
    end case;
end process;

    o_jalr <= s_jalr;
    o_jal <= s_jal;
    o_branch_op <= s_branch_op;
    o_store_op <= s_store_op;
    o_alu_op <= s_alu_op;
    o_alu_src <= s_alu_src;
    o_load_op <= s_load_op;
    o_regwrite <= s_regwrite;
    o_memread <= s_memread;
    o_memtoreg <= s_memtoreg;
    o_exception <= s_exception;
    o_exception_cause <= s_exception_cause;
    o_csr_op <= s_csr_op;
    o_mul_op <= s_mul_op;

    
end architecture behavioral;