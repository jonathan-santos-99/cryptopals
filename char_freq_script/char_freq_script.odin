package main

import "core:os"
import "core:fmt"
import "core:strings"

// FILE_PATH :: "/Users/jonathan.santos/fontes/cryptopals/char_freq_script/shakespeare.txt"
FILE_PATH :: "/Users/jonathan.santos/fontes/cryptopals/char_freq_script/tweets.txt"

PRINTABLE_CHARS :: "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ "
OUT_PATH :: "/Users/jonathan.santos/fontes/cryptopals/set1/freq_map.odin"

main :: proc() {
    as := strings.ascii_set_make(PRINTABLE_CHARS) or_else fmt.panicf("could not create ascii set from %s\n", PRINTABLE_CHARS)
    data := os.read_entire_file_from_filename(FILE_PATH) or_else fmt.panicf("could not read file %s\n", FILE_PATH)

    freqs := make(map[byte]u64)
    total : u64 = 0
    for &c in data {
        total += 1
        if strings.ascii_set_contains(as, c) {
            current := freqs[c] or_else 0
            freqs[c] = current + 1
        }
    }

    sb := strings.builder_make()
    strings.write_string(&sb, "package main\n\n")
    strings.write_string(&sb, "build_freq_map :: proc() -> map[byte]f64 {\n")
    strings.write_string(&sb, "    freq_map := make(map[byte]f64)\n")

    for c in freqs {
        freq := f64(freqs[c])/f64(total)
        if freq >= 0.001 {
            if c == '\'' {
                fmt.sbprintf(&sb, "    freq_map['\\''] = %f\n", freq)
            } else if c == '\\'{
                fmt.sbprintf(&sb, "    freq_map['\\\\'] = %f\n", freq)
            } else {
                fmt.sbprintf(&sb, "    freq_map['%c'] = %f\n", c, freq)
            }
        }
    }
    strings.write_string(&sb, "    return freq_map\n")
    strings.write_string(&sb, "}\n")

    ok := os.write_entire_file(OUT_PATH, transmute([]byte)strings.to_string(sb))
    if !ok {
        fmt.printfln("could not write %s", OUT_PATH)
    }
}