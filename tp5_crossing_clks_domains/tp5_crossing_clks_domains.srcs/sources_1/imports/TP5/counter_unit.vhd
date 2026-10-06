library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity counter_unit is
    generic(
        constant VAL_MAX : integer := 199999999   --par defaut : 2 secondes
        );
    port ( 
		clk			: in std_logic; 
        resetn		: in std_logic; 
        end_counter	: out std_logic
     );
end counter_unit;

architecture behavioral of counter_unit is
	
	-- Declaration des signaux internes
	signal cpt_reg 	: unsigned (27 downto 0) := (others => '0') ;
	
	begin

		--Partie sequentielle
		process(clk,resetn)
		begin
			if(resetn = '0') then 
                cpt_reg <= (others => '0');
                    			     
			elsif(rising_edge(clk)) then
			     if(cpt_reg = VAL_MAX) then
					cpt_reg <= (others => '0');
				else
					cpt_reg <= cpt_reg + 1;

			     end if;
			end if;
		end process;
		
		--Partie combinatoire
		end_counter <= '1' when (cpt_reg = VAL_MAX)
				else '0';
end behavioral;

