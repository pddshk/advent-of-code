filename = joinpath(@__DIR__, "input.txt")

level = map(permutedims(stack(Vector{Char}, eachline(filename)))) do c
    if c == '#'
        32
    elseif c == '^'
        1
    else
        0
    end
end

# urdl = 1 2 4 8

const movements = Dict(
    2 .^ (0:3) .=> CartesianIndex.([(-1, 0), (0, 1), (1, 0), (0, -1)])
)

@inline turnRight(dir) = dir == 8 ? 1 : dir << 1

part1(level) = part1!(copy(level))

@inline endOfLevel(level, guardpos, direction) = !checkbounds(Bool, level, guardpos + movements[direction])

function lurk!(level, guardpos, direction; condition=!endOfLevel, filler)
    while condition(level, guardpos, direction)
        level[guardpos] = filler(level[guardpos], direction)
        nextpos = guardpos + movements[direction]
        if level[nextpos] == 32  # obstacle
            direction = turnRight(direction)
            continue
        end
        guardpos = nextpos
    end
    level[guardpos] = filler(level[guardpos], direction)
    return level, guardpos, direction
end

function part1!(level)
    startpos = findfirst(==(1), level)
    direction = 1
    lurk!(level, startpos, direction; filler=(_...)->1)
    count(==(1), level)
end

part1(level)

@inline adddir(c, direction) = c | direction

@inline hasdir(c, direction) = c & direction != 0

function cycleOrEnd(level, guardpos, direction)
    endOfLevel(level, guardpos, direction) && return true
    newpos = guardpos + movements[direction]
    level[newpos] == 32 && return false 
    return hasdir(level[newpos], direction)  # cycle found
end

function willCycle!(level, guardpos, direction)
    _, guardpos, direction = lurk!(level, guardpos, direction; filler=adddir, condition=!cycleOrEnd)
    return !endOfLevel(level, guardpos, direction)
end

function part2!(level)
    startpos = guardpos = findfirst(==(1), level)
    direction = 1
    counter = 0
    buff = copy(level)
    while !endOfLevel(level, guardpos, direction)
        level[guardpos] = 64
        nextpos = guardpos + movements[direction]
        if level[nextpos] == 32
            direction = turnRight(direction)
            continue
        end
        guardpos = nextpos
        level[nextpos] == 64 && continue  # visited
        buff .= level
        buff[nextpos] = 32
        counter += willCycle!(buff, startpos, 1)
    end
    counter
end

part2(level) = part2!(copy(level))

level2 = copy(level)

@time part2(level)

function finddup(guys)
    n = length(guys)
    for i in 1:n, j in i+1:n
        guys[i] == guys[j] && return guys[i]
    end
end

finddup(guys)

function test!(level)
    startpos = findfirst(==(1), level)
    direction = 1
    lurk!(level, startpos, direction; filler=adddir)
    count(==(1), level)
end

test!(level2)

level2[82:86,44:48]

sizeof(level)