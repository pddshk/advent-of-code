filename = joinpath(@__DIR__, "input.txt")

preparelevel(s::AbstractString) = permutedims(stack(Vector{Char}, split(s, '\n')))
preparemoves(s::AbstractString) = replace(s, '\n' => "")

function parseinput(filename)
    level, moves = split(read(filename, String), "\n\n")
    preparelevel(level), preparemoves(moves)
end

level, moves = parseinput(filename)

const movements = Dict(map(=>, "^>v<", CartesianIndex.(((-1, 0), (0, 1), (1, 0), (0, -1)))))

function ispossible(level, pos, movement)
    @inbounds while true
        pos = pos + movement
        if level[pos] == 'O'
            continue
        else
            return level[pos] == '.'
        end
    end
end

function trymove!(level, pos, dir)
    movement = movements[dir]
    ispossible(level, pos, movement) || return level, pos
    lastpos = pos + movement
    while level[lastpos] != '.'
        lastpos += movement
    end
    level[pos] = '.'
    level[lastpos] = 'O'
    level[pos + movement] = '@'
    return level, pos + movement
end

function makeallmoves!(level, moves, movefunc=trymove!)
    pos = findfirst(==('@'), level)
    for dir in moves
        level, pos = movefunc(level, pos, dir)
    end
    return level, pos
end

function part1!(level, moves)
    makeallmoves!(level, moves)
    sum(findall(==('O'), level)) do ind
        100ind[1] + ind[2] - 101
    end
end

part1(level, moves) = part1!(copy(level), moves)

part1(level, moves)

function makenewmap(level)
    newlevel = fill('.', size(level) .* (1, 2))
    newlevel[:, begin+1:2:end] .= level
    replace!(newlevel, 'O' => ']', '@' => '.')
    newlevel[:, begin:2:end] .= level
    replace!(newlevel, 'O' => '[')
    newlevel
end

function prettyprint(level)
    for row in eachrow(level)
        for i in row
            print(i)
        end
        println()
    end
end

@inline function resolveboxcoords(level, boxpos)
    boxpos2 = boxpos
    if level[boxpos] == '['
        boxpos2 += CartesianIndex(0, 1)
    elseif level[boxpos] == ']'
        boxpos += CartesianIndex(0, -1)
    end
    return boxpos, boxpos2
end

using DataStructures

function gathervacentplaces!(level, pos, movement, gathered)
    nextpos = pos + movement
    if level[nextpos] == '.'
        gathered[pos] = nextpos
        return gathered
    elseif level[nextpos] == '#'
        return nothing
    end

    boxpos, boxpos2 = resolveboxcoords(level, nextpos)
    gathered[boxpos] = boxpos + movement
    gathered[boxpos2] = boxpos2 + movement
    if movement == CartesianIndex(0, 1)
        return gathervacentplaces!(level, boxpos2, movement, gathered)
    elseif movement == CartesianIndex(0, -1)
        return gathervacentplaces!(level, boxpos, movement, gathered)
    elseif movement == CartesianIndex(-1, 0) || movement == CartesianIndex(1, 0)
        if isnothing(gathervacentplaces!(level, boxpos, movement, gathered))
            return nothing
        end
        if isnothing(gathervacentplaces!(level, boxpos2, movement, gathered))
            return nothing
        end
        return gathered
    else
        return nothing
    end
end

function trymove2!(level, pos, dir)
    movement = movements[dir]
    nextpos = pos + movement
    if level[nextpos] == '#'
        return level, pos
    elseif level[nextpos] == '.'
        level[pos] = '.'
        level[nextpos] = '@'
        return level, nextpos
    end
    ordering = Base.Forward
    if dir == 'v' || dir == '>'
        ordering = Base.Reverse
    end
    vacantplaces = SortedDict{CartesianIndex{2}, CartesianIndex{2}}(ordering, pos => nextpos)
    if isnothing(gathervacentplaces!(level, pos, movement, vacantplaces))
        return level, pos
    end
    for (from, to) in vacantplaces
        level[to] = level[from]
        level[from] = '.'
    end
    return level, pos + movement
end

part2(level, moves) = part2!(copy(level), moves)

function part2!(level, moves)
    makeallmoves!(level, moves, trymove2!)
    sum(findall(==('['), level)) do ind
        100ind[1] + ind[2] - 101
    end
end

newlevel = makenewmap(level)

part2(newlevel, moves)