filename = joinpath(@__DIR__, "input.txt")

function parseinput(filename)
    taskRexp = r"Button A: X\+(\d+), Y\+(\d+)\nButton B: X\+(\d+), Y\+(\d+)\nPrize: X=(\d+), Y=(\d+)"
    map(eachmatch(taskRexp, read(filename, String))) do m
        parse.(Int, Tuple(m))
    end

end

tasks = parseinput(filename)

# ax + by = p

# a1 x + b1 y == p1
# a2 x + b2 y == p2

# a1 x + b1 y == p1
# x == (p2 - b2*y)/a2

# a1 (p2 - b2 y) / a2 + b1 y == p1
# a1 p2/a2 - a1 b2 y / a2 + b1 y == p1
# b1 y - b2 y a1 / a2 == p1 - p2 a1/a2
# y (b1 - b2 a1/a2) == p1 - p2 a1/a2
# y = (p1 - p2*a1/a2)/(b1 - b2*a1/a2)
# x = (p2 - b2*((p1 - p2*a1/a2)/(b1 - b2*a1/a2)))/a2

function solvetask((a1, a2, b1, b2, p1, p2); shift=0)
    p1 += shift
    p2 += shift
    y = (p1 - p2*a1//a2)//(b1 - b2*a1//a2)
    x = (p2 - b2*((p1 - p2*a1//a2)//(b1 - b2*a1//a2)))//a2
    return isinteger(x) && isinteger(y) ? (Int(x), Int(y)) : (0, 0)
end

function part1(tasks)
    sum(tasks) do task
        x, y = solvetask(task)
        3x + y
    end
end

part1(tasks)

function part2(tasks)
    sum(tasks) do task
        x, y = solvetask(task; shift=10000000000000)
        3x + y
    end
end

@time part2(tasks)