import ../aoc
import strutils, sequtils, tables, sets, intsets

import std/[bitops]

day 23:
    const MAGIC = -1
    const DIRS = [-256, 256, -1, 1]
    const SCAN = [-257, -256, -255, 1, 257, 256, 255, -1]

    initPacked2D(8)

    proc solve(elfs: Packeds2D, maxRounds = 1000): (int, int) =
        var props: Table[int, int]
        var elfRotation = 0
        var blocked: array[65536, bool]
        var velfs: seq[Packed2D]
        for elf in elfs:
            blocked[elf] = true
            velfs.add(elf)
        var a_tmp: array[8, bool]
        var a_rr: array[4, bool]

        var r = 0
        while true:
            inc r
            if r > maxRounds:
                break

            props.clear()

            for ei, elf in velfs:
                var btest = true
                
                for ai in 0..7:
                    a_tmp[ai] = not blocked[elf+SCAN[ai]]
                    btest = btest and a_tmp[ai]

                if btest:
                    continue

                a_rr[0] = a_tmp[0] and a_tmp[1] and a_tmp[2]
                a_rr[1] = a_tmp[4] and a_tmp[5] and a_tmp[6]                    
                a_rr[2] = a_tmp[6] and a_tmp[7] and a_tmp[0]
                a_rr[3] = a_tmp[2] and a_tmp[3] and a_tmp[4]

                for i in 0..3:
                    let x = (i+elfRotation).bitand(3)
                    if a_rr[x]:
                        # inc hits
                        let move = elf+DIRS[x]
                        if move notin props:
                            props[move] = ei
                        else:
                            props[move] = MAGIC
                        break

            if props.len == 0:
                break

            for move, ei in props:
                if ei != MAGIC:
                    blocked[velfs[ei]] = false
                    blocked[move] = true
                    velfs[ei] = move

            elfRotation = (elfRotation+1).bitand(3)

        let relfs = velfs.unpack
        let box = relfs.max - relfs.min + (1, 1)
        (box[0] * box[1] - relfs.len, r)

    var elfs = lines.toCoords2D('#').pack(offset = (31, 31))

    part 1, 4045: solve(elfs, 10)[0]
    part 2, 963: solve(elfs)[1]
