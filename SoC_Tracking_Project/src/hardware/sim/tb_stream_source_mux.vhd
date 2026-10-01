library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_stream_source_mux is
end tb_stream_source_mux;

architecture behavioral of tb_stream_source_mux is


    component stream_source_mux is
        Port (
            clk           : in  STD_LOGIC;
            reset_n       : in  STD_LOGIC;
            req_source    : in  STD_LOGIC; -- 0 = tpg, 1 = dma

            dma_tdata     : in  STD_LOGIC_VECTOR(23 downto 0);
            dma_tlast     : in  STD_LOGIC;
            dma_tuser     : in  STD_LOGIC;
            dma_tvalid    : in  STD_LOGIC;
            dma_tready    : out STD_LOGIC;

            tpg_tdata     : in  STD_LOGIC_VECTOR(23 downto 0);
            tpg_tlast     : in  STD_LOGIC;
            tpg_tuser     : in  STD_LOGIC;
            tpg_tvalid    : in  STD_LOGIC;
            tpg_tready    : out STD_LOGIC;

            m_axis_tdata  : out STD_LOGIC_VECTOR(23 downto 0);
            m_axis_tlast  : out STD_LOGIC;
            m_axis_tuser  : out STD_LOGIC;
            m_axis_tvalid : out STD_LOGIC;
            m_axis_tready : in  STD_LOGIC
        );
    end component;

    -- Deux motifs constants faciles a distinguer
    constant TPG_PATTERN : std_logic_vector(23 downto 0) := x"555555";
    constant DMA_PATTERN : std_logic_vector(23 downto 0) := x"AAAAAA";

    signal clk        : std_logic := '0';
    signal reset_n    : std_logic := '0';
    signal req_source : std_logic := '0'; -- demarre sur tpg

    -- Un seul compteur, court, juste pour faire pulser tuser periodiquement
    -- (La vraie taille d'image n'a aucune importance pour ce test vérification unqiuement du moment de la bascule)
    constant FRAME_LEN : integer := 50;
    signal x : integer := 0;

    signal dma_tdata, tpg_tdata   : std_logic_vector(23 downto 0);
    signal dma_tlast, tpg_tlast   : std_logic;
    signal dma_tuser, tpg_tuser   : std_logic;
    signal dma_tready, tpg_tready : std_logic;

    signal m_tdata  : std_logic_vector(23 downto 0);
    signal m_tlast, m_tuser, m_tvalid : std_logic;

    constant clk_period : time := 8 ns; -- 125 mhz

    -- Observation en sortie : 0 si on voit le motif tpg, 1 si dma
    signal current_source : std_logic := '0';

begin

    uut: stream_source_mux
        port map (
            clk           => clk,
            reset_n       => reset_n,
            req_source    => req_source,
            dma_tdata     => dma_tdata,
            dma_tlast     => dma_tlast,
            dma_tuser     => dma_tuser,
            dma_tvalid    => '1',
            dma_tready    => dma_tready,
            tpg_tdata     => tpg_tdata,
            tpg_tlast     => tpg_tlast,
            tpg_tuser     => tpg_tuser,
            tpg_tvalid    => '1',
            tpg_tready    => tpg_tready,
            m_axis_tdata  => m_tdata,
            m_axis_tlast  => m_tlast,
            m_axis_tuser  => m_tuser,
            m_axis_tvalid => m_tvalid,
            m_axis_tready => '1' -- toujours pret cote sortie
        );

    clk_process: process
    begin
        clk <= not clk;
        wait for clk_period / 2;
    end process;

    -- tuser periodique toutes les FRAME_LEN cycles - tlast non utilise par ce test, laisse a '0'
    counter_image: process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                x <= 0;
            elsif x = FRAME_LEN - 1 then
                x <= 0;
            else
                x <= x + 1;
            end if;
        end if;
    end process;

    dma_tdata <= DMA_PATTERN;
    dma_tuser <= '1' when (x = 0) else '0';
    dma_tlast <= '0';

    tpg_tdata <= TPG_PATTERN;
    tpg_tuser <= '1' when (x = 0) else '0';
    tpg_tlast <= '0';

    -- Sequence de test : reset, puis demande de bascule vers dma en plein
    -- milieu d'une ligne (donc pas au debut de trame), pour verifier que le mux attend bien le bon moment avant de basculer
    global_process: process
    begin
        reset_n <= '0';
        req_source <= '0';
        wait for 200 ns;
        reset_n <= '1';

        wait for 220 ns;
        req_source <= '1';
        
        wait for 350 ns;
        req_source <= '0';
        
        wait for 350 ns;
        req_source <= '1';

        wait for 20 us; -- Période large pour observer après resultats 
        report "Fin de simulation tb_stream_source_mux" severity note;
        wait;
    end process;

    
    -- Verification : la source vue en sortie (m_tdata) ne doit changer
    -- de valeur qu'au moment ou m_tuser est actif (debut de trame),
    -- jamais au milieu d'une ligne ou d'une trame

    check_proc: process(clk)
        variable new_source : std_logic; 
    begin
        
        if rising_edge(clk) then
            if reset_n = '1' and m_tvalid = '1' then

                if m_tdata = TPG_PATTERN then
                    new_source := '0';
                elsif m_tdata = DMA_PATTERN then
                    new_source := '1';
                end if;

                

                if new_source /= current_source then
                    assert (m_tuser = '1')
                        report "Erreur : la source de sortie a change sans etre alignee sur tuser"
                        severity error;
                end if;
                
                current_source <= new_source;

            end if;
        end if;
    end process;

end behavioral;
