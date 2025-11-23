module Maxoids

using Combinatorics
using Oscar
import Oscar: Edge, Graph, Directed

const Vertex = Int64
const TaggedEdge = Pair{Edge,Bool}
const CIStatement = Tuple{Vertex,Vertex,Vector{Vertex}}

export Vertex
export CIStatement

TaggedEdge(i::Vertex,j::Vertex,tag::Bool) = TaggedEdge(Edge(i,j),tag)

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
export critical_graph
export transitive_closure
export kleene_star
export weighted_transitive_reduction
export all_DAGs
export all_top_ordered_DAGs
export all_top_ordered_TDAGs

include("weights.jl")
export constant_weight_matrix
export random_weight_matrix
export weights_to_tropical_matrix
export matrix_to_weights

include("common-graphs.jl")
export complete_DAG

include("global-markov.jl")
export all_markov_properties
export all_markov_properties_as_ci_string
export ci_string
export ci_to_face_dict
export dag_to_maxoid_dict

include("separation.jl")
export star_separation
export cstar_separation

include("polyhedra.jl")
export symbolic_adjacency_matrix
export maxoid_polytope
export maxoid_fan




end # module Maxoids
