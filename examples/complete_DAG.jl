using Maxoids 

G = complete_DAG(4)

F = maxoid_fan(G) 

P = maxoid_polytope(G) 

CI = all_markov_properties(G)

genericCI = all_markov_properties(G;generic_only = true )

Maxoids.face_ci_dict(G) #dictionary encoding the maxoids corresponding to each face 