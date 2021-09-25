#=
<render> application of the resynthesizer algorithm.

Takes one image, which is the corpus.

Returns new image of the same size
synthesized in its entirety from all the given image.
=#

include("../resynthesizer.jl")

function render(
    image::AbstractArray{T,N},  # corpus
    ) where {N,T}


    #=
    Mask same size a corpus, all true.
    =#
    mask = trues(image)

    #=
    target same size as corpus.
    =#
    targetImage = MaskedImage(copy(image), mask)

    #=
    The corpus is the in image,
    with a mask representing entire selection.
    =#
    corpusImage = MaskedImage(image, mask)         # image is mutable

    resynthesize(targetImage, corpusImage)
end
