using  Maxoids, Oscar;

E = [[1,2],[1,3],[2,3],[2,4],[3,4]];
G = graph_from_edges(Directed, E);

C = weights_to_tropical_matrix(G, [1,1,1,3,1]);

G_tr, C_tr = weighted_transitive_reduction(G,C)

Gbar = transitive_closure(G)
Cbar = weights_to_tropical_matrix(Gbar, [1,1,1,1,3,1])

M     = maxoid(G,C)
M_tr  = maxoid(G_tr,C_tr)
Mbar = maxoid(Gbar,Cbar)

M == M_tr == Mbar 
println("M*(G,C)       = $(M)")
println("M*(G_tr,C_tr) = $(M_tr)")
println("M*(G*,C*)     = $(Mbar)")
println(M == M_tr && M_tr == Mbar)
