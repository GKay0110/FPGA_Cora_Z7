library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity rgb_sequencer is

    port ( 
		clk			: in std_logic; 
        resetn		: in std_logic;
        end_cycle   : in std_logic;
        update    : out std_logic;
        color_code : out std_logic_vector(1 downto 0)
     );

end rgb_sequencer;

architecture Behavioral of rgb_sequencer is

    type state_type is (red, green, blue);
    signal current_state : state_type;
    signal cycle_nb    : integer range 0 to 9; -- Le nombre de cycles pour les transitions de la FSM

begin

    -- FSM en 1 seul process synchrone (sorties enregistrées)
    process(clk, resetn)
    begin
        if resetn = '0' then
            current_state <= red;
            cycle_nb    <= 0;
            update        <= '0';
            color_code    <= "01"; -- Rouge par défaut
            
        elsif rising_edge(clk) then
            -- Par défaut, l'impulsion update dure 1 seul cycle
            update <= '0';

            if end_cycle = '1' then
                if cycle_nb = 9 then  -- Si 10 cycles ON/OFF atteint
                    cycle_nb <= 0;     --Remise à zéro du compteur
                    update     <= '1'; -- Impulsion du signal de mise à jour

                    -- Changement d'état et mise à jour de la couleur
                    case current_state is
                        when red =>     --Par defaut sur Rouge - 10 cycles après -> Bleu
                            current_state <= blue;
                            color_code    <= "11";

                        when blue =>   -- 10 cycles après -> Vert
                            current_state <= green;
                            color_code    <= "10";

                        when green =>  --Retour de la boucle -> Rouge
                            current_state <= red;
                            color_code    <= "01";

                        when others =>
                            current_state <= red;
                            color_code    <= "01";
                    end case;
                else
                    cycle_nb <= cycle_nb + 1;
                end if;
            end if;
        end if;
    end process;

end Behavioral;


