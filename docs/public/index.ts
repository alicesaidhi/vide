import { Cart, CartOptions, Memory, stdIo } from 'cart-luau';
import file from "!raw-loader!/app.luau"
import type { Inode } from "@bjorn3/browser_wasi_shim";
import { File } from "@bjorn3/browser_wasi_shim";
import bundle from "!raw-loader!/bundle.luau"
// import wasm from "!raw-loader!/cart.wasm"

const shared_mem = new Memory();
let cart: Cart;

// function str2ab(str) {
//     var buf = new ArrayBuffer(str.length*2); // 2 bytes for each char
//     var bufView = new Uint16Array(buf);
//     for (var i=0, strLen=str.length; i<strLen; i++) {
//         bufView[i] = str.charCodeAt(i);
//     }
//     return buf;
// }

async function run() {
    const fs = new Map<string, Inode>();
    const text =  (bundle + file)

    cart = new Cart(
        new CartOptions({
            memory: shared_mem,
            fds: stdIo("", fs)
        })
    )

    // console.log(result);
    // console.log(await (await fetch("https://alicesaidhi.github.io/vide/cart.wasm")).text())
    await cart.load("https://alicesaidhi.github.io/vide/cart.wasm");

    const thread = cart.loadThreadFromString("meow", text + file);

    if (!thread.valid) {
        throw new Error("Failed to load example");
    }
    await thread.execute();
}

run()