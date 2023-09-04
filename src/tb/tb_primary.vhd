library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_primary is
end entity;

architecture tb of tb_primary is

    component i2c_primary is
        port ( 
            p_clock   : in  std_logic;
            p_reset   : in  std_logic;
            
            --memory
            m_start_dump : in  std_logic;
            m_data_dump  : out std_logic_vector (7 downto 0);
            
            -- wishbone signals
            i2c_addr_i    : inout std_logic_vector(6 downto 0);  -- i2c addressed
            i2c_read_e : inout  std_logic; -- 0 = WRITE, 1 = READ

            SCL : inout std_logic ;
            SDA : inout std_logic
        );
    end component;

    signal p_clock   : std_logic := '0';
    signal p_reset   : std_logic := '0';
    signal m_start_dump : std_logic := '0';
    signal m_data_dump  : std_logic_vector (7 downto 0);
    signal i2c_addr_i    : std_logic_vector(6 downto 0);
    signal i2c_read_e : std_logic;
    signal SCL : std_logic;
    signal SDA : std_logic;
    constant periodo : time := 20 ns;             -- 32 MHz clock

begin   

    UUT : i2c_primary port map (
        p_clock   => p_clock,
        p_reset   => p_reset,
        m_start_dump => m_start_dump,
        m_data_dump  => m_data_dump,
        i2c_addr_i    => i2c_addr_i,
        i2c_read_e => i2c_read_e,
        SCL => SCL,
        SDA => SDA
    );

    p_clock <= not p_clock after (periodo/2);

    process begin
            p_reset <= '0';
            wait for 250 ns;
            p_reset <= '1';
            m_start_dump <= '1';
            WAIT FOR 1000 us;
            p_reset <= '0';
            wait for 250 ns;
            p_reset <= '1';
            wait;
        end process;
end architecture;
