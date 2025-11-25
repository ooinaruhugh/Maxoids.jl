using Oscar, Maxoids

E = [[1,2],[1,3],[2,3],[2,4],[3,4]]
G = graph_from_edges(Directed, E)

C = weights_to_tropical_matrix(G, [1,1,1,3,1])

G_tr, C_tr = weighted_transitive_reduction(G,C)

Gstar = transitive_closure(G)
Cstar = kleene_star(C)

M     = maxoid(G,C)
M_tr  = maxoid(G_tr,C_tr)
Mstar = maxoid(Gstar,Cstar)

println("M*(G,C)       = $(M)")
println("M*(G_tr,C_tr) = $(M_tr)")
println("M*(G*,C*)     = $(Mstar)")
println(M == M_tr && M_tr == Mstar)
