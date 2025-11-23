@doc raw"""
    constant_weight_matrix(G::Graph{Directed})

Returns a weight matrix representing constant weights on `G`.

# Examples
```jldocstring
julia> G = complete_DAG(3)
Directed graph with 3 nodes and the following edges:
(1, 2)(1, 3)(2, 3)

julia> constant_weight_matrix(G)
[-infty      (0)      (0)]
[-infty   -infty      (0)]
[-infty   -infty   -infty]

```
"""
function constant_weight_matrix(G::Graph{Directed})
    n = nv(G)
    C = zero_matrix(tropical_semiring(max), n, n)
    for e in edges(G)
      C[src(e),dst(e)] = one(tropical_semiring(max))
    end
    return C
end 

@doc raw"""
    random_weight_matrix(G::Graph{Directed}; range=1:10000)

Samples a random weight matrix on `G` with integer entries. The range can be specified using `range`.
"""
function random_weight_matrix(G::Graph{Directed}; range=1:10000)
    n = nv(G)
    C = zero_matrix(tropical_semiring(max), n, n)
    for e in edges(G)
      C[src(e),dst(e)] = rand(range)
    end
    return C
end 

@doc raw"""
    weights_to_tropical_matrix(G::Graph{Directed}, W::AbstractVector{<:RingElement})

Constructs a weight matrix for `G` from the specified vector `W` of weights.

# Examples
```jldocstring
julia> G = complete_DAG(3)
Directed graph with 3 nodes and the following edges:
(1, 2)(1, 3)(2, 3)

julia> weights_to_tropical_matrix(G,[1,2,3])
[-infty      (1)      (2)]
[-infty   -infty      (3)]
[-infty   -infty   -infty]

```
"""
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
