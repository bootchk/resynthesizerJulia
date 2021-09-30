

#=
Create a tiny image as test data
=#

#include("../src/image.jl")

function createTestMaskedImage()
    imagePath = "/home/bootch/git/resynthesizerJulia/test/data/in/tinylighthouse.png"
    image = load(imagePath)

    # The mask is more or less in the middle, with a frisket
    mask = falses(size(image))
    mask[3:4, 2:3] .= true

    # @printf("Image length %d\n", length(image))
    testMaskedImage = MaskedImage(image, mask)
    return testMaskedImage
end
