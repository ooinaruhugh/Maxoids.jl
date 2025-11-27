function path_term(p, C)
    @assert length(p) > 1
    terms = [ C[p[i], p[i+1]] for i in 1:length(p)-1 ]
    length(terms) == 1 ? terms[1] : +(terms...)
end

parents(G, i) = inneighbors(G, i)
children(G, i) = outneighbors(G, i)

# Return a polyhedral condition on C which expresses that i -> j is an edge
# in the critical DAG for G with respect to C and L. We assume that G is
# transitively closed.
function edge_in_critical_graph(G, C, i, j, L)
    @assert transitively_closed(G)
    if !has_edge(G, i, j)
        return false
    end
    with_L = []
    without_L = []
    for p in all_simple_paths(G, i, j)
        # Endpoints don't matter
        if length(intersect(p[2:end-1], L)) > 0
            push!(with_L, p)
        else
            push!(without_L, p)
        end
    end
    if length(with_L) == 0
        return true
    end
    if length(without_L) == 0
        return false
    end
    and([or([path_term(p, C) < path_term(q, C) for q in without_L]...) for p in with_L]...)
end

@doc raw"""
    polyhedral_separation_set(G::Graph{Directed}, C::Matrix{RealExpr}, i::Int64, j::Int64, L=Int64[])

Computes a description of the polyhedral set of all matrices `C` which
satisfy the C*-separation `[i _||_ j | L]` with respect to `G`.

The graph `G` must be transitively closed.
"""
function polyhedral_separation_set(G::Graph{Directed}, C::Matrix{RealExpr}, i::Int64, j::Int64, L=Int64[])
    @assert transitively_closed(G)
    type_a = or(
        edge_in_critical_graph(G, C, i, j, L),
        edge_in_critical_graph(G, C, j, i, L)
    )
    type_b = false
    for p in setdiff(intersect(parents(G, i), parents(G, j)), L)
        type_b = or(type_b, and(
            edge_in_critical_graph(G, C, p, i, L),
            edge_in_critical_graph(G, C, p, j, L)
        ))
    end
    type_c = false
    for c in intersect(children(G, i), children(G, j), L)
        type_c = or(type_c, and(
            edge_in_critical_graph(G, C, i, c, L),
            edge_in_critical_graph(G, C, j, c, L)
        ))
    end
    type_d = false
    for c in intersect(children(G, j), L)
        for p in setdiff(intersect(parents(G, i), parents(G, c)), L)
            type_d = or(type_d, and(
                edge_in_critical_graph(G, C, p, i, L),
                edge_in_critical_graph(G, C, p, c, L),
                edge_in_critical_graph(G, C, j, c, L),
            ))
        end
    end
    for c in intersect(children(G, i), L)
        for p in setdiff(intersect(parents(G, j), parents(G, c)), L)
            type_d = or(type_d, and(
                edge_in_critical_graph(G, C, i, c, L),
                edge_in_critical_graph(G, C, p, c, L),
                edge_in_critical_graph(G, C, p, j, L),
            ))
        end
    end
    type_e = false
    for p in setdiff(parents(G, i), L)
        for q in setdiff(parents(G, j), L)
            for c in intersect(children(G, p), children(G, q), L)
                type_e = or(type_e, and(
                    edge_in_critical_graph(G, C, p, i, L),
                    edge_in_critical_graph(G, C, p, c, L),
                    edge_in_critical_graph(G, C, q, j, L),
                    edge_in_critical_graph(G, C, q, c, L),
                ))
            end
        end
    end
    not(or(type_a, type_b, type_c, type_d, type_e))
end

@doc raw"""
    polyhedral_generic_set(G::Graph{Directed}, C::Matrix{RealExpr})

Computes a description of the set of generic weight matrices for `G`.
For these matrices no two distinct paths between any pair of nodes has
the same weight.
"""
function polyhedral_generic_set(G::Graph{Directed}, C::Matrix{RealExpr})
    n = nv(G)
    gen = true
    for i in 1:n
        for j in 1:n
            P = collect(all_simple_paths(G, i, j))
            for (p, q) in powerset(P, 2, 2)
                gen = and(gen, path_term(p, C) != path_term(q, C))
            end
        end
    end
    gen
end

@doc raw"""
    maxoid_implication(G::Graph{Directed}, P::Vector{CIStmt}, Q::Vector{CIStmt}; generic_only=false)

Test if every maxoid associated to `G` satisfies the implication `and(P) => or(Q)`
(the local CI implication problem). If `generic_only` is `true`, then only generic
maxoids for `G` are tested.

Returns a tuple consisting of a boolean to indicate if the implication is true,
and if it is false, also a counterexample matrix.

The graph `G` must be transitively closed.
"""
function maxoid_implication(G::Graph{Directed}, P::Vector{CIStmt}, Q::Vector{CIStmt}; generic_only = false)
    # Without edges, all implications are true.
    if length(edges(G)) == 0
        return (true, nothing)
    end
    n = nv(G)
    @satvariable(C[1:n, 1:n], Real)
    # Force existing edges to have a value
    @satvariable(lb, Real)
    edge = and(C[src(e),dst(e)] >= lb for e in edges(G))
    prem = and(polyhedral_separation_set(G, C, p.I[1], p.J[1], p.K) for p in P)
    conc = or( polyhedral_separation_set(G, C, q.I[1], q.J[1], q.K) for q in Q)
    feas = edge
    # sat cannot deal with constant input formulas.
    if prem === false || conc === true
        feas = and(feas, lb < lb)
    else
        feas = and(feas, prem, not(conc))
    end
    if generic_only
        feas = and(feas, polyhedral_generic_set(G, C))
    end
    res = sat!(feas)
    (res == :UNSAT, res == :UNSAT ? nothing : replace(value(C), nothing => -Inf))
end

maxoid_implication(G::Graph{Directed}, PQ::Pair; generic_only = false) = maxoid_implication(G, PQ[1], PQ[2]; generic_only=generic_only)

@doc raw"""
    maxoid_implication(n::Int, P::Vector{CIStmt}, Q::Vector{CIStmt}; generic_only=false)

Test if every maxoid on `n` nodes satisfies the implication `and(P) => or(Q)`
(the global CI implication problem). If `generic_only` is `true`, then only
those maxoids are tested which are generic for some graph.

Returns a tuple consisting of a boolean to indicate if the implication is true,
and if it is false, also a graph and a corresponding counterexample matrix.

The graph `G` must be transitively closed.
"""
function maxoid_implication(n::Int, P::Vector{CIStmt}, Q::Vector{CIStmt}; generic_only = false)
    for G in all_TDAGs(n)
        res, cert = maxoid_implication(G, P, Q; generic_only=generic_only)
        if !res
            return (res, [src(e) => dst(e) for e in edges(G)], cert)
        end
    end
    return (true, nothing, nothing)
end

maxoid_implication(n::Int, PQ::Pair; generic_only = false) = maxoid_implication(n, PQ[1], PQ[2]; generic_only=generic_only)
