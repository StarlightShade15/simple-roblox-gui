-- ============================================================
--   ██╗   ██╗██╗    ██╗██╗     ██╗██████╗ 
--   ██║   ██║██║    ██║██║     ██║██╔══██╗
--   ██║   ██║██║    ██║██║     ██║██████╔╝
--   ██║   ██║██║    ██║██║     ██║██╔══██╗
--   ╚██████╔╝██║    ██║███████╗██║██████╔╝
--    ╚═════╝ ╚═╝    ╚═╝╚══════╝╚═╝╚═════╝ 
--
--   Neverlose-Style Premium UI Library
--   Single-file, self-contained framework
--   (Fixed dropdown Z‑index & clipping)
--
--   Usage:
--     local UI = loadstring(game:HttpGet("https://example.com/UILibrary.lua"))()
--     local Window = UI:CreateWindow({ Title = "My Script", ToggleKey = Enum.KeyCode.RightShift })
--
-- ============================================================

local Library = {}
Library.__index = Library

-- ──────────────────── Services ────────────────────────────
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local Players           = game:GetService("Players")
local HttpService       = game:GetService("HttpService")
local TextService       = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer

-- ──────────────────── Theme Definitions ───────────────────
Library.Themes = {
    Dark = {
        Background  = Color3.fromRGB(15,  15,  21),
        Secondary   = Color3.fromRGB(21,  21,  30),
        Tertiary    = Color3.fromRGB(28,  28,  40),
        Accent      = Color3.fromRGB(99,  80,  220),
        AccentDark  = Color3.fromRGB(68,  55,  160),
        AccentGlow  = Color3.fromRGB(130, 110, 255),
        Text        = Color3.fromRGB(218, 218, 230),
        SubText     = Color3.fromRGB(135, 135, 160),
        Outline     = Color3.fromRGB(36,  36,  52),
        Element     = Color3.fromRGB(24,  24,  34),
        Scrollbar   = Color3.fromRGB(50,  50,  75),
    },
    Light = {
        Background  = Color3.fromRGB(242, 242, 250),
        Secondary   = Color3.fromRGB(228, 228, 240),
        Tertiary    = Color3.fromRGB(212, 212, 228),
        Accent      = Color3.fromRGB(88,  68,  200),
        AccentDark  = Color3.fromRGB(64,  50,  155),
        AccentGlow  = Color3.fromRGB(120, 100, 230),
        Text        = Color3.fromRGB(22,  22,  35),
        SubText     = Color3.fromRGB(90,  90,  115),
        Outline     = Color3.fromRGB(195, 195, 215),
        Element     = Color3.fromRGB(232, 232, 245),
        Scrollbar   = Color3.fromRGB(160, 160, 195),
    },
    Ice = {
        Background  = Color3.fromRGB(9,   18,  32),
        Secondary   = Color3.fromRGB(13,  25,  44),
        Tertiary    = Color3.fromRGB(17,  32,  54),
        Accent      = Color3.fromRGB(72,  178, 242),
        AccentDark  = Color3.fromRGB(48,  128, 192),
        AccentGlow  = Color3.fromRGB(110, 210, 255),
        Text        = Color3.fromRGB(195, 225, 248),
        SubText     = Color3.fromRGB(110, 160, 205),
        Outline     = Color3.fromRGB(22,  44,  72),
        Element     = Color3.fromRGB(14,  26,  46),
        Scrollbar   = Color3.fromRGB(30,  65,  110),
    },
    Midnight = {
        Background  = Color3.fromRGB(7,   7,   14),
        Secondary   = Color3.fromRGB(11,  11,  22),
        Tertiary    = Color3.fromRGB(15,  15,  30),
        Accent      = Color3.fromRGB(158, 76,  245),
        AccentDark  = Color3.fromRGB(108, 52,  178),
        AccentGlow  = Color3.fromRGB(190, 120, 255),
        Text        = Color3.fromRGB(200, 198, 225),
        SubText     = Color3.fromRGB(115, 112, 148),
        Outline     = Color3.fromRGB(26,  26,  48),
        Element     = Color3.fromRGB(13,  13,  25),
        Scrollbar   = Color3.fromRGB(45,  40,  85),
    },
    Crimson = {
        Background  = Color3.fromRGB(17,  9,   12),
        Secondary   = Color3.fromRGB(25,  13,  17),
        Tertiary    = Color3.fromRGB(32,  17,  21),
        Accent      = Color3.fromRGB(218, 48,  68),
        AccentDark  = Color3.fromRGB(162, 34,  50),
        AccentGlow  = Color3.fromRGB(255, 90,  110),
        Text        = Color3.fromRGB(232, 210, 215),
        SubText     = Color3.fromRGB(158, 128, 138),
        Outline     = Color3.fromRGB(50,  26,  32),
        Element     = Color3.fromRGB(23,  12,  16),
        Scrollbar   = Color3.fromRGB(80,  35,  45),
    },
    Emerald = {
        Background  = Color3.fromRGB(7,   18,  13),
        Secondary   = Color3.fromRGB(11,  26,  19),
        Tertiary    = Color3.fromRGB(14,  33,  24),
        Accent      = Color3.fromRGB(36,  198, 118),
        AccentDark  = Color3.fromRGB(25,  144, 84),
        AccentGlow  = Color3.fromRGB(75,  230, 148),
        Text        = Color3.fromRGB(198, 232, 215),
        SubText     = Color3.fromRGB(116, 165, 142),
        Outline     = Color3.fromRGB(18,  50,  35),
        Element     = Color3.fromRGB(9,   22,  15),
        Scrollbar   = Color3.fromRGB(25,  70,  48),
    },
}

-- ──────────────────── Library State ───────────────────────
Library.CurrentTheme   = "Dark"
Library.CornerRadius   = 6
Library.Font           = Enum.Font.GothamMedium
Library.Scale          = 1
Library.BlurEnabled    = false
Library.Transparency   = 0
Library.RoundedCorners = true
Library.Flags          = {}
Library._windows       = {}
Library._themeListeners = {}

-- ──────────────────── Internal Helpers ────────────────────
local function T()   return Library.Themes[Library.CurrentTheme] end
local function CR()  return Library.RoundedCorners and Library.CornerRadius or 0 end

local function Tween(obj, props, t, style, dir)
    if not obj or not obj.Parent then return end
    TweenService:Create(
        obj,
        TweenInfo.new(t or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props
    ):Play()
end

local function Corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r ~= nil and r or CR())
    c.Parent = parent
    return c
end

local function Padding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    p.Parent = parent
    return p
end

local function ListLayout(parent, spacing, direction, halign, valign)
    local l = Instance.new("UIListLayout")
    l.Padding          = UDim.new(0, spacing or 4)
    l.FillDirection    = direction or Enum.FillDirection.Vertical
    l.SortOrder        = Enum.SortOrder.LayoutOrder
    if halign then l.HorizontalAlignment = halign end
    if valign  then l.VerticalAlignment  = valign  end
    l.Parent = parent
    return l
end

local function New(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            pcall(function() inst[k] = v end)
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local function Stroke(parent, color, thickness)
    return New("UIStroke", {
        Color     = color or T().Outline,
        Thickness = thickness or 1,
        Parent    = parent,
    })
end

local function RegisterListener(fn)
    table.insert(Library._themeListeners, fn)
    return fn
end

local function FireTheme()
    local theme = T()
    for _, fn in ipairs(Library._themeListeners) do
        pcall(fn, theme)
    end
end

-- ──────────────────── ScreenGui Bootstrap ─────────────────
local ScreenGui
do
    local sg = New("ScreenGui", {
        Name            = "UILibrary_vNL",
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        DisplayOrder    = 9999,
        IgnoreGuiInset  = true,
    })
    local ok = pcall(function()
        sg.Parent = game:GetService("CoreGui")
    end)
    if not ok then
        sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    ScreenGui = sg
end

-- ──────────────────── Popup Container (for dropdowns etc.) ─
local PopupContainer = New("Frame", {
    Name = "PopupContainer",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    ZIndex = 1000,
    Parent = ScreenGui,
})

-- ──────────────────── Notification Container ──────────────
local NotifHolder = New("Frame", {
    Name                = "NotifHolder",
    Size                = UDim2.new(0, 292, 1, 0),
    Position            = UDim2.new(1, -300, 0, 0),
    BackgroundTransparency = 1,
    Parent              = ScreenGui,
})
do
    local l = ListLayout(NotifHolder, 8)
    l.VerticalAlignment   = Enum.VerticalAlignment.Bottom
    l.HorizontalAlignment = Enum.HorizontalAlignment.Right
    Padding(NotifHolder, 8, 8, 0, 8)
end

function Library:Notify(opts)
    local theme    = T()
    local title    = opts.Title    or "Notification"
    local message  = opts.Message  or ""
    local duration = opts.Duration or 4
    local ntype    = opts.Type     or "Info"

    local colorMap = {
        Info    = theme.Accent,
        Success = Color3.fromRGB(38, 200, 105),
        Warning = Color3.fromRGB(238, 170, 28),
        Error   = Color3.fromRGB(220, 55, 65),
    }
    local ac = colorMap[ntype] or theme.Accent

    local card = New("Frame", {
        Name                = "Notif",
        Size                = UDim2.new(1, 0, 0, 0),
        AutomaticSize       = Enum.AutomaticSize.Y,
        BackgroundColor3    = theme.Secondary,
        BackgroundTransparency = 1,
        BorderSizePixel     = 0,
        ClipsDescendants    = true,
        Parent              = NotifHolder,
    })
    Corner(card, 8)
    Stroke(card, theme.Outline)

    -- Coloured left strip
    New("Frame", {
        Size             = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = ac,
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = card,
    })

    local inner = New("Frame", {
        Position            = UDim2.new(0, 10, 0, 0),
        Size                = UDim2.new(1, -10, 0, 0),
        AutomaticSize       = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent              = card,
    })
    Padding(inner, 8, 8, 4, 8)
    ListLayout(inner, 3)

    New("TextLabel", {
        Size                = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text                = title,
        TextColor3          = theme.Text,
        Font                = Enum.Font.GothamBold,
        TextSize            = 13,
        TextXAlignment      = Enum.TextXAlignment.Left,
        Parent              = inner,
    })
    New("TextLabel", {
        Size                = UDim2.new(1, 0, 0, 0),
        AutomaticSize       = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text                = message,
        TextColor3          = theme.SubText,
        Font                = Enum.Font.Gotham,
        TextSize            = 12,
        TextXAlignment      = Enum.TextXAlignment.Left,
        TextWrapped         = true,
        Parent              = inner,
    })

    -- Progress bar
    local progressBG = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = theme.Outline,
        BorderSizePixel  = 0,
        Parent           = card,
    })
    local progressFill = New("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = ac,
        BorderSizePixel  = 0,
        Parent           = progressBG,
    })

    -- Animate in
    Tween(card, { BackgroundTransparency = 0 }, 0.25, Enum.EasingStyle.Quint)
    Tween(progressFill, { Size = UDim2.new(0, 0, 1, 0) }, duration, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        Tween(card, { BackgroundTransparency = 1 }, 0.3)
        task.delay(0.32, function() pcall(function() card:Destroy() end) end)
    end)
end

-- ──────────────────── Tooltip ─────────────────────────────
local ToolTipFrame = New("Frame", {
    Name             = "Tooltip",
    Size             = UDim2.new(0, 160, 0, 26),
    BackgroundColor3 = T().Secondary,
    BorderSizePixel  = 0,
    Visible          = false,
    ZIndex           = 9999,
    Parent           = ScreenGui,
})
Corner(ToolTipFrame, 6)
Stroke(ToolTipFrame, T().Outline)
Padding(ToolTipFrame, 0, 0, 8, 8)

local ToolTipLabel = New("TextLabel", {
    Size                = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text                = "",
    TextColor3          = T().Text,
    Font                = Enum.Font.Gotham,
    TextSize            = 12,
    TextXAlignment      = Enum.TextXAlignment.Left,
    ZIndex              = 10000,
    Parent              = ToolTipFrame,
})

RegisterListener(function(t)
    ToolTipFrame.BackgroundColor3 = t.Secondary
    ToolTipLabel.TextColor3       = t.Text
end)

do
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if ToolTipFrame.Visible then
            local mp = UserInputService:GetMouseLocation()
            ToolTipFrame.Position = UDim2.new(0, mp.X + 14, 0, mp.Y + 8)
        end
    end)
end

local function AttachTooltip(element, text)
    if not text or text == "" then return end
    element.MouseEnter:Connect(function()
        local sz = TextService:GetTextSize(text, 12, Enum.Font.Gotham, Vector2.new(400, 50))
        ToolTipFrame.Size = UDim2.new(0, sz.X + 18, 0, 26)
        ToolTipLabel.Text = text
        ToolTipFrame.Visible = true
    end)
    element.MouseLeave:Connect(function()
        ToolTipFrame.Visible = false
    end)
end

-- ──────────────────── Watermark ───────────────────────────
function Library:SetWatermark(text)
    if self._wm then self._wm.Text = text; return end
    local theme = T()
    local bg = New("Frame", {
        Name             = "Watermark",
        Size             = UDim2.new(0, 0, 0, 28),
        AutomaticSize    = Enum.AutomaticSize.X,
        Position         = UDim2.new(0, 10, 0, 8),
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel  = 0,
        Parent           = ScreenGui,
    })
    Corner(bg, 6)
    Stroke(bg, theme.Outline)
    Padding(bg, 0, 0, 10, 10)
    local lbl = New("TextLabel", {
        Size                = UDim2.new(0, 0, 1, 0),
        AutomaticSize       = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text                = text,
        TextColor3          = theme.Text,
        Font                = Enum.Font.GothamBold,
        TextSize            = 13,
        Parent              = bg,
    })
    self._wm = lbl
    RegisterListener(function(t)
        bg.BackgroundColor3 = t.Secondary
        lbl.TextColor3      = t.Text
    end)
end

-- ──────────────────── Add Custom Theme ────────────────────
function Library:AddTheme(name, data)
    local base = {}
    for k, v in pairs(self.Themes.Dark) do base[k] = v end
    for k, v in pairs(data) do base[k] = v end
    self.Themes[name] = base
end

-- ──────────────────── Window ──────────────────────────────
function Library:CreateWindow(opts)
    opts = opts or {}
    local winTitle  = opts.Title     or "UI Library"
    local winSize   = opts.Size      or UDim2.new(0, 640, 0, 460)
    local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift

    local theme = T()

    local Win = setmetatable({
        _tabs       = {},
        _activeTab  = nil,
        _visible    = true,
        _minimised  = false,
        _baseSize   = winSize,
        Flags       = Library.Flags,
    }, { __index = self })

    -- ── Root Frame ──────────────────────────────────────
    local Root = New("Frame", {
        Name             = "Window_" .. winTitle,
        Size             = winSize,
        Position         = UDim2.new(0.5, -winSize.X.Offset / 2, 0.5, -winSize.Y.Offset / 2),
        BackgroundColor3 = theme.Background,
        BorderSizePixel  = 0,
        ClipsDescendants = false,
        Parent           = ScreenGui,
    })
    Corner(Root, 10)
    local rootStroke = Stroke(Root, theme.Outline, 1)
    Win._root = Root

    -- Drop shadow (decorative)
    local Shadow = New("ImageLabel", {
        Name                = "Shadow",
        Size                = UDim2.new(1, 30, 1, 30),
        Position            = UDim2.new(0, -15, 0, -8),
        BackgroundTransparency = 1,
        Image               = "rbxassetid://6015897843",
        ImageColor3         = Color3.fromRGB(0, 0, 0),
        ImageTransparency   = 0.65,
        ScaleType           = Enum.ScaleType.Slice,
        SliceCenter         = Rect.new(49, 49, 450, 450),
        ZIndex              = 0,
        Parent              = Root,
    })

    -- ── Title Bar ───────────────────────────────────────
    local TitleBar = New("Frame", {
        Name             = "TitleBar",
        Size             = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = Root,
    })
    Corner(TitleBar, 10)
    -- Mask lower rounded corners of title bar
    New("Frame", {
        Size             = UDim2.new(1, 0, 0.5, 0),
        Position         = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = TitleBar,
    })

    local TitleLabel = New("TextLabel", {
        Size                = UDim2.new(1, -90, 1, -2),
        Position            = UDim2.new(0, 14, 0, 1),
        BackgroundTransparency = 1,
        Text                = winTitle,
        TextColor3          = theme.Text,
        Font                = Enum.Font.GothamBold,
        TextSize            = 14,
        TextXAlignment      = Enum.TextXAlignment.Left,
        ZIndex              = 3,
        Parent              = TitleBar,
    })

    -- Accent underline on title bar
    local AccentLine = New("Frame", {
        Name             = "AccentLine",
        Size             = UDim2.new(1, 0, 0, 2),
        Position         = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = TitleBar,
    })

    -- Window control buttons
    local CtrlRow = New("Frame", {
        Size                = UDim2.new(0, 56, 0, 22),
        Position            = UDim2.new(1, -64, 0.5, -11),
        BackgroundTransparency = 1,
        ZIndex              = 4,
        Parent              = TitleBar,
    })
    ListLayout(CtrlRow, 6, Enum.FillDirection.Horizontal)

    local function WinBtn(bgColor, sym, onClick)
        local b = New("TextButton", {
            Size             = UDim2.new(0, 22, 0, 22),
            BackgroundColor3 = bgColor,
            BorderSizePixel  = 0,
            Text             = sym,
            TextColor3       = Color3.fromRGB(255, 255, 255),
            Font             = Enum.Font.GothamBold,
            TextSize         = 13,
            ZIndex           = 5,
            Parent           = CtrlRow,
        })
        Corner(b, 5)
        b.MouseEnter:Connect(function() Tween(b, {BackgroundTransparency = 0.35}, 0.1) end)
        b.MouseLeave:Connect(function() Tween(b, {BackgroundTransparency = 0},    0.1) end)
        b.MouseButton1Click:Connect(onClick)
        return b
    end

    WinBtn(Color3.fromRGB(235, 175, 28), "−", function() Win:_Minimise() end)
    WinBtn(Color3.fromRGB(215, 55,  60), "×", function() Win:Close()     end)

    -- ── Body ────────────────────────────────────────────
    local Body = New("Frame", {
        Name                = "Body",
        Size                = UDim2.new(1, 0, 1, -38),
        Position            = UDim2.new(0, 0, 0, 38),
        BackgroundTransparency = 1,
        ClipsDescendants    = true,
        ZIndex              = 2,
        Parent              = Root,
    })
    Win._body = Body

    -- Tab sidebar
    local TabBar = New("ScrollingFrame", {
        Name                   = "TabBar",
        Size                   = UDim2.new(0, 118, 1, -10),
        Position               = UDim2.new(0, 6,   0, 5),
        BackgroundColor3       = theme.Secondary,
        BorderSizePixel        = 0,
        ScrollBarThickness     = 0,
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize    = Enum.AutomaticSize.Y,
        ZIndex                 = 3,
        Parent                 = Body,
    })
    Corner(TabBar, 8)
    Padding(TabBar, 6, 6, 6, 6)
    ListLayout(TabBar, 3)
    Win._tabBar = TabBar

    -- Content pane
    local ContentArea = New("Frame", {
        Name                = "ContentArea",
        Size                = UDim2.new(1, -130, 1, -10),
        Position            = UDim2.new(0, 128, 0, 5),
        BackgroundTransparency = 1,
        ClipsDescendants    = true,
        ZIndex              = 2,
        Parent              = Body,
    })
    Win._contentArea = ContentArea

    -- ── Dragging ──────────────────────────────────────
    local dragging, dragStart, frameStart
    TitleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = inp.Position
            frameStart = Root.Position
        end
    end)
    TitleBar.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - dragStart
            Root.Position = UDim2.new(
                frameStart.X.Scale, frameStart.X.Offset + d.X,
                frameStart.Y.Scale, frameStart.Y.Offset + d.Y
            )
        end
    end)

    -- ── Toggle Keybind ────────────────────────────────
    UserInputService.InputBegan:Connect(function(inp, gpe)
        if not gpe and inp.KeyCode == toggleKey then
            Win:Toggle()
        end
    end)

    -- ── Theme Listeners for Window chrome ─────────────
    RegisterListener(function(t)
        Root.BackgroundColor3     = t.Background
        rootStroke.Color          = t.Outline
        TitleBar.BackgroundColor3 = t.Secondary
        TitleLabel.TextColor3     = t.Text
        AccentLine.BackgroundColor3 = t.Accent
        TabBar.BackgroundColor3   = t.Secondary
        -- update the titlebar mask frame
        for _, c in ipairs(TitleBar:GetChildren()) do
            if c:IsA("Frame") and c.Name ~= "AccentLine" then
                c.BackgroundColor3 = t.Secondary
            end
        end
    end)

    -- ────────────────────────────────────────────────────
    --  Window Methods
    -- ────────────────────────────────────────────────────

    function Win:Toggle(forceState)
        if forceState ~= nil then self._visible = forceState
        else self._visible = not self._visible end
        if self._visible then
            Root.Visible = true
            Tween(Root, { BackgroundTransparency = Library.Transparency }, 0.2, Enum.EasingStyle.Quint)
        else
            Tween(Root, { BackgroundTransparency = 1 }, 0.2, Enum.EasingStyle.Quint)
            task.delay(0.21, function() if not self._visible then Root.Visible = false end end)
        end
    end

    function Win:_Minimise()
        self._minimised = not self._minimised
        local target = self._minimised
            and UDim2.new(winSize.X.Scale, winSize.X.Offset, 0, 38)
            or  winSize
        Tween(Root, { Size = target }, 0.28, Enum.EasingStyle.Quint)
    end

    function Win:Close()
        Tween(Root, { BackgroundTransparency = 1 }, 0.2)
        task.delay(0.22, function()
            pcall(function() Root:Destroy() end)
        end)
    end

    -- ────────────────────────────────────────────────────
    --  CreateTab
    -- ────────────────────────────────────────────────────
    function Win:CreateTab(name)
        local theme = T()
        local Tab = {
            _name    = name,
            _win     = self,
        }

        -- Sidebar button
        local TabBtn = New("TextButton", {
            Name             = "Tab_" .. name,
            Size             = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = theme.Tertiary,
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            Text             = name,
            TextColor3       = theme.SubText,
            Font             = Enum.Font.GothamMedium,
            TextSize         = 12,
            ZIndex           = 4,
            Parent           = TabBar,
        })
        Corner(TabBtn, 6)

        -- Small accent indicator
        local TabAccent = New("Frame", {
            Name             = "TabAccent",
            Size             = UDim2.new(0, 3, 0.6, 0),
            Position         = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor3 = theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            ZIndex           = 5,
            Parent           = TabBtn,
        })
        Corner(TabAccent, 2)

        Tab._btn    = TabBtn
        Tab._accent = TabAccent

        -- Content frame
        local ContentFrame = New("Frame", {
            Name                = "TabContent_" .. name,
            Size                = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible             = false,
            ZIndex              = 2,
            Parent              = ContentArea,
        })
        Tab._frame = ContentFrame

        -- Two scrollable columns
        local ColRow = New("Frame", {
            Size                = UDim2.new(1, -8, 1, -8),
            Position            = UDim2.new(0, 4, 0, 4),
            BackgroundTransparency = 1,
            Parent              = ContentFrame,
        })
        ListLayout(ColRow, 6, Enum.FillDirection.Horizontal)

        local function MakeScrollCol(side)
            local sf = New("ScrollingFrame", {
                Name                   = side .. "Col",
                Size                   = UDim2.new(0.5, -3, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                ScrollBarThickness     = 2,
                ScrollBarImageColor3   = theme.Scrollbar,
                CanvasSize             = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize    = Enum.AutomaticSize.Y,
                ZIndex                 = 2,
                Parent                 = ColRow,
            })
            ListLayout(sf, 6)
            Padding(sf, 0, 6, 0, 2)
            RegisterListener(function(t)
                sf.ScrollBarImageColor3 = t.Scrollbar
            end)
            return sf
        end

        Tab._leftCol  = MakeScrollCol("Left")
        Tab._rightCol = MakeScrollCol("Right")

        -- Activation logic
        local function Activate()
            if self._activeTab then
                local prev = self._activeTab
                prev._frame.Visible = false
                Tween(prev._btn,    { BackgroundTransparency = 1,   TextColor3 = T().SubText }, 0.14)
                Tween(prev._accent, { BackgroundTransparency = 1 }, 0.14)
            end
            self._activeTab = Tab
            ContentFrame.Visible = true
            Tween(TabBtn,    { BackgroundTransparency = 0, BackgroundColor3 = T().Tertiary, TextColor3 = T().Text }, 0.14)
            Tween(TabAccent, { BackgroundTransparency = 0 }, 0.14)
        end

        TabBtn.MouseButton1Click:Connect(Activate)
        TabBtn.MouseEnter:Connect(function()
            if self._activeTab ~= Tab then
                Tween(TabBtn, { BackgroundTransparency = 0.6, BackgroundColor3 = T().Tertiary }, 0.1)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if self._activeTab ~= Tab then
                Tween(TabBtn, { BackgroundTransparency = 1 }, 0.1)
            end
        end)

        if #self._tabs == 0 then Activate() end
        table.insert(self._tabs, Tab)

        RegisterListener(function(t)
            TabAccent.BackgroundColor3 = t.Accent
            if self._activeTab == Tab then
                TabBtn.BackgroundColor3 = t.Tertiary
                TabBtn.TextColor3       = t.Text
            else
                TabBtn.TextColor3 = t.SubText
            end
        end)

        -- ──────────────────────────────────────────────────
        --  CreateGroupbox
        -- ──────────────────────────────────────────────────
        function Tab:CreateGroupbox(gbName, side)
            local theme = T()
            local col   = (side == "Right") and self._rightCol or self._leftCol

            local GB = { _tab = self }

            local GBFrame = New("Frame", {
                Name             = "GB_" .. gbName,
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundColor3 = theme.Element,
                BorderSizePixel  = 0,
                ZIndex           = 3,
                Parent           = col,
            })
            Corner(GBFrame, 8)
            local gbStroke = Stroke(GBFrame, theme.Outline)

            -- Header
            local GBHeader = New("Frame", {
                Name                = "Header",
                Size                = UDim2.new(1, 0, 0, 26),
                BackgroundTransparency = 1,
                ZIndex              = 4,
                Parent              = GBFrame,
            })
            local headerDivider = New("Frame", {
                Size             = UDim2.new(1, -14, 0, 1),
                Position         = UDim2.new(0, 7, 1, -1),
                BackgroundColor3 = theme.Outline,
                BorderSizePixel  = 0,
                ZIndex           = 4,
                Parent           = GBHeader,
            })
            local headerTitle = New("TextLabel", {
                Size                = UDim2.new(1, -14, 1, 0),
                Position            = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text                = gbName,
                TextColor3          = theme.SubText,
                Font                = Enum.Font.GothamBold,
                TextSize            = 11,
                TextXAlignment      = Enum.TextXAlignment.Left,
                ZIndex              = 5,
                Parent              = GBHeader,
            })

            -- Content list
            local GBContent = New("Frame", {
                Name                = "Content",
                Size                = UDim2.new(1, 0, 0, 0),
                AutomaticSize       = Enum.AutomaticSize.Y,
                Position            = UDim2.new(0, 0, 0, 26),
                BackgroundTransparency = 1,
                ZIndex              = 3,
                Parent              = GBFrame,
            })
            Padding(GBContent, 4, 8, 8, 8)
            ListLayout(GBContent, 5)
            GB._list = GBContent

            RegisterListener(function(t)
                GBFrame.BackgroundColor3   = t.Element
                gbStroke.Color             = t.Outline
                headerDivider.BackgroundColor3 = t.Outline
                headerTitle.TextColor3     = t.SubText
            end)

            -- ──────────────────────────────────────────────
            --  Shared element row builder
            -- ──────────────────────────────────────────────
            local function ElemRow(labelText, height, tooltip)
                local theme = T()
                local row = New("Frame", {
                    Size                = UDim2.new(1, 0, 0, height or 26),
                    BackgroundTransparency = 1,
                    ZIndex              = 4,
                    Parent              = GB._list,
                })
                local lbl = New("TextLabel", {
                    Size                = UDim2.new(0.58, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text                = labelText,
                    TextColor3          = theme.Text,
                    Font                = Library.Font,
                    TextSize            = 12,
                    TextXAlignment      = Enum.TextXAlignment.Left,
                    ZIndex              = 5,
                    Parent              = row,
                })
                if tooltip then AttachTooltip(row, tooltip) end
                RegisterListener(function(t)
                    lbl.TextColor3 = t.Text
                    lbl.Font       = Library.Font
                end)
                return row, lbl
            end

            -- ══════════════════════════════════════════════
            --  BUTTON
            -- ══════════════════════════════════════════════
            function GB:CreateButton(opts)
                local n       = opts.Name     or "Button"
                local cb      = opts.Callback or function() end
                local tooltip = opts.Tooltip
                local theme   = T()

                local row = New("Frame", {
                    Size                = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    ZIndex              = 4,
                    Parent              = self._list,
                })

                local btn = New("TextButton", {
                    Size             = UDim2.new(1, 0, 0, 26),
                    Position         = UDim2.new(0, 0, 0, 1),
                    BackgroundColor3 = theme.Accent,
                    BorderSizePixel  = 0,
                    Text             = n,
                    TextColor3       = Color3.fromRGB(255, 255, 255),
                    Font             = Enum.Font.GothamMedium,
                    TextSize         = 12,
                    ZIndex           = 5,
                    Parent           = row,
                })
                Corner(btn, 6)
                if tooltip then AttachTooltip(btn, tooltip) end

                btn.MouseEnter:Connect(function()    Tween(btn, { BackgroundColor3 = T().AccentGlow }, 0.12) end)
                btn.MouseLeave:Connect(function()    Tween(btn, { BackgroundColor3 = T().Accent },     0.12) end)
                btn.MouseButton1Down:Connect(function()  Tween(btn, { BackgroundColor3 = T().AccentDark }, 0.08) end)
                btn.MouseButton1Up:Connect(function()    Tween(btn, { BackgroundColor3 = T().Accent },     0.12) end)
                btn.MouseButton1Click:Connect(function()
                    pcall(cb)
                end)

                RegisterListener(function(t) btn.BackgroundColor3 = t.Accent end)

                local Ref = {}
                function Ref:SetText(text) btn.Text = text end
                return Ref
            end

            -- ══════════════════════════════════════════════
            --  TOGGLE
            -- ══════════════════════════════════════════════
            function GB:CreateToggle(opts)
                local n       = opts.Name     or "Toggle"
                local default = opts.Default  == true
                local flag    = opts.Flag
                local cb      = opts.Callback or function() end
                local tooltip = opts.Tooltip
                local theme   = T()

                local state = default
                if flag then Library.Flags[flag] = state end

                local row, _ = ElemRow(n, 26, tooltip)

                local track = New("Frame", {
                    Size             = UDim2.new(0, 36, 0, 18),
                    Position         = UDim2.new(1, -36, 0.5, -9),
                    BackgroundColor3 = state and theme.Accent or theme.Outline,
                    BorderSizePixel  = 0,
                    ZIndex           = 5,
                    Parent           = row,
                })
                Corner(track, 9)

                local knob = New("Frame", {
                    Size             = UDim2.new(0, 12, 0, 12),
                    Position         = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel  = 0,
                    ZIndex           = 6,
                    Parent           = track,
                })
                Corner(knob, 6)

                local Ref = {}
                Ref._state = state
                Ref._cb    = cb

                local function SetState(val, silent)
                    state     = val
                    Ref._state = val
                    if flag then Library.Flags[flag] = val end
                    Tween(track, { BackgroundColor3 = val and T().Accent or T().Outline }, 0.14)
                    Tween(knob,  { Position = val and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6) }, 0.14)
                    if not silent then pcall(cb, val) end
                end

                -- Invisible click region
                New("TextButton", {
                    Size                = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text                = "",
                    ZIndex              = 7,
                    Parent              = row,
                }).MouseButton1Click:Connect(function() SetState(not state) end)

                RegisterListener(function(t)
                    track.BackgroundColor3 = state and t.Accent or t.Outline
                end)

                function Ref:Set(v) SetState(v) end
                function Ref:Get() return state end
                function Ref:Dependency(toggleRef, requireVal)
                    local function Upd()
                        row.Visible = (toggleRef:Get() == requireVal)
                    end
                    RunService.Heartbeat:Connect(Upd)
                    Upd()
                end

                return Ref
            end

            -- ══════════════════════════════════════════════
            --  SLIDER
            -- ══════════════════════════════════════════════
            function GB:CreateSlider(opts)
                local n       = opts.Name     or "Slider"
                local min     = opts.Min      or 0
                local max     = opts.Max      or 100
                local default = math.clamp(opts.Default or min, min, max)
                local step    = opts.Step     or 1
                local suffix  = opts.Suffix   or ""
                local flag    = opts.Flag
                local cb      = opts.Callback or function() end
                local tooltip = opts.Tooltip
                local theme   = T()

                local value   = default
                if flag then Library.Flags[flag] = value end

                local row = New("Frame", {
                    Size                = UDim2.new(1, 0, 0, 44),
                    BackgroundTransparency = 1,
                    ZIndex              = 4,
                    Parent              = self._list,
                })
                if tooltip then AttachTooltip(row, tooltip) end

                -- Label row
                local topRow = New("Frame", {
                    Size                = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    ZIndex              = 5,
                    Parent              = row,
                })
                local nameLbl = New("TextLabel", {
                    Size                = UDim2.new(0.6, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text                = n,
                    TextColor3          = theme.Text,
                    Font                = Library.Font,
                    TextSize            = 12,
                    TextXAlignment      = Enum.TextXAlignment.Left,
                    ZIndex              = 6,
                    Parent              = topRow,
                })
                local valLbl = New("TextLabel", {
                    Size                = UDim2.new(0.4, 0, 1, 0),
                    Position            = UDim2.new(0.6, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text                = tostring(value) .. suffix,
                    TextColor3          = theme.SubText,
                    Font                = Library.Font,
                    TextSize            = 12,
                    TextXAlignment      = Enum.TextXAlignment.Right,
                    ZIndex              = 6,
                    Parent              = topRow,
                })

                -- Track
                local track = New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 6),
                    Position         = UDim2.new(0, 0, 0, 26),
                    BackgroundColor3 = theme.Outline,
                    BorderSizePixel  = 0,
                    ZIndex           = 5,
                    Parent           = row,
                })
                Corner(track, 3)

                local pct0 = (value - min) / (max - min)
                local fill = New("Frame", {
                    Size             = UDim2.new(pct0, 0, 1, 0),
                    BackgroundColor3 = theme.Accent,
                    BorderSizePixel  = 0,
                    ZIndex           = 6,
                    Parent           = track,
                })
                Corner(fill, 3)

                local knob = New("Frame", {
                    Size             = UDim2.new(0, 12, 0, 12),
                    Position         = UDim2.new(pct0, -6, 0.5, -6),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel  = 0,
                    ZIndex           = 7,
                    Parent           = track,
                })
                Corner(knob, 6)

                local Ref = {}

                local function SetValue(v, silent)
                    v = math.clamp(step == 1 and math.round(v) or (math.floor(v / step + 0.5) * step), min, max)
                    value = v
                    if flag then Library.Flags[flag] = v end
                    local p = (v - min) / (max - min)
                    Tween(fill,  { Size     = UDim2.new(p, 0, 1, 0)       }, 0.07)
                    Tween(knob, { Position = UDim2.new(p, -6, 0.5, -6)    }, 0.07)
                    valLbl.Text = tostring(v) .. suffix
                    if not silent then pcall(cb, v) end
                end

                local sliding = false
                track.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = true
                        local rel = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                        SetValue(min + rel * (max - min))
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        local rel = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                        SetValue(min + rel * (max - min))
                    end
                end)

                RegisterListener(function(t)
                    track.BackgroundColor3  = t.Outline
                    fill.BackgroundColor3   = t.Accent
                    nameLbl.TextColor3      = t.Text;    nameLbl.Font = Library.Font
                    valLbl.TextColor3       = t.SubText; valLbl.Font  = Library.Font
                end)

                function Ref:Set(v) SetValue(v) end
                function Ref:Get() return value end
                function Ref:Dependency(toggleRef, requireVal)
                    local function Upd() row.Visible = (toggleRef:Get() == requireVal) end
                    RunService.Heartbeat:Connect(Upd); Upd()
                end
                return Ref
            end

            -- ══════════════════════════════════════════════
            --  DROPDOWN (FIXED: popup in PopupContainer, absolute positioning)
            -- ══════════════════════════════════════════════
            function GB:CreateDropdown(opts)
                local n       = opts.Name    or "Dropdown"
                local options = opts.Options or {}
                local default = opts.Default or options[1]
                local flag    = opts.Flag
                local cb      = opts.Callback or function() end
                local tooltip = opts.Tooltip
                local theme   = T()

                local selected = default
                if flag then Library.Flags[flag] = selected end

                local row = New("Frame", {
                    Size                = UDim2.new(1, 0, 0, 52),
                    BackgroundTransparency = 1,
                    ClipsDescendants    = false,
                    ZIndex              = 4,
                    Parent              = self._list,
                })
                if tooltip then AttachTooltip(row, tooltip) end

                New("TextLabel", {
                    Size                = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text                = n,
                    TextColor3          = theme.Text,
                    Font                = Library.Font,
                    TextSize            = 12,
                    TextXAlignment      = Enum.TextXAlignment.Left,
                    ZIndex              = 5,
                    Parent              = row,
                })

                local dropBtn = New("TextButton", {
                    Size             = UDim2.new(1, 0, 0, 26),
                    Position         = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = theme.Secondary,
                    BorderSizePixel  = 0,
                    Text             = "",
                    ZIndex           = 5,
                    Parent           = row,
                })
                Corner(dropBtn, 6)
                Stroke(dropBtn, theme.Outline)

                local selLbl = New("TextLabel", {
                    Size                = UDim2.new(1, -26, 1, 0),
                    Position            = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text                = selected or "Select...",
                    TextColor3          = theme.Text,
                    Font                = Library.Font,
                    TextSize            = 12,
                    TextXAlignment      = Enum.TextXAlignment.Left,
                    TextTruncate        = Enum.TextTruncate.AtEnd,
                    ZIndex              = 6,
                    Parent              = dropBtn,
                })
                New("TextLabel", {
                    Size                = UDim2.new(0, 18, 1, 0),
                    Position            = UDim2.new(1, -22, 0, 0),
                    BackgroundTransparency = 1,
                    Text                = "▾",
                    TextColor3          = theme.SubText,
                    Font                = Enum.Font.GothamBold,
                    TextSize            = 14,
                    ZIndex              = 6,
                    Parent              = dropBtn,
                })

                -- Popup list (now parented to PopupContainer)
                local dropList = New("Frame", {
                    Name             = "DropList",
                    Size             = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0), -- width set later
                    BackgroundColor3 = theme.Secondary,
                    BorderSizePixel  = 0,
                    Visible          = false,
                    ClipsDescendants = true,
                    ZIndex           = 1001,          -- high ZIndex
                    Parent           = PopupContainer,
                })
                Corner(dropList, 6)
                Stroke(dropList, theme.Outline)
                Padding(dropList, 4, 4, 4, 4)
                ListLayout(dropList, 2)

                local Ref = {}
                local isOpen = false
                local updateConn = nil

                local function SetSelected(opt, silent)
                    selected = opt
                    selLbl.Text = opt or "Select..."
                    if flag then Library.Flags[flag] = opt end
                    if not silent then pcall(cb, opt) end
                end

                local function RebuildList()
                    for _, c in ipairs(dropList:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end
                    for _, opt in ipairs(options) do
                        local isSelected = opt == selected
                        local item = New("TextButton", {
                            Size                = UDim2.new(1, 0, 0, 26),
                            BackgroundColor3    = T().Tertiary,
                            BackgroundTransparency = isSelected and 0 or 1,
                            BorderSizePixel     = 0,
                            Text                = opt,
                            TextColor3          = isSelected and T().Text or T().SubText,
                            Font                = Library.Font,
                            TextSize            = 12,
                            ZIndex              = 1002,
                            Parent              = dropList,
                        })
                        Corner(item, 4)
                        item.MouseEnter:Connect(function() Tween(item, { BackgroundTransparency = 0, BackgroundColor3 = T().Tertiary, TextColor3 = T().Text }, 0.08) end)
                        item.MouseLeave:Connect(function() Tween(item, { BackgroundTransparency = (opt == selected) and 0 or 1 }, 0.08) end)
                        item.MouseButton1Click:Connect(function()
                            SetSelected(opt)
                            -- Close dropdown
                            isOpen = false
                            if updateConn then updateConn:Disconnect(); updateConn = nil end
                            Tween(dropList, { Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0) }, 0.14)
                            task.delay(0.14, function() dropList.Visible = false end)
                            RebuildList()
                        end)
                    end
                end
                RebuildList()

                local function updatePopupPosition()
                    if not dropBtn or not dropBtn.Visible then return end
                    local absPos = dropBtn.AbsolutePosition
                    local absSize = dropBtn.AbsoluteSize
                    dropList.Position = UDim2.fromOffset(absPos.X, absPos.Y + absSize.Y + 4)
                    -- also update width in case button resized
                    dropList.Size = UDim2.new(0, absSize.X, 0, dropList.AbsoluteSize.Y)
                end

                dropBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        -- Update position and start tracking
                        updatePopupPosition()
                        updateConn = RunService.RenderStepped:Connect(updatePopupPosition)
                        dropList.Visible = true
                        local h = #options * 28 + 8
                        Tween(dropList, { Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, h) }, 0.15)
                    else
                        if updateConn then updateConn:Disconnect(); updateConn = nil end
                        Tween(dropList, { Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0) }, 0.15)
                        task.delay(0.15, function() dropList.Visible = false end)
                    end
                end)

                RegisterListener(function(t)
                    dropBtn.BackgroundColor3 = t.Secondary
                    selLbl.TextColor3        = t.Text
                    dropList.BackgroundColor3 = t.Secondary
                    RebuildList()
                end)

                function Ref:Set(opt) if table.find(options, opt) then SetSelected(opt); RebuildList() end end
                function Ref:Get() return selected end
                function Ref:SetOptions(newOpts) options = newOpts; RebuildList() end
                function Ref:Dependency(toggleRef, requireVal)
                    local function Upd() row.Visible = (toggleRef:Get() == requireVal) end
                    RunService.Heartbeat:Connect(Upd); Upd()
                end
                return Ref
            end

            -- ══════════════════════════════════════════════
            --  MULTI-DROPDOWN (FIXED)
            -- ══════════════════════════════════════════════
            function GB:CreateMultiDropdown(opts)
                local n       = opts.Name    or "MultiSelect"
                local options = opts.Options or {}
                local default = opts.Default or {}
                local flag    = opts.Flag
                local cb      = opts.Callback or function() end
                local tooltip = opts.Tooltip
                local theme   = T()

                local selected = {}
                for _, v in ipairs(default) do selected[v] = true end
                if flag then Library.Flags[flag] = selected end

                local row = New("Frame", {
                    Size                = UDim2.new(1, 0, 0, 52),
                    BackgroundTransparency = 1,
                    ClipsDescendants    = false,
                    ZIndex              = 4,
                    Parent              = self._list,
                })
                if tooltip then AttachTooltip(row, tooltip) end

                New("TextLabel", {
                    Size                = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text                = n,
                    TextColor3          = theme.Text,
                    Font                = Library.Font,
                    TextSize            = 12,
                    TextXAlignment      = Enum.TextXAlignment.Left,
                    ZIndex              = 5,
                    Parent              = row,
                })

                local dropBtn = New("TextButton", {
                    Size             = UDim2.new(1, 0, 0, 26),
                    Position         = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = theme.Secondary,
                    BorderSizePixel  = 0,
                    Text             = "",
                    ZIndex           = 5,
                    Parent           = row,
                })
                Corner(dropBtn, 6)
                Stroke(dropBtn, theme.Outline)

                local function SelText()
                    local list = {}
                    for k, v in pairs(selected) do if v then table.insert(list, k) end end
                    table.sort(list)
                    return #list > 0 and table.concat(list, ", ") or "None"
                end

                local selLbl = New("TextLabel", {
                    Size                = UDim2.new(1, -26, 1, 0),
                    Position            = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text                = SelText(),
                    TextColor3          = theme.Text,
                    Font                = Library.Font,
                    TextSize            = 11,
                    TextXAlignment      = Enum.TextXAlignment.Left,
                    TextTruncate        = Enum.TextTruncate.AtEnd,
                    ZIndex              = 6,
                    Parent              = dropBtn,
                })
                New("TextLabel", {
                    Size   = UDim2.new(0, 18, 1, 0),
                    Position = UDim2.new(1, -22, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▾", TextColor3 = theme.SubText,
                    Font = Enum.Font.GothamBold, TextSize = 14,
                    ZIndex = 6, Parent = dropBtn,
                })

                -- Popup list (now in PopupContainer)
                local dropList = New("Frame", {
                    Size             = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0),
                    BackgroundColor3 = theme.Secondary,
                    BorderSizePixel  = 0,
                    Visible          = false,
                    ClipsDescendants = true,
                    ZIndex           = 1001,
                    Parent           = PopupContainer,
                })
                Corner(dropList, 6)
                Stroke(dropList, theme.Outline)
                Padding(dropList, 4, 4, 4, 4)
                ListLayout(dropList, 2)

                local Ref = {}
                local isOpen = false
                local updateConn = nil

                local function RebuildMultiList()
                    for _, c in ipairs(dropList:GetChildren()) do
                        if c:IsA("Frame") then c:Destroy() end
                    end
                    for _, opt in ipairs(options) do
                        local isSel = selected[opt] == true
                        local item = New("Frame", {
                            Size                = UDim2.new(1, 0, 0, 26),
                            BackgroundColor3    = isSel and T().Accent or T().Tertiary,
                            BackgroundTransparency = isSel and 0 or 1,
                            BorderSizePixel     = 0,
                            ZIndex              = 1002,
                            Parent              = dropList,
                        })
                        Corner(item, 4)
                        New("TextLabel", {
                            Size = UDim2.new(1, -28, 1, 0), Position = UDim2.new(0, 8, 0, 0),
                            BackgroundTransparency = 1, Text = opt,
                            TextColor3 = T().Text, Font = Library.Font, TextSize = 12,
                            ZIndex = 1003, Parent = item,
                        })
                        local chk = New("TextLabel", {
                            Size = UDim2.new(0, 18, 1, 0), Position = UDim2.new(1, -22, 0, 0),
                            BackgroundTransparency = 1, Text = isSel and "✓" or "",
                            TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.GothamBold,
                            TextSize = 12, ZIndex = 1003, Parent = item,
                        })
                        New("TextButton", {
                            Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
                            Text = "", ZIndex = 1004, Parent = item,
                        }).MouseButton1Click:Connect(function()
                            selected[opt] = not selected[opt]
                            selLbl.Text = SelText()
                            if flag then Library.Flags[flag] = selected end
                            pcall(cb, selected)
                            item.BackgroundTransparency = selected[opt] and 0 or 1
                            item.BackgroundColor3 = selected[opt] and T().Accent or T().Tertiary
                            chk.Text = selected[opt] and "✓" or ""
                        end)
                    end
                end
                RebuildMultiList()

                local function updatePopupPosition()
                    if not dropBtn or not dropBtn.Visible then return end
                    local absPos = dropBtn.AbsolutePosition
                    local absSize = dropBtn.AbsoluteSize
                    dropList.Position = UDim2.fromOffset(absPos.X, absPos.Y + absSize.Y + 4)
                    dropList.Size = UDim2.new(0, absSize.X, 0, dropList.AbsoluteSize.Y)
                end

                dropBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        updatePopupPosition()
                        updateConn = RunService.RenderStepped:Connect(updatePopupPosition)
                        dropList.Visible = true
                        local h = #options * 28 + 8
                        Tween(dropList, { Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, h) }, 0.15)
                    else
                        if updateConn then updateConn:Disconnect(); updateConn = nil end
                        Tween(dropList, { Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0) }, 0.15)
                        task.delay(0.15, function() dropList.Visible = false end)
                    end
                end)

                RegisterListener(function(t) dropBtn.BackgroundColor3 = t.Secondary; selLbl.TextColor3 = t.Text end)

                function Ref:Set(tbl)
                    selected = {}
                    for _, v in ipairs(tbl) do selected[v] = true end
                    selLbl.Text = SelText()
                    if flag then Library.Flags[flag] = selected end
                    RebuildMultiList()
                end
                function Ref:Get()
                    local out = {}
                    for k, v in pairs(selected) do if v then table.insert(out, k) end end
                    return out
                end
                function Ref:Dependency(toggleRef, requireVal)
                    local function Upd() row.Visible = (toggleRef:Get() == requireVal) end
                    RunService.Heartbeat:Connect(Upd); Upd()
                end
                return Ref
            end

            -- ══════════════════════════════════════════════
            --  TEXT INPUT
            -- ══════════════════════════════════════════════
            function GB:CreateTextInput(opts)
                local n           = opts.Name        or "Input"
                local placeholder = opts.Placeholder or "Type here..."
                local default     = opts.Default     or ""
                local flag        = opts.Flag
                local cb          = opts.Callback    or function() end
                local tooltip     = opts.Tooltip
                local theme       = T()

                local value = default
                if flag then Library.Flags[flag] = value end

                local row = New("Frame", {
                    Size                = UDim2.new(1, 0, 0, 52),
                    BackgroundTransparency = 1,
                    ZIndex              = 4,
                    Parent              = self._list,
                })

                New("TextLabel", {
                    Size = UDim2.new(1,0,0,16), BackgroundTransparency = 1,
                    Text = n, TextColor3 = theme.Text, Font = Library.Font,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5, Parent = row,
                })

                local inputBg = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 28),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = theme.Secondary,
                    BorderSizePixel = 0, ZIndex = 5, Parent = row,
                })
                Corner(inputBg, 6)
                Stroke(inputBg, theme.Outline)
                if tooltip then AttachTooltip(inputBg, tooltip) end

                local tb = New("TextBox", {
                    Size = UDim2.new(1, -16, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = value, PlaceholderText = placeholder,
                    TextColor3 = theme.Text, PlaceholderColor3 = theme.SubText,
                    Font = Library.Font, TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false, ZIndex = 6, Parent = inputBg,
                })

                tb.Focused:Connect(function()   Tween(inputBg, { BackgroundColor3 = T().Tertiary }, 0.1) end)
                tb.FocusLost:Connect(function()
                    Tween(inputBg, { BackgroundColor3 = T().Secondary }, 0.1)
                    value = tb.Text
                    if flag then Library.Flags[flag] = value end
                    pcall(cb, value)
                end)

                RegisterListener(function(t)
                    inputBg.BackgroundColor3 = t.Secondary
                    tb.TextColor3            = t.Text
                    tb.PlaceholderColor3     = t.SubText
                    tb.Font                  = Library.Font
                end)

                local Ref = {}
                function Ref:Set(v) tb.Text = v; value = v end
                function Ref:Get() return value end
                function Ref:Dependency(toggleRef, requireVal)
                    local function Upd() row.Visible = (toggleRef:Get() == requireVal) end
                    RunService.Heartbeat:Connect(Upd); Upd()
                end
                return Ref
            end

            -- ══════════════════════════════════════════════
            --  COLOR PICKER (FIXED)
            -- ══════════════════════════════════════════════
            function GB:CreateColorPicker(opts)
                local n       = opts.Name     or "Color"
                local default = opts.Default  or Color3.fromRGB(255, 80, 80)
                local flag    = opts.Flag
                local cb      = opts.Callback or function() end
                local tooltip = opts.Tooltip
                local theme   = T()

                local color   = default
                local h, s, v = color:ToHSV()
                if flag then Library.Flags[flag] = color end

                local row, _ = ElemRow(n, 26, tooltip)
                row.ClipsDescendants = false
                row.ZIndex = 5

                local preview = New("TextButton", {
                    Size             = UDim2.new(0, 52, 0, 20),
                    Position         = UDim2.new(1, -52, 0.5, -10),
                    BackgroundColor3 = color,
                    BorderSizePixel  = 0,
                    Text             = "",
                    ZIndex           = 6,
                    Parent           = row,
                })
                Corner(preview, 4)
                Stroke(preview, theme.Outline)

                -- ── Picker Popup (now in PopupContainer) ──
                local popup = New("Frame", {
                    Size             = UDim2.new(0, 196, 0, 158),
                    BackgroundColor3 = theme.Secondary,
                    BorderSizePixel  = 0,
                    Visible          = false,
                    ZIndex           = 1001,
                    Parent           = PopupContainer,
                })
                Corner(popup, 8)
                Stroke(popup, theme.Outline)
                Padding(popup, 8, 8, 8, 8)

                -- Hue bar
                local hueBar = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 12),
                    Position = UDim2.new(0, 0, 0, 0),
                    BorderSizePixel = 0, ZIndex = 1002, Parent = popup,
                })
                Corner(hueBar, 4)
                local hg = New("UIGradient", { Parent = hueBar })
                hg.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0,    Color3.fromHSV(0,    1, 1)),
                    ColorSequenceKeypoint.new(1/6,  Color3.fromHSV(1/6,  1, 1)),
                    ColorSequenceKeypoint.new(2/6,  Color3.fromHSV(2/6,  1, 1)),
                    ColorSequenceKeypoint.new(3/6,  Color3.fromHSV(3/6,  1, 1)),
                    ColorSequenceKeypoint.new(4/6,  Color3.fromHSV(4/6,  1, 1)),
                    ColorSequenceKeypoint.new(5/6,  Color3.fromHSV(5/6,  1, 1)),
                    ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,    1, 1)),
                })

                local hueCursor = New("Frame", {
                    Size = UDim2.new(0, 4, 1, 0),
                    Position = UDim2.new(h, -2, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(255,255,255),
                    BorderSizePixel = 0, ZIndex = 1003, Parent = hueBar,
                })
                Corner(hueCursor, 2)

                -- SV square
                local svBox = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 96),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = Color3.fromHSV(h, 1, 1),
                    BorderSizePixel = 0, ZIndex = 1002, Parent = popup,
                })
                Corner(svBox, 4)
                New("UIGradient", {
                    Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255)),
                    Transparency = NumberSequence.new(0, 1),
                    Parent = svBox,
                })
                local blackOverlay = New("Frame", {
                    Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.fromRGB(0,0,0),
                    BorderSizePixel = 0, ZIndex = 1003, Parent = svBox,
                })
                Corner(blackOverlay, 4)
                New("UIGradient", {
                    Rotation = 90,
                    Transparency = NumberSequence.new(0, 1),
                    Parent = blackOverlay,
                })
                local svKnob = New("Frame", {
                    Size = UDim2.new(0, 10, 0, 10),
                    Position = UDim2.new(s, -5, 1-v, -5),
                    BackgroundColor3 = Color3.fromRGB(255,255,255),
                    BorderSizePixel = 1, ZIndex = 1004, Parent = svBox,
                })
                Corner(svKnob, 5)

                -- Hex input
                local hexInput = New("TextBox", {
                    Size = UDim2.new(1, 0, 0, 22),
                    Position = UDim2.new(0, 0, 1, -22),
                    BackgroundColor3 = theme.Tertiary,
                    BorderSizePixel = 0,
                    Text = string.format("#%02X%02X%02X", math.round(color.R*255), math.round(color.G*255), math.round(color.B*255)),
                    TextColor3 = theme.Text, Font = Enum.Font.Code, TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    ClearTextOnFocus = false, ZIndex = 1003, Parent = popup,
                })
                Corner(hexInput, 4)

                local function UpdateColor(nh, ns, nv, silent)
                    h, s, v = nh, ns, nv
                    color = Color3.fromHSV(h, s, v)
                    preview.BackgroundColor3 = color
                    svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    hueCursor.Position = UDim2.new(h, -2, 0, 0)
                    svKnob.Position    = UDim2.new(s, -5, 1-v, -5)
                    hexInput.Text = string.format("#%02X%02X%02X", math.round(color.R*255), math.round(color.G*255), math.round(color.B*255))
                    if flag then Library.Flags[flag] = color end
                    if not silent then pcall(cb, color) end
                end

                local hDrag, svDrag = false, false

                hueBar.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        hDrag = true
                        local rel = math.clamp((inp.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                        UpdateColor(rel, s, v)
                    end
                end)
                svBox.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDrag = true
                        local rx = math.clamp((inp.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
                        local ry = math.clamp((inp.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
                        UpdateColor(h, rx, 1 - ry)
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then hDrag = false; svDrag = false end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                    if hDrag then
                        local rel = math.clamp((inp.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                        UpdateColor(rel, s, v)
                    elseif svDrag then
                        local rx = math.clamp((inp.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
                        local ry = math.clamp((inp.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
                        UpdateColor(h, rx, 1 - ry)
                    end
                end)

                hexInput.FocusLost:Connect(function()
                    local hex = hexInput.Text:gsub("#", "")
                    if #hex == 6 then
                        local r = tonumber(hex:sub(1,2), 16)
                        local g = tonumber(hex:sub(3,4), 16)
                        local b = tonumber(hex:sub(5,6), 16)
                        if r and g and b then
                            local c3 = Color3.fromRGB(r, g, b)
                            local nh, ns, nv = c3:ToHSV()
                            UpdateColor(nh, ns, nv)
                        end
                    end
                end)

                local pickerOpen = false
                local updateConn = nil

                local function updatePopupPosition()
                    if not preview or not preview.Visible then return end
                    local absPos = preview.AbsolutePosition
                    local absSize = preview.AbsoluteSize
                    popup.Position = UDim2.fromOffset(absPos.X + absSize.X + 4, absPos.Y)
                end

                preview.MouseButton1Click:Connect(function()
                    pickerOpen = not pickerOpen
                    if pickerOpen then
                        updatePopupPosition()
                        updateConn = RunService.RenderStepped:Connect(updatePopupPosition)
                        popup.Visible = true
                    else
                        if updateConn then updateConn:Disconnect(); updateConn = nil end
                        popup.Visible = false
                    end
                end)

                RegisterListener(function(t)
                    popup.BackgroundColor3 = t.Secondary
                    hexInput.BackgroundColor3 = t.Tertiary
                    hexInput.TextColor3 = t.Text
                end)

                local Ref = {}
                function Ref:Set(c)
                    color = c
                    preview.BackgroundColor3 = c
                    local nh, ns, nv = c:ToHSV()
                    UpdateColor(nh, ns, nv, true)
                end
                function Ref:Get() return color end
                function Ref:Dependency(toggleRef, requireVal)
                    local function Upd() row.Visible = (toggleRef:Get() == requireVal) end
                    RunService.Heartbeat:Connect(Upd); Upd()
                end
                return Ref
            end

            -- ══════════════════════════════════════════════
            --  KEYBIND
            -- ══════════════════════════════════════════════
            function GB:CreateKeybind(opts)
                local n       = opts.Name     or "Keybind"
                local default = opts.Default  or Enum.KeyCode.Unknown
                local flag    = opts.Flag
                local cb      = opts.Callback or function() end
                local tooltip = opts.Tooltip
                local theme   = T()

                local key       = default
                local listening = false
                if flag then Library.Flags[flag] = key end

                local row, _ = ElemRow(n, 26, tooltip)

                local keyBtn = New("TextButton", {
                    Size             = UDim2.new(0, 72, 0, 22),
                    Position         = UDim2.new(1, -72, 0.5, -11),
                    BackgroundColor3 = theme.Secondary,
                    BorderSizePixel  = 0,
                    Text             = key.Name ~= "Unknown" and key.Name or "None",
                    TextColor3       = theme.SubText,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 11,
                    ZIndex           = 5,
                    Parent           = row,
                })
                Corner(keyBtn, 5)
                Stroke(keyBtn, theme.Outline)

                keyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    keyBtn.Text      = "..."
                    keyBtn.TextColor3 = T().Accent
                end)

                UserInputService.InputBegan:Connect(function(inp, gpe)
                    if listening and not gpe then
                        if inp.UserInputType == Enum.UserInputType.Keyboard then
                            key = inp.KeyCode
                            if flag then Library.Flags[flag] = key end
                            keyBtn.Text       = key.Name
                            keyBtn.TextColor3 = T().SubText
                            listening = false
                        end
                    elseif not gpe and not listening and inp.KeyCode == key and key ~= Enum.KeyCode.Unknown then
                        pcall(cb)
                    end
                end)

                RegisterListener(function(t)
                    keyBtn.BackgroundColor3 = t.Secondary
                    keyBtn.TextColor3       = t.SubText
                    keyBtn.Font             = Enum.Font.Gotham
                end)

                local Ref = {}
                function Ref:Set(k) key = k; keyBtn.Text = k.Name end
                function Ref:Get() return key end
                function Ref:Dependency(toggleRef, requireVal)
                    local function Upd() row.Visible = (toggleRef:Get() == requireVal) end
                    RunService.Heartbeat:Connect(Upd); Upd()
                end
                return Ref
            end

            -- ══════════════════════════════════════════════
            --  LABEL
            -- ══════════════════════════════════════════════
            function GB:CreateLabel(opts)
                local text    = opts.Text  or ""
                local clr     = opts.Color
                local theme   = T()

                local lbl = New("TextLabel", {
                    Size                = UDim2.new(1, 0, 0, 0),
                    AutomaticSize       = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Text                = text,
                    TextColor3          = clr or theme.SubText,
                    Font                = Library.Font,
                    TextSize            = 12,
                    TextXAlignment      = Enum.TextXAlignment.Left,
                    TextWrapped         = true,
                    ZIndex              = 5,
                    Parent              = self._list,
                })
                if not clr then
                    RegisterListener(function(t) lbl.TextColor3 = t.SubText; lbl.Font = Library.Font end)
                end
                local Ref = {}
                function Ref:Set(t) lbl.Text = t end
                function Ref:Get() return lbl.Text end
                return Ref
            end

            -- ══════════════════════════════════════════════
            --  DIVIDER
            -- ══════════════════════════════════════════════
            function GB:CreateDivider(labelText)
                local theme = T()
                if labelText and labelText ~= "" then
                    local container = New("Frame", {
                        Size = UDim2.new(1, 0, 0, 16),
                        BackgroundTransparency = 1,
                        ZIndex = 4, Parent = self._list,
                    })
                    New("Frame", {
                        Size = UDim2.new(0.38, 0, 0, 1),
                        Position = UDim2.new(0, 0, 0.5, 0),
                        BackgroundColor3 = theme.Outline, BorderSizePixel = 0, ZIndex = 4, Parent = container,
                    })
                    New("TextLabel", {
                        Size = UDim2.new(0.24, 0, 1, 0), Position = UDim2.new(0.38, 0, 0, 0),
                        BackgroundTransparency = 1, Text = labelText,
                        TextColor3 = theme.SubText, Font = Enum.Font.Gotham, TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 5, Parent = container,
                    })
                    New("Frame", {
                        Size = UDim2.new(0.38, 0, 0, 1), Position = UDim2.new(0.62, 0, 0.5, 0),
                        BackgroundColor3 = theme.Outline, BorderSizePixel = 0, ZIndex = 4, Parent = container,
                    })
                else
                    New("Frame", {
                        Size = UDim2.new(1, 0, 0, 1),
                        BackgroundColor3 = theme.Outline, BorderSizePixel = 0,
                        ZIndex = 4, Parent = self._list,
                    })
                end
            end

            return GB
        end -- CreateGroupbox

        return Tab
    end -- CreateTab

    -- ════════════════════════════════════════════════════════
    --  BUILT-IN: OPTIONS TAB
    -- ════════════════════════════════════════════════════════
    local OptionsTab    = Win:CreateTab("Options")
    local OptLeft       = OptionsTab:CreateGroupbox("Appearance", "Left")
    local OptRight      = OptionsTab:CreateGroupbox("Interface", "Right")

    -- Theme Dropdown
    local themeNames = {}
    for k in pairs(Library.Themes) do table.insert(themeNames, k) end
    table.sort(themeNames)

    OptLeft:CreateDropdown({
        Name    = "Theme",
        Options = themeNames,
        Default = Library.CurrentTheme,
        Tooltip = "Choose a colour theme",
        Callback = function(sel)
            Library.CurrentTheme = sel
            FireTheme()
        end,
    })

    local accentPickerRef = OptLeft:CreateColorPicker({
        Name    = "Accent Color",
        Default = T().Accent,
        Tooltip = "Override the accent colour for the current theme",
        Callback = function(c)
            Library.Themes[Library.CurrentTheme].Accent    = c
            Library.Themes[Library.CurrentTheme].AccentDark = Color3.new(c.R * 0.7, c.G * 0.7, c.B * 0.7)
            Library.Themes[Library.CurrentTheme].AccentGlow = Color3.new(math.min(c.R * 1.3, 1), math.min(c.G * 1.3, 1), math.min(c.B * 1.3, 1))
            FireTheme()
        end,
    })

    OptLeft:CreateToggle({
        Name    = "Rounded Corners",
        Default = Library.RoundedCorners,
        Tooltip = "Toggle rounded or sharp corner radius",
        Callback = function(v) Library.RoundedCorners = v end,
    })

    OptLeft:CreateSlider({
        Name    = "Corner Radius",
        Min = 0, Max = 14, Default = Library.CornerRadius,
        Tooltip = "Pixel radius of rounded corners",
        Callback = function(v) Library.CornerRadius = v end,
    })

    local fontMap = {
        ["Gotham Medium"] = Enum.Font.GothamMedium,
        ["Gotham"]        = Enum.Font.Gotham,
        ["Gotham Bold"]   = Enum.Font.GothamBold,
        ["Arial"]         = Enum.Font.Arial,
        ["Code"]          = Enum.Font.Code,
        ["Source Sans"]   = Enum.Font.SourceSans,
    }
    local fontKeys = {}
    for k in pairs(fontMap) do table.insert(fontKeys, k) end
    table.sort(fontKeys)

    OptLeft:CreateDropdown({
        Name    = "Font",
        Options = fontKeys,
        Default = "Gotham Medium",
        Tooltip = "Change the UI font family",
        Callback = function(f)
            Library.Font = fontMap[f] or Enum.Font.GothamMedium
            FireTheme()
        end,
    })

    OptRight:CreateSlider({
        Name   = "UI Scale",
        Min = 50, Max = 150, Default = 100, Suffix = "%",
        Tooltip = "Scales the window size",
        Callback = function(pct)
            Library.Scale = pct / 100
            Root.Size = UDim2.new(
                winSize.X.Scale, winSize.X.Offset * Library.Scale,
                winSize.Y.Scale, winSize.Y.Offset * Library.Scale
            )
        end,
    })

    OptRight:CreateSlider({
        Name   = "Transparency",
        Min = 0, Max = 80, Default = 0, Suffix = "%",
        Tooltip = "Background transparency of the window",
        Callback = function(pct)
            Library.Transparency = pct / 100
            Root.BackgroundTransparency = Library.Transparency
        end,
    })

    OptRight:CreateToggle({
        Name    = "Blur Background",
        Default = false,
        Tooltip = "Apply depth-of-field blur effect",
        Callback = function(v)
            Library.BlurEnabled = v
            local lighting = game:GetService("Lighting")
            local blur = lighting:FindFirstChild("_UILibBlur")
            if v then
                if not blur then
                    blur = Instance.new("BlurEffect")
                    blur.Name = "_UILibBlur"
                    blur.Size = 12
                    blur.Parent = lighting
                end
                blur.Enabled = true
            else
                if blur then blur.Enabled = false end
            end
        end,
    })

    OptRight:CreateButton({
        Name    = "Reset Theme",
        Tooltip = "Restore the default theme settings",
        Callback = function()
            Library.CurrentTheme = "Dark"
            FireTheme()
            Library:Notify({ Title = "Theme Reset", Message = "Reverted to Dark theme.", Type = "Info" })
        end,
    })

    -- ════════════════════════════════════════════════════════
    --  BUILT-IN: CONFIG TAB
    -- ════════════════════════════════════════════════════════
    local ConfigTab   = Win:CreateTab("Config")
    local CfgLeft     = ConfigTab:CreateGroupbox("Configs", "Left")
    local CfgRight    = ConfigTab:CreateGroupbox("Actions", "Right")

    local CFG_FOLDER  = "UILibConfigs"

    local function SafeFS(fn, ...) local ok, r = pcall(fn, ...) return ok, r end
    local function EnsureDir()
        if not isfolder(CFG_FOLDER) then makefolder(CFG_FOLDER) end
    end
    local function GetCfgList()
        local list = {}
        SafeFS(EnsureDir)
        local ok, files = SafeFS(listfiles, CFG_FOLDER)
        if ok and files then
            for _, f in ipairs(files) do
                local name = (f:match("[^/\\]+$") or f)
                if name:sub(-5) == ".json" then
                    table.insert(list, name:sub(1, -6))
                end
            end
        end
        table.sort(list)
        return list
    end

    local function SerializeFlags()
        local data = {}
        for k, val in pairs(Library.Flags) do
            local t = type(val)
            if t == "boolean" or t == "number" or t == "string" then
                data[k] = val
            elseif typeof(val) == "Color3" then
                data[k] = { _T = "C3", r = val.R, g = val.G, b = val.B }
            elseif typeof(val) == "EnumItem" then
                data[k] = { _T = "EI", eType = tostring(val.EnumType), name = val.Name }
            end
        end
        return data
    end

    local function DeserializeFlags(data)
        for k, val in pairs(data) do
            if type(val) == "table" then
                if val._T == "C3" then
                    Library.Flags[k] = Color3.new(val.r, val.g, val.b)
                elseif val._T == "EI" then
                    pcall(function() Library.Flags[k] = Enum[val.eType][val.name] end)
                end
            else
                Library.Flags[k] = val
            end
        end
    end

    local cfgNameRef = CfgLeft:CreateTextInput({
        Name        = "Config Name",
        Placeholder = "MyConfig",
        Default     = "MyConfig",
    })

    local cfgDropRef = CfgLeft:CreateDropdown({
        Name    = "Saved Configs",
        Options = GetCfgList(),
        Tooltip = "Select a config to load or delete",
    })

    CfgRight:CreateButton({
        Name    = "Save Config",
        Tooltip = "Save current element states to a JSON file",
        Callback = function()
            local name = cfgNameRef:Get()
            if name == "" then name = "MyConfig" end
            SafeFS(EnsureDir)
            local ok, err = SafeFS(writefile, CFG_FOLDER .. "/" .. name .. ".json",
                HttpService:JSONEncode(SerializeFlags()))
            if ok then
                Library:Notify({ Title = "Config Saved", Message = '"' .. name .. '" saved successfully.', Type = "Success" })
                cfgDropRef:SetOptions(GetCfgList())
            else
                Library:Notify({ Title = "Save Failed", Message = tostring(err), Type = "Error" })
            end
        end,
    })

    CfgRight:CreateButton({
        Name    = "Load Config",
        Tooltip = "Load a saved config and apply all element states",
        Callback = function()
            local name = cfgDropRef:Get()
            if not name then
                Library:Notify({ Title = "No Config", Message = "Select a config from the list.", Type = "Warning" })
                return
            end
            local ok, raw = SafeFS(readfile, CFG_FOLDER .. "/" .. name .. ".json")
            if ok then
                local decoded
                ok, decoded = SafeFS(function() return HttpService:JSONDecode(raw) end)
                if ok and decoded then
                    DeserializeFlags(decoded)
                    Library:Notify({ Title = "Config Loaded", Message = '"' .. name .. '" applied.', Type = "Success" })
                else
                    Library:Notify({ Title = "Parse Error", Message = "Config file is corrupted.", Type = "Error" })
                end
            else
                Library:Notify({ Title = "Read Error", Message = "Could not read the config file.", Type = "Error" })
            end
        end,
    })

    CfgRight:CreateButton({
        Name    = "Delete Config",
        Tooltip = "Permanently delete the selected config",
        Callback = function()
            local name = cfgDropRef:Get()
            if not name then
                Library:Notify({ Title = "No Config", Message = "Select a config from the list.", Type = "Warning" })
                return
            end
            local ok, _ = SafeFS(delfile, CFG_FOLDER .. "/" .. name .. ".json")
            Library:Notify({
                Title   = ok and "Deleted" or "Delete Failed",
                Message = ok and ('"' .. name .. '" has been deleted.') or "Could not delete the file.",
                Type    = ok and "Success" or "Error",
            })
            cfgDropRef:SetOptions(GetCfgList())
        end,
    })

    CfgRight:CreateButton({
        Name    = "Refresh List",
        Tooltip = "Re-scan disk for saved config files",
        Callback = function()
            cfgDropRef:SetOptions(GetCfgList())
            Library:Notify({ Title = "Refreshed", Message = "Config list updated.", Type = "Info" })
        end,
    })

    CfgRight:CreateDivider()

    CfgRight:CreateButton({
        Name    = "Reset All Flags",
        Tooltip = "Clear all flag values (does NOT delete files)",
        Callback = function()
            table.clear(Library.Flags)
            Library:Notify({ Title = "Flags Cleared", Message = "All flags have been reset.", Type = "Warning" })
        end,
    })

    table.insert(Library._windows, Win)

    return Win
end

-- ──────────────────── Library Cleanup ─────────────────────
function Library:Destroy()
    pcall(function()
        local blur = game:GetService("Lighting"):FindFirstChild("_UILibBlur")
        if blur then blur:Destroy() end
    end)
    pcall(function() ScreenGui:Destroy() end)
end

return Library
