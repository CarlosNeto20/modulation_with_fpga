-- Portadora Triangular

-- Precisamos de 4 portadoras triangulares, cada uma com um offset diferente.
--
-- Qual que vai ser a ideia:
-- Triangular 1: Base; -2Vdc até -Vdc; 0 a 255
-- Triangular 2: Meio Baixo; -Vdc até 0; 256 a 511;
-- Triangular 3: Meio Alto; 0 até Vdc; 512 a 767;
-- Triangular 4: Topo; Vdc até 2Vdc; 768 a 1023

library ieee;
use ieee.std_logic_1164.all;

entity portadora is port
(
    clk   : in  std_logic;
    rst   : in  std_logic; -- Pino de reset apenas para segurança (você pode querer ou não ter ele, beleza ?)
    tri_1 : out integer range 0 to 255;
    tri_2 : out integer range 256 to 511;
    tri_3 : out integer range 512 to 767;
    tri_4 : out integer range 768 to 1023
);
end entity;

architecture rtl of portadora is
    -- Sinais internos substituem a necessidade do 'buffer'.
	 -- Mas se preferir utilizar o buffer, tudo tranquilo. Fiz assim para ficar mais fácil de entender.
    signal count_1 : integer range 0 to 255   := 0;
    signal count_2 : integer range 256 to 511 := 256;
    signal count_3 : integer range 512 to 767 := 512;
    signal count_4 : integer range 768 to 1023:= 768;
    
    signal flag    : std_logic := '0';
begin

    process(clk, rst)
    begin
        if rst = '1' then
            -- Condição inicial segura. Esse pino de reset pode ser uma chave do kit.
            count_1 <= 0;
            count_2 <= 256;
            count_3 <= 512;
            count_4 <= 768;
            flag    <= '0';
            
        elsif rising_edge(clk) then
            if flag = '0' then
                -- Otimização: Testa apenas um sinal para economizar portas lógicas
					 -- Observação: Você pode criar uma condição com "and" aninhados se quiser, mas
					 -- não vi necessidade.
                if count_1 = 255 then 
                    flag <= '1';
                    count_1 <= count_1 - 1;
                    count_2 <= count_2 - 1;
                    count_3 <= count_3 - 1;
                    count_4 <= count_4 - 1;
                else
                    count_1 <= count_1 + 1;
                    count_2 <= count_2 + 1;
                    count_3 <= count_3 + 1;
                    count_4 <= count_4 + 1;
                end if;
            else
                -- Otimização: Testa apenas a base
                if count_1 = 0 then
                    flag <= '0';
                    count_1 <= count_1 + 1;
                    count_2 <= count_2 + 1;
                    count_3 <= count_3 + 1;
                    count_4 <= count_4 + 1;
                else
                    count_1 <= count_1 - 1;
                    count_2 <= count_2 - 1;
                    count_3 <= count_3 - 1;
                    count_4 <= count_4 - 1;
                end if;
            end if;
        end if;
    end process;

    -- Atribuição contínua dos sinais internos para as portas de saída
    tri_1 <= count_1;
    tri_2 <= count_2;
    tri_3 <= count_3;
    tri_4 <= count_4;
end architecture;