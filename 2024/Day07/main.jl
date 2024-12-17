filename = joinpath(@__DIR__, "input.txt")

function parseInput(filename)
    map(eachline(filename)) do line
        target, values = split(line, ':')
        target = parse(Int, target)
        values = parse.(Int, split(values))
        target, values
    end
end

equations = parseInput(filename)

using IterTools

function zipfold(opsInds, args, ops)
    acc, args = firstrest(args)
    for (opInd, arg) in zip(opsInds, args)
        acc = ops[opInd](acc, arg)
    end
    return acc
end

opsIter(n, possibleOps) = Iterators.product(fill(possibleOps, n)...)

function checkeq(eq, possibleOps=(+, *))::Int
    target, values = eq
    nops = length(values) - 1
    any(opsIter(nops, eachindex(possibleOps))) do ops
        zipfold(ops, values, possibleOps) == target
    end ? target : 0
end

part1(equations) = sum(checkeq, equations)

const p1 = part1(equations)

function concatop(a, b)
    power = ndigits(b)
    a * 10^power + b
end

function part2(equations)
    equations2 = filter(iszero ∘ checkeq, equations)
    p1 + sum(Base.Fix2(checkeq, (+, *, concatop)), equations2)
end

part2(equations)