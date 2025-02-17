
local web = require("@cart/web")


-- local task = require("@cart/task")

local document = web.global("document")
local body = document:get("body")

Instance.add_proxy("ScreenGui", function()
    return {
        name = "UNNAMED",
        parent = nil,
        children = {},
        changed = {},
        properties = {
            _handle = body
        },
        class = "ScreenGui",
        changed_signal = Signal.new() :: any,
        destroying = Signal.new() :: any,
        type = "Instance" :: "Instance"
    }
end)

Instance.add_proxy("Frame", function()

    return {
        name = "UNNAMED",
        parent = nil,
        children = {},
        changed = {},
        properties = {
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 0, 0, 0),
            AnchorPoint = Vector2.new(0, 0),

            BackgroundTransparency = 0,
            BackgroundColor3 = Color3.new(0.6, 0.6, 0.6),
        },
        class = "Frame",
        changed_signal = Signal.new() :: any,
        destroying = Signal.new() :: any,
        type = "Instance" :: "Instance"
    }, function(instance: any)
        local handle = document:invoke("createElement", "div")
        local instance: Frame = instance
        local dirty = true

        instance._handle = handle

        print("created")
        local function rerender()
            print("rendering")
            local declaration = handle:get("style")
            local size = instance.Size
            local position = instance.Position
            local anchor_point = instance.AnchorPoint

            local bgcolor = instance.BackgroundColor3
            local bg = `rgba({bgcolor.R * 255}, {bgcolor.G * 255}, {bgcolor.B * 255}, {1 - instance.BackgroundTransparency})`
            local swidth = `calc({size.x.scale * 100}% + {size.x.offset}px)`
            local sheight = `calc({size.y.scale * 100}% + {size.y.offset}px)`
            local stop = `calc({position.x.scale * 100}% + {position.x.offset}px)`
            local sleft = `calc({position.y.scale * 100}% + {position.y.offset}px)`
            local stransform = `translate({anchor_point.X * -100}%, {anchor_point.Y * -100}%)`

            declaration:invoke("setProperty", "background-color", bg)
            declaration:invoke("setProperty", "top", stop)
            declaration:invoke("setProperty", "left", sleft)
            declaration:invoke("setProperty", "width", swidth)
            declaration:invoke("setProperty", "height", sheight)
            declaration:invoke("setProperty", "transform", stransform)
            declaration:invoke("setProperty", "position", "relative")

            local parent = instance.Parent
            
            if parent and parent.properties._handle then
                parent.properties._handle:invoke("appendChild", handle)
            else
                handle:invoke("remove")
            end

            dirty = false
            declaration:release()
        end

        instance:GetPropertyChangedSignal("Position"):Connect(rerender)
        instance:GetPropertyChangedSignal("Size"):Connect(rerender)
        instance:GetPropertyChangedSignal("BackgroundColor3"):Connect(rerender)
        instance:GetPropertyChangedSignal("BackgroundTransparency"):Connect(rerender)
        instance:GetPropertyChangedSignal("AnchorPoint"):Connect(rerender)
        instance:GetPropertyChangedSignal("Parent"):Connect(rerender)
        
    end
end)

Instance.add_proxy("TextLabel", function()

    return {
        name = "UNNAMED",
        parent = nil,
        children = {},
        changed = {},
        properties = {
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 0, 0, 0),
            AnchorPoint = Vector2.new(0, 0),

            BackgroundTransparency = 0,
            BackgroundColor3 = Color3.new(0.6, 0.6, 0.6),

            Text = "",
            TextSize = 8,
            TextTransparency = 0,
            TextColor3 = Color3.new(0, 0, 0)
        },
        class = "TextLabel",
        changed_signal = Signal.new() :: any,
        destroying = Signal.new() :: any,
        type = "Instance" :: "Instance"
    }, function(instance: any)
        local handle = document:invoke("createElement", "div")
        local p = document:invoke("createElement", "p")

        handle:invoke("appendChild", p)

        local instance: TextLabel = instance
        local dirty = true

        instance._handle = handle
        instance._p = p

        local function rerender()
            local declaration = handle:get("style")
            if declaration == nil then error("no declaration fuond") end
            
            local size = instance.Size
            local position = instance.Position
            local anchor_point = instance.AnchorPoint

            local bgcolor = instance.BackgroundColor3
            local bg = `rgba({bgcolor.R * 255}, {bgcolor.G * 255}, {bgcolor.B * 255}, {1 - instance.BackgroundTransparency})`
            local swidth = `calc({size.x.scale * 100}% + {size.x.offset}px)`
            local sheight = `calc({size.y.scale * 100}% + {size.y.offset}px)`
            local stop = `calc({position.x.scale * 100}% + {position.x.offset}px)`
            local sleft = `calc({position.y.scale * 100}% + {position.y.offset}px)`
            local stransform = `translate({anchor_point.X * -100}%, {anchor_point.Y * -100}%)`

            declaration:invoke("setProperty", "background-color", bg)
            declaration:invoke("setProperty", "top", stop)
            declaration:invoke("setProperty", "left", sleft)
            declaration:invoke("setProperty", "width", swidth)
            declaration:invoke("setProperty", "height", sheight)
            declaration:invoke("setProperty", "transform", stransform)
            declaration:invoke("setProperty", "position", "relative")

            local declaration = p:get("style")
            local textColor = instance.TextColor3
            local textSize = instance.TextSize
            local text = instance.Text or ""
            -- print("rerender", text)
            p:set("textContent", text)
            declaration:invoke("setProperty", "color", `rgba({textColor.R * 255}, {textColor.G * 255}, {textColor.B * 255}, {1 - instance.TextTransparency})`)
            declaration:invoke("setProperty", "font-size", `{textSize}px`)

            local parent = instance.Parent
            
            if parent and parent.properties._handle then
                parent.properties._handle:invoke("appendChild", handle)
            else
                handle:invoke("remove")
            end

            declaration:release()
            dirty = false
        end

        instance:GetPropertyChangedSignal("Position"):Connect(rerender)
        instance:GetPropertyChangedSignal("Size"):Connect(rerender)
        instance:GetPropertyChangedSignal("BackgroundColor3"):Connect(rerender)
        instance:GetPropertyChangedSignal("BackgroundTransparency"):Connect(rerender)
        instance:GetPropertyChangedSignal("AnchorPoint"):Connect(rerender)
        instance:GetPropertyChangedSignal("Parent"):Connect(rerender)
        instance:GetPropertyChangedSignal("Text"):Connect(rerender)
        instance:GetPropertyChangedSignal("TextSize"):Connect(rerender)
        instance:GetPropertyChangedSignal("TextTransparency"):Connect(rerender)
        instance:GetPropertyChangedSignal("TextColor3"):Connect(rerender)
        
    end
end)

Instance.add_proxy("TextButton", function()

    return {
        name = "UNNAMED",
        parent = nil,
        children = {},
        changed = {},
        properties = {
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 0, 0, 0),
            AnchorPoint = Vector2.new(0, 0),

            BackgroundTransparency = 0,
            BackgroundColor3 = Color3.new(0.6, 0.6, 0.6),

            Text = "",
            TextSize = 8,
            TextTransparency = 0,
            TextColor3 = Color3.new(0, 0, 0)
        },
        class = "TextButton",
        changed_signal = Signal.new() :: any,
        destroying = Signal.new() :: any,
        type = "Instance" :: "Instance"
    }, function(instance: any)
        local handle = document:invoke("createElement", "button")
        local p = document:invoke("createElement", "p")
        local activated = Signal.new() :: any

        instance.Activated = activated

        handle:invoke("appendChild", p)

        local instance: TextButton = instance
        local dirty = true

        instance._handle = handle

        local function rerender()
            local declaration = handle:get("style")
            
            local size = instance.Size
            local position = instance.Position
            local anchor_point = instance.AnchorPoint

            local bgcolor = instance.BackgroundColor3
            local bg = `rgba({bgcolor.R * 255}, {bgcolor.G * 255}, {bgcolor.B * 255}, {1 - instance.BackgroundTransparency})`
            local swidth = `calc({size.x.scale * 100}% + {size.x.offset}px)`
            local sheight = `calc({size.y.scale * 100}% + {size.y.offset}px)`
            local stop = `calc({position.x.scale * 100}% + {position.x.offset}px)`
            local sleft = `calc({position.y.scale * 100}% + {position.y.offset}px)`
            local stransform = `translate({anchor_point.X * -100}%, {anchor_point.Y * -100}%)`

            declaration:invoke("setProperty", "background-color", bg)
            declaration:invoke("setProperty", "top", stop)
            declaration:invoke("setProperty", "left", sleft)
            declaration:invoke("setProperty", "width", swidth)
            declaration:invoke("setProperty", "height", sheight)
            declaration:invoke("setProperty", "transform", stransform)
            declaration:invoke("setProperty", "position", "relative")

            local declaration = p:get("style")
            local textColor = instance.TextColor3
            local textSize = instance.TextSize
            local text = tostring(instance.Text or "")
            p:set("textContent", text)
            declaration:invoke("setProperty", "color", `rgba({textColor.R * 255}, {textColor.G * 255}, {textColor.B * 255}, {1 - instance.TextTransparency})`)
            declaration:invoke("setProperty", "font-size", `{textSize}px`)

            local parent = instance.Parent
            
            if parent and parent.properties._handle then
                parent.properties._handle:invoke("appendChild", handle)
            else
                handle:invoke("remove")
            end

            declaration:release()
            dirty = false
        end
        
        local function fire()
            Signal.fire(activated, true)
        end
        handle:invoke("addEventListener", "click", web.marshal(fire))

        instance:GetPropertyChangedSignal("Position"):Connect(rerender)
        instance:GetPropertyChangedSignal("Size"):Connect(rerender)
        instance:GetPropertyChangedSignal("BackgroundColor3"):Connect(rerender)
        instance:GetPropertyChangedSignal("BackgroundTransparency"):Connect(rerender)
        instance:GetPropertyChangedSignal("AnchorPoint"):Connect(rerender)
        instance:GetPropertyChangedSignal("Parent"):Connect(rerender)
        instance:GetPropertyChangedSignal("Text"):Connect(rerender)
        instance:GetPropertyChangedSignal("TextSize"):Connect(rerender)
        instance:GetPropertyChangedSignal("TextTransparency"):Connect(rerender)
        instance:GetPropertyChangedSignal("TextColor3"):Connect(rerender)
        
    end
end)

Instance.add_proxy("TextBox", function()

    return {
        name = "UNNAMED",
        parent = nil,
        children = {},
        changed = {},
        properties = {
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 0, 0, 0),
            AnchorPoint = Vector2.new(0, 0),

            BackgroundTransparency = 0,
            BackgroundColor3 = Color3.new(0.6, 0.6, 0.6),

            Text = "",
            TextSize = 8,
            TextTransparency = 0,
            TextColor3 = Color3.new(0, 0, 0)
        },
        class = "TextBox",
        changed_signal = Signal.new() :: any,
        destroying = Signal.new() :: any,
        type = "Instance" :: "Instance"
    }, function(instance: any)
        local handle = document:invoke("createElement", "input")

        handle:invoke("setAttribute", "type", "text")

        local instance: TextButton = instance
        local p
        local dirty = true

        instance._handle = handle

        local function rerender()
            local declaration = handle:get("style")
            
            local size = instance.Size
            local position = instance.Position
            local anchor_point = instance.AnchorPoint

            local bgcolor = instance.BackgroundColor3
            local bg = `rgba({bgcolor.R * 255}, {bgcolor.G * 255}, {bgcolor.B * 255}, {1 - instance.BackgroundTransparency})`
            local swidth = `calc({size.x.scale * 100}% + {size.x.offset}px)`
            local sheight = `calc({size.y.scale * 100}% + {size.y.offset}px)`
            local stop = `calc({position.x.scale * 100}% + {position.x.offset}px)`
            local sleft = `calc({position.y.scale * 100}% + {position.y.offset}px)`
            local stransform = `translate({anchor_point.X * -100}%, {anchor_point.Y * -100}%)`

            declaration:invoke("setProperty", "background-color", bg)
            declaration:invoke("setProperty", "top", stop)
            declaration:invoke("setProperty", "left", sleft)
            declaration:invoke("setProperty", "width", swidth)
            declaration:invoke("setProperty", "height", sheight)
            declaration:invoke("setProperty", "transform", stransform)
            declaration:invoke("setProperty", "position", "relative")

            -- local textColor = instance.TextColor3
            -- local textSize = instance.TextSize
            -- -- local text = tostring(instance.Text or "")
            -- -- handle:invoke("setAttribute", "value", text)
            -- declaration:invoke("setProperty", "color", `rgba({textColor.R * 255}, {textColor.G * 255}, {textColor.B * 255}, {1 - instance.TextTransparency})`)
            -- declaration:invoke("setProperty", "font-size", `{textSize}px`)

            local parent = instance.Parent
            
            if parent and parent.properties._handle then
                parent.properties._handle:invoke("appendChild", handle)
            else
                handle:invoke("remove")
            end

            declaration:release()
            dirty = false
        end
        
        local function fire(new)
            local s = tostring(new)
            print(s)
            -- Signal.fire(activated, true)
        end
        handle:invoke("addEventListener", "input", web.marshal(fire))

        instance:GetPropertyChangedSignal("Position"):Connect(rerender)
        instance:GetPropertyChangedSignal("Size"):Connect(rerender)
        instance:GetPropertyChangedSignal("BackgroundColor3"):Connect(rerender)
        instance:GetPropertyChangedSignal("BackgroundTransparency"):Connect(rerender)
        instance:GetPropertyChangedSignal("AnchorPoint"):Connect(rerender)
        instance:GetPropertyChangedSignal("Parent"):Connect(rerender)
        instance:GetPropertyChangedSignal("Text"):Connect(rerender)
        instance:GetPropertyChangedSignal("TextSize"):Connect(rerender)
        instance:GetPropertyChangedSignal("TextTransparency"):Connect(rerender)
        instance:GetPropertyChangedSignal("TextColor3"):Connect(rerender)
        
    end
end)


Instance.add_proxy("UIListLayout", function()

    return {
        name = "UNNAMED",
        parent = nil,
        children = {},
        changed = {},
        properties = {
            Padding = UDim.new(0, 0)
        },
        class = "UIListLayout",
        changed_signal = Signal.new() :: any,
        destroying = Signal.new() :: any,
        type = "Instance" :: "Instance"
    }, function(instance: any)
        print("creating uilist")
        local handle = document:invoke("createElement", "div")
        local declaration = handle:get("style")
        declaration:invoke("setProperty", "display", "none")
        declaration:release()

        local instance: UIListLayout = instance
        local dirty = true

        instance._handle = handle
        local previous_parent = nil

        local function rerender()
            local parent = instance.Parent
                        
            if parent and parent.properties._handle then
                local declaration = parent.properties._handle:get("style")
                parent.properties._handle:invoke("appendChild", handle)
                declaration:invoke("setProperty", "display", "flex")
                declaration:invoke("setProperty", "gap", `calc({instance.Padding.scale}% + {instance.Padding.offset}px)`)
                declaration:invoke("setProperty", "flex-direction", "column")
                declaration:release()
            else
                handle:invoke("remove")
            end

            if previous_parent ~= parent and previous_parent and previous_parent.properties._handle then
                local declaration = previous_parent._handle:get("style")
                declaration:invoke("removeProperty", "display")
                declaration:release()
            end

            previous_parent = parent
            dirty = false
        end

        instance:GetPropertyChangedSignal("Padding"):Connect(rerender)
        instance:GetPropertyChangedSignal("Parent"):Connect(rerender)
        
    end
end)