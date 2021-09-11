
#=
Types and methods for images.
=#

using Colors

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
Assert array is 2D, so dimension 1 and 2 e.g. width x height.
More generally, iterate over dimensions of array.

Here the image parameter is just passed through to function size().
So Julia will not specialize, unless we parameterize the function declaration on N.
??? Performance.

But we also want general on N, with specialization????
=#
function generateRandomPoint(image::AbstractArray{T,N} where {T,N}) # ::CartesianIndex{N} # where {N}
    return CartesianIndex( rand(1:size(image, 1)),
                           rand(1:size(image, 2))  )
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
Set null value to elements of masked region.

Typically typeof(value) is  RGB
=#
function nullifyMaskedRegion(maskedImage, nullValue)
    # Require nullValue to be same type as element of Array
    @assert typeof(nullValue) == typeof(maskedImage.image[1,1])

    # broadcasting using a logical mask as index
    maskedImage.image[maskedImage.mask] .= nullValue
end

#=
Return the null value for an image.

TODO when the thing is not an image
=#
function nullValue()
    # Use black, not sure there is a null Color.
    return colorant"black"
    #Fail: RGB(Colors.color_names["black"])
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
Return point offset from a given point.
Coordinate arithmetic.

Returned point may be out of bounds.
Returned point is-a PointInMaskedImage, that is we do *not* discard the frame.
=#
function pointAtOffset(pointInImage, offset)
    #println(pointInImage.point)
    #= OLD, framed
    return PointInMaskedImage(
        pointInImage.point + offset,    # unchecked coordinate arithmetic
        pointInImage.maskedImage
    )
    =#
    return pointInImage + offset # unchecked coordinate arithmetic

    #result = copy(pointInImage)
    #result.point = pointInImage.point + offset
    #return result
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
    #println("not isPointInBoundsOfImage")
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
