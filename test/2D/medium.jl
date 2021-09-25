#=

A call to Resynthesizer using medium data:
large image and medium mask.

For testing mallocs.

Usage:

>julia
julia> include("medium.jl")
julia> @time test(image, mask)

OR

>julia --track-allocation=user
and the usual process for analyzing mallocs...
julia> include("medium.jl")
julia> test(image, mask)
julia>using Profile
julia>Profile.clear_malloc_data()
julia> test(image, mask)
=#

# For "load" local  files
using FileIO
# The tested item
include("../../src/apps/inpaint.jl")

# mock test data
# global so it persists and out of the test
image = load("/home/bootch/git/resynthesizerJulia/test/data/in/lighthouse.png")
# medium mask
mask = falses(size(image))
# 10x20 mask
mask[50:60,300:320] .= true

function test(image, mask)
    inpaint(image, mask)
end
