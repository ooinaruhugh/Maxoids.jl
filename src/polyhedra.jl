function symbolic_adjacency_matrix(G::Graph{Directed})
  d = nv(G)

  R,X = polynomial_ring(QQ, "e$(src(e))$(dst(e))" for e in edges(G))
  C = identity_matrix(R,d)

  for (x,e) in zip(X,edges(G))
    C[src(e),dst(e)] = x
  end

  return C
end

function maxoid_polytope(G::Graph{Directed})
  d = nv(G)
  C = symbolic_adjacency_matrix(G)
  F = filter(C^d|>Matrix) do f
    length(f)>1
  end
  isempty(F) && return simplex(0)
  return sum(newton_polytope(f) for f in F)
end

maxoid_fan(G::Graph{Directed}) = maxoid_polytope(G) |> normal_fan



