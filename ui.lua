--[[
    UI Library ModuleScript (UILibrary)

    This module provides an object-oriented API for building complex UIs with
    cascading structure: Window -> Tab -> Section -> Component.
]]

local ui = {}
local Players = game:GetService("Players")

-- Configuration constants
local C = {
    -- Colors
    PRIMARY_BG = Color3.fromRGB(40, 44, 52),
    SECONDARY_BG = Color3.fromRGB(48, 52, 60), -- Tab/Section background
    HEADER_BG = Color3.fromRGB(24, 25, 29),
    ACCENT = Color3.fromRGB(85, 170, 255),
    TEXT_COLOR = Color3.fromRGB(255, 255, 255),

    -- Sizes & Spacing
    WINDOW_SIZE = UDim2.new(0.3, 0, 0.5, 0),
    HEADER_HEIGHT = 30,
    PADDING_SIZE = 8,
    COMPONENT_HEIGHT = 30,
    CORNER_RADIUS = UDim.new(0, 8),
    SMALL_CORNER_RADIUS = UDim.new(0, 5),
}

-- Private Helper Functions (Instance Creation)
local function createInstance(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do
        inst[k] = v
    end
    return inst
end

local function applyCorners(instance, radius)
    local corner = createInstance("UICorner", {
        CornerRadius = radius or C.SMALL_CORNER_RADIUS,
        Parent = instance,
    })
    return corner
end

local function setupDraggable(frame, dragHandle)
    local dragging = false
    local dragStartPos = Vector2.new(0, 0)
    local frameStartPos = UDim2.new(0, 0, 0, 0)

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStartPos = input.Position
            frameStartPos = frame.Position
        end
    end)

    dragHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStartPos
            local parentSize = frame.Parent.AbsoluteSize
            local newX = frameStartPos.X.Scale + delta.X / parentSize.X
            local newY = frameStartPos.Y.Scale + delta.Y / parentSize.Y
            frame.Position = UDim2.new(newX, 0, newY, 0)
        end
    end)
end

-- ====================================================================
-- Component Metatables (Base Components)
-- ====================================================================

ui.Component = {}

-- [[ Label Component ]] ----------------------------------------------
ui.Component.Label = { __index = ui.Component.Label }

function ui.Component.Label:edit(new_text: string)
    self.Instance.Text = new_text
end

function ui.Component.Label.new(parent, content: string)
    local self = setmetatable({
        Instance = createInstance("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = content,
            Font = Enum.Font.SourceSans,
            TextColor3 = C.TEXT_COLOR,
            TextSize = 16,
            Parent = parent,
        }),
    }, ui.Component.Label)
    return self
end

-- [[ Button Component ]] ---------------------------------------------
ui.Component.Button = { __index = ui.Component.Button }

function ui.Component.Button.new(parent, name: string, callback: function)
    local Button = createInstance("TextButton", {
        Name = name .. "Button",
        Text = name,
        Size = UDim2.new(1, 0, 0, C.COMPONENT_HEIGHT),
        BackgroundColor3 = C.ACCENT,
        Font = Enum.Font.SourceSansBold,
        TextColor3 = C.TEXT_COLOR,
        TextSize = 18,
        Parent = parent,
    })
    applyCorners(Button, C.SMALL_CORNER_RADIUS)

    Button.MouseButton1Click:Connect(callback)

    local self = setmetatable({
        Instance = Button,
    }, ui.Component.Button)
    return self
end

-- [[ Toggle Component ]] ---------------------------------------------
ui.Component.Toggle = { __index = ui.Component.Toggle }

function ui.Component.Toggle.new(parent, name: string, callback: function)
    local Frame = createInstance("Frame", {
        Name = name .. "ToggleContainer",
        Size = UDim2.new(1, 0, 0, C.COMPONENT_HEIGHT),
        BackgroundTransparency = 1,
        Parent = parent,
    })

    -- Layout the components inside the frame
    local ListLayout = createInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, C.PADDING_SIZE),
        Parent = Frame,
    })

    -- Label
    local Label = createInstance("TextLabel", {
        Name = "Label",
        Text = name,
        Size = UDim2.new(1, -30, 1, 0), -- Takes remaining space
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        TextColor3 = C.TEXT_COLOR,
        TextSize = 16,
        Parent = Frame,
    })

    -- Toggle Button
    local IsOn = false
    local ToggleButton = createInstance("TextButton", {
        Name = "Toggle",
        Text = "OFF",
        Size = UDim2.new(0, 45, 1, 0),
        BackgroundColor3 = Color3.fromRGB(150, 40, 40), -- Default RED (Off)
        Font = Enum.Font.SourceSansBold,
        TextColor3 = C.TEXT_COLOR,
        TextSize = 16,
        Parent = Frame,
    })
    applyCorners(ToggleButton, C.SMALL_CORNER_RADIUS)

    local function updateState()
        IsOn = not IsOn
        if IsOn then
            ToggleButton.Text = "ON"
            ToggleButton.BackgroundColor3 = C.ACCENT
        else
            ToggleButton.Text = "OFF"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        end
        callback(IsOn)
    end

    ToggleButton.MouseButton1Click:Connect(updateState)

    local self = setmetatable({
        Instance = Frame,
        Toggle = ToggleButton,
        IsOn = IsOn,
        -- Expose a way to manually change the state if needed
        toggle = updateState,
    }, ui.Component.Toggle)
    return self
end

-- [[ Slider Component ]] ---------------------------------------------
ui.Component.Slider = { __index = ui.Component.Slider }

function ui.Component.Slider.new(parent, name: string, min: number, max: number, precision: number, callback: function)
    local Container = createInstance("Frame", {
        Name = name .. "SliderContainer",
        Size = UDim2.new(1, 0, 0, C.COMPONENT_HEIGHT + 20), -- More height for label and slider
        BackgroundTransparency = 1,
        Parent = parent,
    })

    local TitleLabel = ui.Component.Label.new(Container, name)
    TitleLabel.Instance.Size = UDim2.new(1, 0, 0, 20)
    TitleLabel.Instance.TextYAlignment = Enum.TextYAlignment.Top

    -- Value Display Label (updates with slider)
    local ValueLabel = ui.Component.Label.new(Container, string.format("%." .. precision .. "f", min))
    ValueLabel.Instance.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Instance.Size = UDim2.new(1, 0, 0, 20)
    ValueLabel.Instance.Position = UDim2.new(0, 0, 0, 0)
    
    -- Slider Bar (Frame)
    local SliderBar = createInstance("Frame", {
        Name = "Bar",
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundColor3 = C.SECONDARY_BG,
        Parent = Container,
    })
    applyCorners(SliderBar)

    -- Slider Thumb (Button)
    local Thumb = createInstance("TextButton", {
        Name = "Thumb",
        Text = "",
        Size = UDim2.new(0, 15, 1.5, 0),
        Position = UDim2.new(0, 0, -0.25, 0), -- Slightly overlap top/bottom
        BackgroundColor3 = C.ACCENT,
        Parent = SliderBar,
    })
    applyCorners(Thumb)

    local IsDragging = false
    local currentNormalizedValue = 0

    local function updateValue(normalized)
        -- Clamp between 0 and 1
        normalized = math.max(0, math.min(1, normalized))

        -- Calculate actual value
        local value = min + normalized * (max - min)
        local formattedValue = string.format("%." .. precision .. "f", value)
        
        -- Update UI
        Thumb.Position = UDim2.new(normalized, 0, -0.25, 0)
        ValueLabel.Instance.Text = formattedValue
        currentNormalizedValue = normalized

        -- Execute callback
        callback(value)
    end
    
    -- Initialize
    updateValue(0)

    -- Draggable Logic
    Thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            IsDragging = true
        end
    end)
    
    Thumb.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            IsDragging = false
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if IsDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local localPos = SliderBar:WorldToScreenPoint(input.Position)
            local sliderX = SliderBar.AbsolutePosition.X
            local sliderWidth = SliderBar.AbsoluteSize.X
            
            local mouseX = input.Position.X
            local normalizedX = (mouseX - sliderX) / sliderWidth
            
            updateValue(normalizedX)
        end
    end)

    local self = setmetatable({
        Instance = Container,
        ValueLabel = ValueLabel.Instance,
        SliderBar = SliderBar,
        Thumb = Thumb,
        min = min,
        max = max,
        precision = precision,
    }, ui.Component.Slider)
    return self
end

-- ====================================================================
-- Structural Metatables
-- ====================================================================

-- [[ Section Metatable ]] --------------------------------------------
ui.Section = { __index = ui.Section }

function ui.Section:createSlider(name: string, min: number, max: number, precision: number, callback: function)
    return ui.Component.Slider.new(self.Instance, name, min, max, precision, callback)
end

function ui.Section:createToggle(name: string, callback: function)
    return ui.Component.Toggle.new(self.Instance, name, callback)
end

function ui.Section:createButton(name: string, callback: function)
    return ui.Component.Button.new(self.Instance, name, callback)
end

function ui.Section:createLabel(content: string)
    return ui.Component.Label.new(self.Instance, content)
end

function ui.Section.new(parent, name: string)
    local Frame = createInstance("Frame", {
        Name = name .. "Section",
        Size = UDim2.new(1, 0, 0, 0), -- Auto size Y, full width
        BackgroundColor3 = C.SECONDARY_BG,
        BorderSizePixel = 0,
        Parent = parent,
    })
    applyCorners(Frame)

    createInstance("UIPadding", {
        PaddingTop = UDim.new(0, C.PADDING_SIZE),
        PaddingBottom = UDim.new(0, C.PADDING_SIZE),
        PaddingLeft = UDim.new(0, C.PADDING_SIZE),
        PaddingRight = UDim.new(0, C.PADDING_SIZE),
        Parent = Frame,
    })

    createInstance("UIListLayout", {
        Name = "SectionLayout",
        Padding = UDim.new(0, C.PADDING_SIZE),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Frame,
    })

    createInstance("UISizeConstraint", {
        MinSize = Vector2.new(100, 50),
        Parent = Frame
    })

    local self = setmetatable({
        Name = name,
        Instance = Frame,
    }, ui.Section)
    return self
end

-- [[ Tab Metatable ]] ------------------------------------------------
ui.Tab = { __index = ui.Tab }

function ui.Tab:createSection(name: string)
    return ui.Section.new(self.Instance, name or "Section")
end

function ui.Tab.new(parent, name: string)
    local Frame = createInstance("Frame", {
        Name = name .. "Tab",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false, -- Default hidden
        Parent = parent,
    })

    -- Setup layout for sections
    createInstance("UIListLayout", {
        Name = "TabLayout",
        Padding = UDim.new(0, C.PADDING_SIZE),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Frame,
    })

    local self = setmetatable({
        Name = name,
        Instance = Frame,
    }, ui.Tab)
    return self
end

-- [[ Window Metatable ]] ---------------------------------------------
ui.Window = { __index = ui.Window }

function ui.Window:createTab(name: string)
    -- Create button for the tab bar
    local TabButton = createInstance("TextButton", {
        Name = name .. "TabButton",
        Text = name,
        Size = UDim2.new(0, 100, 1, 0),
        BackgroundColor3 = C.SECONDARY_BG,
        Font = Enum.Font.SourceSansBold,
        TextColor3 = C.TEXT_COLOR,
        TextSize = 16,
        Parent = self.TabContainer,
    })
    applyCorners(TabButton, C.SMALL_CORNER_RADIUS)

    -- Create the actual tab content frame
    local NewTab = ui.Tab.new(self.ContentArea, name)
    self.Tabs[name] = NewTab

    -- Tab switching logic
    local function activateTab()
        -- Deactivate all other tabs
        for _, tab in pairs(self.Tabs) do
            tab.Instance.Visible = false
        end

        -- Activate the new tab
        NewTab.Instance.Visible = true
        self.CurrentTab = name
        
        -- Update button colors
        for tabName, tab in pairs(self.Tabs) do
            local button = self.TabContainer:FindFirstChild(tabName .. "TabButton")
            if button then
                button.BackgroundColor3 = (tabName == name) and C.ACCENT or C.SECONDARY_BG
            end
        end
    end

    TabButton.MouseButton1Click:Connect(activateTab)

    -- If this is the first tab, activate it
    if #self.Tabs == 1 then
        activateTab()
    end

    return NewTab
end

function ui.Window.new(title: string)
    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then return nil end
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

    -- 1. ScreenGui
    local ScreenGui = createInstance("ScreenGui", { Name = title:gsub("%s+", "") .. "Screen", IgnoreGuiInset = true, Parent = PlayerGui })

    -- 2. MainFrame (Window Container)
    local MainFrame = createInstance("Frame", {
        Name = "MainWindow",
        Size = C.WINDOW_SIZE,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = C.PRIMARY_BG,
        BorderSizePixel = 2,
        BorderColor3 = C.HEADER_BG,
        Parent = ScreenGui,
    })
    applyCorners(MainFrame, C.CORNER_RADIUS)
    
    -- 3. Header Frame
    local Header = createInstance("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, C.HEADER_HEIGHT),
        BackgroundColor3 = C.HEADER_BG,
        BorderSizePixel = 0,
        Parent = MainFrame,
    })
    createInstance("TextLabel", {
        Name = "Title",
        Text = title,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSansBold,
        TextColor3 = C.TEXT_COLOR,
        TextSize = 18,
        Parent = Header,
    })
    setupDraggable(MainFrame, Header)

    -- 4. Tab Container (for buttons)
    local TabContainer = createInstance("Frame", {
        Name = "TabButtons",
        Size = UDim2.new(1, 0, 0, C.COMPONENT_HEIGHT),
        Position = UDim2.new(0, 0, 0, C.HEADER_HEIGHT),
        BackgroundTransparency = 1,
        Parent = MainFrame,
    })
    createInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, C.PADDING_SIZE),
        Parent = TabContainer,
    })

    -- 5. Content Area (for tab content)
    local ContentArea = createInstance("Frame", {
        Name = "TabContent",
        Size = UDim2.new(1, 0, 1, -(C.HEADER_HEIGHT + C.COMPONENT_HEIGHT + C.PADDING_SIZE)), -- Header + TabBar height
        Position = UDim2.new(0, 0, 0, C.HEADER_HEIGHT + C.COMPONENT_HEIGHT + C.PADDING_SIZE),
        BackgroundTransparency = 1,
        Parent = MainFrame,
    })
    
    local self = setmetatable({
        Instance = MainFrame,
        ScreenGui = ScreenGui,
        Header = Header,
        TabContainer = TabContainer,
        ContentArea = ContentArea,
        Tabs = {},
        CurrentTab = nil,
    }, ui.Window)
    return self
end

-- ====================================================================
-- Public API
-- ====================================================================

function ui:Init(title: string)
    return ui.Window.new(title)
end

return ui
