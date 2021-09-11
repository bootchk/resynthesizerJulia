using Test
using Printf
using FileIO

# testset for image

# the tested code
include("../src/image.jl")

# This exercises the constructors
include("tinyImage.jl")


@testset "Image" begin

    testImage = createTestMaskedImage()

    # point out of bounds
    testPoint = PointInMaskedImage( CartesianIndex(-1, -1), testImage)
    @test ! isInBoundsAndSelected(testPoint)

    # point in bounds and in mask
    testPoint = PointInMaskedImage( CartesianIndex(3,2), testImage)

    @test isPointSelectedInMaskedImage(testPoint)
    @test isInBoundsAndSelected(testPoint)

    # point in bounds but not in mask
    testPoint = PointInMaskedImage( CartesianIndex(1,1), testImage)
    @test ! isInBoundsAndSelected(testPoint)

end
