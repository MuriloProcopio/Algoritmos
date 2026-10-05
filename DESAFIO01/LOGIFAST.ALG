Algoritmo "LogiFast"
//
//
// Descrição   : Rede de logistica
// Autor(a)    : Murilo Procópio - RA 02010110
// Data atual  : 02/10/2026

Const
   MAX_ENTREGAS = 30
   MAX_REGIOES = 5

   CENTRO = 1
   NORTE = 2
   SUL = 3
   LESTE = 4
   OESTE = 5

   URGENTE = 1
   PRIORITARIA = 2
   NORMAL = 3

   AGUARDANDO = 1
   EM_TRANSPORTE = 2
   ENTREGUE = 3

   VALOR_KM = 2.50

   LIM_PESO1 = 5
   LIM_PESO2 = 20
   LIM_PESO3 = 50

   ACR_PESO1 = 0.10
   ACR_PESO2 = 0.20
   ACR_PESO3 = 0.35

   ACR_PRIORITARIA = 0.15
   ACR_URGENTE = 0.30

Tipo
   TEntrega = registro
      codigo: inteiro
      destinatario: caractere
      origem: inteiro
      destino: inteiro
      peso: real
      valorMercadoria: real
      prioridade: inteiro
      distancia: inteiro
      status: inteiro
      custo: real
   fimregistro

Var
   entregas: vetor[1..MAX_ENTREGAS] de TEntrega
   matrizDist: vetor[1..MAX_REGIOES,1..MAX_REGIOES] de inteiro
   percurso: vetor[1..MAX_REGIOES] de inteiro
   qtdEntregas: inteiro
   opcao: inteiro


funcao nomeRegiao(codigo: inteiro): caractere
var
   nome: caractere
inicio
   escolha codigo
   caso 1
      nome <- "Centro"
   caso 2
      nome <- "Norte"
   caso 3
      nome <- "Sul"
   caso 4
      nome <- "Leste"
   caso 5
      nome <- "Oeste"
   outrocaso
      nome <- "Invalida"
   fimescolha
   retorne nome
fimfuncao


funcao nomePrioridade(codigo: inteiro): caractere
var
   nome: caractere
inicio
   escolha codigo
   caso 1
      nome <- "Urgente"
   caso 2
      nome <- "Prioritaria"
   caso 3
      nome <- "Normal"
   outrocaso
      nome <- "Invalida"
   fimescolha
   retorne nome
fimfuncao


funcao nomeStatus(codigo: inteiro): caractere
var
   nome: caractere
inicio
   escolha codigo
   caso 1
      nome <- "Aguardando"
   caso 2
      nome <- "Em transporte"
   caso 3
      nome <- "Entregue"
   outrocaso
      nome <- "Invalido"
   fimescolha
   retorne nome
fimfuncao


procedimento inicializarMatriz()
inicio
   // Distancias fornecidas na tabela do desafio
   matrizDist[1,1] <- 0
   matrizDist[1,2] <- 12
   matrizDist[1,3] <- 15
   matrizDist[1,4] <- 10
   matrizDist[1,5] <- 14

   matrizDist[2,1] <- 12
   matrizDist[2,2] <- 0
   matrizDist[2,3] <- 25
   matrizDist[2,4] <- 18
   matrizDist[2,5] <- 20

   matrizDist[3,1] <- 15
   matrizDist[3,2] <- 25
   matrizDist[3,3] <- 0
   matrizDist[3,4] <- 16
   matrizDist[3,5] <- 19

   matrizDist[4,1] <- 10
   matrizDist[4,2] <- 18
   matrizDist[4,3] <- 16
   matrizDist[4,4] <- 0
   matrizDist[4,5] <- 22

   matrizDist[5,1] <- 14
   matrizDist[5,2] <- 20
   matrizDist[5,3] <- 19
   matrizDist[5,4] <- 22
   matrizDist[5,5] <- 0
fimprocedimento


funcao localizarEntrega(cod: inteiro; quantidade: inteiro): inteiro
var
   i: inteiro
   posi: inteiro
inicio
   i <- 1
   posi <- 0

   // Percorre somente as entregas realmente cadastradas
   enquanto i <= quantidade faca
      se entregas[i].codigo = cod entao
         posi <- i
      fimse
      i <- i + 1
   fimenquanto

   // Zero indica que nenhuma entrega foi encontrada
   retorne posi
fimfuncao


funcao calcularCusto(dist: inteiro; pesoCarga: real; pri: inteiro): real
var
   custoBase: real
   percentual: real
inicio
   custoBase <- dist * VALOR_KM
   percentual <- 0

   // Define o acrescimo conforme o peso
   se pesoCarga > LIM_PESO3 entao
      percentual <- percentual + ACR_PESO3
   senao
      se pesoCarga > LIM_PESO2 entao
         percentual <- percentual + ACR_PESO2
      senao
         se pesoCarga > LIM_PESO1 entao
            percentual <- percentual + ACR_PESO1
         fimse
      fimse
   fimse

   // Define o acrescimo conforme a prioridade
   se pri = URGENTE entao
      percentual <- percentual + ACR_URGENTE
   senao
      se pri = PRIORITARIA entao
         percentual <- percentual + ACR_PRIORITARIA
      fimse
   fimse

   retorne custoBase * (1 + percentual)
fimfuncao


procedimento exibirEntrega(ind: inteiro)
inicio
   escreval("----------------------------------------")
   escreval("Codigo: ",entregas[ind].codigo)
   escreval("Destinatario: ",entregas[ind].destinatario)
   escreval("Origem: ",nomeRegiao(entregas[ind].origem))
   escreval("Destino: ",nomeRegiao(entregas[ind].destino))
   escreval("Peso: ",entregas[ind].peso," kg")
   escreval("Valor da mercadoria: R$ ",entregas[ind].valorMercadoria)
   escreval("Prioridade: ",nomePrioridade(entregas[ind].prioridade))
   escreval("Distancia: ",entregas[ind].distancia," km")
   escreval("Status: ",nomeStatus(entregas[ind].status))
   escreval("Custo estimado: R$ ",entregas[ind].custo)
fimprocedimento


procedimento cadastrarEntrega()
var
   cod: inteiro
   dest: caractere
   origemCad: inteiro
   destinoCad: inteiro
   pri: inteiro
   posi: inteiro
   pesoCad: real
   valorCad: real
inicio
   se qtdEntregas >= MAX_ENTREGAS entao
      escreval("ERRO: capacidade maxima de entregas atingida.")
   senao
      posi <- 0

      repita
         escreva("Codigo da entrega: ")
         leia(cod)

         se cod <= 0 entao
            escreval("ERRO: o codigo deve ser maior que zero.")
            posi <- -1
         senao
            // Verifica se o codigo informado ja existe
            posi <- localizarEntrega(cod,qtdEntregas)
            se posi <> 0 entao
               escreval("ERRO: codigo ja cadastrado.")
            fimse
         fimse
      ate (cod > 0) e (posi = 0)

      escreva("Nome ou descricao do destinatario: ")
      leia(dest)

      repita
         escreval("Regioes: 1-Centro 2-Norte 3-Sul 4-Leste 5-Oeste")
         escreva("Regiao de origem: ")
         leia(origemCad)

         se (origemCad < 1) ou (origemCad > MAX_REGIOES) entao
            escreval("ERRO: origem inexistente.")
         fimse
      ate (origemCad >= 1) e (origemCad <= MAX_REGIOES)

      repita
         escreva("Regiao de destino: ")
         leia(destinoCad)

         se (destinoCad < 1) ou (destinoCad > MAX_REGIOES) entao
            escreval("ERRO: destino inexistente.")
         senao
            se destinoCad = origemCad entao
               escreval("ERRO: origem e destino devem ser diferentes.")
            fimse
         fimse
      ate (destinoCad >= 1) e (destinoCad <= MAX_REGIOES) e (destinoCad <> origemCad)

      repita
         escreva("Peso da carga em kg: ")
         leia(pesoCad)

         se pesoCad <= 0 entao
            escreval("ERRO: o peso deve ser maior que zero.")
         fimse
      ate pesoCad > 0

      repita
         escreva("Valor da mercadoria: R$ ")
         leia(valorCad)

         se valorCad < 0 entao
            escreval("ERRO: o valor da mercadoria nao pode ser negativo.")
         fimse
      ate valorCad >= 0

      repita
         escreval("Prioridade: 1-Urgente 2-Prioritaria 3-Normal")
         escreva("Informe a prioridade: ")
         leia(pri)

         se (pri < URGENTE) ou (pri > NORMAL) entao
            escreval("ERRO: prioridade inexistente.")
         fimse
      ate (pri >= URGENTE) e (pri <= NORMAL)

      // Cria uma nova posicao no vetor de entregas
      qtdEntregas <- qtdEntregas + 1

      entregas[qtdEntregas].codigo <- cod
      entregas[qtdEntregas].destinatario <- dest
      entregas[qtdEntregas].origem <- origemCad
      entregas[qtdEntregas].destino <- destinoCad
      entregas[qtdEntregas].peso <- pesoCad
      entregas[qtdEntregas].valorMercadoria <- valorCad
      entregas[qtdEntregas].prioridade <- pri

      // Distancia obtida automaticamente pela matriz
      entregas[qtdEntregas].distancia <- matrizDist[origemCad,destinoCad]

      // Toda nova entrega inicia aguardando
      entregas[qtdEntregas].status <- AGUARDANDO

      // Calcula automaticamente o custo
      entregas[qtdEntregas].custo <- calcularCusto(entregas[qtdEntregas].distancia,pesoCad,pri)

      escreval("Entrega cadastrada com sucesso.")
      escreval("Codigo cadastrado: ",entregas[qtdEntregas].codigo)
      escreval("Total de entregas cadastradas: ",qtdEntregas)
      escreval("Distancia calculada: ",entregas[qtdEntregas].distancia," km")
      escreval("Custo estimado: R$ ",entregas[qtdEntregas].custo)
   fimse
fimprocedimento


procedimento listarEntregas()
var
   i: inteiro
inicio
   se qtdEntregas = 0 entao
      escreval("Nenhuma entrega cadastrada.")
   senao
      escreval("========== ENTREGAS CADASTRADAS ==========")

      para i de 1 ate qtdEntregas faca
         exibirEntrega(i)
      fimpara

      escreval("----------------------------------------")
   fimse
fimprocedimento


procedimento consultarEntrega()
var
   cod: inteiro
   posi: inteiro
inicio
   se qtdEntregas = 0 entao
      escreval("Nenhuma entrega cadastrada.")
   senao
      escreva("Digite o codigo da entrega: ")
      leia(cod)

      // Localiza a posicao do codigo dentro do vetor
      posi <- localizarEntrega(cod,qtdEntregas)

      se posi = 0 entao
         escreval("Entrega nao encontrada.")
      senao
         exibirEntrega(posi)
      fimse
   fimse
fimprocedimento


procedimento exibirFilaDespacho()
var
   fila: vetor[1..MAX_ENTREGAS] de TEntrega
   aux: TEntrega
   qtdFila: inteiro
   i: inteiro
   j: inteiro
   trocar: logico
inicio
   qtdFila <- 0

   // Coloca na fila somente entregas aguardando
   para i de 1 ate qtdEntregas faca
      se entregas[i].status = AGUARDANDO entao
         qtdFila <- qtdFila + 1
         fila[qtdFila] <- entregas[i]
      fimse
   fimpara

   se qtdFila = 0 entao
      escreval("Nao existem entregas aguardando despacho.")
   senao
      se qtdFila > 1 entao

         // Bubble Sort aplicado ao vetor de registros
         para i de 1 ate qtdFila - 1 faca
            para j de 1 ate qtdFila - i faca
               trocar <- falso

               // 1 criterio: prioridade
               se fila[j].prioridade > fila[j+1].prioridade entao
                  trocar <- verdadeiro
               senao
                  se fila[j].prioridade = fila[j+1].prioridade entao

                     // 2 criterio: maior valor da mercadoria
                     se fila[j].valorMercadoria < fila[j+1].valorMercadoria entao
                        trocar <- verdadeiro
                     senao
                        se fila[j].valorMercadoria = fila[j+1].valorMercadoria entao

                           // 3 criterio: maior peso
                           se fila[j].peso < fila[j+1].peso entao
                              trocar <- verdadeiro
                           senao
                              se fila[j].peso = fila[j+1].peso entao

                                 // 4 criterio: menor codigo
                                 se fila[j].codigo > fila[j+1].codigo entao
                                    trocar <- verdadeiro
                                 fimse
                              fimse
                           fimse
                        fimse
                     fimse
                  fimse
               fimse

               se trocar entao
                  // Troca o registro completo
                  aux <- fila[j]
                  fila[j] <- fila[j+1]
                  fila[j+1] <- aux
               fimse
            fimpara
         fimpara
      fimse

      escreval("========== FILA DE DESPACHO ==========")

      para i de 1 ate qtdFila faca
         escreval(i," - Codigo: ",fila[i].codigo)
         escreval("Prioridade: ",nomePrioridade(fila[i].prioridade))
         escreval("Valor: R$ ",fila[i].valorMercadoria)
         escreval("Peso: ",fila[i].peso," kg")
      fimpara
   fimse
fimprocedimento


procedimento iniciarTransporte()
var
   cod: inteiro
   posi: inteiro
inicio
   se qtdEntregas = 0 entao
      escreval("Nenhuma entrega cadastrada.")
   senao
      escreva("Codigo da entrega para iniciar transporte: ")
      leia(cod)

      posi <- localizarEntrega(cod,qtdEntregas)

      se posi = 0 entao
         escreval("Entrega nao encontrada.")
      senao

         // Apenas AGUARDANDO pode passar para EM TRANSPORTE
         se entregas[posi].status = AGUARDANDO entao
            entregas[posi].status <- EM_TRANSPORTE
            escreval("Transporte iniciado com sucesso.")
         senao
            se entregas[posi].status = EM_TRANSPORTE entao
               escreval("ERRO: esta entrega ja esta em transporte.")
            senao
               escreval("ERRO: entrega ja concluida.")
            fimse
         fimse
      fimse
   fimse
fimprocedimento


procedimento finalizarEntrega()
var
   cod: inteiro
   posi: inteiro
inicio
   se qtdEntregas = 0 entao
      escreval("Nenhuma entrega cadastrada.")
   senao
      escreva("Codigo da entrega para finalizar: ")
      leia(cod)

      posi <- localizarEntrega(cod,qtdEntregas)

      se posi = 0 entao
         escreval("Entrega nao encontrada.")
      senao

         // Apenas EM TRANSPORTE pode passar para ENTREGUE
         se entregas[posi].status = EM_TRANSPORTE entao
            entregas[posi].status <- ENTREGUE
            escreval("Entrega finalizada com sucesso.")
         senao
            se entregas[posi].status = AGUARDANDO entao
               escreval("ERRO: a entrega ainda esta aguardando transporte.")
            senao
               escreval("ERRO: esta entrega ja foi finalizada.")
            fimse
         fimse
      fimse
   fimse
fimprocedimento


procedimento exibirMatriz()
var
   i: inteiro
   j: inteiro
   maiorDist: inteiro
   menorDist: inteiro
   somaDist: inteiro
   contDist: inteiro
   mediaDist: real
inicio
   maiorDist <- 0
   menorDist <- 999999
   somaDist <- 0
   contDist <- 0

   escreval("========== MATRIZ DE DISTANCIAS ==========")
   escreval("      Centro Norte Sul Leste Oeste")

   // Dois lacos percorrem linhas e colunas da matriz
   para i de 1 ate MAX_REGIOES faca
      escreva(i," -> ")

      para j de 1 ate MAX_REGIOES faca
         escreva(matrizDist[i,j]:5)

         // A diagonal principal nao participa dos calculos
         se i <> j entao
            somaDist <- somaDist + matrizDist[i,j]
            contDist <- contDist + 1

            se matrizDist[i,j] > maiorDist entao
               maiorDist <- matrizDist[i,j]
            fimse

            se matrizDist[i,j] < menorDist entao
               menorDist <- matrizDist[i,j]
            fimse
         fimse
      fimpara

      escreval("  ",nomeRegiao(i))
   fimpara

   mediaDist <- somaDist / contDist

   escreval("Maior distancia: ",maiorDist," km")
   escreval("Menor distancia diferente de zero: ",menorDist," km")
   escreval("Media das distancias: ",mediaDist," km")
fimprocedimento


procedimento exibirEstatisticas()
var
   i: inteiro
   qtdAguardando: inteiro
   qtdTransporte: inteiro
   qtdEntregue: inteiro
   qtdUrgente: inteiro
   qtdPrioritaria: inteiro
   qtdNormal: inteiro
   contRegiao: vetor[1..MAX_REGIOES] de inteiro
   regiaoMais: inteiro
   maiorQtdRegiao: inteiro
   indMaiorValor: inteiro
   indMaiorPeso: inteiro
   indMaiorDist: inteiro
   pesoTotal: real
   valorTotal: real
   custoTotal: real
   mediaPeso: real
   mediaValor: real
   mediaCusto: real
inicio
   se qtdEntregas = 0 entao
      escreval("Nao existem entregas cadastradas para gerar estatisticas.")
   senao
      qtdAguardando <- 0
      qtdTransporte <- 0
      qtdEntregue <- 0

      qtdUrgente <- 0
      qtdPrioritaria <- 0
      qtdNormal <- 0

      pesoTotal <- 0
      valorTotal <- 0
      custoTotal <- 0

      para i de 1 ate MAX_REGIOES faca
         contRegiao[i] <- 0
      fimpara

      indMaiorValor <- 1
      indMaiorPeso <- 1
      indMaiorDist <- 1

      // Percorre as entregas usando contadores e acumuladores
      para i de 1 ate qtdEntregas faca

         se entregas[i].status = AGUARDANDO entao
            qtdAguardando <- qtdAguardando + 1
         senao
            se entregas[i].status = EM_TRANSPORTE entao
               qtdTransporte <- qtdTransporte + 1
            senao
               qtdEntregue <- qtdEntregue + 1
            fimse
         fimse

         se entregas[i].prioridade = URGENTE entao
            qtdUrgente <- qtdUrgente + 1
         senao
            se entregas[i].prioridade = PRIORITARIA entao
               qtdPrioritaria <- qtdPrioritaria + 1
            senao
               qtdNormal <- qtdNormal + 1
            fimse
         fimse

         pesoTotal <- pesoTotal + entregas[i].peso
         valorTotal <- valorTotal + entregas[i].valorMercadoria
         custoTotal <- custoTotal + entregas[i].custo

         // Conta quantas entregas cada regiao recebeu
         contRegiao[entregas[i].destino] <- contRegiao[entregas[i].destino] + 1

         se entregas[i].valorMercadoria > entregas[indMaiorValor].valorMercadoria entao
            indMaiorValor <- i
         fimse

         se entregas[i].peso > entregas[indMaiorPeso].peso entao
            indMaiorPeso <- i
         fimse

         se entregas[i].distancia > entregas[indMaiorDist].distancia entao
            indMaiorDist <- i
         fimse
      fimpara

      mediaPeso <- pesoTotal / qtdEntregas
      mediaValor <- valorTotal / qtdEntregas
      mediaCusto <- custoTotal / qtdEntregas

      regiaoMais <- 1
      maiorQtdRegiao <- contRegiao[1]

      para i de 2 ate MAX_REGIOES faca
         se contRegiao[i] > maiorQtdRegiao entao
            maiorQtdRegiao <- contRegiao[i]
            regiaoMais <- i
         fimse
      fimpara

      escreval("========== ESTATISTICAS ==========")
      escreval("Quantidade total: ",qtdEntregas)
      escreval("Aguardando: ",qtdAguardando)
      escreval("Em transporte: ",qtdTransporte)
      escreval("Entregues: ",qtdEntregue)

      escreval("Urgentes: ",qtdUrgente)
      escreval("Prioritarias: ",qtdPrioritaria)
      escreval("Normais: ",qtdNormal)

      escreval("Peso total: ",pesoTotal," kg")
      escreval("Media de peso: ",mediaPeso," kg")

      escreval("Valor total das mercadorias: R$ ",valorTotal)
      escreval("Valor medio: R$ ",mediaValor)

      escreval("Custo total estimado: R$ ",custoTotal)
      escreval("Custo medio: R$ ",mediaCusto)

      escreval("Entrega de maior valor: ",entregas[indMaiorValor].codigo)
      escreval("Valor: R$ ",entregas[indMaiorValor].valorMercadoria)

      escreval("Entrega de maior peso: ",entregas[indMaiorPeso].codigo)
      escreval("Peso: ",entregas[indMaiorPeso].peso," kg")

      escreval("Entrega de maior distancia: ",entregas[indMaiorDist].codigo)
      escreval("Distancia: ",entregas[indMaiorDist].distancia," km")

      escreval("Regiao que mais recebeu entregas: ",nomeRegiao(regiaoMais))
      escreval("Quantidade: ",maiorQtdRegiao)
   fimse
fimprocedimento


funcao calcularPercursoRecursivo(posicao: inteiro; tamanho: inteiro): inteiro
inicio
   // Caso-base: chegou na ultima regiao do percurso
   se posicao >= tamanho entao
      retorne 0
   senao

      // Soma o trecho atual com o restante calculado recursivamente
      retorne matrizDist[percurso[posicao],percurso[posicao+1]] + calcularPercursoRecursivo(posicao+1,tamanho)
   fimse
fimfuncao


procedimento calcularPercurso()
var
   tamanho: inteiro
   i: inteiro
   distanciaTotal: inteiro
   valido: logico
inicio
   repita
      escreva("Quantidade de regioes do percurso (2 a 5): ")
      leia(tamanho)

      se (tamanho < 2) ou (tamanho > MAX_REGIOES) entao
         escreval("ERRO: informe uma quantidade entre 2 e 5.")
      fimse
   ate (tamanho >= 2) e (tamanho <= MAX_REGIOES)

   escreval("1-Centro 2-Norte 3-Sul 4-Leste 5-Oeste")

   para i de 1 ate tamanho faca
      repita
         valido <- verdadeiro

         escreva("Regiao da posicao ",i,": ")
         leia(percurso[i])

         se (percurso[i] < 1) ou (percurso[i] > MAX_REGIOES) entao
            escreval("ERRO: regiao inexistente.")
            valido <- falso
         senao
            se i > 1 entao

               // Impede duas regioes consecutivas iguais
               se percurso[i] = percurso[i-1] entao
                  escreval("ERRO: regioes consecutivas devem ser diferentes.")
                  valido <- falso
               fimse
            fimse
         fimse
      ate valido
   fimpara

   // Inicia o calculo recursivo pela primeira posicao
   distanciaTotal <- calcularPercursoRecursivo(1,tamanho)

   escreval("Distancia total do percurso: ",distanciaTotal," km")
fimprocedimento


procedimento mostrarMenu()
inicio
   escreval("==============================================")
   escreval("LOGIFAST - SISTEMA DE GERENCIAMENTO DE ENTREGAS")
   escreval("1. Cadastrar entrega")
   escreval("2. Listar entregas")
   escreval("3. Consultar entrega")
   escreval("4. Exibir fila de despacho")
   escreval("5. Iniciar transporte")
   escreval("6. Finalizar entrega")
   escreval("7. Exibir matriz de distancias")
   escreval("8. Exibir estatisticas")
   escreval("9. Calcular percurso recursivamente")
   escreval("10. Encerrar sistema")
   escreval("==============================================")
   escreva("Escolha uma opcao: ")
fimprocedimento


Inicio
   qtdEntregas <- 0

   // Preenche a matriz antes de utilizar o sistema
   inicializarMatriz()

   // Mantem o menu ativo ate a opcao 10
   repita
      mostrarMenu()
      leia(opcao)

      // Estrutura de multipla escolha exigida pelo desafio
      escolha opcao
      caso 1
         cadastrarEntrega()

      caso 2
         listarEntregas()

      caso 3
         consultarEntrega()

      caso 4
         exibirFilaDespacho()

      caso 5
         iniciarTransporte()

      caso 6
         finalizarEntrega()

      caso 7
         exibirMatriz()

      caso 8
         exibirEstatisticas()

      caso 9
         calcularPercurso()

      caso 10
         escreval("Sistema encerrado.")

      outrocaso
         escreval("ERRO: opcao invalida.")
      fimescolha

   ate opcao = 10

Fimalgoritmo