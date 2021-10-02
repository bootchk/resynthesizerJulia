
#=
The "Resynthesizer" algorithm for texture transfer in images.

Copyright 2021 Lloyd Konneker

Original algorithm by Paul Harrison.
=#

#=
This project is an exercise in translating and refactoring algorithms.
Code derived from https://github.com/bootchk/resynthesizer.git, written in C.
Specifically from the  /lib directory, the library implementing the algorithm.

One main lesson is that the original C code is very hard to understand.
(Even though I wrote the C code, but I didn't devise the original algorithm)
-The separate declarations of variables is confusing.
-The large functions are hard to understand.
-Better to name functions properly than to use comments.
-Hard to understand data flow when pointers are used for OUT variables
(although Julia doesn't ease that when you pass mutable objects.)
-Better to pass structs of related values

The derivation is mostly a translation from language C to Julia.
But also refactoring:
- renamed things to better denote what they are, using Smalltalk like naming
- separated functions into smaller files

Retains the original programming strategy of a reentrant C library,
where there are no globals and everything is passed in function arguments.
Except that parameters are global constants.

Also retains the architecture of the original:
a basic, parameterized algorithm, wrapped in use cases of the algorithm.
For example, the basic algorithm takes two images,
but a use case may take one image and derive two images
to pass to the basic algorithm.

Uses many functions built-in to Julia e.g. findall and colordiff.
The original implemented many of those functions from scratch.

Also uses Julia's bounds checking to good advantage,
instead of implementing clipping algorithms from scratch.

The method of development: test based.
After each small migration of code, retest.
>cd tests
>julia julia --project=. resynthesizer.jl
When progress is made and the produced image changes from prior tests,
update reference image interactively:
>julia
julia> include("resynthesizer.jl")
Expect a dialog to let you update the reference test, i.e. the gold standard result.
=#

#=
Another lesson is in "generic" algorithms.
While refactoring, I attempt to generalize to multidimension.
The existing algorithm is specialized to 2D array of color.
Julia is all about writing generic algorithms.
While refactoring, I attempt to maintain genericity.
So that the algorithm could work with  multidimension array AKA tensor,
of differing element type than "color".
IOW the algorithm might now work for the applications:
synthesize missing text, synthesize video, synthesize music.

The algorithm is generic on:
- ValueType: the type of the points being compared in the innermost loops of the algorithm
- DimensionCount: the dimensions of the tensors (e.g. Images are 2D)
So these type variables flow through the code.
When you open a specific tensor file (e.g. an image),
that specifies these type variables, and concretizes many abstract types.
Then Julia compiles the algorithm for those concrete types.

TODO Substitute "tensor" or "MDA multidimensional array" for "image"
Don't use the word "image" except as an example.

TODO In many places, iterate over the dimensions of the tensor,
instead of using just two dimensions.

TODO test harness for text, video, music

My experience has been:
it is relatively easy to specify as generic,
but hard to get performance of the original implementation.
I struggled with too many allocations and with abstract versus concrete types.
I started without type annotations, hoping they would be inferred,
then added many type annotations.
The takeaway might be: it is better to supply type annotations
(even if they could be inferred)
because it is not easy to understand what the inferred types are
(without a lot of testing and harnessing the code
and using code_warntype)
=#

include("image.jl")
include("passes/passes.jl")
include("result/synthResult.jl")
include("result/searchResult.jl")

#include("scatterPatch.jl")
include("parameters.jl")

# global
const parameters = ResynthesizerParameters()

const metric = DE_94()

#=

Note that the original implementation used the word "source" for the target image.
Also, the original used the word "target" ambiguously to mean the masked region of the target.
=#

#=
The applications accepts many abstract types,
but internally uses more concrete types.
=#
function resynthesize(
    targetImage::MaskedImage{ValueType, DimensionCount},  # AbstractArray{T,N},
    corpusImage::MaskedImage{ValueType, DimensionCount}    # AbstractArray{Bool,N},
    ) where {ValueType, DimensionCount}

    #=
    The mask on the target defines the synth region to be possibly mutated.
    The mask on the corpus defines the selected region to sample from.
    =#

    @debug "Image length, size" length(targetImage.image) size(targetImage.image)

    #=
    Seed the RNG so that the random number sequence is reproducible i.e. deterministic.

    Not strictly necessary, but it aids in debugging so that tests are more reproducible.
    =#
    Random.seed!(123)

    # uninitialized mutable struct
    synthPatch = ScatterPatch(targetImage)

    # initial fundamental, overall result
    synthResult = initialSynthResult(targetImage)

    # Initial, singleton searchResult, allocated once and reused by passes
    searchResult = SearchResult(targetImage.image)

    # offsets to span the targetImage
    sortedOffsets = SortedOffsets(targetImage.image)

    # TODO use toggled_asserts
    # This is temporary, while chasing performance
    @assert isconcretetype(typeof(corpusImage))
    @assert isconcretetype(typeof(synthPatch))
    @assert isconcretetype(typeof(synthResult))
    @assert isconcretetype(typeof(sortedOffsets))


    #=
    Nullify the synth region.
    For visual debugging when images, when animated, or at the end too much black is bad.
    The algorithm does not require this.
    =#
    nullifyMaskedRegion(targetImage)

    makePassesUntilGoodEnough(targetImage, corpusImage, synthPatch, synthResult, searchResult, sortedOffsets)
    # assert targetImage is mutated and synthResult is mutated

    #=
    The result is the possibly mutated original (sans mask).
    Possibly: depends on parameters.withReplacement.
    Assert that only the masked region of the original is mutated.
    =#

    # TODO return the synthResult
    return targetImage.image
end
