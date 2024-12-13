filename = joinpath(@__DIR__, "input.txt")
inp = read(filename, String)

using Logging
using IterTools

fillmemo(inp) = fillmemo(Int16, inp)

function fillmemo(T::Type{<:Signed}, inp)
    n = sum(c -> c - '0', inp)
    memory = T[]
    sizehint!(memory, n)
    fileno = 0
    for (i, type) in zip(inp, Iterators.cycle((true, false)))
        fsize = i - '0'
        filler = type ? fileno : -1
        for _ in 1:fsize
            push!(memory, filler)
        end
        fileno += type
    end
    return memory
end

@inline function swapind!(v, i, j)
    temp = v[i]
    v[i] = v[j]
    v[j] = temp
end

function defrag!(memory)
    fwd = firstindex(memory)
    bck = lastindex(memory)
    @inbounds while true
        while memory[bck] == -1
            bck = prevind(memory, bck)
        end
        while memory[fwd] != -1
            fwd = nextind(memory, fwd)
        end
        fwd > bck && break
        swapind!(memory, fwd, bck)
    end
    EOF = findfirst(==(-1), memory)
    deleteat!(memory, EOF:lastindex(memory))
end

function part1(inp)
    memory = fillmemo(inp)
    defrag!(memory)
    summ = 0
    @inbounds for i in eachindex(memory)
        summ += (i-1) * memory[i]
    end
    summ
end

testinp = "2333133121414131402"
part1(testinp)

@time part1(inp)

function findplace(memory, len, stop=lastindex(memory))
    i = firstindex(memory)
    while memory[i] != -1
        i = nextind(memory, i)
    end
    while i < stop
        while i < stop && memory[i] != -1
            i = nextind(memory, i)
        end
        i2 = i
        while i2 < stop && memory[i2] == -1
            i2 = nextind(memory, i2)
        end
        if i2 - i >= len
            return i:i+len-1
        end
        i = nextind(memory, i)
    end
    return nothing
end

function defrag2!(memory)
    bck = lastindex(memory)
    while bck > firstindex(memory)
        while memory[bck] == -1
            bck = prevind(memory, bck)
        end
        val = memory[bck]
        bbck = bck
        while bbck > firstindex(memory) && memory[bbck] == val
            bbck = prevind(memory, bbck)
        end
        len = bck - bbck
        placement = findplace(memory, len, bck)
        if !isnothing(placement)
            swapind!(memory, bbck+1:bck, placement)
        end
        # @showmemo(memory)
        # println()
        bck = bbck
    end
    memory
end

function part2(inp)
    memory = fillmemo(inp)
    defrag2!(memory)
    summ = 0
    @inbounds for i in eachindex(memory)
        summ += (i-1) * (memory[i] == -1 ? 0 : memory[i])
    end
    summ
end

part2(testinp)
part2(inp)
memory = fillmemo(testinp)
defrag2!(memory)

showmemo(memory) = foreach(x -> print(x == -1 ? "." : x), memory)

memory = fillmemo(testinp)
bck = lastindex(memory)





while bck > firstindex(memory)
    while memory[bck] == -1
        bck = prevind(memory, bck)
    end
    val = memory[bck]
    bbck = bck
    while bbck > firstindex(memory) && memory[bbck] == val
        bbck = prevind(memory, bbck)
    end
    len = bck - bbck
    placement = findplace(memory, len, bck)
    if !isnothing(placement)
        swapind!(memory, bbck+1:bck, placement)
    end
    showmemo(memory)
    bck = bbck
end