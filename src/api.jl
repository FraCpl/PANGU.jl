@inline function selectCamera(client, camID)
    jcall(client, "selectCamera", Cvoid, (JavaCall.jlong,), camID)
    return
end

@inline function setFieldOfViewByRadians(client, fov)
    jcall(client, "setFieldOfViewByRadians", Cvoid, (JavaCall.jfloat,), fov)
    return
end

@inline function setSunByRadians(client, distSun, azSun, elSun)
    jcall(client, "setSunByRadians", Cvoid, (jdouble, jdouble, jdouble), distSun, azSun, elSun)
    return
end

@inline function getViewpointByQuaternionD(client, x, y, z, qs, qx, qy, qz)
    return jcall(client, "getViewpointByQuaternionD", Vector{jbyte}, (jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble), x, y, z, qs, qx, qy, qz)
end

@inline function setViewpointByQuaternion(client, x, y, z, qs, qx, qy, qz)
    jcall(client, "setViewpointByQuaternion", Cvoid, (jdouble, jdouble, jdouble, jdouble, jdouble, jdouble, jdouble), x, y, z, qs, qx, qy, qz)
    return
end

@inline function getImage(client)
    return jcall(client, "getImage",  Vector{jbyte}, ())
end
