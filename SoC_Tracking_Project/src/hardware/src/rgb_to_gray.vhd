library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Convertisseur de pixel rgb (24 bits) en niveau de gris (8 bits),
-- Formule standard bt.601 : y = 0.299*r + 0.587*g + 0.114*b
-- Approximee en entier pour eviter le calcul flottant en materiel :
-- y = (77*r + 150*g + 29*b) / 256   (les poids 77+150+29 = 256)

entity rgb_to_gray is
    Port (
        clk           : in  std_logic;
        resetn        : in  std_logic;

        s_axis_tdata  : in  std_logic_vector(23 downto 0); -- r & g & b
        s_axis_tvalid : in  std_logic;
        s_axis_tready : out std_logic;
        s_axis_tuser  : in  std_logic;
        s_axis_tlast  : in  std_logic;

        m_axis_tdata  : out std_logic_vector(7 downto 0); -- gris
        m_axis_tvalid : out std_logic;
        m_axis_tready : in  std_logic;
        m_axis_tuser  : out std_logic;
        m_axis_tlast  : out std_logic
    );
end rgb_to_gray;

architecture Behavioral of rgb_to_gray is

    signal r, g, b : unsigned(7 downto 0);

begin

  
    -- La sortie accepte de nouvelles donnees exactement au meme rythme que celui impose par le recepteur en aval
    s_axis_tready <= m_axis_tready;

    r <= unsigned(s_axis_tdata(23 downto 16));
    g <= unsigned(s_axis_tdata(15 downto 8));
    b <= unsigned(s_axis_tdata(7 downto 0));


    process(clk)
        variable gray_level : unsigned(15 downto 0); -- variable : disponible tout de suite
    begin
        if rising_edge(clk) then
            if resetn = '0' then
                m_axis_tvalid <= '0';
                m_axis_tuser  <= '0';
                m_axis_tlast  <= '0';
                m_axis_tdata  <= (others => '0');
            elsif m_axis_tready = '1' then
                gray_level := (77 * r) + (150 * g) + (29 * b);

                m_axis_tdata  <= std_logic_vector(gray_level(15 downto 8)); -- /256
                m_axis_tvalid <= s_axis_tvalid;
                m_axis_tuser  <= s_axis_tuser;
                m_axis_tlast  <= s_axis_tlast;
            end if;
        end if;
    end process;

end Behavioral;