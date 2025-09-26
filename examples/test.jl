using Maxoids
#using Graphs
include("groebner_weights.jl")




#potential problem example: 

L = [[1,3],[1,4],[2,3],[2,4],[3,4]]
I1 = ideal_from_DAG_edges(L)
I2 = binomial_ideal_from_DAG_edges(L)

I1 == I2 
groebner_basis(I1)
G2 = groebner_basis(I2)
F1 = groebner_fan(I1)
F2 = groebner_fan(I2)
facets.(maximal_cones(F1)) 
facets.(maximal_cones(F2))
#matrices_from_fan(F1,L)

weights1 = matrices_from_fan(F1,L;maximal_only = true  )

weights2 = matrices_from_fan(F2,L;maximal_only = true  )


maxoids1 = unique([Maxoids.csep_markov(Maxoids.DAG_from_edges(L),c) for c in weights1])
maxoids2 = unique([Maxoids.csep_markov(Maxoids.DAG_from_edges(L),c) for c in weights2])

maxoids1 == maxoids2 

#define hyperplane of intersection

H = [0 1 -1 -1 1;0 -1 1 1 -1]
plane = cone_from_inequalities(H)
cns = [intersect(plane,c) for c in maximal_cones(F2)]

#only the second ideal gives all generic maxoids

#look at the complete DAG

L = [[1,2],[1,3],[2,4],[2,5],[3,4],[3,5],[4,6],[5,6]]

I = binomial_ideal_from_DAG_edges(L)

G = groebner_basis(I;ordering = lex(base_ring(I))) #one term doesn't correspond to a path-connected pair 

F = groebner_fan(I)


weights = matrices_from_fan(F3,L;maximal_only = true  )
maxoids = unique([Maxoids.csep_markov(Maxoids.DAG_from_edges(L),c) for c in weights])

function get_cone_reps(G::SimpleDiGraph, trials::Int64)

    cones = []

    for i in 1:trials
        
        C = Maxoids.randomly_sampled_matrix(G)
        ci_stmts = Maxoids.csep_markov(G, C)

        if ! (ci_stmts in cones)
            push!(cones, ci_stmts)

        end
    end

    return cones
end
#=
function perturb(C)
    Cvar = copy(C)
    for i in 1:size(C)[1]
        for j in in 1:size(C)[2]
            if 
            Cvar[i,j]
=# 

function test_claim(G::SimpleDiGraph, trials::Int64)
    #maxoids1 = get_cone_reps(G,trials)
    L = Maxoids.get_edges(G)
    I = binomial_ideal_from_DAG_edges(L)
    if !iszero(I)
        F1 = trop_hyperplanes_of_kleene_star(G)
        F2= groebner_fan(I)
        weights1 = matrices_from_fan(F1,L;maximal_only = true  )
        weights2 = matrices_from_fan(F2,L;maximal_only = true  )

        maxoids1 = unique([Maxoids.csep_markov(G,c) for c in weights1])
        maxoids2 = unique([Maxoids.csep_markov(G,c) for c in weights2])
        #return Set(maxoids2) == Set(maxoids1), issubset(maxoids1, maxoids2)
        return length(maxoids2), length(maximal_cones(F2)), length(maximal_cones(F1))
    else
        return (true,true)
    end 
end 
emp_maxoids = get_cone_reps(Maxoids.DAG_from_edges(L),100)

P = Maxoids.all_top_ordered_TDAGs(4)

function all_markov_properties(G)
    L = Maxoids.get_edges(G)
    I = binomial_ideal_from_DAG_edges(L)
    if !iszero(I)
        F = groebner_fan(I)
        weights = matrices_from_fan(F,L)

        maxoids = unique([Maxoids.csep_markov(G,c) for c in weights])
        return maxoids
    else
        return [Maxoids.csep_markov(G,Maxoids.constant_weights(G))]
    end 
end 


#complete DAG 
L = [[1,2],[1,3],[1,4],[2,3],[2,4],[3,4]]
G = Maxoids.DAG_from_edges(L)

fournodeDAGs = Maxoids.all_top_ordered_TDAGs(4)

markov_properties = [(G,all_markov_properties(G)) for G in Maxoids.all_top_ordered_TDAGs(4)]

fivenodeDAGs = Maxoids.all_top_ordered_TDAGs(5)

markov_properties = [(G,all_markov_properties(G)) for G in Maxoids.all_top_ordered_TDAGs(5)]
