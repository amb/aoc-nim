import ../tracer
import std/[algorithm, sugar]

type
    ShadowLine* = tuple[a: int, b: int]
    ShadowLines* = object
        lines*: seq[ShadowLine]
        empties: seq[int]

proc finalize*(segs: var ShadowLines) =
    segs.lines.sort((a, b) => a[0] > b[0])

# proc addShadow*(segs: ShadowLines, seg: (int, int)): ShadowLines {.meter.} =
#     var finalSeg = seg
#     var isContained = false
#     for si, s in segs.lines:
#         if (finalSeg[0] <= s[1] and finalSeg[0] >= s[0] and s[1] <= finalSeg[1]):
#             # Touching from left side
#             finalSeg[0] = s[0]
#         elif (finalSeg[1] <= s[1] and finalSeg[1] >= s[0] and s[0] >= finalSeg[0]):
#             # Touching from right side
#             finalSeg[1] = s[1]
#         elif (finalSeg[1] >= s[1] and finalSeg[0] <= s[0]):
#             # Seg inside finalseg
#             discard
#         elif (finalSeg[1] <= s[1] and finalSeg[0] >= s[0]):
#             # FinalSeg inside seg
#             isContained = true
#             result.lines.add(s)
#         else:
#             # Completely outside
#             result.lines.add(s)

#     if not isContained:
#         result.lines.add(finalSeg)

proc addShadow*(segs: var ShadowLines, seg: (int, int)) =
    var finalSeg = seg
    var isContained = false
    for si, s in segs.lines:
        if (finalSeg[0] <= s[1] and finalSeg[0] >= s[0] and s[1] <= finalSeg[1]):
            # Touching from left side
            finalSeg[0] = s[0]
        elif (finalSeg[1] <= s[1] and finalSeg[1] >= s[0] and s[0] >= finalSeg[0]):
            # Touching from right side
            finalSeg[1] = s[1]
        elif (finalSeg[1] >= s[1] and finalSeg[0] <= s[0]):
            # Seg inside finalseg
            discard
        elif (finalSeg[1] <= s[1] and finalSeg[0] >= s[0]):
            # FinalSeg inside seg
            isContained = true
            result.lines.add(s)
        else:
            # Completely outside
            result.lines.add(s)

    if not isContained:
        result.lines.add(finalSeg)
