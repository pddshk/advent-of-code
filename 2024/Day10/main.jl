filename = joinpath(@__DIR__, "input.txt")

parseinput(filename) = stack(Vector{UInt8}, eachline(filename)) .- 0x30

parseinput(filename)

testinp = """89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732"""

using DataStructures

function score!(visited, level, pos::T) where T
    visited .= false
    q = Queue{T}()
    enqueue!(q, pos)
    movements = CartesianIndex.(((1,0),(-1,0),(0,1),(0,-1)))
    while !isempty(q)
        curr = dequeue!(q)
        visited[curr] = true
        for movement in movements
            next = curr + movement
            if checkbounds(Bool, level, next) && level[next] - level[curr] == 0x01
                enqueue!(q, next)
            end
        end
    end
    count(==(0x09), @view level[visited])
end

function part1(level)
    visited = falses(axes(level))
    sum(findall(iszero, level)) do startpos
        score!(visited, level, startpos)
    end
end

level = parseinput(IOBuffer(testinp))

level = parseinput(filename)

part1(level)

function rating!(visited, marks, level, pos)
    score!(visited, level, pos)
    marks .= 0
    marks[visited .& (level .== 0x09)] .= 1
    movements = CartesianIndex.(((1,0),(-1,0),(0,1),(0,-1)))
    for i in reverse(0:8)
        is = findall(==(i), level)
        filter!(ind -> visited[ind], is)
        for el in is, movement in movements
            poss = el + movement
            checkbounds(Bool, level, poss) && visited[poss] || continue
            marks[el] += marks[poss]
        end
        visited[level .== i+1] .= false
    end
    marks[pos]
end

function part2(level)
    visited = falses(axes(level))
    marks = zeros(Int, axes(level))
    sum(findall(iszero, level)) do startpos
        rating!(visited, marks, level, startpos)
    end
end

@time part2(level)


function part2(level)
    marks = zeros(Int, axes(level))
    marks[level .== 0x09] .= 1
    movements = CartesianIndex.(((1,0),(-1,0),(0,1),(0,-1)))
    for i in reverse(0:8)
        is = findall(==(i), level)
        for el in is, movement in movements
            poss = el + movement
            checkbounds(Bool, level, poss) && level[poss] - level[el] == 1 || continue
            marks[el] += marks[poss]
        end
    end
    sum(marks[level .== 0])
end

@time part2(level)