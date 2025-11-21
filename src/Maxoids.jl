module Maxoids

using Oscar

import Graphs as gr
import Graphs: all_simple_paths

function to_graphs_graph(G::Graph{Directed})
  out = gr.DiGraph(nv(G))
  for e in edges(G)
    gr.add_edge!(out, src(e), dst(e))
  end

  return out
end

include("graphs.jl")

include("weights.jl")
export constant_weight_matrix
export random_weight_matrix
export weights_to_matrix
export matrix_to_weights

include("common-graphs.jl")
export complete_DAG

include("global-markov.jl")
export ci_string

include("separation.jl")
export star_separation
export cstar_separation

include("polyhedra.jl")
export symbolic_adjacency_matrix
export maxoid_polytope
export maxoid_fan




end # module Maxoids
