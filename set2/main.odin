package main

import "core:strconv"
import "core:fmt"

main :: proc () {
    block := "YELLOW SUBMARINE"
    padded_block := pad_block(transmute([]byte) block, 20)

    fmt.printfln("%d '%x'", len(block), block)
    fmt.printfln("%d '%x'", len(padded_block), transmute(string) padded_block)
}

// challenge 9
pad_block :: proc(block: []byte, expected_block_size: int) -> []byte {
    block_size := len(block)
    if block_size == expected_block_size {
        return block
    }

    ensure(block_size < expected_block_size)

    pad_length := byte(expected_block_size - block_size)
    ensure(pad_length < 255)

    new_block := make([]byte, expected_block_size)
    ensure(copy(new_block, block) == block_size)

    for i := block_size; i < expected_block_size; i += 1 {
        new_block[i] = pad_length
    }

    return new_block
}