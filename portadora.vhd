-- Portadora Triangular

library ieee;
use ieee.std_logic_1164.all;

entity portadora is port
(
	clk : in std_logic;
	tri : buffer integer range 0 to 255 := 0
);
end entity;

architecture rtl of portadora is
	signal flag : std_logic := '0';
begin

	process(clk)
	begin
		if(rising_edge(clk)) then
			if(flag = '0') then
				if(tri = 255) then
					flag <= '1';
					tri <= tri - 1;
				else
					tri <= tri + 1;
				end if;
			else
				if(tri = 0) then
					flag <= '0';
					tri <= tri + 1;
				else
					tri <= tri - 1;
				end if;
			end if;
		end if;
	end process;
end architecture;