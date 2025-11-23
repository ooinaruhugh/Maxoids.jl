
@doc raw"""
    cstar_separation(G::Graph{Directed}, C)

Collects all $C^\star$-separation statements of `G` given the weights `C`.

# Examples
```jldocstring
julia> G = complete_DAG(3)
Directed graph with 3 nodes and the following edges:
(1, 2)(1, 3)(2, 3)

julia> C = weights_to_tropical_matrix(G,[0,-1,0])
[-infty      (0)     (-1)]
[-infty   -infty      (0)]
[-infty   -infty   -infty]

julia> cstar_separation(G,C)
1-element Vector{Any}:
 Any[3, 1, [2]]

```
"""
function cstar_separation(G::Graph{Directed}, C)
  L = []
  for i in collect(vertices(G)), j in 1:i-1
    for K in collect(powerset(setdiff(vertices(G), [i,j])))
      if cstar_separation(G,C,K,i,j)
        push!(L,[i,j,K])
      end 
    end 
  end 
  return L 
end 

@doc raw"""
    cstar_separation(G::Graph{Directed}, W::Vector{<:RingElement})

Collects all $C^\star$-separation statements of `G` given the weights `W`.

# Examples
```jldocstring
julia> G = complete_DAG(3)
Directed graph with 3 nodes and the following edges:
(1, 2)(1, 3)(2, 3)

julia> cstar_separation(G,[0,-1,0])
1-element Vector{Any}:
 Any[3, 1, [2]]

```
"""
cstar_separation(G::Graph{Directed}, W::Vector{<:RingElement}) = cstar_separation(G, weights_to_tropical_matrix(G,W))

@doc raw"""
    ci_string(G::Graph{Directed}, C)

Prints the [gaussoids.de](https://gaussoids.de/gaussoids)-compatible binary string representing the
CI structure of $C^\star$-separation for `G` with weights `C`.

"""
function ci_string(G::Graph{Directed}, C)
  s = ""
  V = vertices(G)
  for ij in sort(collect(powerset(V, 2, 2)))
    Vij = setdiff(V, ij)
    for k in sort(0:length(V)-2)
      for K in sort(collect(powerset(Vij, k, k)))
        if cstar_separation(G,C,K,ij[1],ij[2])
          s *= "0"
        else
          s *= "1"
        end
      end 
    end 
  end 
  return s
end

ci_string(G::Graph{Directed}, W::Vector{<:RingElement}) = ci_string(G, weights_to_tropical_matrix(G,W))
