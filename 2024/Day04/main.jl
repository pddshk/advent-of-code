filename = joinpath(@__DIR__, "input.txt")

mat = stack(Vector{Char}, eachline(filename))

using IterTools
using LinearAlgebra

function countxmases(v)
    count(partition(v, 4, 1)) do part
        all(part .== ['X', 'M', 'A', 'S']) ||
        all(part .== ['S', 'A', 'M', 'X'])
    end
end

function secondarydiag(mat, i=1)
    inds = collect(zip(1:i, reverse(1:i)))
    filter!(inds) do (i,j)
        checkbounds(Bool, mat, i, j)
    end
    (mat[i, j] for (i,j) in inds)
end

maindiags(mat) = (diag(mat, i) for i in -size(mat,1):size(mat, 2))
secondarydiags(mat) = (secondarydiag(mat, i) for i in 1:2size(mat, 2))

secondarydiags(mat)
secondarydiag(mat, 140)
collect(last(secondarydiags(mat)))

iters = (eachcol, eachrow, maindiags, secondarydiags)

sum(countxmases, Iterators.flatten(Ref(mat) .|> iters))

function isgood!(mat)
    mat[2:2:end] .= '.'
    mat == ['M' '.' 'S'; '.' 'A' '.'; 'M' '.' 'S'] ||
    mat == ['S' '.' 'S'; '.' 'A' '.'; 'M' '.' 'M'] ||
    mat == ['M' '.' 'M'; '.' 'A' '.'; 'S' '.' 'S'] ||
    mat == ['S' '.' 'M'; '.' 'A' '.'; 'S' '.' 'M']
end

function part2(mat)
    rows, cols = axes(mat)
    count(isgood!(mat[collect(is), collect(js)]) for is in partition(rows, 3, 1), js in partition(cols, 3, 1))
end

part2(mat)