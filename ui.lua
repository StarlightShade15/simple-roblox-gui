local lib = {}

local function c(o, p)
    for k, v in pairs(p) do
        o[k] = v
    end
    return o
end

function lib.makeText(parent, text, size, color)
    local l = Instance.new("TextLabel")
    c(l, {
        Parent = parent,
        Text = text,
        Size = UDim2.new(0, size.X, 0, size.Y),
        BackgroundTransparency = 1,
        TextColor3 = color or Color3.new(1, 1, 1),
        TextScaled = true
    })
    return l
end

function lib.makeRect(parent, size, bg, stroke, corner)
    local f = Instance.new("Frame")
    c(f, {
        Parent = parent,
        Size = UDim2.new(0, size.X, 0, size.Y),
        BackgroundColor3 = bg
    })

    local s = Instance.new("UIStroke")
    s.Thickness = 1
    s.Color = stroke or bg
    s.Parent = f

    if corner and corner > 0 then
        local u = Instance.new("UICorner")
        u.CornerRadius = UDim.new(0, corner)
        u.Parent = f
    end

    return f
end

function lib.Init(title, corner)
    local gui = Instance.new("ScreenGui")
    gui.Parent = game.CoreGui

    local mainFrame = lib.makeRect(gui, Vector2.new(400, 300), Color3.fromRGB(30, 30, 30), nil, corner or 10)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)

    local header = lib.makeText(mainFrame, title or "Window", Vector2.new(400, 40), Color3.new(1,1,1))
    header.Position = UDim2.new(0,0,0,0)

    local content = Instance.new("Frame")
    c(content, {
        Parent = mainFrame,
        Size = UDim2.new(1, -20, 1, -60),
        Position = UDim2.new(0, 10, 0, 50),
        BackgroundTransparency = 1
    })

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content

    return {
        gui = gui,
        frame = mainFrame,
        content = content,
        addButton = function(self, text, callback)
            local b = lib.makeRect(content, Vector2.new(0, 40), Color3.fromRGB(50,50,50), nil, 5)
            local label = lib.makeText(b, text, Vector2.new(0,40), Color3.new(1,1,1))
            label.Size = UDim2.new(1,0,1,0)
            b.MouseButton1Click = callback or function() end
            return b
        end,
        addToggle = function(self, text, default, callback)
            local f = lib.makeRect(content, Vector2.new(0, 30), Color3.fromRGB(50,50,50), nil, 5)
            local lbl = lib.makeText(f, text, Vector2.new(0,30), Color3.new(1,1,1))
            lbl.Size = UDim2.new(0.7,0,1,0)
            local box = lib.makeRect(f, Vector2.new(20,20), default and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0), nil, 3)
            box.Position = UDim2.new(0.75,0,0.5,-10)
            local toggled = default
            f.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    toggled = not toggled
                    box.BackgroundColor3 = toggled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
                    if callback then callback(toggled) end
                end
            end)
            return f
        end,
        addSlider = function(self, text, min, max, default, callback)
            local f = lib.makeRect(content, Vector2.new(0, 40), Color3.fromRGB(50,50,50), nil, 5)
            local lbl = lib.makeText(f, text, Vector2.new(200, 40), Color3.new(1,1,1))
            lbl.Position = UDim2.new(0,5,0,0)
            local bar = lib.makeRect(f, Vector2.new(150, 20), Color3.fromRGB(100,100,100), nil, 5)
            bar.Position = UDim2.new(0, 220, 0.5, -10)
            local fill = lib.makeRect(bar, Vector2.new(150 * ((default - min)/(max - min)), 20), Color3.fromRGB(0,255,0), nil, 5)
            local dragging = false
            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
            end)
            bar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            game:GetService("UserInputService").InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = math.clamp(input.Position.X - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
                    fill.Size = UDim2.new(0, pos, 1, 0)
                    local val = min + ((pos/bar.AbsoluteSize.X) * (max - min))
                    if callback then callback(val) end
                end
            end)
            return f
        end
    }
end

return lib
