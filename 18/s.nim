include ../aoc

let cubes = "18/input".readFile.split.mapIt(it.ints).mapIt((it[0], it[1], it[2])).toHashSet

proc `-`(a, b: (int, int, int)): (int, int, int) = (a[0]-b[0], a[1]-b[1], a[2]-b[2])
proc `+`(a, b: (int, int, int)): (int, int, int) = (a[0]+b[0], a[1]+b[1], a[2]+b[2])

var openSides = cubes.len * 6
for cube in cubes:
    for loc in cubeLocations:
        if cube+loc in cubes:
            dec openSides

# Part 1
echo openSides

# Add all locations next to cubes
var nextTo: HashSet[(int, int, int)]
for cube in cubes:
    for loc in cubeLocations:
        let testLoc = loc+cube
        if testLoc notin cubes:
            nextTo.incl(testLoc)

assert nextTo.len * 4 != cubes.len

# Check all locations that are surrounded
var counter = 0
for cube in nextTo:
    counter = 0
    for loc in cubeLocations:
        if (loc+cube) in cubes:
            inc counter
    if counter == 6:
        openSides -= 6

echo openSides
    
# 4156 too high
# 3988 too high
