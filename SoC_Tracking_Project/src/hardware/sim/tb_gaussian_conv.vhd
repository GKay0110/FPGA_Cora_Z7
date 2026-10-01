library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- Verification la sortie avec la formule du SRS : convolution (somme ponderee) / 16.
entity tb_gaussian_conv is
end tb_gaussian_conv;

architecture behavioral of tb_gaussian_conv is

    component gaussian_conv is
        Port (
            clk    : in  std_logic;
            resetn : in  std_logic;
            p11, p12, p13 : in std_logic_vector(7 downto 0);
            p21, p22, p23 : in std_logic_vector(7 downto 0);
            p31, p32, p33 : in std_logic_vector(7 downto 0);
            s_valid : in  std_logic;
            s_ready : out std_logic;
            m_tdata  : out std_logic_vector(7 downto 0);
            m_tvalid : out std_logic;
            m_tready : in  std_logic
        );
    end component;

    signal clk    : std_logic := '0';
    signal resetn : std_logic := '0';

    signal p11, p12, p13 : std_logic_vector(7 downto 0) := (others => '0');
    signal p21, p22, p23 : std_logic_vector(7 downto 0) := (others => '0');
    signal p31, p32, p33 : std_logic_vector(7 downto 0) := (others => '0');
    signal s_valid : std_logic := '0';
    signal m_tdata  : std_logic_vector(7 downto 0);
    signal m_tvalid : std_logic;

    constant clk_period : time := 8 ns;

begin

    uut: gaussian_conv
        port map (
            clk => clk, resetn => resetn,
            p11 => p11, p12 => p12, p13 => p13,
            p21 => p21, p22 => p22, p23 => p23,
            p31 => p31, p32 => p32, p33 => p33,
            s_valid => s_valid, s_ready => open,
            m_tdata => m_tdata, m_tvalid => m_tvalid, m_tready => '1'
        );

    clk_process: process
    begin
        clk <= not clk;
        wait for clk_period / 2;
    end process;

    stim_proc: process
    begin
        resetn <= '0';
        wait for 200 ns;
        resetn <= '1';
        wait until rising_edge(clk);

        ------------------------------------------------------------------
        -- cas 1 : fenetre uniforme a 0 -> attendu 0
        ------------------------------------------------------------------
        p11 <= x"00"; p12 <= x"00"; p13 <= x"00";
        p21 <= x"00"; p22 <= x"00"; p23 <= x"00";
        p31 <= x"00"; p32 <= x"00"; p33 <= x"00";
        s_valid <= '1';
        wait until rising_edge(clk);
        s_valid <= '0';
        wait for 1 ns;
        assert (m_tvalid = '1') report "cas 1 : m_tvalid pas actif" severity error;
        assert (m_tdata = x"00")
            report "cas 1 : obtenu " & integer'image(to_integer(unsigned(m_tdata)))
                 & ", attendu 0"
            severity error;
        wait until rising_edge(clk);

        ------------------------------------------------------------------
        -- cas 2 : fenetre uniforme a 255 -> attendu 255
        ------------------------------------------------------------------
        p11 <= x"FF"; p12 <= x"FF"; p13 <= x"FF";
        p21 <= x"FF"; p22 <= x"FF"; p23 <= x"FF";
        p31 <= x"FF"; p32 <= x"FF"; p33 <= x"FF";
        s_valid <= '1';
        wait until rising_edge(clk);
        s_valid <= '0';
        wait for 1 ns;
        assert (m_tvalid = '1') report "cas 2 : m_tvalid pas actif" severity error;
        assert (m_tdata = x"FF")
            report "cas 2 : obtenu " & integer'image(to_integer(unsigned(m_tdata)))
                 & ", attendu 255"
            severity error;
        wait until rising_edge(clk);

        ------------------------------------------------------------------
        -- cas 3 : centre 200, voisins 100 -> attendu 125
        -- (4*200 + 12*100) / 16 = 2000 / 16 = 125
        ------------------------------------------------------------------
        p11 <= std_logic_vector(to_unsigned(100, 8));
        p12 <= std_logic_vector(to_unsigned(100, 8));
        p13 <= std_logic_vector(to_unsigned(100, 8));
        p21 <= std_logic_vector(to_unsigned(100, 8));
        p22 <= std_logic_vector(to_unsigned(200, 8));
        p23 <= std_logic_vector(to_unsigned(100, 8));
        p31 <= std_logic_vector(to_unsigned(100, 8));
        p32 <= std_logic_vector(to_unsigned(100, 8));
        p33 <= std_logic_vector(to_unsigned(100, 8));
        s_valid <= '1';
        wait until rising_edge(clk);
        s_valid <= '0';
        wait for 1 ns;
        assert (m_tvalid = '1') report "cas 3 : m_tvalid pas actif" severity error;
        assert (to_integer(unsigned(m_tdata)) = 125)
            report "cas 3 : obtenu " & integer'image(to_integer(unsigned(m_tdata)))
                 & ", attendu 125"
            severity error;
        wait until rising_edge(clk);

        ------------------------------------------------------------------
        -- cas 4 : 9 valeurs toutes differentes (1 a 9)
        -- Vérifcation que chaque poids s'applique a la bonne position
        -- 1*1+2*2+1*3 + 2*4+4*5+2*6 + 1*7+2*8+1*9 = 80 ; 80/16 = 5
        ------------------------------------------------------------------
        p11 <= std_logic_vector(to_unsigned(1, 8));
        p12 <= std_logic_vector(to_unsigned(2, 8));
        p13 <= std_logic_vector(to_unsigned(3, 8));
        p21 <= std_logic_vector(to_unsigned(4, 8));
        p22 <= std_logic_vector(to_unsigned(5, 8));
        p23 <= std_logic_vector(to_unsigned(6, 8));
        p31 <= std_logic_vector(to_unsigned(7, 8));
        p32 <= std_logic_vector(to_unsigned(8, 8));
        p33 <= std_logic_vector(to_unsigned(9, 8));
        s_valid <= '1';
        wait until rising_edge(clk);
        s_valid <= '0';
        wait for 1 ns;
        assert (m_tvalid = '1') report "cas 4 : m_tvalid pas actif" severity error;
        assert (to_integer(unsigned(m_tdata)) = 5)
            report "cas 4 : obtenu " & integer'image(to_integer(unsigned(m_tdata)))
                 & ", attendu 5"
            severity error;

        wait for 100 ns;
        report "Fin de simulation tb_gaussian_conv" severity note;
        wait;
    end process;

end behavioral;