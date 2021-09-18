
#=
A nieve metric for values of any type: simple subtraction of their values.

Nieve for characters,
since it doesn't represent the knowledge that humans have re classes of characters.
=#

function pointDifference(
        targetValue::T,
        corpusValue::T
        ) where{T}
    return corpusValue - targetValue
end
