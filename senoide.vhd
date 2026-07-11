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
    type rom_type is array (0 to 127) of integer range 0 to 1023;
    
    -- Valores calculados para senoide de 0 a 1023 (512 +/- 511)
    constant SINE_LUT : rom_type := (
        512, 537, 562, 587, 612, 637, 661, 685, 708, 731, 753, 775, 796, 816, 836, 855,
        873, 890, 906, 922, 937, 950, 963, 974, 984, 993, 1001, 1007, 1013, 1017, 1020, 1022,
        1023, 1022, 1020, 1017, 1013, 1007, 1001, 993, 984, 974, 963, 950, 937, 922, 906, 890,
        873, 855, 836, 816, 796, 775, 753, 731, 708, 685, 661, 637, 612, 587, 562, 537,
        512, 487, 462, 437, 412, 387, 363, 339, 316, 293, 271, 249, 228, 208, 188, 169,
        151, 134, 118, 102, 87, 74, 61, 50, 40, 31, 23, 17, 11, 7, 4, 2,
        1, 2, 4, 7, 11, 17, 23, 31, 40, 50, 61, 74, 87, 102, 118, 134,
        151, 169, 188, 208, 228, 249, 271, 293, 316, 339, 363, 387, 412, 437, 462, 487
    );

    -- Acumulador de Fase (DDS) de 32 bits
    signal phase_acc : unsigned(31 downto 0) := (others => '0');

    -- Passo para 60 Hz usando clock de 10 MHz
    -- constant PASSO : unsigned(31 downto 0) := to_unsigned(25770, 32);
	 
	 -- Passo para uma frequência maior usando um clock de teste no main.
	 -- Essa linha serve apenas para que a senoide seja vista no simulador de um melhor forma.
	 -- Se for ver no osciloscópio, comente a linha a baixo e use a linha de cima.
	 constant PASSO : unsigned(31 downto 0) := to_unsigned(858993, 32);

    signal lut_index : integer range 0 to 127;

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
    lut_index <= to_integer(phase_acc(31 downto 25));

    sen <= SINE_LUT(lut_index);

end architecture;