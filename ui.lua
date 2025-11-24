local UILib = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local function createUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UILibraryGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Title.BorderSizePixel = 0
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 24
    Title.Text = "UI Library"
    Title.Parent = MainFrame

    local Tabs = {}
    local function addTab(tabName)
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(0, 100, 0, 30)
        TabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextSize = 18
        TabButton.Text = tabName
        TabButton.Parent = MainFrame

        local TabContent = Instance.new("Frame")
        TabContent.Size = UDim2.new(1, 0, 1, -50)
        TabContent.Position = UDim2.new(0, 0, 0, 50)
        TabContent.BackgroundTransparency = 1
        TabContent.Visible = false
        TabContent.Parent = MainFrame

        Tabs[tabName] = TabContent

        local SectionContainer = {}
        local function addSection(sectionName)
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Size = UDim2.new(1, -20, 0, 100)
            SectionFrame.Position = UDim2.new(0, 10, 0, (#SectionContainer * 110))
            SectionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            SectionFrame.BorderSizePixel = 0
            SectionFrame.Parent = TabContent

            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Size = UDim2.new(1, 0, 0, 30)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Text = sectionName
            SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.TextSize = 18
            SectionTitle.Parent = SectionFrame

            local Elements = {}

            local function addCheck(config)
                local CheckBox = Instance.new("TextButton")
                CheckBox.Size = UDim2.new(1, -20, 0, 25)
                CheckBox.Position = UDim2.new(0, 10, 0, 40 + (#Elements * 35))
                CheckBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                CheckBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                CheckBox.Font = Enum.Font.Gotham
                CheckBox.TextSize = 16
                CheckBox.Text = config.Text .. ": " .. tostring(config.Default)
                CheckBox.Parent = SectionFrame

                local state = config.Default
                CheckBox.MouseButton1Click:Connect(function()
                    state = not state
                    CheckBox.Text = config.Text .. ": " .. tostring(state)
                    if config.Callback then
                        config.Callback(state)
                    end
                end)
            end

            local function addDropdown(config)
                local Dropdown = Instance.new("TextButton")
                Dropdown.Size = UDim2.new(1, -20, 0, 25)
                Dropdown.Position = UDim2.new(0, 10, 0, 40 + (#Elements * 35))
                Dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                Dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
                Dropdown.Font = Enum.Font.Gotham
                Dropdown.TextSize = 16
                Dropdown.Text = config.Text .. ": " .. tostring(config.List[1])
                Dropdown.Parent = SectionFrame

                local selection = config.List[1]
                Dropdown.MouseButton1Click:Connect(function()
                    local nextIndex = table.find(config.List, selection) + 1
                    if nextIndex > #config.List then nextIndex = 1 end
                    selection = config.List[nextIndex]
                    Dropdown.Text = config.Text .. ": " .. tostring(selection)
                    if config.Callback then
                        config.Callback(selection)
                    end
                end)
            end

            local function addInput(config)
                local InputBox = Instance.new("TextBox")
                InputBox.Size = UDim2.new(1, -20, 0, 25)
                InputBox.Position = UDim2.new(0, 10, 0, 40 + (#Elements * 35))
                InputBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                InputBox.PlaceholderText = config.Placeholder or ""
                InputBox.Text = config.Default or ""
                InputBox.Font = Enum.Font.Gotham
                InputBox.TextSize = 16
                InputBox.Parent = SectionFrame

                InputBox.FocusLost:Connect(function(enterPressed)
                    if enterPressed and config.Callback then
                        config.Callback(InputBox.Text)
                    end
                end)
            end

            local function addColorPicker(config)
                local Picker = Instance.new("TextButton")
                Picker.Size = UDim2.new(1, -20, 0, 25)
                Picker.Position = UDim2.new(0, 10, 0, 40 + (#Elements * 35))
                Picker.BackgroundColor3 = config.Default or Color3.new(1, 1, 1)
                Picker.TextColor3 = Color3.fromRGB(255, 255, 255)
                Picker.Font = Enum.Font.Gotham
                Picker.TextSize = 16
                Picker.Text = config.Text
                Picker.Parent = SectionFrame

                local color = config.Default
                local alpha = config.DefaultAlpha or 1
                Picker.MouseButton1Click:Connect(function()
                    if config.Callback then
                        config.Callback(color, alpha)
                    end
                end)
            end

            table.insert(SectionContainer, {
                addCheck = addCheck,
                addDropdown = addDropdown,
                addInput = addInput,
                addColorPicker = addColorPicker
            })

            return SectionContainer[#SectionContainer]
        end

        return {
            addSection = addSection
        }
    end

    local function Toast(message, duration)
        duration = duration or 2
        local toastFrame = Instance.new("Frame")
        toastFrame.Size = UDim2.new(0, 300, 0, 50)
        toastFrame.Position = UDim2.new(0.5, -150, 0.8, 0)
        toastFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        toastFrame.Parent = ScreenGui

        local toastText = Instance.new("TextLabel")
        toastText.Size = UDim2.new(1, 0, 1, 0)
        toastText.BackgroundTransparency = 1
        toastText.TextColor3 = Color3.fromRGB(255, 255, 255)
        toastText.Text = message
        toastText.Font = Enum.Font.Gotham
        toastText.TextSize = 16
        toastText.Parent = toastFrame

        TweenService:Create(toastFrame, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -150, 0.7, 0)}):Play()
        task.delay(duration, function()
            TweenService:Create(toastFrame, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -150, 0.8, 0)}):Play()
            task.wait(0.3)
            toastFrame:Destroy()
        end)
    end

    return {
        init = function(title)
            Title.Text = title
            return {
                addTab = addTab,
                Instance = MainFrame,
                Toast = Toast
            }
        end
    }
end

return createUI()
