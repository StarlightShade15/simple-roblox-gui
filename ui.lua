local UILib = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local function new(class, props)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do
        o[k] = v
    end
    return o
end

local function tween(o, p, t)
    if not o or not p then return end
    local ok, tk = pcall(function()
        return TweenService:Create(o, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p)
    end)
    if ok and tk then
        pcall(function() tk:Play() end)
    end
end

function UILib.init(title)
    local Window = {}
    local parentGui
    local localPlayer = Players.LocalPlayer
    if localPlayer and localPlayer:FindFirstChild("PlayerGui") then
        parentGui = localPlayer:FindFirstChild("PlayerGui")
    else
        parentGui = game:GetService("CoreGui")
    end

    local sg = new("ScreenGui", { Parent = parentGui, ResetOnSpawn = false, IgnoreGuiInset = true })
    local main = new("Frame", {
        Parent = sg,
        Size = UDim2.new(0, 700, 0, 420),
        Position = UDim2.new(0.5, -350, 0.5, -210),
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        BorderSizePixel = 0,
        Active = true
    })

    local dragging, dragStart, startPos
    main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = main.Position
        end
    end)
    main.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local top = new("TextLabel", {
        Parent = main,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = tostring(title or ""),
        TextSize = 18,
        TextColor3 = Color3.new(1, 1, 1)
    })

    local tabbar = new("Frame", {
        Parent = main,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(0, 140, 1, -40),
        BackgroundColor3 = Color3.fromRGB(32, 32, 32),
        BorderSizePixel = 0
    })

    local tablist = new("UIListLayout", {
        Parent = tabbar,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6)
    })

    new("UIPadding", { Parent = tabbar, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })

    local pages = new("Frame", {
        Parent = main,
        Position = UDim2.new(0, 140, 0, 40),
        Size = UDim2.new(1, -140, 1, -40),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0
    })

    Window.Tabs = {}
    Window.Active = nil

    function Window:addTab(name)
        local Tab = {}

        local btn = new("TextButton", {
            Parent = tabbar,
            Size = UDim2.new(1, -20, 0, 34),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            BorderSizePixel = 0,
            Font = Enum.Font.GothamBold,
            Text = name,
            TextSize = 14,
            TextColor3 = Color3.new(1, 1, 1)
        })

        local page = new("ScrollingFrame", {
            Parent = pages,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 6,
            Visible = false
        })

        local pageLayout = new("UIListLayout", { Parent = page, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder })

        new("UIPadding", { Parent = page, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })

        btn.MouseButton1Click:Connect(function()
            if Window.Active then
                Window.Active.page.Visible = false
            end
            page.Visible = true
            Window.Active = { page = page, btn = btn }
        end)

        function Tab:addSection(secName)
            local Sec = {}

            local holder = new("Frame", {
                Parent = page,
                Size = UDim2.new(1, -20, 0, 50),
                BackgroundColor3 = Color3.fromRGB(32, 32, 32),
                BorderSizePixel = 0
            })

            local title = new("TextLabel", {
                Parent = holder,
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = Color3.fromRGB(45, 45, 45),
                BorderSizePixel = 0,
                Font = Enum.Font.GothamBold,
                Text = secName,
                TextSize = 14,
                TextColor3 = Color3.new(1, 1, 1)
            })

            local body = new("Frame", {
                Parent = holder,
                Position = UDim2.new(0, 0, 0, 28),
                Size = UDim2.new(1, 0, 1, -28),
                BackgroundTransparency = 1
            })

            local lay = new("UIListLayout", { Parent = body, Padding = UDim.new(0, 7) })

            lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                task.defer(function()
                    holder.Size = UDim2.new(1, -20, 0, lay.AbsoluteContentSize.Y + 35)
                end)
            end)

            pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                task.defer(function()
                    page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 20)
                end)
            end)

            function Sec:addCheck(cfg)
                local b = new("TextButton", {
                    Parent = body,
                    Size = UDim2.new(1, -10, 0, 28),
                    BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                    Font = Enum.Font.Gotham,
                    Text = cfg.Text or "",
                    TextSize = 14,
                    TextColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0
                })

                local state = cfg.Default and true or false

                local ind = new("Frame", {
                    Parent = b,
                    Size = UDim2.new(0, 22, 0, 22),
                    Position = UDim2.new(1, -26, 0.5, -11),
                    BackgroundColor3 = state and Color3.fromRGB(0, 255, 80) or Color3.fromRGB(80, 80, 80),
                    BorderSizePixel = 0
                })

                b.MouseButton1Click:Connect(function()
                    state = not state
                    tween(ind, { BackgroundColor3 = state and Color3.fromRGB(0, 255, 80) or Color3.fromRGB(80, 80, 80) }, 0.15)
                    if cfg.Callback then cfg.Callback(state) end
                end)
            end

            return Sec
        end

        Window.Tabs[name] = { page = page, btn = btn }

        if not Window.Active then
            page.Visible = true
            Window.Active = { page = page, btn = btn }
        end

        return Tab
    end

    return Window
end

return UILib
