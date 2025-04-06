using LinearAlgebra
using Oscar
using Polymake

function root_polytope(::Type{Matrix}, G::Graph, R=ZZ)
  n = n_vertices(G)
  s = edges(G) .|> src
  t = edges(G) .|> dst

  return R.(hcat(I[[s...,1:n...],1:n], I[[t...,1:n...],1:n]))
end

function fundamental_polytope(::Type{Matrix}, G::Graph, R=ZZ)
  A = root_polytope(Matrix, G, R)

  n = n_vertices(G)
  m = n_edges(G)

  return A[1:m+1,n+1:end] - A[1:m+1,1:n]
end

function weight_for_CI(G::Graph{Directed})
  TT = tropical_semiring(max)
  A = [ones(ZZRingElem, n_edges(G)+1) fundamental_polytope(Matrix, G)]

  P = @pm polytope.PointConfiguration(POINTS=A)
  sfan = Polymake.fan.secondary_fan(P) |> polyhedral_fan

  maximal_cones(sfan)

  map(maximal_cones(sfan)) do C
    v = rays_modulo_lineality(C) |> first |> sum
    W = identity_matrix(TT, n_vertices(G))
    for (e,w) in zip(edges(G), v[1:end-1])
      W[src(e), dst(e)] = w
    end

    W
  end
end
