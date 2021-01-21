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

function fixroot(t::Tree)
    if isa(t, Leaf) return t end
    t.left._parent = t
    t.right._parent = t
    fixroot(t.left)
    fixroot(t.right)
    t
end

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
reroot_wo_clades = fixroot ∘ reroot_exceptchild_



function cuts(f, t :: Tree)
    if isleaf(t)
        
    else
        if (isroot(t))
            r = f(t)
            return r
        end
        f(t.left)
        f(t.right)
        if !isroot(t)
            f(reroot_exceptchild(t, t.left))
            f(reroot_exceptchild(t, t.right))
        end
        cuts(f, t.left)
        cuts(f, t.right)
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

function issingly(t)
    isset(t._clades)
end

unrooted_clades(t) = cladeat.(cuts(t))
function unrooted_clades_trees(t)
    c = cuts(t)
    zip(cladeat.(c), c)
end

function isbelow(l :: Tree, r :: Tree)
    l._clades < r._clades
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