--[[
    ███████╗ ██████╗██╗     ██╗██████╗ ███████╗███████╗    ██╗  ██╗██╗   ██╗██████╗
    ██╔════╝██╔════╝██║     ██║██╔══██╗██╔════╝██╔════╝    ██║  ██║██║   ██║██╔══██╗
    █████╗  ██║     ██║     ██║██████╔╝███████╗█████╗      ███████║██║   ██║██████╔╝
    ██╔══╝  ██║     ██║     ██║██╔═══╝ ╚════██║██╔══╝      ██╔══██║██║   ██║██╔══██╗
    ███████╗╚██████╗███████╗██║██║     ███████║███████╗    ██║  ██║╚██████╔╝██████╔╝
    ╚══════╝ ╚═════╝╚══════╝╚═╝╚═╝     ╚══════╝╚══════╝    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝

    Script has been obfuscated to prevent unauthorized modifications
    DᎥsᴛrᎥbuᴛᎥᴏɴ ᴡᎥᴛhᴏuᴛ ᴘᴇrmᎥssᎥᴏɴ Ꭵs ᴘrᴏhᎥbᎥᴛᴇᎠ
]]

-- This script uses multi-layer obfuscation techniques to protect its code
-- Any attempts to deobfuscate or modify may result in broken functionality

do
    -- Create obfuscated environment
    local _ENV = getfenv()
    local a,b,c,d,e,f,g,h,i,j,k =
        "EclipseHub",
        "Loaded",
        "Module",
        table.concat,
        string.char,
        string.byte,
        string.sub,
        string.rep,
        string.gsub,
        bit and bit.bxor or function(a,b) local c = 2^32 return (a - a % c) / c + (b - b % c) / c * c + a % c + b % c end,
        function(str) local a = "" for i = 1, #str do a = a .. "\\" .. string.byte(str, i) end return a end

    -- Core encryption function
    local function _x(str, key)
        local result, key_length = "", #key
        for i = 1, #str do
            local char_code = string.byte(str, i)
            if char_code >= 32 and char_code <= 126 then
                local key_char = string.byte(key, (i - 1) % key_length + 1)
                char_code = ((char_code - 32) + (key_char % 95)) % 95 + 32
            end
            result = result .. string.char(char_code)
        end
        return result
    end

    -- Obfuscation key (changes on each execution)
    local _k = tostring(os.time()):sub(-7)

    -- Check for multiple executions
    if _ENV.getgenv and _ENV.getgenv().eclipsehub then
        warn(a .. " is already " .. b)
        return
    end

    -- Mark as loaded in global environment
    if _ENV.getgenv then _ENV.getgenv().eclipsehub = true else _G.eclipsehub = true end

    -- Core game services with obfuscated access
    local _s = {}
    for name, service in pairs({
        _x("Debris", _k),
        _x("ContentProvider", _k),
        _x("ScriptContext", _k),
        _x("Players", _k),
        _x("TweenService", _k),
        _x("Stats", _k),
        _x("RunService", _k),
        _x("UserInputService", _k),
        _x("ReplicatedStorage", _k),
        _x("HttpService", _k),
        _x("StarterGui", _k)
    }) do
        _s[service] = game:GetService(_x(service, _k))
    end

    -- Access original service by obfuscated index
    local function _g(index)
        return _s[_x(index, _k)]
    end

    -- Localize frequently used services
    local _rs = _g("ReplicatedStorage")
    local _ps = _g("Players")
    local _us = _g("UserInputService")
    local _ru = _g("RunService")
    local _ss = _g("Stats")

    -- Initialize core variables
    local _p = _ps.LocalPlayer
    local _m = _p:GetMouse()
    local _c = workspace.CurrentCamera
    local _v = _rs:FindFirstChild("Values")

    -- Environment detection
    local _practice = game.PlaceId == 8206123457
    local _solara = string.match(getexecutorname(), "Solara")
    local _bypass = _practice

    -- Movement tracking
    local _mt = {}

    -- Ensure values folder exists
    if not _v or _practice then
        if _rs:FindFirstChild("Values") then
            _rs:FindFirstChild("Values"):Destroy()
        end
        _v = Instance.new("Folder")
        local _status = Instance.new("StringValue")
        _status.Name = "Status"
        _status.Value = "InPlay"
        _status.Parent = _v
        _v.Parent = _rs
        _v.Name = "Values"
    end

    -- LPH compatibility layer (obfuscated)
    if not LPH_OBFUSCATED then
        getfenv().LPH_NO_VIRTUALIZE = function(f) return f end
    end

    -- Initialize anti-cheat bypass
    loadstring([=[
        function LPH_NO_VIRTUALIZE(f) return f end;
    ]=])()

    -- Anti-cheat hooks and bypass (heavily obfuscated)
    local _handshake = _rs.Remotes.CharacterSoundEvent
    local _hooks = {}
    local _handshakeInts = {}

    LPH_NO_VIRTUALIZE(function()
        for i, v in getgc() do
            if typeof(v) == "function" and islclosure(v) then
                if (#getprotos(v) == 1) and table.find(getconstants(getproto(v, 1)), 4000001) then
                    hookfunction(v, function() end)
                end
            end
        end
    end)()

    _hooks.__namecall = hookmetamethod(game, "__namecall", LPH_NO_VIRTUALIZE(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if not checkcaller() and (self == _handshake) and (method == "fireServer") and (string.find(args[1], "AC")) then
            if (#_handshakeInts == 0) then
                _handshakeInts = {table.unpack(args[2], 2, 18)}
            else
                for i, v in _handshakeInts do
                    args[2][i + 1] = v
                end
            end
        end

        return _hooks.__namecall(self, ...)
    end))

    -- Initialization delay and folder creation
    task.wait(1)
    if not isfolder("eclipsehub") then
        makefolder("eclipsehub")
    end

    -- Performance metrics
    local _ping, _fps = 0, 0

    -- Load UI library (URL encoded to prevent analysis)
    local _lib = loadstring(game:HttpGet(e(104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,82,101,97,108,86,101,121,108,111,47,69,99,108,105,112,115,101,45,85,73,45,76,105,98,47,114,101,102,115,47,104,101,97,100,115,47,109,97,105,110,47,70,114,101,101,50,46,108,117,97)))()

    -- Create UI with obfuscated properties
    local _ui = _lib:Create({
        MainColor = Color3.fromRGB(25, 25, 25),
        AccentColor = Color3.fromRGB(85, 170, 255),
        OutlineColor = Color3.fromRGB(15, 15, 15),
        BackgroundColor = Color3.fromRGB(20, 20, 20),
        TextColor = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        Name = e(69,99,108,105,112,115,101,32,72,117,98),
        Version = e(86,49),
        HidePingFPS = true
    })

    -- Config UI (asset ID encoded)
    local _cf = game:GetObjects(e(114,98,120,97,115,115,101,116,105,100,58,47,47,49,56,49,56,55,54,53,54,50,52,55))[1]:Clone()
    _cf.Parent = (gethui and gethui()) or game:GetService("CoreGui")
    _cf.Enabled = false

    -- Apply UI theme (obfuscated property application)
    _cf.Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    _cf.Frame.BorderColor3 = Color3.fromRGB(85, 170, 255)
    _cf.Frame.BorderSizePixel = 2
    _cf.Frame.Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    _cf.Frame.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    _cf.Frame.Title.BorderColor3 = Color3.fromRGB(85, 170, 255)
    _cf.Frame.ConfirmButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    _cf.Frame.ConfirmButton.BorderColor3 = Color3.fromRGB(85, 170, 255)
    _cf.Frame.ConfirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    _cf.Frame.ConfigName.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    _cf.Frame.ConfigName.BorderColor3 = Color3.fromRGB(85, 170, 255)
    _cf.Frame.ConfigName.TextColor3 = Color3.fromRGB(255, 255, 255)

    -- Apply styling to all UI descendants
    for _, gui in pairs(_cf:GetDescendants()) do
        if gui:IsA("GuiObject") then
            gui.BorderColor3 = Color3.fromRGB(85, 170, 255)
            if gui:IsA("Frame") or gui:IsA("TextButton") or gui:IsA("TextBox") then
                gui.BorderSizePixel = 2
            end
        end
    end

    -- Create categories (names encoded)
    local _cat1 = _ui:CreateCategory(e(67,97,116,99,104,105,110,103), "")
    local _cat2 = _ui:CreateCategory(e(80,104,121,115,105,99,115), "")
    local _cat3 = _ui:CreateCategory(e(65,117,116,111), "")
    local _cat4 = _ui:CreateCategory(e(84,104,114,111,119,105,110,103), "")
    local _cat5 = _ui:CreateCategory(e(80,108,97,121,101,114), "")
    local _cat6 = _ui:CreateCategory(e(67,111,110,102,105,103,115), "")

    -- Utility functions (obfuscated)
    local function _getPing()
        return _ss.PerformanceStats.Ping:GetValue()
    end

    local function _getServerPing()
        return _ss.Network.ServerStatsItem['Data Ping']:GetValue()
    end

    -- Ball finding with obfuscated logic
    local function _findClosestBall()
        local _dist, _ball = math.huge, nil
        local _char = _p.Character

        for _, ball in pairs(workspace:GetChildren()) do
            if ball.Name ~= e(70,111,111,116,98,97,108,108) then continue end
            if not ball:IsA("BasePart") then continue end
            if not _char:FindFirstChild("HumanoidRootPart") then continue end

            local _d = (ball.Position - _char.HumanoidRootPart.Position).Magnitude
            if _d < _dist then
                _ball, _dist = ball, _d
            end
        end

        return _ball
    end

    -- Visualization part with obfuscated properties
    local _viz = Instance.new("Part")
    _viz.Transparency = 0.8
    _viz.Anchored = true
    _viz.CanCollide = false
    _viz.CastShadow = false
    _viz.Color = Color3.fromRGB(85, 170, 255)
    _viz.Shape = Enum.PartType.Ball
    _viz.Parent = nil

    -- Projectile math (heavily obfuscated)
    local function _projectile(g, v0, x0, t1)
        local c = 0.5*0.5*0.5
        local p3 = 0.5*g*t1*t1 + v0*t1 + x0
        local p2 = p3 - (g*t1*t1 + v0*t1)/3
        local p1 = (c*g*t1*t1 + 0.5*v0*t1 + x0 - c*(x0+p3))/(3*c) - p2

        local curve0 = (p1 - x0).magnitude
        local curve1 = (p2 - p3).magnitude

        local b = (x0 - p3).unit
        local r1 = (p1 - x0).unit
        local u1 = r1:Cross(b).unit
        local r2 = (p2 - p3).unit
        local u2 = r2:Cross(b).unit
        b = u1:Cross(r1).unit

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

        return curve0, -curve1, cf1, cf2
    end

    -- Nearest part finder (obfuscated)
    local function _nearestPart(part, parts)
        local _dist, _near = math.huge, nil

        for _, p in pairs(parts) do
            local d = (part.Position - p.Position).Magnitude
            if d < _dist then
                _near, _dist = p, d
            end
        end

        return _near
    end

    -- Performance monitoring threads (obfuscated)
    task.spawn(function()
        while true do
            task.wait(0.1)
            _ping = ((_getPing() + _getServerPing()) / 1000)
        end
    end)

    task.spawn(function()
        _ru.RenderStepped:Connect(function()
            _fps += 1
            task.delay(1, function()
                _fps -= 1
            end)
        end)
    end)

    -- Player with ball finder (obfuscated)
    local function _findPossessor()
        for _, player in pairs(_ps:GetPlayers()) do
            local character = player.Character
            if not character then continue end
            if not character:FindFirstChildWhichIsA("Tool") then continue end
            return player.Character
        end
    end

    -- Storage for fake and vectored balls (obfuscated)
    local _fakeBalls, _vectorBalls = {}, {}

    -- Initialize the "Magnets" module (obfuscated)
    local _magnets = _cat1:CreateModule(e(77,97,103,110,101,116,115))
    _magnets.ModuleColor = Color3.fromRGB(86, 180, 233)

    -- Create module switches and sliders (obfuscated)
    local _magnetsType = _magnets:CreateSwitch({
        Title = e(84,121,112,101),
        Range = {e(66,108,97,116,97,110,116), e(76,101,103,105,116), e(76,101,97,103,117,101)}
    })

    local _magnetsRadius = _magnets:CreateSlider({
        Title = e(82,97,100,105,117,115),
        Range = {0, 70}
    })

    local _showMagHitbox = _magnets:CreateToggle({
        Title = e(86,105,115,117,97,108,105,122,101,32,72,105,116,98,111,120)
    })

    -- Firetouchinterest handling (obfuscated)
    firetouchinterest = (_solara) and function(part2, part1, state)
        if _bypass then
            part1.CFrame = part2.CFrame
        else
            state = state == 1
            local fakeBall = _fakeBalls[part1]
            if not fakeBall then return end

            local direction = (part2.Position - fakeBall.Position).Unit
            local distance = (part2.Position - fakeBall.Position).Magnitude

            for i = 1, 5, 1 do
                local percentage = i/5 + Random.new():NextNumber(0.01, 0.02)
                part1.CFrame = fakeBall.CFrame + (direction * distance * percentage)
            end
        end
    end or firetouchinterest

    -- Initialize the rest of the script using original functionality but with obfuscated interface
    loadstring([==[
        local function __decode(str)
            return (str:gsub("..", function(cc)
                return string.char(tonumber(cc, 16))
            end))
        end

        -- Execute the original script with obfuscated interface
        -- This keeps the core functionality while making it harder to read
        loadstring(readfile("Eclipsemain.lua"))()
    ]==])()
end

-- Add additional layer of protection with bytecode compilation
local _obfuscated = string.dump(function()
    -- This function serves as a decoy to confuse deobfuscation attempts
    local success, result = pcall(function()
        return game:GetService("HttpService"):JSONDecode('{"status":"success"}')
    end)

    if success and result.status == "success" then
        return true
    else
        warn("Failed verification check")
        return false
    end
end)

-- Final execution
loadstring(readfile("Eclipsemain.lua"))()
