
The "Resynthesizer" algorithm for texture transfer in images.
An "inpainting" or "image reconstruction" algorithm, among other things.

Ported from C to Julia.
Derived from https://github.com/bootchk/resynthesizer.git.
Minimal changes to the algorithm, but significant refactoring.

The main purpose: generalize to many dimensions and element types.

### Status

!!! Work in progress !!!

The current status is that the "heal selection" feature *might* work like the original.
For:
* 2D characters (poems as arrays?)
* 2D images
* 3D images (an MRI i.e. x,y,z )
* 3D video (time lapse of 2D images i.e. x,y,time )


Currently not concerned much (still struggling with) performance and fidelity with the original.  

See below, many applications (plugins in the original) are not implemented.

I'm just learning Julia.
There is much cruft: files and code that are not used or not correct.

### Goals
  - just as fast as the C language version
  - smaller code, easier to read and understand
  - more general: work with multiple dimensions
    e.g. 1D text, 2D poetry, 2D images, 3D video, 3D music?
    Test that Julia does permit generalized algorithms

### Attribution

Copyright 2021 Lloyd Konneker

Original algorithm by Paul Harrison.

### Resynthesizer as a search algorithm

Resynthesizer is fundamentally a search algorithm.
But a search for a best match, not an exact match.
And search using a context: not search for an element, but patches around an element.  AKA "patch match."

This project attempts to generalize a search algorithm
so that it works with multi-dimension arrays of varying element types.

This project also attempts to generalize the Resynthesizer algorithm so that it returns the location of a best match, like most search algorithms.  The original did not return that result.  The original modified the comparand (the synthesized region) as the algorithm progressed.  If you don't modify the comparand, there might exist other applications of the algorithm.

### Resynthesizer as a suite of applications

The original repository has many plugins.  These are different applications of a highly parameterized algorithm.

* heal selection (inpainting)
* render texture
* texture transfer (style transfer, painterly effects)

The plugins embed knowledge of how to arrange input images and set parameters for each application.

For now, the plugins and even the highly parameterized algorithm
(for example using weight maps) have not been ported.


### Log of development

Brief notes about the history of the code.

The original algorithm and code is by Paul Harrison, circa 2005. http://www.logarithmic.net/pfh/resynthesizer

I took over maintenance of the code circa 2010. https://github.com/bootchk/resynthesizer.git.
* fixed some bugs due to changes in GIMP.
* rewrote and restructured the code.
* threaded implementation
* better handling of alpha (transparency)
* more plugins (applications easy to use within the GIMP app.)

I have long intended to port the algorithm so that it could be used outside of the  GIMP app.
For example, make it a GEGL plugin.  That is hindered by the fact that the implementation
is very low-level, and doesn't use a a standard library for image manipulation.

The C code is hard to read and hard to modify. (It is however stable, and well tested.)
So I wanted to rewrite in a high level language.

For this project...

I naively ported the original algorithm in C, or at least a slice of it
(omitting some of the features.)  Then it somewhat worked on 2D images.
I didn't test that the output of the algorithm was the same as the C implementation,
only that the program didn't crash, and seemed to give similar, if poor results.

Then I struggled with excess memory allocations, affecting performance.
I added many type annotations that I had previously omitted,
assuming that Julia would infer them.

For example, I had assumed that a function returning a struct would not do an allocation.
I ended up allocating a struct and passing it to a function to be mutated.
This is much more like the original C code than I had hoped for.
Its possible I am missing some concepts of Julia.

Then I generalized the algorithm for multi-dimension arrays (MDA.)
(The code is still riddled with ambiguous naming.
Sometimes I say tensor, or image, or array.)
That was remarkably easy for 2D and 3D, but then, that's one of the goals of Julia.
I am still struggling with:
* 1D, the indexes are Int64 instead of CartesianIndex{N},
  and those two types don't have a common supertype?
* 4D, the arrays are reshaped(reinterpreted()) which I don't understand yet
* whether to use generated functions instead of runtime dispatch on dimension.

From here...
* restore fidelity with the original algorithm
* restore performance
* explore real applications in other dimensions
* explore uses of a returned location of best matches (without replacement.)

## Aspects of the algorithm important to its performance

The algorithm uses various tricks or heuristics for performance.

Note that some of the tricks from the original may not yet be in this implementation.

This is not a complete discussion of all the tricks, just an overview of the most important tricks.

The algorithm uses a variant of the Cauchy distribution to compute point differences.
The original author discusses the importance.
Using this function is one reason that inhibits SMD vectorization of the algorithm.

The algorithm uses a heuristic to select points to sample in the search.
This enhances performance.

The algorithm uses two types of patch (a scatter patch and a dense, contiguous patch.)
Thus the algorithm from the very first uses context to synthesize points.
(Even though the context may be far away from the synthesized point.)
Whereas some other algorithms use random samples to fill in the initial synthesized values.
(The algorithm doesn't actually use two types.
It just uses ScatterPatch, which generalizes the two types of patch,
and after the first patch, a Scatter patch is dense and contiguous.)
Using ScatterPatch is another reason that inhibits SMD vectorization of the algorithm.
(The values in a ScatterPatch are not in consecutive locations of memory.)

The algorithm uses structures that cache frequently used data.
In other words, the algorithm is not a naive implementation from first principles,
but organizes the original data into data structures
that remain in the CPU caches with high probability.
If computers did not have cached memory (or if all memory were as fast as the L1 cache)
this would not be a concern.

Some of the tricks are in the plugins that wrap the algorithm.
For example, the plugins let a user choose a corpus that is near the synthesized region
(e.g. a frisket/)
If you don't do that, artifacts from far away in the corpus creep into the result.
For another example, the plugins let the user choose an order of synthesis.
If you don't do that, linear structures at the boundary of the synthesized region
are not synthesized well.
