import { Cart, CartOptions, Memory, stdIo } from 'cart-luau';
import file from "!raw-loader!/app.luau"
import single from "!raw-loader!/vide.luau"
import type { Inode } from "@bjorn3/browser_wasi_shim";
import { File } from "@bjorn3/browser_wasi_shim";


const shared_mem = new Memory();
let cart: Cart;

async function run() {

    const fs = new Map<string, Inode>();

    cart = new Cart(
        new CartOptions({
            memory: shared_mem,
            fds: stdIo("", fs)
        })
    )

    await cart.load("/vide/cart.wasm");
    const thread = cart.loadThreadFromString("meow", single + "\n" + file);

    if (!thread.valid) {
        throw new Error("Failed to load example");
    }
    await thread.execute();
// }

run()