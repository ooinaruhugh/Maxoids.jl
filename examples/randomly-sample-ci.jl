using Oscar,Maxoids

G = complete_DAG(4)
M = Set{Vector{CIStatement}}()
for _ in 1:1000
  C = random_weight_matrix(G)
  push!(M, cstar_separation(G,C))
end

for m in M
  println(m)
end

