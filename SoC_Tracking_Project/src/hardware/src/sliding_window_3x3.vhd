library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- fenetre glissante 3x3 : a partir d'un flux de pixels en niveaux de gris,
-- fabrique a chaque cycle les 9 pixels du voisinage 3x3 courant.
-- architecture classique : deux tampons de ligne (une ram par ligne de
-- retard), plus un petit registre a decalage 3x3 pour la fenetre elle-meme.
entity sliding_window_3x3 is
    generic (
        IMG_WIDTH : integer := 640
    );
    Port (
        clk           : in  std_logic;
        resetn        : in  std_logic;

        s_axis_tdata  : in  std_logic_vector(7 downto 0);
        s_axis_tvalid : in  std_logic;
        s_axis_tready : out std_logic;

        -- la fenetre 3x3 courante, valide quand m_valid = '1'
        p11, p12, p13 : out std_logic_vector(7 downto 0); -- ligne du dessus
        p21, p22, p23 : out std_logic_vector(7 downto 0); -- ligne du milieu
        p31, p32, p33 : out std_logic_vector(7 downto 0); -- ligne courante

        m_valid       : out std_logic;
        m_ready       : in  std_logic
    );
end sliding_window_3x3;

architecture rtl of sliding_window_3x3 is

    -- deux tampons de ligne : line1 retient la ligne d'il y a 1 ligne,
    -- line2 celle d'il y a 2 lignes
    type line_mem_t is array (0 to IMG_WIDTH-1) of std_logic_vector(7 downto 0);
    signal line1, line2 : line_mem_t := (others => (others => '0'));
    signal wr_ptr : integer range 0 to IMG_WIDTH-1 := 0;

    signal r_p11, r_p12, r_p13 : std_logic_vector(7 downto 0) := (others => '0');
    signal r_p21, r_p22, r_p23 : std_logic_vector(7 downto 0) := (others => '0');
    signal r_p31, r_p32, r_p33 : std_logic_vector(7 downto 0) := (others => '0');

    -- 2 lignes completes + 2 pixels avant la toute premiere fenetre valide
    constant FILL_TARGET : integer := 2 * IMG_WIDTH + 2;
    signal fill_count   : integer range 0 to FILL_TARGET := 0;
    signal window_valid : std_logic := '0';

    -- registre d'impulsion : dit "la fenetre est prete" independamment de
    -- ce que fait s_axis_tvalid au cycle suivant (voir explication du bug
    -- qu'il remplace, plus bas)
    signal out_valid : std_logic := '0';

begin

    s_axis_tready <= m_ready;

    p11 <= r_p11; p12 <= r_p12; p13 <= r_p13;
    p21 <= r_p21; p22 <= r_p22; p23 <= r_p23;
    p31 <= r_p31; p32 <= r_p32; p33 <= r_p33;
    m_valid <= out_valid;

    process(clk)
        -- variables : la fenetre "fraiche" de ce cycle, utilisee tout de
        -- suite (contrairement aux signaux r_p.., qui ne seraient visibles
        -- qu'au cycle suivant -- meme piege que pour le mux)
        variable v_p11, v_p12, v_p13 : std_logic_vector(7 downto 0);
        variable v_p21, v_p22, v_p23 : std_logic_vector(7 downto 0);
        variable v_p31, v_p32, v_p33 : std_logic_vector(7 downto 0);
    begin
        if rising_edge(clk) then
            if resetn = '0' then
                wr_ptr       <= 0;
                fill_count   <= 0;
                window_valid <= '0';
                out_valid    <= '0';
            elsif s_axis_tvalid = '1' and m_ready = '1' then

                -- la colonne de droite recoit les anciennes valeurs des
                -- tampons de ligne (lues avant ecrasement), les autres
                -- colonnes decalent simplement vers la gauche
                v_p11 := r_p12; v_p12 := r_p13; v_p13 := line2(wr_ptr);
                v_p21 := r_p22; v_p22 := r_p23; v_p23 := line1(wr_ptr);
                v_p31 := r_p32; v_p32 := r_p33; v_p33 := s_axis_tdata;

                r_p11 <= v_p11; r_p12 <= v_p12; r_p13 <= v_p13;
                r_p21 <= v_p21; r_p22 <= v_p22; r_p23 <= v_p23;
                r_p31 <= v_p31; r_p32 <= v_p32; r_p33 <= v_p33;

                -- mise a jour des tampons de ligne (apres avoir lu leur
                -- ancienne valeur ci-dessus)
                line2(wr_ptr) <= line1(wr_ptr);
                line1(wr_ptr) <= s_axis_tdata;

                if wr_ptr = IMG_WIDTH - 1 then
                    wr_ptr <= 0;
                else
                    wr_ptr <= wr_ptr + 1;
                end if;

                -- out_valid s'allume exactement au cycle qui suit une
                -- transaction qui complete une fenetre -- que le pixel
                -- SUIVANT arrive ou non n'entre pas en compte ici, evitant
                -- de perdre la toute derniere fenetre en fin de flux
                if fill_count < FILL_TARGET then
                    fill_count <= fill_count + 1;
                    out_valid  <= '0';
                else
                    window_valid <= '1';
                    out_valid    <= '1';
                end if;

            else
                -- pas de nouvelle transaction ce cycle : l'impulsion ne
                -- doit durer qu'un seul cycle, donc elle retombe ici
                out_valid <= '0';
            end if;
        end if;
    end process;

end rtl;