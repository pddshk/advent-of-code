using Combinatorics
using IterTools
using Test

const filename = joinpath(@__DIR__, "input.txt")

area(p1::CartesianIndex{2}, p2::CartesianIndex{2}) = (abs(p1[1] - p2[1]) + 1) * (abs(p1[2] - p2[2]) + 1)
area(v::Vector{CartesianIndex{2}}) = area(v[1], v[2])

function parseinput(filename)
    map(eachline(filename)) do line
        CartesianIndex(parse.(Int, split(line, ','))...)
    end
end

part1(points) = maximum(area, combinations(points, 2))

@testset "Part 1" begin
    points = parseinput(IOBuffer("""
    7,1
    11,1
    11,7
    9,7
    9,5
    2,5
    2,3
    7,3"""))
    @test part1(points) == 50
end

points = parseinput(filename)

part1_result = part1(points)

function edges(points)
    points = copy(points)
    push!(points, points[1])  # close the loop
    [min(p1,p2):max(p1,p2) for (p1, p2) in partition(points, 2, 1)]
end

function isvalid(edges, p1, p2)
    botleft = min(p1, p2) + CartesianIndex(1, 1)
    topright = max(p1, p2) - CartesianIndex(1, 1)
    interior = botleft:topright
    all(edge -> isempty(intersect(edge, interior)), edges)
end

function part2(points)
    edgs = edges(points)
    maximum(area, Iterators.filter(v -> isvalid(edgs, v[1], v[2]), combinations(points, 2)))
end

@testset "Part 2" begin
    points = parseinput(IOBuffer("""
    7,1
    11,1
    11,7
    9,7
    9,5
    2,5
    2,3
    7,3"""))
    @test part2(points) == 24
end

part2_result = part2(points)

println("Part 1: ", part1_result, "\nPart 2: ", part2_result)
