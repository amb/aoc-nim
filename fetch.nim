import std/[sequtils, strutils, strformat, strscans, times, parseutils, parseopt, os, httpclient]
import cligen

#    _____         _________   ___________     __         .__
#   /  _  \   ____ \_   ___ \  \_   _____/____/  |_  ____ |  |__   ___________
#  /  /_\  \ /  _ \/    \  \/   |    __)/ __ \   __\/ ___\|  |  \_/ __ \_  __ \
# /    |    (  <_> )     \____  |     \\  ___/|  | \  \___|   Y  \  ___/|  | \/
# \____|__  /\____/ \______  /  \___  / \___  >__|  \___  >___|  /\___  >__|
#         \/               \/       \/      \/          \/     \/     \/

proc getFetcherPath(): string =
    result = os.getCurrentDir()

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

    if not dirExists(fmt"{year}"):
        createDir(fmt"{year}")

    if not dirExists(folderName):
        createDir(folderName)

    if not fileExists(fileName):
        echo "Writing template"

        let templateText = readFile("template.txt").strip()
        let fileText = templateText.replace("{{day}}", $day)
        writeFile(fileName, fileText)

        echo "Fetching AoC input"
        fetchAoC(year, day)
    else:
        echo "File already fetched."

proc cli(fetch="", args: seq[string]): int =
    var year, day: int
    let date = now()
    if "," in fetch:
        let bits = fetch.split(",")
        assert bits.len == 2
        year = parseInt(bits[0])
        day = parseInt(bits[1])
    elif fetch != "":
        year = now().year
        day = parseInt(fetch)
    else:
        year = date.year
        day = date.monthday

    if date.year < year:
        echo "Year out of range."
    elif date.year == year and date.month.ord < 12:
        echo "Date out of range."
    elif date.year == year and date.month.ord == 12 and date.monthday < day:
        echo "Date out of range."
    else:
        echo "Fetch: ", year, ", ", day
        fetchDate(year, day)
        # echo year, ", ", day

dispatch cli, help={"fetch": "Fetch AoC input for given date (YYYY,DD or DD like 2013,3). Empty uses current date."}

# when isMainModule:
#     let date = now()
#     let day = date.monthday

#     if date.month.ord == 12 and day <= 25:
#         fetchDate(date.year, day)
#     else:
#         echo "Not December yet."
