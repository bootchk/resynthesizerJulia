
#=
A specialization of the
the resynthesizer algorithm,
inpainting from context that is a nearby frisket.
The results are better (than resynthesizing from the entire corpus)
since pragmatically, nearby corpus is usually a "background".

Takes one image and a mask.

Returns new image with the masked region synthesized from its *nearby* surroundings.

The one image is first divided into a target and corpus image.
The target image is the input.
The algorithm mutates the target image in the masked region, called the "synth" (a noun) region.

The corpus is inverse of mask applied to input.
The corpus is immutable.
=#

include("../resynthesizer.jl")

include("../image/boundingBox.jl")
include("../image/mask.jl")


function healSelection(
    image::AbstractArray{T,N},      # target
    mask::AbstractArray{Bool,N},    # synth region
    frisketDepth::Int64
    ) where {N,T}

    # Assert image and mask are similar

    # Target for resynthesize() is as passed
    targetImage = MaskedImage(image, mask)         # image is mutable

    #=
    The corpus image is a copy of the in image.
    The corpus is not mutated.

    The corpus mask is a frisket.
    Slightly larger than,
    and surrounding the masked (selected) area of the target,
    with a hole in it where is the selected area of the target.
    =#

    copyImage = copy(image)

    corpusMask = frisketMaskAroundMask(image, mask, frisketDepth)

    # An optimization would be to subarray the image and the mask

    corpusImage = copyImage

    corpusImage = MaskedImage(corpusImage, corpusMask)

    resynthesize(targetImage, corpusImage)
end
