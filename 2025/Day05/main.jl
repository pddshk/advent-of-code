using Test

const filename = joinpath(@__DIR__, "input.txt")

function parseinput(filename)
    raw = read(filename, String)
    ranges, ingridients = split(raw, "\n\n")
    ranges = map(eachline(IOBuffer(ranges))) do line
        start, stop = parse.(Int, split(line, "-"))
        start:stop
    end
    ingridients = parse.(Int, eachline(IOBuffer(ingridients)))
    return sort!(ranges; by=first), sort!(ingridients)
end

ranges, ingridients = parseinput(filename)

function mergeranges(ranges; sorted=false)
    if !sorted
        ranges = sort!(ranges; by=first)
    end
    merged = eltype(ranges)[]
    sizehint!(merged, length(ranges))
    current = first(ranges)
    for r in Iterators.drop(ranges, 1)
        if r.start <= current.stop + 1
            current = current.start:max(current.stop, r.stop)
        else
            push!(merged, current)
            current = r
        end
    end
    push!(merged, current)
    return merged
end

mranges = mergeranges(ranges; sorted=true)

function inanyrange(unfolded, ingridient)
    idx = searchsorted(unfolded, ingridient)
    isodd(idx.stop) || !isempty(idx) # inside a range if index is odd
end

function part1(ranges, ingridients; merged=false, sorted=false)
    if !merged
        ranges = mergeranges(ranges; sorted=sorted)
    end
    unfolded = reinterpret(Int, ranges)
    count(ingridients) do ingridient
        inanyrange(unfolded, ingridient)
    end
end

@testset "part1" begin
    ranges, ingridients = parseinput(IOBuffer("""
    3-5
    10-14
    16-20
    12-18

    1
    5
    8
    11
    17
    32"""))
    @test part1(ranges, ingridients) == 3
end

part1_result = part1(mranges, ingridients; sorted=true, merged=true)

function stupidpart1(ranges, ingridients)
    count(ingridients) do ingridient
        any(r -> ingridient in r, ranges)
    end
end

stupid_part1_result = stupidpart1(ranges, ingridients)

function part2(ranges; merged=false, sorted=false)
    if !merged
        ranges = mergeranges(ranges; sorted=sorted)
    end
    return sum(length, ranges)
end

part2_result = part2(mranges; merged=true, sorted=true)