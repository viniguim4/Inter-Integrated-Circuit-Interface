library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;

entity memory_dump is
  port (
    m_clock   : in  std_logic;
    m_reset   : in  std_logic;
    m_write_e : in  std_logic;
    m_address : in  std_logic_vector (7 downto 0);
    m_datain  : in  std_logic_vector (7 downto 0);

    -- dump memory
    m_start_dump : in  std_logic;
    m_data_dump  : out std_logic_vector (7 downto 0)
  );
end entity memory_dump;

architecture RTL of memory_dump is

   type ram_type is array (0 to (2**m_address'length)-1) of std_logic_vector(m_datain'range);
   signal ram : ram_type := (others => (others => '0'));
begin

  statemachine : block 
    type  state is (idle, dump);
    signal current_state : state;
    signal counter : integer := 0;
  begin
    dump_process : process(m_clock, m_reset)
    begin
    if m_reset = '0' then
      current_state <= idle;
      counter <= 0;
    elsif rising_edge(m_clock) then
      case current_state is
        when idle =>
          if m_start_dump = '1' then
            current_state <= dump;
            counter <= 0;
          else
            current_state <= idle;
          end if;
        when dump =>
          if counter = 2**m_address'length-1 then
            current_state <= idle;
          else
            m_data_dump <= ram(counter);
            counter <= counter + 1;
          end if;
      end case;
    end if;
    end process dump_process;
  end block statemachine;

  RamProc: process(m_clock, m_reset) is
  begin
    if m_reset = '0' then
      ram <= (others => (others => '0'));
    elsif rising_edge(m_clock) then
      if m_write_e = '1' then
        ram(to_integer(unsigned(m_address))) <= m_datain;
      end if;
    end if;
  end process RamProc;

end architecture RTL;