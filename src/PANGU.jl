module PANGU

using JavaCall

include("api.jl")

export launchPangu, getPanguImage, PanguCamera, PanguClient
include("client.jl")

end
