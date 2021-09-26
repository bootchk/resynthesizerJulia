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
image = load("/home/bootch/git/resynthesizerJulia/test/data/in/mediumlighthouse.png")

# selection mask for corpus
# medium
mask = falses(size(image))
mask[15:30,85:100] .= true

function test(image, mask)
    render(image, mask)
end

# Expect an image with texture of the lighthouse, everywhere
