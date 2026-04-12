local Utils = {}

function Utils.tableFind(t, value)
    for i, v in ipairs(t) do
        if v == value then return i end
    end
    return nil
end

function Utils.tableClear(t)
    for k in pairs(t) do
        t[k] = nil
    end
end

function Utils.safePCall(fn, ...)
    local success, result = pcall(fn, ...)
    if not success then
        warn("[UILibrary] Error:", result)
    end
    return success, result
end

function Utils.Tween(obj, props, t, style, dir)
    if not obj or not obj.Parent then return end
    local ts = game:GetService("TweenService")
    local info = TweenInfo.new(t or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local tw = ts:Create(obj, info, props)
    tw:Play()
    return tw
end

function Utils.Corner(parent, r, library)
    local cr = (library and library.RoundedCorners and (r or library.CornerRadius)) or (r or 0)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, cr)
    c.Parent = parent
    return c
end

function Utils.Padding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, top or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft = UDim.new(0, left or 0)
    p.PaddingRight = UDim.new(0, right or 0)
    p.Parent = parent
    return p
end

function Utils.ListLayout(parent, spacing, direction, halign, valign)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, spacing or 4)
    l.FillDirection = direction or Enum.FillDirection.Vertical
    l.SortOrder = Enum.SortOrder.LayoutOrder
    if halign then l.HorizontalAlignment = halign end
    if valign then l.VerticalAlignment = valign end
    l.Parent = parent
    return l
end

function Utils.New(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            pcall(function() inst[k] = v end)
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

function Utils.Stroke(parent, color, thickness)
    return Utils.New("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Parent = parent,
    })
end

return Utils
