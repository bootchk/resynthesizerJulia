using Test
using Printf
using FileIO

# SortedOffsets depends on this
include("../../src/image.jl")
# include("../src/synthResult.jl")

# the tested code
include("../../src/sortedOffsets.jl")


include("tinyImage.jl")

@testset "SortedOffsets" begin

    testImage = createTestMaskedImage()

    testSortedOffsets = SortedOffsets(testImage.image)

    @debug "Sorted offsets" testSortedOffsets

    # offset 0,0 is not in
    @test ! any( offset == CartesianIndex(0,0) for offset in testSortedOffsets.offsets )

    # TODO add .offsets below

    # lower right of image is last element of sortedOffsets
    # Is  this a robust test?  Other large distance offset could be in last element?
    dimensions = size(testImage.image)
    @test last(testSortedOffsets) == CartesianIndex(dimensions)

    # sortedOffsets are unique
    @test length(unique(testSortedOffsets)) == length(testSortedOffsets)

    # sortedOffsets spans
    # approximately four times
    # TODO exact is (2x+1)(2y+1) == 4xy + 2x + 2y + 1
    @test length(testSortedOffsets) >=  4 * length(testImage.image)
end
