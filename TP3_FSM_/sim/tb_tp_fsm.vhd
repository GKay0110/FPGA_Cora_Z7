library ieee;
use ieee.std_logic_1164.all;

entity tb_tp_fsm is
end tb_tp_fsm;

architecture behavioral of tb_tp_fsm is

	signal s_resetn      : std_logic := '0';
	signal s_clk         : std_logic := '0';
	signal s_restart     : std_logic := '0';
	signal s_led_r       : std_logic;
	signal s_led_b       : std_logic;
	signal s_led_g       : std_logic;
	
	-- Les constantes suivantes permette de definir la frequence de l'horloge 
	constant hp : time := 5 ns;      --demi periode de 5ns
	constant period : time := 2*hp;  --periode de 10ns, soit une frequence de 100Hz
	
	
	component tp_fsm
        generic(
            TOGGLE_DELAY : integer
        );
        port ( 
            clk			: in std_logic; 
            resetn		: in std_logic;
            restart     : in std_logic;
            led_r        : out std_logic;
            led_b        : out std_logic;
            led_g        : out std_logic
         );
	end component;
	
	

	begin
	dut: tp_fsm
	   generic map(
	       TOGGLE_DELAY => 2
	    )
        port map (
            clk => s_clk, 
            resetn => s_resetn,
			restart => s_restart,
			led_r => s_led_r,
			led_b => s_led_b,
			led_g => s_led_g
        );
		
	--Simulation du signal d'horloge en continue
	horloge : process
    begin
		wait for hp;
		s_clk <= not s_clk;
	end process;


	process
	begin        
	

        -- Initialisation sous Reset

        s_resetn <= '0';
        s_restart <= '0';
        wait for period * 10;
        
        -- Verification initiale
        assert (s_led_r = s_led_g and s_led_g = s_led_b)
            report "- Erreur de demarrage - La LED n'est pas blanche (IDLE) sous Reset"
            severity failure;    
            
        --  (note) : S'affiche si tout est OK sous reset !
        assert (s_led_r /= s_led_g or s_led_g /= s_led_b) -- Condition inversee pour l'affichage
            report "- OK - Demarrage en etat IDLE (leds blanches) valide "
            severity note;
        
        -- On libere le Reset
        s_resetn <= '1';
        wait for period * 15;
        
        
        -- Deroulement du cycle RED 
        -- Apres la liberation du reset, on doit transiter vers l'etat RED
        wait for period * 15;
        
        assert (s_led_b = '0' and s_led_g = '0')
            report "- Erreur fonctionnelle - Des LEDs non autoirisees s'allument pendant l'etat RED !"
            severity error;
            
        -- (note) : On valide le mode Rouge exclusif
        assert (s_led_b /= '0' or s_led_g /= '0') -- Condition inversee
            report "- OK - Mode RED valide (leds Bleue et Verte bien eteintes) "
            severity note;
        

        -- Transition vers l'etat BLUE et TEST DU RESTART

        wait for period * 5;
        
        -- Test bouton restart - Etat bleu
        s_restart <= '1';
        wait for period * 2; -- On reste appuye pendant 2 cycles d'horloge
        s_restart <= '0';    -- On relache le bouton
        
        wait for 1 ns; -- Stabilisation
        
        -- Verification du retour   l'etat initial 
        assert (s_led_r = s_led_b and s_led_b = s_led_g) 
            report "Erreur critique - L'etat IDLE (Blanc) n'est pas retourne apres un restart" 
            severity failure;
            
        -- Confirmation retour IDLE
        assert (s_led_r /= s_led_b or s_led_b /= s_led_g) -- Condition inversee
            report "- OK - Commande RESTART executee - retour a l'etat IDLE valide "
            severity note;
        
        -- Deroulement normal apres restart
     
       
        wait for period * 40;
        
         -- Fin de la simulation
        assert false report "- SIMULATION DE LA FSM GLOBALE TERMINEE -" severity note;
        wait;
	    
	end process;
	
	
end behavioral;