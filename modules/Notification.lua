local Notification = {}

local LibraryRef = nil
local UtilsRef = nil
local ScreenGui = nil
local NotifHolder = nil

function Notification.init(library, utils)
    LibraryRef = library
    UtilsRef = utils
end

function Notification.setScreenGui(sg)
    ScreenGui = sg
    if not NotifHolder then
        NotifHolder = UtilsRef.New("Frame", {
            Name = "NotifHolder",
            Size = UDim2.new(0, 292, 1, 0),
            Position = UDim2.new(1, -300, 0, 0),
            BackgroundTransparency = 1,
            Parent = ScreenGui,
        })
        local l = UtilsRef.ListLayout(NotifHolder, 8)
        l.VerticalAlignment = Enum.VerticalAlignment.Bottom
        l.HorizontalAlignment = Enum.HorizontalAlignment.Right
        UtilsRef.Padding(NotifHolder, 8, 8, 0, 8)
    end
end

function Notification.notify(opts)
    local theme = LibraryRef.Themes[LibraryRef.CurrentTheme]
    local title = opts.Title or "Notification"
    local message = opts.Message or ""
    local duration = opts.Duration or 4
    local ntype = opts.Type or "Info"

    local colorMap = {
        Info = theme.Accent,
        Success = Color3.fromRGB(38, 200, 105),
        Warning = Color3.fromRGB(238, 170, 28),
        Error = Color3.fromRGB(220, 55, 65),
    }
    local ac = colorMap[ntype] or theme.Accent

    local card = UtilsRef.New("Frame", {
        Name = "Notif",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.Secondary,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = NotifHolder,
    })
    UtilsRef.Corner(card, 8, LibraryRef)
    UtilsRef.Stroke(card, theme.Outline)

    UtilsRef.New("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = ac,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = card,
    })

    local inner = UtilsRef.New("Frame", {
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -10, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = card,
    })
    UtilsRef.Padding(inner, 8, 8, 4, 8)
    UtilsRef.ListLayout(inner, 3)

    UtilsRef.New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = inner,
    })
    UtilsRef.New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = theme.SubText,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = inner,
    })

    local progressBG = UtilsRef.New("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = theme.Outline,
        BorderSizePixel = 0,
        Parent = card,
    })
    local progressFill = UtilsRef.New("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = ac,
        BorderSizePixel = 0,
        Parent = progressBG,
    })

    UtilsRef.Tween(card, { BackgroundTransparency = 0 }, 0.25, Enum.EasingStyle.Quint)
    UtilsRef.Tween(progressFill, { Size = UDim2.new(0, 0, 1, 0) }, duration, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        UtilsRef.Tween(card, { BackgroundTransparency = 1 }, 0.3)
        task.delay(0.32, function() pcall(function() card:Destroy() end) end)
    end)
end

return Notification
