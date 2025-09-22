using NarrowIntegers
using Documenter

DocMeta.setdocmeta!(NarrowIntegers, :DocTestSetup, :(using NarrowIntegers); recursive=true)

makedocs(;
    modules=[NarrowIntegers],
    authors="Anton Oresten <antonoresten@proton.me> and contributors",
    sitename="NarrowIntegers.jl",
    format=Documenter.HTML(;
        canonical="https://MurrellGroup.github.io/NarrowIntegers.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/MurrellGroup/NarrowIntegers.jl",
    devbranch="main",
)
