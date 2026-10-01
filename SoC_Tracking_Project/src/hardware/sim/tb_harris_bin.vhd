library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Testbench harris_conv + binarisation ensemble, isolement (sans sliding_window)
entity tb_harris_bin is
end tb_harris_bin;

architecture behavioral of tb_harris_bin is

    component harris_conv is
        Port (
            clk, resetn : in std_logic;
            p12, p21, p22, p23, p32 : in std_logic_vector(7 downto 0);
            s_valid : in std_logic;
            s_ready : out std_logic;
            m_tdata  : out std_logic_vector(11 downto 0);
            m_tvalid : out std_logic;
            m_tready : in std_logic
        );
    end component;

    component binarisation is
        Port (
            clk, resetn : in std_logic;
            s_tdata : in std_logic_vector(11 downto 0);
            seuil   : in std_logic_vector(11 downto 0);
            s_valid : in std_logic;
            s_ready : out std_logic;
            m_tdata  : out std_logic;
            m_tvalid : out std_logic;
            m_tready : in std_logic
        );
    end component;

    signal clk    : std_logic := '0';
    signal resetn : std_logic := '0';

    signal p12, p21, p22, p23, p32 : std_logic_vector(7 downto 0) := (others => '0');
    signal s_valid : std_logic := '0';

    signal r_tdata  : std_logic_vector(11 downto 0);
    signal r_tvalid : std_logic;

    -- seuil fixe pour ce test : 100
    constant SEUIL : std_logic_vector(11 downto 0) :=
        std_logic_vector(to_signed(100, 12));

    signal bin_tdata  : std_logic;
    signal bin_tvalid : std_logic;

    constant clk_period : time := 8 ns;

begin

    uut_harris : harris_conv
        port map (
            clk => clk, resetn => resetn,
            p12 => p12, p21 => p21, p22 => p22, p23 => p23, p32 => p32,
            s_valid => s_valid, s_ready => open,
            m_tdata => r_tdata, m_tvalid => r_tvalid, m_tready => '1'
        );

    uut_bin : binarisation
        port map (
            clk => clk, resetn => resetn,
            s_tdata => r_tdata, seuil => SEUIL,
            s_valid => r_tvalid, s_ready => open,
            m_tdata => bin_tdata, m_tvalid => bin_tvalid, m_tready => '1'
        );

    clk_process: process
    begin
        clk <= not clk;
        wait for clk_period / 2;
    end process;

    global_process: process
    begin
        resetn <= '0';
        wait for 200 ns;
        resetn <= '1';
        wait until rising_edge(clk);

        ------------------------------------------------------------------
        -- cas 1 : fenetre plate (tout a 100) -> R = 400-400 = 0
        -- 0 >= 100 ? non -> binarise = 0
        ------------------------------------------------------------------
        p12 <= std_logic_vector(to_unsigned(100, 8));
        p21 <= std_logic_vector(to_unsigned(100, 8));
        p22 <= std_logic_vector(to_unsigned(100, 8));
        p23 <= std_logic_vector(to_unsigned(100, 8));
        p32 <= std_logic_vector(to_unsigned(100, 8));
        s_valid <= '1';
        wait until rising_edge(clk);
        s_valid <= '0';
        wait for 1 ns;
        assert (to_integer(signed(r_tdata)) = 0)
            report "cas 1 : R obtenu " & integer'image(to_integer(signed(r_tdata)))
                 & ", attendu 0"
            severity error;
        wait until rising_edge(clk);
        wait for 1 ns;
        assert (bin_tdata = '0')
            report "cas 1 : binarise obtenu '" & std_logic'image(bin_tdata)
                 & "', attendu '0'"
            severity error;
        wait until rising_edge(clk);

        ------------------------------------------------------------------
        -- cas 2 : centre tres clair, voisins noirs -> forte reponse
        -- R = 4*255 - 0 = 1020. 1020 >= 100 ? oui -> binarise = 1
        ------------------------------------------------------------------
        p12 <= std_logic_vector(to_unsigned(0, 8));
        p21 <= std_logic_vector(to_unsigned(0, 8));
        p22 <= std_logic_vector(to_unsigned(255, 8));
        p23 <= std_logic_vector(to_unsigned(0, 8));
        p32 <= std_logic_vector(to_unsigned(0, 8));
        s_valid <= '1';
        wait until rising_edge(clk);
        s_valid <= '0';
        wait for 1 ns;
        assert (to_integer(signed(r_tdata)) = 1020)
            report "Cas 2 : R obtenu " & integer'image(to_integer(signed(r_tdata)))
                 & ", attendu 1020"
            severity error;
        wait until rising_edge(clk);
        wait for 1 ns;
        assert (bin_tdata = '1')
            report "Cas 2 : binarise obtenu '" & std_logic'image(bin_tdata)
                 & "', attendu '1'"
            severity error;
        wait until rising_edge(clk);

        ------------------------------------------------------------------
        -- cas 3 : centre noir, voisins tres clairs -> reponse negative
        -- R = 0 - 4*255 = -1020. -1020 >= 100 ? non -> binarise = 0
        ------------------------------------------------------------------
        p12 <= std_logic_vector(to_unsigned(255, 8));
        p21 <= std_logic_vector(to_unsigned(255, 8));
        p22 <= std_logic_vector(to_unsigned(0, 8));
        p23 <= std_logic_vector(to_unsigned(255, 8));
        p32 <= std_logic_vector(to_unsigned(255, 8));
        s_valid <= '1';
        wait until rising_edge(clk);
        s_valid <= '0';
        wait for 1 ns;
        assert (to_integer(signed(r_tdata)) = -1020)
            report "Cas 3 : R obtenu " & integer'image(to_integer(signed(r_tdata)))
                 & ", attendu -1020"
            severity error;
        wait until rising_edge(clk);
        wait for 1 ns;
        assert (bin_tdata = '0')
            report "Cas 3 : binarise obtenu '" & std_logic'image(bin_tdata)
                 & "', attendu '0'"
            severity error;

        wait for 100 ns;
        report "Fin de simulation tb_harris_bin" severity note;
        wait;
    end process;

end behavioral;