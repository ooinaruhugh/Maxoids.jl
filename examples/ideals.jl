using Maxoids
#using Graphs
include("groebner_weights.jl")




#potential problem example: 

L = [[1,2],[1,3],[2,3],[2,4],[3,4]]
I1 = ideal_from_DAG_edges(L)
I2 = binomial_ideal_from_DAG_edges(L)

I1 == I2 
groebner_basis(I1)
groebner_basis(I2)
F1 = groebner_fan(I1)
F2 = groebner_fan(I2)
maximal_cones(F1) 
maximal_cones(F2)
#matrices_from_fan(F1,L)

weights1 = matrices_from_fan(F1,L;maximal_only = true  )

weights2 = matrices_from_fan(F2,L;maximal_only = true  )

maxoids1 = unique([Maxoids.csep_markov(Maxoids.DAG_from_edges(L),c) for c in weights1])
maxoids2 = unique([Maxoids.csep_markov(Maxoids.DAG_from_edges(L),c) for c in weights2])

maxoids1 == maxoids2 


#only the second ideal gives all generic maxoids

#look at the complete DAG

L = [[1,2],[1,3],[1,4],[2,3],[2,4],[3,4]]

I = binomial_ideal_from_DAG_edges(L)

G = groebner_basis(I) #one term doesn't correspond to a path-connected pair 

F = groebner_fan(I)

weights = matrices_from_fan(F,L)
maxoids = unique([Maxoids.csep_markov(Maxoids.DAG_from_edges(L),c) for c in weights])

