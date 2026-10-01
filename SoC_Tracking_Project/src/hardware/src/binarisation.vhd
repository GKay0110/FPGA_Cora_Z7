library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Binarisation par seuil : sortie = 1 si R >= seuil, 0 sinon
-- "Seuil" est signe, comme R : un seuil negatif ou nul detecterait tout,
-- Communication avec le PS.
entity binarisation is
    Port (
        clk      : in  std_logic;
        resetn   : in  std_logic;

        s_tdata  : in  std_logic_vector(11 downto 0); -- R, signe
        seuil    : in  std_logic_vector(11 downto 0); -- signé, registre PS

        s_valid  : in  std_logic;
        s_ready  : out std_logic;

        m_tdata  : out std_logic; -- 1 bit
        m_tvalid : out std_logic;
        m_tready : in  std_logic
    );
end binarisation;

architecture rtl of binarisation is
begin

    s_ready <= m_tready;

    process(clk)
    begin
        if rising_edge(clk) then
            if resetn = '0' then
                m_tdata  <= '0';
                m_tvalid <= '0';
            elsif m_tready = '1' then

                if signed(s_tdata) >= signed(seuil) then
                    m_tdata <= '1';
                else
                    m_tdata <= '0';
                end if;

                m_tvalid <= s_valid;

            end if;
        end if;
    end process;

end rtl;