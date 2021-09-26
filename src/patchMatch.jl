
include("pointCompare.jl")
include("offset.jl")
include("scatterPatch.jl")

#=
Match a patch.
A probe of a search.
The patch was built from the target.
Compare to patch around given point in corpus.

Return ProbeResult

This understands:
- iteration over points of a patch
- short circuit as soon as discover patch cannot be better

Formerly known as computeBestFit()
=#
function patchMatch(
    targetImage::MaskedImage{ValueType, DimensionCount},
    corpusImage::MaskedImage{ValueType, DimensionCount},
    # corpusPatchCenterPoint::Int64,    # framed point, using linear indexing
    corpusPatchCenterPoint::CartesianIndex{DimensionCount},
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

        # OLD offset points directly
        # patchPointCorpus = corpusPatchCenterPoint + neighbor.offset
        # NEW separate function to mutate
        patchPointCorpus = offsetPatchPoint(corpusImage.image, corpusPatchCenterPoint, neighbor.offset)

        # is wild, might be out of bounds

        # Difference of value of patchPoint (from the target) to value of corresponding point in corpus
        # TEMP test specialized calls
        differenceSum += comparePatchPoints(
            neighbor, # Neighbor caches values of a framed point in target
            corpusImage, patchPointCorpus   # framed point
            )

        if differenceSum >= patchDiffToBeat
            # patch is already worse than previous best
            # @debyg "Short circuit patch match"
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
