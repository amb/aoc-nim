import typetraits, tables, sequtils, sugar

let a = collect:
    for k, v in {'a': 1, 'b': 2}.toTable:
        {k: v+1}

echo a
echo a.type.name

proc foo(k: char, v: int): array[0..0, (char, int)] =
    {k: v+1}

let b = collect:
    for k, v in {'a': 1, 'b': 2}.toTable:
        foo(k, v)

echo b
echo b.type.name
