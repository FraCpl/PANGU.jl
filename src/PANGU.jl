module PANGU

using JavaCall

include("api.jl")

export connectToPangu, launchPangu, getPanguImage, testPangu
include("client.jl")

end
