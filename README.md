clade-phylo
============

## `extract_mclade.jl`

```
extract_mclade.jl: extracts maximum unrooted clades and the induced trees from mul-trees

Usage:
    extract_mclade.jl <gene_trees> [<out>]
```

Input: mul-trees t[1] ... t[n] in a single file where labels are integers, in Newick format. To accomodate SimPhy, labels in the format of "x_y_z" are taken to be simply "x".

Output: the maximal elements (by proper subset) of the singly labeled clades generated by some unrooted subtree of some `t`, along with
the trees that generated these clades.


### Examples

```bash
julia extract_mclade.jl examples/g_trees.tre
```

## Requirements

This is written in Julia (unfortunately not Python, and AFAIK school clusters don't
have Julia). Install Julia 1.5 and install the following packages

```
DocOpt, Multisets, Combinatorics, DataStructures
```

Or run the following in the Julia repl to install
```julia
using Pkg
for pkg = ["DocOpt", "Multisets", "Combinatorics", "DataStructures"]
  Pkg.add(pkg)
end
```