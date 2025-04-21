# This computes at least one representative for each C^*-separation graphoid
# on n vertices up to permutation symmetry.

using Maxoids
using Graphs: transitiveclosure

n = 4;
# We may restrict to topologically ordered and transitively closed DAGs.
#GG = unique([transitiveclosure(G) for G in Maxoids.all_top_ordered_DAGs(n)]);
GG = Maxoids.all_DAGs(n);
CI = unique(Iterators.flatten([
    Maxoids.ci_string.(Ref(G), Maxoids.weights_for_cones(G; with_lower_dimensional=true)) for G in GG
]))
