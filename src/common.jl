using Oscar
import Oscar: Graph, Directed

module GraphsInterop
using Graphs
import Graphs: all_simple_paths
import Oscar: Graph, Directed, Undirected, n_vertices, edges, src, dst

function oscar_to_graphs(G::Graph{Directed})
  n = n_vertices(G)
  GG = SimpleDiGraph(n)

  for e in edges(G)
    add_edge!(GG, src(e), dst(e))
  end

  return GG
end

function oscar_to_graphs(G::Graph{Undirected})
  n = n_vertices(G)
  GG = SimpleGraph(n)

  for e in edges(G)
    add_edge!(GG, src(e), dst(e))
  end

  return GG
end

function all_simple_paths(G::Graph{T}, s, t; cutoff=n_vertices(G)-1) where {T <: Union{Directed,Undirected}}
  GG = oscar_to_graphs(G)

  return all_simple_paths(GG, s, t; cutoff=cutoff)
end

export all_simple_paths

end

import .GraphsInterop: all_simple_paths

#return the matrix supported on G with constant edge weights = 1 
function constant_weights(G::Graph{Directed})
    n = n_vertices(G)
    C = zero_matrix(tropical_semiring(max), n, n)
    
    for e in edges(G)
      C[src(e), dst(e)] = 1
    end
    return C
end 

# make the kleene star of C
function kleene_star(C)

    sum(map(d -> C^d, 0:ncols(C)-1))
end


# compute the weight of a path
function path_weight(C, p)

    prod(map(i -> C[p[i], p[i+1]] , 1:length(p)-1))
end

function get_skeleton(H::Graph{Directed})
    n = n_vertices(H)
    G = Graph{Undirected}(n)
    for e in edges(H)
      add_edge!(G, src(e), dst(e))
    end
    return G 
end 

function critical_graph(G::Graph{Directed}, K::Vector, C)
  V = vertices(G)
  n = n_vertices(G)

  Cstar = kleene_star(C)
  Gstar = Graph{Directed}(n)

  for (i,j) in Iterators.product(V,V)
    if i == j
      continue
    end

    # collect critical paths
    crit_paths = [p for p in all_simple_paths(G, i, j) if path_weight(C, p) == Cstar[i, j]]
    
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
