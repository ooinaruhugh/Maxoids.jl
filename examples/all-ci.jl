# This computes at least one representative for each C^*-separation graphoid
# on n vertices up to permutation symmetry.

using Oscar,Maxoids

n = 4;
# We may restrict to topologically ordered and transitively closed DAGs.
#GG = all_top_ordered_TDAGs(n)
GG = all_DAGs(n);

CI = map(GG) do G
  F   = maxoid_fan(G)
  r,_ = rays_modulo_lineality(F)
  I   = eachrow(cones(F))[1:end-1] # We need to exclude the "empty cone"
  W   = map(I) do i
    sum(r[i])
  end

  ci_string.(Ref(G), W)
end |> Iterators.flatten |> unique

