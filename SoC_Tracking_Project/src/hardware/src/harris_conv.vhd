library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Filtre de  Harris : les poids -> 0 -1 0 / -1 4 -1 / 0 -1 0
-- les coins ont un poids de 0, ils n'entrent pas dans le calcul :
-- R = 4*centre - (somme des 4 voisins directs, haut/bas/gauche/droite)
--
--  La valeur de comparaison R peut etre negatif (si les voisins sont plus clairs que
-- le centre), d'ou une sortie signee sur 12 bits
entity harris_conv is
    Port (
        clk    : in  std_logic;
        resetn : in  std_logic;

        -- seuls les 4 voisins directs et le centre sont utilises
        p12, p21, p22, p23, p32 : in std_logic_vector(7 downto 0);

        s_valid : in  std_logic;
        s_ready : out std_logic;

        m_tdata  : out std_logic_vector(11 downto 0); -- signe
        m_tvalid : out std_logic;
        m_tready : in  std_logic
    );
end harris_conv;

architecture rtl of harris_conv is
begin

    s_ready <= m_tready;

    process(clk)
        variable v_centre  : signed(11 downto 0);
        variable v_voisins : signed(11 downto 0);
        variable v_r       : signed(11 downto 0);
    begin
        if rising_edge(clk) then
            if resetn = '0' then
                m_tdata  <= (others => '0');
                m_tvalid <= '0';
            elsif m_tready = '1' then

                -- x4 par decalage, pas par multiplication,  "*4" doublerait la largeur)
                v_centre := shift_left(resize(signed('0' & p22), 12), 2);

                v_voisins := resize(signed('0' & p12), 12)      
                           + resize(signed('0' & p21), 12)
                           + resize(signed('0' & p23), 12)
                           + resize(signed('0' & p32), 12);

                v_r := v_centre - v_voisins;        -- sortie = -p12 - p21 + 4×p22 - p23 - p32 = 4×p22 - (p12 + p21 + p23 + p32)

                m_tdata  <= std_logic_vector(v_r);
                m_tvalid <= s_valid;

            end if;
        end if;
    end process;

end rtl;