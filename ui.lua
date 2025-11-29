local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local lib = {}

local function c(o,p)
    for k,v in pairs(p) do o[k]=v end
    return o
end

function lib.makeText(parent,text,size,color)
    local l = Instance.new("TextLabel")
    c(l,{
        Parent=parent,
        Text=text,
        Size=UDim2.new(0,size.X,0,size.Y),
        BackgroundTransparency=1,
        TextColor3=color or Color3.new(1,1,1),
        TextScaled=true,
        Font=Enum.Font.Gotham
    })
    return l
end

function lib.makeRect(parent,size,bg,stroke,corner)
    local f=Instance.new("Frame")
    c(f,{Parent=parent,Size=UDim2.new(0,size.X,0,size.Y),BackgroundColor3=bg,ClipsDescendants=true})
    local s=Instance.new("UIStroke")
    s.Thickness=1
    s.Color=stroke or bg
    s.Parent=f
    if corner and corner>0 then
        local u=Instance.new("UICorner")
        u.CornerRadius=UDim.new(0,corner)
        u.Parent=f
    end
    return f
end

function lib.Init(title,corner)
    local gui=Instance.new("ScreenGui")
    gui.ResetOnSpawn=false
    gui.Parent=game.CoreGui

    local mainFrame=lib.makeRect(gui,Vector2.new(620,420),Color3.fromRGB(24,24,24),nil,12)
    mainFrame.Position=UDim2.new(0.5,-310,0.5,-210)
    mainFrame.Name="MemeSenseLikeMenu"

    local header=Instance.new("Frame")
    c(header,{Parent=mainFrame,Size=UDim2.new(1,0,0,44),Position=UDim2.new(0,0,0,0),BackgroundColor3=Color3.fromRGB(18,18,18)})
    local headerCorner=Instance.new("UICorner")
    headerCorner.CornerRadius=UDim.new(0,10)
    headerCorner.Parent=header
    local titleLabel=lib.makeText(header,title or "MEMESENSE",Vector2.new(300,40),Color3.fromRGB(200,200,200))
    titleLabel.Position=UDim2.new(0,12,0,2)
    titleLabel.TextXAlignment=Enum.TextXAlignment.Left

    local leftBar=lib.makeRect(mainFrame,Vector2.new(140,372),Color3.fromRGB(28,28,28),nil,10)
    leftBar.Position=UDim2.new(0,12,0,56)
    local leftList=Instance.new("UIListLayout")
    leftList.Parent=leftBar
    leftList.Padding=UDim.new(0,8)
    leftList.SortOrder=Enum.SortOrder.LayoutOrder
    leftList.HorizontalAlignment=Enum.HorizontalAlignment.Center

    local rightArea=lib.makeRect(mainFrame,Vector2.new(448,372),Color3.fromRGB(20,20,20),nil,10)
    rightArea.Position=UDim2.new(0,164,0,56)

    local tabContainer=Instance.new("Frame")
    c(tabContainer,{Parent=rightArea,Size=UDim2.new(1,-20,1,-20),Position=UDim2.new(0,10,0,10),BackgroundTransparency=1})
    local tabs={}
    local visible=true

    local dragging=false
    local dragInput,dragStart,startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true
            dragStart=input.Position
            startPos=mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.End then dragging=false end
            end)
        end
    end)
    header.InputChanged:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseMovement then dragInput=input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input==dragInput then
            local delta=input.Position-dragStart
            mainFrame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
        end
    end)

    UserInputService.InputBegan:Connect(function(input,processed)
        if not processed and input.KeyCode==Enum.KeyCode.F5 then
            visible=not visible
            gui.Enabled=visible
        end
    end)

    local function makeTabButton(parent,text)
        local btn=Instance.new("TextButton")
        c(btn,{
            Parent=parent,
            Size=UDim2.new(0,116,0,36),
            BackgroundColor3=Color3.fromRGB(40,40,40),
            Text=text,
            TextColor3=Color3.fromRGB(220,220,220),
            TextScaled=true,
            AutoButtonColor=false,
            BorderSizePixel=0,
            Font=Enum.Font.GothamBold
        })
        local corner=Instance.new("UICorner")
        corner.CornerRadius=UDim.new(0,8)
        corner.Parent=btn
        local stroke=Instance.new("UIStroke")
        stroke.Thickness=1
        stroke.Transparency=0.75
        stroke.Parent=btn
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn,TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundColor3=Color3.fromRGB(68,68,68)}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn,TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundColor3=Color3.fromRGB(40,40,40)}):Play()
        end)
        return btn
    end

    local function createTab(tabName)
        local btn=makeTabButton(leftBar,tabName)
        btn.LayoutOrder = #leftBar:GetChildren()
        local content=Instance.new("Frame")
        c(content,{Parent=tabContainer,Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Visible=false})
        local contentLayout=Instance.new("UIListLayout")
        contentLayout.Parent=content
        contentLayout.Padding=UDim.new(0,10)
        contentLayout.SortOrder=Enum.SortOrder.LayoutOrder
        tabs[tabName]={button=btn,frame=content,sections={}}
        btn.MouseButton1Click:Connect(function()
            for k,v in pairs(tabs) do
                v.frame.Visible=false
                TweenService:Create(v.button,TweenInfo.new(0.14),{TextColor3=Color3.fromRGB(220,220,220)}):Play()
            end
            tabs[tabName].frame.Visible=true
            TweenService:Create(btn,TweenInfo.new(0.14),{TextColor3=Color3.fromRGB(255,170,255)}):Play()
        end)
        return tabs[tabName]
    end

    local function createSection(tab,sectionName)
        local sectionFrame=lib.makeRect(tab.frame,Vector2.new(0,0),Color3.fromRGB(30,30,30),nil,8)
        sectionFrame.LayoutOrder= #tab.frame:GetChildren()
        local headerArea=lib.makeRect(sectionFrame,Vector2.new(0,36),Color3.fromRGB(25,25,25),nil,8)
        headerArea.Position=UDim2.new(0,0,0,0)
        headerArea.Size=UDim2.new(1,0,0,36)
        local title=lib.makeText(headerArea,sectionName,Vector2.new(260,36),Color3.fromRGB(220,220,220))
        title.Position=UDim2.new(0,12,0,0)
        title.TextXAlignment=Enum.TextXAlignment.Left
        local secContent=Instance.new("Frame")
        c(secContent,{Parent=sectionFrame,Size=UDim2.new(1,-16,1,-46),Position=UDim2.new(0,8,0,44),BackgroundTransparency=1})
        local layout=Instance.new("UIListLayout")
        layout.Parent=secContent
        layout.Padding=UDim.new(0,8)
        layout.SortOrder=Enum.SortOrder.LayoutOrder
        tab.sections[sectionName]={frame=sectionFrame,content=secContent}
        sectionFrame.Parent=tab.frame
        return tab.sections[sectionName]
    end

    local function addLabel(section,text)
        return lib.makeText(section.content,text,Vector2.new(0,28),Color3.fromRGB(220,220,220))
    end

    local function addSeparator(section)
        return lib.makeRect(section.content,Vector2.new(0,2),Color3.fromRGB(60,60,60),nil,2)
    end

    local function addButton(section,text,callback)
        local b=Instance.new("TextButton")
        c(b,{Parent=section.content,Size=UDim2.new(1,0,0,34),BackgroundColor3=Color3.fromRGB(40,40,40),Text=text,TextColor3=Color3.fromRGB(230,230,230),TextScaled=true,AutoButtonColor=false,BorderSizePixel=0,Font=Enum.Font.GothamBold})
        local u=Instance.new("UICorner"); u.CornerRadius=UDim.new(0,6); u.Parent=b
        local stroke=Instance.new("UIStroke"); stroke.Thickness=1; stroke.Transparency=0.8; stroke.Parent=b
        b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(64,64,64)}):Play() end)
        b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(40,40,40)}):Play() end)
        b.MouseButton1Click:Connect(function() if callback then pcall(callback) end end)
        return b
    end

    local function addToggle(section,text,default,callback)
        local f=lib.makeRect(section.content,Vector2.new(0,34),Color3.fromRGB(35,35,35),nil,8)
        local lbl=lib.makeText(f,text,Vector2.new(260,34),Color3.fromRGB(220,220,220))
        lbl.Position=UDim2.new(0,12,0,0)
        lbl.TextXAlignment=Enum.TextXAlignment.Left
        local holder=lib.makeRect(f,Vector2.new(46,26),Color3.fromRGB(18,18,18),nil,8)
        holder.Position=UDim2.new(1,-56,0,4)
        local glow=Instance.new("Frame")
        c(glow,{Parent=holder,Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0,0,0,0),BackgroundColor3=Color3.fromRGB(170,80,255)})
        local glowCorner=Instance.new("UICorner"); glowCorner.CornerRadius=UDim.new(0,6); glowCorner.Parent=glow
        local inner=Instance.new("TextButton")
        c(inner,{Parent=holder,Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0,0,0,0),BackgroundTransparency=1,Text="",AutoButtonColor=false})
        local toggled = default and true or false
        if toggled then
            glow.Size=UDim2.new(1,0,1,0)
            glow.BackgroundColor3=Color3.fromRGB(110,255,160)
        else
            glow.Size=UDim2.new(0.45,0,1,0)
            glow.BackgroundColor3=Color3.fromRGB(160,160,160)
        end
        inner.MouseButton1Click:Connect(function()
            toggled = not toggled
            if toggled then
                TweenService:Create(glow,TweenInfo.new(0.14,Enum.EasingStyle.Quad),{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(110,255,160)}):Play()
            else
                TweenService:Create(glow,TweenInfo.new(0.14,Enum.EasingStyle.Quad),{Size=UDim2.new(0.45,0,1,0),BackgroundColor3=Color3.fromRGB(160,160,160)}):Play()
            end
            if callback then pcall(callback,toggled) end
        end)
        return f
    end

    local function addSlider(section,text,min,max,default,decimals,callback)
        decimals = decimals or 0
        local f=lib.makeRect(section.content,Vector2.new(0,46),Color3.fromRGB(34,34,34),nil,8)
        local lbl=lib.makeText(f,text,Vector2.new(220,30),Color3.fromRGB(220,220,220)); lbl.Position=UDim2.new(0,12,0,6); lbl.TextXAlignment=Enum.TextXAlignment.Left
        local valLbl=lib.makeText(f,tostring(default),Vector2.new(56,30),Color3.fromRGB(220,220,220)); valLbl.Position=UDim2.new(1,-68,0,6); valLbl.TextXAlignment=Enum.TextXAlignment.Right
        local barHolder=lib.makeRect(f,Vector2.new(0,0),Color3.fromRGB(24,24,24),nil,6)
        barHolder.Position=UDim2.new(0,12,0,28)
        barHolder.Size=UDim2.new(1,-88,0,12)
        local bg=Instance.new("Frame"); c(bg,{Parent=barHolder,Size=UDim2.new(1,0,1,0),Position=UDim2.new(0,0,0,0),BackgroundColor3=Color3.fromRGB(60,60,60)})
        local bgCorner=Instance.new("UICorner"); bgCorner.CornerRadius=UDim.new(0,6); bgCorner.Parent=bg
        local fill=Instance.new("Frame"); c(fill,{Parent=bg,Size=UDim2.new(0,math.clamp((default-min)/(max-min),0,1),1,0),Position=UDim2.new(0,0,0,0),BackgroundColor3=Color3.fromRGB(170,80,255)})
        local fillCorner=Instance.new("UICorner"); fillCorner.CornerRadius=UDim.new(0,6); fillCorner.Parent=fill
        local handle=Instance.new("TextButton"); c(handle,{Parent=bg,Size=UDim2.new(0,14,0,14),BackgroundColor3=Color3.fromRGB(220,220,220),AutoButtonColor=false,BorderSizePixel=0,Text=""})
        handle.Position=UDim2.new(fill.Size.X.Scale,fill.Size.X.Offset/((bg.AbsoluteSize.X>0 and bg.AbsoluteSize.X) or 1),0, -1)
        local handleCorner=Instance.new("UICorner"); handleCorner.CornerRadius=UDim.new(0,7); handleCorner.Parent=handle
        local dragging=false
        local function updateValueFromX(x)
            local absX = math.clamp(x - bg.AbsolutePosition.X,0,bg.AbsoluteSize.X)
            local frac = (bg.AbsoluteSize.X>0) and (absX / bg.AbsoluteSize.X) or 0
            TweenService:Create(fill,TweenInfo.new(0.08,Enum.EasingStyle.Quad),{Size=UDim2.new(frac,0,1,0)}):Play()
            handle.Position = UDim2.new(frac, -7, 0, -1)
            local val = min + frac * (max - min)
            val = math.floor(val * (10^decimals)) / (10^decimals)
            valLbl.Text = tostring(val)
            if callback then pcall(callback,val) end
        end
        handle.MouseButton1Down:Connect(function()
            dragging=true
            TweenService:Create(handle,TweenInfo.new(0.12),{Size=UDim2.new(0,18,0,18),BackgroundColor3=Color3.fromRGB(255,255,255)}):Play()
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 and dragging then
                dragging=false
                TweenService:Create(handle,TweenInfo.new(0.12),{Size=UDim2.new(0,14,0,14),BackgroundColor3=Color3.fromRGB(220,220,220)}):Play()
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
                updateValueFromX(input.Position.X)
            end
        end)
        bg.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 then
                updateValueFromX(input.Position.X)
            end
        end)
        RunService.Heartbeat:Connect(function()
            if bg.AbsoluteSize.X>0 then
                handle.Position = UDim2.new(fill.Size.X.Scale, -7, 0, -1)
            end
        end)
        return f
    end

    local function addDropdown(section,text,options,callback)
        local f=lib.makeRect(section.content,Vector2.new(0,36),Color3.fromRGB(35,35,35),nil,8)
        local lbl=lib.makeText(f,text,Vector2.new(220,30),Color3.fromRGB(220,220,220)); lbl.Position=UDim2.new(0,12,0,3); lbl.TextXAlignment=Enum.TextXAlignment.Left
        local selBtn=Instance.new("TextButton")
        c(selBtn,{Parent=f,Size=UDim2.new(0,156,0,28),Position=UDim2.new(1,-172,0,4),BackgroundColor3=Color3.fromRGB(26,26,26),Text=options[1] or "",TextColor3=Color3.fromRGB(220,220,220),TextScaled=true,AutoButtonColor=false,BorderSizePixel=0,Font=Enum.Font.Gotham})
        local selCorner=Instance.new("UICorner"); selCorner.CornerRadius=UDim.new(0,6); selCorner.Parent=selBtn
        local arrow=Instance.new("TextLabel"); c(arrow,{Parent=selBtn,Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,-28,0,0),BackgroundTransparency=1,Text="▾",TextScaled=true,TextColor3=Color3.fromRGB(170,170,170),Font=Enum.Font.Gotham})
        local dropFrame=lib.makeRect(f,Vector2.new(156, #options*32),Color3.fromRGB(28,28,28),nil,8)
        dropFrame.Position=UDim2.new(1,-172,0,44)
        dropFrame.Visible=false
        dropFrame.Size=UDim2.new(0,156,0,0)
        local dropLayout=Instance.new("UIListLayout"); dropLayout.Parent=dropFrame; dropLayout.Padding=UDim.new(0,4)
        local function closeDropdown()
            if dropFrame.Visible then
                TweenService:Create(dropFrame,TweenInfo.new(0.14,Enum.EasingStyle.Quad),{Size=UDim2.new(0,156,0,0)}):Play()
                delay(0.14,function() dropFrame.Visible=false end)
            end
        end
        local function openDropdown()
            if not dropFrame.Visible then
                dropFrame.Visible=true
                TweenService:Create(dropFrame,TweenInfo.new(0.14,Enum.EasingStyle.Quad),{Size=UDim2.new(0,156,0,#options*32)}):Play()
            else
                closeDropdown()
            end
        end
        for i,opt in ipairs(options) do
            local optBtn=Instance.new("TextButton")
            c(optBtn,{Parent=dropFrame,Size=UDim2.new(1,0,0,28),BackgroundColor3=Color3.fromRGB(28,28,28),Text=opt,TextColor3=Color3.fromRGB(220,220,220),TextScaled=true,AutoButtonColor=false,BorderSizePixel=0,Font=Enum.Font.Gotham})
            local oc=Instance.new("UICorner"); oc.CornerRadius=UDim.new(0,6); oc.Parent=optBtn
            optBtn.MouseEnter:Connect(function() TweenService:Create(optBtn,TweenInfo.new(0.08),{BackgroundColor3=Color3.fromRGB(44,44,44)}):Play() end)
            optBtn.MouseLeave:Connect(function() TweenService:Create(optBtn,TweenInfo.new(0.08),{BackgroundColor3=Color3.fromRGB(28,28,28)}):Play() end)
            optBtn.MouseButton1Click:Connect(function()
                selBtn.Text = opt
                closeDropdown()
                if callback then pcall(callback,opt) end
            end)
        end
        selBtn.MouseButton1Click:Connect(function() openDropdown() end)
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 then
                local mousePos = UserInputService:GetMouseLocation()
                local px,py = mousePos.X,mousePos.Y
                local inDrop = dropFrame.Visible and (px >= dropFrame.AbsolutePosition.X and px <= dropFrame.AbsolutePosition.X + dropFrame.AbsoluteSize.X and py >= dropFrame.AbsolutePosition.Y and py <= dropFrame.AbsolutePosition.Y + dropFrame.AbsoluteSize.Y)
                local inSel = (px >= selBtn.AbsolutePosition.X and px <= selBtn.AbsolutePosition.X + selBtn.AbsoluteSize.X and py >= selBtn.AbsolutePosition.Y and py <= selBtn.AbsolutePosition.Y + selBtn.AbsoluteSize.Y)
                if dropFrame.Visible and not inDrop and not inSel then
                    closeDropdown()
                end
            end
        end)
        return f
    end

    return {
        gui=gui,
        frame=mainFrame,
        leftBar=leftBar,
        rightArea=rightArea,
        createTab=createTab,
        createSection=createSection,
        addLabel=addLabel,
        addSeparator=addSeparator,
        addButton=addButton,
        addToggle=addToggle,
        addSlider=addSlider,
        addDropdown=addDropdown
    }
end

return lib
