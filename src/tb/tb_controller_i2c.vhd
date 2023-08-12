library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_controller_i2c is
    
end entity;

architecture tb of tb_controller_i2c is

    component i2c_master_top is 
        port (
            -- wishbone signals
            wb_clk_i      : in  std_logic;                    -- master clock input
            wb_rst_i      : in  std_logic;                    -- synchronous active high reset
            arst_i        : in  std_logic;                    -- asynchronous reset
            wb_adr_i      : in  std_logic_vector(2 downto 0); -- lower address bits
            wb_dat_i      : in  std_logic_vector(7 downto 0); -- Databus input
            wb_dat_o      : out std_logic_vector(7 downto 0); -- Databus output
            wb_we_i       : in  std_logic;                    -- Write enable input
            wb_stb_i      : in  std_logic;                    -- Strobe signals / core select signal
            wb_cyc_i      : in  std_logic;                    -- Valid bus cycle input
            wb_ack_o      : out std_logic;                    -- Bus cycle acknowledge output
            wb_inta_o     : out std_logic;                    -- interrupt request output signal

            -- i2c lines
            scl_pad_i     : in  std_logic;                    -- i2c clock line input
            scl_pad_o     : out std_logic;                    -- i2c clock line output
            scl_padoen_o  : out std_logic;                    -- i2c clock line output enable, active low
            sda_pad_i     : in  std_logic;                    -- i2c data line input
            sda_pad_o     : out std_logic;                    -- i2c data line output
            sda_padoen_o  : out std_logic                     -- i2c data line output enable, active low
        );
    end component;

        signal wb_clk_i      : std_logic := '0';             
        signal wb_rst_i      : std_logic := '0';             
        signal arst_i        : std_logic := '0';             
        signal wb_adr_i      : std_logic_vector(2 downto 0); 
        signal wb_dat_i      : std_logic_vector(7 downto 0); 
        signal wb_dat_o      : std_logic_vector(7 downto 0); 
        signal wb_we_i       : std_logic := '1';             
        signal wb_stb_i      : std_logic := '0';             
        signal wb_cyc_i      : std_logic := '0';
        signal wb_ack_o      : std_logic;
        signal wb_inta_o     : std_logic;

        signal scl_pad_i       : std_logic := '1';
        signal scl_pad_o       : std_logic := '1';
        signal scl_padoen_o    : std_logic := '1';
        signal sda_pad_i       : std_logic := '1';
        signal sda_pad_o       : std_logic := '1';
        signal sda_padoen_o    : std_logic := '1';
        constant period : time := 31.25 ns;             -- 100 kHz Stantard mode

    begin

        UUT : i2c_master_top port map ( 
            wb_clk_i      => wb_clk_i,     
            wb_rst_i      => wb_rst_i,     
            arst_i        => arst_i,       
            wb_adr_i      => wb_adr_i,     
            wb_dat_i      => wb_dat_i,     
            wb_dat_o      => wb_dat_o,     
            wb_we_i       => wb_we_i,      
            wb_stb_i      => wb_stb_i,     
            wb_cyc_i      => wb_cyc_i,     
            wb_ack_o      => wb_ack_o,     
            wb_inta_o     => wb_inta_o,    
            scl_pad_i     => scl_pad_i,    
            scl_pad_o     => scl_pad_o,    
            scl_padoen_o  => scl_padoen_o, 
            sda_pad_i     => sda_pad_i,    
            sda_pad_o     => sda_pad_o,    
            sda_padoen_o  => sda_padoen_o ); 

        -- Clock

        wb_clk_i <= not wb_clk_i after (period / 2);
        
        process begin

            -- Reset
            wb_rst_i <= '1';
            arst_i <= '0';
            wait for 250 ns;
            wb_rst_i <= '0';
            arst_i <= '1';

            -- Set prescale register
            wb_cyc_i <= '1';
            wb_stb_i <= '1';
            wb_adr_i <= "000";
            wb_dat_i <= "00111111";  -- SET LOW PRESCALE TO 3F =  63 to 100 kHz
            wait for 125 ns;
            wb_adr_i <= "001";
            wb_dat_i <= "00000000";  -- SET HI PRESCALE TO 00
            wait for 125 ns;

            -- Enable I2C core and disable I2C interrupt
            wb_adr_i <= "010";
            wb_dat_i <= "10000000";
            wait for 250 ns;

            --START
            wb_adr_i <= "100";
            wb_dat_i <= "10010000"; -- and say if will read or write  GXRWXXXX
            wait for 0.01 ms;

            -- Transmit to secondary
            wb_adr_i <= "011";
            wb_dat_i <= "11001100"; -- address : 1100110 , 0 means write
            wait for 0.08 ms;
            wb_dat_i <= "11110000"; --  next data : 11110000
            wait for 0.01 ms;

            -- ACKNOWLEDGE FROM SECONDARY
            wb_adr_i <= "100";
            wb_dat_i <= "00011000";
            wait for 0.01 ms;
            
            -- REWRITE
            wb_dat_i <= "00010000"; -- and say if will read or write  XXRWXXXX
            wb_adr_i <= "100";
            wait for 0.08 ms;

            -- ACKNOWLEDGE FROM SECONDARY
           -- wb_adr_i <= "100";
            wb_dat_i <= "00001000";
            wait for 0.01 ms;

            -- STOP
            wb_adr_i <= "100";
            wb_dat_i <= "01000000";

            wait;
            
        end process;

end architecture;