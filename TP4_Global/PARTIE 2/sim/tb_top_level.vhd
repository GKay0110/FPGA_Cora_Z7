library ieee;
use ieee.std_logic_1164.all;

entity tb_top_level is
end tb_top_level;

architecture behavioral of tb_top_level is

    signal s_resetn   : std_logic := '0';
    signal s_clk      : std_logic := '0';
    signal s_button_0 : std_logic := '0';
    signal s_button_1 : std_logic := '0';
    signal s_led_r    : std_logic;
    signal s_led_g    : std_logic;
    signal s_led_b    : std_logic;

    -- Les constantes suivantes permettent de definir la frequence de l'horloge
    constant hp     : time := 5 ns;      -- demi periode de 5ns
    constant period : time := 2*hp;      -- periode de 10ns

  
    constant TOGGLE_DELAY_TB : integer := 4;
    constant FULL_CYCLE      : time := period * (2*TOGGLE_DELAY_TB); -- 1 cycle complet off+on de la FSM
    constant MARGIN          : time := period * 4;                   -- marge de securite anti-course

    component top_level is
        generic(
            TOGGLE_DELAY : integer
        );
        Port ( clk : in std_logic;
               resetn : in std_logic;
               button_0 : in std_logic;     -- Update/Enable
               button_1 : in std_logic;     -- Code couleur
               led_r : out std_logic;
               led_b : out std_logic;
               led_g : out std_logic
             );
    end component;

begin

    uut: top_level
        generic map (
            TOGGLE_DELAY => TOGGLE_DELAY_TB
        )
        port map (
            clk      => s_clk,
            resetn   => s_resetn,
            button_0 => s_button_0,
            button_1 => s_button_1,
            led_r    => s_led_r,
            led_b    => s_led_b,
            led_g    => s_led_g
        );

    horloge : process
    begin
        wait for hp;
        s_clk <= not s_clk;
    end process;

    -----
    -- Simule un appui bref (1 cycle) sur button_0, avec la couleur choisie
    -- sur button_1. Rappel du transcodage fait dans top_level :
    --   button_1 = '1' -> Vert ("10")
    --   button_1 = '0' -> Bleu ("11")
    -- (le Rouge "01" n'est pas selectionnable par bouton, uniquement par defaut)
    ------
     simulation : process

        procedure press_button(constant color_sel : in std_logic) is
        begin
            wait until rising_edge(s_clk);
            s_button_1 <= color_sel;
            s_button_0 <= '1';
            wait until rising_edge(s_clk);
            s_button_0 <= '0';
        end procedure;

    begin
        ------
        -- Initialisation / Reset
        ------
        s_resetn   <= '0';
        s_button_0 <= '0';
        s_button_1 <= '0';
        wait for period * 4;
        s_resetn   <= '1';

        -- Attente automatique du premier allumage physique post-reset
        wait until (s_led_r = '1' or s_led_g = '1' or s_led_b = '1');

        assert (s_led_r = '1' and s_led_g = '0' and s_led_b = '0')
            report "- ERREUR Phase 1 - LED Rouge non active par defaut"
            severity error;
        report "- INFO - LED Rouge active par defaut" severity note;

        -- On laisse s'ecouler un cycle complet pour repartir sur une base stable
        wait for FULL_CYCLE;

        ------
        -- Selection de la LED Verte (button_1= '1') par appui bref
        ------
        press_button('1');

        -- Important : le nouveau code couleur n'est capture par le led_driver
        -- qu'a la prochaine transition de sa FSM interne. Il faut donc
        -- laisser au moins un FULL_CYCLE s'ecouler avant de tester, sinon
        -- on risque de lire l'ancienne couleur encore affichee
        wait for FULL_CYCLE + MARGIN;
        wait until (s_led_r = '1' or s_led_g = '1' or s_led_b = '1');

        assert (s_led_r = '0' and s_led_g = '1' and s_led_b = '0')
            report "- ERREUR - Echec passage a la LED Verte"
            severity error;
        report "- INFO - OK : Changement vers LED Verte reussi" severity note;

        -----
        -- Test anti-maintien : button_0 maintenu, button_1 change en
        --    Cours de route -> ne doit produire qu'une seule ecriture FIFO
        -----
        wait until rising_edge(s_clk);
        s_button_1 <= '1';   -- Vert demande
        s_button_0 <= '1';   -- Appui et maintenu
        wait for FULL_CYCLE;
        s_button_1 <= '0';   -- Couleur changee pendant le maintien : ne doit rien declencher
        wait for FULL_CYCLE;

        -- Tant que le bouton reste enfonce sans relachement, aucun nouveau
        -- Front montant n'est pas genere : le Bleu ne doit jamais s'allumer ici
        assert (s_led_b = '0')
            report "- ERREUR - Instabilite lors de l'appui prolonge (changement de couleur non desire)"
            severity error;

        s_button_0 <= '0';  -- Relachement
        wait for period * 4;
        report "- INFO - OK : Filtre anti-maintien (detecteur de front) valide" severity note;


        ------
        -- Selection de la LED Bleue (button_1='0') par appui bref
        ------
        press_button('0');

        wait for FULL_CYCLE + MARGIN;
        wait until (s_led_r = '1' or s_led_g = '1' or s_led_b = '1');

        assert (s_led_r = '0' and s_led_g = '0' and s_led_b = '1')
            report "- ERREUR - Echec passage a la LED Bleue"
            severity error;
        report "- INFO - OK : Changement vers LED Bleue reussi" severity note;

        wait for FULL_CYCLE;

        ------
        -- Remplissage de plusieurs valeurs consecutives dans la FIFO,
        --    Avant toute lecture, pour verifier que le module led_driver consomme
        --    bien les couleurs dans l'ordre ou elles ont ete ecrites, et
        --    qu'on ne retombe pas sur flag_empty des la 1ere donnee lue 
        --    Sequence ecrite rapidement : Vert, Bleu, Vert (3 valeurs)
        --    A savoir que ces 3 appuis sont volontairement rapproches (2 cycles
        --    d'ecart) pour arriver avant le prochain instant de capture
        --    de la FSM, et donc s'empiler ensemble dans la FIFO
        ------
        press_button('1');  -- Vert
        wait for period * 2;
        press_button('0');  -- Bleu
        wait for period * 2;
        press_button('1');  -- Vert

        -- Verification de la 1ere couleur de la sequence
        wait for FULL_CYCLE + MARGIN;
        wait until (s_led_r = '1' or s_led_g = '1' or s_led_b = '1');
        assert (s_led_g = '1' and s_led_r = '0' and s_led_b = '0')
            report "- ERREUR - Sequence multiple : 1ere couleur (Vert) incorrecte"
            severity error;
        report "- INFO - OK : Sequence multiple, 1ere couleur (Vert) correcte" severity note;

        -- Verification de la 2eme couleur (doit suivre, la FIFO n'est pas encore vide)
        wait for FULL_CYCLE;
        assert (s_led_b = '1' and s_led_r = '0' and s_led_g = '0')
            report "- ERREUR - Sequence multiple : 2eme couleur (Bleu) incorrecte"
            severity error;
        report "- INFO - OK : Sequence multiple, 2eme couleur (Bleu) correcte" severity note;

        -- Verification de la 3eme couleur
        wait for FULL_CYCLE;
        assert (s_led_g = '1' and s_led_r = '0' and s_led_b = '0')
            report "- ERREUR - Sequence multiple : 3eme couleur (Vert) incorrecte"
            severity error;
        report "- INFO - OK : Sequence multiple, 3eme couleur (Vert) correcte" severity note;

        -- La FIFO est maintenant vide : le cycle suivant doit revenir
        -- automatiquement au Rouge par defaut (preuve que flag_empty
        -- redevient actif et que le comportement par defaut reprend)
        wait for FULL_CYCLE;
        assert (s_led_r = '1' and s_led_g = '0' and s_led_b = '0')
            report "- ERREUR - Retour au Rouge par defaut apres vidage FIFO incorrect"
            severity error;
        report "- INFO - OK : Retour au Rouge par defaut confirme, FIFO bien videe" severity note;

        ------
        -- Fin de simulation
        ------
        report "- SIMULATION TERMINEE AVEC SUCCES -" severity note;
        wait;
    end process;

end behavioral;