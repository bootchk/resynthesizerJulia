
#=
<inpaint> application of the resynthesizer algorithm.

"inpaint" is tradional term.  In GIMP app, AKA "heal selection"

Takes one image and a mask.

Returns new image with the masked region synthesized from its *entire* surroundings.

The one image is first divided into a target and corpus image.
The target image is the input.
The algorithm mutates the target image in the masked region, called the "synth" (a noun) region.

The corpus is inverse of mask applied to input.
The corpus is immutable.
=#

include("../resynthesizer.jl")

function inpaint(
    image::AbstractArray{T,N},
    mask::AbstractArray{Bool,N},
    ) where {N,T}

    # Split one image into two

    targetImage = MaskedImage(image, mask)         # image is mutable

    # The corpus is an immutable copy of the in image, with an inverted mask
    invertedMask = .!mask
    corpusImage = MaskedImage(copy(image), invertedMask)
    @assert isconcretetype(typeof(targetImage.mask))

    resynthesize(targetImage, corpusImage)
end
