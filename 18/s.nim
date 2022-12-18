include ../aoc
let cb = "18/input".readFile.split.mapIt(it.ints.cubecoord).toHashSet
echo "Part 1: ", cb.len*6 - CUBEDIRS.mapIt(((cb + it) & cb).len).sum
echo "Part 2: ", cb.throwNet(ic => CUBEDIRS.mapIt(((ic + it) & cb).len).sum).toSeq.sum

# 4192
# 2520