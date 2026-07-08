library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity counter_unit is
    port ( 
		clk			: in std_logic; 
        resetn		: in std_logic; 
        restart     : in std_logic;       
        led_out     : out std_logic;
        count       : out std_logic_vector(27 downto 0)
     );
end counter_unit;

architecture behavioral of counter_unit is
	
	--Declaration des signaux internes
    constant MAX : positive := 199999999;
    --constant MAX : positive := 5;   -- Pour test bench
	signal cpt_reg 	: unsigned (27 downto 0) := (others => '0') ; -- --Bascule pour mémoriser la valeur précédente du compteur
	signal led_reg : std_logic := '0';  --Bascule pour mémoriser la valeur précédente de la LED
    signal end_counter	: std_logic := '0';	-- Flag quand valeur MAX atteinte
    
	begin

		--Partie sequentielle
counter : process(clk,resetn)
		begin
			if(resetn = '0') then 
                cpt_reg <= (others => '0');    			     
			elsif(rising_edge(clk)) then
			     if(restart = '1') then
			         cpt_reg <= (others => '0');
			     elsif(cpt_reg = MAX) then
					cpt_reg <= (others => '0');
			     else
				    cpt_reg <= cpt_reg + 1;
			     end if;
			end if;
		end process;
		
	--Logique combinatoire
	end_counter <= '1' when (cpt_reg = MAX)
		         else '0';

LED_toggle : process(clk,resetn)
		begin
			if(resetn = '0') then 
                led_reg <= '0';    			     
			elsif(rising_edge(clk)) then
			     if(restart = '1') then
					led_reg <= '0';    -- Si restart, la LED est éteinte
			     elsif(end_counter = '1') then
			         led_reg <= not led_reg;   --On inverse la valeur envoyée à la broche physique
                end if;
            end if;
		end process;
		
		--Partie combinatoire
		led_out <= led_reg;		
        count <= std_logic_vector(cpt_reg); 
end behavioral;


	--