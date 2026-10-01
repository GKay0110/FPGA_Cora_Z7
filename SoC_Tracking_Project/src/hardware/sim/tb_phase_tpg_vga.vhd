library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_phase_tpg_vga is
end tb_phase_tpg_vga;

architecture behavioral of tb_phase_tpg_vga is

    -- composant du wrapper vhdl de vivado
    component design_top_level_wrapper is
        port (
            clk_125MHz    : in  std_logic;
            resetn_rtl_0  : in  std_logic;
            VGA_B         : out std_logic_vector(3 downto 0);
            VGA_R         : out std_logic_vector(3 downto 0);
            VGA_G         : out std_logic_vector(3 downto 0);
            VGA_HS_O      : out std_logic;
            VGA_VS_O      : out std_logic
        );
    end component;

    -- signaux de simulation
    signal clk_125MHz   : std_logic := '0';
    signal resetn_rtl_0 : std_logic := '1';

    -- signaux d'observation principaux
    signal VGA_B  : std_logic_vector(3 downto 0);
    signal VGA_R  : std_logic_vector(3 downto 0);
    signal VGA_G  : std_logic_vector(3 downto 0);
    signal hsync  : std_logic;
    signal vsync  : std_logic;

    constant clk_period : time := 8 ns; -- 125 mhz

begin

    -- instanciation du wrapper
    uut: design_top_level_wrapper
        port map (
            clk_125MHz   => clk_125MHz,
            resetn_rtl_0 => resetn_rtl_0,
            VGA_B        => VGA_B,
            VGA_R        => VGA_R,
            VGA_G        => VGA_G,
            VGA_HS_O     => hsync,
            VGA_VS_O     => vsync
        );

    -- generation d'horloge avec l'operateur 'not'
    clk_process: process
    begin
        clk_125MHz <= not clk_125MHz;
        wait for clk_period / 2;
    end process;

    -- sequence de reset
    stim_proc: process
    begin
        resetn_rtl_0 <= '0';
        wait for 200 ns;
        resetn_rtl_0 <= '1';
        wait;
    end process;

end behavioral;