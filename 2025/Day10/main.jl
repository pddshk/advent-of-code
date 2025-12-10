using Combinatorics
using DataStructures
using LinearAlgebra
using InvertedIndices
using Test
using JuMP
using HiGHS

const filename = joinpath(@__DIR__, "input.txt")

struct Machine
    indicators::BitVector
    toggles::Vector{Vector{Int}}
    joltages::Vector{Int}
end

function parseinput(filename)
    map(eachline(filename)) do line
        indicators, toggles..., joltages = split(line, ' ')
        indicators = @views [c == '#' for c in indicators[begin+1:end-1]]
        toggles = map(toggles) do toggle
            toggle = @view toggle[begin+1:end-1]
            parse.(Int, split(toggle, ',')) .+ 1  # shift indices for 1-based indexing
        end
        joltages = @views parse.(Int, split(joltages[begin+1:end-1], ','))
        Machine(indicators, toggles, joltages)
    end
end

function applytoggle!(indicators::AbstractVector{Bool}, toggle)
    indicators[toggle] .= .!indicators[toggle]
    return indicators
end

applytoggle(indicators, toggle) = applytoggle!(copy(indicators), toggle)

@testset "applytoggle" begin
    @test applytoggle(Bool[0,0,0,0], [1,3,4]) == Bool[1,0,1,1]
    @test applytoggle(Bool[1,0,1,1], [1,2,3]) == Bool[0,1,0,1]
end

function solvemachineindicators(m::Machine)
    init() = falses(length(m.indicators))
    for toggleset in powerset(m.toggles, 1)
        res = foldl(applytoggle!, toggleset; init=init())
        res == m.indicators && return toggleset
    end
    error("No solution")
end

@testset "solvemachineindicators" begin
    machines = parseinput(IOBuffer("""
    [.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
    [...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
    [.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}"""))
    @test length(solvemachineindicators(machines[1])) == 2
    @test length(solvemachineindicators(machines[2])) == 3
    @test length(solvemachineindicators(machines[3])) == 2
end

part1(machines) = sum(length ∘ solvemachineindicators, machines)

machines = parseinput(filename)

part1_result = part1(machines)

function genvectors(toggles)
    n = maximum(maximum.(toggles))
    res = zeros(Int, n, length(toggles))
    for (col, toggle) in zip(eachcol(res), toggles)
        col[toggle] .= 1
    end
    return res
end

# awful test case
# m = Machine(Bool[0, 0, 1, 1, 0, 1, 1, 0, 0, 1], [[4, 5, 8, 9], [4, 8], [2, 5, 6, 7, 8], [1, 3, 5, 7, 10], [1], [1, 3, 7, 8, 9], [2, 4, 5, 6, 8, 9, 10], [1, 2, 3, 6, 7, 8, 9, 10], [1, 2, 6, 7, 10], [1, 4, 5, 6, 7, 9, 10], [1, 2, 3, 6, 9, 10]], [73, 226, 37, 229, 224, 242, 47, 240, 250, 240])

function solvemachinejoltages(m::Machine)
    nvars = length(m.toggles)
    mat = genvectors(m.toggles)
    model = Model(HiGHS.Optimizer)
    set_silent(model)
    @variable(model, x[1:nvars] >= 0, Int)
    @objective(model, Min, sum(x))
    @constraint(model, mat * x == m.joltages)
    optimize!(model)
    objective_value(model) |> Int
end

@testset "solvemachinejoltages" begin
    machines = parseinput(IOBuffer("""
    [.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
    [...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
    [.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}"""))
    @test solvemachinejoltages(machines[1]) == 10
    @test solvemachinejoltages(machines[2]) == 12
    @test solvemachinejoltages(machines[3]) == 11
end

part2(machines) = sum(solvemachinejoltages, machines)

part2_result = part2(machines)

println("Part 1: ", part1_result, "\nPart 2: ", part2_result)
