filename = joinpath(@__DIR__, "input.txt")

# part1
checker(line::AbstractString) = checker(parse.(Int, split(line)))

using IterTools

⟹(a::Bool, b::Bool) = a <= b

function checker(levels::AbstractVector{<:Integer})
    allless = levels[1] < levels[2]
    return all(partition(levels, 2, 1)) do (p, n)
        (allless == (p < n)) && 1 <= abs(p - n) <= 3
    end
end

function checker(levels::AbstractVector)
    diffs = @views Iterators.map(-, levels[begin:end-1], levels[begin+1:end])
    allequal(sign, diffs) && all(<(4) ∘ abs, diffs)    
end

count(checker, eachline(filename))

# part2

checker2(line::AbstractString) = checker2(parse.(Int, split(line)))

using InvertedIndices

function checker2(levels::AbstractVector{<:Integer})
    checker(levels) && return true
    diffs = @views levels[begin:end-1] .- levels[begin+1:end]
    jumps = findall(>(3) ∘ abs, diffs)
    length(jumps) > 2 && return false
    to_check = copy(jumps)
    g0 = findall(>(0), diffs)
    l0 = findall(<(0), diffs)
    e0 = findall(==(0), diffs)
    append!(to_check, length(g0) > length(l0) ? l0 : g0, e0)
    union!(to_check, to_check .+ 1)
    any(to_check) do i
        @inbounds @views checker(levels[Not(i)])
    end
end
maximum(length∘split, eachline(filename))

count(checker2, eachline(filename))

checker2([1, 2, 3, 6, 4, 5])
checker2([3, 1, 2, 4, 5])
checker2([1, 2, 3, 7, 4, 5])