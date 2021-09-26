#=
Null value for tensors having elements of a certain type.

!!! Depends on element type, not on dimensions.
=#

using Colors


#=
Runtime dispatch, for now.

TODO not assume the eltype of the array.
Here we arbitrarily choose a color, a blank char, etc.
=#
function nullElementForTensor(tensor)

    elementType = eltype(tensor)

    #=
    Call the type as a constructor.
    A type is callable.

    ??? Does this depend on importing packages, e.g. "using Colors"

    Zero is valid for every type?
    =#
    nullValue = elementType(0)

    #=
    if dims == 1
        nullValue = UInt8(255)
    elseif dims == 2
        # Use black, not sure there is a null Color.
        nullValue = colorant"black"
        #Fail: RGB(Colors.color_names["black"])
    end
    =#

    @debug "typeof null element" typeof(nullValue)
    # Ensure nullValue to be same type as element of Array
    @assert typeof(nullValue) == eltype(tensor)

    return nullValue
end


#=
Returns the least index for a tensor.

Where indexex are assumed to start at 1.

Return type is either Int64 (for DimensionCount==1)
or CartesianIndex{DimensionCount} where DimensionCount>1
=#
function leastIndex(tensor)
    dims = ndims(tensor)
    if dims == 1
        leastIndex = 1
    elseif dims == 2
        leastIndex = CartesianIndex(1,1)
    elseif dims == 3
        leastIndex = CartesianIndex(1,1,1)
    elseif dims == 4
        leastIndex = CartesianIndex(1,1,1,1)
    else
        throw(ErrorException("Unhandled dimension > 4"))
    end

    return leastIndex
end
