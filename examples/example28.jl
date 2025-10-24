using Maxoids

#starting DAG
L = [[1,2],[1,3],[2,3],[2,4],[3,4]] 
G = DAG_from_edges(L)
C = Maxoids.constant_weights(G)
C[2,4] = 3 

#weighted transitive reduction
G_tr = Maxoids.wtr(G,C)[1]
C_tr = constant_weights(G_tr)
C_tr[2,4] = 3

#transitive closure 
G_bar = Maxoids.transitiveclosure(G)
C_bar = Maxoids.constant_weights(G_bar)
C_bar[2,4] = 3 



#are the maxoids equal?
M = Maxoids.csep_markov(G,C)
M_tr = Maxoids.csep_markov(G_tr, C_tr)
M_bar = Maxoids.csep_markov(G_bar, C_bar)

M == M_tr == M_bar #yes! 

#what is the fan of G? 

weights_for_cones(G, with_lower_dimensional = true ) #6 maximal cones 
F = weights_for_cones(G, with_lower_dimensional = true ) #13 cones in total

all_maxoids = unique([Maxoids.csep_markov(G,C) for C in F]) #5 maxoids... 

C_tilde = constant_weights(G)
C_tilde[1,3] = 2

M_tilde = Maxoids.csep_markov(G, C_tilde)

C1 = constant_weights(G)
C1[1,3] = 3

M1 = Maxoids.csep_markov(G,C1)

C2 = constant_weights(G)
C2[1,3] = -1

M2 = Maxoids.csep_markov(G,C2)
Maxoids.wtr(G,C2)[1]

M_tilde == union(M1,M2)