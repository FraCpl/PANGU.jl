mutable struct PanguCamera
    fov_deg::Float64
    width::Int
    height::Int
    img::Matrix{UInt8}
end

function PanguCamera(; fov::Float64=-1.0, fov_deg::Float64=30.0, width::Int=800, height::Int=600)
    if fov > 0
        fov_deg = fov*180/π
    end
    return PanguCamera(fov_deg, width, height, zeros(UInt8, height, width))
end

mutable struct PanguClient
    client
    cam::Vector{PanguCamera}
end

PanguClient(client, cam::PanguCamera) = PanguClient(client, [cam])

function PanguClient(cam; port::Int=10363)
    return PanguClient(makeConnection(port), cam)
end

@inline function launchServer(cam::PanguCamera, args::String=""; port::Int=10363)
    launchServer([cam], args; port=port)
    return
end

function launchServer(cam::Vector{PanguCamera}, args::String=""; port::Int=10363)
    # Build args string
    argsStr = "-image_format_tcp raw -grey_tcp -use_camera_model -use_detector_size $(args) -cfov 0 10 1 0 0"
    for i in eachindex(cam)
        argsStr = argsStr * " -cfov $i $(cam[i].fov_deg) 1 0 0 -detector $i $(Int(i < 3)) $(cam[i].width) $(cam[i].height) 0"
    end

    # Execute PANGU
    launchServer(argsStr, port)
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
