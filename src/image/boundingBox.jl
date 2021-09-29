

#=
A BoundingBox implementation.

A BoundingBox is a volume
that surrounds all the elements of an array
where the elements have a certain property.

Axis aligned.  That is, the coordinates of the bounding box
are in the frame of the array.

Most often, for Bool arrays, where the property is isTrue()
But also for a trivial property "true"
i.e. the bounding box contains all the elements of the array.

A volume is defined by two points i.e. CartesianIndex.
See "Geometric Approximation Algorithms" by S. Har-Peled, 2008.
At least up to 3D it is computable in O(n3)
For 4D, two points define the <diameter>,
the length of the maximum projection onto a line.
Still not sure the below is correct for 4D.

Multi-dimensional.
=#


struct BoundingBox{DimensionCount}
    least::CartesianIndex{DimensionCount}
    most::CartesianIndex{DimensionCount}
end


#=
Outer constructor
From a simple array.
Property: trivial function that always returns true.
I.E. Returns the bounding box of the entire array.
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
Returns a new bounding box,
expanding given bounding box in all dimension by amount.
(Is shrink if amount is negative.)

Ensures least is not less than (1,1,...,1)
but does not ensure most is constrained.
If you need constrained most, subsequently use clamp()
=#
function expandOrShrink(
        boundingBox::BoundingBox{DimensionCount},   # mutated
        amount
    ) where{DimensionCount}

    #=
    Iteration not supported on CartesianIndex,
    so cast to Tuple and then back to CartesianIndex.
    =#

    #=
    <Subtract> from upper left.
    Across all dimensions, and clamp to <1> the least index.
    =#
    least = CartesianIndex(
        max.( (Tuple(boundingBox.least) .- amount),
            1)
        )

    #=
    <Add> to lower right.
    Across all dimensions.
    !!! Not clamp to <max of dimension>
    =#
    #=
    most = CartesianIndex(
        min.( (Tuple(boundingBox.most) .+ amount),
            1)
        )
    =#
    most = CartesianIndex(
            (Tuple(boundingBox.most) .+ amount)
        )

    result = BoundingBox(least, most)
    println("Expanded/shrunk boundingBox")
    println(result)

    #=
    Ensure the bounding box least is > 1's
    but bounding box most may be out of bounds.
    =#
    return result
end


#=
Returns CartesianIndex of clamped most.
=#
function clampMostOfBoundingBox(boundingBox1, boundingBox2)
    most = min.(    Tuple(boundingBox1.most),
                    Tuple(boundingBox2.most)
                )

    result = CartesianIndex(most)
    return result
end


#=
Return new boundingBox which is contained in the image.

Assert given bounding box least is contained in the image.
Only need to clamp the most.
=#
function clampBoundingBoxToImage(
        boundingBox1::BoundingBox{DimensionCount},
        image   # ::Array{}
    ) where{DimensionCount}

    # In general, least is not (1,1,..1)
    least = boundingBox1.least

    #=
    Most is the smaller of the bounding box of the mask
    and the bounding box of the image.
    =#
    # OLD most = boundingBoxConstraint.most
    most = clampMostOfBoundingBox(boundingBox1, BoundingBox(image))

    result = BoundingBox(least, most)
    println("Clamped bounding box")
    println(result)
    return result
end


#=
Return BitArray similar to image,
having trues in the rectangle defined by boundingBox.
=#
function bitMaskFromInShapeOf(
        boundingBox,
        image
    )
    # falses of similar shape
    mask = falses(size(image))

    # trues in the boundingBox
    cartesianIndices = cartesianIndicesFrom(boundingBox)
    mask[cartesianIndices] .= true

    println("Mask from boundingBox")
    println(mask)
    @assert typeof(mask) <: BitArray
    return mask
end

#=
Return CartesianIndices
=#
function cartesianIndicesFrom(
        boundingBox
    )
    # Fail: result = CartesianIndices((boundingBox.least, boundingBox.most))
    # TODO generic on DimensionCount
    result = CartesianIndices(
            (boundingBox.least[1]:boundingBox.most[1],
             boundingBox.least[2]:boundingBox.most[2]
            )
        )
    println("CI of boundingBox")
    println(typeof(result))
    println(result)
    return result

end
