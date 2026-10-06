library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Fenetre glissante 3x3 pour flux video continu, avec gestion des 4 bords par replication (un voisin hors image prend la valeur du pixel le plus proche dans l'image)
-- Sortie : exactement IMG_WIDTH x IMG_HEIGHT

--
-- Principe :
--    deux memoires de ligne + decalage 3x3, comme dans les versions
--     precedentes
--   le pixel central de la fenetre en cours de formation a toujours
--     W+1 transactions de retard sur le pixel qui arrive. on suit donc
--     sa position (cx, cy) directement : bords haut/gauche/droite connus
--     sans ambiguite, et on sait exactement quand la sortie est valide
--    bord du bas : une fois la derniere ligne recue, le module se met en
--     pause (tready=0) et rejoue W+1 fois sa propre derniere ligne depuis
--     line1, pour finir de sortir la derniere ligne de fenetres
--   chaque case de la fenetre finale est calculee une seule fois depuis
--     la fenetre d'origine (o_p11 a o_p33), aucune correction ne relit
--     le resultat d'une autre

entity sliding_window_3x3 is
    generic (
        IMG_WIDTH  : integer := 640;
        IMG_HEIGHT : integer := 480
    );
    Port (
        clk           : in  std_logic;
        resetn        : in  std_logic;

        s_axis_tdata  : in  std_logic_vector(7 downto 0);
        s_axis_tvalid : in  std_logic;
        s_axis_tready : out std_logic;

        p11, p12, p13 : out std_logic_vector(7 downto 0);
        p21, p22, p23 : out std_logic_vector(7 downto 0);
        p31, p32, p33 : out std_logic_vector(7 downto 0);

        m_valid       : out std_logic;
        m_ready       : in  std_logic
    );
end sliding_window_3x3;

architecture rtl of sliding_window_3x3 is

    type line_mem_t is array (0 to IMG_WIDTH-1) of std_logic_vector(7 downto 0);
    signal line1, line2 : line_mem_t := (others => (others => '0'));

    -- Colonne d'ecriture dans les memoires de ligne
    signal wr_ptr    : integer range 0 to IMG_WIDTH-1 := 0;
    -- numero de la ligne en cours de reception (0 a IMG_HEIGHT-1)
    signal row_count : integer range 0 to IMG_HEIGHT-1 := 0;

    -- Nombre de transactions deja traitees dans cette trame, bloque a IMG_WIDTH+1 tant qu'il est plus petit, aucune fenetre valide
    signal warm : integer range 0 to IMG_WIDTH+1 := 0;

    -- Position du pixel central de la fenetre en cours de formation
    signal cx : integer range 0 to IMG_WIDTH-1  := 0;
    signal cy : integer range 0 to IMG_HEIGHT-1 := 0;

    signal in_replay : std_logic := '0';

    -- Etat de decalage : les deux colonnes de droite de la fenetre, avec les vraies donnees
    signal w12, w13 : std_logic_vector(7 downto 0) := (others => '0');
    signal w22, w23 : std_logic_vector(7 downto 0) := (others => '0');
    signal w32, w33 : std_logic_vector(7 downto 0) := (others => '0');

    -- Registres de sortie - fenetre finale, avec les bords recopies
    signal r_p11, r_p12, r_p13 : std_logic_vector(7 downto 0) := (others => '0');
    signal r_p21, r_p22, r_p23 : std_logic_vector(7 downto 0) := (others => '0');
    signal r_p31, r_p32, r_p33 : std_logic_vector(7 downto 0) := (others => '0');

    signal out_valid : std_logic := '0';

begin

    s_axis_tready <= '0' when in_replay = '1' else m_ready;

    p11 <= r_p11; p12 <= r_p12; p13 <= r_p13;
    p21 <= r_p21; p22 <= r_p22; p23 <= r_p23;
    p31 <= r_p31; p32 <= r_p32; p33 <= r_p33;
    m_valid <= out_valid;

    process(clk)
        -- Fenetre d'origine : jamais modifiee une fois calculee, c'est la seule source lue par les 9 affectations plus bas
        variable o_p11, o_p12, o_p13 : std_logic_vector(7 downto 0);
        variable o_p21, o_p22, o_p23 : std_logic_vector(7 downto 0);
        variable o_p31, o_p32, o_p33 : std_logic_vector(7 downto 0);

        variable v_pixel_in   : std_logic_vector(7 downto 0);
        variable v_center_ok  : boolean;
        variable v_top_edge   : boolean;
        variable v_left_edge  : boolean;
        variable v_right_edge : boolean;
        variable v_frame_end  : boolean;
    begin
        if rising_edge(clk) then
            if resetn = '0' then
                wr_ptr    <= 0;
                row_count <= 0;
                warm      <= 0;
                cx        <= 0;
                cy        <= 0;
                in_replay <= '0';
                out_valid <= '0';

            elsif (in_replay = '1' and m_ready = '1')
               or (in_replay = '0' and s_axis_tvalid = '1' and m_ready = '1') then

                -- Pendant le rejeu, le "pixel qui arrive" est relu depuis la memoire : la derniere ligne sert de ligne du dessous
                if in_replay = '1' then
                    v_pixel_in := line1(wr_ptr);
                else
                    v_pixel_in := s_axis_tdata;
                end if;

                -- La fenetre formee a cette transaction est-elle valide, et quelle est la position de son centre ?
                v_center_ok  := (warm = IMG_WIDTH + 1);
                v_top_edge   := (cy = 0);
                v_left_edge  := (cx = 0);
                v_right_edge := (cx = IMG_WIDTH - 1);
                v_frame_end  := v_center_ok and (cx = IMG_WIDTH - 1)
                                            and (cy = IMG_HEIGHT - 1);

                -- Fenetre d'origine (decalage classique)
                o_p11 := w12; o_p12 := w13; o_p13 := line2(wr_ptr);
                o_p21 := w22; o_p22 := w23; o_p23 := line1(wr_ptr);
                o_p31 := w32; o_p32 := w33; o_p33 := v_pixel_in;

                -- Etat de decalage mis a jour avec les vraies donnees
                w12 <= o_p12; w13 <= o_p13;
                w22 <= o_p22; w23 <= o_p23;
                w32 <= o_p32; w33 <= o_p33;

                ------
                -- Les 9 cases finales, chacune ecrite une seule fois, toujours depuis o_p**
                ------

                -- Ligne du haut : si elle n'existe pas, elle copie la ligne du milieu (et si la colonne de gauche/droite n'existe pas non plus, c'est le centre qui est copie)
                if v_top_edge and v_left_edge then
                    r_p11 <= o_p22;
                elsif v_top_edge then
                    r_p11 <= o_p21;
                elsif v_left_edge then
                    r_p11 <= o_p12;
                else
                    r_p11 <= o_p11;
                end if;

                if v_top_edge then
                    r_p12 <= o_p22;
                else
                    r_p12 <= o_p12;
                end if;

                if v_top_edge and v_right_edge then
                    r_p13 <= o_p22;
                elsif v_top_edge then
                    r_p13 <= o_p23;
                elsif v_right_edge then
                    r_p13 <= o_p12;
                else
                    r_p13 <= o_p13;
                end if;

                -- ligne du milieu : seuls gauche et droite peuvent manquer
                if v_left_edge then
                    r_p21 <= o_p22;
                else
                    r_p21 <= o_p21;
                end if;

                r_p22 <= o_p22;

                if v_right_edge then
                    r_p23 <= o_p22;
                else
                    r_p23 <= o_p23;
                end if;

                -- Ligne du bas : le bord du bas est gere par le rejeu (la ligne rejouee est deja la bonne), seuls gauche et droite peuvent manquer
                if v_left_edge then
                    r_p31 <= o_p32;
                else
                    r_p31 <= o_p31;
                end if;

                r_p32 <= o_p32;

                if v_right_edge then
                    r_p33 <= o_p32;
                else
                    r_p33 <= o_p33;
                end if;

                -- Memoires de ligne : pas d'ecriture pendant le rejeu
                if in_replay = '0' then
                    line2(wr_ptr) <= line1(wr_ptr);
                    line1(wr_ptr) <= s_axis_tdata;
                end if;

                -- Sortie valide uniquement quand le centre existe
                if v_center_ok then
                    out_valid <= '1';
                else
                    out_valid <= '0';
                end if;


                ----
                -- Compteurs
                ----
                if v_frame_end then
                    -- Derniere fenetre de la trame : tout repart a zero pour accueillir la trame suivante
                    wr_ptr    <= 0;
                    row_count <= 0;
                    warm      <= 0;
                    cx        <= 0;
                    cy        <= 0;
                    in_replay <= '0';
                else
                    if warm < IMG_WIDTH + 1 then
                        warm <= warm + 1;
                    end if;

                    if v_center_ok then
                        if cx = IMG_WIDTH - 1 then
                            cx <= 0;
                            cy <= cy + 1;
                        else
                            cx <= cx + 1;
                        end if;
                    end if;

                    if wr_ptr = IMG_WIDTH - 1 then
                        wr_ptr <= 0;
                        -- Fin de la derniere ligne reelle : le rejeu demarre (en rejeu, on ne compte plus de lignes)
                        if in_replay = '0' then
                            if row_count = IMG_HEIGHT - 1 then
                                in_replay <= '1';
                            else
                                row_count <= row_count + 1;
                            end if;
                        end if;
                    else
                        wr_ptr <= wr_ptr + 1;
                    end if;
                end if;

            else
                -- Pas de transaction ce cycle - si l'aval est pret, il vient
                -- de prendre la fenetre en cours : la sortie n'est plus
                -- valide. s'il n'est pas pret, on garde la fenetre (et son
                -- m_valid) jusqu'a ce qu'il la prenne, sinon elle serait perdue.
                if m_ready = '1' then
                    out_valid <= '0';
                end if;
            end if;
        end if;
    end process;

end rtl;
