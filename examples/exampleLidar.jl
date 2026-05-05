using PANGU
using GLMakie

# PANGU.setup(panguDir="C:/fc/software/Pangu/v8.01/", jdkDir="C:/fc/software/JavaSDK/jdk-25.0.1/")
PANGU.launchServer("-image_format_tcp raw -grey_tcp")
client = PANGU.makeConnection()
rangeImg, slopeImg = PANGU.getLidarSnapshot(client, 0, 100.0, 0.0, 800.0, 0.0, 0.0, 1.0, 0.0)


fig = Figure(); display(fig)
ax1 = Axis(fig[1, 1], aspect=DataAspect())
heatmap!(ax1, rangeImg)
ax1.yreversed = true

ax2 = Axis(fig[1, 2], aspect=DataAspect())
heatmap!(ax2, slopeImg)
ax2.yreversed = true
