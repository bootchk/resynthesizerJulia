
#=
Test Resynthesizer by comparing out images to reference good result image.

The healSelection application.

Using testing framework.
=#


# See "Code Loading"
# Either include, or import package
include("../../../src/apps/healSelection.jl")


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
  inPath  = "/home/bootch/git/resynthesizerJulia/test/data/in/donkey.png"
  # Reference image in this directory
  outPath = "data/out/donkey.png"

  image = load(inPath)

  mask = falses(size(image))
  # square mask of the donkey itself
  mask[175:275,100:230] .= true

  # frisketDepth = 40
  out = healSelection(image, mask, 40)

  # Julia macro that compares file and expression
  @test_reference outPath out
end
