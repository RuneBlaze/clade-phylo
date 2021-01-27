include("kitchen.jl")
function leafset(t)
    if isa(t, Int)
        return Multiset([t])
    else
        return reduce(+, map(leafset, t))
    end
end

using DocOpt

doc = """validate.jl

Usage:
    validate.jl <trees>

Options:
    -h --help   Show this screen.
"""
args = docopt(doc)
inpath = args["<trees>"]

newicks = eval.(Meta.parse.(readlines(inpath)))
@show issingly.(leafset.(newicks))
function derr(l, r)
    "$l has a clade that is smaller than $(r)!" |> println
    "  by $(leafset(l)) being smaller than $(leafset(r))" |> println
end

for (l, r) in combinations(newicks, 2)
    if leafset(l) < leafset(r)
        derr(l, r)
    end

    if leafset(l) > leafset(r)
        derr(r, l)
    end
end