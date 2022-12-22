include ../aoc
let cb = "18/input".readFile.split.mapIt(it.ints.coord3d).toHashSet
echo "Part 1: ", cb.len*6 - Coords3D.faces.mapIt(((cb + it) & cb).len).sum
echo "Part 2: ", cb.throwNet(ic => Coords3D.faces.mapIt(((ic + it) & cb).len).sum).toSeq.sum

# 4192
# 2520