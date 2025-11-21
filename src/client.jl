mutable struct PanguCamera
    fov_deg::Float64
    width::Int
    height::Int
    img::Matrix{Int}
end

function PanguCamera(; fov::Float64=-1.0, fov_deg::Float64=30.0, width::Int=800, height::Int=600)
    if fov > 0
        fov_deg = fov*180/π
    end
    return PanguCamera(fov_deg, width, height, zeros(Int, height, width))
end

mutable struct PanguClient
    client
    cam::Vector{PanguCamera}
end

PanguClient(client, cam::PanguCamera) = PanguClient(client, [cam])

function PanguClient(cam; port::Int=10363)
    return PanguClient(makeConnection(port), cam)
end

@inline function launchPangu(cam::PanguCamera, args::String=""; port::Int=10363)
    launchPangu([cam], args; port=port)
    return
end

function launchPangu(cam::Vector{PanguCamera}, args::String=""; port::Int=10363)
    # Build args string
    argsStr = "-image_format_tcp raw -grey_tcp -use_camera_model -use_detector_size $(args) -cfov 0 10 1 0 0"
    for i in eachindex(cam)
        argsStr = argsStr * " -cfov $i $(cam[i].fov_deg) 1 0 0 -detector $i $(Int(i < 3)) $(cam[i].width) $(cam[i].height) 0"
    end

    # Execute PANGU
    launchPangu(argsStr, port)
    return
end

function getPanguImageRaw(p::PanguClient, posWS_W, q_WS, distSun, azSun, elSun, camID=1)
    setSunByRadians(p.client, distSun, azSun, elSun)
    setViewpointByQuaternion(p.client, posWS_W, q_WS)
    return getViewpointByCamera(p.client, camID)
end

function getPanguImage(p::PanguClient, posWS_W, q_WS, distSun, azSun, elSun, camID=1)
    rawImage = getPanguImageRaw(p, posWS_W, q_WS, distSun, azSun, elSun, camID)
    @show size(rawImage)
    return rawGrey2image!(p.cam[camID].img, rawImage)
end

@inline function rawGrey2image!(image, rawImage)
    if isempty(rawImage)
        return Int[]
    end
    maxVal = 255# only 8 bits supported for now 2^Nbits - 1
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

@inline function rawGrey2image(rawImage, width, height)
    image = zeros(Int, height, width)
    return rawGrey2image!(image, rawImage)
end
