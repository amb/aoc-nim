import aoc
import sequtils, strutils, tables, sugar

# Picked a really awkward way to solve it and stuck with it

type
    TreeLocation = tuple[x: int, y: int]
    TreeTable = Table[TreeLocation, int]
    TreeItem = tuple[loc: TreeLocation, value: int]
    WarpFunc = proc (ti: TreeItem): TreeItem
    TreeScanFunc = proc (tr: TreeTable): TreeTable

day 8:
    let height: Natural = lines.len
    let width: Natural = lines[0].len
    # echo fmt"Grid size = x: {width}, y: {height}"
    doAssert width == height
    let asize = width

    var trees: TreeTable
    for y, l in lines:
        if len(l) > 2:
            for x, c in l:
                doAssert x < asize and y < asize
                trees[(x, y)] = parseInt($c)

    # proc printTrees(tr: TreeTable) =
    #     var grid = newSeqWith(asize, newSeq[char](asize))
    #     echo "-".repeat(asize)
    #     for (k, v) in tr.pairs:
    #         grid[k[1]][k[0]] = chr(ord('0')+v)
    #     for i in grid:
    #         echo i.join
    #     echo "-".repeat(asize)

    proc scanVisible(tr: TreeTable): TreeTable =
        var scanline = newSeq[int](asize)
        var foundTrees: seq[TreeItem] = collect:
            for i in 0..<asize: (loc: (i, 0), value: tr[(i, 0)])
        for x in 0..<asize:
            for y in 0..<asize:
                let gridVal = tr[(x, y)]
                if gridVal > scanline[x]:
                    scanline[x] = gridVal
                    foundTrees.add((loc: (x: x, y: y), value: gridVal))
        return foundTrees.toTable

    proc scanRoom(tr: TreeTable): TreeTable =
        var lineMemory = newSeqWith(asize, newSeq[int](10))
        var resTrees = tr
        for y in 0..<asize:
            # Top to bottom
            for x in 0..<asize:
                # Left to right
                let gridVal = tr[(x, y)]
                resTrees[(x, y)] = lineMemory[x][gridVal]
                for g in 0..gridVal: lineMemory[x][g] = 0
                for g in 0..9: inc lineMemory[x][g]

        return resTrees

    proc tableWarp(tr: TreeTable, warp: WarpFunc): TreeTable =
        result = collect:
            for k, v in tr.pairs:
                let r = warp((k, v))
                {r[0]: r[1]}

    proc flipH(l: TreeLocation): TreeLocation = (l.x, asize-1-l.y)
    proc tsp(l: TreeLocation): TreeLocation = (l.y, l.x)

    proc tfB(tr: TreeTable): TreeTable = tr.tableWarp(t => (t.loc.flipH, t.value))
    proc tfL(tr: TreeTable): TreeTable = tr.tableWarp(t => (t.loc.tsp, t.value))
    proc tfR(tr: TreeTable): TreeTable = tr.tableWarp(t => (t.loc.tsp.flipH, t.value))

    # Order matters
    doAssert trees.tfR.tfB.tfL == trees

    proc allDir(tr: TreeTable, scanFunc: TreeScanFunc): seq[TreeTable] =
        result.add(scanFunc(trees))
        result.add(scanFunc(trees.tfB).tfB)
        result.add(scanFunc(trees.tfL).tfL)
        result.add(scanFunc(trees.tfR).tfB.tfL)

    part 1, 1782: trees.allDir(scanVisible).mapIt(it.keys.toSeq).concat.deduplicate.len

    let spaceScan = trees.allDir(scanRoom)

    var summed = newSeqWith(asize, newSeq[int](asize))
    var maxVal = ((0, 0), 0) 
    for x in 1..<asize-1:
        for y in 1..<asize-1:
            summed[y][x] = 1
            for g in 0..<4:
                summed[y][x] *= spaceScan[g][(x, y)]
            let sval = summed[y][x]
            if sval > maxVal[1]:
                maxVal = ((x, y), sval)
            
    part 2, 474606: maxVal[1]
