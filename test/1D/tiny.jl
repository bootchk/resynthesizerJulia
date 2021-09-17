#=

A call to Resynthesizer using tiny 1D text

Usage:

>julia
julia> include("test/1D/tiny.jl")
julia> @time test(text, mask)
=#


# The tested item
include("../../src/resynthesizer.jl")

# mock test data
# global so it persists and out of the test

#=
A String is not an AbstractArray.
But a byte-array string literal is, but is immutable.
Converts to a Vector{UInt8}, which is mutable.
=#
textLiteral = b"Now is the time for all good men to come to the aid of their country."
text = Vector{UInt8}(textLiteral)

# small mask
mask = falses(size(text))
mask[3:4] .= true

function test(text, mask)
    # test resynthesizer
    resynthesize(text, mask)
end
