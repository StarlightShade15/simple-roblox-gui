--[[
╔══════════════════════════════════════════════════════════════════════════════╗
║               NEVERLOSE UI LIBRARY  ·  EXTENDED EDITION                     ║
║   Components : Toggle · Slider · Dropdown · ColorPicker · Textbox           ║
║   Architecture: Full OOP metatables, every element :Set() / :Get()          ║
║   Theme       : Bg #0C0C0C  ·  Accent #FF3C3C  ·  Gotham font family       ║
╚══════════════════════════════════════════════════════════════════════════════╝
]]

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- ─────────────────────────────────────────────────────────────────────────────
--  THEME
-- ─────────────────────────────────────────────────────────────────────────────
local Theme = {
    Bg        = Color3.fromRGB(12,  12,  12 ),
    Sidebar   = Color3.fromRGB(15,  15,  15 ),
    Accent    = Color3.fromRGB(255, 60,  60 ),
    AccentDim = Color3.fromRGB(180, 40,  40 ),
    Outline   = Color3.fromRGB(30,  30,  30 ),
    Text      = Color3.fromRGB(255, 255, 255),
    DarkText  = Color3.fromRGB(120, 120, 120),
    SectionBg = Color3.fromRGB(18,  18,  18 ),
    Input     = Color3.fromRGB(22,  22,  22 ),
    Hover     = Color3.fromRGB(255, 60,  60 ),   -- used at low alpha
}

-- ─────────────────────────────────────────────────────────────────────────────
--  UTILITY HELPERS
-- ─────────────────────────────────────────────────────────────────────────────
local function Tween(obj, props, t, style, dir)
    TweenService:Create(
        obj,
        TweenInfo.new(t or 0.12, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props
    ):Play()
end

-- Adds UICorner with given pixel radius
local function Corner(parent, r)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, r or 4)
    return c
end

-- Adds UIStroke
local function Stroke(parent, color, thickness)
    local s = Instance.new("UIStroke", parent)
    s.Color     = color     or Theme.Outline
    s.Thickness = thickness or 1
    return s
end

-- Quick TextLabel factory
local function MakeLabel(parent, props)
    local l = Instance.new("TextLabel", parent)
    l.BackgroundTransparency = 1
    l.Font                   = props.Font     or Enum.Font.Gotham
    l.TextSize               = props.Size     or 12
    l.TextColor3             = props.Color    or Theme.DarkText
    l.Text                   = props.Text     or ""
    l.TextXAlignment         = props.Align    or Enum.TextXAlignment.Left
    l.Position               = props.Pos      or UDim2.new(0, 0, 0, 0)
    l.Size                   = props.SizeUDim or UDim2.new(1, 0, 1, 0)
    if props.ZIndex then l.ZIndex = props.ZIndex end
    return l
end

-- ─────────────────────────────────────────────────────────────────────────────
--  LIBRARY  (root object)
-- ─────────────────────────────────────────────────────────────────────────────
local Library = {}
Library.__index = Library

function Library.new(title)
    local self = setmetatable({}, Library)

    -- ScreenGui -----------------------------------------------------------------
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name            = "NeverloseUI"
    self.ScreenGui.ResetOnSpawn    = false
    self.ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.IgnoreGuiInset  = true
    self.ScreenGui.DisplayOrder    = 10
    self.ScreenGui.Parent          = Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Z-order overlay layers (above the main window) ----------------------------
    --  DropdownLayer  ZIndex 50  – dropdown lists
    --  PickerLayer    ZIndex 60  – color picker panels
    self.DropdownLayer = Instance.new("Frame", self.ScreenGui)
    self.DropdownLayer.Name               = "DropdownLayer"
    self.DropdownLayer.Size               = UDim2.fromScale(1, 1)
    self.DropdownLayer.BackgroundTransparency = 1
    self.DropdownLayer.ZIndex             = 50

    self.PickerLayer = Instance.new("Frame", self.ScreenGui)
    self.PickerLayer.Name               = "PickerLayer"
    self.PickerLayer.Size               = UDim2.fromScale(1, 1)
    self.PickerLayer.BackgroundTransparency = 1
    self.PickerLayer.ZIndex             = 60

    -- Main window ---------------------------------------------------------------
    self.Main = Instance.new("Frame", self.ScreenGui)
    self.Main.Name            = "Main"
    self.Main.Size            = UDim2.new(0, 660, 0, 480)
    self.Main.Position        = UDim2.new(0.5, -330, 0.5, -240)
    self.Main.BackgroundColor3 = Theme.Bg
    self.Main.BorderSizePixel = 0
    self.Main.ZIndex          = 1
    Corner(self.Main, 8)
    Stroke(self.Main, Theme.Outline)

    -- Sidebar -------------------------------------------------------------------
    self.Sidebar = Instance.new("Frame", self.Main)
    self.Sidebar.Size             = UDim2.new(0, 158, 1, 0)
    self.Sidebar.BackgroundColor3 = Theme.Sidebar
    self.Sidebar.BorderSizePixel  = 0
    Corner(self.Sidebar, 8)

    -- 1-px right divider (rounded corners eat the outline, so we fake it)
    local SideDiv = Instance.new("Frame", self.Sidebar)
    SideDiv.Size = UDim2.new(0, 1, 1, 0); SideDiv.Position = UDim2.new(1, -1, 0, 0)
    SideDiv.BackgroundColor3 = Theme.Outline; SideDiv.BorderSizePixel = 0

    -- Title label
    local TitleLbl = Instance.new("TextLabel", self.Sidebar)
    TitleLbl.Text            = title:upper()
    TitleLbl.Font            = Enum.Font.GothamBold
    TitleLbl.TextSize        = 15
    TitleLbl.TextColor3      = Theme.Text
    TitleLbl.Position        = UDim2.new(0, 14, 0, 14)
    TitleLbl.Size            = UDim2.new(1, -28, 0, 22)
    TitleLbl.TextXAlignment  = Enum.TextXAlignment.Left
    TitleLbl.BackgroundTransparency = 1

    -- Accent underline beneath title
    local TitleLine = Instance.new("Frame", self.Sidebar)
    TitleLine.Size = UDim2.new(1, -28, 0, 1); TitleLine.Position = UDim2.new(0, 14, 0, 40)
    TitleLine.BackgroundColor3 = Theme.Outline; TitleLine.BorderSizePixel = 0
    local AccentPip = Instance.new("Frame", TitleLine)
    AccentPip.Size = UDim2.new(0, 20, 1, 0)
    AccentPip.BackgroundColor3 = Theme.Accent; AccentPip.BorderSizePixel = 0

    -- Tab button scroll frame
    self.TabHolder = Instance.new("ScrollingFrame", self.Sidebar)
    self.TabHolder.Size               = UDim2.new(1, 0, 1, -52)
    self.TabHolder.Position           = UDim2.new(0, 0, 0, 52)
    self.TabHolder.BackgroundTransparency = 1
    self.TabHolder.ScrollBarThickness = 0
    self.TabHolder.CanvasSize         = UDim2.new(0, 0, 0, 0)
    self.TabHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local THL = Instance.new("UIListLayout", self.TabHolder)
    THL.Padding = UDim.new(0, 0); THL.SortOrder = Enum.SortOrder.LayoutOrder

    -- State
    self.Tabs             = {}
    self._activeDropdown  = nil   -- at most one dropdown open at a time

    -- Global click-outside: close any open dropdown
    UIS.InputBegan:Connect(function(inp, gpe)
        if gpe then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            if self._activeDropdown then
                self._activeDropdown:_close()
                self._activeDropdown = nil
            end
        end
    end)

    return self
end

-- ─────────────────────────────────────────────────────────────────────────────
--  TAB
-- ─────────────────────────────────────────────────────────────────────────────
local Tab = {}
Tab.__index = Tab

--[[
    Library:CreateTab(name [, iconId])
    iconId – numeric asset id  OR  full "rbxassetid://..." string
]]
function Library:CreateTab(name, iconId)
    local t = setmetatable({ _library = self }, Tab)

    -- Sidebar button ------------------------------------------------------------
    t.Button = Instance.new("TextButton", self.TabHolder)
    t.Button.Size                  = UDim2.new(1, 0, 0, 36)
    t.Button.BackgroundTransparency = 1
    t.Button.Text                  = ""
    t.Button.AutoButtonColor       = false

    -- Hover background (low-alpha accent tint)
    local HoverBg = Instance.new("Frame", t.Button)
    HoverBg.Size = UDim2.new(1, -8, 1, -4); HoverBg.Position = UDim2.new(0, 4, 0, 2)
    HoverBg.BackgroundColor3 = Theme.Accent; HoverBg.BackgroundTransparency = 1
    HoverBg.BorderSizePixel = 0; Corner(HoverBg, 5)
    t._hoverBg = HoverBg

    -- Left accent bar (visible when tab is active)
    local ABar = Instance.new("Frame", t.Button)
    ABar.Size = UDim2.new(0, 2, 0.55, 0); ABar.Position = UDim2.new(0, 4, 0.225, 0)
    ABar.BackgroundColor3 = Theme.Accent; ABar.BackgroundTransparency = 1
    ABar.BorderSizePixel = 0; Corner(ABar, 2)
    t._abar = ABar

    -- Optional icon
    local xStart = 14
    if iconId then
        local Ico = Instance.new("ImageLabel", t.Button)
        Ico.Size     = UDim2.new(0, 14, 0, 14)
        Ico.Position = UDim2.new(0, 16, 0.5, -7)
        Ico.BackgroundTransparency = 1
        Ico.Image    = type(iconId) == "string" and iconId or ("rbxassetid://" .. tostring(iconId))
        Ico.ImageColor3 = Theme.DarkText
        Ico.ScaleType   = Enum.ScaleType.Fit
        t._icon = Ico
        xStart = 36
    end

    -- Label
    local Lbl = MakeLabel(t.Button, {
        Text     = name,
        Font     = Enum.Font.GothamMedium,
        Size     = 12,
        Color    = Theme.DarkText,
        Pos      = UDim2.new(0, xStart, 0, 0),
        SizeUDim = UDim2.new(1, -(xStart + 8), 1, 0),
    })
    t._lbl = Lbl

    -- Content page (two-column scrollable area) ---------------------------------
    t.Page = Instance.new("ScrollingFrame", self.Main)
    t.Page.Size                  = UDim2.new(1, -172, 1, -16)
    t.Page.Position              = UDim2.new(0, 164, 0, 8)
    t.Page.Visible               = false
    t.Page.BackgroundTransparency = 1
    t.Page.ScrollBarThickness    = 2
    t.Page.ScrollBarImageColor3  = Theme.Accent
    t.Page.CanvasSize            = UDim2.new(0, 0, 0, 0)
    t.Page.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    t.Page.BorderSizePixel       = 0

    local PP = Instance.new("UIPadding", t.Page)
    PP.PaddingTop = UDim.new(0, 6); PP.PaddingBottom = UDim.new(0, 6)

    -- Two-column holder
    local ColsHolder = Instance.new("Frame", t.Page)
    ColsHolder.Size = UDim2.new(1, 0, 0, 0)
    ColsHolder.AutomaticSize = Enum.AutomaticSize.Y
    ColsHolder.BackgroundTransparency = 1
    local CHL = Instance.new("UIListLayout", ColsHolder)
    CHL.FillDirection  = Enum.FillDirection.Horizontal
    CHL.Padding        = UDim.new(0, 8)
    CHL.SortOrder      = Enum.SortOrder.LayoutOrder
    CHL.VerticalAlignment = Enum.VerticalAlignment.Top

    t._cols   = {}
    t._colIdx = 0
    for i = 1, 2 do
        local Col = Instance.new("Frame", ColsHolder)
        Col.Size = UDim2.new(0.5, -4, 0, 0)
        Col.AutomaticSize = Enum.AutomaticSize.Y
        Col.BackgroundTransparency = 1
        local CL = Instance.new("UIListLayout", Col)
        CL.Padding = UDim.new(0, 8); CL.SortOrder = Enum.SortOrder.LayoutOrder
        t._cols[i] = Col
    end

    -- Active / inactive visuals
    function t:_setActive(on)
        Tween(self._lbl,    { TextColor3          = on and Theme.Text  or Theme.DarkText }, 0.14)
        Tween(self._abar,   { BackgroundTransparency = on and 0 or 1 }, 0.14)
        Tween(self._hoverBg,{ BackgroundTransparency = on and 0.9 or 1 }, 0.14)
        if self._icon then
            Tween(self._icon, { ImageColor3 = on and Theme.Accent or Theme.DarkText }, 0.14)
        end
    end

    t.Button.MouseEnter:Connect(function()
        if not t.Page.Visible then Tween(t._hoverBg, { BackgroundTransparency = 0.94 }, 0.08) end
    end)
    t.Button.MouseLeave:Connect(function()
        if not t.Page.Visible then Tween(t._hoverBg, { BackgroundTransparency = 1 }, 0.08) end
    end)
    t.Button.MouseButton1Click:Connect(function()
        for _, tab in ipairs(self.Tabs) do
            tab.Page.Visible = false; tab:_setActive(false)
        end
        t.Page.Visible = true; t:_setActive(true)
    end)

    table.insert(self.Tabs, t)
    if #self.Tabs == 1 then t.Page.Visible = true; t:_setActive(true) end

    return t
end

-- ─────────────────────────────────────────────────────────────────────────────
--  CATEGORY
-- ─────────────────────────────────────────────────────────────────────────────
local Category = {}
Category.__index = Category

function Tab:CreateCategory(name)
    local c = setmetatable({ _library = self._library }, Category)

    -- Alternate columns  (1 → left, 2 → right, 3 → left, …)
    self._colIdx = self._colIdx + 1
    local col = self._cols[((self._colIdx - 1) % 2) + 1]

    -- Box
    c.Box = Instance.new("Frame", col)
    c.Box.Size = UDim2.new(1, 0, 0, 0)
    c.Box.AutomaticSize = Enum.AutomaticSize.Y
    c.Box.BackgroundColor3 = Theme.SectionBg
    c.Box.BorderSizePixel  = 0
    Corner(c.Box, 5)
    Stroke(c.Box, Theme.Outline)

    -- Header badge (floats on the top border line)
    local Badge = Instance.new("Frame", c.Box)
    Badge.AutomaticSize = Enum.AutomaticSize.X
    Badge.Size     = UDim2.new(0, 0, 0, 14)
    Badge.Position = UDim2.new(0, 8, 0, -7)
    Badge.BackgroundColor3 = Theme.SectionBg; Badge.BorderSizePixel = 0
    Corner(Badge, 3); Stroke(Badge, Theme.Outline)
    local BP = Instance.new("UIPadding", Badge)
    BP.PaddingLeft = UDim.new(0,6); BP.PaddingRight = UDim.new(0,6)
    MakeLabel(Badge, {
        Text  = name:upper(),
        Font  = Enum.Font.GothamBold,
        Size  = 9,
        Color = Theme.Accent,
        Align = Enum.TextXAlignment.Center,
    })

    -- Inner container
    c.Container = Instance.new("Frame", c.Box)
    c.Container.Size = UDim2.new(1, -14, 0, 0)
    c.Container.AutomaticSize = Enum.AutomaticSize.Y
    c.Container.Position = UDim2.new(0, 7, 0, 12)
    c.Container.BackgroundTransparency = 1
    local CP = Instance.new("UIPadding", c.Container)
    CP.PaddingBottom = UDim.new(0, 8)
    local CL = Instance.new("UIListLayout", c.Container)
    CL.Padding = UDim.new(0, 2); CL.SortOrder = Enum.SortOrder.LayoutOrder

    return c
end

-- ─────────────────────────────────────────────────────────────────────────────
--  TOGGLE   (original, upgraded with pill knob + bind support)
-- ─────────────────────────────────────────────────────────────────────────────
local Toggle = {}
Toggle.__index = Toggle

function Category:CreateToggle(text, default, callback)
    local tg = setmetatable({}, Toggle)
    tg.Value    = default == true
    tg.Callback = callback or function() end
    tg.Binding  = false
    tg.BindKey  = nil
    tg.BindMode = "Toggle"   -- "Toggle" | "Hold"

    local F = Instance.new("TextButton", self.Container)
    F.Size = UDim2.new(1, 0, 0, 26); F.BackgroundTransparency = 1
    F.Text = ""; F.AutoButtonColor = false
    tg.Frame = F

    local Lbl = MakeLabel(F, {
        Text     = text, Font = Enum.Font.Gotham, Size = 12,
        Color    = tg.Value and Theme.Text or Theme.DarkText,
        Pos      = UDim2.new(0, 4, 0, 0),
        SizeUDim = UDim2.new(1, -76, 1, 0),
    })

    -- Pill toggle
    local Pill = Instance.new("Frame", F)
    Pill.Size = UDim2.new(0, 28, 0, 13); Pill.Position = UDim2.new(1, -34, 0.5, -6)
    Pill.BackgroundColor3 = tg.Value and Theme.Accent or Color3.fromRGB(35,35,35)
    Pill.BorderSizePixel = 0; Corner(Pill, 10); Stroke(Pill, Theme.Outline)

    local Knob = Instance.new("Frame", Pill)
    Knob.Size = UDim2.new(0, 9, 0, 9)
    Knob.BackgroundColor3 = Theme.Text; Knob.BorderSizePixel = 0; Corner(Knob, 10)
    Knob.Position = tg.Value and UDim2.new(1,-11,0.5,-4) or UDim2.new(0,2,0.5,-4)

    -- Keybind label
    local BLbl = MakeLabel(F, {
        Text = "", Font = Enum.Font.GothamBold, Size = 9, Color = Theme.Accent,
        Align    = Enum.TextXAlignment.Right,
        Pos      = UDim2.new(1, -70, 0, 0),
        SizeUDim = UDim2.new(0, 34, 1, 0),
    })

    local function Fire(forced)
        tg.Value = (forced ~= nil) and (forced == true) or (not tg.Value)
        Tween(Lbl,  { TextColor3 = tg.Value and Theme.Text or Theme.DarkText }, 0.10)
        Tween(Pill, { BackgroundColor3 = tg.Value and Theme.Accent or Color3.fromRGB(35,35,35) }, 0.12)
        Tween(Knob, {
            Position = tg.Value and UDim2.new(1,-11,0.5,-4) or UDim2.new(0,2,0.5,-4)
        }, 0.12)
        tg.Callback(tg.Value)
    end

    F.MouseButton1Click:Connect(function() Fire() end)
    F.MouseButton2Click:Connect(function() tg.Binding = true; BLbl.Text = "[?]" end)

    UIS.InputBegan:Connect(function(inp, gpe)
        if gpe then return end
        if tg.Binding and inp.UserInputType == Enum.UserInputType.Keyboard then
            tg.BindKey = inp.KeyCode; tg.Binding = false
            local n = inp.KeyCode.Name; BLbl.Text = "[" .. n:sub(1, math.min(#n,4)):upper() .. "]"
        elseif tg.BindKey and inp.KeyCode == tg.BindKey then
            if     tg.BindMode == "Toggle" then Fire()
            elseif tg.BindMode == "Hold"   then Fire(true) end
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if tg.BindKey and inp.KeyCode == tg.BindKey and tg.BindMode == "Hold" then Fire(false) end
    end)

    function tg:Set(v) Fire(v == true)  end
    function tg:Get()  return self.Value end
    return tg
end

-- ─────────────────────────────────────────────────────────────────────────────
--  SLIDER
-- ─────────────────────────────────────────────────────────────────────────────
--[[
    Category:CreateSlider(text, min, max, default, callback)
    • Smooth TweenService fill & knob
    • Global UIS.InputEnded so the knob never sticks when mouse leaves window
    • Integer rounding when both bounds are integers
    • Knob grows slightly on drag for tactile feedback
]]
local Slider = {}
Slider.__index = Slider

function Category:CreateSlider(text, min, max, default, callback)
    local sl = setmetatable({}, Slider)
    sl.Min      = min  or 0
    sl.Max      = max  or 100
    sl.Value    = math.clamp(default or min or 0, sl.Min, sl.Max)
    sl.Callback = callback or function() end
    sl.Dragging = false

    local F = Instance.new("Frame", self.Container)
    F.Size = UDim2.new(1, 0, 0, 40); F.BackgroundTransparency = 1
    sl.Frame = F

    -- Header row: label (left) + value (right)
    MakeLabel(F, {
        Text     = text,
        Pos      = UDim2.new(0, 4, 0, 2),
        SizeUDim = UDim2.new(0.7, 0, 0, 14),
    })
    local VLbl = MakeLabel(F, {
        Text     = tostring(math.floor(sl.Value + 0.5)),
        Font     = Enum.Font.GothamBold,
        Color    = Theme.Accent,
        Align    = Enum.TextXAlignment.Right,
        Pos      = UDim2.new(1, -52, 0, 2),
        SizeUDim = UDim2.new(0, 50, 0, 14),
    })

    -- Track
    local Track = Instance.new("Frame", F)
    Track.Size = UDim2.new(1, -8, 0, 4); Track.Position = UDim2.new(0, 4, 0, 27)
    Track.BackgroundColor3 = Color3.fromRGB(28,28,28); Track.BorderSizePixel = 0
    Corner(Track, 3); Stroke(Track, Theme.Outline)

    -- Fill
    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new(0, 0, 1, 0); Fill.BackgroundColor3 = Theme.Accent
    Fill.BorderSizePixel = 0; Corner(Fill, 3)

    -- Knob
    local Knob = Instance.new("Frame", Track)
    Knob.Size = UDim2.new(0, 10, 0, 10); Knob.Position = UDim2.new(0, -5, 0.5, -5)
    Knob.BackgroundColor3 = Theme.Text; Knob.BorderSizePixel = 0
    Corner(Knob, 10); Stroke(Knob, Theme.Accent)

    -- ── Helpers ──────────────────────────────────────────────────────────────
    local function Pct()
        return (sl.Value - sl.Min) / (sl.Max - sl.Min)
    end

    local function RefreshVisual(instant)
        local p = Pct()
        VLbl.Text = tostring(math.floor(sl.Value + 0.5))
        if instant then
            Fill.Size      = UDim2.new(p, 0, 1, 0)
            Knob.Position  = UDim2.new(p, -5, 0.5, -5)
        else
            Tween(Fill, { Size     = UDim2.new(p, 0, 1, 0)   }, 0.06)
            Tween(Knob, { Position = UDim2.new(p, -5, 0.5, -5)}, 0.06)
        end
    end

    -- Compute value from absolute mouse X, update state, fire callback
    local function FromMouseX(mx)
        local ax, aw = Track.AbsolutePosition.X, Track.AbsoluteSize.X
        if aw == 0 then return end
        local p   = math.clamp((mx - ax) / aw, 0, 1)
        local raw = sl.Min + (sl.Max - sl.Min) * p
        -- Integer rounding when both bounds have no fractional part
        if sl.Min % 1 == 0 and sl.Max % 1 == 0 then
            raw = math.floor(raw + 0.5)
        end
        sl.Value = raw
        RefreshVisual(true)
        sl.Callback(sl.Value)
    end

    -- ── Input ─────────────────────────────────────────────────────────────────
    Track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            sl.Dragging = true
            -- Knob grows to give tactile feel
            Tween(Knob, { Size = UDim2.new(0,12,0,12), Position = UDim2.new(Pct(),-6,0.5,-6) }, 0.10)
            FromMouseX(inp.Position.X)
        end
    end)

    -- Global move: fires even when mouse leaves the track frame
    UIS.InputChanged:Connect(function(inp)
        if sl.Dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            FromMouseX(inp.Position.X)
        end
    end)

    -- Global release: prevents knob sticking
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 and sl.Dragging then
            sl.Dragging = false
            Tween(Knob, { Size = UDim2.new(0,10,0,10), Position = UDim2.new(Pct(),-5,0.5,-5) }, 0.10)
        end
    end)

    RefreshVisual(true)

    function sl:Set(v)
        self.Value = math.clamp(v, self.Min, self.Max)
        RefreshVisual()
        self.Callback(self.Value)
    end
    function sl:Get() return self.Value end
    return sl
end

-- ─────────────────────────────────────────────────────────────────────────────
--  DROPDOWN
-- ─────────────────────────────────────────────────────────────────────────────
--[[
    Category:CreateDropdown(text, options, default, callback)

    Z-Index solution:
    • The list Frame is parented to Library.DropdownLayer, NOT inside the
      Category or Page (which have ClipsDescendants).
    • On open, list position is computed from the button's AbsolutePosition so
      it appears directly below (or above if there isn't enough space below).
    • Animated open/close via ClipsDescendants + Tween on Size.
    • Arrow chevron rotates 180° when open.
    • At most one dropdown is open at a time; opening a second closes the first.
]]
local Dropdown = {}
Dropdown.__index = Dropdown

function Category:CreateDropdown(text, options, default, callback)
    local dd = setmetatable({ _library = self._library }, Dropdown)
    dd.Options  = options or {}
    dd.Value    = default or (options and options[1])
    dd.Callback = callback or function() end
    dd.Open     = false

    local ITEM_H = 24

    local F = Instance.new("Frame", self.Container)
    F.Size = UDim2.new(1, 0, 0, 44); F.BackgroundTransparency = 1
    dd.Frame = F

    -- Label above button
    MakeLabel(F, {
        Text = text, Pos = UDim2.new(0,4,0,2), SizeUDim = UDim2.new(1,-8,0,14),
    })

    -- Select button
    local Btn = Instance.new("TextButton", F)
    Btn.Size = UDim2.new(1,-8,0,22); Btn.Position = UDim2.new(0,4,0,18)
    Btn.BackgroundColor3 = Theme.Input; Btn.BorderSizePixel = 0
    Btn.Text = ""; Btn.AutoButtonColor = false
    Corner(Btn, 4); local BtnStk = Stroke(Btn, Theme.Outline)

    local SelLbl = MakeLabel(Btn, {
        Text     = tostring(dd.Value or "Select…"),
        Color    = Theme.Text,
        Pos      = UDim2.new(0,8,0,0),
        SizeUDim = UDim2.new(1,-28,1,0),
    })
    dd._selLbl = SelLbl

    -- Chevron icon
    local Chev = MakeLabel(Btn, {
        Text     = "▾",
        Font     = Enum.Font.GothamBold,
        Size     = 14,
        Color    = Theme.DarkText,
        Align    = Enum.TextXAlignment.Center,
        Pos      = UDim2.new(1,-20,0,0),
        SizeUDim = UDim2.new(0,18,1,0),
    })
    dd._chev = Chev

    -- ── List (lives in DropdownLayer, NOT in category/page) ──────────────────
    local List = Instance.new("Frame", self._library.DropdownLayer)
    List.BackgroundColor3 = Color3.fromRGB(17,17,17); List.BorderSizePixel = 0
    List.Visible = false; List.ClipsDescendants = true; List.ZIndex = 55
    Corner(List, 5); Stroke(List, Theme.Outline)
    dd._list = List

    local LL = Instance.new("UIListLayout", List)
    LL.SortOrder = Enum.SortOrder.LayoutOrder; LL.Padding = UDim.new(0,0)

    -- Populate option rows
    for _, opt in ipairs(dd.Options) do
        local isActive = (opt == dd.Value)
        local IBtn = Instance.new("TextButton", List)
        IBtn.Size = UDim2.new(1,0,0,ITEM_H); IBtn.BackgroundColor3 = Theme.Accent
        IBtn.BackgroundTransparency = 1; IBtn.Text = ""; IBtn.AutoButtonColor = false
        IBtn.ZIndex = 56

        local ILbl = MakeLabel(IBtn, {
            Text     = tostring(opt),
            Color    = isActive and Theme.Text or Theme.DarkText,
            Pos      = UDim2.new(0,10,0,0),
            SizeUDim = UDim2.new(1,-20,1,0),
            ZIndex   = 57,
        })

        if isActive then
            local Dot = Instance.new("Frame", IBtn)
            Dot.Size = UDim2.new(0,4,0,4); Dot.Position = UDim2.new(1,-10,0.5,-2)
            Dot.BackgroundColor3 = Theme.Accent; Dot.BorderSizePixel = 0
            Corner(Dot,10); Dot.ZIndex = 57
        end

        IBtn.MouseEnter:Connect(function() Tween(IBtn,{BackgroundTransparency=0.87},0.07) end)
        IBtn.MouseLeave:Connect(function() Tween(IBtn,{BackgroundTransparency=1},0.07) end)

        IBtn.MouseButton1Click:Connect(function()
            dd.Value = opt
            SelLbl.Text = tostring(opt)
            -- Refresh active colour in list labels
            for _, ch in ipairs(List:GetChildren()) do
                if ch:IsA("TextButton") then
                    local l = ch:FindFirstChildOfClass("TextLabel")
                    if l then l.TextColor3 = (l.Text == tostring(dd.Value)) and Theme.Text or Theme.DarkText end
                end
            end
            dd.Callback(dd.Value)
            dd:_close()
            self._library._activeDropdown = nil
        end)
    end

    -- ── Open / Close ─────────────────────────────────────────────────────────
    local totalH = #dd.Options * ITEM_H

    function dd:_open()
        local abs = Btn.AbsolutePosition; local sz = Btn.AbsoluteSize
        local scrH = self._library.ScreenGui.AbsoluteSize.Y
        local openDown = (scrH - (abs.Y + sz.Y)) >= totalH + 6
        local listY = openDown and (abs.Y + sz.Y + 3) or (abs.Y - totalH - 3)

        self._list.Position = UDim2.new(0, abs.X,  0, listY)
        self._list.Size     = UDim2.new(0, sz.X,   0, 0)
        self._list.Visible  = true
        Tween(self._list, { Size = UDim2.new(0, sz.X, 0, totalH) }, 0.14)
        Tween(self._chev, { Rotation = 180 }, 0.14)
        Tween(BtnStk, { Color = Theme.Accent }, 0.12)
        self.Open = true
    end

    function dd:_close()
        local w = self._list.AbsoluteSize.X
        Tween(self._list, { Size = UDim2.new(0, w, 0, 0) }, 0.11)
        Tween(self._chev, { Rotation = 0 }, 0.11)
        Tween(BtnStk, { Color = Theme.Outline }, 0.11)
        task.delay(0.12, function() if not self.Open then self._list.Visible = false end end)
        self.Open = false
    end

    Btn.MouseButton1Click:Connect(function()
        if dd.Open then
            dd:_close(); self._library._activeDropdown = nil
        else
            if self._library._activeDropdown then self._library._activeDropdown:_close() end
            self._library._activeDropdown = dd
            dd:_open()
        end
    end)

    function dd:Set(v)
        self.Value = v; SelLbl.Text = tostring(v); self.Callback(v)
    end
    function dd:Get() return self.Value end
    return dd
end

-- ─────────────────────────────────────────────────────────────────────────────
--  COLOR PICKER
-- ─────────────────────────────────────────────────────────────────────────────
--[[
    Category:CreateColorPicker(text, default, callback)

    Panel layout (190×210 px):
    ┌────────────────────────┐
    │  SV canvas  (174×120)  │   ← drag to set Saturation(X) & Value(1-Y)
    │  Hue track  (174×10)   │   ← drag to set Hue
    │  Hex textbox (174×22)  │   ← type "#RRGGBB" to set colour
    └────────────────────────┘

    HSV math:
      S = cursor.X / canvas.Width
      V = 1 – cursor.Y / canvas.Height
      H = cursor.X / hueTrack.Width

    Two UIGradient layers simulate the SV canvas:
      1. White→transparent (horizontal) = adds white at left
      2. Black→transparent (vertical, inverted) = adds black at bottom
    Their parent's BackgroundColor3 is set to Color3.fromHSV(H,1,1).
]]
local ColorPicker = {}
ColorPicker.__index = ColorPicker

function Category:CreateColorPicker(text, default, callback)
    local cp = setmetatable({ _library = self._library }, ColorPicker)
    cp.Callback = callback or function() end
    local startCol = default or Color3.fromRGB(255, 60, 60)
    cp.H, cp.S, cp.V = Color3.toHSV(startCol)
    cp._open = false

    -- Row frame (sits inside category container)
    local F = Instance.new("Frame", self.Container)
    F.Size = UDim2.new(1,0,0,26); F.BackgroundTransparency = 1
    cp.Frame = F

    MakeLabel(F, { Text = text, Pos = UDim2.new(0,4,0,0), SizeUDim = UDim2.new(1,-38,1,0) })

    -- Colour swatch button
    local Swatch = Instance.new("TextButton", F)
    Swatch.Size = UDim2.new(0,26,0,14); Swatch.Position = UDim2.new(1,-30,0.5,-7)
    Swatch.BackgroundColor3 = startCol; Swatch.BorderSizePixel = 0
    Swatch.Text = ""; Swatch.AutoButtonColor = false
    Corner(Swatch,3); Stroke(Swatch, Theme.Outline)
    cp._swatch = Swatch

    -- ── Floating panel (parented to PickerLayer, above everything) ────────────
    local PAD = 8
    local SVW, SVH = 174, 120

    local Panel = Instance.new("Frame", self._library.PickerLayer)
    Panel.Name = "CPPanel"; Panel.Size = UDim2.new(0,190,0,212)
    Panel.BackgroundColor3 = Color3.fromRGB(14,14,14); Panel.BorderSizePixel = 0
    Panel.Visible = false; Panel.ZIndex = 65
    Corner(Panel,6); Stroke(Panel, Theme.Outline)
    cp._panel = Panel

    -- SV canvas base (hue colour; two gradient overlays mimic the SV map)
    local SVBase = Instance.new("Frame", Panel)
    SVBase.Size = UDim2.new(0,SVW,0,SVH); SVBase.Position = UDim2.new(0,PAD,0,PAD)
    SVBase.BackgroundColor3 = Color3.fromHSV(cp.H,1,1); SVBase.BorderSizePixel = 0
    SVBase.ZIndex = 66; Corner(SVBase,4)
    cp._svBase = SVBase

    -- Overlay 1: white-to-transparent (left→right)
    local WF = Instance.new("Frame", SVBase)
    WF.Size = UDim2.fromScale(1,1); WF.BackgroundColor3 = Color3.new(1,1,1)
    WF.BorderSizePixel = 0; WF.ZIndex = 67; Corner(WF,4)
    local WG = Instance.new("UIGradient", WF)
    WG.Color = ColorSequence.new(Color3.new(1,1,1),Color3.new(1,1,1))
    WG.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    WG.Rotation = 0   -- left opaque → right transparent

    -- Overlay 2: transparent-to-black (top→bottom)
    local BF = Instance.new("Frame", SVBase)
    BF.Size = UDim2.fromScale(1,1); BF.BackgroundColor3 = Color3.new(0,0,0)
    BF.BorderSizePixel = 0; BF.ZIndex = 68; Corner(BF,4)
    local BG = Instance.new("UIGradient", BF)
    BG.Color = ColorSequence.new(Color3.new(0,0,0),Color3.new(0,0,0))
    BG.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),   -- top: transparent
        NumberSequenceKeypoint.new(1, 0),   -- bottom: fully black
    })
    BG.Rotation = 90

    -- SV crosshair cursor
    local SVCur = Instance.new("Frame", SVBase)
    SVCur.Size = UDim2.new(0,8,0,8); SVCur.BackgroundColor3 = Color3.new(1,1,1)
    SVCur.BorderSizePixel = 0; SVCur.ZIndex = 72; Corner(SVCur,10); Stroke(SVCur, Color3.new(0,0,0))
    cp._svCursor = SVCur

    -- Invisible click target layered on top of SV canvas
    local SVHit = Instance.new("TextButton", SVBase)
    SVHit.Size = UDim2.fromScale(1,1); SVHit.BackgroundTransparency = 1
    SVHit.Text = ""; SVHit.ZIndex = 73; SVHit.AutoButtonColor = false

    -- Hue track
    local HueTrack = Instance.new("Frame", Panel)
    HueTrack.Size = UDim2.new(0,SVW,0,10)
    HueTrack.Position = UDim2.new(0,PAD,0,PAD+SVH+8)
    HueTrack.BackgroundColor3 = Color3.new(1,1,1); HueTrack.BorderSizePixel = 0
    HueTrack.ZIndex = 66; Corner(HueTrack,3); Stroke(HueTrack, Theme.Outline)
    cp._hueTrack = HueTrack

    -- Rainbow gradient on hue track
    local HGrad = Instance.new("UIGradient", HueTrack)
    HGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0/6, Color3.fromHSV(0/6,1,1)),
        ColorSequenceKeypoint.new(1/6, Color3.fromHSV(1/6,1,1)),
        ColorSequenceKeypoint.new(2/6, Color3.fromHSV(2/6,1,1)),
        ColorSequenceKeypoint.new(3/6, Color3.fromHSV(3/6,1,1)),
        ColorSequenceKeypoint.new(4/6, Color3.fromHSV(4/6,1,1)),
        ColorSequenceKeypoint.new(5/6, Color3.fromHSV(5/6,1,1)),
        ColorSequenceKeypoint.new(1,   Color3.fromHSV(1,  1,1)),
    })

    -- Hue cursor
    local HueCur = Instance.new("Frame", HueTrack)
    HueCur.Size = UDim2.new(0,6,0,16); HueCur.BackgroundColor3 = Color3.new(1,1,1)
    HueCur.BorderSizePixel = 0; HueCur.ZIndex = 67; Corner(HueCur,2); Stroke(HueCur, Color3.new(0,0,0))
    cp._hueCursor = HueCur

    local HueHit = Instance.new("TextButton", HueTrack)
    HueHit.Size = UDim2.fromScale(1,1); HueHit.BackgroundTransparency = 1
    HueHit.Text = ""; HueHit.ZIndex = 68; HueHit.AutoButtonColor = false

    -- Hex input
    local HexBox = Instance.new("TextBox", Panel)
    HexBox.Size = UDim2.new(0,SVW,0,22)
    HexBox.Position = UDim2.new(0,PAD,0,PAD+SVH+8+10+8)
    HexBox.BackgroundColor3 = Theme.Input; HexBox.BorderSizePixel = 0
    HexBox.Font = Enum.Font.GothamMedium; HexBox.TextSize = 11
    HexBox.TextColor3 = Theme.Text; HexBox.PlaceholderText = "#FF3C3C"
    HexBox.PlaceholderColor3 = Theme.DarkText; HexBox.ClearTextOnFocus = false
    HexBox.ZIndex = 66; Corner(HexBox,4)
    local HexStk = Stroke(HexBox, Theme.Outline)
    cp._hex = HexBox

    -- ── Forward-declare updateAll so event closures can reference it ──────────
    local updateAll

    -- Hex focus glow
    HexBox.Focused:Connect(function()  Tween(HexStk,{Color=Theme.Accent},0.12) end)
    HexBox.FocusLost:Connect(function()
        Tween(HexStk,{Color=Theme.Outline},0.12)
        local t2 = HexBox.Text:gsub("#",""):upper()
        if #t2 == 6 then
            local r = tonumber(t2:sub(1,2),16)
            local g = tonumber(t2:sub(3,4),16)
            local b = tonumber(t2:sub(5,6),16)
            if r and g and b then
                cp.H, cp.S, cp.V = Color3.toHSV(Color3.fromRGB(r,g,b))
                updateAll()     -- resolved at call time (after assignment below)
            end
        end
    end)

    -- ── Dragging state ────────────────────────────────────────────────────────
    local dragSV, dragH = false, false

    SVHit.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragSV = true
            local ax,ay = SVBase.AbsolutePosition.X, SVBase.AbsolutePosition.Y
            local aw,ah = SVBase.AbsoluteSize.X, SVBase.AbsoluteSize.Y
            cp.S = math.clamp((inp.Position.X-ax)/aw, 0, 1)
            cp.V = math.clamp(1-(inp.Position.Y-ay)/ah, 0, 1)
            updateAll()
        end
    end)
    HueHit.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragH = true
            local ax,aw = HueTrack.AbsolutePosition.X, HueTrack.AbsoluteSize.X
            cp.H = math.clamp((inp.Position.X-ax)/aw, 0, 1)
            updateAll()
        end
    end)

    -- Global move & release (prevents sticking)
    UIS.InputChanged:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        if dragSV then
            local ax,ay = SVBase.AbsolutePosition.X, SVBase.AbsolutePosition.Y
            local aw,ah = SVBase.AbsoluteSize.X, SVBase.AbsoluteSize.Y
            cp.S = math.clamp((inp.Position.X-ax)/aw, 0, 1)
            cp.V = math.clamp(1-(inp.Position.Y-ay)/ah, 0, 1)
            updateAll()
        end
        if dragH then
            local ax,aw = HueTrack.AbsolutePosition.X, HueTrack.AbsoluteSize.X
            cp.H = math.clamp((inp.Position.X-ax)/aw, 0, 1)
            updateAll()
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragSV=false; dragH=false end
    end)

    -- ── updateAll definition (after all UI exists) ────────────────────────────
    updateAll = function()
        local col = Color3.fromHSV(cp.H, cp.S, cp.V)
        -- Swatch preview
        Swatch.BackgroundColor3 = col
        -- SV canvas base hue
        SVBase.BackgroundColor3 = Color3.fromHSV(cp.H, 1, 1)
        -- SV cursor: S → X axis,  (1–V) → Y axis
        SVCur.Position = UDim2.new(cp.S, -4, 1 - cp.V, -4)
        -- Hue cursor
        HueCur.Position = UDim2.new(cp.H, -3, 0.5, -8)
        -- Hex display
        local r = math.floor(col.R*255+0.5)
        local g = math.floor(col.G*255+0.5)
        local b = math.floor(col.B*255+0.5)
        HexBox.Text = string.format("#%02X%02X%02X", r, g, b)
        cp.Callback(col)
    end

    -- ── Toggle panel on swatch click ──────────────────────────────────────────
    Swatch.MouseButton1Click:Connect(function()
        if cp._open then
            Panel.Visible = false; cp._open = false
        else
            local abs  = Swatch.AbsolutePosition; local sz = Swatch.AbsoluteSize
            local scrW = cp._library.ScreenGui.AbsoluteSize.X
            local scrH = cp._library.ScreenGui.AbsoluteSize.Y
            -- Smart positioning: avoid clipping at screen edges
            local px = math.clamp(abs.X - 190 + sz.X, 4, scrW - 194)
            local py = abs.Y + sz.Y + 4
            if py + 214 > scrH then py = abs.Y - 216 end
            Panel.Position = UDim2.new(0, px, 0, py)
            Panel.Visible  = true; cp._open = true
            updateAll()
        end
    end)

    updateAll()   -- initial sync

    function cp:Set(color)
        self.H, self.S, self.V = Color3.toHSV(color)
        updateAll()
    end
    function cp:Get()
        return Color3.fromHSV(cp.H, cp.S, cp.V)
    end
    return cp
end

-- ─────────────────────────────────────────────────────────────────────────────
--  TEXTBOX
-- ─────────────────────────────────────────────────────────────────────────────
--[[
    Category:CreateTextbox(text, placeholder, callback)
    • UIStroke glows Accent colour on focus, returns to Outline on blur
    • callback(value: string, enterPressed: boolean)
]]
local Textbox = {}
Textbox.__index = Textbox

function Category:CreateTextbox(text, placeholder, callback)
    local tb = setmetatable({}, Textbox)
    tb.Value    = ""
    tb.Callback = callback or function() end

    local F = Instance.new("Frame", self.Container)
    F.Size = UDim2.new(1,0,0,44); F.BackgroundTransparency = 1
    tb.Frame = F

    MakeLabel(F, { Text = text, Pos = UDim2.new(0,4,0,2), SizeUDim = UDim2.new(1,-8,0,14) })

    -- Input container (the visible box)
    local Container = Instance.new("Frame", F)
    Container.Size = UDim2.new(1,-8,0,22); Container.Position = UDim2.new(0,4,0,18)
    Container.BackgroundColor3 = Theme.Input; Container.BorderSizePixel = 0
    Corner(Container,4)
    local ContStk = Stroke(Container, Theme.Outline)   -- stroke on Container, not Box

    -- Actual TextBox
    local Box = Instance.new("TextBox", Container)
    Box.Size = UDim2.new(1,-16,1,0); Box.Position = UDim2.new(0,8,0,0)
    Box.BackgroundTransparency = 1; Box.Text = ""
    Box.PlaceholderText = placeholder or "Type here…"
    Box.Font = Enum.Font.Gotham; Box.TextSize = 12
    Box.TextColor3 = Theme.Text; Box.PlaceholderColor3 = Theme.DarkText
    Box.TextXAlignment = Enum.TextXAlignment.Left
    Box.ClearTextOnFocus = false

    Box.Focused:Connect(function()
        Tween(ContStk,    { Color = Theme.Accent }, 0.14)
        Tween(Container,  { BackgroundColor3 = Color3.fromRGB(26,26,26) }, 0.14)
    end)
    Box.FocusLost:Connect(function(enterPressed)
        Tween(ContStk,    { Color = Theme.Outline }, 0.14)
        Tween(Container,  { BackgroundColor3 = Theme.Input }, 0.14)
        tb.Value = Box.Text
        tb.Callback(Box.Text, enterPressed)
    end)

    function tb:Set(v)
        self.Value = tostring(v); Box.Text = self.Value
    end
    function tb:Get() return self.Value end
    return tb
end

-- ─────────────────────────────────────────────────────────────────────────────
--  MODULE RETURN
--  loadstring usage:
--
--    local Library = loadstring(game:HttpGet("https://your-url/neverlose_ui_extended.lua"))()
--    local Window  = Library.new("My Script")
--
--    local Tab1    = Window:CreateTab("Combat", 6031094200)
--    local Cat1    = Tab1:CreateCategory("Aimbot")
--    Cat1:CreateToggle("Enabled", false, function(val) print(val) end)
--    Cat1:CreateSlider("FOV", 0, 180, 45, function(val) print(val) end)
-- ─────────────────────────────────────────────────────────────────────────────
return Library
