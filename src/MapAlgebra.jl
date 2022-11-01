module MapAlgebra

import GDAL

# A data type for raster data
struct Raster
    width::Int64
    height::Int64
    getValue::Function
end 

function fromFile(path, bands = 1)
    dataset = GDAL.gdalopen(path, GDAL.GA_ReadOnly)
    if bands == 1
        band = GDAL.gdalgetrasterband(dataset, 1)
        Raster(
            GDAL.gdalgetrasterxsize(dataset),
            GDAL.gdalgetrasterysize(dataset),
            (x,y) -> begin
                res = Vector([0])
                GDAL.gdalrasterio(
                    band,
                    GDAL.GF_Read,
                    x, y, 1, 1,
                    res, 1, 1,
                    GDAL.GDT_Int32,
                    0,0
                )
                res[1]
            end
        )
    else

    end
end

function Base.:+(xRaster::Raster, yRaster::Raster)
    @assert xRaster.width == yRaster.width
    @assert xRaster.height == yRaster.height
    Raster(
        xRaster.width, 
        xRaster.height, 
        (x,y) -> xRaster.getValue(x, y) + yRaster.getValue(x, y)
    )
end

function Base.:*(xRaster::Raster, yRaster::Raster)
    @assert xRaster.width == yRaster.width
    @assert xRaster.height == yRaster.height
    Raster(
        xRaster.width, 
        xRaster.height, 
        (x,y) -> xRaster.getValue(x, y) * yRaster.getValue(x, y)
    )
end

function Base.:-(xRaster::Raster, yRaster::Raster)
    @assert xRaster.width == yRaster.width
    @assert xRaster.height == yRaster.height
    Raster(
        xRaster.width, 
        xRaster.height, 
        (x,y) -> xRaster.getValue(x, y) - yRaster.getValue(x, y)
    )
end

function Base.:/(xRaster::Raster, yRaster::Raster)
    @assert xRaster.width == yRaster.width
    @assert xRaster.height == yRaster.height
    Raster(
        xRaster.width, 
        xRaster.height, 
        (x,y) -> xRaster.getValue(x, y) / yRaster.getValue(x, y)
    )
end

function Base.:^(xRaster::Raster, c::Any)
    Raster(
        xRaster.width, 
        xRaster.height, 
        (x,y) -> xRaster.getValue(x, y) ^ c
    )
end

function Base.:^(c::Any, xRaster::Raster)
    Raster(
        xRaster.width, 
        xRaster.height, 
        c ^ (x,y) -> xRaster.getValue(x, y)
    )
end

function Base.:+(xRaster::Raster, c::Any)
    Raster(
        xRaster.width, 
        xRaster.height, 
        (x,y) -> xRaster.getValue(x, y) + c
    )
end

function Base.:+(c::Any, xRaster::Raster)
    Raster(
        xRaster.width, 
        xRaster.height, 
        c + (x,y) -> xRaster.getValue(x, y)
    )
end

function Base.:*(xRaster::Raster, c::Any)
    Raster(
        xRaster.width, 
        xRaster.height, 
        (x,y) -> xRaster.getValue(x, y) * c
    )
end

function Base.:*(c::Any, xRaster::Raster)
    Raster(
        xRaster.width, 
        xRaster.height, 
        c * (x,y) -> xRaster.getValue(x, y)
    )
end

function Base.:-(xRaster::Raster, c::Any)
    Raster(
        xRaster.width, 
        xRaster.height, 
        (x,y) -> xRaster.getValue(x, y) - c
    )
end

function Base.:-(c::Any, xRaster::Raster)
    Raster(
        xRaster.width, 
        xRaster.height, 
        c - (x,y) -> xRaster.getValue(x, y)
    )
end

function Base.:/(xRaster::Raster, c::Any)
    Raster(
        xRaster.width, 
        xRaster.height, 
        (x,y) -> xRaster.getValue(x, y) / c
    )
end

function Base.:/(c::Any, xRaster::Raster)
    Raster(
        xRaster.width, 
        xRaster.height, 
        c / (x,y) -> xRaster.getValue(x, y)
    )
end

end
