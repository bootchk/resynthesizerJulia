
using Printf
using Random

include("pass.jl")

#=
Make passes over image.
Each pass improves the image.
Break when improvement to the target is small (to a threshold of goodness)
Otherwise to a maximum count of passes.

This understands the ordering of target points for the search.

Formerly known as "refiner"
=#

#=
Most preparation of was done earlier (especially for immutable, constant data)
So we do little additional prep here, but pass all arguments, without change, to each pass.
Except that we prepare targetPoints anew for each pass.
=#
function makePassesUntilGoodEnough(
        targetImage::MaskedImage{ValueType, DimensionCount},
        corpusImage,
        synthPatch,
        synthResult,
        sortedOffsets
        ) where{ValueType, DimensionCount}
    for i = 1:6  # MAX_PASSES, hardcoded here and in the original code

        #=
        The nature of the algorithm is that the very earliest synthesized points are crude.
        The algorithm works better/faster if in later passes we concentrate on those points
        and omit resynthesizing the later points.
        The original algorithm: on later passes, use a prefix subset of all target points.

        TODO pass in candidateTargetPoints and rename this subsetCandidateTargetPoints
        =#
        targetPoints = generateOrderedSynthPoints(targetImage)
        @assert isconcretetype(typeof(targetPoints))

        countBetterPixels = makeAPass(
            targetImage,
            corpusImage,
            targetPoints,
            synthPatch,
            synthResult,
            sortedOffsets)

        #=
        In the original: IMAGE_SYNTH_TERMINATE_FRACTION.
        Hardcoded, not  a parameter
        =#
        if countBetterPixels < length(targetPoints) * 0.1
            @debug "Short circuit passes."
            break
        end
        @debug  "Pass $(i) found $(countBetterPixels) betters."
   end
end




#=
Return vector of points to be synthesized.
Those points that are masked.
Points in frame of the target image.
Ordered in scan order (i.e. whatever order findall() creates)

findall returns a vector of indices, not the elements i.e. not a Bool.
=#
function generateSynthPoints(
        target::MaskedImage{ValueType, DimensionCount}
        )::Vector{CartesianIndex{DimensionCount}} where{ValueType, DimensionCount}
    return findall(target.mask)
end


#=
Return vector of points to be synthesized.
Those points that are masked.
Points in frame of the target image.
Ordered by the optional ordering function, else the default: shuffled.

The order causes a "direction" of synthesis, e.g. brushfire from a boundary.
Random is a reasonable default.
Scan order (across, then down or vice versa) usually bad.
Other orders, say brushfire inwards, often give better results.
=#
function generateOrderedSynthPoints(
        target::MaskedImage{ValueType, DimensionCount}
        )::Vector{CartesianIndex{DimensionCount}} where{ValueType, DimensionCount}
    return shuffle(generateSynthPoints(target));
end
