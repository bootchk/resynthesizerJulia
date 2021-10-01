#=
<render> application of the resynthesizer algorithm.

Takes one image and a mask.
Masked region of image is the corpus.

Returns new image of the same size
synthesized in its entirety from the corpus.

FUTURE render target of separately given dimensions
=#

include("../resynthesizer.jl")

function render(
    corpusImage::AbstractArray{T,N},
    corpusSelectionMask::AbstractArray{Bool,N}
    ) where {N,T}

    corpusMaskedImage = MaskedImage(corpusImage, corpusSelectionMask)

    # Output target is same size as corpus.
    newImage = copy(corpusImage)

    #=
    Mask same size as targetImage, all true.
    =#
    newMask = trues(size(newImage))

    targetMaskedImage = MaskedImage(newImage, newMask)

    resynthesize(targetMaskedImage, corpusMaskedImage)
end
