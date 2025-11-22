module PANGU

using JavaCall
using Preferences

# Directories setup
include("setup.jl")

# PANGU API
include("api.jl")

# Image conversion tools
include("image.jl")

const campxn::String = "'"*replace(dirname(pathof(@__MODULE__)), "\\" => "/")*"/camera.pxn'"

end
