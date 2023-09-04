library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity i2c_primary is
  generic
  (
    ARST_LVL       : std_logic                     := '0';
    SELF_I2C_ADDR  : std_logic_vector(6 downto 0)  := "0000010";
    SELF_I2C_MODE  : std_logic                     := '0'; -- 0 = WRITE, 1 = READ
    DATA_VECTOR    : std_logic_vector(39 downto 0) := x"48656c6c6f"; -- "Hello"
    REQ_REG_VECTOR : std_logic_vector(39 downto 0) := x"0706050403" -- "Hello"
  );
  port
  (

    p_clock : in std_logic;
    p_reset : in std_logic := not ARST_LVL;

    --memory
    m_start_dump : in std_logic := '0';
    m_data_dump  : out std_logic_vector (7 downto 0);

    -- wishbone signals
    i2c_addr_i : inout std_logic_vector(6 downto 0); -- i2c addressed
    i2c_read_e : inout std_logic; -- 0 = WRITE, 1 = READ

    SCL : inout std_logic;
    SDA : inout std_logic
  );
end entity i2c_primary;

architecture structural of i2c_primary is
  component memory_dump is
    port
    (
      m_clock   : in std_logic;
      m_reset   : in std_logic;
      m_write_e : in std_logic;
      m_address : in std_logic_vector (7 downto 0);
      m_datain  : in std_logic_vector (7 downto 0);

      -- dump memory
      m_start_dump : in std_logic;
      m_data_dump  : out std_logic_vector (7 downto 0)
    );
  end component memory_dump;

  component i2c_master_top is
    generic
    (
      ARST_LVL : std_logic := '0' -- asynchronous reset level
    );
    port
    (
      --done I2C transfer
      sc_done_o : out std_logic; -- I2C transfer done
      -- wishbone signals
      wb_clk_i   : in std_logic; -- master clock input
      wb_rst_i   : in std_logic := '0'; -- synchronous active high reset
      arst_i     : in std_logic := not ARST_LVL; -- asynchronous reset
      wb_adr_i   : in std_logic_vector(2 downto 0); -- lower address bits
      wb_dat_i   : in std_logic_vector(7 downto 0); -- Databus input
      wb_dat_o   : out std_logic_vector(7 downto 0); -- Databus output
      wb_we_i    : in std_logic; -- Write enable input
      wb_stb_i   : in std_logic; -- Strobe signals / core select signal
      wb_cyc_i   : in std_logic; -- Valid bus cycle input
      wb_ack_o   : out std_logic; -- Bus cycle acknowledge output
      wb_inta_o  : out std_logic; -- interrupt request output signal
      i2c_addr_i : in std_logic_vector(6 downto 0);

      -- i2c lines
      scl_pad_i    : in std_logic; -- i2c clock line input
      scl_pad_o    : out std_logic; -- i2c clock line output
      scl_padoen_o : out std_logic; -- i2c clock line output enable, active low
      sda_pad_i    : in std_logic; -- i2c data line input
      sda_pad_o    : out std_logic; -- i2c data line output
      sda_padoen_o : out std_logic -- i2c data line output enable, active low
    );
  end component i2c_master_top;

  -- SINAIS
  --aux
  constant I2C_FREQ     : integer := 100000; -- 100 kHz
  constant CLK_PERIOD   : time    := 20 ns; -- 32 MHz clock
  constant CLK_FREQ     : integer := 1000000000 * ns/CLK_PERIOD; -- 32 MHz
  constant PREESCALER   : integer := CLK_FREQ / (I2C_FREQ * 5) - 1;
  signal preescaler_aux : std_logic_vector(15 downto 0);
  signal sc_done_o      : std_logic;
  --memory
  signal m_write_e : std_logic                     := '0';
  signal m_address : std_logic_vector (7 downto 0) := (others => '0');
  --wishbone
  signal wb_rst_i  : std_logic                    := '0';
  signal wb_adr_i  : std_logic_vector(2 downto 0) := (others => '0');
  signal wb_dat_i  : std_logic_vector(7 downto 0) := (others => '0');
  signal wb_dat_o  : std_logic_vector(7 downto 0);
  signal wb_we_i   : std_logic := '0';
  signal wb_stb_i  : std_logic := '1';
  signal wb_cyc_i  : std_logic := '1';
  signal wb_ack_o  : std_logic;
  signal wb_inta_o : std_logic;
  --i2c   
  signal scl_pad_i        : std_logic := '0';
  signal scl_pad_o        : std_logic;
  signal scl_padoen_o     : std_logic;
  signal sda_pad_i        : std_logic := '0';
  signal sda_pad_o        : std_logic;
  signal sda_padoen_o     : std_logic;
  signal counter          : integer                       := 0;
  signal data_vector_s    : std_logic_vector(39 downto 0) := DATA_VECTOR;
  signal req_reg_vector_s : std_logic_vector(39 downto 0) := REQ_REG_VECTOR;
  signal i2c_target_addr  : std_logic_vector(6 downto 0); --secondary address

begin

  memory : component memory_dump
    port map(
      m_clock      => p_clock,
      m_reset      => p_reset,
      m_write_e    => m_write_e,
      m_address    => m_address,
      m_datain     => wb_dat_o,
      m_start_dump => m_start_dump,
      m_data_dump  => m_data_dump
    );

    i2c_master : component i2c_master_top
      port
      map (
      sc_done_o    => sc_done_o,
      wb_clk_i     => p_clock,
      wb_rst_i     => wb_rst_i,
      arst_i       => p_reset,
      wb_adr_i     => wb_adr_i,
      wb_dat_i     => wb_dat_i,
      wb_dat_o     => wb_dat_o,
      wb_we_i      => wb_we_i,
      wb_stb_i     => wb_stb_i,
      wb_cyc_i     => wb_cyc_i,
      wb_ack_o     => wb_ack_o,
      wb_inta_o    => wb_inta_o,
      i2c_addr_i   => i2c_addr_i,
      scl_pad_i    => scl_pad_i,
      scl_pad_o    => scl_pad_o,
      scl_padoen_o => scl_padoen_o,
      sda_pad_i    => sda_pad_i,
      sda_pad_o    => sda_pad_o,
      sda_padoen_o => sda_padoen_o
      );

      preescaler_aux  <= std_logic_vector(to_unsigned(PREESCALER, preescaler_aux'length));
      i2c_addr_i      <= SELF_I2C_ADDR;
      i2c_read_e      <= SELF_I2C_MODE;
      i2c_target_addr <= "1100110"; --secondary address
      wb_rst_i        <= '0';
      wb_stb_i        <= '1';
      wb_cyc_i        <= '1';
      -- instacia componentes
      statemachine : block
        type states is (init, set_preescaler_lo, set_preescaler_hi, en_I2C, start_I2C, start_I2C_w, addressing_I2C,
          addressing_I2C_w, writetx_I2C, writetx_I2C_b, writetx_I2C_c, stop_I2C, stop_I2C_b,
          set_read_mode, acquire_data, send_ack, w_datas, idle_for_address, idle, idle_stop);
        signal c_state        : states;
        signal callback_state : states;

      begin
        nxt_state_decoder : process (p_clock, p_reset)
        begin
          if p_reset = ARST_LVL then
            data_vector_s   <= DATA_VECTOR;
            req_reg_vector_s <= REQ_REG_VECTOR;
            c_state <= init;
          elsif rising_edge(p_clock) then
            case c_state is
              when init => -- init state for handshake
                if (wb_ack_o = '1') then 
                  c_state <= set_preescaler_lo;
                else
                  c_state <= init;
                end if;

              when set_preescaler_lo =>
                wb_we_i  <= '1';
                wb_adr_i <= "000"; -- LO preescaler register address in wb
                wb_dat_i <= preescaler_aux(7 downto 0); -- SET LOW PRESCALE TO 3F =  63 to 100 kHz
                if (wb_ack_o = '1') then
                  wb_we_i <= '0';
                  c_state <= set_preescaler_hi;
                else
                  c_state <= set_preescaler_lo;
                end if;

              when set_preescaler_hi =>
                wb_we_i  <= '1';
                wb_adr_i <= "001"; -- HI preescaler register address in wb
                wb_dat_i <= preescaler_aux(15 downto 8);
                if (wb_ack_o = '1') then
                  wb_we_i <= '0';
                  c_state <= en_I2C;
                else
                  c_state <= set_preescaler_hi;
                end if;

              when en_I2C =>
                wb_we_i  <= '1';
                wb_adr_i <= "010"; -- control register in wb
                wb_dat_i <= "10000000"; -- -- Enable I2C core (7) and disable I2C interrupt (6)
                if (wb_ack_o = '1') then
                  wb_we_i <= '0';
                  c_state <= start_I2C;
                else
                  c_state <= en_I2C;
                end if;

              when start_I2C =>
                wb_we_i  <= '1';
                wb_adr_i <= "100"; --commandregister
                wb_dat_i <= "10010000"; -- start condition (7) and write on SDA (4) SXRWXXXX
                if (wb_ack_o = '1') then
                  wb_we_i <= '0';
                  c_state <= start_I2C_w;
                else
                  c_state <= start_I2C;
                end if;

              when start_I2C_w =>
                if (sc_done_o = '1') then
                  c_state <= idle_for_address;
                else
                  c_state <= start_I2C_w;
                end if;

              when idle_for_address =>
                if (wb_ack_o = '1') then
                  c_state <= addressing_I2C;
                else
                  c_state <= idle_for_address;
                end if;

              when addressing_I2C =>
                wb_we_i  <= '1';
                wb_adr_i <= "011"; -- register of byte to be transmited
                wb_dat_i <= i2c_target_addr & i2c_read_e; -- address of slave AND RW BIT
                if (wb_ack_o = '1') then
                  wb_we_i <= '0';
                  c_state <= addressing_I2C_w;
                else
                  c_state <= addressing_I2C;
                end if;

              when addressing_I2C_w =>
                if (sc_done_o = '1') then
                  if i2c_read_e = '0' then
                    counter <= data_vector_s'length;
                  else
                    counter <= req_reg_vector_s'length;
                  end if;
                  callback_state <= writetx_I2C;
                  c_state        <= idle;
                else
                  c_state <= addressing_I2C_w;
                end if;

              when writetx_I2C =>
                wb_we_i  <= '1';
                wb_adr_i <= "011"; -- register of byte to be transmited
                if i2c_read_e = '0' then    -- ESCREVE UM BYTE OU O ENDEREÇO DE REQUISIÇÃO DO REGISTRADOR
                  wb_dat_i <= data_vector_s(7 downto 0);
                else
                  wb_dat_i <= req_reg_vector_s(7 downto 0);
                end if;
                if (wb_ack_o = '1') then
                  c_state <= writetx_I2C_b;
                  wb_we_i <= '0';
                else
                  c_state <= writetx_I2C;
                end if;

              when writetx_I2C_b =>
                if counter > 1 then
                  wb_we_i  <= '1';
                  wb_adr_i <= "100"; -- register of byte to be transmited
                  wb_dat_i <= "00010000";
                  if (wb_ack_o = '1') then
                    c_state <= writetx_I2C_c;
                    wb_we_i <= '0';
                  else
                    c_state <= writetx_I2C_b;
                  end if;
                else
                  c_state <= idle_stop;
                  if i2c_read_e = '0' then
                    counter <= data_vector_s'length;
                  else
                    counter <= req_reg_vector_s'length;
                  end if;
                end if;

              when writetx_I2C_c =>
                if (sc_done_o = '1') then
                  if i2c_read_e = '0' then
                    callback_state <= writetx_I2C;
                  else
                    callback_state <= set_read_mode; -- NEED A READ MODE TO READ FROM THE SECONDARY REGISTER QUERY
                  end if;
                  c_state        <= idle;
                  counter        <= counter - 8;
                  if i2c_read_e = '0' then
                    data_vector_s  <= "00000000" & data_vector_s(39 downto 8);
                  else
                    req_reg_vector_s <= "00000000" & req_reg_vector_s(39 downto 8);
                  end if;
                else
                    c_state <= writetx_I2C_c;
                end if;
              
              when set_read_mode =>  
                wb_adr_i <= "100"; -- control register in wb
                wb_dat_i <= "00100000"; -- Enable I2C read (5)
                wb_we_i  <= '1';
                if (wb_ack_o = '1') then
                  wb_we_i <= '0';
                  c_state <= acquire_data;

                else
                  c_state <= set_read_mode;
                end if;

              when acquire_data =>
                if (sc_done_o = '1') then
                  c_state <= send_ack;
                else
                  c_state <= acquire_data;
                end if;  
              
              when send_ack =>
                wb_adr_i <= "011";
                if (sc_done_o = '1') then
                    c_state <= w_datas;
                else
                    c_state <= send_ack;
                end if;

              when w_datas =>
                wb_adr_i <= "011"; -- register of byte to be read
                m_address <= std_logic_vector(to_unsigned(((req_reg_vector_s'length-counter)/8), 8));
                m_write_e <= '1';
                if (wb_ack_o = '1') then
                  c_state <= writetx_I2C;  -- CALLBACK TO WRITE MODE TO REQUEST THE NEXT REGISTER DATA
                  m_write_e <= '0';
                else
                  c_state <= w_datas;
                end if;

              when idle_stop =>
                if (wb_ack_o = '1') then
                  c_state <= stop_I2C;
                else
                  c_state <= idle_stop;
                end if;

              when stop_I2C =>
                wb_we_i  <= '1';
                wb_adr_i <= "100"; --commandregister
                wb_dat_i <= "01000000"; -- stop condition (2) XSXXXXXX
                if (wb_ack_o = '1') then
                  wb_we_i <= '0';
                  c_state <= stop_I2C_b;
                else
                  c_state <= stop_I2C;
                end if;

              when stop_I2C_b =>
                if (sc_done_o = '1') then
                  c_state <= idle;
                else
                  c_state <= stop_I2C_b;
                end if;

              when idle =>
                if (sc_done_o = '1') then
                  c_state <= callback_state;
                else
                  c_state <= idle;
                end if;

            end case;
          end if;
        end process nxt_state_decoder;
      end block statemachine;

      -- I2C  LINES
      SCL <= scl_pad_o when (scl_padoen_o = '0') else
        'Z';
      SDA <= sda_pad_o when (sda_padoen_o = '0') else
        'Z';

      scl_pad_i <= SCL;
      sda_pad_i <= SDA;

    end architecture;