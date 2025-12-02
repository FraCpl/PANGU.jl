using PANGU
using Documenter

DocMeta.setdocmeta!(PANGU, :DocTestSetup, :(using PANGU); recursive = true)

makedocs(;
    modules = [PANGU],
    authors = "F. Capolupo",
    sitename = "PANGU.jl",
    format = Documenter.HTML(;
        canonical = "https://FraCpl.github.io/PANGU.jl",
        edit_link = "master",
        assets = String[],
    ),
    pages = ["Home" => "index.md"],
)

deploydocs(; repo = "github.com/FraCpl/PANGU.jl", devbranch = "master")
