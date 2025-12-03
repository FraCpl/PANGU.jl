module PANGU

using JavaCall
using Preferences

# Directories setup
include("setup.jl")

# PANGU API
include("api.jl")

# Image conversion tools
include("image.jl")

end
