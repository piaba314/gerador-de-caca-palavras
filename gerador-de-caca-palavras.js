function letraAleatoria(){
  return String.fromCharCode(65 + Math.floor(26 * Math.random()));
}

function gradeVazia(linhas, colunas){
  return Array(linhas).fill(0).map(v => Array(colunas).fill(" "));
}

function mostraGrade(grade){
  console.log(grade.map(linha => linha.join(" ")).join("\n"));
}

const direcoes = ["horizontal", "vertical", "diagonal"];
const direcaoParaDeslocamento = {
  "horizontal": [0, 1],
  "vertical": [1, 0],
  "diagonal": [1, 1]
};

function inserePalavra(palavra, grade, linha, coluna, direcao){
  let [dlinha, dcoluna] = direcaoParaDeslocamento[direcao];
  for(let letra of palavra.toUpperCase()){
    grade[linha][coluna] = letra;
    linha += dlinha;
    coluna += dcoluna;
  }
}

function preencheEspacosVazios(grade){
  for (let i = 0; i < grade.length; i++){
    for (let j = 0; j < grade[0].length; j++){
      if (grade[i][j] === " "){
        grade[i][j] = letraAleatoria();
      }
    }
  }
}

function podeInserirPalavra(palavra, grade, linha, coluna, direcao){
  return (
    cabePalavra(palavra, grade, linha, coluna, direcao) &&
    !apagaLetras(palavra, grade, linha, coluna, direcao)
  )
}

function cabePalavra(palavra, grade, linha, coluna, direcao){
  const [dlinha, dcoluna] = direcaoParaDeslocamento[direcao];
  const flinha = linha + (palavra.length - 1) * dlinha;
  const fcoluna = coluna + (palavra.length - 1) * dcoluna;
  return flinha >= 0 && flinha < grade.length && fcoluna >= 0 && fcoluna < grade[0].length;
}

function apagaLetras(palavra, grade, linha, coluna, direcao){
  const [dlinha, dcoluna] = direcaoParaDeslocamento[direcao];
  for(let letra of palavra.toUpperCase()){
    if (![" ", letra].includes(grade[linha][coluna])) return true;
    linha += dlinha;
    coluna += dcoluna;
  }
  return false;
}

function primeiraPosicaoDirecaoPossivel(palavra, grade, direcoes){
  for(let linha = 0; linha < grade.length; linha++){
    for(let coluna = 0; coluna < grade[0].length; coluna++){
      for(let direcao of direcoes){
        if(podeInserirPalavra(palavra, grade, linha, coluna, direcao)){
          return {linha, coluna, direcao}
        }
      }
    }
  }
  return false;
}

function criaCacaPalavras(palavras, linhas, colunas, direcoes){
  const grade = gradeVazia(linhas, colunas);
  for(let palavra of palavras){
    while(true){
      let linha = Math.floor(linhas * Math.random());
      let coluna = Math.floor(colunas * Math.random());
      let direcao = direcoes[Math.floor(direcoes.length * Math.random())];
      if (podeInserirPalavra(palavra, grade, linha, coluna, direcao)){
        inserePalavra(palavra, grade, linha, coluna, direcao);
        break;
      }
    }
  }
  preencheEspacosVazios(grade);
  return grade;
}

function resolveCacaPalavras(palavras, grade, direcoes){
  return palavras.map(palavra => {
    return {palavra, ...primeiraPosicaoDirecaoPossivel(palavra, grade, direcoes)};
  });
}
