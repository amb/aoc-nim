import std/[sequtils, strutils, strformat, strscans, times, parseutils, parseopt, os, httpclient]

#    _____         _________   ___________     __         .__
#   /  _  \   ____ \_   ___ \  \_   _____/____/  |_  ____ |  |__   ___________
#  /  /_\  \ /  _ \/    \  \/   |    __)/ __ \   __\/ ___\|  |  \_/ __ \_  __ \
# /    |    (  <_> )     \____  |     \\  ___/|  | \  \___|   Y  \  ___/|  | \/
# \____|__  /\____/ \______  /  \___  / \___  >__|  \___  >___|  /\___  >__|
#         \/               \/       \/      \/          \/     \/     \/

proc getFetcherPath(): string =
    result = os.getCurrentDir()

proc getInput*(year, day: int): string =
    let inputPath = getFetcherPath() / $year / "inputs" / fmt"day{day}.in"
    if fileExists inputPath:
        return readFile(inputPath)
    else:
        raise newException(
            ValueError,
            fmt"Input data missing: {inputPath}"
        )

proc getCookie(): string =
    let cookiePath = getFetcherPath() / "session.txt"

    if not fileExists cookiePath:
        writeFile(cookiePath, "")

    result = readFile(cookiePath).strip()

    if result == "":
        raise newException(IOError, fmt"Please write your AoC cookie to '{cookiePath}'.")

    var token: string
    if not result.scanf("session=$+", token):
        raise newException(
            ValueError,
            fmt"Session token should be of format 'session=128_CHAR_HEX_NUMBER', " &
            fmt"but got '{result}' instead."
        )

    if token.len != 128:
        raise newException(
            ValueError,
            fmt"Session token should be a 128 character long hexadecimal number, " &
            fmt"but got '{token}' which is {token.len} characters long."
        )

    try:
        discard parseHexInt(token)
    except ValueError:
        raise newException(
            ValueError,
            fmt"Session token should be a hexadecimal number, " &
            fmt"but could not parse' {token}' as a hexadecimal."
        )

proc fetchAoC(year, day: int) =
    let inputPath = getFetcherPath() / $year / "inputs" / fmt"day{day}.in"
    echo fmt"Downloading input for year {year}, day {day}."
    let client = newHttpClient()
    defer: client.close()
    client.headers["cookie"] = getCookie()

    let content = client.getContent(fmt"https://adventofcode.com/{year}/day/{day}/input")
    inputPath.writeFile(content)

proc fetchDate(year, day: int) =
    let fileName = fmt"{year}/day{day}.nim"
    let folderName = fmt"{year}/inputs"
    if not fileExists(fileName):
        echo "Fetching AoC input"

        fetchAoC(year, day)

        if not dirExists(folderName):
            createDir(folderName)

        let fileText = fmt"""
import ../aoc
import std/[sequtils, strutils]

day {day}:
    let lines = input.splitLines

    part 1:
        404

    part 2:
        404
        """
        writeFile(fileName, fileText)
    else:
        echo "File already fetched."


when isMainModule:
    let date = now()
    let day = date.monthday

    if modate.month.ord == 12 and day <= 25:
        fetchDate(date.year, day)
    else:
        echo "Not December yet."
