using Maxoids, Oscar, Graphs

 

#recovers the ideal from rmk 2.14 from the edges of a DAG 

#TODO: handle case where edge set is empty 
function ideal_from_DAG_edges(L)
    G = Maxoids.DAG_from_edges(L)
    n = Graphs.nv(G)
    G_o = Oscar.graph_from_edges(Directed, L)
    l_indices = [Tuple([e[1],e[2]]) for e in L]
    R, c = polynomial_ring(QQ, ["c[$(i), $(j)]" for (i,j) in l_indices])
    c_dict = Dict([l_indices[i] => c[i] for i in 1:length(l_indices)])
    I_gens = []
    for i in 1:n
        for j in i:n
            if length(collect(all_simple_paths(G,i,j))) > 1 
                paths = all_simple_paths(G,i,j)
                poly = 0 
                for path in paths
                    term = prod([c_dict[path[k],path[k+1]] for k in 1:length(path)-1])
                    poly += term
                end 
                push!(I_gens, poly)

            end 

        end 
    end     
    I = isempty(I_gens) ? ideal(zero(R)) : ideal(I_gens)
    return I 
end 

function binomial_ideal_from_DAG_edges(L)
    G = Maxoids.DAG_from_edges(L)
    n = Graphs.nv(G)
    G_o = Oscar.graph_from_edges(Directed, L)
    l_indices = [Tuple([e[1],e[2]]) for e in L]
    R, c = polynomial_ring(QQ, ["c[$(i), $(j)]" for (i,j) in l_indices])
    c_dict = Dict([l_indices[i] => c[i] for i in 1:length(l_indices)])
    I_gens = []
    for i in 1:n
        for j in i:n
            if length(collect(all_simple_paths(G,i,j))) > 1 
                paths = collect(all_simple_paths(G,i,j))
                for path1 in paths
                    for path2 in paths 
                        if path1 != path2 && length(intersect(path1,path2)) == 2
                            term1 = prod([c_dict[path1[k],path1[k+1]] for k in 1:length(path1)-1])
                            term2 = prod([c_dict[path2[k],path2[k+1]] for k in 1:length(path2)-1])
                            poly = term1-term2
                            push!(I_gens,poly)
                        end 
                    end 


                end        
            end 

        end 
    end     
    I = isempty(I_gens) ? ideal(zero(R)) : ideal(I_gens)
    return I 
end 


function ideal_from_DAG(G::SimpleDiGraph)
    return ideal_from_DAG_edges(Maxoids.get_edges(G))
end 

#constructs the Gröbner fan from Rmk 2.14, given the edge set L of a DAG
function fan_from_DAG_edges(L)

    return(groebner_fan(binomial_ideal_from_DAG_edges(L)))

end


function fan_from_DAG(G::SimpleDiGraph)
    return fan_from_DAG_edges(Maxoids.get_edges(G))
end 



###Functions for generating fans matrices from fans 

function matrices_from_fan(F,L;maximal_only = false)
    points = [] 
    if maximal_only
        for cone in cones(F, dim(F))
            push!(points, -relative_interior_point(cone))
        end  
    else 

        for d in 1:Oscar.dim(F)
            for cone in cones(F, d)
                push!(points, -relative_interior_point(cone))
            end 
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

##get Gröbner cone
function bounding_vectors(I)
  gens_by_terms = terms.(I; ordering=ordering(I))
  
  v = map(Iterators.peel.(gens_by_terms)) do (lead,tail)
      Ref(leading_exponent_vector(lead)) .- leading_exponent_vector.(tail)
  end

  return unique!(reduce(vcat, v))
end




function symbolic_adjacency_matrix(G)
  d = Graphs.nv(G)
  n = Graphs.ne(G)

  R,X = polynomial_ring(QQ, ["e$(Graphs.src(e))$(Graphs.dst(e))" for e in Graphs.edges(G)])
  C = identity_matrix(R,d)

  for (x,e) in zip(X,Graphs.edges(G))
    C[Graphs.src(e),Graphs.dst(e)] = x
  end

  return C
end

function trop_hyperplanes_of_kleene_star(G)
  d = Graphs.nv(G)
  C = symbolic_adjacency_matrix(G)
  F = filter(C^d|>Matrix) do f
    length(f)>1
  end

  N = newton_polytope.(F)
  NF = normal_fan.(N) .|> Oscar.pm_object
  
  return polyhedral_fan(reduce(Polymake.fan.common_refinement, NF[2:end]; init=first(NF)))
end

#sample the fan randomly 
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