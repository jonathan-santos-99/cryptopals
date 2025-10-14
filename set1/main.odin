package main

import "core:fmt"
import "core:encoding/hex"
import "core:encoding/base64"
import "core:mem"
import "core:os"
import "core:strings"
import "core:math/bits"
import "core:math"
import "core:slice"
import "core:sort"

FILE_4 :: "4.txt"
FILE_6 :: "ch_6_text"

main :: proc() {
    raw_data := os.read_entire_file_from_filename(FILE_6) or_else fmt.panicf("could not read file %s\n", FILE_6)
    data := base64.decode(transmute(string)raw_data) or_else panic("could not decode base64")
    candidates := get_possible_cypher_xor_arr_repeating(data)

    for cypher in candidates {
        text := xor_arr_repeting(data, cypher)
        sb_file_name := strings.builder_make()
        fmt.sbprintf(&sb_file_name, "ksz_%d.txt", len(cypher))
        if !os.write_entire_file(strings.to_string(sb_file_name), transmute([]byte)text) {
            panic("could not write file")
        }
    }
}

get_possible_cypher_xor_arr_repeating :: proc(data: []byte, n_key_sizes_to_test: int = 40, candidates_to_return: int = 3) -> []string {
    freq_map := build_freq_map()
    possible_cyphers := make([]string, candidates_to_return)

    keysizes := calculate_possible_keysizes(data, n_key_sizes_to_test, candidates_to_return)
    for i := 0; i < candidates_to_return; i += 1 {
        blocks := make_blocks(data, keysizes[i])
        transposed_blocks := transpose(blocks)

        sb_cypher := strings.builder_make()
        for block in transposed_blocks {
            _byte, _ := xor_candidate(block, freq_map)
            strings.write_byte(&sb_cypher, _byte)
        }

        possible_cyphers[i] = strings.to_string(sb_cypher)
    }

    return possible_cyphers;
}

transpose :: proc(m: [][]byte) -> [][]byte {
    ms := len(m[0])
    bs := len(m)
    transposed_block := make([][]byte, ms)

    for i := 0; i < ms; i += 1 {
        transposed_block[i] = make([]byte, bs)
        for j := 0; j < bs; j += 1 {
            transposed_block[i][j] = m[j][i]
        }
    }

    return transposed_block
}

make_blocks :: proc(data: []byte, block_size: int) -> [][]byte {
    data_size := len(data)
    total_blocks := int(math.ceil(f64(data_size) / f64(block_size)))
    blocks := make([][]byte, total_blocks)

    for i := 0; i < total_blocks; i += 1 {
        block := make([]byte, block_size)
        for j := 0; j < block_size; j += 1 {
            index := i*block_size + j
            if index < data_size {
                block[j] = data[index]
            } else {
                block[j] = 0
            }
        }
        blocks[i] = block
    }

    return blocks
}

calculate_possible_keysizes :: proc(data: [] byte, nkeys: int, total_keys_to_return: int = 3) -> []int {
    keysize_map := make(map[int]f32, nkeys)

    for i := 0; i < nkeys; i += 1 {
        keysize := i + 2
        assert(keysize*4 < len(data))

        a  := data[keysize*0:keysize*1]
        b  := data[keysize*1:keysize*2]
        aa := data[keysize*2:keysize*3]
        bb := data[keysize*3:keysize*4]

        d1 := f32(hamming_distance(a, b))/f32(keysize)
        d2 := f32(hamming_distance(b, aa))/f32(keysize)
        d3 := f32(hamming_distance(aa, bb))/f32(keysize)

        avg_d := (d1 + d2 + d3) / 3.0

        keysize_map[keysize] = avg_d
    }

    nkeysizes := make([]f32, total_keys_to_return)

    keysizes := make([]int, total_keys_to_return)
    for i := 0; i < nkeys; i += 1 {
        keysize := i + 2

        for j := 0; j < total_keys_to_return; j += 1 {
            if nkeysizes[j] == 0 {
                nkeysizes[j] = keysize_map[keysize]
                keysizes[j] = keysize
                break
            }

            if keysize_map[keysize] < nkeysizes[j] {
                for k := total_keys_to_return - 1; k > j; k -= 1 {
                    nkeysizes[k] = nkeysizes[k - 1]
                    keysizes[k] = keysizes[k - 1]
                }

                nkeysizes[j] = keysize_map[keysize]
                keysizes[j] = keysize
                break
            }
        }
    }

    return keysizes
}

hamming_distance_str :: proc(a: string, b: string) -> u8 {
    return hamming_distance(transmute([]byte)a, transmute([]byte)b)
}

hamming_distance :: proc(a: []byte, b: []byte) -> u8 {
    c := fixed_xor(a, b)

    distance : u8 = 0
    for b in c {
        distance += bits.count_ones(b)
    }

    return distance
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

        for _byte in xored {
            points += freq_map[_byte] or_else 0
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