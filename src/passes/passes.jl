
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
    #=
    The ordering is the same for all passes.
    But later passes may resynthesize a subset.
    =#

    for passIndex = 1:6  # MAX_PASSES, hardcoded here and in the original code

        #=
        The algorithm works better/faster when
        in later passes we concentrate on the earliest synthesized points
        and omit resynthesizing the later points.
        The original algorithm: on later passes, use a prefix subset of all target points.

        TODO subset the synth points as in original
        =#
        subsetOfSynthPoints = subsetSynthPoints(allSynthPoints, passIndex)

        countBetterPixels = makeAPass(
            targetImage,
            corpusImage,
            subsetOfSynthPoints,
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
        @debug  "Pass $(passIndex) found $(countBetterPixels) betters."
   end
end




#=
Original by Paul Harrison was not a subset, but a superset, with repeats

Here, on third and subsequent passes,
only resynthesize a smaller and smaller prefix of all points.
=#
function subsetSynthPoints(allPoints, passIndex)
    # For test with no subsetting:  return allPoints

    if passIndex == 1
        return allPoints
    elseif passIndex == 2
        return allPoints
    else
        lastIndex = floor(Int, (0.75^(passIndex-1)) * length(allPoints))
        #=
         TODO assert inbounds??
         Not sure that a view performs well
        =#
        return view(allPoints, 1:lastIndex)
    end
end
