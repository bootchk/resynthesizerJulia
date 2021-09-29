

# unit under test
include("../../src/image/mask.jl")


# test data

array1 = ones(3, 3)
array2 = ones(5, 5)

mask1 = BitArray(
[0 0 0;
 0 1 0;
 0 0 0])

mask1Frisket = BitArray(
 [1 1 1;
  1 0 1;
  1 1 1])

mask2 = BitArray(
[0 0 0 0 0;
 0 0 0 0 0;
 0 0 1 0 0;
 0 0 0 0 0;
 0 0 0 0 0])

mask2Frisket = BitArray(
[0 0 0 0 0;
 0 1 1 1 0;
 0 1 0 1 0;
 0 1 1 1 0;
 0 0 0 0 0])

 mask2Frisket2 = BitArray(
 [1 1 1 1 1;
  1 1 1 1 1;
  1 1 0 1 1;
  1 1 1 1 1;
  1 1 1 1 1])

result = frisketMaskAroundMask(array1, mask1, 1)
@assert result == mask1Frisket


result = frisketMaskAroundMask(array2, mask2, 1)
@assert result == mask2Frisket

result = frisketMaskAroundMask(array2, mask2, 2)
@assert result == mask2Frisket2

# frisketDepth out of bounds of array
result = frisketMaskAroundMask(array2, mask2, 3)
@assert result == mask2Frisket2
