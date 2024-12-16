filename = joinpath(@__DIR__, "input.txt")

preparelevel(s::AbstractString) = permutedims(stack(Vector{Char}, split(s, '\n')))
preparemoves(s::AbstractString) = replace(s, '\n' => "")

function parseinput(filename)
    level, moves = split(read(filename, String), "\n\n")
    preparelevel(level), preparemoves(moves)
end

level, moves = parseinput(filename)

const movements = Dict(map(=>, "^>v<", CartesianIndex.(((-1, 0), (0, 1), (1, 0), (0, -1)))))

function trymove!(level, pos, dir)
    movement = movements[dir]
    lastpos = pos + movement
    while level[lastpos] == 'O'
        lastpos += movement
    end
    level[lastpos] == '#' && return level, pos  # can't move
    level[pos] = '.'
    level[lastpos] = 'O'  # replace with box first because if there is no boxes
    level[pos + movement] = '@' # the box will be replaced with robot immediatelly
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
using IterTools: @ifsomething

"""
    gathervacentplaces!(level, pos, movement, gathered)
Return `gathered` -- an `SortedDict` with all replacements to be done -- if 
movement is valid, `nothing` otherwise
"""
function gathervacentplaces!(level, pos, movement, gathered)
    nextpos = pos + movement
    gathered[pos] = nextpos
    if level[nextpos] == '.'
        return gathered
    elseif level[nextpos] == '#'
        return nothing
    end

    boxpos, boxpos2 = resolveboxcoords(level, nextpos)
    gathered[boxpos] = boxpos + movement
    gathered[boxpos2] = boxpos2 + movement

    # left or right
    if movement == CartesianIndex(0, 1)
        return gathervacentplaces!(level, boxpos2, movement, gathered)
    elseif movement == CartesianIndex(0, -1)
        return gathervacentplaces!(level, boxpos, movement, gathered)
    end
    
    # up or down, means we need to gather vacant positions for left and 
    # right boxpos if any returns nothing then propagate nothing
    @ifsomething gathervacentplaces!(level, boxpos, movement, gathered)
    @ifsomething gathervacentplaces!(level, boxpos2, movement, gathered)

    return gathered
end

function trymove2!(level, pos, dir)
    movement = movements[dir]
    ordering = dir == 'v' || dir == '>' ? Base.Reverse : Base.Forward
    
    vacantplaces = SortedDict{CartesianIndex{2}, CartesianIndex{2}}(ordering)
    
    if isnothing(gathervacentplaces!(level, pos, movement, vacantplaces))
        return level, pos
    end
    for (from, to) in vacantplaces  # usage of SortedDict allows this
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