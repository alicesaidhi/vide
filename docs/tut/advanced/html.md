# Sandbox

::: luau-sandbox {template=vanilla-ts}
<<< @/public/index.ts{#hidden}

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