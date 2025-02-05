# Sandbox

::: luau-sandbox {template=vanilla-ts}
```ts /index.ts [hidden]
import { Cart, CartOptions, Memory, stdIo } from 'cart-luau';
import file from "!raw-loader!/app.luau"
import type { Inode } from "@bjorn3/browser_wasi_shim";
import { File } from "@bjorn3/browser_wasi_shim";

const shared_mem = new Memory();
let cart: Cart;

async function run() {
    const frame = await fetch("http://localhost:5173/vide/frame.luau");
    const datatypes = await fetch("http://localhost:5173/vide/datatypes.luau");
    const instance = await fetch("http://localhost:5173/vide/instance.luau");
    const vide = await fetch("http://localhost:5173/vide/vide.luau");

    const fs = new Map<string, Inode>();
    const text = (await instance.text()) + "\n" + (await datatypes.text()) + "\n" + (await frame.text()) + "\n" + (await vide.text()) + "\n"

    console.log("added libraries")

    cart = new Cart(
        new CartOptions({
            memory: shared_mem,
            fds: stdIo("", fs)
        })
    )

    await cart.load("http://localhost:5173/vide/cart.wasm");
    const thread = cart.loadThreadFromString("meow", text + file);

    if (!thread.valid) {
        throw new Error("Failed to load example");
    }
    await thread.execute();
}

run()
```

```luau /app.luau [active]
local create = vide.create

create "ScreenGui" {
  create "Frame" {
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Color3.new(1, 0, 0),
    Size = UDim2.new(0, 50, 0, 50)  
  }
}
```

:::