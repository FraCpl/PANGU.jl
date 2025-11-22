@inline function rawGrey2image!(image::AbstractMatrix{U}, rawImage::AbstractVector{T}) where {T, U}
    @assert U == unsigned(T)
    if isempty(rawImage)
        return U[]
    end
    maxVal = typemax(U)
    height, width = size(image)
    k = 1
    @inbounds for j in 1:height
        @inbounds for i in 1:width
            val = rawImage[k]
            image[j, i] = val < 0 ? val + maxVal : val
            k += 1
        end
    end
    return image
end

@inline function rawGrey2image(rawImage::AbstractVector{T}, width::Int, height::Int) where {T}
    image = zeros(unsigned(T), height, width)
    return rawGrey2image!(image, rawImage)
end

const rawGray2image = rawGrey2image
const rawGray2image! = rawGrey2image!

@inline function rawRGB2image!(image::Array{U, 3}, rawImage::AbstractVector{T}) where {T, U}
    @assert U == unsigned(T)
    if isempty(rawImage)
        return Array{U, 3}(undef, 0, 0, 0)
    end
    maxVal = typemax(U)
    height, width = size(image)
    k = 1
    @inbounds for j in 1:height
        @inbounds for i in 1:width
            @inbounds for p in 1:3
                val = rawImage[k]
                image[j, i, p] = val < 0 ? val + maxVal : val
                k += 1
            end
        end
    end
    return image
end

@inline function rawRGB2image(rawImage::AbstractVector{T}, width::Int, height::Int) where {T}
    image = zeros(unsigned(T), height, width, 3)
    return rawRGB2image!(image, rawImage)
end
