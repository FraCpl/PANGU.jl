
@inline isPanguRunning() = occursin("viewer.exe", read(`tasklist /FI "IMAGENAME eq viewer.exe"`, String))

# Launch PANGU in server mode
function launchPangu(; panguDir::String="C:/fc/software/Pangu/v8.01/", port::Int=10363, width::Int=800, height::Int=600)
    if !isPanguRunning()
        run(`$(joinpath(panguDir, "bin", "viewer")) -server -port $port -image_format_tcp raw -grey_tcp -width $width -height $height`, wait=false)
    end
    return port
end

function connectToPangu(; panguDir::String="C:/fc/software/Pangu/v8.01/", port::Int=10363, javaSDKDir="C:/fc/software/JavaSDK/jdk-25.0.1/")
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

    # Launch PANGU if not already running
    if !isPanguRunning()
        launchPangu()
    end

    # Connect client to PANGU server
    while !isPanguRunning()
        wait(0.1)
    end
    client = jcall(ConnectionFactory, "makeConnection", ClientConnection, (JString, jint), "localhost", port)

    return client
end

function testPangu()
    client = connectToPangu()
    return getPanguImage(client, [0.0, 0.0, 2000.0], [0.0; 1.0; 0.0; 0.0], 149597870700.0, 0.0, π / 8, 0.6)
end

function getPanguImage(client, posWS_W, q_WS, distSun, azSun, elSun, fov, camID=0)
    x, y, z = posWS_W
    qs, qx, qy, qz = q_WS
    selectCamera(client, camID)
    setFieldOfViewByRadians(client, fov)
    setSunByRadians(client, distSun, azSun, elSun)

    rawImage = Int.(getViewpointByQuaternionD(client, x, y, z, qs, qx, qy, qz))
    @inbounds for i in eachindex(rawImage)
        val = rawImage[i]
        rawImage[i] = val < 0 ? val + 255 : val
    end
    return reshape(rawImage, 800, 600)' # TODO: modify size, or at least retrieve it from client
end
