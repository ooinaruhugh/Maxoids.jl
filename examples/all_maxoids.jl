include("groebner_weights.jl")

function all_markov_properties(G;generic_only = false )
    F = trop_hyperplanes_of_kleene_star(G)
    if F == []
        maxoids = [Maxoids.csep_markov(G, Maxoids.constant_weights(G))]
    else 
        weights = matrices_from_fan(F,Maxoids.get_edges(G);maximal_only = generic_only )

        maxoids = [Maxoids.csep_markov(G,c) for c in weights]
    end 
    return maxoids 
end 

function all_markov_properties_ci_string(G;generic_only = false )
    #F = trop_hyperplanes_of_kleene_star(G)
    if F == []
        maxoids = [Maxoids.ci_string(G, Maxoids.constant_weights(G))]
    else 
        weights = matrices_from_fan(F,Maxoids.get_edges(G);maximal_only = generic_only )

        maxoids = [Maxoids.ci_string(G,c) for c in weights]
    end 
    return maxoids 
end 
#test instance: complete DAG 
G = Maxoids.complete_DAG(4) 
all_markov_properties(G) 
#sampling the fan randomly gives all maxoids after sufficiently many trials 
get_cone_reps(G,100) 
get_cone_reps(G,1000)


# graphs, a list of simple digraphs
# make a dictionary whose keys are the DAGs in graphs
# the values are the different CI structures obtained by sampling the Gröbner fan
function csep_markov_dict(graphs::Vector)

    graph_mps = Dict()

    i = 0

    for G in graphs

        graph_mps[G] = all_markov_properties(G)
        i += 1
    end

    if i % 10 == 0
        print(i)
    end
    
    return graph_mps  
end


#from a list of DAGs, gather all maxoids which can arise from them 
function gather_all_CI(graphs;generic_only = false ) 
    CI = [] 
    for graph in graphs 
        maxoids = all_markov_properties(graph;generic_only )
        for maxoid in maxoids 
            push!(CI, maxoid)
        end 
    end 
    return unique(CI) 
end 

## All maxoids on 4 nodes 
threenodeDAGs = Maxoids.all_top_ordered_TDAGs(3)
#fournode_dict = csep_markov_dict(fournodeDAGs) #dictionary of maxoids, indexed by underlying DAG 
all_threenode_maxoids = gather_all_CI(threenodeDAGs, generic_only = true) #all possible maxoids arising from four node DAGs


## All maxoids on 4 nodes 
fournodeDAGs = Maxoids.all_top_ordered_TDAGs(4)
#fournode_dict = csep_markov_dict(fournodeDAGs) #dictionary of maxoids, indexed by underlying DAG 
all_fournode_maxoids = gather_all_CI(fournodeDAGs, generic_only = false ) #all possible maxoids arising from four node DAGs
all_fournode_generic_maxoids = gather_all_CI(fournodeDAGs, generic_only= true )
# All maxoids on 5 nodes 
fivenodeDAGs = Maxoids.all_top_ordered_TDAGs(5)
#fivenode_dict = csep_markov_dict(fivenodeDAGs)
all_fivenode_maxoids = gather_all_CI(fivenodeDAGs)


sixnodeDAGs = Maxoids.all_top_ordered_TDAGs(6)
all_sixnode_maxoids = gather_all_CI(sixnodeDAGs) #all possible maxoids arising from four node DAGs


sixvar = filter(x -> length(Maxoids.get_edges(x)) < 11, sixnodeDAGs)
G = sixvar[2598]

L = all_markov_properties_ci_string(G;generic_only = true)