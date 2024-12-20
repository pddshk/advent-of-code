using Dates

year = isempty(ARGS) ? string(year(now())) : ARGS[1]

for i in 1:25
    path = joinpath(@__DIR__, year, "Day$(string(i; pad=2))")
    mkpath(path)
    mainjl = joinpath(path, "main.jl")
    isfile(mainjl) || write(mainjl, """filename = joinpath(@__DIR__, "input.txt")\n\nparseinput(filename) = read(filename, String)\n""")
    inputtxt = joinpath(path, "input.txt")
    isfile(inputtxt) || write(inputtxt, "\n")
end