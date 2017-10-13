using CA

using Base.Test

const testdir = dirname(@__FILE__)

tests = [
   "Display",
   "Grid",
   "World",
   "ShortestPaths"
]

@testset "CA" begin
    for t in tests
        tp = joinpath(testdir, "$(t).jl")
        include(tp)
    end
end

