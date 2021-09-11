
include("pointCompare.jl")

#=
Match a patch.
A probe of a search.
The patch was built from the target, compare to given point in corpus.

Return ProbeResult

This understands:
- iteration over points of a patch
- short circuit as soon as discover patch cannot be better

Formerly known as computeBestFit()
=#
function patchMatch(
    targetImage::MaskedImage{ValueType, DimensionCount}, corpusImage::MaskedImage{ValueType, DimensionCount},
    corpusPatchCenterPoint::CartesianIndex{DimensionCount},    # framed point
    synthPatch::ScatterPatch{ValueType, DimensionCount},
    patchDiffToBeat::Float32   # For this target patch, but only while the target is unchanged
    )::ProbeResult where {ValueType, DimensionCount}
    #=
    Iterate over patch of corpus surrounding corpusPoint,
    summing point difference from corresponding patch in source/target.

    A patch is a vector of offsets.
    Offset (can be negative) is not a subtype of Point (only positive)
    Adding an Offset to a Point yields a Point that can be out of range in its frame,
    so the comparison allows that, and compensates.

    As long as patches are not huge,
    no need to worry about loss of precision.
    We are summing many numbers each ~1.0
    =#
    differenceSum::Float32 = zero(Float32)

    # Framed point to mutate in the for loop
    #=
    patchPointCorpus = PointInMaskedImage(
        corpusPatchCenterPoint.point,          # point mutates in the loop
        corpusPatchCenterPoint.maskedImage )   # frame is constant in the loop
    =#
    # patchPointCorpus::CartesianIndex{N}   # N not defined

    #=
    Iterate over points of the patch.

    !!! The patch may be empty:
    when the context is empty, on the first point of the first pass.
    =#
    for neighbor in synthPatch.neighbors

        # Mutate the point of the framed point.  CartesianIndex arithmetic.
        #=
        OLD too many allocations???
        foo = corpusPatchCenterPoint.point + patchPoint.offset
        println("types")
        println(typeof(corpusPatchCenterPoint.point))
        println(typeof(patchPoint.offset))
        patchPointCorpus.point =  foo
        =#

        # NEW separate function to mutate
        # offsetPatchPoint(patchPointCorpus, corpusPatchCenterPoint.point, patchPoint.offset)

        # NEW create a new immutable
        #= OLD framed,
        patchPointCorpus = PointInMaskedImage(
            corpusPatchCenterPoint.point + patchPoint.offset,
            corpusPatchCenterPoint.maskedImage )
        =#
        patchPointCorpus = corpusPatchCenterPoint + neighbor.offset
        # is wild


        # Difference of value of patchPoint (from the target) to value of corresponding point in corpus
        # TEMP test specialized calls
        differenceSum += comparePatchPoints(
            neighbor, # Neighbor caches values of a framed point in target
            corpusImage, patchPointCorpus   # framed point
            )

        if differenceSum >= patchDiffToBeat
            # patch is already worse than previous best
            # println("Short circuit patch match")
            break
        end
    end

    #=
    # assert differenceSum >= patchDiffToBeat
    or is < and is computed over the entire patch
    =#

    # Classify the betterment
    betterment = classifyBetterment(differenceSum, patchDiffToBeat)

    return ProbeResult(betterment, differenceSum)
end



#=

function offsetPatchPoint(
    patchPoint::PointInMaskedImage, point::CartesianIndex, offset::CartesianIndex)
    patchPoint.point = point + offset
end
=#
