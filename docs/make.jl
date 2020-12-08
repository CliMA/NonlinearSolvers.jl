using NonlinearSolvers, Documenter

pages = Any["Home" => "index.md", "API" => "API.md"]

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
    sitename = "NonlinearSolvers.jl",
    doctest = true,
    strict = true,
    format = format,
    clean = true,
    checkdocs = :exports,
    modules = [NonlinearSolvers],
    pages = pages,
)

deploydocs(
    repo = "github.com/CliMA/NonlinearSolvers.jl.git",
    target = "build",
    push_preview = true,
)
