function parse_newick(io)
    cont = read(io, String)
    cont = replace(cont, r":\d+\.\d+" => "")
    cont = replace(cont, r"_\d+_\d+" => "")
    cont = replace(cont, r"\)\d+" => ")")
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

# function takenumber(s :: IO)
#     buffer = IOBuffer()
#     while isdigit(peek(s, Char))
#         print(buffer, peek(s, Char))
#         skip(s, 1)
#     end
#     parse(Int, take!(buffer))
# end

# function ps(s)
#     stack = Tree[]
#     while peek(s, Char) != ';'
#         if peek(s, Char) == '('
#             skip(s, 1)
#         end
#         if peek(s, Char) == ','
#             skip(s, 1)
#         end
#         if isdigit(peek(s, Char))
#             push!(stack, Leaf(takenumber(s), Multiset([tup]), nothing))
#         end
#         if peek(s, Char) == ')'
#             a = pop!(stack)
#             b = pop!(stack)
#             res = Branch(a, b, l._clades + r._clades, nothing)
#             a._parent = res
#             b._parent = res
#             push!(stack, res)
#             skip(s, 1)
#         end
#     end
#     stack
# end

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

newick = parse_tuple

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