using Mods
using Test

const filename = joinpath(@__DIR__, "input.txt")

function part1(init=Mod{100}(50), lines=eachline(filename))
    cnt = 0
    for line in lines
        op = line[1] == 'R' ? (+) : (-);
        init = op(init, parse(Int, line[2:end]))
        if iszero(init)
            cnt += 1
        end
    end
    return cnt
end

@testset "Part 1" begin
    input = """
    L68
    L30
    R48
    L5
    R60
    L55
    L1
    L99
    R14
    L82"""
    @test part1(Mod{100}(50), eachsplit(input, '\n')) == 3
end

part1_result = part1()

function part2(state=50, lines=eachline(filename), modulus=100)
    cnt = 0
    for line in lines
        dist = parse(Int, line[2:end])
        dir = line[1] == 'R'
        if dir
            newstate = state + dist
        else
            newstate = state - dist
        end
        n, newstate = divrem(newstate, modulus, RoundDown)
        n = abs(n)
        if newstate == 0
            cnt += !dir
        end
        if state == 0 && n > 0 && !dir
            n -= 1
        end
        cnt += n
        state = newstate
    end
    return cnt
end

@testset "Part 2" begin
    input = """
    L68
    L30
    R48
    L5
    R60
    L55
    L1
    L99
    R14
    L82"""
    @test part2(50, eachsplit(input, '\n')) == 6
    input = """
    L1
    R1"""
    @test part2(1, eachsplit(input, '\n')) == 1
    input = """
    R1000"""
    @test part2(50, eachsplit(input, '\n')) == 10
    input = """
    L1000"""
    @test part2(50, eachsplit(input, '\n')) == 10
    input = """
    L1
    R1"""
    @test part2(1, eachsplit(input, '\n')) == 1
    input = """
    L101"""
    @test part2(1, eachsplit(input, '\n')) == 2
end

part2_result = part2()

function stupidpart2(state=50, lines=eachline(filename), modulus=100)
    cnt = 0
    for line in lines
        dist = parse(Int, line[2:end])
        if line[1] == 'R'
            for _ in 1:dist
                state += 1
                state = mod(state, modulus)
                cnt += state == 0
            end
        else
            for _ in 1:dist
                state -= 1
                state = mod(state, modulus)
                cnt += state == 0
            end
        end
    end
    return cnt
end

stupidpart2_result = stupidpart2()
