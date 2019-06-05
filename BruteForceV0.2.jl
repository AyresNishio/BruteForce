clearconsole()
#TESTANDO GIT_HUUB
using LinearAlgebra
using Combinatorics

# Monta vetor de medidas completo
function vetMed(A)
    medidas=zeros(Int64,nMedMax,3) # Vetor que organiza medidores.
    med=0

    for de=1:n
        for para=1:n
            if (A[de,para]==1)
                med=med+1
                medidas[med,1]=Int(de)
                medidas[med,2]=Int(para)
            end
        end
    end #flUXO

    for i=1:n
        med=med+1
        medidas[med,1]=Int(i)
        medidas[med,2]=Int(i)
    end #INJEÇÃO

    return medidas
end

# Seta como ligados todas as medidas armazenadas em um e conta o número total de medidas.
function altMed(medidas,medidasAdd,status)
    #liga ou desliga medidas no vetor de medidas completo
    #medidas = matriz de medidas completa
    #medidasIni = matriz de medidas a serem adiciondas
    #ambas as matrizes devem estar ordenadas.
    #status = 1 ligado; 0 desligado
    nMed=size(medidasAdd,1)
    indMax=size(medidas,1)
    actIdx=Array{Int64}(undef,nMed)#zeros(nMed,1)
    med=1
    ind=1
    while (med<=nMed && ind<=indMax)

        dc=medidas[ind,1]
        di=medidasAdd[med,1]
        pc=medidas[ind,2]
        pi=medidasAdd[med,2]
        #Se medidas[ind].de==medidasIni[med].de
        #   &&
        #Se medidas[ind].para==medidasIni[med].para
        if (dc==di && pc==pi)
            medidas[ind,3]=status
            actIdx[med]=ind
            med=med+1
        end
        ind=ind+1

    end
    return (medidas,actIdx)
end

# Calcula matriz jacobiano
function jacobiana(medidas,A,ref)
    nMed=Int(sum(medidas[:,3]))
    n=size(A,1)
    H=zeros(nMed+1,n)
    H[nMed+1,ref]=1
    ind=1
    med=1
    while med<=nMed
        if medidas[ind,3]==1
            de=Int(medidas[ind,1])
            para=Int(medidas[ind,2])
            if de!=para
                for l=1:n
                    if     (l==de)   H[med,l]=1
                    elseif (l==para) H[med,l]=-1 end
                end
            else
                nbc=Int(sum(A[de,:]))
                for l=1:n
                    if (l==de) H[med,l]=nbc
                    else       H[med,l]=A[de,l] end
                end
            end
            med=med+1
        end
        ind=ind+1
    end

    return H
end

# Retorna verdadeiro se o dicionario Crit contém subconjunto de i
function contemKcrit(i, card)
    global Crit
    contid=false
    for j=1:card-1
        #println("size",size(Crit[j],1))
        for k=1:size(Crit[j],1)
            #print("i",i," ")
            #print("crit",Crit[j][k]," ")
            #println(issubset(Crit[j][k],i))
            if (issubset(Crit[j][k],i))
                #println(i)
                contid=true                       # Se contid se torna verdadeiro, i contém tupla crítica de tamanho
                break                             # inferior e deve ser desconsiderado.
            end
        end
    end
    return contid
end

## Descomentar o sistema desejado

# Matriz de conexões do sistema 16 barras
A=[0 1 1 0 1 0
   1 0 1 0 0 0
   1 1 0 1 0 0
   0 0 1 0 1 1
   1 0 0 1 0 0
   0 0 0 1 0 0]

# # Matriz de conexões do sistema padrão ieee de 14 barras
# A = [0	1	0	0	1	0	0	0	0	0	0	0	0	0
#     1	0	1	1	1	0	0	0	0	0	0	0	0	0
#     0	1	0	1	0	0	0	0	0	0	0	0	0	0
#     0	1	1	0	1	0	1	0	1	0	0	0	0	0
#     1	1	0	1	0	1	0	0	0	0	0	0	0	0
#     0	0	0	0	1	0	0	0	0	0	1	1	1	0
#     0	0	0	1	0	0	0	1	1	0	0	0	0	0
#     0	0	0	0	0	0	1	0	0	0	0	0	0	0
#     0	0	0	1	0	0	1	0	0	1	0	0	0	1
#     0	0	0	0	0	0	0	0	1	0	1	0	0	0
#     0	0	0	0	0	1	0	0	0	1	0	0	0	0
#     0	0	0	0	0	1	0	0	0	0	0	0	1	0
#     0	0	0	0	0	1	0	0	0	0	0	1	0	1
#     0	0	0	0	0	0	0	0	1	0	0	0	1	0]

n=size(A,1)                    # Número de barras
m=Int(sum(A)/2)                # Número de ramos
nMedMax=n+2m                   # Número máximo de medidas possível
Crit=Dict()                    # Dicionário onde serão armazenadas as tuplas críticas

# Constroi o vetor que organiza as medidas disponíveis.
# Da forma: [|barra de| |barra para| |ligado ou desligado|]
medidas = vetMed(A)
#Vetor de medidas Inicial 6
medidasIni=[1 2
            2 3
            4 5
            4 6
            5 4
            1 1
            3 3
            5 5
            6 6]

# #Vetor de medidas Inicial 14
# medidasAtivas=[1	2
#                1	5
#                2	3
#                2	5
#                4	7
#                4	9
#                5	2
#                6	11
#                6	12
#                6	13
#                7	8
#                9	10
#                9	14
#                12	6
#                12	13
#                3	3
#                6	6
#                9	9
#                10	10
#                12	12]

# Ativa, na matriz medidas, as medidas em medidasAtivas
(medidas,actIdx)=altMed(medidas,medidasAtivas,1)
#H=jacobiana(medidas,A,1)
clearconsole()
for card=1:3
    println("--------Cardinalidade $card:----------")
    global Crit=merge(Dict(card=>[]),Crit)    # Adciona vetor que armazena as k-tuplas ( [card]-tuplas ) críticas
                                              # no dicionário. São indexadas como k (card).

    for i in combinations(actIdx,card)        # Percorre combinações de medidas tomados k a k (card a card).
        if (!(contemKcrit(i, card)))          # Evita análise de tuplas que contenham k-tuplas críticas
            medidasR=copy(medidas)            # Preserva matriz de medidas
            for j=1:card                      # Para toda unidade medida da tupla que está sendo analisada...
                # de=Int(medidasR[i[j],1])    # Parece que não faz nada...Inutil
                # para=Int(medidasR[i[j],2])

                medidasR[i[j],3]=0            # Desativa medidas (pertencentes à tupla analisada)
            end
            # Análise de Observabilidade
            H=jacobiana(medidasR,A,1)
            G=transpose(H)*H
            detG=det(G)
            if detG>0.0001
                #println("OBSERVAVEL!)
            else
                print("medidas removidas=")
                for j=1:card
                    de=Int(medidasR[i[j],1])
                    para=Int(medidasR[i[j],2])
                    print("P",de,"-",para," ")
                end
                append!(Crit[card],[i])
                println()
                println(" ")
            end
        end
    end
end
