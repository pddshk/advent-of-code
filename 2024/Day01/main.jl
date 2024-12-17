filename = joinpath(@__DIR__, "input.txt")
matrix = stack(line -> parse.(Int, split(line)), eachline(filename))

# 1st part
sum(eachcol(sort!(matrix; dims=2))) do (a, b)
    abs(a - b)
end

# 2nd part
using StatsBase
cm = countmap(@view matrix[2, :])
sum(i -> i * get(cm, i, 0), @view matrix[1, :])
