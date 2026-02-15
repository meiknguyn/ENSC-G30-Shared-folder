library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all; -- Required for writing std_logic
use std.textio.all;

entity tb_adder_csa is
end entity tb_adder_csa;

architecture test of tb_adder_csa is
    -- Constants
    constant N : natural := 64;
    constant TestVectorFile : string := "Adder00.tvs";
    constant PreStimTime    : time := 1 ns;
    constant PostStimTime   : time := 10 ns;

    -- Signals
    signal A, B : std_logic_vector(N-1 downto 0);
    signal S    : std_logic_vector(N-1 downto 0);
    signal Cin  : std_logic;
    signal Cout, Ovfl : std_logic;
    
    signal S_expected : std_logic_vector(N-1 downto 0);
    signal Cout_expected, Ovfl_expected : std_logic;
    
    signal measurement_index : integer := 0;

    -- Helper function to convert hex character to std_logic_vector
    function hex_to_slv(c : character) return std_logic_vector is
    begin
        case c is
            when '0' => return "0000"; when '1' => return "0001";
            when '2' => return "0010"; when '3' => return "0011";
            when '4' => return "0100"; when '5' => return "0101";
            when '6' => return "0110"; when '7' => return "0111";
            when '8' => return "1000"; when '9' => return "1001";
            when 'a' | 'A' => return "1010"; when 'b' | 'B' => return "1011";
            when 'c' | 'C' => return "1100"; when 'd' | 'D' => return "1101";
            when 'e' | 'E' => return "1110"; when 'f' | 'F' => return "1111";
            when others => return "XXXX";
        end case;
    end function;

    -- Helper to convert hex string to slv
    function hex_str_to_slv(s : string) return std_logic_vector is
        variable result : std_logic_vector(s'length*4-1 downto 0);
    begin
        for i in 1 to s'length loop
            result( (s'length-i+1)*4-1 downto (s'length-i)*4 ) := hex_to_slv(s(i));
        end loop;
        return result;
    end function;

    -- Helper to convert slv to hex string for reporting
    function slv_to_hex(v : std_logic_vector) return string is
        constant hex_digit : string(1 to 16) := "0123456789ABCDEF";
        variable result : string(1 to v'length/4);
        variable nibble : integer;
    begin
        for i in 0 to (v'length/4 - 1) loop
            nibble := to_integer(unsigned(v( (i+1)*4-1 downto i*4 )));
            result( (v'length/4) - i ) := hex_digit(nibble + 1);
        end loop;
        return result;
    end function;

begin

    -- DUT Instantiation (CSA version)
    DUT: entity work.Adder(CSA)
        generic map ( N => N )
        port map (
            A => A, B => B, Cin => Cin,
            S => S, Cout => Cout, Ovfl => Ovfl
        );

    -- Stimulus process
    STIM: process
        file tv_file : text open read_mode is TestVectorFile;
        variable tv_line : line;
        variable v_A_hex, v_B_hex, v_S_hex : string(1 to 16);
        variable v_Cin_bit, v_Cout_bit, v_Ovfl_bit : character;
        variable v_space : character;
        variable v_pass : boolean;
        variable report_line : line;
    begin
        while not endfile(tv_file) loop
            readline(tv_file, tv_line);
            
            if tv_line'length = 0 or tv_line(1) = '#' then
                next;
            end if;

            read(tv_line, v_A_hex);
            read(tv_line, v_space);
            read(tv_line, v_B_hex);
            read(tv_line, v_space);
            read(tv_line, v_Cin_bit);
            read(tv_line, v_space);
            read(tv_line, v_S_hex);
            read(tv_line, v_space);
            read(tv_line, v_Cout_bit);
            read(tv_line, v_space);
            read(tv_line, v_Ovfl_bit);

            measurement_index <= measurement_index + 1;

            A <= (others => 'X');
            B <= (others => 'X');
            Cin <= 'X';
            wait for PreStimTime;

            A <= hex_str_to_slv(v_A_hex);
            B <= hex_str_to_slv(v_B_hex);
            if v_Cin_bit = '1' then Cin <= '1'; else Cin <= '0'; end if;
            
            S_expected <= hex_str_to_slv(v_S_hex);
            if v_Cout_bit = '1' then Cout_expected <= '1'; else Cout_expected <= '0'; end if;
            if v_Ovfl_bit = '1' then Ovfl_expected <= '1'; else Ovfl_expected <= '0'; end if;

            wait for PostStimTime;

            v_pass := (S = S_expected) and (Cout = Cout_expected) and (Ovfl = Ovfl_expected);

            write(report_line, string'("Idx: "));
            write(report_line, measurement_index);
            write(report_line, string'(" | A: ")); write(report_line, v_A_hex);
            write(report_line, string'(" | B: ")); write(report_line, v_B_hex);
            write(report_line, string'(" | Cin: ")); write(report_line, v_Cin_bit);
            write(report_line, string'(" | S: ")); 
            if S = S_expected then write(report_line, slv_to_hex(S));
            else write(report_line, slv_to_hex(S) & " (EXP: " & v_S_hex & ")"); end if;
            
            write(report_line, string'(" | Cout: ")); write(report_line, Cout);
            write(report_line, string'(" | Ovfl: ")); write(report_line, Ovfl);
            
            if v_pass then
                write(report_line, string'(" | RESULT: PASS"));
            else
                write(report_line, string'(" | RESULT: FAIL"));
                assert v_pass report "Verification failed!" severity warning;
            end if;
            
            writeline(output, report_line);

        end loop;

        write(tv_line, string'("Simulation Finished. Processing of ") & integer'image(measurement_index) & string'(" vectors completed."));
        writeline(output, tv_line);
        wait;
    end process;

end architecture test;
