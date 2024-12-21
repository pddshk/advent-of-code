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

function writemovement(io, delta, horizfirst)
    v = delta[1] > 0 ? 'v' : '^'
    h = delta[2] > 0 ? '>' : '<'
    if horizfirst
        write(io, h ^ abs(delta[2]))
        write(io, v ^ abs(delta[1]))
    else
        write(io, v ^ abs(delta[1])) 
        write(io, h ^ abs(delta[2]))
    end
    write(io, 'A')
end

function _navigate(code; coords, startpos, forbidden)
    seq = [IOBuffer()]
    for c in code
        nextpos = coords[c]
        delta = nextpos - startpos
        if startpos + CartesianIndex(delta[1], 0) == forbidden
            writemovement.(seq, Ref(delta), true)
        elseif startpos + CartesianIndex(0, delta[2]) == forbidden
            writemovement.(seq, Ref(delta), false)
        else
            seq2 = deepcopy(seq)
            writemovement.(seq, Ref(delta), false)
            writemovement.(seq2, Ref(delta), true)
            seq = [seq; seq2]
        end
        startpos = nextpos
    end
    variants = String.(take!.(seq))
    minlen, _ = findmin(length, variants)
    filter!(var -> length(var) == minlen, variants)
    unique!(variants)
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

function navigate3(code)
    coords = Dict(['^', 'A', '<', 'v', '>'] .=> (CartesianIndex(i, j) for j in 1:3, i in 1:2 if i != 1 || j != 1))
    startpos = CartesianIndex(1, 3)
    seq = IOBuffer()
    for c in code
        nextpos = coords[c]
        delta = nextpos - startpos
        writemovement(seq, delta, delta[1] < 0)  # delta[1] < 0 means move up, hence move horizontally first
        startpos = nextpos
    end
    String(take!(seq))
end

navigate2(code) = _navigate(
    code;
    coords=Dict(['^', 'A', '<', 'v', '>'] .=> (CartesianIndex(i, j) for j in 1:3, i in 1:2 if i != 1 || j != 1)),
    startpos=CartesianIndex(1, 3),
    forbidden=CartesianIndex(1, 1),
)

e1 = navigate1("379A")
e2 = mapreduce(navigate2, vcat, e1)
navigate3(e2[1])

function part1(codes)
    sum(codes) do code
        m1 = parse(Int, replace(code, "A" => ""))
        e1 = navigate1(code)
        e2 = mapreduce(navigate2, vcat, e1)
        e3 = navigate3.(e2)
        minlen, _ = findmin(length, e3)
        m1 * minlen
    end
end

codes = parseinput(filename)

codes = split("""029A
980A
179A
456A
379A""")

part1(codes)
