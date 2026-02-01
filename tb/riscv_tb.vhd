library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

library work;
use work.regfile_pkg.all;

entity cpu_tb is
end entity cpu_tb;

architecture Behavioral of cpu_tb is

    -- Component declaration
    component cpu_top is
        port (
            clk          : in  std_logic;
            reset        : in  std_logic;
            imem_addr    : out std_logic_vector(31 downto 0);
            imem_data    : in  std_logic_vector(31 downto 0);
            dmem_addr    : out std_logic_vector(31 downto 0);
            dmem_wdata   : out std_logic_vector(31 downto 0);
            dmem_rdata   : in  std_logic_vector(31 downto 0);
            dmem_we      : out std_logic;
            dmem_re      : out std_logic;
            pc_out       : out std_logic_vector(31 downto 0);
            reg_dump     : out reg_array_public
        );
    end component;

    -- Clock and Reset
    signal clk          : std_logic := '0';
    signal reset        : std_logic := '1';
    signal sim_done     : boolean := false;

    -- CPU Interface Signals
    signal imem_addr    : std_logic_vector(31 downto 0);
    signal imem_data    : std_logic_vector(31 downto 0);
    signal dmem_addr    : std_logic_vector(31 downto 0);
    signal dmem_wdata   : std_logic_vector(31 downto 0);
    signal dmem_rdata   : std_logic_vector(31 downto 0);
    signal dmem_we      : std_logic;
    signal dmem_re      : std_logic;
    signal pc_out       : std_logic_vector(31 downto 0);
    signal reg_dump     : reg_array_public;

    -- Memory arrays
    type mem_array is array (0 to 1023) of std_logic_vector(31 downto 0);
    signal imem : mem_array := (others => x"00000013"); -- NOP
    signal dmem : mem_array := (others => x"00000000");

    -- Simulation control
    constant CLK_PERIOD : time := 10 ns;
    constant MAX_CYCLES : integer := 1000;
    
    -- Testbench configuration
    constant HEX_FILE_PATH : string := "C:\riscv_cpu_project\tb\test_add.hex";
    constant TRACE_OUTPUT  : string := "trace_output.txt";
    constant FINAL_OUTPUT  : string := "final_output.txt";

    -- Tracking variables
    signal cycle_count  : integer := 0;
    signal prev_pc      : std_logic_vector(31 downto 0) := (others => '0');
    signal pc_stable_count : integer := 0;

    -- For tracking writes to register file
    signal prev_reg_dump : reg_array_public := (others => (others => '0'));
    
    -- Pipeline tracking for trace generation (track PC, instruction, and Rd through pipeline)
    type pc_pipe_array is array (0 to 4) of std_logic_vector(31 downto 0);
    type instr_pipe_array is array (0 to 4) of std_logic_vector(31 downto 0);
    type rd_pipe_array is array (0 to 4) of std_logic_vector(4 downto 0);
    type regwrite_pipe_array is array (0 to 4) of std_logic;
    signal pc_pipeline : pc_pipe_array := (others => (others => '0'));
    signal instr_pipeline : instr_pipe_array := (others => x"00000013");
    signal rd_pipeline : rd_pipe_array := (others => (others => '0'));
    signal regwrite_pipeline : regwrite_pipe_array := (others => '0');

begin

    -- Clock Generation
    clk_process: process
    begin
        while not sim_done loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- DUT Instantiation
    DUT: cpu_top
        port map (
            clk        => clk,
            reset      => reset,
            imem_addr  => imem_addr,
            imem_data  => imem_data,
            dmem_addr  => dmem_addr,
            dmem_wdata => dmem_wdata,
            dmem_rdata => dmem_rdata,
            dmem_we    => dmem_we,
            dmem_re    => dmem_re,
            pc_out     => pc_out,
            reg_dump   => reg_dump
        );

    -- Instruction Memory Interface
    imem_process: process(imem_addr)
        variable addr_int : integer;
    begin
        addr_int := to_integer(unsigned(imem_addr)) / 4;
        if addr_int >= 0 and addr_int < 1024 then
            imem_data <= imem(addr_int);
        else
            imem_data <= x"00000013"; -- NOP
        end if;
    end process;

    -- Data Memory Interface
    dmem_process: process(clk)
        variable addr_int : integer;
    begin
        if rising_edge(clk) then
            addr_int := to_integer(unsigned(dmem_addr)) / 4;
            
            -- Write operation
            if dmem_we = '1' and addr_int >= 0 and addr_int < 1024 then
                dmem(addr_int) <= dmem_wdata;
            end if;
            
            -- Read operation
            if addr_int >= 0 and addr_int < 1024 then
                dmem_rdata <= dmem(addr_int);
            else
                dmem_rdata <= x"00000000";
            end if;
        end if;
    end process;

    -- Main Test Process
    test_process: process
        file hex_file     : text;
        file trace_file   : text;
        file final_file   : text;
        variable line_in  : line;
        variable line_out : line;
        variable hex_val  : std_logic_vector(31 downto 0);
        variable char     : character;
        variable good     : boolean;
        variable addr     : integer := 0;
        variable step_count : integer := 0;
        variable has_data : boolean;
        variable addr_int : integer;
        variable instr_val : std_logic_vector(31 downto 0);
        variable rd_val : integer;
        variable opcode : std_logic_vector(6 downto 0);
        variable will_write : std_logic;
        
    begin
        -- Load hex file into instruction memory
        report "Loading hex file: " & HEX_FILE_PATH;
        file_open(hex_file, HEX_FILE_PATH, read_mode);
        
        -- Start loading at address 
        addr := 0;
        while not endfile(hex_file) loop
            readline(hex_file, line_in);
            
            -- Try to read hex value from line
            if line_in'length > 0 then
                -- Try to read as hex 
                hread(line_in, hex_val, good);
                
                if good then
                    imem(addr) <= hex_val;
                    report "Loaded instruction " & integer'image(addr) & ": 0x" & to_hstring(hex_val);
                    addr := addr + 1;
                end if;
            end if;
        end loop;
        file_close(hex_file);
        
        report "Loaded " & integer'image(addr) & " instructions from hex file";
        
        -- Debug: print first few instructions
        report "First instructions loaded:";
        for j in 0 to 7 loop
            report "  [" & integer'image(j*4) & "]: 0x" & to_hstring(imem(j));
        end loop;
        
        -- Reset sequence
        reset <= '1';
        wait for CLK_PERIOD * 5;
        wait until falling_edge(clk); -- Release reset before the rising edge
        reset <= '0';
        
        -- Open trace file
        file_open(trace_file, TRACE_OUTPUT, write_mode);
        write(line_out, string'("# Golden Trace Log"));
        writeline(trace_file, line_out);
        write(line_out, string'("Step") & HT & "PC" & HT & "Instr" & HT & "Rd" & HT & "Value");
        writeline(trace_file, line_out);
        
        -- Run simulation and track register writes
        prev_reg_dump <= (others => (others => '0'));
        
        -- Initialize pipeline tracking
        pc_pipeline <= (others => (others => '0'));
        instr_pipeline <= (others => x"00000013");
        rd_pipeline <= (others => (others => '0'));
        regwrite_pipeline <= (others => '0');
        
        for i in 0 to MAX_CYCLES loop
            wait until rising_edge(clk);
            cycle_count <= cycle_count + 1;
            
            -- Shift pipeline first (before fetching new instruction)
            pc_pipeline(4) <= pc_pipeline(3);
            pc_pipeline(3) <= pc_pipeline(2);
            pc_pipeline(2) <= pc_pipeline(1);
            pc_pipeline(1) <= pc_pipeline(0);
            
            instr_pipeline(4) <= instr_pipeline(3);
            instr_pipeline(3) <= instr_pipeline(2);
            instr_pipeline(2) <= instr_pipeline(1);
            instr_pipeline(1) <= instr_pipeline(0);
            
            rd_pipeline(4) <= rd_pipeline(3);
            rd_pipeline(3) <= rd_pipeline(2);
            rd_pipeline(2) <= rd_pipeline(1);
            rd_pipeline(1) <= rd_pipeline(0);
            
            regwrite_pipeline(4) <= regwrite_pipeline(3);
            regwrite_pipeline(3) <= regwrite_pipeline(2);
            regwrite_pipeline(2) <= regwrite_pipeline(1);
            regwrite_pipeline(1) <= regwrite_pipeline(0);
            
            -- Now capture current PC and fetch its instruction
            pc_pipeline(0) <= pc_out;
            
            -- Get current instruction at PC
            addr_int := to_integer(unsigned(pc_out)) / 4;
            if addr_int >= 0 and addr_int < 1024 then
                instr_val := imem(addr_int);
            else
                instr_val := x"00000013";
            end if;
            
            -- Extract opcode and rd from instruction
            opcode := instr_val(6 downto 0);
            rd_val := to_integer(unsigned(instr_val(11 downto 7)));
            
            -- Determine if this instruction will write to register file
            if (opcode = "0110011" or  -- R-type
                opcode = "0010011" or  -- I-type (ADDI, etc)
                opcode = "0000011" or  -- Load
                opcode = "0110111" or  -- LUI
                opcode = "0010111" or  -- AUIPC
                opcode = "1101111" or  -- JAL
                opcode = "1100111") and -- JALR
               rd_val /= 0 then
                will_write := '1';
            else
                will_write := '0';
            end if;
            
            -- Store current instruction and control info at pipeline stage 0
            instr_pipeline(0) <= instr_val;
            rd_pipeline(0) <= instr_val(11 downto 7);
            regwrite_pipeline(0) <= will_write;
            
            -- Log instruction if it writes to register file (at WB stage)
            if regwrite_pipeline(4) = '1' then
                rd_val := to_integer(unsigned(rd_pipeline(4)));
                
                -- Debug output
                if step_count < 10 then
                    report "Step " & integer'image(step_count) & 
                           ": PC=0x" & to_hstring(pc_pipeline(4)) & 
                           " Instr=0x" & to_hstring(instr_pipeline(4)) &
                           " Rd=x" & integer'image(rd_val) &
                           " Value=0x" & to_hstring(reg_dump(rd_val));
                end if;
                
                write(line_out, integer'image(step_count));
                write(line_out, HT & "0x");
                hwrite(line_out, pc_pipeline(4));
                write(line_out, HT & "0x");
                hwrite(line_out, instr_pipeline(4));
                write(line_out, HT & "x" & integer'image(rd_val));
                write(line_out, HT & "0x");
                hwrite(line_out, reg_dump(rd_val));
                writeline(trace_file, line_out);
                
                step_count := step_count + 1;
            end if;
            
            prev_reg_dump <= reg_dump;
            
            -- Check for completion (PC not changing for several cycles)
            if pc_out = prev_pc then
                pc_stable_count <= pc_stable_count + 1;
                if pc_stable_count > 10 then
                    report "PC stable at " & integer'image(to_integer(unsigned(pc_out))) & " - simulation complete";
                    exit;
                end if;
            else
                pc_stable_count <= 0;
                prev_pc <= pc_out;
            end if;
            
            -- Timeout check
            if i = MAX_CYCLES then
                report "Maximum cycles reached - stopping simulation";
                exit;
            end if;
        end loop;
        
        file_close(trace_file);
        
        -- Generate final output file
        file_open(final_file, FINAL_OUTPUT, write_mode);
        
        write(line_out, string'("# FINAL REGISTER STATE (32-bit Hex)"));
        writeline(final_file, line_out);
        
        write(line_out, string'("PC: "));
        hwrite(line_out, pc_out);
        writeline(final_file, line_out);
        
        for i in 0 to 31 loop
            write(line_out, string'("x") & integer'image(i) & ": ");
            hwrite(line_out, reg_dump(i));
            writeline(final_file, line_out);
        end loop;
        
        writeline(final_file, line_out); -- blank line
        write(line_out, string'("# FINAL DATA MEMORY STATE (Address: Data)"));
        writeline(final_file, line_out);
        
        -- Write non-zero data memory locations
        has_data := false;
        for i in 0 to 1023 loop
            if dmem(i) /= x"00000000" then
                write(line_out, string'("0x"));
                hwrite(line_out, std_logic_vector(to_unsigned(i*4, 32)));
                write(line_out, string'(": 0x"));
                hwrite(line_out, dmem(i));
                writeline(final_file, line_out);
                has_data := true;
            end if;
        end loop;
        
        if not has_data then
            write(line_out, string'("# (no writes)"));
            writeline(final_file, line_out);
        end if;
        
        file_close(final_file);
        
        report "Simulation complete. Output files generated:";
        report "  - " & TRACE_OUTPUT;
        report "  - " & FINAL_OUTPUT;
        
        sim_done <= true;
        wait;
    end process;

end architecture Behavioral;
