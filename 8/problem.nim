import typetraits, tables, sequtils, sugar, sets

let a = collect:
    for k, v in {'a': 1, 'b': 2}.toTable:
        {k: v+1}

echo a
echo a.type.name

proc foo(k: char, v: int): auto =
    (k, v+1)

let b = collect:
    for k, v in {'a': 1, 'b': 2}.toTable:
        let r = foo(k, v)
        {r[0]: r[1]}

echo b
echo b.type.name
