#=
Test resynthesizer in 4D using commonly available test data.
=#


# requires pkg OMETIFF
# using Pkg; Pkg.add("OMETIFF")
# OMETIFF supports 4D in .tiff format?


# The tested item
include("../../src/resynthesizer.jl")


using ImageMetadata

# Grab the open source test data
using TestImages
# "multi" is short name
fullImage = testimage("multi");

println("fullImage is:")
println(summary(fullImage))
# 167×439×3×7

#=
See JuliaImages.
The image has named axes.
And metadata??
We only want to convert the data.
Extract: data(fullImage), not fullImage.data??
=#
imageWithAxes = data(fullImage)
println("imageWithAxes is:")
println(summary(imageWithAxes))

imageView = imageWithAxes.data
println("image is:")
println(summary(imageView))

#=
imageView is still reshape(reinterpret(...)) which throws type errors.
Its a view.
So copy it.
=#
image = copy(imageView)
println("typeof copy")
println(typeof(image))

# Create a mask
mask = falses(size(image))
# ??? The third dimension is 3 channels.  Arbitrarily take them all.
mask[3:4, 2:3, 1:3, 5:6] .= true

println("mask is:")
println(summary(mask))

function test(data, mask)
    result = resynthesize(data, mask)

    # Assert result is 3D array

    #=
    Chunk it back into the Image for display.
    =#
    #fullImage.data = result
    # imshow(result)

    # return type so not massive print object
    typeof(result)
end

#imshow requires    using ImageView, Images
