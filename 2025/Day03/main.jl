using Test

filename = joinpath(@__DIR__, "input.txt")

function parseinput(filename)
    stack(line -> [Int(c - '0') for c in line], eachline(filename))
end

input = parseinput(filename)

function maxjoltage(vec)
    vmax, imax = findmax(vec)
    if imax == lastindex(vec)
        v2max = maximum(@view vec[1:imax-1])
        return 10v2max + vmax
    else
        v2max = maximum(@view vec[imax+1:end])
        return 10vmax + v2max
    end
end

@testset "maxjoltage tests" begin
    @test maxjoltage([1,2,3,4,5]) == 45
    @test maxjoltage([5,4,3,2,1]) == 54
    @test maxjoltage([1,3,5,2,4]) == 54
    @test maxjoltage([2,3,5,4,1]) == 54
end

function part1(input)
    sum(maxjoltage, eachcol(input))    
end

@testset "part1 tests" begin
    input = parseinput(IOBuffer("""
    987654321111111
    811111111111119
    234234234234278
    818181911112111"""))
    @test part1(input) == 357
end

part1_result = part1(input)

function maxjoltage2(vec, acc=0, cnt=0)
    if cnt == 12
        return acc
    end
    vmax, imax = findmax(@view vec[begin:end-12+cnt+1])
    return maxjoltage2(vec[imax+1:end], 10acc + vmax, cnt + 1)
end

@testset "maxjoltage2 tests" begin
    @test maxjoltage2(fill(1, 12)) == 111_111_111_111
    @test maxjoltage2([1,2,3,4,5,6,7,8,9,1,1,1]) == 123456789111
end

function part2(input)
    sum(maxjoltage2, eachcol(input))    
end

@testset "part2 tests" begin
    input = parseinput(IOBuffer("""
    987654321111111
    811111111111119
    234234234234278
    818181911112111"""))
    @test part2(input) == 3121910778619
end

part2_result = part2(input)
