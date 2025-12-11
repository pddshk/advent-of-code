using DataStructures
using Bijections
using Graphs
using Test

const filename = joinpath(@__DIR__, "input.txt")

function parseinput(filename)
    vertices = Set{String}()
    edges = Dict{String, Vector{String}}()
    for line in eachline(filename)
        src, dsts... = split(line)
        src = src[1:3]
        edges[src] = String.(dsts)
        push!(vertices, src, dsts...)
    end
    edges["out"] = String[]
    return construct_graph(vertices, edges)
end

function construct_graph(V, E)
    enumerated = Dict(v => i+2 for (i, v) in enumerate(v for v in V if v != "you" && v != "out"))
    enumerated["you"] = 1
    enumerated["out"] = 2
    g = DiGraph(length(V))
    for (v, i) in enumerated
        for next in E[v]
            add_edge!(g, i, enumerated[next])
        end
    end
    g
end

function part1(g)
    ways = zeros(Int, nv(g))
    topo = topological_sort(g)
    ways[1] = 1
    for v in topo, neigh in neighbors(g, v)
        ways[neigh] += ways[v]
    end
    return ways[2]
end

part1(g)

@testset "part 1" begin
    g = parseinput(IOBuffer("""
    aaa: you hhh
    you: bbb ccc
    bbb: ddd eee
    ccc: ddd eee fff
    ddd: ggg
    eee: out
    fff: out
    ggg: out
    hhh: ccc fff iii
    iii: out"""))
    @test part1(g) == 5
end

g = parseinput(filename)

part1_result = part1(g)