using Combinatorics
using DataStructures
using LinearAlgebra: norm2
using Test

const filename = joinpath(@__DIR__, "input.txt")

struct Point3D
    x::Int
    y::Int
    z::Int
end

Point3D(p::AbstractVector{Int}) = Point3D(p[1], p[2], p[3])

Base.:-(p1::Point3D, p2::Point3D) = Point3D(p1.x - p2.x, p1.y - p2.y, p1.z - p2.z)
LinearAlgebra.norm2(p::Point3D) = p.x^2 + p.y^2 + p.z^2

function parseinput(filename)
    map(eachline(filename)) do line
        Point3D(parse.(Int, split(line, ",")))
    end
end


function part1(points; ncouples=1000, ncircuits=3)
    couples = collect(combinations(points, 2))
    partialsort!(couples, ncouples; by=(a) -> norm2(a[2] - a[1]))
    couples = couples[1:ncouples]
    sets = Set{Point3D}[]
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

part1(points; ncouples=10, ncircuits=3)

points = parseinput(filename)
part1(points)

function part2(points)
    npoints = length(points)
    couples = collect(combinations(points, 2))
    sort!(couples; by=(a) -> norm2(a[2] - a[1]))
    s = DisjointSet{Point3D}()
    for couple in couples
        p1, p2 = couple
        push!(s, p1)
        push!(s, p2)
        union!(s, p1, p2)
        if num_groups(s) == 1 && length(s) == npoints
            return p1.x * p2.x
        end
    end
end

part2(points)
