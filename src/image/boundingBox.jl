
#=
A BoundingBox implementation.

Multi-dimensional.


=#


mutable struct BoundingBox{DimensionCount}
    least::CartesianIndex{DimensionCount}
    most::CartesianIndex{DimensionCount}
end


#=
Outer constructor
From a simple image.
=#
function BoundingBox(
        tensor) # ::AbstractArray{ValueType, DimensionCount})
    # where{ValueType, DimensionCount}
    #=

    =#
    # All the indices, sorted
    indices = CartesianIndices(tensor)
    # Assert they are in order !!!

    # More or less: upper left point and lower right point
    result = BoundingBox(indices[1], indices[end])

    println(result)
    return result
end


#=
Outer constructor
From a MaskedImage.
Returning the bounding box of trues.
=#
#tensor::MaskedImage{ValueType, DimensionCount}
#) where {ValueType, DimensionCount}


#=
Outer constructor
From a mask.
Returning the bound box of trues.
=#
function BoundingBox(
        mask::BitArray{DimensionCount}
    ) where {DimensionCount}
    #=

    =#
    # All the indices, sorted
    indices = CartesianIndices(mask)
    # Assert they are in order !!!

    # see logical masking on an image in Julia, SO
    # An array can be indexed by a BitArray
    indicesOfTrue = indices[mask]

    result = BoundingBox(indicesOfTrue[1], indicesOfTrue[end])
    println(result)
    return result
end


#=
Expand or shrink a bounding box in all dimension by amount.
=#
function expandOrShrink(
        boundingBox::BoundingBox{DimensionCount},   # mutated
        amount
    ) where{DimensionCount}

    #=
    <Subtract> from upper left.
    Across all dimensions, and clamp to <1> the least index.
    =#
    boundingBox.least = CartesianIndex(
        max.( (Tuple(boundingBox.least) .- amount),
            1)
        )

    #=
    <Add> to lower right.
    Across all dimensions, and clamp to <max of dimension>
    =#
    boundingBox.most = CartesianIndex(
        max.( (Tuple(boundingBox.most) .+ amount),
            1)
        )

    println("Expanded/shrunk boundingBox")
    println(boundingBox)
    return boundingBox
end


#=
Return BitArray similar to mask,
trues in the rectangle defined by boundingBox.
=#
function bitMaskFrom(
        mask,
        boundingBox
    )
    # falses of similar shape
    mask = falses(size(mask))

    # trues in the boundingBox
    cartesianIndices = cartesianIndicesFrom(boundingBox)
    mask[cartesianIndices] .= true

    println("Mask from boundingBox")
    println(mask)
    return mask

end

#=
Return CartesianIndices
=#
function cartesianIndicesFrom(
        boundingBox
    )

    # result = CartesianIndices((boundingBox.least, boundingBox.most))
    result = CartesianIndices(
            (boundingBox.least[1]:boundingBox.most[1],
            boundingBox.least[2]:boundingBox.most[2]
            )
        )
    println("CI of boundingBox")
    println(result)
    return result

end
