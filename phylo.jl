using Multisets
using Combinatorics
using DataStructures

abstract type Tree end

mutable struct Branch <: Tree
    left :: Union{Tree,Nothing}
    right :: Union{Tree, Nothing}
    _clades :: Multiset{Int}
    _parent :: Union{Tree, Nothing}
end

mutable struct Leaf <: Tree
    value :: Int
    _clades :: Multiset{Int}
    _parent :: Union{Tree, Nothing}
end

isroot(t) = isnothing(t._parent)
isleaf(x) = isa(x, Leaf)

function Base.show(io::IO, t::Tree)
    print(io, "Rooted[$(bintree2newick(t));]")
end

function Base.:(==)(x :: Tree, y :: Tree)
    if (isleaf(x))
        isleaf(y) && y.value == x.value
    elseif isleaf(y)
        isleaf(x) && x.value == y.value
    else
        (x.left == y.left && x.right == y.right) || (x.left == y.right && x.right == y.left)
    end
end

function Base.hash(x :: Tree, h :: UInt)
    if isleaf(x)
        return hash(x.value, h)
    else
        return hash(hash((x.left, x.right), h) + hash((x.right, x.left), h), h)
    end
end

# reroot at node t by a cut between t and barring
function reroot_exceptchild_(t::Branch, barring::Tree)
    otherchild(t, barring) = t.left == barring ? t.right : t.left
    if isroot(t)
        return otherchild(t, barring)
    else
        oc = otherchild(t, barring)
        rerooted = reroot_exceptchild_(t._parent, t)
        return Branch(oc, rerooted, Multiset{Int}(), nothing)
    end
end

function fixroot_(t::Tree)
    if isa(t, Leaf) return t end
    t.left._parent = t
    t.right._parent = t
    fixroot_(t.left)
    fixroot_(t.right)
    t
end

function destroy_root(t :: Tree)
    t._parent = nothing
    t
end

fixroot = destroy_root ∘ fixroot_

function fixclades(t::Tree)
    if isa(t, Leaf)
        t._clades = Multiset([t.value])
    else
        fixclades(t.left)
        fixclades(t.right)
        t._clades = t.left._clades + t.right._clades
    end
    t
end

reroot_exceptchild = fixclades ∘ fixroot ∘ reroot_exceptchild_

function reroot_root_clades(t :: Branch, barring :: Tree, root_clades :: Multiset{Int})
    tre_wo_clades = reroot_exceptchild_(t, barring) |> fixroot
    tre_wo_clades._clades = root_clades - barring._clades
    tre_wo_clades
end

function cuts(f, t :: Tree)
    let root_clade = nothing
        function cuts_(f, t :: Tree)
            if isleaf(t)

            else
                if (isroot(t))
                    root_clade = t._clades
                    f(t)
                end
                f(t.left)
                f(t.right)
                if !isroot(t)
                    f(reroot_root_clades(t, t.left, root_clade))
                    f(reroot_root_clades(t, t.right, root_clade))
                end
                cuts_(f, t.left)
                cuts_(f, t.right)
            end
        end
        cuts_(f, t)
    end
end

function cladeat(t :: Tree)
    t._clades
end

function cuts(t :: Tree)
    res = Tree[]
    cuts(t) do s
        push!(res, s)
    end
    res
end

function clade_induced_trees(tre, f)
    f(tre._clades)
end

function isset(M :: Multiset{T}) where {T}
    all(M.data[x] <= 1 for x in keys(M.data))
end

function issingly(t :: Tree)
    isset(t._clades)
end

function issingly(t :: Multiset{Int})
    isset(t)
end

unrooted_subtrees = cuts
subtrees = unrooted_subtrees
unrooted_clades(t) = cladeat.(cuts(t))
clades = unrooted_clades

function unrooted_clades_trees(t)
    c = cuts(t)
    zip(cladeat.(c), c)
end

function isbelow(l :: Tree, r :: Tree)
    l._clades < r._clades
end

function issinglysubtree(l :: Tree)
    if isleaf(l) return false end
    if isnothing(l._parent) return false end
    if issingly(l._parent)
        return true
    end
    return false
end


function maximal_elements(coll, rel=isbelow)
    outdegs = Set()
    for (l, r) in combinations(coll, 2)
        if rel(l, r)
            # then l points to r
            push!(outdegs,l)
        end
        if rel(r, l)
            push!(outdegs,r)
        end
    end
    setdiff(Set(coll), outdegs)
end