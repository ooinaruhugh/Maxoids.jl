
@doc raw"""
    cstar_separation(G::Graph{Directed}, C)

Collects all $C^\star$-separation statements of `G` given the weights `C`.
"""
function cstar_separation(G::Graph{Directed}, C)
    L = []
    for i in collect(vertices(G)), j in 1:i-1
        for K in collect(powerset(setdiff(vertices(G), [i,j])))
            if csep(G,C,K,i,j)
                push!(L,[i,j,K])
            end 
        end 
    end 
    return L 
end 

@doc raw"""
    ci_string(G::Graph{Directed}, C)

Prints the [gaussoids.de](https://gaussoids.de/gaussoids)-compatible binary string representing the
CI structure of $C^\star$-separation for `G` with weights `C`.

"""
function ci_string(G::Graph{Directed}, C)
    s = ""
    V = vertices(G)
    for ij in sort(collect(powerset(V, 2, 2)))
        Vij = setdiff(V, ij)
        for k in sort(0:length(V)-2)
            for K in sort(collect(powerset(Vij, k, k)))
                if csep(G,C,K,ij[1],ij[2])
                    s *= "0"
                else
                    s *= "1"
                end
            end 
        end 
    end 
    return s
end
