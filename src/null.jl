#=

Null value for tensors of parameteized dimension.

=#

using Colors


#=
Runtime dispatch, for now.
TODO fully generic on dimension

TODO not assume the eltype of the array.
Here we arbitrarily choose a color, a blank char, etc.
=#
function nullElementForTensor(tensor)
    dims = ndims(tensor)
    if dims == 1
        nullValue = UInt8(255)
    elseif dims == 2
        # Use black, not sure there is a null Color.
        nullValue = colorant"black"
        #Fail: RGB(Colors.color_names["black"])
    end

    println(typeof(nullValue))
    # Ensure nullValue to be same type as element of Array
    @assert typeof(nullValue) == eltype(tensor)

    return nullValue
end
