
@doc raw"""
    critical_graph(G::Graph{Directed}, K::Vector{Vertex}, C::Union{MatElem{<:TropicalSemiringElem},Matrix{<:TropicalSemiringElem}})

Computes the critical DAG $\mathcal{G}^*_{C,K}$ which contains an edge $i\to j$
whenever $i$ and $j$ are connected by a directed path, and no critical path 
from $i$ to $j$ in `G` intersects `K`.
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
    critical_graph(G::Graph{Directed}, K::Vector{Vertex}, W::Vector{<:RingElement}

Computes the critical DAG $\mathcal{G}^*_{C,K}$ which contains an edge $i\to j$
whenever $i$ and $j$ are connected by a directed path, and no critical path 
from $i$ to $j$ in `G` intersects `K`. $C$ denotes the weight matrix on `G` given by the weight
vector `W`.
"""
critical_graph(G::Graph{Directed}, K::Vector{Vertex}, W::Vector{<:RingElement}) = critical_graph(G,K,weights_to_tropical_matrix(G,W))

kleene_star(C) = (identity_matrix(C|>matrix)+C)^ncols(C)
path_weight(C,p) = prod(i -> C[p[i], p[i+1]] , 1:length(p)-1)

function weighted_transitive_reduction(G::Graph{Directed}, C)
  #iterate through edges of G and check whether the edge is the critical path
  #if this is not the case, remove 
  G_tr = Graph{Directed}(nv(G))
  Cstar = kleene_star(C)
  for (i,j) in get_edges(G)
    if C[i,j] == Cstar[i,j]
      add_edge!(G_tr, i, j)
    else 
      Cstar[i,j] = zero(tropical_semiring(max))
    end 
  end 

  return G_tr, Cstar
end 

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

function all_top_ordered_DAGs(n::Int)
  D = []
  all_edges = [(i,j) for i in 1:n, j in 1:n if i<j]
  for E in collect(powerset(all_edges))
    G = graph_from_edges(Directed, E, n)
    push!(D, G)
  end 
  return D 
end 

function all_top_ordered_TDAGs(n::Int)
  D = all_top_ordered_DAGs(n)
  T = []
  for G in D
    if G == transitiveclosure(G) && is_connected(get_skeleton(G)) && nv(G) == n 
      push!(T, G)
    end 
  end 
  return T
end 
