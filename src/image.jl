
#=
Types and methods for tensors (multidimension array).

It is cruft if it says "image" instead of "tensor"
=#

include("null.jl")



#=
A tensor (usually 2D image) and same length mask.
The mask defines a non-rectangular region, a "selection".

Parameterized.
E.G. For usual notion of "2D image": T is Color, and N is 2.
E.G. For usual notion of "3D image": T is Color, and N is 3.
E.G. For usual notion of "text": T is Char, and N is 1.
E.G. For unusual notion of "poem": T is Char, and N is 2.

!!! Not mutable (so it is not allocated),
Only the image and mask themselves are mutable.
But the algorithm does not always mutate the image (on the target, not the corpus)
and never mutates the mask.

TODO rename selectionMask because that's what it is used for
"mask" is over general
=#

struct MaskedImage{ValueType, DimensionCount}

    #=
    NOT AbstractArray to allow more implementations of Array.
    Here we choose a concrete type appropriate to the algorithm.
    =#
    # WAS image::AbstractArray{ValueType, DimensionCount}
    # WAS mask::AbstractArray{Bool, DimensionCount}
    image::Array{ValueType, DimensionCount}
    mask::BitArray{DimensionCount}

    #=
    inner constructor.
    Enforces invariant that mask is same dimensions as image.
    =#
    #=
    temp
    function MaskedImage(image, mask)
        @assert size(image) == size(mask) "image and mask must have same size"
        return new{typeof(image), size(image)}(image, mask)
    end
    =#
end







#=
Return CartesionIndex with each element a rand in range of indices of each dimension of array.

General on N i.e. DimensionCount.
We parameterize the function declaration on N.

The returned value is a CartesianIndex, or for 1D a Int64??? TODO

??? Performance.
=#
function generateRandomPoint(tensor::AbstractArray{T,N} where {T,N}) # ::CartesianIndex{N} # where {N}
    #= OLD, specific to 2D
    return CartesianIndex( rand(1:size(tensor, 1)),
                           rand(1:size(tensor, 2))  )
    =#

    #=
    eachIndex is a generator of all indices for an Array.
    See the documentation.
    "For array types that have opted into fast linear indexing
    (like Array), this is simply the range 1:length(A)"
    i.e. a Int64.

    Choose a random element of that set.
    ??? Don't know if it is fast.
    =#
    linearIndex = rand(eachindex(tensor))

    #=
    Convert to CartesianIndex.

    TODO as noted above, it might already be a CartesianIndex.

    Recommended way to convert to a CartesianIndex is
    CartesianIndices(tensor)[linearIndex]
    But requires expensive division.
    But we do that later.
    =#
    result = CartesianIndices(tensor)[linearIndex]

    return result
end


#=
Like the above, but also require the point to be masked.
(The mask true indicates is a desired or selected point.)
=#
function generateRandomMaskedPoint(maskedImage)
    point = 0
    while true
        point = generateRandomPoint(maskedImage.image)
        if maskedImage.mask[point]
            break
        end
    end
    return point
end

#=
Set elements of masked region to a null value

Re the algorithm, calling this is not necessary,
but aids in debugging (so you can see in the result what might be wrong.)

Typically typeof(value) is  RGB
=#
function nullifyMaskedRegion(maskedImage)

    nullValue = nullElementForTensor(maskedImage.image)

    # broadcasting using a logical mask as index
    maskedImage.image[maskedImage.mask] .= nullValue
end




#=
The mask defines a selected, non-rectangular region.
=#
function isPointSelectedInMaskedImage(
        maskedImage::MaskedImage{ValueType, DimensionCount},
        point::CartesianIndex{DimensionCount}
        )::Bool where {ValueType, DimensionCount}
    # is the mask value true at the point ?
    return maskedImage.mask[point]
end




#=
Is the point in bounds?
=#
#= OLD, framed
function isPointInBoundsOfImage(pointInImage)
    # use Julia method
    return checkbounds(Bool, pointInImage.maskedImage.image, pointInImage.point)
end
=#
function isPointInBoundsOfImage(
        maskedImage::MaskedImage{ValueType, DimensionCount},
        point::CartesianIndex{DimensionCount}
        )::Bool where {ValueType, DimensionCount}
    # use Julia method
    return checkbounds(Bool, maskedImage.image, point)
end


#=
FAIL: too slow and allocates memory for the excepttion?

Implementation uses an exception builtin to Julia.
Exception is expected, *not* a program error.

isInBounds = true
try
    # access the point, result is unused
    pointInImage.maskedImage.image[pointInImage.point]
catch BoundsError
    # @debug "not isPointInBoundsOfImage"
    isInBounds = false
end
return isInBounds
=#


#=
Is the given point in bounds of its MaskedImage
AND selected (mask is true)

In original C code clippedOrMaskedCorpus()
=#
function isInBoundsAndSelected(maskedImage, wildPoint)::Bool
    return (   isPointInBoundsOfImage(maskedImage, wildPoint)
            && isPointSelectedInMaskedImage(maskedImage, wildPoint)
            )
end
