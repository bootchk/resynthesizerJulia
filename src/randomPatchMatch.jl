#=
Probe at randomly selected corpus points.
A fixed count of probes, with short circuit for perfect match.

Should be kept very similar to heuristicPatchMatch
TODO refactor so common code is in one place
=#
function matchPatchesAtRandomCorpusPoints(
    synthPatch,
    targetImage, corpusImage,
    bestKnownPatchDiff, synthResult)

    # result to be mutated by the search loop
    result = SearchResult(bestKnownPatchDiff)
    #@debug  "Random search diff to beat %f\n" result.bestProbeResult.patchDifference

    for i = 1:parameters.maxProbeCount
        corpusPatchCenterPoint = generateRandomMaskedPoint(corpusImage)
        # OLD PointInMaskedImage( generateRandomMaskedPoint(corpus), corpus)
        probeResult = patchMatch(
            targetImage, corpusImage,
            corpusPatchCenterPoint,
            synthPatch,
            result.bestProbeResult.patchDifference)

        if probeResult.betterment != NotBetter
            # Better or equal to any point probed in this pass

            # Lift the probeResult into the searchResult
            result.bestMatchPointInCorpus = corpusPatchCenterPoint
            # Any further searching must best this latest probeResult
            result.bestProbeResult = probeResult

            @debug  "Better random match" result

            # Is better, might be perfect
            if probeResult.betterment == PerfectMatch
                @debug "Perfect match"
                break
            end
        end
    end

    @debug  "Random search result " result
    return result
end
