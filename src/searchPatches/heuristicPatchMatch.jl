#=
One of two phases of search for patch match of a synthPatch.
See also matchPatchesAtRandomCorpusPoints()

Probe corpus points selected by their relation to the best matching corpus point of this target point.
This is a heuristic: good matches are likely near the previous best matching corpus point.

!!! Here we are selecting the origin of a patch in the corpus.
Neighbor's are used here for a different purpose
than when comparing patches (when we also iterate over neighbors.)
=#
function matchPatchesAtHeuristicCorpusPoints(synthPatch, targetImage, corpusImage, bestKnownPatchDiff, synthResult,
        searchResult    # result to be mutated by the search
        )

    # To test without heuristic search, return an faked result
    # return SearchResult(bestKnownPatchDiff)


    # OLD result = SearchResult(bestKnownPatchDiff)
    # OLD setStartingSearchResult(searchResult, bestKnownPatchDiff)

    # assert searchResult is set to prior best result

    for neighbor in synthPatch.neighbors
        if isInSynthAndWasSynthesized(
                synthResult,
                targetImage, neighbor.targetPoint   # framed point
                )
            wildIndex = wildRelatedCorpusIndex(neighbor, synthResult)

            # Heuristic #2
            #=
            For a given ScatterPatch, many of the neighbors will have the
            same wild corpus point.
            We cache them, and skip matching them again for the same ScatterPatch.
            TODO
            =#

            # OLD Frame the wild index, needed to call methods on the corpus
            # wildPoint = PointInMaskedImage(wildIndex, corpusImage)

            if ! isInBoundsAndSelected(corpusImage, wildIndex)
                @debug "Clipped or masked heuristic point. " wildIndex
                continue
            else
                #=
                wildindex is now not wild, i.e. is in bounds of the corpusImage
                The role is now: corpusPatchOriginPoint
                Don't give it an alias since that has performance issue, unless declared const !!
                =#

                # Same code as in phase 2
                probeResult = patchMatch(
                    targetImage, corpusImage,
                    wildIndex,    # framed point
                    synthPatch,
                    searchResult.bestProbeResult.patchDifference  # patch diff to beat
                    )

                if probeResult.betterment != NotBetter
                    # Better or equal to any point probed in this search and in this pass
                    # TODO an assertion to prove it
                    setBetterSearchResult(searchResult, probeResult, wildIndex)
                    @debug  "Better heuristic probe, at" searchResult wildIndex

                    # Is better, might be perfect
                    if probeResult.betterment == PerfectMatch
                        @debug "Perfect heuristic match"
                        break
                    end
                end
            end
        end
    end

    @debug  "  >>Heuristic search result" searchResult
    return searchResult
end


#=
For the given neighbor,
compute a wild corpus point which is in opposite relation (vector direction)
to this neighbor's best matching corpus point.
Opposite relation from this neighbor to the origin of the ScatterPatch of this neighbor.

Wild means it is computed using coordinate arithmetic and might be:
1) masked
2) out of bounds
=#
# TEMP WIP trying to parameterize on DimensionCount
#function wildRelatedCorpusIndex(neighbor::Neighbor{DimensionCount, ValueType}, synthResult)::CartesianIndex{DimensionCount}

function wildRelatedCorpusIndex(neighbor, synthResult)::CartesianIndex
    # assert neighbor is in the synth region and has been synthesized

    #=
    Coord arithmetic: corpus minus neighbor offset.  Both are subtype of CartesianIndex.
    !!! Subtraction reverses the direction of the offset.
    =#
    bestMatchingCorpusIndex = synthResult.mapFromTargetToCorpusPoints[neighbor.targetPoint]

    # TODO move to offset.jl  pointAtInverseOffset
    # @assert typeof(bestMatchingCorpusIndex) <: CartesianIndex
    wildCorpusIndex = bestMatchingCorpusIndex - neighbor.offset
    return wildCorpusIndex
end
