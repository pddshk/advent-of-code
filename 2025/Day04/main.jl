using Test

filename = joinpath(@__DIR__, "input.txt")

function parseinput(filename)
    stack(eachline(filename)) do line
        [c == '@' for c in line]
    end
end

maze = parseinput(filename)

function padmaze(maze)
    rows, cols = size(maze)
    padded = falses(rows + 2, cols + 2)
    padded[2:end-1, 2:end-1] = maze
    padded
end

const DIRS = CartesianIndex.([
    (-1,-1),
    (-1,0),
    (-1,1),
    (0,-1),
    (0,1),
    (1,-1),
    (1,0),
    (1,1)
])

function isaccessible(maze, ind)
    neighs = count(dir -> maze[ind + dir], DIRS)
    return neighs < 4
end

function part1(maze; padded=false)
    pmaze = padded ? maze : padmaze(maze)
    rows, cols = size(pmaze)
    count(CartesianIndices((2:rows-1, 2:cols-1))) do ind
        pmaze[ind] && isaccessible(pmaze, ind)
    end
end

@testset "Part 1" begin
    input = parseinput(IOBuffer("""
    ..@@.@@@@.
    @@@.@.@.@@
    @@@@@.@.@@
    @.@@@@..@.
    @@.@@@@.@@
    .@@@@@@@.@
    .@.@.@.@@@
    @.@@@.@@@@
    .@@@@@@@@.
    @.@.@@@.@."""))
    @test part1(input; padded=false) == 13
end

part1_result = part1(maze; padded=false)

function removeaccessible!(pmaze)
    cnt = 0
    rows, cols = size(pmaze)
    for ind in CartesianIndices((2:rows-1, 2:cols-1))
        if pmaze[ind] && isaccessible(pmaze, ind)
            pmaze[ind] = false
            cnt += 1
        end
    end
    return cnt
end

function part2(maze; padded=false)
    pmaze = padded ? maze : padmaze(maze)
    count = 0
    anyremoved = true
    while anyremoved
        removed = removeaccessible!(pmaze)
        anyremoved = removed > 0
        count += removed
    end
    return count
end

@testset "Part 2" begin
    input = parseinput(IOBuffer("""
    ..@@.@@@@.
    @@@.@.@.@@
    @@@@@.@.@@
    @.@@@@..@.
    @@.@@@@.@@
    .@@@@@@@.@
    .@.@.@.@@@
    @.@@@.@@@@
    .@@@@@@@@.
    @.@.@@@.@."""))
    @test part2(input; padded=false) == 43
end

part2_result = part2(maze; padded=false)