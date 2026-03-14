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
--   (Fixed: memory leaks, theme rebuilds, cleanup, utils)
--
--   Usage:
--     local UI = loadstring(game:HttpGet("https://example.com/UILibrary.lua"))()
--     local Window = UI:CreateWindow({ Title = "My Script", ToggleKey = Enum.KeyCode.RightShift })
--
-- ============================================================

local Library = {}
Library.__index = Library

-- ──────────────────── Constants ────────────────────────────
local DEFAULT_CORNER_RADIUS = 6
local DEFAULT_FONT = Enum.Font.GothamMedium
local POPUP_Z_INDEX = 1000
local TOOLTIP_Z_INDEX = 9999
local ANIMATION_TIME = 0.15
local EASING_STYLE = Enum.EasingStyle.Quad
local EASING_DIR = Enum.EasingDirection.Out

-- ──────────────────── Services ────────────────────────────
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local Players           = game:GetService("Players")
local HttpService       = game:GetService("HttpService")
local TextService       = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer

-- ──────────────────── Utility Functions ────────────────────
local function tableFind(t, value)
    for i, v in ipairs(t) do
        if v == value then return i end
    end
    return nil
end

local function tableClear(t)
    for k in pairs(t) do
        t[k] = nil
    end
end

local function safePCall(fn, ...)
    local success, result = pcall(fn, ...)
    if not success then
        warn("[UILibrary] Error:", result)
    end
    return success, result
end

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
Library.CornerRadius   = DEFAULT_CORNER_RADIUS
Library.Font           = DEFAULT_FONT
Library.Scale          = 1
Library.BlurEnabled    = false
Library.Transparency   = 0
Library.RoundedCorners = true
Library.Flags          = {}
Library._windows       = {}
Library._themeListeners = {} -- each listener is { func, remove }
Library._tooltipConnection = nil

-- ──────────────────── Internal Helpers ────────────────────
local function T()   return Library.Themes[Library.CurrentTheme] end
local function CR()  return Library.RoundedCorners and Library.CornerRadius or 0 end

local function Tween(obj, props, t, style, dir)
    if not obj or not obj.Parent then return end
    TweenService:Create(
        obj,
        TweenInfo.new(t or ANIMATION_TIME, style or EASING_STYLE, dir or EASING_DIR),
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

-- Theme listener registration with removal capability
function Library:RegisterListener(fn)
    local listener = { func = fn }
    table.insert(self._themeListeners, listener)
    return function()
        for i, v in ipairs(self._themeListeners) do
            if v == listener then
                table.remove(self._themeListeners, i)
                break
            end
        end
    end
end

local function FireTheme()
    local theme = T()
    for _, listener in ipairs(Library._themeListeners) do
        safePCall(listener.func, theme)
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
        ok = pcall(function()
            sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end)
    end
    if not ok then
        warn("[UILibrary] Could not parent ScreenGui to CoreGui or PlayerGui.")
    end
    ScreenGui = sg
end

-- ──────────────────── Popup Container ─────────────────────
local PopupContainer = New("Frame", {
    Name = "PopupContainer",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    ZIndex = POPUP_Z_INDEX,
    Parent = ScreenGui,
})

-- ──────────────────── Tooltip ─────────────────────────────
local ToolTipFrame = New("Frame", {
    Name             = "Tooltip",
    Size             = UDim2.new(0, 160, 0, 26),
    BackgroundColor3 = T().Secondary,
    BorderSizePixel  = 0,
    Visible          = false,
    ZIndex           = TOOLTIP_Z_INDEX,
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
    ZIndex              = TOOLTIP_Z_INDEX + 1,
    Parent              = ToolTipFrame,
})

Library:RegisterListener(function(t)
    ToolTipFrame.BackgroundColor3 = t.Secondary
    ToolTipLabel.TextColor3       = t.Text
end)

-- Tooltip position update connection (stored for cleanup)
Library._tooltipConnection = RunService.RenderStepped:Connect(function()
    if ToolTipFrame.Visible then
        local mp = UserInputService:GetMouseLocation()
        ToolTipFrame.Position = UDim2.new(0, mp.X + 14, 0, mp.Y + 8)
    end
end)

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
    self:RegisterListener(function(t)
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
        _cleanup    = {}, -- functions to call on destroy
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
    New("ImageLabel", {
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
    table.insert(Win._cleanup, Library:RegisterListener(function(t)
        if not Root.Parent then return end
        Root.BackgroundColor3     = t.Background
        rootStroke.Color          = t.Outline
        TitleBar.BackgroundColor3 = t.Secondary
        TitleLabel.TextColor3     = t.Text
        AccentLine.BackgroundColor3 = t.Accent
        TabBar.BackgroundColor3   = t.Secondary
        for _, c in ipairs(TitleBar:GetChildren()) do
            if c:IsA("Frame") and c.Name ~= "AccentLine" then
                c.BackgroundColor3 = t.Secondary
            end
        end
    end))

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
            task.delay(0.21, function() if not self._visible and Root then Root.Visible = false end end)
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
            if Root then Root:Destroy() end
            for _, cleanup in ipairs(self._cleanup) do cleanup() end
            tableClear(self._cleanup)
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
            _cleanup = {},
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
            table.insert(Tab._cleanup, Library:RegisterListener(function(t)
                if sf and sf.Parent then sf.ScrollBarImageColor3 = t.Scrollbar end
            end))
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

        table.insert(Tab._cleanup, Library:RegisterListener(function(t)
            if not TabBtn or not TabBtn.Parent then return end
            TabAccent.BackgroundColor3 = t.Accent
            if self._activeTab == Tab then
                TabBtn.BackgroundColor3 = t.Tertiary
                TabBtn.TextColor3       = t.Text
            else
                TabBtn.TextColor3 = t.SubText
            end
        end))

        -- ──────────────────────────────────────────────────
        --  CreateGroupbox
        -- ──────────────────────────────────────────────────
        function Tab:CreateGroupbox(gbName, side)
            local theme = T()
            local col   = (side == "Right") and self._rightCol or self._leftCol

            local GB = {
                _tab = self,
                _cleanup = {},
                _list = nil,
            }

            local GBFrame = New("Frame", {
                Name             = "GB_" .. gbName,
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundColor3 = theme.Element,
                BorderSizePixel  = 0,
                ZIndex           =  ZIndex           = 3,
               3,
                Parent           Parent           = col,
            = col,
            })
            })
            Corner( Corner(GBFrame, GBFrame, 8)
8)
            local gbStroke =            local gbStroke = Stroke(GBFrame Stroke(GBFrame, theme.Outline)

           , theme.Outline)

            -- Header
            -- Header
            local GB local GBHeader =Header = New(" New("Frame", {
                Name               Frame", {
                Name                = " = "Header",
Header",
                Size                =                Size                = UDim2.new UDim2.new(1, 0,(1, 0, 0 0, , 26),
                BackgroundTransparency = 1,
                ZIndex              = 4,
                Parent              = GBFrame,
            })
            local headerDivider = New("Frame", {
26),
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
            Size             = UDim2.new(1, -14, 0, 1),
                Position         = UDim2.new(0, 7, 1, -1),
                BackgroundColor3 = theme.Outline,
                BorderSizePixel  = 0,
                ZIndex           = 4,
                Parent           = GBHeader,
            })
            local headerTitle = New("TextLabel })
            local headerTitle = New("TextLabel", {
                Size                =", {
                Size                = UDim2.new(1, - UDim2.new(1, -14, 114, 1, 0),
, 0),
                Position            =                Position            = UDim2.new UDim2.new(0, 10,(0, 10, 0 0, 0),
, 0),
                BackgroundTransparency = 1,
                BackgroundTransparency = 1,
                Text                Text                =                = gbName,
 gbName,
                Text                TextColor3          =Color3          = theme.Sub theme.SubText,
                FontText,
                Font                = Enum.Font.GothamBold,
                = Enum.Font.GothamBold,
                TextSize            = 11,
                TextXAlignment      = Enum.TextXAlignment.Left                TextSize            = 11,
                TextXAlignment      = Enum.TextXAlignment.Left,
                ZIndex              = 5,
               ,
                ZIndex              = 5,
                Parent              = GB Parent              = GBHeader,
            })

Header,
            })

            -- Content list
            local GBContent =            -- Content list
            local GBContent = New("Frame", New("Frame", {
                Name                = " {
                Name                = "Content",
                Size                = UDimContent",
                Size                = UDim2.new2.new(1, (1, 0, 0, 0, 0, 0),
                Automatic0),
                AutomaticSize       = EnumSize      .Automatic = Enum.AutomaticSize.YSize.Y,
                Position            = U,
                Position            = UDim2.new(Dim2.new(0,0, 0 0, 0,, 0, 26 26),
                BackgroundTrans),
                BackgroundTransparency = 1parency = 1,
                ZIndex              =,
                ZIndex              = 3,
                3 Parent              = GB,
                Parent              = GBFrame,
Frame,
            })
            Padding            })
            Padding(GB(GBContent,Content, 4 4, 8,, 8, 8 8, 8)
            ListLayout(, 8)
GBContent            ListLayout(GBContent, 5)
, 5)
            GB._list            GB._list = GBContent

            table = GBContent

            table.insert(GB._.insert(GB._cleanupcleanup, Library:RegisterListener(function, Library:RegisterListener(function(t)
                if(t)
                if not GBFrame or not GBFrame or not GBFrame.P not GBFrame.Parent then return endarent then return end
                GBFrame.Background
                GBFrame.BackgroundColor3Color3   = t.Element   = t.Element
                gb
                gbStroke.Color             = t.Stroke.Color             = t.Outline
                headerDividerOutline
                headerDivider.BackgroundColor3 = t.Outline
               .BackgroundColor3 = t.Outline
                headerTitle headerTitle.TextColor3.TextColor3     = t     = t.SubText
           .SubText
            end))

            -- ─ end))

            -- ──────────────────────────────────────────────────────────────────────────────────────────
            --─
            --  Shared  Shared element row element row builder
            -- builder
            -- ───────────────────────────────── ──────────────────────────────────────────────
─────────────
            local function E            local function ElemRowlemRow(labelText, height(labelText, height, tool, tooltip)
                localtip)
                local theme = T()
                local theme = T()
                local row = row = New("Frame", New("Frame", {
                    Size                {
                    Size                = U = UDim2.new(Dim2.new(1, 0, 0, height or 261, 0, 0, height or 26),
                    BackgroundTrans),
                    BackgroundTransparency = 1,
                    ZIndexparency = 1,
                                 = 4 ZIndex              = 4,
                    Parent             ,
                    = GB._list Parent              = GB._list,
                })
               ,
                local lbl = New })
                local lbl = New("Text("TextLabel", {
                   Label", {
                    Size                = UDim2 Size                = U.new(Dim2.new(0.58,0.58, 0,  0, 1, 0),
                   1, 0),
                    BackgroundTrans BackgroundTransparency =parency = 1 1,
                    Text               ,
                    Text                = label = labelText,
                    TextColor3Text,
                    TextColor3          =          = theme.Text,
                    theme.Text,
                    Font                = Library Font                = Library.Font,
                    Text.Font,
                    TextSize           Size            = 12,
                    Text = 12,
                    TextXAlignment      =XAlignment      = Enum.TextXAlignment.Left Enum.TextXAlignment.Left,
                   ,
                    ZIndex              = 5 ZIndex              = 5,
                   ,
                    Parent              = row Parent              = row,
                })
               ,
                })
                if tool if tooltip then AttachTooltiptip then Attach(row, tooltipTooltip(row, tooltip) end
               ) end table.insert(GB
                table.insert(GB._cleanup,._cleanup, Library:RegisterListener Library:RegisterListener(function(t)
                   (function(t if lbl and lbl)
                    if lbl and lbl.Parent.Parent then
                        lbl then
                        lbl.TextColor3 =.TextColor3 = t.Text t.Text
                       
                        lbl.Font       = lbl.Font Library.Font       =
                    Library.Font
                    end
 end
                end                end))
                return row, lbl
           ))
                return row, lbl end


            end

            --            -- ═════ ══════════════════════════════════════════════════════════════════════════════
            --═════════
            --  BUTTON
  BUTTON
            --            -- ═════════════════════ ══════════════════════════════════════════════════════
═════════════════
            function            function GB:CreateButton GB:CreateButton(opts(opts)
                local n       =)
                local n       = opts.Name     or "Button opts.Name     or"
                local cb "Button"
                local cb      = opts.C      = optsallback or.Callback or function() function() end
                local end
                local tooltip = opts tooltip.Tooltip
 = opts.Tooltip
                local                local theme   theme   = T = T()

                local row()

                local row = New = New("Frame", {
                    Size("Frame", {
                =                    Size                = UDim2.new(1 UDim2.new(1, 0, 0, , 0, 028),
, 28),
                    Background                    BackgroundTransparencyTransparency = 1,
 =                     ZIndex              = 1,
                    ZIndex             4,
 = 4,
                    Parent              = self._                    Parent              =list,
 self._list,
                               })

                local btn = })

                local New(" btn = New("TextButtonTextButton", {
                    Size", {
             = UDim                    Size             =2.new(1 UDim2.new, (1, 0,0, 0,  026),
,                     Position26),
         = UDim2.new                    Position         = UDim(02.new(0, 0, 0, , 1),
                    Background0, 0, 1),
                    BackgroundColor3Color3 = theme.Accent,
                    = theme.Accent,
                    BorderSizePixel  = 0,
                    Text             = BorderSizePixel  = 0,
                    Text             = n,
 n,
                    TextColor3                    TextColor3       = Color3.fromRGB(255       = Color3.fromRGB(255, , 255, 255255,),
                    255),
                    Font             Font             = Enum.Font.Gotham = Enum.Font.GothamMedium,
Medium,
                    TextSize         =                     TextSize         = 12,
                    Z12,
Index           =                     ZIndex           = 5,
                    Parent5,
           = row,
                    Parent           =                })
                Corner row,
                })
                Corner(btn(btn, , 6)
                if6)
                if tooltip tooltip then AttachTool then AttachTooltip(tip(btn,btn, tooltip) end tooltip

               ) end

                btn.M btn.MouseEnter:ConnectouseEnter(function():Connect(function()    T    Tween(ween(btn, { Backgroundbtn, { BackgroundColor3Color3 = T().Acc = T().AccentGlow },entGlow }, 0.12) end 0.12) end)
                btn.MouseLeave)
                btn.MouseLeave:Connect(function():Connect(function()    T    Tween(btn, { BackgroundColor3 = Tween(btn, { BackgroundColor3 = T().Accent },     0.12) end)
                btn.MouseButton1Down:Connect(function()  Tween(().Accent },     0.12) end)
                btn.MouseButton1Down:Connect(function()  Tween(btn, { Backgroundbtn, { BackgroundColor3 = T().AccentDark }, Color3 = T().AccentDark }, 0.08) end)
                btn0.08) end)
                btn.Mouse.MouseButton1Up:Connect(function()Button1Up:Connect(function()    T    Tween(btn, {ween(btn, { BackgroundColor3 = BackgroundColor3 = T().Accent },      T().Accent },     0.0.12)12) end)
                btn end)
                btn.Mouse.MouseButton1Click:Connect(functionButton1Click:Connect(function()
                   ()
                    safePCall(cb)
 safePCall(cb)
                end                end)

                table.insert)

                table.insert(self._cleanup, Library(self._cleanup, Library:RegisterListener(function:Register(t)
                    ifListener(function(t)
 btn and                    if btn and btn.Parent then btn.Back btn.Parent then btn.BackgroundColor3 =groundColor3 = t.Acc t.Accent end
               ent end end))

                local Ref =
                end))

                local Ref = {}
                function Ref:SetText(text {}
                function Ref:SetText(text) btn.Text = text end
               ) btn.Text = text end
                return Ref
            return Ref
            end

 end

            --            -- ═════ ══════════════════════════════════════════════════════════════════════════════════════
═
            --  TOGGLE            --  TOGGLE
            --
            -- ═ ══════════════════════════════════════════════════════════════════════════════════════
═════
                       function GB function GB:CreateToggle(opts)
                local:CreateToggle(opts)
 n                      local n       = opts.Name     or " = opts.Name    Toggle"
                local or "Toggle"
                local default = opts.Default default = opts.Default  == true
  == true
                local flag                   local flag    = opts.Flag = opts.Flag
                local cb
                local cb      = opts.Callback or      = opts.C function() end
                localallback or function() end
 tooltip                local tooltip = opts = opts.Tooltip
.Tooltip
                local                local theme   theme   = T()

                = T local state = default()

                local state
                if flag = default
                if flag then Library.Fl then Library.Flags[flag]ags = state end

[flag] = state end

                local row,                local _ = Elem row, _ = ElemRow(n, Row(n, 26, tooltip26, tooltip)

                local)

                local track track = New("Frame = New("Frame", {
                    Size             =", {
                    Size             = UDim UDim2.new2.new(0(0, 36,, 36, 0,  018),
                    Position, 18),
                    Position         = UDim         =2.new(1 UDim2.new(1, -36, 0, -36, 0.5.5, -9),
                    Background, -9),
                    BackgroundColor3 = state and theme.AccentColor3 = state and theme.Accent or theme or theme.Outline,
                    BorderSize.Outline,
                    BorderSizePixel  = Pixel 0,
 = 0,
                    Z                    ZIndex          Index           =  = 5,
                    Parent5,
           =                    Parent           = row,
                })
                Corner row,
                })
(track, 9)

                Corner(track,                 local9)

                local knob = knob = New("Frame", New(" {
                   Frame", {
                    Size             Size             = UDim2 = U.new(0,Dim2.new(0, 12,  120,, 0, 12 12),
                   ),
                    Position         = state Position         = state and UDim2 and UDim2.new(1,.new(1, -15, 0.5, -15, 0.5, -6 -6) or UDim2.new) or UDim2.new(0, (0, 3, 0.53, 0.5, -6),
                    Background, -6),
                    BackgroundColor3 = ColorColor3 = Color3.from3.fromRGB(RGB(255, 255255, 255, 255),
                    Border, 255),
                    BorderSizePixel  =SizePixel 0,
                     = 0,
                    ZIndex           = ZIndex 6,
                              = 6,
                    Parent           = track,
                Parent           })
                = track,
                })
                Corner(knob,  Corner(knob6)

                local, 6)

                local Ref = Ref = {}
                Ref._state = {}
                Ref._state = state
 state
                Ref                Ref._cb._cb    = cb

                local    = cb

                local function SetState(val function SetState(val, silent)
                   , silent)
                    state     = val state     = val
                   
                    Ref._ Ref._state = val
state = val
                    if                    if flag then flag then Library.Flags Library.Flags[flag[flag] = val end] = val end
                   
                    Tween(track Tween(track, { BackgroundColor, { BackgroundColor3 =3 = val and val and T().Accent T().Accent or T or T().Outline }, 0.14)
                    Tween(k().Outline }, 0.14)
                    Tnob,  { Position = val and UDim2.new(1, -15, 0.5, -6) or UDim2.newween(knob,  { Position = val and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0(0, 3, 0.5.5, -6), -6) },  }, 0.0.14)
                    if14)
                    if not silent not silent then safePCall then safePCall(cb, val(cb, val) end) end
                end


                end

                --                -- Invisible Invisible click region
                click region
                New(" New("TextButtonTextButton", {
                    Size", {
                    Size                =                = UDim UDim2.new2.new(1, (1, 0,0, 1,  10),
                    Background, 0),
                    BackgroundTransparency = Transparency = 1,
1,
                    Text                    Text                = "",
                                   = "",
                    ZIndex ZIndex              = 7,
                                 = 7 Parent              = row,
               ,
                    Parent              = row,
                }).MouseButton1 }).MouseButton1Click:Click:Connect(functionConnect(function() SetState(() SetState(not state) end)

                table.insert(self._not state) end)

                table.insert(self._cleanup, Library:RegisterListener(functioncleanup, Library:RegisterListener(function(t)
                    if track and track.Parent then
                        track(t)
                    if track and track.Parent then
                        track.BackgroundColor3 = state and t.BackgroundColor3 = state.Accent and t.Accent or t or t.Outline
                    end
                end))

                function Ref:Set(v) SetState.Outline
                    end
                end))

                function Ref:Set(v)(v) end
                function Ref:Get() SetState(v) end
                function Ref:Get() return state end
                function Ref:Dependency(toggleRef, requireVal)
                    local conn return state end
                function Ref:Dependency(toggleRef, requireVal)
                    local conn
                    local function
                    local function Upd()
                        if not row then conn Upd()
                        if not row then conn:Disconnect() return:Disconnect() return end
                        row.Visible end
                        row.Visible = (toggleRef = (toggleRef:Get() == requireVal)
                   :Get() == requireVal)
                    end
                    conn = RunService.Heartbeat end
                    conn = RunService.Heartbeat:Connect(Upd)
                    Up:Connect(Upd)
                    Upd()
d()
                end

                return Ref                end

                return Ref
            end

            --
            end

            -- ═════════════════════════════════════════════ ══════════════════════════════════════════════
            --  SLIDER
            -- ══════════════════════════════════════════════
            function GB:CreateSlider(opts)
                local n       = opts.Name     or═
            --  SLIDER
            -- ══════════════════════════════════════════════
            function GB:CreateSlider(opts)
                local n       = opts.Name     or "Slider"
                "Slider"
                local min     = opts.Min      or 0 local min     = opts.Min      or 0
                local max     = opts.Max
                local max     = opts.Max      or 100
                local default      or 100
                local default = math.clamp(opts.Default or min, = math.clamp(opts.Default or min, min, min, max)
                local max)
                local step    = opts step    = opts.Step     or 1
                local suffix  = opts.Suffix   or ""
                local flag    = opts.Step     or 1
                local suffix  = opts.Suffix   or ""
                local flag    = opts.Flag.Flag
                local cb      = opts.Callback or function() end
                local tooltip = opts.Tooltip
                local theme   = T()

                local value   = default
                if flag then Library.F
                local cb      = opts.Callback or function() end
                local tooltip = opts.Tooltip
                local theme   = T()

                local value   = default
                if flag then Library.Flags[flag] = value end

                local rowlags[flag] = value end

                local row = New("Frame", {
                    Size                = UDim2.new(1, 0, 0, 44),
                    BackgroundTransparency = 1,
                    ZIndex              = 4,
                    Parent              = self._list,
 = New("Frame", {
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
                    Font                })
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
                    Position         = UDim2.new(0, 0,                = Library.Font,
                    TextSize            = 12,
                    TextXAlignment      = Enum.TextXAlignment.Right,
                    ZIndex              = 6,
                    Parent              = topRow,
                })

                -- Track
                local track = New("Frame", {
                    Size             = UDim2.new(1, 0, 0, 6),
                    Position         = UDim2.new(0, 0, 0 0, 26),
                    BackgroundColor3 = theme.Outline,
                    BorderSizePixel , 26),
                    BackgroundColor3 = theme.Outline,
                    BorderSize = 0,
                    ZIndex           = 5,
                    Parent           = row,
                })
                CornerPixel  = 0,
                    ZIndex           = 5,
                    Parent           = row,
                })
                Corner(track, 3)

(track, 3)

                local pct0 =                local pct0 = (value - min (value - min) / (max - min)
                local fill = New) / (max - min)
                local fill = New("Frame", {
                    Size             = UDim2.new(pct0,("Frame", {
                    Size             = UDim2.new(pct0, 0, 1, 0, 1, 0),
                    0),
                    BackgroundColor3 = BackgroundColor3 = theme.Accent,
                    BorderSizePixel theme.Accent,
                    Border  = 0,
                    ZIndexSizePixel  = 0,
                    ZIndex           = 6           = 6,
                    Parent           = track,
                })
                Corner(f,
                    Parent           = track,
                })
                Corner(fill, 3ill, 3)

               )

                local knob = New local knob = New("Frame", {
("Frame", {
                    Size             = UDim2.new(0                    Size             = UDim2.new(0, , 12, 0, 12),
                    Position         =12, 0, 12),
                    Position         = UDim UDim2.new(pct2.new(pct0, -6, 0, -60., 0.5,5, -6 -6),
                    BackgroundColor),
                    BackgroundColor3 =3 = Color3.fromRGB Color3.fromRGB(255, 255,(255,  255255, 255),
                    BorderSize),
                    BorderSizePixel Pixel  = 0,
 = 0,
                                       ZIndex           = 7,
                    Parent ZIndex           = 7,
                    Parent           = track,
                })
           = track,
                })
                Corner(kn                Corner(knob,ob, 6)

                local Ref 6)

                = {}

                local local Ref = {}

                local function SetValue(v function SetValue(v, silent)
                    v = math.cl, silent)
                    v = math.clamp(step == 1amp(step == 1 and math and math.round(v) or.round(v) or (math.floor(v (math.floor(v / step +  / step + 0.0.5)5) * step), min, max * step), min, max)
                   )
                    value = v
 value =                    if flag then Library.F v
                    if flag thenlags[flag Library.Flags[flag] =] = v end
                    v end
                    local p local p = ( = (v - min)v - / (max - min) / (max - min)
                    T min)
ween(fill,                    Tween(fill,  { Size      { = UDim2 Size     = UDim2.new(p, 0,.new(p, 0, 1 1, 0)       },, 0)       }, 0 0.07)
                   .07)
                    Tween Tween(kn(knob, { Positionob, { Position = UDim2 = UDim2.new(p.new(p, -6,, -6, 0.5 0.5, -6), -6)    },    }, 0.07 0.07)
                   )
                    valLbl.Text valL = tostring(vbl.Text = tostring(v) .. suffix
) .. suffix
                    if                    if not silent not silent then safe then safePCall(cb, v) end
                end

PCall(cb, v) end
                end

                local                local sliding = false
 sliding = false
                track                track.InputBegan:.InputBegan:Connect(functionConnect(function(inp)
                   (inp)
                    if inp.UserInputType == if inp.UserInputType == Enum.User Enum.UserInputType.MouseButton1InputType.MouseButton1 then
 then
                        sliding = true                        sliding = true
                        local rel
                        local rel = math = math.clamp((in.clamp((inp.Pp.Position.Xosition.X - track.AbsolutePosition.X) / track.Abs - track.AbsolutePosition.X) / track.AbsoluteSize.X,oluteSize.X, 0,  0, 1)
                        SetValue(min1)
                        SetValue(min + rel + rel * ( * (max - min))
                    endmax - min))
                    end
                end)
                User
                end)
InputService.InputEnded:                UserInputService.InputEndConnect(functioned:Connect(function(inp(inp)
                    if inp)
                    if inp.UserInputType ==.UserInputType == Enum.User Enum.UserInputTypeInputType.MouseButton1.MouseButton1 then sliding then sliding = false = false end
                end end
                end)
               )
                UserInput UserInputService.InputService.InputChanged:Connect(function(inp)
                    if sliding and inp.UserInputChanged:Connect(function(inp)
                    if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        local rel = mathType == Enum.UserInputType.MouseMovement then
                        local rel = math.clamp((in.clamp((inp.Position.X - trackp.Position.X.AbsolutePosition - track.AbsolutePosition.X) / track.Abs.X)oluteSize.X, / track.AbsoluteSize.X, 0 0, 1)
,                         SetValue(min + rel1)
                        SetValue * ((min + rel * (max -max - min))
                    end min))
                    end
               
                end)

                table end)

                table.insert(self._clean.insert(self._cleanup, Library:RegisterListenerup, Library:RegisterListener(function(t)
                   (function(t)
                    if track and track.Parent then
 if track and track.Parent then
                        track.Background                        track.BackgroundColor3Color3  = t.  = t.Outline
Outline
                        fill.Background                        fillColor3   = t.Acc.BackgroundColor3   =ent
 t.Accent
                        name                        nameLbl.TextColorLbl.TextColor3     3      = t = t.Text;    nameLbl.Text;    nameLbl.Font = Library.Font.Font = Library.Font
                        valLbl.TextColor3       =
                        valLbl.TextColor3       = t.Sub t.SubText;Text; valLbl.Font  = valLbl.Font  = Library.Font
                    end
 Library.Font
                    end
                end))

                               end function Ref))

                function Ref:Set:Set(v) SetValue(v)(v) SetValue(v) end
                function end
                function Ref: Ref:Get() return valueGet() return value end
 end
                function                function Ref:Dependency(t Ref:DoggleRefependency(toggleRef, require, requireVal)
                    localVal)
                    local conn
 conn
                    local                    local function Up function Upd()
                        ifd()
                        if not row not row then conn then conn:Disconnect():Disconnect() return end return end
                       
                        row.Visible = row.Visible = (toggleRef:Get() == requireVal)
                    end (toggle
                    conn = RunServiceRef:Get() == requireVal)
                    end
                    conn =.Heartbeat:Connect( RunService.Heartbeat:Connect(UpdUpd); Upd()
               ); Upd()
                end
 end
                return Ref
            end                return Ref
            end

            --

            -- ═ ═══════════════════════════════════════════════════════════════════════════════════════════
           
            --  DROPDOWN --  DROPDOWN (fixed: popup positioning (fixed: popup positioning, theme, theme update)
 update)
            --            -- ═════ ══════════════════════════════════════════════════════════════════════════════════════
            function GB:═
            function GB:CreateDropdown(optsCreateDropdown(opts)
                local n)
                local n       = opts.Name       = opts.Name    or "Dropdown    or "Dropdown"
                local options"
                local options = opts.Options = opts.Options or {}
                local or {}
                local default = default = opts.Default opts.Default or options or options[1]
               [1]
                local flag    = local flag    = opts.F opts.Flag
lag
                local cb                     local = opts.Callback cb      = opts.Callback or function or function() end() end
                local tool
                local tooltip =tip = opts.Tooltip opts.Tooltip
               
                local theme local theme   = T()

   = T()

                local                local selected = selected = default
                if default
 flag then                if flag then Library.F Library.Flags[flaglags[flag] =] = selected end selected end

                local row

                = New local row = New("Frame("Frame", {
", {
                    Size                =                    Size                = UDim UDim2.new2.new(1, 0,(1, 0, 0,  0, 52),
                    Background52),
                    BackgroundTransparency = Transparency = 1,
1,
                    Cl                    ClipsDescendants    = false,
                   ipsDescendants    = false ZIndex,
                    ZIndex              =              = 4 4,
                   ,
                    Parent              Parent              = self = self._list,
               ._list })
               ,
                if tool })
                if tooltip then Attachtip thenTooltip AttachTooltip(row,(row, tooltip tooltip) end

                New("TextLabel) end

                New("TextLabel", {
", {
                    Size                =                    Size                = UDim2.new(1,  UDim2.new(10, 0, 0, 0, 16),
, 16),
                    BackgroundTransparency                    BackgroundTransparency =  = 1,
                    Text1,
                                   = n,
 Text                = n,
                    TextColor3                    TextColor3          = theme.Text,
                             = theme.Text,
                    Font                = Library.Font,
 Font                = Library.Font,
                    TextSize            =                     TextSize           12,
                    TextXAlignment = 12,
                    TextXAlignment      = Enum.Text      = Enum.TextXAlignmentXAlignment.Left.Left,
                    ZIndex,
                    ZIndex              = 5,
                                 = 5,
                    Parent              = row Parent              = row,
,
                })

                local drop                })

                local dropBtn = New("TextButton", {
Btn = New("TextButton", {
                    Size             = UDim                    Size             = UDim2.new(12.new(1, 0, 0, 0, 0, 26),
                    Position,          = UDim26),
                    Position         = UDim2.new(0, 2.new(0, 0,0, 0,  0, 20),
20),
                    BackgroundColor3 = theme.Second                    BackgroundColor3 = theme.Secondary,
                    BorderSizePixelary,
                    BorderSizePixel  = 0,
                     = 0 Text             = "",
,
                    Text             = "",
                    ZIndex           =                     ZIndex           = 5,
5,
                    Parent                    Parent           = row,
           = row,
                })
                })
                Corner(drop                CornerBtn, 6)
               (dropBtn, 6 Stroke(dropBtn, theme)
                Stroke(dropBtn, theme.Outline)

                local sel.Outline)

                local selLbl = NewLbl = New("TextLabel", {
                   ("TextLabel", {
                    Size                = UDim2 Size                = UDim2.new(1,.new(1, -26, 1, -26,  0),
                    Position           1, 0 = U),
                    Position            = UDim2.new(Dim2.new(0,0, 8,  8, 0, 0),
                    BackgroundTrans0, 0),
                    BackgroundTransparency = 1,
                   parency = 1,
                    Text                Text                = selected or " = selected or "Select...Select...",
                   ",
                    TextColor3          = theme TextColor3          = theme.Text,
.Text,
                    Font                = Library.Font,
                    TextSize            =                    Font                = Library.Font,
                    TextSize 12            = 12,
                   ,
                    TextXAlignment      TextX = EnumAlignment      = Enum.TextX.TextXAlignment.Alignment.Left,
                    TextLeft,
                    TextTrTruncate       uncate        = Enum = Enum.TextTruncate.TextTruncate.AtEnd.AtEnd,
                    ZIndex,
                    ZIndex              =              = 6,
                    Parent              = drop 6,
                    Parent              = dropBtn,
Btn,
                })
                New                })
("Text                New("TextLabel",Label", {
                    Size                = U {
                    Size               Dim2.new(0, = UDim2.new(0, 18,  18, 1, 0),
                   1, 0 Position            = U),
                    Position            = UDim2Dim2.new(1, -22.new(, 0,1, -22 0),
                   , 0, 0),
                    BackgroundTransparency = 1 BackgroundTransparency =,
                    Text                = " 1,
                   ▾",
                    Text                = "▾ TextColor",
                    TextColor3          = theme.SubText3          = theme.SubText,
                    Font               ,
                    Font                = Enum = Enum.Font.GothamBold.Font.GothamBold,
                    TextSize,
                    TextSize            =            = 14,
                    14,
                    ZIndex              = ZIndex              = 6 6,
                   ,
                    Parent              Parent              = dropBtn,
                })

 = dropBtn,
                --                })

                -- Popup list (parent Popup list (parented to PopupContainer)
ed to PopupContainer)
                local dropList                local dropList = New("Frame = New", {
                    Name             = "Drop("Frame", {
                    Name             = "DropList",
List",
                    Size             = UDim                    Size             = UDim2.new(02.new, drop(0, dropBtn.AbsoluteSize.XBtn.AbsoluteSize.X, , 0,0, 0),
                    BackgroundColor 0),
                    BackgroundColor3 =3 = theme.Secondary theme.Secondary,
                    BorderSize,
                    BorderSizePixel Pixel  = 0,
 = 0,
                    Visible          = false                    Visible          = false,
,
                    ClipsDesc                    ClipsDescendants = true,
endants = true,
                    Z                    ZIndex           = POPUP_Z_INDEXIndex           = POP + UP_Z_INDEX + 1,
1,
                    Parent                    Parent           =           = PopupContainer,
 PopupContainer,
                })
                Corner                })
                Corner(dropList, 6(dropList, 6)
               )
                Stroke(dropList, theme Stroke(dropList.Outline, theme)
                Padding(d.Outline)
                Padding(dropListropList, , 4, 4, 4, 44, 4, 4, 4)
                ListLayout)
                ListLayout(dropList,(dropList, 2 2)

               )

                local Ref = {}
                local isOpen local Ref = {}
                local isOpen = false
                local updateConn = = false
                local updateConn = nil

                local function Set nil

                local function SetSelected(Selected(opt, silent)
                    selected = optopt, silent)
                    selected = opt
                    selLbl.Text = opt or "
                    selLbl.Text = opt or "Select..."
                    ifSelect..."
                    if flag then flag then Library.F Library.Flags[flaglags[flag] =] = opt end opt end
                    if not
                    if not silent then silent then safePCall(c safePCall(cb, opt)b, opt) end
 end
                end                end

               

                local function RebuildList local function RebuildList(just(Colors)
                   justColors)
                    -- Update -- Update existing items' existing colors without destroying items' colors without destroying
                   
                    if justColors then if justColors then
                        local theme
                        local themeNowNow = T = T()
                       ()
                        for _, c in for _, c in ipairs ipairs(dropList:GetChildren()) do
                            if c(dropList:GetChildren()) do:IsA("
                            if c:IsA("TextButtonTextButton") then
                               ") then
                                local local isSel isSel = (c.Text = (c.Text == selected == selected)
                                c.BackgroundColor)
                                c.BackgroundColor3 =3 = themeNow.Tertiary
                                c themeNow.Tertiary
                                c.BackgroundTransparency = is.BackgroundTransparency = isSel andSel and 0 0 or 1
 or 1
                                c                                c.TextColor.TextColor3 = isSel3 = isSel and theme and themeNow.TextNow.Text or theme or themeNow.SubText
Now.SubText
                            end                            end
                       
                        end
                        return
                    end
                        return
                    end
 end
                    -- Full rebuild
                                       -- Full rebuild
                    for _, for _, c in c in ipairs(drop ipairsList:GetChildren(dropList:GetChildren()) do()) do
                       
                        if c:Is if c:IsA("A("TextButtonTextButton") then") then c: c:Destroy()Destroy() end
                    end end
                    end
                   
                    for _, for _, opt in ip opt in ipairs(options)airs(options) do
                        local isSelected do
                        local = opt isSelected == selected = opt == selected
                       
                        local item local item = New("Text = New("TextButton",Button", {
                            Size                {
                            = U Size                = UDim2Dim2.new(.new(1, 01, 0, , 0,0, 26 26),
                           ),
                            BackgroundColor BackgroundColor3   3    = T().Tertiary = T().Tertiary,
                            BackgroundTrans,
                           parency = BackgroundTransparency = isSelected isSelected and 0 or and  10 or 1,
                           ,
                            BorderSize BorderSizePixel    Pixel     =  = 0,
0,
                            Text                = opt,
                            Text                = opt,
                            Text                            TextColor3Color3          = isSelected          = isSelected and T and T().Text().Text or T().SubText,
 or T().SubText,
                            Font                = Library.Font                            Font                = Library.Font,
                           ,
                            TextSize TextSize            = 12            = 12,
                           ,
                            ZIndex ZIndex              = POPUP              = POPUP_Z__Z_INDEX + 2INDEX + 2,
                           ,
                            Parent              Parent              = dropList,
 = dropList,
                        })
                        })
                        Corner                        Corner(item, 4(item, 4)
                       )
                        item.M item.MouseEnter:Connect(function() TweenouseEnter:Connect(function() Tween(item,(item, { BackgroundTransparency =  { BackgroundTransparency = 0,0, Background BackgroundColor3 =Color3 = T().Tert T().Tertiary,iary, TextColor3 = TextColor3 = T(). T().TextText }, }, 0.08) end 0.08) end)
                       )
                        item.M item.MouseLeaveouseLeave:Connect:Connect(function()(function() Tween(item, { Background Tween(item, { BackgroundTransparencyTransparency = (opt == = ( selected)opt == and  selected) and 0 or0 or 1 1 }, 0. }, 0.08)08) end)
                        item end)
.Mouse                        item.MouseButton1Button1Click:Connect(functionClick:Connect(function()
                           ()
                            SetSelected(opt SetSelected(opt)
                           )
                            isOpen isOpen = false = false
                            if updateConn then updateConn
                            if updateConn then updateConn:Dis:Disconnect(); updateConnconnect(); updateConn = nil end
 = nil end
                            Tween(d                            Tween(dropListropList, { Size =, { Size = UDim UDim2.new2.new(0(0, drop, dropBtn.ABtn.AbsoluteSize.XbsoluteSize.X, 0,, 0,  00) }, 0) }, 0.14)
                           .14)
                            task.d task.delay(0.14,elay(0.14, function() function() dropList dropList.Visible.Visible = false end)
                            Re = false end)
                            RebuildListbuildList(true)(true) -- update -- update colors
 colors
                        end                        end)
                   )
                    end
 end
                end                end
               
                Rebuild RebuildList()

                local function updateList()

                local function updatePopupPosition()
                    if not dropBtn or not dropBtnPopupPosition()
                    if not dropBtn or not dropBtn.Visible then return end
.Visible then return end
                    local                    local absPos absPos = dropBtn = dropBtn.Absolute.AbsolutePosition
Position
                    local                    local absSize = dropBtn.AbsoluteSize
                    absSize = dropBtn.AbsoluteSize
                    -- Ensure popup stays -- Ensure popup stays on screen on screen
                   
                    local view local viewSize = workspaceSize = workspace.CurrentCamera.CurrentCamera.ViewportSize
.ViewportSize
                    local popupX = absPos                    local popupX =.X
 absPos.X
                    local                    local popup popupY = absPosY = absPos.Y +.Y + absSize absSize.Y +.Y + 4 4
                    if pop
                    if popupX + absupX + absSize.X > viewSize.X > viewSize.XSize.X then
 then
                        pop                        popupXupX = viewSize.X = viewSize.X - absSize.X
                    - absSize.X end

                    end
                    if                    if popupY + popup dropListY + dropList.AbsoluteSize.Abs.Y >oluteSize.Y > viewSize viewSize.Y then.Y then
                        popup
                        popupY =Y = absPos.Y - dropList.Abs absPos.Y - dropList.AbsoluteSizeoluteSize.Y - 4.Y - 4
                   
                    end
 end
                    dropList.Position =                    dropList.Position = UDim2.fromOffset(p UDim2.fromOffset(popupopupX,X, popupY)
 popupY)
                    drop                    dropList.SizeList.Size = UDim2 = UDim2.new(.new(0,0, absSize.X, absSize.X, 0 0, drop, dropList.AbsoluteSize.YList.AbsoluteSize.Y)
               )
                end

                dropBtn.M end

                dropBtn.MouseButtonouseButton1Click:Connect1Click:Connect(function()
(function()
                    is                    isOpen =Open = not isOpen
 not isOpen
                    if                    if isOpen isOpen then
                        update then
                        updatePopupPositionPopupPosition()
                       ()
                        updateConn updateConn = Run = RunService.RService.RenderStepped:enderStepped:Connect(functionConnect(function()
                           ()
                            if dropBtn and if dropBtn and dropBtn dropBtn.Parent.Parent then updatePopupPosition() end
                        end)
                        dropList. then updatePopupPosition() end
                        end)
                        dropVisible =List.Visible = true
 true
                        local                        local h = #options h = #options * 28 + 8 * 28 + 8
                       
                        Tween Tween(dropList, { Size(dropList, { Size = U = UDim2Dim2.new(0,.new(0, dropBtn dropBtn.Abs.AbsoluteSize.X, 0oluteSize.X, 0, h) },, h) }, 0 0.15.15)
                    else
)
                                           if else
                        if updateConn updateConn then update then updateConn:Conn:DisconnectDisconnect(); update(); updateConn = nil endConn = nil end
                       
                        Tween Tween(drop(dropList,List, { Size { Size = UDim2 = UDim2.new(.new(0, dropBtn.AbsoluteSize.X,0, dropBtn.AbsoluteSize 0, 0).X, 0, 0) }, 0. }, 0.15)
15)
                        task.delay                        task.delay(0(0.15.15, function, function() dropList.Visible =() dropList.Visible = false end false end)
                   )
                    end
 end
                end                end)

               )

                table.insert(self._ table.insert(self._cleanup, Library:Registercleanup, Library:RegisterListener(function(t)
                    ifListener(function(t)
 dropBtn                    if dropBtn and drop and dropBtn.PBtn.Parent then
                       arent then
                        dropBtn.Background dropBtnColor3.Background = tColor3 = t.Secondary
.Secondary
                        selLbl                        selLbl.TextColor3       .TextColor = t3        = t.Text
.Text
                        drop                        dropList.BackList.BackgroundColorgroundColor3 =3 = t.Secondary
                        Rebuild t.Secondary
                        RebuildList(true) --List(true) -- update colors only
 update colors only
                    end
                                   end
                end))

 end))

                function                function Ref: Ref:Set(opt)
                    ifSet(opt)
                    if tableFind tableFind(options, opt(options, opt)) then
 then
                        Set                        SetSelected(opt)
Selected(opt)
                        Re                        RebuildList(true)
                    end
                end
                function Ref:Get() return selected end
                function Ref:buildList(true)
                    end
                end
                function Ref:Get() return selected end
                function Ref:SetOptions(newOpts)SetOptions(newOpt options =s) newOpt options = newOpts; RebuildList()s; RebuildList() end
 end
                function                function Ref:Dependency(t Ref:Dependency(toggleRef, requireoggleRef, requireVal)
Val)
                    local conn
                    local conn
                    local function Up                    local function Upd()
                        if not row then conn:Disd()
                        if not row then conn:Disconnect() return end
                       connect() return end
                        row. row.Visible = (toggleRef:Visible = (toggleRef:Get()Get() == require == requireVal)
                    end
                    conn = RunServiceVal)
                    end
                    conn = RunService.Heart.Heartbeat:Connect(Updbeat:Connect(Upd); Up); Upd()
d()
                end
                return Ref
            end

            -- ═════                end
                return Ref
            end

            -- ══════════════════════════════════════════════════════════════════════
            --═════════════════
            --  MULTI-DROPD  MULTI-DROPDOWN (fixed similarly)
           OWN (fixed similarly)
            -- ═════════ -- ═══════════════════════════════════════════════════════════════════════════════════
            function GB
            function GB:Create:CreateMultiDropdownMultiDropdown(opts)
               (opts)
                local n       = local n       = opts.Name    or opts.Name    or "MultiSelect"
 "MultiSelect"
                local options =                local options = opts.O opts.Options or {}
                local defaultptions or {}
                local default = opts.Default or = opts.Default or {}
                local flag    = opts.Flag
                local cb      = opts.Callback or function() end
                local tooltip = opts.Tooltip
                local theme   = T()

                local selected = {}
                for _, v in {}
                local flag    = opts.Flag
                local cb      = opts.Callback or function() end
                local tooltip = opts.Tooltip
                local theme   = T()

                local selected = {}
                for _, v in ipairs ipairs(default) do selected(default) do selected[v] = true[v] = true end
 end
                if flag then                if flag then Library.F Library.Flags[flag] = selected endlags[flag] = selected end

               

                local row = local row = New("Frame New("Frame", {
                    Size", {
                    Size                =                = UDim UDim2.new(1, 0, 0, 52),
                    Background2.new(1, 0, 0, 52),
                    BackgroundTransparency = 1,
Transparency = 1,
                    ClipsDescendants                       ClipsDescendants    = false = false,
                   ,
                    ZIndex ZIndex              = 4              = 4,
                   ,
                    Parent              Parent              = self._list = self._list,
               ,
                })
                })
                if tool if tooltip thentip then Attach AttachTooltipTooltip(row, tooltip(row, tooltip) end

               ) end

                New("TextLabel", {
                    Size New("TextLabel", {
                    Size                = UDim2.new                = UDim2.new(1(1, 0, 0, 16),
                    Background, 0, 0, 16),
                    BackgroundTransparency = Transparency = 1,
                    Text                =1,
                    Text                = n,
                    TextColor3          = n,
                    TextColor3          = theme.Text,
                    Font                theme.Text,
                    Font                = Library = Library.Font,
                    TextSize            = .Font,
                    TextSize            = 12,
                    Text12,
                    TextXAlignment      =XAlignment      = Enum.TextXAlignment.Left,
                    ZIndex              = 5,
                    Enum.TextXAlignment.Left,
                    ZIndex              = 5,
                    Parent              Parent              = row,
                = row,
                })

                })

                local dropBtn local drop = New("Btn = New("TextButton", {
TextButton", {
                    Size             =                    Size             = UDim2.new(1,  UDim2.new(1, 0, 00, 0, 26),
, 26),
                    Position                    Position         =         = UDim2.new UDim2.new(0(0, 0,, 0, 0,  0, 20),
                    Background20),
                    BackgroundColor3 = themeColor3 = theme.Second.Secondary,
                    BorderSizePixelary,
                    BorderSizePixel  = 0  = 0,
                    Text             = "",
,
                    Text             = "",
                    Z                    ZIndex           = Index           = 5,
5,
                    Parent           = row,
                    Parent                })
           = row,
                })
                Corner                Corner(dropBtn(dropBtn, 6, 6)
               )
                Stroke(dropBtn Stroke(dropBtn, theme.Outline, theme.Outline)

               )

                local function SelText local function()
                    local list = {}
 SelText()
                    local list = {}
                    for k, v in pairs(                    for k, v in pairs(selected) do ifselected) do if v then v then table.insert(list, table.insert(list, k) k) end end
                    table.sort(list)
                    return #list > 0 and end end
                    table.sort(list)
                    return #list > 0 and table.concat table.concat(list,(list, ", ") or " ", ") or "None"
None"
                end                end

                local sel

               Lbl = New("TextLabel", {
                    Size                = U local selLbl = New("TextLabel", {
                    Size               Dim2 = UDim2.new(1, -26, 1, 0),
                    Position           .new(1, -26, 1, 0),
                    Position            = U = UDim2.new(0,Dim2.new(0, 8, 0, 0 8, 0, 0),
                    BackgroundTransparency =),
                    BackgroundTransparency = 1,
                    Text                = Sel 1,
                    Text                = SelText(),
                    TextColor3Text(),
                    TextColor3          = theme.Text,
                             = theme.Text,
                    Font                = Library.Font,
                    TextSize            Font                = Library.Font,
                    TextSize            = 11,
 = 11,
                    Text                    TextXAlignment      =XAlignment      = Enum.Text Enum.TextXAlignment.Left,
                   XAlignment.Left TextTruncate        = Enum.Text,
                    TextTruncate        = Enum.TextTruncTruncate.AtEnd,
ate.AtEnd,
                    ZIndex              = 6,
                    Parent                    ZIndex              = 6,
                    Parent              = dropBtn,
                })
                New("TextLabel", {
                    Size   = UDim2.new(0              = dropBtn,
                })
                New("TextLabel", {
                    Size   = UDim2.new(0, 18, 1, 18, 1, , 0),
                    Position0),
                    Position = UDim2.new(1, -22 = UDim2.new(1, -22, , 0, 0),
                    BackgroundTrans0, 0),
                    BackgroundTransparency =parency = 1,
                    1,
                    Text = Text = " "▾", TextColor▾", TextColor3 = theme.Sub3 = theme.SubText,
Text,
                    Font                    Font = Enum.Font.G = Enum.Font.GothamBoldothamBold, TextSize = 14,
                    ZIndex = 6, Parent = dropBtn, TextSize = 14,
                    ZIndex = 6, Parent = dropBtn,
               ,
                })

                })

                -- Popup list -- Popup list
               
                local drop local dropList =List = New(" New("Frame", {
                   Frame", {
                    Size             = U Size             = UDim2Dim2.new(.new(0, dropBtn0, dropBtn.Abs.AbsoluteSize.X, 0oluteSize.X, 0, , 0),
0),
                    BackgroundColor3                    BackgroundColor3 = theme = theme.Secondary,
                    Border.Secondary,
SizePixel                    BorderSizePixel  =  = 0 0,
                   ,
                    Visible          = false,
                    Clips Visible          = false,
                    ClipsDescendants = trueDescendants = true,
                   ,
                    ZIndex           = ZIndex           = POPUP POPUP_Z__Z_INDEX + 1,
                    Parent           = PopINDEX + 1,
                    Parent          upContainer,
                = PopupContainer })
               ,
                })
                Corner(dropList Corner(dropList, , 6)
                Stroke6)
                Stroke(drop(dropList,List, theme.Outline)
                Padding(dropList, 4,  theme.Outline)
                Padding(dropList, 4, 4, 4, 4, 44)
, 4)
                ListLayout(drop                ListList, Layout(dropList, 2)

2)

                local Ref =                local Ref = {}
                local is {}
               Open = local isOpen = false
 false
                local                local updateConn updateConn = nil = nil

                local function

                Rebuild local function RebuildMultiList(justMultiList(justColors)
                    ifColors)
                    if justColors justColors then
 then
                        local                        local themeNow = T themeNow()
                        for _, c in ipairs(drop = T()
                        for _, c in ipairs(dropList:List:GetChildrenGetChildren()) do
                           ()) do
                            if if c c:Is:IsA("A("Frame") then
Frame") then
                                local                                local opt opt = = c:FindFirstChild c:FindFirstChildOfClass("TextLabel").Text
                               OfClass("TextLabel").Text
                                local isSel = local isSel = selected selected[opt] == true
                                c.BackgroundColor3 = themeNow[opt] == true
                                c.BackgroundColor3 = themeNow.Tertiary
.Tertiary
                                c                                c.BackgroundTransparency.BackgroundTransparency = is = isSel andSel and 0 0 or  or 1
                                local1
                                local chk = c:Find chk = c:FindFirstChildOfClass("TextLabel") -- the checkmark
                                ifFirstChildOfClass("TextLabel") -- the checkmark
 chk and chk ~= c:Find                                if chk and chk ~= c:FindFirstChildFirstChildOfClass("TextLabel") then
OfClass("TextLabel") then
                                    chk.Text                                    chk.Text = is = isSel and "✓Sel and "✓" or" or ""
                                end
                            end ""
                                end
                            end
                       
                        end
                        return end
                        return
                    end
                    for _, c
                    end
                    for in ipairs(dropList _, c in ipairs(dropList:GetChildren()) do
                        if c::GetChildren()) do
                        if c:IsA("Frame") thenIsA("Frame") then c:Destroy() end
                    end c:Destroy() end

                    for _,                    end
                    for _, opt in ipairs(options) do
                        local isSel opt in ipairs(options) do
                        local isSel = selected[opt] == true
 = selected[opt] ==                        local true
                        local item = item = New("Frame", {
                            New("Frame", {
                            Size                = UDim2.new( Size                = UDim2.new(1, 01,, 0, 0, 0, 26),
 26                            BackgroundColor),
                            BackgroundColor3   3    = T().Tertiary = T().T,
                           ertiary,
                            BackgroundTrans BackgroundTransparency =parency = isSel isSel and 0 or and 0 or 1,
                            1 BorderSize,
                            BorderSizePixel    Pixel     =  = 0,
0,
                            ZIndex                                         ZIndex              = POP = POPUP_ZUP_Z_INDEX + _INDEX + 2,
                            Parent2,
                            Parent              =              = dropList dropList,
                       ,
                        })
                        Corner(item })
                       ,  Corner(item4)
, 4)
                        New                        New("Text("TextLabel", {
                           Label", {
                            Size = Size = UDim UDim2.new2.new(1, -(1, -28,28, 1 1, , 0),0), Position = UDim Position = UDim2.new(02.new(0, , 8, 0, 8, 0, 0),
                            Background0),
Transparency                            BackgroundTransparency =  = 1,1, Text = opt,
                            Text Text =Color3 opt,
                            TextColor3 = T = T().Text, Font = Library().Text, Font = Library.Font,.Font, TextSize = 12,
 TextSize = 12,
                            ZIndex =                            ZIndex = POPUP POPUP_Z__Z_INDEX + 3INDEX + 3, Parent, Parent = item = item,
                       ,
                        })
                        local chk = New(" })
                        local chk = New("TextLabelTextLabel", {
", {
                            Size = U                            SizeDim2.new = UDim2.new((0,0, 18 18, 1,, 1, 0 0), Position), Position = U = UDim2Dim2.new(1,.new(1, -22,  -22, 0,0, 0),
                            0),
                            BackgroundTransparency = BackgroundTransparency = 1 1, Text = is, Text = isSel andSel and "✓" or "",
                            "✓" or "",
                            TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.GothamBold,
                            TextSize = 12, ZIndex = POPUP_Z_INDEX +  TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.GothamBold,
                            TextSize = 12, ZIndex = POPUP_Z_INDEX + 3, Parent = item,
                        })
                        New3, Parent = item,
                        })
                        New("TextButton", {
                            Size("TextButton", {
                            Size = UDim = UDim2.new2.new(1,0(1,0,1,1,0), Background,0), BackgroundTransparency = 1,
Transparency = 1,
                            Text = "",                            Text = "", ZIndex = POPUP_Z ZIndex = POPUP_Z_INDEX + 4,_INDEX + 4, Parent = item,
                        }).MouseButton1Click:Connect Parent = item,
                        }).MouseButton1Click:Connect(function()
                            selected[opt(function()
                            selected[opt] = not selected[opt]
                           ] = not selected[opt]
                            selLbl.Text selLbl.Text = SelText()
                            if flag then = SelText()
                            if Library.F flag then Library.Flagslags[flag] =[flag] = selected end
                            selected end
                            safePCall(c safePCall(cb,b, selected)
                            item.BackgroundTransparency = selected[opt] and 0 or 1
                            item selected)
                            item.BackgroundTransparency = selected[opt] and 0 or 1
                            item.BackgroundColor3.BackgroundColor3 = T().Tertiary
                            chk.Text = = T().Tertiary
                            chk.Text = selected[opt] and " selected[opt] and "✓" or ""
                        end✓" or ""
                        end)
                   )
                    end
 end
                end
                RebuildMultiList                end
                RebuildMultiList()

                local function updatePopup()

                local function updatePopupPosition()
                    if not dropBtn or not dropBtn.Visible then return end
                    local absPos =Position()
                    if not dropBtn or not dropBtn.Visible then return end
                    local absPos = dropBtn.AbsolutePosition
                    dropBtn.AbsolutePosition
                    local absSize = local absSize = dropBtn dropBtn.Abs.AbsoluteSize
                   oluteSize
                    local view local viewSize = workspace.CurrentCamera.ViewSize = workspace.CurrentCamera.ViewportSizeportSize
                    local pop
                    local popupX = absPos.X
                    local popupY = absupX = absPos.X
                    local popupY = absPos.Y + absSize.Y + 4
Pos.Y + absSize.Y + 4
                    if popup                    if popupX + absSizeX + absSize.X > viewSize.X > viewSize.X then
                       .X then
                        popupX = viewSize.X - popupX = viewSize.X - absSize.X
 absSize.X
                    end
                                       end
                    if popupY if popupY + drop + dropList.AbsoluteList.AbsoluteSize.Y > viewSize.Y then
                        popSize.Y > viewSize.Y then
                        popupY = absupY = absPos.Y - dropPos.Y - dropList.AList.AbsoluteSize.Y - 4
                    endbsoluteSize.Y - 4
                    end
                   
                    dropList.Position dropList.Position = U = UDim2Dim2.fromOffset.fromOffset(popupX(popupX, pop, popupY)
                   upY)
                    dropList.Size = dropList.Size = UDim2.new(0, absSize.X, 0, dropList.AbsoluteSize.Y)
                end

                dropBtn UDim2.new(0, absSize.X, 0, dropList.AbsoluteSize.Y)
                end

               .MouseButton1Click:Connect(function()
                    dropBtn.MouseButton1Click:Connect(function()
                    isOpen isOpen = not = not isOpen
                    isOpen
                    if is if isOpen then
                        updatePopupPosition()
                        updateOpen then
                        updatePopupPosition()
                        updateConn = RunServiceConn = RunService.Render.RenderStepped:ConnectStepped(function()
:Connect(function()
                            if                            if dropBtn and drop dropBtn and dropBtn.Parent then updatePopupBtn.Parent thenPosition() end
                        end)
                        dropList.Visible updatePopupPosition() end
                        end)
                        dropList.Visible = true = true
                       
                        local h local h = #options * = #options * 28 28 +  + 8
8
                        Tween(dropList, {                        Tween(dropList, { Size = Size = UDim UDim2.new(0, dropBtn.Absolute2.new(0, dropBtn.AbsoluteSize.X, Size.X, 0, h) }, 0, h) }, 0.0.15)
15)
                    else
                                           else
                        if update if updateConn thenConn then updateConn:Dis updateConn:Disconnect();connect(); updateConn = nil updateConn = nil end
 end
                        T                        Tween(dween(dropList, {ropList, { Size = Size = UDim2.new(0, dropBtn.Absolute UDim2.new(0, dropBtn.AbsoluteSize.X, 0,Size.X, 0, 0 0) }, 0.15)
                        task.d) }, 0.15)
                        task.delay(elay(0.15, function()0.15, function() dropList.Visible dropList.Visible = false = false end)
                    end
                end)

 end)
                    end
                end)

                table.insert(self._clean                table.insert(self._cleanup,up, Library:RegisterListener Library:RegisterListener(function(t(function(t)
                   )
                    if dropBtn and if dropBtn and dropBtn.Parent then
                        dropBtn.BackgroundColor3 = t.Secondary
                        dropBtn.Parent then
                        dropBtn.BackgroundColor3 = t.Secondary
                        selLbl.Text selLbl.TextColor3       Color3        = t = t.Text
.Text
                        dropList.Back                        dropList.BackgroundColorgroundColor3 =3 = t.Secondary t.Secondary
                       
                        RebuildMultiList RebuildMultiList(true)
                    end
               (true)
                    end
                end))

 end))

                function Ref:Set(t                function Ref:Set(tbl)
                    selected = {}
                    for _, v in ipbl)
                    selected = {}
                    for _, v in ipairs(tbl)airs(tbl) do selected do selected[v] = true[v] = true end
 end
                    sel                    selLbl.Text =Lbl.Text = SelText SelText()
                   ()
                    if flag if flag then Library then Library.Fl.Flagsags[flag] = selected[flag] = selected end
                    Re end
                    RebuildMultiList()
                end
                function Ref:Get()
                    local out = {}
                    forbuildMultiList()
                end
                function Ref:Get()
                    local out = {}
                    for k, v in k, v in pairs(selected) pairs(selected) do if do if v then v then table.insert(out, table.insert(out, k) k) end end end end
                    return out
                    return out
               
                end
 end
                function Ref:D                function Ref:Dependency(tependency(toggleRef, requireoggleRef, requireVal)
                    local conn
Val)
                    local conn
                    local function Upd()
                        if                    local function Upd()
                        if not row not row then conn then conn:Disconnect():Disconnect() return end
                        return end
                        row. row.Visible =Visible = (toggleRef: (toggleRef:Get()Get() == requireVal)
 == requireVal)
                    end
                    conn = RunService                    end
                    conn = RunService.Heart.Heartbeat:beat:Connect(Upd); Upd()
                end
               Connect(Upd); Upd()
                end
                return Ref
            return Ref
            end end

            --

            -- ═════ ══════════════════════════════════════════════════════════════════════
═════════════════
            --  TEXT            --  TEXT INPUT
            -- INPUT
            -- ═════ ══════════════════════════════════════════════════════════════════════
            function═════════════════
            function GB:CreateTextInput(opts)
 GB:CreateTextInput(opts)
                local                local n           = opts n           = opts.Name       .Name        or "Input"
                local or "Input"
                local placeholder = placeholder = opts.P opts.Placeholder or "laceholder or "Type hereType here..."
               ..."
                local default local default     =     = opts.Default opts.Default     or ""
                local flag        = opts.Flag
     or ""
                local flag        = opts.Flag
                local cb          = opts.Callback                local cb          = opts.Callback    or    or function() end
 function() end
                local tooltip     =                local tooltip     = opts.T opts.Tooltipooltip
                local theme
                local theme       =       = T()

 T()

                local value =                local value = default
 default
                if                if flag then Library.F flag then Library.Flags[flag] =lags[flag] = value end value end

               

                local row local row = New("Frame", {
                    Size                = = New("Frame", {
                    Size                = UDim2.new UDim2.new(1(1, , 0,0, 0 0, , 52),
52),
                    Background                    BackgroundTransparencyTransparency =  = 1,
1,
                    Z                    ZIndexIndex                           = 4,
                    Parent              = = 4,
                    Parent              = self._list,
                })

                New self._list,
                })

                New("TextLabel", {
                    Size =("TextLabel", {
                    UDim2.new(1 Size = UDim2.new(1,0,0,0,0,16,16), BackgroundTransparency), BackgroundTransparency =  = 1,
1,
                    Text                    Text = n, Text = nColor3, TextColor3 = theme.Text, = theme.Text, Font = Library.Font Font = Library.Font,
                    TextSize,
                    TextSize = 12, = 12, TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5, TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5, Parent = Parent = row,
 row,
                })

                local                })

                local inputBg inputBg = New = New("Frame", {
("Frame", {
                    Size                    Size = U = UDim2Dim2.new(1,.new(1, 0, 0, 0, 0, 28),
                    Position = UDim2.new 28),
                    Position = UDim2.new(0, 0, 0(0, 0, 0, 20),
, 20),
                    Background                    BackgroundColor3Color3 = theme.Second = theme.Secondary,
                    Borderary,
                    BorderSizePixelSizePixel = 0, ZIndex = 0, ZIndex =  = 5,5, Parent = row,
 Parent = row,
                })
                Corner(inputBg, 6)
                Stroke(inputBg, theme                })
                Corner(inputBg, 6)
                Stroke(inputBg.Outline)
                if tooltip then AttachTooltip(inputBg, tooltip), theme.Outline)
                if tooltip then AttachTooltip(inputBg, tooltip) end

                local tb = New("TextBox", end

                local tb = New("TextBox", {
                    Size = UDim2.new(1, -16, {
                    Size = UDim2.new(1, -16, 1,  1, 0),
                    Position = UDim2.new(0, 80),
                    Position = UDim2.new(0, 8, , 0, 0),
                   0, 0),
                    BackgroundTransparency = 1,
                    BackgroundTransparency = 1,
                    Text = value, PlaceholderText = placeholder,
 Text = value, PlaceholderText =                    TextColor3 = theme.Text, placeholder,
                    TextColor3 = theme.Text, PlaceholderColor3 = theme.SubText,
                    Font = PlaceholderColor3 = theme.SubText Library.Font, Text,
                    Font = Library.Font, TextSize = 12,
                    TextXAlignment =Size = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false, Z ClearTextOnFocus = false, ZIndex = 6, Parent = inputIndex = 6, Parent = inputBg,
Bg,
                })

                tb.Focused:Connect(function()                })

                tb.Focused:Connect   Tween(inputBg, { Background(function()   Tween(inputBg,Color3 { BackgroundColor3 = T().Tertiary }, 0. = T().Tertiary }, 0.1) end)
                tb.Focus1) end)
                tb.FocusLost:Connect(function()
                    TweenLost:Connect(function()
                    Tween(inputBg, { BackgroundColor3 = T().(inputBg, { BackgroundColor3 = T().Secondary }, 0.1Secondary }, 0.1)
                    value = tb.Text
                   )
                    value = tb.Text
                    if flag then Library if flag then Library.Flags[flag] = value.Flags[flag] = value end
                    safePCall(cb, value end
                    safePCall(cb, value)
                end)

                table)
                end)

                table.insert(self._cleanup,.insert(self._cleanup, Library:RegisterListener(function(t)
                    if input Library:RegisterListener(function(t)
                    if inputBg and inputBgBg and inputBg.Parent then
                        inputBg.BackgroundColor3 =.Parent then
                        inputBg.BackgroundColor3 = t.Secondary
                        tb.TextColor3 t.Secondary
                        tb.TextColor3            = t.Text
                                   = t.Text
                        tb.PlaceholderColor3     = t.Sub tb.PlaceholderColor3     = t.SubText
                        tb.Font                 Text
                        tb.Font                  = Library.Font
                    end
                = Library.Font
                    end
                end))

                local Ref = {}
                end))

                local Ref = {}
                function Ref:Set(v) function Ref:Set(v) tb.Text = v tb.Text = v; value = v end
                function Ref:Get(); value = v end
                function Ref:Get() return value end
                function return value end
                function Ref:Dependency(toggleRef, requireVal)
 Ref:Dependency(toggleRef, requireVal)
                    local conn
                    local function Upd()
                        if not row then conn                    local conn
                    local function Upd()
                        if not row then conn:Disconnect() return end
                       :Disconnect() return end
                        row.Visible = (toggleRef: row.Visible = (toggleRef:Get() == requireVal)
                    endGet() == requireVal)
                    end
                    conn = RunService.Heart
                    conn = RunService.Heartbeat:Connect(Updbeat:Connect(Upd); Upd()
                end
               ); Upd()
                end
                return Ref
            end

            -- return Ref
            end

            -- ═════════════════════ ══════════════════════════════════════════════════════════════════════
            --  COLOR PICK═
            --  COLOR PICKER (fixed: off-screen adjustment)
            -- ═ER (fixed: off-screen adjustment)
            -- ══════════════════════════════════════════════════════════════════════════════════════
            function GB:CreateColorPicker(opts═════
            function GB:CreateColorPicker(opts)
                local n       = opts.Name)
                local n       = opts.Name     or "Color"
                    or "Color"
                local default = opts.Default  local default = opts.Default  or Color3.fromRGB(255, or Color3.fromRGB(255, 80, 80)
 80, 80)
                local                local flag    = opts.Flag
                local cb flag    = opts.Flag
                local cb      = opts.Callback or function()      = opts.Callback or function() end
                local tooltip = opts.Tooltip
                local theme   end
                local tooltip = opts.Tooltip
                local theme   = T()

                local color   = default
 = T()

                               local h, local color   = default
                local h, s, v = color:ToHSV()
                s, v = color:ToHSV()
                if flag then Library.Flags if flag then Library.Flags[flag] = color end

                local[flag] = color end

                local row, _ = Elem row, _ = ElemRow(n, 26, tooltipRow(n, 26, tooltip)
                row.ClipsDescendants)
                row.Clips = false
                row.ZDescendants = false
                row.ZIndex = 5

                local preview = NewIndex = 5

                local preview = New("TextButton", {
                    Size             = UDim2.new("TextButton", {
                    Size             = UDim2.new((0, 52, 0,0, 52, 0, 20),
                    Position         = UDim2.new( 20),
                    Position         = UDim2.new(1, -52, 1, -52, 0.5, -10),
                    BackgroundColor0.5, -10),
                   3 = color,
                    BorderSizePixel BackgroundColor3 = color,
                    BorderSizePixel  = 0,
                     = 0,
                    Text             = "",
                    ZIndex           Text             = "",
                    ZIndex           = 6,
                    Parent           = row,
 = 6,
                    Parent           = row,
                })
                Corner(preview, 4)
                })
                Corner(preview, 4)
                Stroke(preview, theme                Stroke(preview, theme.Outline.Outline)

                -- Picker Popup
                local popup = New("Frame", {
)

                -- Picker Popup
                local popup = New("Frame", {
                    Size                    Size             =             = UDim2.new(0 UDim2.new(0, 196, 0, 158),
                    BackgroundColor3, 196, 0, 158),
                    BackgroundColor3 = theme.Secondary,
                    Border = theme.Secondary,
                    BorderSizePixel  = 0,
                   SizePixel  = 0,
                    Visible          = false,
                    ZIndex Visible          = false,
                    ZIndex           = POPUP_Z_INDEX + 1           = POPUP_Z_INDEX + 1,
                    Parent           = PopupContainer,
                })
               ,
                    Parent           = PopupContainer,
                })
                Corner(popup, 8)
                Stroke(popup, Corner(popup, 8)
                Stroke(popup, theme.Outline)
                Padding(popup, theme.Outline)
                Padding(popup, 8, 8, 8, 8)

 8, 8, 8, 8)

                -- Hue bar
                local hueBar = New("Frame", {
                                   -- Hue bar
                local hueBar = New("Frame", {
                    Size = UDim2.new(1, 0, 0 Size = UDim2.new(1, 0, 0, 12),
                    Position = UDim2, 12),
                    Position = UDim2.new(.new(0, 0, 0, 0),
                   0, 0, 0, 0),
                    BorderSizePixel = 0, ZIndex = POPUP_Z_INDEX + 2, Parent BorderSizePixel = 0, ZIndex = POPUP_Z_INDEX + 2, Parent = popup,
                })
                Corner = popup,
                })
                Corner(hueBar, 4(hueBar, 4)
                local hg = New("UIG)
                local hg = New("UIGradient", { Parentradient", { Parent = hueBar })
                hg.Color = hueBar })
                hg.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0,    Color3.from = ColorSequence.new({
                    ColorSequenceKeypoint.new(0,    Color3.fromHSV(0,    1, 1)),
                    ColorSequenceKeyHSV(0,    1, 1)),
                    ColorSequenceKeypoint.new(1/6,  Color3point.new(1/6,  Color3.fromHSV(1/6,  1, 1)),
                   .fromHSV(1/6,  1, 1)),
                    ColorSequenceKeypoint.new(2/6,  Color3.fromHSV( ColorSequenceKeypoint.new(2/6,  Color3.fromHSV(2/6,  1, 1)),
2/6,  1, 1)),
                    ColorSequenceKeypoint.new(3/6,  Color3.fromHSV(3/6                    ColorSequenceKeypoint.new(3/6,  Color3.fromHSV(3/6,  1, 1)),
                    ColorSequence,  1, 1)),
                    ColorSequenceKeypoint.new(4/6,  ColorKeypoint.new(4/6,  Color3.fromHSV(4/6,  13.fromHSV(4/6,  1, 1)),
                    ColorSequenceKeypoint.new(5, 1)),
                    ColorSequenceKeypoint.new(5/6,  Color3.fromHSV(5/6,  1, 1)),
                   /6,  Color3.fromHSV(5/6,  1, 1 ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,    1, )),
                    ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,    1, 1)),
                })

                local hueCursor = New("Frame", {
1)),
                })

                local hueCursor = New("Frame", {
                    Size = UDim2                    Size = UDim2.new(0, 4, 1, 0),
                   .new(0, 4, 1, 0),
                    Position = UDim2.new(h, -2, 0, 0),
                    BackgroundColor Position = UDim2.new(h, -2, 0, 0),
                    BackgroundColor3 = Color33 = Color3.fromRGB(255,255,255.fromRGB(255,255,255),
                    BorderSizePixel = 0),
                    BorderSizePixel = 0, ZIndex = POPUP, ZIndex = POPUP_Z_INDEX + 3, Parent = hue_Z_INDEX + 3, Parent = hueBar,
                })
                Corner(hueBar,
                })
                Corner(hueCursor, 2)

                -- SVCursor, 2)

                -- SV square
                local svBox = New("Frame", {
 square
                local svBox                    Size = UDim2.new( = New("Frame", {
                    Size = UDim2.new(1, 01, 0, 0,, 0, 96),
                    Position = 96),
                    Position = UDim2.new(0, 0, 0 UDim2.new(0, 0, 0, 20),
, 20),
                    BackgroundColor3 = Color3.fromHSV(h                    BackgroundColor3 = Color3.fromHSV(h, 1, 1),
                    BorderSizePixel =, 1, 1),
                    BorderSizePixel = 0, ZIndex = POPUP_Z_INDEX + 2 0, ZIndex = POPUP_Z_INDEX + 2, Parent = popup,
, Parent = popup,
                })
                Corner(svBox, 4)
                New("UIG                })
                Corner(svBox, 4)
                New("UIGradient", {
                    Color = ColorSequence.new(Colorradient", {
                    Color = ColorSequence.new(Color3.fromRGB(255,255,255),3.fromRGB(255,255, Color3.fromRGB255), Color3.fromRGB(255,255,255)),
                    Transparency = NumberSequence(255,255,255)),
                    Transparency = NumberSequence.new(0, 1),
                    Parent = svBox.new(0, 1),
                    Parent = svBox,
                })
                local blackOverlay = New("Frame,
                })
                local blackOverlay = New("Frame", {
                    Size = UDim2.new(1,0,", {
                    Size = UDim2.new(1,0,1,0), BackgroundColor3 =1,0), BackgroundColor3 = Color3.fromRGB(0,0,0),
                    Color3.fromRGB(0,0,0),
                    BorderSizePixel = 0, Z BorderSizePixel = 0, ZIndex = POPUP_Z_INDEX +Index = POPUP_Z_INDEX + 3, Parent = svBox,
                })
                Corner(blackOverlay,  3, Parent = svBox,
                })
                Corner(blackOverlay, 4)
                New("UIGradient", {
                    Rotation4)
                New("UIGradient", {
                    Rotation = 90,
                    Transparency = NumberSequence.new = 90,
                    Transparency = NumberSequence.new(0, 1),
                    Parent(0, 1),
                    Parent = blackOverlay,
                })
                local svKnob = New("Frame", {
 = blackOverlay,
                })
                local svKnob = New("Frame", {
                    Size = UDim2.new(                    Size = UDim2.new(0, 10, 0, 10),
                   0, 10, 0, 10),
                    Position = UDim2.new Position = UDim2.new(s, -5, 1-v, -(s, -5, 1-v, -5),
                    BackgroundColor35),
                    BackgroundColor3 = Color3.fromRGB(255, = Color3.fromRGB(255,255,255),
                    BorderSizePixel255,255),
                    BorderSizePixel = 1, ZIndex = POPUP_Z = 1, ZIndex = POPUP_Z_INDEX + 4,_INDEX + 4, Parent = svBox,
                })
                Parent = svBox,
                })
                Corner(svKnob, 5)

                -- Hex Corner(svKnob, 5)

                -- Hex input
                local hexInput = New("TextBox", {
                    Size = U input
                local hexInput = New("TextBox", {
                    Size = UDim2.new(1, 0, 0, 22),
                    Position = UDim2.new(0, 0, 1, -22),
                    BackgroundColor3 = theme.Tertiary,
                    BorderSizePixel = 0,
                    Text = string.format("#Dim2.new(1, 0, 0, 22),
                    Position = UDim2.new(0, 0, 1, -22),
                    BackgroundColor3 = theme.Tertiary,
                    BorderSizePixel = 0,
                    Text = string.format("#%02X%%02X%02X%02X", math.round(color.R02X%02X", math.round(color.R*255*255), math.round(color.G*255), math.round(color.B*255)),
                    TextColor3 = theme.Text, Font = Enum.Font.Code, TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Center), math.round(color.G*255), math.round(color.B*255)),
                    TextColor3 = theme.Text, Font = Enum.Font.Code, TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    ClearTextOnFocus = false, ZIndex = POPUP_Z_INDEX +,
                    ClearTextOnFocus = false, ZIndex = POPUP_Z_ 3INDEX + 3, Parent, Parent = popup,
                })
                Corner(hex = popup,
                })
                Corner(hexInput, 4)

                local function UpdateColor(nhInput, 4)

                local function UpdateColor(nh, ns, n, ns, nv, silent)
                    hv, silent)
                    h, s, v = nh, s, v = nh, ns, nv
, ns, n                    colorv
                    color = Color = Color3.fromHSV(h3.fromHSV(h, s, s, v)
                   , v)
                    preview.BackgroundColor preview.BackgroundColor3 = color
                    svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
3 = color
                    svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    hueCursor.Position = UDim2.new                    hueCursor.Position = UDim2.new(h, -2, (h, -2, 0, 0)
                    svKnob.Position    = UDim2.new(s, -5, 10, 0)
                    svKnob.Position    = UDim2.new(s, -5, 1-v, -5)
                   -v, -5)
                    hexInput hexInput.Text = string.format.Text = string.format("#%("#%02X02X%02%02X%02XX%02X", math.round(color.R*", math.round(color.R*255), math.round(color.G*255), math.round(color.B*255))
                    if255), math.round(color.G*255), math.round(color.B*255))
                    if flag then Library.Flags[flag] = color end
                    if not silent then safePCall(cb, flag then Library.Flags[flag] = color end
                    if not silent then safePCall(cb, color) end
                end

                local hDrag, svDrag = false, false

                hueBar.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        hDrag = true
                        local rel = math.clamp((inp.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                        UpdateColor(rel, s, v)
                    end
                end)
                svBox.InputBegan:Connect(function(inp color) end
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
                    if inp.UserInputType == Enum.UserInputType.MouseButton1)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDrag = true
                        local rx = math.clamp((inp.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, then
                        svDrag = true
                        local rx = math.clamp((inp.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
                        local ry = math.clamp((in 1)
                        local ry = math.clamp((inp.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
                        UpdateColor(h, rx, p.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
                        UpdateColor(h, rx, 1 - ry)
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInput1 - ry)
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseType == Enum.UserInputType.MouseButton1 then hButton1 then hDrag =Drag = false; false; svDrag svDrag = false = false end
                end end
                end)
                UserInput)
                UserInputService.InputChanged:Connect(functionService.InputChanged:Connect(function(inp)
                    if inp.UserInput(inp)
                    if inp.UserInputType ~= Enum.UserInputType.MouseMovementType ~= Enum.UserInputType.MouseMovement then return end
                    if then return end
                    if hDrag then
                        local rel = math.clamp((inp.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X,  hDrag then
                        local rel = math.clamp((inp.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 10, 1)
                       )
                        UpdateColor UpdateColor(rel, s(rel, s, v, v)
                    elseif svDrag then
                        local rx = math.clamp((inp.Position.X - sv)
                    elseif svDrag then
                        local rx = math.clamp((inp.Position.X - svBox.ABox.AbsolutePosition.XbsolutePosition.X) /) / svBox svBox.Abs.AbsoluteSize.X, 0oluteSize.X, 0, 1)
, 1)
                        local ry = math.clamp((inp.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1                        local ry = math.clamp((inp.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
                       )
                        UpdateColor UpdateColor(h, rx,(h, rx, 1 - ry)
                    1 - ry end
)
                    end
                end)

                hexInput                end)

                hexInput.Focus.FocusLost:Lost:Connect(functionConnect(function()
                   ()
                    local hex = hex local hex = hexInput.Text:gsub("#", "")
                    if #hex == Input.Text:gsub("#", "")
                    if #hex == 6 then
                        local r = tonumber(hex:sub(1,6 then
                        local r = tonumber(hex:sub(1,2), 16)
                        local g = tonumber(hex:sub(3,4), 16)
                        local2), 16)
                        local g = tonumber(hex:sub(3,4), 16)
                        local b b = tonumber(hex:sub = tonumber(hex:sub(5,(5,6),6), 16)
                        if r and g 16)
                        if r and g and b and b then
                            local then
                            local c3 c3 = Color3.fromRGB(r = Color3.fromRGB(r, g, g, b)
                           , b)
                            local nh local nh, ns, ns, nv = c3, nv = c3:ToHSV()
                            UpdateColor(nh, ns, nv)
                        end
                    end
                end)

                local pickerOpen = false
                local updateConn = nil

                local function updatePopupPosition()
                    if not preview or not:ToHSV()
                            UpdateColor(nh, ns, nv)
                        end
                    end
                end)

                local pickerOpen = false
                local updateConn = nil

                local function updatePopupPosition()
                    if not preview or not preview.Visible then return end
                    local absPos = preview.AbsolutePosition
                    local absSize = preview preview.Visible then return end
                    local absPos = preview.AbsolutePosition
                    local absSize = preview.AbsoluteSize
                    local viewSize = workspace.CurrentCamera.View.AbsoluteSize
                    local viewSize = workspace.CurrentCamera.ViewportSize
                   portSize
                    local pop local popupXupX = absPos.X + absSize.X = absPos.X + abs + 4
                    local popupSize.X + 4
                    local popupY = absPosY = absPos.Y
.Y
                    if                    if popupX + popupX + popup popup.AbsoluteSize.AbsoluteSize.X >.X > viewSize viewSize.X then
                        popup.X then
                        popupX =X = absPos absPos.X -.X - popup.Abs popup.AbsoluteSize.X - 4
                    end
                    if popupY +oluteSize.X - 4
                    end
                    if popupY + popup popup.AbsoluteSize.Y > viewSize.Y then
                        popupY = viewSize.Y - popup.AbsoluteSize.Y > viewSize.Y then
                        popupY = viewSize.Y - popup.Abs.AbsoluteSizeoluteSize.Y
.Y
                    end
                                       end
                    popup popup.Position.Position = UDim2 = U.fromOffset(popupX, popupYDim2.fromOffset(popupX, pop)
                end

                preview.MouseupY)
                end

                preview.MouseButton1Click:Connect(function()
                    pickerButton1Click:Connect(function()
                    pickerOpen = not pickerOpen
                   Open = not pickerOpen
                    if pickerOpen then
                        update if pickerOpen then
                        updatePopupPosition()
                        updateConn = RunPopupPosition()
                        updateConn = RunService.RenderStepped:Service.RenderStepped:Connect(function()
                            if previewConnect(function()
                            if preview and preview.Parent then updatePopupPosition() end
                        end)
 and preview.Parent then updatePopupPosition() end
                                               popup.Visible = true
 end)
                        popup.Visible = true
                    else                    else
                        if updateConn then updateConn:Dis
                        if updateConn then updateConn:Disconnect(); updateConn = nil end
                        popconnect(); updateConn = nil end
up.Visible = false
                        popup.Visible =                    end
                false
                    end
                end)

                table.insert(self._cleanup, Library:RegisterListener(function(t)
                    if popup and popup end)

                table.insert(self._cleanup, Library:RegisterListener(function(t)
                    if popup and.Parent popup.Parent then
                        popup.BackgroundColor3 = t.Secondary then
                        popup.BackgroundColor3 = t.Secondary
                       
                        hexInput.BackgroundColor3 = t.Tert hexInput.BackgroundColor3 = t.Tertiary
                        hexInput.Textiary
                        hexInput.TextColor3 = t.Text
                    end
               Color3 = t.Text
                    end end))

                local Ref = {}
               
                end))

                local Ref = {}
                function Ref:Set(c)
                    color function Ref:Set(c)
                    color = = c
                    preview.BackgroundColor c
                    preview.BackgroundColor3 = c
                    local3 = c
                    local nh, ns, nv = c:To nh, ns, nv = c:ToHSV()
                    UpdateColor(nh, ns, nv, trueHSV()
                    UpdateColor(nh, ns, nv, true)
                end
)
                end
                function Ref:Get()                function Ref:Get() return color return color end
                function Ref:Dependency(t end
                function Ref:Dependency(toggleRef, requireVal)
                    localoggleRef, requireVal)
                    local conn
                    local function Up conn
                    local function Upd()
                        if not rowd()
                        if not row then conn:Disconnect() return end
                        then conn:Disconnect() return end
                        row.Visible = (toggleRef: row.Visible = (toggleRef:Get() == requireVal)
                    endGet() == requireVal)
                    end
                    conn = RunService.Heartbeat:Connect(Upd); Up
                    conn = RunService.Heartbeat:Connect(Upd); Upd()
                end
                return Ref
            end

            -- ═════d()
                end
                return Ref
            end

            -- ══════════════════════════════════════════════
            --  KEYBIND═════════════════════════════════════════
            --  KEY
            -- ═════════BIND
            -- ═══════════════════════════════════════════════════════════════════════════════════
            function GB:Create
            function GB:CreateKeybind(opts)
               Keybind(opts)
                local n       = opts.Name local n       = opts.Name     or "Keybind"
                local default = opts.Default     or "Keybind"
                local default = opts.Default  or Enum.KeyCode.Unknown
                local flag     or Enum.KeyCode.Unknown
                local flag    = opts.Flag
                local cb      = opts.C = opts.Flag
                local cb      = opts.Callback or function() end
                local tooltipallback or function() end
                local tooltip = opts.Tooltip
                local = opts.Tooltip
                local theme   = T()

                local key theme   = T()

                local key       =       = default
                local listening = default
                local listening = false
 false
                if flag then Library.Flags[flag                if flag then Library.Flags[flag] = key end

                local row, _ = ElemRow(n, 26, tool] = key end

                local row, _ = ElemRow(n, 26, tooltip)

                local keyBtn = New("Texttip)

                local keyBtn = New("TextButton", {
                    Size             = UDim2Button", {
                    Size             = UDim2.new(0,.new(0, 72, 0, 22 72, 0, 22),
                   ),
                    Position         = UDim2.new( Position         = UDim2.new(1,1, -72,  -72, 0.5, -11),
                   0.5, -11),
                    BackgroundColor3 = theme.Secondary BackgroundColor3 = theme.Secondary,
                    BorderSizePixel  = ,
                    BorderSizePixel  = 0,
                    Text             = key.Name0,
                    Text             = key.Name ~= "Unknown" and key.Name or " ~= "Unknown" and key.Name or "None",
                    TextColor3       = theme.SubNone",
                    TextColor3       =Text,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 11,
                    ZIndex           theme.SubText,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 11,
                    Z = 5,
                    Parent           =Index           = 5,
                    Parent           = row,
                })
                Corner(keyBtn,  row,
                })
                Corner(keyBtn, 5)
5)
                Stroke(keyBtn, theme.Outline                Stroke(keyBtn, theme.Outline)

                keyBtn.MouseButton1Click:Connect(function)

                keyBtn.MouseButton1Click:()
                    listening = true
                    keyBtn.TextConnect(function()
                    listening = true
                    keyBtn.Text      = "..."
                    keyBtn.TextColor3 = T      = "..."
                    keyBtn.Text().Accent
                endColor3 = T().Accent
                end)

               )

                UserInputService.InputBegan:Connect(function(in UserInputService.InputBegan:Connect(function(inp, gpep, gpe)
                    if listening and not gpe then
                        if inp.UserInputType == Enum.UserInputType.Keyboard then)
                    if listening and not gpe then
                        if inp.UserInputType == Enum.UserInputType.Keyboard then
                            key =
                            key = inp.KeyCode
                            if flag then Library.Flags[flag inp.KeyCode
                            if flag then Library.Flags[flag] = key end
                            keyBtn] = key end
                            keyBtn.Text      .Text       = key = key.Name
                            keyBtn.TextColor3 = T.Name
                            keyBtn.TextColor3 = T().SubText
                            listening().SubText
                            listening = false
                        end
                    elseif not gpe and = false
                        end
                    elseif not gpe and not listening and inp.KeyCode not listening and inp.KeyCode == key and key ~= Enum.KeyCode.Unknown then == key and key ~= Enum.KeyCode.Unknown then
                        safePCall(cb)
                    end
                end)

                table
                        safePCall(cb)
                    end
                end)

                table.insert(self._cleanup, Library:RegisterListener.insert(self._cleanup, Library:RegisterListener(function(t)
                    if keyBtn and keyBtn.Parent then
                        key(function(t)
                    if keyBtn and keyBtn.Parent then
                        keyBtn.BackgroundColor3 = t.SeBtn.BackgroundColor3 = t.Secondary
                        keyBtn.TextColorcondary
                        keyBtn.TextColor3       = t.SubText
                       3       = t.SubText
                        keyBtn.Font             = Enum.Font.Gotham keyBtn.Font             = Enum.Font.Gotham
                    end
                end))

               
                    end
                end))

                local Ref = {}
                function local Ref = {}
                function Ref: Ref:Set(k) key = k; keyBtn.Text = k.Name end
                function Ref:Get() returnSet(k) key = k; keyBtn.Text = k.Name end
                function Ref:Get() return key end
                function Ref key end
                function Ref:Dependency(toggleRef, requireVal:Dependency(toggleRef, requireVal)
                    local conn
                    local function Upd()
                       )
                    local conn
                    local function Upd()
                        if not row then if not row then conn:Disconnect() return end
                        row.Visible conn:Disconnect() return end
                        row.Visible = (toggleRef:Get = (toggleRef:Get() == requireVal)
                    end
() == requireVal)
                    end
                    conn = RunService.Heartbeat:Connect                    conn = RunService.Heartbeat:Connect(Upd); Upd()
               (Upd); Upd()
                end
                return Ref
            end

            -- ═ end
                return Ref
            end

            -- ══════════════════════════════════════════════
            --  LABEL═════════════════════════════════════════════
            --  LABEL
            -- ══════════════════════════════════════════════
           
            -- ══════════════════════════════════════════════
            function GB function GB:CreateLabel(opts)
                local:CreateLabel(opts)
                local text    = opts.Text  or ""
                local text    = opts.Text  or ""
 clr     = opts.Color
                               local clr     = opts.Color
                local theme   = T()

                local local theme   = T()

                local lbl = New("TextLabel", {
                    Size lbl = New("TextLabel", {
                    Size                = UDim                = UDim2.new(1, 0, 2.new(1, 0,0, 0),
                    AutomaticSize       = Enum.AutomaticSize.Y,
                    Background 0, 0),
                    AutomaticSize       = Enum.AutomaticSize.Y,
                   Transparency = 1,
                    Text                = text,
                    TextColor3          = cl BackgroundTransparency = 1,
                    Text                = text,
                    TextColor3          = clr or theme.SubText,
r or theme.Sub                    Font                = Library.Font,
                    TextSizeText,
                    Font                = Library.Font,
                    TextSize            = 12,
                    TextXAlignment      = Enum.TextXAlignment.Left,
            = 12,
                    TextXAlignment      = Enum.TextXAlignment.                    TextWrapped         = true,
                    ZIndex             Left,
                    TextWrapped         = true,
                    ZIndex              = 5,
                    Parent              = = 5,
                    Parent              = self._list,
                })
 self._list,
                if not clr then
                                   })
                if not cl table.insert(self._cleanup, Library:RegisterListener(function(t)
                        if lbl and lbl.Parent then
                           r then
                    table.insert(self._cleanup, Library:RegisterListener(function(t)
                        if lbl and lbl.Parent then
                            lbl.TextColor3 = t.SubText
                            lbl.Font lbl.TextColor3 = t.SubText
                                  = Library.Font
                        end
                    end lbl.Font       = Library.Font
                        end
                    end))
               ))
                end
                local Ref = {}
                function Ref:Set(t) lbl.Text = t end end
                local Ref = {}
                function Ref:Set(t) lbl.Text = t end

                function Ref:Get() return lbl.Text end
                return Ref                function Ref:Get() return lbl.Text end
               
            end

            -- return Ref
            end

            -- ═════════════════════════════════════ ══════════════════════════════════════════════
            --═════════
            --  DIVIDER
            -- ═════════════  DIVIDER
            -- ══════════════════════════════════════════════
            function GB:CreateDiv═════════════════════════════════
            function GB:CreateDivider(labelText)
                local theme = T()
                if labelTextider(labelText)
                local theme = T()
 and labelText ~= ""                if labelText and labelText ~= "" then
                    local container = New(" then
                    local container =Frame", {
                        Size = U New("Frame", {
                        Size = UDim2.new(1, Dim2.new(1, 0, 0, 16),
                        Background0, 0, 16),
                        BackgroundTransparency = 1,
                        ZTransparency = 1,
                        ZIndex = 4, Parent = selfIndex = 4, Parent = self._list,
                    })
                    New("Frame", {
                        Size = UDim2.new(0.38, ._list,
                    })
                    New("Frame", {
                        Size = UDim2.new(0.38, 0, 0, 1),
0, 0, 1),
                        Position = UDim2.new(0, 0, 0.5,                        Position = UDim2.new(0, 0, 0.5, 0),
                        BackgroundColor3 = 0),
                        BackgroundColor3 = theme.Outline, BorderSizePixel = theme.Outline, BorderSizePixel = 0, ZIndex = 4, Parent = container,
                    0, ZIndex = 4, Parent = container,
                    })
                    New("TextLabel", {
                        Size })
                    New("TextLabel", {
                        Size = UDim2.new(0.24, = UDim2.new(0.24, 0, 1, 0), Position = UDim2.new(0.38, 0, 1, 0), Position = UDim2.new(0.38, 0, 0, 0),
                        BackgroundTrans 0, 0, 0),
                        BackgroundTransparency = 1, Text = labelText,
                       parency = 1, Text = labelText,
 TextColor3 = theme.SubText, Font                        TextColor3 = theme.SubText, Font = Enum.Font.Gotham, Text = Enum.Font.Gotham, TextSize = 10,
                        TextXAlignment =Size = 10,
                        TextXAlignment = Enum.TextXAlignment.Center Enum.TextXAlignment.Center, ZIndex = 5, Parent = container, ZIndex = 5, Parent = container,
                    })
                    New(",
                    })
                    New("Frame",Frame", {
                        Size = UDim2.new(0.38,  {
                        Size = UDim2.new(0.38, 0, 0, 1),0, 0, 1), Position = Position = UDim2.new(0 UDim2.new(0.62.62, 0, 0.5, , 0, 0.5, 0),
                        BackgroundColor3 = theme.Outline0),
                        BackgroundColor3 = theme.Outline, BorderSizePixel = , BorderSizePixel = 0, ZIndex = 4, Parent =0, ZIndex = 4, Parent = container,
                    })
                else container,
                    })
                else
                    New("Frame", {
                        Size = UDim
                    New("Frame", {
                        Size = UDim2.new(1, 0,2.new(1, 0, 0, 1),
 0, 1),
                        BackgroundColor3 = theme.Outline, BorderSizePixel = 0,
                        ZIndex =                        BackgroundColor3 = theme.Outline, BorderSizePixel = 0,
                        ZIndex = 4, Parent = self 4, Parent = self._list,
                    })
                end
            end

           ._list,
                    })
                end
            end

            return GB
        end -- CreateGroupbox

        return Tab
 return GB
        end -- CreateGroupbox

        return Tab
    end -- CreateTab

    -- ═════════════════════════════    end -- CreateTab

    -- ═══════════════════════════════════════════════════════════════════════════════════
   
    --  BUILT-IN: OPTIONS TAB (unchanged except --  BUILT-IN: OPTIONS TAB (unchanged except using safePCall)
    -- using safePCall)
    -- ═════════════════════════════════════════════ ════════════════════════════════════════════════
    local Options═══════════════════
    local OptionsTab    = Win:CreateTab("Tab    = Win:CreateTab("Options")
Options")
    local OptLeft       = OptionsTab    local OptLeft       = OptionsTab:CreateGroupbox("Appearance",:CreateGroupbox("Appearance", "Left")
    "Left")
    local Opt local OptRight      = OptionsTab:CreateGroupRight      = OptionsTab:CreateGroupbox("Interface", "Right")

    -- Themebox("Interface", "Right")

    -- Theme Dropdown
    Dropdown
    local themeNames = {}
    for k in pairs(Library.Themes) do local themeNames = {}
    for k in pairs(Library.Themes) do table.insert(themeNames, k) table.insert(themeNames, k) end
    table.sort(themeNames)

    OptLeft end
    table.sort(themeNames)

    OptLeft:CreateDropdown({
        Name:CreateDropdown({
        Name    = "Theme",
        Options = themeNames    = "Theme",
        Options = themeNames,
        Default = Library.CurrentTheme,
,
        Default = Library.CurrentTheme,
        Tooltip = "Choose a        Tooltip = "Choose a colour theme",
        Callback = function( colour theme",
        Callback = function(sel)
            Library.CurrentTheme = sel
           sel)
            Library.CurrentTheme = sel
            FireTheme()
        end,
    })

    local accentPickerRef = FireTheme()
        end,
    })

    local accentPickerRef = OptLeft:CreateColorPicker({
        Name    = " OptLeft:CreateColorPicker({
        Name    = "Accent Color",
        Default = TAccent Color",
        Default = T().Accent,
        Tooltip =().Accent,
        Tooltip = "Override the accent colour for the current theme",
 "Override the accent colour for the current theme",
        Callback = function(c)
            Library.Themes[Library.CurrentTheme].        Callback = function(c)
            Library.Themes[Library.CurrentTheme].AccentAccent    = c
            Library.Themes[Library.CurrentTheme].AccentDark    = c
            Library.Themes[Library.CurrentTheme].Acc = Color3.new(c.R * 0.7, c.GentDark = Color3.new(c.R * 0.7, c.G * 0.7, * 0.7, c.B * 0.7)
 c.B * 0.7)
            Library            Library.Themes[Library.CurrentTheme].AccentGlow = Color3.new(math.min(c.Themes[Library.CurrentTheme].AccentGlow = Color3.new(math.R * 1.3, 1),.min(c.R * 1.3, 1), math.min(c.G * 1. math.min(c.G * 1.3, 1), math.min(c.B *3, 1), math.min(c.B * 1 1.3, 1))
            FireTheme()
.3, 1))
            Fire        end,
    })

   Theme()
        end,
    })

    OptLeft:CreateToggle({
        Name    = "R OptLeft:CreateToggle({
        Name    = "Rounded Corners",
        Defaultounded Corners",
        Default = Library.RoundedCorners,
        = Library.RoundedCorners,
        Tooltip = "Toggle rounded or sharp corner radius Tooltip = "Toggle rounded or sharp corner radius",
        Callback = function(v) Library.RoundedCorners = v end",
        Callback = function(v) Library.RoundedCorners = v end,
,
    })

    OptLeft:CreateSlider    })

    OptLeft:CreateSlider({
        Name    = "Corner Radius",
        Min({
        Name    = "Corner Radius",
        Min = 0, Max = 14 = 0, Max = 14, Default, Default = Library.CornerRadius,
        = Library.CornerRadius,
        Tooltip = "Pixel radius of rounded corners",
        Callback = function(v Tooltip = "Pixel radius of rounded corners",
        Callback = function(v) Library.CornerRadius = v end,
    })

) Library.CornerRadius = v end,
    local fontMap = {
        ["    })

    local fontMap = {
Gotham Medium"] = Enum.Font        ["Gotham Medium"] = Enum.Font.Goth.GothamMedium,
        ["GothamamMedium,
        ["Gotham"]        = Enum.Font.G"]        = Enum.Font.Gotham,
        ["Gotham Bold"]   = Enum.Font.Gothotham,
        ["Gotham Bold"]   = Enum.Font.GothamBold,
        ["ArialamBold,
        ["Arial"]         = Enum.Font.Arial,
        ["Code"]"]         = Enum.Font.Arial,
        ["          = Enum.Font.Code,
        ["Source SansCode"]          = Enum.Font.Code,
        [""]   = Enum.Font.SourceSans,
Source Sans"]   = Enum.Font.SourceSans,
    }
    }
    local    local fontKeys = {}
    for k in pairs(fontMap fontKeys = {}
    for k in pairs(fontMap) do table.insert(fontKeys, k) end
    table.sort(fontKeys) do table.insert(fontKeys, k) end
    table.sort(f)

    OptLeft:CreateDropdown({
ontKeys)

    OptLeft:CreateDropdown({
        Name        Name    = "Font",
        Options = fontKeys    = "Font",
        Options = fontKeys,
        Default = "G,
        Default = "Gotham Medium",
        Tooltip = "Change the UIotham Medium",
        Tooltip = "Change the UI font family",
        Callback = function(f)
            Library.Font = font family",
        Callback = function(f)
            Library.Font = fontMap[f] or Enum.Font.Gotham fontMap[f] or Enum.Font.GothamMedium
            FireTheme()
        end,
    })

    OptRightMedium
            FireTheme()
        end,
    })

    OptRight:CreateSlider({
        Name   = "UI Scale",
        Min:CreateSlider({
        Name   = "UI Scale",
        Min = 50, Max = 150 = 50, Max = 150, Default = 100, Suffix = "%, Default = 100, Suffix = "%",
        Tooltip = "Scales",
        Tooltip = "Scales the window size",
        Callback = function(p the window size",
        Callback = function(pct)
            Library.Scale = pct / 100ct)
            Library.Scale = pct / 100
            Root.Size = UDim2
            Root.Size = UDim2.new(
                winSize.X.Scale, winSize.X.Offset.new(
                winSize.X.Scale, winSize.X.Offset * Library.Scale,
                winSize.Y.Scale, winSize * Library.Scale,
                winSize.Y.Scale, winSize.Y.Offset * Library.Scale
.Y.Offset * Library.Scale
            )
        end,
    })

    OptRight:CreateSlider({
            )
        end,
    })

    OptRight:CreateSlider({
        Name   = "Trans        Name   = "Transparency",
        Min = 0, Max = 80parency",
        Min = 0, Max =, Default = 0, Suffix = "%",
        Tooltip = "Background transparency 80, Default = 0, Suffix = "%",
        Tooltip = "Background transparency of the window",
        Callback = function(p of the window",
        Callback = function(pct)
            Library.Transct)
            Library.Transparency = pct / parency = pct / 100
            Root.BackgroundTransparency = Library.Transparency
100
            Root.BackgroundTransparency = Library.Transparency
        end,
    })

    OptRight:CreateToggle({
        Name        end,
    })

    OptRight:CreateToggle({
        Name    = "Blur Background",
        Default =    = "Blur Background",
        false,
 Default = false,
        Tooltip = "Apply depth-of-field blur effect",
        Callback = function(v)
                   Tooltip = "Apply depth-of-field blur effect",
        Callback = function(v)
            Library.BlurEnabled = v
            local lighting = Library.BlurEnabled = v
            local lighting = game:GetService("Lighting")
            local blur = game:GetService("Lighting")
            local lighting:FindFirstChild(" blur = lighting:FindFirstChild("_U_UILibBlurILibBlur")
           ")
            if v then
                if not blur if v then
                if not blur then
                    blur = Instance.new("BlurEffect")
                    blur.Name = "_UILibBlur"
                    blur.Size =  then
                    blur = Instance.new("BlurEffect")
                    blur.Name = "_UILibBlur"
                    blur.Size12
                    blur.Parent = lighting
                = 12
                    blur.Parent = lighting
                end
 end
                blur.Enabled                blur = true
            else
                if blur then blur.Enabled = false end.Enabled = true
            else
                if blur then blur.Enabled = false end
           
            end
        end,
    })

    end
        end,
    })

    OptRight OptRight:CreateButton({
        Name    = "Reset:CreateButton({
        Name Theme",
        Tooltip = "Restore the    = "Reset Theme",
        Tooltip = "Restore the default theme settings",
 default theme settings",
        Callback = function()
            Library.CurrentTheme        Callback = function()
            Library.CurrentTheme = "Dark"
            FireTheme()
            Library:Notify({ Title = "Theme Reset", Message = "Reverted to Dark theme = "Dark"
            FireTheme()
            Library:Notify({ Title = "Theme Reset", Message = "Reverted to Dark theme.", Type = "Info" })
        end,
.", Type = "Info" })
           })

 end,
    })

    --    -- ════════════════════════════════════════════════════════ ════════════════════════════════════════════════════════
    --  BUILT-IN: CON
    --  BUILT-IN: CONFIG TABFIG TAB (fixed (fixed table.clear)
    -- ═════════════════════════════════════ table.clear)
    -- ════════════════════════════════════════════════
    local ConfigTab   = Win:CreateTab("═══════════════════════════
    local ConfigTab   = Win:CreateTab("Config")
Config")
    local CfgLeft     = Config    local CfgLeft     = ConfigTab:CreateGroupbox("Configs", "Tab:CreateGroupbox("Configs", "Left")
    local CfgRight   Left")
    local CfgRight    = Config = ConfigTab:CreateGroupbox("Actions", "Right")

    local CFTab:CreateGroupbox("Actions", "Right")

    local CFG_FOLDER  = "UILG_FOLDER  = "UILibConfigs"

    local function SafeibConfigs"

    local function SafeFS(fFS(fn, ...)
        local ok,n, ...)
        local ok, r = pcall(fn, ...)
        if r = pcall(fn, ...)
        not ok then warn if not ok then warn("[UILibrary] FileSystem error:", r) end
        return ok("[UILibrary] FileSystem error:", r) end
        return ok, r
    end
    local function EnsureDir()
        if not isfolder then return end, r
    end
    local function EnsureDir()
        if not isfolder then return end
        if not isfolder(CFG_F
        if not isfolder(CFOLDER) then
            SafeFS(makefolder,G_FOLDER) then
            SafeFS(make CFGfolder, CFG_FOLDER)
        end
    end
    local function_FOLDER)
        end
    end
    local function GetCfgList()
        local list GetCfgList()
        local list = {}
        if not isfolder then = {}
        if not isfolder then return list end
        SafeFS( return list end
        SafeFS(EnsureDir)
        local ok, files = SafeFS(listfiles, CFG_FOLDEREnsureDir)
        local ok, files = SafeFS(listfiles, CFG_FOLDER)
       )
        if ok and files then
            for _, f in ipairs(files) do
                local if ok and files then
            for _, f in ipairs(files) do
 name = (f:match("[^/\\]+$") or f)
                if                local name = (f:match("[^/\\]+$") or f)
                if name:sub(-5) == ".json" name:sub(-5) == ". then
                    table.insert(list, name:subjson" then
                    table.insert(list, name:sub(1(1, -6))
                end
            end
        end
        table.sort(list)
        return list
    end

   , -6))
                end
            end
        end
        table.sort(list)
        return list
    end local function SerializeFlags()
        local data =

    local function SerializeFlags()
        local data = {}
        for k, val in pairs {}
        for k, val in pairs(Library.Flags) do
            local t =(Library.Flags) do
            local type(val)
            t = type(val)
            if t == "boolean" or t == "number" or t == "string" then
                data if t == "boolean" or t == "number" or t == "string" then
                data[k] = val
            elseif typeof(val)[k] = val
            elseif typeof(val) == "Color3" then
                data[k] = { _T = "C3", r = val.R == "Color3" then
                data[k] = { _T = "C3", r =, g = val.G, b = val.B }
            elseif typeof val.R, g = val(val) == "EnumItem" then
               .G, b = val.B }
            elseif typeof(val) == "EnumItem" then
                data[k] = { _T = "EI data[k] = { _T = "EI", e", eType = tostring(val.EnumType), nameType = tostring(val.EnumType), name = val = val.Name }
            end
        end
.Name }
            end
        end
        return        return data
    end data
    end

   

    local function DeserializeFlags(data)
        local function DeserializeFlags(data)
        for k, val in pairs(data) do
            if type(val) == "table" then
                if val for k, val in pairs(data) do
            if type(val) == "table" then
                if val._T == "C3" then
                    Library.Flags._T == "C3" then
                    Library.Flags[k][k] = Color = Color3.new(val.r, val.g, val.b)
                elseif val._T == "EI"3.new(val.r, val.g, val.b)
                elseif val._T == "EI" then
                    pcall(function() Library.Flags[k then
                    pcall(function() Library.Flags[k] = Enum[val.eType][val.name] end] = Enum[val.eType][val.name)
                end
            else
               ] end)
                end
            else
                Library.F Library.Flags[k] = val
            end
lags[k] = val
            end
        end
    end

    local cfgNameRef = Cfg        end
    end

    local cfgNameRef = CfgLeft:CreateTextInput({
        Name        = "Config Name",
Left:CreateTextInput({
        Name        = "Config Name",
        Placeholder = "MyConfig",
        Default        Placeholder = "MyConfig",
        Default     = "MyConfig",
    })

        = "MyConfig",
    })

    local cfgDropRef = CfgLeft:CreateDropdown({
        Name    = "Saved Configs",
        Options local cfgDropRef = CfgLeft:CreateDropdown({
        Name    = "Saved Configs",
        Options = Get = GetCfgList(),
        Tooltip = "Select a config to load or delete",
    })

   CfgList(),
        Tooltip = "Select a config to load or delete",
    CfgRight:CreateButton({
        Name    = " })

    CfgRight:CreateButton({
        Name   Save Config",
        Tooltip = " = "Save Config",
        Tooltip = "Save current element states to a JSON file",
        Callback = function()
           Save current element states to a JSON file",
        Callback = function if not writefile then
                Library:Notify({ Title = "Unsupported",()
            if not writefile then
                Library:Notify({ Title = "Unsupported", Message = "File system not available.", Type = Message = "File system not available.", Type = "Error" })
                return "Error" })

            end
            local name = cfgNameRef:Get()
            if name ==                return
            end
            local name = cfgNameRef:Get()
            if name == "" then name = "MyConfig" end
            Safe "" then name = "MyConfig" end
            SafeFS(EnsureDir)
            local ok, errFS(EnsureDir)
            local ok = SafeFS(writefile, CFG_FOLDER .. "/", err = SafeFS(writefile, CFG_FOLDER .. "/" .. name .. ". .. name .. ".json",
json",
                HttpService:JSONEncode(SerializeFlags()))
                           HttpService:JSONEncode(SerializeFlags if ok then
                Library:Notify({ Title = "Config Saved", Message = '"()))
            if ok then
                Library:Notify({ Title = "Config Saved", Message = '"' ..' .. name .. '" saved successfully.', Type = name .. '" saved successfully.', Type = "Success" })
                cfgDropRef:SetOptions( "Success" })
                cfgDropRef:SetGetCfgList())
           Options(GetCfgList else
                Library:Notify({ Title = "Save Failed", Message = tostring(err())
            else
                Library:Notify({ Title = "Save Failed", Message = tostring(err), Type = "Error" })
            end
        end,
    })

   ), Type = "Error" })
            end
        end,
    })

    CfgRight:CreateButton({
        Name    = " CfgRight:CreateButton({
        Name   Load Config",
        = "Load Config",
        Tooltip = "Load a saved config and apply all element states",
        Callback = Tooltip = "Load a saved config and apply all element states",
        Callback = function()
            if not readfile then
                function()
            if not readfile then
                Library:Notify({ Title = "Unsupported", Message = Library:Notify({ Title = "Unsupported", Message = "File system not available.", Type = "Error" })
                return "File system not available.", Type = "Error" })
                return
            end
            local
            end
            local name = cfgDropRef:Get()
 name = cfgDrop            if not name then
                Library:Notify({ Title = "No Config", Message = "Select a config from the listRef:Get()
            if not name then
                Library:Notify({ Title = "No Config", Message = "Select a config from the list.", Type = "Warning" })
                return
            end.", Type = "Warning" })
                return
            end
            local ok, raw = SafeFS(readfile,
            local ok CFG_FOLDER .. "/" .. name .. ".json, raw = SafeFS(readfile, CFG_FOLDER .. "/" .. name .. ".json")
            if ok then
                local decoded
")
            if ok then
                local decoded
                ok, decoded = SafeFS(function() return                ok, decoded = SafeFS(function() return HttpService HttpService:JSONDecode(raw) end)
                if ok and:JSONDecode(raw) end)
                if decoded then
                    DeserializeFlags(decoded)
                    Library:Notify({ Title = "Config ok and decoded then
                    Loaded", Message = '"' .. name .. '" applied DeserializeFlags(decoded)
                    Library:Notify({ Title = "Config Loaded", Message = '"' .. name ...', Type = "Success" })
                else
                    Library:Notify({ Title = "Parse Error '" applied.', Type = "Success" })
                else
                    Library:Notify({ Title = "", Message = "Config file is corrupted.", Type = "Parse Error", Message = "Error" })
                end
            elseConfig file is corrupted.", Type = "Error" })
                end
            else
                Library:Notify({ Title = "Read Error", Message =
                Library:Notify({ Title = "Read Error", Message = "Could not read the config file.", Type = "Error "Could not read the config file.", Type =" })
            end
        end,
    })

 "Error" })
            end
        end,
    })

    CfgRight:Create    CfgRightButton({
        Name    = "Delete Config",
        Tool:CreateButton({
        Name    = "Delete Config",
        Tooltip = "Permanently delete the selected config",
        Callback = function()
            if not delftip = "Permanently delete the selected config",
        Callback = function()
            if notile then
                Library:Notify({ Title = delfile then
                Library:Notify({ Title = "Un "Unsupported", Message = "File system not available.",supported", Message = "File system not available.", Type = "Error Type = "Error" })
                return
           " })
                return
            end
            local name = cfgDropRef:Get()
            if not name then
 end
            local name = cfgDropRef:Get()
            if not name then
                Library:Notify({ Title = "No Config", Message = "Select a                Library:Notify({ Title = "No Config", Message = "Select a config from the list config from the list.", Type = "Warning" })
                return
            end
            local ok.", Type = "Warning" })
                return
            end
            local ok, _ = Safe, _ = SafeFS(delfile, CFG_FOLDER ..FS(delfile, CFG_FOLDER .. "/" .. name .. ".json")
            Library "/" .. name .. ".json")
            Library:Notify({
                Title   = ok:Notify({
                Title   = ok and "Deleted" or "Delete Failed",
                Message = and "Deleted" or "Delete Failed",
                Message = ok and ('"' .. name .. '" ok and ('"' .. name .. '" has been deleted. has been deleted.') or "Could not delete the file.",
                Type    = ok and "Success" or "') or "Could not delete the file.",
                Type    = ok and "Success" or "Error",
Error",
            })
            cfgDropRef:SetOptions(GetCfgList())
        end,
    })

    CfgRight:CreateButton({
        Name            })
            cfgDropRef:SetOptions(GetCfgList())
        end,
    })

    CfgRight:CreateButton({
        Name    = "Refresh    = "Refresh List",
        Tooltip = "Re-scan disk for saved config files",
        Callback = function()
            cfgDropRef List",
        Tooltip = "Re-scan disk for saved config files",
        Callback = function()
            cfgDropRef:SetOptions(GetCfgList())
            Library::SetOptions(GetCfgList())
            Library:Notify({ Title = "Refreshed", MessageNotify({ Title = "Refreshed", Message = "Config list updated.", Type = "Info" })
 = "Config list updated.", Type = "Info" })
        end,
    })

    CfgRight:CreateDivider()

    CfgRight:CreateButton({
        Name        end,
    })

    CfgRight:CreateDivider()

    CfgRight:CreateButton({
        Name    =    = "Reset All Flags",
        Tooltip = "Clear all flag values (does NOT delete "Reset All Flags",
        Tooltip = "Clear all flag values (does NOT delete files)",
 files)",
        Callback = function()
            tableClear(Library.Flags        Callback = function()
            tableClear(Library.Flags)
            Library:Notify({)
            Library:Notify({ Title = "Flags Cleared", Message = " Title = "Flags Cleared", Message = "All flags have been reset.", Type = "Warning" })
All flags have been reset.", Type = "Warning" })
        end,
    })

    table.insert(Library        end,
    })

    table.insert(Library._windows, Win)

    return Win
end

-- ──────────────────── Library Cleanup ─────────────────────
function._windows, Win)

    return Win
end

-- ──────────────────── Library Cleanup ───────────────────── Library:Destroy()
    p
function Library:Destroy()
call(function()
        local blur = game:Get    pcall(function()
        local blur = game:GetService("Lighting"):FindFirstChild("_UILibBlur")
        if blur then blur:DestroyService("Lighting"):FindFirstChild("_UILibBlur")
        if blur then blur:Destroy() end
    end)
    if self._tooltip() end
    end)
    if self._tooltipConnection then
        self._Connection then
       tooltipConnection:Disconnect()
        self._tooltipConnection = nil
    end self._tooltipConnection:Disconnect()
        self._tooltipConnection = nil
    end
    pcall(function() ScreenGui:Destroy() end
    pcall(function() ScreenGui:Destroy)
end

return Library
() end)
end

return Library
