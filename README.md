# Maxoids.jl

This repository contains a Julia package for working with conditional independence of max-linear Bayesian networks.
It accompanies the paper *Polyhedral aspects of maxoids* ([arxiv](https://arxiv.org/abs/2504.21068)).

Currently, this package can be installed by executing the following in a Julia REPL.
```jlcon
julia> using Pkg

julia> Pkg.add("Maxoids")
```

Then, one can use this package as follows.
```jlcon
julia> using Maxoids

julia> G = complete_DAG(4)

julia> maxoid(G,[1,2,3,4,5,6])
7-element Vector{Oscar.CIStmt}:
 [1 _||_ 3 | 2]
 [1 _||_ 3 | {2, 4}]
 [1 _||_ 4 | 2]
 [1 _||_ 4 | 3]
 [1 _||_ 4 | {2, 3}]
 [2 _||_ 4 | 3]
 [2 _||_ 4 | {1, 3}]
```
