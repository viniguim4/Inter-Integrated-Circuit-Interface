library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_i2c_component is
end entity;

architecture tb of tb_i2c_component is

    component i2c_interface_component is
        generic (
            ARST_LVL: std_logic := '0'
        );
        port (
            p_clock : in std_logic;
            p_reset : in std_logic := not ARST_LVL;

            --mode
            component_mode : in std_logic; -- 0 = primary 1 = secondary

            --memory
            m_start_dump : in std_logic := '0';
            m_data_dump  : out std_logic;

            -- wishbone signals
            i2c_addr_i : in std_logic_vector(6 downto 0); -- i2c addressed
            i2c_read_e : in std_logic; -- 0 = WRITE, 1 = READ

            SCL : inout std_logic;
            SDA : inout std_logic
            
        );
    end component;

    signal clk   : std_logic := '0';
    signal rst   : std_logic := '0';
    signal start : std_logic := '0';
    signal memorydump1  : std_logic;
    signal primary : std_logic := '0';
    signal p_addr : std_logic_vector(6 downto 0) := "0000010";
    signal p_mode : std_logic := '1';

    signal clk_2 : std_logic := '0';
    signal rst_2 : std_logic := '0';
    signal start_2 : std_logic := '0';
    signal memorydump2    : std_logic;
    signal secondary : std_logic := '1';
    signal s_addr : std_logic_vector(6 downto 0) := "1100110";
    signal s_mode : std_logic := '0';

    signal SCL : std_logic;
    signal SDA : std_logic;

    constant periodo : time := 20 ns;             -- 50 MHz clock

begin

    primary_i2c : i2c_interface_component port map(
        p_clock => clk,
        p_reset => rst,
        component_mode => primary ,
        m_start_dump => start,
        m_data_dump => memorydump1,
        i2c_addr_i => p_addr,
        i2c_read_e => p_mode,
        SCL => SCL,
        SDA => SDA
    );

    secondary_i2c : i2c_interface_component port map(
        p_clock => clk_2,
        p_reset => rst_2,
        component_mode => secondary ,
        m_start_dump => start_2,
        m_data_dump => memorydump2,
        i2c_addr_i => s_addr,
        i2c_read_e => s_mode,
        SCL => SCL,
        SDA => SDA
    );

    clk <= not clk after (periodo/2);
    clk_2 <= clk;

    process begin
        rst <= '0';
        rst_2 <= '0';
        wait for 250 ns;
        rst <= '1';
        rst_2 <= '1';
        WAIT FOR 700 us;
        start <= '1';
        start_2 <= '1';
        wait;
    end process;

end architecture;