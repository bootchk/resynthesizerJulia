#=
Implementation of a metric.

From scratch.

Choose one metric to include,
if you also defined another metric having the same signature.
=#


using Colors    # RGB

# metric functions
include("negLnCauchy.jl")

#=
Specialized for types from Colors module.
Often: RGB{FixedPointNumbers.N0f8}
The specialization:
1) knows the components i.e. channels r,g,b
2) knows kinds of arithmetic (fixed point versus float)
that could be used for channels

# TODO generic for ValueType
# WAS RGB{T}
=#

using FixedPointNumbers

function pointDifference(
        targetColor::RGB{FixedPointNumbers.N0f8},
        corpusColor::RGB{FixedPointNumbers.N0f8}
        )   # RGB{T} where {T}   # ::Float32
    #=
    Sum differences over the channels.

    Colors are not iterable over channels, but have getters r,g,b

    The type is one from Colors module.
    Often: FixedPointNumbers.N0f8
    See discussion of arithmetic on Julia docs.
    May convert to float.
    Saturated and wrapping arithmetic not available yet?

    It needs to not lose magnitude through adding plus and minus
    =#

    #=
    When T is FixedPointNumbers.N0f8,
    1) difference (-)  could wrap, overflow, or saturate and still fit in N0F8
    2) abs() might be better and also fit.
    TODO resolve whether - yields type Float

    Anyway, the sum over channels does not fit in N0F8
    (without losing accuracy due to overflow)
    So we sum to a float.
    =#

    sum::Float32 = zero(Float32)

    # typeof(targetColor.r)) is Float ???
    #=
    Use abs(), we want magnitude, not a signed difference.
    Depends on whether the cauchy function is computed from a symmetric table
    =#
    for value in (  targetColor.r - corpusColor.r,
                    targetColor.g - corpusColor.g,
                    targetColor.b - corpusColor.b,
                    )
        # sum += abs(value)
        # sum += negLnCauchy(abs(value))
        sum += negLnCauchy(value)
    end

    # Ensure the sum is positive,
    @assert sum >= 0
    return sum
end


#=
The maximum value of the metric.

The maximum value when one (target) value is zero and the other (corpus) value is
the max value of the difference between values of a channel,
summed over channels.
=#

#=
All types for channels of RGB
are basically [0.0, 1.0] ????
=#
const maxPointDifference = 3 * 1.0
