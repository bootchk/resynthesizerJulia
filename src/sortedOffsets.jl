
using LinearAlgebra

#=
SortedOffsets is a vector of vectors (directional arrows) that span a tensor.
!!! Not indexes ( which are usually one based and positive).
Offsets are zero based and signed.

!!! Does not include the zero length vector, e.g. for 2D, (0,0)

Ordered by distance from the origin.
The ordering makes patches that are compact around the distinguished point.
A compact patch is crucial.

E.G. for 2D the set of shortest distance offsets is [(-1,0), (1,0), (0,-1), (0,1)]

Includes enough offsets to span an Array
(from any corner to the opposite corner.)

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
Consequently, offsets that will from any point in the target
to any other point are all the vectors (of all signedness)
whose x,y are the dimensions of the target.
IOW, the length of the vector of sorted offsets is four times the length of the target.
=#

#=
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

# Define type
#= OLD type alias
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
    println(typeof(offsets))

    #=
    sort() alone would sort on y, then x
    Instead sort by manhattan AKA cityblock distance

    sort! sorts in place (but with no fewer allocations?)
    =#
    sortedOffsets = sort!(offsets, by=cityBlockDistance)
    println(typeof(sortedOffsets))
    println(size(sortedOffsets))

    # Exclude the first element which is CartesianIndex(0,0)

    #=
    Strategies:

    pop() or deleteat() does 25M allocations for medium data
    deleteat!(sortedOffsets, 1)

    Slice is performant.  It creates a view, or a copy?
    =#
    # This still does many allocations??? TODO
    # TEMP testing allocs when this is omitted
    # sortedOffsets = sortedOffsets[2:end]

    # FAIL, no signature for SubArray
    # sortedOffsets = @view sortedOffsets[2:end]

    # Assert size is one less than before
    println(size(sortedOffsets))

    # call default constructor to encapsulate vector in a struct
    return SortedOffsets(sortedOffsets)
end

#=
Create vector of offsets that span the tensor.

Offsets are signed and include zero [-x,...,0,...,x]
=#

#=
Create a vector of all the arrows to span a tensor.

Another strategy would be to generate all words of (-1,1) of length k,
then multiply by CartesianIndices of the tensor, shifted by substracting 1.

Specialized for 2D
TODO more generally for multidimension
=#
function  createOffsets(tensor)::Vector{CartesianIndex{2}}

    sizeVec = size(tensor)
    # sizeVec is a vector, one element per dimension, giving size on an axis

    rawArray = [ CartesianIndex(x,y) for x = -sizeVec[1]:sizeVec[1], y = -sizeVec[2]:sizeVec[2]  ]
    rawVector = vec(rawArray)   # reshape from array to vector
    # !!! Contains (0,0) still
    return rawVector
end


#=
Manhattan/taxicab/L1 distance of a vector is norm(vector,1) using LinearAlgebra pkg.
Vector between two  points x, y is x-y
Fails because iteration is unsupported for CartesianIndex

Alternatively using Distances pkg.
=#
function cityBlockDistance(coordinates) # ::CartesianIndex{DimensionCount})
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
