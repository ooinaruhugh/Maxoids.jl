function constant_weight_matrix(G::Graph{Directed})
    n = nv(G)
    C = zeros(tropical_semiring(max), n, n)
    for e in edges(G)
      C[src(e),dst(e)] = zero(tropical_semiring(max))
    end
    return C
end 

function randow_weight_matrix(G::Graph{Directed}; range=1:10000)
    n = nv(G)
    C = zeros(tropical_semiring(max), n, n)
    for e in edges(G)
      C[src(e),dst(e)] = rand(range)
    end
    return C
end 

function weights_to_matrix(G::Graph{Directed}, W::Vector{<:TropicalSemiringElem})
  C = zeros(tropical_semiring(max), nv(G), nv(G))

  for e,w in zip(edges(G),W)
    s,t = src(e),dst(e)
    C[s,t] = w
  end

  return C
end

function matrix_to_weights(G::Graph{Directed}, C::Matrix{<:TropicalSemiringElem})
  W = [C[src(e),dst(e)] for e in edges(G)]
  return W
end
