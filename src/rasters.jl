
import GDAL
import Core
using Pipe: @pipe

"""
    Raster

Type representing the abstract notion of a raster. 

May or may not be associated with a concrete raster on disk, and may instead be
 an in-memory representation, or even a lazy combination of other rasters.

Pulls individual pixels (via `getValue`) lazily by default -- and does not load the
 whole raster into memory unless requested.
"""
struct Raster
    width::Int64
    height::Int64
    getValue::Function
end 

"""
    readRaster(path::String)

Load a GDAL-compatible raster file from disk.

Loads multi-band rasters in as a raster whose `getValue`
 function returns an array.
"""
function readRaster(path::String)
    dataset = GDAL.gdalopen(path, GDAL.GA_ReadOnly)
    numBands = GDAL.gdalgetrastercount(dataset)

    if numBands == 1
        band = GDAL.gdalgetrasterband(dataset, 1)
        Raster(
            GDAL.gdalgetrasterxsize(dataset),
            GDAL.gdalgetrasterysize(dataset),
            (x,y) -> begin
                readRasterSingle(band, x, y, GDAL.GDT_Int32)
            end
        )
    else
        bands = @pipe 1:numBands |> 
            collect(_) |>
            map((i) -> GDAL.gdalgetrasterband(dataset, 1), _)

        Raster(
            GDAL.gdalgetrasterxsize(dataset),
            GDAL.gdalgetrasterysize(dataset),
            (x,y) -> begin
                @pipe bands |>
                    map((band) -> readRasterSingle(band, x, y, GDAL.GDT_Int32))
            end
        )
    end
end

function readRasterSingle(band, x, y, type)
    res = Vector([0])
    GDAL.gdalrasterio(
        band,
        GDAL.GF_Read,
        x, y, 1, 1,
        res, 1, 1,
        type,
        0, 0
    )
    res[1]
end

# Unary operations on rasters

"""
    map(f::Function, r::Raster)

Apply a function `f` lazily to the result values of the raster.
"""
map(f::Function, r::Raster) = Raster(
    r.width, 
    r.height, 
    (x,y) -> f(r.getValue(x, y))
)

Base.cos(r::Raster) = map(cos, r)

Base.sin(r::Raster) = map(sin, r)

Base.tan(r::Raster) = map(tan, r)

Base.atan(r::Raster) = map(atan, r)

Base.log(r::Raster) = map(log, r)

# Raster - Raster operations

"""
    lift2(f::Function, xRaster::Raster, yRaster::Raster)

Take a function of two arguments, and apply it to two rasters.

Will throw an exception if the rasters are both not of the same dimensions
 (`xSize`, `ySize` and projection).
 
Can be used to define new binary operators on rasters.
"""
function lift2(f::Function, xRaster::Raster, yRaster::Raster) 
    @assert xRaster.width == yRaster.width
    @assert xRaster.height == yRaster.height
    Raster(
        xRaster.width, 
        xRaster.height, 
        (x,y) -> f(xRaster.getValue(x, y), yRaster.getValue(x, y))
    )
end

Base.:+(xRaster::Raster, yRaster::Raster) = lift2(+, xRaster, yRaster)

Base.:*(xRaster::Raster, yRaster::Raster) = lift2(*, xRaster, yRaster)

Base.:-(xRaster::Raster, yRaster::Raster)  = lift2(-, xRaster, yRaster)

Base.:/(xRaster::Raster, yRaster::Raster)  = lift2(/, xRaster, yRaster)

# Raster - Scalar Operations

"""
lift2C(f::Function, c::Any, raster::Raster) 

Take a function of two arguments, and apply it to a raster and a scalar.
 
Can be used to define new binary operators combining a scalar with a raster.
"""
function lift2C(f::Function, c::Any, raster::Raster) 
    Raster(
        raster.width, 
        raster.height, 
        (x,y) -> f(c, yRaster.getValue(x, y))
    )
end

Base.:^(xRaster::Raster, c::Any) = lift2C(^, c, xRaster)

Base.:^(c::Any, xRaster::Raster) = lift2C(^, c, xRaster)

Base.:+(xRaster::Raster, c::Any) = lift2C(+, c, xRaster)

Base.:+(c::Any, xRaster::Raster) = lift2C(+, c, xRaster)

Base.:*(xRaster::Raster, c::Any) = lift2C(*, c, xRaster)

Base.:*(c::Core.Number, xRaster::Raster) = lift2C(*, c, xRaster)

Base.:-(xRaster::Raster, c::Any) = lift2C(-, c, xRaster)

Base.:-(c::Any, xRaster::Raster) = lift2C(-, c, xRaster)

Base.:/(xRaster::Raster, c::Any) = lift2C(/, c, xRaster)

Base.:/(c::Any, xRaster::Raster) = lift2C(/, c, xRaster)
