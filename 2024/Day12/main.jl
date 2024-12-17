filename = joinpath(@__DIR__, "input.txt")

parseinput(filename) = permutedims(stack(Vector{Char}, eachline(filename)))

const movements = CartesianIndex.(((1,0),(-1,0),(0,1),(0,-1)))

level = parseinput(filename)

function marklevel(level)
    marks = zeros(Int, axes(level))
    for ind in eachindex(IndexCartesian(), level), m in movements
        neigh = m + ind
        marks[ind] += checkbounds(Bool, level, neigh) && level[ind] != level[neigh]
    end
    marks[begin, :] .+= 1
    marks[end, :] .+= 1
    marks[:, begin] .+= 1
    marks[:, end] .+= 1
    marks
end

using DataStructures

function part1(level)
    marks = marklevel(level)
    used = zeros(Int8, axes(level))
    guy = findfirst(iszero, used)
    cost = 0
    i1 = 0
    q = Queue{CartesianIndex}()
    while !isnothing(guy)
        used[guy] = 1
        enqueue!(q, guy)
        i2 = 0
        while !isempty(q)
            cur = dequeue!(q)
            for movement in movements
                nxt = cur + movement
                if checkbounds(Bool, level, nxt) && level[cur] == level[nxt] && used[nxt] == 0
                    enqueue!(q, nxt)
                    used[nxt] = 1
                end
            end
            i2 += 1
            i2 > 20000 && error("INNER STUCK")
        end
        selector = used .== 1
        s = count(selector)
        p = sum(marks[selector])
        # @show (p, s, p*s)
        cost += p*s
        used[selector] .= -1
        guy = findfirst(iszero, used)
        i1 += 1
        i1 > 20000 && error("OUTER STUCK")
    end
    cost, i1
end

part1(level)

using IterTools

function countwallsfromdir(sliceiter)
    x, xs = firstrest(sliceiter)
    prevdist = find(==(1), x)
    nwalls = Int(!isnothing(prevdist))
    for row in xs
        nxtdist = findall(==((0, 1)), collect(IterTools.partition(row, 2, 1)))
        if prevdist != nxtdist
            nwalls += 1
            prevdist = nxtdist
        end 
    end
    nwalls
end

function countwallsfromdir(sliceiter)
    toonecheck = in(((0, 1), (-1, 1)))
    tozerocheck = in(((1, 0), (1, -1)))
    x, xs = firstrest(sliceiter)
    pars = collect(IterTools.partition([0; x; 0], 2, 1))
    prev2one = findall(toonecheck, pars)
    prev2zero = findall(tozerocheck, pars)
    nwalls = 2length(prev2one)
    for row in xs
        pars = collect(IterTools.partition([0; row; 0], 2, 1))
        nxt2one = findall(toonecheck, pars)
        nxt2zero = findall(tozerocheck, pars)
        nwalls += length(setdiff(nxt2one, prev2one))
        nwalls += length(setdiff(nxt2zero, prev2zero))
        prev2one = nxt2one
        prev2zero = nxt2zero
    end
    nwalls
end

function countwalls(used)
    2countwallsfromdir(eachrow(used))# +
    # countwallsfromdir(eachcol(used))
end

function part2(level)
    used = zeros(Int8, axes(level))
    guy = findfirst(iszero, used)
    cost = 0
    i1 = 0
    q = Queue{CartesianIndex}()
    while !isnothing(guy)
        used[guy] = 1
        enqueue!(q, guy)
        i2 = 0
        while !isempty(q)
            cur = dequeue!(q)
            for movement in movements
                nxt = cur + movement
                if checkbounds(Bool, level, nxt) && level[cur] == level[nxt] && used[nxt] == 0
                    enqueue!(q, nxt)
                    used[nxt] = 1
                end
            end
            i2 += 1
            i2 > 20000 && error("INNER STUCK")
        end
        selector = used .== 1
        s = count(selector)
        p = countwalls(used)
        # @show (p, s, p*s)
        cost += p*s
        used[selector] .= -1
        guy = findfirst(iszero, used)
        i1 += 1
        i1 > 20000 && error("OUTER STUCK")
    end
    cost
end

@time part2(level)

using Test

@testset "Part 2" begin
    inputs = parseinput.(IOBuffer.([
        """
        RRRRIICCFF
        RRRRIICCCF
        VVRRRCCFFF
        VVRCCCJFFF
        VVVVCJJCFE
        VVIVCCJJEE
        VVIIICJJEE
        MIIIIIJJEE
        MIIISIJEEE
        MMMISSJEEE""",
        """
        AAAAAA
        AAABBA
        AAABBA
        ABBAAA
        ABBAAA
        AAAAAA""",
        """
        EEEEE
        EXXXX
        EEEEE
        EXXXX
        EEEEE""",
        """
        OOOOO
        OXOXO
        OOOOO
        OXOXO
        OOOOO""",
    ]))
    outputs = [1206, 368, 236, 436]
    for (inp, outp) in zip(inputs, outputs)
        @test part2(inp) == outp
    end
end

testinp = parseinput(IOBuffer("""
.........D..DDDD.......
........DDDDDDDDD......
........DDDDDDDDD......
.......DDDDDDDDDD......
........DDDDDDDDD......
......DDDDDDDDDDDDDD...
......DDDDDDDDDDDDD....
......DDDDDDDD...DD....
.......DDDDDDDDD.......
....DDDDDD.DDDDD.......
.....DDDD..............
......................."""))

11+9+10+9

part1(testinp)
part2(testinp)

countwallsfromdir(eachrow(testinp .== 'D'))
countwallsfromdir(eachcol(testinp .== 'D'))

open("out.txt", "w") do io
    for (c, i) in prs
        println(io, c, " ", i)
    end
end
