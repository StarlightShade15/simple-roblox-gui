local ConfigManager = {}

local LibraryRef = nil
local UtilsRef = nil
local HttpService = nil

function ConfigManager.init(library, utils, http)
    LibraryRef = library
    UtilsRef = utils
    HttpService = http
end

function ConfigManager.initGroupboxes(CfgLeft, CfgRight, Win)
    local CFG_FOLDER = "UILibConfigs"

    local function SafeFS(fn, ...)
        local ok, r = pcall(fn, ...)
        if not ok then warn("[UILibrary] FileSystem error:", r) end
        return ok, r
    end

    local function EnsureDir()
        if not isfolder then return end
        if not isfolder(CFG_FOLDER) then
            SafeFS(makefolder, CFG_FOLDER)
        end
    end

    local function GetCfgList()
        local list = {}
        if not isfolder then return list end
        SafeFS(EnsureDir)
        local ok, files = SafeFS(listfiles, CFG_FOLDER)
        if ok and files then
            for _, f in ipairs(files) do
                local name = (f:match("[^/\\]+$") or f)
                if name:sub(-5) == ".json" then
                    table.insert(list, name:sub(1, -6))
                end
            end
        end
        table.sort(list)
        return list
    end

    local function SerializeFlags()
        local data = {}
        for k, val in pairs(LibraryRef.Flags) do
            local t = type(val)
            if t == "boolean" or t == "number" or t == "string" then
                data[k] = val
            elseif typeof(val) == "Color3" then
                data[k] = { _T = "C3", r = val.R, g = val.G, b = val.B }
            elseif typeof(val) == "EnumItem" then
                data[k] = { _T = "EI", eType = tostring(val.EnumType), name = val.Name }
            end
        end
        return data
    end

    local function DeserializeFlags(data)
        for k, val in pairs(data) do
            if type(val) == "table" then
                if val._T == "C3" then
                    LibraryRef.Flags[k] = Color3.new(val.r, val.g, val.b)
                elseif val._T == "EI" then
                    pcall(function() LibraryRef.Flags[k] = Enum[val.eType][val.name] end)
                end
            else
                LibraryRef.Flags[k] = val
            end
        end
    end

    local cfgNameRef = CfgLeft:CreateTextInput({
        Name = "Config Name",
        Placeholder = "MyConfig",
        Default = "MyConfig",
    })

    local cfgDropRef = CfgLeft:CreateDropdown({
        Name = "Saved Configs",
        Options = GetCfgList(),
        Tooltip = "Select a config to load or delete",
    })

    CfgRight:CreateButton({
        Name = "Save Config",
        Tooltip = "Save current element states to a JSON file",
        Callback = function()
            if not writefile then
                LibraryRef:Notify({ Title = "Unsupported", Message = "File system not available.", Type = "Error" })
                return
            end
            local name = cfgNameRef:Get()
            if name == "" then name = "MyConfig" end
            SafeFS(EnsureDir)
            local ok, err = SafeFS(writefile, CFG_FOLDER .. "/" .. name .. ".json", HttpService:JSONEncode(SerializeFlags()))
            if ok then
                LibraryRef:Notify({ Title = "Config Saved", Message = '"' .. name .. '" saved successfully.', Type = "Success" })
                cfgDropRef:SetOptions(GetCfgList())
            else
                LibraryRef:Notify({ Title = "Save Failed", Message = tostring(err), Type = "Error" })
            end
        end,
    })

    CfgRight:CreateButton({
        Name = "Load Config",
        Tooltip = "Load a saved config and apply all element states",
        Callback = function()
            if not readfile then
                LibraryRef:Notify({ Title = "Unsupported", Message = "File system not available.", Type = "Error" })
                return
            end
            local name = cfgDropRef:Get()
            if not name then
                LibraryRef:Notify({ Title = "No Config", Message = "Select a config from the list.", Type = "Warning" })
                return
            end
            local ok, raw = SafeFS(readfile, CFG_FOLDER .. "/" .. name .. ".json")
            if ok then
                local decoded
                ok, decoded = SafeFS(function() return HttpService:JSONDecode(raw) end)
                if ok and decoded then
                    DeserializeFlags(decoded)
                    LibraryRef:Notify({ Title = "Config Loaded", Message = '"' .. name .. '" applied.', Type = "Success" })
                else
                    LibraryRef:Notify({ Title = "Parse Error", Message = "Config file is corrupted.", Type = "Error" })
                end
            else
                LibraryRef:Notify({ Title = "Read Error", Message = "Could not read the config file.", Type = "Error" })
            end
        end,
    })

    CfgRight:CreateButton({
        Name = "Delete Config",
        Tooltip = "Permanently delete the selected config",
        Callback = function()
            if not delfile then
                LibraryRef:Notify({ Title = "Unsupported", Message = "File system not available.", Type = "Error" })
                return
            end
            local name = cfgDropRef:Get()
            if not name then
                LibraryRef:Notify({ Title = "No Config", Message = "Select a config from the list.", Type = "Warning" })
                return
            end
            local ok, _ = SafeFS(delfile, CFG_FOLDER .. "/" .. name .. ".json")
            LibraryRef:Notify({
                Title = ok and "Deleted" or "Delete Failed",
                Message = ok and ('"' .. name .. '" has been deleted.') or "Could not delete the file.",
                Type = ok and "Success" or "Error",
            })
            cfgDropRef:SetOptions(GetCfgList())
        end,
    })

    CfgRight:CreateButton({
        Name = "Refresh List",
        Tooltip = "Re-scan disk for saved config files",
        Callback = function()
            cfgDropRef:SetOptions(GetCfgList())
            LibraryRef:Notify({ Title = "Refreshed", Message = "Config list updated.", Type = "Info" })
        end,
    })

    CfgRight:CreateDivider()

    CfgRight:CreateButton({
        Name = "Reset All Flags",
        Tooltip = "Clear all flag values (does NOT delete files)",
        Callback = function()
            UtilsRef.tableClear(LibraryRef.Flags)
            LibraryRef:Notify({ Title = "Flags Cleared", Message = "All flags have been reset.", Type = "Warning" })
        end,
    })
end

return ConfigManager
