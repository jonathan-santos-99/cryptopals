package main

import "core:os"
import "core:fmt"
import "core:strings"

FILE_PATH :: "/home/jonathan/fontes/cryptopals/char_freq_script/shakespeare.txt"
PRINTABLE_CHARS :: "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ "

main :: proc() {
    as := strings.ascii_set_make(PRINTABLE_CHARS) or_else fmt.panicf("could not create ascii set from %s\n", PRINTABLE_CHARS)
    data := os.read_entire_file_from_filename(FILE_PATH) or_else fmt.panicf("could not read file %s\n", FILE_PATH)

    freq := make(map[byte]u64)
    total : u64 = 0
    for &c in data {
        total += 1
        if strings.ascii_set_contains(as, c) {
            if c >= 'A' && c <= 'Z' {
                c = c + 32
            }

            current := freq[c] or_else 0
            freq[c] = current + 1
        }
    }

    fmt.printf("freq_map := make(map[byte]f32)\n")
    for c in freq {
        if c == '\'' {
            fmt.printf("freq_map['\\%c'] = %f\n", c, 100 * f64(freq[c])/f64(total))
        } else {
            fmt.printf("freq_map['%c'] = %f\n", c, 100 * f64(freq[c])/f64(total))
        }
    }
}