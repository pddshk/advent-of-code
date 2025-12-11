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
    enumerated = Dict(v => i for (i, v) in enumerate(V))
    g = DiGraph(length(V))
    for (v, i) in enumerated
        for next in E[v]
            add_edge!(g, i, enumerated[next])
        end
    end
    g, enumerated
end

function count_paths(g, src, dst, enumerated, topo=topological_sort(g))
    ways = zeros(Int, nv(g))
    ways[enumerated[src]] = 1
    for v in topo, neigh in neighbors(g, v)
        ways[neigh] += ways[v]
    end
    return ways[enumerated[dst]]
end

part1(g, enumerated) = count_paths(g, "you", "out", enumerated)

@testset "part 1" begin
    g, enumerated = parseinput(IOBuffer("""
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
    @test part1(g, enumerated) == 5
end

g, enumerated = parseinput(filename)

part1_result = part1(g, enumerated)

function part2(g, enumerated)
    topo = topological_sort(g)
    dac = findfirst(==(enumerated["dac"]), topo)
    fft = findfirst(==(enumerated["fft"]), topo)
    if dac < fft
        svr2dac = count_paths(g, "svr", "dac", enumerated, topo)
        dac2fft = count_paths(g, "dac", "fft", enumerated, topo)
        fft2out = count_paths(g, "fft", "out", enumerated, topo)
        return svr2dac * dac2fft * fft2out
    else
        svr2fft = count_paths(g, "svr", "fft", enumerated, topo)
        fft2dac = count_paths(g, "fft", "dac", enumerated, topo)
        dac2out = count_paths(g, "dac", "out", enumerated, topo)
        return svr2fft * fft2dac * dac2out
    end
end

@testset "part 2" begin
    g, enumerated = parseinput(IOBuffer("""
    svr: aaa bbb
    aaa: fft
    fft: ccc
    bbb: tty
    tty: ccc
    ccc: ddd eee
    ddd: hub
    hub: fff
    eee: dac
    dac: fff
    fff: ggg hhh
    ggg: out
    hhh: out"""))
    @test part2(g, enumerated) == 2
end

part2_result = part2(g, enumerated)

println("Part 1: ", part1_result, "\nPart 2: ", part2_result)
