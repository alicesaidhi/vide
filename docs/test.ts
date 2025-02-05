import { Cart, CartOptions, Memory, stdIo } from 'cart-luau';
import "./a."

const shared_mem = new Memory();
let cart: Cart;
cart.wasi.

async function run() {
    cart = new Cart(
        new CartOptions({
            memory: shared_mem,
        })
    )
    const response = await fetch("/vide/");
    console.log(response.text())

    await cart.load("https://github.com/lodinukal/cart/releases/latest/download/cart.wasm");
    const thread = cart.loadThreadFromString("meow", `
print("This is horrible.")     
`);

    if (!thread.valid) {
        throw new Error("Failed to load example");
    }
    await thread.execute();
}

run()