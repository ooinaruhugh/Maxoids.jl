using Maxoids, Oscar, Graphs

 

#recovers the ideal from rmk 2.14 from the edges of a DAG 

function ideal_from_DAG_edges(L)

    G = Maxoids.DAG_from_edges(L)
    G_o = Oscar.graph_from_edges(Directed, L)
    n = Graphs.nv(G)
    S = gaussian_ring(n)
    M = graphical_model(G_o, S, cached = true )
    W, K = M.param_gens 

    R = M.param_ring 

    I_gens = []


    for i in 1:n
        for j in i:n
            if length(collect(all_simple_paths(G,i,j))) > 1 
                paths = all_simple_paths(G,i,j)
                poly = 0 
                for path in paths
                    term = prod([W[path[k],path[k+1]] for k in 1:length(path)-1])
                    poly += term
                end 
                push!(I_gens, poly)

            end 

        end 
    end 

    I = ideal(I_gens)
    return I 

end 

function ideal_from_DAG(G::SimpleDiGraph)
    return ideal_from_DAG_edges(Maxoids.get_edges(G))
end 

#constructs the Gröbner fan from Rmk 2.14, given the edge set L of a DAG
function fan_from_DAG_edges(L)

    return(groebner_fan(ideal_from_DAG_edges(L)))

end


function fan_from_DAG(G::SimpleDiGraph)
    return fan_from_DAG_edges(Maxoids.get_edges(G))
end 

#recovers a  matrix for each cone in the fan F of the DAG G with edge set L
#TODO: add some kind of "with_lower_dimensional" optional argument 
function matrices_from_fan(F,L)
    points = [] 

    for d in 1:Oscar.dim(F)
        for cone in cones(F, d)
            push!(points, relative_interior_point(cone))
        end 
    end 
    
    weight_matrices = [] 
    for point in points 
        C = Maxoids.constant_weights(Maxoids.DAG_from_edges(L))
        for k in 1:length(L)
            i,j = L[k]
            C[i,j] = point[k]
        end 
        push!(weight_matrices, C)
    end 
    return weight_matrices
end 

#gathers a list of matrices supported on G, one for each cone in the fan (including non-generic)
function matrices_from_DAG(G::SimpleDiGraph)
    F = fan_from_DAG(G)
    L = Maxoids.get_edges(G)
    return matrices_from_fan(F,L)
end 
##Diamond example (2.15)

G = Maxoids.complete_DAG(3)
C = matrices_from_DAG(G)
maxoid = unique([Maxoids.csep_markov(G,c) for c in C ])
