filename = joinpath(@__DIR__, "input.txt")

function parseinput(filename)
    raw = read(filename, String)
    elements = split(raw, "\n\n")
    _keys = NTuple{5, Int}[]
    locks = copy(keys)
    for el in elements
        mat = stack(Vector{Char}, split(el))
        values = Tuple(count(==('#'), mat; dims=2))
        dest = startswith("#####")(el) ? locks : _keys
        push!(dest, values)
    end
    _keys, locks
end

_keys, locks = parseinput(filename)

part1(keys, locks) = count(all(<=(7), k .+ l) for k in keys, l in locks)

part1(_keys, locks)

part2() = println("HOHOHO!")

part2()