include("phylo.jl")

function singly_cuts(f, t :: Tree)
    let root_clade = nothing
        function g(parent, child, root_clade)
            if issingly(root_clade - child._clades)
                f(reroot_root_clades(parent, child, root_clade))
            end
        end

        function h(t)
            if issingly(t)
                f(t)
            end
        end

        function cuts_(t :: Tree)
            if isleaf(t)

            else
                if (isroot(t))
                    root_clade = t._clades
                    h(t)
                end
                h(t.left)
                h(t.right)
                if !isroot(t)
                    g(t, t.left, root_clade)
                    g(t, t.right, root_clade)
                end
                cuts_(t.left)
                cuts_(t.right)
            end
        end
        cuts_(t)
    end
end

function istrivial(t :: Tree)
    (t._clades.data |> length) < 4
end

 function singly_cuts(t :: Tree)
    res = Tree[]
    singly_cuts(t) do s
        push!(res, s)
    end
    res
 end