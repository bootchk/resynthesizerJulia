
#=
Test Resynthesizer by comparing out images to reference good result image.

Using testing framework.
=#


# See "Code Loading"
# Either include, or import package
include("../../src/resynthesizer.jl")
# using Resynthesizer

# the Julia testing framework
using ReferenceTests
using Test

# profiling framework
using Profile

# for "testimage" of packaged, remote  test files ?
using TestImages

# For "load" local  files
using FileIO

using ColorTypes

#using Pkg
#Pkg.instantiate()

# This is executable, not a definition
@testset "Resynthesizer" begin

  # donkey image

  # Don't understand why I can't use relative path here
  inPath  = "/home/bootch/git/resynthesizerJulia/test/data/in/lighthouse.png"
  # Reference image in this directory
  outPath = "data/out/lighthouse.png"

  image = load(inPath)

  mask = falses(size(image))
  # upright rectangular mask of the lighthouse itself
  mask[50:350,300:400] .= true

  out = resynthesize(image, mask)

  # Julia macro that compares file and expression
  @test_reference outPath out
end
