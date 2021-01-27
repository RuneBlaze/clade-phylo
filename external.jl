# function parse_newick(io)
#     cont = read(io, String)
#     cont = replace(cont, r":\d+\.\d+" => "")
#     cont = replace(cont, r"_\d+_\d+" => "")
#     cont = replace(cont, r"\)\d+" => ")")
#     return parse_tuple(eval(Meta.parse(cont)))
# end

function parse_newicks(io)
    res = Tree[]
    skipws() = skipchars(isspace, io)
    skipws()
    while !eof(io)
        push!(res, parse_newick(io))
        accept(io, ';')
        skipws()
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

# function parse_newicks(io)
#     res = Tree[]
#     tree_src = readuntil(io, ";"; keep=true)
#     skipchars(isspace, io)
#     while !isempty(tree_src)
#         push!(res, parse_newick(IOBuffer(tree_src)))
#         tree_src = readuntil(io, ";"; keep=true)
#         skipchars(isspace, io)
#     end
#     res
# end

# recursive descent parser for newicks... yeah apprantly

function takenumber(io :: IO)
    buf = IOBuffer()
    x = peek(io, Char)
    while isdigit(x)
        print(buf, x)
        skip(io, 1)
        x = peek(io, Char)
    end
    return parse(Int, String(take!(buf)))
end

function skip_suffix(io :: IO)
    while peek(io, Char) == '_'
        skip(io, 1)
        takenumber(io)
    end
end

function skiplength(io :: IO)
    if peek(io, Char) == ':' # oh boy, those pesky lengths...
        skipchars(io) do ch
            ch == ':' || ch == '.' || isdigit(ch)
        end
    end
end

function accept(io :: IO, ch :: Char)
    if peek(io, Char) != ch
        throw("$(peek(io, Char)) should not occur, it should be $ch")
    end
    skip(io, 1)
end



function buildbranch(l :: Tree, r :: Tree)
    res = Branch(l, r, +(l._clades, r._clades), nothing)
    l._parent = res
    r._parent = res
    res
end

function parse_newick(io :: IO) # return a newick value
    if isdigit(peek(io, Char))
        # it is a number value
        n = takenumber(io)
        skip_suffix(io)
        skiplength(io)
        Leaf(n, Multiset([n]), nothing)
    else
        # it is a value type
        accept(io, '(')
        l = parse_newick(io)
        accept(io, ',')
        r = parse_newick(io)
        accept(io, ')')
        if isdigit(peek(io, Char))
            takenumber(io)
            skiplength(io)
        end
        skiplength(io)
        buildbranch(l, r)
    end
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
    notatetree(io, tree)
    println(io, ";")
end

function notatetree(buf :: IO, tree :: Tree)
    function f(t :: Tree)
        if isleaf(t)
            print(buf, t.value)
        else
            print(buf, '(')
            f(t.left)
            print(buf, ',')
            f(t.right)
            print(buf, ')')
        end
    end
    f(tree)
end

function notatetree(tree :: Tree)
    buf = IOBuffer()
    notatetree(buf, tree)
    take!(buf) |> String
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