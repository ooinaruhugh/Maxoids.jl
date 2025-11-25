using Oscar, Maxoids

G = Maxoids.diamond()
F = maxoid_fan(G)

for c in maximal_cones(F)
  w = relative_interior_point(c)
  println(maxoid(G,w))
  println("Maxoid for $(facets(c)|>first)")
end

println(maxoid(G, constant_weight_matrix(G)))
println("Maxoid for $(affine_hyperplane([1,-1,1,-1],0))")
