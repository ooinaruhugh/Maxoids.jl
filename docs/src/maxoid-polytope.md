Let $\mathbb{R}[E]:= \mathbb{R}[x_{uv} : u\rightarrow v \in E]$ be the polynomial ring with variables
indexed by the edges of a DAG $G$. For each pair of nodes $i$ and $j$ in $G$ with at
least two paths between them, consider the *path polynomial*
```math
f_{ij} = \sum_{\pi \in P(i,j)} \prod_{u \rightarrow v \in \pi}x_{uv} \in \mathbb{R}[E].
```

Each of the path polynomials $f_{ij}$ has a associated *Newton polytope* as the convex hull of
the exponent vectors of each term. We call the Minkowski sum of those Newton polytopes
(or equivalently, the Newton polytope of the product of the $f_{ij}$) the *maxoid polytope* 
of $G$.
```@docs
    maxoid_polytope(G::Graph{Directed})
```

The *maxoid fan* arises as the outer normal fan of the maxoid polytope and provides a polyhedral
subdivision of the space of weights $W\in\mathbb{R}^E$ into types of maxoids.
```@docs
    maxoid_fan(G::Graph{Directed})
```
