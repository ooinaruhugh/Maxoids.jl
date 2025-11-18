###Functions for generating matrices from fans 

function matrices_from_fan(F,L;maximal_only = false)
    points = [] 
    L = sort(L)
    if maximal_only
        for cone in cones(F, Oscar.dim(F))
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

function matrices_from_fan_facets(F,L)
    points = [] 
    L = sort(L)
    for cone in cones(F, Oscar.dim(F)-1)
        push!(points, -relative_interior_point(cone))
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

function maxoid_fan(G)
  d = Graphs.nv(G)
  C = symbolic_adjacency_matrix(G)
  F = filter(C^d|>Matrix) do f
    length(f)>1
  end
  if isempty(F)
    return []
  else 
    N = newton_polytope.(F)
    NF = normal_fan.(N) .|> Oscar.pm_object
  
    return polyhedral_fan(reduce(Polymake.fan.common_refinement, NF[2:end]; init=first(NF)))
  end 
end

#construct maxoid polytope according to section 3 
#TODO:
function maxoid_polytope(G)
    I = ideal_from_DAG(G)
    polynomials = gens(I)
    if !iszero(I)
        newton_polytopes = [newton_polytope(f) for f in polynomials]
        P = sum(newton_polytopes)
    else 
        zero_vector = canonical_matrix(lex(base_ring(I)))[1,:] - canonical_matrix(lex(base_ring(I)))[1,:] 
        P = convex_hull(zero_vector)
    end 
    return P 


end 

# functions for determining which maxoids the faces of P correspond to 

function interior_point_of_normal_cone(P,Q)
    QV = Oscar.vertices(Q)
    PV = Oscar.vertices(P)
    Q_vertex_indices = [findfirst(x -> x ==v, PV) for v in QV ]
    full_dim_cones = [normal_cone(P, i) for i in Q_vertex_indices]
    return -relative_interior_point(intersect(full_dim_cones)) 
end 

#given a vector in the fan of G, construct the matrix supported on G with the according entries of v
function matrix_from_vector(G,v)
    C = Maxoids.constant_weights(G)
    L = Maxoids.get_edges(G)
    for k in 1:length(L)
        i,j = L[k]
        C[i,j] = v[k]
    end 
    return C 
end 


# INPUT: A graph G 
# OUTPUT: a dictionary indexed by the maxoids of G 
# The values of the dict are the faces of P_G which realize the maxoid 
function face_ci_dict(G)
    P = maxoid_polytope(G)
    face_dict = Dict()
    for i in 0:Oscar.dim(P)
        for face in faces(P,i)
            v = interior_point_of_normal_cone(P,face)
            maxoid = Maxoids.csep_markov(G, matrix_from_vector(G,v))
            push!(get!(face_dict, maxoid , []), face)
        end 
    end
    return face_dict  
end 