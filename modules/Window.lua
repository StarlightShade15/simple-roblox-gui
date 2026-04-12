local Window = {}

local LibraryRef = nil
local UtilsRef = nil
local ThemeManager = nil
local Tooltip = nil
local Notification = nil
local ConfigManager = nil
local TweenService = nil
local UserInputService = nil
local RunService = nil
local POPUP_Z_INDEX = nil
local ScreenGui = nil

function Window.init(library, utils, themeMgr, tooltip, notification, configMgr, tweenSvc, uis, runSvc, popupZ)
    LibraryRef = library
    UtilsRef = utils
    ThemeManager = themeMgr
    Tooltip = tooltip
    Notification = notification
    ConfigManager = configMgr
    TweenService = tweenSvc
    UserInputService = uis
    RunService = runSvc
    POPUP_Z_INDEX = popupZ
end

function Window.setScreenGui(sg)
    ScreenGui = sg
end

function Window.create(opts)
    opts = opts or {}
    local winTitle = opts.Title or "UI Library"
    local winSize = opts.Size or UDim2.new(0, 640, 0, 460)
    local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift

    local theme = ThemeManager.getCurrent()

    local Win = {
        _tabs = {},
        _activeTab = nil,
        _visible = true,
        _minimised = false,
        _baseSize = winSize,
        _cleanup = {},
        Flags = LibraryRef.Flags,
    }
    setmetatable(Win, { __index = Window })

    -- Root
    local Root = UtilsRef.New("Frame", {
        Name = "Window_" .. winTitle,
        Size = winSize,
        Position = UDim2.new(0.5, -winSize.X.Offset / 2, 0.5, -winSize.Y.Offset / 2),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        Parent = ScreenGui,
    })
    UtilsRef.Corner(Root, 10, LibraryRef)
    local rootStroke = UtilsRef.Stroke(Root, theme.Outline, 1)
    Win._root = Root

    -- Shadow
    UtilsRef.New("ImageLabel", {
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
    local TitleBar = UtilsRef.New("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = Root,
    })
    UtilsRef.Corner(TitleBar, 10, LibraryRef)
    UtilsRef.New("Frame", {
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = TitleBar,
    })

    local TitleLabel = UtilsRef.New("TextLabel", {
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

    local AccentLine = UtilsRef.New("Frame", {
        Name = "AccentLine",
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = TitleBar,
    })

    -- Window controls
    local CtrlRow = UtilsRef.New("Frame", {
        Size = UDim2.new(0, 56, 0, 22),
        Position = UDim2.new(1, -64, 0.5, -11),
        BackgroundTransparency = 1,
        ZIndex = 4,
        Parent = TitleBar,
    })
    UtilsRef.ListLayout(CtrlRow, 6, Enum.FillDirection.Horizontal)

    local function WinBtn(bgColor, sym, onClick)
        local b = UtilsRef.New("TextButton", {
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
        UtilsRef.Corner(b, 5, LibraryRef)
        b.MouseEnter:Connect(function() UtilsRef.Tween(b, { BackgroundTransparency = 0.35 }, 0.1) end)
        b.MouseLeave:Connect(function() UtilsRef.Tween(b, { BackgroundTransparency = 0 }, 0.1) end)
        b.MouseButton1Click:Connect(onClick)
        return b
    end

    WinBtn(Color3.fromRGB(235, 175, 28), "−", function() Win:_Minimise() end)
    WinBtn(Color3.fromRGB(215, 55, 60), "×", function() Win:Close() end)

    -- Body
    local Body = UtilsRef.New("Frame", {
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
    local TabBar = UtilsRef.New("ScrollingFrame", {
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
    UtilsRef.Corner(TabBar, 8, LibraryRef)
    UtilsRef.Padding(TabBar, 6, 6, 6, 6)
    UtilsRef.ListLayout(TabBar, 3)
    Win._tabBar = TabBar

    -- ContentArea
    local ContentArea = UtilsRef.New("Frame", {
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
    local dragging = false
    local dragStart = nil
    local frameStart = nil
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
    table.insert(Win._cleanup, ThemeManager.registerListener(function(t)
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
            UtilsRef.Tween(Root, { BackgroundTransparency = LibraryRef.Transparency }, 0.2, Enum.EasingStyle.Quint)
        else
            UtilsRef.Tween(Root, { BackgroundTransparency = 1 }, 0.2, Enum.EasingStyle.Quint)
            task.delay(0.21, function() if not self._visible and Root then Root.Visible = false end end)
        end
    end

    function Win:_Minimise()
        self._minimised = not self._minimised
        local target = self._minimised and UDim2.new(winSize.X.Scale, winSize.X.Offset, 0, 38) or winSize
        UtilsRef.Tween(Root, { Size = target }, 0.28, Enum.EasingStyle.Quint)
    end

    function Win:Close()
        UtilsRef.Tween(Root, { BackgroundTransparency = 1 }, 0.2)
        task.delay(0.22, function()
            if Root then Root:Destroy() end
            for _, cleanup in ipairs(self._cleanup) do cleanup() end
            UtilsRef.tableClear(self._cleanup)
        end)
    end

    -- CreateTab
    function Win:CreateTab(name)
        local theme = ThemeManager.getCurrent()
        local Tab = {
            _name = name,
            _win = self,
            _cleanup = {},
        }

        local TabBtn = UtilsRef.New("TextButton", {
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
        UtilsRef.Corner(TabBtn, 6, LibraryRef)

        local TabAccent = UtilsRef.New("Frame", {
            Name = "TabAccent",
            Size = UDim2.new(0, 3, 0.6, 0),
            Position = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor3 = theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 5,
            Parent = TabBtn,
        })
        UtilsRef.Corner(TabAccent, 2, LibraryRef)

        Tab._btn = TabBtn
        Tab._accent = TabAccent

        local ContentFrame = UtilsRef.New("Frame", {
            Name = "TabContent_" .. name,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            ZIndex = 2,
            Parent = ContentArea,
        })
        Tab._frame = ContentFrame

        local ColRow = UtilsRef.New("Frame", {
            Size = UDim2.new(1, -8, 1, -8),
            Position = UDim2.new(0, 4, 0, 4),
            BackgroundTransparency = 1,
            Parent = ContentFrame,
        })
        UtilsRef.ListLayout(ColRow, 6, Enum.FillDirection.Horizontal)

        local function MakeScrollCol(side)
            local sf = UtilsRef.New("ScrollingFrame", {
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
            UtilsRef.ListLayout(sf, 6)
            UtilsRef.Padding(sf, 0, 6, 0, 2)
            table.insert(Tab._cleanup, ThemeManager.registerListener(function(t)
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
                UtilsRef.Tween(prev._btn, { BackgroundTransparency = 1, TextColor3 = ThemeManager.getCurrent().SubText }, 0.14)
                UtilsRef.Tween(prev._accent, { BackgroundTransparency = 1 }, 0.14)
            end
            self._activeTab = Tab
            ContentFrame.Visible = true
            UtilsRef.Tween(TabBtn, { BackgroundTransparency = 0, BackgroundColor3 = ThemeManager.getCurrent().Tertiary, TextColor3 = ThemeManager.getCurrent().Text }, 0.14)
            UtilsRef.Tween(TabAccent, { BackgroundTransparency = 0 }, 0.14)
        end

        TabBtn.MouseButton1Click:Connect(Activate)
        TabBtn.MouseEnter:Connect(function()
            if self._activeTab ~= Tab then
                UtilsRef.Tween(TabBtn, { BackgroundTransparency = 0.6, BackgroundColor3 = ThemeManager.getCurrent().Tertiary }, 0.1)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if self._activeTab ~= Tab then
                UtilsRef.Tween(TabBtn, { BackgroundTransparency = 1 }, 0.1)
            end
        end)

        if #self._tabs == 0 then Activate() end
        table.insert(self._tabs, Tab)

        table.insert(Tab._cleanup, ThemeManager.registerListener(function(t)
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
            local theme = ThemeManager.getCurrent()
            local col = (side == "Right") and self._rightCol or self._leftCol

            local GB = {
                _tab = self,
                _cleanup = {},
                _list = nil,
            }

            local GBFrame = UtilsRef.New("Frame", {
                Name = "GB_" .. gbName,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = theme.Element,
                BorderSizePixel = 0,
                ZIndex = 3,
                Parent = col,
            })
            UtilsRef.Corner(GBFrame, 8, LibraryRef)
            local gbStroke = UtilsRef.Stroke(GBFrame, theme.Outline)

            local GBHeader = UtilsRef.New("Frame", {
                Name = "Header",
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundTransparency = 1,
                ZIndex = 4,
                Parent = GBFrame,
            })
            local headerDivider = UtilsRef.New("Frame", {
                Size = UDim2.new(1, -14, 0, 1),
                Position = UDim2.new(0, 7, 1, -1),
                BackgroundColor3 = theme.Outline,
                BorderSizePixel = 0,
                ZIndex = 4,
                Parent = GBHeader,
            })
            local headerTitle = UtilsRef.New("TextLabel", {
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

            local GBContent = UtilsRef.New("Frame", {
                Name = "Content",
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Position = UDim2.new(0, 0, 0, 26),
                BackgroundTransparency = 1,
                ZIndex = 3,
                Parent = GBFrame,
            })
            UtilsRef.Padding(GBContent, 4, 8, 8, 8)
            UtilsRef.ListLayout(GBContent, 5)
            GB._list = GBContent

            table.insert(GB._cleanup, ThemeManager.registerListener(function(t)
                if not GBFrame or not GBFrame.Parent then return end
                GBFrame.BackgroundColor3 = t.Element
                gbStroke.Color = t.Outline
                headerDivider.BackgroundColor3 = t.Outline
                headerTitle.TextColor3 = t.SubText
            end))

            -- Helper for element rows
            local function ElemRow(labelText, height, tooltipText)
                local themeNow = ThemeManager.getCurrent()
                local row = UtilsRef.New("Frame", {
                    Size = UDim2.new(1, 0, 0, height or 26),
                    BackgroundTransparency = 1,
                    ZIndex = 4,
                    Parent = GB._list,
                })
                local lbl = UtilsRef.New("TextLabel", {
                    Size = UDim2.new(0.58, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = labelText,
                    TextColor3 = themeNow.Text,
                    Font = LibraryRef.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = row,
                })
                if tooltipText then Tooltip.attach(row, tooltipText) end
                table.insert(GB._cleanup, ThemeManager.registerListener(function(t)
                    if lbl and lbl.Parent then
                        lbl.TextColor3 = t.Text
                        lbl.Font = LibraryRef.Font
                    end
                end))
                return row, lbl
            end

            -- Button
            function GB:CreateButton(opts)
                local n = opts.Name or "Button"
                local cb = opts.Callback or function() end
                local tooltipText = opts.Tooltip
                local themeNow = ThemeManager.getCurrent()

                local row = UtilsRef.New("Frame", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    ZIndex = 4,
                    Parent = self._list,
                })

                local btn = UtilsRef.New("TextButton", {
                    Size = UDim2.new(1, 0, 0, 26),
                    Position = UDim2.new(0, 0, 0, 1),
                    BackgroundColor3 = themeNow.Accent,
                    BorderSizePixel = 0,
                    Text = n,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    ZIndex = 5,
                    Parent = row,
                })
                UtilsRef.Corner(btn, 6, LibraryRef)
                if tooltipText then Tooltip.attach(btn, tooltipText) end

                btn.MouseEnter:Connect(function() UtilsRef.Tween(btn, { BackgroundColor3 = ThemeManager.getCurrent().AccentGlow }, 0.12) end)
                btn.MouseLeave:Connect(function() UtilsRef.Tween(btn, { BackgroundColor3 = ThemeManager.getCurrent().Accent }, 0.12) end)
                btn.MouseButton1Down:Connect(function() UtilsRef.Tween(btn, { BackgroundColor3 = ThemeManager.getCurrent().AccentDark }, 0.08) end)
                btn.MouseButton1Up:Connect(function() UtilsRef.Tween(btn, { BackgroundColor3 = ThemeManager.getCurrent().Accent }, 0.12) end)
                btn.MouseButton1Click:Connect(function()
                    UtilsRef.safePCall(cb)
                end)

                table.insert(self._cleanup, ThemeManager.registerListener(function(t)
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
                local tooltipText = opts.Tooltip

                local state = default
                if flag then LibraryRef.Flags[flag] = state end

                local row, _ = ElemRow(n, 26, tooltipText)

                local track = UtilsRef.New("Frame", {
                    Size = UDim2.new(0, 36, 0, 18),
                    Position = UDim2.new(1, -36, 0.5, -9),
                    BackgroundColor3 = state and ThemeManager.getCurrent().Accent or ThemeManager.getCurrent().Outline,
                    BorderSizePixel = 0,
                    ZIndex = 5,
                    Parent = row,
                })
                UtilsRef.Corner(track, 9, LibraryRef)

                local knob = UtilsRef.New("Frame", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    ZIndex = 6,
                    Parent = track,
                })
                UtilsRef.Corner(knob, 6, LibraryRef)

                local Ref = { _state = state, _cb = cb }

                local function SetState(val, silent)
                    state = val
                    Ref._state = val
                    if flag then LibraryRef.Flags[flag] = val end
                    UtilsRef.Tween(track, { BackgroundColor3 = val and ThemeManager.getCurrent().Accent or ThemeManager.getCurrent().Outline }, 0.14)
                    UtilsRef.Tween(knob, { Position = val and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6) }, 0.14)
                    if not silent then UtilsRef.safePCall(cb, val) end
                end

                UtilsRef.New("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 7,
                    Parent = row,
                }).MouseButton1Click:Connect(function() SetState(not state) end)

                table.insert(self._cleanup, ThemeManager.registerListener(function(t)
                    if track and track.Parent then
                        track.BackgroundColor3 = state and t.Accent or t.Outline
                    end
                end))

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
                local tooltipText = opts.Tooltip

                local value = default
                if flag then LibraryRef.Flags[flag] = value end

                local row = UtilsRef.New("Frame", {
                    Size = UDim2.new(1, 0, 0, 44),
                    BackgroundTransparency = 1,
                    ZIndex = 4,
                    Parent = self._list,
                })
                if tooltipText then Tooltip.attach(row, tooltipText) end

                local topRow = UtilsRef.New("Frame", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    ZIndex = 5,
                    Parent = row,
                })
                local nameLbl = UtilsRef.New("TextLabel", {
                    Size = UDim2.new(0.6, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = n,
                    TextColor3 = ThemeManager.getCurrent().Text,
                    Font = LibraryRef.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6,
                    Parent = topRow,
                })
                local valLbl = UtilsRef.New("TextLabel", {
                    Size = UDim2.new(0.4, 0, 1, 0),
                    Position = UDim2.new(0.6, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(value) .. suffix,
                    TextColor3 = ThemeManager.getCurrent().SubText,
                    Font = LibraryRef.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 6,
                    Parent = topRow,
                })

                local track = UtilsRef.New("Frame", {
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 0, 26),
                    BackgroundColor3 = ThemeManager.getCurrent().Outline,
                    BorderSizePixel = 0,
                    ZIndex = 5,
                    Parent = row,
                })
                UtilsRef.Corner(track, 3, LibraryRef)

                local pct0 = (value - min) / (max - min)
                local fill = UtilsRef.New("Frame", {
                    Size = UDim2.new(pct0, 0, 1, 0),
                    BackgroundColor3 = ThemeManager.getCurrent().Accent,
                    BorderSizePixel = 0,
                    ZIndex = 6,
                    Parent = track,
                })
                UtilsRef.Corner(fill, 3, LibraryRef)

                local knob = UtilsRef.New("Frame", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(pct0, -6, 0.5, -6),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    ZIndex = 7,
                    Parent = track,
                })
                UtilsRef.Corner(knob, 6, LibraryRef)

                local Ref = {}

                local function SetValue(v, silent)
                    v = math.clamp(step == 1 and math.round(v) or (math.floor(v / step + 0.5) * step), min, max)
                    value = v
                    if flag then LibraryRef.Flags[flag] = v end
                    local p = (v - min) / (max - min)
                    UtilsRef.Tween(fill, { Size = UDim2.new(p, 0, 1, 0) }, 0.07)
                    UtilsRef.Tween(knob, { Position = UDim2.new(p, -6, 0.5, -6) }, 0.07)
                    valLbl.Text = tostring(v) .. suffix
                    if not silent then UtilsRef.safePCall(cb, v) end
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

                table.insert(self._cleanup, ThemeManager.registerListener(function(t)
                    if track and track.Parent then
                        track.BackgroundColor3 = t.Outline
                        fill.BackgroundColor3 = t.Accent
                        nameLbl.TextColor3 = t.Text
                        nameLbl.Font = LibraryRef.Font
                        valLbl.TextColor3 = t.SubText
                        valLbl.Font = LibraryRef.Font
                    end
                end))

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
                local tooltipText = opts.Tooltip

                local selected = default
                if flag then LibraryRef.Flags[flag] = selected end

                local row = UtilsRef.New("Frame", {
                    Size = UDim2.new(1, 0, 0, 52),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    ZIndex = 4,
                    Parent = self._list,
                })
                if tooltipText then Tooltip.attach(row, tooltipText) end

                UtilsRef.New("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text = n,
                    TextColor3 = ThemeManager.getCurrent().Text,
                    Font = LibraryRef.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = row,
                })

                local dropBtn = UtilsRef.New("TextButton", {
                    Size = UDim2.new(1, 0, 0, 26),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = ThemeManager.getCurrent().Secondary,
                    BorderSizePixel = 0,
                    Text = "",
                    ZIndex = 5,
                    Parent = row,
                })
                UtilsRef.Corner(dropBtn, 6, LibraryRef)
                UtilsRef.Stroke(dropBtn, ThemeManager.getCurrent().Outline)

                local selLbl = UtilsRef.New("TextLabel", {
                    Size = UDim2.new(1, -26, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = selected or "Select...",
                    TextColor3 = ThemeManager.getCurrent().Text,
                    Font = LibraryRef.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 6,
                    Parent = dropBtn,
                })
                UtilsRef.New("TextLabel", {
                    Size = UDim2.new(0, 18, 1, 0),
                    Position = UDim2.new(1, -22, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▾",
                    TextColor3 = ThemeManager.getCurrent().SubText,
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    ZIndex = 6,
                    Parent = dropBtn,
                })

                local dropList = UtilsRef.New("Frame", {
                    Name = "DropList",
                    Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0),
                    BackgroundColor3 = ThemeManager.getCurrent().Secondary,
                    BorderSizePixel = 0,
                    Visible = false,
                    ClipsDescendants = true,
                    ZIndex = POPUP_Z_INDEX + 1,
                    Parent = ScreenGui:FindFirstChild("PopupContainer") or (function()
                        local pc = UtilsRef.New("Frame", { Name = "PopupContainer", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = POPUP_Z_INDEX, Parent = ScreenGui })
                        return pc
                    end)(),
                })
                UtilsRef.Corner(dropList, 6, LibraryRef)
                UtilsRef.Stroke(dropList, ThemeManager.getCurrent().Outline)
                UtilsRef.Padding(dropList, 4, 4, 4, 4)
                UtilsRef.ListLayout(dropList, 2)

                local Ref = {}
                local isOpen = false
                local updateConn = nil

                local function SetSelected(opt, silent)
                    selected = opt
                    selLbl.Text = opt or "Select..."
                    if flag then LibraryRef.Flags[flag] = opt end
                    if not silent then UtilsRef.safePCall(cb, opt) end
                end

                local function RebuildList(justColors)
                    if justColors then
                        local t = ThemeManager.getCurrent()
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
                        local item = UtilsRef.New("TextButton", {
                            Size = UDim2.new(1, 0, 0, 26),
                            BackgroundColor3 = ThemeManager.getCurrent().Tertiary,
                            BackgroundTransparency = isSelected and 0 or 1,
                            BorderSizePixel = 0,
                            Text = opt,
                            TextColor3 = isSelected and ThemeManager.getCurrent().Text or ThemeManager.getCurrent().SubText,
                            Font = LibraryRef.Font,
                            TextSize = 12,
                            ZIndex = POPUP_Z_INDEX + 2,
                            Parent = dropList,
                        })
                        UtilsRef.Corner(item, 4, LibraryRef)
                        item.MouseEnter:Connect(function()
                            UtilsRef.Tween(item, { BackgroundTransparency = 0, BackgroundColor3 = ThemeManager.getCurrent().Tertiary, TextColor3 = ThemeManager.getCurrent().Text }, 0.08)
                        end)
                        item.MouseLeave:Connect(function()
                            UtilsRef.Tween(item, { BackgroundTransparency = (opt == selected) and 0 or 1 }, 0.08)
                        end)
                        item.MouseButton1Click:Connect(function()
                            SetSelected(opt)
                            isOpen = false
                            if updateConn then updateConn:Disconnect(); updateConn = nil end
                            UtilsRef.Tween(dropList, { Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0) }, 0.14)
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
                    if popupX + absSize.X > viewSize.X then
                        popupX = viewSize.X - absSize.X
                    end
                    if popupY + dropList.AbsoluteSize.Y > viewSize.Y then
                        popupY = absPos.Y - dropList.AbsoluteSize.Y - 4
                    end
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
                        UtilsRef.Tween(dropList, { Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, h) }, 0.15)
                    else
                        if updateConn then updateConn:Disconnect(); updateConn = nil end
                        UtilsRef.Tween(dropList, { Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0) }, 0.15)
                        task.delay(0.15, function() dropList.Visible = false end)
                    end
                end)

                table.insert(self._cleanup, ThemeManager.registerListener(function(t)
                    if dropBtn and dropBtn.Parent then
                        dropBtn.BackgroundColor3 = t.Secondary
                        selLbl.TextColor3 = t.Text
                        dropList.BackgroundColor3 = t.Secondary
                        RebuildList(true)
                    end
                end))

                function Ref:Set(opt)
                    if UtilsRef.tableFind(options, opt) then
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
                local tooltipText = opts.Tooltip

                local selected = {}
                for _, v in ipairs(default) do selected[v] = true end
                if flag then LibraryRef.Flags[flag] = selected end

                local row = UtilsRef.New("Frame", {
                    Size = UDim2.new(1, 0, 0, 52),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    ZIndex = 4,
                    Parent = self._list,
                })
                if tooltipText then Tooltip.attach(row, tooltipText) end

                UtilsRef.New("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text = n,
                    TextColor3 = ThemeManager.getCurrent().Text,
                    Font = LibraryRef.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = row,
                })

                local dropBtn = UtilsRef.New("TextButton", {
                    Size = UDim2.new(1, 0, 0, 26),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = ThemeManager.getCurrent().Secondary,
                    BorderSizePixel = 0,
                    Text = "",
                    ZIndex = 5,
                    Parent = row,
                })
                UtilsRef.Corner(dropBtn, 6, LibraryRef)
                UtilsRef.Stroke(dropBtn, ThemeManager.getCurrent().Outline)

                local function SelText()
                    local list = {}
                    for k, v in pairs(selected) do if v then table.insert(list, k) end end
                    table.sort(list)
                    return #list > 0 and table.concat(list, ", ") or "None"
                end

                local selLbl = UtilsRef.New("TextLabel", {
                    Size = UDim2.new(1, -26, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = SelText(),
                    TextColor3 = ThemeManager.getCurrent().Text,
                    Font = LibraryRef.Font,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 6,
                    Parent = dropBtn,
                })
                UtilsRef.New("TextLabel", {
                    Size = UDim2.new(0, 18, 1, 0),
                    Position = UDim2.new(1, -22, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▾",
                    TextColor3 = ThemeManager.getCurrent().SubText,
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    ZIndex = 6,
                    Parent = dropBtn,
                })

                local dropList = UtilsRef.New("Frame", {
                    Name = "DropList",
                    Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0),
                    BackgroundColor3 = ThemeManager.getCurrent().Secondary,
                    BorderSizePixel = 0,
                    Visible = false,
                    ClipsDescendants = true,
                    ZIndex = POPUP_Z_INDEX + 1,
                    Parent = ScreenGui:FindFirstChild("PopupContainer") or (function()
                        local pc = UtilsRef.New("Frame", { Name = "PopupContainer", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = POPUP_Z_INDEX, Parent = ScreenGui })
                        return pc
                    end)(),
                })
                UtilsRef.Corner(dropList, 6, LibraryRef)
                UtilsRef.Stroke(dropList, ThemeManager.getCurrent().Outline)
                UtilsRef.Padding(dropList, 4, 4, 4, 4)
                UtilsRef.ListLayout(dropList, 2)

                local Ref = {}
                local isOpen = false
                local updateConn = nil

                local function RebuildMultiList(justColors)
                    if justColors then
                        local t = ThemeManager.getCurrent()
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
                        local item = UtilsRef.New("Frame", {
                            Size = UDim2.new(1, 0, 0, 26),
                            BackgroundColor3 = ThemeManager.getCurrent().Tertiary,
                            BackgroundTransparency = isSel and 0 or 1,
                            BorderSizePixel = 0,
                            ZIndex = POPUP_Z_INDEX + 2,
                            Parent = dropList,
                        })
                        UtilsRef.Corner(item, 4, LibraryRef)
                        UtilsRef.New("TextLabel", {
                            Size = UDim2.new(1, -28, 1, 0),
                            Position = UDim2.new(0, 8, 0, 0),
                            BackgroundTransparency = 1,
                            Text = opt,
                            TextColor3 = ThemeManager.getCurrent().Text,
                            Font = LibraryRef.Font,
                            TextSize = 12,
                            ZIndex = POPUP_Z_INDEX + 3,
                            Parent = item,
                        })
                        local chk = UtilsRef.New("TextLabel", {
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
                        UtilsRef.New("TextButton", {
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            Text = "",
                            ZIndex = POPUP_Z_INDEX + 4,
                            Parent = item,
                        }).MouseButton1Click:Connect(function()
                            selected[opt] = not selected[opt]
                            selLbl.Text = SelText()
                            if flag then LibraryRef.Flags[flag] = selected end
                            UtilsRef.safePCall(cb, selected)
                            item.BackgroundTransparency = selected[opt] and 0 or 1
                            item.BackgroundColor3 = ThemeManager.getCurrent().Tertiary
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
                        UtilsRef.Tween(dropList, { Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, h) }, 0.15)
                    else
                        if updateConn then updateConn:Disconnect(); updateConn = nil end
                        UtilsRef.Tween(dropList, { Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0) }, 0.15)
                        task.delay(0.15, function() dropList.Visible = false end)
                    end
                end)

                table.insert(self._cleanup, ThemeManager.registerListener(function(t)
                    if dropBtn and dropBtn.Parent then
                        dropBtn.BackgroundColor3 = t.Secondary
                        selLbl.TextColor3 = t.Text
                        dropList.BackgroundColor3 = t.Secondary
                        RebuildMultiList(true)
                    end
                end))

                function Ref:Set(tbl)
                    selected = {}
                    for _, v in ipairs(tbl) do selected[v] = true end
                    selLbl.Text = SelText()
                    if flag then LibraryRef.Flags[flag] = selected end
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
                local tooltipText = opts.Tooltip

                local value = default
                if flag then LibraryRef.Flags[flag] = value end

                local row = UtilsRef.New("Frame", {
                    Size = UDim2.new(1, 0, 0, 52),
                    BackgroundTransparency = 1,
                    ZIndex = 4,
                    Parent = self._list,
                })

                UtilsRef.New("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text = n,
                    TextColor3 = ThemeManager.getCurrent().Text,
                    Font = LibraryRef.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = row,
                })

                local inputBg = UtilsRef.New("Frame", {
                    Size = UDim2.new(1, 0, 0, 28),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = ThemeManager.getCurrent().Secondary,
                    BorderSizePixel = 0,
                    ZIndex = 5,
                    Parent = row,
                })
                UtilsRef.Corner(inputBg, 6, LibraryRef)
                UtilsRef.Stroke(inputBg, ThemeManager.getCurrent().Outline)
                if tooltipText then Tooltip.attach(inputBg, tooltipText) end

                local tb = UtilsRef.New("TextBox", {
                    Size = UDim2.new(1, -16, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = value,
                    PlaceholderText = placeholder,
                    TextColor3 = ThemeManager.getCurrent().Text,
                    PlaceholderColor3 = ThemeManager.getCurrent().SubText,
                    Font = LibraryRef.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    ZIndex = 6,
                    Parent = inputBg,
                })

                tb.Focused:Connect(function() UtilsRef.Tween(inputBg, { BackgroundColor3 = ThemeManager.getCurrent().Tertiary }, 0.1) end)
                tb.FocusLost:Connect(function()
                    UtilsRef.Tween(inputBg, { BackgroundColor3 = ThemeManager.getCurrent().Secondary }, 0.1)
                    value = tb.Text
                    if flag then LibraryRef.Flags[flag] = value end
                    UtilsRef.safePCall(cb, value)
                end)

                table.insert(self._cleanup, ThemeManager.registerListener(function(t)
                    if inputBg and inputBg.Parent then
                        inputBg.BackgroundColor3 = t.Secondary
                        tb.TextColor3 = t.Text
                        tb.PlaceholderColor3 = t.SubText
                        tb.Font = LibraryRef.Font
                    end
                end))

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

            -- ColorPicker (simplified – full version can be added similarly)
            function GB:CreateColorPicker(opts)
                local n = opts.Name or "Color"
                local default = opts.Default or Color3.fromRGB(255, 80, 80)
                local flag = opts.Flag
                local cb = opts.Callback or function() end
                local tooltipText = opts.Tooltip

                local color = default
                if flag then LibraryRef.Flags[flag] = color end

                local row, _ = ElemRow(n, 26, tooltipText)
                row.ClipsDescendants = false
                row.ZIndex = 5

                local preview = UtilsRef.New("TextButton", {
                    Size = UDim2.new(0, 52, 0, 20),
                    Position = UDim2.new(1, -52, 0.5, -10),
                    BackgroundColor3 = color,
                    BorderSizePixel = 0,
                    Text = "",
                    ZIndex = 6,
                    Parent = row,
                })
                UtilsRef.Corner(preview, 4, LibraryRef)
                UtilsRef.Stroke(preview, ThemeManager.getCurrent().Outline)

                -- Placeholder: color picker popup omitted for brevity; add full implementation if needed
                local Ref = {}
                function Ref:Set(c) color = c; preview.BackgroundColor3 = c end
                function Ref:Get() return color end
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
                local tooltipText = opts.Tooltip

                local key = default
                local listening = false
                if flag then LibraryRef.Flags[flag] = key end

                local row, _ = ElemRow(n, 26, tooltipText)

                local keyBtn = UtilsRef.New("TextButton", {
                    Size = UDim2.new(0, 72, 0, 22),
                    Position = UDim2.new(1, -72, 0.5, -11),
                    BackgroundColor3 = ThemeManager.getCurrent().Secondary,
                    BorderSizePixel = 0,
                    Text = key.Name ~= "Unknown" and key.Name or "None",
                    TextColor3 = ThemeManager.getCurrent().SubText,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    ZIndex = 5,
                    Parent = row,
                })
                UtilsRef.Corner(keyBtn, 5, LibraryRef)
                UtilsRef.Stroke(keyBtn, ThemeManager.getCurrent().Outline)

                keyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    keyBtn.Text = "..."
                    keyBtn.TextColor3 = ThemeManager.getCurrent().Accent
                end)

                UserInputService.InputBegan:Connect(function(inp, gpe)
                    if listening and not gpe then
                        if inp.UserInputType == Enum.UserInputType.Keyboard then
                            key = inp.KeyCode
                            if flag then LibraryRef.Flags[flag] = key end
                            keyBtn.Text = key.Name
                            keyBtn.TextColor3 = ThemeManager.getCurrent().SubText
                            listening = false
                        end
                    elseif not gpe and not listening and inp.KeyCode == key and key ~= Enum.KeyCode.Unknown then
                        UtilsRef.safePCall(cb)
                    end
                end)

                table.insert(self._cleanup, ThemeManager.registerListener(function(t)
                    if keyBtn and keyBtn.Parent then
                        keyBtn.BackgroundColor3 = t.Secondary
                        keyBtn.TextColor3 = t.SubText
                        keyBtn.Font = Enum.Font.Gotham
                    end
                end))

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
                local lbl = UtilsRef.New("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = clr or ThemeManager.getCurrent().SubText,
                    Font = LibraryRef.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    ZIndex = 5,
                    Parent = self._list,
                })
                if not clr then
                    table.insert(self._cleanup, ThemeManager.registerListener(function(t)
                        if lbl and lbl.Parent then
                            lbl.TextColor3 = t.SubText
                            lbl.Font = LibraryRef.Font
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
                local theme = ThemeManager.getCurrent()
                if labelText and labelText ~= "" then
                    local container = UtilsRef.New("Frame", {
                        Size = UDim2.new(1, 0, 0, 16),
                        BackgroundTransparency = 1,
                        ZIndex = 4,
                        Parent = self._list,
                    })
                    UtilsRef.New("Frame", {
                        Size = UDim2.new(0.38, 0, 0, 1),
                        Position = UDim2.new(0, 0, 0.5, 0),
                        BackgroundColor3 = theme.Outline,
                        BorderSizePixel = 0,
                        ZIndex = 4,
                        Parent = container,
                    })
                    UtilsRef.New("TextLabel", {
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
                    UtilsRef.New("Frame", {
                        Size = UDim2.new(0.38, 0, 0, 1),
                        Position = UDim2.new(0.62, 0, 0.5, 0),
                        BackgroundColor3 = theme.Outline,
                        BorderSizePixel = 0,
                        ZIndex = 4,
                        Parent = container,
                    })
                else
                    UtilsRef.New("Frame", {
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
    for k in pairs(LibraryRef.Themes) do table.insert(themeNames, k) end
    table.sort(themeNames)

    OptLeft:CreateDropdown({
        Name = "Theme",
        Options = themeNames,
        Default = LibraryRef.CurrentTheme,
        Tooltip = "Choose a colour theme",
        Callback = function(sel)
            LibraryRef.CurrentTheme = sel
            ThemeManager.fireTheme()
        end,
    })

    OptLeft:CreateToggle({
        Name = "Rounded Corners",
        Default = LibraryRef.RoundedCorners,
        Tooltip = "Toggle rounded or sharp corner radius",
        Callback = function(v) LibraryRef.RoundedCorners = v end,
    })

    OptLeft:CreateSlider({
        Name = "Corner Radius",
        Min = 0, Max = 14, Default = LibraryRef.CornerRadius,
        Tooltip = "Pixel radius of rounded corners",
        Callback = function(v) LibraryRef.CornerRadius = v end,
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
            LibraryRef.Font = fontMap[f] or Enum.Font.GothamMedium
            ThemeManager.fireTheme()
        end,
    })

    OptRight:CreateSlider({
        Name = "UI Scale",
        Min = 50, Max = 150, Default = 100, Suffix = "%",
        Tooltip = "Scales the window size",
        Callback = function(pct)
            LibraryRef.Scale = pct / 100
            Root.Size = UDim2.new(winSize.X.Scale, winSize.X.Offset * LibraryRef.Scale, winSize.Y.Scale, winSize.Y.Offset * LibraryRef.Scale)
        end,
    })

    OptRight:CreateSlider({
        Name = "Transparency",
        Min = 0, Max = 80, Default = 0, Suffix = "%",
        Tooltip = "Background transparency of the window",
        Callback = function(pct)
            LibraryRef.Transparency = pct / 100
            Root.BackgroundTransparency = LibraryRef.Transparency
        end,
    })

    OptRight:CreateToggle({
        Name = "Blur Background",
        Default = false,
        Tooltip = "Apply depth-of-field blur effect",
        Callback = function(v)
            LibraryRef.BlurEnabled = v
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
            LibraryRef.CurrentTheme = "Dark"
            ThemeManager.fireTheme()
            Notification.notify({ Title = "Theme Reset", Message = "Reverted to Dark theme.", Type = "Info" })
        end,
    })

    -- Built-in Config Tab
    local ConfigTab = Win:CreateTab("Config")
    local CfgLeft = ConfigTab:CreateGroupbox("Configs", "Left")
    local CfgRight = ConfigTab:CreateGroupbox("Actions", "Right")

    ConfigManager.initGroupboxes(CfgLeft, CfgRight, Win)

    table.insert(LibraryRef._windows, Win)
    return Win
end

return Window
