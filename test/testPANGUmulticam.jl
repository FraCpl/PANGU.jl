using PANGU
using Images

# PANGU.setup(panguDir="C:/fc/software/Pangu/v8.01/", javasdkDir="C:/fc/software/JavaSDK/jdk-25.0.1/")
s = [512; 1024]

PANGU.launchServer("-image_format_tcp raw -grey_tcp -use_camera_model -use_detector_size -detector 0 1 10 10 0 -detector 1 1 $(s[1]) $(s[1]) 0 -detector 2 1 $(s[2]) $(s[2]) 0")
client = PANGU.makeConnection()

idCam = 2
PANGU.selectCamera(client, idCam)
PANGU.setViewpointByQuaternion(client, 0.0, 0.0, 6000.0, 0.0, 1.0, 0.0, 0.0)
rawImage = PANGU.getImage(client)
image = PANGU.rawGrey2image(rawImage, s[idCam], s[idCam])
colorview(Gray, image ./ 255)
