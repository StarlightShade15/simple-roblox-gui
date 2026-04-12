-- ============================================================
--   Neverlose-Style Premium UI Library (Full Config System)
--   Fixed: syntax errors, PopupContainer nil, memory leaks
--   Added: full config save/load with JSON, flag updater registry
-- ============================================================

local Library = {}
Library.__index = Library

-- Constants
local DEFAULT_CORNER_RADIUS = 6
local DEFAULT_FONT = Enum.Font.GothamMedium
local POPUP_Z_INDEX = 1000
local TOOLTIP_Z_INDEX = 9999
local ANIMATION_TIME = 0.15
local EASING_STYLE = Enum.EasingStyle.Quad
local EASING_DIR = Enum.EasingDirection.Out

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer

-- Utility functions
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

local function tableCopy(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end

local function safePCall(fn, ...)
    local success, result = pcall(fn, ...)
    if not success then
        warn("[UILibrary] Error:", result)
    end
    return success, result
end

local function Tween(obj, props, t, style, dir)
    if not obj or not obj.Parent then return end
    TweenService:Create(obj, TweenInfo.new(t or ANIMATION_TIME, style or EASING_STYLE, dir or EASING_DIR), props):Play()
end

local function Corner(parent, r)
    local cr = Library.RoundedCorners and (r or Library.CornerRadius) or 0
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, cr)
    c.Parent = parent
    return c
end

local function Padding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, top or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft = UDim.new(0, left or 0)
    p.PaddingRight = UDim.new(0, right or 0)
    p.Parent = parent
    return p
end

local function ListLayout(parent, spacing, direction, halign, valign)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, spacing or 4)
    l.FillDirection = direction or Enum.FillDirection.Vertical
    l.SortOrder = Enum.SortOrder.LayoutOrder
    if halign then l.HorizontalAlignment = halign end
    if valign then l.VerticalAlignment = valign end
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
    return New("UIStroke", { Color = color, Thickness = thickness or 1, Parent = parent })
end

-- Themes
Library.Themes = {
    Dark = {
        Background = Color3.fromRGB(15, 15, 21),
        Secondary = Color3.fromRGB(21, 21, 30),
        Tertiary = Color3.fromRGB(28, 28, 40),
        Accent = Color3.fromRGB(99, 80, 220),
        AccentDark = Color3.fromRGB(68, 55, 160),
        AccentGlow = Color3.fromRGB(130, 110, 255),
        Text = Color3.fromRGB(218, 218, 230),
        SubText = Color3.fromRGB(135, 135, 160),
        Outline = Color3.fromRGB(36, 36, 52),
        Element = Color3.fromRGB(24, 24, 34),
        Scrollbar = Color3.fromRGB(50, 50, 75),
    },
    Light = {
        Background = Color3.fromRGB(242, 242, 250),
        Secondary = Color3.fromRGB(228, 228, 240),
        Tertiary = Color3.fromRGB(212, 212, 228),
        Accent = Color3.fromRGB(88, 68, 200),
        AccentDark = Color3.fromRGB(64, 50, 155),
        AccentGlow = Color3.fromRGB(120, 100, 230),
        Text = Color3.fromRGB(22, 22, 35),
        SubText = Color3.fromRGB(90, 90, 115),
        Outline = Color3.fromRGB(195, 195, 215),
        Element = Color3.fromRGB(232, 232, 245),
        Scrollbar = Color3.fromRGB(160, 160, 195),
    },
    Ice = {
        Background = Color3.fromRGB(9, 18, 32),
        Secondary = Color3.fromRGB(13, 25, 44),
        Tertiary = Color3.fromRGB(17, 32, 54),
        Accent = Color3.fromRGB(72, 178, 242),
        AccentDark = Color3.fromRGB(48, 128, 192),
        AccentGlow = Color3.fromRGB(110, 210, 255),
        Text = Color3.fromRGB(195, 225, 248),
        SubText = Color3.fromRGB(110, 160, 205),
        Outline = Color3.fromRGB(22, 44, 72),
        Element = Color3.fromRGB(14, 26, 46),
        Scrollbar = Color3.fromRGB(30, 65, 110),
    },
    Midnight = {
        Background = Color3.fromRGB(7, 7, 14),
        Secondary = Color3.fromRGB(11, 11, 22),
        Tertiary = Color3.fromRGB(15, 15, 30),
        Accent = Color3.fromRGB(158, 76, 245),
        AccentDark = Color3.fromRGB(108, 52, 178),
        AccentGlow = Color3.fromRGB(190, 120, 255),
        Text = Color3.fromRGB(200, 198, 225),
        SubText = Color3.fromRGB(115, 112, 148),
        Outline = Color3.fromRGB(26, 26, 48),
        Element = Color3.fromRGB(13, 13, 25),
        Scrollbar = Color3.fromRGB(45, 40, 85),
    },
    Crimson = {
        Background = Color3.fromRGB(17, 9, 12),
        Secondary = Color3.fromRGB(25, 13, 17),
        Tertiary = Color3.fromRGB(32, 17, 21),
        Accent = Color3.fromRGB(218, 48, 68),
        AccentDark = Color3.fromRGB(162, 34, 50),
        AccentGlow = Color3.fromRGB(255, 90, 110),
        Text = Color3.fromRGB(232, 210, 215),
        SubText = Color3.fromRGB(158, 128, 138),
        Outline = Color3.fromRGB(50, 26, 32),
        Element = Color3.fromRGB(23, 12, 16),
        Scrollbar = Color3.fromRGB(80, 35, 45),
    },
    Emerald = {
        Background = Color3.fromRGB(7, 18, 13),
        Secondary = Color3.fromRGB(11, 26, 19),
        Tertiary = Color3.fromRGB(14, 33, 24),
        Accent = Color3.fromRGB(36, 198, 118),
        AccentDark = Color3.fromRGB(25, 144, 84),
        AccentGlow = Color3.fromRGB(75, 230, 148),
        Text = Color3.fromRGB(198, 232, 215),
        SubText = Color3.fromRGB(116, 165, 142),
        Outline = Color3.fromRGB(18, 50, 35),
        Element = Color3.fromRGB(9, 22, 15),
        Scrollbar = Color3.fromRGB(25, 70, 48),
    },
}

-- Library state
Library.CurrentTheme = "Dark"
Library.CornerRadius = DEFAULT_CORNER_RADIUS
Library.Font = DEFAULT_FONT
Library.Scale = 1
Library.BlurEnabled = false
Library.Transparency = 0
Library.RoundedCorners = true
Library.Flags = {}
Library._windows = {}
Library._themeListeners = {}
Library._tooltipConnection = nil
Library._flagControls = {} -- flag -> { updater, ... }
Library._configStorage = {} -- internal cache for configs (if no file access)
Library._useFileSystem = pcall(function() return writefile and readfile and listfiles end) and true or false

local function T() return Library.Themes[Library.CurrentTheme] end
local function CR() return Library.RoundedCorners and Library.CornerRadius or 0 end

-- Config storage path
local CONFIG_DIR = "UILibraryConfigs/"
local function ensureConfigDir()
    if Library._useFileSystem and not isfolder(CONFIG_DIR) then
        makefolder(CONFIG_DIR)
    end
end

-- Serialization helpers
local function serializeValue(val)
    if typeof(val) == "EnumItem" then
        return { __type = "Enum", enum = tostring(val.EnumType), value = val.Name }
    elseif typeof(val) == "Color3" then
        return { __type = "Color3", r = val.R, g = val.G, b = val.B }
    elseif typeof(val) == "UDim2" then
        return { __type = "UDim2", X = { Scale = val.X.Scale, Offset = val.X.Offset }, Y = { Scale = val.Y.Scale, Offset = val.Y.Offset } }
    elseif typeof(val) == "Vector2" then
        return { __type = "Vector2", X = val.X, Y = val.Y }
    elseif type(val) == "table" then
        local t = {}
        for k, v in pairs(val) do
            t[k] = serializeValue(v)
        end
        return t
    else
        return val
    end
end

local function deserializeValue(val)
    if type(val) == "table" and val.__type then
        if val.__type == "Enum" then
            local enum = Enum[val.enum]
            return enum and enum[val.value] or Enum.KeyCode.Unknown
        elseif val.__type == "Color3" then
            return Color3.new(val.r, val.g, val.b)
        elseif val.__type == "UDim2" then
            return UDim2.new(val.X.Scale, val.X.Offset, val.Y.Scale, val.Y.Offset)
        elseif val.__type == "Vector2" then
            return Vector2.new(val.X, val.Y)
        end
    end
    if type(val) == "table" then
        local t = {}
        for k, v in pairs(val) do
            t[k] = deserializeValue(v)
        end
        return t
    end
    return val
end

function Library:SaveConfig(name)
    if not name or name == "" then return false end
    local configData = {}
    for flag, value in pairs(self.Flags) do
        configData[flag] = serializeValue(value)
    end
    
    local json = HttpService:JSONEncode(configData)
    if self._useFileSystem then
        ensureConfigDir()
        local success, err = pcall(writefile, CONFIG_DIR .. name .. ".json", json)
        if not success then
            warn("[Config] Failed to save to file:", err)
            self._configStorage[name] = configData
        end
    else
        self._configStorage[name] = configData
    end
    self:Notify({ Title = "Config Saved", Message = "Saved as '" .. name .. "'", Type = "Success" })
    return true
end

function Library:LoadConfig(name)
    if not name or name == "" then return false end
    local rawData = nil
    if self._useFileSystem then
        local path = CONFIG_DIR .. name .. ".json"
        if isfile(path) then
            local content = readfile(path)
            rawData = HttpService:JSONDecode(content)
        end
    else
        rawData = self._configStorage[name]
    end
    
    if not rawData then
        self:Notify({ Title = "Config Error", Message = "Config '" .. name .. "' not found", Type = "Error" })
        return false
    end
    
    -- Deserialize and apply
    local loadedFlags = {}
    for flag, serialized in pairs(rawData) do
        loadedFlags[flag] = deserializeValue(serialized)
    end
    
    -- Apply to flags and update controls
    for flag, newValue in pairs(loadedFlags) do
        self.Flags[flag] = newValue
        if self._flagControls[flag] then
            for _, updater in ipairs(self._flagControls[flag]) do
                safePCall(updater, newValue)
            end
        end
    end
    
    self:Notify({ Title = "Config Loaded", Message = "Loaded '" .. name .. "'", Type = "Info" })
    return true
end

function Library:DeleteConfig(name)
    if not name or name == "" then return false end
    if self._useFileSystem then
        local path = CONFIG_DIR .. name .. ".json"
        if isfile(path) then
            delfile(path)
        end
    else
        self._configStorage[name] = nil
    end
    self:Notify({ Title = "Config Deleted", Message = "Deleted '" .. name .. "'", Type = "Warning" })
    return true
end

function Library:GetConfigList()
    local list = {}
    if self._useFileSystem then
        ensureConfigDir()
        local files = listfiles(CONFIG_DIR)
        for _, file in ipairs(files) do
            local name = file:match("([^/]+)%.json$")
            if name then
                table.insert(list, name)
            end
        end
    else
        for name in pairs(self._configStorage) do
            table.insert(list, name)
        end
    end
    table.sort(list)
    return list
end

function Library:ExportConfig(name)
    if not name or name == "" then return nil end
    local rawData = nil
    if self._useFileSystem then
        local path = CONFIG_DIR .. name .. ".json"
        if isfile(path) then
            rawData = readfile(path)
        end
    else
        if self._configStorage[name] then
            rawData = HttpService:JSONEncode(self._configStorage[name])
        end
    end
    return rawData
end

function Library:ImportConfig(jsonString, newName)
    if not jsonString or not newName then return false end
    local success, data = pcall(HttpService.JSONDecode, HttpService, jsonString)
    if not success then
        self:Notify({ Title = "Import Error", Message = "Invalid JSON", Type = "Error" })
        return false
    end
    if self._useFileSystem then
        ensureConfigDir()
        pcall(writefile, CONFIG_DIR .. newName .. ".json", jsonString)
    else
        self._configStorage[newName] = data
    end
    self:Notify({ Title = "Import Success", Message = "Imported as '" .. newName .. "'", Type = "Success" })
    return true
end

function Library:RegisterFlagUpdater(flag, updater)
    if not flag then return end
    if not self._flagControls[flag] then
        self._flagControls[flag] = {}
    end
    table.insert(self._flagControls[flag], updater)
end

-- Theme listener registration
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

-- ScreenGui
local ScreenGui
do
    local sg = New("ScreenGui", {
        Name = "UILibrary_vNL",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 9999,
        IgnoreGuiInset = true,
    })
    local ok = pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not ok then
        pcall(function() sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
    end
    ScreenGui = sg
end

-- PopupContainer (used by dropdowns)
local PopupContainer = New("Frame", {
    Name = "PopupContainer",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    ZIndex = POPUP_Z_INDEX,
    Parent = ScreenGui,
})

-- Tooltip
local ToolTipFrame = New("Frame", {
    Name = "Tooltip",
    Size = UDim2.new(0, 160, 0, 26),
    BackgroundColor3 = T().Secondary,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = TOOLTIP_Z_INDEX,
    Parent = ScreenGui,
})
Corner(ToolTipFrame, 6)
Stroke(ToolTipFrame, T().Outline)
Padding(ToolTipFrame, 0, 0, 8, 8)

local ToolTipLabel = New("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "",
    TextColor3 = T().Text,
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = TOOLTIP_Z_INDEX + 1,
    Parent = ToolTipFrame,
})

Library:RegisterListener(function(t)
    ToolTipFrame.BackgroundColor3 = t.Secondary
    ToolTipLabel.TextColor3 = t.Text
end)

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

-- Notification container
local NotifHolder = New("Frame", {
    Name = "NotifHolder",
    Size = UDim2.new(0, 292, 1, 0),
    Position = UDim2.new(1, -300, 0, 0),
    BackgroundTransparency = 1,
    Parent = ScreenGui,
})
do
    local l = ListLayout(NotifHolder, 8)
    l.VerticalAlignment = Enum.VerticalAlignment.Bottom
    l.HorizontalAlignment = Enum.HorizontalAlignment.Right
    Padding(NotifHolder, 8, 8, 0, 8)
end

function Library:Notify(opts)
    local theme = T()
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

    local card = New("Frame", {
        Name = "Notif",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.Secondary,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = NotifHolder,
    })
    Corner(card, 8)
    Stroke(card, theme.Outline)

    New("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = ac,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = card,
    })

    local inner = New("Frame", {
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -10, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = card,
    })
    Padding(inner, 8, 8, 4, 8)
    ListLayout(inner, 3)

    New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = inner,
    })
    New("TextLabel", {
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

    local progressBG = New("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = theme.Outline,
        BorderSizePixel = 0,
        Parent = card,
    })
    local progressFill = New("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = ac,
        BorderSizePixel = 0,
        Parent = progressBG,
    })

    Tween(card, { BackgroundTransparency = 0 }, 0.25, Enum.EasingStyle.Quint)
    Tween(progressFill, { Size = UDim2.new(0, 0, 1, 0) }, duration, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        Tween(card, { BackgroundTransparency = 1 }, 0.3)
        task.delay(0.32, function() pcall(function() card:Destroy() end) end)
    end)
end

-- Watermark
function Library:SetWatermark(text)
    if self._wm then self._wm.Text = text; return end
    local theme = T()
    local bg = New("Frame", {
        Name = "Watermark",
        Size = UDim2.new(0, 0, 0, 28),
        AutomaticSize = Enum.AutomaticSize.X,
        Position = UDim2.new(0, 10, 0, 8),
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        Parent = ScreenGui,
    })
    Corner(bg, 6)
    Stroke(bg, theme.Outline)
    Padding(bg, 0, 0, 10, 10)
    local lbl = New("TextLabel", {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        Parent = bg,
    })
    self._wm = lbl
    self:RegisterListener(function(t)
        bg.BackgroundColor3 = t.Secondary
        lbl.TextColor3 = t.Text
    end)
end

function Library:AddTheme(name, data)
    local base = {}
    for k, v in pairs(self.Themes.Dark) do base[k] = v end
    for k, v in pairs(data) do base[k] = v end
    self.Themes[name] = base
end

-- Window creator
function Library:CreateWindow(opts)
    opts = opts or {}
    local winTitle = opts.Title or "UI Library"
    local winSize = opts.Size or UDim2.new(0, 640, 0, 460)
    local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift

    local theme = T()

    local Win = setmetatable({
        _tabs = {},
        _activeTab = nil,
        _visible = true,
        _minimised = false,
        _baseSize = winSize,
        _cleanup = {},
        Flags = Library.Flags,
    }, { __index = self })

    -- Root
    local Root = New("Frame", {
        Name = "Window_" .. winTitle,
        Size = winSize,
        Position = UDim2.new(0.5, -winSize.X.Offset / 2, 0.5, -winSize.Y.Offset / 2),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        Parent = ScreenGui,
    })
    Corner(Root, 10)
    local rootStroke = Stroke(Root, theme.Outline, 1)
    Win._root = Root

    -- Shadow
    New("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0, -15, 0, -8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.65,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = 0,
        Parent = Root,
    })

    -- Title Bar
    local TitleBar = New("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = Root,
    })
    Corner(TitleBar, 10)
    New("Frame", {
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = TitleBar,
    })

    local TitleLabel = New("TextLabel", {
        Size = UDim2.new(1, -90, 1, -2),
        Position = UDim2.new(0, 14, 0, 1),
        BackgroundTransparency = 1,
        Text = winTitle,
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = TitleBar,
    })

    local AccentLine = New("Frame", {
        Name = "AccentLine",
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = TitleBar,
    })

    -- Window controls
    local CtrlRow = New("Frame", {
        Size = UDim2.new(0, 56, 0, 22),
        Position = UDim2.new(1, -64, 0.5, -11),
        BackgroundTransparency = 1,
        ZIndex = 4,
        Parent = TitleBar,
    })
    ListLayout(CtrlRow, 6, Enum.FillDirection.Horizontal)

    local function WinBtn(bgColor, sym, onClick)
        local b = New("TextButton", {
            Size = UDim2.new(0, 22, 0, 22),
            BackgroundColor3 = bgColor,
            BorderSizePixel = 0,
            Text = sym,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            ZIndex = 5,
            Parent = CtrlRow,
        })
        Corner(b, 5)
        b.MouseEnter:Connect(function() Tween(b, { BackgroundTransparency = 0.35 }, 0.1) end)
        b.MouseLeave:Connect(function() Tween(b, { BackgroundTransparency = 0 }, 0.1) end)
        b.MouseButton1Click:Connect(onClick)
        return b
    end

    WinBtn(Color3.fromRGB(235, 175, 28), "−", function() Win:_Minimise() end)
    WinBtn(Color3.fromRGB(215, 55, 60), "×", function() Win:Close() end)

    -- Body
    local Body = New("Frame", {
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -38),
        Position = UDim2.new(0, 0, 0, 38),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 2,
        Parent = Root,
    })
    Win._body = Body

    -- TabBar
    local TabBar = New("ScrollingFrame", {
        Name = "TabBar",
        Size = UDim2.new(0, 118, 1, -10),
        Position = UDim2.new(0, 6, 0, 5),
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 3,
        Parent = Body,
    })
    Corner(TabBar, 8)
    Padding(TabBar, 6, 6, 6, 6)
    ListLayout(TabBar, 3)
    Win._tabBar = TabBar

    -- ContentArea
    local ContentArea = New("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -130, 1, -10),
        Position = UDim2.new(0, 128, 0, 5),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 2,
        Parent = Body,
    })
    Win._contentArea = ContentArea

    -- Dragging
    local dragging, dragStart, frameStart = false, nil, nil
    TitleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
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
            Root.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + d.X, frameStart.Y.Scale, frameStart.Y.Offset + d.Y)
        end
    end)

    -- Toggle keybind
    UserInputService.InputBegan:Connect(function(inp, gpe)
        if not gpe and inp.KeyCode == toggleKey then
            Win:Toggle()
        end
    end)

    -- Theme listeners for window chrome
    table.insert(Win._cleanup, Library:RegisterListener(function(t)
        if not Root.Parent then return end
        Root.BackgroundColor3 = t.Background
        rootStroke.Color = t.Outline
        TitleBar.BackgroundColor3 = t.Secondary
        TitleLabel.TextColor3 = t.Text
        AccentLine.BackgroundColor3 = t.Accent
        TabBar.BackgroundColor3 = t.Secondary
        for _, c in ipairs(TitleBar:GetChildren()) do
            if c:IsA("Frame") and c.Name ~= "AccentLine" then
                c.BackgroundColor3 = t.Secondary
            end
        end
    end))

    -- Window methods
    function Win:Toggle(forceState)
        if forceState ~= nil then self._visible = forceState else self._visible = not self._visible end
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
        local target = self._minimised and UDim2.new(winSize.X.Scale, winSize.X.Offset, 0, 38) or winSize
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

    -- CreateTab
    function Win:CreateTab(name)
        local theme = T()
        local Tab = {
            _name = name,
            _win = self,
            _cleanup = {},
        }

        local TabBtn = New("TextButton", {
            Name = "Tab_" .. name,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = theme.Tertiary,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = name,
            TextColor3 = theme.SubText,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            ZIndex = 4,
            Parent = TabBar,
        })
        Corner(TabBtn, 6)

        local TabAccent = New("Frame", {
            Name = "TabAccent",
            Size = UDim2.new(0, 3, 0.6, 0),
            Position = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor3 = theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 5,
            Parent = TabBtn,
        })
        Corner(TabAccent, 2)

        Tab._btn = TabBtn
        Tab._accent = TabAccent

        local ContentFrame = New("Frame", {
            Name = "TabContent_" .. name,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            ZIndex = 2,
            Parent = ContentArea,
        })
        Tab._frame = ContentFrame

        local ColRow = New("Frame", {
            Size = UDim2.new(1, -8, 1, -8),
            Position = UDim2.new(0, 4, 0, 4),
            BackgroundTransparency = 1,
            Parent = ContentFrame,
        })
        ListLayout(ColRow, 6, Enum.FillDirection.Horizontal)

        local function MakeScrollCol(side)
            local sf = New("ScrollingFrame", {
                Name = side .. "Col",
                Size = UDim2.new(0.5, -3, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = theme.Scrollbar,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ZIndex = 2,
                Parent = ColRow,
            })
            ListLayout(sf, 6)
            Padding(sf, 0, 6, 0, 2)
            table.insert(Tab._cleanup, Library:RegisterListener(function(t)
                if sf and sf.Parent then sf.ScrollBarImageColor3 = t.Scrollbar end
            end))
            return sf
        end

        Tab._leftCol = MakeScrollCol("Left")
        Tab._rightCol = MakeScrollCol("Right")

        local function Activate()
            if self._activeTab then
                local prev = self._activeTab
                prev._frame.Visible = false
                Tween(prev._btn, { BackgroundTransparency = 1, TextColor3 = T().SubText }, 0.14)
                Tween(prev._accent, { BackgroundTransparency = 1 }, 0.14)
            end
            self._activeTab = Tab
            ContentFrame.Visible = true
            Tween(TabBtn, { BackgroundTransparency = 0, BackgroundColor3 = T().Tertiary, TextColor3 = T().Text }, 0.14)
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
                TabBtn.TextColor3 = t.Text
            else
                TabBtn.TextColor3 = t.SubText
            end
        end))

        -- Groupbox creator
        function Tab:CreateGroupbox(gbName, side)
            local theme = T()
            local col = (side == "Right") and self._rightCol or self._leftCol

            local GB = {
                _tab = self,
                _cleanup = {},
                _list = nil,
            }

            local GBFrame = New("Frame", {
                Name = "GB_" .. gbName,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = theme.Element,
                BorderSizePixel = 0,
                ZIndex = 3,
                Parent = col,
            })
            Corner(GBFrame, 8)
            local gbStroke = Stroke(GBFrame, theme.Outline)

            local GBHeader = New("Frame", {
                Name = "Header",
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundTransparency = 1,
                ZIndex = 4,
                Parent = GBFrame,
            })
            local headerDivider = New("Frame", {
                Size = UDim2.new(1, -14, 0, 1),
                Position = UDim2.new(0, 7, 1, -1),
                BackgroundColor3 = theme.Outline,
                BorderSizePixel = 0,
                ZIndex = 4,
                Parent = GBHeader,
            })
            local headerTitle = New("TextLabel", {
                Size = UDim2.new(1, -14, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = gbName,
                TextColor3 = theme.SubText,
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = GBHeader,
            })

            local GBContent = New("Frame", {
                Name = "Content",
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Position = UDim2.new(0, 0, 0, 26),
                BackgroundTransparency = 1,
                ZIndex = 3,
                Parent = GBFrame,
            })
            Padding(GBContent, 4, 8, 8, 8)
            ListLayout(GBContent, 5)
            GB._list = GBContent

            table.insert(GB._cleanup, Library:RegisterListener(function(t)
                if not GBFrame or not GBFrame.Parent then return end
                GBFrame.BackgroundColor3 = t.Element
                gbStroke.Color = t.Outline
                headerDivider.BackgroundColor3 = t.Outline
                headerTitle.TextColor3 = t.SubText
            end))

            local function ElemRow(labelText, height, tooltip)
                local row = New("Frame", {
                    Size = UDim2.new(1, 0, 0, height or 26),
                    BackgroundTransparency = 1,
                    ZIndex = 4,
                    Parent = GB._list,
                })
                local lbl = New("TextLabel", {
                    Size = UDim2.new(0.58, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = labelText,
                    TextColor3 = T().Text,
                    Font = Library.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = row,
                })
                if tooltip then AttachTooltip(row, tooltip) end
                table.insert(GB._cleanup, Library:RegisterListener(function(t)
                    if lbl and lbl.Parent then
                        lbl.TextColor3 = t.Text
                        lbl.Font = Library.Font
                    end
                end))
                return row, lbl
            end

            -- Button
            function GB:CreateButton(opts)
                local n = opts.Name or "Button"
                local cb = opts.Callback or function() end
                local tooltip = opts.Tooltip
                local theme = T()

                local row = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    ZIndex = 4,
                    Parent = self._list,
                })

                local btn = New("TextButton", {
                    Size = UDim2.new(1, 0, 0, 26),
                    Position = UDim2.new(0, 0, 0, 1),
                    BackgroundColor3 = theme.Accent,
                    BorderSizePixel = 0,
                    Text = n,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    ZIndex = 5,
                    Parent = row,
                })
                Corner(btn, 6)
                if tooltip then AttachTooltip(btn, tooltip) end

                btn.MouseEnter:Connect(function() Tween(btn, { BackgroundColor3 = T().AccentGlow }, 0.12) end)
                btn.MouseLeave:Connect(function() Tween(btn, { BackgroundColor3 = T().Accent }, 0.12) end)
                btn.MouseButton1Down:Connect(function() Tween(btn, { BackgroundColor3 = T().AccentDark }, 0.08) end)
                btn.MouseButton1Up:Connect(function() Tween(btn, { BackgroundColor3 = T().Accent }, 0.12) end)
                btn.MouseButton1Click:Connect(function()
                    safePCall(cb)
                end)

                table.insert(self._cleanup, Library:RegisterListener(function(t)
                    if btn and btn.Parent then btn.BackgroundColor3 = t.Accent end
                end))

                local Ref = {}
                function Ref:SetText(text) btn.Text = text end
                return Ref
            end

            -- Toggle
            function GB:CreateToggle(opts)
                local n = opts.Name or "Toggle"
                local default = opts.Default == true
                local flag = opts.Flag
                local cb = opts.Callback or function() end
                local tooltip = opts.Tooltip

                local state = default
                if flag then Library.Flags[flag] = state end

                local row, _ = ElemRow(n, 26, tooltip)

                local track = New("Frame", {
                    Size = UDim2.new(0, 36, 0, 18),
                    Position = UDim2.new(1, -36, 0.5, -9),
                    BackgroundColor3 = state and T().Accent or T().Outline,
                    BorderSizePixel = 0,
                    ZIndex = 5,
                    Parent = row,
                })
                Corner(track, 9)

                local knob = New("Frame", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    ZIndex = 6,
                    Parent = track,
                })
                Corner(knob, 6)

                local Ref = { _state = state, _cb = cb }

                local function SetState(val, silent)
                    state = val
                    Ref._state = val
                    if flag then Library.Flags[flag] = val end
                    Tween(track, { BackgroundColor3 = val and T().Accent or T().Outline }, 0.14)
                    Tween(knob, { Position = val and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6) }, 0.14)
                    if not silent then safePCall(cb, val) end
                end

                New("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 7,
                    Parent = row,
                }).MouseButton1Click:Connect(function() SetState(not state) end)

                table.insert(self._cleanup, Library:RegisterListener(function(t)
                    if track and track.Parent then
                        track.BackgroundColor3 = state and t.Accent or t.Outline
                    end
                end))

                if flag then
                    Library:RegisterFlagUpdater(flag, function(newVal)
                        SetState(newVal, true)
                    end)
                end

                function Ref:Set(v) SetState(v) end
                function Ref:Get() return state end
                function Ref:Dependency(toggleRef, requireVal)
                    local conn
                    local function Upd()
                        if not row then conn:Disconnect() return end
                        row.Visible = (toggleRef:Get() == requireVal)
                    end
                    conn = RunService.Heartbeat:Connect(Upd)
                    Upd()
                end
                return Ref
            end

            -- Slider
            function GB:CreateSlider(opts)
                local n = opts.Name or "Slider"
                local min = opts.Min or 0
                local max = opts.Max or 100
                local default = math.clamp(opts.Default or min, min, max)
                local step = opts.Step or 1
                local suffix = opts.Suffix or ""
                local flag = opts.Flag
                local cb = opts.Callback or function() end
                local tooltip = opts.Tooltip

                local value = default
                if flag then Library.Flags[flag] = value end

                local row = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 44),
                    BackgroundTransparency = 1,
                    ZIndex = 4,
                    Parent = self._list,
                })
                if tooltip then AttachTooltip(row, tooltip) end

                local topRow = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    ZIndex = 5,
                    Parent = row,
                })
                local nameLbl = New("TextLabel", {
                    Size = UDim2.new(0.6, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = n,
                    TextColor3 = T().Text,
                    Font = Library.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6,
                    Parent = topRow,
                })
                local valLbl = New("TextLabel", {
                    Size = UDim2.new(0.4, 0, 1, 0),
                    Position = UDim2.new(0.6, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(value) .. suffix,
                    TextColor3 = T().SubText,
                    Font = Library.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 6,
                    Parent = topRow,
                })

                local track = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 0, 26),
                    BackgroundColor3 = T().Outline,
                    BorderSizePixel = 0,
                    ZIndex = 5,
                    Parent = row,
                })
                Corner(track, 3)

                local pct0 = (value - min) / (max - min)
                local fill = New("Frame", {
                    Size = UDim2.new(pct0, 0, 1, 0),
                    BackgroundColor3 = T().Accent,
                    BorderSizePixel = 0,
                    ZIndex = 6,
                    Parent = track,
                })
                Corner(fill, 3)

                local knob = New("Frame", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(pct0, -6, 0.5, -6),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    ZIndex = 7,
                    Parent = track,
                })
                Corner(knob, 6)

                local Ref = {}

                local function SetValue(v, silent)
                    v = math.clamp(step == 1 and math.round(v) or (math.floor(v / step + 0.5) * step), min, max)
                    value = v
                    if flag then Library.Flags[flag] = v end
                    local p = (v - min) / (max - min)
                    Tween(fill, { Size = UDim2.new(p, 0, 1, 0) }, 0.07)
                    Tween(knob, { Position = UDim2.new(p, -6, 0.5, -6) }, 0.07)
                    valLbl.Text = tostring(v) .. suffix
                    if not silent then safePCall(cb, v) end
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

                table.insert(self._cleanup, Library:RegisterListener(function(t)
                    if track and track.Parent then
                        track.BackgroundColor3 = t.Outline
                        fill.BackgroundColor3 = t.Accent
                        nameLbl.TextColor3 = t.Text
                        nameLbl.Font = Library.Font
                        valLbl.TextColor3 = t.SubText
                        valLbl.Font = Library.Font
                    end
                end))

                if flag then
                    Library:RegisterFlagUpdater(flag, function(newVal)
                        SetValue(newVal, true)
                    end)
                end

                function Ref:Set(v) SetValue(v) end
                function Ref:Get() return value end
                function Ref:Dependency(toggleRef, requireVal)
                    local conn
                    local function Upd()
                        if not row then conn:Disconnect() return end
                        row.Visible = (toggleRef:Get() == requireVal)
                    end
                    conn = RunService.Heartbeat:Connect(Upd)
                    Upd()
                end
                return Ref
            end

            -- Dropdown
            function GB:CreateDropdown(opts)
                local n = opts.Name or "Dropdown"
                local options = opts.Options or {}
                local default = opts.Default or options[1]
                local flag = opts.Flag
                local cb = opts.Callback or function() end
                local tooltip = opts.Tooltip

                local selected = default
                if flag then Library.Flags[flag] = selected end

                local row = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 52),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    ZIndex = 4,
                    Parent = self._list,
                })
                if tooltip then AttachTooltip(row, tooltip) end

                New("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text = n,
                    TextColor3 = T().Text,
                    Font = Library.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = row,
                })

                local dropBtn = New("TextButton", {
                    Size = UDim2.new(1, 0, 0, 26),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = T().Secondary,
                    BorderSizePixel = 0,
                    Text = "",
                    ZIndex = 5,
                    Parent = row,
                })
                Corner(dropBtn, 6)
                Stroke(dropBtn, T().Outline)

                local selLbl = New("TextLabel", {
                    Size = UDim2.new(1, -26, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = selected or "Select...",
                    TextColor3 = T().Text,
                    Font = Library.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 6,
                    Parent = dropBtn,
                })
                New("TextLabel", {
                    Size = UDim2.new(0, 18, 1, 0),
                    Position = UDim2.new(1, -22, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▾",
                    TextColor3 = T().SubText,
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    ZIndex = 6,
                    Parent = dropBtn,
                })

                local dropList = New("Frame", {
                    Name = "DropList",
                    Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0),
                    BackgroundColor3 = T().Secondary,
                    BorderSizePixel = 0,
                    Visible = false,
                    ClipsDescendants = true,
                    ZIndex = POPUP_Z_INDEX + 1,
                    Parent = PopupContainer,
                })
                Corner(dropList, 6)
                Stroke(dropList, T().Outline)
                Padding(dropList, 4, 4, 4, 4)
                ListLayout(dropList, 2)

                local Ref = {}
                local isOpen = false
                local updateConn = nil

                local function SetSelected(opt, silent)
                    selected = opt
                    selLbl.Text = opt or "Select..."
                    if flag then Library.Flags[flag] = opt end
                    if not silent then safePCall(cb, opt) end
                end

                local function RebuildList(justColors)
                    if justColors then
                        local t = T()
                        for _, c in ipairs(dropList:GetChildren()) do
                            if c:IsA("TextButton") then
                                local isSel = (c.Text == selected)
                                c.BackgroundColor3 = t.Tertiary
                                c.BackgroundTransparency = isSel and 0 or 1
                                c.TextColor3 = isSel and t.Text or t.SubText
                            end
                        end
                        return
                    end
                    for _, c in ipairs(dropList:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end
                    for _, opt in ipairs(options) do
                        local isSelected = (opt == selected)
                        local item = New("TextButton", {
                            Size = UDim2.new(1, 0, 0, 26),
                            BackgroundColor3 = T().Tertiary,
                            BackgroundTransparency = isSelected and 0 or 1,
                            BorderSizePixel = 0,
                            Text = opt,
                            TextColor3 = isSelected and T().Text or T().SubText,
                            Font = Library.Font,
                            TextSize = 12,
                            ZIndex = POPUP_Z_INDEX + 2,
                            Parent = dropList,
                        })
                        Corner(item, 4)
                        item.MouseEnter:Connect(function()
                            Tween(item, { BackgroundTransparency = 0, BackgroundColor3 = T().Tertiary, TextColor3 = T().Text }, 0.08)
                        end)
                        item.MouseLeave:Connect(function()
                            Tween(item, { BackgroundTransparency = (opt == selected) and 0 or 1 }, 0.08)
                        end)
                        item.MouseButton1Click:Connect(function()
                            SetSelected(opt)
                            isOpen = false
                            if updateConn then updateConn:Disconnect(); updateConn = nil end
                            Tween(dropList, { Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0) }, 0.14)
                            task.delay(0.14, function() dropList.Visible = false end)
                            RebuildList(true)
                        end)
                    end
                end
                RebuildList()

                local function updatePopupPosition()
                    if not dropBtn or not dropBtn.Visible then return end
                    local absPos = dropBtn.AbsolutePosition
                    local absSize = dropBtn.AbsoluteSize
                    local viewSize = workspace.CurrentCamera.ViewportSize
                    local popupX = absPos.X
                    local popupY = absPos.Y + absSize.Y + 4
                    if popupX + absSize.X > viewSize.X then popupX = viewSize.X - absSize.X end
                    if popupY + dropList.AbsoluteSize.Y > viewSize.Y then popupY = absPos.Y - dropList.AbsoluteSize.Y - 4 end
                    dropList.Position = UDim2.fromOffset(popupX, popupY)
                    dropList.Size = UDim2.new(0, absSize.X, 0, dropList.AbsoluteSize.Y)
                end

                dropBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        updatePopupPosition()
                        updateConn = RunService.RenderStepped:Connect(function()
                            if dropBtn and dropBtn.Parent then updatePopupPosition() end
                        end)
                        dropList.Visible = true
                        local h = #options * 28 + 8
                        Tween(dropList, { Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, h) }, 0.15)
                    else
                        if updateConn then updateConn:Disconnect(); updateConn = nil end
                        Tween(dropList, { Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0) }, 0.15)
                        task.delay(0.15, function() dropList.Visible = false end)
                    end
                end)

                table.insert(self._cleanup, Library:RegisterListener(function(t)
                    if dropBtn and dropBtn.Parent then
                        dropBtn.BackgroundColor3 = t.Secondary
                        selLbl.TextColor3 = t.Text
                        dropList.BackgroundColor3 = t.Secondary
                        RebuildList(true)
                    end
                end))

                if flag then
                    Library:RegisterFlagUpdater(flag, function(newVal)
                        if tableFind(options, newVal) then
                            SetSelected(newVal, true)
                            RebuildList(true)
                        end
                    end)
                end

                function Ref:Set(opt)
                    if tableFind(options, opt) then
                        SetSelected(opt)
                        RebuildList(true)
                    end
                end
                function Ref:Get() return selected end
                function Ref:SetOptions(newOpts) options = newOpts; RebuildList() end
                function Ref:Dependency(toggleRef, requireVal)
                    local conn
                    local function Upd()
                        if not row then conn:Disconnect() return end
                        row.Visible = (toggleRef:Get() == requireVal)
                    end
                    conn = RunService.Heartbeat:Connect(Upd)
                    Upd()
                end
                return Ref
            end

            -- MultiDropdown
            function GB:CreateMultiDropdown(opts)
                local n = opts.Name or "MultiSelect"
                local options = opts.Options or {}
                local default = opts.Default or {}
                local flag = opts.Flag
                local cb = opts.Callback or function() end
                local tooltip = opts.Tooltip

                local selected = {}
                for _, v in ipairs(default) do selected[v] = true end
                if flag then Library.Flags[flag] = selected end

                local row = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 52),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    ZIndex = 4,
                    Parent = self._list,
                })
                if tooltip then AttachTooltip(row, tooltip) end

                New("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text = n,
                    TextColor3 = T().Text,
                    Font = Library.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = row,
                })

                local dropBtn = New("TextButton", {
                    Size = UDim2.new(1, 0, 0, 26),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = T().Secondary,
                    BorderSizePixel = 0,
                    Text = "",
                    ZIndex = 5,
                    Parent = row,
                })
                Corner(dropBtn, 6)
                Stroke(dropBtn, T().Outline)

                local function SelText()
                    local list = {}
                    for k, v in pairs(selected) do if v then table.insert(list, k) end end
                    table.sort(list)
                    return #list > 0 and table.concat(list, ", ") or "None"
                end

                local selLbl = New("TextLabel", {
                    Size = UDim2.new(1, -26, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = SelText(),
                    TextColor3 = T().Text,
                    Font = Library.Font,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 6,
                    Parent = dropBtn,
                })
                New("TextLabel", {
                    Size = UDim2.new(0, 18, 1, 0),
                    Position = UDim2.new(1, -22, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▾",
                    TextColor3 = T().SubText,
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    ZIndex = 6,
                    Parent = dropBtn,
                })

                local dropList = New("Frame", {
                    Name = "DropList",
                    Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0),
                    BackgroundColor3 = T().Secondary,
                    BorderSizePixel = 0,
                    Visible = false,
                    ClipsDescendants = true,
                    ZIndex = POPUP_Z_INDEX + 1,
                    Parent = PopupContainer,
                })
                Corner(dropList, 6)
                Stroke(dropList, T().Outline)
                Padding(dropList, 4, 4, 4, 4)
                ListLayout(dropList, 2)

                local Ref = {}
                local isOpen = false
                local updateConn = nil

                local function RebuildMultiList(justColors)
                    if justColors then
                        local t = T()
                        for _, c in ipairs(dropList:GetChildren()) do
                            if c:IsA("Frame") then
                                local opt = c:FindFirstChildOfClass("TextLabel").Text
                                local isSel = selected[opt] == true
                                c.BackgroundColor3 = t.Tertiary
                                c.BackgroundTransparency = isSel and 0 or 1
                                local chk = c:FindFirstChildOfClass("TextLabel")
                                if chk and chk ~= c:FindFirstChildOfClass("TextLabel") then
                                    chk.Text = isSel and "✓" or ""
                                end
                            end
                        end
                        return
                    end
                    for _, c in ipairs(dropList:GetChildren()) do
                        if c:IsA("Frame") then c:Destroy() end
                    end
                    for _, opt in ipairs(options) do
                        local isSel = selected[opt] == true
                        local item = New("Frame", {
                            Size = UDim2.new(1, 0, 0, 26),
                            BackgroundColor3 = T().Tertiary,
                            BackgroundTransparency = isSel and 0 or 1,
                            BorderSizePixel = 0,
                            ZIndex = POPUP_Z_INDEX + 2,
                            Parent = dropList,
                        })
                        Corner(item, 4)
                        New("TextLabel", {
                            Size = UDim2.new(1, -28, 1, 0),
                            Position = UDim2.new(0, 8, 0, 0),
                            BackgroundTransparency = 1,
                            Text = opt,
                            TextColor3 = T().Text,
                            Font = Library.Font,
                            TextSize = 12,
                            ZIndex = POPUP_Z_INDEX + 3,
                            Parent = item,
                        })
                        local chk = New("TextLabel", {
                            Size = UDim2.new(0, 18, 1, 0),
                            Position = UDim2.new(1, -22, 0, 0),
                            BackgroundTransparency = 1,
                            Text = isSel and "✓" or "",
                            TextColor3 = Color3.fromRGB(255, 255, 255),
                            Font = Enum.Font.GothamBold,
                            TextSize = 12,
                            ZIndex = POPUP_Z_INDEX + 3,
                            Parent = item,
                        })
                        New("TextButton", {
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            Text = "",
                            ZIndex = POPUP_Z_INDEX + 4,
                            Parent = item,
                        }).MouseButton1Click:Connect(function()
                            selected[opt] = not selected[opt]
                            selLbl.Text = SelText()
                            if flag then Library.Flags[flag] = selected end
                            safePCall(cb, selected)
                            item.BackgroundTransparency = selected[opt] and 0 or 1
                            item.BackgroundColor3 = T().Tertiary
                            chk.Text = selected[opt] and "✓" or ""
                        end)
                    end
                end
                RebuildMultiList()

                local function updatePopupPosition()
                    if not dropBtn or not dropBtn.Visible then return end
                    local absPos = dropBtn.AbsolutePosition
                    local absSize = dropBtn.AbsoluteSize
                    local viewSize = workspace.CurrentCamera.ViewportSize
                    local popupX = absPos.X
                    local popupY = absPos.Y + absSize.Y + 4
                    if popupX + absSize.X > viewSize.X then popupX = viewSize.X - absSize.X end
                    if popupY + dropList.AbsoluteSize.Y > viewSize.Y then popupY = absPos.Y - dropList.AbsoluteSize.Y - 4 end
                    dropList.Position = UDim2.fromOffset(popupX, popupY)
                    dropList.Size = UDim2.new(0, absSize.X, 0, dropList.AbsoluteSize.Y)
                end

                dropBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        updatePopupPosition()
                        updateConn = RunService.RenderStepped:Connect(function()
                            if dropBtn and dropBtn.Parent then updatePopupPosition() end
                        end)
                        dropList.Visible = true
                        local h = #options * 28 + 8
                        Tween(dropList, { Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, h) }, 0.15)
                    else
                        if updateConn then updateConn:Disconnect(); updateConn = nil end
                        Tween(dropList, { Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0) }, 0.15)
                        task.delay(0.15, function() dropList.Visible = false end)
                    end
                end)

                table.insert(self._cleanup, Library:RegisterListener(function(t)
                    if dropBtn and dropBtn.Parent then
                        dropBtn.BackgroundColor3 = t.Secondary
                        selLbl.TextColor3 = t.Text
                        dropList.BackgroundColor3 = t.Secondary
                        RebuildMultiList(true)
                    end
                end))

                if flag then
                    Library:RegisterFlagUpdater(flag, function(newSelected)
                        selected = newSelected
                        selLbl.Text = SelText()
                        RebuildMultiList()
                    end)
                end

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
                    local conn
                    local function Upd()
                        if not row then conn:Disconnect() return end
                        row.Visible = (toggleRef:Get() == requireVal)
                    end
                    conn = RunService.Heartbeat:Connect(Upd)
                    Upd()
                end
                return Ref
            end

            -- TextInput
            function GB:CreateTextInput(opts)
                local n = opts.Name or "Input"
                local placeholder = opts.Placeholder or "Type here..."
                local default = opts.Default or ""
                local flag = opts.Flag
                local cb = opts.Callback or function() end
                local tooltip = opts.Tooltip

                local value = default
                if flag then Library.Flags[flag] = value end

                local row = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 52),
                    BackgroundTransparency = 1,
                    ZIndex = 4,
                    Parent = self._list,
                })

                New("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text = n,
                    TextColor3 = T().Text,
                    Font = Library.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = row,
                })

                local inputBg = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 28),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = T().Secondary,
                    BorderSizePixel = 0,
                    ZIndex = 5,
                    Parent = row,
                })
                Corner(inputBg, 6)
                Stroke(inputBg, T().Outline)
                if tooltip then AttachTooltip(inputBg, tooltip) end

                local tb = New("TextBox", {
                    Size = UDim2.new(1, -16, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = value,
                    PlaceholderText = placeholder,
                    TextColor3 = T().Text,
                    PlaceholderColor3 = T().SubText,
                    Font = Library.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    ZIndex = 6,
                    Parent = inputBg,
                })

                tb.Focused:Connect(function() Tween(inputBg, { BackgroundColor3 = T().Tertiary }, 0.1) end)
                tb.FocusLost:Connect(function()
                    Tween(inputBg, { BackgroundColor3 = T().Secondary }, 0.1)
                    value = tb.Text
                    if flag then Library.Flags[flag] = value end
                    safePCall(cb, value)
                end)

                table.insert(self._cleanup, Library:RegisterListener(function(t)
                    if inputBg and inputBg.Parent then
                        inputBg.BackgroundColor3 = t.Secondary
                        tb.TextColor3 = t.Text
                        tb.PlaceholderColor3 = t.SubText
                        tb.Font = Library.Font
                    end
                end))

                if flag then
                    Library:RegisterFlagUpdater(flag, function(newVal)
                        tb.Text = newVal
                        value = newVal
                    end)
                end

                local Ref = {}
                function Ref:Set(v) tb.Text = v; value = v end
                function Ref:Get() return value end
                function Ref:Dependency(toggleRef, requireVal)
                    local conn
                    local function Upd()
                        if not row then conn:Disconnect() return end
                        row.Visible = (toggleRef:Get() == requireVal)
                    end
                    conn = RunService.Heartbeat:Connect(Upd)
                    Upd()
                end
                return Ref
            end

            -- Keybind
            function GB:CreateKeybind(opts)
                local n = opts.Name or "Keybind"
                local default = opts.Default or Enum.KeyCode.Unknown
                local flag = opts.Flag
                local cb = opts.Callback or function() end
                local tooltip = opts.Tooltip

                local key = default
                local listening = false
                if flag then Library.Flags[flag] = key end

                local row, _ = ElemRow(n, 26, tooltip)

                local keyBtn = New("TextButton", {
                    Size = UDim2.new(0, 72, 0, 22),
                    Position = UDim2.new(1, -72, 0.5, -11),
                    BackgroundColor3 = T().Secondary,
                    BorderSizePixel = 0,
                    Text = key.Name ~= "Unknown" and key.Name or "None",
                    TextColor3 = T().SubText,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    ZIndex = 5,
                    Parent = row,
                })
                Corner(keyBtn, 5)
                Stroke(keyBtn, T().Outline)

                keyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    keyBtn.Text = "..."
                    keyBtn.TextColor3 = T().Accent
                end)

                local inputConn
                inputConn = UserInputService.InputBegan:Connect(function(inp, gpe)
                    if listening and not gpe then
                        if inp.UserInputType == Enum.UserInputType.Keyboard then
                            key = inp.KeyCode
                            if flag then Library.Flags[flag] = key end
                            keyBtn.Text = key.Name
                            keyBtn.TextColor3 = T().SubText
                            listening = false
                        end
                    elseif not gpe and not listening and inp.KeyCode == key and key ~= Enum.KeyCode.Unknown then
                        safePCall(cb)
                    end
                end)

                table.insert(self._cleanup, function() inputConn:Disconnect() end)

                table.insert(self._cleanup, Library:RegisterListener(function(t)
                    if keyBtn and keyBtn.Parent then
                        keyBtn.BackgroundColor3 = t.Secondary
                        keyBtn.TextColor3 = t.SubText
                        keyBtn.Font = Enum.Font.Gotham
                    end
                end))

                if flag then
                    Library:RegisterFlagUpdater(flag, function(newKey)
                        key = newKey
                        keyBtn.Text = key.Name ~= "Unknown" and key.Name or "None"
                    end)
                end

                local Ref = {}
                function Ref:Set(k) key = k; keyBtn.Text = k.Name end
                function Ref:Get() return key end
                function Ref:Dependency(toggleRef, requireVal)
                    local conn
                    local function Upd()
                        if not row then conn:Disconnect() return end
                        row.Visible = (toggleRef:Get() == requireVal)
                    end
                    conn = RunService.Heartbeat:Connect(Upd)
                    Upd()
                end
                return Ref
            end

            -- Label
            function GB:CreateLabel(opts)
                local text = opts.Text or ""
                local clr = opts.Color
                local lbl = New("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = clr or T().SubText,
                    Font = Library.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    ZIndex = 5,
                    Parent = self._list,
                })
                if not clr then
                    table.insert(self._cleanup, Library:RegisterListener(function(t)
                        if lbl and lbl.Parent then
                            lbl.TextColor3 = t.SubText
                            lbl.Font = Library.Font
                        end
                    end))
                end
                local Ref = {}
                function Ref:Set(t) lbl.Text = t end
                function Ref:Get() return lbl.Text end
                return Ref
            end

            -- Divider
            function GB:CreateDivider(labelText)
                local theme = T()
                if labelText and labelText ~= "" then
                    local container = New("Frame", {
                        Size = UDim2.new(1, 0, 0, 16),
                        BackgroundTransparency = 1,
                        ZIndex = 4,
                        Parent = self._list,
                    })
                    New("Frame", {
                        Size = UDim2.new(0.38, 0, 0, 1),
                        Position = UDim2.new(0, 0, 0.5, 0),
                        BackgroundColor3 = theme.Outline,
                        BorderSizePixel = 0,
                        ZIndex = 4,
                        Parent = container,
                    })
                    New("TextLabel", {
                        Size = UDim2.new(0.24, 0, 1, 0),
                        Position = UDim2.new(0.38, 0, 0, 0),
                        BackgroundTransparency = 1,
                        Text = labelText,
                        TextColor3 = theme.SubText,
                        Font = Enum.Font.Gotham,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        ZIndex = 5,
                        Parent = container,
                    })
                    New("Frame", {
                        Size = UDim2.new(0.38, 0, 0, 1),
                        Position = UDim2.new(0.62, 0, 0.5, 0),
                        BackgroundColor3 = theme.Outline,
                        BorderSizePixel = 0,
                        ZIndex = 4,
                        Parent = container,
                    })
                else
                    New("Frame", {
                        Size = UDim2.new(1, 0, 0, 1),
                        BackgroundColor3 = theme.Outline,
                        BorderSizePixel = 0,
                        ZIndex = 4,
                        Parent = self._list,
                    })
                end
            end

            return GB
        end

        return Tab
    end

    -- Built-in Options Tab
    local OptionsTab = Win:CreateTab("Options")
    local OptLeft = OptionsTab:CreateGroupbox("Appearance", "Left")
    local OptRight = OptionsTab:CreateGroupbox("Interface", "Right")

    local themeNames = {}
    for k in pairs(Library.Themes) do table.insert(themeNames, k) end
    table.sort(themeNames)

    OptLeft:CreateDropdown({
        Name = "Theme",
        Options = themeNames,
        Default = Library.CurrentTheme,
        Tooltip = "Choose a colour theme",
        Callback = function(sel)
            Library.CurrentTheme = sel
            FireTheme()
        end,
    })

    OptLeft:CreateToggle({
        Name = "Rounded Corners",
        Default = Library.RoundedCorners,
        Tooltip = "Toggle rounded or sharp corner radius",
        Callback = function(v) Library.RoundedCorners = v end,
    })

    OptLeft:CreateSlider({
        Name = "Corner Radius",
        Min = 0, Max = 14, Default = Library.CornerRadius,
        Tooltip = "Pixel radius of rounded corners",
        Callback = function(v) Library.CornerRadius = v end,
    })

    local fontMap = {
        ["Gotham Medium"] = Enum.Font.GothamMedium,
        ["Gotham"] = Enum.Font.Gotham,
        ["Gotham Bold"] = Enum.Font.GothamBold,
        ["Arial"] = Enum.Font.Arial,
        ["Code"] = Enum.Font.Code,
        ["Source Sans"] = Enum.Font.SourceSans,
    }
    local fontKeys = {}
    for k in pairs(fontMap) do table.insert(fontKeys, k) end
    table.sort(fontKeys)

    OptLeft:CreateDropdown({
        Name = "Font",
        Options = fontKeys,
        Default = "Gotham Medium",
        Tooltip = "Change the UI font family",
        Callback = function(f)
            Library.Font = fontMap[f] or Enum.Font.GothamMedium
            FireTheme()
        end,
    })

    OptRight:CreateSlider({
        Name = "UI Scale",
        Min = 50, Max = 150, Default = 100, Suffix = "%",
        Tooltip = "Scales the window size",
        Callback = function(pct)
            Library.Scale = pct / 100
            Root.Size = UDim2.new(winSize.X.Scale, winSize.X.Offset * Library.Scale, winSize.Y.Scale, winSize.Y.Offset * Library.Scale)
        end,
    })

    OptRight:CreateSlider({
        Name = "Transparency",
        Min = 0, Max = 80, Default = 0, Suffix = "%",
        Tooltip = "Background transparency of the window",
        Callback = function(pct)
            Library.Transparency = pct / 100
            Root.BackgroundTransparency = Library.Transparency
        end,
    })

    OptRight:CreateToggle({
        Name = "Blur Background",
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
        Name = "Reset Theme",
        Tooltip = "Restore the default theme settings",
        Callback = function()
            Library.CurrentTheme = "Dark"
            FireTheme()
            Library:Notify({ Title = "Theme Reset", Message = "Reverted to Dark theme.", Type = "Info" })
        end,
    })

    -- Full Config Tab with saving/loading UI
    local ConfigTab = Win:CreateTab("Config")
    local CfgLeft = ConfigTab:CreateGroupbox("Config Management", "Left")
    local CfgRight = ConfigTab:CreateGroupbox("Actions", "Right")

    local configListDropdown
    local newConfigNameInput
    local statusLabel

    local function RefreshConfigList()
        local list = Library:GetConfigList()
        if configListDropdown then
            configListDropdown:SetOptions(list)
            if #list > 0 and not configListDropdown:Get() then
                configListDropdown:Set(list[1])
            end
        end
    end

    -- Config Name Input
    newConfigNameInput = CfgLeft:CreateTextInput({
        Name = "Config Name",
        Placeholder = "my_config",
        Tooltip = "Name for saving/loading config",
    })

    -- Config Dropdown
    configListDropdown = CfgLeft:CreateDropdown({
        Name = "Saved Configs",
        Options = {},
        Tooltip = "Select a config to load/delete",
    })

    -- Save button
    CfgLeft:CreateButton({
        Name = "Save Current Config",
        Tooltip = "Save all flags to the named config",
        Callback = function()
            local name = newConfigNameInput:Get()
            if name and name ~= "" then
                Library:SaveConfig(name)
                RefreshConfigList()
            else
                Library:Notify({ Title = "Config Error", Message = "Please enter a config name", Type = "Warning" })
            end
        end,
    })

    -- Load button
    CfgLeft:CreateButton({
        Name = "Load Selected Config",
        Tooltip = "Load the selected config",
        Callback = function()
            local name = configListDropdown:Get()
            if name then
                Library:LoadConfig(name)
            else
                Library:Notify({ Title = "Config Error", Message = "No config selected", Type = "Warning" })
            end
        end,
    })

    -- Delete button
    CfgLeft:CreateButton({
        Name = "Delete Selected Config",
        Tooltip = "Delete the selected config",
        Callback = function()
            local name = configListDropdown:Get()
            if name then
                Library:DeleteConfig(name)
                RefreshConfigList()
            else
                Library:Notify({ Title = "Config Error", Message = "No config selected", Type = "Warning" })
            end
        end,
    })

    -- Export button
    CfgRight:CreateButton({
        Name = "Export Config (JSON)",
        Tooltip = "Copy config JSON to clipboard",
        Callback = function()
            local name = configListDropdown:Get()
            if name then
                local json = Library:ExportConfig(name)
                if json then
                    setclipboard(json)
                    Library:Notify({ Title = "Exported", Message = "Config JSON copied to clipboard", Type = "Success" })
                else
                    Library:Notify({ Title = "Export Failed", Message = "Could not export config", Type = "Error" })
                end
            else
                Library:Notify({ Title = "Export Error", Message = "Select a config first", Type = "Warning" })
            end
        end,
    })

    -- Import button (with dialog)
    CfgRight:CreateButton({
        Name = "Import Config",
        Tooltip = "Import config from JSON string",
        Callback = function()
            local success, json = pcall(function()
                return UserInputService:GetStringFromUser("Paste JSON config:", "Import Config", "", true)
            end)
            if success and json and json ~= "" then
                local newName = newConfigNameInput:Get()
                if newName and newName ~= "" then
                    Library:ImportConfig(json, newName)
                    RefreshConfigList()
                else
                    Library:Notify({ Title = "Import Error", Message = "Enter a config name first", Type = "Warning" })
                end
            end
        end,
    })

    -- Reset All Flags
    CfgRight:CreateButton({
        Name = "Reset All Flags",
        Tooltip = "Clear all flag values",
        Callback = function()
            tableClear(Library.Flags)
            -- Also reset each control via flag updaters? Already cleared flags, but controls still hold old values.
            -- We'll manually re-apply default values from flag updaters? Better to just notify.
            Library:Notify({ Title = "Flags Cleared", Message = "All flags have been reset. UI may not reflect until re-toggle.", Type = "Warning" })
        end,
    })

    -- Refresh config list on tab open
    local refreshConn
    ConfigTab._frame:GetPropertyChangedSignal("Visible"):Connect(function()
        if ConfigTab._frame.Visible then
            RefreshConfigList()
        end
    end)

    table.insert(Library._windows, Win)
    return Win
end

function Library:Destroy()
    pcall(function()
        local blur = game:GetService("Lighting"):FindFirstChild("_UILibBlur")
        if blur then blur:Destroy() end
    end)
    if self._tooltipConnection then
        self._tooltipConnection:Disconnect()
        self._tooltipConnection = nil
    end
    pcall(function() ScreenGui:Destroy() end)
end

return Library
