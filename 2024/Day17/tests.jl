using Test

@testset "Part 1" begin
    inp1 = """
    Register A: 729
    Register B: 0
    Register C: 0

    Program: 0,1,5,4,3,0"""

    s1 = parseinput(IOBuffer(inp1))
    @test process!(s1) == [4,6,3,5,6,3,5,2,1,0]

    inp2 = """
    Register A: 21539243
    Register B: 0
    Register C: 0

    Program: 2,4,1,3,7,5,1,5,0,3,4,1,5,5,3,0
    """
    s2 = parseinput(IOBuffer(inp2))
    @test process!(s2) == [6,7,5,2,1,3,5,1,7]
end