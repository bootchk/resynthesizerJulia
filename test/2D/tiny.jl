#=

A call to Resynthesizer using tiny image.

For testing mallocs.

Usage:

>julia
julia> include("tiny.jl")
julia> @time test(img, mask)

OR

>julia --track-allocation=user
and the usual process for analyzing mallocs...
julia> include("tiny.jl")
julia> test(img, mask)
julia>using Profile
julia>Profile.clear_malloc_data()
julia> test(img, mask)
=#

# For "load" local  files
using FileIO
# The tested item
include("../src/resynthesizer.jl")

# mock test data
# global so it persists and out of the test
img = load("/home/bootch/git/resynthesizerJulia/test/data/tinylighthouse.png")
# small mask
mask = falses(size(img))
mask[3:4, 2:3] .= true

function test(img, mask)
    # test resynthesizer
    resynthesize(img, mask)
end
