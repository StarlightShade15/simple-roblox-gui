local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local function MakeDraggable(topbarobject, object)
	local Dragging = nil
	local DragInput = nil
	local DragStart = nil
	local StartPosition = nil

	local function Update(input)
		local Delta = input.Position - DragStart
		local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
		object.Position = pos
	end

	topbarobject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = input.Position
			StartPosition = object.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	topbarobject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			DragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			Update(input)
		end
	end)
end

function Library:CreateWindow(titleText)
	local Window = {}
	
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "UILibrary_" .. tostring(math.random(1000, 9999))
	ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	ScreenGui.ResetOnSpawn = false

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 600, 0, 400)
	MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
	MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	MainFrame.BorderSizePixel = 0
	MainFrame.Parent = ScreenGui
	
	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 6)
	MainCorner.Parent = MainFrame
	
	local Topbar = Instance.new("Frame")
	Topbar.Name = "Topbar"
	Topbar.Size = UDim2.new(1, 0, 0, 40)
	Topbar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	Topbar.BorderSizePixel = 0
	Topbar.Parent = MainFrame
	
	local TopbarCorner = Instance.new("UICorner")
	TopbarCorner.CornerRadius = UDim.new(0, 6)
	TopbarCorner.Parent = Topbar

	local TopbarFiller = Instance.new("Frame")
	TopbarFiller.Size = UDim2.new(1, 0, 0, 10)
	TopbarFiller.Position = UDim2.new(0, 0, 1, -10)
	TopbarFiller.BackgroundColor3 = Topbar.BackgroundColor3
	TopbarFiller.BorderSizePixel = 0
	TopbarFiller.Parent = Topbar

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size = UDim2.new(1, -20, 1, 0)
	TitleLabel.Position = UDim2.new(0, 20, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = titleText
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextSize = 16
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = Topbar

	MakeDraggable(Topbar, MainFrame)

	local TabContainer = Instance.new("Frame")
	TabContainer.Name = "TabContainer"
	TabContainer.Size = UDim2.new(0, 150, 1, -40)
	TabContainer.Position = UDim2.new(0, 0, 0, 40)
	TabContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	TabContainer.BorderSizePixel = 0
	TabContainer.Parent = MainFrame
	
	local TabContainerCorner = Instance.new("UICorner")
	TabContainerCorner.CornerRadius = UDim.new(0, 6)
	TabContainerCorner.Parent = TabContainer
	
	local TabFiller = Instance.new("Frame")
	TabFiller.Size = UDim2.new(0, 10, 0, 10)
	TabFiller.Position = UDim2.new(1, -10, 0, 0)
	TabFiller.BackgroundColor3 = TabContainer.BackgroundColor3
	TabFiller.BorderSizePixel = 0
	TabFiller.Parent = TabContainer

	local TabListLayout = Instance.new("UIListLayout")
	TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TabListLayout.Padding = UDim.new(0, 5)
	TabListLayout.Parent = TabContainer
	
	local TabPadding = Instance.new("UIPadding")
	TabPadding.PaddingTop = UDim.new(0, 10)
	TabPadding.PaddingLeft = UDim.new(0, 10)
	TabPadding.Parent = TabContainer

	local PageContainer = Instance.new("Frame")
	PageContainer.Name = "PageContainer"
	PageContainer.Size = UDim2.new(1, -160, 1, -50)
	PageContainer.Position = UDim2.new(0, 160, 0, 45)
	PageContainer.BackgroundTransparency = 1
	PageContainer.Parent = MainFrame

	function Window:Toggle(bool)
		ScreenGui.Enabled = bool
	end
	
	function Window:Destroy()
		ScreenGui:Destroy()
	end

	local FirstTab = true
	
	function Window:CreateTab(tabName)
		local Tab = {}
		
		-- Tab Button
		local TabButton = Instance.new("TextButton")
		TabButton.Name = tabName .. "Button"
		TabButton.Size = UDim2.new(1, -10, 0, 30)
		TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40) -- Unselected
		TabButton.Text = tabName
		TabButton.Font = Enum.Font.Gotham
		TabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
		TabButton.TextSize = 14
		TabButton.Parent = TabContainer
		
		local TabCorner = Instance.new("UICorner")
		TabCorner.CornerRadius = UDim.new(0, 4)
		TabCorner.Parent = TabButton

		-- Page (ScrollingFrame)
		local Page = Instance.new("ScrollingFrame")
		Page.Name = tabName .. "Page"
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 4
		Page.Visible = false
		Page.Parent = PageContainer
		
		local PageLayout = Instance.new("UIListLayout")
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PageLayout.Padding = UDim.new(0, 10)
		PageLayout.Parent = Page
		
		local PagePadding = Instance.new("UIPadding")
		PagePadding.PaddingRight = UDim.new(0, 10)
		PagePadding.Parent = Page

		PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y)
		end)

		if FirstTab then
			FirstTab = false
			Page.Visible = true
			TabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		end

		TabButton.MouseButton1Click:Connect(function()
			for _, child in pairs(PageContainer:GetChildren()) do
				if child:IsA("ScrollingFrame") then child.Visible = false end
			end
			for _, child in pairs(TabContainer:GetChildren()) do
				if child:IsA("TextButton") then
					TweenService:Create(child, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40), TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
				end
			end
			Page.Visible = true
			TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
		end)



		function Tab:CreateSection(sectionName)
			local Section = {}
			
			local SectionFrame = Instance.new("Frame")
			SectionFrame.Name = "Section"
			SectionFrame.Size = UDim2.new(1, 0, 0, 30) -- Height scales automatically
			SectionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			SectionFrame.Parent = Page
			
			local SectionCorner = Instance.new("UICorner")
			SectionCorner.CornerRadius = UDim.new(0, 4)
			SectionCorner.Parent = SectionFrame
			
			local SectionList = Instance.new("UIListLayout")
			SectionList.SortOrder = Enum.SortOrder.LayoutOrder
			SectionList.Padding = UDim.new(0, 5)
			SectionList.Parent = SectionFrame
			
			local SectionPadding = Instance.new("UIPadding")
			SectionPadding.PaddingTop = UDim.new(0, 10)
			SectionPadding.PaddingBottom = UDim.new(0, 10)
			SectionPadding.PaddingLeft = UDim.new(0, 10)
			SectionPadding.PaddingRight = UDim.new(0, 10)
			SectionPadding.Parent = SectionFrame

			local SectionTitle = Instance.new("TextLabel")
			SectionTitle.Text = sectionName
			SectionTitle.Size = UDim2.new(1, 0, 0, 20)
			SectionTitle.BackgroundTransparency = 1
			SectionTitle.Font = Enum.Font.GothamBold
			SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
			SectionTitle.TextSize = 14
			SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
			SectionTitle.Parent = SectionFrame

			SectionList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				SectionFrame.Size = UDim2.new(1, 0, 0, SectionList.AbsoluteContentSize.Y + 20)
			end)



			function Section:CreateButton(text, callback)
				callback = callback or function() end
				
				local Button = Instance.new("TextButton")
				Button.Name = "Button"
				Button.Size = UDim2.new(1, 0, 0, 30)
				Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
				Button.Text = text
				Button.Font = Enum.Font.Gotham
				Button.TextColor3 = Color3.fromRGB(255, 255, 255)
				Button.TextSize = 14
				Button.Parent = SectionFrame
				
				local BtnCorner = Instance.new("UICorner")
				BtnCorner.CornerRadius = UDim.new(0, 4)
				BtnCorner.Parent = Button

				Button.MouseButton1Click:Connect(function()
					callback()
					-- Click Animation
					TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
					task.wait(0.1)
					TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
				end)
			end
			
			function Section:CreateToggle(text, default, callback)
				callback = callback or function() end
				local toggled = default or false

				local ToggleFrame = Instance.new("Frame")
				ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
				ToggleFrame.BackgroundTransparency = 1
				ToggleFrame.Parent = SectionFrame

				local ToggleLabel = Instance.new("TextLabel")
				ToggleLabel.Text = text
				ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
				ToggleLabel.BackgroundTransparency = 1
				ToggleLabel.Font = Enum.Font.Gotham
				ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
				ToggleLabel.TextSize = 14
				ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
				ToggleLabel.Parent = ToggleFrame

				local ToggleBtn = Instance.new("TextButton")
				ToggleBtn.Size = UDim2.new(0, 24, 0, 24)
				ToggleBtn.Position = UDim2.new(1, -24, 0.5, -12)
				ToggleBtn.BackgroundColor3 = toggled and Color3.fromRGB(55, 255, 55) or Color3.fromRGB(60, 60, 60)
				ToggleBtn.Text = ""
				ToggleBtn.Parent = ToggleFrame
				
				local ToggleCorner = Instance.new("UICorner")
				ToggleCorner.CornerRadius = UDim.new(0, 4)
				ToggleCorner.Parent = ToggleBtn

				ToggleBtn.MouseButton1Click:Connect(function()
					toggled = not toggled
					
					local targetColor = toggled and Color3.fromRGB(55, 255, 55) or Color3.fromRGB(60, 60, 60)
					TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
					
					callback(toggled)
				end)
			end
			
			function Section:CreateSlider(text, min, max, default, callback)
				callback = callback or function() end
				local value = default or min

				local SliderFrame = Instance.new("Frame")
				SliderFrame.Size = UDim2.new(1, 0, 0, 50)
				SliderFrame.BackgroundTransparency = 1
				SliderFrame.Parent = SectionFrame

				local SliderLabel = Instance.new("TextLabel")
				SliderLabel.Text = text
				SliderLabel.Size = UDim2.new(1, 0, 0, 20)
				SliderLabel.BackgroundTransparency = 1
				SliderLabel.Font = Enum.Font.Gotham
				SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
				SliderLabel.TextSize = 14
				SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
				SliderLabel.Parent = SliderFrame
				
				local ValueLabel = Instance.new("TextLabel")
				ValueLabel.Text = tostring(value)
				ValueLabel.Size = UDim2.new(1, 0, 0, 20)
				ValueLabel.BackgroundTransparency = 1
				ValueLabel.Font = Enum.Font.Gotham
				ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				ValueLabel.TextSize = 14
				ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
				ValueLabel.Parent = SliderFrame

				local SliderBar = Instance.new("Frame")
				SliderBar.Size = UDim2.new(1, 0, 0, 6)
				SliderBar.Position = UDim2.new(0, 0, 0, 30)
				SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
				SliderBar.BorderSizePixel = 0
				SliderBar.Parent = SliderFrame
				
				local BarCorner = Instance.new("UICorner")
				BarCorner.CornerRadius = UDim.new(1, 0)
				BarCorner.Parent = SliderBar

				local Fill = Instance.new("Frame")
				Fill.Size = UDim2.new((value - min)/(max - min), 0, 1, 0)
				Fill.BackgroundColor3 = Color3.fromRGB(55, 155, 255)
				Fill.BorderSizePixel = 0
				Fill.Parent = SliderBar
				
				local FillCorner = Instance.new("UICorner")
				FillCorner.CornerRadius = UDim.new(1, 0)
				FillCorner.Parent = Fill

				local Trigger = Instance.new("TextButton")
				Trigger.Size = UDim2.new(1, 0, 1, 0)
				Trigger.BackgroundTransparency = 1
				Trigger.Text = ""
				Trigger.Parent = SliderBar

				local isDragging = false

				local function updateSlider(input)
					local pos = UDim2.new(math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1), 0, 1, 0)
					Fill:TweenSize(pos, "Out", "Sine", 0.1, true)
					
					local result = math.floor(min + ((max - min) * pos.X.Scale))
					ValueLabel.Text = tostring(result)
					callback(result)
				end

				Trigger.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						isDragging = true
						updateSlider(input)
					end
				end)

				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						isDragging = false
					end
				end)

				UserInputService.InputChanged:Connect(function(input)
					if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						updateSlider(input)
					end
				end)
			end
			
			function Section:CreateDropdown(text, options, callback)
				callback = callback or function() end
				local isDropped = false
				
				local DropdownFrame = Instance.new("Frame")
				DropdownFrame.Size = UDim2.new(1, 0, 0, 35) -- Default size
				DropdownFrame.BackgroundTransparency = 1
				DropdownFrame.Parent = SectionFrame
				
				local DropdownBtn = Instance.new("TextButton")
				DropdownBtn.Size = UDim2.new(1, 0, 0, 30)
				DropdownBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
				DropdownBtn.Text = text .. " v"
				DropdownBtn.Font = Enum.Font.Gotham
				DropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				DropdownBtn.TextSize = 14
				DropdownBtn.Parent = DropdownFrame
				
				local DropCorner = Instance.new("UICorner")
				DropCorner.CornerRadius = UDim.new(0, 4)
				DropCorner.Parent = DropdownBtn
				
				local OptionContainer = Instance.new("Frame")
				OptionContainer.Size = UDim2.new(1, 0, 0, 0)
				OptionContainer.Position = UDim2.new(0, 0, 0, 35)
				OptionContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
				OptionContainer.Visible = false
				OptionContainer.ClipsDescendants = true
				OptionContainer.Parent = DropdownFrame
				
				local OptionList = Instance.new("UIListLayout")
				OptionList.SortOrder = Enum.SortOrder.LayoutOrder
				OptionList.Parent = OptionContainer
				
				local OptionCorner = Instance.new("UICorner")
				OptionCorner.CornerRadius = UDim.new(0, 4)
				OptionCorner.Parent = OptionContainer

				for _, option in pairs(options) do
					local OptionBtn = Instance.new("TextButton")
					OptionBtn.Size = UDim2.new(1, 0, 0, 25)
					OptionBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
					OptionBtn.Text = option
					OptionBtn.Font = Enum.Font.Gotham
					OptionBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
					OptionBtn.TextSize = 13
					OptionBtn.BorderSizePixel = 0
					OptionBtn.Parent = OptionContainer
					
					OptionBtn.MouseButton1Click:Connect(function()
						DropdownBtn.Text = text .. ": " .. option
						callback(option)
						-- Close dropdown
						isDropped = false
						OptionContainer.Visible = false
						DropdownFrame.Size = UDim2.new(1, 0, 0, 35)
					end)
				end
				
				DropdownBtn.MouseButton1Click:Connect(function()
					isDropped = not isDropped
					OptionContainer.Visible = isDropped
					
					if isDropped then
						local contentSize = OptionList.AbsoluteContentSize.Y
						DropdownFrame.Size = UDim2.new(1, 0, 0, 35 + contentSize)
						OptionContainer.Size = UDim2.new(1, 0, 0, contentSize)
					else
						DropdownFrame.Size = UDim2.new(1, 0, 0, 35)
					end
				end)
			end

			return Section
		end

		return Tab
	end

	return Window
end

return Library
