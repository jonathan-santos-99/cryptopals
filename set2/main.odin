package main

import "core:mem"
import "base:intrinsics"
import "core:fmt"
import "core:crypto/aes"
import "core:encoding/base64"
import "core:os"
import "core:strings"

main :: proc () {
    FILE :: "10.txt"
    key : [16]byte = "YELLOW SUBMARINE"
    iv : [16]byte

    // decrypt
    raw_data := os.read_entire_file_from_filename(FILE) or_else fmt.panicf("could not read file %s\n", FILE)
    data := base64.decode(transmute(string)raw_data) or_else panic("could not decode base64")
    decrypted_text := decrypt_cbc(data, key[:], iv[:])

    // encrypt
    encrypted_text := encrypt_cbc(decrypted_text, key[:], iv[:])

    fmt.println(mem.compare(encrypted_text, data))
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

encrypt_cbc :: proc (data: []byte, key: []byte, iv: []byte) -> []byte {
    ensure(len(key) == aes.BLOCK_SIZE)
    ensure(len(iv) == aes.BLOCK_SIZE)
    ensure(len(data) % aes.BLOCK_SIZE == 0)

    ctx : aes.Context_ECB
    aes.init_ecb(&ctx, key)

    last_cypher_text := iv
    encrypted_text := make([]byte, len(data))
    for i := 0; i + aes.BLOCK_SIZE <= len(data); i += aes.BLOCK_SIZE {
        src := fixed_xor(data[i: i + aes.BLOCK_SIZE], last_cypher_text)
        dst := encrypted_text[i: i + aes.BLOCK_SIZE]
        aes.encrypt_ecb(&ctx, dst, src)
        last_cypher_text = dst
    }

    return encrypted_text
}

decrypt_cbc :: proc (data: []byte, key: []byte, iv: []byte) -> []byte {
    ensure(len(key) == aes.BLOCK_SIZE)
    ensure(len(iv) == aes.BLOCK_SIZE)
    ensure(len(data) % aes.BLOCK_SIZE == 0)

    ctx : aes.Context_ECB
    aes.init_ecb(&ctx, key)

    last_cypher_text := iv
    decrypted_text := make([]byte, len(data))
    for i := 0; i + aes.BLOCK_SIZE <= len(data); i += aes.BLOCK_SIZE {
        src := data[i: i + aes.BLOCK_SIZE]
        dst := decrypted_text[i: i + aes.BLOCK_SIZE]
        aes.decrypt_ecb(&ctx, dst, src)
        fixed_xor_inplace(dst, last_cypher_text)
        last_cypher_text = src
    }

    return decrypted_text
}

encrypt_ecb :: proc (data: []byte, key: []byte) -> []byte {
    ensure(len(key) == aes.BLOCK_SIZE)
    ensure(len(data) % aes.BLOCK_SIZE == 0)
    ctx : aes.Context_ECB
    aes.init_ecb(&ctx, key)

    encrypted_text := make([]byte, len(data))
    for i := 0; i + aes.BLOCK_SIZE <= len(data); i += aes.BLOCK_SIZE {
        src := data[i: i + aes.BLOCK_SIZE]
        dst := encrypted_text[i: i + aes.BLOCK_SIZE]
        aes.encrypt_ecb(&ctx, dst, src)
    }

    return encrypted_text
}

decrypt_ecb :: proc (data: []byte, key: []byte) -> []byte{
    ensure(len(key) == aes.BLOCK_SIZE)
    ensure(len(data) % aes.BLOCK_SIZE == 0)
    ctx : aes.Context_ECB
    aes.init_ecb(&ctx, key)

    decrypted_text := make([]byte, len(data))
    for i := 0; i + aes.BLOCK_SIZE <= len(data); i += aes.BLOCK_SIZE {
        src := data[i: i + aes.BLOCK_SIZE]
        dst := decrypted_text[i: i + aes.BLOCK_SIZE]
        aes.decrypt_ecb(&ctx, dst, src)
    }

    return decrypted_text
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

fixed_xor_inplace :: proc(a: []byte, b: []byte) {
    ensure(len(a) == len(b))
    for i := 0; i < len(a); i += 1 {
        a[i] ~= b[i]
    }
}