using Oscar,Maxoids

G = complete_DAG(4)
P = maxoid_polytope(G)

#visualize(project_full(P))

F   = maxoid_fan(G)
r,_ = rays_modulo_lineality(F)

for i in eachrow(cones(F))[1:end-1]
  w = sum(r[i])
  M = maxoid(G,w)
  println(M)
end
