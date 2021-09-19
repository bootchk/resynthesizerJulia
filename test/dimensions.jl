#=
Test suite across dimensions and element types.
An aggregation of individual test cases (e.g. see 2D/test/tiny.jl)

See below.
Loosely speaking:
    data types: color, grey, char
    dimensions: 2, 3

>cd <top>
>julia --project=test test/dimensions.jl
=#

# The tested code
include("../src/resynthesizer.jl")


# the Julia testing framework
using ReferenceTests
using Test
using Profile
using TestImages    # for "testimage" of packaged, remote  test files ?
using FileIO    # For "load" local  files
using ColorTypes


# This is executable, not a definition
# Each test_reference is a test of the testset
@testset "Dimensions" begin


    # 1D text
    # Not working, index is Int64 instead of Cartesian{1}




    # 2D text
    # exactly 72 bytes long
    inPath = "/home/bootch/git/resynthesizerJulia/test/data/in/tiny.txt"
    # !!! load will not load a text, use read()
    file = open(inPath)
    textStream = read(file, 72)
    # reshape to an array, a pseudo-poem
    data = reshape(textStream, 6, 12)

    mask = falses(size(data))
    mask[3:4, 2:3] .= true

    outPath = "data/out/tiny.txt"
    @test_reference outPath resynthesize(data, mask)



    # 2D color image

    inPath = "/home/bootch/git/resynthesizerJulia/test/data/in/tinylighthouse.png"
    data = load(inPath)
    mask = falses(size(data))
    mask[3:4, 2:3] .= true

    outPath = "data/out/tinylighthouse.png"
    @test_reference outPath resynthesize(data, mask)





    # 3D gray (slices of an mri)
    using TestImages
    fullImage = testimage("mri");
    print(summary(fullImage))

    # See JuliaImages. The image has named axes. We only want to convert the data.
    data = fullImage.data

    # mask
    mask = falses(size(data))
    # synthesize a small cube in the horizontal slices 5 and 6
    mask[3:4, 2:3, 5:6] .= true

    out = resynthesize(data, mask)

    outPath = "data/out/mri"
    #=
    TODO this fails because test_reference fails to handle 3D???

    @test_reference outPath resynthesize(data, mask)

    Consequently, we iteratively compare some slices of the image.
    =#

    # The first horizontal (superior axis) plane is at z=5
    slice = out[:,:,5]
    print(summary(slice))

    # compare one slice to the reference
    @test_reference outPath slice



    # 3D color video (time lapsed 2D images)
    # TODO



    # 4D e.g. time lapsed 3D images, or time lapses 2D images with explicit channels?
    # copied from test/4D/multi.jl
    # "multi" is short name
    fullImage = testimage("multi");

    println("fullImage is:")
    println(summary(fullImage))
    # 167×439×3×7

    #=
    See JuliaImages.
    The image has named axes.
    And metadata??
    We only want to convert the data.
    Extract: data(fullImage), not fullImage.data??
    =#
    imageWithAxes = data(fullImage)
    imageView = imageWithAxes.data
    #=
    imageView is still reshape(reinterpret(...)) which throws type errors.
    Its a view. So copy it.
    =#
    image = copy(imageView)

    # Create mask
    mask = falses(size(image))
    # ??? The third dimension is 3 channels.  Arbitrarily take them all.
    mask[3:4, 2:3, 1:3, 5:6] .= true

    # test
    out = resynthesize(data, mask)

    outPath = "data/out/multi"
    #=
    test_reference fails to handle 3D, 4D ???
    Consequently, we iteratively compare some slices of the image.
    =#
    println("typeof(out) is")
    println(typeof(out))

    # Don't care what this slice is, u=5
    slice = out[:,:,:,5]
    print(summary(slice))

    # compare one slice to the reference
    #@test_reference outPath slice
end
