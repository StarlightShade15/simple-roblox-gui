local Tooltip = {}

local LibraryRef = nil
local UtilsRef = nil
local UserInputService = nil
local TextService = nil
local TOOLTIP_Z_INDEX = nil
local ScreenGui = nil

local ToolTipFrame = nil
local ToolTipLabel = nil
local connection = nil

function Tooltip.init(library, utils, uis, textSvc, zIndex)
    LibraryRef = library
    UtilsRef = utils
    UserInputService = uis
    TextService = textSvc
    TOOLTIP_Z_INDEX = zIndex
end

function Tooltip.setScreenGui(sg)
    ScreenGui = sg
    if not ToolTipFrame then
        ToolTipFrame = UtilsRef.New("Frame", {
            Name = "Tooltip",
            Size = UDim2.new(0, 160, 0, 26),
            BackgroundColor3 = LibraryRef.Themes[LibraryRef.CurrentTheme].Secondary,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = TOOLTIP_Z_INDEX,
            Parent = ScreenGui,
        })
        UtilsRef.Corner(ToolTipFrame, 6, LibraryRef)
        UtilsRef.Stroke(ToolTipFrame, LibraryRef.Themes[LibraryRef.CurrentTheme].Outline)
        UtilsRef.Padding(ToolTipFrame, 0, 0, 8, 8)
        ToolTipLabel = UtilsRef.New("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            TextColor3 = LibraryRef.Themes[LibraryRef.CurrentTheme].Text,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = TOOLTIP_Z_INDEX + 1,
            Parent = ToolTipFrame,
        })
        LibraryRef:RegisterListener(function(t)
            if ToolTipFrame then
                ToolTipFrame.BackgroundColor3 = t.Secondary
                ToolTipLabel.TextColor3 = t.Text
            end
        end)
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if ToolTipFrame and ToolTipFrame.Visible then
                local mp = UserInputService:GetMouseLocation()
                ToolTipFrame.Position = UDim2.new(0, mp.X + 14, 0, mp.Y + 8)
            end
        end)
        LibraryRef._tooltipConnection = connection
    end
end

function Tooltip.attach(element, text)
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

return Tooltip
