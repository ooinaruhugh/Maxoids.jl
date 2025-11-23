
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
  L = CIStatement[]
  for i in collect(vertices(G)), j in 1:i-1
    for K in collect(powerset(setdiff(vertices(G), [i,j])))
      if cstar_separation(G,C,K,i,j)
        push!(L,(i,j,K))
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
  for (i,j) in sort(collect(powerset(V, 2, 2)))
    Vij = setdiff(V, [i,j])
    for k in sort(0:length(V)-2)
      for K in sort(collect(powerset(Vij, k, k)))
        if cstar_separation(G,C,K,i,j)
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

function _all_markov_properties(G,f; generic_only = false)
  F = maxoid_fan(G)
  if dim(F) == 0
    return [f(G, constant_weight_matrix(G))]
  end

  W = if !generic_only
    r,_ = rays_modulo_lineality(F)
    I   = cones(F)[1:end-1,:]

    map(eachrow(I)) do i
      sum(r[i])
    end
  else
    map(relative_interior_point, maximal_cones(F))
  end

  return [f(G,w) for w in W]
end

@doc raw"""
    all_markov_properties(G; generic_only = false)

Returns all maxoids that can arise from weights on `G`. If `generic_only` is `true`,
then returns only the generic maxoids for `G`.
"""
function all_markov_properties(G::Graph{Directed}; generic_only = false)
  return _all_markov_properties(G, cstar_separation; generic_only = generic_only)
end

@doc raw"""
    all_markov_properties(G::Vector{Graph{Directed}}; generic_only = false)

Returns all maxoids that can arise from any graph in `G`. If `generic_only` is `true`,
then returns only the generic maxoids.
"""
function all_markov_properties(G::AbstractVector{Graph{Directed}}; generic_only = false)
  M = Set{CIStatement}()
  for g in G
    m = all_markov_properties(g; generic_only = generic_only)
    push!(M, m...)
  end

  return collect(M)
end

function all_markov_properties_as_ci_string(G; generic_only = false)
  return _all_markov_properties(G, ci_string; generic_only = generic_only)
end

function all_markov_properties_as_ci_string(G::Vector{Graph{Directed}}; generic_only = false)
  M = Set{String}()
  for g in G
    m = all_markov_properties_as_ci_string(g; generic_only = generic_only)
    push!(M, m...)
  end

  return collect(M)
end

@doc raw"""
    ci_to_face_dict(G::Graph{Directed})

Returns a dictionary mapping maxoids on `G` to faces of the maxoid polytope of `G`.
"""
function ci_to_face_dict(G::Graph{Directed})
  P = maxoid_polytope(G)
  face_dict = Dict{Vector{CIStatement},Vector{Polyhedron}}()

  for i in 0:dim(P)
    for f in faces(P,i)
      v = interior_point_of_normal_cone(P,f)
      M = cstar_separation(G,v)
      
      push!(get!(face_dict, M, Polyhedron[]), f)
    end
  end

  return face_dict
end

@doc raw"""
    dag_to_maxoid_dict(G::Vector{Graph{Directed}})

Given a list of graphs `G`, returns a dictionary mapping graphs to the maxoids
that can arise from them.

"""
function dag_to_maxoid_dict(G::Vector{Graph{Directed}})
  M = map(all_markov_properties, G)
  return Dict(G .=> M)
end

