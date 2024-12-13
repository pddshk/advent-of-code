filename = joinpath(@__DIR__, "input.txt")

inp = parse.(Int, split(read(filename, String)))

using Memoize

@memoize function blink(n::Int, count::Int)
    count == 0 && return 1
    if n == 0
        return blink(1, count-1)
    elseif iseven(ndigits(n))
        nd = 10^(ndigits(n) ÷ 2)
        l = n ÷ nd
        r = n % nd
        return blink(l, count-1) + blink(r, count-1)
    else
        return blink(2024n, count-1)
    end
end

part1(v, count=25) = sum(Base.Fix2(blink, count), v)

part1([1], 0)

@time part1(inp, 75)

memoize_cache(blink)