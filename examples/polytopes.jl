include("groebner_weights.jl")
#=
L = [[1,2],[1,3],[2,3],[2,4],[3,4]]
I = ideal_from_DAG_edges(L)
gens(I)
f1,f2,f3 = gens(I)
P1 = newton_polytope(f1)
P2 = newton_polytope(f2)
P3 = newton_polytope(f3)

Psum = P1 + P2 + P3 

F1 = normal_fan(P1)
F2 = normal_fan(P2)
collect(Oscar.vertices(Psum))

=# 

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
G = Maxoids.complete_DAG(4)
P = maxoid_polytope(G)
F = trop_hyperplanes_of_kleene_star(G) 
L = Maxoids.get_edges(G)
facets(P)
V = Oscar.vertices(P)
maximal_cones(F) .|> facets

Q = faces(P,2)[4]
 
issubset(Oscar.vertices(Q), Oscar.vertices(P))
#INPUT: A polytope P, a face Q of P 
#OUTPUT: A vector in the interior of the cone of the normal fan corresponding to F 
function interior_point_of_normal_cone(P,Q)
    QV = Oscar.vertices(Q)
    PV = Oscar.vertices(P)
    Q_vertex_indices = [findfirst(x -> x ==v, PV) for v in QV ]
    full_dim_cones = [normal_cone(P, i) for i in Q_vertex_indices]
    return -relative_interior_point(intersect(full_dim_cones)) 
end 

#verify that the vector is a normal vector to Q 

[dot(interior_point_of_normal_cone(P,Q), v) for v in Oscar.vertices(Q)]

dot(interior_point_of_normal_cone(P,Q), relative_interior_point(Q)) #looks good! 

v = interior_point_of_normal_cone(P,Q)
function matrix_from_vector(G,v)
    C = Maxoids.constant_weights(G)
    L = Maxoids.get_edges(G)
    for k in 1:length(L)
        i,j = L[k]
        C[i,j] = v[k]
    end 
    return C 
end 

C = matrix_from_vector(G,v) 
Q_maxoid = Maxoids.csep_markov(G,C)

Q_maxoid in all_markov_properties(G;generic_only = true)

# INPUT: A graph G 
# OUTPUT: a dictionary indexed by the maxoids of G 
# The values of the dict are the faces of P_G which realize the maxoid 
function face_ci_dict(G)
    P = maxoid_polytope(G)
    face_dict = Dict()
    for i in 0:dim(P)
        for face in faces(P,i)
            v = interior_point_of_normal_cone(P,face)
            maxoid = Maxoids.csep_markov(G, matrix_from_vector(G,v))
            push!(get!(face_dict, maxoid , []), face)
        end 
    end
    return face_dict  
end 
#now write a function 

#look at maxoids corresponding to EDGES: how many of them are properly non-generic? 
matrices1 = matrices_from_fan(F,L;maximal_only = true)
matrices2 = matrices_from_fan_rays(F,L)
maxoids1 = unique([Maxoids.csep_markov(G,c) for c in matrices1])
maxoids2 = [Maxoids.csep_markov(G,c) for c in matrices2]
issubset(maxoids2, maxoids1)
setdiff(maxoids1, maxoids2)


#look at a facet of V, see if the maxoids are related 
facet_V = [p for p in V if p[6] + p[8] - p[10] == 2]
facet = convex_hull(facet_V)
facet_F = normal_fan(convex_hull(facet_V))
facet_matrices = matrices_from_fan(facet_F, sort(Maxoids.get_edges(G));maximal_only = true )
maxoids = [Maxoids.csep_markov(G,c) for c in facet_matrices]
#F2 = trop_hyperplanes_of_kleene_star(G)
matr = matrices_from_fan(F2,sort(Maxoids.get_edges(G)))
maxoids = unique([Maxoids.csep_markov(G,c) for c in matr])




#= 
L = [[1,2],[1,3],[1,4],[2,5],[3,5],[4,5]]
G = Maxoids.DAG_from_edges(L)
P = maxoid_polytope(G) 
Oscar.dim(P)

length(gens(groebner_basis(binomial_ideal_from_DAG_edges(L))))

[
length(gens(groebner_basis(binomial_ideal_from_DAG_edges(sort(Maxoids.get_edges(G)))))) for G in fournodeDAGs
]

[dim(maxoid_polytope(G)) for G in fournodeDAGs]

function skel_from_statements(H::SimpleDiGraph, S::Vector{Any})
    G = Graphs.complete_graph(Graphs.nv(H))
    sort!(S, by = x -> length(x[3]))
    for statement in S
        i, j, K = statement 
        if Graphs.has_edge(G, i, j) && (all( k-> Graphs.has_edge(G, i, k), K) || all( k-> Graphs.has_edge(G, k,j), K)) #line 5 of pseudocode
            Graphs.rem_edge!(G, i, j)
        end
    end
    return G
end

unique([Maxoids.get_edges(skel_from_statements(G, S)) for S in maxoids])

L = sort(filter(x -> x[1] < x[2], collect(Iterators.product(1:6, 1:6))))
G = Maxoids.DAG_from_edges(L)
P = maxoid_polytope(G)


G = Maxoids.complete_digraph(6)
I = ideal_from_DAG(G)
gens(I)

R2 = polynomial_ring(QQ, ["x$i" for i in 1:15])

phi = hom(base_ring(I),R2[1], ["x$i" for i in 1:15])
(gens(I))


#groebner_basis(I)
P = maxoid_polytope(G)

=# 
