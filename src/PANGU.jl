module PANGU

using JavaCall

include("api.jl")

export connectToPangu, launchPangu, getPanguImage, testPangu, PanguCamera, PanguClient
include("client.jl")

end
