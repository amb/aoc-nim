import ../aoc
import strutils, math, sequtils, npeg


day 2:
    type Colors = object
        red: int
        green: int
        blue: int

    proc `>`(a, b: Colors): bool =
        if a.red > b.red or a.green > b.green or a.blue > b.blue:
            return true
        return false

    var games: seq[seq[Colors]]

    for line in lines:
        let a = line.split(": ")
        let game_n = a[0].split(" ")[1].parseInt()
        let game_sets = a[1].split("; ")
        var color_sets = newSeq[Colors]()
        for fistful in game_sets:
            var tcol = Colors(red: 0, green: 0, blue: 0)
            for color in fistful.split(", "):
                let color = color.split(" ")
                if color[1] == "red":
                    tcol.red = color[0].parseInt()
                elif color[1] == "green":
                    tcol.green = color[0].parseInt()
                elif color[1] == "blue":
                    tcol.blue = color[0].parseInt()
            color_sets.add(tcol)
        games.add(color_sets)

    part 1, 2006: 
        let maxCubes = Colors(red: 12, green: 13, blue: 14)
        var ids_sum = 0
        for i, c in games:
            block innerloop:
                for gc in c:
                    if gc > maxCubes:
                        break innerloop
                ids_sum += i+1
        ids_sum

    part 2, 84911:
        var max_sets = newSeq[Colors]()
        for i, c in games:
            var max_set = c[0]
            for gc in c:
                max_set.red = max(max_set.red, gc.red)
                max_set.green = max(max_set.green, gc.green)
                max_set.blue = max(max_set.blue, gc.blue)
            max_sets.add(max_set)
        sum(max_sets.mapIt(it.red * it.green * it.blue))

                
