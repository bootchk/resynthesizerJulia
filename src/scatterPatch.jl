

include("neighbor.jl")
include("sortedOffsets.jl")
include("result/synthResult.jl")

#=
A patch that can be neither rectangular nor contiguous.
That is, it can be an irregular shape and sparse.

Shape
=======

Irregular i.e. non-centered

 Here continuguous but skewed with distinguished point in corner
 XXX
 XXC

Here, non-contiguous

X  X  X
X
X  C
X XXXXX

Here, non-rectangular but nearest to distinguished point.

 X
XCX
 X


Length
======

All ScatterPatch's need not have the same length.
Depending on the given images and the stage of the process,
the length of a ScatterPatch might not be as large as we desire.
The algorithm does not require the given tensors (usually images)
to be larger than a minimum size needed to create lengthy patches.
More discussion later, under "testing."

The usual size is defined by parameters.maxPatchSize

Disambiguation
==============

Originally called neighbors (plural) or neighborhood, but that denotes contiguous.
We still use the word neighbor for an element of a scatterPatch,
since neighbor (singular) does not denote adjacent.

Patches vary across and within passes of the algorithm
======================================================

During the Resynthesizer process, when repeating a point,
the point's scatterPatch might have more, different, closer neighbors
than on a prior (especially the first) pass.
IOW a scatterPatch is like a shotgun pattern in the first pass,
but a contiguous patch in later passes.

Also, since we are replacing the value of a point,
that affects the patches of its nearby points.

Distinguished point
===================

A scatterPatch is around a distinguished point.
Often, but not necessarily, the distinguished point is near the center.
An example when the distinguished point is not near the center:
when the synth region is at the edge of the target.


Defined in target, overlaid on corpus
=====================================

A ScatterPatch comprises target points.
The same pattern of a ScatterPatch is searched for in the corpus.
But the same pattern overlain on the corpus might be out of bounds,
i.e. is clipped.


Testing
=======

Case: vector of offsets shorter in length than  ScatterPatch.
Expect ScatterPatch no longer in length than vector of offsets.

Case: tensor not longer in length than ScatterPatch.
(e.g. small image)
Expect ScatterPatch no longer in length than tensor.

Case: tensor small and synth area large.
Because the algorithm starts with the synth area uninitialized,
in this case the context is shorter in length than ScatterPatch.
Expect during the startup, length of ScatterPatch is shorter than desired,
and only later reaches the desired ScatterPatch length.

Case: texture synthesis without "use border"
In this case, then entire target is being synthesized.
So there is never a context, the synth region covers the entire target.
In this case, the first probe for the first point of the first pass
is the best match.
IOW more or less choose a best match at random.
Expect that during startup, length of ScatterPatch grows from 1
to desired length of ScatterPatch
(as each synthesized point is added to the ScatterPatch of the next search.)

TODO review and create test cases for this discussion.
=#

#=
OLD alias for type, and a function that is not a constructor

# Define type
# Original was Vector{Neighbor}
ScatterPatch = Vector{Neighbor{DimensionCount, ValueType} where {DimensionCount, ValueType}}
=#

struct ScatterPatch{ValueType, DimensionCount}
    neighbors::Vector{Neighbor{ValueType, DimensionCount}}
end


#=
Outer constructor.
Constructs fixed length but uninitialized.
From an image having desired type.
=#
function ScatterPatch(image::MaskedImage{ValueType, DimensionCount}) where {ValueType, DimensionCount}
    #=
    Fixed length vector of neighbors, each neighbor is undef, not the reference to the Neighbor.
    =#
    # Fail: undef reference later:
    # neighbors = Vector{Neighbor{ValueType, DimensionCount}}(undef, parameters.maxPatchSize)

    # in vector comprehension, call inner constructor of Neighbor
    # Fail: Cannot `convert` an object of type UndefInitializer to an object of type CartesianIndex{2}
    # neighbors = [Neighbor{ValueType, DimensionCount}(undef, undef, undef) for _ = 1:parameters.maxPatchSize]
    neighbors = [Neighbor(image) for _ = 1:parameters.maxPatchSize]
    # call inner constructor
    return ScatterPatch(neighbors)
end

#=
Return a ScatterPatch
with elements both inside the synth, and outside i.e. in the context (if use_border).

Ensure each neighbor is in the target (the synth or its context)
i.e. not clipped
(and TODO and if the target has another mask, for an irregular shape,
is in the irregular shape. Usually transparency is used instead of a second mask.)

Of a given maximum length.  May be shorter than the given maximum.
The absolute minimum is one (the distinguished point itself), but thats not useful as a patch,
and its not reasonable to have a test case for it.

Neighbors in the ScatterPatch are the nearest distance to the given distinguishedSynthPoint.
(Since SortedOffsets is sorted by distance.)

The distinguishedSynthPoint is strictly in the synth region.
Other neighbors can be, but need not be, in the synth region.
On the first pass, the proportion of neighbors that are also in the synth region builds up.
But for example, the first point of the first pass has no neighbors in the synth regions.
Indeeed, if the context is empty (it can be, the synth region can cover the entire target)
Then there are no neighbors at all.

This is a heuristic: best matches are usually nearer.
If the algorithm did not require neighbors to be near,
it would still find matches,
but the algorithm would not do what the user expect: reconstruct plausibly.

ScatterPatch is ordered by distance but the algorithm does not require it.
This is distinct: not only not required to be near, also not required to be ordered.

When choosing neighbors,
filter so that any neighbor in the synth has a value, i.e. been synthesized already.
(Early on, they have been nulled or blackened.)
Use the current synthResult to determine what points have values.

The context region of the target is not mutated
so the value of (color of) a neighbor in the context is constant.

When parameters.withReplacement,
the synth region of the target is mutated.
But we compute a new ScatterPatch after each point is synthesized
(using the new value of any synth points just mutated.)

The value of neighbors is cached in Neighbor.

In original, called prepare_neighbors()
=#



#=
!!! Weirdness of the original algorithm.
The distinguishedSynthPoint is in the ScatterPatch (offset 0,0)
even though during the first pass it doesn't have a value.
And the comparePointsTargetWithCorpus() tested for and omitted the origin point.
Below, in the for loop, we won't push it again, it is filtered.

push!(result, Neighbor(CartesianIndex(0,0), distinguishedSynthPoint) )
count = 1
=#


#=
outer constructor from a MaskedImage.

This performs poorly, many allocations at push.
=#
#=
NOT USED
function ScatterPatch(
        targetImage::MaskedImage{ValueType, DimensionCount},
        distinguishedSynthPoint::CartesianIndex{DimensionCount},
        synthResult::SynthResult{DimensionCount},
        sortedOffsets::SortedOffsets{DimensionCount}
        ) where {ValueType, DimensionCount}
    # sortedOffsets are offsets to span the tensor of the distinguishedSynthPoint

    # empty vector of undef neighbors
    neighbors = Vector{Neighbor{ValueType, DimensionCount}}(undef, 0)

    count = 0
    for offset in sortedOffsets.offsets
        # wild: may be out of bounds
        wildPoint = pointAtOffset(distinguishedSynthPoint, offset)

        # TODO filtering side effect on wildPoint i.e. toroid
        if ! isPatchPointInTargetFiltered(
            targetImage, wildPoint,     # framed point
            synthResult)
            # assert wildPoint is not wild: is in bounds

            #=
            TODO this allocates.  Because it is a push?
            A better implementation would be to use a fixed length vector
            and use indexing but then return the length of the valid portion of the vector?
            =#
            push!(neighbors,
                Neighbor(
                    offset,
                    targetImage, wildPoint  # framed point
                ) )
            count += 1
            if count >= parameters.maxPatchSize
                break
            end
        end
    end

    # TODO fixed length Vector??
    #result[0] = Neighbor(CartesianIndex(0,0))

    # Except in edge use cases (e.g. synth large and target small), the patch is full size.
    if length(neighbors) != 10
        @debug "Patch small, length %d" length(neighbors)
    end

    @debug "Scatter patch" neighbors
    # call default constructor
    return ScatterPatch(neighbors)
end
=#

#=
Setter method for ScatterPatch.
Given an existing ScatterPatch, mutate its elements for a new set of neighbors.

This avoids allocating an reallocating the ScatterPatch vector
and the Neighbor elements of the vector.
=#
function prepareScatterPatch(
        scatterPatch::ScatterPatch{ValueType, DimensionCount},  # out, mutated
        targetImage::MaskedImage{ValueType, DimensionCount},
        distinguishedSynthPoint::CartesianIndex{DimensionCount},
        synthResult::SynthResult{DimensionCount},
        sortedOffsets::SortedOffsets{DimensionCount}
        )::UInt where {ValueType, DimensionCount}

    #=
    sortedOffsets are offsets to span the tensor of the distinguishedSynthPoint.
    [0,0] i.e. the origin offset is at sortedOffsets[1] !!!
    =#

    neighborIndex = 1

    # OLD do not exclude the distinguished point
    # for offset in sortedOffsets.offsets

    #=
    sortedOffsets might include the zero offset.
    IOW the distinguished point is its own neighbor.
    See sortedOffsets.jl
    =#
    for offset in sortedOffsets.offsets

        wildPoint = offsetPatchPoint(targetImage.image, distinguishedSynthPoint, offset)
        #OLD wildPoint = pointAtOffset(distinguishedSynthPoint, offset)
        # wild: may be out of bounds

        # TODO filtering side effect on wildPoint i.e. toroid
        if ! isPatchPointInTargetFiltered(
                targetImage,
                wildPoint,     # framed point
                synthResult)
            #=
            assert wildPoint is not wild: is in bounds
            assert wildPoint has a value
            =#

            scatterPatch.neighbors[neighborIndex].offset = offset
            scatterPatch.neighbors[neighborIndex].targetPoint = wildPoint  # framed point
            scatterPatch.neighbors[neighborIndex].value = targetImage.image[wildPoint]

            # @debug "Neighbor" neighborIndex scatterPatch.neighbors[neighborIndex]

            neighborIndex += 1
            if neighborIndex >= parameters.maxPatchSize
                # neighborIndex is at last element of vector
                break
            end
        end
    end

    # Except in edge use cases (e.g. synth large and target small), the patch is full size.
    if neighborIndex != parameters.maxPatchSize
        @debug "Patch small, length %d" neighborIndex
    end

    # @debug "Prepared scatter patch" scatterPatch
    # return count of valid points in synthPatch
    return neighborIndex
end



#=
For the Resynthesizer algorithm,
ensure a point in a ScatterPatch:
1) is in bounds of the target (TODO or can be toroidally wrapped to the target)
2) when is in the synth, has a value (synthesized already)
=#
function isPatchPointInTargetFiltered(targetImage, patchPoint, synthResult)::Bool
    if isPointInBoundsOfImage(targetImage, patchPoint)
        if ! doesPointHaveValue(synthResult, patchPoint)
            # in bounds, but is in synth region and has no color yet
            return  true
        else
            # in bounds and has a value
            return false  # not filtered, i.e. valid
        end
    else
        # out of bounds of target

        # TODO try wrap to toroid
        # if we succeed in wrapping, again ensure it has a value
        # return a new point

        return true
    end
end
