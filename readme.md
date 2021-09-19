
The "Resynthesizer" algorithm for texture transfer in images.
An "inpainting" or "image reconstruction" algorithm, among other things.

Ported from C to Julia.
Derived from https://github.com/bootchk/resynthesizer.git.
Minimal changes to the algorithm, but significant refactoring.


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
