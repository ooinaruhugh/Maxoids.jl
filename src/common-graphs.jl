
function complete_DAG(d)
  v = Iterators.repeated(1)
  E = strictly_upper_triangular_matrix(Iterators.take(v, Int(d*(d-1)/2))|>collect)

  return graph_from_adjacency_matrix(Directed,E)
end

complete_3DAG() = complete_DAG(3)
collider() = graph_from_edges(Directed, [[1,3],[2,3]])
three_path() = graph_from_edges(Directed, [[1,2],[2,3]])

diamond() = graph_from_edges(Directed, [[1,2],[1,3],[2,4],[3,4]])
diamond_var() = graph_from_edges(Directed, [[1,4],[1,2],[2,3],[3,4]])
diamond_double_collider() = graph_from_edges(Directed, [[1,3],[2,3],[1,4],[2,4]])
diamond_with_14() = graph_from_edges(Directed, [[1,2],[1,3],[2,4],[3,4],[1,4]])
complete_4DAG() = complete_DAG(4)

cassiopeia() = graph_from_edges(Directed, [[1,4],[2,4],[2,5],[3,5]])
