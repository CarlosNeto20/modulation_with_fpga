import math

def gerar_tabela_senoide_vhdl(num_pontos):
    """
    Gera uma tabela LUT (Look-Up Table) de uma senoide formatada em VHDL.
    
    Quantidade de pontos da tabela geralmente nos valores: 32, 64, 128, 256, etc.
    """
    # Configurações da escala de 10 bits
    offset = 512
    amplitude = 511
    valores_por_linha = 16
    
    lut = []
    
    # Calcula cada ponto da senoide
    for i in range(num_pontos):
        # Converte o índice atual em um ângulo em radianos (0 a 2*PI)
        angulo = (2 * math.pi * i) / num_pontos
        
        # Calcula o valor senoidal, aplica offset/amplitude e arredonda
        valor = round(offset + amplitude * math.sin(angulo))
        
        # Limitações de segurança para garantir que caiba em 10 bits (0 a 1023)
        if valor > 1023:
            valor = 1023
        elif valor < 0:
            valor = 0
            
        lut.append(valor)
        
    # Início da impressão do código VHDL formatado
    print(f"-- Tabela LUT gerada para {num_pontos} pontos")
    print(f"type rom_type is array (0 to {num_pontos - 1}) of integer range 0 to 1023;\n")
    print("constant SINE_LUT : rom_type := (")
    
    # Divide a lista em blocos para imprimir linhas organizadas
    linhas = []
    for i in range(0, num_pontos, valores_por_linha):
        # Pega uma fatia da lista (ex: de 0 a 15)
        bloco = lut[i : i + valores_por_linha]
        
        # Formata cada número para ter um espaçamento alinhado (opcional, mas fica mais bonito no VHDL)
        linha_texto = "    " + ", ".join(f"{v}" for v in bloco)
        linhas.append(linha_texto)
        
    # Junta todas as linhas com uma vírgula e quebra de linha
    print(",\n".join(linhas))
    print(");")

# ==========================================
#              ÁREA DE EXECUÇÃO
# ==========================================
quantidade_de_pontos = 128

gerar_tabela_senoide_vhdl(quantidade_de_pontos)