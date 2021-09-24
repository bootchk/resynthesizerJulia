#=
Neighbor is an element of a patch.

Element of array of points of the target image (both selection and context).
But kept as offset (arrow vectors) i.e. that work in the target and corpus frames.
That is, the coordinate system of an offset has as origin the distinguished point of the patch.

!!! Mutable.  A single vector of Neighbors is mutated.
(When created dynamically, need not be mutable.)

!!! All fields are NOT abstract types, since that lowers performance.
Fields are parameterized concrete types.
=#


include("null.jl")  # leastIndex
include("image.jl")


mutable struct Neighbor{ValueType, DimensionCount}

    #=
    The fundamental attribute: a vector from patch's distinguished point to this neighbor point.

    Not a PointInMaskedImage, i.e. doesn't carry a frame.
    =#
    offset::CartesianIndex{DimensionCount}

    #=
    Attributes for performance.
    1) attributes used many times computed once.
       Same targetPoint is used for many search probes over the corpus
    2) CPU cache coherence is improved if we precompute these attributes into one compact locality

    For example, the cache can hold the entire ScatterPatch,
    but might not hold the entire target image.
    Since on the first pass the target points might be scattered widely,
    and even on further passes, since the image is not tiled, nearby points
    can be far away in the cache memory.

    TODO the original code kept: targetPoint, color, sourceOf
    =#

    #=
    The corresponding point in the target image.
    Assert is inbounds of the target image.
    =#
    targetPoint::CartesianIndex{DimensionCount}

    # The value (e.g. color) of the point in the target
    value::ValueType

    # TODO
    # Coords of corpus point this target synthed from, or -1 if this neighbor is context
    # Coordinates sourceOf;
end


#=
Outer constructor taking only targetImage.
Creates more or less undefined Neighbor, subsequently mutated.

The types must be correct, but the values are don't care: we write but never read.
So we use the coordinates and values of the first index.
=#

function Neighbor(targetImage::MaskedImage{ValueType, DimensionCount}) where {ValueType, DimensionCount}
    firstIndex = leastIndex(targetImage.image)
    # WAS: CartesianIndex(1,1) but that is specialized to 2D
    return Neighbor(
        firstIndex, # point in target frame
        firstIndex, # point in corpus frame ??? is leastIndex same for corpus?
        targetImage.image[firstIndex]   # value
        )
end

#=
Outer constructor taking only the offset, targetImage, and targetPoint (and not the value.)
The value is taken from the targetImage.
=#
function Neighbor(
        offset::CartesianIndex{DimensionCount},
        targetMaskedImage::MaskedImage{ValueType, DimensionCount},
        targetPoint::CartesianIndex{DimensionCount}    # framed point
        ) where {ValueType, DimensionCount}
    # call default constructor
    return Neighbor(
        offset,
        targetPoint,
        targetMaskedImage.image[targetPoint]    # value
        )
end
