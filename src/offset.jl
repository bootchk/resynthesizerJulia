#=
Offset

A point in an array is located by its index in the frame of the array.

An offset is a vector, in another, amorphous frame
(whose origin is the other point in the other frame.)

This hides that indices may be linear or cartesian.
Whereas an offset may be of the opposite variety.
Hides in the sense: I went back and forth choosing types
in the algorithm when testing 1D, 2D,...

In Resynthesizer, offsetting points is done:
1) when choosing neighbors (ScatterPatch is a set of nearest offset points.)
2) in the heuristic search, inverse offsetting back into the target.

TODO when sampling random points in the corpus,
we could choose offsets at random and use this.
=#





#=
Return a point (index) offset from given point.

Given point is in bounds of array.

Returned point may be out of bounds.
Returned point is in frame of array.

IOW this is coordinate arithmetic.
=#


#=
Specific to case where index and offset are same type, usually linear index i.e. Int64,
or both CartesianIndex{N}
TODO cruft?
specific to point is-a Int64 and offset is-a CartesianIndex???
=#
function offsetPatchPoint(
        array::Array{ValueType, DimensionCount},    # not used
        point, # ::CartesianIndex,
        offset::CartesianIndex{DimensionCount}
        ) where{ValueType, DimensionCount}
    return point + offset
end

#=
Specific to case where index is linear index i.e. Int64
but offset is CartesianIndex
TODO maybe we should generate offsets that are always linear indices???
=#
function offsetPatchPoint(
        array::Array{ValueType, DimensionCount},
        point::Int64,   # linear index
        offset::CartesianIndex{DimensionCount}) where{ValueType, DimensionCount}
    #=
    Conversion from linear index to Cartesian is expensive division.
    =#
    return CartesianIndices(array)[point] + offset
end



#= CRUFT
Formerly called from ScatterPatch

function pointAtOffset(pointInImage, offset)
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
=#
