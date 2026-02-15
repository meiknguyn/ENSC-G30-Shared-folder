library ieee;
use ieee.std_logic_1164.all;

entity Adder_FastRipple is
    generic ( N : natural := 64 );
    port (
        A, B : in  std_logic_vector(N-1 downto 0);
        S    : out std_logic_vector(N-1 downto 0);
        Cin  : in  std_logic;
        Cout, Ovfl : out std_logic
    );
end entity Adder_FastRipple;

architecture Wrapper of Adder_FastRipple is
begin
    DUT: entity work.Adder(FastRipple)
        generic map ( N => N )
        port map ( A => A, B => B, S => S, Cin => Cin, Cout => Cout, Ovfl => Ovfl );
end architecture Wrapper;
