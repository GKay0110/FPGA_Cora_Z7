library ieee;
use ieee.std_logic_1164.all;

entity tb_led_driver is
end tb_led_driver;

architecture behavioral of tb_led_driver is

	signal s_resetn      : std_logic := '0';
	signal s_clk         : std_logic := '0';
	signal s_update     : std_logic := '0';
	signal s_color_code  : std_logic_vector(1 downto 0) := "00";
	signal s_led_r      : std_logic;
	signal s_led_g      : std_logic;
	signal s_led_b      : std_logic;
	
	-- Les constantes suivantes permette de definir la frequence de l'horloge 
	constant hp : time := 5 ns;      --demi periode de 5ns
	constant period : time := 2*hp;  --periode de 10ns, soit une frequence de 100Hz
	
	
	component led_driver is
        generic(
            TOGGLE_DELAY : integer 
     );                                                       
        port ( 
		  clk			: in std_logic; 
            resetn		: in std_logic;
            update    : in std_logic;
            color_code    : in std_logic_vector(1 downto 0);
		    led_r        : out std_logic;
		    led_b        : out std_logic;
		    led_g        : out std_logic 
     );
    end component;

    begin
	uut: led_driver
	   generic map (
            TOGGLE_DELAY => 4
        )
        port map (
            clk         => s_clk,
            resetn      => s_resetn,
            update      => s_update,
            color_code  => s_color_code,
            led_r       => s_led_r, 
            led_b       => s_led_b,
            led_g       => s_led_g
        );

horloge : process
    begin
	   wait for hp;
	   s_clk <= not s_clk;
    end process;

    -- Scenario de test 
    process
    begin
        -----
        -- Initialisation par défaut
        -----
        s_resetn     <= '0';
        s_update     <= '0';
        s_color_code <= "00";
        wait for period * 4;
        
        s_resetn     <= '1';
        
        -- Attente automatique du premier allumage physique d'une LED rouge post-reset
        wait until (s_led_r = '1' or s_led_g = '1' or s_led_b = '1');
        
        assert (s_led_r = '1' and s_led_g = '0' and s_led_b = '0') 
            report "- ERREUR Phase 1 - LED Rouge non active par defaut" 
            severity error;

        report "- INFO - : LED Rouge active par defaut" severity note;
        wait for period * 8;   -- Avance d'un cycle complet pour rester synchrone
        
        -----
        -- Passage à la LED Verte (color_code = "01") + Test d'appui prolonge
        -----
        wait until rising_edge(s_clk);
        s_color_code <= "01"; -- Vert
        s_update     <= '1';  -- Front montant sur update
        
        -- Attente que le vert s'allume physiquement
        wait until (s_led_r = '1' or s_led_g = '1' or s_led_b = '1');
        
        assert (s_led_r = '0' and s_led_g = '1' and s_led_b = '0') 
            report "- ERREUR - Echec passage a la LED Verte" 
            severity error;
        
        report "- INFO - OK : Changement vers LED Verte reussi" severity note;

        -- Test de l'anti-maintien : le bouton reste appuye longtemps
        s_color_code <= "00"; -- Modification du code couleur pendant que update reste a 1
        wait for period * 32;
        
        -- Verification : Pendant le clignotement vert,
        -- Les LEDs Bleue et Rouge ne doivent jamais passer a '1' (que la LED verte soit ON ou OFF)
        assert (s_led_b = '0' and s_led_r = '0') 
            report "- ERREUR - Instabilite lors de l'appui prolonge (changement de couleur non desire)" 
            severity error;

        s_update <= '0'; -- Relachement du bouton
        wait for period * 12;
        report "- INFO - OK : Filtre anti-maintien valide" severity note;
        
        -----
        -- Passage à la LED Bleue (color_code = "00") via une impulsion courte
        -----
        wait until rising_edge(s_clk);
        s_color_code <= "00"; -- Bleu
        s_update     <= '1';
        wait for period * 2;
        s_update     <= '0'; -- Relachement immediat (impulsion)
        
        wait for period * 4;
        s_color_code <= "01"; -- Modification du code couleur pour tester la memoire du registre
        
        -- Attente de l'allumage physique
        wait until (s_led_r = '1' or s_led_g = '1' or s_led_b = '1');
        
        assert (s_led_r = '0' and s_led_g = '0' and s_led_b = '1') 
            report "- ERREUR - Echec passage a la LED Bleue" 
            severity error;

        report "- INFO - OK : Changement vers LED Bleue reussi" severity note;
        wait for period * 20;
  
  
        -----
        -- Fin de simulation
        -----
        report "- SIMULATION TERMINEE AVEC SUCCES -" severity note;
        wait;
end process;

end Behavioral;