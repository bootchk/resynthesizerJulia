#=

A call to app/render using tiny image.

>julia
julia> include("render.jl")
julia> @time test(image)
=#

# For "load" local  files
using FileIO
# The tested item
include("../../src/apps/render.jl")

# mock test data
# global so it persists and out of the test
image = load("/home/bootch/git/resynthesizerJulia/test/data/in/tinylighthouse.png")

# selection mask for corpus
mask = falses(size(image))
mask[3:4, 2:3] .= true

function test(image, mask)
    render(image, mask)
end
