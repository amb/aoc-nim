import std/[algorithm, sugar]

type
    ShadowLine* = object
        a*, b*: int64
        valid: bool
    ShadowLines* = object
        lines*: seq[ShadowLine]
        empties: seq[int64]
    SegRelationship* = enum
        TouchingLeft, TouchingRight, Inside, Container, Outside


proc segRelationship(a, b: ShadowLine): SegRelationship =
    # What is b in relation to a?
    if (a.a <= b.b and a.a >= b.a and b.b <= a.b): 
        return SegRelationship.TouchingLeft
    elif (a.b <= b.b and a.b >= b.a and b.a >= a.a): 
        return SegRelationship.TouchingRight
    elif (a.b >= b.b and a.a <= b.a): 
        return SegRelationship.Inside
    elif (a.b <= b.b and a.a >= b.a): 
        return SegRelationship.Container
    else: 
        return SegRelationship.Outside

proc addItem(sl: var ShadowLines, i: ShadowLine) =
    if sl.empties.len == 0:
        sl.lines.add(i)
    else:
        let ol = sl.empties.pop()
        sl.lines[ol] = i

proc markRemoved(sl: var ShadowLines, i: int64) =
    sl.lines[i].valid = false
    sl.empties.add(i)

proc finalize*(sl: var ShadowLines) =
    # TODO: sort smart and just .setLen to sl.lines.len-invalids.len
    sl.lines = collect:
        for l in sl.lines:
            if l.valid: l
    sl.lines.sort((a, b) => a.a > b.a)

proc reset*(sl: var ShadowLines) =
    sl.empties.setLen(0)
    sl.lines.setLen(0)

proc addShadowSorted4*(sl: var ShadowLines, seg: (int64, int64)) =
    var finalSeg = ShadowLine(a: seg[0], b: seg[1], valid: true)
    assert sl.lines.len <= 4
    
    template snet(id1, id0: untyped): untyped =
        if sl.lines[id1].a < sl.lines[id0].a: swap(sl.lines[id1], sl.lines[id0])
    if sl.lines.len == 4:
        snet(2, 0); snet(3, 1); snet(1, 0); snet(3, 2)
    elif sl.lines.len == 3:
        snet(1, 0); snet(2, 0); snet(2, 1)
    elif sl.lines.len == 2:
        snet(1, 0)

    var slc = 0
    var sline = sl.lines[slc]
    if finalSeg.b < sline.a:
        sl.addItem(finalSeg)
    if finalSeg.a < sline.a and finalSeg.b >= sline.a and finalSeg.b < sline.b:
        finalSeg.b = sline.b
        sl.markRemoved(slc)

    assert false, "Undone"

proc addShadow*(sl: var ShadowLines, seg: (int64, int64)) =
    var finalSeg = ShadowLine(a: seg[0], b: seg[1], valid: true)
    for si in 0..<sl.lines.len:
        let s = sl.lines[si]
        if not s.valid: continue
        case segRelationship(finalSeg, s):
        of Container:
            return
        of TouchingLeft:
            finalSeg.a = s.a
            sl.markRemoved(si)
        of TouchingRight:
            finalSeg.b = s.b
            sl.markRemoved(si)
        of Inside:
            sl.markRemoved(si)
        of Outside:
            discard
    sl.addItem(finalSeg)

# TODO: two sorted shadowline (set of non-int64ersecting ranges)
#       do not require sorting to join or test for collisions
#       IMPLEMENT both

iterator empties*(segs: ShadowLines, lval, hval: int64): (int64, int64) =
    var i = 0
    while i < segs.lines.len-1:
        let ls = segs.lines[i].b
        let hs = segs.lines[i+1].a
        assert hs > ls
        assert not (ls < lval and hs > hval)
        if hs < lval or ls > hval: continue
        if ls < lval: 
            yield (lval, hs)
        elif hs > hval: 
            yield (ls, hval)
        else:
            yield (ls, hs)
        inc i
