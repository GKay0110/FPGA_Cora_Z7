library ieee;
use ieee.std_logic_1164.all;

entity tb_top_level is
end tb_top_level;

architecture behavioral of tb_top_level is

    -- Horloge système physique (125 MHz -> période 8 ns)
    signal s_sys_clk : std_logic := '0';
    signal s_resetn  : std_logic := '0';

    -- Sorties LED
    signal s_led0_r, s_led0_g, s_led0_b : std_logic;
    signal s_led1_r, s_led1_g, s_led1_b : std_logic;

    -- Paramètres d'horloge 125 MHz
    constant hp_sys     : time := 4 ns;
    constant period_sys : time := 2 * hp_sys; -- 8 ns

    -- Horloges internes générées par la PLL pour les calculs de temporisation
    constant periodA : time := 4 ns;  -- clkA à 250 MHz
    constant periodB : time := 20 ns; -- clkB à 50 MHz

    constant TB_TOGGLE_DELAY : integer := 2;
    constant NB_CYCLE        : integer := 10;

    -- Durée d'une couleur complète (calculée sur clkA = 250 MHz)
    constant COLOR_DURATION : time := periodA * NB_CYCLE * 2 * TB_TOGGLE_DELAY;

    -- Marge de sécurité pour la resynchronisation vers clkB (LED1)
    constant MARGIN : time := periodB * 4;

    
    component top_level is
        generic (
            TOGGLE_DELAY : integer
        );
        port (
            sys_clk : in  std_logic;
            resetn  : in  std_logic;
            led0_r  : out std_logic;
            led0_g  : out std_logic;
            led0_b  : out std_logic;
            led1_r  : out std_logic;
            led1_g  : out std_logic;
            led1_b  : out std_logic
        );
    end component;

begin

    --------
    -- Instanciation du Top-Level physique
    --------
    uut: top_level
        generic map (
            TOGGLE_DELAY => TB_TOGGLE_DELAY
        )
        port map (
            sys_clk => s_sys_clk,
            resetn  => s_resetn,
            led0_r  => s_led0_r,
            led0_g  => s_led0_g,
            led0_b  => s_led0_b,
            led1_r  => s_led1_r,
            led1_g  => s_led1_g,
            led1_b  => s_led1_b
        );

    ---------
    -- Génération de l'horloge 125 MHz
    --------
    horloge : process
    begin
        wait for hp_sys;
        s_sys_clk <= not s_sys_clk;
    end process;



    simulation : process
    begin
        ------
        -- Initialisation : Reset pendant 5 cycles d'horloge système
        ------
        s_resetn <= '0';
        wait for period_sys * 5;
        s_resetn <= '1';

        -- Attente de la stabilisation de la PLL + premier démarrage sur Rouge
        wait until (s_led0_r = '1' or s_led0_g = '1' or s_led0_b = '1');
        assert (s_led0_r = '1' and s_led0_g = '0' and s_led0_b = '0')
            report "- ERREUR - LED0 ne démarre pas sur Rouge"
            severity error;
        report "- INFO - OK : LED0 démarre sur Rouge" severity note;

        wait for MARGIN;
        assert (s_led1_r = '1' and s_led1_g = '0' and s_led1_b = '0')
            report "- ERREUR - LED1 ne démarre pas sur Rouge"
            severity error;
        report "- INFO - OK : LED1 démarre sur Rouge" severity note;

        ------
        -- Transition Rouge -> Bleu
        ------
        wait for COLOR_DURATION - periodA;
        wait until (s_led0_r = '1' or s_led0_g = '1' or s_led0_b = '1');
        assert (s_led0_g = '0' and s_led0_r = '0' and s_led0_b = '1')
            report "- ERREUR - LED0 : transition Rouge -> Bleu incorrecte"
            severity error;
        report "- INFO - OK : LED0 passe au Bleu" severity note;

        wait for MARGIN;
        assert (s_led1_g = '0' and s_led1_r = '0' and s_led1_b = '1')
            report "- ERREUR - LED1 : transition Rouge -> Bleu incorrecte"
            severity error;
        report "- INFO - OK : LED1 suit vers le Bleu" severity note;

        ------
        -- Transition Bleu -> Vert
        ------
        wait for COLOR_DURATION - periodA;
        wait until (s_led0_r = '1' or s_led0_g = '1' or s_led0_b = '1');
        assert (s_led0_b = '0' and s_led0_r = '0' and s_led0_g = '1')
            report "- ERREUR - LED0 : transition Bleu -> Vert incorrecte"
            severity error;
        report "- INFO - OK : LED0 passe au Vert" severity note;

        wait for MARGIN;
        assert (s_led1_b = '0' and s_led1_r = '0' and s_led1_g = '1')
            report "- ERREUR - LED1 : transition Bleu -> Vert incorrecte"
            severity error;
        report "- INFO - OK : LED1 suit vers le Vert" severity note;

        ------
        -- Rebouclage Vert -> Rouge
        ------
        wait for COLOR_DURATION - periodA;
        wait until (s_led0_r = '1' or s_led0_g = '1' or s_led0_b = '1');
        assert (s_led0_r = '1' and s_led0_g = '0' and s_led0_b = '0')
            report "- ERREUR - LED0 : la boucle ne revient pas sur Rouge"
            severity error;
        report "- INFO - OK : LED0 boucle R -> B -> V -> R validée" severity note;

        wait for MARGIN;
        assert (s_led1_r = '1' and s_led1_g = '0' and s_led1_b = '0')
            report "- ERREUR - LED1 : la boucle ne revient pas sur Rouge"
            severity error;
        report "- INFO - OK : LED1 boucle R -> B -> V -> R validée" severity note;

        report "- SIMULATION TERMINEE AVEC SUCCES -" severity note;
        wait;
    end process;

end behavioral;