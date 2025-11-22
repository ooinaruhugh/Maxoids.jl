
function critical_graph(G::Graph{Directed}, K::Vector{Vertex}, C)
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

kleene_star(C) = (identity_matrix(C|>matrix)+C)^ncols(C)
path_weight(C,p) = prod(map(i -> C[p[i], p[i+1]] , 1:length(p)-1))

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
    for edge in gr.edges(G)
        gr.add_edge!(G, edge)
    end
    return G 
end 

