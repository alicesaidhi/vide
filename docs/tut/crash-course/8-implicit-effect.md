# Implicit Effects

Explicitly creating effects to update properties is tedious. You can
*implicitly* create an effect to update properties instead.

::: tabs

== Implicit effect

::: luau-sandbox {template=vanilla-ts}
<<< @/public/index.ts{#hidden}
<<< @/public/cart.wasm{#hidden}
<<< @/public/bundle.luau{#hidden}

```luau /app.luau [active]
local create = vide.create
local source = vide.source

local function Counter()
    local count = source(0)

    return create "TextButton" {
        Size = UDim2.fromOffset(100, 50),
        TextSize = 16,
        Activated = function()
            count(count() + 1)
        end,

        Text = function()
            return "count: " .. count()
        end
    }
end

return vide.mount(Counter, create "ScreenGui" {})
```
:::
::: tabs
== Explicit Effect

::: luau-sandbox {template=vanilla-ts}
<<< @/public/index.ts{#hidden}
<<< @/public/cart.wasm{#hidden}
<<< @/public/bundle.luau{#hidden}

```luau /app.luau [active]
local create = vide.create
local source = vide.source
local effect = vide.effect

local function Counter()
    local count = source(0)

    local instance = create "TextButton" {
        Size = UDim2.fromOffset(100, 50),
        TextSize = 16,
        Activated = function()
            count(count() + 1)
        end
    }

    effect(function()
        instance.Text = "count: " .. count()
    end)

    return instance
end

return vide.mount(Counter, create "ScreenGui" {})
```
:::

This example is equivalent to the example seen on the previous page.

Instead of explicitly creating an effect, assigning a (non-event) property a
function will implicitly create an effect to update that property.

## Children

Children can also be set in a similar manner. A source passed as a child (passed
with a number key instead of string key) can return an instance or an array of
instances. An effect is automatically created to unparent removed instances and
parent new instances on source update.

::: luau-sandbox {template=vanilla-ts}
<<< @/public/index.ts{#hidden}
<<< @/public/cart.wasm{#hidden}
<<< @/public/bundle.luau{#hidden}

```luau /app.luau [active]
local task = require("@cart/task")
local source = vide.source
local create = vide.create

local items = source {
    create "TextLabel" {
        Size = UDim2.fromOffset(50, 100),
        TextSize = 18,
        Text = "A"
    }
}

local function List(props: { children: () -> { Instance } })
    return create "Frame" {
        create "UIListLayout" {},
        props.children
    }
end

vide.mount(function()
    local list = List { children = items } -- creates a list with text label "A"

    task.delay(3, function()
        items {
            create "TextLabel" {
                Size = UDim2.fromOffset(50, 100),
                TextSize = 18,
                Text = "B"
            },
            create "TextLabel" {
                Size = UDim2.fromOffset(50, 100),
                TextSize = 18,
                Text = "C"
            }
        }
    end)

    return list
end, create "ScreenGui" {})

-- this will automatically unparent text label "A", and parent labels "B" and "C"
```
