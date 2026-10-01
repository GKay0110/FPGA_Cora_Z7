library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stream_source_mux is
    Port (
        clk      : in  std_logic;
        reset_n        : in  std_logic;
        req_source     : in  std_logic; -- '0' = tpg, '1' = dma

        tpg_tdata      : in  std_logic_vector(23 downto 0);
        tpg_tvalid     : in  std_logic;
        tpg_tready     : out std_logic;
        tpg_tlast      : in  std_logic;
        tpg_tuser      : in  std_logic;

        dma_tdata      : in  std_logic_vector(23 downto 0);
        dma_tvalid     : in  std_logic;
        dma_tready     : out std_logic;
        dma_tlast      : in  std_logic;
        dma_tuser      : in  std_logic;

        m_axis_tdata   : out std_logic_vector(23 downto 0);
        m_axis_tvalid  : out std_logic;
        m_axis_tready  : in  std_logic;
        m_axis_tlast   : out std_logic;
        m_axis_tuser   : out std_logic
    );
end stream_source_mux;

architecture Behavioral of stream_source_mux is
    signal current_sel : std_logic := '0';
begin


    process(clk, reset_n)
        variable next_sel : std_logic;
    begin
        if reset_n = '0' then
            current_sel   <= '0';
            m_axis_tdata  <= (others => '0');
            m_axis_tvalid <= '0';
            m_axis_tlast  <= '0';
            m_axis_tuser  <= '0';
        elsif rising_edge(clk) then

            -- A partir de la selection actuelle, et modification seulement si la source demandee vient d'afficher son propre debut de trame
            next_sel := current_sel;
            if (req_source = '0' and tpg_tuser = '1' and tpg_tvalid = '1') or
               (req_source = '1' and dma_tuser = '1' and dma_tvalid = '1') then
                next_sel := req_source;
            end if;
            current_sel <= next_sel;

            -- La sortie utilise directement next_sel : elle change donc exactement au meme cycle que la decision, plus de decalage
            if next_sel = '0' then
                m_axis_tdata  <= tpg_tdata;
                m_axis_tvalid <= tpg_tvalid;
                m_axis_tlast  <= tpg_tlast;
                m_axis_tuser  <= tpg_tuser;
            else
                m_axis_tdata  <= dma_tdata;
                m_axis_tvalid <= dma_tvalid;
                m_axis_tlast  <= dma_tlast;
                m_axis_tuser  <= dma_tuser;
            end if;

        end if;
    end process;

    -- tready reste combinatoire : le signal indique tout de suite quelle source peut envoyer une donnee
    -- La source desselectionnée n'est plus gelée : on la laisse tourner en
    -- arriere-plan (ses donnees sont ignorees) pour qu'elle continue produire des tuser periodiques 
    tpg_tready <= m_axis_tready when current_sel = '0' else '1';
    dma_tready <= m_axis_tready when current_sel = '1' else '1';

end Behavioral;