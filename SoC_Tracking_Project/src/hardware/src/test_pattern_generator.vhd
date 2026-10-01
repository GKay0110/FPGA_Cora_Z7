library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_pattern_generator is
    Port (
        clk           : in  STD_LOGIC;
        resetn        : in  STD_LOGIC;
        m_axis_tdata  : out STD_LOGIC_VECTOR(23 downto 0);
        m_axis_tvalid : out STD_LOGIC;
        m_axis_tready : in  STD_LOGIC;
        m_axis_tuser  : out STD_LOGIC;
        m_axis_tlast  : out STD_LOGIC
    );
end test_pattern_generator;

architecture Behavioral of test_pattern_generator is
    signal x_cnt      : unsigned(9 downto 0) := (others => '0'); 
    signal y_cnt      : unsigned(9 downto 0) := (others => '0');
    signal frame_cnt  : integer range 0 to 255 := 0;
  
    signal r, g, b    : std_logic_vector(7 downto 0);
    
    signal move_x     : integer range 0 to 640 := 0;
    signal box_x_dir  : std_logic := '1';

begin

    m_axis_tvalid <= '1';
    m_axis_tuser  <= '1' when (x_cnt = 0 and y_cnt = 0) else '0';  --Début d'une nouvelle image 
    m_axis_tlast  <= '1' when (x_cnt = 639) else '0';               --Fin de chaque ligne 
    
    m_axis_tdata  <= r & g & b;
    
    
    -- Gestion de la cible en mouvement
    
    process(clk)
    begin
        if rising_edge(clk) then
            if resetn = '0' then
                r <= (others => '0');
                g <= (others => '0');
                b <= (others => '0');
                move_x <= 0;
                box_x_dir <= '1';
            else
                if (x_cnt = 639 and y_cnt = 479) then               --Rebond du carré sur les bords droits et gauche de l'écran
                    if box_x_dir = '1' then
                        if move_x >= 539 then
                            box_x_dir <= '0';
                            move_x <= move_x - 4;                   
                        else
                            move_x <= move_x + 4;
                        end if;
                    else
                        if move_x <= 4 then
                            box_x_dir <= '1';
                            move_x <= move_x + 4;
                        else
                            move_x <= move_x - 4;
                        end if;
                    end if;
                end if;

                if (to_integer(x_cnt) >= move_x and to_integer(x_cnt) < (move_x + 100) and
                    to_integer(y_cnt) >= 190 and to_integer(y_cnt) < 290) then
                    r <= x"FF"; g <= x"00"; b <= x"00";         -- Positionnement d'un carré rouge de gauche à droite et inversemeent
                else
                    if (x_cnt(4) = '1') xor (y_cnt(4) = '1') then
                        r <= x"20"; g <= x"20"; b <= x"40";         --Cases du damier
                    else
                        r <= x"10"; g <= x"10"; b <= x"20";
                    end if;
                end if;
            end if;
        end if;
    end process;

-- Compteurs pour résolution VGA : 640x480
    process(clk)
    begin
        if rising_edge(clk) then
            if resetn = '0' then
                x_cnt     <= (others => '0');
                y_cnt     <= (others => '0');
                frame_cnt <= 0;
   
            elsif (m_axis_tready = '1') then
                if x_cnt = 639 then
                    x_cnt <= (others => '0');
                    if y_cnt = 479 then
                        y_cnt <= (others => '0');
                        if frame_cnt = 255 then
                            frame_cnt <= 0;
                        else
                            frame_cnt <= frame_cnt + 1;
                        end if;
                    else
                        y_cnt <= y_cnt + 1;
                    end if;
                else
                    x_cnt <= x_cnt + 1;
                end if;
            end if;
        end if;
    end process;

end Behavioral;