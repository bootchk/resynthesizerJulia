
using LinearAlgebra

#=
SortedOffsets is a vector of vectors (directional arrows) that span a tensor.
!!! Not indexes ( which are usually one based and positive).
Offsets are zero based and signed.


The zero offset
===============

For the Resynthesizer algorithm, for most uses:

!!! Does not include the zero length vector, e.g. for 2D, (0,0)
IOW, a patch is a donut, with a hole in the middle.

When parameters.withReplacement (which is most use cases)
we are synthesizing the center of the patch,
and don't want to compare the in-progress synthesized value with the corpus,
so we exclude the zero offset.
In other words, the being-synthesized point it not its own neighbor.

Otherwise, when we are just finding the best match,
we might as well compare the centers of the patches, target and corpus.



Order
=====

Ordered by distance from the origin.
The ordering makes patches that are compact around the distinguished point.
A compact patch is crucial.

E.G. for 2D the set of shortest distance offsets is [(-1,0), (1,0), (0,-1), (0,1)]

Spanning
========

Includes enough offsets to span an Array (from any corner to the opposite corner.)

Consider this worst case diagram of a target image and its synth region

CCC
CSS
CSZ

Legend:
C = context
S = synth region
Z = distinguished point of a patch (also in the synth region)

To reach from the distinguished point in a corner, to the opposite corner
requires an offset the size of the dimensions of the target.
Also, requires a negative offset.
Consequently, offsets that will reach from any point in the target
to any other point are all the vectors (of all signedness)
whose x,y are the dimensions of the target.
IOW, the length of the vector of sorted offsets is four times the length of the target.


Use of the entire vector
========================
For the Resynthesizer algorithm:
Only in rare use cases are all the sorted offsets actually used.
That is, the above case is a worst case.

Only on the first pass does the Resynthesizer algorithm need offsets that span the entire target.
On subsequent passes, the algorithm only needs offsets that span a patch,
since the synth region has values, so any patch will be contiguous instead of scattered.

The sorted offsets for the first pass is large and expensive.
We only create it once, and pass it.

We don't bother to create a different, smaller instance of SortedOffsets for subsequent passes.

TODO Faster in most use cases to generate lazily.



=#


#=
Not sure why I don't just define a type alias: (maybe it affects performance?)
SortedOffsets = Vector{CartesianIndex{DimensionCount}} where {DimensionCount}
=#
struct SortedOffsets{DimensionCount}
    offsets::Vector{CartesianIndex{DimensionCount}}
end


#=
Outer constructor from a tensor.

Create from SortedOffets from the tensor the offsets should span.

Minimizing allocations is not too important because this is only called once.
=#
function SortedOffsets(
    tensor::Array{ValueType, DimensionCount}
    ) where {ValueType, DimensionCount}
    # mock
    # return createMockSortedOffsets()


    offsets = createOffsets(tensor)

    #=
    sort() alone would sort on y, then x
    Instead sort by manhattan AKA cityblock distance

    sort! sorts in place (but with no fewer allocations?)
    =#
    sortedOffsets = sort!(offsets, by=cityBlockDistance)

    #=
    if parameters.withReplacement
        sortedOffsets = excludeFirstElement(sortedOffsets)
    end
    =#

    # call default constructor to encapsulate vector in a struct
    result = SortedOffsets(sortedOffsets)
    @debug "SortedOffsets of type, size" typeof(result) size(result.offsets)
    @debug "SortedOffsets" result.offsets
    return result
end


#=
I struggled to get this performant.
It still does many allocations that could probably be eliminated,
but it is only done once.

Strategies:

pop() or deleteat() does 25M allocations for medium data
deleteat!(sortedOffsets, 1)

Slice is performant.  It creates a view, or a copy?

This still does many allocations??? TODO
sortedOffsets[2:end]

FAIL, no signature for SubArray
@view sortedOffsets[2:end]

# Assert size is one less than before
=#

# Exclude the first element, the zero offset
function excludeFirstElement(vector)
    result = vector[2:length(vector)]
end



#=
Create a vector of all the arrows to span a tensor.

The strategy is to generate a large array (four times larger than tensor)
of CartesianIndex of suitable ranges (negative:positve), then convert
to a Vector.

Another strategy would be to generate all words of (-1,1) of length k,
then multiply by CartesianIndices of the tensor, shifted by substracting 1,
to get zeros.
=#
function createOffsets(
                tensor::Array{ValueType, DimensionCount}
            )::Vector{CartesianIndex{DimensionCount}}  where{ValueType, DimensionCount}

    sizeVec = size(tensor)
    # sizeVec is a tuple, one element per dimension, giving size on an axis

    rawArray = createArrayofSpanningIndex(sizeVec)

    rawVector = vec(rawArray)   # reshape from array to vector
    # !!! Contains (0,0) still
    return rawVector
end


#=
Create array of CartesianIndex{DimensionCount}
where elements are indices in range -size:size

Since in all generality, there are infinite sizeVec's (for DimensionCount in range 1:Inf)
we could use @generated function,
Or use runtime determined
=#
function createArrayofSpanningIndex(sizeVec)
    #=
    Runtime dispatch.
    Performance is not an issue, we only do this once.
    But it is not fully general for all inputs to algorithm beyond dimension coded here.
    =#
    # Using comprehension
    countDimensions = length(sizeVec)
    if countDimensions == 1
        # TODO 1D indexes are Int64, not CartesianIndex{1}
        return [ CartesianIndex(x) for x = -sizeVec[1]:sizeVec[1] ]
    elseif countDimensions == 2
        return [ CartesianIndex(x,y) for x = -sizeVec[1]:sizeVec[1], y = -sizeVec[2]:sizeVec[2]  ]
    elseif countDimensions == 3
        return [ CartesianIndex(x,y,z) for  x = -sizeVec[1]:sizeVec[1],
                                            y = -sizeVec[2]:sizeVec[2],
                                            z = -sizeVec[3]:sizeVec[3]  ]
    elseif countDimensions == 4
        return [ CartesianIndex(x,y,z,u) for x = -sizeVec[1]:sizeVec[1],
                                            y = -sizeVec[2]:sizeVec[2],
                                            z = -sizeVec[3]:sizeVec[3],
                                            u = -sizeVec[4]:sizeVec[4]  ]
    else
        throw(ErrorException("Unhandled dimension > 4"))
    end
end




#=
Manhattan/taxicab/L1 distance of a vector is norm(vector,1) using LinearAlgebra pkg.
The so-called 1-norm.  Here the literal 1 means the 1-norm.
That is, the literal 1 is the value of the argument with keyword "p",
i.e. this is from a family of norms called p-norms.

Result is a scalar.

Alternatively use Distances pkg?
=#
function cityBlockDistance(coordinates) # ::CartesianIndex{DimensionCount})
    # convert to Tuple because norm requires an iterable and CartsianIndex is not iterable?
    return norm(Tuple(coordinates), 1)
end


#=
Create a short SortedOffsets, for testing.
=#
function createMockSortedOffsets()
    return [
        # !!! Exclude CartesianIndex(0,0),
        CartesianIndex(0,1),
        CartesianIndex(0,-1)
    ]
end
