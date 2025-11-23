module TikzExt

using Oscar,Maxoids
using TikzPictures,TikzGraphs,Serialization

function DAG_to_pdf(G::Graph{Directed}, name::String)
  _G = Maxoids.to_graphs_graph(G)
  t = TikzGraphs.plot(_G)
  TikzGraphs.save(PDF(name* ".pdf"), t)
end

function graph_to_pdf(G::Graph{Undirected}, name::String)
  _G = Maxoids.to_graphs_graph(G)
  t = TikzGraphs.plot(_G)
  TikzGraphs.save(PDF(name* ".pdf"), t)
end

end
