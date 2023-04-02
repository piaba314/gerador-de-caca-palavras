#!/usr/bin/env python3

import random
import drawsvg

def letra_aleatoria():
    "Retorna uma letra aleatória de A a Z."
    return chr(random.randint(65, 90))

def grade_vazia(linhas, colunas):
    "Retorna uma grade de formada por espaços vazios."
    return [[" " for _ in range(colunas)] for __ in range(linhas)]

def mostra_grade(grade):
    "Imprime a grade na saida padrão."
    for linha in grade:
        print(" ".join(linha))

def preenche_espacos_vazios(grade):
    "Preenche os espaços vazios de uma grade com letras aleatórias."
    for i in range(len(grade)):
        for j in range(len(grade[0])):
            if grade[i][j] == " ":
                grade[i][j] = letra_aleatoria()
    return grade

# lista de direções possíveis
direcoes = ["horizontal", "vertical", "diagonal"]

# descolamentos associados a cada direção 
direcoes_deslocamentos = {
    "horizontal": (0, 1),
    "vertical": (1, 0),
    "diagonal": (1, 1)
}

def insere_palavra(palavra, grade, linha, coluna, direcao):
    "Insere uma palavra na grade na posição e direção dadas"
    dlinha, dcoluna = direcoes_deslocamentos[direcao]
    for letra in palavra.upper():
        grade[linha][coluna] = letra
        linha += dlinha
        coluna += dcoluna

def eh_possivel_inserir(palavra, grade, linha, coluna, direcao):
    "Verifica se é possivel inserir palavra na grade na posição e direção dadas."
    dlinha, dcoluna = direcoes_deslocamentos[direcao]
    flinha = linha + (len(palavra) - 1) * dlinha
    fcoluna = coluna + (len(palavra) - 1) * dcoluna
    # verifica se a palavra sai da grade
    if flinha < 0 or flinha >= len(grade) or fcoluna < 0 or fcoluna >= len(grade[0]):
        return False

    # verifica se a inserção da palavra pode apagar uma palavra que já existe
    for letra in palavra.upper():
        if not grade[linha][coluna] in (" ", letra):
            return False
        linha += dlinha
        coluna += dcoluna

    return True

def primeira_posicao_e_direcao_validas(palavra, grade):
    """Retorna a primeira posição e direção em que a palavra pode ser inserida na grade.
    A função pode ser usada para verificar se uma palavra pode se inserida na grade ou
    para encontrar a palavra numa grade já preenchida."""
    for linha in range(len(grade)):
        for coluna in range(len(grade[0])):
            for direcao in direcoes:
                if eh_possivel_inserir(palavra, grade, linha, coluna, direcao):
                    return {"linha": linha, "coluna": coluna, "direcao": direcao}
    return False

def gera_caca_palavras(palavras, linhas, colunas, direcoes):
    "Retorna um novo caça palavras."
    grade = grade_vazia(linhas, colunas)
    for palavra in palavras:
        while True:
            linha, coluna = random.randrange(linhas), random.randrange(colunas)
            direcao = random.choice(direcoes)
            if eh_possivel_inserir(palavra, grade, linha, coluna, direcao):
                insere_palavra(palavra, grade, linha, coluna, direcao)
                break
    preenche_espacos_vazios(grade)
    return grade

def resolve_caca_palavras(palavras, grade, direcoes):
    "Resolve o caça palavras."
    return {palavra: primeira_posicao_e_direcao_validas(palavra, grade) for palavra in palavras}

def grade_para_svg(grade, nome_do_arquivo, largura=400, altura=400):
    "Salva o caça-palavras como uma imagem svg."
    desenho = drawsvg.Drawing(largura, altura, origin=(0, 0))
    lado = min(largura / len(grade[0]), altura / len(grade))
    for i in range(len(grade)):
        for j in range(len(grade[0])):
            x = lado / 2 + j * lado
            y = lado / 2 + i * lado
            desenho.append(drawsvg.Text(grade[i][j], 16, x, y, text_anchor="middle", dominant_baseline="middle"))
    desenho.save_svg(nome_do_arquivo)
