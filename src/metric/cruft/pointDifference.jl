



#=
Compute difference between values at points.

This hides knowledge of the values at points.
E.G. the values are colors.

!!! This is deep in loops, i.e. in the bottleneck, it is important to be fast.

In math terms, a metric.
Here we are not concerned if the metric does not have properties of a true metric,
We want property "non-negative".
We don't care property "symmetric" and other properties of a metric.

More generally, the metric should be a property of the tensor.
=#

#=
Apply a metric between colors at points in images,
returning a large value when points are out of bounds.
Require patchPointTarget to be in bounds,
but not require patchPointCorpus to be in bounds,

The original implemented its own metric and iterated over pixelels.
Here we don't use the word "pixel", which is fraught with ambiguity.

Here use Julia built-in colordiff()

Wolfram says CIE2000 is 3x slower than CIE94.
In Julia DE_2000 versus DE_94

TODO more generally, this should take a comparator function,
instead of specializing to Color.
=#
#=
function pointDifference(
    patchPointTarget::CartesianIndex{DimensionCount},
    patchPointCorpus::CartesianIndex{DimensionCount}
    ) where {DimensionCount}

    result = 0

    # Require both points to be in bounds

    result = colordiff(
        patchPointCorpus.maskedImage.image[ patchPointCorpus.point ],
        patchPointTarget.maskedImage.image[ patchPointTarget.point ],
        metric=DE_94() )
    # @debug "Color diff" result patchPointCorpus.point patchPointTarget.point

    # TODO original algorithm also used weight maps

    return result
end
=#


#=
Specialized: first argument is color.
More generally, call it a "value."
=#
function pointDifference(targetColor, patchPointCorpus )
    result = 0
    # Require both points to be in bounds
    corpusColor = patchPointCorpus.maskedImage.image[ patchPointCorpus.point ]
    result = colordiff(
        corpusColor,
        targetColor,
        metric )
    # WAS metric=DE_94() i.e. computing the metric deep in the loops
    return result
end
