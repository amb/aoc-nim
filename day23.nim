include aoc
import tracer

day 23:
    let surround = compassRD.values.toSeq.toCoords2D
    var elfCheck: seq[seq[Coord2D]]

    proc resetElfCheck() =
        elfCheck.setLen(0)
        for dirs in @[
            ("NE", "N", "NW"), 
            ("SE", "S", "SW"), 
            ("NW", "W", "SW"), 
            ("NE", "E", "SE")]:
            var il: seq[Coord2D]
            il.add(compassRD[dirs[0]])
            il.add(compassRD[dirs[1]])
            il.add(compassRD[dirs[2]])
            elfCheck.add(il)

    const MAGIC = (-555,-555)

    proc proposal(elf: Coord2D, tiles: Coords2D): Coord2D =
        for dirs in elfCheck:
            var hasPos = true
            for direction in dirs:
                if (elf+direction) in tiles:
                    hasPos = false
                    break
            if hasPos:
                return elf+dirs[1]
        return MAGIC

    proc getprops(elfs: Coords2D): Table[Coord2D, Coord2D] =
        # Gather suggestions
        for elf in elfs:
            var hugging = false
            for it in surround:
                if elf+it in elfs:
                    hugging = true
                    break
            if hugging:
                let move = elf.proposal(elfs)
                if move != MAGIC:
                    if move notin result:
                        result[move] = elf
                    else:
                        result[move] = MAGIC

    proc solve(oelfs: Coords2D, maxRounds = 1000): (int, int) =
        resetElfCheck()
        var r = 0
        var elfs = oelfs
        while true:
            inc r
            if r > maxRounds:
                break

            let props = getprops(elfs)

            if props.len == 0:
                break

            for move, elf in props:
                if elf != MAGIC:
                    elfs.excl(elf)
                    elfs.incl(move)

            elfCheck.rollL(0, elfCheck.high)

        let box = elfs.max - elfs.min + (1, 1)
        (box[0] * box[1] - elfs.len, r)

    var elfs = lines.toCoords2D('#')

    part 1, 4045: solve(elfs, 10)[0]
    part 2, 963: solve(elfs)[1]
