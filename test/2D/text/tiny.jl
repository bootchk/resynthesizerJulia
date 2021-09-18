#=

A call to Resynthesizer using tiny 2D array of char


Usage:

>julia
julia> include("test/2D/text/tiny.jl")
julia> @time test(text, mask)

=#

# The tested item
include("../../../src/resynthesizer.jl")

# mock test data
# global so it persists and out of the test

# length is 72 so it can be reshaped easily to 6x12
textLiteral = b"Now is the time for all good men to come to the aid of their country.!?*"

textStream = Vector{UInt8}(textLiteral)

text = reshape(textStream, 6, 12)

# small mask
mask = falses(size(text))
mask[3:4, 2:3] .= true


function test(img, mask)
    # test resynthesizer
    result = resynthesize(img, mask)

    # Assert result is Array(UInt8)

    #=
    Convert to string that prints nicely.
    Broadcast conversion function Char()
    =#
    Char.(result)
end
