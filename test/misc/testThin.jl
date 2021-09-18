#=
This is a thin slice of Resynthesizer.
To test type stability.
=#


# For "load" local  files
using FileIO

include("../src/neighbor.jl")
include("../src/image.jl")
include("../src/pointCompare.jl")


# load an image

img_path = "/home/bootch/git/resynthesizerJulia/test/data/tinylighthouse.png"
img = load(img_path)

println(typeof(img))

# Need a mask to create MaskedImage
# The mask selcts whole image
mask = trues(size(img))


maskedImage = MaskedImage(img, mask)


#=
Create a dummy neighbor
=#

# Use the same index for offset, wildPoint
point = CartesianIndex(1,1)
offset = point

neighbor = Neighbor(
                    offset,
                    maskedImage,    # target,
                    offset  # framed point in target
                )
println("Describing neighbor instance")
println(neighbor)
println(typeof(neighbor.offset))
# call compare
#=
@code_warntype comparePatchPoints(
    neighbor,
    maskedImage,
    # Use same dummy point
    point    # framed point
    )
=#

function test(x::Int64)
    for  i in x
        comparePatchPoints(
            neighbor,
            maskedImage,
            # Use same dummy point
            point    # framed point
            )
    end
end

# @code_warntype test()
@time test(10000)
