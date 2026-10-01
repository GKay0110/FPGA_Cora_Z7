library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Fonction qui prend une fenetre 3x3 deja formee (par sliding_window_3x3) et applique
-- le filtre gaussien : poids 1-2-1/2-4-2/1-2-1, sortie = somme/16 (entier)
entity gaussian_conv is
    Port (
        clk    : in  std_logic;
        resetn : in  std_logic;

        p11, p12, p13 : in std_logic_vector(7 downto 0); -- ligne du dessus
        p21, p22, p23 : in std_logic_vector(7 downto 0); -- ligne du milieu
        p31, p32, p33 : in std_logic_vector(7 downto 0); -- ligne actuelle
        s_valid : in  std_logic;
        s_ready : out std_logic;

        m_tdata  : out std_logic_vector(7 downto 0);
        m_tvalid : out std_logic;
        m_tready : in  std_logic
    );
end gaussian_conv;

architecture rtl of gaussian_conv is
begin

    s_ready <= m_tready;

    process(clk)
        variable v_sum : unsigned(11 downto 0); -- Capacité assez large pour 16*255 = 4080
    begin
        if rising_edge(clk) then
            if resetn = '0' then
                m_tvalid <= '0';
                m_tdata  <= (others => '0');
            elsif m_tready = '1' then

                v_sum :=      resize(unsigned(p11), 12) + shift_left(resize(unsigned(p12), 12), 1) +      resize(unsigned(p13), 12)
                       + shift_left(resize(unsigned(p21), 12), 1) + shift_left(resize(unsigned(p22), 12), 2) + shift_left(resize(unsigned(p23), 12), 1)     
                       +      resize(unsigned(p31), 12) + shift_left(resize(unsigned(p32), 12), 1) +      resize(unsigned(p33), 12);

                -- Division par 16 = ne garder que les 8 bits hauts sur 12 : 
                -- Aucun calcul reel, juste une lecture de bits 
                m_tdata  <= std_logic_vector(v_sum(11 downto 4));
                m_tvalid <= s_valid;

            end if;
        end if;
    end process;

end rtl;