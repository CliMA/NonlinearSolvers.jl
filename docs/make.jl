using NLSolvers, Documenter

pages = Any[
    "Home" => "index.md",
    "API" => "API.md",
]

mathengine = MathJax(Dict(
    :TeX => Dict(
        :equationNumbers => Dict(:autoNumber => "AMS"),
        :Macros => Dict(),
    ),
))

format = Documenter.HTML(
    prettyurls = get(ENV, "CI", nothing) == "true",
    mathengine = mathengine,
    collapselevel = 1,
)

makedocs(
    sitename = "NLSolvers.jl",
    doctest = true,
    strict = true,
    format = format,
    clean = true,
    modules = [NLSolvers],
    pages = pages,
)

deploydocs(
    repo = "github.com/CliMA/NLSolvers.jl.git",
    target = "build",
    push_preview = true,
)

