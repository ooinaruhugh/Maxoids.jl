function symbolic_adjacency_matrix(G::Graph{Directed})
  d = nv(G)

  R,X = polynomial_ring(QQ, ["e$(src(e))$(dst(e))" for e in edges(G)])
  C = identity_matrix(R,d)

  for (x,e) in zip(X,edges(G))
    C[src(e),dst(e)] = x
  end

  return C
end

@doc raw"""
    maxoid_polytope(G::Graph{Directed})

Computes the maxoid polytope for `G`.
"""
function maxoid_polytope(G::Graph{Directed})
  d = nv(G)
  C = symbolic_adjacency_matrix(G)
  F = filter(C^d|>Matrix) do f
    length(f)>1
  end
  isempty(F) && return simplex(0)
  return sum(newton_polytope(f) for f in F)
end

@doc raw"""
    maxoid_fan(G::Graph{Directed})

Computes the maxoid fan for `G` as the outer normal fan of the maxoid polytope.

"""
function maxoid_fan(G::Graph{Directed})
  inner_nf = maxoid_polytope(G) |> normal_fan

  dim(inner_nf) == 0 && return inner_nf

  r, l = rays_modulo_lineality(inner_nf)
  c    = cones(inner_nf)

  return polyhedral_fan(c, -r, l)
end

function interior_point_of_normal_cone(P,Q)
  PV = vertices(P)
  QV = vertices(Q)
  Q_vertex_indices = [findfirst(x -> x ==v, PV) for v in QV ]
  full_dim_cones = [normal_cone(P, i) for i in Q_vertex_indices]

  C = intersect(full_dim_cones)
  return -relative_interior_point(C)
end

