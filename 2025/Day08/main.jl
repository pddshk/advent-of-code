using Combinatorics
using LinearAlgebra
using Test

const filename = joinpath(@__DIR__, "input.txt")

function parseinput(filename)
    stack(eachline(filename)) do line
        parse.(Int, split(line, ","))
    end
end

points = parseinput(filename)

function part1(points; ncouples=1000, ncircuits=3)
    couples = collect(combinations(eachcol(points), 2))
    partialsort!(couples, ncouples; by=(a) -> norm(a[2] - a[1]))
    couples = couples[1:ncouples]
    sets = Set{Vector{Int}}[]
    for couple in couples
        p1, p2 = couple
        found = false
        cnt = []
        for (i, s) in enumerate(sets)
            if p1 in s || p2 in s
                push!(s, p1)
                push!(s, p2)
                found = true
                push!(cnt, i)
            end
        end
        if length(cnt) == 2
            s1 = sets[cnt[1]]
            s2 = sets[cnt[2]]
            union!(s1, s2)
            deleteat!(sets, cnt[2])
        end
        if !found
            push!(sets, Set([p1, p2]))
        end
    end
    partialsort!(sets, ncircuits; by=length, rev=true)
    # return sets
    prod(length, @view sets[1:ncircuits])
end

points = parseinput(IOBuffer("""
162,817,812
57,618,57
906,360,560
592,479,940
352,342,300
466,668,158
542,29,236
431,825,988
739,650,466
52,470,668
216,146,977
819,987,18
117,168,530
805,96,715
346,949,466
970,615,88
941,993,340
862,61,35
984,92,344
425,690,689
"""))
sets = part1(points; ncouples=10, ncircuits=3)

length.(ans)

part1(parseinput(filename); ncouples=1000, ncircuits=3)  # 7220 too low

function part2(points)
    npoints = size(points, 2)
    couples = collect(combinations(eachcol(points), 2))
    sort!(couples; by=(a) -> norm(a[2] - a[1]))
    sets = Set{Vector{Int}}[]
    for couple in couples
        p1, p2 = couple
        found = false
        cnt = []
        for (i, s) in enumerate(sets)
            if p1 in s || p2 in s
                push!(s, p1)
                push!(s, p2)
                found = true
                push!(cnt, i)
            end
        end
        if length(cnt) == 2
            s1 = sets[cnt[1]]
            s2 = sets[cnt[2]]
            union!(s1, s2)
            deleteat!(sets, cnt[2])
        end
        if !found
            push!(sets, Set([p1, p2]))
        end
        if length(sets) == 1 && length(sets[1]) == npoints
            return p1[1] * p2[1]
        end
    end
    # partialsort!(sets, ncircuits; by=length, rev=true)
    # return sets
    # prod(length, @view sets[1:ncircuits])
end

part2(points)

part2(parseinput(filename))
