
@inline isPanguRunning() = occursin("viewer.exe", read(`tasklist /FI "IMAGENAME eq viewer.exe"`, String))

@inline i2id(i::Int) = i == 1 ? i - 1 : i + 2

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

# Launch PANGU in server mode
@inline function launchPangu(cam::PanguCamera; panguDir::String="C:/fc/software/Pangu/v8.01/", port::Int=10363)
    return launchPangu([cam]; panguDir=panguDir, port=port)
end

function launchPangu(cam::Vector{PanguCamera}; panguDir::String="C:/fc/software/Pangu/v8.01/", port::Int=10363)
    rm("PANGU.log", force=true)
    rm("_PERF_RESULTS.txt", force=true)
    cmdStr = "$panguDir/bin/viewer -server -port $port -image_format_tcp raw -grey_tcp -use_camera_model -use_detector_size"
    for i in eachindex(cam)
        cmdStr = cmdStr * " -cfov $(i2id(i)) $(cam[i].fov_deg) 1 0 0 -detector $(i2id(i)) $(Int(i == 1)) $(cam[i].width) $(cam[i].height) 0"
    end
    if !isPanguRunning()
        @show cmdStr
        run(`$(split(cmdStr))`, wait=false)
    else
        @warn "PANGU is already running"
    end
    return
end

mutable struct PanguClient
    client
    cam::Vector{PanguCamera}
end

PanguClient(client, cam::PanguCamera) = PanguClient(client, [cam])

function PanguClient(cam; panguDir::String="C:/fc/software/Pangu/v8.01/", port::Int=10363, javaSDKDir="C:/fc/software/JavaSDK/jdk-25.0.1/")
    # Initialize the JVM
    # Can be downloaded from: https://www.oracle.com/java/technologies/downloads/, x64 Compressed Archive for Windows
    ENV["JAVA_HOME"] = javaSDKDir

    # Initialize JVM with both jar and class directory in the classpath
    jarPath = joinpath(panguDir, "bin", "pangu_client_library.jar")
    classDir = joinpath(panguDir, "java", "pangu_client_library")
    try
        JavaCall.init(["-Xmx2G", "-Djava.class.path=$(jarPath);$(classDir)"])
    catch
    end

    # Import the Java classes
    ConnectionFactory = @jimport uk.ac.dundee.spacetech.pangu.ClientLibrary.ConnectionFactory
    ClientConnection = @jimport uk.ac.dundee.spacetech.pangu.ClientLibrary.ClientConnection

    # Connect client to PANGU server
    client = jcall(ConnectionFactory, "makeConnection", ClientConnection, (JString, jint), "localhost", port)

    return PanguClient(client, cam)
end

function getPanguImage(p::PanguClient, posWS_W, q_WS, distSun, azSun, elSun, camID=1)
    x, y, z = posWS_W
    qs, qx, qy, qz = q_WS

    # Run PANGU
    selectCamera(p.client, i2id(camID))
    setSunByRadians(p.client, distSun, azSun, elSun)
    rawImage = getViewpointByQuaternionD(p.client, x, y, z, qs, qx, qy, qz)
    @show size(rawImage)

    # Return image
    return rawGrey2image!(p.cam[camID].img, rawImage)
end

@inline function rawGrey2image!(image, rawImage, Nbits=8)
    maxVal = 2^Nbits - 1
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
