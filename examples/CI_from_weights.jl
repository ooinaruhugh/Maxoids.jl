using Maxoids

G = Maxoids.complete_DAG(4)
C = weights_from_cones(G)

CI = Maxoids.csep_markov.(Ref(G), C)
