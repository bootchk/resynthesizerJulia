#=

Test resynthesizer in 3D using commonly available test data.

=#

# The tested item
include("../../src/resynthesizer.jl")


using ImageView, Images


# Grab the open source test data
using TestImages
fullImage = testimage("mri");

println("fullImage is:")
println(summary(fullImage))

#=
See JuliaImages.
The image has named axes.
We only want to convert the data.
=#
image = fullImage.data
println("image is:")
println(summary(image))

# Create a mask
mask = falses(size(image))
mask[3:4, 2:3, 5:6] .= true

println("mask is:")
println(summary(mask))

function test(data, mask)
    result = resynthesize(data, mask)

    # Assert result is 3D array

    #=
    Chunk it back into the Image for display.
    =#
    #fullImage.data = result
    imshow(result)
end
