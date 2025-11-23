using Oscar,Maxoids

G = complete_DAG(4)
P = maxoid_polytope(G)
F = maxoid_fan(G)

D = ci_to_face_dict(G)
for (k,v) in collect(D)
  println("  $(k) => $(v)")
end
