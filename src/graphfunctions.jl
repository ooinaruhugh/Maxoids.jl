#Generic graph functions. 

using Graphs, TikzGraphs, TikzPictures, Serialization, Combinatorics, Distributions
import Oscar: tropical_semiring, zero, matrix, ncols 


#general edge to graph, graph to pdf functionality 

function DAG_to_pdf(H::SimpleDiGraph, name::String)
    t = TikzGraphs.plot(H)
    TikzGraphs.save(PDF(name* ".pdf"), t)
end 

function graph_to_pdf(H::SimpleGraph, name::String)
    t = TikzGraphs.plot(H)
    TikzGraphs.save(PDF(name* ".pdf"), t)
end 

function _graph_from_edges(A::Vector)
    n = maximum([max(a[1],a[2]) for a in A ]) 
    D = SimpleGraph(n,0)
    for (i,j) in A 
        Graphs.add_edge!(D, i, j)
    end 
    return D 
end  

function DAG_from_edges(A::Vector)
    n = maximum([max(a[1],a[2]) for a in A ]) 
    D = SimpleDiGraph(n,0)
    for (i,j) in A 
        Graphs.add_edge!(D, i, j)
    end 
    return D 
end  

function DAG_from_edges(n, E)
    G = SimpleDiGraph(n,0)
    for edge in E
        Graphs.add_edge!(G, edge[1],edge[2])
    end
    G
end 

function get_edges(G::SimpleDiGraph{Int64})
    n = nv(G)
    return sort([[i,j] for i in 1:n ,j in 1:n if has_edge(G,i,j)])
end 

function get_edges(G::SimpleGraph{Int64})
    n = nv(G)
    return sort([[i,j] for i in 1:n, j in 1:n if (has_edge(G,i,j) && i < j)])
end 

function get_skeleton(H::SimpleDiGraph)
    n = Graphs.nv(H)
    G = SimpleGraph(n,0)
    for edge in Graphs.edges(H)
        Graphs.add_edge!(G, edge)
    end
    return G 
end 

#functions which collect all DAGs on n nodes with certain properties

function all_DAGs(n::Int64)
    D = []
    L = [(i,j) for i in 1:n, j in 1:n if i<j]
    perms = permutations(1:n)
    for E in collect(powerset(L))
        if !isempty(E) 
            for perm in perms 
                F = [(perm[i],perm[j]) for (i,j) in E] 

                push!(D, sort(F))
            end 

        end 

    end     
    push!(D, [])
    return [DAG_from_edges(n, E) for E in collect(Set(D))]

end

function all_top_ordered_DAGs(n::Int64)
    D = []
    L = [(i,j) for i in 1:n, j in 1:n if i<j]
    for E in collect(powerset(L))
        G = DAG_from_edges(n, E)
        push!(D, G)
    end 
    return D 
end 

function all_top_ordered_TDAGs(n::Int64)
    D = all_top_ordered_DAGs(n)
    T = []
    for G in D
        if G == transitiveclosure(G) && is_connected(get_skeleton(G)) && nv(G) == n 
            push!(T, G)
        end 
    end 
    return T
end 



##Weighted DAG functionality 


# make the kleene star of C
function kleene_star(C)

    sum(map(d -> C^d, 0:ncols(C)-1))
end



# compute the weight of a path
function path_weight(C, p)

    prod(map(i -> C[p[i], p[i+1]] , 1:length(p)-1))
end



#compute the weighted transitive reduction of G w.r.t. the matrix C 
#contains (i,j) iff this edge is the UNIQUE critical i-j path in G
function wtr(G::SimpleDiGraph, C)
    #iterate through edges of G and check whether the edge is the critical path
    #if this is not the case, remove 
    G_tr = SimpleDiGraph(nv(G), 0)
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

#return the matrix supported on G with constant edge weights = 1 
function constant_weights(G::SimpleDiGraph)
    n = Graphs.nv(G)
    C = matrix(tropical_semiring(max), [[zero(tropical_semiring(max)) for i in 1:n] for j in 1:n])
    for i in 1:n , j in 1:n 
        if Graphs.has_edge(G, i, j)
            C[i,j] = 1 
        end 
    end 
    return C
end 

#return a randomly sampled matrix supported on G 
function randomly_sampled_matrix(G::SimpleDiGraph)
    n = Graphs.nv(G)
    C = matrix(tropical_semiring(max), [[zero(tropical_semiring(max)) for i in 1:n] for j in 1:n])
    for i in 1:n , j in 1:n 
        if Graphs.has_edge(G, i, j)
            C[i,j] = rand(1:10000)
        end 
    end 
    return C

end 

##Critical graph functionality 


# make the critical DAG given a dag G, a conditioning set K, and weights C
function critical_graph(G::SimpleDiGraph, K::Vector, C)

    V = Graphs.vertices(G)

    # make the kleene star to test for max weighted paths
    Cstar = kleene_star(C);

    # make an empty graph which will be our critical graph that we add edges to
    Gstar = SimpleDiGraph(length(V), 0)

    # loop over every possible edge
    for e in Iterators.product(V, V)

        (i, j) = e

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
            Graphs.add_edge!(Gstar, (i, j))
        end
    end

    return Gstar
end

function reachability_graph(G::SimpleDiGraph, K::Vector)
    V = Graphs.vertices(G)
        # make an empty graph which will be our critical graph that we add edges to
    Gstar = SimpleDiGraph(length(V), 0)

    # loop over every possible edge
    for e in Iterators.product(V, V)

        (i, j) = e

        if i == j
            continue
        end

        # collect paths
        paths = collect(all_simple_paths(G, i, j))
        
        if length(paths) == 0
            continue
        end

        # check if any path factors through K
        # if so we do not add the edge [i, j] otherwise we add it
        if any(map(p -> any(map(k -> k in p[2:length(p)-1], K)), paths))
            continue
        else
            Graphs.add_edge!(Gstar, (i, j))
        end
    end
    return Gstar
end 

## Checks if paths are one of the types (b) - (e) 
function is_type_b(G::SimpleDiGraph, P::Vector, K::Vector)
    return  issubset([P[1], P[3]], Graphs.outneighbors(G,P[2])) && !(P[2] in K) 
end 

function is_type_c(G::SimpleDiGraph, P::Vector, K::Vector)
    return issubset([P[1], P[3]], Graphs.inneighbors(G,P[2])) && P[2] in K 

end 

function is_type_d(G::SimpleDiGraph, P::Vector, K::Vector)
    bool = false 
    if issubset([P[1], P[3]], Graphs.outneighbors(G,P[2])) && issubset([P[2],P[4]], Graphs.inneighbors(G, P[3])) && P[3] in K && !(P[2] in K)
        bool = true
    elseif issubset([P[1], P[3]], Graphs.inneighbors(G,P[2])) && issubset([P[2],P[4]], Graphs.outneighbors(G, P[3])) && P[2] in K && !(P[3] in K)
        bool = true 
    end 
    return bool 
end 

function is_type_e(G::SimpleDiGraph, P::Vector, K::Vector)
    return issubset([P[1],P[3]], Graphs.outneighbors(G, P[2])) && issubset([P[3],P[5]], Graphs.outneighbors(G, P[4])) && P[3] in K && !(P[2] in K) && !(P[4] in K)
end 
