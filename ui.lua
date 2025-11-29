--[[
    UI Library ModuleScript (UILibrary)

    This module provides a simple, single-function API for initializing a styled,
    centered, and titled UI window on the client side.

    To use:
    1. Place this ModuleScript in ReplicatedStorage or a similar accessible location.
    2. Require it in a LocalScript:
       local ui = require(game.ReplicatedStorage.UILibrary)
    3. Initialize the window:
       local mainWindow = ui.Init("My Awesome Tool")
       -- Now 'mainWindow' is the main Frame, ready for content.
]]

local ui = {}
local Players = game:GetService("Players")

-- Configuration constants for styling
local UI_CONFIG = {
    Size = UDim2.new(0.3, 0, 0.5, 0), -- 30% width, 50% height
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0), -- Centered
    BackgroundColor = Color3.fromRGB(40, 44, 52), -- Dark grey
    BorderColor = Color3.fromRGB(24, 25, 29),
    BorderSizePixel = 2,
    CornerRadius = UDim.new(0, 8),
    HeaderHeight = UDim2.new(0, 30),
    TitleTextColor = Color3.fromRGB(255, 255, 255),
    TitleTextSize = 18,
}

--- Initializes the main UI window.
-- @param title string: The title to display on the window header.
-- @return Instance: The main content Frame of the UI.
function ui.Init(title: string)
    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then
        warn("UILibrary.Init() called without a LocalPlayer. UI can only be initialized on the client.")
        return nil
    end

    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

    -- 1. Create the ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = title:gsub("%s+", "") .. "Screen" -- Simple name sanitization
    ScreenGui.IgnoreGuiInset = true -- Better for full-screen UI
    ScreenGui.Parent = PlayerGui

    -- 2. Create the main window Frame (Container)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainWindow"
    MainFrame.Size = UI_CONFIG.Size
    MainFrame.AnchorPoint = UI_CONFIG.AnchorPoint
    MainFrame.Position = UI_CONFIG.Position
    MainFrame.BackgroundColor3 = UI_CONFIG.BackgroundColor
    MainFrame.BorderSizePixel = UI_CONFIG.BorderSizePixel
    MainFrame.BorderColor3 = UI_CONFIG.BorderColor
    MainFrame.Parent = ScreenGui

    -- Add rounded corners to the main frame
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UI_CONFIG.CornerRadius
    UICorner.Parent = MainFrame

    -- 3. Create the Header Frame
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 30) -- Full width, fixed height
    Header.Position = UDim2.new(0, 0, 0, 0)
    Header.BackgroundColor3 = UI_CONFIG.BorderColor -- Slightly darker color
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    -- Add rounded corners to the top of the header only (using clip descendants)
    local UICornerHeader = Instance.new("UICorner")
    UICornerHeader.CornerRadius = UI_CONFIG.CornerRadius
    UICornerHeader.Parent = Header

    -- 4. Create the Title Label
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, 0, 1, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.Text = title
    TitleLabel.TextColor3 = UI_CONFIG.TitleTextColor
    TitleLabel.TextSize = UI_CONFIG.TitleTextSize
    TitleLabel.Parent = Header

    -- 5. Create a content area (to allow for header/content separation)
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "Content"
    ContentFrame.Size = UDim2.new(1, 0, 1, -30) -- Full width, remaining height
    ContentFrame.Position = UDim2.new(0, 0, 0, 30) -- Below the header
    ContentFrame.BackgroundColor3 = UI_CONFIG.BackgroundColor
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = MainFrame

    -- Optional: Add basic dragging functionality to the Header
    local function setupDraggable(element, dragHandle)
        local dragging = false
        local dragStartPos = Vector2.new(0, 0)
        local frameStartPos = UDim2.new(0, 0, 0, 0)

        dragHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStartPos = input.Position
                frameStartPos = element.Position
                input.Handled = true
            end
        end)

        dragHandle.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStartPos
                local newX = frameStartPos.X.Scale + delta.X / element.Parent.AbsoluteSize.X
                local newY = frameStartPos.Y.Scale + delta.Y / element.Parent.AbsoluteSize.Y
                element.Position = UDim2.new(newX, 0, newY, 0)
            end
        end)
    end

    setupDraggable(MainFrame, Header)

    -- Return the ContentFrame, as this is where the developer will add their widgets
    return ContentFrame
end

return ui
