import std/[algorithm, sugar]

type
    ShadowLine* = object
        a, b: int
        valid: bool
    ShadowLines* = object
        lines*: seq[ShadowLine]
        empties: seq[int]

proc addItem(sl: var ShadowLines, i: ShadowLine) =
    if sl.empties.len == 0:
        sl.lines.add(i)
    else:
        let ol = sl.empties.pop()
        sl.lines[ol] = i

proc markRemoved(sl: var ShadowLines, i: int) =
    sl.lines[i].valid = false
    sl.empties.add(i)

proc finalize*(sl: var ShadowLines) =
    sl.lines = collect:
        for l in sl.lines:
            if l.valid: l
    sl.lines.sort((a, b) => a.a > b.a)

proc reset*(sl: var ShadowLines) =
    sl.empties.setLen(0)
    sl.lines.setLen(0)

proc addShadow*(sl: var ShadowLines, seg: (int, int)) =
    var finalSeg = ShadowLine(a: seg[0], b: seg[1], valid: true)
    var isContained = false
    for si in 0..<sl.lines.len:
        let s = sl.lines[si]
        if not s.valid:
            continue
        if (finalSeg.a <= s.b and finalSeg.a >= s.a and s.b <= finalSeg.b):
            # Touching from left side
            finalSeg.a = s.a
            sl.markRemoved(si)
        elif (finalSeg.b <= s.b and finalSeg.b >= s.a and s.a >= finalSeg.a):
            # Touching from right side
            finalSeg.b = s.b
            sl.markRemoved(si)
        elif (finalSeg.b >= s.b and finalSeg.a <= s.a):
            # Seg inside finalseg
            sl.markRemoved(si)
        elif (finalSeg.b <= s.b and finalSeg.a >= s.a):
            # FinalSeg inside seg
            isContained = true

    if not isContained:
        sl.addItem(finalSeg)

# TODO: super stupid, doesn't actually clip left or right
iterator empties*(segs: ShadowLines, lval, hval: int): (int, int) =
    var i = 0
    while i < segs.lines.len-1:
        let left = segs.lines[i]
        let right = segs.lines[i+1]
        assert right.a > left.b
        yield (left.b, right.a)
        inc i
