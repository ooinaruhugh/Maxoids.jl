using Oscar, Maxoids

n = 4
G = complete_DAG(n)
P = maxoid_polytope(G)
F = maxoid_fan(G)
V = vertices(P)

Q = faces(P,2)[4]
Q_maxoid = cstar_separation(G,Maxoids.interior_point_of_normal_cone(P,Q))

# Look at maxoids corresponding to EDGES: how many of them are properly non-generic?
W1   = map(relative_interior_point, maximal_cones(F))
W2,_ = rays_modulo_lineality(F)

M1 = [maxoid(G,w) for w in W1] |> unique
M2 = [maxoid(G,w) for w in W2]

issubset(M2,M1)
setdiff(M1,M2)

#look at a facet of V, see if the maxoids are related
facet_V = [p for p in V if p[6] + p[8] - p[10] == 2]
facet = convex_hull(facet_V)
facet_F = normal_fan(convex_hull(facet_V))
facet_W = map(relative_interior_point, maximal_cones(F))
M = [maxoid(G,w) for w in facet_W]

