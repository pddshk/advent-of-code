filename = joinpath(@__DIR__, "input.txt")

function parseinput(filename)
    r = r"p=(\d{1,3}),(\d{1,3}) v=(\-?\d{1,3}),(\-?\d{1,3})"
    map(eachline(filename)) do line
        p1, p2, v1, v2 = parse.(Int, match(r, line))
        (p1, p2), (v1, v2)
    end
end

robots = parseinput(filename)

function part1(robots, nsec=100, mapsize=(101, 103))
    shifted = map(robots) do robot
        p, v = robot
        mod.(p .+ nsec .* v, mapsize)
    end
    m1, m2 = mapsize .÷ 2
    fst = count(shifted) do (p1, p2)
        p1 < m1 && p2 < m2
    end
    snd = count(shifted) do (p1, p2)
        p1 < m1 && p2 > m2
    end
    trd = count(shifted) do (p1, p2)
        p1 > m1 && p2 < m2
    end
    frt = count(shifted) do (p1, p2)
        p1 > m1 && p2 > m2
    end
    fst * snd * trd * frt
end

@time part1(robots)

function checkjolka(level, kernelsize=(5,5))
    start = CartesianIndex(1,1)
    step = CartesianIndex(kernelsize)
    stop = last(eachindex(IndexCartesian() ,level))-step
    @views for ind in start:step:stop
        all(level[ind:ind+step]) && return true
    end
    return false
end

function part2(robots, mapsize=(101, 103))
    ps = first.(robots)
    vs = last.(robots)
    counter = 1
    level = BitMatrix(undef, mapsize)
    while true
        level .= false
        for i in eachindex(ps)
            ps[i] = mod.(ps[i] .+ vs[i], mapsize)
        end
        for ind in ps
            level[CartesianIndex(ind .+ 1)] = true
        end
        checkjolka(level) && return counter
        counter += 1
        counter > 20000 && error("Not found")
    end
end

part2(robots)