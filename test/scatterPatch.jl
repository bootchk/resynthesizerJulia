using Test
using Printf
using FileIO

# ScatterPatch depends on this
include("../src/image.jl")
include("../src/synthResult.jl")

# the tested code
include("../src/scatterPatch.jl")


include("tinyImage.jl")


@testset "ScatterPatch" begin

    # This mimics the startup of Resynthesizer
    testImage = createTestMaskedImage()
    testSynthResult = initialSynthResult(testImage)
    testSortedOffsets = createSortedOffsets(testImage.image)

    @debug "Sorted offset" testSortedOffsets

    # scatter patch distinguished point (origin) is upper left of synth
    testDistinguishedPoint = PointInMaskedImage( CartesianIndex(3,2), testImage)

    testScatterPatch = prepareScatterPatch(testDistinguishedPoint, testSynthResult, testSortedOffsets)

    # Original C algorithm.
    # The patchPoint origin is in the ScatterPatch (at offset 0,0)
    # We also know it should be the first element, since ordered by offset
    # @test any(neighbor.offset == CartesianIndex(0,0) for neighbor in testScatterPatch))
    #@test testScatterPatch[1].offset == CartesianIndex(0,0)

    # The patchPoint origin *not* in the ScatterPatch (at offset 0,0)
    @test ! any( neighbor.offset == CartesianIndex(0,0) for neighbor in testScatterPatch )

    # The point above  the origin is in the ScatterPatch ( at offset -1,0)
    # We know its the third element.
    # More generally, use any()
    @test testScatterPatch[2].offset == CartesianIndex(-1,0)

    # The point below the origin is not in the scatterPatch
    # because it is in the synth and has no value (not synthesized)
    @test ! any( neighbor.offset == CartesianIndex(1,0) for neighbor in testScatterPatch )

    # The point left of the origin is in the scatterPatch
    # because it is in the context and has a value
    @test any( neighbor.offset == CartesianIndex(0, -1) for neighbor in testScatterPatch )

    # The points are distinct
    # Specifically, the origin is not repeated
    # TODO

end
