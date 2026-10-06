library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- FIFO + jonction pour l'overlay.
-- Le pixel brut attend dans la FIFO que son bit de detection arrive de la chaine, ils sortent ensemble -  tuser et tlast sont stockes avec le pixel

-- Prefixes : s = flux brut en entree, c = vers la chaine, f = bit de detection (flag) venant de la chaine, m = video finale en sortie

-- Le mode (A ou B) est pris au premier pixel de chaque image (tuser) et garde jusqu'a l'image suivante

entity overlay_stage is
    generic (
        G_FIFO_DEPTH : integer := 2048;
        G_OVL_COLOR  : std_logic_vector(23 downto 0) := x"00FFFF"  -- r & g & b - Couleur Cyan
    );
    port (
        clk    : in  std_logic;
        resetn : in  std_logic;

        mode_overlay : in std_logic;  -- '1' = mode B (overlay), '0' = mode A (brut)

        -- Entree : flux brut (du mux)
        s_axis_tdata  : in  std_logic_vector(23 downto 0);
        s_axis_tvalid : in  std_logic;
        s_axis_tready : out std_logic;
        s_axis_tuser  : in  std_logic;
        s_axis_tlast  : in  std_logic;

        -- Sortie vers la chaine de traitement
        c_axis_tdata  : out std_logic_vector(23 downto 0);
        c_axis_tvalid : out std_logic;
        c_axis_tready : in  std_logic;
        c_axis_tuser  : out std_logic;
        c_axis_tlast  : out std_logic;

        -- Entree : bit de detection (de la chaine)
        f_axis_tdata  : in  std_logic;
        f_axis_tvalid : in  std_logic;
        f_axis_tready : out std_logic;

        -- Sortie : video finale
        m_axis_tdata  : out std_logic_vector(23 downto 0);
        m_axis_tvalid : out std_logic;
        m_axis_tready : in  std_logic;
        m_axis_tuser  : out std_logic;
        m_axis_tlast  : out std_logic;

        fifo_level : out std_logic_vector(11 downto 0)
    );
end overlay_stage;

architecture rtl of overlay_stage is

    type mem_t is array (0 to G_FIFO_DEPTH - 1) of std_logic_vector(25 downto 0);
    signal mem : mem_t := (others => (others => '0'));

    signal wr_ptr : integer range 0 to G_FIFO_DEPTH - 1 := 0;
    signal rd_ptr : integer range 0 to G_FIFO_DEPTH - 1 := 0;
    signal count  : integer range 0 to G_FIFO_DEPTH     := 0;

    signal fifo_full  : std_logic;
    signal fifo_empty : std_logic;
    signal wr_en      : std_logic;
    signal rd_en      : std_logic;
    signal pixel_brut : std_logic_vector(25 downto 0);
    signal mode_q     : std_logic := '0';
    signal mode_eff   : std_logic;

begin

    fifo_full  <= '1' when count = G_FIFO_DEPTH else '0';
    fifo_empty <= '1' when count = 0            else '0';
    fifo_level <= std_logic_vector(to_unsigned(count, 12));

    -- fork
    s_axis_tready <= c_axis_tready and not fifo_full;
    c_axis_tvalid <= s_axis_tvalid and not fifo_full;
    c_axis_tdata  <= s_axis_tdata;
    c_axis_tuser  <= s_axis_tuser;
    c_axis_tlast  <= s_axis_tlast;
    wr_en         <= s_axis_tvalid and c_axis_tready and not fifo_full;

    -- Jonction
    pixel_brut    <= mem(rd_ptr);
    m_axis_tvalid <= f_axis_tvalid and not fifo_empty;
    rd_en         <= f_axis_tvalid and m_axis_tready and not fifo_empty;
    -- Pret tant qu'aucun bit n'attend : evite le blocage au demarrage
    f_axis_tready <= (m_axis_tready and not fifo_empty) or (not f_axis_tvalid);

    m_axis_tuser  <= pixel_brut(25);
    m_axis_tlast  <= pixel_brut(24);
    mode_eff      <= mode_overlay when pixel_brut(25) = '1' else mode_q;
    m_axis_tdata  <= G_OVL_COLOR
                     when (mode_eff = '1' and f_axis_tdata = '1')
                     else pixel_brut(23 downto 0);

    -- FIFO
    process(clk)
    begin
        if rising_edge(clk) then
            if resetn = '0' then
                wr_ptr <= 0;
                rd_ptr <= 0;
                count  <= 0;
                mode_q <= '0';
            else
                if rd_en = '1' and pixel_brut(25) = '1' then
                    mode_q <= mode_overlay;
                end if;

                if wr_en = '1' then
                    mem(wr_ptr) <= s_axis_tuser & s_axis_tlast & s_axis_tdata;
                    if wr_ptr = G_FIFO_DEPTH - 1 then
                        wr_ptr <= 0;
                    else
                        wr_ptr <= wr_ptr + 1;
                    end if;
                end if;

                if rd_en = '1' then
                    if rd_ptr = G_FIFO_DEPTH - 1 then
                        rd_ptr <= 0;
                    else
                        rd_ptr <= rd_ptr + 1;
                    end if;
                end if;

                if wr_en = '1' and rd_en = '0' then
                    count <= count + 1;
                elsif wr_en = '0' and rd_en = '1' then
                    count <= count - 1;
                end if;
            end if;
        end if;
    end process;

end rtl;