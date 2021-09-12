#=

A call to Resynthesizer using large image.

For testing mallocs.

Usage:

>julia
julia> include("large.jl")
julia> @time test(img, mask)

OR

>julia --track-allocation=user
and the usual process for analyzing mallocs...
julia> include("large.jl")
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
# large mask
mask = falses(size(img))
mask[50:350,300:400] .= true

function test(img, mask)
    # test resynthesizer
    resynthesize(img, mask)
end
