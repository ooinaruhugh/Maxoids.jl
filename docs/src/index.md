# Maxoids.jl

[Maxoids.jl](https://github.com/ooinaruhugh/Maxoids.jl#readme) provides code to work with conditional independence statements
of max-linear Bayeisan networks. This package accompanies the paper *Polyhedral aspects of maxoids* ([arxiv](https://arxiv.org/abs/2504.21068)).

## Setup
Currently, this package can be installed by executing the following in a Julia REPL.
```jlcon
julia> using Pkg

julia> Pkg.add("https://github.com/ooinaruhugh/PolyhedralAspectsofMaxoids")
```

## Quick start
```jlcon
julia> using Maxoids

julia> G = complete_DAG(4) 
Directed graph with 4 nodes and the following edges:
(1, 2)(1, 3)(1, 4)(2, 3)(2, 4)(3, 4)

julia> maxoid(G, [1,2,3,4,5,6]) 
7-element Vector{CIStmt}:
 [1 _||_ 3 | 2]
 [1 _||_ 3 | {2, 4}]
 [1 _||_ 4 | 2]
 [1 _||_ 4 | 3]
 [1 _||_ 4 | {2, 3}]
 [2 _||_ 4 | 3]
 [2 _||_ 4 | {1, 3}]
```

