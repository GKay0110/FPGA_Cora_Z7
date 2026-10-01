----------------------------------------------------------------------------------
-- Convertisseur AXI-Stream vers VGA (Sans PLL interne)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity axis_to_vga_adapter is
    Port ( 
        -- Horloge pixel externe (ex: 25 MHz générée par une unique PLL en amont)
        clk       : in  STD_LOGIC;
        resetn        : in  STD_LOGIC;
        
        -- Interface AXI-Stream (provenant de ton TPG)
        s_axis_tdata  : in  STD_LOGIC_VECTOR (23 downto 0); 
        s_axis_tvalid : in  STD_LOGIC;
        s_axis_tready : out STD_LOGIC;
        s_axis_tuser  : in  STD_LOGIC;
        s_axis_tlast  : in  STD_LOGIC;
        
        -- Sorties physiques VGA (4 bits par canal)
        VGA_HS_O      : out STD_LOGIC;
        VGA_VS_O      : out STD_LOGIC;
        VGA_R         : out STD_LOGIC_VECTOR (3 downto 0);
        VGA_B         : out STD_LOGIC_VECTOR (3 downto 0);
        VGA_G         : out STD_LOGIC_VECTOR (3 downto 0)
    );
end axis_to_vga_adapter;

architecture Behavioral of axis_to_vga_adapter is

-- Résolution 640x480@60Hz
constant FRAME_WIDTH  : natural := 640;
constant FRAME_HEIGHT : natural := 480;

constant H_FP : natural := 16;
constant H_PW : natural := 96;
constant H_MAX : natural := 800;

constant V_FP : natural := 10;
constant V_PW : natural := 2;
constant V_MAX : natural := 525;

constant H_POL : std_logic := '0';
constant V_POL : std_logic := '0';

signal active  : std_logic;

signal h_cntr_reg : std_logic_vector(11 downto 0) := (others => '0');
signal v_cntr_reg : std_logic_vector(11 downto 0) := (others => '0');

signal h_sync_reg : std_logic := not(H_POL);
signal v_sync_reg : std_logic := not(V_POL);

signal h_sync_dly_reg : std_logic := not(H_POL);
signal v_sync_dly_reg : std_logic := not(V_POL);

signal r_reg, g_reg, b_reg : std_logic_vector(3 downto 0) := (others => '0');
signal pixel_en : std_logic;

begin

    -- Compteurs de timing VGA pilotés par la vraie horloge pixel externe
    process (clk, resetn)
    begin
        if resetn = '0' then
            h_cntr_reg <= (others => '0');
            v_cntr_reg <= (others => '0');
        elsif rising_edge(clk) then
            if h_cntr_reg = (H_MAX - 1) then
                h_cntr_reg <= (others => '0');
                if v_cntr_reg = (V_MAX - 1) then
                    v_cntr_reg <= (others => '0');
                else
                    v_cntr_reg <= v_cntr_reg + 1;
                end if;
            else
                h_cntr_reg <= h_cntr_reg + 1;
            end if;
        end if;
    end process;

    -- Signaux de synchro H et V
    process (clk)
    begin
        if rising_edge(clk) then
            if h_cntr_reg >= (H_FP + FRAME_WIDTH - 1) and h_cntr_reg < (H_FP + FRAME_WIDTH + H_PW - 1) then
                h_sync_reg <= H_POL;
            else
                h_sync_reg <= not(H_POL);
            end if;

            if v_cntr_reg >= (V_FP + FRAME_HEIGHT - 1) and v_cntr_reg < (V_FP + FRAME_HEIGHT + V_PW - 1) then
                v_sync_reg <= V_POL;
            else
                v_sync_reg <= not(V_POL);
            end if;
        end if;
    end process;

    active <= '1' when (h_cntr_reg < FRAME_WIDTH) and (v_cntr_reg < FRAME_HEIGHT) else '0';

    -- Gestion du flux AXI-Stream
    pixel_en <= '1' when (active = '1') else '0';
    s_axis_tready <= pixel_en;

    -- Échantillonnage des données AXI et sortie vers le VGA
    process (clk, resetn)
    begin
        if resetn = '0' then
            r_reg <= (others => '0');
            g_reg <= (others => '0');
            b_reg <= (others => '0');
            v_sync_dly_reg <= not(V_POL);
            h_sync_dly_reg <= not(H_POL);
        elsif rising_edge(clk) then
            v_sync_dly_reg <= v_sync_reg;
            h_sync_dly_reg <= h_sync_reg;

            if (s_axis_tvalid = '1' and pixel_en = '1') then
                -- Extraction des canaux (adapte les indices selon la largeur du tdata)
                r_reg <= s_axis_tdata(23 downto 20);
                g_reg <= s_axis_tdata(15 downto 12);
                b_reg <= s_axis_tdata(7 downto 4);
            else
                r_reg <= (others => '0');
                g_reg <= (others => '0');
                b_reg <= (others => '0');
            end if;
        end if;
    end process;

    VGA_HS_O <= h_sync_dly_reg;
    VGA_VS_O <= v_sync_dly_reg;
    VGA_R    <= r_reg;
    VGA_G    <= g_reg;
    VGA_B    <= b_reg;

end Behavioral;