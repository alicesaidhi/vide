# Creating UI

Instances are created using `create()`.

Parentheses `()` can be omitted when calling functions with string or
table literals for brevity.

::: luau-sandbox {template=vanilla-ts}
<<< @/public/index.ts{#hidden}
<<< @/public/cart.wasm{#hidden}
<<< @/public/bundle.luau{#hidden}

```luau /app.luau [active]
local create = vide.create

return create "ScreenGui" {
    create "Frame" {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.4, 0.7),

          create "UIListLayout" { Padding = UDim.new(0, 32) },

        create "TextLabel" {
          Size = UDim2.fromOffset(200, 50),
            Text = "hiiiii"
        },

        create "TextLabel" {
          Size = UDim2.fromOffset(200, 50),
            Text = "bye"
        },

        create "TextButton" {
          Size = UDim2.fromOffset(200, 50),
            Text = "click me",

            Activated = function()
                print "clicked!"
            end
        }
    }
}
```
:::

Assign a value to a string key to set a property, and assign a value to a
number key to set a child. Events can be connected to by assigning a function
to a string key.
