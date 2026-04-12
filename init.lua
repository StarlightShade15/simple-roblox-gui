-- ============================================================
--  _   _                     _                    
-- | \ | |                   | |                   
-- |  \| | _____   _____ _ __| |     ___  ___  ___ 
-- | . ` |/ _ \ \ / / _ \ '__| |    / _ \/ __|/ _ \
-- | |\  |  __/\ V /  __/ |  | |___| (_) \__ \  __/
-- \_| \_/\___| \_/ \___|_|  \_____/\___/|___/\___|
                                                
                                                
--
--   Neverlose-Style Premium UI Library
--   Modular version (fixed & cleaned)
-- ============================================================

local Library = {}
Library.__index = Library

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer

-- Constants
local DEFAULT_CORNER_RADIUS = 6
local DEFAULT_FONT = Enum.Font.GothamMedium
local POPUP_Z_INDEX = 1000
local TOOLTIP_Z_INDEX = 9999
local ANIMATION_TIME = 0.15
local EASING_STYLE = Enum.EasingStyle.Quad
local EASING_DIR = Enum.EasingDirection.Out

-- State
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

-- Import modules
local Utils = require(script.Parent.modules.Utils)
local ThemeManager = require(script.Parent.modules.ThemeManager)
local Tooltip = require(script.Parent.modules.Tooltip)
local Notification = require(script.Parent.modules.Notification)
local Watermark = require(script.Parent.modules.Watermark)
local ConfigManager = require(script.Parent.modules.ConfigManager)
local Window = require(script.Parent.modules.Window)

-- Inject dependencies into modules
ThemeManager.init(Library, Utils)
Tooltip.init(Library, Utils, UserInputService, TextService, TOOLTIP_Z_INDEX)
Notification.init(Library, Utils)
Watermark.init(Library, Utils)
ConfigManager.init(Library, Utils, HttpService)
Window.init(Library, Utils, ThemeManager, Tooltip, Notification, ConfigManager, TweenService, UserInputService, RunService, POPUP_Z_INDEX)

-- Create ScreenGui
local ScreenGui
do
    local sg = Instance.new("ScreenGui")
    sg.Name = "UILibrary_vNL"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = 9999
    sg.IgnoreGuiInset = true
    local ok = pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not ok then
        pcall(function() sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
    end
    ScreenGui = sg
end

-- Expose ScreenGui to modules
Window.setScreenGui(ScreenGui)
Notification.setScreenGui(ScreenGui)
Tooltip.setScreenGui(ScreenGui)
Watermark.setScreenGui(ScreenGui)

-- Public API
function Library:AddTheme(name, data)
    ThemeManager.addTheme(name, data)
end

function Library:Notify(opts)
    Notification.notify(opts)
end

function Library:SetWatermark(text)
    Watermark.set(text)
end

function Library:CreateWindow(opts)
    return Window.create(opts)
end

function Library:Destroy()
    -- Cleanup all windows and connections
    for _, win in ipairs(self._windows) do
        win:Close()
    end
    table.clear(self._windows)
    if self._tooltipConnection then
        self._tooltipConnection:Disconnect()
        self._tooltipConnection = nil
    end
    pcall(function() ScreenGui:Destroy() end)
end

return Library
