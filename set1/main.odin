package main

import "core:fmt"
import "core:encoding/hex"
import "core:encoding/base64"
import "core:mem"

main :: proc() {
    freq_map := make(map[byte]f64)
    freq_map['"'] = 0.008
    freq_map['z'] = 0.030
    freq_map['q'] = 0.066
    freq_map['l'] = 3.121
    freq_map['k'] = 0.650
    freq_map['f'] = 1.478
    freq_map['>'] = 0.008
    freq_map['5'] = 0.001
    freq_map['0'] = 0.005
    freq_map['!'] = 0.162
    freq_map['['] = 0.038
    freq_map['y'] = 1.732
    freq_map['t'] = 6.051
    freq_map['s'] = 4.571
    freq_map['n'] = 4.465
    freq_map['e'] = 8.206
    freq_map['`'] = 0.000
    freq_map['8'] = 0.001
    freq_map['7'] = 0.001
    freq_map['2'] = 0.006
    freq_map[')'] = 0.011
    freq_map['|'] = 0.001
    freq_map['v'] = 0.690
    freq_map['m'] = 2.046
    freq_map['h'] = 4.352
    freq_map['g'] = 1.252
    freq_map['b'] = 1.137
    freq_map['?'] = 0.193
    freq_map[':'] = 0.033
    freq_map['1'] = 0.016
    freq_map[','] = 1.528
    freq_map['&'] = 0.000
    freq_map[']'] = 0.038
    freq_map['u'] = 2.367
    freq_map['p'] = 1.071
    freq_map['o'] = 5.774
    freq_map['j'] = 0.087
    freq_map['a'] = 5.308
    freq_map['9'] = 0.017
    freq_map['4'] = 0.002
    freq_map['3'] = 0.006
    freq_map['.'] = 1.433
    freq_map[' '] = 23.574
    freq_map['_'] = 0.001
    freq_map['}'] = 0.000
    freq_map['x'] = 0.096
    freq_map['w'] = 1.642
    freq_map['r'] = 4.364
    freq_map['i'] = 4.660
    freq_map['d'] = 2.743
    freq_map['c'] = 1.616
    freq_map['<'] = 0.008
    freq_map[';'] = 0.316
    freq_map['6'] = 0.001
    freq_map['-'] = 0.148
    freq_map['('] = 0.011
    freq_map['\''] = 0.571

    encoded_str := "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"
    byte_array := decode_hex(encoded_str)

    curr : []u8

    max_points := 0.0
    i : u8 = 0
    for ; i < 255; i += 1 {
        xored := xor_arr(byte_array, i)
        points := 0.0
        for c in xored {
            point := freq_map[c] or_else 0
            points += point
        }

        if max_points < points {
            curr = xored
            max_points = points
        }
    }

    str := transmute(string)curr
    fmt.printf("character used to xor: %c. Score: %f\n", i, max_points)
    fmt.println(str)
}

decode_hex :: proc(hex_str: string) -> []byte {
    return hex.decode(transmute([]u8)hex_str) or_else fmt.panicf("could not decode %s\n", hex_str)
}

hex2b64 :: proc(hex_str: string) -> (b64_str: string) {
    return base64.encode(decode_hex(hex_str)) or_else fmt.panicf("could not encode resulted string")
}

xor_arr :: proc(a: []byte, x: byte) -> []byte {
    size := len(a)
    c := make([]byte, size)
    for i := 0; i < size; i += 1 {
        c[i] = a[i] ~ x
    }

    return c
}

fixed_xor :: proc(a: []byte, b: []byte) -> []byte {
    assert(len(a) == len(b))

    size := len(a)
    c := make([]byte, size)
    for i := 0; i < size; i += 1 {
        c[i] = a[i] ~ b[i]
    }

    return c
}