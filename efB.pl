% Autor: José Póvoa
% Data: 06-12-2015

:-use_module(library(lists)).

%abrir a base de dados
adiciona_predicado(end_of_file):-
                                 !.

adiciona_predicado(L):-
                   assert(L),
                   le_predicado.

le_predicado:- read(L),
               adiciona_predicado(L).

abre_base_dados:- open('cromos.txt',read,Fin),
                  current_input(Tec),
                  set_input(Fin),
                  le_predicado,
                  set_input(Tec),
                  close(Fin).

%X é colecionador
colecionador(X):-
                 cromos(X,_).

%N é o número de E´s na lista E
conta_elementos_x([],_,C,C).

conta_elementos_x([X|Lf],E,N,C):-
                                 X==E,
                                 Ci is C + 1,
                                 conta_elementos_x(Lf,E,N,Ci).

conta_elementos_x([X|Lf],E,N,C):-
                                 X\==E,
                                 conta_elementos_x(Lf,E,N,C).

conta_elementos(L,E,N):-
                        conta_elementos_x(L,E,N,0).

%N é o número de cromos M do colecionador X
numero_cromos(M,X,N):-
                      cromos(X,L),
                      conta_elementos(L,M,N).
                      
%N é número total de cromos do colecionador X
numero_cromos_total(X,N):-
                          cromos(X,L),
                          length(L,N).

%C é o conjunto de cromos do colecionador X
conjunto_cromos(X,C):-
                      cromos(X,L),
                      list_to_set(L,Cn),
                      sort(Cn,C).

%L é a lista do numero de cromos do conjunto de cromos do colecionador X
lista_numero_cromos_x(_,[],La,La).

lista_numero_cromos_x(X,[M|Cf],Lr,La):-
                                       numero_cromos(M,X,N),
                                       lista_numero_cromos_x(X,Cf,Lr,[N|La]).

lista_numero_cromos(X,L):-
                          conjunto_cromos(X,C),
                          lista_numero_cromos_x(X,C,Li,[]),
                          reverse(Li,L).

%M é um cromo procurado pelo colecionador X
cromo_procurado(M,X):-
                      conjunto_cromos(X,C),
                      not(member(M,C)).

%C é o conjunto de cromos procurados pelo colecionador X
conjunto_cromos_procurados_x(0,_,Ca,Ca).

conjunto_cromos_procurados_x(M,Cx,Cr,Ca):-
                                         M>0,
                                         member(M,Cx),
                                         Mi is M-1,
                                         conjunto_cromos_procurados_x(Mi,Cx,Cr,Ca).

conjunto_cromos_procurados_x(M,Cx,Cr,Ca):-
                                         M>0,
                                         not(member(M,Cx)),
                                         Mi is M-1,
                                         conjunto_cromos_procurados_x(Mi,Cx,Cr,[M|Ca]).

conjunto_cromos_procurados(X,C):-
                                 conjunto_cromos(X,Cx),
                                 colecao_cromos(N),
                                 conjunto_cromos_procurados_x(N,Cx,C,[]).

%M é um cromo disponível para troca pelo colecionador X
cromo_troca(M,X):-
                  numero_cromos(M,X,N),
                  N > 1.

%C é o conjunto de cromos disponíveis para troca do colecionador X
conjunto_cromos_troca_x(0,_,Ca,Ca).

conjunto_cromos_troca_x(M,X,Cr,Ca):-
                                    M>0,
                                    numero_cromos(M,X,Nm),
                                    Nm=<1,
                                    Mi is M-1,
                                    conjunto_cromos_troca_x(Mi,X,Cr,Ca).

conjunto_cromos_troca_x(M,X,Cr,Ca):-
                                    M>0,
                                    numero_cromos(M,X,Nm),
                                    Nm>1,
                                    Mi is M-1,
                                    conjunto_cromos_troca_x(Mi,X,Cr,[M|Ca]).

conjunto_cromos_troca(X,C):-
                            colecao_cromos(N),
                            conjunto_cromos_troca_x(N,X,C,[]).

%C é o conjunto de cromos que o colecionador X1 procura e X2 tem para troca
conjunto_possiveis_trocas(X1,X2,C):-
                                    conjunto_cromos_procurados(X1,C1),
                                    conjunto_cromos_troca(X2,C2),
                                    X1\==X2,
                                    intersection(C1,C2,C).

%O colecionador X1 procura o cromo M, X2 tem M para troca
%e C é o conjunto de cromos que X1 tem para oferecer em troca a X2
procura_oferta(M,X1,X2,C):-
                           cromo_troca(M,X2),
                           conjunto_possiveis_trocas(X2,X1,C),
                           pontuacao(M,Pm),
                           pontuacao_conj(C,Pc),
                           Pc>=Pm.

%L é a lista de cromos de todos os colecionadores
lista_total_cromos_x([],La,La).

lista_total_cromos_x([X|Lf],Lr,La):-
                                    cromos(X,Lx),
                                    append(Lx,La,Laa),
                                    lista_total_cromos_x(Lf,Lr,Laa).

lista_total_cromos(L):-
                       colecionadores(Xs),
                       lista_total_cromos_x(Xs,L,[]).

%N é o número de cromos M de todos os colecionadores
numero_cromos_col(M,N):-
                        lista_total_cromos(L),
                        conta_elementos(L,M,N).

%N é o número de cromos de todos os colecionadores
numero_cromos_total_col(N):-
                            lista_total_cromos(L),
                            length(L,N).

%C é o conjunto de cromos da colecao - apenas os cromos que de colecionadores
conjunto_cromos_col(C):-
                        lista_total_cromos(L),
                        list_to_set(L,Cn),
                        sort(Cn,C).

%L é a lista do numero de cromos do conjunto de cromos da coleção
lista_numero_cromos_col_x([],La,La).

lista_numero_cromos_col_x([M|Cf],Lr,La):-
                                         numero_cromos_col(M,N),
                                         lista_numero_cromos_col_x(Cf,Lr,[N|La]).

lista_numero_cromos_col(L):-
                            conjunto_cromos_col(C),
                            lista_numero_cromos_col_x(C,Li,[]),
                            reverse(Li,L).

%Xs é a lista colecionadores que têm o cromo M procurado pelo colecionador X1
lista_col_oferta_x(_,_,[],Xa,Xa).

lista_col_oferta_x(M,X1,[X|Lf],Xr,Xa):-
                                       procura_oferta(M,X1,X,_),
                                       lista_col_oferta_x(M,X1,Lf,Xr,[X|Xa]).

lista_col_oferta_x(M,X1,[X|Lf],Xr,Xa):-
                                       not(procura_oferta(M,X1,X,_)),
                                       lista_col_oferta_x(M,X1,Lf,Xr,Xa).

lista_col_oferta(M,X1,Xs):-
                           colecionadores(LX),
                           select(X1,LX,LO),
                           lista_col_oferta_x(M,X1,LO,Xs,[]).

%Cs é a lista de conjuntos de cromos que o colecionador X1 oferece em troca
%aos colecionadores com o cromo procurado disponivel para troca
lista_conj_oferta_x(_,_,[],La,La).

lista_conj_oferta_x(M,X1,[X|Lf],Cr,La):-
                                        procura_oferta(M,X1,X,C),
                                        lista_conj_oferta_x(M,X1,Lf,Cr,[C|La]).

lista_conj_oferta(M,X1,Cs):-
                            lista_col_oferta(M,X1,Xs),
                            lista_conj_oferta_x(M,X1,Xs,Cr,[]),
                            reverse(Cr,Cs).

%P é a pontuação do cromo M, determinada pela sua frequência relativa F
pontuacao_x(F,5):-
                  F<0.05.
                  
pontuacao_x(F,4):-
                  F>=0.05,
                  F<0.10.

pontuacao_x(F,3):-
                  F>=0.10,
                  F<0.15.
                  
pontuacao_x(F,2):-
                  F>=0.15,
                  F<0.25.

pontuacao_x(F,1):-
                  F>=0.25.

pontuacao(M,P):-
                numero_cromos_col(M,Nc),
                numero_cromos_total_col(N),
                F is Nc/N,
                pontuacao_x(F,P).

%P é a pontuação total do conjunto de cromos C
pontuacao_conj_x([],Pa,Pa).

pontuacao_conj_x([M|Cf],P,Pa):-
                               pontuacao(M,Pm),
                               Paa is Pa + Pm,
                               pontuacao_conj_x(Cf,P,Paa).

pontuacao_conj(C,P):-
                     pontuacao_conj_x(C,P,0).

%grava a base de dados
grava_base_dados:- open('cromos.txt',write,Fout),
                   current_output(Tec),
                   set_output(Fout),
                   listing(colecao_cromos/1),
                   listing(colecionadores/1),
                   listing(cromos/2),
                   set_output(Tec),
                   close(Fout).

%escreve uma lista
escreve_lista([]):-
                   nl,
                   !.

escreve_lista([X|Lf]):-
                       write(X),
                       write(' '),
                       escreve_lista(Lf).

%escreve lista de colecionadores e opcoes de troca
escreve_ofertas([],[]):-
                          !.

escreve_ofertas([X|Xf],[C|Cf]):-
                                write("cromos oferecidos em troca a "),
                                writeln(X),
                                escreve_lista(C),
                                pontuacao_conj(C,P),
                                write("pontuacao: "), writeln(P),
                                escreve_ofertas(Xf,Cf).

%le nome introduzido pelo utilizador
le_nome(X):-
              repeat,
              writeln("escreva o nome de colecionador"),
              read(X),
              atomic(X),
              !.

%le um número inteiro introduzida pelo utilizador
le_int(N):-
           repeat,
           writeln("escreva um numero inteiro"),
           read(N),
           integer(N),
           !.

%le o numero de cromo da colecao
le_cromo(M):-
             repeat,
             colecao_cromos(N),
             write("cromo (1 a "),
             write(N),
             writeln(")"),
             le_int(M),
             M>0,
             M=<N,
             !.

%apresenta o menu ao utilizador
menu:-
      repeat,
      writeln("--------------------------------------------"),
      writeln("                   Menu"),
      writeln("--------------------------------------------"),
      writeln("1 - listar colecao"),
      writeln("2 - listar colecionadores"),
      writeln("3 - registar novo colecionador"),
      writeln("4 - listar cromos de colecionador"),
      writeln("5 - listar cromos de colecionador para troca"),
      writeln("6 - listar cromos procurados por colecionador"),
      writeln("7 - adicionar cromo"),
      writeln("8 - subtrair cromo"),
      writeln("9 - procurar cromo"),
      writeln("0 - sair"),
      writeln("--------------------------------------------"),
      le_int(N),
      opcao(N),
      N==0,
      !.

%realiza as opcoes
opcao(1):-
          writeln("cromos da colecao:"),
          conjunto_cromos_col(C),
          escreve_lista(C),
          writeln("respetivas quantidades:"),
          lista_numero_cromos_col(L),
          escreve_lista(L),
          !.

opcao(2):-
          writeln("colecionadores:"),
          colecionadores(L),
          escreve_lista(L),
          !.

opcao(3):-
          le_nome(X),
          colecionadores(Xs),
          retract(colecionadores(_)),
          assert(colecionadores([X|Xs])),
          assert(cromos(X,[])),
          !.

opcao(4):-
          le_nome(X),
          writeln("cromos do colecionador:"),
          conjunto_cromos(X,C),
          escreve_lista(C),
          writeln("respetivas quantidades:"),
          lista_numero_cromos(X,L),
          escreve_lista(L),
          !.

opcao(5):-
          le_nome(X),
          writeln("cromos do colecionador disponíveis para troca:"),
          conjunto_cromos_troca(X,C),
          escreve_lista(C),
          !.

opcao(6):-
          le_nome(X),
          writeln("cromos procurados por colecionador:"),
          conjunto_cromos_procurados(X,C),
          escreve_lista(C),
          !.

opcao(7):-
          le_nome(X),
          le_cromo(M),
          cromos(X,L),
          retract(cromos(X,_)),
          assert(cromos(X,[M|L])),
          writeln("cromo adicionado"),
          !.

opcao(8):-
          le_nome(X),
          le_cromo(M),
          cromos(X,L),
          select(M,L,Ls),
          retract(cromos(X,_)),
          assert(cromos(X,Ls)),
          writeln("cromo subtraido"),
          !.
          
opcao(9):-
          le_nome(X),
          le_cromo(M),
          pontuacao(M,P),
          write("cromo procurado: "), write(M), write(" pontuacao: "), writeln(P),
          writeln("colecionadores com cromo procurado disponivel para troca:"),
          lista_col_oferta(M,X,Xs),
          lista_conj_oferta(M,X,Cs),
          escreve_ofertas(Xs,Cs),
          !.

opcao(0):-
          !.

%main
cromogest:-
           abre_base_dados,
           menu,
           grava_base_dados.