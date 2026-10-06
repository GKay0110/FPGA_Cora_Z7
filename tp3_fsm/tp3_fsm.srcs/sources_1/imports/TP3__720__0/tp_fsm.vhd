library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity tp_fsm is
    generic(
        TOGGLE_DELAY : integer := 100000000   --Horloge à 100 MHz -> 1 seconde pour chaque changement d'état 
     );                                       --                     2 secondes pour un cycle Eteint/Allumé
    port ( 
		clk			: in std_logic; 
        resetn		: in std_logic;
		restart     : in std_logic;
		led_r        : out std_logic; --Broches physqiues pour chaque couleur de la LED RGB
		led_b        : out std_logic;
		led_g        : out std_logic 
     );
end tp_fsm;

architecture behavioral of tp_fsm is

    component cycle_counter is
        generic (
            TOGGLE_DELAY : integer
        );
        port (
            clk          : in  std_logic;
            resetn       : in  std_logic;
            enable          : in  std_logic; 
            clear        : in  std_logic; 
            led_state    : out std_logic; 
            nb_cycle     : out std_logic_vector(2 downto 0)
        );
    end component;

    type state is (idle, red, blue, green); --a modifier avec vos etats
    
    signal current_state : state;  --etat dans lequel on se trouve actuellement
    signal next_state : state;	   --etat dans lequel on passera au prochain coup d'horloge

    signal s_ena, s_clear, s_led_on : std_logic;    -- Signaux internes pour le compteur de cycles
    signal s_nb_cycle : std_logic_vector(2 downto 0);
	
	
	begin
    
    --Signal "Enable" toujours spécifiée à 1 - Pas de mention pour utilisation spécifique 
    
    s_ena <= '1';
    
    -- Instanciation du module cycle_counter
    Counter : cycle_counter
        generic map (
             TOGGLE_DELAY => TOGGLE_DELAY
        )
        port map (
            clk         => clk,
            resetn      => resetn,
            enable      => s_ena, 
            clear       => s_clear,
            led_state   => s_led_on, 
            nb_cycle    => s_nb_cycle
        );
	
	--Unité de controle synchronisant la machine d'états à l'horloge
		Control_Unit : process(clk,resetn,restart)
		begin
            if(resetn = '0' or restart = '1' ) then
            
                current_state <= idle;
                 
			elsif(rising_edge(clk)) then
			
				current_state <= next_state;
				
            end if;
		end process Control_Unit;
		
		
		
		
		-- FSM
		State_Machine : process(current_state,s_nb_cycle) 
		begin		
           case current_state is            -- Définition des transisitions entre chaque état 
              when idle =>
                if(s_nb_cycle = 3) then        -- Si la condition n'ets pas respectée, on reste à l'état actuel
				    next_state <= red;
				else
				    next_state <= idle; 
                end if;
                
              when red =>
				if(s_nb_cycle = 3) then
				    next_state <= blue;
				else
				    next_state <= red; 
                end if;
              
              when blue =>
			     if(s_nb_cycle = 3) then
				    next_state <= green;
				else
				    next_state <= blue; 
				end if;
         
              when green =>
                if(s_nb_cycle = 3) then
				    next_state <= idle;
				else
				    next_state <= green; 
                end if;
              end case;
              
          
		end process State_Machine;
		
		--Logique combinatoire 
		s_clear <= '1' when (s_nb_cycle = 3 or restart ='1') else '0'; --Remise directe à zéro une fois le nommbre de cycles max atteint ou un restart effectué
		
		--Affectation des sorties
		Outputs : process(current_state, s_led_on)
        begin
	       case current_state is               -- Utilisation de la sortie du compteur de cycles pour faire clignoter la couleur de LED correspondante
	                                           --Mise à au niveau bas des couleurs non utilisées
            when idle =>
                 led_r <= s_led_on; led_b <= s_led_on; led_g <= s_led_on; 
                  
            when red => 
                 led_r <= s_led_on; led_b <= '0'; led_g <= '0'; 
                  
            when blue =>
                 led_r <= '0' ; led_b <= s_led_on; led_g <= '0'; 
                  
            when green =>
                led_r<='0'; led_b <= '0'; led_g <= s_led_on; 
            
            when others =>
                led_r <= '0'; led_b <= '0'; led_g <= '0';
                
            end case;
        end process Outputs;


end behavioral;