using Maxoids

G = Maxoids.DAG_from_edges(4, [(1,2), (1,3), (2,4), (3,4)])
F = Maxoids.weights_for_cones(G)

# This gives a cone on which the CI structure is exactly
#   { 14|3, 23|1, 14|23 } = { 14|3 } \cup d-sep(G).
# As 14|3 and 14|23 hold but neither 12|3 nor 24|3, this
# violates Weak Transitivity.
[ C => Maxoids.csep_markov(G, C) for C in F ]
