#=

A call to Resynthesizer using tiny image.

For testing mallocs.

Usage:

>julia
julia> include("tiny.jl")
julia> @time test(image, mask)

OR

>julia --track-allocation=user
and the usual process for analyzing mallocs...
julia> include("tiny.jl")
julia> test(image, mask)
julia>using Profile
julia>Profile.clear_malloc_data()
julia> test(image, mask)
=#

# For "load" local  files
using FileIO
# The tested item
include("../../src/resynthesizer.jl")

# mock test data
# global so it persists and out of the test
image = load("/home/bootch/git/resynthesizerJulia/test/data/in/tinylighthouse.png")
# small mask
mask = falses(size(image))
mask[3:4, 2:3] .= true

function test(image, mask)
    # test resynthesizer
    resynthesize(image, mask)
end
