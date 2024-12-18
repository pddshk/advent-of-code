filename = joinpath(@__DIR__, "input.txt")

function parseinput(filename)
    map(eachline(filename)) do line
        a, b = parse.(Int, split(line, ','))
        CartesianIndex(a+1, b+1)
    end
end

places = parseinput(filename)

function filllevel(coords, levelsize=(71, 71))
    level = fill(typemax(Int), levelsize)
    filllevel!(level, coords)
end

function filllevel!(level, coords)
    setindex!.(Ref(level), -1, coords)
    level
end

using DataStructures

function marklevel!(level, q=Queue{CartesianIndex{2}}(length(level)), startpos=CartesianIndex(1, 1), endpos=last(eachindex(IndexCartesian(), level)))
    level[startpos] = 0
    enqueue!(q, startpos)
    movements = CartesianIndex.(((-1, 0), (0, 1), (1, 0), (0, -1)))
    while !isempty(q)
        curr = dequeue!(q)
        for movement in movements
            next = curr + movement
            checkbounds(Bool, level, next) && level[next] - level[curr] > 1 && level[next] != -1 || continue
            level[next] = level[curr] + 1
            next == endpos && return level
            enqueue!(q, next)
        end
    end
    level
end

function part1(places)
    places2 = @view places[1:1024]
    level = filllevel(places2)
    marklevel!(level)
    level[71, 71]
end

part1(places)

function part2(places)
    level = Matrix{Int}(undef, 71, 71)
    filllevel!(level, @view places[1:1024])
    level2 = copy(level)
    q=Queue{CartesianIndex{2}}(length(level))
    for i in @view places[1025:end]
        level2[i] = -1
        level .= level2
        empty!(q)
        marklevel!(level, q)
        level[71, 71] == typemax(Int) && return i - CartesianIndex(1, 1)
    end
end

part2(places)