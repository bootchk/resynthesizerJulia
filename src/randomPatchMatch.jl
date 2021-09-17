#=
Probe at randomly selected corpus points.
A fixed count of probes, with short circuit for perfect match.

Should be kept very similar to heuristicPatchMatch
TODO refactor so common code is in one place
=#
function matchPatchesAtRandomCorpusPoints(
    synthPatch,  # const IN
    targetImage, # mutable, IN and OUT
    corpusImage, # const IN
    bestKnownPatchDiff, # IN
    synthResult,    # mutable, OUT
    searchResult    # mutable, IN/OUT to be mutated by the search
    )

    # OLD setStartingSearchResult(searchResult, bestKnownPatchDiff)
    #@debug  "Random search diff to beat %f\n" result.bestProbeResult.patchDifference

    for i = 1:parameters.maxProbeCount
        corpusPatchCenterPoint = generateRandomMaskedPoint(corpusImage)
        # OLD PointInMaskedImage( generateRandomMaskedPoint(corpus), corpus)
        probeResult = patchMatch(
            targetImage, corpusImage,
            corpusPatchCenterPoint,
            synthPatch,
            searchResult.bestProbeResult.patchDifference)

        if probeResult.betterment != NotBetter
            # Better or equal to any point probed in this pass

            # TODO a method of SearchResult
            # Lift the probeResult into the searchResult
            searchResult.bestMatchPointInCorpus = corpusPatchCenterPoint
            # Any further searching must best this latest probeResult
            searchResult.bestProbeResult = probeResult

            @debug  "Better random match" result

            # Is better, might be perfect
            if probeResult.betterment == PerfectMatch
                @debug "Perfect match"
                break
            end
        end
    end

    @debug  "Random search result " searchResult
    return searchResult
end
