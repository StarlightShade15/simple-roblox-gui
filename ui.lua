local mod = {}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Internal Helper: Draggable logic
local function makeDraggable(frame)
	local dragging, dragInput, dragStart, startPos
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true; dragStart = input.Position; startPos = frame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
end

-- Main Init
function mod.init(title)
	local sg = Instance.new("ScreenGui", playerGui)
	sg.Name = title
	
	local main = Instance.new("Frame", sg)
	main.Size = UDim2.new(0, 450, 0, 300)
	main.Position = UDim2.new(0.5, -225, 0.5, -150)
	main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	main.BorderSizePixel = 0
	makeDraggable(main)
	
	local corner = Instance.new("UICorner", main)
	corner.CornerRadius = UDim.new(0, 8)
	
	-- Sidebar
	local sidebar = Instance.new("Frame", main)
	sidebar.Size = UDim2.new(0, 120, 1, -40)
	sidebar.Position = UDim2.new(0, 10, 0, 30)
	sidebar.BackgroundTransparency = 1
	
	local sideLayout = Instance.new("UIListLayout", sidebar)
	sideLayout.Padding = UDim.new(0, 5)
	
	-- Content Area
	local container = Instance.new("Frame", main)
	container.Size = UDim2.new(1, -150, 1, -40)
	container.Position = UDim2.new(0, 140, 0, 30)
	container.BackgroundTransparency = 1
	
	local titleL = Instance.new("TextLabel", main)
	titleL.Text = title:upper()
	titleL.Size = UDim2.new(0, 120, 0, 30)
	titleL.BackgroundTransparency = 1
	titleL.TextColor3 = Color3.fromRGB(160, 100, 255)
	titleL.Font = Enum.Font.GothamBold
	titleL.TextSize = 14
	
	return {main = main, sidebar = sidebar, container = container}
end

-- Component: Tab
function mod.addTab(ui, name)
	local tabBtn = Instance.new("TextButton", ui.sidebar)
	tabBtn.Size = UDim2.new(1, 0, 0, 30)
	tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	tabBtn.Text = name
	tabBtn.TextColor3 = Color3.new(1,1,1)
	tabBtn.Font = Enum.Font.Gotham
	tabBtn.TextSize = 12
	Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 4)
	
	local page = Instance.new("ScrollingFrame", ui.container)
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.ScrollBarThickness = 2
	page.ScrollBarImageColor3 = Color3.fromRGB(160, 100, 255)
	
	local layout = Instance.new("UIListLayout", page)
	layout.Padding = UDim.new(0, 8)
	
	tabBtn.MouseButton1Click:Connect(function()
		for _, v in pairs(ui.container:GetChildren()) do v.Visible = false end
		page.Visible = true
	end)
	
	return page
end

-- Component: Section
function mod.addSection(parent, text)
	local label = Instance.new("TextLabel", parent)
	label.Size = UDim2.new(1, 0, 0, 20)
	label.Text = "  " .. text:upper()
	label.TextColor3 = Color3.fromRGB(100, 100, 110)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 10
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
end

-- Component: Button
function mod.addButton(parent, text, callback)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(1, -10, 0, 35)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	btn.Text = text
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 13
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	
	btn.MouseButton1Click:Connect(callback)
end

-- Component: Slider
function mod.addSlider(parent, text, min, max, callback)
	local sliderFrame = Instance.new("Frame", parent)
	sliderFrame.Size = UDim2.new(1, -10, 0, 45)
	sliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	Instance.new("UICorner", sliderFrame)
	
	local label = Instance.new("TextLabel", sliderFrame)
	label.Text = "  " .. text
	label.Size = UDim2.new(1, 0, 0, 20)
	label.TextColor3 = Color3.new(1,1,1)
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	
	local bar = Instance.new("Frame", sliderFrame)
	bar.Size = UDim2.new(0.9, 0, 0, 4)
	bar.Position = UDim2.new(0.05, 0, 0.7, 0)
	bar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	
	local fill = Instance.new("Frame", bar)
	fill.Size = UDim2.new(0.5, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(160, 100, 255)
	
	local function update(input)
		local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		fill.Size = UDim2.new(pos, 0, 1, 0)
		local value = math.floor(min + (max - min) * pos)
		callback(value)
	end
	
	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then update(input) end
	end)
end

-- Component: Text Input
function mod.addInput(parent, placeholder, callback)
	local box = Instance.new("TextBox", parent)
	box.Size = UDim2.new(1, -10, 0, 35)
	box.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	box.PlaceholderText = placeholder
	box.Text = ""
	box.TextColor3 = Color3.new(1,1,1)
	box.Font = Enum.Font.Gotham
	Instance.new("UICorner", box)
	
	box.FocusLost:Connect(function(enter)
		if enter then callback(box.Text) end
	end)
end

return mod
