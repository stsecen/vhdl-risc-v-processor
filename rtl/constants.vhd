library ieee;
use ieee.std_logic_1164.all;

package constants is

    constant PC_RESET_ADDRESS: std_logic_vector(31 downto 0) := (others => '0');
    --> REGISTERS WIDTH FOR RV32I ISA <--

    constant XLEN_1: integer := 31;
    constant RLEN_1: integer := 4;

    --> OPCODES FOR RV32I ISA  <--

    constant OPCODE_LUI: std_logic_vector(6 downto 0)     := "0110111"; 
    constant OPCODE_AUIPC: std_logic_vector(6 downto 0)   := "0010111"; 
    constant OPCODE_JALR: std_logic_vector(6 downto 0)    := "1100111"; 
    constant OPCODE_JAL: std_logic_vector(6 downto 0)     := "1101111"; 
    constant OPCODE_BRANCH: std_logic_vector(6 downto 0)  := "1100011"; 
    constant OPCODE_STORE: std_logic_vector(6 downto 0)   := "0100011"; 
    constant OPCODE_IMM: std_logic_vector(6 downto 0)     := "0010011"; 
    constant OPCODE_ARTH: std_logic_vector(6 downto 0)    := "0110011";
    constant OPCODE_LOAD: std_logic_vector(6 downto 0)    := "0000011";
    constant OPCODE_SYSTEM: std_logic_vector(6 downto 0)   := "1110011";

    --> FUNCTION 3 FOR RV32I ISA <--

    --> BRANCHES 
    constant F3_JALR: std_logic_vector(2 downto 0) := "000";
    constant F3_BRANCH_BEQ: std_logic_vector(2 downto 0)  := "000";
    constant F3_BRANCH_BNE: std_logic_vector(2 downto 0)  := "001";
    constant F3_BRANCH_BLT: std_logic_vector(2 downto 0)  := "100";
    constant F3_BRANCH_BGE: std_logic_vector(2 downto 0)  := "101";
    constant F3_BRANCH_BLTU: std_logic_vector(2 downto 0) := "110";
    constant F3_BRANCH_BGEU: std_logic_vector(2 downto 0) := "111";
    
    --> LOAD 
    constant F3_LOAD_LB: std_logic_vector(2 downto 0) := "000";
    constant F3_LOAD_LH: std_logic_vector(2 downto 0) := "001";
    constant F3_LOAD_LW: std_logic_vector(2 downto 0) := "010";
    constant F3_LOAD_LBU: std_logic_vector(2 downto 0) := "100";
    constant F3_LOAD_LHU: std_logic_vector(2 downto 0) := "101";

    --> STORE
    constant F3_STORE_SB: std_logic_vector(2 downto 0) := "000";
    constant F3_STORE_SH: std_logic_vector(2 downto 0) := "001";
    constant F3_STORE_SW: std_logic_vector(2 downto 0) := "010";

    --> IMMEDIATE 
    constant F3_IMM_ADDI: std_logic_vector(2 downto 0) := "000";
    constant F3_IMM_SLTI: std_logic_vector(2 downto 0) := "010";
    constant F3_IMM_SLTIU: std_logic_vector(2 downto 0) := "011";
    constant F3_IMM_XORI: std_logic_vector(2 downto 0) := "100";
    constant F3_IMM_ORI: std_logic_vector(2 downto 0)  := "110";
    constant F3_IMM_ANDI: std_logic_vector(2 downto 0) := "111";
    constant F3_IMM_SLLI: std_logic_vector(2 downto 0) := "001";
    constant F3_IMM_SRLI: std_logic_vector(2 downto 0) := "101";
    constant F3_IMM_SRAI: std_logic_vector(2 downto 0) := "101";

    --> REGISTERS
    constant F3_ARTH_ADD: std_logic_vector(2 downto 0) := "000";
    constant F3_ARTH_SUB: std_logic_vector(2 downto 0) := "000";
    constant F3_ARTH_SLL: std_logic_vector(2 downto 0) := "001";
    constant F3_ARTH_SLT: std_logic_vector(2 downto 0) := "010";
    constant F3_ARTH_SLTU: std_logic_vector(2 downto 0):= "011";
    constant F3_ARTH_XOR: std_logic_vector(2 downto 0) := "100";
    constant F3_ARTH_SRL: std_logic_vector(2 downto 0) := "101";
    constant F3_ARTH_SRA: std_logic_vector(2 downto 0) := "101";
    constant F3_ARTH_OR: std_logic_vector(2 downto 0) := "110";
    constant F3_ARTH_AND: std_logic_vector(2 downto 0) := "111";

    --> FUNCTION 7 FOR RV32I ISA <--

    
    constant F7_OPIMM_SLLI: std_logic_vector(6 downto 0) := "0000000";
    constant F7_OPIMM_SRLI: std_logic_vector(6 downto 0) := "0000000";
    constant F7_OPIMM_SRAI: std_logic_vector(6 downto 0) := "0100000";

    constant F7_OP_ADD: std_logic_vector(6 downto 0) := "0000000";
    constant F7_OP_SUB: std_logic_vector(6 downto 0) := "0100000";
    constant F7_OP_SLL: std_logic_vector(6 downto 0) := "0000000";
    constant F7_OP_SLT: std_logic_vector(6 downto 0) := "0000000";
    constant F7_OP_SLTU: std_logic_vector(6 downto 0) := "0000000";
    constant F7_OP_XOR: std_logic_vector(6 downto 0) := "0000000";
    constant F7_OP_SRL: std_logic_vector(6 downto 0) := "0000000";
    constant F7_OP_SRA: std_logic_vector(6 downto 0) := "0100000";
    constant F7_OP_OR: std_logic_vector(6 downto 0) := "0000000";
    constant F7_OP_AND: std_logic_vector(6 downto 0) := "0000000";

    --> ALU OPERATIONS <--

    constant ALU_AND: std_logic_vector(3 downto 0) := "0000";
    constant ALU_OR: std_logic_vector(3 downto 0) :=  "0001";
    constant ALU_XOR: std_logic_vector(3 downto 0) := "0010";
    constant ALU_ADD: std_logic_vector(3 downto 0) := "0011";
    constant ALU_SUB: std_logic_vector(3 downto 0) := "0100";
    constant ALU_SLT: std_logic_vector(3 downto 0) := "0101";
    constant ALU_SLTU: std_logic_vector(3 downto 0) := "0110";
    constant ALU_SLL: std_logic_vector(3 downto 0) :=  "0111";
    constant ALU_SRL: std_logic_vector(3 downto 0) := "1000";
    constant ALU_SRA: std_logic_vector(3 downto 0) := "1001";
    constant ALU_USUB: std_logic_vector(3 downto 0) := "1010";
    constant ALU_INVALID: std_logic_vector(3 downto 0) := "1111";

    --> ALU SRC 

    constant ALU_SRC_INVALID: std_logic_vector(2 downto 0) := "000";
    constant ALU_SRC_LUI: std_logic_vector(2 downto 0) := "001";
    constant ALU_SRC_AUIPC: std_logic_vector(2 downto 0) := "010";
    constant ALU_SRC_JAL: std_logic_vector(2 downto 0) := "011";
    constant ALU_SRC_ARTH: std_logic_vector(2 downto 0) := "100";
    constant ALU_SRC_IMM: std_logic_vector(2 downto 0) := "101";

    --> COMPARATOR 

    constant NO_BRANCH: std_logic_vector(2 downto 0) := "000";
    constant BEQ: std_logic_vector(2 downto 0) := "001";
    constant BNE: std_logic_vector(2 downto 0) := "010";
    constant BLT: std_logic_vector(2 downto 0) := "011";
    constant BGE: std_logic_vector(2 downto 0) := "100";
    constant BLTU: std_logic_vector(2 downto 0) := "101";
    constant BGEU: std_logic_vector(2 downto 0) := "110";

    --> LOAD CONTROL 

    constant LOAD_NOP: std_logic_vector(2 downto 0) := "000";
    constant LOAD_LB: std_logic_vector(2 downto 0) := "001";
    constant LOAD_LH: std_logic_vector(2 downto 0) := "010";
    constant LOAD_LW: std_logic_vector(2 downto 0) := "011";
    constant LOAD_LBU: std_logic_vector(2 downto 0) := "100";
    constant LOAD_LHU: std_logic_vector(2 downto 0) := "101";

    --> STORE CONTROL 

    constant NO_MEM: std_logic_vector(1 downto 0) := "00"; 
    constant STORE_BYTE: std_logic_vector(1 downto 0) := "01";
    constant STORE_HALF: std_logic_vector(1 downto 0) := "10";
    constant STORE_WORD: std_logic_vector(1 downto 0) := "11";

    constant NOP: std_logic_vector(XLEN_1 downto 0) := (31 downto 5 => '0') & "10011";


    constant F7_MULT : std_logic_vector(6 downto 0) := "0000001";

    constant F3_MULT_MUL : std_logic_vector(2 downto 0) := "000";
    constant F3_MULT_MULH : std_logic_vector(2 downto 0) := "001";
    constant F3_MULT_MULHSU : std_logic_vector(2 downto 0) := "010";
    constant F3_MULT_MULHU : std_logic_vector(2 downto 0) := "011";
    constant F3_MULT_DIV : std_logic_vector(2 downto 0) := "100";
    constant F3_MULT_DIVU : std_logic_vector(2 downto 0) := "101";
    constant F3_MULT_REM : std_logic_vector(2 downto 0) := "110";
    constant F3_MULT_REMU : std_logic_vector(2 downto 0) := "111";

    constant ALU_MUL : std_logic_vector(2 downto 0) := "000";
    constant ALU_MULH : std_logic_vector(2 downto 0) := "001";
    constant ALU_MULHSU : std_logic_vector(2 downto 0) := "010";
    constant ALU_MULHU : std_logic_vector(2 downto 0) := "011";
    constant ALU_DIV : std_logic_vector(2 downto 0) := "100";
    constant ALU_DIVU : std_logic_vector(2 downto 0) := "101";
    constant ALU_REM : std_logic_vector(2 downto 0) := "110";
    constant ALU_REMU : std_logic_vector(2 downto 0) := "111";

    

    --> csr's ids  
        --> machine information registers
    constant CSR_MVENDORID : std_logic_vector(11 downto 0) := x"f11";
	constant CSR_MARCHID   : std_logic_vector(11 downto 0) := x"f12";
	constant CSR_MIMPID    : std_logic_vector(11 downto 0) := x"f13";
	constant CSR_MHARTID   : std_logic_vector(11 downto 0) := x"f14";

        --> machine trap setup 
    constant CSR_MSTATUS : std_logic_vector(11 downto 0) := x"300";
	constant CSR_MISA : std_logic_vector(11 downto 0) := x"301";
    constant CSR_MIE : std_logic_vector(11 downto 0) := x"304";
    constant CSR_MTVEC : std_logic_vector(11 downto 0) := x"305";

        --> machine trap handling 
    
    constant CSR_MSCRATCH : std_logic_vector(11 downto 0) := x"340";
	constant CSR_MEPC : std_logic_vector(11 downto 0) := x"341";
	constant CSR_MCAUSE : std_logic_vector(11 downto 0) := x"342";
	constant CSR_MTVAL : std_logic_vector(11 downto 0) := x"343";
    constant CSR_MIP : std_logic_vector(11 downto 0) := x"344";
    
        --> machine counter timers 
    
    constant CSR_CYCLE : std_logic_vector(11 downto 0) := x"b00";
	constant CSR_CYCLEH : std_logic_vector(11 downto 0) := x"b80";
	constant CSR_INSTRET : std_logic_vector(11 downto 0) := x"b02";
    constant CSR_INSTRETH : std_logic_vector(11 downto 0) := x"b82";
    
    constant CSR_TIME : std_logic_vector(11 downto 0)  := x"c01";
    constant CSR_TIMEH : std_logic_vector(11 downto 0)  := x"c81";
    constant CSR_MTIMECMP : std_logic_vector(11 downto 0) := x"321";

    --> debug&trace registers

    constant CSR_TSELECT : std_logic_vector(11 downto 0) := x"7A0";
    constant CSR_TDATA1 : std_logic_vector(11 downto 0) := x"7A1";
    constant CSR_TDATA2 : std_logic_vector(11 downto 0) := x"7A2";
    constant CSR_TDATA3 : std_logic_vector(11 downto 0) := x"7A3";

        --> debug mode registers
    constant CSR_DCSR : std_logic_vector(11 downto 0) := x"7B1";
    constant CSR_DPC : std_logic_vector(11 downto 0) := x"7B1";
    constant CSR_DSCRATCH0 : std_logic_vector(11 downto 0) := x"7B2";
    constant CSR_DSTRATCH1 : std_logic_vector(11 downto 0) := x"7B3";

        --> mcause values 
    constant MCAUSE_INSTR_ADDRESS_MISSALIGN : std_logic_vector(5 downto 0) := "000000";
	constant MCAUSE_INSTR_ACCESS_FAULT : std_logic_vector(5 downto 0) := "000001";
	constant MCAUSE_ILLEGAL_INSTR : std_logic_vector(5 downto 0) := "000010";
	constant MCAUSE_BREAKPOINT : std_logic_vector(5 downto 0) := "000011";
	constant MCAUSE_LOAD_ADDRESS_MISALIGN : std_logic_vector(5 downto 0) := "000100";
	constant MCAUSE_LOAD_ACCESS_FAULT : std_logic_vector(5 downto 0) := "000101";
	constant MCAUSE_STORE_ADDRESS_MISALIGN : std_logic_vector(5 downto 0) := "000110";
	constant CSR_CAUSE_STORE_ADDRESS_FAULT : std_logic_vector(5 downto 0) := "000111";
    constant MCAUSE_MCODE_ECALL : std_logic_vector(5 downto 0) := "001011";
    constant MCAUSE_NONE : std_logic_vector(5 downto 0) := "011111";
     

    constant F3_CSRRW: std_logic_vector(2 downto 0) := "001";
    constant F3_CSRRS : std_logic_vector(2 downto 0) := "010";
    constant F3_CSRRC : std_logic_vector(2 downto 0) := "011";
    constant F3_CSRRWI : std_logic_vector(2 downto 0) := "101";
    constant F3_CSRRSI : std_logic_vector(2 downto 0) := "110";
    constant F3_CSRRCI : std_logic_vector(2 downto 0) := "111";

    constant CSR_READ_WRITE : std_logic_vector(1 downto 0) := "11";
    constant CSR_READ_CLEAR : std_logic_vector(1 downto 0) := "10";
    constant CSR_READ_SET : std_logic_vector(1 downto 0) := "01";
    constant CSR_NONE : std_logic_vector(1 downto 0) := "00";




end package constants;

