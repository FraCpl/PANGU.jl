using PANGU
using Images

sz = [256; 1024]

PANGU.launchServer("
-image_format_tcp raw
-grey_tcp
-list_frames
-list_cameras
-dynamic_object 3 cam3 $(PANGU.campxn) 1 1 1 0 0 0 1 0 0 0 0
-link_camera 3 3 camera
-set_camera_size 3 $(sz[1]) $(sz[1]) 30 30
-detector 3 1 $(sz[1]) $(sz[1]) 0
-dynamic_object 4 cam4 $(PANGU.campxn) 1 1 1 0 0 0 1 0 0 0 0
-link_camera 4 4 camera
-set_camera_size 4 $(sz[2]) $(sz[2]) 30 30
-detector 4 1 $(sz[2]) $(sz[2]) 0
")

client = PANGU.makeConnection()

idCam = 1
PANGU.setObjectPositionAttitude(client, idCam + 2, 0.0, 0.0, 1000.0, 0.0, 1.0, 0.0, 0.0)
PANGU.selectCamera(client, idCam + 2)
rawImage = PANGU.getImage(client)
image = PANGU.rawGrey2image(rawImage, sz[idCam], sz[idCam])
colorview(Gray, image ./ typemax(eltype(image)))
