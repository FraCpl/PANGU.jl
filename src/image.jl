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
            val = Int(rawImage[k])
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
