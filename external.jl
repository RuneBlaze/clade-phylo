function parse_newick(io)
    cont = read(io, String)
    cont = replace(cont, r":\d+\.\d+" => "")
    cont = replace(cont, r"_\d+_\d+" => "")
    return parse_tuple(eval(Meta.parse(cont)))
end

function parse_newicks(io)
    res = Tree[]
    tree_src = readuntil(io, ";"; keep=true)
    skipchars(isspace, io)
    while !isempty(tree_src)
        push!(res, parse_newick(IOBuffer(tree_src)))
        tree_src = readuntil(io, ";"; keep=true)
        skipchars(isspace, io)
    end
    res
end

function parse_tuple(tup)
    if isa(tup, Int)
        Leaf(tup, Multiset([tup]), nothing)
    else
        l = parse_tuple(tup[1])
        r = parse_tuple(tup[2])
        res = Branch(l, r, +(l._clades, r._clades), nothing)
        l._parent = res
        r._parent = res
        res
    end
end

function writetree(io::IO, tree :: Tree)
    buf = IOBuffer()
    print(buf, bintree2newick(tree))
    print(io, replace(String(take!(buf)), " " => ""))
    println(io, ";")
end

function writetrees(io :: IO, trees)
    for t in trees
        writetree(io, t)
    end
end

function bintree2newick(t)
    if isa(t, Branch)
        (bintree2newick(t.left), bintree2newick(t.right))
    else
        t.value
    end
end