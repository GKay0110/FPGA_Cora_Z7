library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity cycle_counter is
    generic (
        -- Par defaut : 1 seconde d'attente a 100 MHz (clignotement total sur 2s)
        TOGGLE_DELAY : integer := 100000000 
    );
    port (
        clk          : in  std_logic;
        resetn       : in  std_logic;
        enable       : in  std_logic; -- '1' pour autoriser le comptage
        clear        : in  std_logic; -- '1' pour forcer la remise a 0
        led_state    : out std_logic; -- Sortie pour faire clignoter la LED (1s On / 1s Off)
        nb_cycle     : out std_logic_vector(2 downto 0) -- Valeur brute du compteur pour le nombre de cycles LED on/off (0 a 15)
    );
end entity;

architecture Behavioral of cycle_counter is

    -- Déclaration du composant counter_unit
    component counter_unit is
        generic (
            VAL_MAX : integer
        );
        port (
            clk         : in  std_logic;
            resetn      : in  std_logic;
            end_counter : out std_logic
        );
    end component;

    -- Signaux internes
    signal finish_flag   : std_logic := '0';
    signal led_reg      : std_logic := '0';
    signal cpt_reg : unsigned(2 downto 0) := "000";

begin

    -- Instanciation du module counter_unit
    counter : counter_unit
        generic map (
            VAL_MAX => TOGGLE_DELAY -- Prend la valeur 125 000 000 par defaut
        )
        port map (
            clk         => clk,
            resetn      => resetn,
            end_counter => finish_flag
        );

    -- Process de gestion du compteur et du clignotement
    process(clk, resetn)
    begin
        if resetn = '0' then
            cpt_reg <= (others => '0');
            led_reg      <= '0';
        elsif rising_edge(clk) then
            
            if clear = '1' then     
                cpt_reg <= (others => '0'); -- Remise à 0
                led_reg      <= '0';
                
            elsif enable = '1' and finish_flag = '1' then
                --cpt_reg <= cpt_reg + 1; -- +1 au compteur de changements
                led_reg <= not led_reg; -- Inversion de l'état (Toggle toutes les 1s)
                
                -- Ne s'incrémente que si la LED était à '1' et qu'elle s'éteint
                -- Cela valide un cycle complet (Allumé puis Éteint)
                if led_reg = '1' then
                  cpt_reg <= cpt_reg + 1;
                end if;    
            end if;
        end if;
    end process;

    -- Affectation des sorties 
    led_state    <= led_reg;
    nb_cycle <= std_logic_vector(cpt_reg);

end Behavioral;