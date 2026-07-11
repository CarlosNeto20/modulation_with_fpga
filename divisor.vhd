-- Divisor de Frequência
--
-- Uma vez que o PLL está desenvolvido corretamente, nosso clock de entrada para este divisor está com
-- a frequência definida em 250 MHz.
--
-- Este divisor tem o intuito de dividir esse clock de entrada para uma frequência de 20 kHz. Essa nova 
-- frequência será justamente a frequência do PWM gerado ao final do projeto.
--
-- Quem define, portanto, a frequência do PWM é a frequência da portadora, que neste caso será uma TRIANGULAR.
-- 
-- Agora vamos pensar no problema. Precisamos que a portadora tenha uma frequência de 20 kHz. Como estaremos utilizando
-- uma resolução de 8 bits para cada triangular, logo uma faixa numérica de 0 a 255. Portanto, precisaremos contar 512 pulsos de clock
-- para formar a onda desejada, em que metade (256) serão para a subida e a outra metade (256) dos pulsos para a descida.
--
-- Em resumo, para cada ciclo da triangular precisaremos de 2^9 = 512 pulsos de clock. Então a pergunta que deve ser feita é:
-- Qual deve ser a frequência de entrada no bloco da portadora ?
--
-- Simples:
-- f_port = f_pwm x pulsos
-- f_port = 20 x 1e3 x 512 = 10,24 MHz
--
-- A partir disso podemos definir o número divisor para este bloco da seguinte forma:
-- N = f_pll / f_port = 24,4141
--
-- Se N = 24 implica que f_pwm = 20,3451 kHz
-- Se N = 25 implica que f_pwm = 19,5313 kHz
--
-- CONCLUSÃO: A divisão aplicada ao divisor será de 25.
--
-- EXTRAS POSSÍVEIS:
--
-- Existe uma maneiro de obtermos exatamente a frequência desejada, porém perdendo a resolução da portadora minimamente.
-- Vamos imaginar que nossa resolução não seja de 255, mas sim de 249. Nesse caso teriamos 500 pulsos de contagem, logo:
--
-- f_port = f_pwm x pulsos
-- f_port = 20 x 1e3 x 500 = 10 MHz
-- 
-- N = f_pll / f_port = 25
--
-- Portanto fica a critério do projetista escolher um dos dois caminhos. Nesse nosso caso, será escolhido o caminho de manter a resolução
-- de 8 bits para a portadora triangular. 

library ieee;
use ieee.std_logic_1164.all;

entity divisor is 
generic (
    N : integer := 25 -- Fator de divisão (deve ser um número ímpar para este formato de código)
);
port (
    clk_in  : in  std_logic;
    clk_out : out std_logic
);
end entity;

architecture rtl of divisor is

    -- Sinais internos
    signal contador : integer range 0 to N-1 := 0;
    signal out_r    : std_logic := '0'; -- Sinal da borda de subida (rising)
    signal out_f    : std_logic := '0'; -- Sinal da borda de descida (falling)
    
begin

    -- Processo 1: Lida com o contador e o sinal da borda de subida
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            -- Lógica do contador de 0 até N-1
            if contador = N-1 then
                contador <= 0;
            else
                contador <= contador + 1;
            end if;
            
            -- Lógica do sinal out_r (fica em '1' por N/2 ciclos inteiros)
            -- Em VHDL, a divisão de inteiros (3/2) resulta em 1.
            if contador < (N / 2) then 
                out_r <= '1';
            else
                out_r <= '0';
            end if;
        end if;
    end process;

    -- Processo 2: Lida com a borda de descida para criar o "meio ciclo" de atraso
    process(clk_in)
    begin
        if falling_edge(clk_in) then
            out_f <= out_r; -- Simplesmente atrasa o sinal out_r em 0.5 ciclo de clock
        end if;
    end process;

    -- A saída final é a união (OR) dos dois sinais
    clk_out <= out_r or out_f;

end architecture;