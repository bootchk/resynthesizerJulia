
using Printf

include("scatterPatch.jl")
include("patchMatch.jl")

include("result/searchResult.jl")

include("heuristicPatchMatch.jl")
include("randomPatchMatch.jl")


#=
Search for a better match in corpus for a target point.
Better than known match (from prior passes.)

This understands that a search has two, sequential phases: "by heuristic", and "at random".

The "by heuristic" phase looks at places near where previous best matches were found.

The second phase is skipped when the first phase finds a perfectMatch.

The second phase, since it is random,
looks at novel places that we might not have tried before.

The result of the overall search is the cumulutive result of both phases.
=#


#=
OLD
When I assumed that a SearchResult would be returned on the stack.
Instead, it seems to be allocated on the heap.

function searchForPatchMatches(
        synthPatch,
        targetImage::MaskedImage{ValueType, DimensionCount},
        synthPatchCenterPoint, # framed point
        corpusImage,
        synthResult,
        )::SearchResult{DimensionCount} where {ValueType, DimensionCount}

    patchDiffToBeat = startingPatchDiff(synthPatchCenterPoint)

    firstPhaseSearchResult = matchPatchesAtHeuristicCorpusPoints(
        synthPatch,
        targetImage, corpusImage,
        patchDiffToBeat, synthResult, searchResult)

    # If already a perfectMatch, skip second phase (random search)
    if firstPhaseSearchResult.bestProbeResult.betterment != PerfectMatch
        # Continue second phase of search

        # Any further searching must best the first phase or the starting result
        patchDiffToBeat = firstPhaseSearchResult.bestProbeResult.patchDifference

        secondPhaseSearchResult = matchPatchesAtRandomCorpusPoints(
            synthPatch,
            targetImage, corpusImage,
            patchDiffToBeat, synthResult, searchResult)

        #=
        If second phase better, overall result is that result, else first phase result.
        =#
        if secondPhaseSearchResult.bestProbeResult.betterment != NotBetter
            overallResult = secondPhaseSearchResult
        else
            overallResult = firstPhaseSearchResult
        end
    else
        @debug "Skipping random search phase since perfect match"
        overallResult = firstPhaseSearchResult
    end
    @debug  "Overall search result" overallResult

    return overallResult
end

=#


function searchForPatchMatches(
        synthPatch,
        targetImage::MaskedImage{ValueType, DimensionCount},
        synthPatchCenterPoint, # framed point
        corpusImage,
        synthResult,
        searchResult,
        )::SearchResult{DimensionCount} where {ValueType, DimensionCount}

    patchDiffToBeat = startingPatchDiff(synthPatchCenterPoint)

    matchPatchesAtHeuristicCorpusPoints(
        synthPatch,
        targetImage, corpusImage,
        patchDiffToBeat, synthResult, searchResult)

    # If already a perfectMatch, skip second phase (random search)
    if searchResult.bestProbeResult.betterment != PerfectMatch
        # Continue second phase of search

        # Any further searching must best the first phase or the starting result
        patchDiffToBeat = searchResult.bestProbeResult.patchDifference

        secondPhaseSearchResult = matchPatchesAtRandomCorpusPoints(
            synthPatch,
            targetImage, corpusImage,
            patchDiffToBeat, synthResult, searchResult)
    else
        @debug "Skipping random search phase since perfect match"
    end
    @debug  "Overall search result" searchResult

    return searchResult
end




#=
Initial patch diff for a search.

When the algorithm begins with the heuristic,
and the first neighbor is the targetPoint (its neighbor is itself)
Then the initial patch diff can be Inf, and the first search
according to the heuristic will recover the previous best patch diff.
=#
function startingPatchDiff(targetPoint)
    # TODO comments about this and first neighbor.
    return Inf
end
