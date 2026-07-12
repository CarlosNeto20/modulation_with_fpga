-- Bloco PWM
--
-- Um vez criado os blocos para a portadora triangular e para a moduladora senoidal,
-- o último passo é criar o bloco para realizar as comparações entre portadora e moduladora, e com isso
-- gerar o sinal PWM.
--
-- Modificação atual: Implementação de Amostragem Regular (Regular Sampling).
-- A senoide é "congelada" nos topos e fundos da onda triangular para evitar glitches
-- de múltiplas comutações durante o cruzamento.
--
-- A condição desta comparação é bem simples:
-- triangular <= senoide entao pwm <= '1'
-- triangular > senoide entao pwm <= '0'

library ieee;
use ieee.std_logic_1164.all;

entity pwm is port
(
	-- Clock de sincronismo para as ações de comparação
	clk : in std_logic;

	-- Recebendo o sinal senoidal
	sen : in integer range 0 to 1023;

	-- Recebendo os sinais das triangulares
	tri_1 : in integer range 0 to 255;
	tri_2 : in integer range 256 to 511;
	tri_3 : in integer range 512 to 767;
	tri_4 : in integer range 768 to 1023;
	
	-- Sinais PWM como saidas
	pwm_1 : out std_logic;
	pwm_2 : out std_logic;
	pwm_3 : out std_logic;
	pwm_4 : out std_logic
);
end entity;

architecture rtl of pwm is
	
	-- Sinal interno para guardar o valor congelado da senoide
	signal sen_amostrado : integer range 0 to 1023 := 512;

begin
	process(clk)
	begin
		if rising_edge(clk) then
			
			-- AMOSTRAGEM REGULAR:
			-- Captura o valor atual da senoide apenas quando a triangular da base 
			-- atinge o seu limite inferior (0) ou superior (255).
			-- Como todas as 4 triangulares estão em fase, checar apenas a tri_1 é suficiente.
			if (tri_1 = 0 or tri_1 = 255) then
				sen_amostrado <= sen;
			end if;

			-- COMPARAÇÕES:
			-- Agora utilizamos o "sen_amostrado" (que fica estável durante a descida ou subida da rampa)
			-- em vez do "sen" original. Isso elimina completamente os glitches.
			
			if (sen_amostrado >= tri_1) then
				pwm_1 <= '1';
			else
				pwm_1 <= '0';
			end if;

			if (sen_amostrado >= tri_2) then
				pwm_2 <= '1';
			else
				pwm_2 <= '0';
			end if;

			if (sen_amostrado >= tri_3) then
				pwm_3 <= '1';
			else
				pwm_3 <= '0';
			end if;

			if (sen_amostrado >= tri_4) then
				pwm_4 <= '1';
			else
				pwm_4 <= '0';
			end if;

		end if;
	end process;
end architecture;