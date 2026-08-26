library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity top_level is
    generic (
        TOGGLE_DELAY : integer := 99999999
    );
    port (
        sys_clk : in  std_logic; -- Entrée horloge 125 MHz physique 
        resetn  : in  std_logic;
        -- Sorties RGB LED0
        led0_r  : out std_logic;
        led0_g  : out std_logic;
        led0_b  : out std_logic;
      
        -- Sorties RGB LED1
        led1_r  : out std_logic;
        led1_g  : out std_logic;
        led1_b  : out std_logic;
        
        -- Broches IO
        io : out std_logic_vector(1 downto 0)  -- Observation oscilloscope 
    );
end top_level;

architecture Behavioral of top_level is

    -- Déclaration du composant PLL (Clocking Wizard)
    component clk_wiz_0
        port (
            clk_in1  : in  std_logic;
            reset    : in  std_logic;
            clk_out1 : out std_logic;
            clk_out2 : out std_logic;
            locked   : out std_logic
        );
    end component;

    -- Déclaration du module RGB_Sequencer
    component rgb_sequencer
        port (
            clk        : in  std_logic;
            resetn     : in  std_logic;
            end_cycle  : in  std_logic;
            update     : out std_logic;
            color_code : out std_logic_vector(1 downto 0)
        );
    end component;

    -- Déclaration du module LED Driver
    component led_driver
        generic (
            TOGGLE_DELAY : integer := 99999999
        );
        port (
            clk        : in  std_logic;
            resetn     : in  std_logic;
            update     : in  std_logic;
            color_code : in  std_logic_vector(1 downto 0);
            end_cycle  : out std_logic;
            led_r      : out std_logic;
            led_g      : out std_logic;
            led_b      : out std_logic
        );
    end component;

    -- Signaux d'horloges internes générés par la PLL
    signal clkA : std_logic; -- 250 MHz
    signal clkB : std_logic; -- 50 MHz

    -- Signaux de gestion de la PLL et du reset
    signal pll_reset       : std_logic;
    signal locked          : std_logic;
    signal internal_resetn : std_logic;

    -- Signaux d'interconnexion internes
    signal s_update     : std_logic;
    signal s_color_code : std_logic_vector(1 downto 0);
    signal s_end_cycle0 : std_logic := '0';

    -- Signaux Pulse Stretching (Domaine d'horloge clkA)
    signal s_update_stretched : std_logic := '0';
    signal stretching_cpt     : integer range 0 to 10 := 0;

    -- Signaux de synchronisation et detecteur de fronts (Domaine d'horloge clkB)
    signal r1_stage      : std_logic := '0';
    signal r2_stage      : std_logic := '0';
    signal r3_stage      : std_logic := '0';
    signal s_update_clkB : std_logic := '0';
    
    -- Signaux internes pour dupliquer les sorties
        signal s_led0_r : std_logic;
        signal s_led1_r : std_logic;

begin

    --------
    -- Instanciation et Gestion de la PLL
    --------
    pll_reset       <= not resetn;
    internal_resetn <= resetn and locked; -- Maintient le reste du circuit sous reset tant que la PLL n'est pas verrouillée

    Instance_PLL : clk_wiz_0
        port map (
            clk_in1  => sys_clk,   -- Horloge 125 MHz de la carte
            reset    => pll_reset, -- Reset actif à l'état haut pour la PLL
            clk_out1 => clkA,      -- Génère 250 MHz
            clk_out2 => clkB,      -- Génère 50 MHz
            locked   => locked
        );

    --------
    -- Étirement d'impulsion (clkA - 250 MHz)
    -- Étire le pulse de 4 ns à 40 ns (10 cycles clkA = 2 cycles clkB)
    ---------
    process(clkA, internal_resetn)
    begin
        if internal_resetn = '0' then
            stretching_cpt     <= 0;
            s_update_stretched <= '0';
        elsif rising_edge(clkA) then
            if s_update = '1' then
                stretching_cpt     <= 9; -- 1 cycle initial + 9 de décompte = 10 cycles (40 ns)
                s_update_stretched <= '1';
            elsif stretching_cpt > 0 then
                stretching_cpt     <= stretching_cpt - 1;
                s_update_stretched <= '1';
            else
                s_update_stretched <= '0';
            end if;
        end if;
    end process;

    ----------
    -- Synchronisation 2-Flip Flop (Metastabilite) + Detecteur de front (clkB - 50 MHz)
    ----------
    process(clkB, internal_resetn)
    begin
        if internal_resetn = '0' then
            r1_stage <= '0';
            r2_stage <= '0';
            r3_stage <= '0';
        elsif rising_edge(clkB) then
            r1_stage <= s_update_stretched; -- Absorption de la métastabilité
            r2_stage <= r1_stage;           -- Signal propre étiré
            r3_stage <= r2_stage;           -- Registre d'un cycle de retard
        end if;
    end process;

    -- Génération de l'impulsion de 1 cycle clkB pour le module LED_Driver_1
    s_update_clkB <= r2_stage and not r3_stage;

    --------
    -- Instanciation des composants
    --------

    -- Séquenceur RGB (Domaine clkA)
    Instance_RGB_Sequencer : rgb_sequencer
        port map (
            clk        => clkA,
            resetn     => internal_resetn,
            end_cycle  => s_end_cycle0,
            update     => s_update,
            color_code => s_color_code
        );

    -- LED_Driver 0 - Maître (Domaine clkA)
    Instance_LED_Driver_0 : led_driver
        generic map (
            TOGGLE_DELAY => TOGGLE_DELAY 
        )
        port map (
            clk        => clkA,
            resetn     => internal_resetn,
            update     => s_update,        -- Pulse direct de 4 ns
            color_code => s_color_code,
            end_cycle  => s_end_cycle0,
            led_r      => s_led0_r,
            led_g      => led0_g,
            led_b      => led0_b
        );

    -- LED_Driver 1 - Esclave (Domaine clkB)
    Instance_LED_Driver_1 : led_driver
        generic map (
            TOGGLE_DELAY => TOGGLE_DELAY 
        )
        port map (
            clk        => clkB,
            resetn     => internal_resetn,
            update     => s_update_clkB,   -- Pulse resynchronisé de 20 ns
            color_code => s_color_code,   -- Signal statique sécurisé
            end_cycle  => open,
            led_r      => s_led1_r,
            led_g      => led1_g,
            led_b      => led1_b
        );
     
     --Observations des fréquences à l'oscilloscope 
     
     led0_r <= s_led0_r;  -- Le fil interne va allumer la LED 0
     led1_r <= s_led1_r;
     io(0) <= s_led0_r; -- Canal 1 de l'oscilloscope (signal sur clkA - 250 MHz)
     io(1) <= s_led1_r; -- Canal 2 de l'oscilloscope (signal sur clkB - 50 MHz)

end Behavioral;