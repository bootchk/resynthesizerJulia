
include("pass.jl")
include("../synthPoints.jl")

#=
Make passes over image.
Each pass improves the image.
The first pass "synthesizes", later passes "re" synthesize.
The very earliest synthesized points are crude, so we synthesize them again.

Break when improvement to the target is small (to a threshold of goodness)
Otherwise to a maximum count of passes.

This understands the ordering of target points for the search.

Formerly known as "refiner"
=#

#=
Most preparation of was done earlier (especially for immutable, constant data)
So we do little additional prep here, but pass all arguments, without change, to each pass.

Except that we choose a subset of synth points for each pass.
=#
function makePassesUntilGoodEnough(
        targetImage::MaskedImage{ValueType, DimensionCount},
        corpusImage,
        synthPatch,
        synthResult,
        searchResult,
        sortedOffsets
        ) where{ValueType, DimensionCount}


    allSynthPoints = generateOrderedSynthPoints(targetImage)
    @assert isconcretetype(typeof(allSynthPoints))

    for i = 1:6  # MAX_PASSES, hardcoded here and in the original code

        #=
        The algorithm works better/faster when
        in later passes we concentrate on the earliest synthesized points
        and omit resynthesizing the later points.
        The original algorithm: on later passes, use a prefix subset of all target points.

        TODO subset the synth points as in original
        =#
        subsetSynthPoints = allSynthPoints  # !!! No subsetting.

        countBetterPixels = makeAPass(
            targetImage,
            corpusImage,
            subsetSynthPoints,
            synthPatch,
            synthResult,
            searchResult,
            sortedOffsets)

        #=
        In the original: IMAGE_SYNTH_TERMINATE_FRACTION.
        Hardcoded, not  a parameter
        =#
        if countBetterPixels < length(allSynthPoints) * 0.1
            @debug "Short circuit passes."
            break
        end
        @debug  "Pass $(i) found $(countBetterPixels) betters."
   end
end
