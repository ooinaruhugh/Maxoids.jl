```@docs
polyhedral_separation_set(G::Graph{Directed}, C::Matrix{RealExpr}, i::Int64, j::Int64, L=Int64[])
function polyhedral_generic_set(G::Graph{Directed}, C::Matrix{RealExpr})
maxoid_implication(G::Graph{Directed}, P::Vector{CIStmt}, Q::Vector{CIStmt}; generic_only = false)
maxoid_implication(n::Int, P::Vector{CIStmt}, Q::Vector{CIStmt}; generic_only = false)
```
