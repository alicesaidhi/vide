# Sandbox

::: luau-sandbox {template=vanilla-ts}
```ts /index.ts [hidden]
import { Cart, CartOptions, Memory, stdIo } from 'cart-luau';
import file from "!raw-loader!/app.luau"

const shared_mem = new Memory();
let cart: Cart;

async function run() {
    cart = new Cart(
        new CartOptions({
            memory: shared_mem,
        })
    )

    await cart.load("http://localhost:5173/vide/cart.wasm");
    const thread = cart.loadThreadFromString("meow", file);

    if (!thread.valid) {
        throw new Error("Failed to load example");
    }
    await thread.execute();
}

run()
```

```luau /app.luau [active]
print("This sucks")
```

:::