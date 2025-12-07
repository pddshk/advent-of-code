using DataStructures
using Test

const filename = joinpath(@__DIR__, "input.txt")

function parseinput(filename)
    permutedims(stack(Vector{Char}, eachline(filename)))
end

parseinput_result = parseinput(filename)

function trace_beam!(mat)
    q = Queue{CartesianIndex{2}}()
    s = findfirst(==('S'), mat)
    enqueue!(q, s)
    mat[s] = '.'
    # visited = Set{CartesianIndex{2}}()
    dir = CartesianIndex(1, 0)
    cnt = 0
    while !isempty(q)
        pos = dequeue!(q)
        # if pos in visited
        #     continue
        # end
        # push!(visited, pos)
        current = mat[pos]
        if current == '.'
            mat[pos] = '|'
            newpos = pos + dir
            if checkbounds(Bool, mat, newpos)
                enqueue!(q, newpos)
            end
        elseif current == '^'
            cnt += 1
            for d in (CartesianIndex(0, -1), CartesianIndex(0, 1))
                newpos = pos + d
                if checkbounds(Bool, mat, newpos)
                    enqueue!(q, newpos)
                end
            end
        end
    end
    return cnt
end

@testset "trace_beam!" begin
    mat = parseinput(IOBuffer("""
    .......S.......
    ...............
    .......^.......
    ...............
    ......^.^......
    ...............
    .....^.^.^.....
    ...............
    ....^.^...^....
    ...............
    ...^.^...^.^...
    ...............
    ..^...^.....^..
    ...............
    .^.^.^.^.^...^.
    ..............."""))
    @test trace_beam!(mat) == 21
end

part1_result = let mat = parseinput(filename)
    trace_beam!(mat)
end

function transformmap(mat)
    map(mat) do c
        if c == '.'
            0
        elseif c == '^'
            -1
        else
            -2
        end
    end
end

function trace_beam2!(mat)
    q = Queue{CartesianIndex{2}}()
    visited = Set{CartesianIndex{2}}()
    s = findfirst(==(-2), mat)
    enqueue!(q, s)
    mat[s] = 1
    dir = CartesianIndex(1, 0)
    while !isempty(q)
        pos = dequeue!(q)
        if pos in visited
            continue
        end
        push!(visited, pos)
        nextpos = pos + dir
        if !checkbounds(Bool, mat, nextpos)
            continue
        end
        if mat[nextpos] != -1
            mat[nextpos] += mat[pos]
            enqueue!(q, nextpos)
        else
            for d in (CartesianIndex(0, -1), CartesianIndex(0, 1))
                newpos = nextpos + d
                if checkbounds(Bool, mat, newpos)
                    mat[newpos] += mat[pos]
                    enqueue!(q, newpos)
                end
            end
        end
    end
    return sum(mat[end, :])
end

@testset "trace_beam2!" begin
    mat = parseinput(IOBuffer("""
    .......S.......
    ...............
    .......^.......
    ...............
    ......^.^......
    ...............
    .....^.^.^.....
    ...............
    ....^.^...^....
    ...............
    ...^.^...^.^...
    ...............
    ..^...^.....^..
    ...............
    .^.^.^.^.^...^.
    ...............""")) |> transformmap
    @test trace_beam2!(mat) == 40
end

part2_result = let mat = parseinput(filename) |> transformmap
    trace_beam2!(mat)
end
