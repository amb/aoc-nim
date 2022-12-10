include ../aoc

let commands = readFile("10/input").split({'\n', ' '})

block part1:
    var chkPt = @[20, 60, 100, 140, 180, 220].reversed
    var cycle = 1
    var X = 1
    proc solve(line: string): int =
        inc cycle
        if line[0] in {'0'..'9', '-'}:
            X += parseInt(line.strip)
        if chkPt.len > 0 and cycle == chkPt[^1]:
            result = chkPt.pop() * X

    let signal = collect:
        for line in commands: line.solve

    echo signal.sum

block part2:
    var chkPt = countdown(240, 40, 40).toSeq
    var pix = newSeq[int](40)
    var cycle = 1
    var X = 1
    proc solve2(line: string): string =
        let cursor = (cycle-1) mod 40
        pix[cursor] = (if cursor>=X-1 and cursor<=X+1: 1 else: 0)
        if line[0] in {'0'..'9', '-'}:
            X += parseInt(line.strip)
        if chkPt.len > 0 and cycle >= chkPt[^1]:
            discard chkPt.pop()
            result = pix.mapIt(if it==0: '.' else: '#').join() & "\n"
        inc cycle

    let signal = collect:
        for line in commands: line.solve2

    echo signal.join()
