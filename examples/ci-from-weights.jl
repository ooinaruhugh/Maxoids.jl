# This script shows how to retrieve all maxoids for a specific graph
# using the maxoid fan.
using Oscar,Maxoids

G = complete_DAG(4)
F = maxoid_fan(G)

# To retrieve the generic maxoids:
W = map(relative_interior_point, maximal_cones(F))
M = [maxoid(G,w) for w in W]
println("Generic maxoids: ")
for m in M
  println(m)
end
println()

# To retrieve all maxoids:
r,_       = rays_modulo_lineality(F)
W_generic = map(eachrow(cones(F))[1:end-1]) do f
  sum(r[f])
end
M_generic = [maxoid(G,w) for w in W_generic]
println("All maxoids: ")
for m in M_generic
  println(m)
end
