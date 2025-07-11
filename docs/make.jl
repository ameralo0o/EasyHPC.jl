using Documenter
using EasyHPC

makedocs(
    sitename="EasyHPC.jl",
    modules=[EasyHPC],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
        "API Reference" => "api.md"
    ]
)


deploydocs(
    repo="github.com/ameralo0o/EasyHPC.jl"
)
