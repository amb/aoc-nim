import ../aoc
import strutils, math, sequtils, npeg, tables

day 2:
    let lines = input.splitLines

    type Colors = array[3, int]
    const cname = {"red": 0, "green": 1, "blue": 2}.toTable
    
    var games: seq[seq[Colors]]
    for line in lines:
        let game_sets = line.split(": ")[1].split("; ")
        var color_sets = newSeq[Colors]()
        for fistful in game_sets:
            var tcol = [0, 0, 0]
            for color in fistful.split(", "):
                let color = color.split(" ")
                tcol[cname[color[1]]] = color[0].parseInt()
            color_sets.add(tcol)
        games.add(color_sets)

    # use npeg to parse lines
    # games[seq] -> colorseq[seq] -> r, g, b
    # let parser = peg("root", games: seq[seq[Colors]]):
    #     root <- +(game * '\n')
    #     game <- *(colorset * "; ") * colorset:
    #         games.add(newSeq[Colors]())
    #     colorset <- *(color * ", ") * color:
    #         games[^1].add([0, 0, 0])
    #     color <- >(+Digit) * ' ' * >(+Alpha):
    #         games[^1][^1][cname[$2]] = parseInt($1)
    
    # var g: seq[seq[Colors]]
    # echo "Parsing result: ", parser.match(input, g).ok
    # echo g.len

    part 1, 2006: 
        let maxCubes = [12, 13, 14]
        var ids_sum = 0
        for i, c in games:
            block outerloop:
                for gc in c:
                    if gc[0] > maxCubes[0] or gc[1] > maxCubes[1] or gc[2] > maxCubes[2]:
                        break outerloop
                ids_sum += i+1
        ids_sum

    part 2, 84911:
        var max_sets = newSeq[Colors]()
        for i, c in games:
            var max_set = c[0]
            for gc in c:
                for n in 0..2:
                    max_set[n] = max(max_set[n], gc[n])
            max_sets.add(max_set)
        sum(max_sets.mapIt(it[0] * it[1] * it[2]))
