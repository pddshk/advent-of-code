filename = joinpath(@__DIR__, "input.txt")

function parseinput(filename)
    raw = read(filename, String)
    init, gates = split(raw, "\n\n")
    vals = Dict(String(k) => v == "1" for (k, v) in eachmatch(r"(.{3}): (\d)", init))
    gates = Dict(
        Iterators.map(eachmatch(r"(.{3}) (.*?) (.{3}) -> (.{3})", gates)) do (lhs, op, rhs, dst)
            op = if op == "AND"
                &
            elseif op == "OR"
                |
            else  # XOR
                ⊻
            end
            dst => (op, lhs, rhs)
        end
    )
    vals, gates
end

function calculate!(vals, gates, reg)
    haskey(vals, reg) && return vals[reg]
    op, lhs, rhs = pop!(gates, reg)
    lhs = calculate!(vals, gates, lhs)
    rhs = calculate!(vals, gates, rhs)
    vals[reg] = op(lhs, rhs)
end

function solve!(vals, gates)
    while !isempty(gates)
        reg = first(gates)[1]
        calculate!(vals, gates, reg)
    end
    vals
end

function part1!(vals, gates)
    solve!(vals, gates)
    k = sort!(filter(contains(r"^z\d\d$"), collect(keys(vals))))
    getindex.(Ref(vals), k).chunks[1] |> Int
end

part1(vals, gates) = part1!(copy(vals), copy(gates))

vals, gates = parseinput(filename)

part1(vals, gates)

areXY(lhs, rhs) = lhs[1] == 'x' && rhs[1] == 'y'

function part2(gates)
    bad = String[]
    for (dst, (op, lhs, rhs)) in gates
        lhs, rhs = minmax(lhs, rhs)

        # XOR only for combine xi, yi or produce zi
        if op == xor && !areXY(lhs, rhs) && dst[1] != 'z'
            push!(bad, dst)
            continue
        end

        # xi,yi are only combined by XOR / AND
        if areXY(lhs, rhs) && op ∉ (&, ⊻)
            push!(bad, dst)
            continue
        end

        # Rules for zi
        if dst[1] == 'z'
            # zi is produced by XOR except for the last one
            if op != xor && dst != "z45"
                push!(bad, dst)
            # XOR does not go after AND, except for 1st iteration
            elseif op == xor && lhs != "x00"
                gates[lhs][1] == (&) && !endswith(gates[lhs][2], "00") && push!(bad, lhs) 
                gates[rhs][1] == (&) && !endswith(gates[rhs][2], "00") && push!(bad, rhs)
            end
        end

        # OR must be exactly after 2 ANDs
        if op == (|)
            gates[lhs][1] != (&) && push!(bad, lhs)
            gates[rhs][1] != (&) && push!(bad, rhs)
        end
    end
    join(sort!(unique!(bad)), ",")
end

part2(gates)
