local ThemeManager = {}

local Themes = {
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
}local LibraryRef = nil
local UtilsRef = nil

function ThemeManager.init(library, utils)
    LibraryRef = library
    UtilsRef = utils
    LibraryRef.Themes = Themes
end

function ThemeManager.getCurrent()
    return LibraryRef.Themes[LibraryRef.CurrentTheme]
end

function ThemeManager.addTheme(name, data)
    local base = {}
    for k, v in pairs(Themes.Dark) do base[k] = v end
    for k, v in pairs(data) do base[k] = v end
    Themes[name] = base
end

function ThemeManager.registerListener(fn)
    local listener = { func = fn }
    table.insert(LibraryRef._themeListeners, listener)
    return function()
        for i, v in ipairs(LibraryRef._themeListeners) do
            if v == listener then
                table.remove(LibraryRef._themeListeners, i)
                break
            end
        end
    end
end

function ThemeManager.fireTheme()
    local theme = ThemeManager.getCurrent()
    for _, listener in ipairs(LibraryRef._themeListeners) do
        UtilsRef.safePCall(listener.func, theme)
    end
end

return ThemeManager
