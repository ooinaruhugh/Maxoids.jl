using Oscar: Edge, Graph, Directed

const Vertex = Int64
const TaggedEdge = Pair{Edge,Bool}

TaggedEdge(i::Vertex,j::Vertex,tag::Bool) = TaggedEdge(Edge(i,j),tag)

function star_reachability(
  D::Graph{Directed},
  illegal_edges::Vector{Tuple{Edge,Edge}},
  J::Vector{Vertex}
)
  R = Set{Vertex}()
  frontier = TaggedEdge[]
  next_frontier = TaggedEdge[]
  visited = TaggedEdge[]

  D_prime = copy(D)
  # 1. Add a dummy vertex for each node j in J
  for i in 1:length(J)
    add_vertex!(D_prime)
    add_edge!(D_prime, nv(D)+i, J[i])
    push!(frontier, TaggedEdge(nv(D)+i, J[i], false))

    push!(R, J[i])
    push!(R, nv(D)+i)
  end

  # 2. Add reversed edges to D_prime
  for s in vertices(D)
   for t in outneighbors(D, s)
     add_edge!(D_prime, t, s)
   end
  end

  while true
    # 3. Expand the reachability set
    for ((s,t),passed_collider) in frontier
      push!(R,t)

      # Check if it's a "s -> t" edge or "s <- t" in the original graph 
      s_to_t = s < nv(D)+1 ? has_edge(D,s,t) : true

      # Find all out-edges from t in D_prime (these are the neighbors of t in D)
      for f in outedges(D_prime, t)
        _, u = f

        u_to_t = has_edge(D,u,t)
        t_is_collider = s < nv(D)+1 ? (s_to_t && u_to_t) : false

        t_is_collider && passed_collider && continue

        new_tagged_edge = TaggedEdge(t,u, passed_collider || t_is_collider)

        new_tagged_edge in visited && continue
        (e, Edge(t,u)) in illegal_edges && continue

        push!(next_frontier, new_tagged_edge)
    end

    union!(visited, frontier)

    isempty(next_frontier) && return R

    frontier = next_frontier
    next_frontier = TaggedEdge[]
  end
end

function outedges(D::Graph{Directed}, t::Vertex)
  L = Pair{Vertex,Vertex}[]
  for edge in edges(D)
    if src(edge) == t
      push!(L, (t, dst(edge)))
    end
  end
  return L 
end 

@doc raw"""
    star_separation(D::Graph{Directed}, J::Vector{Vertex}, L::Vector{Vertex})

Computes the set of nodes $I$ in the digraph `D` that is $\star$-separated from `J`
by the nodes in `L`.
"""
function star_separation(
  D::Graph{Directed},
  J::Vector{Vertex},
  L::Vector{Vertex}
)
  # 1. Compute the ancestors of L
  L_ancestors = Vertex[]
  for v in L
    union!(L_ancestors, ancestors(D,v))
  end

  # 2. Collect the list of illegal pairs of edges
  illegal_edges = Tuple{Edge, Edge}[]
  for s in vertices(D)
    for t in outneighbors(D, s)
      # Handle cases s -> t -> u, where t in L ("t is a non-collider in L")
      for u in outneighbors(D, t)
        if t in L
          push!(illegal_edges, (Edge(s, t), Edge(t, u)))
        end
      end

      # Handle cases s -> t <- u,  where t not in an(L) ("t is a collider not in an(L)")
      for u in inneighbors(D, t)
        if !(t in L_ancestors)
          push!(illegal_edges, (Edge(s, t), Edge(t, u)))
        end
      end
    end

    for t in inneighbors(D, s)
      # Handle cases s <- t -> u, where t in L ("t is a non-collider in L)
      for u in outneighbors(D, t)
        if t in L
          push!(illegal_edges, (Edge(s, t), Edge(t, u)))
        end
      end

      # Handle cases s <- t <- u, where t in L ("t is a non-collider in L")
      for u in inneighbors(D, t)
        if t in L
          push!(illegal_edges, (Edge(s, t), Edge(t, u)))
        end
      end
    end
  end

  # 3. Perform the star reachability algorithm
  K_prime = star_reachability(D, illegal_edges, J)

  # 4. Determine the *-separated nodes
  K = collect(vertices(D))
  setdiff!(K, K_prime)
  setdiff!(K, J)
  setdiff!(K, L)

  return K
end

#starsep
@doc raw"""
    star_separation(H::Graph{Directed}, i::Vertex, j::Vertex, K::Vector{Vertex})

Tests whether node `i` is $\star$-separated from `j` in `H` given the nodes in `K`
and returns an appropriate boolean. 
"""
function star_separation(H::Graph{Directed}, i::Vertex, j::Vertex, K::Vector{Vertex})
  return in(j, star_separation(H, [i], K))
end

@doc raw"""
    cstar_separation(G::Graph{Directed}, C, K::Vector{Vertex}, i::Vertex, j::Vertex)

Tests whether `i` is $C^\star$-separated from `j` in `G` given the nodes in `K`
and weights `C` on `G`.
"""
function cstar_separation(G::Graph{Directed}, C, K::Vector{Vertex}, i::Vertex, j::Vertex)
  issubset([i,j], K) && return false

  G_star = critical_graph(G, K, C)
  undirected_G_star = get_skeleton(G_star) # This better be a Graphs.Graph
  paths = all_simple_paths(undirected_G_star, i, j;cutoff = 4)

  return all(paths) do p
    !(length(p) == 2 && (has_edge(G_star, i,j) || has_edge(G_star, j, i))) \
    && !(length(p) == 3 && (is_type_b(G_star, p, K) || is_type_c(G_star, p, K))) \
    && !(length(p) == 4 && is_type_d(G_star, p, K)) \
    && !(length(p) == 5 && is_type_e(G_star, p,K)) && true
  end
end

@doc raw"""
    cstar_separation(G::Graph{Directed}, K::Vector{Vertex}, i::Vertex, j::Vertex)

Tests whether `i` is $C^\star$-separated from `j` in `G` given the nodes in `K`
and constant weights on `G`.
"""
cstar_separation(G::Graph{Directed}, K, i, j) = csep(G, constant_weights(G), K, i, j )

## Checks if paths are one of the types (b) - (e) 
function is_type_b(G::Graph{Directed}, P::Vector, K::Vector)
    return issubset([P[1], P[3]], outneighbors(G,P[2])) && !(P[2] in K) 
end 

function is_type_c(G::Graph{Directed}, P::Vector, K::Vector)
    return issubset([P[1], P[3]], inneighbors(G,P[2])) && P[2] in K 

end 

function is_type_d(G::Graph{Directed}, P::Vector, K::Vector)
    bool = false 
    if issubset([P[1], P[3]], outneighbors(G,P[2])) && issubset([P[2],P[4]], inneighbors(G, P[3])) && P[3] in K && !(P[2] in K)
        bool = true
    elseif issubset([P[1], P[3]], inneighbors(G,P[2])) && issubset([P[2],P[4]], outneighbors(G, P[3])) && P[2] in K && !(P[3] in K)
        bool = true 
    end 
    return bool 
end 

function is_type_e(G::Graph{Directed}, P::Vector, K::Vector)
    return issubset([P[1],P[3]], outneighbors(G, P[2])) && issubset([P[3],P[5]], outneighbors(G, P[4])) && P[3] in K && !(P[2] in K) && !(P[4] in K)
end 
