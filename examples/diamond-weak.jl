using Oscar,Maxoids

G = Maxoids.diamond()
F = maxoid_fan(G)

r,_ = rays_modulo_lineality(F)
W = map(eachrow(cones(F))[1:end-1]) do i
  sum(r[i])
end

M = [w => maxoid(G,w) for w in W]
for m in M
  println(m)
end
