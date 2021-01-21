#!/usr/bin/env julia

doc = """extract_mclade.jl: extracts maximum unrooted clades and the induced trees from mul-trees

Usage:
    extract_mclade.jl <gene_trees> [<out>]

Options:
    -h --help   Show this screen.
"""

include("phylo.jl")
include("external.jl")

using DocOpt
args = docopt(doc)
inpath = args["<gene_trees>"]
outpath = isnothing(args["<out>"]) ? inpath : args["<out>"]

gene_trees = parse_newicks(open(inpath))
singly_trees = Set{Tree}()
for gt in gene_trees
    for t=subtrees(gt)
        if issingly(t)
            push!(singly_trees, t)
        end
    end
end
maximal_trees = sort(
    collect(maximal_elements(collect(singly_trees)));
    by=it -> length(it._clades)
)
open(outpath * ".maximal.tre", "w+") do f
    writetrees(f, maximal_trees)
end

open(outpath * ".maximal.clades", "w+") do f
    for t in maximal_trees
        println(f, t._clades)
    end
end