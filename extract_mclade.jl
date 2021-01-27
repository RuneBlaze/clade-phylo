#!/usr/bin/env julia

doc = """extract_mclade.jl: extracts maximum unrooted clades and the induced trees from mul-trees

Usage:
    extract_mclade.jl <gene_trees> [<out>]

Options:
    -h --help   Show this screen.
"""

include("phylo.jl")
include("external.jl")
include("phylo_extra.jl")

using DocOpt
args = docopt(doc)
inpath = args["<gene_trees>"]
outpath = isnothing(args["<out>"]) ? inpath : args["<out>"]

gene_trees = parse_newicks(open(inpath))

maximal_trees = Tree[]
for (i, gt) in enumerate(gene_trees)

    singly_trees = Tree[]
    for t=singly_cuts(gt)
        if !istrivial(t) && !issinglysubtree(t)
            push!(singly_trees, t)
        end
    end
    mt = sort(collect(maximal_elements(collect(singly_trees)));　by=it -> length(it._clades))
    append!(maximal_trees, mt)
end

open(outpath * ".maximal.tre", "w+") do f
    writetrees(f, maximal_trees)
end

open(outpath * ".maximal.clades", "w+") do f
    for t in maximal_trees
        println(f, t._clades)
    end
end