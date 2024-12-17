filename = joinpath(@__DIR__, "input.txt")

function parseInput(filename)
    rules, pages = split(read(filename, String), "\n\n")
    pages = split.(eachline(IOBuffer(pages)), ",")
    rules = reverse.(split.(eachline(IOBuffer(rules)), "|"))
    rules, pages
end

function isgood(rules, v)
    n = length(v)
    for i in 1:n, j in i+1:n
        [v[i], v[j]] in rules && return false
    end
    return true
end

rules, pages = parseInput(filename)

function part1(rules, pages)
    sum(pages) do page
        isgood(rules, page) || return 0
        parse(Int, page[length(page) ÷ 2 + 1])
    end
end

part1(rules, pages)

using DataStructures

function part2(rules, pages)
    dd = DefaultDict(true, Dict(Tuple.(rules) .=> false))
    lt(a, b) = dd[(a, b)]
    sum(pages) do page
        isgood(rules, page) && return 0
        sorted = sort(page; lt=lt, alg=InsertionSort)
        parse(Int, sorted[length(page) ÷ 2 + 1])
    end
end

part2(rules, pages)