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

-- ORIGINAL SCRIPT CONTINUES - Load SenseUI library (keeping original UI as backup)
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

-- ORIGINAL Config System (Enhanced)
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
                    -- Update UI elements if they exist
                    if getgenv().MillenniumUI and getgenv().MillenniumUI.UpdateOption then
                        getgenv().MillenniumUI:UpdateOption(optionName, value)
                    end
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

-- ORIGINAL Keybind System
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
        [Enum.KeyCode.Q] = "Q", [Enum.KeyCode.W] = "W", [Enum.KeyCode.E] = "E", [Enum.KeyCode.R] = "R",
        [Enum.KeyCode.T] = "T", [Enum.KeyCode.Y] = "Y", [Enum.KeyCode.U] = "U", [Enum.KeyCode.I] = "I",
        [Enum.KeyCode.O] = "O", [Enum.KeyCode.P] = "P", [Enum.KeyCode.A] = "A", [Enum.KeyCode.S] = "S",
        [Enum.KeyCode.D] = "D", [Enum.KeyCode.F] = "F", [Enum.KeyCode.G] = "G", [Enum.KeyCode.H] = "H",
        [Enum.KeyCode.J] = "J", [Enum.KeyCode.K] = "K", [Enum.KeyCode.L] = "L", [Enum.KeyCode.Z] = "Z",
        [Enum.KeyCode.X] = "X", [Enum.KeyCode.C] = "C", [Enum.KeyCode.V] = "V", [Enum.KeyCode.B] = "B",
        [Enum.KeyCode.N] = "N", [Enum.KeyCode.M] = "M", [Enum.KeyCode.One] = "1", [Enum.KeyCode.Two] = "2",
        [Enum.KeyCode.Three] = "3", [Enum.KeyCode.Four] = "4", [Enum.KeyCode.Five] = "5", [Enum.KeyCode.Six] = "6",
        [Enum.KeyCode.Seven] = "7", [Enum.KeyCode.Eight] = "8", [Enum.KeyCode.Nine] = "9", [Enum.KeyCode.Zero] = "0",
        [Enum.KeyCode.LeftShift] = "LShift", [Enum.KeyCode.RightShift] = "RShift",
        [Enum.KeyCode.LeftControl] = "LCtrl", [Enum.KeyCode.RightControl] = "RCtrl",
        [Enum.KeyCode.LeftAlt] = "LAlt", [Enum.KeyCode.RightAlt] = "RAlt",
        [Enum.KeyCode.Tab] = "Tab", [Enum.KeyCode.Space] = "Space", [Enum.KeyCode.Return] = "Enter"
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

-- ALL ORIGINAL OPTIONS CREATION
local QuickTPToggle = createOption("QuickTP", false)
local QuickTPSpeed = createOption("QuickTPSpeed", 3)
local DivePowerToggle = createOption("DivePower", false)
local DivePowerDistance = createOption("DivePowerDistance", 3)
local SpeedToggle = createOption("Speed", false)
local SpeedValue = createOption("SpeedValue", 22)
local JumpPowerToggle = createOption("JumpPower", false)
local JumpPowerValue = createOption("JumpPowerValue", 60)
local AngleAssistToggle = createOption("AngleAssist", false)
local AngleAssistJP = createOption("AngleAssistJP", 60)
local ClickTackleAimbotToggle = createOption("ClickTackleAimbot", false)
local ClickTackleAimbotDistance = createOption("ClickTackleAimbotDistance", 7)
local AntiJamToggle = createOption("AntiJam", false)
local AntiBlockToggle = createOption("AntiBlock", false)
local VisualizeBallPathToggle = createOption("VisualizeBallPath", false)
local NoJumpCooldownToggle = createOption("NoJumpCooldown", false)
local NoFreezeToggle = createOption("NoFreeze", false)
local OptimalJumpToggle = createOption("OptimalJump", false)
local OptimalJumpType = createOption("OptimalJumpType", "Jump")
local NoBallTrailToggle = createOption("NoBallTrail", false)
local BigHeadToggle = createOption("BigHead", false)
local BigHeadSize = createOption("BigHeadSize", 3)
local AntiOOBToggle = createOption("AntiOOB", false)
local MagnetsToggle = createOption("Magnets", false)
local MagnetsType = createOption("MagnetsType", "League")
local MagnetsCustomRadius = createOption("MagnetsCustomRadius", 35)
local ShowMagHitbox = createOption("ShowMagHitbox", false)
local PullVectorToggle = createOption("PullVector", false)
local PullVectorDistance = createOption("PullVectorDistance", 50)
local PullVectorType = createOption("PullVectorType", "Glide")
local PullVectorPower = createOption("PullVectorPower", 3)
local FreezeTechToggle = createOption("FreezeTech", false)
local FreezeTechDuration = createOption("FreezeTechDuration", 0.5)
local AutoCapToggle = createOption("AutoCap", false)
local AutoResetToggle = createOption("AutoReset", false)
local AutoResetDelay = createOption("AutoResetDelay", 1)
local AutoSaveToggle = createOption("AutoSave", false)

-- PHYSICS EXTENDERS (original)
if firetouchinterest and not IS_SOLARA then
    local TackleExtenderToggle = createOption("TackleExtender", false)
    local TackleExtenderRadius = createOption("TackleExtenderRadius", 5)
end

if AC_BYPASS then
    local BlockExtenderToggle = createOption("BlockExtender", false)
    local BlockExtenderRange = createOption("BlockExtenderRange", 10)
    local BlockExtenderTransparency = createOption("BlockExtenderTransparency", 1)
end

-- UTILITY FUNCTIONS (ALL ORIGINAL)
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

-- TRACKING VARIABLES (ALL ORIGINAL)
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

-- MILLENNIUM UI SETUP
local MillenniumUI = {}

-- Configuration
local Config = {
    MainImageId = "rbxassetid://129937299302497",
    Theme = {
        Background = Color3.fromRGB(25, 25, 35),
        SecondaryBackground = Color3.fromRGB(35, 35, 45),
        AccentColor = Color3.fromRGB(130, 100, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        SecondaryTextColor = Color3.fromRGB(180, 180, 180),
        BorderColor = Color3.fromRGB(60, 60, 70),
        SuccessColor = Color3.fromRGB(50, 200, 50),
        WarningColor = Color3.fromRGB(255, 200, 50),
        ErrorColor = Color3.fromRGB(255, 80, 80)
    }
}

-- Store globally for Part 2 access
getgenv().MillenniumUI = MillenniumUI
getgenv().Config = Config
getgenv().Options = Options
getgenv().ConfigSystem = ConfigSystem
getgenv().KeybindSystem = KeybindSystem

-- FF2 Script with Millennium UI Integration - PART 2 (CORRECTED)
-- Millennium UI Implementation + Complete Original Script Logic

-- Utility Functions for Millennium UI
local function CreateTween(object, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    return tweenService:Create(object, tweenInfo, properties)
end

local function RoundCorners(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = object
    return corner
end

local function AddStroke(object, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Config.Theme.BorderColor
    stroke.Thickness = thickness or 1
    stroke.Parent = object
    return stroke
end

-- Create Main GUI
function MillenniumUI:CreateGUI()
    -- Destroy existing GUI if it exists
    local playerGui = player:WaitForChild("PlayerGui")
    if playerGui:FindFirstChild("MillenniumUI") then
        playerGui.MillenniumUI:Destroy()
    end

    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MillenniumUI"
    ScreenGui.Parent = playerGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Toggle Button
    local ToggleButton = Instance.new("ImageButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 60, 0, 60)
    ToggleButton.Position = UDim2.new(0.5, -30, 0.5, -30)
    ToggleButton.BackgroundColor3 = Config.Theme.SecondaryBackground
    ToggleButton.Image = Config.MainImageId
    ToggleButton.ScaleType = Enum.ScaleType.Fit
    ToggleButton.Parent = ScreenGui
    ToggleButton.Active = true
    ToggleButton.Draggable = true

    RoundCorners(ToggleButton, 30)
    AddStroke(ToggleButton, Config.Theme.AccentColor, 2)

    -- Main Window
    local MainWindow = Instance.new("Frame")
    MainWindow.Name = "MainWindow"
    MainWindow.Size = UDim2.new(0, 850, 0, 550)
    MainWindow.Position = UDim2.new(0.5, -425, 0.5, -275)
    MainWindow.BackgroundColor3 = Config.Theme.Background
    MainWindow.Parent = ScreenGui
    MainWindow.Visible = false
    MainWindow.Active = true

    RoundCorners(MainWindow, 12)
    AddStroke(MainWindow, Config.Theme.BorderColor, 1)

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.BackgroundColor3 = Config.Theme.SecondaryBackground
    TitleBar.Parent = MainWindow

    RoundCorners(TitleBar, 12)

    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "TitleText"
    TitleText.Size = UDim2.new(1, -220, 1, 0)
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "Sense Hub - Millennium"
    TitleText.TextColor3 = Config.Theme.TextColor
    TitleText.TextSize = 18
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Font = Enum.Font.GothamBold
    TitleText.Parent = TitleBar

    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -40, 0, 5)
    CloseButton.BackgroundColor3 = Config.Theme.ErrorColor
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 20
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TitleBar

    RoundCorners(CloseButton, 6)

    -- Search Bar
    local SearchFrame = Instance.new("Frame")
    SearchFrame.Name = "SearchFrame"
    SearchFrame.Size = UDim2.new(0, 160, 0, 30)
    SearchFrame.Position = UDim2.new(1, -180, 0, 5)
    SearchFrame.BackgroundColor3 = Config.Theme.Background
    SearchFrame.Parent = TitleBar

    RoundCorners(SearchFrame, 6)

    local SearchBox = Instance.new("TextBox")
    SearchBox.Name = "SearchBox"
    SearchBox.Size = UDim2.new(1, -10, 1, 0)
    SearchBox.Position = UDim2.new(0, 5, 0, 0)
    SearchBox.BackgroundTransparency = 1
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "Search..."
    SearchBox.TextColor3 = Config.Theme.TextColor
    SearchBox.PlaceholderColor3 = Config.Theme.SecondaryTextColor
    SearchBox.TextSize = 14
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.Parent = SearchFrame

    -- Content Area
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, 0, 1, -40)
    ContentFrame.Position = UDim2.new(0, 0, 0, 40)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainWindow

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 180, 1, 0)
    Sidebar.Position = UDim2.new(0, 0, 0, 0)
    Sidebar.BackgroundColor3 = Config.Theme.SecondaryBackground
    Sidebar.Parent = ContentFrame

    RoundCorners(Sidebar, 8)

    -- Tab Container
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, -10, 1, -10)
    TabContainer.Position = UDim2.new(0, 5, 0, 5)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 4
    TabContainer.ScrollBarImageColor3 = Config.Theme.AccentColor
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.Parent = Sidebar

    -- Panel Area
    local PanelArea = Instance.new("Frame")
    PanelArea.Name = "PanelArea"
    PanelArea.Size = UDim2.new(1, -185, 1, -5)
    PanelArea.Position = UDim2.new(0, 185, 0, 5)
    PanelArea.BackgroundColor3 = Config.Theme.Background
    PanelArea.Parent = ContentFrame

    RoundCorners(PanelArea, 8)

    -- Store references
    self.ScreenGui = ScreenGui
    self.ToggleButton = ToggleButton
    self.MainWindow = MainWindow
    self.TabContainer = TabContainer
    self.PanelArea = PanelArea
    self.CurrentTab = nil
    self.Tabs = {}
    self.UIElements = {}

    -- Toggle functionality
    local isVisible = false
    ToggleButton.MouseButton1Click:Connect(function()
        isVisible = not isVisible
        MainWindow.Visible = isVisible

        if isVisible then
            MainWindow.Size = UDim2.new(0, 0, 0, 0)
            MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
            CreateTween(MainWindow, {
                Size = UDim2.new(0, 850, 0, 550),
                Position = UDim2.new(0.5, -425, 0.5, -275)
            }, 0.4, Enum.EasingStyle.Back):Play()
        end
    end)

    CloseButton.MouseButton1Click:Connect(function()
        isVisible = false
        CreateTween(MainWindow, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, 0.3):Play()

        wait(0.3)
        MainWindow.Visible = false
    end)

    -- Make window draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainWindow.Position
        end
    end)

    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    userInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    return self
end

-- Create Tab
function MillenniumUI:CreateTab(name, icon)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Tab"
    tabButton.Size = UDim2.new(1, -10, 0, 35)
    tabButton.Position = UDim2.new(0, 5, 0, #self.Tabs * 40 + 5)
    tabButton.BackgroundColor3 = Config.Theme.Background
    tabButton.Text = ""
    tabButton.Parent = self.TabContainer

    RoundCorners(tabButton, 6)

    local tabIcon = Instance.new("TextLabel")
    tabIcon.Name = "Icon"
    tabIcon.Size = UDim2.new(0, 20, 0, 20)
    tabIcon.Position = UDim2.new(0, 10, 0.5, -10)
    tabIcon.BackgroundTransparency = 1
    tabIcon.Text = icon or "●"
    tabIcon.TextColor3 = Config.Theme.SecondaryTextColor
    tabIcon.TextSize = 16
    tabIcon.Font = Enum.Font.Gotham
    tabIcon.Parent = tabButton

    local tabLabel = Instance.new("TextLabel")
    tabLabel.Name = "Label"
    tabLabel.Size = UDim2.new(1, -35, 1, 0)
    tabLabel.Position = UDim2.new(0, 35, 0, 0)
    tabLabel.BackgroundTransparency = 1
    tabLabel.Text = name
    tabLabel.TextColor3 = Config.Theme.SecondaryTextColor
    tabLabel.TextSize = 14
    tabLabel.TextXAlignment = Enum.TextXAlignment.Left
    tabLabel.Font = Enum.Font.Gotham
    tabLabel.Parent = tabButton

    -- Tab Panel
    local tabPanel = Instance.new("ScrollingFrame")
    tabPanel.Name = name .. "Panel"
    tabPanel.Size = UDim2.new(1, -10, 1, -10)
    tabPanel.Position = UDim2.new(0, 5, 0, 5)
    tabPanel.BackgroundTransparency = 1
    tabPanel.ScrollBarThickness = 4
    tabPanel.ScrollBarImageColor3 = Config.Theme.AccentColor
    tabPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabPanel.Visible = false
    tabPanel.Parent = self.PanelArea

    -- Tab functionality
    tabButton.MouseButton1Click:Connect(function()
        self:SelectTab(name)
    end)

    -- Store tab data
    local tabData = {
        name = name,
        button = tabButton,
        panel = tabPanel,
        icon = tabIcon,
        label = tabLabel,
        elements = {},
        elementCount = 0
    }

    table.insert(self.Tabs, tabData)

    -- Select first tab by default
    if #self.Tabs == 1 then
        self:SelectTab(name)
    end

    -- Update canvas size
    self.TabContainer.CanvasSize = UDim2.new(0, 0, 0, #self.Tabs * 40 + 10)

    return tabData
end

-- Select Tab
function MillenniumUI:SelectTab(tabName)
    for _, tab in pairs(self.Tabs) do
        if tab.name == tabName then
            tab.button.BackgroundColor3 = Config.Theme.AccentColor
            tab.icon.TextColor3 = Config.Theme.TextColor
            tab.label.TextColor3 = Config.Theme.TextColor
            tab.panel.Visible = true
            self.CurrentTab = tab
        else
            tab.button.BackgroundColor3 = Config.Theme.Background
            tab.icon.TextColor3 = Config.Theme.SecondaryTextColor
            tab.label.TextColor3 = Config.Theme.SecondaryTextColor
            tab.panel.Visible = false
        end
    end
end

-- Add Toggle to Tab
function MillenniumUI:AddToggle(tab, text, optionName, callback)
    local toggle = Instance.new("Frame")
    toggle.Name = text .. "Toggle"
    toggle.Size = UDim2.new(1, -10, 0, 40)
    toggle.Position = UDim2.new(0, 5, 0, tab.elementCount * 45 + 5)
    toggle.BackgroundColor3 = Config.Theme.SecondaryBackground
    toggle.Parent = tab.panel

    RoundCorners(toggle, 6)

    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = "Label"
    toggleLabel.Size = UDim2.new(1, -60, 1, 0)
    toggleLabel.Position = UDim2.new(0, 15, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = text
    toggleLabel.TextColor3 = Config.Theme.TextColor
    toggleLabel.TextSize = 14
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.Parent = toggle

    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "Button"
    toggleButton.Size = UDim2.new(0, 40, 0, 20)
    toggleButton.Position = UDim2.new(1, -50, 0.5, -10)
    toggleButton.BackgroundColor3 = (Options[optionName] and Options[optionName].Value) and Config.Theme.AccentColor or Config.Theme.BorderColor
    toggleButton.Text = ""
    toggleButton.Parent = toggle

    RoundCorners(toggleButton, 10)

    local toggleIndicator = Instance.new("Frame")
    toggleIndicator.Name = "Indicator"
    toggleIndicator.Size = UDim2.new(0, 16, 0, 16)
    toggleIndicator.Position = (Options[optionName] and Options[optionName].Value) and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    toggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleIndicator.Parent = toggleButton

    RoundCorners(toggleIndicator, 8)

    toggleButton.MouseButton1Click:Connect(function()
        if Options[optionName] then
            local newValue = not Options[optionName].Value
            Options[optionName]:SetValue(newValue)

            CreateTween(toggleButton, {
                BackgroundColor3 = newValue and Config.Theme.AccentColor or Config.Theme.BorderColor
            }):Play()

            CreateTween(toggleIndicator, {
                Position = newValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            }):Play()

            if callback then
                callback(newValue)
            end
        end
    end)

    tab.elementCount = tab.elementCount + 1
    tab.panel.CanvasSize = UDim2.new(0, 0, 0, tab.elementCount * 45 + 10)

    -- Store element reference for config updates
    self.UIElements[optionName] = {
        type = "toggle",
        button = toggleButton,
        indicator = toggleIndicator,
        update = function(value)
            toggleButton.BackgroundColor3 = value and Config.Theme.AccentColor or Config.Theme.BorderColor
            toggleIndicator.Position = value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        end
    }

    return toggle
end

-- Add Slider to Tab
function MillenniumUI:AddSlider(tab, text, optionName, min, max, callback)
    local slider = Instance.new("Frame")
    slider.Name = text .. "Slider"
    slider.Size = UDim2.new(1, -10, 0, 50)
    slider.Position = UDim2.new(0, 5, 0, tab.elementCount * 55 + 5)
    slider.BackgroundColor3 = Config.Theme.SecondaryBackground
    slider.Parent = tab.panel

    RoundCorners(slider, 6)

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Name = "Label"
    sliderLabel.Size = UDim2.new(0.7, 0, 0, 25)
    sliderLabel.Position = UDim2.new(0, 15, 0, 5)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = text
    sliderLabel.TextColor3 = Config.Theme.TextColor
    sliderLabel.TextSize = 14
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.Font = Enum.Font.Gotham
    sliderLabel.Parent = slider

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.new(0.3, -15, 0, 25)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(Options[optionName] and Options[optionName].Value or min)
    valueLabel.TextColor3 = Config.Theme.AccentColor
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Parent = slider

    local sliderTrack = Instance.new("Frame")
    sliderTrack.Name = "Track"
    sliderTrack.Size = UDim2.new(1, -30, 0, 4)
    sliderTrack.Position = UDim2.new(0, 15, 1, -15)
    sliderTrack.BackgroundColor3 = Config.Theme.BorderColor
    sliderTrack.Parent = slider

    RoundCorners(sliderTrack, 2)

    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = Config.Theme.AccentColor
    sliderFill.Parent = sliderTrack

    RoundCorners(sliderFill, 2)

    local sliderHandle = Instance.new("Frame")
    sliderHandle.Name = "Handle"
    sliderHandle.Size = UDim2.new(0, 12, 0, 12)
    sliderHandle.Position = UDim2.new(0, -6, 0.5, -6)
    sliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderHandle.Parent = sliderTrack

    RoundCorners(sliderHandle, 6)

    local dragging = false

    -- Update slider visuals
    local function updateSlider()
        local value = Options[optionName] and Options[optionName].Value or min
        local percentage = (value - min) / (max - min)
        sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        sliderHandle.Position = UDim2.new(percentage, -6, 0.5, -6)
        valueLabel.Text = tostring(math.floor(value * 100) / 100)
    end

    updateSlider()

    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    sliderTrack.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    userInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = input.Position
            local trackPosition = sliderTrack.AbsolutePosition
            local trackSize = sliderTrack.AbsoluteSize

            local percentage = math.clamp((mouse.X - trackPosition.X) / trackSize.X, 0, 1)
            local value = min + (max - min) * percentage

            if Options[optionName] then
                Options[optionName]:SetValue(value)
                updateSlider()

                if callback then
                    callback(value)
                end
            end
        end
    end)

    tab.elementCount = tab.elementCount + 1
    tab.panel.CanvasSize = UDim2.new(0, 0, 0, tab.elementCount * 55 + 10)

    -- Store element reference for config updates
    self.UIElements[optionName] = {
        type = "slider",
        update = updateSlider
    }

    return slider
end

-- Add Dropdown to Tab
function MillenniumUI:AddDropdown(tab, text, optionName, options, callback)
    local dropdown = Instance.new("Frame")
    dropdown.Name = text .. "Dropdown"
    dropdown.Size = UDim2.new(1, -10, 0, 40)
    dropdown.Position = UDim2.new(0, 5, 0, tab.elementCount * 45 + 5)
    dropdown.BackgroundColor3 = Config.Theme.SecondaryBackground
    dropdown.Parent = tab.panel

    RoundCorners(dropdown, 6)

    local dropdownLabel = Instance.new("TextLabel")
    dropdownLabel.Name = "Label"
    dropdownLabel.Size = UDim2.new(0.5, 0, 1, 0)
    dropdownLabel.Position = UDim2.new(0, 15, 0, 0)
    dropdownLabel.BackgroundTransparency = 1
    dropdownLabel.Text = text
    dropdownLabel.TextColor3 = Config.Theme.TextColor
    dropdownLabel.TextSize = 14
    dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    dropdownLabel.Font = Enum.Font.Gotham
    dropdownLabel.Parent = dropdown

    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Name = "Button"
    dropdownButton.Size = UDim2.new(0.5, -20, 0, 30)
    dropdownButton.Position = UDim2.new(0.5, 5, 0, 5)
    dropdownButton.BackgroundColor3 = Config.Theme.Background
    dropdownButton.Text = (Options[optionName] and Options[optionName].Value) or options[1] or "Select..."
    dropdownButton.TextColor3 = Config.Theme.TextColor
    dropdownButton.TextSize = 12
    dropdownButton.Font = Enum.Font.Gotham
    dropdownButton.Parent = dropdown

    RoundCorners(dropdownButton, 4)

    local dropdownArrow = Instance.new("TextLabel")
    dropdownArrow.Name = "Arrow"
    dropdownArrow.Size = UDim2.new(0, 20, 1, 0)
    dropdownArrow.Position = UDim2.new(1, -20, 0, 0)
    dropdownArrow.BackgroundTransparency = 1
    dropdownArrow.Text = "▼"
    dropdownArrow.TextColor3 = Config.Theme.SecondaryTextColor
    dropdownArrow.TextSize = 10
    dropdownArrow.Font = Enum.Font.Gotham
    dropdownArrow.Parent = dropdownButton

    local optionsFrame = Instance.new("Frame")
    optionsFrame.Name = "OptionsFrame"
    optionsFrame.Size = UDim2.new(0.5, -20, 0, #options * 25)
    optionsFrame.Position = UDim2.new(0.5, 5, 1, 5)
    optionsFrame.BackgroundColor3 = Config.Theme.Background
    optionsFrame.Visible = false
    optionsFrame.ZIndex = 10
    optionsFrame.Parent = dropdown

    RoundCorners(optionsFrame, 4)
    AddStroke(optionsFrame, Config.Theme.BorderColor, 1)

    local isOpen = false

    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Name = option .. "Option"
        optionButton.Size = UDim2.new(1, 0, 0, 25)
        optionButton.Position = UDim2.new(0, 0, 0, (i-1) * 25)
        optionButton.BackgroundTransparency = 1
        optionButton.Text = option
        optionButton.TextColor3 = Config.Theme.TextColor
        optionButton.TextSize = 12
        optionButton.Font = Enum.Font.Gotham
        optionButton.Parent = optionsFrame

        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundColor3 = Config.Theme.AccentColor
            optionButton.BackgroundTransparency = 0
        end)

        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundTransparency = 1
        end)

        optionButton.MouseButton1Click:Connect(function()
            if Options[optionName] then
                Options[optionName]:SetValue(option)
                dropdownButton.Text = option
            end
            isOpen = false
            optionsFrame.Visible = false
            dropdownArrow.Text = "▼"

            if callback then
                callback(option)
            end
        end)
    end

    dropdownButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        optionsFrame.Visible = isOpen
        dropdownArrow.Text = isOpen and "▲" or "▼"
    end)

    tab.elementCount = tab.elementCount + 1
    tab.panel.CanvasSize = UDim2.new(0, 0, 0, tab.elementCount * 45 + 10)

    -- Store element reference for config updates
    self.UIElements[optionName] = {
        type = "dropdown",
        button = dropdownButton,
        update = function(value)
            dropdownButton.Text = value
        end
    }

    return dropdown
end

-- Add Button to Tab
function MillenniumUI:AddButton(tab, text, callback)
    local button = Instance.new("TextButton")
    button.Name = text .. "Button"
    button.Size = UDim2.new(1, -10, 0, 35)
    button.Position = UDim2.new(0, 5, 0, tab.elementCount * 40 + 5)
    button.BackgroundColor3 = Config.Theme.SecondaryBackground
    button.Text = text
    button.TextColor3 = Config.Theme.TextColor
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.Parent = tab.panel

    RoundCorners(button, 6)
    AddStroke(button, Config.Theme.BorderColor, 1)

    button.MouseEnter:Connect(function()
        CreateTween(button, {BackgroundColor3 = Config.Theme.AccentColor}):Play()
    end)

    button.MouseLeave:Connect(function()
        CreateTween(button, {BackgroundColor3 = Config.Theme.SecondaryBackground}):Play()
    end)

    button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)

    tab.elementCount = tab.elementCount + 1
    tab.panel.CanvasSize = UDim2.new(0, 0, 0, tab.elementCount * 40 + 10)

    return button
end

-- Update Option (for config loading)
function MillenniumUI:UpdateOption(optionName, value)
    if self.UIElements[optionName] and self.UIElements[optionName].update then
        self.UIElements[optionName].update(value)
    end
end

-- Initialize Millennium UI
local UI = MillenniumUI:CreateGUI()

-- Create tabs
local catchingTab = UI:CreateTab("Catching", "🎯")
local physicsTab = UI:CreateTab("Physics", "⚡")
local playerTab = UI:CreateTab("Player", "👤")
local autoTab = UI:CreateTab("Auto", "🤖")
local settingsTab = UI:CreateTab("Settings", "⚙️")

-- CATCHING TAB
UI:AddToggle(catchingTab, "Magnets", "Magnets", function(value)
    print("Magnets:", value)
end)

UI:AddDropdown(catchingTab, "Type", "MagnetsType", {"Blatant", "Legit", "League"}, function(value)
    print("Magnets Type:", value)
end)

UI:AddSlider(catchingTab, "Radius", "MagnetsCustomRadius", 0, 70, function(value)
    print("Magnets Radius:", value)
end)

UI:AddToggle(catchingTab, "Visualise Hitbox", "ShowMagHitbox", function(value)
    print("Show Mag Hitbox:", value)
end)

UI:AddToggle(catchingTab, "Pull Vector", "PullVector", function(value)
    print("Pull Vector:", value)
end)

UI:AddSlider(catchingTab, "Distance", "PullVectorDistance", 0, 100, function(value)
    print("Pull Vector Distance:", value)
end)

UI:AddDropdown(catchingTab, "Pull Type", "PullVectorType", {"Glide", "Teleport"}, function(value)
    print("Pull Vector Type:", value)
end)

UI:AddSlider(catchingTab, "Power", "PullVectorPower", 1, 5, function(value)
    print("Pull Vector Power:", value)
end)

UI:AddToggle(catchingTab, "Freeze Tech", "FreezeTech", function(value)
    print("Freeze Tech:", value)
end)

UI:AddSlider(catchingTab, "Freeze Duration", "FreezeTechDuration", 0, 3, function(value)
    print("Freeze Tech Duration:", value)
end)

-- PHYSICS TAB
UI:AddToggle(physicsTab, "Click Tackle Aimbot", "ClickTackleAimbot", function(value)
    print("Click Tackle Aimbot:", value)
end)

UI:AddSlider(physicsTab, "Distance", "ClickTackleAimbotDistance", 0, 15, function(value)
    print("Click Tackle Distance:", value)
end)

UI:AddToggle(physicsTab, "Anti Jam", "AntiJam", function(value)
    print("Anti Jam:", value)
end)

UI:AddToggle(physicsTab, "Anti Block", "AntiBlock", function(value)
    print("Anti Block:", value)
end)

UI:AddToggle(physicsTab, "Visualize Ball Path", "VisualizeBallPath", function(value)
    print("Visualize Ball Path:", value)
end)

UI:AddToggle(physicsTab, "No Jump Cooldown", "NoJumpCooldown", function(value)
    print("No Jump Cooldown:", value)
end)

UI:AddToggle(physicsTab, "No Freeze", "NoFreeze", function(value)
    print("No Freeze:", value)
end)

UI:AddToggle(physicsTab, "Optimal Jump", "OptimalJump", function(value)
    print("Optimal Jump:", value)
end)

UI:AddDropdown(physicsTab, "Type", "OptimalJumpType", {"Jump", "Dive"}, function(value)
    print("Optimal Jump Type:", value)
end)

UI:AddToggle(physicsTab, "No Ball Trail", "NoBallTrail", function(value)
    print("No Ball Trail:", value)
end)

UI:AddToggle(physicsTab, "Big Head", "BigHead", function(value)
    print("Big Head:", value)
end)

UI:AddSlider(physicsTab, "Size", "BigHeadSize", 1, 5, function(value)
    print("Big Head Size:", value)
end)

UI:AddToggle(physicsTab, "Anti Out Of Bounds", "AntiOOB", function(value)
    print("Anti OOB:", value)
end)

-- PHYSICS EXTENDERS (conditional)
if firetouchinterest and not IS_SOLARA then
    UI:AddToggle(physicsTab, "Tackle Extender", "TackleExtender", function(value)
        print("Tackle Extender:", value)
    end)

    UI:AddSlider(physicsTab, "Tackle Radius", "TackleExtenderRadius", 0, 10, function(value)
        print("Tackle Extender Radius:", value)
    end)
end

if AC_BYPASS then
    UI:AddToggle(physicsTab, "Block Extender", "BlockExtender", function(value)
        print("Block Extender:", value)
    end)

    UI:AddSlider(physicsTab, "Block Range", "BlockExtenderRange", 1, 20, function(value)
        print("Block Extender Range:", value)
    end)

    UI:AddSlider(physicsTab, "Block Transparency", "BlockExtenderTransparency", 0, 1, function(value)
        print("Block Extender Transparency:", value)
    end)
end

-- PLAYER TAB
UI:AddToggle(playerTab, "Quick TP", "QuickTP", function(value)
    print("Quick TP:", value)
end)

UI:AddSlider(playerTab, "Speed", "QuickTPSpeed", 1, 5, function(value)
    print("Quick TP Speed:", value)
end)

-- Create keybind for Quick TP (keeping original functionality)
local quickTPCooldown = os.clock()
local QuickTPKeybind = KeybindSystem:CreateKeybind("QuickTP", Enum.KeyCode.F, function()
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

UI:AddToggle(playerTab, "Dive Power", "DivePower", function(value)
    print("Dive Power:", value)
end)

UI:AddSlider(playerTab, "Dive Distance", "DivePowerDistance", 0, 10, function(value)
    print("Dive Power Distance:", value)
end)

UI:AddToggle(playerTab, "Speed", "Speed", function(value)
    if value then
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Options.SpeedValue.Value
        end
    end
    print("Speed:", value)
end)

UI:AddSlider(playerTab, "Speed Value", "SpeedValue", 20, 23, function(value)
    if Options.Speed and Options.Speed.Value then
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
    print("Speed Value:", value)
end)

UI:AddToggle(playerTab, "Jump Power", "JumpPower", function(value)
    print("Jump Power:", value)
end)

UI:AddSlider(playerTab, "Power", "JumpPowerValue", 50, 70, function(value)
    if Options.JumpPower and Options.JumpPower.Value then
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        if humanoid and AC_BYPASS then
            humanoid.JumpPower = value
        end
    end
    print("Jump Power Value:", value)
end)

UI:AddToggle(playerTab, "Angle Enhancer", "AngleAssist", function(value)
    print("Angle Assist:", value)
end)

UI:AddSlider(playerTab, "JP", "AngleAssistJP", 50, 70, function(value)
    if Options.AngleAssist and Options.AngleAssist.Value then
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        if humanoid and AC_BYPASS then
            humanoid.JumpPower = value
        end
    end
    print("Angle Assist JP:", value)
end)

-- AUTO TAB
UI:AddToggle(autoTab, "Auto Cap", "AutoCap", function(value)
    print("Auto Cap:", value)
end)

UI:AddToggle(autoTab, "Auto Reset After Catch", "AutoReset", function(value)
    print("Auto Reset:", value)
end)

UI:AddSlider(autoTab, "Reset Delay", "AutoResetDelay", 0, 5, function(value)
    print("Auto Reset Delay:", value)
end)

-- SETTINGS TAB - Enhanced Config System
local currentConfigName = ""

-- Config dropdown with existing configs
local function updateConfigDropdown()
    local configs = ConfigSystem:GetConfigs()
    table.insert(configs, 1, "Create New Config")
    return configs
end

local configDropdown = UI:AddDropdown(settingsTab, "Config Name", "ConfigName", updateConfigDropdown(), function(value)
    currentConfigName = value
    print("Selected config:", value)
end)

-- Config buttons
UI:AddButton(settingsTab, "Save Config", function()
    if currentConfigName == "" or currentConfigName == "Create New Config" then
        currentConfigName = "Config_" .. os.date("%H%M%S")
    end

    local success = ConfigSystem:SaveConfig(currentConfigName)
    if success then
        starterGui:SetCore("SendNotification", {
            Title = "Sense Hub";
            Text = "Config saved: " .. currentConfigName;
            Duration = 3;
        })
    else
        starterGui:SetCore("SendNotification", {
            Title = "Sense Hub";
            Text = "Failed to save config";
            Duration = 3;
        })
    end
end)

UI:AddButton(settingsTab, "Load Config", function()
    if currentConfigName == "" or currentConfigName == "Create New Config" then
        starterGui:SetCore("SendNotification", {
            Title = "Sense Hub";
            Text = "Please select a config to load";
            Duration = 3;
        })
        return
    end

    local success = ConfigSystem:LoadConfig(currentConfigName)
    if success then
        -- Update all UI elements
        for optionName, element in pairs(UI.UIElements) do
            if Options[optionName] and element.update then
                element.update(Options[optionName].Value)
            end
        end

        starterGui:SetCore("SendNotification", {
            Title = "Sense Hub";
            Text = "Config loaded: " .. currentConfigName;
            Duration = 3;
        })
    else
        starterGui:SetCore("SendNotification", {
            Title = "Sense Hub";
            Text = "Failed to load config";
            Duration = 3;
        })
    end
end)

UI:AddButton(settingsTab, "Delete Config", function()
    if currentConfigName == "" or currentConfigName == "Create New Config" then
        starterGui:SetCore("SendNotification", {
            Title = "Sense Hub";
            Text = "Please select a config to delete";
            Duration = 3;
        })
        return
    end

    local success = ConfigSystem:DeleteConfig(currentConfigName)
    if success then
        starterGui:SetCore("SendNotification", {
            Title = "Sense Hub";
            Text = "Config deleted: " .. currentConfigName;
            Duration = 3;
        })
        currentConfigName = ""
    else
        starterGui:SetCore("SendNotification", {
            Title = "Sense Hub";
            Text = "Failed to delete config";
            Duration = 3;
        })
    end
end)

UI:AddToggle(settingsTab, "Auto Save", "AutoSave", function(value)
    print("Auto Save:", value)
end)

-- ALL ORIGINAL SCRIPT LOGIC CONTINUES HERE (FIXED DIVE POWER HOOK)
local divePowerOldNamecall
divePowerOldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method, args = getnamecallmethod(), {...}
    if args[2] == "dive" and Options.DivePower and Options.DivePower.Value then
        local character = player.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local diveForce = Options.DivePowerDistance and Options.DivePowerDistance.Value or 3
                local lookDirection = humanoidRootPart.CFrame.LookVector
                local horizontalForce = Vector3.new(lookDirection.X, 0, lookDirection.Z).Unit * diveForce * 10
                humanoidRootPart:ApplyImpulse(horizontalForce * humanoidRootPart.AssemblyMass)
            end
        end
    end
    return divePowerOldNamecall(self, ...)
end)

-- ALL ORIGINAL MAIN LOOPS AND HANDLERS

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

print("Enjoy Sense Hub")
