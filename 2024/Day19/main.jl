filename = joinpath(@__DIR__, "input.txt")

function parseinput(filename)
    raw = read(filename, String)
    towels, patterns = split(raw, "\n\n")
    towels = split(towels, ", ")
    patterns = split(patterns, "\n")
    String.(towels), patterns
end

function ispatternpossible(pattern, towels; sorted=false)
    possible_towels = filter(occursin(pattern), towels)
    sorted || sort!(possible_towels; by=length, rev=true)
    firstpossible = filter(towel -> startswith(towel)(pattern), possible_towels)
    lastpossible = filter(towel -> endswith(towel)(pattern), possible_towels)
    for firsttowel in firstpossible, lasttowel in lastpossible
        length(firsttowel) + length(lasttowel) > length(pattern) && continue
        firsttowel == pattern && return true
        patt = @view pattern[begin+length(firsttowel):end-length(lasttowel)]
        (patt == "" || ispatternpossible(patt, possible_towels; sorted=true)) && return true
    end
    return false
end

function part1(towels, patterns)
    sort(towels; by=length, rev=true)
    count(patterns) do pattern
        ispatternpossible(pattern, towels; sorted=true)
    end
end

const towels, patterns = parseinput(filename)

sort!(towels; by=length, rev=true)

part1(towels, patterns)

const memo = Dict{String, Int}("" => 1)
sizehint!(memo, 135000)

function count_possible_arrangements(pattern, towels; memo=memo)
    haskey(memo, pattern) && return memo[pattern]
    possible_towels = filter(occursin(pattern), towels)
    firstpossible = filter(towel -> startswith(towel)(pattern), possible_towels)
    lastpossible = filter(towel -> endswith(towel)(pattern), possible_towels)
    res = 0
    for firsttowel in firstpossible
        if pattern == firsttowel
            res += 1
            continue
        end
        for lasttowel in lastpossible
            pattern == lasttowel && continue
            length(firsttowel) + length(lasttowel) > length(pattern) && continue
            patt = pattern[begin+length(firsttowel):end-length(lasttowel)]
            res += count_possible_arrangements(patt, possible_towels)
        end
    end
    memo[pattern] = res
    return res
end

part2(patterns) = sum(pattern -> count_possible_arrangements(pattern, towels), patterns; init=1)

part2(patterns)