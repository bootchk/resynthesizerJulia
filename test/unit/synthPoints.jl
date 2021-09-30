using Test
using Printf
using FileIO


include("../../src/image.jl")


# the tested code
include("../../src/synthPoints.jl")


include("tinyImage.jl")

@testset "SortedOffsets" begin

    testImage = createTestMaskedImage()

    testSynthPoints = generateOrderedSynthPoints(testImage)

    println(testSynthPoints)
    @debug "Synth points" testSynthPoints

    for point in testSynthPoints
        println(point)
    end

end
