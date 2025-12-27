# Launch PANGU in server mode
@inline function launchServer(args::String="", port::Int=10363; rmlogs=true)
    # Check if setup has been done or not
    if isnothing(panguDir()) || isnothing(javasdkDir())
        @error "PANGU has not been setup properly. Please launch 'setupPangu(panguDir=..., javasdkDir=...)' and retry"
        return nothing
    end

    # Check if PANGU is already running
    if occursin("viewer.exe", read(`tasklist /FI "IMAGENAME eq viewer.exe"`, String))
        @warn "PANGU is already running"
        return nothing
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
    run(`$(Base.shell_split(cmdStr))`, wait=false)
    return nothing
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
    return jcall(client, "selectCamera", Cvoid, (JavaCall.jlong,), cid)
end

@inline function setFieldOfViewByRadians(client, fov)
    return jcall(client, "setFieldOfViewByRadians", Cvoid, (JavaCall.jfloat,), fov)
end

@inline function setFieldOfViewByDegrees(client, fov)
    return jcall(client, "setFieldOfViewByDegrees", Cvoid, (JavaCall.jfloat,), fov)
end

@inline function setSunByRadians(client, r, azi, ele)
    return jcall(client, "setSunByRadians", Cvoid, (jdouble, jdouble, jdouble), r, azi, ele)
end

@inline function setSunByDegrees(client, r, azi, ele)
    return jcall(client, "setSunByDegrees", Cvoid, (jdouble, jdouble, jdouble), r, azi, ele)
end

@inline function getViewpointByCamera(client, cid)
    return jcall(client, "getViewpointByCamera", Vector{jbyte}, (jlong,), cid)
end

@inline function getViewpointByQuaternion(client, x, y, z, q0, qx, qy, qz)
    return jcall(
        client, "getViewpointByQuaternionD", Vector{jbyte}, (jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble), x, y, z, q0, qx, qy, qz
    )
end

@inline function getViewpointByQuaternionD(client, x, y, z, q0, qx, qy, qz)
    return jcall(
        client, "getViewpointByQuaternionD", Vector{jbyte}, (jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble), x, y, z, q0, qx, qy, qz
    )
end

@inline function setViewpointByQuaternion(client, pos, q)
    x, y, z = pos
    q0, qx, qy, qz = q
    return jcall(client, "setViewpointByQuaternion", Cvoid, (jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble), x, y, z, q0, qx, qy, qz)
end

@inline function setViewpointByQuaternion(client, x, y, z, q0, qx, qy, qz)
    return jcall(client, "setViewpointByQuaternion", Cvoid, (jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble), x, y, z, q0, qx, qy, qz)
end

@inline function getViewpointByDegreesD(client, x, y, z, yaw, pitch, roll)
    return jcall(
        client, "getViewpointByDegreesD", Vector{jbyte}, (jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble), x, y, z, yaw, pitch, roll
    )
end

@inline function getViewpointByRadians(client, x, y, z, yaw, pitch, roll)
    return jcall(
        client, "getViewpointByRadians", Vector{jbyte}, (jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble), x, y, z, yaw, pitch, roll
    )
end

@inline function getViewpointByFrame(client, oid, fid)
    return jcall(client, "getViewpointByFrame", Vector{jbyte}, (jlong, jlong), oid, fid)
end

@inline function setViewpointByQuaternionD(client, x, y, z, q0, qx, qy, qz)
    return jcall(client, "setViewpointByQuaternionD", Cvoid, (jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble), x, y, z, q0, qx, qy, qz)
end

@inline function setViewpointByDegrees(client, x, y, z, yaw, pitch, roll)
    return jcall(client, "setViewpointByDegrees", Cvoid, (jdouble, jdouble, jdouble, jdouble, jdouble, jdouble), x, y, z, yaw, pitch, roll)
end

@inline function setViewpointByDegreesD(client, x, y, z, yaw, pitch, roll)
    return jcall(client, "setViewpointByDegreesD", Cvoid, (jdouble, jdouble, jdouble, jdouble, jdouble, jdouble), x, y, z, yaw, pitch, roll)
end

@inline function setViewpointByRadians(client, x, y, z, yaw, pitch, roll)
    return jcall(client, "setViewpointByRadians", Cvoid, (jdouble, jdouble, jdouble, jdouble, jdouble, jdouble), x, y, z, yaw, pitch, roll)
end

@inline function getImage(client)
    return jcall(client, "getImage", Vector{jbyte}, ())
end

@inline function getRangeTexture(client)
    return jcall(client, "getRangeTexture", Vector{jbyte}, ())
end

@inline function getRangeImage(client, offset, scale)
    return jcall(client, "getRangeImage", Vector{jbyte}, (jfloat, jfloat), offset, scale)
end

@inline function quit(client)
    return jcall(client, "quit", Cvoid, ())
end

@inline function quitServer(client)
    return jcall(client, "quitServer", Cvoid, ())
end

@inline function goodbye(client)
    return jcall(client, "goodbye", Cvoid, ())
end

@inline function setAspectRatio(client, ratio)
    return jcall(client, "setAspectRatio", Cvoid, (jfloat,), ratio)
end

@inline function setImageFormat(client, f, gray)
    return jcall(client, "setImageFormat", Cvoid, (jlong, jboolean), f, gray)
end

@inline function setIrradiance(client, band, r, g, b)
    return jcall(client, "setIrradiance", Cvoid, (jlong, jdouble, jdouble, jdouble), band, r, g, b)
end

@inline function getIrradiance(client, band)
    return jcall(client, "getIrradiance", Vector{jdouble}, (jlong,), band)
end

@inline function getDetectorBias(client, cid)
    return jcall(client, "getDetectorBias", Vector{jdouble}, (jlong,), cid)
end

@inline function setDetectorBias(client, cid, r, g, b)
    return jcall(client, "setDetectorBias", Cvoid, (jlong, jdouble, jdouble, jdouble), cid, r, g, b)
end

@inline function getDetectorGain(client, cid)
    return jcall(client, "getDetectorGain", Vector{jdouble}, (jlong,), cid)
end

@inline function setDetectorGain(client, cid, r, g, b)
    return jcall(client, "setDetectorGain", Cvoid, (jlong, jdouble, jdouble, jdouble), cid, r, g, b)
end

@inline function getDetectorQE(client, cid)
    return jcall(client, "getDetectorQE", Vector{jdouble}, (jlong,), cid)
end

@inline function setDetectorQE(client, cid, r, g, b)
    return jcall(client, "setDetectorQE", Cvoid, (jlong, jdouble, jdouble, jdouble), cid, r, g, b)
end

@inline function setCameraBand(client, cid, band)
    return jcall(client, "setCameraBand", Cvoid, (jlong, jlong), cid, band)
end

@inline function setBandwidth(client, band, r, g, b)
    return jcall(client, "setBandwidth", Cvoid, (jlong, jdouble, jdouble, jdouble), band, r, g, b)
end

@inline function getBandwidth(client, band)
    return jcall(client, "getBandwidth", Vector{jdouble}, (jlong,), band)
end

@inline function setSkyType(client, type)
    return jcall(client, "setSkyType", Cvoid, (jint,), type)
end

@inline function setSkyRGB(client, r, g, b)
    return jcall(client, "setSkyRGB", Cvoid, (jfloat, jfloat, jfloat), r, g, b)
end

@inline function setSkyCIE(client, x, y, z)
    return jcall(client, "setSkyCIE", Cvoid, (jfloat, jfloat, jfloat), x, y, z)
end

@inline function setGlobalTime(client, t)
    return jcall(client, "setGlobalTime", Cvoid, (jdouble,), t)
end

@inline function setSunColour(client, r, g, b)
    return jcall(client, "setSunColour", Cvoid, (jfloat, jfloat, jfloat), r, g, b)
end

@inline function setAmbientLight(client, r, g, b)
    return jcall(client, "setAmbientLight", Cvoid, (jfloat, jfloat, jfloat), r, g, b)
end

@inline function setDetectorExposure(client, cid, t)
    return jcall(client, "setDetectorExposure", Cvoid, (jlong, jdouble), cid, t)
end

@inline function setDetectorWellCapacity(client, cid, r, g, b)
    return jcall(client, "setDetectorWellCapacity", Cvoid, (jlong, jdouble, jdouble, jdouble), cid, r, g, b)
end

@inline function getDetectorWellCapacity(client, cid)
    return jcall(client, "getDetectorWellCapacity", Vector{jdouble}, (jlong,), cid)
end

@inline function getWavelength(client, band)
    return jcall(client, "getWavelength", Vector{jdouble}, (jlong,), band)
end

@inline function setDetectorTemperature(client, cid, t)
    return jcall(client, "setDetectorTemperature", Cvoid, (jlong, jdouble), cid, t)
end

@inline function setDetectorReadoutRMS(client, cid, r, g, b)
    return jcall(client, "setDetectorReadoutRMS", Cvoid, (jlong, jdouble, jdouble, jdouble), cid, r, g, b)
end

@inline function getDetectorReadoutRMS(client, cid)
    return jcall(client, "getDetectorReadoutRMS", Vector{jdouble}, (jlong,), cid)
end

@inline function setFocalLength(client, cid, f)
    return jcall(client, "setFocalLength", Cvoid, (jlong, jdouble), cid, f)
end

@inline function setFocalAperture(client, cid, f)
    return jcall(client, "setFocalAperture", Cvoid, (jlong, jdouble), cid, f)
end

@inline function setProjectionMode(client, cid, mode)
    return jcall(client, "setProjectionMode", Cvoid, (jlong, jlong), cid, mode)
end

@inline function setFocusDistance(client, cid, d)
    return jcall(client, "setFocusDistance", Cvoid, (jlong, jdouble), cid, d)
end

@inline function setCameraMotion(client, cid, vx, vy, vz, rx, ry, rz, ax, ay, az, sx, sy, sz, jx, jy, jz, tx, ty, tz)
    return jcall(
        client,
        "setCameraMotion",
        Cvoid,
        (
            jlong,
            jdouble,
            jdouble,
            jdouble,
            jdouble,
            jdouble,
            jdouble,
            jdouble,
            jdouble,
            jdouble,
            jdouble,
            jdouble,
            jdouble,
            jdouble,
            jdouble,
            jdouble,
            jdouble,
            jdouble,
            jdouble,
        ),
        cid,
        vx,
        vy,
        vz,
        rx,
        ry,
        rz,
        ax,
        ay,
        az,
        sx,
        sy,
        sz,
        jx,
        jy,
        jz,
        tx,
        ty,
        tz,
    )
end

@inline function setStarMagnitudes(client, m)
    return jcall(client, "setStarMagnitudes", Cvoid, (jdouble,), m)
end

@inline function setAtmosphereMode(client, smode, gmode, amode)
    return jcall(client, "setAtmosphereMode", Cvoid, (jlong, jlong, jlong), smode, gmode, amode)
end

@inline function setStarQuaternion(client, q0, qx, qy, qz)
    return jcall(client, "setAtmosphereMode", Cvoid, (jdouble, jdouble, jdouble, jdouble), q0, qx, qy, qz)
end

@inline function setWavelength(client, band, r, g, b)
    return jcall(client, "setWavelength", Cvoid, (jlong, jdouble, jdouble, jdouble), band, r, g, b)
end

@inline function setSecondaryByRadians(client, r, azi, ele)
    return jcall(client, "setSecondaryByRadians", Cvoid, (jdouble, jdouble, jdouble), r, azi, ele)
end

@inline function setSecondaryByDegrees(client, r, azi, ele)
    return jcall(client, "setSecondaryByDegrees", Cvoid, (jdouble, jdouble, jdouble), r, azi, ele)
end

@inline function setGlobalFogMode(client, type)
    return jcall(client, "setGlobalFogMode", Cvoid, (jlong,), type)
end

@inline function setAtmosphereTau(client, mie_r, mie_g, mie_b, ray_r, ray_g, ray_b)
    return jcall(client, "setAtmosphereTau", Cvoid, (jfloat, jfloat, jfloat, jfloat, jfloat, jfloat), mie_r, mie_g, mie_b, ray_r, ray_g, ray_b)
end

@inline function setObjectPositionAttitude(client, n, x, y, z, q0, qx, qy, qz)
    return jcall(
        client, "setObjectPositionAttitude", Cvoid, (jlong, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble), n, x, y, z, q0, qx, qy, qz
    )
end

@inline function setObjectPositionAttitude(client, n, pos, q)
    x, y, z = pos
    q0, qx, qy, qz = q
    return setObjectPositionAttitude(client, n, x, y, z, q0, qx, qy, qz)
end

@inline function setObjectView(client, oid, type)
    return jcall(client, "setObjectView", Cvoid, (jlong, jlong), oid, type)
end

@inline function getFrameAsRadians(client, obj, frame)
    return jcall(client, "getFrameAsRadians", Vector{jdouble}, (jlong, jlong), obj, frame)
end

@inline function bindLightToCamera(client, res, cid, ena)
    return jcall(client, "bindLightToCamera", Cvoid, (jlong, jlong, jboolean), res, cid, ena)
end

@inline function setEmissionScale(client, r, g, b)
    return jcall(client, "setEmissionScale", Cvoid, (jdouble, jdouble, jdouble), r, g, b)
end

@inline function setOrthoFieldOfView(client, cid, w, h)
    return jcall(client, "setOrthoFieldOfView", Cvoid, (jlong, jdouble, jdouble), cid, w, h)
end

@inline function setBoulderView(client, type, texture)
    return jcall(client, "setBoulderView", Cvoid, (jint, jboolean), type, texture)
end

@inline function setSurfaceView(client, type, texture, detail)
    return jcall(client, "setSurfaceView", Cvoid, (jint, jboolean, jboolean), type, texture, detail)
end

@inline function setLightPositionDirection(client, res, px, py, pz, dx, dy, dz)
    return jcall(client, "setLightPositionDirection", Cvoid, (jlong, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble), 0, px, py, pz, dx, dy, dz)
end

@inline function configureLightByRadians(client, res, r, g, b, h, e)
    return jcall(client, "configureLightByRadians", Cvoid, (jlong, jfloat, jfloat, jfloat, jfloat, jfloat), 0, r, g, b, h, e)
end

@inline function configureLightByDegrees(client, res, r, g, b, h, e)
    return jcall(client, "configureLightByDegrees", Cvoid, (jlong, jfloat, jfloat, jfloat, jfloat, jfloat), 0, r, g, b, h, e)
end

@inline function getEmissionScale(client)
    return jcall(client, "getEmissionScale", Vector{jdouble}, ())
end

@inline function getThermalSource(client, obj, hid)
    return jcall(client, "getThermalSource", Vector{jdouble}, (jlong, jlong), obj, hid)
end

@inline function getThermalAreaFactors(client, obj)
    return jcall(client, "getThermalAreaFactors", Vector{jdouble}, (jlong,), obj)
end

# @inline function setThermalSource(client, obj, hid) # DOES NOT CORRESPOND TO MANUAL!
#     return jcall(client, "setThermalSource", Cvoid, (jlong, jlong, jdouble, jboolean, jdouble, jboolean, jdouble, jboolean), obj, hid)
# end
# void setThermalSource(long, long, double, boolean, double, boolean, double, boolean)

@inline function getFrame(client, obj, frame)
    return jcall(client, "getFrame", Vector{jdouble}, (jlong, jlong), obj, long)
end

@inline function stop(client)
    return jcall(client, "stop", Cvoid, ())
end

@inline function printMethods(client)
    println.(JavaCall.listmethods(client))
    return nothing
end

# void expect(int)
# java.io.DataOutputStream getOutputStream()
# byte[] echo(byte[])
# uk.ac.dundee.spacetech.pangu.ClientLibrary.ValidPoint getPoint(uk.ac.dundee.spacetech.pangu.ClientLibrary.Vector3D)
# java.util.Vector getFrames(long)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.ValidTimeTag getTimeTag()
# java.util.Vector getJoints(long)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.ValidPoint[] getPoints(uk.ac.dundee.spacetech.pangu.ClientLibrary.Vector3D[])
# uk.ac.dundee.spacetech.pangu.ClientLibrary.ValidElevation[] getElevations(uk.ac.dundee.spacetech.pangu.ClientLibrary.Vector3D[])
# double[] getJointConfig(long, long)
# byte[] getViewpointByQuaternionS(float, float, float, float, float, float, float)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.ValidElevation getElevation()
# uk.ac.dundee.spacetech.pangu.ClientLibrary.ValidPoint[] lookupPoints(uk.ac.dundee.spacetech.pangu.ClientLibrary.Vector2D[])
# uk.ac.dundee.spacetech.pangu.ClientLibrary.ValidPoint lookupPoint(uk.ac.dundee.spacetech.pangu.ClientLibrary.Vector2D)
# java.lang.String expectReply(int)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.LidarPulseResult getLidarPulseResult(uk.ac.dundee.spacetech.pangu.ClientLibrary.Vector3D, uk.ac.dundee.spacetech.pangu.ClientLibrary.Vector3D)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.LidarMeasurement getLidarMeasurement(float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.RadarResponse getRadarResponse(int, int, int, int, uk.ac.dundee.spacetech.pangu.ClientLibrary.Vector3D, uk.ac.dundee.spacetech.pangu.ClientLibrary.Vector3D, float, float, float, float, float, float, float, float, float)
# java.util.Vector getThermalSources(long)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.CameraProperties getCameraProperties(long)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.LidarMeasurement getLidarMeasurementS(float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float, float)
# uk.ac.dundee.spacetech.pangu.ClientLibrary.LidarMeasurement getLidarMeasurementD(double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double, double)
# float[][] getViewAsDEM(int, boolean, int, int, float, float, float)
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
# void setCornerCubeAttitude(float, float, float, float, float, float, float, float, float, float, float, float, float)
# void setGlobalFogProperties(double, double, double, double)
# void setCornerCubesS(uk.ac.dundee.spacetech.pangu.ClientLibrary.CornerCube[])
# void generateEvents(long, long, long)
# void setEventDelta(long, double)
# void setThermalAreaFactors(long, double, boolean, double, boolean, double, boolean, double, boolean, double, boolean, double, boolean)
# void setLidarScan(double[])
# void displayHoldBuffer(int)
# void renderToHoldBuffer(long, int)
# void setCornerCubesD(uk.ac.dundee.spacetech.pangu.ClientLibrary.CornerCube[])
# void setEventLeakRate(long, double)
# void setEventResetTime(long, double)
# void setEventThresholds(long, double, double, double)
# void setEventBandwidth(long, double)
