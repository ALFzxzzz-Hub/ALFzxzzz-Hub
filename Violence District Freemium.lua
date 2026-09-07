--========================================================--
-- PURPLE X HUB • OBSIDIAN UI • OPTIMIZED --
-- MOBILE + PC --
--========================================================--

-- LOAD LIB
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

-- SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--========================================================--
-- THEME
--========================================================--

Library.Scheme.AccentColor = Color3.fromRGB(158, 158, 158)
Library.Scheme.BackgroundColor = Color3.fromRGB(7, 5, 10)
Library.Scheme.MainColor = Color3.fromRGB(45, 45, 45)
Library.Scheme.OutlineColor = Color3.fromRGB(204, 204, 204)
Library.Scheme.FontColor = Color3.fromRGB(233, 233, 233)

--========================================================--
-- TOGGLE MENU
--========================================================--

local function CreateToggleMenu(IconId)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PurpleXToggle"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = game:GetService("CoreGui")

    local MainButton = Instance.new("TextButton")
    MainButton.Name = "ToggleButton"
    MainButton.Text = ""
    MainButton.AutoButtonColor = false
    MainButton.Size = UDim2.fromOffset(45, 45)
    MainButton.Position = UDim2.fromOffset(15, 120)
    MainButton.BackgroundColor3 = Color3.fromRGB(20, 14, 27)
    MainButton.BackgroundTransparency = 0.05
    MainButton.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainButton

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(150, 150, 150)
    Stroke.Thickness = 1.5
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = MainButton

    local Icon = Instance.new("ImageLabel")
    Icon.Size = UDim2.fromScale(0.7, 0.7)
    Icon.Position = UDim2.fromScale(0.15, 0.15)
    Icon.BackgroundTransparency = 1
    Icon.Image = "rbxassetid://" .. IconId
    Icon.Parent = MainButton

    MainButton.MouseButton1Click:Connect(function()
        Library:Toggle()
    end)

    Library:MakeDraggable(MainButton, MainButton, true)

    return MainButton, ScreenGui
end

CreateToggleMenu(92826170205694)

--========================================================--
-- WINDOW
--========================================================--

local Window = Library:CreateWindow({
    Title = "ALFzxzzz X Hub",
    Footer = "Violence District - ALFzxzzz Hub - Freemium",
    Icon = 92826170205694,
    IconSize = UDim2.fromOffset(40, 40),
    CornerRadius = 7,
    NotifySide = "Right",
    ShowCustomCursor = true,
    ShowMobileButtons = false,
    ToggleKeybind = Enum.KeyCode.LeftControl,
    Size = UDim2.fromOffset(500, 350),
    EnableSidebarResize = false,
    EnableCompacting = true,
    SidebarCompacted = true,
})

--========================================================--
-- TABS
--========================================================--

local Tabs = {
    Player = Window:AddTab("Player", "user"),
    ESP = Window:AddTab("ESP", "eye"),
    Killer = Window:AddTab("Killer", "skull"),
    Misc = Window:AddTab("Misc", "sliders-horizontal"),
    UI = Window:AddTab("UI Settings", "settings-2")
}

--========================================================--
-- GROUPBOXES
--========================================================--

local AbilityBox = Tabs.Player:AddLeftGroupbox("Ability", "zap")
local SkillCheckBox = Tabs.Player:AddLeftGroupbox("Auto Skillcheck", "zap")
local ParryBox = Tabs.Player:AddLeftGroupbox("Auto Parry", "swords")
local ParryV2Box = Tabs.Player:AddLeftGroupbox("Auto Parry V2", "swords")
local SilentAimBox = Tabs.Player:AddLeftGroupbox("Silent Aim", "crosshair")
local MovementBox = Tabs.Player:AddRightGroupbox("Movement & Aim", "crosshair")
local ButtonBox = Tabs.Player:AddRightGroupbox("Buttons", "mouse-pointer-click")

local ESPBox = Tabs.ESP:AddLeftGroupbox("ESP", "scan-eye")
local ESPStatusBox = Tabs.ESP:AddRightGroupbox("ESP Status", "scan-eye")

local KillerBox = Tabs.Killer:AddLeftGroupbox("Killer", "skull")
local PowerBox = Tabs.Killer:AddRightGroupbox("Masked Power", "zap")

local ZoomBox = Tabs.Misc:AddLeftGroupbox("Camera", "camera")
local FunBox = Tabs.Misc:AddRightGroupbox("Fun", "smile")

local MenuBox = Tabs.UI:AddLeftGroupbox("Menu", "wrench")

--========================================================--
-- ANTI KNOCKDOWN
--========================================================--

local PlayerMods = { GodMode = false }

local function applyGodMode()
    if not PlayerMods.GodMode then return end
    local char = Player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if hum.Health < hum.MaxHealth then pcall(function() hum.Health = hum.MaxHealth end) end
    local state = hum:GetState()
    if state == Enum.HumanoidStateType.Dead or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Ragdoll then
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
    end
end

task.spawn(function() while true do task.wait(0.1) applyGodMode() end end)

--========================================================--
-- AUTO WIGGLE
--========================================================--

local AutoWiggle = { Enabled = false, WiggleSpam = 5 }
local function AutoWiggleFunction()
    if not AutoWiggle.Enabled then return end
    local char = Player.Character
    if not char then return end
    local carried = (char:FindFirstChild("IsCarried") and char.IsCarried.Value) or (char:FindFirstChild("IsCarrying") and char.IsCarrying.Value)
    if not carried then return end
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then return end
    local carry = remotes:FindFirstChild("Carry")
    if not carry then return end
    local event = carry:FindFirstChild("SelfUnHookEvent")
    if not event then return end
    for i = 1, AutoWiggle.WiggleSpam do event:FireServer() end
end
task.spawn(function() while true do task.wait(0.1) AutoWiggleFunction() end end)

--========================================================--
-- AUTO FLEE KILLER (SYSTEM ASLI)
--========================================================--

local AutoFlee = { Enabled = false, DetectDistance = 50, Cooldown = 0.1 }
local LastFlee = 0
local FleeButtonGui = nil

local function GetNearestKiller()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local closest, shortest = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Team and plr.Team.Name == "Killer" and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then local dist = (hrp.Position - root.Position).Magnitude if dist < shortest then shortest = dist closest = hrp end end
        end
    end
    return closest, shortest
end

local function GetFarthestGeneratorPoint(killerRoot)
    if not killerRoot then return nil end
    local bestPoint, farthestDistance = nil, 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.match(obj.Name, "^GeneratorPoint%d+$") then
            local dist = (obj.Position - killerRoot.Position).Magnitude
            if dist > farthestDistance then farthestDistance = dist bestPoint = obj end
        end
    end
    return bestPoint
end

task.spawn(function()
    while task.wait(0.2) do
        if not AutoFlee.Enabled then continue end
        local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        local killerRoot, distance = GetNearestKiller()
        if killerRoot and distance <= AutoFlee.DetectDistance and tick() - LastFlee > AutoFlee.Cooldown then
            local point = GetFarthestGeneratorPoint(killerRoot)
            if point then LastFlee = tick() root.CFrame = point.CFrame + Vector3.new(0, 5, 0) end
        end
    end
end)

-- Flee Button (ON/OFF) - Warna sama kayak button lain
local function createFleeButton()
    if FleeButtonGui then FleeButtonGui:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "FleeButtonGui"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = game:GetService("CoreGui")

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 160, 0, 40)
    btn.Position = UDim2.new(0.35, 0, 0.85, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = 0.3
    btn.Text = "AUTO FLEE : OFF"
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(150, 150, 150)
    stroke.Transparency = 0
    stroke.Parent = btn

    local function updateText()
        if AutoFlee.Enabled then
            btn.Text = "AUTO FLEE : ON"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            stroke.Color = Color3.fromRGB(255, 255, 255)
        else
            btn.Text = "AUTO FLEE : OFF"
            btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            stroke.Color = Color3.fromRGB(150, 150, 150)
        end
    end

    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    local moved = false

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragInput = input
            dragStart = input.Position
            startPos = btn.Position
        end
    end)

    btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging or input ~= dragInput then return end
        local delta = input.Position - dragStart
        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then moved = true end
        btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging and not moved then
                AutoFlee.Enabled = not AutoFlee.Enabled
                updateText()
            end
            dragging = false
        end
    end)

    updateText()
    FleeButtonGui = gui
end

local function removeFleeButton()
    if FleeButtonGui then
        FleeButtonGui:Destroy()
        FleeButtonGui = nil
    end
end

--========================================================--
-- AUTO CROUCH DODGE (ANTI SLASH) - FIXED
--========================================================--

local AutoCrouchDodge = { Enabled = false, DodgeRange = 40 }
local CrouchButton = nil
local LastCrouchTime = 0
local CROUCH_COOLDOWN = 0.5

local function GetCrouchButton()
    if CrouchButton and CrouchButton.Parent then return CrouchButton end
    local survivorMob = PlayerGui:FindFirstChild("Survivor-mob")
    if not survivorMob then return nil end
    local controls = survivorMob:FindFirstChild("Controls")
    if not controls then return nil end
    CrouchButton = controls:FindFirstChild("Crouch")
    return CrouchButton
end

local function TriggerCrouch()
    local btn = GetCrouchButton()
    local now = tick()
    if now - LastCrouchTime < CROUCH_COOLDOWN then return false end
    LastCrouchTime = now
    
    if btn then
        -- Coba semua metode trigger
        pcall(function() btn:Activate() end)
        
        if typeof(firesignal) == "function" then
            pcall(function() firesignal(btn.MouseButton1Down) end)
            pcall(function() firesignal(btn.MouseButton1Click) end)
            pcall(function() firesignal(btn.Activated) end)
        elseif typeof(getconnections) == "function" then
            for _, conn in ipairs(getconnections(btn.MouseButton1Down)) do
                if conn.Function then pcall(conn.Function) end
            end
            for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do
                if conn.Function then pcall(conn.Function) end
            end
            for _, conn in ipairs(getconnections(btn.Activated)) do
                if conn.Function then pcall(conn.Function) end
            end
        end
    else
        -- Fallback keyboard C
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.C, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, game)
        end)
    end
    
    return true
end

local hookedDodgeKillers = {}

local function hookKillerForDodge(char)
    if hookedDodgeKillers[char] then return end
    hookedDodgeKillers[char] = true
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then return end
    
    animator.AnimationPlayed:Connect(function(track)
        if not AutoCrouchDodge.Enabled then return end
        
        local anim = track.Animation
        if not anim then return end
        
        local animId = anim.AnimationId:match("%d+")
        if not animId then return end
        
        if animId == "80411309607666" then
            local myChar = Player.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local killerRoot = char:FindFirstChild("HumanoidRootPart")
            
            if myRoot and killerRoot then
                local distance = (killerRoot.Position - myRoot.Position).Magnitude
                
                if distance <= AutoCrouchDodge.DodgeRange then
                    task.spawn(function()
                        TriggerCrouch()
                    end)
                end
            end
        end
    end)
end

local function scanDodgeKillers()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Team and p.Team.Name == "Killer" then
            hookKillerForDodge(p.Character)
        end
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        if AutoCrouchDodge.Enabled then
            scanDodgeKillers()
            GetCrouchButton()
        end
    end
end)

Player.CharacterAdded:Connect(function()
    CrouchButton = nil
    task.wait(1)
    GetCrouchButton()
end)

Workspace.DescendantRemoving:Connect(function(obj)
    if obj:IsA("Model") and hookedDodgeKillers[obj] then
        hookedDodgeKillers[obj] = nil
    end
end)

--========================================================--
-- AUTO PALLET DROPDOWN (FIXED)
--========================================================--

local PalletDropdown = { Enabled = false, LastDropdown = 0, Cooldown = 6.5, PalletRange = 6, KillerRange = 11 }

task.spawn(function()
    while true do
        task.wait(0.1)
        if not PalletDropdown.Enabled then continue end
        local char = Player.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        if tick() - PalletDropdown.LastDropdown < PalletDropdown.Cooldown then continue end

        -- Cari pallet terdekat (Model ATAU BasePart)
        local nearPallet = false
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then
                if obj.Name == "Pallet" or obj.Name == "Palletwrong" or string.find(obj.Name, "Pallet") then
                    local pos = obj:GetPivot().Position
                    if (pos - root.Position).Magnitude <= PalletDropdown.PalletRange then
                        nearPallet = true
                        break
                    end
                end
            elseif obj:IsA("BasePart") then
                if obj.Name == "Pallet" or obj.Name == "Palletwrong" then
                    if (obj.Position - root.Position).Magnitude <= PalletDropdown.PalletRange then
                        nearPallet = true
                        break
                    end
                end
            end
        end
        if not nearPallet then continue end

        -- Cari killer dalam jarak
        local nearKiller = false
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Player and plr.Team and plr.Team.Name == "Killer" and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - root.Position).Magnitude <= PalletDropdown.KillerRange then
                    nearKiller = true
                    break
                end
            end
        end
        if not nearKiller then continue end

        PalletDropdown.LastDropdown = tick()

        -- Trigger action button
        local survivorMob = PlayerGui:FindFirstChild("Survivor-mob")
        if survivorMob then
            local controls = survivorMob:FindFirstChild("Controls")
            if controls then
                local actionBtn = controls:FindFirstChild("action")
                if actionBtn then
                    -- Coba beberapa metode
                    pcall(function()
                        if actionBtn:IsA("GuiButton") then
                            actionBtn:Activate()
                        end
                    end)
                    if typeof(firesignal) == "function" then
                        pcall(function()
                            firesignal(actionBtn.MouseButton1Down)
                            firesignal(actionBtn.Activated)
                        end)
                    end
                else
                    -- Fallback keyboard
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    end)
                end
            end
        end
    end
end)

--========================================================--
-- AUTO WINDOWS VAULT (SAFE + WORK)
--========================================================--

local VaultWindows = { Enabled = false, LastVault = 0, Cooldown = 1, Range = 6 }

task.spawn(function()
    while task.wait(0.1) do
        if not VaultWindows.Enabled then continue end
        local char = Player.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        if tick() - VaultWindows.LastVault < VaultWindows.Cooldown then continue end
        
        -- Deteksi window di sekitar
        local foundWindow = false
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local objName = obj.Name
            local isWindow = false
            
            if obj:IsA("Model") then
                isWindow = (objName == "Window" or objName == "WindowBoard" or string.find(objName, "Window") or string.find(objName, "window"))
            elseif obj:IsA("BasePart") then
                isWindow = (objName == "Window" or string.find(objName, "Window") or string.find(objName, "window"))
            end
            
            if isWindow then
                local objPos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                if (objPos - root.Position).Magnitude <= VaultWindows.Range then
                    foundWindow = true
                    break
                end
            end
        end
        
        if not foundWindow then continue end
        
        VaultWindows.LastVault = tick()
        
        -- Trigger: cari tombol action atau spam keyboard
        local pressed = false
        
        -- Method 1: Tombol UI
        local sm = PlayerGui:FindFirstChild("Survivor-mob")
        if sm then
            local ct = sm:FindFirstChild("Controls")
            if ct then
                local btn = ct:FindFirstChild("action") or ct:FindFirstChild("Action") or ct:FindFirstChild("Interact")
                if btn then
                    pcall(function() btn:Activate() end)
                    if typeof(firesignal) == "function" then
                        pcall(function()
                            firesignal(btn.MouseButton1Down)
                            firesignal(btn.MouseButton1Click)
                            firesignal(btn.Activated)
                        end)
                    end
                    pressed = true
                end
            end
        end
        
        -- Method 2: Keyboard E kalau tombol nggak ketemu
        if not pressed then
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end)
        end
    end
end)

--========================================================--
-- MOONWALK SYSTEM (FALLENS 100% EXACT)
--========================================================--

local Moonwalk = { Enabled = false, ShowButton = false, SpamSpeed = 30, Intensity = 35, SlowSpeed = 13, UseSlow = true }
local MoonwalkConnection = nil
local MoonwalkButton = nil
local ParryActive = false

local function isDowned()
    local char = Player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    return hum.Health <= 0 or hum.Health < 2 or char:GetAttribute("Downed") == true or char:GetAttribute("IsDown") == true or char:GetAttribute("Knocked") == true
end

local function startMoonwalk()
    if MoonwalkConnection then MoonwalkConnection:Disconnect() MoonwalkConnection = nil end
    MoonwalkConnection = RunService.RenderStepped:Connect(function()
        if not Moonwalk.Enabled or ParryActive or isDowned() then
            local char = Player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed == Moonwalk.SlowSpeed then hum.WalkSpeed = 16 end
            return
        end
        local char = Player.Character
        if not char or not char.Parent then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local cam = workspace.CurrentCamera
        if humanoid and hrp and cam then
            if Moonwalk.UseSlow and humanoid.WalkSpeed ~= Moonwalk.SlowSpeed then humanoid.WalkSpeed = Moonwalk.SlowSpeed end
            local look = cam.CFrame.LookVector
            local flatLook = Vector3.new(look.X, 0, look.Z)
            if flatLook.Magnitude > 0 then
                flatLook = flatLook.Unit
                local baseCF = CFrame.new(hrp.Position, hrp.Position + flatLook)
                local angle = math.sin(tick() * Moonwalk.SpamSpeed) * Moonwalk.Intensity
                hrp.CFrame = baseCF * CFrame.Angles(0, math.rad(angle), 0)
                humanoid:Move(Vector3.new(0, 0, 1), true)
            end
        end
    end)
end

local function createMoonwalkButton()
    if not PlayerGui or not PlayerGui.Parent then return end
    if MoonwalkButton then MoonwalkButton:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MoonwalkGui"
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("CoreGui")

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 140, 0, 40)
    btn.Position = UDim2.new(0.65, 0, 0.75, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = 0.3
    btn.Text = "MOONWALK : OFF"
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = gui

    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 10) corner.Parent = btn
    local stroke = Instance.new("UIStroke") stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border stroke.Thickness = 1.5 stroke.Color = Color3.fromRGB(180, 50, 255) stroke.Transparency = 0 stroke.Parent = btn

    local function updateText()
        if Moonwalk.Enabled then
            btn.Text = "MOONWALK : ON"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            stroke.Color = Color3.fromRGB(255, 255, 255)
        else
            btn.Text = "MOONWALK : OFF"
            btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            stroke.Color = Color3.fromRGB(150, 150, 150)
        end
    end

    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    local moved = false

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragInput = input
            dragStart = input.Position
            startPos = btn.Position
        end
    end)

    btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging or input ~= dragInput then return end
        local delta = input.Position - dragStart
        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then moved = true end
        btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging and not moved then
                Moonwalk.Enabled = not Moonwalk.Enabled
                local char = Player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if Moonwalk.Enabled then
                    if not MoonwalkConnection then startMoonwalk() end
                else
                    if hum then hum.WalkSpeed = 16 end
                end
                updateText()
            end
            dragging = false
        end
    end)

    MoonwalkButton = gui
end
local function removeMoonwalkButton() if MoonwalkButton then MoonwalkButton:Destroy() MoonwalkButton = nil end end

--========================================================--
-- SILENT AIM (TOF) - UNIVERSAL + LASER TRACER
--========================================================--

local SILENT_AIM_ENABLED = false
local SHOW_TRACER = false
local KILLER_MARKER_NAME = "Lookscriptkiller"
local CAMERA = workspace.CurrentCamera
local FireRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Items"):WaitForChild("Twist of Fate"):WaitForChild("Fire")
local isShooting = false

local function GetCharacter() return Player.Character end
local function GetEquippedGun(rightArm)
    for _, child in ipairs(rightArm:GetChildren()) do
        if (child:IsA("Model") or child:IsA("BasePart")) and not string.find(child.Name, "Weld") and not string.find(child.Name, "Grip") then return child end
    end
    return rightArm:FindFirstChildWhichIsA("Model")
end
local function GetKillerBody(character)
    if not character then return nil end
    return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("LowerTorso") or character:FindFirstChild("HumanoidRootPart")
end
local function GetKiller()
    local myChar = GetCharacter() local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    local nearestBody, nearestDistance = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player then
            local char = player.Character
            if char and char:FindFirstChild(KILLER_MARKER_NAME, true) then
                local body = GetKillerBody(char)
                if body then local distance = (body.Position - myHRP.Position).Magnitude if distance < nearestDistance then nearestDistance = distance nearestBody = body end end
            end
        end
    end
    return nearestBody
end

local tracerStart = Instance.new("Part")
tracerStart.Size = Vector3.new(0.1, 0.1, 0.1) tracerStart.Transparency = 1 tracerStart.Anchored = true tracerStart.CanCollide = false tracerStart.Parent = workspace
local tracerEnd = tracerStart:Clone() tracerEnd.Parent = workspace
local att0 = Instance.new("Attachment", tracerStart) local att1 = Instance.new("Attachment", tracerEnd)
local tracerBeam = Instance.new("Beam")
tracerBeam.Attachment0 = att0 tracerBeam.Attachment1 = att1 tracerBeam.Color = ColorSequence.new(Color3.fromRGB(170, 170, 170)) tracerBeam.Width0 = 0.15 tracerBeam.Width1 = 0.15 tracerBeam.LightEmission = 1 tracerBeam.LightInfluence = 0 tracerBeam.FaceCamera = true tracerBeam.Enabled = false tracerBeam.Parent = tracerStart

RunService.Heartbeat:Connect(function()
    local myChar = GetCharacter() local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart") local targetBody = GetKiller()
    if isShooting and SHOW_TRACER and SILENT_AIM_ENABLED and myHRP and targetBody then
        local twist = myChar:FindFirstChild("Twist of Fate") local rightArm = twist and twist:FindFirstChild("Right Arm") local gun = rightArm and GetEquippedGun(rightArm)
        tracerStart.Position = (gun and gun:GetPivot().Position) or (myHRP.Position + Vector3.new(0, 1, 0))
        tracerEnd.Position = targetBody.Position tracerBeam.Enabled = true
    else tracerBeam.Enabled = false end
end)

local function Shoot()
    if not SILENT_AIM_ENABLED then return end
    local char = GetCharacter() if not char then return end
    local twist = char:FindFirstChild("Twist of Fate") if not twist then return end
    local rightArm = twist:FindFirstChild("Right Arm") if not rightArm then return end
    local gun = GetEquippedGun(rightArm) if not gun then return end
    local myHRP = char:FindFirstChild("HumanoidRootPart") local direction = CAMERA.CFrame.LookVector
    if SILENT_AIM_ENABLED and myHRP then
        local targetBody = GetKiller()
        if targetBody then local rawDirection = targetBody.Position - myHRP.Position if rawDirection.Magnitude > 0.001 then direction = rawDirection.Unit end end
    end
    FireRemote:FireServer(gun, direction)
end

local connectedShootButtons = {}
local function ConnectShootButton(button)
    if not button or connectedShootButtons[button] then return end
    connectedShootButtons[button] = true
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then isShooting = true Shoot() end
    end)
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then isShooting = false end
    end)
end
local function ScanForShootButton()
    local survivorMob = PlayerGui:FindFirstChild("Survivor-mob")
    if not survivorMob then return end
    for _, object in ipairs(survivorMob:GetDescendants()) do
        if object:IsA("ImageButton") and object.Name == "Gui-mob" then ConnectShootButton(object) end
    end
end
ScanForShootButton()
PlayerGui.DescendantAdded:Connect(function(object) if object:IsA("ImageButton") and object.Name == "Gui-mob" then ConnectShootButton(object) end end)
UserInputService.InputBegan:Connect(function(input, processed) if processed then return end if input.UserInputType == Enum.UserInputType.MouseButton1 then isShooting = true Shoot() end end)
UserInputService.InputEnded:Connect(function(input, processed) if input.UserInputType == Enum.UserInputType.MouseButton1 then isShooting = false end end)
Player.CharacterAdded:Connect(function() task.wait(0.5) ScanForShootButton() tracerBeam.Enabled = false isShooting = false end)

--========================================================--
-- AUTO SKILLCHECK SYSTEM (VD AUTO GENERATOR v3)
--========================================================--

local AutoSkillcheck = { Enabled = false, Mode = "SUCCESS" }
local SUCCESS_MIN, SUCCESS_MAX = 102, 116
local NEUTRAL_MIN, NEUTRAL_MAX = 116, 159
local TriggerDelay, LastTrigger = 0.035, 0
local Busy, ScourgeActive, ScourgeRound = false, false, 0
local KingScourgeStart, KingScourgeEnd

pcall(function()
    local KillerPerks = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("KillerPerks")
    local KingScourge = KillerPerks:WaitForChild("kingscourge")
    KingScourgeStart = KingScourge:WaitForChild("KingScourgeStart") KingScourgeEnd = KingScourge:WaitForChild("KingScourgeEnd")
end)

local Check, Line, Goal, Action
local function RefreshReferences()
    pcall(function()
        local SkillGui = PlayerGui:FindFirstChild("SkillCheckPromptGui")
        if SkillGui then Check = SkillGui:FindFirstChild("Check") if Check then Line = Check:FindFirstChild("Line") Goal = Check:FindFirstChild("Goal") end end
        local Survivor = PlayerGui:FindFirstChild("Survivor-mob")
        if Survivor then local Controls = Survivor:FindFirstChild("Controls") if Controls then Action = Controls:FindFirstChild("action") end end
    end)
end
RefreshReferences() task.spawn(function() while true do RefreshReferences() task.wait(0.5) end end)

local function TriggerAction()
    if not Action then RefreshReferences() end if not Action then return false end
    local Now = os.clock() if Now - LastTrigger < TriggerDelay then return false end LastTrigger = Now
    pcall(function() if Action:IsA("GuiButton") then Action:Activate() end end)
    if typeof(firesignal) == "function" then pcall(function() firesignal(Action.MouseButton1Down) end) end
    return true
end
local function GetAngle() if not Line or not Goal then return nil end return tonumber(Line.Rotation) or 0, tonumber(Goal.Rotation) or 0 end
local function IsSuccess() local lr, gr = GetAngle() if not lr then return false end return lr >= gr + SUCCESS_MIN and lr <= gr + SUCCESS_MAX end
local function IsNeutral() local lr, gr = GetAngle() if not lr then return false end return lr > gr + NEUTRAL_MIN and lr <= gr + NEUTRAL_MAX end
local function InstantNormal()
    if not Check or not Line or not Goal then RefreshReferences() end
    if not Check or not Line or not Goal then return end if not Check.Visible then return end
    Line.Rotation = (tonumber(Goal.Rotation) or 0) + 109 TriggerAction()
end
local function InstantScourge()
    if not AutoSkillcheck.Enabled or not ScourgeActive then return end
    if not Line or not Goal then RefreshReferences() end if not Line or not Goal then return end
    Line.Rotation = (tonumber(Goal.Rotation) or 0) + 109 TriggerAction() ScourgeRound += 1
end
if KingScourgeStart then KingScourgeStart.OnClientEvent:Connect(function() if not AutoSkillcheck.Enabled then return end ScourgeActive = true ScourgeRound = 0 Busy = false task.defer(function() if not AutoSkillcheck.Enabled then return end if AutoSkillcheck.Mode == "INSTANT" then InstantScourge() end end) end) end
if KingScourgeEnd then KingScourgeEnd.OnClientEvent:Connect(function() ScourgeActive = false Busy = false end) end

local PreviousVisible = false
RunService.RenderStepped:Connect(function()
    if not AutoSkillcheck.Enabled then PreviousVisible = false return end
    if not Check then RefreshReferences() end if not Check then return end
    local Visible = Check.Visible
    if Visible and not PreviousVisible then Busy = false if not ScourgeActive and AutoSkillcheck.Mode == "INSTANT" then InstantNormal() end end
    PreviousVisible = Visible
    if Visible and not ScourgeActive and not Busy then
        local ShouldTrigger = false
        if AutoSkillcheck.Mode == "SUCCESS" then ShouldTrigger = IsSuccess() elseif AutoSkillcheck.Mode == "NEUTRAL" then ShouldTrigger = IsNeutral() end
        if ShouldTrigger then Busy = true TriggerAction() task.delay(0.07, function() Busy = false end) end
    end
    if ScourgeActive and Visible then
        if AutoSkillcheck.Mode == "SUCCESS" and not Busy and IsSuccess() then Busy = true TriggerAction() task.delay(0.06, function() Busy = false end)
        elseif AutoSkillcheck.Mode == "NEUTRAL" and not Busy and IsNeutral() then Busy = true TriggerAction() task.delay(0.06, function() Busy = false end)
        elseif AutoSkillcheck.Mode == "INSTANT" then local d = math.abs((tonumber(Line.Rotation) or 0) - (tonumber(Goal.Rotation) or 0)) if d > 130 then Busy = false end end
    end
end)

task.spawn(function()
    local LastGoalRotation = nil
    while true do
        if AutoSkillcheck.Enabled and ScourgeActive and AutoSkillcheck.Mode == "INSTANT" then
            RefreshReferences()
            if Check and Check.Visible and Goal and Line then
                local CurrentGoal = tonumber(Goal.Rotation) or 0
                if LastGoalRotation == nil then LastGoalRotation = CurrentGoal InstantScourge()
                elseif math.abs(CurrentGoal - LastGoalRotation) > 1 then LastGoalRotation = CurrentGoal InstantScourge() end
            end
        else LastGoalRotation = nil end
        task.wait(0.005)
    end
end)

Player.CharacterAdded:Connect(function() Busy = false ScourgeActive = false PreviousVisible = false task.wait(1) RefreshReferences() end)

--========================================================--
-- AUTO PARRY V2 (PURPLE THEME)
--========================================================--

local AutoParryV2 = { Enabled = false, VisualEnabled = false, ParryRange = 15, Cooldown = 0.85 }
local ParryV2State = { LastParryTime = 0, Killers = {} }
local AttackIDs = {
    ["139369275981139"] = true, ["121216847022485"] = true, ["78935059863801"] = true,
    ["74968262036854"] = true, ["82666958311998"] = true, ["78432063483146"] = true,
    ["132817836308238"] = true, ["111920872708571"] = true, ["138720291317243"] = true,
    ["130593238885843"] = true, ["106871536134254"] = true, ["109402730355822"] = true,
}

local RingVisual = Instance.new("Part")
RingVisual.Name = "ParryRangeRing" RingVisual.Anchored = true RingVisual.CanCollide = false RingVisual.Massless = true RingVisual.CastShadow = false RingVisual.Transparency = 1 RingVisual.Parent = Workspace RingVisual.CFrame = CFrame.new(0, -9999, 0)
local SurfaceGui = Instance.new("SurfaceGui")
SurfaceGui.Face = Enum.NormalId.Top SurfaceGui.LightInfluence = 0 SurfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud SurfaceGui.PixelsPerStud = 30 SurfaceGui.AlwaysOnTop = false SurfaceGui.Parent = RingVisual
local RingFrame = Instance.new("Frame") RingFrame.Size = UDim2.new(1, 0, 1, 0) RingFrame.BackgroundTransparency = 1 RingFrame.Parent = SurfaceGui
local UICorner = Instance.new("UICorner") UICorner.CornerRadius = UDim.new(0.5, 0) UICorner.Parent = RingFrame
local UIStroke = Instance.new("UIStroke") UIStroke.Thickness = 6 UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border UIStroke.Color = Color3.fromRGB(255, 255, 255) UIStroke.Parent = RingFrame
local UIGradient = Instance.new("UIGradient")
local PurpleColor = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 50, 220)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 100, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 30, 180)) })
local VioletColor = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 50, 255)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(230, 150, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 30, 255)) })
UIGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 0.7), NumberSequenceKeypoint.new(1, 0) })
UIGradient.Color = PurpleColor UIGradient.Parent = UIStroke

local function CheckForKiller(obj)
    if obj.Name == "Lookscriptkiller" then
        local char = obj:FindFirstAncestorOfClass("Model")
        if char and char:FindFirstChild("Humanoid") then ParryV2State.Killers[char] = true end
    end
end
for _, obj in ipairs(Workspace:GetDescendants()) do CheckForKiller(obj) end
Workspace.DescendantAdded:Connect(CheckForKiller)
Workspace.DescendantRemoving:Connect(function(obj) if obj:IsA("Model") and ParryV2State.Killers[obj] then ParryV2State.Killers[obj] = nil end end)

local function TriggerOriginalParry()
    local pg = Player:FindFirstChild("PlayerGui") if not pg then return end
    local survivorMob = pg:FindFirstChild("Survivor-mob")
    if survivorMob then
        local controls = survivorMob:FindFirstChild("Controls")
        if controls then
            local btnMob = controls:FindFirstChild("Gui-mob")
            if btnMob then
                if type(firesignal) == "function" then firesignal(btnMob.MouseButton1Down)
                elseif type(getconnections) == "function" then for _, conn in ipairs(getconnections(btnMob.MouseButton1Down)) do if conn.Function then conn.Function() end end end
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    local character = Player.Character local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart or (not AutoParryV2.VisualEnabled and not AutoParryV2.Enabled) then RingVisual.CFrame = CFrame.new(0, -9999, 0) return end
    if AutoParryV2.VisualEnabled then
        RingVisual.Size = Vector3.new(AutoParryV2.ParryRange * 2, 0.05, AutoParryV2.ParryRange * 2)
        RingVisual.CFrame = CFrame.new(rootPart.Position - Vector3.new(0, 2.9, 0))
        UIGradient.Rotation = (tick() * 120) % 360
    else RingVisual.CFrame = CFrame.new(0, -9999, 0) end
    local incomingAttack = false
    for killerChar, _ in pairs(ParryV2State.Killers) do
        if killerChar.Parent and killerChar:FindFirstChild("HumanoidRootPart") and killerChar:FindFirstChild("Humanoid") then
            local killerRoot = killerChar.HumanoidRootPart local distance = (rootPart.Position - killerRoot.Position).Magnitude
            if distance <= AutoParryV2.ParryRange then
                local animator = killerChar.Humanoid:FindFirstChild("Animator")
                if animator then for _, track in ipairs(animator:GetPlayingAnimationTracks()) do local animId = string.match(track.Animation.AnimationId, "%d+") if AttackIDs[animId] then incomingAttack = true break end end end
            end
        else ParryV2State.Killers[killerChar] = nil end
    end
    if incomingAttack then
        if AutoParryV2.VisualEnabled then UIGradient.Color = VioletColor end
        if AutoParryV2.Enabled and (tick() - ParryV2State.LastParryTime) >= AutoParryV2.Cooldown then ParryV2State.LastParryTime = tick() TriggerOriginalParry() end
    else if AutoParryV2.VisualEnabled then UIGradient.Color = PurpleColor end end
end)

--========================================================--
-- AUTO PARRY V1
--========================================================--

local AutoParry = { Enabled = false, ParryDistance = 15, FaceSensitivity = 0.7 }
local ParryRangeVisual = { Enabled = false, Color = Color3.fromRGB(150, 150, 150), Transparency = 0.1 }
local Visuals = { Circle = nil }
local lastParry = 0
local PARRY_DEBOUNCE = 0.2
local KillerAnims = {
    ["rbxassetid://105374834496520"] = true, ["rbxassetid://113255068724446"] = true, ["rbxassetid://118907603246885"] = true,
    ["rbxassetid://129784271201071"] = true, ["rbxassetid://117042998468241"] = true, ["rbxassetid://122812055447896"] = true,
    ["rbxassetid://78935059863801"] = true, ["rbxassetid://74968262036854"] = true, ["rbxassetid://78432063483146"] = true,
    ["rbxassetid://132817836308238"] = true, ["rbxassetid://133963973694098"] = true, ["rbxassetid://111920872708571"] = true,
    ["rbxassetid://80411309607666"] = true, ["rbxassetid://98163597193511"] = true, ["rbxassetid://82666958311998"] = true,
    ["rbxassetid://110355011987939"] = true, ["rbxassetid://139369275981139"] = true, ["rbxassetid://135002183282873"] = true,
    ["rbxassetid://121216847022485"] = true, ["rbxassetid://130593238885843"] = true, ["rbxassetid://117070354890871"] = true,
    ["rbxassetid://106871536134254"] = true, ["rbxassetid://138720291317243"] = true
}
local hookedKillers = {}
local function getRoot() return Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") end
local function TriggerParry()
    local pg = Player:FindFirstChild("PlayerGui") if not pg then return end
    local survivorMob = pg:FindFirstChild("Survivor-mob") if not survivorMob then return end
    local controls = survivorMob:FindFirstChild("Controls") if not controls then return end
    local btnMob = controls:FindFirstChild("Gui-mob") if not btnMob then return end
    if typeof(firesignal) == "function" then pcall(function() firesignal(btnMob.MouseButton1Down) end)
    elseif typeof(getconnections) == "function" then for _, conn in ipairs(getconnections(btnMob.MouseButton1Down)) do if conn.Function then conn.Function() end end end
end
local function doParry()
    local now = tick() if now - lastParry < PARRY_DEBOUNCE then return end
    lastParry = now ParryActive = true TriggerParry() task.delay(0.3, function() ParryActive = false end)
end
local function isInParryRange(killerChar)
    local myRoot = getRoot() if not myRoot or not killerChar then return false end
    local enemyRoot = killerChar:FindFirstChild("HumanoidRootPart") if not enemyRoot then return false end
    return (enemyRoot.Position - myRoot.Position).Magnitude <= AutoParry.ParryDistance
end
local function isFacingTarget(targetChar)
    if AutoParry.FaceSensitivity <= -1 then return true end
    local myChar = Player.Character if not myChar then return false end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart") local enemyRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not myRoot or not enemyRoot then return false end
    return enemyRoot.CFrame.LookVector:Dot((myRoot.Position - enemyRoot.Position).Unit) >= AutoParry.FaceSensitivity
end
local function hookKiller(char)
    if hookedKillers[char] then return end hookedKillers[char] = true
    local hum = char:FindFirstChildOfClass("Humanoid") if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator") if not animator then return end
    animator.AnimationPlayed:Connect(function(track)
        if not AutoParry.Enabled then return end
        local anim = track.Animation if not anim then return end
        local id = anim.AnimationId:match("%d+") if not id then return end
        if KillerAnims["rbxassetid://" .. id] then
            if not isInParryRange(char) then return end
            if not isFacingTarget(char) then return end
            doParry()
        end
    end)
end
local function scanKillers() for _, p in pairs(Players:GetPlayers()) do if p ~= Player and p.Character and p.Team and p.Team.Name == "Killer" then hookKiller(p.Character) end end end
task.spawn(function() while true do task.wait(1) if AutoParry.Enabled then scanKillers() end end end)

local function CreateCircle()
    if Visuals.Circle then Visuals.Circle:Destroy() Visuals.Circle = nil end
    local char = Player.Character if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart") if not root then return end
    local folder = Instance.new("Folder") folder.Name = "ParryCircle" folder.Parent = root
    local numSegments = 32 local radius = AutoParry.ParryDistance local yOffset = -3.0
    for i = 1, numSegments do
        local angle1 = (i - 1) / numSegments * math.pi * 2 local angle2 = i / numSegments * math.pi * 2
        local pos1 = Vector3.new(math.cos(angle1) * radius, yOffset, math.sin(angle1) * radius)
        local pos2 = Vector3.new(math.cos(angle2) * radius, yOffset, math.sin(angle2) * radius)
        local att1 = Instance.new("Attachment") att1.Position = pos1 att1.Parent = folder
        local att2 = Instance.new("Attachment") att2.Position = pos2 att2.Parent = folder
        local beam = Instance.new("Beam") beam.Attachment0 = att1 beam.Attachment1 = att2 beam.Color = ColorSequence.new(ParryRangeVisual.Color) beam.Transparency = NumberSequence.new(ParryRangeVisual.Transparency) beam.Width0 = 0.3 beam.Width1 = 0.3 beam.FaceCamera = true beam.Parent = folder
    end
    Visuals.Circle = folder
end
local function updateParryCircle()
    if not ParryRangeVisual.Enabled then if Visuals.Circle then Visuals.Circle:Destroy() Visuals.Circle = nil end return end
    if not Visuals.Circle then CreateCircle() end
end
task.spawn(function() while true do task.wait(0.5) if AutoParry.Enabled then updateParryCircle() end end end)

--========================================================--
-- PARRY V1 BUTTON
--========================================================--

local ParryV1Btn = { GuiInstance = nil, Active = false }

local function createParryV1Button()
    if ParryV1Btn.GuiInstance then ParryV1Btn.GuiInstance:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "ParryV1Gui"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = game:GetService("CoreGui")

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 140, 0, 40)
    btn.Position = UDim2.new(0.3, 0, 0.75, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = 0.3
    btn.Text = "PARRY : OFF"
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = gui

    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 10) corner.Parent = btn
    local stroke = Instance.new("UIStroke") stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border stroke.Thickness = 1.5 stroke.Color = Color3.fromRGB(150, 150, 150) stroke.Transparency = 0 stroke.Parent = btn

    local function updateText()
        if ParryV1Btn.Active then
            btn.Text = "PARRY : ON"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            stroke.Color = Color3.fromRGB(255, 255, 255)
        else
            btn.Text = "PARRY : OFF"
            btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            stroke.Color = Color3.fromRGB(150, 150, 150)
        end
    end

    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    local moved = false

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragInput = input
            dragStart = input.Position
            startPos = btn.Position
        end
    end)

    btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging or input ~= dragInput then return end
        local delta = input.Position - dragStart
        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then moved = true end
        btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging and not moved then
                ParryV1Btn.Active = not ParryV1Btn.Active
                AutoParry.Enabled = ParryV1Btn.Active
                if ParryV1Btn.Active then
                    ParryRangeVisual.Enabled = true
                    CreateCircle()
                    scanKillers()
                else
                    ParryRangeVisual.Enabled = false
                    if Visuals.Circle then Visuals.Circle:Destroy() Visuals.Circle = nil end
                end
                updateText()
            end
            dragging = false
        end
    end)

    ParryV1Btn.GuiInstance = gui
end

local function removeParryV1Button()
    if ParryV1Btn.GuiInstance then ParryV1Btn.GuiInstance:Destroy() ParryV1Btn.GuiInstance = nil end
    ParryV1Btn.Active = false
end

--========================================================--
-- PARRY V2 BUTTON
--========================================================--

local ParryV2Btn = { GuiInstance = nil, Active = false }

local function createParryV2Button()
    if ParryV2Btn.GuiInstance then ParryV2Btn.GuiInstance:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "ParryV2Gui"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = game:GetService("CoreGui")

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 140, 0, 40)
    btn.Position = UDim2.new(0.3, 0, 0.65, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = 0.3
    btn.Text = "PARRY V2 : OFF"
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = gui

    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 10) corner.Parent = btn
    local stroke = Instance.new("UIStroke") stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border stroke.Thickness = 1.5 stroke.Color = Color3.fromRGB(150, 150, 150) stroke.Transparency = 0 stroke.Parent = btn

    local function updateText()
        if ParryV2Btn.Active then
            btn.Text = "PARRY V2 : ON"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            stroke.Color = Color3.fromRGB(255, 255, 255)
        else
            btn.Text = "PARRY V2 : OFF"
            btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            stroke.Color = Color3.fromRGB(150, 150, 150)
        end
    end

    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    local moved = false

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragInput = input
            dragStart = input.Position
            startPos = btn.Position
        end
    end)

    btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging or input ~= dragInput then return end
        local delta = input.Position - dragStart
        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then moved = true end
        btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging and not moved then
                ParryV2Btn.Active = not ParryV2Btn.Active
                
                if ParryV2Btn.Active then
                    AutoParryV2.Enabled = true
                    AutoParryV2.VisualEnabled = true
                else
                    AutoParryV2.Enabled = false
                    AutoParryV2.VisualEnabled = false
                    RingVisual.CFrame = CFrame.new(0, -9999, 0)
                end
                
                updateText()
            end
            dragging = false
        end
    end)

    ParryV2Btn.GuiInstance = gui
end

local function removeParryV2Button()
    if ParryV2Btn.GuiInstance then ParryV2Btn.GuiInstance:Destroy() ParryV2Btn.GuiInstance = nil end
    ParryV2Btn.Active = false
end

--========================================================--
-- FAST VAULT
--========================================================--

local FastVault = { Enabled = false, Speed = 1.2, ReplaceMap = { ["rbxassetid://83873880822918"] = "rbxassetid://136962284480779" } }
local VaultTracks = {}
local function normalizeId(id) local num = tostring(id):match("%d+") return num and ("rbxassetid://" .. num) end
local function hookVault(char)
    local hum = char:FindFirstChildOfClass("Humanoid") if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator") if not animator then return end
    animator.AnimationPlayed:Connect(function(track)
        if not FastVault.Enabled then return end
        local anim = track.Animation if not anim or not anim.AnimationId then return end
        local id = normalizeId(anim.AnimationId) if not id then return end
        local replaceId = FastVault.ReplaceMap[id] if not replaceId then return end
        if VaultTracks[track] then return end VaultTracks[track] = true
        track:Stop()
        local newAnim = Instance.new("Animation") newAnim.AnimationId = replaceId
        local newTrack = animator:LoadAnimation(newAnim) newTrack.Priority = Enum.AnimationPriority.Action newTrack:Play() newTrack:AdjustSpeed(FastVault.Speed)
        newTrack.Stopped:Connect(function() VaultTracks[track] = nil end)
    end)
end
Player.CharacterAdded:Connect(function(char) task.wait(0.5) hookVault(char) end)
if Player.Character then hookVault(Player.Character) end

--========================================================--
-- AIMLOCK SYSTEM
--========================================================--

local Aimlock = { Enabled = false, Holding = false, TargetMode = "Killer", AimPart = "HumanoidRootPart", FOV = 250, Strength = 1, Predict = true, PredictStrength = 0.12, VisibilityCheck = true }
local AimlockConnection = nil
local CachedSCP = {}
local RayParams = RaycastParams.new() RayParams.FilterType = Enum.RaycastFilterType.Blacklist

local function isVisible(part)
    local cam = workspace.CurrentCamera
    RayParams.FilterDescendantsInstances = {Player.Character}
    local origin = cam.CFrame.Position local direction = (part.Position - origin)
    local result = workspace:Raycast(origin, direction, RayParams)
    if not result then return true end
    return result.Instance:IsDescendantOf(part.Parent)
end

for _, obj in ipairs(Workspace:GetDescendants()) do local name = string.lower(obj.Name) if string.find(name, "scp") then CachedSCP[obj] = true end end
Workspace.DescendantAdded:Connect(function(obj) local name = string.lower(obj.Name) if string.find(name, "scp") then CachedSCP[obj] = true end end)
Workspace.DescendantRemoving:Connect(function(obj) CachedSCP[obj] = nil end)

local function getClosestAimlockTarget()
    local cam = workspace.CurrentCamera local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local closest, shortest = nil, Aimlock.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Team then
            local valid = false
            if Aimlock.TargetMode == "Killer" and p.Team.Name == "Killer" then valid = true
            elseif Aimlock.TargetMode == "Survivor" and p.Team.Name == "Survivors" then valid = true end
            if valid then
                local hrp = p.Character:FindFirstChild(Aimlock.AimPart) local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local pos, visible = cam:WorldToViewportPoint(hrp.Position)
                    if visible then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist < shortest then
                            if Aimlock.VisibilityCheck and not isVisible(hrp) then continue end
                            shortest = dist closest = hrp
                        end
                    end
                end
            end
        end
    end
    if Aimlock.TargetMode == "SCP" then
        for obj in pairs(CachedSCP) do
            if obj and obj.Parent then
                local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                if part then
                    local pos, visible = cam:WorldToViewportPoint(part.Position)
                    if visible then local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude if dist < shortest then shortest = dist closest = part end end
                end
            end
        end
    end
    return closest
end

local function startAimlock()
    if AimlockConnection then return end
    AimlockConnection = RunService.RenderStepped:Connect(function()
        if not Aimlock.Enabled or not Aimlock.Holding then return end
        local cam = workspace.CurrentCamera local target = getClosestAimlockTarget() if not target then return end
        local pos = target.Position
        if Aimlock.Predict then pos = pos + (target.AssemblyLinearVelocity * Aimlock.PredictStrength) end
        local cf = CFrame.new(cam.CFrame.Position, pos) cam.CFrame = cam.CFrame:Lerp(cf, Aimlock.Strength)
    end)
end

UserInputService.InputBegan:Connect(function(input, gp) if gp then return end if input.UserInputType == Enum.UserInputType.MouseButton2 then Aimlock.Holding = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton2 then Aimlock.Holding = false end end)

local CurrentGunButton = nil
local function GetGunAimButton()
    local current = PlayerGui
    for segment in string.gmatch("Survivor-mob.Controls.Gui-mob", "[^%.]+") do current = current and current:FindFirstChild(segment) end
    return current
end
task.spawn(function()
    while true do
        task.wait(1)
        local btn = GetGunAimButton()
        if not btn then CurrentGunButton = nil continue end
        if btn ~= CurrentGunButton then
            CurrentGunButton = btn
            btn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton2 then Aimlock.Holding = true end end)
            btn.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton2 then Aimlock.Holding = false end end)
        end
    end
end)

--========================================================--
-- AIMLOCK ATTACK SYSTEM
--========================================================--

local AttackAim = { Enabled = false, Holding = false, Predict = true, PredictStrength = 0.12, FOV = 250, AimPart = "HumanoidRootPart" }
local AttackAimConnection = nil

local function getClosestAttackTarget()
    local cam = workspace.CurrentCamera local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local closest, shortest = nil, AttackAim.FOV
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Team and p.Team.Name == "Survivors" and p.Character then
            local hrp = p.Character:FindFirstChild(AttackAim.AimPart) local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local pos, visible = cam:WorldToViewportPoint(hrp.Position)
                if visible then local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude if dist < shortest then shortest = dist closest = hrp end end
            end
        end
    end
    return closest
end

local function startAttackAim()
    if AttackAimConnection then return end
    AttackAimConnection = RunService.RenderStepped:Connect(function()
        if not AttackAim.Enabled or not AttackAim.Holding then return end
        local target = getClosestAttackTarget() if not target then return end
        local cam = workspace.CurrentCamera local pos = target.Position
        if AttackAim.Predict then pos = pos + (target.AssemblyLinearVelocity * AttackAim.PredictStrength) end
        cam.CFrame = CFrame.new(cam.CFrame.Position, pos)
    end)
end

UserInputService.InputBegan:Connect(function(input, gp) if gp then return end if input.UserInputType == Enum.UserInputType.MouseButton2 then AttackAim.Holding = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton2 then AttackAim.Holding = false end end)

local CurrentAttackButton = nil
local function GetAttackAimButton()
    local attackPaths = {"Slasher-mob.Controls.attack", "Masked-mob.Controls.attack", "Killer-mob.Controls.attack"}
    for _, path in ipairs(attackPaths) do
        local current = PlayerGui
        for segment in string.gmatch(path, "[^%.]+") do current = current and current:FindFirstChild(segment) end
        if current and current:IsA("GuiObject") then return current end
    end
    return nil
end
task.spawn(function()
    while true do
        task.wait(1)
        local btn = GetAttackAimButton()
        if btn and btn ~= CurrentAttackButton then
            CurrentAttackButton = btn
            btn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch then AttackAim.Holding = true end end)
            btn.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch then AttackAim.Holding = false end end)
        end
    end
end)

--========================================================--
-- KILLER AIMLOCK BUTTON
--========================================================--

local KillerAimlockBtn = { Enabled = false, GuiInstance = nil, AimActive = false, Distance = 115 }
local KillerAimlockConnection = nil

local function getClosestSurvivorForAimlock()
    local cam = workspace.CurrentCamera
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local closest, shortest = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Team and p.Team.Name == "Survivors" and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local myRoot = getRoot()
                if myRoot then
                    local distance = (hrp.Position - myRoot.Position).Magnitude
                    if distance <= KillerAimlockBtn.Distance then
                        local pos, visible = cam:WorldToViewportPoint(hrp.Position)
                        if visible then
                            local screenDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                            if screenDist < shortest then shortest = screenDist closest = hrp end
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function startKillerAimlock()
    if KillerAimlockConnection then return end
    KillerAimlockConnection = RunService.RenderStepped:Connect(function()
        if not KillerAimlockBtn.AimActive then return end
        local cam = workspace.CurrentCamera
        local target = getClosestSurvivorForAimlock()
        if not target then return end
        local pos = target.Position
        local cf = CFrame.new(cam.CFrame.Position, pos)
        cam.CFrame = cam.CFrame:Lerp(cf, 1)
    end)
end

local function createKillerAimlockButton()
    if KillerAimlockBtn.GuiInstance then KillerAimlockBtn.GuiInstance:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "KillerAimlockGui"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = game:GetService("CoreGui")

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 140, 0, 40)
    btn.Position = UDim2.new(0.5, -70, 0.4, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = 0.3
    btn.Text = "AIMLOCK : OFF"
    btn.TextColor3 = Color3.fromRGB(180, 50, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = gui

    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 10) corner.Parent = btn
    local stroke = Instance.new("UIStroke") stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border stroke.Thickness = 1.5 stroke.Color = Color3.fromRGB(180, 50, 255) stroke.Transparency = 0 stroke.Parent = btn

    local function updateText()
        if KillerAimlockBtn.AimActive then
            btn.Text = "AIMLOCK : ON"
            btn.TextColor3 = Color3.fromRGB(140, 50, 220)
            stroke.Color = Color3.fromRGB(140, 50, 220)
        else
            btn.Text = "AIMLOCK : OFF"
            btn.TextColor3 = Color3.fromRGB(180, 50, 255)
            stroke.Color = Color3.fromRGB(180, 50, 255)
        end
    end

    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    local moved = false

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragInput = input
            dragStart = input.Position
            startPos = btn.Position
        end
    end)

    btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging or input ~= dragInput then return end
        local delta = input.Position - dragStart
        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then moved = true end
        btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging and not moved then
                KillerAimlockBtn.AimActive = not KillerAimlockBtn.AimActive
                if KillerAimlockBtn.AimActive then startKillerAimlock() end
                updateText()
            end
            dragging = false
        end
    end)

    KillerAimlockBtn.GuiInstance = gui
end

local function removeKillerAimlockButton()
    if KillerAimlockBtn.GuiInstance then KillerAimlockBtn.GuiInstance:Destroy() KillerAimlockBtn.GuiInstance = nil end
    KillerAimlockBtn.AimActive = false
end

--========================================================--
-- CAMERA ZOOM & FOV
--========================================================--

local CameraZoom = { UnlimitedZoom = false, MaxDistance = 1000, FOVEnabled = false, FOV = 70, DefaultFOV = workspace.CurrentCamera.FieldOfView }
local function applyUnlimitedZoom()
    if CameraZoom.UnlimitedZoom then Player.CameraMaxZoomDistance = CameraZoom.MaxDistance Player.CameraMinZoomDistance = 0
    else Player.CameraMaxZoomDistance = 128 Player.CameraMinZoomDistance = 0.5 end
end
local function applyCameraFOV()
    local cam = workspace.CurrentCamera if not cam then return end
    if CameraZoom.FOVEnabled then cam.FieldOfView = CameraZoom.FOV else cam.FieldOfView = CameraZoom.DefaultFOV end
end
Player.CharacterAdded:Connect(function() task.wait(0.5) applyUnlimitedZoom() applyCameraFOV() end)
RunService.RenderStepped:Connect(function()
    if CameraZoom.FOVEnabled then local cam = workspace.CurrentCamera if cam and cam.FieldOfView ~= CameraZoom.FOV then cam.FieldOfView = CameraZoom.FOV end end
end)

--========================================================--
-- JERK TOOL
--========================================================--

local JerkTool = { Enabled = false, ToolName = "Jerk Off" }
local currentJerkTool = nil
local function createJerkTool()
    if currentJerkTool then currentJerkTool:Destroy() end
    local character = Player.Character if not character then return end
    local humanoid = character:FindFirstChildWhichIsA("Humanoid") local backpack = Player:FindFirstChildWhichIsA("Backpack")
    if not humanoid or not backpack then return end
    local tool = Instance.new("Tool") tool.Name = JerkTool.ToolName tool.ToolTip = "jorking it" tool.RequiresHandle = false tool.Parent = backpack
    currentJerkTool = tool
    local jorkin = false local track = nil
    local function stopTomfoolery() jorkin = false if track then track:Stop() track = nil end end
    tool.Equipped:Connect(function() jorkin = true end) tool.Unequipped:Connect(stopTomfoolery) humanoid.Died:Connect(stopTomfoolery)
    task.spawn(function()
        while task.wait() do
            if not JerkTool.Enabled or not jorkin then if track then track:Stop() end continue end
            local isR15 = humanoid.RigType == Enum.HumanoidRigType.R15
            if not track then local anim = Instance.new("Animation") anim.AnimationId = not isR15 and "rbxassetid://72042024" or "rbxassetid://698251653" track = humanoid:LoadAnimation(anim) end
            track:Play() track:AdjustSpeed(isR15 and 0.7 or 0.65) track.TimePosition = 0.6
            task.wait(0.1) while track and track.TimePosition < (not isR15 and 0.65 or 0.7) do task.wait(0.1) end
            if track then track:Stop() end
        end
    end)
end
Player.CharacterAdded:Connect(function() task.wait(1) if JerkTool.Enabled then createJerkTool() end end)

--========================================================--
-- EMOTE SYSTEM
--========================================================--

local Emote = { Selected = "Mannrobics", Show = false, GuiInstance = nil, LabelRef = nil }
local EmoteList = {"Mannrobics", "Arm Swing", "Schadenfreude", "Kyoufuu", "Backflip", "Griddy", "Friday Night", "Floating Rest", "OnePlays", "Quick Combo", "WarCry", "Wave"}
local EmoteRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("EmoteHandler")
local function playEmote(name) pcall(function() EmoteRemote:FireServer(name) end) end

local function createEmoteButton()
    if Emote.GuiInstance then Emote.GuiInstance:Destroy() end
    local gui = Instance.new("ScreenGui")
    gui.Name = "EmoteButtonGui"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = game:GetService("CoreGui")

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 140, 0, 40)
    btn.Position = UDim2.new(0.55, 0, 0.75, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = 0.3
    btn.Text = "EMOTE : " .. Emote.Selected
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = gui

    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 10) corner.Parent = btn
    local stroke = Instance.new("UIStroke") stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border stroke.Thickness = 1.5 stroke.Color = Color3.fromRGB(150, 150, 150) stroke.Transparency = 0 stroke.Parent = btn

    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    local moved = false

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragInput = input
            dragStart = input.Position
            startPos = btn.Position
        end
    end)

    btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging or input ~= dragInput then return end
        local delta = input.Position - dragStart
        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then moved = true end
        btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging and not moved then
                playEmote(Emote.Selected)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                task.delay(0.3, function()
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                end)
            end
            dragging = false
        end
    end)

    Emote.GuiInstance = gui
    Emote.LabelRef = btn
end

local function updateEmoteText()
    if Emote.LabelRef and Emote.LabelRef:IsA("TextButton") then
        Emote.LabelRef.Text = "EMOTE : " .. Emote.Selected
    end
end

local function removeEmoteButton() if Emote.GuiInstance then Emote.GuiInstance:Destroy() Emote.GuiInstance = nil Emote.LabelRef = nil end end

--========================================================--
-- KILLER SYSTEM
--========================================================--

local Killer = { KillAll = false, AutoAttack = false, AttackDelay = 0.45 }
local KillerTarget = nil
local AutoStalk = { Enabled = false, StalkRange = 150 }
local AttackEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attacks"):WaitForChild("BasicAttack")

local function GetNearestAliveSurvivor()
    local root = getRoot() if not root then return nil end
    local closest, shortest = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid") local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 30 then local d = (hrp.Position - root.Position).Magnitude if d < shortest then shortest = d closest = plr.Character end end
        end
    end
    return closest
end
local function getClosestSurvivorForStalk()
    local root = getRoot() if not root then return nil end
    local closest, shortest = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid") local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 30 then local dist = (hrp.Position - root.Position).Magnitude if dist <= AutoStalk.StalkRange and dist < shortest then shortest = dist closest = plr end end
        end
    end
    return closest
end
local StalkConnection = nil
local function startAutoStalk()
    if StalkConnection then return end
    StalkConnection = RunService.Heartbeat:Connect(function()
        if not AutoStalk.Enabled then return end
        local target = getClosestSurvivorForStalk() if not target or not target.Character then return end
        local stalkEvent = ReplicatedStorage:FindFirstChild("Remotes", true) and ReplicatedStorage.Remotes:FindFirstChild("Killers", true) and ReplicatedStorage.Remotes.Killers:FindFirstChild("Stalker", true) and ReplicatedStorage.Remotes.Killers.Stalker:FindFirstChild("StartStalking")
        if stalkEvent then pcall(function() stalkEvent:FireServer(target) end) end
    end)
end
local function stopAutoStalk() if StalkConnection then StalkConnection:Disconnect() StalkConnection = nil end end

RunService.Heartbeat:Connect(function()
    if Killer.AutoAttack then pcall(function() AttackEvent:FireServer(false) end) task.wait(Killer.AttackDelay) end
    if Killer.KillAll then
        local root = getRoot()
        if root then
            if not KillerTarget or not KillerTarget:FindFirstChild("Humanoid") or KillerTarget.Humanoid.Health <= 35 then KillerTarget = GetNearestAliveSurvivor() end
            if KillerTarget then
                local targetHRP = KillerTarget:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    local targetPos = targetHRP.Position + (targetHRP.AssemblyLinearVelocity * 0.15)
                    local behind = targetHRP.CFrame.LookVector * -3 root.CFrame = CFrame.new(targetPos + behind, targetPos)
                end
                pcall(function() AttackEvent:FireServer(false) end)
            end
        end
    end
end)

--========================================================--
-- SELECT MASKED MENU
--========================================================--

local SelectMaskedMenu = { Enabled = false, GuiInstance = nil, Minimized = false }

local MaskedData = {
    { Name = "Alex", Image = "122432656503319" },
    { Name = "Rabbit", Image = "126193878341006" },
    { Name = "Brandon", Image = "137361388213125" },
    { Name = "Cobra", Image = "108523763323583" },
    { Name = "Tony", Image = "82052273951485" },
    { Name = "Richter", Image = "129872740597145" },
}

local ActivatePowerRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Killers") and ReplicatedStorage.Remotes.Killers:FindFirstChild("Masked") and ReplicatedStorage.Remotes.Killers.Masked:FindFirstChild("Activatepower")
local DeactivatePowerRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Killers") and ReplicatedStorage.Remotes.Killers:FindFirstChild("Masked") and ReplicatedStorage.Remotes.Killers.Masked:FindFirstChild("Deactivatepower")

local function CreateGradientStroke(parent, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = thickness or 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 150, 150)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150)),
    })
    gradient.Rotation = 45
    gradient.Parent = stroke
    
    return stroke, gradient
end

local function createSelectMaskedMenu()
    if SelectMaskedMenu.GuiInstance then SelectMaskedMenu.GuiInstance:Destroy() end
    SelectMaskedMenu.Minimized = false

    local gui = Instance.new("ScreenGui")
    gui.Name = "SelectMaskedMenu"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = game:GetService("CoreGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 210, 0, 310)
    MainFrame.Position = UDim2.new(0.5, -105, 0.25, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 7, 14)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = gui

    local Corner = Instance.new("UICorner") Corner.CornerRadius = UDim.new(0, 12) Corner.Parent = MainFrame
    local MainStroke, MainGradient = CreateGradientStroke(MainFrame, 2)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -80, 0, 35)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "SELECT MASKED"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 13
    Title.Font = Enum.Font.GothamBlack
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = MainFrame

    local TitleGradient = Instance.new("UIGradient")
    TitleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 150, 150)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150)),
    })
    TitleGradient.Rotation = 90
    TitleGradient.Parent = Title

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 22, 0, 22)
    MinimizeBtn.Position = UDim2.new(1, -58, 0, 7)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(20, 14, 27)
    MinimizeBtn.Text = "—"
    MinimizeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    MinimizeBtn.TextSize = 12
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.AutoButtonColor = false
    MinimizeBtn.Parent = MainFrame

    local MinCorner = Instance.new("UICorner") MinCorner.CornerRadius = UDim.new(1, 0) MinCorner.Parent = MinimizeBtn
    local MinStroke = Instance.new("UIStroke") MinStroke.Color = Color3.fromRGB(150, 150, 150) MinStroke.Thickness = 1 MinStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border MinStroke.Parent = MinimizeBtn

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 22, 0, 22)
    CloseBtn.Position = UDim2.new(1, -30, 0, 7)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(20, 14, 27)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = MainFrame

    local CloseCorner = Instance.new("UICorner") CloseCorner.CornerRadius = UDim.new(1, 0) CloseCorner.Parent = CloseBtn
    local CloseStroke = Instance.new("UIStroke") CloseStroke.Color = Color3.fromRGB(150, 150, 150) CloseStroke.Thickness = 1 CloseStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border CloseStroke.Parent = CloseBtn

    CloseBtn.MouseButton1Click:Connect(function()
        SelectMaskedMenu.Enabled = false
        SelectMaskedMenu.Minimized = false
        gui:Destroy()
        SelectMaskedMenu.GuiInstance = nil
    end)

    local Grid = Instance.new("Frame")
    Grid.Size = UDim2.new(1, -20, 0, 230)
    Grid.Position = UDim2.new(0, 10, 0, 40)
    Grid.BackgroundTransparency = 1
    Grid.Parent = MainFrame

    local positions = {
        { X = 0, Y = 0 },
        { X = 1, Y = 0 },
        { X = 2, Y = 0 },
        { X = 0, Y = 1 },
        { X = 1, Y = 1 },
        { X = 2, Y = 1 },
    }

    for i, masked in ipairs(MaskedData) do
        local pos = positions[i]
        
        local ImageBtn = Instance.new("ImageButton")
        ImageBtn.Size = UDim2.new(0, 55, 0, 55)
        ImageBtn.Position = UDim2.new(0, 5 + (pos.X * 65), 0, 10 + (pos.Y * 75))
        ImageBtn.BackgroundColor3 = Color3.fromRGB(20, 14, 27)
        ImageBtn.Image = "rbxassetid://" .. masked.Image
        ImageBtn.ImageTransparency = 0.05
        ImageBtn.AutoButtonColor = false
        ImageBtn.Parent = Grid

        local ImgCorner = Instance.new("UICorner") ImgCorner.CornerRadius = UDim.new(0, 8) ImgCorner.Parent = ImageBtn
        local ImgStroke, ImgGradient = CreateGradientStroke(ImageBtn, 1.5)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0, 55, 0, 15)
        Label.Position = UDim2.new(0, 0, 1, 2)
        Label.BackgroundTransparency = 1
        Label.Text = masked.Name
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 9
        Label.Font = Enum.Font.GothamBold
        Label.Parent = ImageBtn

        local LabelGradient = Instance.new("UIGradient")
        LabelGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 150, 150)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
        })
        LabelGradient.Rotation = 90
        LabelGradient.Parent = Label

        ImageBtn.MouseButton1Click:Connect(function()
            if ActivatePowerRemote then
                ActivatePowerRemote:FireServer(masked.Name)
                ImgStroke.Thickness = 3
                task.delay(0.3, function() ImgStroke.Thickness = 1.5 end)
                Library:Notify({ Title = "Power Activated", Content = masked.Name, Duration = 2 })
            end
        end)
    end

    local DeactivateBtn = Instance.new("TextButton")
    DeactivateBtn.Size = UDim2.new(1, -20, 0, 35)
    DeactivateBtn.Position = UDim2.new(0, 10, 1, -45)
    DeactivateBtn.BackgroundColor3 = Color3.fromRGB(20, 14, 27)
    DeactivateBtn.Text = "DEACTIVATE POWER"
    DeactivateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DeactivateBtn.TextSize = 11
    DeactivateBtn.Font = Enum.Font.GothamBold
    DeactivateBtn.AutoButtonColor = false
    DeactivateBtn.Parent = MainFrame

    local DeactCorner = Instance.new("UICorner") DeactCorner.CornerRadius = UDim.new(0, 8) DeactCorner.Parent = DeactivateBtn
    local DeactStroke, DeactGradient = CreateGradientStroke(DeactivateBtn, 2)

    local DeactTextGradient = Instance.new("UIGradient")
    DeactTextGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 150, 159)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150)),
    })
    DeactTextGradient.Rotation = 90
    DeactTextGradient.Parent = DeactivateBtn

    DeactivateBtn.MouseButton1Click:Connect(function()
        if DeactivatePowerRemote then
            DeactivatePowerRemote:FireServer()
            Library:Notify({ Title = "Power Deactivated", Content = "Power has been turned off", Duration = 2 })
        end
    end)

    local function SetMinimized(minimized)
        SelectMaskedMenu.Minimized = minimized
        if minimized then
            Grid.Visible = false
            DeactivateBtn.Visible = false
            MainFrame.Size = UDim2.new(0, 210, 0, 38)
            MinimizeBtn.Text = "+"
            MinimizeBtn.TextSize = 14
        else
            Grid.Visible = true
            DeactivateBtn.Visible = true
            MainFrame.Size = UDim2.new(0, 210, 0, 310)
            MinimizeBtn.Text = "—"
            MinimizeBtn.TextSize = 12
        end
    end

    MinimizeBtn.MouseButton1Click:Connect(function()
        SetMinimized(not SelectMaskedMenu.Minimized)
    end)

    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    Title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging or input ~= dragInput then return end
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    SelectMaskedMenu.GuiInstance = gui
end

local function removeSelectMaskedMenu()
    if SelectMaskedMenu.GuiInstance then SelectMaskedMenu.GuiInstance:Destroy() SelectMaskedMenu.GuiInstance = nil end
    SelectMaskedMenu.Minimized = false
end

--========================================================--
-- ESP SYSTEM (OPTIMIZED)
--========================================================--

local ESP = { Survivor = false, Killer = false, Generator = false, Pallet = false, Window = false, SCP = false, Distance = 100, StatusEnabled = false, ShowName = true, ShowDistance = true, ShowHealth = false, StatusRadius = 100 }
local TeamColors = { Killer = Color3.fromRGB(255, 0, 0), Survivor = Color3.fromRGB(255, 255, 255) }
local ESPObjects = {} local StatusESP = {}
local CachedGenerators, CachedWindows, CachedPallets = {}, {}, {}
local GeneratorColor = Color3.fromRGB(255, 170, 0) local PalletColor = Color3.fromRGB(74, 255, 181) local WindowColor = Color3.fromRGB(74, 255, 181) local SCPColor = Color3.fromRGB(255, 0, 0)

local function cacheObject(obj)
    if obj.Name == "Generator" then CachedGenerators[obj] = true elseif obj.Name == "Window" then CachedWindows[obj] = true elseif obj.Name == "Pallet" or obj.Name == "Palletwrong" then CachedPallets[obj] = true end
end
for _, obj in ipairs(Workspace:GetDescendants()) do cacheObject(obj) local name = string.lower(obj.Name) if string.find(name, "scp") then CachedSCP[obj] = true end end
Workspace.DescendantAdded:Connect(function(obj) cacheObject(obj) local name = string.lower(obj.Name) if string.find(name, "scp") then CachedSCP[obj] = true end end)
Workspace.DescendantRemoving:Connect(function(obj) CachedSCP[obj] = nil CachedGenerators[obj] = nil CachedWindows[obj] = nil CachedPallets[obj] = nil if ESPObjects[obj] then ESPObjects[obj]:Destroy() ESPObjects[obj] = nil end end)

local function removeESP(obj) if ESPObjects[obj] then ESPObjects[obj]:Destroy() ESPObjects[obj] = nil end end
local function createESP(obj, color)
    if not obj then return end
    if ESPObjects[obj] then ESPObjects[obj].FillColor = color ESPObjects[obj].OutlineColor = color return end
    local h = Instance.new("Highlight") h.FillColor = color h.OutlineColor = color h.FillTransparency = 0.9 h.OutlineTransparency = 0.3 h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop h.Parent = obj ESPObjects[obj] = h
end
local function removeStatusESP(char) if StatusESP[char] then StatusESP[char]:Destroy() StatusESP[char] = nil end end
local function createStatusESP(player, char, root)
    if not ESP.StatusEnabled then removeStatusESP(char) return end
    if not root then return end
    local head = char:FindFirstChild("Head") local hum = char:FindFirstChildOfClass("Humanoid") if not head or not hum then return end
    local isDown = hum.Health <= 0 or hum.Health < 2 local dist = (head.Position - root.Position).Magnitude
    if dist > ESP.StatusRadius then removeStatusESP(char) return end
    local text = "" if isDown then text = "DOWN\n" end
    if ESP.ShowName then text = text .. player.Name .. "\n" end
    if ESP.ShowDistance then text = text .. string.format("Dist: %.0f\n", dist) end
    if ESP.ShowHealth then text = text .. string.format("HP: %.0f\n", hum.Health) end
    if text == "" then removeStatusESP(char) return end
    local billboard = StatusESP[char]
    if not billboard then
        billboard = Instance.new("BillboardGui") billboard.Size = UDim2.new(0, 120, 0, 50) billboard.AlwaysOnTop = true
        local label = Instance.new("TextLabel") label.Size = UDim2.new(1, 0, 1, 0) label.BackgroundTransparency = 1 label.TextColor3 = Color3.new(1,1,1) label.TextStrokeTransparency = 0 label.Font = Enum.Font.GothamBold label.TextSize = 12 label.Text = text label.Parent = billboard
        billboard.Adornee = head billboard.StudsOffset = Vector3.new(0, 2.5, 0) billboard.Parent = char StatusESP[char] = billboard
    else local label = billboard:FindFirstChildOfClass("TextLabel") if label then label.Text = text end end
end
local function updateESP()
    local root = getRoot() if not root then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local char = p.Character local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local distance = (hrp.Position - root.Position).Magnitude
                    if distance <= ESP.Distance then
                        if ESP.Survivor and p.Team and p.Team.Name == "Survivors" then createESP(char, TeamColors.Survivor)
                        elseif ESP.Killer and p.Team and p.Team.Name == "Killer" then createESP(char, TeamColors.Killer) else removeESP(char) end
                    else removeESP(char) end
                end
                createStatusESP(p, char, root)
            else removeESP(char) end
        end
    end
    if ESP.SCP then for obj in pairs(CachedSCP) do if obj and obj.Parent then local pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position if pos and (pos - root.Position).Magnitude <= ESP.Distance then createESP(obj, SCPColor) else removeESP(obj) end end end
    else for obj in pairs(CachedSCP) do removeESP(obj) end end
    if ESP.Generator then for obj in pairs(CachedGenerators) do if obj and obj.Parent then local pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position if pos and (pos - root.Position).Magnitude <= ESP.Distance then createESP(obj, GeneratorColor) else removeESP(obj) end end end
    else for obj in pairs(CachedGenerators) do removeESP(obj) end end
    if ESP.Window then for obj in pairs(CachedWindows) do if obj and obj.Parent then local pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position if pos and (pos - root.Position).Magnitude <= ESP.Distance then createESP(obj, WindowColor) else removeESP(obj) end end end
    else for obj in pairs(CachedWindows) do removeESP(obj) end end
    if ESP.Pallet then for obj in pairs(CachedPallets) do if obj and obj.Parent then local pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position if pos and (pos - root.Position).Magnitude <= ESP.Distance then createESP(obj, PalletColor) else removeESP(obj) end end end
    else for obj in pairs(CachedPallets) do removeESP(obj) end end
end
task.spawn(function() while true do task.wait(0.1) if ESP.Survivor or ESP.Killer or ESP.SCP or ESP.Generator or ESP.Window or ESP.Pallet or ESP.StatusEnabled then updateESP() end end end)

--========================================================--
-- UI COMPONENTS
--========================================================--

-- ABILITY
AbilityBox:AddToggle("AutoWiggle", { Text = "Auto Wiggle", Default = false, Callback = function(v) AutoWiggle.Enabled = v end })
AbilityBox:AddToggle("AutoFleeKiller", { Text = "Auto Flee Killer", Default = false, Callback = function(v) AutoFlee.Enabled = v end })
AbilityBox:AddCheckbox("ShowFleeButton", { Text = "Show Flee Button", Default = false, Callback = function(v) if v then createFleeButton() else removeFleeButton() end end })
AbilityBox:AddDivider()
AbilityBox:AddToggle("AutoCrouchDodge", { 
    Text = "Auto Crouch Dodge", 
    Default = false, 
    Callback = function(v) 
        AutoCrouchDodge.Enabled = v 
        if v then 
            scanDodgeKillers()
            GetCrouchButton()
        end 
    end 
})
AbilityBox:AddDivider()
AbilityBox:AddToggle("AutoPalletDropdown", { 
    Text = "Auto Pallet Dropdown", 
    Default = false, 
    Callback = function(v) 
        PalletDropdown.Enabled = v 
    end 
})
AbilityBox:AddDivider()
AbilityBox:AddToggle("VaultWindows", { 
    Text = "Auto Windows Vault", 
    Default = false, 
    Callback = function(v) 
        VaultWindows.Enabled = v 
    end 
})
AbilityBox:AddToggle("AntiKnockdown", { Text = "Anti Knockdown", Default = false, Callback = function(v) PlayerMods.GodMode = v end })
AbilityBox:AddDivider()
AbilityBox:AddToggle("Moonwalk", { Text = "Moonwalk", Default = false, Callback = function(v) Moonwalk.Enabled = v if v then startMoonwalk() else local char = Player.Character local hum = char and char:FindFirstChildOfClass("Humanoid") if hum then hum.WalkSpeed = 16 end end end })
AbilityBox:AddSlider("MoonwalkSpamSpeed", { Text = "Spam Speed", Default = 30, Min = 1, Max = 50, Rounding = 0, Callback = function(v) Moonwalk.SpamSpeed = v end })
AbilityBox:AddSlider("MoonwalkIntensity", { Text = "Intensity", Default = 35, Min = 1, Max = 50, Rounding = 0, Callback = function(v) Moonwalk.Intensity = v end })

-- SKILLCHECK
SkillCheckBox:AddToggle("AutoSkillcheck", { Text = "Auto Skillcheck", Default = false, Callback = function(v) AutoSkillcheck.Enabled = v Busy = false if not AutoSkillcheck.Enabled then ScourgeActive = false end end })
SkillCheckBox:AddDropdown("SkillcheckMode", { Text = "Mode", Values = {"SUCCESS", "NEUTRAL", "INSTANT"}, Default = 1, Multi = false, Callback = function(v) AutoSkillcheck.Mode = v Busy = false end })

-- PARRY V1
ParryBox:AddToggle("AutoParry", { Text = "Auto Parry", Default = false, Callback = function(v) 
    AutoParry.Enabled = v 
    if v then 
        ParryRangeVisual.Enabled = true 
        CreateCircle() 
        scanKillers()
    else
        ParryRangeVisual.Enabled = false
        if Visuals.Circle then Visuals.Circle:Destroy() Visuals.Circle = nil end
    end
end })
ParryBox:AddCheckbox("ShowParryButton", { Text = "Show Parry Button", Default = false, Callback = function(v) if v then createParryV1Button() else removeParryV1Button() end end })
ParryBox:AddToggle("ShowParryRange", { Text = "Show Parry Range", Default = false, Callback = function(v) 
    ParryRangeVisual.Enabled = v 
    if v and AutoParry.Enabled then CreateCircle() 
    elseif not v then if Visuals.Circle then Visuals.Circle:Destroy() Visuals.Circle = nil end end
end })
ParryBox:AddSlider("ParryRange", { Text = "Parry Range", Default = 15, Min = 5, Max = 20, Rounding = 0, Callback = function(v) AutoParry.ParryDistance = v if ParryRangeVisual.Enabled and AutoParry.Enabled then CreateCircle() end end })
ParryBox:AddSlider("FaceSensitivity", { Text = "Face Sensitivity", Default = 0.7, Min = -1, Max = 1, Rounding = 2, Callback = function(v) AutoParry.FaceSensitivity = v end })

-- PARRY V2
ParryV2Box:AddToggle("AutoParryV2", { Text = "Auto Parry V2", Default = false, Callback = function(v) 
    AutoParryV2.Enabled = v 
    if v then 
        AutoParryV2.VisualEnabled = true 
    else 
        AutoParryV2.VisualEnabled = false 
        RingVisual.CFrame = CFrame.new(0, -9999, 0) 
    end 
end })
ParryV2Box:AddCheckbox("ShowParryV2Button", { Text = "Show Parry V2 Button", Default = false, Callback = function(v) if v then createParryV2Button() else removeParryV2Button() end end })
ParryV2Box:AddToggle("ShowParryRangeV2", { Text = "Show Range Circle", Default = false, Callback = function(v) 
    AutoParryV2.VisualEnabled = v 
    if not v then RingVisual.CFrame = CFrame.new(0, -9999, 0) end 
end })
ParryV2Box:AddSlider("ParryRangeV2", { Text = "Parry Range", Default = 15, Min = 1, Max = 32, Rounding = 0, Callback = function(v) AutoParryV2.ParryRange = v end })

-- SILENT AIM
SilentAimBox:AddToggle("SilentAim", { Text = "Silent Aim", Default = false, Callback = function(v) SILENT_AIM_ENABLED = v if not v then isShooting = false tracerBeam.Enabled = false end end })
SilentAimBox:AddToggle("ShowTracer", { Text = "Show Tracer Line", Default = false, Callback = function(v) SHOW_TRACER = v if not v then tracerBeam.Enabled = false end end })

-- MOVEMENT
MovementBox:AddToggle("FastVault", { Text = "Fast Vault", Default = false, Callback = function(v) FastVault.Enabled = v end })
MovementBox:AddSlider("VaultSpeed", { Text = "Vault Speed", Default = 1.2, Min = 1, Max = 5, Rounding = 1, Callback = function(v) FastVault.Speed = v end })
MovementBox:AddDivider()
MovementBox:AddToggle("Aimlock", { Text = "Aimlock", Default = false, Callback = function(v) Aimlock.Enabled = v if v then startAimlock() end end })
MovementBox:AddToggle("AimlockVisCheck", { Text = "Visibility Check", Default = true, Callback = function(v) Aimlock.VisibilityCheck = v end })
MovementBox:AddDropdown("AimlockTarget", { Text = "Target", Values = {"Killer", "Survivor", "SCP"}, Default = 1, Multi = false, Callback = function(v) Aimlock.TargetMode = v end })
MovementBox:AddDropdown("AimlockPart", { Text = "Target Part", Values = {"Head", "HumanoidRootPart", "Torso"}, Default = 2, Multi = false, Callback = function(v) Aimlock.AimPart = v end })
MovementBox:AddSlider("AimlockFOV", { Text = "FOV", Default = 250, Min = 50, Max = 1000, Rounding = 0, Callback = function(v) Aimlock.FOV = v end })
MovementBox:AddSlider("AimlockStrength", { Text = "Strength", Default = 1, Min = 0.1, Max = 1, Rounding = 2, Callback = function(v) Aimlock.Strength = v end })
MovementBox:AddSlider("AimlockPredict", { Text = "Prediction", Default = 0.12, Min = 0, Max = 1, Rounding = 2, Callback = function(v) Aimlock.PredictStrength = v end })

-- BUTTONS (TETEP TOGGLE)
ButtonBox:AddToggle("MoonwalkButton", { Text = "Moonwalk Button", Default = false, Callback = function(v) Moonwalk.ShowButton = v if v then createMoonwalkButton() else removeMoonwalkButton() end end })
ButtonBox:AddDivider()
ButtonBox:AddToggle("EmoteButton", { Text = "Emote Button", Default = false, Callback = function(v) Emote.Show = v if v then createEmoteButton() else removeEmoteButton() end end })
ButtonBox:AddDropdown("SelectEmote", { Text = "Select Emote", Values = EmoteList, Default = 1, Multi = false, Callback = function(v) Emote.Selected = v updateEmoteText() end })

-- ESP
ESPBox:AddToggle("ESPKiller", { Text = "ESP Killer", Default = false, Callback = function(v) ESP.Killer = v end })
ESPBox:AddToggle("ESPSurvivor", { Text = "ESP Survivor", Default = false, Callback = function(v) ESP.Survivor = v end })
ESPBox:AddToggle("ESPSCP", { Text = "ESP SCP", Default = false, Callback = function(v) ESP.SCP = v end })
ESPBox:AddToggle("ESPGenerator", { Text = "ESP Generator", Default = false, Callback = function(v) ESP.Generator = v end })
ESPBox:AddToggle("ESPWindow", { Text = "ESP Window", Default = false, Callback = function(v) ESP.Window = v end })
ESPBox:AddToggle("ESPPallet", { Text = "ESP Pallet", Default = false, Callback = function(v) ESP.Pallet = v end })
ESPBox:AddSlider("ESPRadius", { Text = "ESP Radius", Default = 100, Min = 10, Max = 1000, Rounding = 0, Callback = function(v) ESP.Distance = v end })

-- ESP STATUS
ESPStatusBox:AddToggle("ESPStatus", { Text = "ESP Status", Default = false, Callback = function(v) ESP.StatusEnabled = v end })
ESPStatusBox:AddToggle("ShowName", { Text = "Show Name", Default = true, Callback = function(v) ESP.ShowName = v end })
ESPStatusBox:AddToggle("ShowDistance", { Text = "Show Distance", Default = true, Callback = function(v) ESP.ShowDistance = v end })
ESPStatusBox:AddToggle("ShowHealth", { Text = "Show Health", Default = false, Callback = function(v) ESP.ShowHealth = v end })
ESPStatusBox:AddSlider("StatusRadius", { Text = "Status Radius", Default = 100, Min = 20, Max = 500, Rounding = 0, Callback = function(v) ESP.StatusRadius = v end })

-- KILLER
KillerBox:AddToggle("KillerAimlock", { Text = "Aimlock (Button)", Default = false, Callback = function(v) KillerAimlockBtn.Enabled = v if v then createKillerAimlockButton() else removeKillerAimlockButton() end end })
KillerBox:AddDivider()
KillerBox:AddToggle("AimlockAttack", { Text = "Aimlock Attack", Default = false, Callback = function(v) AttackAim.Enabled = v if v then startAttackAim() end end })
KillerBox:AddDivider()
KillerBox:AddToggle("AutoStalk", { Text = "Auto Stalk", Default = false, Callback = function(v) AutoStalk.Enabled = v if v then startAutoStalk() else stopAutoStalk() end end })
KillerBox:AddToggle("KillAll", { Text = "Auto Kill All", Default = false, Callback = function(v) Killer.KillAll = v end })
KillerBox:AddToggle("AutoAttack", { Text = "Auto Spam Attack", Default = false, Callback = function(v) Killer.AutoAttack = v end })
KillerBox:AddSlider("AttackDelay", { Text = "Attack Delay", Default = 0.45, Min = 0.1, Max = 1, Rounding = 2, Callback = function(v) Killer.AttackDelay = v end })

-- POWER
PowerBox:AddToggle("ShowSelectMasked", { Text = "Show Select Masked", Default = false, Callback = function(v) SelectMaskedMenu.Enabled = v if v then createSelectMaskedMenu() else removeSelectMaskedMenu() end end })

-- MISC
ZoomBox:AddToggle("UnlimitedZoom", { Text = "Unlimited Zoom Out", Default = false, Callback = function(v) CameraZoom.UnlimitedZoom = v applyUnlimitedZoom() end })
ZoomBox:AddSlider("MaxZoomDistance", { Text = "Max Zoom Distance", Default = 1000, Min = 100, Max = 5000, Rounding = 0, Callback = function(v) CameraZoom.MaxDistance = v if CameraZoom.UnlimitedZoom then applyUnlimitedZoom() end end })
ZoomBox:AddDivider()
ZoomBox:AddToggle("CustomFOV", { Text = "Custom FOV", Default = false, Callback = function(v) CameraZoom.FOVEnabled = v applyCameraFOV() end })
ZoomBox:AddSlider("CameraFOV", { Text = "Camera FOV", Default = 70, Min = 40, Max = 120, Rounding = 0, Callback = function(v) CameraZoom.FOV = v if CameraZoom.FOVEnabled then applyCameraFOV() end end })

FunBox:AddToggle("JerkTool", { Text = "Jerk Tool", Default = false, Callback = function(v) JerkTool.Enabled = v if v then createJerkTool() else if currentJerkTool then currentJerkTool:Destroy() currentJerkTool = nil end end end })

-- UI SETTINGS
MenuBox:AddToggle("ShowCustomCursor", { Text = "Custom Cursor", Default = true, Callback = function(v) Library.ShowCustomCursor = v end })
MenuBox:AddDropdown("NotificationSide", { Text = "Notification Side", Values = {"Left", "Right"}, Default = "Right", Multi = false, Callback = function(v) Library:SetNotifySide(v) end })
MenuBox:AddButton("Unload Script", function() Library:Unload() end)

--========================================================--
-- THEME MANAGER & SAVE MANAGER
--========================================================--

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
ThemeManager:SetFolder("PurpleXHub")
SaveManager:SetFolder("PurpleXHub/configs")
SaveManager:BuildConfigSection(Tabs.UI)

--========================================================--
-- FINAL
--========================================================--

print("====================================")
print(" PURPLE X HUB • OBSIDIAN UI • OPTIMIZED")
print(" Toggle Menu : READY")
print(" Ability Box : READY")
print(" Auto Wiggle : READY")
print(" Auto Flee Killer : READY")
print(" Flee Button (Checkbox) : READY")
print(" Auto Crouch Dodge : READY")
print(" Anti Knockdown : READY")
print(" Moonwalk (Fallens Exact) : READY")
print(" Moonwalk Button (Toggle) : READY")
print(" Emote Button (Toggle) : READY")
print(" Auto Skillcheck (VD v3) : READY")
print(" Auto Parry V1 + Button (Checkbox) : READY")
print(" Auto Parry V2 + Button (Checkbox) : READY")
print(" Silent Aim (Universal) : READY")
print(" Tracer Line (Hold) : READY")
print(" Aimlock (Hold) : READY")
print(" Aimlock Attack (Hold) : READY")
print(" Killer Aimlock Button (Toggle) : READY")
print(" Select Masked Menu (Minimize) : READY")
print(" Misc Tab : READY")
print(" Unlimited Zoom : READY")
print(" Custom FOV : READY")
print(" Jerk Tool : READY")
print(" All Systems : READY")
print("====================================") 
