#=
Fundamental result of the entire algorithm:
for each point in the masked region of the target image,
the coordinates (in the corpus frame)
of the best matching patch.

When the algorithm is "with replacement"
the target image is also mutated as the algorithm proceeds.

It is not the same thing to execute without replacement,
and only then mutate (set the color of) the target image
with the color from the best match in the corpus.
Since replacing as you go along gives an ever changing comparand for searches.

But you could also say that the mutated target is a result.
Thats the most used result, say for the "retouching" application.

After the algorithm,
1) hasValue is all true
2) and mapFromTargetToCorpusPoints is valid CartesianIndex in the synth region
and uninitialized elsewhere.
=#


#=
The arrays are the same shape as the target.

The arrays are ordinary.
The mapFromTargetToCorpusPoints is sparse:
most values not initialized, only values in the synth region ever get values.
But we don't use an implementation that uses less storage when sparse.

The frame of the arrays is the same as the frame of the target image.

TODO use a subarray with the same frame, but less storage???
i.e. an array that encloses the synthesized region of the target
=#


# Depends on image.jl because methods take instance of MaskedImage
include("../image.jl")  # MaskedImage


struct SynthResult{DimensionCount}
    #=
    Both the array, and its elements, have same DimensionCount.
    !!! The elements of the array are CartesianIndex.
    The eltype() is (CartesianIndex{DimensionCount})

    NOT AbstractArray.
    Resynthesizer chooses an implementation.
    =#
    mapFromTargetToCorpusPoints::Array{CartesianIndex{DimensionCount}, DimensionCount}
    hasValue::BitArray{DimensionCount}
end


#=
Return the initial SynthResult

No points in the synth region have been synthesized.
The coordinates of the best match for points in the synth region is unknown.

In original C, prepare_target_sources()
=#
function initialSynthResult(targetImage::MaskedImage)
    println("SynthResult initializer called")
    # arrays same shape as target

    #=
    Uninitialized array of CartesianIndex.
    Whose elements have same concrete type as the indices of targetImage
    e.g. CartesianIndex{N}

    TODO Really the indices of the corpusImage.
    For more generality, allow targetImage and corpusImage to have differing dimensions.
    =#
    elementType = CartesianIndex{ndims(targetImage.image)}

    mapFromTargetToCorpusPoints = similar(targetImage.image, elementType) # {DimensionCount})

    # boolean array false only in the synth region (the selected region give by the mask)
    hasValue = trues(size(targetImage.image))
    hasValue[targetImage.mask] .= false
    @debug "Initial hasValue map" hasValue

    result = SynthResult(mapFromTargetToCorpusPoints, hasValue)
    println(typeof(result))
    # Useless  to assert isconcretetype(result) since all structs are concrete
    return result
end

#=
Setter method of the SynthResult object.
=#
function setBetterSearchResult(
        synthResult::SynthResult{DimensionCount},
        targetIndex::CartesianIndex{DimensionCount},
        corpusIndex::CartesianIndex{DimensionCount}
        )::Nothing where {DimensionCount}
    synthResult.hasValue[targetIndex] = true
    synthResult.mapFromTargetToCorpusPoints[targetIndex] = corpusIndex
    return nothing
end


#=
Does the point have a value?
I.E. has been synthesized already?
Getter method of the SynthResult object.

All points in target outside the synth region have a value
(from initial image, never mutated.)
Otherwise only some points in the synth region of the target have a value
(have been synthesized i.e. mutated as search progresses and improves.)
This is only pertinent for the first pass, since the algorithm starts
by nullify or blacken the values of point in the synth region.
After the first pass, they have a value, albeit a crude value.
=#
function doesPointHaveValue(synthResult, patchPoint )::Bool
    # assert patchPoint and synthResult in same frame, the target
    return synthResult.hasValue[patchPoint]
end


#=
Is the targetPoint in the synth region (not the context)
AND has been synthesized (has a best match in the corpus.)

In original C code: has_source_neighbor()

!!! This is not the original implementation.
The original relies on sourceOf field of Neighbor,
i.e. on caching SynthResult.mapFromTargetToCorpusPoints[targetIndex] in the Neighbor.
Which probably gives better cpu cache coherence.
Since the implementation below:
1) accesses the original mask
2) accesses an inverted copy of the mask (SynthResult.hasValue)
both of which are large and both might not fit in the cpu cache.
=#
function isInSynthAndWasSynthesized(
        synthResult,
        targetMaskedImage, patchPoint   # framed point ::PointInMaskedImage)
        )::Bool
        # assert patchPoint is in target frame

    #=
    Order of the terms is important for performance:
    hasValue is  general, for any target point, and is usually true when target is much larger than synth region.
    =#
    return ( isPointSelectedInMaskedImage(targetMaskedImage, patchPoint)  # is in synth region
            && doesPointHaveValue(synthResult, patchPoint)
            )
end
