library ieee;
use ieee.std_logic_1164.all;

entity tb_cycle_counter is
end tb_cycle_counter;

architecture behavioral of tb_cycle_counter is

	signal s_resetn      : std_logic := '0';
	signal s_clk         : std_logic := '0';
	signal s_enable      : std_logic := '0';
	signal s_clear       : std_logic := '0';
	signal s_led_state      : std_logic;
	signal s_nb_cycle      : std_logic_vector(2 downto 0);
	
	-- Les constantes suivantes permette de definir la frequence de l'horloge 
	constant hp : time := 5 ns;      --demi periode de 5ns
	constant period : time := 2*hp;  --periode de 10ns, soit une frequence de 100Hz
	
	
	component cycle_counter
	   generic (
            TOGGLE_DELAY : integer
        );
		port ( 
			clk			: in std_logic; 
			resetn		: in std_logic;
            enable       : in  std_logic;
            clear        : in  std_logic; 
            led_state    : out std_logic; 
            nb_cycle     : out std_logic_vector(2 downto 0) 
		 );
	end component;

    begin
	uut: cycle_counter
	   generic map (
            TOGGLE_DELAY => 4
        )
        port map (
            clk         => s_clk,
            resetn      => s_resetn,
            enable      => s_enable, 
            clear       => s_clear,
            led_state   => s_led_state, 
            nb_cycle    => s_nb_cycle
        );

horloge : process
    begin
	   wait for hp;
	   s_clk <= not s_clk;
    end process;

    -- Scenario de test 
    process
    begin
        -- Initialisation sous Reset
        s_resetn <= '0';
        s_enable    <= '0';
        s_clear  <= '0';
        wait for 3 * period;
        
        -- Sous reset, le nombre de cycles et la led doivent etre à 0'
        assert (s_nb_cycle = "000") 
            report "! Erreur -  Le compteur de cycles n'est pas a 0 sous Reset " 
            severity error;
        assert (s_led_state = '0') 
            report "! Eerreur - La LED n'est pas eteinte sous Reset " 
            severity error;
        
        -- Liberation du Reset
        s_resetn <= '1';
        wait for 2 * period;

        -- Test : On verifie que sans enable, rien ne bouge
        s_enable <= '0';
        wait for 10 * period; 

        -- Test : Mode comptage actif
        -- Comme TOGGLE_DELAY = 4, le compteur doit faire +1 tous les 4 cycles d'horloge
        s_enable <= '1';
        -- Un cycle complet d'une LED Allumee/Eteinte dure - 4 cycles d'horloge pour s'allumer + 4 cycles pour s'eteindre = 8 cycles d'horloge
        -- Apres 8 cycles d'horloge, nb_cycle doit passer a "001" (1 cycle complet fait)
        wait for 8 * period;
        
        -- Apres un cycle LED complet (8 * period), nb_cycle doit valoir 1
        assert (s_nb_cycle = "001") 
            report "! Erreur - Le compteur de cycles ne vaut pas 1 apres 1 cycle de clignotement" 
            severity error;
            
        -- On attend encore 8 periodes pour passer a 2 cycles
        wait for 8 * period;
        assert (s_nb_cycle = "011") -- Faux test negatif !!
            report "! Erreur : Le compteur de cycles ne vaut pas 2 "  -- !! Vraie valeur nb_cycle = 010 = 2 !!
            severity error;

        wait for 8 * period; -- Total de 24 periodes ecoulees dans ce bloc

        -- Mode Clear synchrone
        s_clear <= '1';
        wait for 2 * period;
        
        -- Le signal clear synchrone doit forcer le compteur de cycles a 000
        assert (s_nb_cycle = "000") 
        report "! Erreur - Le CLEAR n'a pas remis le compteur de cycles a zero " 
        severity error;
        
        -- Relachement du clear
        s_clear <= '0';
        wait for 8 * period;

        -- Fin du scenario : le wait tout seul fige ce process definitivement
        wait; 
    end process;

end Behavioral;