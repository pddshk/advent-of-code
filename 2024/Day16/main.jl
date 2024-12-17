filename = joinpath(@__DIR__, "input.txt")

const freespace = typemax(Int)

function parseinput(filename)
    levelc = permutedims(stack(Vector{Char}, eachline(filename)))
    level = fill(freespace, axes(levelc)..., 4)
    for i in eachindex(IndexCartesian(), levelc)
        if levelc[i] == '#'
            level[i, :] .= -100
        elseif levelc[i] == 'S'
            level[i, :] .= -1
        elseif levelc[i] == 'E'
            level[i, :] .= -2
        end
    end
    level
end

level = parseinput(filename)

using DataStructures

function markpath!(level)
    startpos = @views findfirst(==(-1), level[:, :, 1])
    endpos = @views findfirst(==(-2), level[:, :, 1])
    level[endpos, :] .= freespace
    movements = CartesianIndex.(((-1, 0), (0, 1), (1, 0), (0, -1)))
    q = Queue{Tuple{CartesianIndex{2}, CartesianIndex{2}}}()
    enqueue!(q, (startpos, CartesianIndex(0, 1)))
    level[startpos, :] .= 0
    counter = 0
    while !isempty(q)
        node, direction = dequeue!(q)
        layerno = findfirst(==(direction), movements)
        cost = level[node, layerno]
        for (i, movement) in enumerate(movements)
            nextnode = node + movement
            newcost = cost + (movement == direction ? 1 : 1001)
            (level[nextnode, 1] == -100 || level[nextnode, i] < newcost) && continue
            level[nextnode, i] = newcost
            nextnode == endpos && continue
            enqueue!(q, (nextnode, movement))
        end
        counter > 10length(level) && error("STUCK!!")
        counter += 1
    end
    level
end

function part1!(level)
    endpos = findfirst(==(-2), @view level[:, :, 1])
    markpath!(level)
    minimum(level[endpos, :])
end

part1(level) = part1!(copy(level))

level = parseinput(filename)
part1(level)

function findallpaths(level)
    ll = fill('.', axes(level)[1:2])
    ll[level[:, :, 1] .== -100] .= '#'
    movements = CartesianIndex.(((-1, 0), (0, 1), (1, 0), (0, -1)))
    m, n, _ = size(level)
    q = Queue{CartesianIndex{3}}()
    p1 = minimum(level[2, n-1, :])
    for i in 1:4
        if level[2, n-1, i] == p1
            enqueue!(q, CartesianIndex(2, n-1, i))
        end
    end
    ll[2, n-1] = 'O'
    counter = 0
    while !isempty(q)
        curr = dequeue!(q)
        flatcurr = CartesianIndex(curr[1], curr[2])
        for i in 1:4, movement in movements
            nextpos = CartesianIndex(flatcurr + movement, i)
            delta = level[curr] - level[nextpos]
            if delta == 1 || delta == 1001
                ll[flatcurr + movement] = 'O'
                enqueue!(q, nextpos)
            end
        end
        counter += 1
        counter > length(level) && error("STUCK!!!")
    end
    ll
end

function part2!(level)
     ll = findallpaths(markpath!(level))
     count(==('O'), ll)
end

part2(level) = part2!(copy(level))

part2(level)
