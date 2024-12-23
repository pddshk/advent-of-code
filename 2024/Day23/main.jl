filename = joinpath(@__DIR__, "input.txt")

using Bijections
using GraphIO.EdgeList
using Graphs
using IterTools

function EdgeList.loadedgelist(io::IO, _::String)
    srcs = String[]
    dsts = String[]
    for line in eachline(io)
        if !startswith(line, "#") && !isempty(line)
            r = r"(\w+)[\s,\-]+(\w+)"
            src_s, dst_s = match(r, line)
            push!(srcs, src_s)
            push!(dsts, dst_s)
        end
    end
    vxset = union(srcs, dsts)
    vxdict = Dict(k => v for (v, k) in enumerate(vxset))

    n_v = length(vxset)
    g = Graphs.Graph(n_v)
    for (u, v) in zip(srcs, dsts)
        add_edge!(g, vxdict[u], vxdict[v])
    end
    return g, vxdict
end

parseinput(filename) = loadgraph(filename, "", EdgeListFormat())

g, vnames = parseinput(filename)

vnames = Bijection(vnames)

function three_cliques(g)
    cliques = maximal_cliques(g)
    filter!(clique -> length(clique) >= 3, cliques)
    res = Set{Set{Int}}()
    for clique in cliques
        length(clique) == 3 && push!(res, Set(clique))
        push!(res, Set.(subsets(clique, 3))...)
    end
    collect.(res)
end

function part1(g, vnames)
    count(three_cliques(g)) do clique
        any(ind -> vnames(ind)[1] == 't', clique)
    end
end

part1(g, vnames)

function part2(g, vnames)
    party = argmax(length, maximal_cliques(g))
    names = vnames.(party)
    sort!(names)
    join(names, ",")
end

part2(g, vnames)