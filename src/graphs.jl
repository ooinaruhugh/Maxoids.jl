
@doc raw"""
    critical_graph(G::Graph{Directed}, K::Vector{Vertex}, C::Union{MatElem{<:TropicalSemiringElem},Matrix{<:TropicalSemiringElem}})

Computes the critical DAG $\mathcal{G}^*_{C,K}$ which contains an edge $i\to j$
whenever $i$ and $j$ are connected by a directed path, and no critical path 
from $i$ to $j$ in `G` intersects `K`.

# Examples

The following calculates the critical DAG `G` of the line graph with constant weights and empty `K`.
This amounts to taking the transitive closure of `G`.
```jldocstring
julia> G = graph_from_edges(Directed,[[1,2],[2,3]])
Directed graph with 3 nodes and the following edges:
(1, 2)(2, 3)

julia> critical_graph(G,Vertex[],constant_weight_matrix(G))
Directed graph with 3 nodes and the following edges:
(1, 2)(1, 3)(2, 3)

```

In the following example, the critical DAG does not always agree with the transitive closure, 
depending on the choice of `K`.
```jldocstring
julia> G = Maxoids.diamond()
Directed graph with 4 nodes and the following edges:
(1, 2)(1, 3)(2, 4)(3, 4)

julia> C = weights_to_tropical_matrix(G,[1,0,1,0]);

julia> critical_graph(G,[2],C)
Directed graph with 4 nodes and the following edges:
(1, 2)(1, 3)(2, 4)(3, 4)

julia> critical_graph(G,[3],C)
Directed graph with 4 nodes and the following edges:
(1, 2)(1, 3)(1, 4)(2, 4)(3, 4)

```
"""
function critical_graph(
  G::Graph{Directed}, 
  K::Vector{Vertex}, 
  C::Union{MatElem{<:TropicalSemiringElem},Matrix{<:TropicalSemiringElem}}
)
    V = vertices(G)
    _G = to_graphs_graph(G)

    # make the kleene star to test for max weighted paths
    Cstar = kleene_star(C)

    # make an empty graph which will be our critical graph that we add edges to
    Gstar = Graph{Directed}(nv(G))

    # loop over every possible edge
    for (i,j) in Iterators.product(V, V)
        i == j && continue

        # collect critical paths
        crit_paths = [p for p in all_simple_paths(_G, i, j) if path_weight(C, p) == Cstar[i, j]]
        
        if length(crit_paths) == 0
          continue
        end

        # check if any critical path factors through K
        # if so we do not add the edge [i, j] otherwise we add it
        if any(map(p -> any(map(k -> k in p[2:length(p)-1], K)), crit_paths))
          continue
        else
          add_edge!(Gstar, i, j)
        end
    end

    return Gstar
end

@doc raw"""
    transitive_closure(G::Graph{Directed})

Returns the transtive closure of `G`, which contains an edge $i\to j$ whenever
there is a path from $i$ to $j$ in `G`.

# Examples
```jldocstring
julia> G = graph_from_edges(Directed, [[1,2],[2,3]])
Directed graph with 3 nodes and the following edges:
(1, 2)(2, 3)

julia> transitive_closure(G)
Directed graph with 3 nodes and the following edges:
(1, 2)(1, 3)(2, 3)

"""
function transitive_closure(G::Graph{Directed})
  C = constant_weight_matrix(G)
  return critical_graph(G,Vertex[],C)
end

@doc raw"""
    critical_graph(G::Graph{Directed}, K::Vector{Vertex}, W::Vector{<:RingElement}

Computes the critical DAG $\mathcal{G}^*_{C,K}$ which contains an edge $i\to j$
whenever $i$ and $j$ are connected by a directed path, and no critical path 
from $i$ to $j$ in `G` intersects `K`. $C$ denotes the weight matrix on `G` given by the weight
vector `W`.

# Examples

The following calculates the critical DAG `G` of the line graph with constant weights and empty `K`.
This amounts to taking the transitive closure of `G`.
```jldocstring
julia> G = graph_from_edges(Directed,[[1,2],[2,3]])
Directed graph with 3 nodes and the following edges:
(1, 2)(2, 3)

julia> critical_graph(G,Vertex[],constant_weight_matrix(G))
Directed graph with 3 nodes and the following edges:
(1, 2)(1, 3)(2, 3)

```

In the following example, the critical DAG does not always agree with the transitive closure, 
depending on the choice of `K`.
```jldocstring
julia> G = Maxoids.diamond()
Directed graph with 4 nodes and the following edges:
(1, 2)(1, 3)(2, 4)(3, 4)

julia> w = [1,0,1,0];

julia> critical_graph(G,[2],w)
Directed graph with 4 nodes and the following edges:
(1, 2)(1, 3)(2, 4)(3, 4)

julia> critical_graph(G,[3],w)
Directed graph with 4 nodes and the following edges:
(1, 2)(1, 3)(1, 4)(2, 4)(3, 4)

```
"""
critical_graph(G::Graph{Directed}, K::Vector{Vertex}, W::AbstractVector{<:RingElement}) = critical_graph(G,K,weights_to_tropical_matrix(G,W))

kleene_star(C) = (identity_matrix(C|>matrix)+C)^ncols(C)
path_weight(C,p) = prod(i -> C[p[i], p[i+1]] , 1:length(p)-1)

@doc raw"""
    weighted_transitive_reduction(G::Graph{Directed}, C)

Returns the weighted transitive reduction of `G` with weights `C`.

# Examples
```jldocstring
julia> G = graph_from_edges(Directed, [[1,2],[2,3]])
Directed graph with 3 nodes and the following edges:
(1, 2)(2, 3)

julia> C1 = weights_to_tropical_matrix(G,[0,1,0])
[-infty      (0)      (1)]
[-infty   -infty      (0)]
[-infty   -infty   -infty]

julia> weighted_transitive_reduction(G,C1) |> first
Directed graph with 3 nodes and the following edges:
(1, 2)(1, 3)(2, 3)

julia> C2 = weights_to_tropical_matrix(G,[1,0,1])
[-infty      (1)      (0)]
[-infty   -infty      (1)]
[-infty   -infty   -infty]

julia> weighted_transitive_reduction(G,C2) |> first
Directed graph with 3 nodes and the following edges:
(1, 2)(2, 3)

```
"""
function weighted_transitive_reduction(G::Graph{Directed}, C)
  #iterate through edges of G and check whether the edge is the critical path
  #if this is not the case, remove 
  G_tr = Graph{Directed}(nv(G))
  Cstar = kleene_star(C)
  C_tr = one(C)
  for e in edges(G)
    i,j = src(e),dst(e)
    if C[i,j] == Cstar[i,j]
      add_edge!(G_tr, i, j)
      C_tr[i,j] = C[i,j]
    end 
  end 

  return G_tr, C_tr
end 

@doc raw"""
    weighted_transitive_reduction(G::Graph{Directed}, W::Vector{<:RingElement})

Returns the weighted transitive reduction of `G` with weights `W`.

# Examples
```jldocstring
julia> G = graph_from_edges(Directed, [[1,2],[2,3]])
Directed graph with 3 nodes and the following edges:
(1, 2)(2, 3)

julia> weighted_transitive_reduction(G,[0,1,0]) |> first
Directed graph with 3 nodes and the following edges:
(1, 2)(1, 3)(2, 3)

julia> weighted_transitive_reduction(G,[1,0,1]) |> first
Directed graph with 3 nodes and the following edges:
(1, 2)(2, 3)

```
"""
weighted_transitive_reduction(G::Graph{Directed}, W::Vector{<:RingElement}) = 
  weighted_transitive_reduction(G, weights_to_tropical_matrix(G,W))

function reachability_graph(G::Graph{Directed}, K::Vector{Vertex})
  V = vertices(G)
  Gstar = Graph{Directed}(nv(G))

  for (i,j) in Iterators.product(V,V)
    i == j && continue

    paths = collect(all_simple_paths(G,i,j))
    length(paths) == 0 && continue

    if any(map(p -> any(map(k -> k in p[2:length(p)-1], K)), paths))
      continue
    else
      add_edge!(Gstar, i, j)
    end
  end
  return Gstar
end

function get_skeleton(H::Graph{Directed})
    n = nv(H)
    G = gr.SimpleGraph(n,0)
    for e in edges(H)
      gr.add_edge!(G, src(e), dst(e))
    end
    return G 
end 

function all_DAGs(n::Int)
  D = Set{Vector{Tuple{Int,Int}}}()
  all_edges = [(i,j) for i in 1:n, j in 1:n if i<j]
  perms = permutations(1:n)

  for E in collect(powerset(all_edges))
    if !isempty(E) 
      for perm in perms 
        F = [(perm[i],perm[j]) for (i,j) in E] 

        push!(D, sort(F))
      end 

    end 

  end     
  push!(D, Tuple{Int,Int}[])
  return [graph_from_edges(Directed, E, n) for E in collect(D)]
end

function all_TDAGs(n::Int)
  return Iterators.filter(all_DAGs(n)) do G
    _G = to_graphs_graph(G)
    _G == gr.transitiveclosure(_G) && gr.is_connected(get_skeleton(G)) && nv(G) == n
  end
end

@doc raw"""
    all_top_ordered_DAGs(n::Int)

Returns a generator for all topologically ordered DAGs.

"""
function all_top_ordered_DAGs(n::Int)
  all_edges = [(i,j) for i in 1:n, j in 1:n if i<j]
  EE = powerset(all_edges)
  D = (graph_from_edges(Directed, E, n) for E in EE)
  return D
end 

@doc raw"""
    all_top_ordered_DAGs(n::Int)

Returns a generator for all topologically ordered DAGs which are transitively closed.

"""
function all_top_ordered_TDAGs(n::Int)
  return Iterators.filter(all_top_ordered_DAGs(n)) do G
    _G = to_graphs_graph(G)
    _G == gr.transitiveclosure(_G) && gr.is_connected(get_skeleton(G)) && nv(G) == n
  end
end 
