module OscarInterop

using LinearAlgebra
using Oscar
using Polymake

import Graphs as gr
import Graphs: SimpleDiGraph
import Oscar: Graph, Directed

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

function Oscar.Graph{Directed}(H::gr.SimpleDiGraph) 
  n = gr.nv(H)
  G = Graph{Directed}(n)

  for e in gr.edges(H)
    add_edge!(G, gr.src(e), gr.dst(e))
  end

  return G
end

function secondary_fan(A::Matrix)
  P = @pm polytope.PointConfiguration(POINTS=A)
  sfan = Polymake.fan.secondary_fan(P) |> polyhedral_fan

  return sfan
end

function weights_for_cones(G::Graph{Directed}; with_lower_dimensional=false)
  TT = tropical_semiring(max)
  n = n_vertices(G)
  A = [ones(ZZRingElem, n_edges(G)+1) fundamental_polytope(Matrix, G)]

  sfan = secondary_fan(A)

  O = identity_matrix(TT, n)
  for e in edges(G)
    O[src(e), dst(e)] = 0
  end

  if with_lower_dimensional
    if rays_modulo_lineality(sfan) |> first |> isempty
      return [O]
    else 
      return [map(eachrow(cones(sfan))) do i
        v = (rays_modulo_lineality(sfan) |> first)[i] |> sum
        W = identity_matrix(TT, n)

        for (e,w) in zip(edges(G), v[1:end-1])
          W[src(e), dst(e)] = w
        end

        W
      end...,O]
    end
  else
    return map(maximal_cones(sfan)) do C
      v = rays_modulo_lineality(C) |> first |> sum
      W = identity_matrix(TT, n_vertices(G))
      for (e,w) in zip(edges(G), v[1:end-1])
        W[src(e), dst(e)] = w
      end

      W
    end
  end
end

function weights_for_cones(H::SimpleDiGraph; with_lower_dimensional=false)
  G = Graph{Directed}(H)
  return weights_for_cones(G; with_lower_dimensional=with_lower_dimensional)
end

export secondary_fan
export weights_for_cones

end
