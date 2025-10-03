package main

import "core:fmt"
import "core:encoding/hex"
import "core:encoding/base64"
import "core:mem"
import "core:os"
import "core:strings"
import "core:slice"

FILE_4 :: "4.txt"

main :: proc() {
}

encode_hex :: proc(byte_arr: []byte) -> string {
    return transmute(string)hex.encode(byte_arr)
}
decode_hex :: proc(hex_str: string) -> []byte {
    return hex.decode(transmute([]u8)hex_str) or_else fmt.panicf("could not decode %s\n", hex_str)
}

hex2b64 :: proc(hex_str: string) -> (b64_str: string) {
    return base64.encode(decode_hex(hex_str)) or_else fmt.panicf("could not encode resulted string")
}

xor_arr_repeting :: proc(a: []byte, xs: string) -> []byte {
    c := slice.clone(a)
    size_xs := len(xs)
    size := len(c)
    for i := 0; i < size; i += 1{
        xor_byte := xs[i % size_xs]
        c[i] ~= xor_byte
    }

    return c
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

challeng_4 :: proc() {
    freq_map := build_freq_map()

    data := os.read_entire_file_from_filename(FILE_4) or_else fmt.panicf("could not read file %s\n", FILE_4)
    lines := strings.split_lines(transmute(string)data)

    topline_byte : byte
    topline_points := 0.0
    topline_index := 0
    topline : []byte
    size := len(lines)
    for i := 0; i < size; i += 1 {
        line := lines[i]
        byte_array := decode_hex(line)
        if b, p := xor_candidate(byte_array, freq_map); p > topline_points {
            topline_byte = b
            topline_points = p
            topline = byte_array
            topline_index = i
        }
    }

    fmt.printf("[%d] %s\n", topline_index, lines[topline_index])
    fmt.printf("[%d] %s", topline_index, transmute(string)xor_arr(topline, topline_byte))
}

xor_candidate :: proc(byte_array: []byte, freq_map: map[byte]f64) -> (byte, f64) {
    top_candidate_points := 0.0
    top_candidate : byte = 0
    candiate := top_candidate
    for {
        xored := xor_arr(byte_array, candiate)
        points := 0.0
        for c in xored {
            points += freq_map[c] or_else 0
        }

        if points > top_candidate_points {
            top_candidate_points = points
            top_candidate = candiate
        }

        if candiate == 255 {
            break
        }

        candiate += 1
    }

    return top_candidate, top_candidate_points
}