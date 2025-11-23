# This computes at least one representative for each C^*-separation graphoid
# on n vertices up to permutation symmetry.

using Oscar,Maxoids

n = 4;

# We may restrict to topologically ordered and transitively closed DAGs.
#GG = all_top_ordered_TDAGs(n)
GG = all_DAGs(n);

CI = all_markov_properties_as_ci_string(GG)
println(CI)

threenode_DAGs = all_top_ordered_TDAGs(3)
all_threenode_maxoids = all_markov_properties(threenode_DAGs; generic_only = true)

fournode_DAGs = all_top_ordered_TDAGs(4)
all_fournode_maxoids = all_markov_properties(fournode_DAGs)
all_fournode_generic_maxoids = all_markov_properties(fournode_DAGs; generic_only = true)

fivenode_DAGs = all_top_ordered_TDAGs(4)
all_fivenode_maxoids = all_markov_properties(fivenode_DAGs)

sixnode_DAGs = all_top_ordered_TDAGs(6)
all_sixnode_maxoids = all_markov_properties(sixnode_DAGs)

sixvar = filter(x -> n_edges(x) < 11, sixnode_DAGs)
G = sixvar[2598]
M = all_markov_properties_as_ci_string(G; generic_only = true)

