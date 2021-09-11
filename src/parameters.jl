
using Parameters


#=
Parameters of the algorithm.

Some affect iteration length.
Some affect struct size.

Names from original C implementation in the comments.

Defaults are from original C.
=#

#=
TODO
Constants spread in the code.  Not parameters, here or in the original.

MAX_PASSES

IMAGE_SYNTH_MAX_NEIGHBORS was defined in the original, not here.
It was a hard limit on patchLength parameter

IMAGE_SYNTH_TERMINATE_FRACTION. 0.1

# MAX_PROBES_PER_PASS ??
=#

@with_kw struct ResynthesizerParameters
    maxPatchSize::UInt   = 30   # desired size of patches, some will be shorter
    maxProbeCount::UInt = 200
    withReplacement::Bool = true
    #b::Float64 = -1.1
    #c::UInt8
end
