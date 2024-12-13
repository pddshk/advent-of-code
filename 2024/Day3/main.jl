filename = joinpath(@__DIR__, "input.txt")

str = read(filename, String)

function part1(str)
    sum(eachmatch(r"mul\((\d{1,3}),(\d{1,3})\)", str)) do match
        a, b = parse.(Int, match)
        a*b
    end
end

part1(str)

function part2(str)
    sum(eachmatch(r"(?s)(?:do\(\)|^)(.*?)(?:don't\(\)|$)", str)) do match
        part1(match[1])
    end
end

part2(str)
