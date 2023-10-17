import math

# 0x5f375a86 fast isqrt
proc Q_rsqrt(number: float32): float32 =
    var half = 0.5f32 * number
    var i: int32 = cast[int32](number)
    i = 0x5f375a86 - (i shr 1)
    var x: float32 = cast[float32](i)
    x = x * (1.5 - half * x * x)
    x = x * (1.5 - half * x * x)
    return x

echo Q_rsqrt(4.0)
echo 1.0/sqrt(4.0)
