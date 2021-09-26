
#=
Test Resynthesizer by comparing out images to reference good result image.

Using testing framework.
=#


# See "Code Loading"
# Either include, or import package
include("../src/apps/inpaint.jl")
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

  # lighthouse image

  # Here the in image is the same as the reference
  # The in image has already been processed, we mask the result off,
  # and process it again.

  # input

  tiny = true
  donkey = false

  # a mask, that covers the lighthouse
  # height dimension first for Julia
  if tiny
      # 8w x 5h

      img_path = "/home/bootch/git/resynthesizerJulia/test/data/in/tinylighthouse.png"
      img = load(img_path)
      mask = falses(size(img))
      mask[3:4, 2:3] .= true
  elseif donkey
      img_path = "/home/bootch/git/resynthesizerJulia/test/data/indonkey.png"
      img = load(img_path)
      mask = falses(size(img))
      # square mask of the donkey itself
      mask[175:275,100:230] .= true
  else
      # 768x x 512h

      # The file is remote, in the  TestImage  pkg ??
      #img  = Float64.(Gray.(testimage("lighthouse")))
      img  = testimage("lighthouse")
      mask = falses(size(img))

      # Usual size mask
      #mask[50:350,300:400] .= true
      # Smaller masks, for dev
      mask[50:60,300:320] .= true
      # Tiny mask
      # mask[50:52,300:302] .= true
  end

  # time or profile or none
  #out = @time inpaint(img, mask)
  # @profile
  # or better to do this in the REPL?
  # out = inpaint(img, mask)
  out = @time inpaint(img, mask)


  img_path = "/home/bootch/git/resynthesizerJulia/test/out.png"
  save(img_path, out)

  # Julia macro that compares file and expression
  @test_reference "data/out/lighthouse.png" out
end
