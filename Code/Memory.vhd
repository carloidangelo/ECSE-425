--Memory.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Memory is
	generic(
		data_mem_size : integer := 32768
	);
	port (
		clock: in std_logic;
		i_waitrequest : out std_logic := '1';
		f_waitrequest : in std_logic;
		address : in integer range 0 to data_mem_size-1;
		writedata : in std_logic_vector (31 downto 0);
		readdata : out std_logic_vector (31 downto 0);
		alu_opcode : in std_logic_vector (4 downto 0);
		status : out std_logic := '0';
 
		m_addr : out integer range 0 to data_mem_size-1;
		m_read : out std_logic := '0';
		m_readdata : in std_logic_vector (31 downto 0);
		m_write : out std_logic := '0';
		m_writedara : out std_logic_vector (31 downto 0);
		m_waitrequest : in std_logic
	);
end Memory;

architecture behaviour of Memory is
	type states is (operating,reset);
	signal current_state : states := operating;
begin

	fetching: process (clock)
	begin
		if (rising_edge(clock)) then
			case current_state is
				when operating =>
					if (m_waitrequest = '1') then
						--write
						if (alu_opcode = "10111") then 
							status <= '1';
							m_addr <= address;
							m_write <= '1';
							current_state <= operating;
						--read
						elsif (alu_opcode = "10101") then 
							status <= '1';
							m_addr <= address;
							m_read <= '1';
							current_state <= operating;
						END IF;
					elsif (m_waitrequest = '0') then
						readdata <= m_readdata;
						m_read <= '0';
						m_write <= '0';
						i_waitrequest <= '0';
						current_state <= reset;
					end if;
				when reset =>
					-- synchronize with other memory unit, so pipeline order is preserved
					if (f_waitrequest = '0') then
						i_waitrequest <= '1';
						current_state <= operating;
					else
						i_waitrequest <= '0';
						current_state <= reset;
					END IF;
				when others =>
					null;
			end case;
		end if;
	end process;

end behaviour;