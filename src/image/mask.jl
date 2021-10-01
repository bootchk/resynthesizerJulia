#=
A mask is a BitArray

Masking is boolean.
Not a byte, so no degree of masking.

A mask is usually associated with an image.

It can represent:
- selection, something a user specifies
- transparency: is the corresponding image pixel visible,
- validity: is the corresponding image pixel part of a non-rectangular shape.
=#


include("boundingBox.jl")

function nand(x, y)
    return ~(x & y)
end

#=
Boolean subtraction
(clamped subtraction on 0,1)

Truth table

    0 1
0   0 0
1   1 0
=#
function subtractBool(x, y)
    if x
        return ~y
    else
        return false
    end
end



#=
Subtract masks

Case: not intersect
    all false
Case: intersect but second mask not contained
    the region outside the intersection but in mask1 or mask2
Case: mask2 contained by mask1
    the region in mask1 but not in mask2
=#

function subtractMasks(mask1, mask2)
    # FAIL, changes to Int64
    # result = .-(mask1, mask2)

    result = subtractBool.(mask1, mask2)
    @debug "subtractMasks" result
    @assert typeof(result) <: BitArray
    return result
end


#=
Create a new  mask which is a frisket around a given mask.

The frisket may not be a donut if the given mask
is closer than frisketDepth to the edge of the array.

The frisket is larger than the given mask unless the given mask is entire,
in which case the frisket is empty.
=#
function frisketMaskAroundMask(image, mask, frisketDepth)::BitArray

    # get bounding box of the given mask
    boundingBox = BoundingBox(mask)

    # Method of BoundingBox
    newBoundingBox = expandOrShrink(boundingBox, frisketDepth)

    # clamp expanded box to image
    constrainedBoundingBox = clampBoundingBoxToImage(newBoundingBox, image)

    # BitArray from bounding box, similar to mask
    moreMask = bitMaskFromInShapeOf(constrainedBoundingBox, mask)

    # Punch out (nand) the original mask (the selection in the target) to make a frisket (mask with a hole.)
    result = subtractMasks(moreMask, mask)

    @debug "frisket" result typeof(result)
    @assert typeof(result) <: BitArray
    return result
end
