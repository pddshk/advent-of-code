filename = joinpath(@__DIR__, "input.txt")

mutable struct State
    A::Int
    B::Int
    C::Int
    asm::Vector{Int}
    CIR::Int
    out::Vector{Int}

    State(A::Int, B::Int, C::Int, asm::Vector, CIR=1, out=Int[]) = new(A, B, C, asm, CIR, out)
end

Base.deepcopy(s::State) = State(s.A, s.B, s.C, copy(s.asm), s.CIR, copy(s.out))

function parseinput(filename)
    raw = read(filename, String)
    registers, program = split(raw, "\n\n")
    A, B, C = parse.(Int, first.(eachmatch(r"Register .: (\d+)", registers)))
    asm = parse.(Int, split(match(r"Program: (.*)", program)[1], ','))
    State(A, B, C, asm)
end

function comboop(s::State, arg::Int)
    if arg == 4
        s.A
    elseif arg == 5
        s.B
    elseif arg == 6
        s.C
    else
        arg
    end
end

function Base.iterate(s::State, _=nothing)
    checkbounds(Bool, s.asm, s.CIR) || return nothing
    instr = s.asm[s.CIR]
    operand = s.asm[s.CIR+1]
    if instr == 0      # adv
        s.A ÷= 2^comboop(s, operand)
    elseif instr == 1  # bxl
        s.B ⊻= operand
    elseif instr == 2  # bst
        s.B = mod(comboop(s, operand), 8)
    elseif instr == 3 && s.A != 0 # jnz
        s.CIR = operand - 1
    elseif instr == 4  # bxc
        s.B ⊻= s.C
    elseif instr == 5  # out
        push!(s.out, mod(comboop(s, operand), 8))
    elseif instr == 6  # bdv
        s.B = s.A ÷ 2^comboop(s, operand)
    elseif instr == 7  # cdv
        s.C = s.A ÷ 2^comboop(s, operand)
    end
    s.CIR += 2
    return (s, nothing)
end

function process!(s::State)
    for _ in s end
    copy(s.out)
end

function part1!(s::State)
    out = process!(s)
    println(join(out, ','))
end

part1(s::State) = part1!(deepcopy(s))

s = parseinput(filename)

part1(s)

function findA(s::State, patt, start)
    for i in start:start+10^5
        s2 = deepcopy(s)
        s2.A = i
        process!(s2) == patt && return i
    end
end

function part2(s::State)
    expected = s.asm
    actual = Int[]
    sizehint!(actual, length(expected))
    start = 0
    for i in Iterators.reverse(expected)
        pushfirst!(actual, i)
        start = findA(s, actual, start)
        start <<= 3
    end
    return start >> 3
end

part2(s)