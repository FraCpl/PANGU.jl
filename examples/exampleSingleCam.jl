using PANGU
using Images

# PANGU.setup(panguDir="C:/fc/software/Pangu/v8.01/", jdkDir="C:/fc/software/JavaSDK/jdk-25.0.1/")

PANGU.launchServer("-image_format_tcp raw -grey_tcp")
client = PANGU.makeConnection()
rawImage = PANGU.getViewpointByQuaternion(client, 0.0, 0.0, 1000.0, 0.0, 1.0, 0.0, 0.0)
image = PANGU.rawGrey2imageD(rawImage, 512, 512)
colorview(Gray, image)
