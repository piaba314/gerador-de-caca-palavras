(defun letra-aleatoria ()
  "Retorna uma letra aleatória de A a Z."
  (code-char (+ 65 (random 26))))

(defun grade-vazia (linhas colunas)
  "Retorna uma grade vazia dados o número de linhas e de colunas."
  (make-array (list linhas colunas) :initial-element #\space))

(defun preenche-espacos-vazios (grade)
  "Preenche os espaços vazios da grade com letras aleatórias."
  (loop for i from 0 below (array-dimension grade 0) do
    (loop for j from 0 below (array-dimension grade 1) do
      (when (eq (aref grade i j) #\space)
        (setf (aref grade i j) (letra-aleatoria))))))

(defparameter *direcoes* '(horizontal vertical diagonal)
  "Direções em que uma palavra pode aparecer na grade.")

(defparameter *direcoes-deslocamentos* '((horizontal (0 1))
                                         (vertical (1 0))
                                         (diagonal (1 1))))

(defun insere-palavra (palavra grade linha coluna direcao)
  "Insere a palavra na grade na posição e direção dadas."
  (let ((palavra (string-upcase palavra)))
    (destructuring-bind (dlinha dcoluna) (cadr (assoc direcao *direcoes-deslocamentos*))
      (loop for i from 0 below (length palavra) do
        (setf (aref grade linha coluna) (aref palavra i))
        (setq linha (+ linha dlinha))
        (setq coluna (+ coluna dcoluna))))))

(defun mostra-grade (grade)
  "Imprime a grade na saida padrão."
  (loop for i from 0 below (array-dimension grade 0) do
        (loop for j from 0 below (array-dimension grade 1) do
          (format t "~c " (aref grade i j)))
        (format t "~%")))

(defun possivel-inserir-p (palavra grade linha coluna direcao)
  "Verifica se é possível inserir a palavra na grade na posição e direção dadas."
  (and (cabe-na-grade-p palavra grade linha coluna direcao)
       (not (apaga-letras-p palavra grade linha coluna direcao))))

(defun cabe-na-grade-p (palavra grade linha coluna direcao)
  "Verifica se a palavra não sai da grade."
  (destructuring-bind (dlinha dcoluna) (cadr (assoc direcao *direcoes-deslocamentos*))
    (let ((flinha (+ linha (* (- (length palavra) 1) dlinha)))
          (fcoluna (+ coluna (* (- (length palavra) 1) dcoluna))))
      (and (>= flinha 0) (< flinha (array-dimension grade 0))
           (>= fcoluna 0) (< fcoluna (array-dimension grade 1))))))

(defun apaga-letras-p (palavra grade linha coluna direcao)
  "Verifica se a palavra apaga letras que já existiam na grade."
  (let ((palavra (string-upcase palavra)))
    (destructuring-bind (dlinha dcoluna) (cadr (assoc direcao *direcoes-deslocamentos*))
      (loop for i from 0 below (length palavra) do
        (when (not (member (aref grade linha coluna)
                           (list #\space (aref palavra i))))
          (return-from apaga-letras-p t))
        (setq linha (+ linha dlinha))
        (setq coluna (+ coluna dcoluna)))
      nil)))

(defun primeira-posicao-direcao-possivel (palavra grade direcoes)
  "Retorna a primeira posição e direção possível onde é possível inserira palavra.
   Pode ser usada para verificar se é possível inserir a palavra na grade e para encontrar
   a palavra na grade."
  (let ((palavra (string-upcase palavra)))
    (loop for i from 0 below (array-dimension grade 0) do
      (loop for j from 0 below (array-dimension grade 1) do
        (loop for direcao in direcoes do
          (when (possivel-inserir-p palavra grade i j direcao)
            (return-from primeira-posicao-direcao-possivel
              (list :linha i :coluna j :direcao direcao)))))))
  nil)

(defun cria-caca-palavra (palavras linhas colunas direcoes)
  "Cria um caça-palavras com as palavras e dimensões dadas."
  (let ((grade (grade-vazia linhas colunas)))
    (loop for palavra in palavras do
          (loop
                (let ((linha (random linhas))
                      (coluna (random colunas))
                      (direcao (escolha direcoes)))
                  (when (possivel-inserir-p palavra grade linha coluna direcao)
                    (insere-palavra palavra grade linha coluna direcao)
                    (return)))))
    (preenche-espacos-vazios grade)
    grade))

(defun escolha (lst)
  "Retorna uma elemento aletório de uma lista."
  (elt lst (random (length lst))))

(defun resolve-caca-palavras (palavras grade direcoes)
  "Encontra palavras na grade."
  (loop for palavra in palavras
        collect (list palavra (primeira-posicao-direcao-possivel palavra grade direcoes))))

(defun grade-para-svg (grade nome-do-arquivo &optional (largura 400) (altura 400))
  "Uma solução adhoc para salvar o caça-palavras como uma imagem svg."
  (with-open-file (f nome-do-arquivo :direction :output
                                     :if-exists :supersede
                                     :if-does-not-exist :create)
    (format f "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\"
     width=\"~d\" height=\"~d\" viewBox=\"0 0 ~d ~d\">~%
" largura altura largura altura)
    (let ((lado (min (/ largura (array-dimension grade 1))
                     (/ altura (array-dimension grade 0)))))
      (loop for i from 0 below (array-dimension grade 0) do
        (loop for j from 0 below (array-dimension grade 1) do
          (let ((x (+ (/ lado 2) (* j lado)))
                (y (+ (/ lado 2) (* i lado))))
            (format f "<text x=\"~d\" y=\"~d\" font-size=\"16\" text-anchor=\"middle\" dominant-baseline=\"middle\">~c</text>~%"
                    x y (aref grade i j))))))
    (format f "</svg>")))
