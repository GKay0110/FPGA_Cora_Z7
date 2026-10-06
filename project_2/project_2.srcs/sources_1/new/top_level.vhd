library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Entité top_level de l'application : Entrées et sorties physiques + Modules FIFO & LED Driver
entity top_level is
    generic(
             TOGGLE_DELAY : integer := 99999999
        );
    Port ( clk : in std_logic;
           resetn : in std_logic;
           button_0 : in std_logic;     --Update/Enable
           button_1 : in std_logic;     -- Code couleur
           led_r : out std_logic;
           led_b : out std_logic;
           led_g : out std_logic);
end top_level;

architecture Behavioral of top_level is

component led_driver is
    generic(
        TOGGLE_DELAY : integer    --Horloge à 100 MHz -> 1 seconde pour chaque changement d'état 
     );                                       --                     2 secondes pour un cycle Eteint/Allumé
    port ( 
		clk			: in std_logic; 
        resetn		: in std_logic;
        
        fifo_empty  : in std_logic;                     -- '0' = une donnée est disponible
        color_code   : in std_logic_vector(1 downto 0);  -- Le code couleur lu (ex: "10" ou "11")
        
        end_cycle   : out std_logic;                    -- Signal de fin de cycle (relié au wr_en de la FIFO)
        led_r : out std_logic;
        led_b : out std_logic;
        led_g : out std_logic
        
     );
end component;


component fifo is
  PORT (
        clk : IN STD_LOGIC;
        srst : IN STD_LOGIC;
        din : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        wr_en : IN STD_LOGIC;
        rd_en : IN STD_LOGIC;
        dout : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        full : OUT STD_LOGIC;
        empty : OUT STD_LOGIC
  );
  
end component;

-----
-- Signaux internes reliant les instances
-----
signal s_end_cycle, s_wr_ena : std_logic; 
signal pulse_button, s_prev_button_0 : std_logic; 
signal s_fifo_dout, s_fifo_din : std_logic_vector(1 downto 0);
signal s_flag_empty, s_flag_full : std_logic;           -- 
signal fifo_reset : std_logic;                          



begin

-- Synchronisation bouton d'entrée
    process(clk, resetn)
        begin
            if (resetn = '0') then
                s_prev_button_0 <= '0';
            elsif rising_edge(clk) then
                s_prev_button_0 <= button_0;
            end if;
        end process;
-- Impulsion de 1 cycle au moment exact où le bouton est appuyé
    pulse_button <= button_0 and (not s_prev_button_0);

 
    -----
    -- Transcodage des couleurs : '1' -> "10" (Vert), '0' -> "11" (Bleu)
    -----
    s_fifo_din <= "10" when (button_1 = '1') else "11";

    -- Sécurité Overflow (Full) : Autorisation de l'écriture que si appui bouton et FIFO non pleine
    s_wr_ena <= pulse_button and (not s_flag_full);
    
    fifo_reset <= not resetn;

    -----
    -- Instanciations de entités
    ----
    instance_fifo : fifo
        port map (
            clk   => clk,
            srst  => fifo_reset,
            din   => s_fifo_din,    -- Toujours en fonctionnement avec une valeur d'entrée
            wr_en => s_wr_ena,    -- Écriture sécurisée par le flag Full
            rd_en => s_end_cycle,    -- Ordre de dépilage venant du led_driver
            dout  => s_fifo_dout,
            full  => s_flag_full,     -- Flag de sécurité FIFO pleine
            empty => s_flag_empty     -- Flag de sécurité FIFO vide
        );

    instance_led_driver : led_driver
       generic map (
             TOGGLE_DELAY => TOGGLE_DELAY
        )
        port map(
            clk        => clk,
            resetn     => resetn,
            fifo_empty => s_flag_empty,
            color_code => s_fifo_dout,
            end_cycle  => s_end_cycle,
            led_r  => led_r,
            led_g  => led_g,
            led_b   => led_b
        );


end Behavioral;
