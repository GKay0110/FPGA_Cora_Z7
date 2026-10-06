library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Traitement chaine video complet, sans bus AXI - les registres sont dans l'IP AXI en dehors
--   s_axis (video RGB du mux) -> overlay_stage (pour la jonction) -> rgb_to_gray -> fenetre -> gaussien
--   -> fenetre -> Harris -> binarisation -> retour vers overlay_stage -> m_axis

--   seuil_in et mode_in viennent de l'IP AXI ; r_max_out, pos_x_out, pos_y_out et
--   frame_cnt_out se branchent sur ses entrees

-- une image coupee (changement de  source) est detectee : la chaine est videe et repart sur l'image suivante
entity video_chain_top is
    generic (
        IMG_WIDTH    : integer := 640;
        IMG_HEIGHT   : integer := 480;
        G_FIFO_DEPTH : integer := 2048;
        G_OVL_COLOR  : std_logic_vector(23 downto 0) := x"00FFFF" -- Couleur Cyan
    );
    port (
        aclk    : in  std_logic;
        aresetn : in  std_logic;

        s_axis_tdata  : in  std_logic_vector(23 downto 0);
        s_axis_tvalid : in  std_logic;
        s_axis_tready : out std_logic;
        s_axis_tuser  : in  std_logic;
        s_axis_tlast  : in  std_logic;

        m_axis_tdata  : out std_logic_vector(23 downto 0);
        m_axis_tvalid : out std_logic;
        m_axis_tready : in  std_logic;
        m_axis_tuser  : out std_logic;
        m_axis_tlast  : out std_logic;


        seuil_in       : in  std_logic_vector(11 downto 0);
        mode_in        : in  std_logic;
        r_max_out      : out std_logic_vector(31 downto 0);
        pos_x_out      : out std_logic_vector(31 downto 0);
        pos_y_out      : out std_logic_vector(31 downto 0);
        frame_cnt_out  : out std_logic_vector(31 downto 0)
    );
end video_chain_top;

architecture rtl of video_chain_top is

    signal c_tdata  : std_logic_vector(23 downto 0);
    signal c_tvalid, c_tuser, c_tlast, c_tready : std_logic;

    signal gray_data : std_logic_vector(7 downto 0);
    signal gray_valid, gray_ready : std_logic;

    signal p11, p12, p13, p21, p22, p23, p31, p32, p33 : std_logic_vector(7 downto 0);
    signal win1_valid, win1_ready : std_logic;
    signal g_data : std_logic_vector(7 downto 0);
    signal g_valid, g_ready : std_logic;

    signal q11, q12, q13, q21, q22, q23, q31, q32, q33 : std_logic_vector(7 downto 0);
    signal win2_valid, win2_ready : std_logic;

    signal r_data : std_logic_vector(11 downto 0);
    signal r_valid, r_ready : std_logic;
    signal r_q : std_logic_vector(11 downto 0);

    signal b_data, b_valid, b_ready : std_logic;

    signal ovl_tvalid, ovl_tuser, ovl_tlast : std_logic;
    signal px_accepte : std_logic;

    constant NPIX : integer := IMG_WIDTH * IMG_HEIGHT;
    signal in_cnt      : integer range 0 to NPIX := 0;
    signal soft_cnt    : integer range 0 to 3 := 0;
    signal soft_rst    : std_logic;
    signal cut_detect  : std_logic;
    signal rst_chain_n : std_logic;
    signal ovl_s_tvalid, ovl_s_tready : std_logic;
    signal seuil : std_logic_vector(11 downto 0);

begin

    -- Resynchronisation - un tuser qui arrive alors que l'image precedente n'a pas eu ses resolutions pixels (image coupee, par exemple par le mux au changement de source) vide la chaine, puis le pixel est accepte
    cut_detect   <= s_axis_tvalid and s_axis_tuser when (in_cnt /= 0 and in_cnt /= NPIX) else '0';
    soft_rst     <= '1' when soft_cnt /= 0 else '0';
    rst_chain_n  <= aresetn and not soft_rst;
    ovl_s_tvalid <= s_axis_tvalid and not cut_detect and not soft_rst;
    s_axis_tready <= ovl_s_tready and not cut_detect and not soft_rst;

    resync_p : process(aclk)
    begin
        if rising_edge(aclk) then
            if aresetn = '0' then
                in_cnt <= 0;
                soft_cnt <= 0;
            elsif soft_cnt /= 0 then
                soft_cnt <= soft_cnt - 1;
                in_cnt <= 0;
            elsif cut_detect = '1' then
                soft_cnt <= 3;
            elsif s_axis_tvalid = '1' and ovl_s_tready = '1' then
                if s_axis_tuser = '1' then
                    in_cnt <= 1;
                elsif in_cnt < NPIX then
                    in_cnt <= in_cnt + 1;
                end if;
            end if;
        end if;
    end process;

    overlay : entity work.overlay_stage
        generic map (G_FIFO_DEPTH => G_FIFO_DEPTH, G_OVL_COLOR => G_OVL_COLOR)
        port map (
            clk => aclk, resetn => rst_chain_n, mode_overlay => mode_in,
            s_axis_tdata => s_axis_tdata, s_axis_tvalid => ovl_s_tvalid,
            s_axis_tready => ovl_s_tready, s_axis_tuser => s_axis_tuser,
            s_axis_tlast => s_axis_tlast,
            c_axis_tdata => c_tdata, c_axis_tvalid => c_tvalid, c_axis_tready => c_tready,
            c_axis_tuser => c_tuser, c_axis_tlast => c_tlast,
            f_axis_tdata => b_data, f_axis_tvalid => b_valid, f_axis_tready => b_ready,
            m_axis_tdata => m_axis_tdata, m_axis_tvalid => ovl_tvalid,
            m_axis_tready => m_axis_tready, m_axis_tuser => ovl_tuser,
            m_axis_tlast => ovl_tlast, fifo_level => open);

    m_axis_tvalid <= ovl_tvalid;
    px_accepte    <= ovl_tvalid and m_axis_tready;
    m_axis_tuser  <= ovl_tuser;
    m_axis_tlast  <= ovl_tlast;

    rgb_to_gray : entity work.rgb_to_gray
        port map (
            clk => aclk, resetn => rst_chain_n,
            s_axis_tdata => c_tdata, s_axis_tvalid => c_tvalid, s_axis_tready => c_tready,
            s_axis_tuser => c_tuser, s_axis_tlast => c_tlast,
            m_axis_tdata => gray_data, m_axis_tvalid => gray_valid,
            m_axis_tready => gray_ready, m_axis_tuser => open, m_axis_tlast => open);

    fenetre1 : entity work.sliding_window_3x3
        generic map (IMG_WIDTH => IMG_WIDTH, IMG_HEIGHT => IMG_HEIGHT)
        port map (
            clk => aclk, resetn => rst_chain_n,
            s_axis_tdata => gray_data, s_axis_tvalid => gray_valid, s_axis_tready => gray_ready,
            p11 => p11, p12 => p12, p13 => p13, p21 => p21, p22 => p22, p23 => p23,
            p31 => p31, p32 => p32, p33 => p33,
            m_valid => win1_valid, m_ready => win1_ready);

    gaussian : entity work.gaussian_conv
        port map (
            clk => aclk, resetn => rst_chain_n,
            p11 => p11, p12 => p12, p13 => p13, p21 => p21, p22 => p22, p23 => p23,
            p31 => p31, p32 => p32, p33 => p33,
            s_valid => win1_valid, s_ready => win1_ready,
            m_tdata => g_data, m_tvalid => g_valid, m_tready => g_ready);

    fenetre2 : entity work.sliding_window_3x3
        generic map (IMG_WIDTH => IMG_WIDTH, IMG_HEIGHT => IMG_HEIGHT)
        port map (
            clk => aclk, resetn => rst_chain_n,
            s_axis_tdata => g_data, s_axis_tvalid => g_valid, s_axis_tready => g_ready,
            p11 => q11, p12 => q12, p13 => q13, p21 => q21, p22 => q22, p23 => q23,
            p31 => q31, p32 => q32, p33 => q33,
            m_valid => win2_valid, m_ready => win2_ready);

    harris : entity work.harris_conv
        port map (
            clk => aclk, resetn => rst_chain_n,
            p12 => q12, p21 => q21, p22 => q22, p23 => q23, p32 => q32,
            s_valid => win2_valid, s_ready => win2_ready,
            m_tdata => r_data, m_tvalid => r_valid, m_tready => r_ready);

    binarisation : entity work.binarisation
        port map (
            clk => aclk, resetn => rst_chain_n,
            s_tdata => r_data, seuil => seuil, s_valid => r_valid, s_ready => r_ready,
            m_tdata => b_data, m_tvalid => b_valid, m_tready => b_ready);

    -- Copie du score R, avance et arretee exactement comme la sortie de binarisation - r_q est toujours le score du pixel dont b_data est le bit de detection
    r_copie : process(aclk)
    begin
        if rising_edge(aclk) then
            if rst_chain_n = '0' then
                r_q <= (others => '0');
            elsif b_ready = '1' then
                r_q <= r_data;
            end if;
        end if;
    end process;

    suivi : entity work.harris_track
        generic map (IMG_WIDTH => IMG_WIDTH, IMG_HEIGHT => IMG_HEIGHT)
        port map (
            clk => aclk, resetn => aresetn,
            v_valid => px_accepte, v_user => ovl_tuser, v_last => ovl_tlast, v_r => r_q,
            seuil_in => seuil_in, seuil_out => seuil,
            r_max => r_max_out, pos_x => pos_x_out, pos_y => pos_y_out,
            frame_cnt => frame_cnt_out);

end rtl;