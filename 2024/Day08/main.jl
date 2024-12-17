filename = joinpath(@__DIR__, "input.txt")

parseinput(filename) = permutedims(stack(Vector{Char}, eachline(filename)))

level = parseinput(filename)

using IterTools

macro setind_if_inbounds(expr)
    arr = expr.args[1].args[1]
    inds = expr.args[1].args[2:end]
    quote
        if checkbounds(Bool, $(esc(arr)), $(esc(inds...)))
            $(esc(expr))
        end
    end
end

function antinodes_locations(level; antinodes_calc=calculate_antinodes)
    antennas = unique!(filter(!=('.'), level))
    antinodes = falses(axes(level))
    for antenna in antennas
        locations = findall(==(antenna), level)
        for (a1, a2) in subsets(locations, 2)
            antiloc = antinodes_calc(a1, a2)
            for anti in antiloc
                @setind_if_inbounds antinodes[anti] = true
            end
        end
    end
    return antinodes
end

function calculate_antinodes(pos1, pos2)
    v = pos2 - pos1
    outer1 = pos2 + v
    outer2 = pos1 - v
    return outer1, outer2
end

using Test

@testset begin
    testinp = """............
                ........0...
                .....0......
                .......0....
                ....0.......
                ......A.....
                ............
                ............
                ........A...
                .........A..
                ............
                ............"""
    testout = """......#....#
                ...#....0...
                ....#0....#.
                ..#....0....
                ....0....#..
                .#....A.....
                ...#........
                #......#....
                ........A...
                .........A..
                ..........#.
                ..........#."""
    level = parseinput(IOBuffer(testinp))
    antinodes = antinodes_locations(level)

    level2 = copy(level)
    
    for i in eachindex(antinodes)
        if antinodes[i] && level2[i] == '.'
            level2[i] = '#'
        end
    end
    
    @test join(String.(eachrow(level2)), "\n") == testout
end

part1(level) = count(antinodes_locations(level))

part1(level)

function calculate_antinodes2(pos1, pos2)
    v = pos2 - pos1
    inds = pos1-50v:v:pos2 + 50v
    Iterators.map(CartesianIndex, zip(inds.indices...))
end

part2(level) = count(antinodes_locations(level; antinodes_calc=calculate_antinodes2))

@testset begin
    testinp = """............
                ........0...
                .....0......
                .......0....
                ....0.......
                ......A.....
                ............
                ............
                ........A...
                .........A..
                ............
                ............"""
    testout = """##....#....#
                .#.#....0...
                ..#.#0....#.
                ..##...0....
                ....0....#..
                .#...#A....#
                ...#..#.....
                #....#.#....
                ..#.....A...
                ....#....A..
                .#........#.
                ...#......##"""
    level = parseinput(IOBuffer(testinp))
    antinodes = antinodes_locations(level; antinodes_calc=calculate_antinodes2)

    level2 = copy(level)
    
    for i in eachindex(antinodes)
        if antinodes[i] && level2[i] == '.'
            level2[i] = '#'
        end
    end
    join(String.(eachrow(level2)), "\n") |> print
    @test join(String.(eachrow(level2)), "\n") == testout
end

part2(level)
