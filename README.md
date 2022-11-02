# MapAlgebra.jl

[![Build Status](https://github.com/sintrastes/MapAlgebra.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/sintrastes/MapAlgebra.jl/actions/workflows/CI.yml?query=branch%3Amain)

MapAlgebra.jl is a small Julia library wrapping [GDAL.jl](https://github.com/JuliaGeo/GDAL.jl), providing a higher-level `Raster` type and some mathematical (algebraic) operations on said rasters.

## Design Principles

MapAlgebra.jl's design and overall goals difer from existing GDAL wrappers in Julia such as [ArchGDAL.jl](https://github.com/yeesian/ArchGDAL.jl) in several ways:

  * **Functional**: We want to provide a convinient API allowing the user to perform GIS processing largely in a declarative/functional style. Most functionality should be possible by chaining functions together, such as with [Pipe.jl](https://github.com/oxinabox/Pipe.jl).
  * **Lazy**: All raster operations are lazy by default -- this allows for the flexibility of allowing users to either calculate values of a composite raster on-the-fly as needed for their particular application, or to pre-process these operations and store them either in-memory or on-disk.
  * **Mathematical**: We want to make use of mathematical abstractions where appropriate instead of the raw GDAL data model. For instance, to bridge the gap between vector and raster data, we make use of a free vector space (TODO). Functional programming idioms derived from category theory such as profunctors are also available where appropriate.
  * **Extensible**: GDAL only supports a fixed set of data types that can be stored in raster bands -- but that doesn't mean you have to limit yourself! We aim to make use of Julia features and idioms such as multiple dispatch and traits to be as extensible as possible. Want to do some quaternion calculations on LIDAR data, and write that to a file? No problem (TODO)!
  
## Usage Examples

Estimate walking velocity:

```julia
import MapAlgebra

# Load some raw elevation data from a GeoTiff
elevation = MapAlgebra.readRaster("/path/to/elevation/raster.tif")

# Build an aniostropic slope raster from elevation (lazily)
slope = MapAlgebra.anisoSlope(elevation)

# Define a function to estimate walking velocity from slope.
toblers(θ) = 6 * e ^ (-3.5 * abs(tan(θ) + 0.05))

# Build up an anisotropic walking speed raster and write it to file.
MapAlgebra.writeToFile(toblers(slope), "/path/to/out.tif")
```
