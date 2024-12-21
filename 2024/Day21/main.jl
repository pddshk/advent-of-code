filename = joinpath(@__DIR__, "input.txt")

parseinput(filename) = collect(eachline(filename))

# +---+---+---+
# | 7 | 8 | 9 |
# +---+---+---+
# | 4 | 5 | 6 |
# +---+---+---+
# | 1 | 2 | 3 |
# +---+---+---+
#     | 0 | A |
#     +---+---+

using Memoize

@memoize function writemovement(delta, horizfirst)
    v = delta[1] > 0 ? 'v' : '^'
    h = delta[2] > 0 ? '>' : '<'
    io = IOBuffer()
    if horizfirst
        write(io, h ^ abs(delta[2]))
        write(io, v ^ abs(delta[1]))
    else
        write(io, v ^ abs(delta[1])) 
        write(io, h ^ abs(delta[2]))
    end
    write(io, 'A')
    String(take!(io))
end

function _navigate(code; coords, startpos, forbidden)
    seq = String[]
    sizehint!(seq, length(code))
    for c in code
        nextpos = coords[c]
        delta = nextpos - startpos
        encoded = if startpos + CartesianIndex(delta[1], 0) == forbidden
            writemovement(delta, true)
        elseif startpos + CartesianIndex(0, delta[2]) == forbidden
            writemovement(delta, false)
        # "<v" is preferable over "v<"
        # "<^" is preferable over "^<"
        # "v>" is preferable over ">v"
        elseif delta[2] <= 0
            writemovement(delta, true)
        else
            writemovement(delta, false)
        end
        push!(seq, encoded)
        startpos = nextpos
    end
    seq
end

navigate1(code) = _navigate(
    code;
    coords=Dict(['7':'9'; '4':'6'; '1':'3'; '0'; 'A'] .=> (CartesianIndex(i, j) for j in 1:3, i in 1:4 if i != 4 || j != 1)),
    startpos=CartesianIndex(4, 3),
    forbidden=CartesianIndex(4, 1),
)

#     +---+---+
#     | ^ | A |
# +---+---+---+
# | < | v | > |
# +---+---+---+

navigate2(code) = _navigate(
    code;
    coords=Dict(['^', 'A', '<', 'v', '>'] .=> (CartesianIndex(i, j) for j in 1:3, i in 1:2 if i != 1 || j != 1)),
    startpos=CartesianIndex(1, 3),
    forbidden=CartesianIndex(1, 1),
)


@memoize function dfs(code, limit=0)
    limit == 0 && return length(code)
    sum(dfs.(navigate2(code), limit-1))
end

function part1(codes)
    sum(codes; init=0) do code
        m1 = parse(Int, replace(code, "A" => ""))
        e1 = navigate1(code)
        m1 * sum(dfs.(e1, 2))
    end
end

codes = parseinput(filename)

part1(codes)

function part2(codes)
    sum(codes; init=0) do code
        m1 = parse(Int, replace(code, "A" => ""))
        e1 = navigate1(code)
        m1 * sum(dfs.(e1, 25))
    end
end

part2(codes)