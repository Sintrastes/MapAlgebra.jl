# MapAlgebra.jl

[![Build Status](https://github.com/sintrastes/MapAlgebra.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/sintrastes/MapAlgebra.jl/actions/workflows/CI.yml?query=branch%3Amain)

MapAlgebra.jl is a small Julia library wrapping [GDAL.jl](https://github.com/JuliaGeo/GDAL.jl), providing a higher-level `Raster` type and some mathematical (algebraic) operations on said rasters.

## Usage Examples

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
