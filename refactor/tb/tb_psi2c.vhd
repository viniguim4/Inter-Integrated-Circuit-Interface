library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_psi2c is
end entity;

architecture tb of tb_psi2c is

    component top_uut is
        port ( 
            clk : in std_logic;
            rst : in std_logic;
            start : in std_logic;
            memorydump1 : out std_logic_vector(7 downto 0);
            memorydump2 : out std_logic_vector(7 downto 0);
            SDA : inout std_logic;
            SCL : inout std_logic
        );
    end component;

    signal clk   : std_logic := '0';
    signal rst   : std_logic := '0';
    signal start : std_logic := '0';
    signal memorydump1  : std_logic_vector (7 downto 0);
    signal memorydump2    : std_logic_vector(7 downto 0);
    signal SCL : std_logic;
    signal SDA : std_logic;

    constant periodo : time := 31.25 ns;             -- 32 MHz clock

begin   

    uut : top_uut port map(
        clk => clk,
        rst => rst,
        start => start,
        memorydump1 => memorydump1,
        memorydump2 => memorydump2,
        SCL => SCL,
        SDA => SDA
    );

    clk <= not clk after (periodo/2);

    process begin
            rst <= '0';
            wait for 250 ns;
            rst <= '1';
            start <= '1';
            WAIT FOR 350us;
            wait;
        end process;
end architecture;
