using LinearAlgebra
using Test

const filename = joinpath(@__DIR__, "input.txt")

struct Region
    width::Int
    length::Int
    shapes::NTuple{6, Int}
end

function parseinput(filename)
    shape = r"\d:\n(?<shape>(?:[.#]{3}\n){3})"
    raw = read(filename, String)
    shapes = map(eachmatch(shape, raw)) do m
        stack(line -> [c == '#' for c in line], eachline(IOBuffer(m["shape"])))
    end
    region = r"(?<w>\d+)x(?<l>\d+): (?<nums>(?:\d+ ?)+)"
    regions = map(eachmatch(region, raw)) do m
        w = parse(Int, m["w"])
        l = parse(Int, m["l"])
        nums = parse.(Int, split(m["nums"])) |> Tuple
        Region(w, l, nums)
    end
    return shapes, regions
end

shapes, regions = parseinput(filename)

count(regions) do region
    area = region.width * region.length
    to_fit_area = 7sum(region.shapes)
    area >= to_fit_area
end |> println
