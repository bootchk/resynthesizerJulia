

include("neighbor.jl")


#=
Include the metric functions.
Include at least one metric function for every supported ValueType,
e.g. one for Color and one for Char.
When there are many implementations of metric having same signature, choose one.
=#
# TODO cruft here
include("metric/colorCauchy.jl")
include("metric/character/nieve.jl")
# include("colorMetric.jl")
# include("pointDifference.jl")


#=
Return difference between points in two different Arrays.
(E.G. difference between colors of pixels in 2D images.)

This hides dealing with bounds and masking in the corpus (see below.)
It generically calls pointDifference, a metric function (see elsewhere.)

The points belong to a patch.
Assert the center point of the corpus patch is ensured in bounds,
but the given point might not be.
Assert the center of the target patch is ensured in bounds.
And the center of the target patch is in the synth region.
And each given point of the target patch is ensured in bounds (by construction.)
Any given target point can be in the synth region or its complement (the context.)

In other words, patchPointCorpus is wild:
-possibly out of bounds
-possibly masked (a selection mask defines non-rectangular regions)
When masked or out of bounds, return a maximum difference.

Not a separate function in the original code.
=#


#=
OLD, when points were PointInMaskedImage i.e. carried their frame.

function comparePointsTargetWithCorpus(patchPointTarget, patchPointCorpus)
    result = 0

    # in bounds of the corpus (within the outer boundary)
    # and in the selected region of corpus (within interior boundaries so to speak)
    if isInBoundsAndSelected(patchPointCorpus)
        # call the metric.  See metric/ dir
        result = pointDifference(
            patchPointTarget,
            patchPointCorpus)
    else
        # We don't distinguish between out of bounds or masked, both yield maximum diff
        #@debug "Max color diff, masked or out of bounds" patchPointCorpus.point
        result = maxPointDifference()
    end

    return result
end
=#

#=
Specialized: first argument is Neighbor.
Where a Neighbor caches the value of its point.
=#
function comparePointsTargetWithCorpus(
    neighbor::Neighbor{ValueType, DimensionCount},
    corpusImage::MaskedImage{ValueType, DimensionCount}, # frame
    patchPointCorpus::CartesianIndex{DimensionCount}     # framed point
    ) where {DimensionCount, ValueType}

    # result has the return type of the metric
    result::Float32 = zero(Float32)

    #=
    Is in bounds of the corpus (within the outer boundary)
    and in the selected region of corpus (within interior boundaries so to speak).

    Named "clippedOrMaskedCorpus" in the original code.
    =#
    if isInBoundsAndSelected(corpusImage, patchPointCorpus)
        result = pointDifference(
            neighbor.value,                         # target value
            corpusImage.image[patchPointCorpus])    # corpus value
    else
        # We don't distinguish between out of bounds or masked, both yield maximum diff
        #@debug "Max point diff, masked or out of bounds" patchPointCorpus.point
        result = maxPointDifference
    end

    # @debug "Compare point, yields" patchPointCorpus result
    return result
end
