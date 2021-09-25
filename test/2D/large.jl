#=

A call to Resynthesizer using large image.

For testing mallocs.

Usage:

>julia
julia> include("large.jl")
julia> @time test(image, mask)

OR

>julia --track-allocation=user
and the usual process for analyzing mallocs...
julia> include("large.jl")
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
# large mask
mask = falses(size(image))
mask[50:350,300:400] .= true

function test(image, mask)
    inpaint(image, mask)
end
