using Test

filename = joinpath(@__DIR__, "input.txt")

function parseinput(filename)
    raw = read(filename, String)
    res = typeof(1:1)[]
    for line in eachsplit(raw, ',')
        a, b = parse.(Int, eachsplit(line, '-'))
        push!(res, a:b)
    end
    return Iterators.flatten(res)
end

input = parseinput(filename)

function part1(input)
    sum = 0
    for i in input
        digs = digits(i)
        isodd(length(digs)) && continue
        mid = div(length(digs), 2)
        @views if all(digs[1:mid] .== digs[mid+1:end])
            sum += i
        end
    end
    return sum
end

@testset "part1" begin
    input = """
    11-22,95-115,998-1012,1188511880-1188511890,222220-222224,
1698522-1698528,446443-446449,38593856-38593862,565653-565659,
824824821-824824827,2121212118-2121212124""" |> IOBuffer
    @test part1(parseinput(input)) == 1227775554
end

part1(input)

using IterTools
using Primes

function isinvalid(i)
    digs = digits(i)
    divs = divisors(length(digs))
    for d in divs[begin:end-1]
        allequal(partition(digs, d)) && return true
    end
    return false
end

isinvalid(111)

@testset "isinvalid" begin
    @test isinvalid(111) == true
    @test isinvalid(123456) == false
    @test isinvalid(121121) == true
    @test isinvalid(123123) == true
    @test isinvalid(999999) == true
    @test isinvalid(12341234) == true
    @test isinvalid(123123123) == true
    @test isinvalid(1212121212) == true
    @test isinvalid(1111111) == true
end

part2(input) = sum(Iterators.filter(isinvalid, input))

@testset "part2" begin
    input = """
    11-22,95-115,998-1012,1188511880-1188511890,222220-222224,
1698522-1698528,446443-446449,38593856-38593862,565653-565659,
824824821-824824827,2121212118-2121212124""" |> IOBuffer
    @test part2(parseinput(input)) == 4174379265
end

part2(input)
