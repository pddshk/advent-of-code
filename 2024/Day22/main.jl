filename = joinpath(@__DIR__, "input.txt")

parseinput(filename) = parse.(Int, eachline(filename))

@inline mix(secret, value) = secret ⊻ value

@inline prune(value) = mod(value, 16777216)

function step(secret)
    secret = prune(mix(secret, 64secret))
    secret = prune(mix(secret, secret ÷ 32))
    secret = prune(mix(secret, 2048secret))
    return secret
end

function part1!(nums)
    for _ in 1:2000
        nums .= step.(nums)
    end
    sum(nums)
end

part1(nums) = part1!(copy(nums))

nums = parseinput(filename)

part1(nums)

function generate_secrets(num; nsecrets=2000)
    res = Vector{Int}(undef, nsecrets)
    res[1] = num
    for i in 2:nsecrets
        res[i] = step(res[i-1])
    end
    res
end

using IterTools

function prices_to_seq(prices)
    deltas = @views prices[2:end] .- prices[1:end-1]
    Dict{NTuple{4, Int}, Int}(
        Iterators.zip(
            partition(Iterators.reverse(deltas), 4, 1),
            Iterators.reverse(@view prices[5:end])
        )
    )
end

function merge_dicts!(d1, d2)
    for k in keys(d2)
        if haskey(d1, k)
            d1[k] += d2[k]
        else
            d1[k] = d2[k]
        end
    end
    d1
end

function part2(nums)
    d = mapreduce(merge_dicts!, nums) do num
        prices = generate_secrets(num)
        prices .%= 10
        prices_to_seq(prices)
    end
    findmax(d)[1]
end

@time part2(nums)