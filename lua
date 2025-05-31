if getgenv().Sense_Hub then warn("Sense Hub is already executed") return end
getgenv().Sense_Hub = true

-- Global variables
local angleTick = 0

loadstring([[
local function LPH_NO_VIRTUALIZE(f) return f end;
]])();

-- Safely get Players service
local players = game:GetService("Players")
local player

local tweenService = game:GetService("TweenService")
local statsService = game:GetService("Stats")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local httpService = game:GetService("HttpService")
local starterGui = game:GetService("StarterGui")

-- Get player reference safely
local success, result = pcall(function()
    return players.LocalPlayer
end)
if success then
    player = result
else
    -- Fallback if we can't get the player
    for _, p in pairs(players:GetPlayers()) do
        player = p
        break
    end
end

local mouse
pcall(function()
    mouse = player and player:GetMouse()
end)

local camera = workspace.CurrentCamera
local values = nil

pcall(function()
    values = replicatedStorage:FindFirstChild("Values")
end)

local IS_PRACTICE = game.PlaceId == 8206123457
local IS_SOLARA = typeof(getexecutorname) == "function" and string.match(getexecutorname(), "Solara") or false
local AC_BYPASS = IS_PRACTICE

local moveToUsing = {}

-- Clean up old moveToUsing times
task.spawn(function()
    while true do
        task.wait(5)
        local currentTime = os.clock()
        for i = #moveToUsing, 1, -1 do
            if currentTime - moveToUsing[i] > 2 then
                table.remove(moveToUsing, i)
            end
        end
    end
end)

-- Track last moveTo time
task.spawn(function()
    local oldMoveTo = player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.MoveTo

    if oldMoveTo then
        player.Character.Humanoid.MoveTo = function(self, position, ...)
            table.insert(moveToUsing, os.clock())
            return oldMoveTo(self, position, ...)
        end
    end

    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        local oldMoveTo = humanoid.MoveTo

        humanoid.MoveTo = function(self, position, ...)
            table.insert(moveToUsing, os.clock())
            return oldMoveTo(self, position, ...)
        end
    end)
end)

if not values or IS_PRACTICE then
    if replicatedStorage:FindFirstChild("Values") then
        replicatedStorage:FindFirstChild("Values"):Destroy()
    end
    values = Instance.new("Folder")
    local status = Instance.new("StringValue")
    status.Name = "Status"
    status.Value = "InPlay"
    status.Parent = values
    values.Parent = replicatedStorage
    values.Name = "Values"
end

if not LPH_OBFUSCATED then
    getfenv().LPH_NO_VIRTUALIZE = function(f) return f end
end

local Handshake = replicatedStorage.Remotes.CharacterSoundEvent
local Hooks = {}
local HandshakeInts = {}

LPH_NO_VIRTUALIZE(function()
    for i, v in getgc() do
        if typeof(v) == "function" and islclosure(v) then
            if (#getprotos(v) == 1) and table.find(getconstants(getproto(v, 1)), 4000001) then
                hookfunction(v, function() end)
            end
        end
    end
end)()

Hooks.__namecall = hookmetamethod(game, "__namecall", LPH_NO_VIRTUALIZE(function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}

    if not checkcaller() and (self == Handshake) and (Method == "fireServer") and (string.find(Args[1], "AC")) then
        if (#HandshakeInts == 0) then
            HandshakeInts = {table.unpack(Args[2], 2, 18)}
        else
            for i, v in HandshakeInts do
                Args[2][i + 1] = v
            end
        end
    end

    return Hooks.__namecall(self, ...)
end))

task.wait(1)

if not isfolder("Sense Hub") then
    makefolder("Sense Hub")
end

local ping = 0
local fps = 0

-- Load SenseUI library
local SenseUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/RealVeylo/SenseUI/refs/heads/main/lua"))()

local function safeIndex(t, index)
    if type(t) ~= "table" and type(t) ~= "userdata" then
        return nil
    end

    local success, result = pcall(function()
        return t[index]
    end)

    if success then
        return result
    else
        return nil
    end
end

-- Extended Tab functionality for SenseUI
local function extendTabFunctionality(tab)
    function tab:CreateKeybind(text, defaultKey, callback)
        text = text or "New Keybind"
        defaultKey = defaultKey or Enum.KeyCode.F
        callback = callback or function() end

        -- Create the keybind in the system
        local keybindName = text:gsub("%s+", "")
        local keybind = KeybindSystem:CreateKeybind(keybindName, defaultKey, callback)

        -- Create UI element similar to button but for keybind
        local KeybindLabel = Instance.new("TextLabel")
        local KeybindButton = Instance.new("TextButton")
        local KeybindButtonBG = Instance.new("ImageLabel")
        local KeybindCorner = Instance.new("UICorner")

        KeybindLabel.Name = "KeybindLabel"
        KeybindLabel.Parent = tab.Frame -- Use the frame from the tab
        KeybindLabel.BackgroundTransparency = 1
        KeybindLabel.Size = UDim2.new(0, 200, 0, 50)
        KeybindLabel.Font = Enum.Font.SourceSansSemibold
        KeybindLabel.Text = text
        KeybindLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeybindLabel.TextSize = 14

        KeybindButton.Name = "KeybindButton"
        KeybindButton.Parent = KeybindLabel
        KeybindButton.BackgroundTransparency = 1
        KeybindButton.Position = UDim2.new(1, 0, 0.3, 0)
        KeybindButton.Size = UDim2.new(0, 60, 0, 20)
        KeybindButton.Font = Enum.Font.SourceSansBold
        KeybindButton.Text = KeybindSystem:GetKeyName(defaultKey)
        KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeybindButton.TextSize = 12
        KeybindButton.ZIndex = 2

        KeybindButtonBG.Name = "KeybindButtonBG"
        KeybindButtonBG.Parent = KeybindButton
        KeybindButtonBG.BackgroundTransparency = 1
        KeybindButtonBG.Size = UDim2.new(1, 0, 1, 0)
        KeybindButtonBG.Image = "rbxassetid://3570695787"
        KeybindButtonBG.ImageColor3 = Color3.fromRGB(35, 35, 35)
        KeybindButtonBG.ScaleType = Enum.ScaleType.Slice
        KeybindButtonBG.SliceCenter = Rect.new(100, 100, 100, 100)
        KeybindButtonBG.SliceScale = 0.020

        KeybindCorner.CornerRadius = UDim.new(0, 4)
        KeybindCorner.Parent = KeybindButtonBG

        local listening = false
        KeybindButton.MouseButton1Click:Connect(function()
            if listening then return end
            listening = true
            KeybindButton.Text = "..."
            KeybindButtonBG.ImageColor3 = Color3.fromRGB(0, 255, 255)

            local connection
            connection = userInputService.InputBegan:Connect(function(input, gameProcessed)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    keybind.key = input.KeyCode
                    KeybindButton.Text = KeybindSystem:GetKeyName(input.KeyCode)
                    KeybindButtonBG.ImageColor3 = Color3.fromRGB(35, 35, 35)
                    listening = false
                    connection:Disconnect()
                end
            end)
        end)

        return keybind
    end

    return tab
end

-- Create window and tabs using SenseUI (REMOVED Throwing tab)
local Window = SenseUI:CreateWindow("Sense Hub")
local Tabs = {
    Catching = extendTabFunctionality(Window:CreateTab("Catching")),
    Physics = extendTabFunctionality(Window:CreateTab("Physics")),
    Auto = extendTabFunctionality(Window:CreateTab("Auto")),
    Player = extendTabFunctionality(Window:CreateTab("Player")),
    Settings = extendTabFunctionality(Window:CreateTab("Settings"))
}

-- Set the first tab as active
Tabs.Catching:Show()

-- Options table to store values
local Options = {}

-- Helper function to create option storage
local function createOption(name, defaultValue)
    Options[name] = {
        Value = defaultValue,
        Default = defaultValue,
        SetValue = function(self, value)
            self.Value = value
        end
    }
    return Options[name]
end

-- Config System
local ConfigSystem = {}
ConfigSystem.configs = {}

function ConfigSystem:SaveConfig(name)
    if not name or name == "" then return false end

    local configData = {}
    for optionName, option in pairs(Options) do
        configData[optionName] = option.Value
    end

    local success = pcall(function()
        if not isfolder("Sense Hub") then
            makefolder("Sense Hub")
        end
        if not isfolder("Sense Hub/configs") then
            makefolder("Sense Hub/configs")
        end
        writefile("Sense Hub/configs/" .. name .. ".json", httpService:JSONEncode(configData))
    end)

    return success
end

function ConfigSystem:LoadConfig(name)
    if not name or name == "" then return false end

    local success = pcall(function()
        if isfile("Sense Hub/configs/" .. name .. ".json") then
            local configData = httpService:JSONDecode(readfile("Sense Hub/configs/" .. name .. ".json"))

            for optionName, value in pairs(configData) do
                if Options[optionName] then
                    Options[optionName]:SetValue(value)
                end
            end
            return true
        end
    end)

    return success
end

function ConfigSystem:GetConfigs()
    local configs = {}
    if isfolder("Sense Hub/configs") then
        for _, file in pairs(listfiles("Sense Hub/configs")) do
            if file:sub(-5) == ".json" then
                local configName = file:match("([^/\\]+)%.json$")
                if configName then
                    table.insert(configs, configName)
                end
            end
        end
    end
    return configs
end

function ConfigSystem:DeleteConfig(name)
    if not name or name == "" then return false end

    local success = pcall(function()
        if isfile("Sense Hub/configs/" .. name .. ".json") then
            delfile("Sense Hub/configs/" .. name .. ".json")
            return true
        end
    end)

    return success
end

-- Keybind System
local KeybindSystem = {}
KeybindSystem.keybinds = {}

function KeybindSystem:CreateKeybind(name, defaultKey, callback)
    local keybind = {
        name = name,
        key = defaultKey,
        callback = callback or function() end,
        enabled = true
    }

    self.keybinds[name] = keybind
    return keybind
end

function KeybindSystem:SetKeybind(name, newKey)
    if self.keybinds[name] then
        self.keybinds[name].key = newKey
    end
end

function KeybindSystem:GetKeyName(keyCode)
    local keyNames = {
        [Enum.KeyCode.Q] = "Q", 
        [Enum.KeyCode.W] = "W", 
        [Enum.KeyCode.E] = "E", 
        [Enum.KeyCode.R] = "R",
        [Enum.KeyCode.T] = "T", 
        [Enum.KeyCode.Y] = "Y", 
        [Enum.KeyCode.U] = "U", 
        [Enum.KeyCode.I] = "I",
        [Enum.KeyCode.O] = "O", 
        [Enum.KeyCode.P] = "P", 
        [Enum.KeyCode.A] = "A", 
        [Enum.KeyCode.S] = "S",
        [Enum.KeyCode.D] = "D", 
        [Enum.KeyCode.F] = "F", 
        [Enum.KeyCode.G] = "G", 
        [Enum.KeyCode.H] = "H",
        [Enum.KeyCode.J] = "J", 
        [Enum.KeyCode.K] = "K", 
        [Enum.KeyCode.L] = "L", 
        [Enum.KeyCode.Z] = "Z",
        [Enum.KeyCode.X] = "X", 
        [Enum.KeyCode.C] = "C", 
        [Enum.KeyCode.V] = "V", 
        [Enum.KeyCode.B] = "B",
        [Enum.KeyCode.N] = "N", 
        [Enum.KeyCode.M] = "M", 
        [Enum.KeyCode.One] = "1", 
        [Enum.KeyCode.Two] = "2",
        [Enum.KeyCode.Three] = "3", 
        [Enum.KeyCode.Four] = "4", 
        [Enum.KeyCode.Five] = "5", 
        [Enum.KeyCode.Six] = "6",
        [Enum.KeyCode.Seven] = "7", 
        [Enum.KeyCode.Eight] = "8", 
        [Enum.KeyCode.Nine] = "9", 
        [Enum.KeyCode.Zero] = "0",
        [Enum.KeyCode.LeftShift] = "LShift", 
        [Enum.KeyCode.RightShift] = "RShift", 
        [Enum.KeyCode.LeftControl] = "LCtrl",
        [Enum.KeyCode.RightControl] = "RCtrl", 
        [Enum.KeyCode.LeftAlt] = "LAlt", 
        [Enum.KeyCode.RightAlt] = "RAlt",
        [Enum.KeyCode.Tab] = "Tab", 
        [Enum.KeyCode.Space] = "Space", 
        [Enum.KeyCode.Return] = "Enter"
    }
    return keyNames[keyCode] or tostring(keyCode):gsub("Enum.KeyCode.", "")
end

-- Input handler for keybinds
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    for _, keybind in pairs(KeybindSystem.keybinds) do
        if keybind.enabled and input.KeyCode == keybind.key then
            pcall(keybind.callback)
        end
    end
end)

-- Create toggles and sliders using SenseUI

-- PLAYER TAB (Moved from Throwing tab)
local QuickTPToggle = createOption("QuickTP", false)
Tabs.Player:CreateToggle("Quick TP", function(value)
    QuickTPToggle:SetValue(value)
end)

local QuickTPSpeed = createOption("QuickTPSpeed", 3)
Tabs.Player:CreateSlider("Speed", 1, 5, function(value)
    QuickTPSpeed:SetValue(value)
end)

-- Create keybind for Quick TP
local quickTPCooldown = os.clock()
local QuickTPKeybind = Tabs.Player:CreateKeybind("Quick TP Key", Enum.KeyCode.F, function()
    if not Options.QuickTP or not Options.QuickTP.Value then return end

    local character = player.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChild("Humanoid")

    if not character or not humanoidRootPart or not humanoid then return end
    if (os.clock() - quickTPCooldown) < 0.1 then return end

    local speed = 2 + ((Options.QuickTPSpeed and Options.QuickTPSpeed.Value or 3) / 4)

    humanoidRootPart.CFrame += humanoid.MoveDirection * speed
    quickTPCooldown = os.clock()
end)

-- Fixed Dive Power (moved from throwing tab)
local DivePowerToggle = createOption("DivePower", false)
Tabs.Player:CreateToggle("Dive Power", function(value)
    DivePowerToggle:SetValue(value)
end)

local DivePowerDistance = createOption("DivePowerDistance", 3)
Tabs.Player:CreateSlider("Dive Distance", 0, 10, function(value)
    DivePowerDistance:SetValue(value)
end)

-- Speed controls
local SpeedToggle = createOption("Speed", false)
Tabs.Player:CreateToggle("Speed", function(value)
    SpeedToggle:SetValue(value)
    if value then
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Options.SpeedValue.Value
        end
    end
end)

local SpeedValue = createOption("SpeedValue", 22)
Tabs.Player:CreateSlider("Speed Value", 20, 23, function(value)
    SpeedValue:SetValue(value)
    if Options.Speed and Options.Speed.Value then
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
end)

local JumpPowerToggle = createOption("JumpPower", false)
Tabs.Player:CreateToggle("Jump Power", function(value)
    JumpPowerToggle:SetValue(value)
end)

local JumpPowerValue = createOption("JumpPowerValue", 60)
Tabs.Player:CreateSlider("Power", 50, 70, function(value)
    JumpPowerValue:SetValue(value)
    if Options.JumpPower and Options.JumpPower.Value then
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        if humanoid then
            if AC_BYPASS then
                humanoid.JumpPower = value
            end
        end
    end
end)

local AngleAssistToggle = createOption("AngleAssist", false)
Tabs.Player:CreateToggle("Angle Enhancer", function(value)
    AngleAssistToggle:SetValue(value)
end)

local AngleAssistJP = createOption("AngleAssistJP", 60)
Tabs.Player:CreateSlider("JP", 50, 70, function(value)
    AngleAssistJP:SetValue(value)
    if Options.AngleAssist and Options.AngleAssist.Value then
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        if humanoid and AC_BYPASS then
            humanoid.JumpPower = value
        end
    end
end)

-- PHYSICS TAB
local ClickTackleAimbotToggle = createOption("ClickTackleAimbot", false)
Tabs.Physics:CreateToggle("Click Tackle Aimbot", function(value)
    ClickTackleAimbotToggle:SetValue(value)
end)

local ClickTackleAimbotDistance = createOption("ClickTackleAimbotDistance", 7)
Tabs.Physics:CreateSlider("Distance", 0, 15, function(value)
    ClickTackleAimbotDistance:SetValue(value)
end)

local AntiJamToggle = createOption("AntiJam", false)
Tabs.Physics:CreateToggle("Anti Jam", function(value)
    AntiJamToggle:SetValue(value)
end)

local AntiBlockToggle = createOption("AntiBlock", false)
Tabs.Physics:CreateToggle("Anti Block", function(value)
    AntiBlockToggle:SetValue(value)
end)

local VisualizeBallPathToggle = createOption("VisualizeBallPath", false)
Tabs.Physics:CreateToggle("Visualize Ball Path", function(value)
    VisualizeBallPathToggle:SetValue(value)
end)

local NoJumpCooldownToggle = createOption("NoJumpCooldown", false)
Tabs.Physics:CreateToggle("No Jump Cooldown", function(value)
    NoJumpCooldownToggle:SetValue(value)
end)

local NoFreezeToggle = createOption("NoFreeze", false)
Tabs.Physics:CreateToggle("No Freeze", function(value)
    NoFreezeToggle:SetValue(value)
end)

local OptimalJumpToggle = createOption("OptimalJump", false)
Tabs.Physics:CreateToggle("Optimal Jump", function(value)
    OptimalJumpToggle:SetValue(value)
end)

local OptimalJumpType = createOption("OptimalJumpType", "Jump")
Tabs.Physics:CreateDropdown("Type", {"Jump", "Dive"}, function(value)
    OptimalJumpType:SetValue(value)
end)

local NoBallTrailToggle = createOption("NoBallTrail", false)
Tabs.Physics:CreateToggle("No Ball Trail", function(value)
    NoBallTrailToggle:SetValue(value)
end)

local BigHeadToggle = createOption("BigHead", false)
Tabs.Physics:CreateToggle("Big Head", function(value)
    BigHeadToggle:SetValue(value)
end)

local BigHeadSize = createOption("BigHeadSize", 3)
Tabs.Physics:CreateSlider("Size", 1, 5, function(value)
    BigHeadSize:SetValue(value)
end)

local AntiOOBToggle = createOption("AntiOOB", false)
Tabs.Physics:CreateToggle("Anti Out Of Bounds", function(value)
    AntiOOBToggle:SetValue(value)
end)

-- CATCHING TAB
local MagnetsToggle = createOption("Magnets", false)
Tabs.Catching:CreateToggle("Magnets", function(value)
    MagnetsToggle:SetValue(value)
end)

local MagnetsType = createOption("MagnetsType", "League")
Tabs.Catching:CreateDropdown("Type", {"Blatant", "Legit", "League"}, function(value)
    MagnetsType:SetValue(value)
end)

local MagnetsCustomRadius = createOption("MagnetsCustomRadius", 35)
Tabs.Catching:CreateSlider("Radius", 0, 70, function(value)
    MagnetsCustomRadius:SetValue(value)
end)

local ShowMagHitbox = createOption("ShowMagHitbox", false)
Tabs.Catching:CreateToggle("Visualise Hitbox", function(value)
    ShowMagHitbox:SetValue(value)
end)

local PullVectorToggle = createOption("PullVector", false)
Tabs.Catching:CreateToggle("Pull Vector", function(value)
    PullVectorToggle:SetValue(value)
end)

local PullVectorDistance = createOption("PullVectorDistance", 50)
Tabs.Catching:CreateSlider("Distance", 0, 100, function(value)
    PullVectorDistance:SetValue(value)
end)

local PullVectorType = createOption("PullVectorType", "Glide")
Tabs.Catching:CreateDropdown("Type", {"Glide", "Teleport"}, function(value)
    PullVectorType:SetValue(value)
end)

local PullVectorPower = createOption("PullVectorPower", 3)
Tabs.Catching:CreateSlider("Power", 1, 5, function(value)
    PullVectorPower:SetValue(value)
end)

local FreezeTechToggle = createOption("FreezeTech", false)
Tabs.Catching:CreateToggle("Freeze Tech", function(value)
    FreezeTechToggle:SetValue(value)
end)

local FreezeTechDuration = createOption("FreezeTechDuration", 0.5)
Tabs.Catching:CreateSlider("Freeze Duration", 0, 3, function(value)
    FreezeTechDuration:SetValue(value)
end)

-- AUTO TAB
local AutoCapToggle = createOption("AutoCap", false)
Tabs.Auto:CreateToggle("Auto Cap", function(value)
    AutoCapToggle:SetValue(value)
end)

local AutoResetToggle = createOption("AutoReset", false)
Tabs.Auto:CreateToggle("Auto Reset After Catch", function(value)
    AutoResetToggle:SetValue(value)
end)

local AutoResetDelay = createOption("AutoResetDelay", 1)
Tabs.Auto:CreateSlider("Reset Delay", 0, 5, function(value)
    AutoResetDelay:SetValue(value)
end)

-- SETTINGS TAB - Config System UI
local currentConfigName = ""
local configNames = ConfigSystem:GetConfigs()
table.insert(configNames, 1, "Enter New Name")

local ConfigNameDropdown = createOption("ConfigName", "Enter New Name")
Tabs.Settings:CreateDropdown("Config Name", configNames, function(value)
    ConfigNameDropdown:SetValue(value)
    currentConfigName = value
end)

Tabs.Settings:CreateButton("Save Config", function()
    if currentConfigName == "" or currentConfigName == "Enter New Name" then
        currentConfigName = "Config_" .. os.date("%H%M%S")
    end

    local success = ConfigSystem:SaveConfig(currentConfigName)
    if success then
        print("Config saved: " .. currentConfigName)
    else
        print("Failed to save config")
    end
end)

Tabs.Settings:CreateButton("Load Config", function()
    if currentConfigName == "" or currentConfigName == "Enter New Name" then
        print("Please select a config to load")
        return
    end

    local success = ConfigSystem:LoadConfig(currentConfigName)
    if success then
        print("Config loaded: " .. currentConfigName)
    else
        print("Failed to load config")
    end
end)

Tabs.Settings:CreateButton("Delete Config", function()
    if currentConfigName == "" or currentConfigName == "Enter New Name" then
        print("Please select a config to delete")
        return
    end

    local success = ConfigSystem:DeleteConfig(currentConfigName)
    if success then
        print("Config deleted: " .. currentConfigName)
        configNames = ConfigSystem:GetConfigs()
        table.insert(configNames, 1, "Enter New Name")
    else
        print("Failed to delete config")
    end
end)

local AutoSaveToggle = createOption("AutoSave", false)
Tabs.Settings:CreateToggle("Auto Save", function(value)
    AutoSaveToggle:SetValue(value)
end)

-- PHYSICS EXTENDERS
if firetouchinterest and not IS_SOLARA then
    local TackleExtenderToggle = createOption("TackleExtender", false)
    Tabs.Physics:CreateToggle("Tackle Extender", function(value)
        TackleExtenderToggle:SetValue(value)
    end)

    local TackleExtenderRadius = createOption("TackleExtenderRadius", 5)
    Tabs.Physics:CreateSlider("Radius", 0, 10, function(value)
        TackleExtenderRadius:SetValue(value)
    end)
end

if AC_BYPASS then
    local BlockExtenderToggle = createOption("BlockExtender", false)
    Tabs.Physics:CreateToggle("Block Extender", function(value)
        BlockExtenderToggle:SetValue(value)
    end)

    local BlockExtenderRange = createOption("BlockExtenderRange", 10)
    Tabs.Physics:CreateSlider("Range", 1, 20, function(value)
        BlockExtenderRange:SetValue(value)
    end)

    local BlockExtenderTransparency = createOption("BlockExtenderTransparency", 1)
    Tabs.Physics:CreateSlider("Transparency", 0, 1, function(value)
        BlockExtenderTransparency:SetValue(value)
    end)
end

-- UTILITY FUNCTIONS
local function getPing()
    return statsService.PerformanceStats.Ping:GetValue()
end

local function getServerPing()
    return statsService.Network.ServerStatsItem['Data Ping']:GetValue()
end

local function findClosestBall()
    local lowestDistance = math.huge
    local nearestBall = nil

    local character = player.Character
    if not character then return nil end

    for index, ball in pairs(workspace:GetChildren()) do
        if ball.Name ~= "Football" then continue end
        if not ball:IsA("BasePart") then continue end
        if not character:FindFirstChild("HumanoidRootPart") then continue end
        local distance = (ball.Position - character.HumanoidRootPart.Position).Magnitude

        if distance < lowestDistance then
            nearestBall = ball
            lowestDistance = distance
        end
    end

    return nearestBall
end

local function findPossessor()
    if not players then return nil end

    for _, plr in pairs(players:GetPlayers()) do
        if not plr or not plr.Character then continue end
        local character = plr.Character
        if not character:FindFirstChildWhichIsA("Tool") then continue end
        return character
    end
    return nil
end

local function getNearestPartToPartFromParts(part, parts)
    local lowestDistance = math.huge
    local nearestPart = nil

    for index, p in pairs(parts) do
        local distance = (part.Position - p.Position).Magnitude

        if distance < lowestDistance then
            nearestPart = p
            lowestDistance = distance
        end
    end

    return nearestPart
end

function beamProjectile(g, v0, x0, t1)
    local c = 0.5*0.5*0.5;
    local p3 = 0.5*g*t1*t1 + v0*t1 + x0;
    local p2 = p3 - (g*t1*t1 + v0*t1)/3;
    local p1 = (c*g*t1*t1 + 0.5*v0*t1 + x0 - c*(x0+p3))/(3*c) - p2;

    local curve0 = (p1 - x0).magnitude;
    local curve1 = (p2 - p3).magnitude;

    local b = (x0 - p3).unit;
    local r1 = (p1 - x0).unit;
    local u1 = r1:Cross(b).unit;
    local r2 = (p2 - p3).unit;
    local u2 = r2:Cross(b).unit;
    b = u1:Cross(r1).unit;

    local cf1 = CFrame.new(
        x0.x, x0.y, x0.z,
        r1.x, u1.x, b.x,
        r1.y, u1.y, b.y,
        r1.z, u1.z, b.z
    )

    local cf2 = CFrame.new(
        p3.x, p3.y, p3.z,
        r2.x, u2.x, b.x,
        r2.y, u2.y, b.y,
        r2.z, u2.z, b.z
    )

    return curve0, -curve1, cf1, cf2;
end

-- TRACKING VARIABLES
local boundaries = {}
local fakeBalls = {}
local pullVectoredBalls = {}
local velocity = {}
local isCatching = false

if not IS_PRACTICE then
    for index, part in pairs(workspace.Models.Boundaries:GetChildren()) do
        boundaries[#boundaries + 1] = part
    end
end

-- Initialize magnet hitbox visualization
local part = Instance.new("Part")
part.Transparency = 0.5
part.Anchored = true
part.CanCollide = false
part.CastShadow = false
part.Color = Color3.fromRGB(0, 255, 255)
part.Shape = Enum.PartType.Ball
part.Material = Enum.Material.ForceField
part.Parent = workspace

-- Define firetouchinterest with proper fallback
firetouchinterest = firetouchinterest or function() end

-- Customize firetouchinterest for Solara
if IS_SOLARA then
    local originalFiretouchinterest = firetouchinterest
    firetouchinterest = function(part2, part1, state)
        if AC_BYPASS then
            return originalFiretouchinterest(part2, part1, state)
        else
            state = state == 1
            local fakeBall = fakeBalls[part1]
            if not fakeBall then return end

            local direction = (part2.Position - fakeBall.Position).Unit
            local distance = (part2.Position - fakeBall.Position).Magnitude

            for i = 1,5,1 do
                local percentage = i/5 + Random.new():NextNumber(0.01, 0.02)
                part1.CFrame = fakeBall.CFrame + (direction * distance * percentage)
            end
        end
    end
end

-- FIXED DIVE POWER HOOK
local divePowerOldNamecall
divePowerOldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method, args = getnamecallmethod(), {...}
    if args[2] == "dive" and Options.DivePower and Options.DivePower.Value then
        local character = player.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            -- Fixed dive power to prevent getting stuck in ground
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local diveForce = Options.DivePowerDistance and Options.DivePowerDistance.Value or 3
                -- Apply horizontal force instead of velocity to prevent ground clipping
                local lookDirection = humanoidRootPart.CFrame.LookVector
                local horizontalForce = Vector3.new(lookDirection.X, 0, lookDirection.Z).Unit * diveForce * 10
                
                -- Apply impulse instead of direct velocity change
                humanoidRootPart:ApplyImpulse(horizontalForce * humanoidRootPart.AssemblyMass)
            end
        end
    end
    return divePowerOldNamecall(self, ...)
end)

-- MAIN LOOPS AND HANDLERS

-- Clean up tables periodically
task.spawn(function()
    while true do
        task.wait(30)
        for ball, _ in pairs(pullVectoredBalls) do
            if not ball or not ball.Parent then
                pullVectoredBalls[ball] = nil
            end
        end

        for ball, _ in pairs(fakeBalls) do
            if not ball or not ball.Parent then
                if fakeBalls[ball] and fakeBalls[ball].Parent then
                    fakeBalls[ball]:Destroy()
                end
                fakeBalls[ball] = nil
            end
        end

        for ball, _ in pairs(velocity) do
            if not ball or not ball.Parent then
                velocity[ball] = nil
            end
        end
    end
end)

-- Ping tracking
task.spawn(function()
    while true do
        task.wait(0.1)
        ping = ( getPing() + getServerPing() ) / 1000
    end
end)

-- FPS tracking
task.spawn(function()
    runService.RenderStepped:Connect(function()
        fps += 1
        task.delay(1, function()
            fps -= 1
        end)
    end)
end)

-- Character catching handler
local function onCharacterCatching(character)
    if not character then return end

    local arm
    local success = pcall(function()
        arm = character:WaitForChild('Left Arm', 5)
    end)

    if not success or not arm then return end

    arm.ChildAdded:Connect(function(child)
        if not child:IsA("Weld") then return end
        isCatching = true
        task.wait(1.7)
        isCatching = false
    end)

    character.ChildAdded:Connect(function(child)
        if child.Name == "Football" and child:IsA("Tool") then
            -- Freeze Tech
            if Options.FreezeTech and Options.FreezeTech.Value then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local hrp = character:FindFirstChild("HumanoidRootPart")

                if humanoid and hrp and humanoid.FloorMaterial == Enum.Material.Air then
                    if not IS_PRACTICE then
                        if values and values.Status.Value ~= "InPlay" then return end
                    end

                    local originalWalkSpeed = humanoid.WalkSpeed
                    local originalJumpPower = humanoid.JumpPower

                    humanoid.WalkSpeed = 0
                    humanoid.JumpPower = 0
                    hrp.Anchored = true

                    local freezeDuration = Options.FreezeTechDuration and Options.FreezeTechDuration.Value or 0.5
                    if freezeDuration <= 0 then freezeDuration = 0.01 end

                    task.delay(freezeDuration, function()
                        if character and character.Parent and humanoid and humanoid.Parent and hrp and hrp.Parent then
                            hrp.Anchored = false
                            humanoid.WalkSpeed = originalWalkSpeed
                            humanoid.JumpPower = originalJumpPower
                        end
                    end)
                end
            end

            -- Auto Reset After Catch
            if Options.AutoReset and Options.AutoReset.Value then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    task.wait(Options.AutoResetDelay and Options.AutoResetDelay.Value or 1)
                    humanoid.Health = 0
                end
            end
        end
    end)
end

-- Initialize character handlers
onCharacterCatching(player.Character)
player.CharacterAdded:Connect(onCharacterCatching)

-- Auto-save functionality
task.spawn(function()
    while true do
        task.wait(30)
        if Options.AutoSave and Options.AutoSave.Value then
            ConfigSystem:SaveConfig("autosave")
        end
    end
end)

-- Load autosave on startup
task.wait(2)
ConfigSystem:LoadConfig("autosave")

-- Initialize option defaults
for _, option in pairs(Options) do
    if type(option) == "table" and option.SetValue then
        local success, err = pcall(function()
            if option.Value == nil then
                option:SetValue(option.Default)
            end
        end)
    end
end

print("Sense Hub loaded successfully!")
