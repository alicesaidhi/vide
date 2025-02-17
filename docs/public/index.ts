import { Cart, CartOptions, Memory, stdIo } from 'cart-luau';
import file from "!raw-loader!/app.luau"
import type { Inode } from "@bjorn3/browser_wasi_shim";
import { File } from "@bjorn3/browser_wasi_shim";

const shared_mem = new Memory();
let cart: Cart;

async function run() {
    const frame = await fetch("https://alicesaidhi.github.io/vide/frame.luau");
    const datatypes = await fetch("https://alicesaidhi.github.io/vide/datatypes.luau");
    const instance = await fetch("https://alicesaidhi.github.io/vide/instance.luau");
    const vide = await fetch("https://alicesaidhi.github.io/vide/vide.luau");
    

    const fs = new Map<string, Inode>();
    const text = (await instance.text()) + "\n" + (await datatypes.text()) + "\n" + (await frame.text()) + "\n" + (await vide.text()) + "\n"

    console.log("added libraries")

    cart = new Cart(
        new CartOptions({
            memory: shared_mem,
            fds: stdIo("", fs)
        })
    )

    await cart.load("https://alicesaidhi.github.io/vide/cart.wasm");
    const thread = cart.loadThreadFromString("meow", text + file);

    if (!thread.valid) {
        throw new Error("Failed to load example");
    }
    await thread.execute();
}

run()