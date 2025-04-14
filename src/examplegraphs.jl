using Oscar

collider = graph_from_edges(Directed, [[1,3], [2,3]])
path_graph(n) = graph_from_edges(Directed, [ [i, i+1] for i in 1:(n-1) ])

function complete_DAG(n)
  G = Graph{Directed}(n);

  for j in 1:n
      for i in (j+1):n
          add_edge!(G, j, i)
      end
  end

  return G
end

# On 4 nodes

#diamond = graph_from_edges
#diamond = DAG_from_edges([(1,2),(1,3),(2,4),(3,4)])
#
#diamond_var = DAG_from_edges([[1,4],[1,2],[2,3],[3,4]]) #non-unique 1-4 path
#
#diamond_double_collider = DAG_from_edges([[1,3],[2,3],[1,4],[2,4]])
#
#diamond_with_14 = DAG_from_edges([(1,2),(1,3),(2,4),(3,4), (1,4)])
#
#complete_4DAG = DAG_from_edges([[1,2],[1,3],[1,4],[2,3],[2,4],[3,4]])
#
## On >4 nodes 
#
#cassio = DAG_from_edges([(1,4),(2,4), (2,5) ,(3,5)])
#
#longcassio_edges = [(7,6),(6,1),(1,4),(2,4),(2,5),(3,5),(8,3),(9,8)]
#
#longcassio = DAG_from_edges(longcassio_edges)
#
#
#diamondcassio_edges = [(1,4),(2,4), (2,5) ,(3,5), (1,6),(2,6)]
#
#diamondcassio = DAG_from_edges(diamondcassio_edges)
#
#pyramid =DAG_from_edges([(4,6),(5,6), (1,4),(2,4), (2,5) ,(3,5) ])
#
#double_pyramid = DAG_from_edges([(1,6),(2,6),(2,7),(3,7),(3,8),(4,8),(4,9),(5,9), (6,10),(7,10),(8,11),(9,11)])
#
#
#cassiovariant = DAG_from_edges([(1,4),(2,4), (2,5) ,(3,5),(4,6), (3,6), (1,7),(7,3)])
#
#
#bigv = DAG_from_edges([(1,4),(2,4), (2,5) ,(3,5),(6,4),(6,5)])
#
#
#M = DAG_from_edges([(1,2),(2,3),(4,3),(4,5)])
