-- Bloco para a Senoide (moduladora)
--
-- Especificações:
-- f = 60 hz
-- resolução = 10 bits
--
-- Qual a ideia ? A ideia é comparar cada triangular com a senoide. Como a senoide
-- tem 10 bits e cada triangular tem 8 bits, vamos comparar cada um quarto de parte
-- da senoide com uma triangular. Assim formando quatro PWMs diferentes.
--
-- Mas como realmente. Bom, como a senoide tem 10 bits, isso gera um intervalo numérico de 0 a 1023, logo 1024 intervalos.
-- Cada triangular tem um intervalo numérico de 0 a 255, logo 256 intervalos.
-- Como explicado no código que produziu as quatro triangulares, cada triangular tem um offset associado.
-- Logo teremos 4 comparações diferentes entre as portadoras e a moduladora.
--
-- Um detalhe interessante é que, como o número 0 representa o offset de -2 Vdc, então a senoidal terá o seu
-- eixo zero no 512. Por isso ela vai iniciar com 512.
--
-- Isso seria para um inveror de 4 níveis.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity senoide is port
(
    clk : in  std_logic; -- Ligar no clk_out de 10 MHz do Divisor
    rst : in  std_logic; -- Reset do sistema
    sen : out integer range 0 to 1023 := 512
);
end entity;

architecture rtl of senoide is

    -- Memória ROM (LUT) de 32 pontos para a senoide
    type rom_type is array (0 to 31) of integer range 0 to 1023;
    
    constant SINE_LUT : rom_type := (
        512, 612, 708, 796, 873, 937, 984, 1013, 
        1023, 1013, 984, 937, 873, 796, 708, 612, 
        512, 412, 316, 228, 151,  87,  40,  11, 
          1,  11,  40,  87, 151, 228, 316, 412
    );

    -- Acumulador de Fase (DDS) de 32 bits
    signal phase_acc : unsigned(31 downto 0) := (others => '0');

    -- Passo para 60 Hz usando clock de 10 MHz
    -- constant PASSO : unsigned(31 downto 0) := to_unsigned(25770, 32);
	 
	 -- Passo para uma frequência maior usando um clock de teste no main.
	 -- Essa linha serve apenas para que a senoide seja vista no simulador de um melhor forma.
	 -- Se for ver no osciloscópio, comente a linha a baixo e use a linha de cima.
	 constant PASSO : unsigned(31 downto 0) := to_unsigned(858993, 32);

    signal lut_index : integer range 0 to 31;

begin

    process(clk, rst)
    begin
        if rst = '1' then
            phase_acc <= (others => '0');
        elsif rising_edge(clk) then
            phase_acc <= phase_acc + PASSO;
        end if;
    end process;

    -- Extrai os 5 bits mais significativos para varrer a LUT de 32 posições
    lut_index <= to_integer(phase_acc(31 downto 27));

    sen <= SINE_LUT(lut_index);

end architecture;