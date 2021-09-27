
#=
A specialization of the
the resynthesizer algorithm,
inpainting from context that is a nearby frisket.

Takes one image and a mask.

Returns new image with the masked region synthesized from its *nearby* surroundings.

The one image is first divided into a target and corpus image.
The target image is the input.
The algorithm mutates the target image in the masked region, called the "synth" (a noun) region.

The corpus is inverse of mask applied to input.
The corpus is immutable.
=#

include("../resynthesizer.jl")

function healSelection(
    image::AbstractArray{T,N},
    mask::AbstractArray{Bool,N},
    ) where {N,T}

    # Split one image into two

    targetImage = MaskedImage(image, mask)         # image is mutable

    #=
    The corpus is an copy of the in image,
    slightly larger than,
    and surrounding the masked area of the target,
    an with an inverted mask.
    The corpus is not mutated.
    =#

    copyImage = copy(image)

    # get bounds of the mask

    # extend the bounds

    # subarray the image and the mask

    corpusImage = copyImage

    corpusMask = .!mask


    corpusImage = MaskedImage(corpusImage, corpusMask)

    resynthesize(targetImage, corpusImage)
end
