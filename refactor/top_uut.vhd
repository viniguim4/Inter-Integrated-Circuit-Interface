library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_uut is
    port(
        clk : in std_logic;
        rst : in std_logic;
        start : in std_logic;
        memorydump1 : out std_logic_vector(7 downto 0);
        memorydump2 : out std_logic_vector(7 downto 0);
        SDA : inout std_logic;
        SCL : inout std_logic
    );
end entity;

architecture structural of top_uut is
    component i2c_primary is
        port (
        p_clock : in std_logic;
        p_reset : in std_logic;
    
        --memory
        m_start_dump : in std_logic ;
        m_data_dump  : out std_logic_vector (7 downto 0);
    
        SCL : inout std_logic;
        SDA : inout std_logic
        );
    end component i2c_primary;

    component i2c_secondary is
        port (       
        p_clock : in std_logic;
        p_reset : in std_logic;
    
        --memory
        m_start_dump : in std_logic ;
        m_data_dump  : out std_logic_vector (7 downto 0);
    
        SCL : inout std_logic;
        SDA : inout std_logic

        );

    end component i2c_secondary;

begin   
    i2c_primary_inst : i2c_primary
        port map (
            p_clock => clk,
            p_reset => rst,
            m_start_dump => start,
            m_data_dump => memorydump1,
            SCL => SCL,
            SDA => SDA
        );

    i2c_secondary_inst : i2c_secondary
        port map (
            p_clock => clk,
            p_reset => rst,
            m_start_dump => start,
            m_data_dump => memorydump2,
            SCL => SCL,
            SDA => SDA
        );
end architecture;
