

include("patchMatchSearch.jl")

#=
A pass that searches.

This understands that a pass is an iteration over the target pixels.
The result of a pass is side effects on the image and other data.
The only non side effect is the returned value.

Return the count of better points that the pass found.

TODO use the same wording "Original name"
AKA synthesize()
=#

function makeAPass(targetImage, corpusImage, targetPoints, synthPatch, synthResult, sortedOffsets)::Int64
    #=
    Retry a target point even if a perfect match was found on prior pass
    since its patch might have changed.
    That is, we don't retain patch diffs between passes.
    All we keep is the best matching point.
    =#
    countBetterPixels::Int64 = 0

    for targetPoint in targetPoints

        synthPatchCenterPoint = targetPoint

        # We pass synthResult because a patch can contain already synthesized point
        #=
        OLD dynamic allocated
        synthPatch = ScatterPatch(
            targetImage,
            synthPatchCenterPoint, # framed point
            synthResult,
            sortedOffsets)
        =#
        #println(typeof(synthPatch))
        #println(isconcretetype(typeof(synthPatch)))

        patchSize = prepareScatterPatch(
            synthPatch,
            targetImage,           # frame
            synthPatchCenterPoint, # framed point
            synthResult,
            sortedOffsets)
        # TODO pass patchSize to the search, and limit iteration over patch

        # !!! side effects on targetImage, and synthResult
        searchResult = searchForPatchMatches(
            synthPatch,
            targetImage, synthPatchCenterPoint, # framed point
            corpusImage,
            synthResult)

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
            Not save the diff, since patch may change.
            !!! This also records the boolean event that we synthesized targetPoint,
            so we now know its value (e.g. color or best matching color)
            even if we did not actually replace the value in the target.
            =#
            setBetterSearchResult(synthResult, targetPoint, searchResult.bestMatchPointInCorpus)
        end
    end
    return countBetterPixels
end
