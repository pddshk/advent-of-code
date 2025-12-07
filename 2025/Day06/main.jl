using Test

const filename = joinpath(@__DIR__, "input.txt")

function parseinput(filename)
    raw = read(filename, String)
    lines = split(raw, '\n'; keepempty=false)
    n = length(lines)
    ops = map(split(lines[end], ' '; keepempty=false)) do op
        op == "*" ? (*) : (+)
    end
    m = length(ops)
    items = Matrix{Int}(undef, n-1, m)
    for i in 1:n-1
        items[i, :] = parse.(Int, split(lines[i], ' '; keepempty=false))
    end
    return items, ops
end

@testset "parseinput" begin
    items, ops = parseinput(IOBuffer("""
    123 328   51  64 
     45  64  387  23 
      6  98  215 314
      *   +    *   + """))
    @test items == [123 328 51 64; 45 64 387 23; 6 98 215 314]
    @test ops == [(*), (+), (*), (+)]
end

function part1(items, ops)
    sum(zip(ops, eachcol(items))) do (op, col)
        reduce(op, col)
    end
end

@testset "part 1" begin
    items, ops = parseinput(IOBuffer("""
    123 328   51  64 
     45  64  387  23 
      6  98  215 314
      *   +    *   + """))
    @test part1(items, ops) == 4277556
end

part1_result = let (items, ops) = parseinput(filename)
    part1(items, ops)
end

function parseinput2(filename)
    raw = read(filename, String)
    lines = split(raw, '\n'; keepempty=false)
    n = length(lines)
    mat = @views hcat(Vector{Char}.(lines)...)
    display(mat)
    op = identity
    acc = 0
    acc2 = 0
    for row in eachrow(mat)
        if all(==(' '), row)
            @show op acc2
            acc += acc2
            continue
        end
        if row[end] == '*'
            op = (*)
            acc2 = 1
        elseif row[end] == '+'
            op = (+)
            acc2 = 0
        end
        val = join(row[1:end-1]) |> strip
        @show val
        acc2 = op(acc2, parse(Int, val))
    end
    acc += acc2
    return acc
end

@testset "parseinput2" begin
    result = parseinput2(IOBuffer("""
    123 328  51 64 
     45 64  387 23 
      6 98  215 314
    *   +   *   +  
    """))
    @test result == 3263827
end

parseinput2(filename)
