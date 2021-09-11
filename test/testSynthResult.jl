#=
This is a thin slice of Resynthesizer.
To test type stability
Of SynthResult
=#


# For "load" local  files
using FileIO

include("../src/synthResult.jl")


#=
Tests that all fields of given type expr are concrete.
=#
macro isconcretestruct(expr)
    @assert expr.head == :struct
    S = expr.args[2]
    return quote
        $(esc(expr))

        for n in fieldnames($S)
            if !isconcretetype(fieldtype($S, n))
                error("field $n is not concrete")
            end
        end
    end
end


# load an image

img_path = "/home/bootch/git/resynthesizerJulia/test/data/tinylighthouse.png"
img = load(img_path)

println(typeof(img))

# Need a mask to create MaskedImage
# The mask selcts whole image
mask = trues(size(img))


maskedImage = MaskedImage(img, mask)


synthResult = initialSynthResult(maskedImage)

println("Describing synthResult instance")
println(synthResult)
println(typeof(synthResult))

println(typeof(synthResult.mapFromTargetToCorpusPoints))
println(isconcretetype(typeof(synthResult.mapFromTargetToCorpusPoints)))

println(typeof(synthResult.hasValue))
println(isconcretetype(typeof(synthResult.hasValue)))

# Useless  to assert isconcretetype(result) since all structs are concrete
#println("Is fields concrete")
# Fail: @isconcretestruct(synthResult == 0)






# @code_warntype test()
# @time test(10000)
