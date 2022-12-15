

# Create KD-tree from data
proc manhattanKD(x, y: KdPoint): float = abs(x[0]-y[0])+abs(x[1]-y[1])
var tree = newKDTree[Vec2i](beacons.mapIt(it.asFloatArray), beacons, distFunc=manhattanKD)

# Check everything is good
for si, s in sensors:
    let treeres = tree.nearestNeighbour([s.location.x.float, s.location.y.float])
    assert treeres[1] == beacons[si]
    assert treeres[2].int == s.area

proc sensorScanline(sensor: Sensor, sid: int, y: int): Option[(int, int)] =
    let ydisp = abs(sensor.location.y-y)
    if ydisp > sensor.area:
        return none((int, int))
    let closeToFringe = (sensor.area-ydisp)
    return some((sensor.location.x - closeToFringe, sensor.location.x + closeToFringe))

proc findBacon(sensors: seq[Sensor], lval, hval: int): (int, int) =
    var slines: ShadowLines
    for ri in 0..hval:
        for si, s in sensors:
            let r = s.sensorScanline(si, ri)
            if r.isSome:
                slines.addShadow(r.get)
        slines.finalize()
        for e in slines.empties(lval, hval):
            if e[1]-e[0] > 1:
                return (e[0]+1, ri)
        slines.reset()

proc findBaconB(sensors: seq[Sensor], lval, hval: int): (int, int) =

    template rscan(scid, scdx, sy: untyped): untyped =
        while scdx < sensors.len:
            scid = sensorScanline(sensors[scdx], sy)
            if scid.isSome or scdx >= sensors.len:
                break
            inc scdx
    
    for y in 0..hval:
        var loca = 0
        var locb: int
        var ascan: Option[(int, int)]
        var bscan: Option[(int, int)]

        rscan(ascan, loca, y)
        while loca+1 < sensors.len:
            locb = loca+1
            rscan(bscan, locb, y)
            if ascan.isSome and bscan.isSome:
                if bscan.get[0]-ascan.get[1] >= 1:
                    echo fmt"{y}: {bscan.get[0]-ascan.get[1]}, {loca}:{locb}"
            else:
                break
            loca = locb
            ascan = bscan
