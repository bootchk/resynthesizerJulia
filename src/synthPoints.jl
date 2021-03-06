#=
The "synth" region of an array is the set of points to be synthesized
(to find a best match for, possibly with replacement.)

Those points that are selected by a mask.

Points are in frame of the target array.
=#


using Random    # shuffle


#=
Return vector of points to be synthesized.

Ordered in scan order (i.e. whatever order findall() creates)

findall returns a vector of indices, not the elements i.e. not a Bool.

findall returns indices of varying types, not necessarily CartesianIndex{N}
especially for N==1, where it returns Int64 i.e. a linear index????
Thus we don't specify the return type.
=#
function generateSynthPoints(
            target::MaskedImage{ValueType, DimensionCount}
        ) where{ValueType, DimensionCount}
        #Fail for N==1 )::Vector{CartesianIndex{DimensionCount}}
    result = findall(target.mask)
    @debug "SynthPoints type, size" size(result) typeof(result)
    @debug "SynthPoints" result
    return result
end


#=
Return vector of all points to be synthesized.
Ordered by the optional ordering function, else the default: shuffled.

The order causes a "direction" of synthesis, e.g. brushfire from a boundary.
Random shuffle is a reasonable default.
Scan order (across, then down or vice versa) usually bad.
Other orders, say brushfire inwards, often give better results.
=#
function generateOrderedSynthPoints(
            target::MaskedImage{ValueType, DimensionCount}
        ) where{ValueType, DimensionCount}
        # )::Vector{CartesianIndex{DimensionCount}} where{ValueType, DimensionCount}
    return shuffle(generateSynthPoints(target));
end
