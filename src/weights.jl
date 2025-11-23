function constant_weight_matrix(G::Graph{Directed})
    n = nv(G)
    C = zero_matrix(tropical_semiring(max), n, n)
    for e in edges(G)
      C[src(e),dst(e)] = one(tropical_semiring(max))
    end
    return C
end 

function randow_weight_matrix(G::Graph{Directed}; trials=1000, range=1:10000)
    n = nv(G)
    C = zero_matrix(tropical_semiring(max), n, n)
    for e in edges(G)
      C[src(e),dst(e)] = rand(range)
    end
    return C
end 

function weights_to_tropical_matrix(G::Graph{Directed}, W::AbstractVector{<:RingElement})
  T = tropical_semiring(max)
  C = zero_matrix(T, nv(G), nv(G))

  for (e,w) in zip(edges(G),W)
    s,t = src(e),dst(e)
    C[s,t] = T(w)
  end

  return C
end

function matrix_to_weights(G::Graph{Directed}, C::Matrix{<:RingElement})
  W = [C[src(e),dst(e)] for e in edges(G)]
  return W
end
