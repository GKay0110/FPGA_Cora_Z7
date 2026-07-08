library ieee;
use ieee.std_logic_1164.all;

entity tb_counter is
end tb_counter;

architecture behavioral of tb_counter is

	signal sresetn      : std_logic := '1';
	signal sclk         : std_logic := '0';
	signal sled_out     : std_logic;
	signal srestart     : std_logic := '0'; 
	signal scount       : std_logic_vector (27 downto 0);
	
	-- Les constantes suivantes permette de definir la frequence de l'horloge 
	constant hp : time := 5 ns;      --demi periode de 5ns
	constant period : time := 2*hp;  --periode de 10ns, soit une frequence de 100Hz
	
	--Declaration de l'entite a tester
	component counter_unit 
		port ( 
			clk			: in std_logic; 
			resetn		: in std_logic;
			restart      : in std_logic;
			led_out      : out std_logic;
            count       : out std_logic_vector(27 downto 0)			
		 );
	end component;
	
	

	begin
	
	--Affectation des signaux du testbench avec ceux de l'entite a tester
	uut: counter_unit
        port map (
            clk => sclk, 
            resetn => sresetn,
            restart => srestart,
            led_out => sled_out,
            count => scount
        );
		
	--Simulation du signal d'horloge en continue
horloge: process
    begin
		wait for hp;
		sclk <= not sclk;
	end process horloge;


counter : process
	begin        
	   
	    sresetn <= '0';
        wait for period * 2; 
        sresetn <= '1'; -- On relâche le reset
        wait for period;
        
        -- TEST : On laisse le compteur tourner jusqu'au MAX
        -- On attend que le compteur atteigne sa valeur MAX (5) et bascule la LED
        wait for period * 6; 
        
        -- TEST : Validation du bouton restart
        -- On attend que le compteur monte un peu (ex: jusqu'à 3)
        wait for period * 2; 
        
        -- On appuie sur le bouton restart
        srestart <= '1';
        wait for period * 2;
        -- On relâche le bouton restart
        srestart <= '0';
        wait for period * 4;
        
        -- Fin de la simulation
        wait;
	   
	end process counter;
	
end behavioral;