library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity tb_sliding_window is
end tb_sliding_window;

architecture behavioral of tb_sliding_window is

    constant IMG_WIDTH : integer := 4;

    component sliding_window_3x3 is
        generic ( IMG_WIDTH : integer := 640 );
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
    end component;

    signal clk    : std_logic := '0';
    signal resetn : std_logic := '0';

    signal s_tdata  : std_logic_vector(7 downto 0) := (others => '0');
    signal s_tvalid : std_logic := '0';

    signal p11, p12, p13 : std_logic_vector(7 downto 0);
    signal p21, p22, p23 : std_logic_vector(7 downto 0);
    signal p31, p32, p33 : std_logic_vector(7 downto 0);
    signal m_valid : std_logic;

    constant clk_period : time := 8 ns;


-- image de test 4x3, connue a l'avance :
--   ligne 0 (2 lignes avant) : 1  2  3  4
--   ligne 1 (1 ligne avant)  : 5  6  7  8
--   ligne 2 (courante)       : 9 10 11 12
    -- l'image de test, pixel par pixel, dans l'ordre du flux
    type img_array is array (0 to 11) of integer;
    constant IMG : img_array := (
        1,2,3,4,
        5,6,7,8,
        9,10,11,12
    );

    signal already_checked : boolean := false;

begin

-- donc : p11,p12,p13 = 1,2,3  (ligne du dessus, colonnes 0 a 2)
--        p21,p22,p23 = 5,6,7  (ligne du milieu)
--        p31,p32,p33 = 9,10,11 (ligne courante)

    uut: sliding_window_3x3
        generic map (IMG_WIDTH => IMG_WIDTH)
        port map (
            clk => clk, resetn => resetn,
            s_axis_tdata => s_tdata, s_axis_tvalid => s_tvalid,
            s_axis_tready => open,
            p11 => p11, p12 => p12, p13 => p13,
            p21 => p21, p22 => p22, p23 => p23,
            p31 => p31, p32 => p32, p33 => p33,
            m_valid => m_valid, m_ready => '1'
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

        for i in IMG'range loop
            s_tdata  <= std_logic_vector(to_unsigned(IMG(i), 8));
            s_tvalid <= '1';
            wait until rising_edge(clk);
        end loop;

        s_tvalid <= '0';
        wait for 100 ns;
        report "fin de simulation tb_sliding_window" severity note;
        wait;
    end process;

    -- Verifie la toute premiere fenetre valide, une seule fois
    check_proc: process(clk)
    begin
        if rising_edge(clk) then
            if resetn = '1' and m_valid = '1' and not already_checked then

                assert (to_integer(unsigned(p11)) = 1 and to_integer(unsigned(p12)) = 2 and to_integer(unsigned(p13)) = 3)
                    report "erreur sliding_window : ligne du dessus incorrecte" severity error;

                assert (to_integer(unsigned(p21)) = 5 and to_integer(unsigned(p22)) = 6 and to_integer(unsigned(p23)) = 7)
                    report "erreur sliding_window : ligne du milieu incorrecte" severity error;

                assert (to_integer(unsigned(p31)) = 9 and to_integer(unsigned(p32)) = 10 and to_integer(unsigned(p33)) = 11)
                    report "erreur sliding_window : ligne courante incorrecte" severity error;

                report "sliding_window : premiere fenetre valide conforme" severity note;
                already_checked <= true;

            end if;
        end if;
    end process;

end behavioral;