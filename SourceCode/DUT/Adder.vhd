library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Adder is
    generic ( 
        N : natural := 64 
    );
    port (
        A    : in  std_logic_vector(N-1 downto 0);
        B    : in  std_logic_vector(N-1 downto 0);
        S    : out std_logic_vector(N-1 downto 0);
        Cin  : in  std_logic;
        Cout : out std_logic;
        Ovfl : out std_logic
    );
end entity Adder;

-------------------------------------------------------------------------------
-- Architecture A: Baseline (Structural Ripple-Carry)
-------------------------------------------------------------------------------
architecture Baseline of Adder is
    component FullAdder is
        port (
            A, B, Cin : in  std_logic;
            S, Cout   : out std_logic
        );
    end component;

    signal carry : std_logic_vector(N downto 0);
begin
    carry(0) <= Cin;

    GEN_RCA: for i in 0 to N-1 generate
        FA_inst: FullAdder
            port map (
                A    => A(i),
                B    => B(i),
                Cin  => carry(i),
                S    => S(i),
                Cout => carry(i+1)
            );
    end generate GEN_RCA;

    Cout <= carry(N);
    Ovfl <= carry(N) xor carry(N-1);

end architecture Baseline;

-------------------------------------------------------------------------------
-- Architecture B: FastRipple (Behavioral using '+' operator)
-------------------------------------------------------------------------------
architecture FastRipple of Adder is
    signal temp_A    : unsigned(N downto 0);
    signal temp_B    : unsigned(N downto 0);
    signal temp_Cin  : unsigned(N downto 0);
    signal sum_full  : unsigned(N downto 0);
    signal internal_S : std_logic_vector(N-1 downto 0);
begin
    temp_A   <= unsigned('0' & A);
    temp_B   <= unsigned('0' & B);
    
    -- Correct Cin expansion for synthesis
    temp_Cin(0)          <= Cin;
    temp_Cin(N downto 1) <= (others => '0');
    
    sum_full <= temp_A + temp_B + temp_Cin;
    
    internal_S <= std_logic_vector(sum_full(N-1 downto 0));
    S    <= internal_S;
    Cout <= sum_full(N);
    
    -- Overflow for 2's complement: 
    -- If (A_msb == B_msb) and (S_msb /= A_msb)
    Ovfl <= '1' when (A(N-1) = B(N-1)) and (internal_S(N-1) /= A(N-1)) else '0';

end architecture FastRipple;

-------------------------------------------------------------------------------
-- Architecture C: CSA (Conditional-Sum / Carry-Select)
-- This implementation uses a 4-bit Carry-Select block structure.
-------------------------------------------------------------------------------
architecture CSA of Adder is
    constant BLOCK_SIZE : integer := 4;
    constant NUM_BLOCKS : integer := N / BLOCK_SIZE;

    -- Internal components for hierarchical structure
    component RippleAdder4 is
        port (
            A, B : in  std_logic_vector(3 downto 0);
            Cin  : in  std_logic;
            S    : out std_logic_vector(3 downto 0);
            Cout : out std_logic
        );
    end component;

    signal block_carries : std_logic_vector(NUM_BLOCKS downto 0);
    
    -- Signals to hold results from all blocks for Cin=0 and Cin=1
    signal S0_all, S1_all : std_logic_vector(N-1 downto 0);
    signal C0_all, C1_all : std_logic_vector(NUM_BLOCKS-1 downto 0);

begin
    block_carries(0) <= Cin;

    GEN_CSA: for i in 0 to NUM_BLOCKS-1 generate
    begin
        -- Each block calculates two sums: one for Cin=0 and one for Cin=1
        ADD0: entity work.Adder(Baseline)
            generic map ( N => BLOCK_SIZE )
            port map (
                A => A((i+1)*BLOCK_SIZE-1 downto i*BLOCK_SIZE),
                B => B((i+1)*BLOCK_SIZE-1 downto i*BLOCK_SIZE),
                Cin => '0',
                S => S0_all((i+1)*BLOCK_SIZE-1 downto i*BLOCK_SIZE),
                Cout => C0_all(i),
                Ovfl => open
            );
            
        ADD1: entity work.Adder(Baseline)
            generic map ( N => BLOCK_SIZE )
            port map (
                A => A((i+1)*BLOCK_SIZE-1 downto i*BLOCK_SIZE),
                B => B((i+1)*BLOCK_SIZE-1 downto i*BLOCK_SIZE),
                Cin => '1',
                S => S1_all((i+1)*BLOCK_SIZE-1 downto i*BLOCK_SIZE),
                Cout => C1_all(i),
                Ovfl => open
            );

        -- Mux to select based on actual carry-in to this block
        S((i+1)*BLOCK_SIZE-1 downto i*BLOCK_SIZE) <= S0_all((i+1)*BLOCK_SIZE-1 downto i*BLOCK_SIZE) when block_carries(i) = '0' else S1_all((i+1)*BLOCK_SIZE-1 downto i*BLOCK_SIZE);
        block_carries(i+1) <= C0_all(i) when block_carries(i) = '0' else C1_all(i);
        
    end generate GEN_CSA;

    Cout <= block_carries(NUM_BLOCKS);

    -- For Overflow, we look inside the last block logic.
    process(A, B, block_carries, S0_all, S1_all)
        variable last_S_msb : std_logic;
    begin
        if block_carries(NUM_BLOCKS-1) = '0' then
            last_S_msb := S0_all(N-1);
        else
            last_S_msb := S1_all(N-1);
        end if;
        
        if (A(N-1) = B(N-1)) and (last_S_msb /= A(N-1)) then
            Ovfl <= '1';
        else
            Ovfl <= '0';
        end if;
    end process;

end architecture CSA;
