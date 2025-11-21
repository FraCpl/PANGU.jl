module PANGU

using JavaCall
using Preferences

export setupPangu
include("setup.jl")

export launchPangu, makeConnection
include("api.jl")

export PanguClient, PanguCamera, getPanguImage
include("client.jl")

include("image.jl")

end
