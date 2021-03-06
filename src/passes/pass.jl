

include("../searchPatches/searchPatches.jl")


#=
A pass that searches.

This understands that a pass is an iteration over the target values (pixels).
The result of a pass is side effects on the array (image) and other data.
The only non side effect is the returned value.

Return the count of better points that the pass found.

Original name in C: synthesize()
=#

function makeAPass(targetImage, corpusImage, targetPoints, synthPatch, synthResult, searchResult, sortedOffsets)::Int64
    #=
    Retry a target point even if a perfect match was found on prior pass
    since its patch might have changed.
    That is, we don't retain patch diffs between passes.
    All we keep is the best matching point.
    =#
    countBetterPixels::Int64 = 0

    for targetPoint in targetPoints

        synthPatchCenterPoint = targetPoint

        #=
        The scatterPatch was passed in, so it was allocated once.)
        Mutate it, instead of allocating a new one.
        =#
        patchSize = prepareScatterPatch(
            synthPatch,
            targetImage,           # frame
            synthPatchCenterPoint, # framed point
            synthResult,
            sortedOffsets)
        #=
        Assert for certain edge-case inputs, the synthPatch is not full size.
        TODO pass patchSize to the search, and iterate over only the valid patch.
        =#

        #=
        Set searchResult to the starting value of (NotBetter, Inf)
        We can't use diff for this targetpoint/patch from prior passes,
        since, as discussed below, the patch changes.
        =#
        setStartSearchResult(searchResult, ProbeResult())

        # !!! side effects on targetImage, and synthResult
        searchResult = searchForPatchMatches(
            synthPatch,
            targetImage, synthPatchCenterPoint, # framed point
            corpusImage,
            synthResult,
            searchResult)

        if searchResult.bestProbeResult.betterment != NotBetter
            # TODO this is too crude, for equal to the old result ??
            # See original algorithm
            countBetterPixels += 1

            #@debug "Corpus and target points"
            #@debug searchResult.bestMatchPointInCorpus
            #@debug targetPoint

            #=
            TODO When parameters.withReplacement.
            Side effect on targetImage.
            Change the value at the target point for which we found a better match.
            =#
            targetImage.image[targetPoint] = corpusImage.image[searchResult.bestMatchPointInCorpus]

            #=
            All we save from the searchResult is bestMatchPointInCorpus.
            !!! Not save the diff, since patch may change.
            That is, the existing diff for this point was for a patch that is now different
            because the neighbors changed.

            !!! This also records the boolean event that we synthesized targetPoint,
            so we now know its value (e.g. color or best matching color)
            even if we did not actually replace the value in the target.
            =#
            setBetterSearchResult(synthResult, targetPoint, searchResult.bestMatchPointInCorpus)
        end
    end
    return countBetterPixels
end
