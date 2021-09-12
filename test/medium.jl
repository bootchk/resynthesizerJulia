#=

A call to Resynthesizer using medium data:
large image and medium mask.

For testing mallocs.

Usage:

>julia
julia> include("medium.jl")
julia> @time test(img, mask)

OR

>julia --track-allocation=user
and the usual process for analyzing mallocs...
julia> include("medium.jl")
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
img = load("/home/bootch/git/resynthesizerJulia/test/data/lighthouse.png")
# medium mask
mask = falses(size(img))
# 10x20 mask
mask[50:60,300:320] .= true

function test(img, mask)
    # test resynthesizer
    resynthesize(img, mask)
end
