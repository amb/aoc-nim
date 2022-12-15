

# Create KD-tree from data
proc manhattanKD(x, y: KdPoint): float = abs(x[0]-y[0])+abs(x[1]-y[1])
var tree = newKDTree[Vec2i](beacons.mapIt(it.asFloatArray), beacons, distFunc=manhattanKD)

# Check everything is good
for si, s in sensors:
    let treeres = tree.nearestNeighbour([s.location.x.float, s.location.y.float])
    assert treeres[1] == beacons[si]
    assert treeres[2].int == s.area
