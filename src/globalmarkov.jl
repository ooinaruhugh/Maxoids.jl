using Oscar
import Oscar: Graph, Directed

#function which gathers all C*-separation statements of a weighted DAG
function csep_markov(G::Graoh{Directed}, C)
    L = []
    for i in collect(Graphs.vertices(G)), j in 1:i-1
        for K in collect(powerset(setdiff(Graphs.vertices(G), [i,j])))
            if csep(G,C,K,i,j)
                push!(L,[i,j,K])
            end 
        end 
    end 
    return L 
end 


# randomly samples coefficient matrices C supported on G `trials` many times
# outputs the list of unique C* Markov properties obtained over all samples
function get_cone_reps(G::SimpleDiGraph, trials::Int64)

    cones = []

    for i in 1:trials
        
        C = randomly_sampled_matrix(G)
        ci_stmts = csep_markov(G, C)

        if ! (ci_stmts in cones)
            push!(cones, ci_stmts)

        end
    end

    return cones
end


# graphs, a list of simple digraphs
# make a dictionary whose keys are the DAGs in graphs
# the values are the different CI structures obtained by sampling random matrices C
# the number of samples per graph is given by `trials`
function csep_markov_dict(graphs::Vector, trials::Int64)

    graph_mps = Dict()

    i = 0

    for G in graphs

        graph_mps[G] = get_cone_reps(G, trials)
        i += 1
    end

    if i % 10 == 0
        print(i)
    end
    
    return graph_mps  
end


# graph_mps, is a dictionary of the form created by csep_markov_dict
# the output is the set of all possible CI structures produced by C*-separation
function all_markov_properties(graph_mps)

    return collect(Set(reduce(vcat, values(graph_mps))))
end

# graph_mps, a dictionary of the form produced by csep_markov_dict
# ci_struct, a list of CI statements of the form [i, j, K]
# finds all graphs in the dictionary whose markov property under C*-separation is ci_struct
function find_compatible_graphs(graph_mps, ci_struct, KeepDenseGraphs = false)

    graphs = [G for G in keys(graph_mps) if ci_struct in graph_mps[G]]

    if KeepDenseGraphs 
        return graphs
    end

    min_edges = minimum(map(ne, graphs))

    return [G for G in graphs if ne(G) == min_edges]
end

#TODO: Figure out exactly how we want to organize the CI data. 
#One option could be to associate each connected TDAG to its fan. 


## Some examples on 4 node DAGs

#fournode_TDAGs = all_top_ordered_TDAGs(4) #all TDAGs with connected undirected skeleton
#
#fournode_dict = csep_markov_dict(fournode_TDAGs, 1000) #construct fans
#
#
#fournode_markov_properties = all_markov_properties(fournode_dict) #all possible CI structures on 4 nodes? 
#
##How many graphs have the same CI structure as the diamond?
#
#find_compatible_graphs(fournode_dict, csep_markov(diamond, constant_weights(diamond))) #throws an error: the CI structure of the diamond with constant weights is highly non-generic!
#
#C = constant_weights(diamond)
#
#C[3,4] = 2 #make 1-3-4 the unique critical 1-4 path
#
#diamond_csepmarkov = csep_markov(diamond, C)
#
#find_compatible_graphs(fournode_dict, diamond_csepmarkov) #this is the transitive closure of the diamond 
#
#filter(i -> length(find_compatible_graphs(fournode_dict, i))>1, fournode_markov_properties) #every CI structure in fournode_dict is realised by exactly one TDAG



