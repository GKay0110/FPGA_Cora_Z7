library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Suivi du score Harris maximal de chaque image, sans bus AXI.
-- r_max, pos_x, pos_y et frame_cnt figes a la fin de chaque image 
-- seuil_out : le seuil du PS, pris en compte a l'image suivante.
entity harris_track is
    generic (
        IMG_WIDTH  : integer := 640;
        IMG_HEIGHT : integer := 480
    );
    port (
        clk    : in  std_logic;
        resetn : in  std_logic;

        -- Pixel de sortie accepte : v_valid vaut valid et ready
        v_valid : in  std_logic;
        v_user  : in  std_logic;
        v_last  : in  std_logic;
        v_r     : in  std_logic_vector(11 downto 0);

        seuil_in  : in  std_logic_vector(11 downto 0);
        seuil_out : out std_logic_vector(11 downto 0);

        r_max     : out std_logic_vector(31 downto 0);
        pos_x     : out std_logic_vector(31 downto 0);
        pos_y     : out std_logic_vector(31 downto 0);
        frame_cnt : out std_logic_vector(31 downto 0)
    );
end harris_track;

architecture rtl of harris_track is

    signal started   : std_logic := '0';
    signal seuil_eff : std_logic_vector(11 downto 0) := (others => '0');

    signal rmax_q    : signed(11 downto 0) := (others => '0');
    signal posx_q    : integer range 0 to IMG_WIDTH  := 0;
    signal posy_q    : integer range 0 to IMG_HEIGHT := 0;
    signal frame_q   : unsigned(31 downto 0) := (others => '0');

    signal cnt_x  : integer range 0 to IMG_WIDTH  := 0;
    signal cnt_y  : integer range 0 to IMG_HEIGHT := 0;
    signal best_r : signed(11 downto 0) := (others => '0');
    signal best_x : integer range 0 to IMG_WIDTH  := 0;
    signal best_y : integer range 0 to IMG_HEIGHT := 0;

begin

    -- Avant la premiere image, le seuil du PS passe tel quel
    seuil_out <= seuil_in when started = '0' else seuil_eff;

    r_max     <= std_logic_vector(resize(rmax_q, 32));
    pos_x     <= std_logic_vector(to_unsigned(posx_q, 32));
    pos_y     <= std_logic_vector(to_unsigned(posy_q, 32));
    frame_cnt <= std_logic_vector(frame_q);

    process(clk)
        variable cur_x, cur_y : integer;
        variable nb_r : signed(11 downto 0);
        variable nb_x, nb_y : integer;
    begin
        if rising_edge(clk) then
            if resetn = '0' then
                started <= '0';
                seuil_eff <= (others => '0');
                cnt_x <= 0; cnt_y <= 0;
                best_r <= (others => '0'); best_x <= 0; best_y <= 0;
                rmax_q <= (others => '0'); posx_q <= 0; posy_q <= 0;
                frame_q <= (others => '0');
            elsif v_valid = '1' then
                if v_user = '1' then
                    cur_x := 0; cur_y := 0;
                else
                    cur_x := cnt_x; cur_y := cnt_y;
                end if;

                if v_user = '1' then
                    nb_r := signed(v_r); nb_x := 0; nb_y := 0;
                elsif signed(v_r) > best_r then
                    nb_r := signed(v_r); nb_x := cur_x; nb_y := cur_y;
                else
                    nb_r := best_r; nb_x := best_x; nb_y := best_y;
                end if;
                best_r <= nb_r;
                best_x <= nb_x;
                best_y <= nb_y;

                if v_last = '1' then
                    cnt_x <= 0;
                    cnt_y <= cur_y + 1;
                else
                    cnt_x <= cur_x + 1;
                    cnt_y <= cur_y;
                end if;

                -- Derniere ligne, dernier pixel : on fige le resultat, et le seuil du PS sera celui de l'image suivante en entier (la chaine met
                -- environ deux lignes a sortir le premier pixel de la suivante)
                if v_last = '1' and cur_y = IMG_HEIGHT - 1 then
                    rmax_q    <= nb_r;
                    posx_q    <= nb_x;
                    posy_q    <= nb_y;
                    frame_q   <= frame_q + 1;
                    seuil_eff <= seuil_in;
                end if;

                -- Debut d'une image qui ne suit pas une image complete (demarrage, image coupee) : on prend le seuil du PS maintenant
                if v_user = '1' then
                    started <= '1';
                    if started = '0' or cnt_y /= IMG_HEIGHT then
                        seuil_eff <= seuil_in;
                    end if;
                end if;
            end if;
        end if;
    end process;

end rtl;