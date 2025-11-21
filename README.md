# PANGU.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://FraCpl.github.io/PANGU.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://FraCpl.github.io/PANGU.jl/dev/)
<!-- [![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle) -->

An unofficial (work in progress) Julia interface for [PANGU](https://pangu.software/). 

After loading the package for the very first time, setup the required directories by executing:

```julia
using PANGU
PANGU.setup(panguDir="your/path/to/Pangu/v8.01/", javasdkDir="your/path/to/JavaSDK/jdk-25.0.1/")
```

The following commands can be run to obtain a sample image:
```julia
using PANGU
using Images

PANGU.launchServer("-image_format_tcp raw -grey_tcp")
client = PANGU.makeConnection()
rawImage = PANGU.getViewpointByQuaternion(client, 0.0, 0.0, 1000.0, 0.0, 1.0, 0.0, 0.0)
image = PANGU.rawGrey2image(rawImage, 512, 512)
colorview(Gray, image ./ 255)
```