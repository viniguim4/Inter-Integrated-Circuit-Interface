library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity i2c_primary is
    generic(
        ARST_LVL : std_logic := '0';
        SELF_I2C_ADDR : std_logic_vector(6 downto 0) := "1100110";
        SELF_I2C_MODE : std_logic := '0'; -- 0 = WRITE, 1 = READ
    );
	port (
        
        p_clock   : in  std_logic;
        p_reset   : in  std_logic := not ARST_LVL;
        
        --memory
        m_start_dump : in  std_logic;
        m_data_dump  : out std_logic_vector (7 downto 0);
        
        -- wishbone signals
        i2c_addr_i    : in std_logic_vector(6 downto 0) := SELF_I2C_ADDR ;  -- i2c addressed
        i2c_read_e : in  std_logic := SELF_I2C_MODE; -- 0 = WRITE, 1 = READ

		SCL : inout std_logic ;
		SDA : inout std_logic
	);
end entity i2c_primary;

architecture structural of i2c_primary is
    component memory is
        port(
            m_clock   : in  std_logic;
            m_reset   : in  std_logic;
            m_write_e : in  std_logic;
            m_address : in  std_logic_vector (7 downto 0);
            m_datain  : in  std_logic_vector (7 downto 0);
        
            -- dump memory
            m_start_dump : in  std_logic;
            m_data_dump  : out std_logic_vector (7 downto 0);
        )
    end component memory;

    component i2c_master_top is
        generic(
            ARST_LVL : std_logic := '0'                       -- asynchronous reset level
        );
        port   (
                --done I2C transfer
                sc_done_o       : out std_logic;                   -- I2C transfer done
                -- wishbone signals
                wb_clk_i      : in  std_logic;                    -- master clock input
                wb_rst_i      : in  std_logic := '0';             -- synchronous active high reset
                arst_i        : in  std_logic := not ARST_LVL;    -- asynchronous reset
                wb_adr_i      : in  std_logic_vector(2 downto 0); -- lower address bits
                wb_dat_i      : in  std_logic_vector(7 downto 0); -- Databus input
                wb_dat_o      : out std_logic_vector(7 downto 0); -- Databus output
                wb_we_i       : in  std_logic;                    -- Write enable input
                wb_stb_i      : in  std_logic;                    -- Strobe signals / core select signal
                wb_cyc_i      : in  std_logic;                    -- Valid bus cycle input
                wb_ack_o      : out std_logic;                    -- Bus cycle acknowledge output
                wb_inta_o     : out std_logic;                    -- interrupt request output signal
                i2c_addr_i	  : in  std_logic_vector(6 downto 0);

                -- i2c lines
                scl_pad_i     : in  std_logic;                    -- i2c clock line input
                scl_pad_o     : out std_logic;                    -- i2c clock line output
                scl_padoen_o  : out std_logic;                    -- i2c clock line output enable, active low
                sda_pad_i     : in  std_logic;                    -- i2c data line input
                sda_pad_o     : out std_logic;                    -- i2c data line output
                sda_padoen_o  : out std_logic                     -- i2c data line output enable, active low
        );
    end component i2c_master_top;

    -- SINAIS
        --aux
    constant I2C_FREQ : integer := 100000;         -- 100 kHz
    constant CLK_PERIOD : time := 31.25 ns;             -- 32 MHz clock
    signal preescaler_aux : std_logic_vector(15 downto 0) := (others => '0');
    signal sc_done_o : std_logic;
        --memory
    signal m_write_e : std_logic := '0';
    signal m_address : std_logic_vector (7 downto 0) := (others => '0');
    signal m_start_dump : std_logic := '0';
    signal m_data_dump  : std_logic_vector (7 downto 0);
        --wishbone
    signal wb_rst_i : std_logic := '0';
    signal wb_adr_i : std_logic_vector(2 downto 0) := (others => '0');
    signal wb_dat_i : std_logic_vector(7 downto 0) := (others => '0');
    signal wb_dat_o : std_logic_vector(7 downto 0);
    signal wb_we_i  : std_logic := '0';
    signal wb_stb_i : std_logic := '1';
    signal wb_cyc_i : std_logic := '1';
    signal wb_ack_o : std_logic;
    signal wb_inta_o : std_logic;
            --i2c   
    signal scl_pad_i    : std_logic := '0';
    signal scl_pad_o    : std_logic;
    signal scl_padoen_o : std_logic;
    signal sda_pad_i    : std_logic := '0';
    signal sda_pad_o    : std_logic;
    signal sda_padoen_o : std_logic;

begin

    memory_dump : component memory
        port map(
            m_clock   => p_clock,
            m_reset   => p_reset,
            m_write_e => m_write_e,
            m_address => m_address,
            m_datain  => wb_dat_o,
            m_start_dump => m_start_dump,
            m_data_dump  => m_data_dump
        );

    i2c_master : component i2c_master_top
        port map (
            sc_done_o     => sc_done_o,
            wb_clk_i      => p_clock,
            wb_rst_i      => wb_rst_i,
            arst_i        => p_reset,
            wb_adr_i      => wb_adr_i,
            wb_dat_i      => wb_dat_i,
            wb_dat_o      => wb_dat_o,
            wb_we_i       => wb_we_i,
            wb_stb_i      => wb_stb_i,
            wb_cyc_i      => wb_cyc_i,
            wb_ack_o      => wb_ack_o,
            wb_inta_o     => wb_inta_o,
            i2c_addr_i	  => i2c_addr_i,
            scl_pad_i     => scl_pad_i,
            scl_pad_o     => scl_pad_o,
            scl_padoen_o  => scl_padoen_o,
            sda_pad_i     => sda_pad_i,
            sda_pad_o     => sda_pad_o,
            sda_padoen_o  => sda_padoen_o
        );

    preescaler : process(p_clock)
    begin
        if rising_edge(p_clock) then
            wb_adr_i <= "000";
            wb_dat_i <= "00111111";  -- SET LOW PRESCALE TO 3F =  63 to 100 kHz
        end if;
    end process preescaler;
    -- instacia componentes
    statemachine : block
        type states is (set_preescaler, en_I2C, start_I2C, addressing_I2C, writetx_I2C, readtx_I2C, stop_I2C, idle);
        signal c_state : states;
    begin
        nxt_state_decoder: process(p_clock, p_reset, wb_ack_o, sc_done_o)
	    begin
            if p_reset = ARST_LVL then
                c_state <= set_preescaler;
            elsif rising_edge(p_clock) then
                case c_state is
                    when set_preescaler =>
                        wb_we_i <= '1';
                        wb_adr_i <= "000"; -- LO preescaler register address in wb
                        preescaler_aux <= (1/(CLK_PERIOD * I2C_FREQ * 5)) - 1; -- 32MHz / 100kHz = 320
                        wb_dat_i <= preescaler_aux(7 downto 0); -- SET LOW PRESCALE TO 3F =  63 to 100 kHz
                        wait until rising_edge(wb_ack_o);
                        wb_adr_i <= "001"; -- HI preescaler register address in wb
                        wb_dat_i <= preescaler_aux(15 downto 8);
                        wait until rising_edge(wb_ack_o);
                        wb_we_i <= '0';
                        c_state <= en_I2C;
                    when en_I2C =>
                        wb_we_i <= '1';
                        wb_adr_i <= "010"; -- control register in wb
                        wb_dat_i <= "10000000"; -- -- Enable I2C core (7) and disable I2C interrupt (6)
                        wait until rising_edge(wb_ack_o);
                        wb_we_i <= '0';
                        c_state <= start_I2C;
                    when start_I2C =>
                        wb_we_i <= '1';
                        wb_adr_i <= "100"; --commandregister
                        wb_dat_i <= "10010000"; -- start condition (7) and write on SDA (4) SXRWXXXX
                        wait until rising_edge(wb_ack_o);
                        wb_we_i <= '0';
                        wait until rising_edge(sc_done_o);
                        c_state <= transaction_I2C;
                    when addresing_I2C =>
                        wb_we_i <= '1';
                        wb_adr_i <= "011"; -- register of byte to be transmited
                        wb_dat_i <= i2c_addr_i & i2c_read_e; -- address of slave AND RW BIT
                        wait until rising_edge(wb_ack_o);
                        wb_we_i <= '0';                        
                        wait until rising_edge(sc_done_o);
                        if i2c_read_e = '0' then
                            c_state <= writetx_I2C;
                        else
                            c_state <= readtx_I2C;
                        end if;
                    when writetx_I2C =>
                        -- passar so uns 8 primero byte
                        
                        

                    

        
        end process nxt_state_decoder;
    end block statemachine;

        -- I2C  LINES
	SCL <= scl_pad_o when (scl_padoen_o = '0') else 'Z';
    SDA <= sda_pad_o when (sda_padoen_o = '0') else 'Z';
        
    scl_pad_i <= SCL;
    sda_pad_i <= SDA;

end architecture;