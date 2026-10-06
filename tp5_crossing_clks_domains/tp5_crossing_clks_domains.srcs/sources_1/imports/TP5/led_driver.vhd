library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity led_driver is
    generic(
        TOGGLE_DELAY : integer := 99999999   --Horloge à 100 MHz -> 1 seconde pour chaque changement d'état 
     );                                       --                     2 secondes pour un cycle Eteint/Allumé
    port ( 
		clk			: in std_logic; 
        resetn		: in std_logic;
        update    : in std_logic;
        color_code : in std_logic_vector(1 downto 0);
        end_cycle : out std_logic := '0';
		led_r        : out std_logic;
		led_b        : out std_logic;
		led_g        : out std_logic --Broches physqiues pour chaque couleur de la LED RGB
     );
end led_driver;

architecture behavioral of led_driver is

    component counter_unit is
        generic (
            VAL_MAX : integer
        );
        port (
            clk          : in  std_logic;
            resetn       : in  std_logic;
            end_counter  : out std_logic
        );
    end component;

    type state is (led_off, led_on); --a modifier avec vos etats
    
    signal current_state : state;  --etat dans lequel on se trouve actuellement
    signal next_state : state;	   --etat dans lequel on passera au prochain coup d'horloge
    signal s_color_reg : std_logic_vector(1 downto 0);      -- Registre de couleurs 2 bits ("01", "10" ou "11")
	signal s_end_counter : std_logic;              -- Flag de fin de transition
	
	begin
    
    
    
    -- Instanciation du module counter_unit
    Counter : counter_unit
        generic map (
             VAL_MAX => TOGGLE_DELAY
        )
        port map (
            clk         => clk,
            resetn      => resetn,
            end_counter => s_end_counter

        );
      
     --Logique combinatoire pour la sortie 'end_cycle'
     --end_cycle <= '1' when (current_state = led_on and s_end_counter = '1') else '0';
	
	
	--Unité de controle synchronisant la machine d'états à l'horloge
		Control_Unit : process(clk,resetn)
		begin
            if(resetn = '0') then
                
                current_state <= led_off;
                s_color_reg <= "01";  -- LED Rouge par défaut
                 
			elsif(rising_edge(clk)) then
				current_state <= next_state;
				
                if(update = '1') then 
                    s_color_reg <= color_code;
    			end if;    
    			
    			if (current_state = led_on and s_end_counter = '1') then     -- La sortie 'end_cycle' synchornisée
                    end_cycle <= '1';
                else
                    end_cycle <= '0';
                end if;
            end if;
		end process Control_Unit;
		
		
		-- FSM - 2 Etats
		State_Machine : process(current_state, s_end_counter) 
		begin		
           case current_state is           -- Gestion des transitions entre chaque état selon le signal envoyé par le compteur
              when led_off =>
                if(s_end_counter = '1') then        
				    next_state <= led_on;
				else
				    next_state <= led_off; 
                end if;
                
              when led_on =>
				if(s_end_counter = '1') then
				    next_state <= led_off;
				else
				    next_state <= led_on; 
                end if;
               
              when others =>
                    next_state <= led_off;
         
              end case;
              
          
		end process State_Machine;
		
		--Affectation des sorties
		Outputs : process(current_state, s_color_reg)
        begin
	     -- Les LEDs sont éteintes par défaut (1 seule fois au début du process)
            led_r <= '0';
            led_g <= '0';
            led_b <= '0';
    
    -- Gestion des LEDs 
            case current_state is
                when led_off =>
                    null; -- Les LEDs restent éteintes
                    
                when led_on =>
                    if (s_color_reg = "10") then
                        led_g <= '1'; -- On passe juste la LED Verte à 1
                    elsif (s_color_reg = "11") then
                        led_b <= '1'; -- On passe juste la LED Bleue à 1
                    else
                        led_r <= '1'; -- On passe juste la LED Rouge à 1
                    end if;
            end case;
                end process Outputs;
end behavioral;