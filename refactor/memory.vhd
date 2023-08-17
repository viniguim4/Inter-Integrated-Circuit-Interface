library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;

entity sync_ram is
  port (
    m_clock   : in  std_logic;
    m_reset   : in  std_logic;
    m_write_e : in  std_logic;
    m_address : in  std_logic_vector (7 downto 0);
    m_datain  : in  std_logic_vector (7 downto 0);

    -- dump memory
    m_start_dump : in  std_logic;
    m_data_dump  : out std_logic_vector (7 downto 0);
  );
end entity sync_ram;

architecture RTL of sync_ram is

   type ram_type is array (0 to (2**m_address'length)-1) of std_logic_vector(m_datain'range);
   signal ram : ram_type := (others => (others => '0'));

begin

  RamProc: process(m_clock) is
  begin
    if m_reset = '0' then
      m_write_e <= '0';
      m_address <= (others => '0');
      m_datain <= (others => '0');
      ram <= (others => (others => '0'));
    elsif rising_edge(m_clock) then
      if we = '1' then
        ram(to_integer(unsigned(m_address))) <= m_datain;
      end if;
    end if;
  end process RamProc;

  dump_p : process(m_start_dump, m_clock)
    begin
      if m_reset = '0' then
        m_start_dump <= '0';
      elsif(rising_edge(m_start_dump)) then
            for ii in 0 to 2**m_address'length-1 loop
                m_data_dump <= ram(ii);
                wait until rising_edge(m_clock);
            end loop;
      end if;
    end process dump_p;

end architecture RTL;