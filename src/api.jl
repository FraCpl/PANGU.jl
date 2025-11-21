# Launch PANGU in server mode
@inline function launchServer(args::String="", port::Int=10363; rmlogs=true)
    # Check if setup has been done or not
    if isnothing(panguDir())
        @error "PANGU has not been setup properly. Please launch 'setupPangu(panguDir=..., javasdkDir=...)' and retry"
        return
    end

    # Check if PANGU is already running
    if occursin("viewer.exe", read(`tasklist /FI "IMAGENAME eq viewer.exe"`, String))
        @warn "PANGU is already running"
        return
    end

    # Remove old logging files
    if rmlogs
        try
            rm("PANGU.log", force=true)
            rm("_PERF_RESULTS.txt", force=true)
        catch
        end
    end

    # Execute PANGU
    cmdStr = "$(panguDir())bin/viewer -server -port $port $args"
    println("Launching PANGU server: $cmdStr")
    run(`$(split(cmdStr))`, wait=false)
end

function makeConnection(port::Int=10363)
    # Initialize the JVM
    ENV["JAVA_HOME"] = javasdkDir()

    # Initialize JVM with both jar and class directory in the classpath
    jarPath = joinpath(panguDir(), "bin", "pangu_client_library.jar")
    classDir = joinpath(panguDir(), "java", "pangu_client_library")
    try
        JavaCall.init(["-Xmx2G", "-Djava.class.path=$(jarPath);$(classDir)"])
    catch
    end

    # Import the Java classes
    ConnectionFactory = @jimport uk.ac.dundee.spacetech.pangu.ClientLibrary.ConnectionFactory
    ClientConnection = @jimport uk.ac.dundee.spacetech.pangu.ClientLibrary.ClientConnection

    # Connect client to PANGU server
    return jcall(ConnectionFactory, "makeConnection", ClientConnection, (JString, jint), "localhost", port)
end


@inline function selectCamera(client, cid)
    jcall(client, "selectCamera", Cvoid, (JavaCall.jlong,), cid)
    return
end

@inline function setFieldOfViewByRadians(client, fov)
    jcall(client, "setFieldOfViewByRadians", Cvoid, (JavaCall.jfloat,), fov)
    return
end

@inline function setFieldOfViewByDegrees(client, fov)
    jcall(client, "setFieldOfViewByDegrees", Cvoid, (JavaCall.jfloat,), fov)
    return
end

@inline function setSunByRadians(client, r, azi, ele)
    jcall(client, "setSunByRadians", Cvoid, (jdouble, jdouble, jdouble), r, azi, ele)
    return
end

@inline function setSunByDegrees(client, r, azi, ele)
    jcall(client, "setSunByDegrees", Cvoid, (jdouble, jdouble, jdouble), r, azi, ele)
    return
end

@inline function getViewpointByCamera(client, cid)
    jcall(client, "getViewpointByCamera", Vector{jbyte}, (jlong,), cid)
end

@inline function getViewpointByQuaternion(client, x, y, z, qs, qx, qy, qz)
    return jcall(client, "getViewpointByQuaternionD", Vector{jbyte}, (jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble), x, y, z, qs, qx, qy, qz)
end

@inline function getViewpointByQuaternionD(client, x, y, z, qs, qx, qy, qz)
    return jcall(client, "getViewpointByQuaternionD", Vector{jbyte}, (jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble), x, y, z, qs, qx, qy, qz)
end

@inline function setViewpointByQuaternion(client, pos, q)
    x, y, z = pos
    qs, qx, qy, qz = q
    jcall(client, "setViewpointByQuaternion", Cvoid, (jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble), x, y, z, qs, qx, qy, qz)
    return
end

@inline function setViewpointByQuaternion(client, x, y, z, qs, qx, qy, qz)
    jcall(client, "setViewpointByQuaternion", Cvoid, (jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble), x, y, z, qs, qx, qy, qz)
    return
end

@inline function getViewpointByDegreesD(client, x, y, z, yaw, pitch, roll)
    jcall(client, "getViewpointByDegreesD", Vector{jbyte}, (jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble), x, y, z, yaw, pitch, roll)
    return
end

@inline function getViewpointByRadians(client, x, y, z, yaw, pitch, roll)
    jcall(client, "getViewpointByRadians", Vector{jbyte}, (jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble), x, y, z, yaw, pitch, roll)
    return
end

@inline function setViewpointByQuaternionD(client, x, y, z, qs, qx, qy, qz)
    jcall(client, "setViewpointByQuaternionD", Cvoid, (jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble), x, y, z, qs, qx, qy, qz)
    return
end

@inline function setViewpointByDegrees(client, x, y, z, yaw, pitch, roll)
    jcall(client, "setViewpointByDegrees", Cvoid, (jdouble, jdouble, jdouble, jdouble, jdouble, jdouble), x, y, z, yaw, pitch, roll)
    return
end

@inline function setViewpointByDegreesD(client, x, y, z, yaw, pitch, roll)
    jcall(client, "setViewpointByDegreesD", Cvoid, (jdouble, jdouble, jdouble, jdouble, jdouble, jdouble), x, y, z, yaw, pitch, roll)
    return
end

@inline function setViewpointByRadians(client, x, y, z, yaw, pitch, roll)
    jcall(client, "setViewpointByRadians", Cvoid, (jdouble, jdouble, jdouble, jdouble, jdouble, jdouble), x, y, z, yaw, pitch, roll)
    return
end

@inline function getImage(client)
    return jcall(client, "getImage", Vector{jbyte}, ())
end

@inline function quit(client)
    jcall(client, "quit", Cvoid, ())
    return
end

@inline function quitServer(client)
    jcall(client, "quitServer", Cvoid, ())
    return
end

@inline function goodbye(client)
    jcall(client, "goodbye", Cvoid, ())
    return
end

@inline function setAspectRatio(client, ratio)
    jcall(client, "setAspectRatio", Cvoid, (jfloat,), ratio)
    return
end

@inline function setImageFormat(client, f, gray)
    jcall(client, "setImageFormat", Cvoid, (jlong, jboolean), f, gray)
    return
end

@inline function setIrradiance(client, band, r, g, b)
    jcall(client, "setIrradiance", Cvoid, (jlong, jdouble, jdouble, jdouble), band, r, g, b)
    return
end

@inline function getIrradiance(client, band)
    return jcall(client, "getIrradiance", Vector{jdouble}, (jlong,), band)
end

@inline function getDetectorBias(client, cid)
    return jcall(client, "getDetectorBias", Vector{jdouble}, (jlong,), cid)
end

@inline function setDetectorBias(client, cid, r, g, b)
    jcall(client, "setDetectorBias", Cvoid, (jlong, jdouble, jdouble, jdouble), cid, r, g, b)
    return
end

@inline function getDetectorGain(client, cid)
    return jcall(client, "getDetectorGain", Vector{jdouble}, (jlong,), cid)
end

@inline function setDetectorGain(client, cid, r, g, b)
    jcall(client, "setDetectorGain", Cvoid, (jlong, jdouble, jdouble, jdouble), cid, r, g, b)
    return
end

@inline function getDetectorQE(client, cid)
    return jcall(client, "getDetectorQE", Vector{jdouble}, (jlong,), cid)
end

@inline function setDetectorQE(client, cid, r, g, b)
    jcall(client, "setDetectorQE", Cvoid, (jlong, jdouble, jdouble, jdouble), cid, r, g, b)
    return
end

@inline function setCameraBand(client, cid, band)
    jcall(client, "setCameraBand", Cvoid, (jlong, jlong), cid, band)
    return
end

@inline function getBandwidth(client, band)
    return jcall(client, "getBandwidth", Vector{jdouble}, (jlong,), band)
end

@inline function setSkyType(client, type)
    jcall(client, "setSkyType", Cvoid, (jint,), type)
    return
end

@inline function setSkyRGB(client, r, g, b)
    jcall(client, "setSkyRGB", Cvoid, (jfloat, jfloat, jfloat), r, g, b)
    return
end

@inline function setSkyCIE(client, x, y, z)
    jcall(client, "setSkyCIE", Cvoid, (jfloat, jfloat, jfloat), x, y, z)
    return
end

@inline function setGlobalTime(client, t)
    jcall(client, "setGlobalTime", Cvoid, (jdouble,), t)
    return
end

@inline function setSunColour(client, r, g, b)
    jcall(client, "setSunColour", Cvoid, (jfloat, jfloat, jfloat), r, g, b)
    return
end

@inline function setAmbientLight(client, r, g, b)
    jcall(client, "setAmbientLight", Cvoid, (jfloat, jfloat, jfloat), r, g, b)
    return
end

@inline function setDetectorExposure(client, cid, t)
    jcall(client, "setDetectorExposure", Cvoid, (jlong, jdouble), cid, t)
    return
end

@inline function setDetectorWellCapacity(client, cid, r, g, b)
    jcall(client, "setDetectorWellCapacity", Cvoid, (jlong, jdouble, jdouble, jdouble), cid, r, g, b)
    return
end

@inline function getDetectorWellCapacity(client, cid)
    return jcall(client, "getDetectorWellCapacity", Vector{jdouble}, (jlong,), cid)
end

@inline function setDetectorTemperature(client, cid, t)
    jcall(client, "setDetectorTemperature", Cvoid, (jlong, jdouble), cid, t)
    return
end

@inline function setFocalLength(client, cid, f)
    jcall(client, "setFocalLength", Cvoid, (jlong, jdouble), cid, f)
    return
end

@inline function setFocalAperture(client, cid, f)
    jcall(client, "setFocalAperture", Cvoid, (jlong, jdouble), cid, f)
    return
end

@inline function setProjectionMode(client, cid, mode)
    jcall(client, "setProjectionMode", Cvoid, (jlong, jlong), cid, mode)
    return
end

@inline function setFocusDistance(client, cid, d)
    jcall(client, "setFocusDistance", Cvoid, (jlong, jdouble), cid, d)
    return
end

@inline function setCameraMotion(client, cid, vx, vy, vz, rx, ry, rz, ax, ay, az, sx, sy, sz, jx, jy, jz, tx, ty, tz)
    jcall(client, "setCameraMotion", Cvoid, (jlong, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble),
        cid, vx, vy, vz, rx, ry, rz, ax, ay, az, sx, sy, sz, jx, jy, jz, tx, ty, tz)
    return
end

@inline function setStarMagnitudes(client, m)
    jcall(client, "setStarMagnitudes", Cvoid, (jdouble,), m)
    return
end

@inline function stop(client)
    jcall(client, "stop", Cvoid, ())
    return
end


@inline function printMethods(client)
    println.(JavaCall.listmethods(client))
    return
end

# void start()
# void start(int)
# java.io.DataInputStream getInputStream()
# double[] getFrame(long, long)
# void expect(int)
# java.io.DataOutputStream getOutputStream()
# byte[] echo(byte[])
# uk.ac.dundee.spacetech.pangu.ClientLibrary.ValidPoint getPoint(uk.ac.dundee.spacetech.pangu.ClientLibrary.Vector3D)
# java.util.Vector getFrames(long)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.ValidTimeTag getTimeTag()
# java.util.Vector getJoints(long)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.ValidPoint[] getPoints(uk.ac.dundee.spacetech.pangu.ClientLibrary.Vector3D[])
# byte[] getRangeImage(float, float)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.ValidElevation[] getElevations(uk.ac.dundee.spacetech.pangu.ClientLibrary.Vector3D[])
# double[] getJointConfig(long, long)
# byte[] getViewpointByQuaternionS(float, float, float, float, float, float, float)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.ValidElevation getElevation()
# uk.ac.dundee.spacetech.pangu.ClientLibrary.ValidPoint[] lookupPoints(uk.ac.dundee.spacetech.pangu.ClientLibrary.Vector2D[])
# uk.ac.dundee.spacetech.pangu.ClientLibrary.ValidPoint lookupPoint(uk.ac.dundee.spacetech.pangu.ClientLibrary.Vector2D)
# java.lang.String expectReply(int)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.LidarPulseResult getLidarPulseResult(uk.ac.dundee.spacetech.pangu.ClientLibrary.Vector3D, uk.ac.dundee.spacetech.pangu.ClientLibrary.Vector3D)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.LidarMeasurement getLidarMeasurement(float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float)
# byte[] getRangeTexture()
# uk.ac.dundee.spacetech.pangu.ClientLibrary.RadarResponse getRadarResponse(int, int, int, int, uk.ac.dundee.spacetech.pangu.ClientLibrary.Vector3D, uk.ac.dundee.spacetech.pangu.ClientLibrary.Vector3D, float, float, float, float, float, float, float, float, float)
# java.util.Vector getThermalSources(long)
# double[] getThermalAreaFactors(long)
# double[] getFrameViewpointByAngle(long, long)
# double[] getWavelength(long)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.CameraProperties getCameraProperties(long)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.LidarMeasurement getLidarMeasurementS(float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.LidarMeasurement getLidarMeasurementD(double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double)
# double[] getFrameAsRadians(long, long)
# float[][] getViewAsDEM(int, boolean, int, int, float, float, float)
# double[] getThermalSource(long, long)
# double[] getEmissionScale()
# byte[] getViewpointByFrame(long, long)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.ValidElevation getSurfaceElevation(boolean, float, float)
# float[][] getSurfacePatch(boolean, float, float, int, int, float, float)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.ValidElevation[] getSurfaceElevations(boolean, uk.ac.dundee.spacetech.pangu.ClientLibrary.Vector2D[])
# uk.ac.dundee.spacetech.pangu.ClientLibrary.ValidDouble getEventLeakRate(long)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.ValidDouble getFocalAperture(long)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.ValidDouble getFocusDistance(long)
# byte[] getEventImage(long, long, long)
# double[] getEventThresholds(long)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.ValidDouble getFocalLength(long)
# void setViewpoint(float, float, float, float, float, float)
# void setViewpoint(uk.ac.dundee.spacetech.pangu.ClientLibrary.Vector3D, float, float, float)
# void setViewpoint(float, float, float, float, float, float, float)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.ValidDouble getDetectorTemperature(long)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.ValidDouble getEventBandwidth(long)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.ValidDouble getEventResetTime(long)
# double[] getDetectorReadoutRMS(long)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.DetectorEventArray getEventArray(long)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.ValidDouble getEventDelta(long)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.ValidDouble getDetectorExposure(long)
# void setJointConfig(long, long, double[])
# void setLidarParameters(uk.ac.dundee.spacetech.pangu.ClientLibrary.LidarParameters)
# void setSecondaryByRadians(double, double, double)
# void setGlobalFogMode(long)
# void setSecondaryByDegrees(double, double, double)
# void setObjectPositionAttitude(long, double, double, double, double, double, double, double)
# void setObjectView(long, int)
# void setBoulderView(int, boolean)
# void setSurfaceView(int, boolean, boolean)
# void setCornerCubeAttitude(float, float, float, float, float, float, float, float, float, float, float, float, float)
# void setGlobalFogProperties(double, double, double, double)
# void setStarMagnitudes(double)
# void setStarQuaternion(double, double, double, double)
# void setAtmosphereMode(long, long, long)
# void setCornerCubesS(uk.ac.dundee.spacetech.pangu.ClientLibrary.CornerCube[])
# void setSecondaryPosition(double, double, double)
# void setAtmosphereTau(float, float, float, float, float, float)
# void generateEvents(long, long, long)
# void setEventDelta(long, double)
# void bindLightToCamera(long, long, boolean)
# void setThermalAreaFactors(long, double, boolean, double, boolean, double, boolean, double, boolean, double, boolean, double, boolean)
# void setWavelength(long, double, double, double)
# void setLidarScan(double[])
# void setEmissionScale(double, double, double)
# void setOrthoFieldOfView(long, double, double)
# void configureLightByRadians(long, float, float, float, float, float)
# void setLightPositionDirection(long, double, double, double, double, double, double)
# void setDetectorReadoutRMS(long, double, double, double)
# void displayHoldBuffer(int)
# void renderToHoldBuffer(long, int)
# void setBandwidth(long, double, double, double)
# void setCornerCubesD(uk.ac.dundee.spacetech.pangu.ClientLibrary.CornerCube[])
# void setThermalSource(long, long, double, boolean, double, boolean, double, boolean)
# void configureLightByDegrees(long, float, float, float, float, float)
# void setEventLeakRate(long, double)
# void setEventResetTime(long, double)
# void setEventThresholds(long, double, double, double)
# void setEventBandwidth(long, double)
