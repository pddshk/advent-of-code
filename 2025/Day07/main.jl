using Test

const filename = joinpath(@__DIR__, "input.txt")

function parseinput(filename)
    mat = stack(Vector{Char}, eachline(filename))  # do not transpose as columns work better in Julia
    mat = @view mat[:, any.(!=('.'), eachcol(mat))]
    mat = map(mat) do c
        if c == '.'
            0
        elseif c == '^'
            -1
        else
            1
        end
    end
    return mat
end

function trace_beam!(mat)
    m, n = size(mat)
    indexleft(ind) = ind + CartesianIndex(0, -1)
    cnt = 0
    for ind in CartesianIndices((1:m, 2:n))  # skip first col
        if mat[ind] != -1
            mat[ind] += max(0, mat[indexleft(ind)])
        else
            cnt += mat[indexleft(ind)] != 0
            for d in (CartesianIndex(-1, 0), CartesianIndex(1, 0))
                newind = ind + d
                mat[newind] += mat[indexleft(ind)]
            end
        end
    end
    return (part1_result=cnt, part2_result=sum(x -> max(x, 0), mat[:, end]))         
end

@testset "day 7" begin
    mat = parseinput(IOBuffer("""
    .......S.......
    ...............
    .......^.......
    ...............
    ......^.^......
    ...............
    .....^.^.^.....
    ...............
    ....^.^...^....
    ...............
    ...^.^...^.^...
    ...............
    ..^...^.....^..
    ...............
    .^.^.^.^.^...^.
    ..............."""))
    @test trace_beam!(mat) == (part1_result=21, part2_result=40)
end

trace_beam!(parseinput(filename))
