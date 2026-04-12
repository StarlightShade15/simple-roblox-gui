local Watermark = {}

local LibraryRef = nil
local UtilsRef = nil
local ScreenGui = nil
local watermarkLabel = nil

function Watermark.init(library, utils)
    LibraryRef = library
    UtilsRef = utils
end

function Watermark.setScreenGui(sg)
    ScreenGui = sg
end

function Watermark.set(text)
    if watermarkLabel then
        watermarkLabel.Text = text
        return
    end
    local theme = LibraryRef.Themes[LibraryRef.CurrentTheme]
    local bg = UtilsRef.New("Frame", {
        Name = "Watermark",
        Size = UDim2.new(0, 0, 0, 28),
        AutomaticSize = Enum.AutomaticSize.X,
        Position = UDim2.new(0, 10, 0, 8),
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        Parent = ScreenGui,
    })
    UtilsRef.Corner(bg, 6, LibraryRef)
    UtilsRef.Stroke(bg, theme.Outline)
    UtilsRef.Padding(bg, 0, 0, 10, 10)
    local lbl = UtilsRef.New("TextLabel", {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        Parent = bg,
    })
    watermarkLabel = lbl
    LibraryRef:RegisterListener(function(t)
        if bg and bg.Parent then
            bg.BackgroundColor3 = t.Secondary
            lbl.TextColor3 = t.Text
        end
    end)
end

return Watermark
