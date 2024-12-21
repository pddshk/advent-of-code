filename = joinpath(@__DIR__, "input.txt")

function parseinput(filename)
    chars = permutedims(stack(Vector{Char}, eachline(filename)))
    startpos = findfirst(==('S'), chars)
    endpos = findfirst(==('E'), chars)
    level = zeros(Int, axes(chars))
    level[chars .== '#'] .= -1
    return level, startpos, endpos
end

function marklevel!(level, startpos, endpos)
    path = CartesianIndex{2}[]
    pathlen = count(iszero, level)
    sizehint!(path, pathlen)
    push!(path, endpos)
    level[endpos] = 1
    movements = CartesianIndex.(((-1, 0), (0, 1), (1, 0), (0, -1)))
    for _ in 1:pathlen, movement in movements
        nextpos = path[end] + movement
        if level[nextpos] == 0
            level[nextpos] = level[path[end]] + 1
            push!(path, nextpos)
        end
    end
    return level, path
end

function part1!(level, startpos, endpos; isgood=(>=(100)))
    _, path = marklevel!(level, startpos, endpos)
    movements = 2 .* CartesianIndex.(((-1, 0), (0, 1), (1, 0), (0, -1)))
    counter = 0
    for p in path, movement in movements
        shortcut = p + movement
        checkbounds(Bool, level, shortcut) || continue
        counter += isgood(level[shortcut] - level[p] - 2)
    end
    return counter
end

part1(level, args...; kwargs...) = part1!(copy(level), args...; kwargs...)

level, startpos, endpos = parseinput(filename)
part1(level, startpos, endpos)

rhombus(d; center=CartesianIndex(0, 0)) = (center + CartesianIndex(i, j) for j in -d:d for i in -d:d if abs(i) + abs(j) <= d)

function part2!(level, startpos, endpos; isgood=(>=(100)))
    _, path = marklevel!(level, startpos, endpos)
    counter = 0
    for p in path, movement in rhombus(20)
        shortcut = movement + p
        checkbounds(Bool, level, shortcut) && level[shortcut] != -1 || continue
        cheatlength = abs(movement[1]) + abs(movement[2])
        counter += isgood(level[shortcut] - level[p] - cheatlength)
    end
    return counter
end

part2(level, args...; kwargs...) = part2!(copy(level), args...; kwargs...)

part2(level, startpos, endpos)
