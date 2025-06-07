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
local debris = game:GetService("Debris")

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

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

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

local Window = Fluent:CreateWindow({
    Title = "Sense Hub",
    SubTitle = "by Veylo",
    TabWidth = 160,
    Size = UDim2.fromOffset(595, 355),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl,
    CanResize = true,
    ScrollSpeed = 30,
    ScrollingEnabled = true
})

local Tabs = {
    Catching = Window:AddTab({ Title = "Catching", Icon = "radio", ScrollingEnabled = true }),
    Physics = Window:AddTab({ Title = "Physics", Icon = "rocket", ScrollingEnabled = true }),
    Auto = Window:AddTab({ Title = "Auto", Icon = "bot", ScrollingEnabled = true }),
    Throwing = Window:AddTab({ Title = "Throwing", Icon = "send", ScrollingEnabled = true }),
    Player = Window:AddTab({ Title = "Player", Icon = "user", ScrollingEnabled = true }),
    Trolling = Window:AddTab({ Title = "Trolling", Icon = "zap", ScrollingEnabled = true }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings", ScrollingEnabled = true })
}

local Options = Fluent.Options

-- QBAimbot Feature 
-- Main Toggle
local QBAimbotToggle = Tabs.Throwing:AddToggle("QBAimbot", {
    Title = "QB Aimbot",
    Default = false,
    Description = "Advanced quarterback aimbot with prediction"
})

-- UI Controls
local QBAimbotUIToggle = Tabs.Throwing:AddToggle("QBAimbotUI", {
    Title = "Show Info UI",
    Default = true,
    Description = "Shows real-time throwing information"
})

local QBAimbotVisualiseToggle = Tabs.Throwing:AddToggle("QBAimbotVisualise", {
    Title = "Visualise",
    Default = true,
    Description = "Shows throw trajectory and target highlight"
})

local QBAimbotAutoAngleToggle = Tabs.Throwing:AddToggle("QBAimbotAutoAngle", {
    Title = "Auto Angle",
    Default = false,
    Description = "Automatically calculates optimal throw angle"
})

local QBAimbotAutoThrowTypeToggle = Tabs.Throwing:AddToggle("QBAimbotAutoThrowType", {
    Title = "Auto Throw Type",
    Default = false,
    Description = "Automatically selects throw type based on situation"
})

local QBAimbot95PowerOnlyToggle = Tabs.Throwing:AddToggle("QBAimbot95PowerOnly", {
    Title = "95 Power Only",
    Default = false,
    Description = "Forces 95 power throws"
})

local QBAimbotAntiOOBToggle = Tabs.Throwing:AddToggle("QBAimbotAntiOOB", {
    Title = "Anti Out of Bounds",
    Default = false,
    Description = "Prevents throwing out of bounds"
})

local QBAimbotExperimentalToggle = Tabs.Throwing:AddToggle("QBAimbotExperimental", {
    Title = "Experimental",
    Default = true,
    Description = "Uses experimental prediction algorithms"
})

local QBAimbotAdjustPowerGUIToggle = Tabs.Throwing:AddToggle("QBAimbotAdjustPowerGUI", {
    Title = "Adjust Power GUI",
    Default = false,
    Description = "Automatically adjusts in-game power GUI"
})

-- Sliders
local QBAimbotAntiOOBThreshold = Tabs.Throwing:AddSlider("QBAimbotAntiOOBThreshold", {
    Title = "Anti OOB Threshold",
    Description = "Threshold for out of bounds prevention",
    Default = 0,
    Min = -10,
    Max = 10,
    Rounding = 1
})

local QBAimbotXOffset = Tabs.Throwing:AddSlider("QBAimbotXOffset", {
    Title = "X Offset",
    Description = "Horizontal aim offset",
    Default = 0,
    Min = -5,
    Max = 5,
    Rounding = 1
})

local QBAimbotYOffset = Tabs.Throwing:AddSlider("QBAimbotYOffset", {
    Title = "Y Offset",
    Description = "Vertical aim offset",
    Default = 0,
    Min = -5,
    Max = 5,
    Rounding = 1
})

-- Keybinds for throw types
local QBAimbotDimeKeybind = Tabs.Throwing:AddKeybind("QBAimbotDimeKeybind", {
    Title = "Dime Bind",
    Default = "One",
    Mode = "Toggle",
    Description = "Key for Dime throw"
})

local QBAimbotJumpKeybind = Tabs.Throwing:AddKeybind("QBAimbotJumpKeybind", {
    Title = "Jump Bind",
    Default = "Two",
    Mode = "Toggle",
    Description = "Key for Jump throw"
})

local QBAimbotBulletKeybind = Tabs.Throwing:AddKeybind("QBAimbotBulletKeybind", {
    Title = "Bullet Bind",
    Default = "Three",
    Mode = "Toggle",
    Description = "Key for Bullet throw"
})

local QBAimbotDiveKeybind = Tabs.Throwing:AddKeybind("QBAimbotDiveKeybind", {
    Title = "Dive Bind",
    Default = "Four",
    Mode = "Toggle",
    Description = "Key for Dive throw"
})

local QBAimbotMagKeybind = Tabs.Throwing:AddKeybind("QBAimbotMagKeybind", {
    Title = "Mag Bind",
    Default = "Five",
    Mode = "Toggle",
    Description = "Key for Mag throw"
})

-- QBAimbot Core Variables and Functions 
local target = nil
local power = 65
local direction = Vector3.new(0, 1, 0)
local angle = 45
local locked = false
local firedRemoteEvent = false
local within = table.find
local throwType = "Dive"
local nonVisualThrowType = nil

-- Custom QBAimbot Cards UI with Light Blue Theme
local qbCards = nil
pcall(function()
    -- Create custom cards UI instead of using asset
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "QBAimbotCards"
    screenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
    screenGui.Enabled = false

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 250, 0, 200)
    container.Position = UDim2.new(0, 10, 0, 10)
    container.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    container.BackgroundTransparency = 0.8
    container.BorderSizePixel = 2
    container.BorderColor3 = Color3.fromRGB(0, 255, 255)
    container.Parent = screenGui

    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container

    -- Create info labels
    local infoData = {
        {name = "Player", text = "Player: None"},
        {name = "Angle", text = "Angle: 45"},
        {name = "Power", text = "Power: 65"},
        {name = "Mode", text = "Mode: Dive"},
        {name = "Route", text = "Route: None"},
        {name = "Distance", text = "Distance: 0"},
        {name = "Interceptable", text = "Interceptable: false"}
    }

    for i, info in ipairs(infoData) do
        local frame = Instance.new("Frame")
        frame.Name = info.name
        frame.Size = UDim2.new(1, -10, 0, 25)
        frame.Position = UDim2.new(0, 5, 0, 5 + (i-1) * 27)
        frame.BackgroundTransparency = 1
        frame.Parent = container

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Name = "Value"
        valueLabel.Size = UDim2.new(1, 0, 1, 0)
        valueLabel.Position = UDim2.new(0, 0, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = info.text
        valueLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
        valueLabel.TextScaled = true
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextXAlignment = Enum.TextXAlignment.Left
        valueLabel.Parent = frame
    end

    qbCards = screenGui
end)

local qbHighlight = Instance.new("Highlight")
qbHighlight.FillColor = Color3.fromRGB(0, 255, 255)
qbHighlight.OutlineColor = Color3.fromRGB(0, 255, 255)
qbHighlight.FillTransparency = 0.5
qbHighlight.OutlineTransparency = 0
qbHighlight.Parent = replicatedStorage

local qbPart = Instance.new("Part")
qbPart.Parent = workspace
qbPart.Anchored = true
qbPart.CanCollide = false

local qbInbPart = Instance.new("Part")
qbInbPart.CanCollide = false
qbInbPart.Anchored = true
qbInbPart.Transparency = 1
qbInbPart.Position = IS_PRACTICE and Vector3.new(245, 40.55, 0) or Vector3.new(0, 40.55, 0)
qbInbPart.Size = Vector3.new(161, 75, 360)
qbInbPart.Parent = workspace

-- QBAimbot trajectory beam with light blue color
local qbA0, qbA1 = Instance.new("Attachment"), Instance.new("Attachment")
qbA0.Parent = workspace.Terrain; qbA1.Parent = workspace.Terrain

local qbBeam = Instance.new("Beam", workspace.Terrain)
qbBeam.Attachment0 = qbA0
qbBeam.Attachment1 = qbA1
qbBeam.Segments = 500
qbBeam.Width0 = 0.5
qbBeam.Width1 = 0.5
qbBeam.Transparency = NumberSequence.new(0)
qbBeam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255))

-- QBAimbot throw type switching
local throwTypesSwitch = {
    ["Dive"] = "Mag",
    ["Mag"] = "Bullet",
    ["Bullet"] = "Jump",
    ["Jump"] = "Dime",
    ["Dime"] = "Dive"
}

-- QBAimbot keybind handlers
local qbKeys = {
    R = function()
        angle = math.clamp(angle + 5, 5, 85)
    end,
    F = function()
        angle = math.clamp(angle - 5, 5, 85)
    end,
    Q = function()
        locked = not locked
    end,
    Z = function()
        throwType = throwTypesSwitch[throwType]
    end,
}

-- Route and offset data 
local sidewayRoutes = {"in/out", "flat"}
local inAirAdditiveRoutes = {"stationary", "curl/comeback"}

local qbOffsets = {
    Dive = {
        xLead = 3,
        yLead = 4.5,
        routes = {
            ["go"] = {xzOffset = 0, yOffset = 0},
            ["post/corner"] = {xzOffset = 0, yOffset = 0},
            ["slant"] = {xzOffset = 0, yOffset = 0},
            ["in/out"] = {xzOffset = -1, yOffset = -2},
            ["flat"] = {xzOffset = 0, yOffset = -2},
            ["curl/comeback"] = {xzOffset = 4, yOffset = 0},
            ["stationary"] = {xzOffset = 0, yOffset = 0}
        }
    },
    Mag = {
        xLead = 3,
        yLead = 6,
        routes = {
            ["go"] = {xzOffset = 0, yOffset = 0},
            ["post/corner"] = {xzOffset = 0, yOffset = 0},
            ["slant"] = {xzOffset = 0, yOffset = 0},
            ["in/out"] = {xzOffset = -1, yOffset = -2},
            ["flat"] = {xzOffset = 0, yOffset = -2},
            ["curl/comeback"] = {xzOffset = 6, yOffset = 0},
            ["stationary"] = {xzOffset = 0, yOffset = 0}
        }
    },
    Jump = {
        xLead = 2,
        yLead = 3,
        routes = {
            ["go"] = {xzOffset = 0, yOffset = -1.5},
            ["post/corner"] = {xzOffset = 0, yOffset = 0},
            ["slant"] = {xzOffset = 0, yOffset = 0},
            ["in/out"] = {xzOffset = -1, yOffset = 3},
            ["flat"] = {xzOffset = 0, yOffset = 3},
            ["curl/comeback"] = {xzOffset = 2, yOffset = 4},
            ["stationary"] = {xzOffset = 0, yOffset = 7.5}
        }
    },
    Dime = {
        xLead = 2,
        routes = {
            ["go"] = {xzOffset = 0, yOffset = 0},
            ["post/corner"] = {xzOffset = 0, yOffset = 0},
            ["slant"] = {xzOffset = 0, yOffset = 0},
            ["in/out"] = {xzOffset = -1, yOffset = -1},
            ["flat"] = {xzOffset = 0, yOffset = -1},
            ["curl/comeback"] = {xzOffset = 2, yOffset = 0},
            ["stationary"] = {xzOffset = 0, yOffset = 0}
        }
    },
}

-- Movement direction tracking for experimental mode
local qbMoveDirection = {}

-- Other UI elements
local QuickTPToggle = Tabs.Player:AddToggle("QuickTP", {
    Title = "Quick TP",
    Default = false,
    Description = "Teleport quickly in the direction you're moving"
})

local QuickTPSpeed = Tabs.Player:AddSlider("QuickTPSpeed", {
    Title = "Speed",
    Description = "QuickTP speed multiplier",
    Default = 3,
    Min = 1,
    Max = 5,
    Rounding = 1
})

local QuickTPBind = Tabs.Physics:AddKeybind("QuickTPBind", {
    Title = "Keybind",
    Default = "F",
    Mode = "Toggle",
    Description = "Key to activate Quick TP"
})

local ClickTackleAimbotToggle = Tabs.Physics:AddToggle("ClickTackleAimbot", {
    Title = "Click Tackle Aimbot",
    Default = false,
    Description = "Teleport to the ball carrier when clicking"
})

local ClickTackleAimbotDistance = Tabs.Physics:AddSlider("ClickTackleAimbotDistance", {
    Title = "Distance",
    Description = "Maximum teleport distance",
    Default = 7,
    Min = 0,
    Max = 15,
    Rounding = 1
})

local AntiJamToggle = Tabs.Physics:AddToggle("AntiJam", {
    Title = "Anti Jam",
    Default = false,
    Description = "Prevents you from getting jammed"
})

local AntiBlockToggle = Tabs.Physics:AddToggle("AntiBlock", {
    Title = "Anti Block",
    Default = false,
    Description = "Prevents players from blocking you"
})

local VisualizeBallPathToggle = Tabs.Physics:AddToggle("VisualizeBallPath", {
    Title = "Visualize Ball Path",
    Default = false,
    Description = "Shows the path of the ball"
})

local NoJumpCooldownToggle = Tabs.Physics:AddToggle("NoJumpCooldown", {
    Title = "No Jump Cooldown",
    Default = false,
    Description = "Removes the cooldown between jumps"
})

local NoFreezeToggle = Tabs.Physics:AddToggle("NoFreeze", {
    Title = "No Freeze",
    Default = false,
    Description = "Prevents movement freezing"
})

local OptimalJumpToggle = Tabs.Physics:AddToggle("OptimalJump", {
    Title = "Optimal Jump",
    Default = false,
    Description = "Shows the best position to jump for catches"
})

local OptimalJumpType = Tabs.Physics:AddDropdown("OptimalJumpType", {
    Title = "Type",
    Values = {"Jump", "Dive"},
    Default = "Jump",
    Description = "Jump or dive indicator"
})

local NoBallTrailToggle = Tabs.Physics:AddToggle("NoBallTrail", {
    Title = "No Ball Trail",
    Default = false,
    Description = "Removes the trail behind the ball"
})

local BigHeadToggle = Tabs.Physics:AddToggle("BigHead", {
    Title = "Big Head",
    Default = false,
    Description = "Increases the size of player heads"
})

local BigHeadSize = Tabs.Physics:AddSlider("BigHeadSize", {
    Title = "Size",
    Description = "Head size multiplier",
    Default = 3,
    Min = 1,
    Max = 5,
    Rounding = 1
})

local AntiOOBToggle = Tabs.Physics:AddToggle("AntiOOB", {
    Title = "Anti Out Of Bounds",
    Default = false,
    Description = "Prevents going out of bounds by toggling boundaries"
})

local SpeedToggle = Tabs.Player:AddToggle("Speed", {
    Title = "Speed",
    Default = false,
    Description = "Increases your movement speed"
})

local SpeedValue = Tabs.Player:AddSlider("SpeedValue", {
    Title = "Speed",
    Description = "Speed multiplier",
    Default = 22,
    Min = 20,
    Max = 23,
    Rounding = 1
})

local JumpPowerToggle = Tabs.Player:AddToggle("JumpPower", {
    Title = "Jump Power",
    Default = false,
    Description = "Increases your jump height"
})

local JumpPowerValue = Tabs.Player:AddSlider("JumpPowerValue", {
    Title = "Power",
    Description = "Jump power multiplier",
    Default = 60,
    Min = 50,
    Max = 70,
    Rounding = 1
})

local AngleAssistToggle = Tabs.Player:AddToggle("AngleAssist", {
    Title = "Angle Enhancer",
    Default = false,
    Description = "Enhances your angles"
})

local AngleAssistJP = Tabs.Player:AddSlider("AngleAssistJP", {
    Title = "JP",
    Description = "Jump power for angle assist",
    Default = 60,
    Min = 50,
    Max = 70,
    Rounding = 1
})

-- CATCHING TAB
local MagnetsToggle = Tabs.Catching:AddToggle("Magnets", {
    Title = "Magnets",
    Default = false,
    Description = "Helps you catch the ball"
})

local MagnetsType = Tabs.Catching:AddDropdown("MagnetsType", {
    Title = "Type",
    Values = {"Blatant", "Legit", "League"},
    Default = "League",
    Description = "How obvious the magnets behavior is"
})

local MagnetsCustomRadius = Tabs.Catching:AddSlider("MagnetsCustomRadius", {
    Title = "Radius",
    Description = "Radius for the Magnets",
    Default = 35,
    Min = 0,
    Max = 70,
    Rounding = 1
})

local ShowMagHitbox = Tabs.Catching:AddToggle("ShowMagHitbox", {
    Title = "Visualise Hitbox",
    Default = false,
    Description = "Displays the mag hitbox"
})

local PullVectorToggle = Tabs.Catching:AddToggle("PullVector", {
    Title = "Pull Vector",
    Default = false,
    Description = "Pulls you towards the ball"
})

local PullVectorDistance = Tabs.Catching:AddSlider("PullVectorDistance", {
    Title = "Distance",
    Description = "Maximum distance to activate pull",
    Default = 50,
    Min = 0,
    Max = 100,
    Rounding = 1
})

local PullVectorType = Tabs.Catching:AddDropdown("PullVectorType", {
    Title = "Type",
    Values = {"Glide", "Teleport"},
    Default = "Glide"
})

local PullVectorPower = Tabs.Catching:AddSlider("PullVectorPower", {
    Title = "Power",
    Description = "Strength of the pull effect",
    Default = 3,
    Min = 1,
    Max = 5,
    Rounding = 1
})

-- AUTO TAB
local AutoCapToggle = Tabs.Auto:AddToggle("AutoCap", {
    Title = "Auto Cap",
    Default = false,
    Description = "Makes you auto win the race for captain"
})

local AutoResetToggle = Tabs.Auto:AddToggle("AutoReset", {
    Title = "Auto Reset After Catch",
    Default = false,
    Description = "Automatically reset after catching"
})

local AutoResetDelay = Tabs.Auto:AddSlider("AutoResetDelay", {
    Title = "Reset Delay",
    Description = "Delay before resetting (seconds)",
    Default = 1,
    Min = 0,
    Max = 5,
    Rounding = 1
})

-- TROLLING TAB
local EditJerseyNameToggle = Tabs.Trolling:AddToggle("EditJerseyName", {
    Title = "Edit Jersey Name",
    Default = false,
    Description = "Change the name on your jersey"
})

local JerseyNameInput = Tabs.Trolling:AddInput("JerseyNameInput", {
    Title = "Jersey Name",
    Default = "",
    Placeholder = "Enter jersey name...",
    Numeric = false,
    Finished = false
})

local ShinyHelmetToggle = Tabs.Trolling:AddToggle("ShinyHelmet", {
    Title = "Shiny Helmet",
    Default = false,
    Description = "Makes your helmet shiny and reflective"
})

-- Functions needed for QBAimbot and other features
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

task.spawn(function()
    while true do
        task.wait(0.1)
        ping = ( getPing() + getServerPing() ) / 1000
    end
end)

task.spawn(function()
    runService.RenderStepped:Connect(function()
        fps += 1
        task.delay(1, function()
            fps -= 1
        end)
    end)
end)

-- QB Aimbot Helper Functions (From Bleachhack.lua)
local function findTarget(opp)
    local cc = workspace.CurrentCamera
    local target = nil
    local dist = math.huge
    local targets = {}

    for index, plr in pairs(players:GetPlayers()) do
        if not opp then
            if players.LocalPlayer.Team and (players.LocalPlayer.Team ~= plr.Team) then continue end
        else
            if players.LocalPlayer.Team and (players.LocalPlayer.Team == plr.Team) then continue end
        end
        targets[#targets + 1] = plr.Character
    end

    if IS_PRACTICE then
        targets[#targets + 1] = workspace.npcwr.a['bot 1']
        targets[#targets + 1] = workspace.npcwr.a['bot 2']
        targets[#targets + 1] = workspace.npcwr.b['bot 3']
        targets[#targets + 1] = workspace.npcwr.b['bot 4']
    end

    for i,v in pairs(targets) do
        if not v or not v:FindFirstChild("HumanoidRootPart") then continue end
        local screenpoint,onscreen = cc:WorldToViewportPoint(v.HumanoidRootPart.Position)
        local check = (Vector2.new(userInputService:GetMouseLocation().X,userInputService:GetMouseLocation().Y)-Vector2.new(screenpoint.X,screenpoint.Y)).magnitude
        if check < dist then
            target = v
            dist = check
        end
    end

    return target
end

local function getTimeForHeight(from, to, height)
    local g = Vector3.new(0, -28, 0)
    local conversionFactor = 4
    local xMeters = height * conversionFactor

    local a = 0.5 * g.Y
    local b = to.Y - from.Y
    local c = xMeters - from.Y

    local discriminant = b * b - 4 * a * c
    if discriminant < 0 then
        return nil
    end

    local t1 = (-b + math.sqrt(discriminant)) / (2 * a)
    local t2 = (-b - math.sqrt(discriminant)) / (2 * a)

    local t = math.max(t1, t2)
    return t
end

local function clamp_oobPosition(position)
    qbInbPart.Size = Vector3.new(161 + (Options.QBAimbotAntiOOBThreshold.Value * 2), 75, 360 + (Options.QBAimbotAntiOOBThreshold.Value * 2))
    return Vector3.new(
        math.clamp(position.X, -qbInbPart.Size.X / 2 + qbInbPart.Position.X, qbInbPart.Size.X / 2 + qbInbPart.Position.X),
        math.clamp(position.Y, -qbInbPart.Size.Y / 2, qbInbPart.Size.Y / 2),
        math.clamp(position.Z, -qbInbPart.Size.Z / 2 + qbInbPart.Position.Z, qbInbPart.Size.Z / 2 + qbInbPart.Position.Z)
    )
end

local function getVelocityForXYinTime(from, to, time)
    local g = Vector3.new(0, -28, 0)
    local v0 = (to - from - 0.5*g*time*time)/time;
    local dir = ((from + v0) - from).Unit
    local power = v0.Y / dir.Y
    return v0, dir, math.clamp(math.round(power), 0, 95)
end

local function getVelocityForAngle(from, to, angle, standingStill)
    local yMult = standingStill and
        angle / 90 / ((angle > 65 and 1 - (angle - 70) / 25) or (angle > 50 and 1.6 - (angle - 55) / 50) or (angle > 40 and 1.9) or (angle > 30 and 2.25) or (angle > 15 and 2.5) or 3)
        or angle / 90 / ((angle > 70 and 0.55 - ( (angle - 60) / 30 ) * 0.45) or (angle > 60 and 0.8 - ( (angle - 60) / 30 ) * 0.45) or (angle > 53 and 1) or (angle > 43 and 1.2) or (angle > 30 and 1.5) or 1.9)

    local distance = (from - to).Magnitude
    local height = yMult * distance

    local t = getTimeForHeight(from, to, height)
    local velocity = getVelocityForXYinTime(from, to, t)

    return velocity, t
end

local function qbFinalCalc(char, angle, xLead, yLead, sideways)
    xLead = xLead or 0

    local IS_PLAYER = players:GetPlayerFromCharacter(char)
    local moveDirection = IS_PLAYER and ((not sideways and Options.QBAimbotExperimental.Value and qbMoveDirection[char]) or char.Humanoid.MoveDirection) or (char.Humanoid.WalkToPoint - char.HumanoidRootPart.Position).Unit
    local _, t = getVelocityForAngle(player.Character.Head.Position, char.HumanoidRootPart.Position, angle, moveDirection.Magnitude <= 0)

    local pos = char.Head.Position + (moveDirection * 20 * t) + (moveDirection * xLead) + (moveDirection * 20 * ping) + Vector3.new(0, yLead, 0)

    pos = Options.QBAimbotAntiOOB.Value and clamp_oobPosition(pos) or pos

    return getVelocityForXYinTime(player.Character.Head.Position, pos, t), pos, t
end

local function checkIfInterceptable(position, time)
    local blacklist = {}
    local interceptable = false

    blacklist[target.Name] = true

    if player.Team then
        for index, plr in pairs(player.Team:GetPlayers()) do
            blacklist[plr.Name] = true
        end
    end

    local targets = {}

    for index, plr in pairs(players:GetPlayers()) do
        targets[#targets + 1] = plr.Character
    end

    if IS_PRACTICE then
        targets[#targets + 1] = workspace.npcwr.a['bot 1']
        targets[#targets + 1] = workspace.npcwr.a['bot 2']
        targets[#targets + 1] = workspace.npcwr.b['bot 3']
        targets[#targets + 1] = workspace.npcwr.b['bot 4']
    end

    for index, character in pairs(targets) do
        if blacklist[character.Name] then continue end
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

        if not humanoidRootPart then continue end

        local distance = (humanoidRootPart.Position - position).Magnitude
        local radius = (20 * time) + 7.5

        interceptable = distance < radius
        if interceptable then break end
    end

    return interceptable
end

local function getPosInXTimeFromVel(initialPos, initialVelocity, gravity, time)
    local position = initialPos + initialVelocity * time + 0.5 * gravity * time * time
    return position
end

local function findRoute(character)
    local isPlayer = players:GetPlayerFromCharacter(character)

    local moveDirection = isPlayer and character.Humanoid.MoveDirection or (character.Humanoid.WalkToPoint - character.HumanoidRootPart.Position).Unit
    local distance = (character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude

    local function isDiagonal()
        local absMD = Vector3.new(math.abs(moveDirection.X), 0, math.abs(moveDirection.Z))
        local diff = (absMD - Vector3.new(0.7, 0, 0.7)).Magnitude
        return diff < 0.5
    end

    local function isSideways()
        local direction = (character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Unit
        local highest = math.abs(direction.X) > math.abs(direction.Z) and "Z" or "X"
        return math.abs(moveDirection[highest]) > 0.8
    end

    local function towardsQB()
        local newDistance = ((character.HumanoidRootPart.Position + (moveDirection * 16)) - player.Character.HumanoidRootPart.Position).Magnitude
        return (distance - newDistance) > 12
    end

    local requirements = {
        ["go"] = function()
            return not isDiagonal() and not towardsQB()
        end,
        ["post/corner"] = function()
            return isDiagonal() and not towardsQB() and distance > 125
        end,
        ["slant"] = function()
            return isDiagonal() and not towardsQB() and distance <= 125
        end,
        ["in/out"] = function()
            return isSideways() and distance > 125
        end,
        ["flat"] = function()
            return isSideways() and distance <= 125
        end,
        ["curl/comeback"] = function()
            return towardsQB()
        end,
        ["stationary"] = function()
            return moveDirection.Magnitude <= 0
        end,
    }

    local route = nil

    for routeName, func in pairs(requirements) do
        route = func() and routeName or route
        if route then break end
    end

    return route, moveDirection
end

local function determineAutoAngle(distance, route)
    local autoAngleFunc = {
        ["go"] = function()
            return math.min(25 + (distance / 10), 40)
        end,
        ["in/out"] = function()
            return 10 + math.max((distance - 100), 0) / 10
        end,
        ["flat"] = function()
            return 10 + math.max((distance - 100), 0) / 10
        end,
        ["curl/comeback"] = function()
            return 7.5 + math.max((distance - 100), 0) / 20
        end,
        ["stationary"] = function()
            return 17 + math.max((distance - 100), 0) / 20
        end,
    }

    return (autoAngleFunc[route] or autoAngleFunc.go)()
end

local function determine95PowerOnlyAngle(distance, route)
    local IN_AIR = player.Character.Humanoid.FloorMaterial == Enum.Material.Air

    local autoAngleFunc = {
        ["go"] = function()
            return distance > 150 and math.max(IN_AIR and (16 + math.max(distance - 100, 0) / 5) or (14 + math.max(distance - 100, 0) / 5), 25)
                or (IN_AIR and 16.5 + math.max(distance, 0) * (12.5 / 150) or 14 + math.max(distance, 0) * (12.5 / 150))
        end,
        ["in/out"] = function()
            return 10 + math.max((distance - 100), 0) / 10
        end,
        ["flat"] = function()
            return 10 + math.max((distance - 100), 0) / 10
        end,
        ["curl/comeback"] = function()
            return 7.5 + math.max((distance - 100), 0) / 20
        end,
        ["stationary"] = function()
            return 13.5 + math.max((distance - 100), 0) / 20
        end,
    }

    return (autoAngleFunc[route] or autoAngleFunc.go)()
end

local function determineAutoThrowType(route)
    if not target then return end

    local IS_PLAYER = players:GetPlayerFromCharacter(target)
    local dbDistance = math.huge

    for index, plr in pairs(players:GetPlayers()) do
        if IS_PLAYER and IS_PLAYER.Team and IS_PLAYER.Team == plr.Team then continue end
        if IS_PLAYER and plr == IS_PLAYER then continue end

        local character = plr.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

        if not humanoidRootPart then continue end

        local distance = (humanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude

        if distance < dbDistance then
            dbDistance = distance
        end
    end

    local forwardRoutes = {"go", "post/corner", "slant", "curl/comeback", "stationary"}
    local sidewayRoutes = {"in/out", "flat"}

    if within(forwardRoutes, route) then
        if dbDistance > 5 then
            return (Options.QBAimbot95PowerOnly.Value or angle < 40) and "Jump" or "Dime"
        elseif dbDistance > 2 then
            return "Dive"
        end

        return "Mag"
    elseif within(sidewayRoutes, route) then
        if dbDistance > 4 then
            return "Dime"
        end

        return "Jump"
    end

    return "Dime"
end

local function findClosestMultiple(x, y)
    local m = math.round(y / x)
    return m * x
end

local function changePowerGui(power)
    local ballGui = player.PlayerGui:FindFirstChild("BallGui")
    if ballGui then
        for index, frame in pairs(ballGui['Frame0']:GetChildren()) do
            if frame.Name == "Disp" then continue end
            frame.BackgroundTransparency = tonumber(frame.Name) <= power and 0 or 0.9
        end
    end

    ballGui['Frame0'].Disp.Text = power
end

-- QBAimbot Movement Direction Tracking
task.spawn(function()
    local moveDirectionData = {}

    while true do task.wait(1/30);
        for index, plr in pairs(players:GetPlayers()) do
            local character = plr.Character
            local humanoid = character and character:FindFirstChild("Humanoid")

            if not humanoid then continue end

            if not moveDirectionData[character] then
                moveDirectionData[character] = {
                    Direction = humanoid.MoveDirection,
                    Started = os.clock()
                }
                qbMoveDirection[character] = humanoid.MoveDirection
            end

            local newMoveDirection = humanoid.MoveDirection

            if (newMoveDirection - moveDirectionData[character].Direction).Magnitude > 0.2 then
                moveDirectionData[character] = {
                    Direction = humanoid.MoveDirection,
                    Started = os.clock()
                }
            else
                if (os.clock() - moveDirectionData[character].Started) > 0.5 then
                    qbMoveDirection[character] = humanoid.MoveDirection
                    moveDirectionData[character] = {
                        Direction = humanoid.MoveDirection,
                        Started = os.clock()
                    }
                end
            end
        end
    end
end)

-- QBAimbot Input Handling
userInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not qbKeys[input.KeyCode.Name] then return end

    qbKeys[input.KeyCode.Name]()
end)

userInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    if Options.QBAimbotDimeKeybind.Value == input.KeyCode then
        throwType = "Dime"
    end

    if Options.QBAimbotJumpKeybind.Value == input.KeyCode then
        throwType = "Jump"
    end

    if Options.QBAimbotDiveKeybind.Value == input.KeyCode then
        throwType = "Dive"
    end

    if Options.QBAimbotMagKeybind.Value == input.KeyCode then
        throwType = "Mag"
    end

    if Options.QBAimbotBulletKeybind.Value == input.KeyCode then
        throwType = "Bullet"
    end
end)

-- QBAimbot Remote Event Hooking (From Bleachhack.lua)
if not (AC_BYPASS and not IS_PRACTICE) then
    local lastQBAimbotValue = false
    local remoteEvents = {}

    local handoffToggle = false

    local function onToggle()
        local character = player.Character
        local football = character:FindFirstChildWhichIsA("Tool")

        if football then
            if not remoteEvents[football] then
                remoteEvents[football] = football.Handle:FindFirstChildWhichIsA("RemoteEvent")
            end

            local coreScript = football.Handle:FindFirstChildWhichIsA("LocalScript")

            if not coreScript then return end

            coreScript.Enabled = false

            if Options.QBAimbot.Value then
                local fakeRemoteEvent = Instance.new("BoolValue")
                fakeRemoteEvent.Name = "RemoteEvent"
                fakeRemoteEvent.Parent = football.Handle

                remoteEvents[football].Parent = replicatedStorage
            else
                if football.Handle:FindFirstChildWhichIsA("BoolValue") then
                    football.Handle:FindFirstChildWhichIsA("BoolValue"):Destroy()
                end

                remoteEvents[football].Parent = football.Handle
            end

            coreScript.Enabled = true
        end
    end

    local function onCharacter(char)
        char.ChildAdded:Connect(function(tool)
            task.wait(); if not tool:IsA("Tool") then return end
            onToggle()
        end)
    end

    onCharacter(player.Character)
    player.CharacterAdded:Connect(onCharacter)

    game:GetService("ScriptContext").Error:Connect(function(message, stackTrace)
        if not string.match(message, "Football") then return end

        local nwArgs = {"Clicked", player.Character.Head.Position, player.Character.Head.Position + direction * 10000, (IS_PRACTICE and power) or 95, power}

        if string.match(message, "ContextActionService") or string.match(stackTrace, "function ho") then
            handoffToggle = not handoffToggle
            nwArgs = {"x "..(handoffToggle and "down" or "up")}
        end

        local football = player.Character:FindFirstChildWhichIsA("Tool")
        local remoteEvent = remoteEvents[football]

        firedRemoteEvent = true
        remoteEvent:FireServer(unpack(nwArgs))
    end)

    task.spawn(function()
        while true do
            task.wait()
            if lastQBAimbotValue ~= Options.QBAimbot.Value then
                onToggle()
            end

            lastQBAimbotValue = Options.QBAimbot.Value
        end
    end)
else
    local __namecall; __namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()

        if args[1] == "Clicked" and Options.QBAimbot.Value and not checkcaller() then
            local nwArgs = {"Clicked", player.Character.Head.Position, player.Character.Head.Position + direction * 10000, (IS_PRACTICE and power) or args[4], power}
            firedRemoteEvent = true
            return __namecall(self, unpack(nwArgs))
        end

        return __namecall(self, ...)
    end))
end

-- QBAimbot Main Execution Loop
task.spawn(function()
    while true do task.wait();
        local s, e = pcall(function()
            local qbCardsEnabled = Options.QBAimbotUI.Value and Options.QBAimbot.Value and (player.PlayerGui:FindFirstChild("BallGui") or camera.CameraSubject:IsA("BasePart"))
            if qbCards then
                qbCards.Enabled = qbCardsEnabled
            end

            qbBeam.Enabled = Options.QBAimbotVisualise.Value and Options.QBAimbot.Value and (player.PlayerGui:FindFirstChild("BallGui") or camera.CameraSubject:IsA("BasePart"))
            qbHighlight.Enabled = Options.QBAimbotVisualise.Value and Options.QBAimbot.Value and player.PlayerGui:FindFirstChild("BallGui")

            qbHighlight.FillColor = locked and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(255, 255, 255)
            qbHighlight.OutlineColor = locked and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 255, 255)

            qbPart.Transparency = Options.QBAimbotVisualise.Value and Options.QBAimbot.Value and (player.PlayerGui:FindFirstChild("BallGui") or camera.CameraSubject:IsA("BasePart")) and 0 or 1

            if not player.Character:FindFirstChild("Football") and player.PlayerGui:FindFirstChild("BallGui") then
                player.PlayerGui:FindFirstChild("BallGui").Parent = nil
            end

            if not player.PlayerGui:FindFirstChild("BallGui") then firedRemoteEvent = false return end
            if not Options.QBAimbot.Value then return end
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

            target = (locked and target) or findTarget()

            if not target then return end

            if not target.Parent then locked = false return end
            if not target:FindFirstChild("HumanoidRootPart") then locked = false return end

            local IN_AIR = player.Character.Humanoid.FloorMaterial == Enum.Material.Air

            local distance = (target.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            local route = findRoute(target)

            if Options.QBAimbotAutoThrowType.Value then
                throwType = determineAutoThrowType(route)
            end

            nonVisualThrowType = throwType == "Bullet" and (IN_AIR and "Jump" or "Dime") or nil

            local realThrowType = throwType
            local throwType = nonVisualThrowType or throwType

            local QBAimbot95PowerOnly = realThrowType == "Bullet" and {
                Value = true
            } or Options.QBAimbot95PowerOnly

            local xLead = qbOffsets[throwType].xLead or 0
            local yLead = qbOffsets[throwType].yLead or 0

            if QBAimbot95PowerOnly.Value and throwType == "Jump" then
                xLead += 3.5
                yLead -= 1
            end

            if angle > 30 and QBAimbot95PowerOnly.Value and route == "go" then
                yLead -= 0.5 + math.min(angle - 30, 5) / 10
            end

            if within(sidewayRoutes, route) and IN_AIR then
                yLead += 8
                xLead += 3
            end

            if within(inAirAdditiveRoutes, route) and IN_AIR then
                yLead += 4
            end

            xLead += qbOffsets[throwType].routes[route].xzOffset or 0
            yLead += qbOffsets[throwType].routes[route].yOffset or 0

            xLead += Options.QBAimbotXOffset.Value
            yLead += Options.QBAimbotYOffset.Value

            if IN_AIR and QBAimbot95PowerOnly.Value then
                yLead += 1
            end

            angle = (QBAimbot95PowerOnly.Value and determine95PowerOnlyAngle(distance, route, target)) or (Options.QBAimbotAutoAngle.Value and determineAutoAngle(distance, route)) or angle

            if (not Options.QBAimbotAutoAngle.Value and not QBAimbot95PowerOnly.Value) and (angle % 5 ~= 0) then
                angle = 45
            end

            local s, velocity, position, airtime = pcall(qbFinalCalc, target, angle, xLead, yLead, table.find(sidewayRoutes, route))

            if not s then
                return
            end

            local isInterceptable = checkIfInterceptable(position, airtime)

            power = math.min(math.round(velocity.Magnitude), 95)
            direction = velocity.Unit
            local curve0, curve1, cf1, cf2 = beamProjectile(Vector3.new(0, -28, 0), power * direction, player.Character.Head.Position + (direction * 5), airtime);
            qbBeam.CurveSize0 = curve0; qbBeam.CurveSize1 = curve1
            qbA0.CFrame = qbA0.Parent.CFrame:inverse() * cf1
            qbA1.CFrame = qbA1.Parent.CFrame:inverse() * cf2

            if qbCards and qbCards:FindFirstChild("Container") then
                pcall(function()
                    qbCards.Container.Angle.Value.Text = "Angle: " .. math.round(angle * 10) / 10
                    qbCards.Container.Player.Value.Text = "Player: " .. target.Name
                    qbCards.Container.Interceptable.Value.Text = "Interceptable: " .. tostring(isInterceptable)
                    qbCards.Container.Power.Value.Text = "Power: " .. power
                    qbCards.Container.Mode.Value.Text = "Mode: " .. realThrowType
                    qbCards.Container.Route.Value.Text = "Route: " .. route
                    qbCards.Container.Distance.Value.Text = "Distance: " .. math.round(distance)
                end)
            end

            qbPart.Position = getPosInXTimeFromVel(player.Character.Head.Position + direction * 5, power * direction, Vector3.new(0, -28, 0), airtime)

            qbHighlight.Parent = target
            qbHighlight.Adornee = target

            if Options.QBAimbotAdjustPowerGUI.Value then
                changePowerGui(findClosestMultiple(5, power))
            end
        end);
    end
end)

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

local fakeBalls = {}
local pullVectoredBalls = {}
local velocity = {}
local isCatching = false

local part = Instance.new("Part")
part.Transparency = 0.5
part.Anchored = true
part.CanCollide = false
part.CastShadow = false
part.Color = Color3.fromRGB(0, 255, 255)
part.Shape = Enum.PartType.Ball
part.Material = Enum.Material.ForceField
part.Parent = workspace

-- Clear tables periodically to prevent memory leaks
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
end

workspace.ChildAdded:Connect(function(ball)
    if ball.Name ~= "Football" then return end
    if not ball:IsA("BasePart") then return end
    task.wait()

    -- Ball velocity tracking and Solara fake ball system
    local lastPosition = ball.Position
    local lastCheck = os.clock()
    local initalVelocity = Vector3.new(0, 0, 0)
    pcall(function()
        if ball and typeof(ball) == "Instance" and ball:IsA("BasePart") then
            initalVelocity = ball.Velocity
        end
    end)

    if (IS_SOLARA) and ball:FindFirstChildWhichIsA("Trail") and not ball.Anchored and camera.CameraSubject ~= ball then
        local fakeBall = ball:Clone()
        fakeBall.Name = "FFootball"
        fakeBall.Parent = workspace
        fakeBall.Anchored = true
        fakeBall.CanCollide = false
        if fakeBall:FindFirstChildWhichIsA('PointLight') then
            fakeBall:FindFirstChildWhichIsA('PointLight'):Destroy()
        end
        ball.Transparency = 1
        local spiralDegrees = 0
        fakeBalls[ball] = fakeBall
        task.spawn(function()
            while ball.Parent == workspace do
                local dt = runService.Heartbeat:Wait()
                spiralDegrees += 1500 * dt
                initalVelocity += Vector3.new(0, -28 * dt, 0)
                fakeBall.Position += initalVelocity * dt
                fakeBall.CFrame = CFrame.lookAt(fakeBall.Position, fakeBall.Position + initalVelocity) * CFrame.Angles(math.rad(90), math.rad(spiralDegrees), 0)

                if ball:FindFirstChildWhichIsA("Trail") then
                    ball:FindFirstChildWhichIsA("Trail").Enabled = false
                end
            end
            if fakeBall and fakeBall.Parent then
                fakeBall:Destroy()
            end
            fakeBalls[ball] = nil
        end)
    end

    task.spawn(function()
        while ball.Parent do
            task.wait(0.1)
            local t = (os.clock() - lastCheck)
            pcall(function()
                if ball and typeof(ball) == "Instance" and ball:IsA("BasePart") then
                    velocity[ball] = (ball.Position - lastPosition) / t
                end
            end)
            lastCheck = os.clock()
            pcall(function()
                if ball and typeof(ball) == "Instance" and ball:IsA("BasePart") then
                    lastPosition = ball.Position
                end
            end)
        end
        velocity[ball] = nil
        fakeBalls[ball] = nil
    end)

    if Options.NoBallTrail.Value and ball:FindFirstChildWhichIsA("Trail") then
        ball:FindFirstChildWhichIsA("Trail").Enabled = false
    end

    task.spawn(function()
        if not Options.OptimalJump.Value then return end
        local initalVelocity = Vector3.new(0,0,0)
        pcall(function()
            if ball and ball:IsA("BasePart") then initalVelocity = ball.Velocity end
        end)
        local optimalPosition = Vector3.zero

        local currentPosition = ball.Position

        local t = 0

        while true do
            t += 0.05
            initalVelocity += Vector3.new(0, -28 * 0.05, 0)
            currentPosition += initalVelocity * 0.05
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {workspace:FindFirstChild("Models")}
            raycastParams.FilterType = Enum.RaycastFilterType.Include

            local ray = workspace:Raycast(currentPosition, Vector3.new(0, Options.OptimalJumpType.Value == "Jump" and -13 or -15, 0), raycastParams)
            local antiCrashRay = workspace:Raycast(currentPosition, Vector3.new(0, -500, 0), raycastParams)

            if ray and t > 0.75 then
                optimalPosition = ray.Position + Vector3.new(0, 2, 0)
                break
            end

            if not antiCrashRay then
                optimalPosition = currentPosition
                break
            end
        end

        local part = Instance.new("Part")
        part.Anchored = true
        part.Material = Enum.Material.Neon
        part.Size = Vector3.new(1.5, 1.5, 1.5)
        part.Position = optimalPosition
        part.CanCollide = false
        part.Color = Color3.fromRGB(0, 255, 255)
        part.Parent = workspace

        repeat task.wait() until ball.Parent ~= workspace

        part:Destroy()
    end)

    -- Ball Path Visualization
    task.spawn(function()
        if not Options.VisualizeBallPath.Value then return end
        local currentInitialVelocity = Vector3.new(0,0,0)
        pcall(function()
            if ball and ball:IsA("BasePart") then currentInitialVelocity = ball.Velocity end
        end)

        local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
        a0.Parent = workspace.Terrain; a1.Parent = workspace.Terrain

        local beam = Instance.new("Beam", workspace.Terrain)
        beam.Attachment0 = a0
        beam.Attachment1 = a1
        beam.Segments = 500
        beam.Width0 = 0.5
        beam.Width1 = 0.5
        beam.Transparency = NumberSequence.new(0)
        beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255))

        local g = Vector3.new(0, -28 ,0)
        local x0 = ball.Position
        local v0 = currentInitialVelocity

        local curve0, curve1, cf1, cf2 = beamProjectile(g, v0, x0, 5)

        beam.CurveSize0 = curve0
        beam.CurveSize1 = curve1
        a0.CFrame = a0.Parent.CFrame:inverse() * cf1
        a1.CFrame = a1.Parent.CFrame:inverse() * cf2

        repeat task.wait() until not ball or ball.Parent ~= workspace

        if beam then beam:Destroy() end
        if a0 then a0:Destroy() end
        if a1 then a1:Destroy() end
    end)
end)

local quickTPCooldown = os.clock()

-- Magnet Hitbox Logic
task.spawn(function()
    while true do
        task.wait(1/60)
        local ball = findClosestBall()
        local character = player.Character
        local showHitboxOption = safeIndex(Options.ShowMagHitbox, "Value")
        local magnetsEnabled = Options.Magnets and Options.Magnets.Value

        if not ball or not character or not magnetsEnabled then
            if part and part.Parent then
                part.Parent = nil
            end
            continue
        end

        local catchLeft = character:FindFirstChild("CatchLeft")
        local catchRight = character:FindFirstChild("CatchRight")

        if not catchLeft or not catchRight then
            if part and part.Parent then part.Parent = nil end
            continue
        end

        local catchPart = getNearestPartToPartFromParts(ball, {catchLeft, catchRight})

        if not catchPart then
            if part and part.Parent then part.Parent = nil end
            continue
        end

        if part and not showHitboxOption then
            part.Parent = nil
        end

        if Options.MagnetsType.Value == "League" then
            if not velocity[ball] then
                if part and part.Parent then part.Parent = nil end
                continue
            end

            local predictedPosition = (fakeBalls[ball] or ball).Position + (velocity[ball] * ping)
            local distance = (catchPart.Position - predictedPosition).Magnitude

            part.Position = ball.Position
            part.Size = Vector3.new(
                safeIndex(Options.MagnetsCustomRadius, "Value") or 35,
                safeIndex(Options.MagnetsCustomRadius, "Value") or 35,
                safeIndex(Options.MagnetsCustomRadius, "Value") or 35
            )

            if magnetsEnabled and showHitboxOption then
                part.Parent = workspace
            else
                if part then part.Parent = nil end
            end

            if part and part.Parent then
                part.Color = Color3.fromRGB(0, 255, 255)
                part.Material = Enum.Material.ForceField
                part.Transparency = 0.6
            end

            if distance <= (safeIndex(Options.MagnetsCustomRadius, "Value") or 35) then
                firetouchinterest(catchPart, ball, 0)
                firetouchinterest(catchPart, ball, 1)
            end
        else
            local distance = (catchPart.Position - ball.Position).Magnitude
            local radius = (Options.MagnetsType.Value == "Blatant" and 50 or 6)

            part.Position = (fakeBalls[ball] or ball).Position
            part.Size = Vector3.new(radius, radius, radius)

            if magnetsEnabled and showHitboxOption then
                part.Parent = workspace
            else
                if part then part.Parent = nil end
            end

            if part and part.Parent then
                part.Color = Color3.fromRGB(0, 255, 255)
                part.Material = Enum.Material.ForceField
                part.Transparency = 0.6
            end

            if not isCatching and IS_SOLARA then
                -- No action
            else
                if distance < radius then
                    firetouchinterest(catchPart, ball, 0)
                    firetouchinterest(catchPart, ball, 1)
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        local ball = findClosestBall() if not ball then continue end
        local character = player.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

        if not ball:FindFirstChildWhichIsA("Trail") then continue end
        if not character or not humanoidRootPart then continue end
        if not Options.PullVector.Value then continue end
        if ball.Anchored then continue end

        local distance = (humanoidRootPart.Position - ball.Position).Magnitude
        if distance > Options.PullVectorDistance.Value then continue end

        local direction = (ball.Position - humanoidRootPart.Position).Unit

        if Options.PullVectorType.Value == "Teleport" then
            local dist = 10 + ((Options.PullVectorPower.Value - 1) * 5)
            pcall(function()
                if humanoidRootPart and typeof(humanoidRootPart) == "Instance" then
                    humanoidRootPart.CFrame += direction * dist
                end
            end)
        else
            pcall(function()
                if humanoidRootPart and typeof(humanoidRootPart) == "Instance" and humanoidRootPart:IsA("BasePart") then
                    local newVelocity = direction * Options.PullVectorPower.Value * 25
                    humanoidRootPart.Velocity = newVelocity
                end
            end)
        end
    end
end)

onCharacterCatching(player.Character)
player.CharacterAdded:Connect(onCharacterCatching)

-- Physics and other features continue...

local boundaries = {}

if not IS_PRACTICE then
    for index, part in pairs(workspace.Models.Boundaries:GetChildren()) do
        boundaries[#boundaries + 1] = part
    end
end

-- Anti OOB implementation
task.spawn(function()
    while true do
        task.wait()

        if Options.AntiOOB and Options.AntiOOB.Value then
            for _, boundary in pairs(boundaries) do
                if boundary and boundary.Parent then
                    boundary.Parent = nil
                end
            end
        else
            for _, boundary in pairs(boundaries) do
                if boundary and not boundary.Parent then
                    boundary.Parent = workspace.Models.Boundaries
                end
            end
        end
    end
end)

userInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    if not Options.QuickTPBind or not Options.QuickTPBind.Value then return end

    if input.KeyCode ~= Options.QuickTPBind.Value then return end

    local character = player.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChild("Humanoid")

    if not Options.QuickTP or not Options.QuickTP.Value then return end
    if not character or not humanoidRootPart or not humanoid then return end
    if (os.clock() - quickTPCooldown) < 0.1 then return end

    local speed = 2 + ((Options.QuickTPSpeed and Options.QuickTPSpeed.Value or 3) / 4)

    humanoidRootPart.CFrame += humanoid.MoveDirection * speed
    quickTPCooldown = os.clock()
end)

mouse.Button1Down:Connect(function()
    if not Options.ClickTackleAimbot or not Options.ClickTackleAimbot.Value then return end

    local possessor = findPossessor()
    local character = player.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

    if not character or not humanoidRootPart then return end
    if not possessor or not possessor:FindFirstChild("HumanoidRootPart") then return end

    local distance = (possessor.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
    if not Options.ClickTackleAimbotDistance or distance > Options.ClickTackleAimbotDistance.Value then return end

    humanoidRootPart.CFrame = possessor.HumanoidRootPart.CFrame
end)

local function onCharacterPhysics(char)
    local humanoid = char:WaitForChild("Humanoid")

    char.DescendantAdded:Connect(function(v)
        task.wait()
        if v.Name:match("FFmover") and Options.AntiBlock.Value then
            v:Destroy()
        end
    end)

    task.spawn(function()
        while true do
            task.wait()
            if Options.NoJumpCooldown.Value then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            end

            local torso = char:FindFirstChild("Torso")
            local head = char:FindFirstChild("Head")

            if not torso or not head then return end

            if humanoid:GetState() == Enum.HumanoidStateType.Running and values.Status.Value == "InPlay" then
                torso.CanCollide = not Options.AntiJam.Value
                head.CanCollide = not Options.AntiJam.Value
            else
                torso.CanCollide = true
                head.CanCollide = true
            end
        end
    end)
end

task.spawn(function()
    local function applyChanges(character)
        local head = character and character:FindFirstChild("Head")
        local mesh = head and head:FindFirstChildWhichIsA("SpecialMesh")

        if not mesh then return end

        mesh.MeshType = Options.BigHead.Value and Enum.MeshType.Sphere or Enum.MeshType.Head
        head.Size = Options.BigHead.Value and Vector3.new(Options.BigHeadSize.Value, 1, Options.BigHeadSize.Value) or Vector3.new(2, 1, 1)
    end

    while true do
        task.wait()

        for index, plr in pairs(players:GetPlayers()) do
            if plr == players.LocalPlayer then continue end
            applyChanges(plr.Character)
        end
    end
end)

onCharacterPhysics(player.Character)
player.CharacterAdded:Connect(onCharacterPhysics)

local function onCharacterMovement(character)
    local humanoid = character:WaitForChild("Humanoid")
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    task.spawn(function()
        while AC_BYPASS and humanoid.Parent do
            task.wait(.1)
            humanoid.JumpPower = Options.JumpPower.Value and Options.JumpPowerValue.Value or 50
        end
    end)

    humanoid.Jumping:Connect(function()
        if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then return end
        if AC_BYPASS then return end
        task.wait(0.05)
        if Options.JumpPower.Value then
            pcall(function()
                if humanoidRootPart and typeof(humanoidRootPart) == "Instance" and humanoidRootPart:IsA("BasePart") then
                    local jumpBoost = Options.JumpPowerValue.Value - 50
                    humanoidRootPart.Velocity += Vector3.new(0, jumpBoost, 0)
                end
            end)
        end
    end)
end

onCharacterMovement(player.Character or player.CharacterAdded:Wait())
player.CharacterAdded:Connect(onCharacterMovement)

local angleTick = os.clock()

task.spawn(function()
    local oldLookVector = Vector3.new(0, 0, 0)
    local shiftLockEnabled = false
    local lastEnabled = false

    local function hookCharacter(character)
        local humanoid = character:WaitForChild("Humanoid")
        local hrp = character:WaitForChild("HumanoidRootPart")

        humanoid.Jumping:Connect(function(isJumpingState)
            if not (humanoid:GetState() == Enum.HumanoidStateType.Jumping) then return end
            if not (Options.AngleAssist and Options.AngleAssist.Value) then return end
            if AC_BYPASS then return end

            if (os.clock() - (angleTick or 0)) < 0.25 then
                if hrp then
                    local jpValue = Options.AngleAssistJP and Options.AngleAssistJP.Value or 50
                    local impulse = (jpValue - 50)
                    if impulse > 0 then
                        hrp.Velocity += Vector3.new(0, impulse, 0)
                    end
                end
            end
        end)
    end

    hookCharacter(player.Character or player.CharacterAdded:Wait())

    player.CharacterAdded:Connect(hookCharacter)

    userInputService:GetPropertyChangedSignal("MouseBehavior"):Connect(function()
        if userInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
            shiftLockEnabled = true
        else
            if shiftLockEnabled then
                angleTick = os.clock()
            end
            shiftLockEnabled = false
        end
    end)

    while true do
        task.wait()
        local character = player.Character; if not character then continue end
        local hrp = character:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
        local humanoid = character:FindFirstChild("Humanoid"); if not humanoid then continue end

        if AC_BYPASS then
            if (os.clock() - (angleTick or 0) < 0.2) and Options.AngleAssist and Options.AngleAssist.Value then
                humanoid.JumpPower = (Options.JumpPower and Options.JumpPower.Value and Options.JumpPowerValue.Value or 50) + (Options.AngleAssistJP.Value - 50)
            elseif not (Options.AngleAssist and Options.AngleAssist.Value) then
                humanoid.JumpPower = (Options.JumpPower and Options.JumpPower.Value and Options.JumpPowerValue.Value or 50)
            end
        end

        oldLookVector = hrp.CFrame.LookVector
        lastEnabled = shiftLockEnabled
    end
end)

runService:BindToRenderStep("walkSpeed", Enum.RenderPriority.Character.Value, function()
    local character = player.Character
    local humanoid = character and character:FindFirstChild("Humanoid")

    if not character or not humanoid then return end
    if humanoid:GetState() ~= Enum.HumanoidStateType.Running then return end
    if humanoid.WalkSpeed == 0 and not (Options.NoFreeze and Options.NoFreeze.Value) then return end
    if not character:FindFirstChild("HumanoidRootPart") then return end

    local moveDirection

    if moveToUsing and #moveToUsing > 0 and (os.clock() - (moveToUsing[#moveToUsing] or 0)) < 0.5 then
        pcall(function()
            if humanoid.WalkToPoint and typeof(humanoid.WalkToPoint) == "Vector3" and
               character and character:FindFirstChild("HumanoidRootPart") and
               typeof(character.HumanoidRootPart.Position) == "Vector3" then
                local direction = (humanoid.WalkToPoint - character.HumanoidRootPart.Position)
                if direction.Magnitude > 0 then
                    moveDirection = direction.Unit
                end
            end
        end)
    end

    if not moveDirection then
        moveDirection = humanoid.MoveDirection
    end

    local currentVel = Vector3.new(0, 0, 0)
    pcall(function()
        if character and character:FindFirstChild("HumanoidRootPart") and
           typeof(character.HumanoidRootPart) == "Instance" and
           character.HumanoidRootPart:IsA("BasePart") then
            currentVel = character.HumanoidRootPart.Velocity
        end
    end)

    if (Options.Speed and Options.Speed.Value) or (Options.NoFreeze and Options.NoFreeze.Value) then
        local speedVal = 20

        if Options.Speed and Options.Speed.Value and Options.SpeedValue then
            if type(Options.SpeedValue.Value) == "number" and Options.SpeedValue.Value > 20 then
                speedVal = Options.SpeedValue.Value
            end
        end

        pcall(function()
            if character and character:FindFirstChild("HumanoidRootPart") and
               typeof(character.HumanoidRootPart) == "Instance" and
               character.HumanoidRootPart:IsA("BasePart") then
                local newVelocity = Vector3.new(
                    moveDirection.X * speedVal,
                    currentVel.Y,
                    moveDirection.Z * speedVal
                )
                character.HumanoidRootPart.Velocity = newVelocity
            end
        end)
    end
end)

-- Auto Reset / Auto Cap / etc.
local finishLine = not IS_PRACTICE and workspace.Models.LockerRoomA.FinishLine or Instance.new('Part')

task.spawn(function()
    while true do
        task.wait()
        if not safeIndex(Options.AutoCap, "Value") then continue end
        if IS_PRACTICE then continue end

        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        if not finishLine or typeof(finishLine) ~= "Instance" then continue end

        local distance
        pcall(function()
            distance = (hrp.Position - finishLine.Position).Magnitude
        end)

        if not distance or distance > 10 then continue end

        local possessor = findPossessor()
        if not possessor then continue end

        local possessorIsLocalPlayer = possessor == character
        if possessorIsLocalPlayer then
            local event = game:GetService("ReplicatedStorage").Remotes.Touchdown
            if event then
                event:FireServer()
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)

        if safeIndex(Options.Speed, "Value") and safeIndex(Options.SpeedValue, "Value") then
            local character = player.Character
            local humanoid = character and character:FindFirstChild("Humanoid")
            if humanoid then
                if AC_BYPASS then
                    humanoid.WalkSpeed = Options.SpeedValue.Value
                end
            end
        end

        if safeIndex(Options.JumpPower, "Value") and safeIndex(Options.JumpPowerValue, "Value") then
            local character = player.Character
            local humanoid = character and character:FindFirstChild("Humanoid")
            if humanoid and AC_BYPASS then
                humanoid.JumpPower = Options.JumpPowerValue.Value
            end
        end

        if safeIndex(Options.AngleAssist, "Value") and safeIndex(Options.AngleAssistJP, "Value") then
            local character = player.Character
            local humanoid = character and character:FindFirstChild("Humanoid")
            if humanoid and AC_BYPASS then
                if os.clock() - (angleTick or 0) < 0.2 then
                    humanoid.JumpPower = Options.AngleAssistJP.Value
                end
            end
        end
    end
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("Sense Hub")
SaveManager:SetFolder("Sense Hub/ff2")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
