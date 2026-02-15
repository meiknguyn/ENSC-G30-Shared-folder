library ieee;
use ieee.std_logic_1164.all;

entity Adder_CSA is
    generic ( N : natural := 64 );
    port (
        A, B : in  std_logic_vector(N-1 downto 0);
        S    : out std_logic_vector(N-1 downto 0);
        Cin  : in  std_logic;
        Cout, Ovfl : out std_logic
    );
end entity Adder_CSA;

architecture Wrapper of Adder_CSA is
begin
    DUT: entity work.Adder(CSA)
        generic map ( N => N )
        port map ( A => A, B => B, S => S, Cin => Cin, Cout => Cout, Ovfl => Ovfl );
end architecture Wrapper;
