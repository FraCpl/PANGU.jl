using PANGU
using Images

cams = PanguCamera()
launchPangu(cams)

# Make sure PANGU is open before launching the following commands
p = PanguClient(cams)

posWS_W = [0.0, 0.0, 1000.0]
q_WS = [0.0; 1.0; 0.0; 0.0]
img1 = getPanguImage(p, posWS_W, q_WS, 1.49e11, 0.0, π / 8, 1)
colorview(Gray, img1 ./ 255)
