```@docs
    cstar_separation(G::Graph{Directed}, C)
    cstar_separation(G::Graph{Directed}, W::Vector{<:RingElement})
```

```@docs
    cstar_separation(G::Graph{Directed}, C, i::Vertex, j::Vertex, K::Vector{Vertex})
    cstar_separation(G::Graph{Directed}, W::AbstractVector{<:RingElement}, i::Vertex, j::Vertex, K::Vector{Vertex})
    cstar_separation(G::Graph{Directed}, i::Vertex, j::Vertex, K::Vector{Vertex})
```

```@docs
    star_separation(H::Graph{Directed}, i::Vertex, j::Vertex, K::Vector{Vertex})
```

```@docs
    ci_string(G::Graph{Directed}, C)
```

```@docs
    all_markov_properties(G::Graph{Directed}; generic_only = false)
    all_markov_properties(G::AbstractVector{Graph{Directed}}; generic_only = false)
```
