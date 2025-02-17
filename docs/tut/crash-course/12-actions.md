# Actions

Actions are special callbacks that you can pass along with properties,
to run some code on an instance receiving them.


::: luau-sandbox {template=vanilla-ts}
<<< @/public/index.ts{#hidden}

```luau /app.luau [active]
local create = vide.create
local action = vide.action

create "TextLabel" {
    Text = "test",

    action(function(instance)
        print(instance.Text)
    end)
}

-- will print "test"
```
:::

Actions can be wrapped with functions for reuse. Below is an example of an
action used to listen for property changes:


::: luau-sandbox {template=vanilla-ts}
<<< @/public/index.ts{#hidden}

```luau /app.luau [active]
local create = vide.create
local action = vide.action
local source = vide.source
local effect = vide.effect
local cleanup = vide.cleanup

local function changed(property: string, callback: (new) -> ())
    return action(function(instance)
        local connection = instance:GetPropertyChangedSignal(property):Connect(function()
            callback(instance[property])
        end)

        -- remember to clean up the connection when the reactive scope the action
        -- is ran in is destroyed, so the instance can be garbage collected
        cleanup(connection)
    end)
end

local output = source ""

local instance = create "TextBox" {
    Size = UDim2.fromOffset(100, 50),
    -- changed("Text", output)
}

-- effect(function()
--     print(output())
-- end)

instance.Text = "foo" -- "foo" will be printed by the effect
instance.Parent = create "ScreenGui" {}
```
:::

The source `output` will be updated with the new property value any time it is
changed externally.
