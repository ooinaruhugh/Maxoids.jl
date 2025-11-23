using Oscar, Maxoids

G = Maxoids.diamond()
F = maxoid_fan(G)

for c in maximal_cones(F)
  r,_ = rays_modulo_lineality(c)
  println(cstar_separation(G,sum(r)))
  println("Maxoid for $(facets(c)|>first)")
end

println(cstar_separation(G, constant_weight_matrix(G)))
println("Maxoid for $(affine_hyperplane([1,-1,1,-1],0))")
