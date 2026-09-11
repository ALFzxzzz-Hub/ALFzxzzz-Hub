-- ============================================================
-- WISNU TRIMMED v15
-- TAB 1: ESP | TAB 2: COMBAT | TAB 3: SURVIVOR | TAB 4: KILLER | TAB 5: VISUAL
-- THEME: GRAY × WHITE (Accent = 191,191,191)
-- ============================================================

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

Library.ForceCheckbox = false

-- ============================================================
-- CUSTOM THEME: GRAY × WHITE
-- ============================================================
Library.Scheme.AccentColor     = Color3.fromRGB(191, 191, 191)
Library.Scheme.BackgroundColor = Color3.fromRGB(20, 20, 22)
Library.Scheme.MainColor       = Color3.fromRGB(28, 28, 30)
Library.Scheme.OutlineColor    = Color3.fromRGB(90, 90, 95)
Library.Scheme.FontColor       = Color3.fromRGB(240, 240, 245)

-- ============== SERVICES =================
local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local UserInputService    = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting            = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local Camera      = workspace.CurrentCamera
local isMobile    = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- ============== VISUAL CONFIG =================
local OriginalLighting = {
    Brightness    = Lighting.Brightness,
    ClockTime     = Lighting.ClockTime,
    Ambient       = Lighting.Ambient,
    OutdoorAmbient= Lighting.OutdoorAmbient,
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd        = Lighting.FogEnd,
    FogStart      = Lighting.FogStart,
}

local VisualConfig = {
    FullBright    = false,
    NoFog         = false,
    LockPOV       = false,
    LockPOVFOV    = 90,
}

local VisualState = {
    FogCache         = {},
    LockPOVActive    = false,
    OriginalFOV      = Camera.FieldOfView,
    OriginalCamType  = Camera.CameraType,
}

-- ============== CONFIG =================
local ESP = {
    Survivor  = false,
    Killer    = false,
    Generator = false,
    Pallet    = false,
    Window    = false,
    SCP       = false,
    Distance  = 100
}

local ESPStatus = {
    Enabled      = false,
    ShowName     = true,
    ShowDistance = true,
    ShowHealth   = false,
    ShowItem     = true,
    Radius       = 100
}

local TeamColors = {
    Killer   = Color3.fromRGB(255, 60, 60),
    Survivor = Color3.fromRGB(60, 255, 120)
}

local GeneratorColor = Color3.fromRGB(255, 170, 0)
local PalletColor    = Color3.fromRGB(74, 255, 181)
local WindowColor    = Color3.fromRGB(74, 255, 181)
local SCPColor       = Color3.fromRGB(255, 0, 0)

local ESPItems = {
    ["Twist of Fate"]   = true,
    ["Bandage"]         = true,
    ["Motion Tracker"]  = true,
    ["Gate"]            = true,
    ["Shadow Clone"]    = true,
    ["Parrying Dagger"] = true
}

local Config = {
    Surv_AutoParry       = false,
    Surv_ParrySafety     = false,
    Surv_ParryAggressive = false,
    Surv_ParryCircle     = true,
    Surv_ParryRadius     = 15,
    Surv_ParryFace       = 0.7,
    Surv_AutoCrouch      = false,
    Ignored_Skills_List  = {}
}

local ToFAim = {
    Enabled      = false,
    TargetMode   = "Killer",
    AimPart      = "Torso",
    UseFOV       = false,
    FOV          = 150,
    ShowFOV      = false,
    LockAim      = false,
    BlockKnocked = false,
    HideLaser    = false,
    BulletSpeed  = 400,
    YOffset      = -2,
}

local VeilConfig = {
    Enabled              = false,
    ShowFOV              = true,
    ShowTargetLaser      = true,
    FOV                  = 220,
    SpearSpeed           = 165,
    Gravity              = workspace.Gravity * 0.5,
    MaxDist              = 200,
    AutoPredict          = false,
    TargetPart           = "Torso",
    HorizontalPredictFactor = 1.0,
}

local VeilState = {
    chargingSpear    = false,
    touchInput       = nil,
    attackCooldown   = false,
    passiveCooldown  = false,
    remoteHooked     = false,
    lastPredictedPos = nil,
}

local VeilVelocityCache = {}

-- ============== FLASHLIGHT SILENT AIM =================
local FlashConfig = {
    Enabled      = false,
    Laser        = true,
    TargetPart   = "Head",
    Range        = 120,
    Smooth       = 0.35,
    YOffset      = 0,
    Keybind      = Enum.KeyCode.F,
    KeyActive    = false,
}

local FlashState = {
    Active          = false,
    FlashlightPart  = nil,
    LaserBeam       = nil,
    Connection      = nil,
    remoteHooked    = false,
}

-- ============== AIMLOCK ATTACK (ALFzxzzz - Mouse1) =================
local AttackAim = {
    Enabled         = false,
    Holding         = false,
    Strength        = 1,
    Predict         = true,
    PredictStrength = 0.12,
    FOV             = 250,
    VisibilityCheck = true,
    AimPart         = "HumanoidRootPart",
    TargetMode      = "Survivor",
    ShowFOV         = false,
    Keybind         = Enum.KeyCode.LeftAlt,
}

local AttackAimState = {
    Holding   = false,
    FOVCircle = nil,
}

-- ============== AIMLOCK ATTACK (WISNU - Mouse2) =================
local WisnuAttackAim = {
    Enabled         = false,
    Holding         = false,
    Strength        = 1,
    Predict         = true,
    PredictStrength = 0.12,
    FOV             = 250,
    VisibilityCheck = true,
    AimPart         = "HumanoidRootPart",
    TargetMode      = "Survivor",
    ShowFOV         = false,
}

local WisnuAttackAimState = {
    FOVCircle = nil,
}

-- ============== AIMLOCK ATTACK SPEAR MODE =================
local SpearAim = {
    Enabled         = false,
    Holding         = false,
    Strength        = 1,
    Gravity         = 50,
    Speed           = 100,
    FOV             = 250,
    VisibilityCheck = true,
    AimPart         = "HumanoidRootPart",
    TargetMode      = "Survivor",
    ShowFOV         = false,
    Keybind         = Enum.KeyCode.LeftAlt,
}

local SpearAimState = {
    Holding   = false,
    FOVCircle = nil,
}

-- ============== DASH LOCK (KILLER) =================
local DashLockConfig = {
    Enabled          = false,
    Duration         = 1.5,
    Smoothness       = 0.3,
    FreezeDuringDash = false,
    DashAnimationId  = "rbxassetid://98163597193511",
    ShowIndicator    = true,
}

local DashLockState = {
    Active        = false,
    Target        = nil,
    Connection    = nil,
    DashHookConn  = nil,
}

-- ============== SILENT FLASK (CURE) =================
local FlaskConfig = {
    Enabled    = false,
    SilentAim  = false,
    ShowLaser  = true,
    TargetPart = "HumanoidRootPart",
    MaxDist    = 200,
}

local FlaskState = {
    remoteHooked    = false,
    LaserPart       = nil,
    LaserConnection = nil,
    Active          = false,
}

-- ============== SURVIVOR CONFIG =================
local SurvivorConfig = {
    AutoSkillCheck       = false,
    SkillCheckMode       = "Legit",
    FleeKiller           = false,
    FleeDistance         = 40,
    SwiftVault           = false,
    SwiftVaultV2         = false,
    SwiftVaultSpeed      = 13,
    InstantHealSelf      = false,
    ShowHealButton       = false,
    DragLockedHealBtn    = false,
}

local SurvivorState = {
    LastSkillCheckBusy   = false,
    LastGoalRotation     = nil,
    HasClickedThisGoal   = false,
    LastLineRotation     = nil,
    LastTick             = nil,
    WasActive            = false,
}

-- ============== FAKE PERKS STATE =================
local FakePerksState = {
    ActiveBuffs  = {},
    HB           = nil,
    LastBuffEnd  = 0,
    CooldownTime = 10,
    FlowstateOn  = false,
    QuickRecOn   = false,
    PerfLandOn   = false,
    AdrenalineOn = false,
    Conns        = {},
}

-- ============== KILLER CONFIG =================
local KillerConfig = {
    InfAbyssalBurst = false,
    InfHiddenSkill  = false,
    InfFrenzy       = false,
    InfLakeMist     = false,
    InfPursuit      = false,
    InfLunge        = false,
    NoSlowdown      = false,

    AutoAttack         = false,
    AutoAttackRange    = 12,
    AutoDropAllPallet  = false,
    BlockAllVaults     = false,
    CounterParry       = false,
}

local KillerState = {
    AbyssConnection       = nil,
    CorruptHandlerFunc    = nil,
    HiddenBypassThread    = nil,
    JeffBypassThread      = nil,
    SlasherBypassThread   = nil,
    OriginalLungeBoost    = nil,
    AntiStunHooked        = false,

    LastPalletBlockTime   = 0,
    LastVaultBlockTime    = 0,
    FakeAttackThread      = nil,
}

local State = {
    ParryCooldown       = false,
    ParryCooldownThread = nil,
    AutoParryAdornment  = nil,
    lastParry           = 0,

    ChargingPistol      = false,
    LockedPistolTarget  = nil,
    PistolLaser         = nil,
    FOVCircle           = nil,
    TouchPistolInput    = nil,
}

local Timers = {
    lastESPUpdate = 0
}

local ESPCache = {
    Objects    = {},
    Status     = {},
    SCP        = {},
    Generators = {},
    Windows    = {},
    Pallets    = {}
}

-- ============== KONSTANTA =================
local PARRY_DEBOUNCE = 0.2

local VALID_PARRY_IDS = {
    ["122812055447896"] = "Veil lunge",
    ["133963973694098"] = "Mayers Basic",
    ["117042998468241"] = "Mayers lunge",
    ["135002183282873"] = "cure lunge",
    ["121216847022485"] = "cure Basic",
    ["132817836308238"] = "Jeff Basic",
    ["129784271201071"] = "Jeff lunge",
    ["82666958311998"]  = "Jeff Frenzy",
    ["78432063483146"]  = "Abyssal Basic",
    ["118907603246885"] = "Abyssal lunge",
    ["139369275981139"] = "Jason Basic",
    ["110355011987939"] = "Jason lunge",
    ["111920872708571"] = "Masked Basic",
    ["105374834496520"] = "Masked lunge",
    ["138720291317243"] = "Masked Tony",
    ["106871536134254"] = "Masked Alex",
    ["130593238885843"] = "Masked Cobra",
    ["115244153053858"] = "Masked Cobra lunge",
    ["74968262036854"]  = "Hidden Basic",
    ["113255068724446"] = "Hidden lunge",
    ["98163597193511"]  = "Hidden S1",
    ["80411309607666"]  = "Abyssal S1"
}

local Attached = {}

-- ============== HELPER =================
local function getRoot()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function IsDowned(char)
    if not char then return false end
    return char:GetAttribute("Knocked") == true or char:GetAttribute("IsHooked") == true
end

local function IsKiller(p)
    return p and p.Team and p.Team.Name == "Killer"
end

local function GetDistance(pos)
    local root = getRoot()
    if not root then return math.huge end
    return (pos - root.Position).Magnitude
end

-- ============================================================
-- ============== VISUAL: FULLBRIGHT ==========================
-- ============================================================
task.spawn(function()
    while true do
        if VisualConfig.FullBright then
            pcall(function()
                Lighting.Brightness     = 2
                Lighting.ClockTime      = 14
                Lighting.GlobalShadows  = false
                Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
                Lighting.FogStart       = 0
                Lighting.FogEnd         = 100000

                for _, v in pairs(Lighting:GetChildren()) do
                    if v:IsA("Atmosphere") then
                        v.Density = 0
                        v.Offset  = 0
                        v.Glare   = 0
                        v.Haze    = 0
                    end
                    if v:IsA("BlurEffect") then v.Size = 0 end
                    if v:IsA("ColorCorrectionEffect") then v.Enabled = false end
                    if v:IsA("SunRaysEffect") then v.Enabled = false end
                end
            end)
        else
            pcall(function()
                Lighting.Brightness     = OriginalLighting.Brightness
                Lighting.ClockTime      = OriginalLighting.ClockTime
                Lighting.GlobalShadows  = OriginalLighting.GlobalShadows
                Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
                Lighting.FogStart       = OriginalLighting.FogStart
                Lighting.FogEnd         = OriginalLighting.FogEnd
            end)
        end
        task.wait(0.5)
    end
end)

-- ============================================================
-- ============== VISUAL: NO FOG ==============================
-- ============================================================
local function Visual_RemoveFog()
    pcall(function()
        local map = workspace:FindFirstChild("Map")
        if map then
            for _, obj in ipairs(map:GetDescendants()) do
                if obj.Name:lower():find("fog")
                    or obj:IsA("Atmosphere")
                    or obj:IsA("BloomEffect")
                    or obj:IsA("BlurEffect")
                    or obj:IsA("ColorCorrectionEffect") then
                    if not VisualState.FogCache[obj] then
                        VisualState.FogCache[obj] = {
                            enabled = obj:IsA("PostEffect") and obj.Enabled or true,
                            parent  = obj.Parent
                        }
                    end
                    if obj:IsA("PostEffect") then obj.Enabled = false else obj.Parent = nil end
                end
            end
        end

        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("Atmosphere") or obj.Name:lower():find("fog") then
                if not VisualState.FogCache[obj] then
                    VisualState.FogCache[obj] = { enabled = true, parent = obj.Parent }
                end
                if obj:IsA("Atmosphere") then obj.Density = 0 else obj.Parent = nil end
            end
        end

        Lighting.FogEnd   = 100000
        Lighting.FogStart = 0
    end)
end

local function Visual_RestoreFog()
    pcall(function()
        for obj, data in pairs(VisualState.FogCache) do
            if obj and data.parent then
                if obj:IsA("PostEffect") then obj.Enabled = data.enabled else obj.Parent = data.parent end
            end
        end
        VisualState.FogCache = {}
        Lighting.FogEnd   = OriginalLighting.FogEnd
        Lighting.FogStart = OriginalLighting.FogStart
    end)
end

-- ============================================================
-- ============== VISUAL: LOCK POV ============================
-- ============================================================
RunService.RenderStepped:Connect(function()
    if not VisualConfig.LockPOV then
        if VisualState.LockPOVActive then
            VisualState.LockPOVActive = false
            pcall(function()
                local cam = workspace.CurrentCamera
                if cam then
                    cam.CameraType = VisualState.OriginalCamType
                    cam.FieldOfView = VisualState.OriginalFOV
                end
                LocalPlayer.CameraMode = Enum.CameraMode.Classic
                LocalPlayer.CameraMaxZoomDistance = 128
                LocalPlayer.CameraMinZoomDistance = 0.5

                local char = LocalPlayer.Character
                local head = char and char:FindFirstChild("Head")
                if head then head.LocalTransparencyModifier = 0 end
                for _, obj in ipairs(char and char:GetChildren() or {}) do
                    if obj:IsA("Accessory") then
                        local handle = obj:FindFirstChild("Handle")
                        if handle then handle.LocalTransparencyModifier = 0 end
                    end
                end
            end)
        end
        return
    end

    if not VisualState.LockPOVActive then
        VisualState.LockPOVActive = true
        local cam = workspace.CurrentCamera
        if cam then
            VisualState.OriginalCamType = cam.CameraType
            VisualState.OriginalFOV = cam.FieldOfView
        end
    end

    pcall(function()
        local cam = workspace.CurrentCamera
        if cam then
            cam.CameraType = Enum.CameraType.Custom
            cam.FieldOfView = VisualConfig.LockPOVFOV or 90
        end
        LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
        LocalPlayer.CameraMaxZoomDistance = 0
        LocalPlayer.CameraMinZoomDistance = 0

        local char = LocalPlayer.Character
        local head = char and char:FindFirstChild("Head")
        if head then head.LocalTransparencyModifier = 1 end
        for _, obj in ipairs(char and char:GetChildren() or {}) do
            if obj:IsA("Accessory") then
                local handle = obj:FindFirstChild("Handle")
                if handle then handle.LocalTransparencyModifier = 1 end
            end
        end
    end)
end)

-- ============================================================
-- ============== ESP SYSTEM ==================================
-- ============================================================

for _, obj in ipairs(workspace:GetDescendants()) do
    if string.find(string.lower(obj.Name), "scp") then ESPCache.SCP[obj] = true end
    if obj.Name == "Generator" then ESPCache.Generators[obj] = true
    elseif obj.Name == "Window" then ESPCache.Windows[obj] = true
    elseif obj.Name == "Pallet" or obj.Name == "Palletwrong" then ESPCache.Pallets[obj] = true
    end
end

workspace.DescendantAdded:Connect(function(obj)
    local name = string.lower(obj.Name)
    if string.find(name, "scp") then ESPCache.SCP[obj] = true end
    if obj.Name == "Generator" then ESPCache.Generators[obj] = true
    elseif obj.Name == "Window" then ESPCache.Windows[obj] = true
    elseif obj.Name == "Pallet" or obj.Name == "Palletwrong" then ESPCache.Pallets[obj] = true
    end
end)

workspace.DescendantRemoving:Connect(function(obj)
    ESPCache.SCP[obj] = nil
    ESPCache.Generators[obj] = nil
    ESPCache.Windows[obj] = nil
    ESPCache.Pallets[obj] = nil
    if ESPCache.Objects[obj] then
        ESPCache.Objects[obj]:Destroy()
        ESPCache.Objects[obj] = nil
    end
end)

local function removeESP(obj)
    if ESPCache.Objects[obj] then
        ESPCache.Objects[obj]:Destroy()
        ESPCache.Objects[obj] = nil
    end
end

local function createESP(obj, color)
    if not obj then return end
    if ESPCache.Objects[obj] then
        ESPCache.Objects[obj].FillColor    = color
        ESPCache.Objects[obj].OutlineColor = color
        return
    end
    local h = Instance.new("Highlight")
    h.FillColor            = color
    h.OutlineColor         = color
    h.FillTransparency     = 0.9
    h.OutlineTransparency  = 0.3
    h.DepthMode            = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent               = obj
    ESPCache.Objects[obj]  = h
    obj.AncestryChanged:Connect(function(_, parent)
        if not parent then removeESP(obj) end
    end)
end

local function removeStatusESP(char)
    if ESPCache.Status[char] then
        ESPCache.Status[char]:Destroy()
        ESPCache.Status[char] = nil
    end
end

local function GetHeldItem(char)
    if not char then return nil end
    for _, obj in ipairs(char:GetChildren()) do
        if ESPItems[obj.Name] then return obj.Name end
        if obj:IsA("Tool") and ESPItems[obj.Name] then return obj.Name end
    end
    return nil
end

local function GetGameValue(obj, name)
    if not obj then return nil end
    local attr = obj:GetAttribute(name)
    if attr ~= nil then return attr end
    local child = obj:FindFirstChild(name)
    if child then
        local ok, val = pcall(function() return child.Value end)
        if ok then return val end
    end
    return nil
end

local function ApplyGenHighlight(object, color)
    local h = object:FindFirstChild("GenHighlight") or Instance.new("Highlight")
    h.Name               = "GenHighlight"
    h.Adornee            = object
    h.FillColor          = color
    h.OutlineColor       = color
    h.FillTransparency   = 0.9
    h.OutlineTransparency = 0.3
    h.DepthMode          = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent             = object
end

local function CreateBillboard(text, color)
    local billboard = Instance.new("BillboardGui")
    billboard.Name        = "GenESP"
    billboard.Size        = UDim2.new(0, 100, 0, 30)
    billboard.AlwaysOnTop = true
    local label = Instance.new("TextLabel")
    label.Size                 = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text                 = text
    label.TextColor3           = color
    label.TextStrokeTransparency = 0
    label.Font                 = Enum.Font.GothamBold
    label.TextSize             = 12
    label.Parent               = billboard
    return billboard
end

local function UpdateGenerator(generator)
    if not generator or not generator.Parent then return end
    if not ESP.Generator then
        local old = generator:FindFirstChild("GenESP")
        if old then old:Destroy() end
        local h = generator:FindFirstChild("GenHighlight")
        if h then h:Destroy() end
        return
    end
    local percent = GetGameValue(generator, "RepairProgress") or GetGameValue(generator, "Progress") or 0
    local billboard = generator:FindFirstChild("GenESP")
    if percent >= 100 then
        if billboard then billboard:Destroy() end
        return
    end
    local cp    = math.clamp(percent, 0, 100)
    local color = GeneratorColor:Lerp(Color3.fromRGB(0, 255, 120), cp / 100)
    local text  = string.format("[%.0f%%]", percent)
    if not billboard then
        billboard        = CreateBillboard(text, color)
        billboard.Adornee = generator
        billboard.Parent  = generator
    else
        local lbl = billboard:FindFirstChildOfClass("TextLabel")
        if lbl then lbl.Text = text; lbl.TextColor3 = color end
    end
    ApplyGenHighlight(generator, color)
end

local function UpdateMapESP(obj, root)
    if not obj or not root then return end
    local pos
    if obj:IsA("Model") then pos = obj:GetPivot().Position
    elseif obj:IsA("BasePart") then pos = obj.Position end
    if not pos then return end
    local distance = (pos - root.Position).Magnitude
    if obj.Name == "Window" then
        if ESP.Window and distance <= ESP.Distance then createESP(obj, WindowColor)
        else removeESP(obj) end
    end
    if obj.Name == "Pallet" or obj.Name == "Palletwrong" then
        if ESP.Pallet and distance <= ESP.Distance then createESP(obj, PalletColor)
        else removeESP(obj) end
    end
end

local function createStatusESP(player, char, root)
    if not ESPStatus.Enabled then removeStatusESP(char); return end
    if not root then return end
    local head = char:FindFirstChild("Head")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not head or not hum then return end

    local isDown = hum.Health <= 0 or hum.Health < 2
        or char:GetAttribute("Downed") == true
        or char:GetAttribute("IsDown") == true
        or char:GetAttribute("Knocked") == true

    local dist = (head.Position - root.Position).Magnitude
    if dist > ESPStatus.Radius then removeStatusESP(char); return end

    local text = ""
    if isDown then text = "DOWN\n" end
    if ESPStatus.ShowName then
        text = text .. player.Name
        if ESPStatus.ShowItem then
            local item = GetHeldItem(char)
            if item then text = text .. " [" .. item .. "]" end
        end
        text = text .. "\n"
    end
    if ESPStatus.ShowDistance then text = text .. string.format("Dist: %.0f\n", dist) end
    if ESPStatus.ShowHealth   then text = text .. string.format("HP: %.0f\n", hum.Health) end
    if text == "" then removeStatusESP(char); return end

    local teamColor = Color3.new(1, 1, 1)
    if player.Team then
        if player.Team.Name == "Killer" then teamColor = TeamColors.Killer
        elseif player.Team.Name == "Survivors" then teamColor = TeamColors.Survivor end
    end
    if isDown then teamColor = Color3.fromRGB(255, 0, 0) end

    local billboard = ESPCache.Status[char]
    if not billboard then
        billboard         = Instance.new("BillboardGui")
        billboard.Size    = UDim2.new(0, 120, 0, 50)
        billboard.AlwaysOnTop = true
        local label = Instance.new("TextLabel")
        label.Size                 = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3           = teamColor
        label.TextStrokeTransparency = 0
        label.Font                 = Enum.Font.GothamBold
        label.TextSize             = 12
        label.Text                 = text
        label.Parent               = billboard
        billboard.Adornee          = head
        billboard.StudsOffset      = Vector3.new(0, 2.5, 0)
        billboard.Parent           = char
        ESPCache.Status[char]      = billboard
    else
        local label = billboard:FindFirstChildOfClass("TextLabel")
        if label then label.Text = text; label.TextColor3 = teamColor end
    end
end

local function UpdateSCPEsp(root)
    if not ESP.SCP then
        for obj in pairs(ESPCache.SCP) do removeESP(obj) end
        return
    end
    for obj in pairs(ESPCache.SCP) do
        if obj and obj.Parent then
            local pos
            if obj:IsA("Model") then pos = obj:GetPivot().Position
            elseif obj:IsA("BasePart") then pos = obj.Position end
            if pos then
                if (pos - root.Position).Magnitude <= ESP.Distance then
                    createESP(obj, SCPColor)
                else
                    removeESP(obj)
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    local root = getRoot()
    if not root then return end
    local now = tick()

    if now - Timers.lastESPUpdate >= 0.05 then
        Timers.lastESPUpdate = now

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local char = p.Character
                local hum  = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local hrp2 = char:FindFirstChild("HumanoidRootPart")
                    if hrp2 then
                        local distance = (hrp2.Position - root.Position).Magnitude
                        if distance <= ESP.Distance then
                            if ESP.Survivor and p.Team and p.Team.Name == "Survivors" then
                                createESP(char, TeamColors.Survivor)
                            elseif ESP.Killer and p.Team and p.Team.Name == "Killer" then
                                createESP(char, TeamColors.Killer)
                            else
                                removeESP(char)
                            end
                        else
                            removeESP(char)
                        end
                    end
                    createStatusESP(p, char, root)
                else
                    removeESP(char)
                end
            end
        end

        if ESP.Generator then
            for gen in pairs(ESPCache.Generators) do UpdateGenerator(gen) end
        end

        for obj in pairs(ESPCache.Windows) do UpdateMapESP(obj, root) end
        for obj in pairs(ESPCache.Pallets) do UpdateMapESP(obj, root) end

        UpdateSCPEsp(root)
    end
end)

-- ============================================================
-- ============== AUTO PARRY ==================================
-- ============================================================

function IsSafeToParry(char)
    if not Config.Surv_ParrySafety then return true end
    if not char then return false end
    local interactObj = char:FindFirstChild("CheckInterractable")
    if interactObj then
        if interactObj:GetAttribute("isVaulting")  == true then return false end
        if interactObj:GetAttribute("isRepairing") == true then return false end
        if interactObj:GetAttribute("isUnhooking") == true then return false end
        if interactObj:GetAttribute("isHealing")   == true then return false end
        if interactObj:GetAttribute("isSliding")   == true then return false end
    end
    return true
end

function TriggerCrouch()
    pcall(function()
        local b = LocalPlayer:FindFirstChild("PlayerGui")
        for segment in string.gmatch("Survivor-mob.Controls.crouch.icon", "[^%.]+") do
            if b then b = b:FindFirstChild(segment) end
        end
        if b and b:IsA("GuiObject") and b.Visible and b.Parent and b.Parent:IsA("GuiButton") then
            local btn = b.Parent
            if UserInputService.TouchEnabled and type(firesignal) == "function" then
                firesignal(btn.MouseButton1Click); task.wait(2); firesignal(btn.MouseButton1Click)
            else
                VirtualInputManager:SendKeyEvent(true,  Enum.KeyCode.LeftControl, false, game)
                task.wait(2)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
            end
        else
            VirtualInputManager:SendKeyEvent(true,  Enum.KeyCode.LeftControl, false, game)
            task.wait(2)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
        end
    end)
end

function tapMobileParryButton()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    local survivorMob = playerGui:FindFirstChild("Survivor-mob")
    local parryBtn = survivorMob
        and survivorMob:FindFirstChild("Controls")
        and survivorMob.Controls:FindFirstChild("Gui-mob")
    if parryBtn and parryBtn.Visible then
        if firesignal then
            pcall(function()
                firesignal(parryBtn.MouseButton1Down)
                task.wait(0.01)
                firesignal(parryBtn.MouseButton1Up)
            end)
        end
    else
        pcall(function()
            if mouse2click then mouse2click(); return end
            if mouse2press and mouse2release then
                mouse2press(); task.wait(0.01); mouse2release(); return
            end
            if MouseButton2Click then MouseButton2Click(); return end
            VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true,  game, 0)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
        end)
    end
end

function ExecuteParry()
    if State.ParryCooldown then return end
    pcall(function()
        local parryRemote = ReplicatedStorage:FindFirstChild("Remotes")
            :FindFirstChild("Items")
            :FindFirstChild("Parrying Dagger")
            :FindFirstChild("parry")
        if parryRemote then
            for i = 1, 10 do parryRemote:FireServer() end
        end
        task.spawn(tapMobileParryButton)
    end)
end

function ListenToParryResult()
    task.spawn(function()
        local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
        local dagger = remotes
            and remotes:WaitForChild("Items", 5):WaitForChild("Parrying Dagger", 5)
        local parryResultRemote = dagger and dagger:WaitForChild("parryResult", 5)
        if parryResultRemote then
            parryResultRemote.OnClientEvent:Connect(function(arg1, arg2)
                local cdDur = tonumber(arg2) or ((arg1 == true) and 90 or 60)
                State.ParryCooldown = true
                if State.ParryCooldownThread then task.cancel(State.ParryCooldownThread) end
                State.ParryCooldownThread = task.delay(cdDur, function()
                    State.ParryCooldown = false
                end)
            end)
        end
    end)
end
ListenToParryResult()

function AttachParrySensor(kChar)
    if not kChar or Attached[kChar] then return end
    Attached[kChar] = true
    local humanoid = kChar:FindFirstChild("Humanoid")
    if not humanoid then
        humanoid = kChar:WaitForChild("Humanoid", 5)
        if not humanoid then return end
    end
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = humanoid:WaitForChild("Animator", 5)
        if not animator then return end
    end
    humanoid.ChildAdded:Connect(function(child)
        if child:IsA("Animator") then
            Attached[kChar] = nil
            AttachParrySensor(kChar)
        end
    end)
    kChar.AncestryChanged:Connect(function(_, parent)
        if not parent then Attached[kChar] = nil end
    end)
    animator.AnimationPlayed:Connect(function(track)
        local animId = track.Animation and track.Animation.AnimationId or ""
        local id     = animId:match("%d+")
        local attackName = VALID_PARRY_IDS[id]
        if not attackName then return end

        if id == "80411309607666" and Config.Surv_AutoCrouch then
            local myChar = LocalPlayer.Character
            if IsDowned(myChar) then return end
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local kHRP  = kChar:FindFirstChild("HumanoidRootPart")
            if myHRP and kHRP then
                local dist = (myHRP.Position - kHRP.Position).Magnitude
                if dist <= 40 then TriggerCrouch() end
            end
            return
        end

        if not Config.Surv_AutoParry then return end
        if State.ParryCooldown then return end
        if Config.Ignored_Skills_List and Config.Ignored_Skills_List[attackName] then return end

        local myChar = LocalPlayer.Character
        if IsDowned(myChar) or not IsSafeToParry(myChar) then return end

        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local kHRP  = kChar:FindFirstChild("HumanoidRootPart")
        if not myHRP or not kHRP then return end

        local delta         = myHRP.Position - kHRP.Position
        local startDistance = delta.Magnitude

        if Config.Surv_ParryAggressive then
            local aggressiveRadius = 12
            local detectionRadius  = Config.Surv_ParryRadius + 5
            if startDistance > detectionRadius then return end
            if startDistance <= aggressiveRadius then
                ExecuteParry()
            else
                local tracker
                local startTime = os.clock()
                tracker = RunService.Heartbeat:Connect(function()
                    if os.clock() - startTime >= 1.5
                        or State.ParryCooldown
                        or not myHRP or not kHRP or IsDowned(myChar) then
                        if tracker then tracker:Disconnect() end
                        return
                    end
                    local currentDist = (myHRP.Position - kHRP.Position).Magnitude
                    if currentDist <= aggressiveRadius then
                        ExecuteParry()
                        if tracker then tracker:Disconnect() end
                    end
                end)
            end
        else
            if startDistance > Config.Surv_ParryRadius then return end
            local myPosFlat = Vector3.new(myHRP.Position.X, 0, myHRP.Position.Z)
            local kPosFlat  = Vector3.new(kHRP.Position.X, 0, kHRP.Position.Z)
            local flatDelta = myPosFlat - kPosFlat
            if flatDelta.Magnitude > 0 then
                local flatDirection = flatDelta.Unit
                local kLookFlat = Vector3.new(
                    kHRP.CFrame.LookVector.X, 0, kHRP.CFrame.LookVector.Z
                ).Unit
                local isFacing = kLookFlat:Dot(flatDirection)
                if isFacing < Config.Surv_ParryFace then return end
            end
            ExecuteParry()
        end
    end)
end

function TryAttach(p)
    if p ~= LocalPlayer and IsKiller(p) and p.Character then
        AttachParrySensor(p.Character)
    end
end

function SetupPlayer(p)
    if p == LocalPlayer then return end
    p.CharacterAdded:Connect(function() TryAttach(p) end)
    p:GetPropertyChangedSignal("Team"):Connect(function() TryAttach(p) end)
    if p.Character then TryAttach(p) end
end

RunService.RenderStepped:Connect(function()
    local hrp = getRoot()
    if Config.Surv_ParryCircle and Config.Surv_AutoParry and hrp then
        if not State.AutoParryAdornment or State.AutoParryAdornment.Parent ~= hrp then
            if State.AutoParryAdornment then State.AutoParryAdornment:Destroy() end
            State.AutoParryAdornment = Instance.new("CylinderHandleAdornment")
            State.AutoParryAdornment.Name         = "AutoParryCircleESP"
            State.AutoParryAdornment.Height       = 0.05
            State.AutoParryAdornment.Transparency = 0.3
            State.AutoParryAdornment.Adornee      = hrp
            State.AutoParryAdornment.Parent       = hrp
            State.AutoParryAdornment.ZIndex       = 0
            State.AutoParryAdornment.AlwaysOnTop  = false
        end
        local cR = Config.Surv_ParryRadius
        State.AutoParryAdornment.Radius      = cR
        State.AutoParryAdornment.InnerRadius = math.max(0.1, cR - 0.15)
        State.AutoParryAdornment.CFrame      = CFrame.new(0, -3, 0) * CFrame.Angles(math.rad(90), 0, 0)
        if State.ParryCooldown then
            State.AutoParryAdornment.Color3 = Color3.fromRGB(255, 128, 0)
        elseif Config.Surv_ParryAggressive then
            State.AutoParryAdornment.Color3 = Color3.fromRGB(255, 0, 0)
        else
            State.AutoParryAdornment.Color3 = Color3.fromRGB(0, 255, 255)
        end
    elseif State.AutoParryAdornment then
        State.AutoParryAdornment:Destroy()
        State.AutoParryAdornment = nil
    end
end)

-- ============================================================
-- ============== ToF SILENT AIM ==============================
-- ============================================================

local function GetToFTargetPart(char)
    if ToFAim.AimPart == "Head" then
        return char:FindFirstChild("Head")
    elseif ToFAim.AimPart == "Root" or ToFAim.AimPart == "HumanoidRootPart" then
        return char:FindFirstChild("HumanoidRootPart")
    else
        return char:FindFirstChild("Torso")
            or char:FindFirstChild("UpperTorso")
            or char:FindFirstChild("HumanoidRootPart")
    end
end

local function GetToFPistolTarget()
    local myChar = LocalPlayer.Character
    local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    if ToFAim.BlockKnocked and IsDowned(myChar) then return nil end

    local cam      = workspace.CurrentCamera
    local mouseLoc = UserInputService:GetMouseLocation()
    local closestDist = (ToFAim.ShowFOV and ToFAim.UseFOV) and ToFAim.FOV or math.huge
    local bestTarget  = nil

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local valid = false
            if ToFAim.TargetMode == "Killer" and p.Team and p.Team.Name == "Killer" then
                valid = true
            elseif ToFAim.TargetMode == "Survivor" and p.Team and p.Team.Name == "Survivors" then
                valid = true
            end
            if valid then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 and not IsDowned(p.Character) then
                    local targetPart = GetToFTargetPart(p.Character)
                    if targetPart then
                        local screenPos, onScreen = cam:WorldToViewportPoint(targetPart.Position)
                        if onScreen or not ToFAim.UseFOV then
                            local dist = ToFAim.UseFOV
                                and (Vector2.new(screenPos.X, screenPos.Y) - mouseLoc).Magnitude
                                or (targetPart.Position - myHRP.Position).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                bestTarget  = targetPart
                            end
                        end
                    end
                end
            end
        end
    end

    if ToFAim.TargetMode == "SCP" then
        for obj, _ in pairs(ESPCache.SCP) do
            if obj and obj.Parent then
                local part
                if obj:IsA("Model") then
                    part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                elseif obj:IsA("BasePart") then
                    part = obj
                end
                if part then
                    local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
                    if onScreen or not ToFAim.UseFOV then
                        local dist = ToFAim.UseFOV
                            and (Vector2.new(screenPos.X, screenPos.Y) - mouseLoc).Magnitude
                            or (part.Position - myHRP.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            bestTarget  = part
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

local function ExecuteToFSilentFire()
    local myChar = LocalPlayer.Character
    if not myChar then return end
    if ToFAim.BlockKnocked and IsDowned(myChar) then return end

    local targetPart = State.LockedPistolTarget
    if not (targetPart and targetPart.Parent) then
        targetPart = GetToFPistolTarget()
    end
    if not targetPart then return end

    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local twistOfFate = myChar:FindFirstChild("Twist of Fate")
    if not twistOfFate then return end

    local weaponArg = twistOfFate
    local rightArm  = twistOfFate:FindFirstChild("Right Arm")
    if rightArm then
        if rightArm:FindFirstChild("EmperorGun") then
            weaponArg = rightArm:FindFirstChild("EmperorGun")
        elseif rightArm:FindFirstChild("gun") then
            weaponArg = rightArm:FindFirstChild("gun")
        else
            weaponArg = rightArm
        end
    end

    local startPos  = myRoot.Position
    local targetPos = targetPart.Position
    local targetVel = targetPart.AssemblyLinearVelocity
    targetVel = Vector3.new(targetVel.X, 0, targetVel.Z)

    local distance     = (targetPos - startPos).Magnitude
    local timeToHit    = distance / ToFAim.BulletSpeed
    local predictedPos = targetPos + (targetVel * timeToHit) + Vector3.new(0, ToFAim.YOffset, 0)
    local aimDirection = (predictedPos - startPos).Unit

    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local fireRemote = remotes
        and remotes:FindFirstChild("Items")
        and remotes.Items:FindFirstChild("Twist of Fate")
        and remotes.Items["Twist of Fate"]:FindFirstChild("Fire")

    if fireRemote then
        fireRemote:FireServer(weaponArg, aimDirection)
    end
end

local function EnsureToFLaser()
    if State.PistolLaser then return end
    State.PistolLaser = Instance.new("Part")
    State.PistolLaser.Name         = "Wisnu_ToFLaser"
    State.PistolLaser.Material     = Enum.Material.Neon
    State.PistolLaser.Color        = Color3.fromRGB(255, 0, 0)
    State.PistolLaser.CanCollide   = false
    State.PistolLaser.Anchored     = true
    State.PistolLaser.CastShadow   = false
    State.PistolLaser.Size         = Vector3.new(0.05, 0.05, 1)
    State.PistolLaser.Transparency = 0
end

local function EnsureToFFOVCircle()
    if State.FOVCircle then return end
    State.FOVCircle = Drawing.new("Circle")
    State.FOVCircle.Color     = Color3.fromRGB(255, 255, 255)
    State.FOVCircle.Thickness = 1.5
    State.FOVCircle.Filled    = false
    State.FOVCircle.Visible   = false
end
EnsureToFLaser()
EnsureToFFOVCircle()

UserInputService.InputBegan:Connect(function(input, gp)
    local isTouch = input.UserInputType == Enum.UserInputType.Touch
    if gp and not isTouch then return end

    if input.UserInputType == Enum.UserInputType.MouseButton2 and ToFAim.Enabled then
        State.ChargingPistol     = true
        State.LockedPistolTarget = GetToFPistolTarget()
    end
    if input.UserInputType == Enum.UserInputType.MouseButton1
        and ToFAim.Enabled and State.ChargingPistol then
        ExecuteToFSilentFire()
    end
    if isTouch and ToFAim.Enabled then
        local survivorMob = PlayerGui:FindFirstChild("Survivor-mob")
        local controls    = survivorMob and survivorMob:FindFirstChild("Controls")
        local targetBtn   = controls and controls:FindFirstChild("Gui-mob")
        if targetBtn and targetBtn.Visible then
            local pos     = input.Position
            local absPos  = targetBtn.AbsolutePosition
            local absSize = targetBtn.AbsoluteSize
            if pos.X >= absPos.X and pos.X <= (absPos.X + absSize.X)
                and pos.Y >= absPos.Y and pos.Y <= (absPos.Y + absSize.Y) then
                State.ChargingPistol     = true
                State.TouchPistolInput   = input
                State.LockedPistolTarget = GetToFPistolTarget()
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and State.ChargingPistol then
        State.ChargingPistol     = false
        State.LockedPistolTarget = nil
    end
    if input.UserInputType == Enum.UserInputType.Touch
        and input == State.TouchPistolInput and State.ChargingPistol then
        State.ChargingPistol     = false
        State.TouchPistolInput   = nil
        ExecuteToFSilentFire()
        State.LockedPistolTarget = nil
    end
end)

RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    if not cam then return end

    if State.ChargingPistol then
        if State.LockedPistolTarget
            and ToFAim.LockAim
            and State.LockedPistolTarget.Parent
            and State.LockedPistolTarget.Parent:FindFirstChildOfClass("Humanoid")
            and State.LockedPistolTarget.Parent:FindFirstChildOfClass("Humanoid").Health > 0 then
            local targetCFrame = CFrame.lookAt(cam.CFrame.Position, State.LockedPistolTarget.Position)
            cam.CFrame = cam.CFrame:Lerp(targetCFrame, 0.15)
        else
            State.LockedPistolTarget = GetToFPistolTarget()
        end
    end

    if State.ChargingPistol and ToFAim.Enabled then
        local targetPart = GetToFPistolTarget()
        if targetPart then
            EnsureToFLaser()
            local myChar  = LocalPlayer.Character
            local leftArm = myChar and (myChar:FindFirstChild("Left Arm") or myChar:FindFirstChild("LeftHand"))
            local startPos = leftArm and leftArm.Position
                or (myChar and myChar:GetPivot().Position or Vector3.new())
            local targetPos = targetPart.Position
            local targetVel = targetPart.AssemblyLinearVelocity
            targetVel = Vector3.new(targetVel.X, 0, targetVel.Z)
            local distance     = (targetPos - startPos).Magnitude
            local timeToHit    = distance / ToFAim.BulletSpeed
            local predictedPos = targetPos + (targetVel * timeToHit) + Vector3.new(0, -1.2, 0)
            if State.PistolLaser then
                State.PistolLaser.Parent       = workspace
                State.PistolLaser.Transparency = ToFAim.HideLaser and 1 or 0
                local newDist = (predictedPos - startPos).Magnitude
                if newDist > 0 then
                    State.PistolLaser.Size   = Vector3.new(0.05, 0.05, newDist)
                    State.PistolLaser.CFrame = CFrame.new(startPos, predictedPos) * CFrame.new(0, 0, -newDist / 2)
                end
            end
        else
            if State.PistolLaser and State.PistolLaser.Parent then
                State.PistolLaser.Parent = nil
            end
        end
    else
        if State.PistolLaser and State.PistolLaser.Parent then
            State.PistolLaser.Parent = nil
        end
    end

    if ToFAim.Enabled and ToFAim.ShowFOV and ToFAim.UseFOV then
        EnsureToFFOVCircle()
        State.FOVCircle.Visible  = true
        State.FOVCircle.Radius   = ToFAim.FOV
        State.FOVCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        local t = GetToFPistolTarget()
        State.FOVCircle.Color = t and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 100)
    elseif State.FOVCircle then
        State.FOVCircle.Visible = false
    end
end)

-- ============================================================
-- ============== SILENT VEIL (SPEAR AIMBOT) ==================
-- ============================================================

local VeilDraw = {
    FOVCircle = Drawing.new("Circle"),
    Highlight = Instance.new("Highlight"),
    Tracer    = Drawing.new("Circle"),
}

VeilDraw.FOVCircle.Color     = Color3.fromRGB(148, 148, 148)
VeilDraw.FOVCircle.Thickness = 1.5
VeilDraw.FOVCircle.Filled    = false
VeilDraw.FOVCircle.Visible   = false

VeilDraw.Highlight.Name                = "Wisnu_VeilTarget"
VeilDraw.Highlight.FillColor           = Color3.fromRGB(204, 204, 204)
VeilDraw.Highlight.OutlineColor        = Color3.fromRGB(158, 158, 158)
VeilDraw.Highlight.FillTransparency    = 0.5
VeilDraw.Highlight.OutlineTransparency = 0

VeilDraw.Tracer.Thickness = 2
VeilDraw.Tracer.Radius    = 5
VeilDraw.Tracer.Color     = Color3.fromRGB(95, 95, 95)
VeilDraw.Tracer.Filled    = true
VeilDraw.Tracer.Visible   = false

function Veil_GetRealVelocity(part, playerName)
    if not part then return Vector3.zero end
    local currentPos = part.Position
    local currentTime = tick()
    if not VeilVelocityCache[playerName] then
        VeilVelocityCache[playerName] = {lastPos = currentPos, lastTime = currentTime, velocity = Vector3.zero}
        return Vector3.zero
    end
    local cache = VeilVelocityCache[playerName]
    local dt = currentTime - cache.lastTime
    if dt > 0.01 then
        dt = math.min(dt, 0.12)
        local rawVelocity = (currentPos - cache.lastPos) / dt
        if rawVelocity.Magnitude < 100 then
            cache.velocity = cache.velocity:Lerp(rawVelocity, 0.35)
        end
    end
    cache.lastPos = currentPos
    cache.lastTime = currentTime
    return cache.velocity
end

function veil_getTargetPart(char)
    if VeilConfig.TargetPart == "Head" then
        return char:FindFirstChild("Head")
    elseif VeilConfig.TargetPart == "Root" then
        return char:FindFirstChild("HumanoidRootPart")
    else
        return char:FindFirstChild("Torso")
            or char:FindFirstChild("UpperTorso")
            or char:FindFirstChild("HumanoidRootPart")
    end
end

function veil_getClosestSurvivor()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local cam      = workspace.CurrentCamera
    local center   = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local bestDist = VeilConfig.FOV
    local bestTarget = nil

    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
        if p ~= LocalPlayer and p.Team and p.Team.Name == "Survivors" and p.Character then
            local char = p.Character
            local hum  = char:FindFirstChildOfClass("Humanoid")
            local part = veil_getTargetPart(char)
            if hum and hum.Health > 0 and part then
                local dist3D = (part.Position - myRoot.Position).Magnitude
                if dist3D <= VeilConfig.MaxDist then
                    local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist2D < bestDist then
                            bestDist   = dist2D
                            bestTarget = { Player = p, Part = part }
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

function veil_setupInterceptor()
    if VeilState.remoteHooked then return end
    task.spawn(function()
        pcall(function()
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                if not checkcaller() and method == "FireServer" then
                    if self.Name == "Spearthrow" and VeilConfig.Enabled then
                        return nil
                    end
                end
                return oldNamecall(self, ...)
            end)
            VeilState.remoteHooked = true
        end)
    end)
end
veil_setupInterceptor()

function veil_fire()
    if VeilState.attackCooldown then return end
    VeilState.attackCooldown = true
    task.delay(2, function() VeilState.attackCooldown = false end)

    local myChar    = LocalPlayer.Character
    local startPart = myChar and (myChar:FindFirstChild("Head") or myChar:FindFirstChild("HumanoidRootPart"))
    if not startPart then return end

    local startPos   = startPart.Position
    local targetInfo = veil_getClosestSurvivor()
    local aimDir

    if targetInfo and targetInfo.Part then
        local targetPart = targetInfo.Part
        local targetPlayer = targetInfo.Player
        local targetPos = targetPart.Position

        local velocity = Veil_GetRealVelocity(targetPart, targetPlayer.Name)
        local horizontalVel = Vector3.new(velocity.X, 0, velocity.Z)
        local speed = horizontalVel.Magnitude

        local distance = (targetPos - startPos).Magnitude
        local timeToHit = distance / VeilConfig.SpearSpeed

        local horizontalPrediction = Vector3.zero
        if speed > 4 and VeilConfig.AutoPredict then
            local factor = VeilConfig.HorizontalPredictFactor
            horizontalPrediction = horizontalVel * timeToHit * factor
        end
        local predictedPos = targetPos + horizontalPrediction

        local autoGravity = math.max(0, distance - 8)
        local gravity = VeilConfig.AutoPredict and autoGravity or VeilConfig.Gravity
        local drop = 0.5 * gravity * (timeToHit ^ 2)
        local finalPos = predictedPos + Vector3.new(0, drop, 0)

        aimDir = (finalPos - startPos).Unit
        VeilState.lastPredictedPos = finalPos
    else
        aimDir = workspace.CurrentCamera.CFrame.LookVector
        VeilState.lastPredictedPos = nil
    end

    pcall(function()
        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        if remotes then
            local killers = remotes:FindFirstChild("Killers")
            if killers then
                local veil = killers:FindFirstChild("Veil")
                if veil and veil:FindFirstChild("Spearthrow") then
                    veil.Spearthrow:FireServer(aimDir, VeilConfig.SpearSpeed, startPos)
                end
            end
        end
    end)

    VeilDraw.FOVCircle.Color = Color3.fromRGB(128, 128, 128)
    if not VeilState.passiveCooldown then
        VeilState.passiveCooldown = true
        task.delay(30, function()
            VeilDraw.FOVCircle.Color = Color3.fromRGB(128, 128, 128)
            VeilState.passiveCooldown = false
        end)
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    local isTouch = input.UserInputType == Enum.UserInputType.Touch
    if gp and not isTouch then return end
    local char = LocalPlayer.Character
    local isSpearMode = char and char:GetAttribute("spearmode") == true
    if not VeilConfig.Enabled then return end
    if not isSpearMode then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        VeilState.chargingSpear = true
    elseif isTouch then
        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
        if pGui then
            local slasher = pGui:FindFirstChild("Slasher-mob")
            if slasher then
                local ctrl = slasher:FindFirstChild("Controls")
                if ctrl then
                    local attackBtn = ctrl:FindFirstChild("attack")
                    if attackBtn and attackBtn.Visible then
                        local pos     = input.Position
                        local absPos  = attackBtn.AbsolutePosition
                        local absSize = attackBtn.AbsoluteSize
                        if pos.X >= absPos.X and pos.X <= absPos.X + absSize.X
                        and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y then
                            VeilState.chargingSpear = true
                            VeilState.touchInput    = input
                        end
                    end
                end
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if VeilState.chargingSpear
    and (input == VeilState.touchInput or input.UserInputType == Enum.UserInputType.MouseButton1) then
        VeilState.chargingSpear = false
        if VeilState.touchInput == input then VeilState.touchInput = nil end
        veil_fire()
    end
end)

RunService.RenderStepped:Connect(function()
    local cam         = workspace.CurrentCamera
    local myChar      = LocalPlayer.Character
    local isSpearMode = myChar and myChar:GetAttribute("spearmode") == true

    if VeilConfig.Enabled and VeilConfig.ShowFOV and isSpearMode then
        VeilDraw.FOVCircle.Visible  = true
        VeilDraw.FOVCircle.Radius   = VeilConfig.FOV
        VeilDraw.FOVCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    else
        VeilDraw.FOVCircle.Visible = false
    end

    if VeilState.chargingSpear and VeilConfig.Enabled and isSpearMode then
        local target = veil_getClosestSurvivor()
        if target and target.Part and target.Part.Parent then
            VeilDraw.Highlight.Parent = target.Part.Parent

            if VeilConfig.ShowTargetLaser then
                if not getgenv().Wisnu_SpearLaserPart then
                    local laser = Instance.new("Part")
                    laser.Name = "Wisnu_SpearSilentAimLaser"
                    laser.Anchored = true
                    laser.CanCollide = false
                    laser.CanTouch = false
                    laser.CastShadow = false
                    laser.Material = Enum.Material.Neon
                    laser.Color = Color3.fromRGB(128, 128, 128)
                    laser.Transparency = 0
                    laser.Parent = workspace
                    getgenv().Wisnu_SpearLaserPart = laser
                end

                local originPart = myChar and (myChar:FindFirstChild("Head") or myChar:FindFirstChild("HumanoidRootPart"))
                if originPart then
                    local originPos = originPart.Position
                    local targetPos = target.Part.Position
                    local dist = (targetPos - originPos).Magnitude
                    if dist > 0.1 then
                        local laser = getgenv().Wisnu_SpearLaserPart
                        laser.Size = Vector3.new(0.16, 0.16, dist)
                        laser.CFrame = CFrame.new((originPos + targetPos) / 2, targetPos)
                        laser.Transparency = 0.5
                    end
                end
            else
                if getgenv().Wisnu_SpearLaserPart then getgenv().Wisnu_SpearLaserPart.Transparency = 1 end
            end
        else
            VeilDraw.Highlight.Parent = nil
            if getgenv().Wisnu_SpearLaserPart then getgenv().Wisnu_SpearLaserPart.Transparency = 1 end
        end
    else
        VeilDraw.Highlight.Parent = nil
        if getgenv().Wisnu_SpearLaserPart then getgenv().Wisnu_SpearLaserPart.Transparency = 1 end
    end

    if VeilConfig.Enabled and isSpearMode and VeilState.lastPredictedPos then
        local screenPos, onScreen = cam:WorldToViewportPoint(VeilState.lastPredictedPos)
        local viewport = cam.ViewportSize
        local center = Vector2.new(viewport.X / 2, viewport.Y / 2)

        if onScreen then
            VeilDraw.Tracer.Position = Vector2.new(screenPos.X, screenPos.Y)
        else
            local dx = screenPos.X - center.X
            local dy = screenPos.Y - center.Y
            if math.abs(dx) < 1 and math.abs(dy) < 1 then
                VeilDraw.Tracer.Position = center
            else
                local maxX = viewport.X / 2 - 10
                local maxY = viewport.Y / 2 - 10
                local scaleX = maxX / math.abs(dx)
                local scaleY = maxY / math.abs(dy)
                local scale = math.min(scaleX, scaleY)
                local borderPos = Vector2.new(
                    center.X + dx * scale,
                    center.Y + dy * scale
                )
                VeilDraw.Tracer.Position = borderPos
            end
        end
        VeilDraw.Tracer.Visible = true
    else
        VeilDraw.Tracer.Visible = false
    end
end)

-- ============================================================
-- ============== SILENT AIM FLASHLIGHT =======================
-- ============================================================
local function Flash_GetTargetPart(char)
    if FlashConfig.TargetPart == "Head" then
        return char:FindFirstChild("Head")
    elseif FlashConfig.TargetPart == "UpperTorso" then
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    elseif FlashConfig.TargetPart == "Torso" then
        return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    else
        return char:FindFirstChild("HumanoidRootPart")
    end
end

local function Flash_IsAlive(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    return char:GetAttribute("State") ~= "Dead"
end

local function Flash_GetTarget()
    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end

    local maxRange = tonumber(FlashConfig.Range) or 120
    local bestPart, bestScore = nil, math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and Flash_IsAlive(player.Character) then
            local isKiller = player.Team and player.Team.Name == "Killer"
            if isKiller then
                local part = Flash_GetTargetPart(player.Character)
                if part then
                    local dist = (localRoot.Position - part.Position).Magnitude
                    if dist <= maxRange and dist < bestScore then
                        bestScore = dist
                        bestPart  = part
                    end
                end
            end
        end
    end
    return bestPart
end

local function Flash_ClearLaser()
    if FlashState.LaserBeam then
        pcall(function() FlashState.LaserBeam:Destroy() end)
        FlashState.LaserBeam = nil
    end
end

local function Flash_GetOrigin(cam)
    local source = FlashState.FlashlightPart
    if typeof and typeof(source) == "Instance" then
        if source:IsA("BasePart") then return source.Position end
        local part = source:FindFirstChildWhichIsA("BasePart", true)
        if part then return part.Position end
    end

    local char = LocalPlayer.Character
    local hand = char and (
        char:FindFirstChild("RightHand")
        or char:FindFirstChild("Right Arm")
        or char:FindFirstChild("HumanoidRootPart")
    )
    if hand and hand:IsA("BasePart") then return hand.Position end
    return cam and cam.CFrame.Position or nil
end

local function Flash_UpdateLaser(originPos, targetPos)
    if not FlashState.LaserBeam then
        local laser = Instance.new("Part")
        laser.Name        = "Wisnu_FlashLaser"
        laser.Anchored    = true
        laser.CanCollide  = false
        laser.CanTouch    = false
        laser.CastShadow  = false
        laser.Material    = Enum.Material.Neon
        laser.Color       = Color3.fromRGB(255, 255, 255)
        laser.Transparency = 0
        laser.Parent      = workspace
        FlashState.LaserBeam = laser
    end

    local dist = (targetPos - originPos).Magnitude
    if dist < 0.1 then return end

    local laser = FlashState.LaserBeam
    laser.Size = Vector3.new(0.16, 0.16, dist)
    laser.CFrame = CFrame.new((originPos + targetPos) / 2, targetPos)
    laser.Transparency = 0
end

local function Flash_AimStep()
    if not (FlashConfig.Enabled and FlashState.Active) then
        if FlashState.LaserBeam then FlashState.LaserBeam.Transparency = 1 end
        return
    end

    local cam = workspace.CurrentCamera
    local targetPart = Flash_GetTarget()
    if not (cam and targetPart) then
        if FlashState.LaserBeam then FlashState.LaserBeam.Transparency = 1 end
        return
    end

    local targetPos = targetPart.Position + Vector3.new(0, FlashConfig.YOffset, 0)
    local smooth    = math.clamp(tonumber(FlashConfig.Smooth) or 0.35, 0.05, 1)
    local originPos = Flash_GetOrigin(cam)

    if FlashConfig.Laser and originPos then
        Flash_UpdateLaser(originPos, targetPos)
    elseif FlashState.LaserBeam then
        FlashState.LaserBeam.Transparency = 1
    end

    pcall(function()
        cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, targetPos), smooth)
    end)

    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z))
        end
    end)
end

local function Flash_Start()
    getgenv().Wisnu_FlashlightActivateRemote = (function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local items = remotes and remotes:FindFirstChild("Items")
        local flashlight = items and items:FindFirstChild("Flashlight")
        local activate = flashlight and flashlight:FindFirstChild("Activate")
        return activate and activate:IsA("RemoteEvent") and activate or nil
    end)()

    if FlashState.Connection then return end
    FlashState.Connection = RunService.RenderStepped:Connect(Flash_AimStep)
end

local function Flash_Stop()
    FlashState.Active = false
    FlashState.FlashlightPart = nil
    Flash_ClearLaser()
    if FlashState.Connection then
        pcall(function() FlashState.Connection:Disconnect() end)
        FlashState.Connection = nil
    end
end

local function Flash_SetEnabled(v)
    FlashConfig.Enabled = v and true or false
    if v then
        Flash_Start()
    else
        Flash_Stop()
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == FlashConfig.Keybind then
        FlashConfig.KeyActive = not FlashConfig.KeyActive
        FlashState.Active = FlashConfig.KeyActive
    end
end)

-- ============================================================
-- ============== AIMLOCK ATTACK (ALFzxzzz - Mouse1) ==========
-- ============================================================
local function AttackAim_IsVisible(part)
    local cam = workspace.CurrentCamera
    if not cam then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character }
    local origin = cam.CFrame.Position
    local direction = part.Position - origin
    local result = workspace:Raycast(origin, direction, params)
    if not result then return true end
    return result.Instance:IsDescendantOf(part.Parent)
end

local function AttackAim_GetTarget()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local closest, shortest = nil, AttackAim.FOV

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local valid = false
            if AttackAim.TargetMode == "Survivor" and p.Team and p.Team.Name == "Survivors" then
                valid = true
            elseif AttackAim.TargetMode == "Killer" and p.Team and p.Team.Name == "Killer" then
                valid = true
            end

            if valid then
                local hrp = p.Character:FindFirstChild(AttackAim.AimPart)
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local pos, visible = cam:WorldToViewportPoint(hrp.Position)
                    if visible then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist < shortest then
                            if AttackAim.VisibilityCheck and not AttackAim_IsVisible(hrp) then continue end
                            shortest = dist
                            closest  = hrp
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function AttackAim_Update()
    if not AttackAim.Enabled then
        if AttackAimState.FOVCircle then AttackAimState.FOVCircle.Visible = false end
        return
    end
    if not AttackAimState.Holding then
        if AttackAimState.FOVCircle then AttackAimState.FOVCircle.Visible = false end
        return
    end

    local cam = workspace.CurrentCamera
    if not cam then return end

    local target = AttackAim_GetTarget()
    if target then
        local pos = target.Position
        if AttackAim.Predict then
            pos = pos + (target.AssemblyLinearVelocity * AttackAim.PredictStrength)
        end
        cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, pos), AttackAim.Strength)
    end

    if AttackAimState.FOVCircle then
        AttackAimState.FOVCircle.Visible  = AttackAim.ShowFOV
        AttackAimState.FOVCircle.Radius   = AttackAim.FOV
        AttackAimState.FOVCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        AttackAimState.FOVCircle.Color    = target and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 100)
    end
end

AttackAimState.FOVCircle = Drawing.new("Circle")
AttackAimState.FOVCircle.Thickness = 1.5
AttackAimState.FOVCircle.Filled    = false
AttackAimState.FOVCircle.Visible   = false

RunService.RenderStepped:Connect(AttackAim_Update)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        AttackAimState.Holding = true
    end
    if input.KeyCode == AttackAim.Keybind then
        AttackAim.Enabled = not AttackAim.Enabled
        Library:Notify({
            Title = "Aimlock Attack",
            Description = AttackAim.Enabled and "Enabled" or "Disabled",
            Time = 2
        })
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        AttackAimState.Holding = false
    end
end)

-- ============================================================
-- ============== AIMLOCK ATTACK (WISNU - Mouse2) =============
-- ============================================================
WisnuAttackAimState.FOVCircle = Drawing.new("Circle")
WisnuAttackAimState.FOVCircle.Thickness = 1.5
WisnuAttackAimState.FOVCircle.Filled    = false
WisnuAttackAimState.FOVCircle.Visible   = false

local function WisnuAttackAim_IsVisible(part)
    local cam = workspace.CurrentCamera
    if not cam then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character }
    local origin = cam.CFrame.Position
    local direction = part.Position - origin
    local result = workspace:Raycast(origin, direction, params)
    if not result then return true end
    return result.Instance:IsDescendantOf(part.Parent)
end

local function WisnuAttackAim_GetTarget()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local closest, shortest = nil, WisnuAttackAim.FOV

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local valid = false
            if WisnuAttackAim.TargetMode == "Survivor" and p.Team and p.Team.Name == "Survivors" then
                valid = true
            elseif WisnuAttackAim.TargetMode == "Killer" and p.Team and p.Team.Name == "Killer" then
                valid = true
            end

            if valid then
                local hrp = p.Character:FindFirstChild(WisnuAttackAim.AimPart)
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local pos, visible = cam:WorldToViewportPoint(hrp.Position)
                    if visible then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist < shortest then
                            if WisnuAttackAim.VisibilityCheck and not WisnuAttackAim_IsVisible(hrp) then continue end
                            shortest = dist
                            closest  = hrp
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function WisnuAttackAim_Update()
    if not WisnuAttackAim.Enabled then
        if WisnuAttackAimState.FOVCircle then WisnuAttackAimState.FOVCircle.Visible = false end
        return
    end
    if not WisnuAttackAim.Holding then
        if WisnuAttackAimState.FOVCircle then WisnuAttackAimState.FOVCircle.Visible = false end
        return
    end

    local cam = workspace.CurrentCamera
    if not cam then return end

    local target = WisnuAttackAim_GetTarget()
    if target then
        local pos = target.Position
        if WisnuAttackAim.Predict then
            pos = pos + (target.AssemblyLinearVelocity * WisnuAttackAim.PredictStrength)
        end
        cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, pos), WisnuAttackAim.Strength)
    end

    if WisnuAttackAimState.FOVCircle then
        WisnuAttackAimState.FOVCircle.Visible  = WisnuAttackAim.ShowFOV
        WisnuAttackAimState.FOVCircle.Radius   = WisnuAttackAim.FOV
        WisnuAttackAimState.FOVCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        WisnuAttackAimState.FOVCircle.Color    = target and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 100)
    end
end

RunService.RenderStepped:Connect(WisnuAttackAim_Update)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        WisnuAttackAim.Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        WisnuAttackAim.Holding = false
    end
end)

-- ============================================================
-- ============== AIMLOCK ATTACK SPEAR MODE ===================
-- ============================================================
SpearAimState.FOVCircle = Drawing.new("Circle")
SpearAimState.FOVCircle.Thickness = 1.5
SpearAimState.FOVCircle.Filled    = false
SpearAimState.FOVCircle.Visible   = false

local function SpearAim_IsVisible(part)
    local cam = workspace.CurrentCamera
    if not cam then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character }
    local origin = cam.CFrame.Position
    local direction = part.Position - origin
    local result = workspace:Raycast(origin, direction, params)
    if not result then return true end
    return result.Instance:IsDescendantOf(part.Parent)
end

local function SpearAim_GetTarget()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local closest, shortest = nil, SpearAim.FOV

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local valid = false
            if SpearAim.TargetMode == "Survivor" and p.Team and p.Team.Name == "Survivors" then
                valid = true
            elseif SpearAim.TargetMode == "Killer" and p.Team and p.Team.Name == "Killer" then
                valid = true
            end

            if valid then
                local hrp = p.Character:FindFirstChild(SpearAim.AimPart)
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local pos, visible = cam:WorldToViewportPoint(hrp.Position)
                    if visible then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist < shortest then
                            if SpearAim.VisibilityCheck and not SpearAim_IsVisible(hrp) then continue end
                            shortest = dist
                            closest  = hrp
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function SpearAim_CalcAimPos(startPos, targetPos)
    local distance = (targetPos - startPos).Magnitude
    local time     = distance / (SpearAim.Speed or 100)
    local drop     = 0.5 * (SpearAim.Gravity or 50) * time * time
    return targetPos + Vector3.new(0, drop, 0)
end

local function SpearAim_Update()
    if not SpearAim.Enabled then
        if SpearAimState.FOVCircle then SpearAimState.FOVCircle.Visible = false end
        return
    end
    if not SpearAimState.Holding then
        if SpearAimState.FOVCircle then SpearAimState.FOVCircle.Visible = false end
        return
    end

    local cam = workspace.CurrentCamera
    if not cam then return end

    local target = SpearAim_GetTarget()
    if target then
        local startPos = cam.CFrame.Position
        local aimPos   = SpearAim_CalcAimPos(startPos, target.Position)
        cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, aimPos), SpearAim.Strength)
    end

    if SpearAimState.FOVCircle then
        SpearAimState.FOVCircle.Visible  = SpearAim.ShowFOV
        SpearAimState.FOVCircle.Radius   = SpearAim.FOV
        SpearAimState.FOVCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        SpearAimState.FOVCircle.Color    = target and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 100)
    end
end

RunService.RenderStepped:Connect(SpearAim_Update)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        SpearAimState.Holding = true
    end
    if input.KeyCode == SpearAim.Keybind then
        SpearAim.Enabled = not SpearAim.Enabled
        Library:Notify({
            Title = "Aimlock Spear",
            Description = SpearAim.Enabled and "Enabled" or "Disabled",
            Time = 2
        })
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        SpearAimState.Holding = false
    end
end)

-- ============================================================
-- ============== DASH LOCK (KILLER) ==========================
-- ============================================================
local function DashLock_GetClosestSurvivor()
    local myRoot = getRoot()
    if not myRoot then return nil, math.huge end
    local closest, closestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team and p.Team.Name == "Survivors" and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local dist = (hrp.Position - myRoot.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest     = hrp
                end
            end
        end
    end
    return closest, closestDist
end

local function DashLock_Update()
    if not DashLockConfig.Enabled then
        if DashLockState.Active then
            DashLockState.Active = false
            DashLockState.Target = nil
            if DashLockConfig.FreezeDuringDash then
                local char = LocalPlayer.Character
                local hum  = char and char:FindFirstChildOfClass("Humanoid")
                if hum and hum.WalkSpeed == 0 then hum.WalkSpeed = 16 end
            end
        end
        return
    end

    if not DashLockState.Active then return end

    local target, dist = DashLock_GetClosestSurvivor()
    if not target then return end
    DashLockState.Target = target

    local cam = workspace.CurrentCamera
    if cam then
        local smoothFactor = DashLockConfig.Smoothness or 0.3
        cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, target.Position), smoothFactor)
    end

    if DashLockConfig.FreezeDuringDash then
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= 0 then hum.WalkSpeed = 0 end
    end
end

local function DashLock_SetActive(v)
    if v == DashLockState.Active then return end
    DashLockState.Active = v

    if v then
        if not DashLockState.Connection then
            DashLockState.Connection = RunService.RenderStepped:Connect(DashLock_Update)
        end
    else
        if DashLockState.Connection then
            DashLockState.Connection:Disconnect()
            DashLockState.Connection = nil
        end
        if DashLockConfig.FreezeDuringDash then
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed == 0 then hum.WalkSpeed = 16 end
        end
        DashLockState.Target = nil
    end
end

local function DashLock_HookCharacter(char)
    if not char then return end
    task.spawn(function()
        local humanoid = char:WaitForChild("Humanoid", 5)
        if not humanoid then return end
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if not animator then
            animator = humanoid:WaitForChild("Animator", 5)
        end
        if not animator then return end

        animator.AnimationPlayed:Connect(function(track)
            if not DashLockConfig.Enabled then return end
            if track.Animation and track.Animation.AnimationId == DashLockConfig.DashAnimationId then
                DashLock_SetActive(true)
                task.delay(DashLockConfig.Duration or 1.5, function()
                    DashLock_SetActive(false)
                end)
            end
        end)
    end)
end

if LocalPlayer.Character then
    DashLock_HookCharacter(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(DashLock_HookCharacter)

local DashIndicator = Drawing.new("Text")
DashIndicator.Visible = false
DashIndicator.Size    = 16
DashIndicator.Color   = Color3.fromRGB(255, 80, 80)
DashIndicator.Center  = true
DashIndicator.Outline = true

RunService.RenderStepped:Connect(function()
    if DashLockConfig.Enabled and DashLockConfig.ShowIndicator and DashLockState.Active then
        local cam = workspace.CurrentCamera
        if cam then
            DashIndicator.Position = Vector2.new(cam.ViewportSize.X / 2, 60)
            DashIndicator.Text     = "DASH LOCK ACTIVE"
            DashIndicator.Visible  = true
        end
    else
        DashIndicator.Visible = false
    end
end)

-- ============================================================
-- ============== SILENT FLASK (CURE) =========================
-- ============================================================
local function Flask_GetTargetPart(char)
    if FlaskConfig.TargetPart == "Head" then
        return char:FindFirstChild("Head")
    elseif FlaskConfig.TargetPart == "Torso" then
        return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    else
        return char:FindFirstChild("HumanoidRootPart")
    end
end

local function Flask_GetClosestSurvivor()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local closest, closestDist = nil, FlaskConfig.MaxDist
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team and p.Team.Name == "Survivors" and p.Character then
            local hum  = p.Character:FindFirstChildOfClass("Humanoid")
            local part = Flask_GetTargetPart(p.Character)
            if hum and hum.Health > 0 and part then
                local dist = (part.Position - myRoot.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest     = { Player = p, Part = part }
                end
            end
        end
    end
    return closest
end

local function Flask_SetupInterceptor()
    if FlaskState.remoteHooked then return end
    task.spawn(function()
        pcall(function()
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                if not checkcaller() and method == "FireServer" then
                    if self.Name == "ThrowFlask" and FlaskConfig.SilentAim then
                        local args = {...}
                        local targetInfo = Flask_GetClosestSurvivor()
                        if targetInfo and targetInfo.Part then
                            if args[2] and typeof(args[2]) == "Vector3" then
                                args[1] = (targetInfo.Part.Position - args[2]).Unit
                            else
                                args[1] = (targetInfo.Part.Position - LocalPlayer.Character.HumanoidRootPart.Position).Unit
                            end
                            setnamecallmethod(method)
                            return oldNamecall(self, unpack(args))
                        end
                    end
                end
                return oldNamecall(self, ...)
            end)
            FlaskState.remoteHooked = true
        end)
    end)
end
Flask_SetupInterceptor()

local function Flask_UpdateLaser()
    local char = LocalPlayer.Character
    if not char then return end

    local targetInfo = Flask_GetClosestSurvivor()
    local originPart = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not originPart then return end

    local actionActive = false
    for _, child in pairs(char:GetChildren()) do
        if child:IsA("LocalScript") and child:GetAttribute("action") == true then
            actionActive = true
            break
        end
    end

    if targetInfo and targetInfo.Part and actionActive and FlaskConfig.ShowLaser then
        if not FlaskState.LaserPart then
            local laser = Instance.new("Part")
            laser.Name        = "Wisnu_FlaskSilentAimLaser"
            laser.Anchored    = true
            laser.CanCollide  = false
            laser.CanTouch    = false
            laser.CastShadow  = false
            laser.Material    = Enum.Material.Neon
            laser.Color       = Color3.fromRGB(255, 255, 255)
            laser.Transparency = 0
            laser.Parent      = workspace
            FlaskState.LaserPart = laser
        end

        local originPos = originPart.Position
        local targetPos = targetInfo.Part.Position
        local dist = (targetPos - originPos).Magnitude
        if dist > 0.1 then
            FlaskState.LaserPart.Size = Vector3.new(0.16, 0.16, dist)
            FlaskState.LaserPart.CFrame = CFrame.new((originPos + targetPos) / 2, targetPos)
            FlaskState.LaserPart.Transparency = 0.5
        end
    else
        if FlaskState.LaserPart then
            FlaskState.LaserPart.Transparency = 1
        end
    end
end

local function Flask_StartLaser()
    if FlaskState.LaserConnection then return end
    FlaskState.LaserConnection = RunService.RenderStepped:Connect(function()
        if not FlaskConfig.Enabled then
            if FlaskState.LaserPart then
                pcall(function() FlaskState.LaserPart:Destroy() end)
                FlaskState.LaserPart = nil
            end
            if FlaskState.LaserConnection then
                FlaskState.LaserConnection:Disconnect()
                FlaskState.LaserConnection = nil
            end
            return
        end
        pcall(Flask_UpdateLaser)
    end)
end

local function Flask_SetSilentAim(v)
    FlaskConfig.Enabled   = v and true or false
    FlaskConfig.SilentAim = v and true or false
    if v then
        Flask_StartLaser()
    else
        if FlaskState.LaserConnection then
            FlaskState.LaserConnection:Disconnect()
            FlaskState.LaserConnection = nil
        end
        if FlaskState.LaserPart then
            pcall(function() FlaskState.LaserPart:Destroy() end)
            FlaskState.LaserPart = nil
        end
    end
end

-- ============================================================
-- ============== SURVIVOR: AUTO SKILLCHECK ===================
-- ============================================================
function Survivor_PressSkill()
    local isMobile2 = UserInputService.TouchEnabled
    if isMobile2 then
        local btn = PlayerGui:FindFirstChild("check", true)
        if btn and btn:IsA("GuiObject") then
            local pos   = btn.AbsolutePosition
            local size  = btn.AbsoluteSize
            local inset = game:GetService("GuiService"):GetGuiInset()
            local x = pos.X + (size.X / 2) + inset.X
            local y = pos.Y + (size.Y / 2) + inset.Y
            pcall(function() VirtualInputManager:SendTouchEvent(8822, Enum.UserInputState.Begin.Value, x, y) end)
            task.wait(0.01)
            pcall(function() VirtualInputManager:SendTouchEvent(8822, Enum.UserInputState.End.Value, x, y) end)
            pcall(function()
                if firesignal and btn.MouseButton1Click then
                    firesignal(btn.MouseButton1Click)
                end
            end)
        end
    else
        pcall(function() VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game) end)
        task.wait(0.01)
        pcall(function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end)
    end
end

function Survivor_GetSkillCheck()
    for _, guiName in ipairs({ "SkillCheckPromptGui", "SkillCheckPromptGui-con" }) do
        local gui = PlayerGui:FindFirstChild(guiName, true)
        if gui then
            local check = gui:FindFirstChild("Check", true)
            if check and check.Visible then
                local line = check:FindFirstChild("Line", true)
                local goal = check:FindFirstChild("Goal", true)
                if line and goal then return line, goal end
            end
        end
    end
end

function Survivor_AngularDelta(from, to)
    local d = to - from
    if d > 180 then d = d - 360 end
    if d < -180 then d = d + 360 end
    return d
end

function Survivor_CrossedZone(prevLr, lr, startPos, endPos)
    local function inZone(r)
        if startPos > endPos then
            return r >= startPos or r <= endPos
        end
        return r >= startPos and r <= endPos
    end
    if inZone(lr) then return true end
    if prevLr == nil then return false end
    local delta = Survivor_AngularDelta(prevLr, lr)
    local steps = math.abs(math.floor(delta))
    if steps < 2 then return false end
    local stepSize = delta / steps
    for i = 1, steps do
        if inZone((prevLr + stepSize * i) % 360) then return true end
    end
    return false
end

function Survivor_SkillCheckUpdate()
    if not SurvivorConfig.AutoSkillCheck then return end
    if SurvivorState.LastSkillCheckBusy then return end

    if SurvivorConfig.SkillCheckMode == "Instant" then
        local prompt = PlayerGui:FindFirstChild("SkillCheckPromptGui")
        if not prompt then prompt = PlayerGui:FindFirstChild("SkillCheckPromptGui-con") end
        if not prompt then return end

        local check = prompt:FindFirstChild("Check")
        if not check or not check.Visible then return end

        local line = check:FindFirstChild("Line")
        local goal = check:FindFirstChild("Goal")
        if not line or not goal then return end

        line.Rotation = goal.Rotation + 109

        SurvivorState.LastSkillCheckBusy = true
        task.spawn(function()
            Survivor_PressSkill()
            task.wait(0.2)
            SurvivorState.LastSkillCheckBusy = false
        end)
        return
    end

    local line, goal = Survivor_GetSkillCheck()
    if not (line and goal) then
        SurvivorState.LastGoalRotation = nil
        SurvivorState.HasClickedThisGoal = false
        SurvivorState.LastLineRotation = nil
        SurvivorState.LastTick = nil
        SurvivorState.WasActive = false
        return
    end

    local lr = line.Rotation % 360
    local gr = goal.Rotation % 360
    local now = os.clock()
    if not SurvivorState.WasActive then
        SurvivorState.WasActive = true
        SurvivorState.HasClickedThisGoal = false
        SurvivorState.LastGoalRotation = gr
        SurvivorState.LastLineRotation = lr
        SurvivorState.LastTick = now
        return
    end
    if SurvivorState.LastGoalRotation and math.abs(Survivor_AngularDelta(SurvivorState.LastGoalRotation, gr)) > 5 then
        SurvivorState.HasClickedThisGoal = false
        SurvivorState.LastLineRotation = nil
        SurvivorState.LastTick = nil
    end
    SurvivorState.LastGoalRotation = gr
    if SurvivorState.HasClickedThisGoal then
        SurvivorState.LastLineRotation = lr
        SurvivorState.LastTick = now
        return
    end
    if SurvivorState.LastLineRotation and SurvivorState.LastTick then
        local dt = now - SurvivorState.LastTick
        if dt > 0 then
            local lineSpeed = Survivor_AngularDelta(SurvivorState.LastLineRotation, lr) / dt
            local predicted = (lr + lineSpeed * dt * 0) % 360
            if Survivor_CrossedZone(SurvivorState.LastLineRotation, predicted, (gr + 104) % 360, (gr + 109) % 360) then
                SurvivorState.HasClickedThisGoal = true
                task.spawn(function()
                    task.wait(0.03)
                    Survivor_PressSkill()
                end)
            end
        end
    end
    SurvivorState.LastLineRotation = lr
    SurvivorState.LastTick = now
end

RunService.RenderStepped:Connect(function()
    pcall(Survivor_SkillCheckUpdate)
end)

-- ============================================================
-- ============== FLEE KILLER (Survivor) ======================
-- ============================================================
function Survivor_GetNearestKiller()
    local root = getRoot()
    if not root then return nil, math.huge end
    local closest, shortest = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsKiller(p) and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist < shortest then shortest = dist; closest = hrp end
            end
        end
    end
    return closest, shortest
end

function Survivor_GetFarthestGeneratorPoint(killerRoot)
    if not killerRoot then return nil end
    local bestPoint, farthestDistance = nil, 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.match(obj.Name, "^GeneratorPoint%d+$") then
            local dist = (obj.Position - killerRoot.Position).Magnitude
            if dist > farthestDistance then
                farthestDistance = dist; bestPoint = obj
            end
        end
    end
    return bestPoint
end

task.spawn(function()
    while task.wait(0.2) do
        if not SurvivorConfig.FleeKiller then continue end
        local root = getRoot()
        if not root then continue end
        local killerRoot, distance = Survivor_GetNearestKiller()
        if killerRoot and distance <= (SurvivorConfig.FleeDistance or 40) then
            local point = Survivor_GetFarthestGeneratorPoint(killerRoot)
            if point then
                root.CFrame = point.CFrame + Vector3.new(0, 5, 0)
            end
        end
    end
end)

-- ============================================================
-- ============== SWIFT VAULT =================================
-- ============================================================
local _vaultedWindows = {}
local _lastVaultScan  = 0

RunService.Heartbeat:Connect(function()
    if not SurvivorConfig.SwiftVault then return end
    local char = LocalPlayer.Character
    if not char then return end

    if tick() - _lastVaultScan < 0.15 then return end
    _lastVaultScan = tick()

    pcall(function()
        local myRoot = char:FindFirstChild("HumanoidRootPart")
        local hum    = char:FindFirstChildOfClass("Humanoid")
        if not myRoot or not hum or hum.Health <= 0 then return end

        local vel = myRoot.AssemblyLinearVelocity
        if vel.Magnitude < 1 then return end

        local remotes   = ReplicatedStorage:FindFirstChild("Remotes")
        local winFolder = remotes and remotes:FindFirstChild("Window")
        local vaultEv   = winFolder and winFolder:FindFirstChild("VaultCommit")
        if not vaultEv then return end

        local windowGroups = {}
        for _, win in ipairs(ESPCache.Windows or {}) do
            local part = win.part or win.model
            if part then
                local rootWindow = part.Parent
                if part.Name == "VaultPoint" and part.Parent and part.Parent.Name == "VaultTrigger" then
                    rootWindow = part.Parent.Parent
                elseif part.Name == "VaultTrigger" and part.Parent then
                    rootWindow = part.Parent
                end
                if rootWindow then
                    windowGroups[rootWindow] = windowGroups[rootWindow] or {}
                    local exists = false
                    for _, p in ipairs(windowGroups[rootWindow]) do
                        if p == part then exists = true break end
                    end
                    if not exists then table.insert(windowGroups[rootWindow], part) end
                end
            end
        end

        for rootWindow, _ in pairs(windowGroups) do
            local function getVTPosition(vt)
                if vt:IsA("BasePart") then return vt.Position end
                if vt:IsA("Model") then
                    if vt.PrimaryPart then return vt.PrimaryPart.Position end
                    local bp = vt:FindFirstChildWhichIsA("BasePart", true)
                    if bp then return bp.Position end
                end
                return nil
            end

            local allVTs = {}
            for _, child in ipairs(rootWindow:GetChildren()) do
                if child.Name == "VaultTrigger" then
                    table.insert(allVTs, child)
                end
            end
            if #allVTs == 0 then continue end

            local nearestVT, nearestVTDist = nil, math.huge
            for _, vt in ipairs(allVTs) do
                local pos = getVTPosition(vt)
                if pos then
                    local d = (myRoot.Position - pos).Magnitude
                    if d < nearestVTDist then
                        nearestVTDist = d
                        nearestVT = vt
                    end
                end
            end

            if not nearestVT or nearestVTDist > 6.0 then continue end

            local lastUsed = _vaultedWindows[rootWindow] or 0
            if tick() - lastUsed < 3.0 then continue end

            local finalTarget = nearestVT
            local remotes2 = ReplicatedStorage:FindFirstChild("Remotes")
            local winFold  = remotes2 and remotes2:FindFirstChild("Window")
            if winFold and finalTarget then
                local vaultEvent     = winFold:FindFirstChild("VaultEvent")
                local vaultBindable  = winFold:FindFirstChild("Vaultbindable")
                local fastvault      = winFold:FindFirstChild("fastvault")
                local vaultComplete1 = winFold:FindFirstChild("VaultCompleteEventpart1")
                local vaultComplete  = winFold:FindFirstChild("VaultCompleteEvent")

                if vaultEvent     then pcall(function() vaultEvent:FireServer(finalTarget, true) end) end
                if vaultBindable  then pcall(function() vaultBindable:Fire(finalTarget, true) end) end
                if fastvault      then pcall(function() fastvault:FireServer(LocalPlayer) end) end
                if vaultComplete1 then pcall(function() vaultComplete1:FireServer() end) end
                if vaultComplete  then pcall(function() vaultComplete:FireServer(finalTarget, false) end) end
            end

            _vaultedWindows[rootWindow] = tick()
            break
        end
    end)
end)

RunService.Heartbeat:Connect(function()
    if SurvivorConfig.SwiftVaultV2 then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                char:SetAttribute("vaultspeed", (SurvivorConfig.SwiftVaultSpeed or 13) / 10)
            end
        end)
    end
end)

function Survivor_SetSwiftVaultV2(v)
    SurvivorConfig.SwiftVaultV2 = v and true or false
    if not v then
        local char = LocalPlayer.Character
        if char then char:SetAttribute("vaultspeed", 1) end
    end
end

-- ============================================================
-- ============== AURA HEAL (SELF) ============================
-- ============================================================
local InstantHealConnection = nil

local function HealSelf_Start()
    local healActive = false
    if InstantHealConnection then InstantHealConnection:Disconnect() end

    InstantHealConnection = RunService.Heartbeat:Connect(function()
        if not SurvivorConfig.InstantHealSelf then return end
        local myChar = LocalPlayer.Character
        local myHum  = myChar and myChar:FindFirstChildOfClass("Humanoid")
        if not myHum then return end

        if myHum.Health >= myHum.MaxHealth * 0.9 then
            if healActive then
                healActive = false
                local healRemote = ReplicatedStorage:FindFirstChild("Remotes")
                    and ReplicatedStorage.Remotes:FindFirstChild("Healing")
                    and ReplicatedStorage.Remotes.Healing:FindFirstChild("HealEvent")
                local hrp = myChar:FindFirstChild("HumanoidRootPart")
                if healRemote and hrp then
                    pcall(function() healRemote:FireServer(hrp, false) end)
                end
            end
            return
        end

        if healActive then
            local checkScript = myChar:FindFirstChild("CheckInterractable")
            if checkScript and not checkScript:GetAttribute("isHealing") then
                healActive = false
            end
        end

        if not healActive then
            healActive = true
            pcall(function()
                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                local healing = remotes and remotes:FindFirstChild("Healing")
                local healRemote = healing and healing:FindFirstChild("HealEvent")
                local skillCheckRemote = healing and healing:FindFirstChild("SkillCheckResultEvent")
                local hrp = myChar:FindFirstChild("HumanoidRootPart")
                if healRemote and hrp then
                    healRemote:FireServer(hrp, true)
                end
                if skillCheckRemote then
                    skillCheckRemote:FireServer("success", 100, myChar)
                end
            end)
        end
    end)
end

function Survivor_SetInstantHealSelf(v)
    SurvivorConfig.InstantHealSelf = v and true or false
    if v then
        HealSelf_Start()
    else
        if InstantHealConnection then
            InstantHealConnection:Disconnect()
            InstantHealConnection = nil
        end
        pcall(function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local healing = remotes and remotes:FindFirstChild("Healing")
            local healRemote = healing and healing:FindFirstChild("HealEvent")
            local myChar = LocalPlayer.Character
            local hrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if healRemote and hrp then
                healRemote:FireServer(hrp, false)
            end
        end)
    end
end

-- ============================================================
-- ============== AURA HEAL FLOATING BUTTON ===================
-- ============================================================
local SelfHealButton = {
    UI       = nil,
    Button   = nil,
    Stroke   = nil,
    Label    = nil,
    Dragging = false,
    DragStart = nil,
    DragStartPos = nil,
}

function SelfHeal_UpdateButton()
    if not SelfHealButton.Button then return end
    if SurvivorConfig.InstantHealSelf then
        SelfHealButton.Button.BackgroundColor3 = Color3.fromRGB(20, 75, 35)
        SelfHealButton.Label.TextColor3        = Color3.fromRGB(120, 255, 160)
        SelfHealButton.Stroke.Color            = Color3.fromRGB(80, 255, 130)
        SelfHealButton.Label.Text              = "HEAL\nON"
    else
        SelfHealButton.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        SelfHealButton.Label.TextColor3        = Color3.fromRGB(220, 220, 220)
        SelfHealButton.Stroke.Color            = Color3.fromRGB(180, 180, 180)
        SelfHealButton.Label.Text              = "HEAL\nOFF"
    end
end

function SelfHeal_DestroyButton()
    if SelfHealButton.UI then
        pcall(function() SelfHealButton.UI:Destroy() end)
    end
    SelfHealButton.UI       = nil
    SelfHealButton.Button   = nil
    SelfHealButton.Stroke   = nil
    SelfHealButton.Label    = nil
    SelfHealButton.Dragging = false
end

function SelfHeal_CreateButton()
    local pg = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10)
    if not pg then return end

    SelfHeal_DestroyButton()

    local gui = Instance.new("ScreenGui")
    gui.Name          = "WisnuSelfHealUI"
    gui.ResetOnSpawn  = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder  = 999998
    gui.Parent        = pg
    SelfHealButton.UI = gui

    local btn = Instance.new("TextButton")
    btn.Name                 = "SelfHealButton"
    btn.Size                 = UDim2.fromOffset(65, 65)
    btn.Position             = UDim2.new(0.78, 0, 0.75, 0)
    btn.AnchorPoint          = Vector2.new(0.5, 0.5)
    btn.BackgroundColor3     = Color3.fromRGB(25, 25, 35)
    btn.BackgroundTransparency = 0.12
    btn.AutoButtonColor      = false
    btn.Text                 = ""
    btn.ZIndex               = 10
    btn.Parent               = gui

    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness       = 2
    stroke.Transparency    = 0.05
    stroke.Color           = Color3.fromRGB(180, 180, 180)
    stroke.Parent          = btn

    local label = Instance.new("TextLabel")
    label.Size                 = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text                 = "HEAL\nOFF"
    label.TextColor3           = Color3.fromRGB(220, 220, 220)
    label.TextScaled           = true
    label.Font                 = Enum.Font.GothamBold
    label.ZIndex               = 11
    label.Parent               = btn

    SelfHealButton.Button = btn
    SelfHealButton.Stroke = stroke
    SelfHealButton.Label  = label

    SelfHeal_UpdateButton()

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            if SurvivorConfig.DragLockedHealBtn then return end
            SelfHealButton.Dragging     = true
            SelfHealButton.DragStart    = input.Position
            SelfHealButton.DragStartPos = btn.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if SelfHealButton.Dragging
            and not SurvivorConfig.DragLockedHealBtn
            and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - SelfHealButton.DragStart
            btn.Position = UDim2.new(
                SelfHealButton.DragStartPos.X.Scale, SelfHealButton.DragStartPos.X.Offset + delta.X,
                SelfHealButton.DragStartPos.Y.Scale, SelfHealButton.DragStartPos.Y.Offset + delta.Y
            )
        end
    end)

    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            SelfHealButton.Dragging = false
        end
    end)

    btn.MouseButton1Click:Connect(function()
        Survivor_SetInstantHealSelf(not SurvivorConfig.InstantHealSelf)
        SelfHeal_UpdateButton()
        if Window and Window.ConfigElements then
            local elem = Window.ConfigElements["InstantHealSelf"]
            if elem and elem.Set then
                pcall(function() elem:Set(SurvivorConfig.InstantHealSelf) end)
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if SurvivorConfig.ShowHealButton then
        SelfHeal_CreateButton()
    end
end)

-- ============================================================
-- ============== FAKE PERKS ==================================
-- ============================================================
local function FP_Char() return LocalPlayer.Character end
local function FP_Hum()
    local c = FP_Char()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function FP_GetTotalSpeedBuff()
    local total = 0
    for name, b in pairs(FakePerksState.ActiveBuffs) do
        if tick() < b.endTime then
            total = total + b.amt
        end
    end
    return total
end

local function FP_ApplySpeed()
    local char = FP_Char()
    local hum  = FP_Hum()
    local totalBuff = FP_GetTotalSpeedBuff()

    if char then
        if totalBuff > 0 then
            local multiplier = 1 + (totalBuff / 14)
            char:SetAttribute("speedboost", multiplier)
        else
            char:SetAttribute("speedboost", 1)
        end
    end

    if hum then
        local base = 16
        if totalBuff > 0 then
            hum.WalkSpeed = base + totalBuff
        end
    end
end

local function FP_EnsureHB()
    if FakePerksState.HB then return end
    FakePerksState.HB = RunService.Heartbeat:Connect(function()
        local expired = {}
        for name, b in pairs(FakePerksState.ActiveBuffs) do
            if tick() >= b.endTime then
                table.insert(expired, name)
            end
        end
        for _, name in ipairs(expired) do
            FakePerksState.ActiveBuffs[name] = nil
        end

        if #expired > 0 then
            if FP_GetTotalSpeedBuff() <= 0 then
                FakePerksState.LastBuffEnd = tick()
            end
        end

        FP_ApplySpeed()

        if FP_GetTotalSpeedBuff() <= 0 and next(FakePerksState.ActiveBuffs) == nil then
            if FakePerksState.HB then FakePerksState.HB:Disconnect(); FakePerksState.HB = nil end
            local char = FP_Char()
            if char then char:SetAttribute("speedboost", 1) end
        end
    end)
end

local function FP_TryBuff(name, amt, dur)
    if FakePerksState.ActiveBuffs[name] then return end
    if tick() - FakePerksState.LastBuffEnd < FakePerksState.CooldownTime and next(FakePerksState.ActiveBuffs) == nil then return end

    FakePerksState.ActiveBuffs[name] = { amt = amt, endTime = tick() + dur }
    FP_ApplySpeed()
    FP_EnsureHB()
    Library:Notify({ Title = "Fake Perks", Description = "[" .. name .. "] Aktif! +" .. amt .. " Speed (" .. dur .. "s)", Time = 3 })
end

local function FP_Clean(name)
    if FakePerksState.Conns[name] then
        for _, c in ipairs(FakePerksState.Conns[name]) do pcall(function() c:Disconnect() end) end
        FakePerksState.Conns[name] = nil
    end
end

local function FP_Reg(name, conn)
    if not FakePerksState.Conns[name] then FakePerksState.Conns[name] = {} end
    table.insert(FakePerksState.Conns[name], conn)
end

function Survivor_ToggleFlowstate(v)
    FakePerksState.FlowstateOn = v
    local char = FP_Char()
    if char then char:SetAttribute("Flowstate", v) end

    if v then
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        local w = r and r:FindFirstChild("Window")
        local p = r and r:FindFirstChild("Pallet")

        local function onVaultAction()
            if not FakePerksState.FlowstateOn then return end
            task.delay(0.5, function()
                if FakePerksState.FlowstateOn then
                    FP_TryBuff("Flowstate", 5, 3)
                end
            end)
        end

        if w then
            local vb = w:FindFirstChild("Vaultbindable")
            if vb and vb:IsA("BindableEvent") then
                FP_Reg("Flowstate", vb.Event:Connect(onVaultAction))
            end
        end
        if p then
            local sb = p:FindFirstChild("Slidebindable")
            if sb and sb:IsA("BindableEvent") then
                FP_Reg("Flowstate", sb.Event:Connect(onVaultAction))
            end
        end
    else
        FP_Clean("Flowstate")
        FakePerksState.ActiveBuffs["Flowstate"] = nil
        local c = FP_Char()
        if c then c:SetAttribute("Flowstate", false) end
    end
end

function Survivor_ToggleQuickRecovery(v)
    FakePerksState.QuickRecOn = v
    if v then
        local function onHealed()
            if not FakePerksState.QuickRecOn then return end
            FP_TryBuff("QuickRecovery", 6, 3)
        end

        local function hookHealth(c)
            if not c then return end
            local hum = c:FindFirstChildOfClass("Humanoid")
            if hum then
                local lastHP = hum.Health
                local conn = hum.HealthChanged:Connect(function(newHP)
                    if not FakePerksState.QuickRecOn then return end
                    if newHP > lastHP and (newHP >= hum.MaxHealth or (newHP - lastHP) >= 15) then
                        onHealed()
                    end
                    lastHP = newHP
                end)
                FP_Reg("QuickRecovery", conn)
            end
        end
        hookHealth(LocalPlayer.Character)
        FP_Reg("QuickRecovery", LocalPlayer.CharacterAdded:Connect(hookHealth))
    else
        FP_Clean("QuickRecovery")
        FakePerksState.ActiveBuffs["QuickRecovery"] = nil
    end
end

function Survivor_TogglePerfectLanding(v)
    FakePerksState.PerfLandOn = v
    if v then
        local function hookFall(c)
            if not c then return end
            local hum = c:FindFirstChildOfClass("Humanoid")
            if not hum then return end

            local wasFalling = false
            local fallStart = 0
            local conn = hum.StateChanged:Connect(function(old, new)
                if not FakePerksState.PerfLandOn then return end
                if new == Enum.HumanoidStateType.Freefall then
                    wasFalling = true
                    fallStart = tick()
                end
                if wasFalling and (new == Enum.HumanoidStateType.Landed or new == Enum.HumanoidStateType.Running) then
                    local fallTime = tick() - fallStart
                    wasFalling = false
                    if fallTime >= 0.25 then
                        FP_TryBuff("PerfectLanding", 8, 3)
                    end
                end
            end)
            FP_Reg("PerfectLanding", conn)
        end
        hookFall(LocalPlayer.Character)
        FP_Reg("PerfectLanding", LocalPlayer.CharacterAdded:Connect(hookFall))
    else
        FP_Clean("PerfectLanding")
        FakePerksState.ActiveBuffs["PerfectLanding"] = nil
    end
end

function Survivor_ToggleAdrenalineRush(v)
    FakePerksState.AdrenalineOn = v
    if v then
        local function hookDamage(c)
            if not c then return end
            local hum = c:FindFirstChildOfClass("Humanoid")
            if not hum then return end

            local lastHP = hum.Health
            local conn = hum.HealthChanged:Connect(function(newHP)
                if not FakePerksState.AdrenalineOn then return end
                if newHP < lastHP and newHP <= 50 and newHP > 0 then
                    FP_TryBuff("AdrenalineRush", 4, 5)
                end
                lastHP = newHP
            end)
            FP_Reg("AdrenalineRush", conn)
        end
        hookDamage(LocalPlayer.Character)
        FP_Reg("AdrenalineRush", LocalPlayer.CharacterAdded:Connect(hookDamage))
    else
        FP_Clean("AdrenalineRush")
        FakePerksState.ActiveBuffs["AdrenalineRush"] = nil
    end
end

-- =====================================================
-- GEN BOOST BYPASS (dari ALFzxzzz)
-- =====================================================
GenBypass = {
    Enabled     = false,
    Button      = nil,
    UI          = nil,
    Cache       = {},
    CacheTimer  = 0,
    Processed   = {},
    HotkeyCode  = Enum.KeyCode.G,
}

function GB_GetAllGenerators()
    local now = tick()
    if now - GenBypass.CacheTimer < 5 then return GenBypass.Cache end
    GenBypass.Cache = {}
    GenBypass.CacheTimer = now
    local mapFolder = workspace:FindFirstChild("Map")
    if not mapFolder then return GenBypass.Cache end
    pcall(function()
        for _, v in pairs(mapFolder:GetDescendants()) do
            if not v:IsA("Model") then continue end
            if v.Name ~= "Generator" then continue end
            local isReal = v:GetAttribute("RepairProgress") ~= nil
                or v:GetAttribute("kickcount") ~= nil
                or v:GetAttribute("ProgressRepair") ~= nil
            if isReal then table.insert(GenBypass.Cache, v) end
        end
    end)
    return GenBypass.Cache
end

function GB_GetPoints(genModel)
    local points = {}
    pcall(function()
        for _, obj in pairs(genModel:GetChildren()) do
            if obj.Name:find("GeneratorPoint") and obj:IsA("BasePart") then
                table.insert(points, obj)
            end
        end
    end)
    return points
end

function GB_WaitRepairing(point, timeout)
    local start = tick()
    while tick() - start < (timeout or 1) do
        if point:GetAttribute("IsRepairing") == true then return true end
        task.wait(0.05)
    end
    return false
end

function GB_DoRepair(targetPoint)
    local genModel = targetPoint.Parent
    if GenBypass.Processed[genModel] then return end
    GenBypass.Processed[genModel] = true

    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then GenBypass.Processed[genModel] = nil return end

    local RepairEvent = ReplicatedStorage:FindFirstChild("Remotes")
        and ReplicatedStorage.Remotes:FindFirstChild("Generator")
        and ReplicatedStorage.Remotes.Generator:FindFirstChild("RepairEvent")

    local originalCFrame = hrp.CFrame
    pcall(function()
        for _, point in pairs(GB_GetPoints(genModel)) do
            if point ~= targetPoint and point.Parent then
                hrp.Anchored = true
                hrp.CFrame = point.CFrame
                task.wait(0.15)
                pcall(function() if RepairEvent then RepairEvent:FireServer(point, true) end end)
                if not GB_WaitRepairing(point, 0.8) then
                    pcall(function() if RepairEvent then RepairEvent:FireServer(point, false) end end)
                    task.wait(0.1)
                    hrp.CFrame = point.CFrame
                    task.wait(0.15)
                    pcall(function() if RepairEvent then RepairEvent:FireServer(point, true) end end)
                    GB_WaitRepairing(point, 0.5)
                end
                hrp.Anchored = false
                task.wait(0.05)
            end
        end
    end)
    pcall(function()
        if hrp and hrp.Parent then
            hrp.Anchored = false
            hrp.CFrame = originalCFrame
        end
    end)
    task.wait(0.1)
    pcall(function() if RepairEvent then RepairEvent:FireServer(targetPoint, false) end end)
    GenBypass.Processed[genModel] = nil
end

function GB_GetNearestPoint()
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local bestPoint, bestDist = nil, math.huge
    for _, gen in pairs(GB_GetAllGenerators()) do
        for _, point in pairs(GB_GetPoints(gen)) do
            local d = (hrp.Position - point.Position).Magnitude
            if d < bestDist then bestDist = d; bestPoint = point end
        end
    end
    return bestPoint, bestDist
end

function GB_IsPromptVisible()
    local ok, frame = pcall(function()
        return LocalPlayer.PlayerGui.pcprompts.Frame.GeneratorRepair
    end)
    return ok and frame and frame.Visible
end

function GB_UpdateButton()
    if GenBypass.Button then
        GenBypass.Button.Visible = GenBypass.Enabled and isMobile
    end
end

function GB_CreateButton()
    local oldUI = LocalPlayer.PlayerGui:FindFirstChild("BypassGenUI")
    if oldUI then oldUI:Destroy() end

    GenBypass.UI = Instance.new("ScreenGui")
    GenBypass.UI.Name = "BypassGenUI"
    GenBypass.UI.ResetOnSpawn = false
    GenBypass.UI.IgnoreGuiInset = true
    GenBypass.UI.Parent = LocalPlayer:WaitForChild("PlayerGui")

    GenBypass.Button = Instance.new("ImageButton")
    GenBypass.Button.Name = "BypassGenButton"
    GenBypass.Button.Size = UDim2.new(0, 60, 0, 60)
    GenBypass.Button.Position = UDim2.new(0.88, 0, 0.55, 0)
    GenBypass.Button.AnchorPoint = Vector2.new(0.5, 0.5)
    GenBypass.Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    GenBypass.Button.BackgroundTransparency = 0.15
    GenBypass.Button.AutoButtonColor = true
    GenBypass.Button.Visible = false
    GenBypass.Button.ZIndex = 10
    GenBypass.Button.Parent = GenBypass.UI
    Instance.new("UICorner", GenBypass.Button).CornerRadius = UDim.new(1, 0)

    local s = Instance.new("UIStroke", GenBypass.Button)
    s.Color = Color3.fromRGB(255, 255, 255)
    s.Thickness = 2; s.Transparency = 0.2

    local lbl = Instance.new("TextLabel", GenBypass.Button)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "GEN"
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBlack
    lbl.ZIndex = 11

    GenBypass.Button.MouseButton1Click:Connect(function()
        if not GenBypass.Enabled then return end
        local bestPoint, bestDist = GB_GetNearestPoint()
        if bestPoint and bestDist <= 8 then GB_DoRepair(bestPoint) end
    end)
end

GB_CreateButton()

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    GB_CreateButton()
    GB_UpdateButton()
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if isMobile then return end
    if input.KeyCode == GenBypass.HotkeyCode and GenBypass.Enabled then
        if not GB_IsPromptVisible() then return end
        local bestPoint, bestDist = GB_GetNearestPoint()
        if not bestPoint or bestDist > 8 then return end
        if GenBypass.Processed[bestPoint.Parent] then return end
        GB_DoRepair(bestPoint)
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if not GenBypass.Enabled then return end
    if not GB_IsPromptVisible() then return end
    local bestPoint, bestDist = GB_GetNearestPoint()
    if not bestPoint or bestDist > 8 then return end
    if GenBypass.Processed[bestPoint.Parent] then return end
    GB_DoRepair(bestPoint)
end)

task.spawn(function()
    while true do
        task.wait(2)
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for genModel in pairs(GenBypass.Processed) do
                if not genModel or not genModel.Parent then
                    GenBypass.Processed[genModel] = nil
                    continue
                end
                local nearAny = false
                for _, point in pairs(GB_GetPoints(genModel)) do
                    if point.Parent and (hrp.Position - point.Position).Magnitude <= 10 then
                        nearAny = true; break
                    end
                end
                if not nearAny then GenBypass.Processed[genModel] = nil end
            end
        end
    end
end)

function setGenBypass(v)
    GenBypass.Enabled = v
    GB_UpdateButton()
end

-- ============================================================
-- ============== KILLER INFINITE SKILL =======================
-- ============================================================

function StartAbyssCooldownBypass()
    if not KillerState.CorruptHandlerFunc then
        for _, v in pairs(getgc(true)) do
            if type(v) == "function" and islclosure(v) then
                local constants = debug.getconstants(v)
                if table.find(constants, "corrupt") and table.find(constants, "Immobile") then
                    KillerState.CorruptHandlerFunc = v
                    break
                end
            end
        end
    end

    if not KillerState.CorruptHandlerFunc then return end

    if KillerState.AbyssConnection then
        KillerState.AbyssConnection:Disconnect()
    end

    KillerState.AbyssConnection = RunService.Heartbeat:Connect(function()
        if not KillerConfig.InfAbyssalBurst then return end
        if KillerState.CorruptHandlerFunc then
            local upvalues = debug.getupvalues(KillerState.CorruptHandlerFunc)
            for idx, val in pairs(upvalues) do
                if type(val) == "boolean" then
                    if val == false then
                        debug.setupvalue(KillerState.CorruptHandlerFunc, idx, true)
                    end
                end
            end
        end
    end)
end

function StopAbyssCooldownBypass()
    if KillerState.AbyssConnection then
        KillerState.AbyssConnection:Disconnect()
        KillerState.AbyssConnection = nil
    end
end

function StartHiddenCooldownBypass()
    if KillerState.HiddenBypassThread then return end
    KillerState.HiddenBypassThread = task.spawn(function()
        local leapFunction, m2Function

        local function scanGC()
            pcall(function()
                for _, v in pairs(getgc(true)) do
                    if type(v) == "function" and islclosure(v) then
                        local info
                        pcall(function() info = debug.getinfo(v) end)
                        if info then
                            if info.name == "tryActivate" then
                                leapFunction = v
                            elseif info.name == "playM2Animation" then
                                m2Function = v
                            end
                        end
                    end
                    if leapFunction and m2Function then break end
                end
            end)
        end

        scanGC()

        local lastScan = os.clock()
        while task.wait(0.1) do
            if not KillerConfig.InfHiddenSkill then break end

            if not (leapFunction and m2Function) then
                local now = os.clock()
                if now - lastScan >= 2 then
                    lastScan = now
                    scanGC()
                end
            end

            if leapFunction then
                pcall(function()
                    for i, val in pairs(debug.getupvalues(leapFunction)) do
                        if type(val) == "boolean" and val == true then
                            debug.setupvalue(leapFunction, i, false)
                        end
                    end
                end)
            end
            if m2Function then
                pcall(function()
                    for i, val in pairs(debug.getupvalues(m2Function)) do
                        if type(val) == "boolean" and val == true then
                            debug.setupvalue(m2Function, i, false)
                        end
                    end
                end)
            end
        end
        KillerState.HiddenBypassThread = nil
    end)
end

function StopHiddenCooldownBypass() end

function StartJeffCooldownBypass()
    if KillerState.JeffBypassThread then return end
    KillerState.JeffBypassThread = task.spawn(function()
        while task.wait() do
            if not KillerConfig.InfFrenzy then break end
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:GetAttribute("Frenzy") ~= true then
                    char:SetAttribute("Frenzy", true)
                end
            end)
        end
        KillerState.JeffBypassThread = nil
    end)
end

function StopJeffCooldownBypass()
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:GetAttribute("Frenzy") == true then
            char:SetAttribute("Frenzy", false)
            local killer = ReplicatedStorage:FindFirstChild("Remotes")
                and ReplicatedStorage.Remotes:FindFirstChild("Killers")
                and ReplicatedStorage.Remotes.Killers:FindFirstChild("Killer")
            if killer then
                local deact = killer:FindFirstChild("Deactivatefromclient")
                if deact then deact:FireServer() end
            end
        end
    end)
end

function StartSlasherCooldownBypass()
    if KillerState.SlasherBypassThread then return end

    pcall(function()
        local b = true
        local mt = debug.getmetatable(b)
        if not mt then
            mt = {}
            debug.setmetatable(b, mt)
        end
        if setreadonly then setreadonly(mt, false) end
        mt.__div = function() return 0 end
        mt.__mul = function() return 0 end
        mt.__add = function() return 0 end
        mt.__sub = function() return 0 end
        if setreadonly then setreadonly(mt, true) end
    end)

    KillerState.SlasherBypassThread = task.spawn(function()
        local toggleFunc = nil
        local pursuitHandler = nil

        local function scanGCForSlasher()
            pcall(function()
                for _, v in pairs(getgc(true)) do
                    if type(v) == "function" and islclosure(v) then
                        local consts = debug.getconstants(v)
                        local hasOffset, hasLinear, hasAction, hasTweenInfo = false, false, false, false
                        local hasPursuit, hasWalkSpeed = false, false

                        for _, c in pairs(consts) do
                            if c == "Offset" then hasOffset = true end
                            if c == "Linear" then hasLinear = true end
                            if c == "action" then hasAction = true end
                            if c == "TweenInfo" then hasTweenInfo = true end
                            if c == "Pursuit" then hasPursuit = true end
                            if c == "WalkSpeed" then hasWalkSpeed = true end
                        end

                        if hasOffset and hasLinear and hasAction and hasTweenInfo and not hasPursuit then
                            toggleFunc = v
                        end
                        if hasPursuit and hasTweenInfo and hasAction and hasWalkSpeed then
                            pursuitHandler = v
                        end
                    end
                    if toggleFunc and pursuitHandler then break end
                end
            end)
        end

        scanGCForSlasher()
        local lastScan = os.clock()

        while task.wait(0.1) do
            if not KillerConfig.InfLakeMist and not KillerConfig.InfPursuit then break end

            if not (toggleFunc and pursuitHandler) then
                if os.clock() - lastScan >= 2 then
                    scanGCForSlasher()
                    lastScan = os.clock()
                end
            end

            if toggleFunc and KillerConfig.InfLakeMist then
                pcall(function()
                    debug.setupvalue(toggleFunc, 6, false)
                    debug.setupvalue(toggleFunc, 10, false)
                end)
            end
            if pursuitHandler and KillerConfig.InfPursuit then
                pcall(function()
                    debug.setupvalue(pursuitHandler, 5, false)
                    debug.setupvalue(pursuitHandler, 6, false)
                end)
            end
        end

        KillerState.SlasherBypassThread = nil
    end)
end

function StopSlasherCooldownBypass()
    pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        local jason = rs:FindFirstChild("Remotes")
            and rs.Remotes:FindFirstChild("Killers")
            and rs.Remotes.Killers:FindFirstChild("Jason")
        if jason then
            if not KillerConfig.InfLakeMist then
                local lm = jason:FindFirstChild("LakeMist")
                if lm then lm:FireServer(false) end
            end
            if not KillerConfig.InfPursuit then
                local ps = jason:FindFirstChild("Pursuit")
                if ps then ps:FireServer(false) end
            end
        end
    end)
end

function UpdateInfiniteLunge()
    local char = LocalPlayer.Character
    if not char then return end

    if KillerConfig.InfLunge then
        if char:GetAttribute("lungeboost") ~= 999999 then
            KillerState.OriginalLungeBoost = char:GetAttribute("lungeboost") or 1
            char:SetAttribute("lungeboost", 999999)
        end
    else
        if KillerState.OriginalLungeBoost then
            char:SetAttribute("lungeboost", KillerState.OriginalLungeBoost)
            KillerState.OriginalLungeBoost = nil
        end
    end
end

function SetupKillerAntiStun()
    if KillerState.AntiStunHooked then return end
    KillerState.AntiStunHooked = true

    pcall(function()
        local ok, mt = pcall(function() return getrawmetatable(game) end)
        if ok and mt and setreadonly then
            pcall(function()
                setreadonly(mt, false)
                local oldNI = mt.__newindex
                mt.__newindex = newcclosure(function(t, k, v)
                    if k == "WalkSpeed" or k == "Anchored" then
                        if not checkcaller() and KillerConfig.NoSlowdown then
                            if k == "WalkSpeed" and typeof(v) == "number" and v < 16
                                and typeof(t) == "Instance" and t:IsA("Humanoid") then
                                return oldNI(t, k, 16)
                            end
                            if k == "Anchored" and v == true
                                and typeof(t) == "Instance" and t:IsA("BasePart")
                                and t.Name == "HumanoidRootPart" then
                                return oldNI(t, k, false)
                            end
                        end
                    end
                    return oldNI(t, k, v)
                end)
                setreadonly(mt, true)
            end)
        end
    end)
end
task.spawn(SetupKillerAntiStun)

function MAWWW_AutoAttack()
    if not KillerConfig.AutoAttack then return end
    local role = LocalPlayer.Team and LocalPlayer.Team.Name or ""
    if role ~= "Killer" then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Team and player.Team.Name == "Survivors" then
            local tRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local tHum  = player.Character:FindFirstChildOfClass("Humanoid")
            if tRoot and tHum and tHum.MaxHealth > 0 then
                local pct = tHum.Health / tHum.MaxHealth
                if pct > 0.25 and (tRoot.Position - root.Position).Magnitude <= (KillerConfig.AutoAttackRange or 12) then
                    pcall(function()
                        local r = ReplicatedStorage:FindFirstChild("Remotes")
                        local a = r and r:FindFirstChild("Attacks")
                        local b = a and a:FindFirstChild("BasicAttack")
                        if b then b:FireServer(false) end
                    end)
                    break
                end
            end
        end
    end
end

function MAWWW_BlockAllPalletDrops()
    if not KillerConfig.AutoDropAllPallet then return end
    local role = LocalPlayer.Team and LocalPlayer.Team.Name or ""
    if role ~= "Killer" then return end

    local now = tick()
    if now - KillerState.LastPalletBlockTime < 2 then return end
    KillerState.LastPalletBlockTime = now

    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local palletFold = remotes and remotes:FindFirstChild("Pallet")
        local dropEvent = palletFold and palletFold:FindFirstChild("PalletDropEvent")
        if not dropEvent then return end

        local map = workspace:FindFirstChild("Map")
        if not map then return end

        for _, obj in ipairs(map:GetDescendants()) do
            if obj.Name == "Palletwrong" and (obj:IsA("Model") or obj:IsA("Folder")) then
                local target = obj:FindFirstChild("PalletPointSlide") or obj:FindFirstChild("PalletPoint")
                if target then
                    pcall(function() dropEvent:FireServer(target) end)
                end
            end
        end
    end)
end

function MAWWW_BlockAllVaults()
    if not KillerConfig.BlockAllVaults then return end
    local role = LocalPlayer.Team and LocalPlayer.Team.Name or ""
    if role ~= "Killer" then return end

    local now = tick()
    if now - KillerState.LastVaultBlockTime < 1.5 then return end
    KillerState.LastVaultBlockTime = now

    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local vaultEvent = remotes and remotes:FindFirstChild("Window") and remotes.Window:FindFirstChild("VaultEvent")
        if not vaultEvent then return end

        local map = workspace:FindFirstChild("Map")
        local vaultsFolder = map and map:FindFirstChild("Vaults")

        if vaultsFolder then
            for _, vault in ipairs(vaultsFolder:GetChildren()) do
                for _, part in ipairs(vault:GetChildren()) do
                    if part:IsA("BasePart") then
                        pcall(function() vaultEvent:FireServer(part, true) end)
                    end
                end
            end
        else
            for window in pairs(ESPCache.Windows) do
                if window and window.Parent then
                    for _, child in ipairs(window:GetDescendants()) do
                        if child:IsA("BasePart") then
                            pcall(function() vaultEvent:FireServer(child, true) end)
                        end
                    end
                end
            end
        end
    end)
end

function MAWWW_ToggleCounterParry(enabled)
    if not enabled then
        if KillerState.FakeAttackThread then
            task.cancel(KillerState.FakeAttackThread)
            KillerState.FakeAttackThread = nil
        end
        return
    end

    if KillerState.FakeAttackThread then return end

    KillerState.FakeAttackThread = task.spawn(function()
        while KillerConfig.CounterParry do
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                local animator = hum and hum:FindFirstChild("Animator")
                if animator then
                    local myRoot = char:FindFirstChild("HumanoidRootPart")
                    local near = false
                    if myRoot then
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and p.Team and p.Team.Name == "Survivors" then
                                local r = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                                if r and (myRoot.Position - r.Position).Magnitude <= 15 then
                                    near = true
                                    break
                                end
                            end
                        end
                    end

                    if near then
                        pcall(function()
                            local bait = Instance.new("Animation")
                            bait.AnimationId = "rbxassetid://117042998468241"
                            local track = animator:LoadAnimation(bait)
                            track:Play()
                            track:AdjustWeight(0)
                            task.wait(0.05)
                            track:Stop()
                        end)
                    end
                end
            end
            task.wait(0.3)
        end
        KillerState.FakeAttackThread = nil
    end)
end

task.spawn(function()
    while true do
        task.wait(0.1)
        pcall(MAWWW_AutoAttack)
        pcall(MAWWW_BlockAllPalletDrops)
        pcall(MAWWW_BlockAllVaults)
    end
end)

-- ============================================================
-- ============== UI ==========================================
-- ============================================================

local Window = Library:CreateWindow({
    Title  = "Wisnu Hub",
    Footer = "ESP + Combat + Survivor + Killer + Visual | v15",
    Icon   = "92826170205694",
    IconSize = UDim2.fromOffset(50, 50),
    NotifySide = "Right",
    EnableSidebarResize = true,
    EnableCompacting = true,
    SidebarCompacted = true,
    Size = UDim2.fromOffset(500, 800),
    CornerRadius = 20,
    AutoShow = true,
})

local Tabs = {
    ESP      = Window:AddTab("ESP", "eye"),
    Combat   = Window:AddTab("Combat", "swords"),
    Survivor = Window:AddTab("Survivor", "user"),
    Killer   = Window:AddTab("Killer", "skull"),
    Visual   = Window:AddTab("Visual", "sparkles"),
    UI       = Window:AddTab("UI Settings", "settings-2"),
}

-- ============== TAB 1: ESP =================
local ESPBox       = Tabs.ESP:AddLeftGroupbox("ESP Cham", "scan-eye")
local ESPStatusBox = Tabs.ESP:AddRightGroupbox("ESP Status", "scan-eye")

local SurvivorESP = ESPBox:AddCheckbox("SurvivorESP", {
    Text = "ESP Survivor", Default = false,
    Callback = function(v) ESP.Survivor = v end
})
SurvivorESP:AddColorPicker("SurvivorESPColor", {
    Default = TeamColors.Survivor, Title = "Survivor Color",
    Callback = function(color) TeamColors.Survivor = color end
})

local KillerESP = ESPBox:AddCheckbox("KillerESP", {
    Text = "ESP Killer", Default = false,
    Callback = function(v) ESP.Killer = v end
})
KillerESP:AddColorPicker("KillerESPColor", {
    Default = TeamColors.Killer, Title = "Killer Color",
    Callback = function(color) TeamColors.Killer = color end
})

local ESPGeneratorToggle = ESPBox:AddCheckbox("ESPGenerator", {
    Text = "Generator", Default = false,
    Callback = function(v) ESP.Generator = v end
})
ESPGeneratorToggle:AddColorPicker("GeneratorColor", {
    Default = GeneratorColor, Title = "Generator Color",
    Callback = function(v) GeneratorColor = v end
})

local ESPSCPToggle = ESPBox:AddCheckbox("ESPSCP", {
    Text = "SCP", Default = false,
    Callback = function(v) ESP.SCP = v end
})
ESPSCPToggle:AddColorPicker("SCPColor", {
    Default = SCPColor, Title = "SCP Color",
    Callback = function(v) SCPColor = v end
})

local ESPPalletToggle = ESPBox:AddCheckbox("ESPPallet", {
    Text = "Pallet", Default = false,
    Callback = function(v) ESP.Pallet = v end
})
ESPPalletToggle:AddColorPicker("PalletColor", {
    Default = PalletColor, Title = "Pallet Color",
    Callback = function(v) PalletColor = v end
})

local ESPWindowToggle = ESPBox:AddCheckbox("ESPWindow", {
    Text = "Window", Default = false,
    Callback = function(v) ESP.Window = v end
})
ESPWindowToggle:AddColorPicker("WindowColor", {
    Default = WindowColor, Title = "Window Color",
    Callback = function(v) WindowColor = v end
})

ESPBox:AddSlider("ESPDistance", {
    Text = "ESP Radius", Default = 100, Min = 10, Max = 1000, Rounding = 0,
    Callback = function(v) ESP.Distance = v end
})

ESPStatusBox:AddCheckbox("EnableStatus", {
    Text = "Enable Status ESP", Default = false,
    Callback = function(v) ESPStatus.Enabled = v end
})
ESPStatusBox:AddCheckbox("ShowName", {
    Text = "Show Name", Default = true,
    Callback = function(v) ESPStatus.ShowName = v end
})
ESPStatusBox:AddCheckbox("ShowItemESP", {
    Text = "Show Item", Default = true,
    Callback = function(v) ESPStatus.ShowItem = v end
})
ESPStatusBox:AddCheckbox("ShowDistance", {
    Text = "Show Distance", Default = true,
    Callback = function(v) ESPStatus.ShowDistance = v end
})
ESPStatusBox:AddCheckbox("ShowHealth", {
    Text = "Show Health", Default = false,
    Callback = function(v) ESPStatus.ShowHealth = v end
})
ESPStatusBox:AddSlider("StatusRadius", {
    Text = "Status Radius", Default = 100, Min = 20, Max = 500, Rounding = 0,
    Callback = function(v) ESPStatus.Radius = v end
})

-- ============== TAB 2: COMBAT =================
local ParryBox         = Tabs.Combat:AddLeftGroupbox("Auto Parry", "swords")
local AttackAimBox     = Tabs.Combat:AddLeftGroupbox("Aimlock Attack (Mouse1)", "crosshair")
local WisnuAttackAimBox= Tabs.Combat:AddLeftGroupbox("Aimlock Attack (Mouse2)", "crosshair")
local SpearAimBox      = Tabs.Combat:AddLeftGroupbox("Aimlock Spear", "sword")
local DashLockBox      = Tabs.Combat:AddLeftGroupbox("Dash Lock (Killer)", "zap")
local ToFBox           = Tabs.Combat:AddRightGroupbox("Twist of Fate", "target")
local VeilBox          = Tabs.Combat:AddRightGroupbox("Silent Veil", "zap")
local FlashBox         = Tabs.Combat:AddRightGroupbox("Silent Flashlight", "flashlight")
local FlaskBox         = Tabs.Combat:AddRightGroupbox("Silent Flask", "flask-conical")

local AutoParryToggle = ParryBox:AddCheckbox("AutoParry", {
    Text = "Auto Parry", Default = false,
    Callback = function(v) Config.Surv_AutoParry = v end,
}):AddKeyPicker("AutoParryKey", {
    Default = "None", Text = "Auto Parry Key", Mode = "Toggle",
    Callback = function(v) Config.Surv_AutoParry = v end,
})

ParryBox:AddCheckbox("Surv_ParrySafety", { Text = "Safety Parry", Default = false, Callback = function(v) Config.Surv_ParrySafety = v end })
ParryBox:AddToggle("ParryAggressive", { Text = "Aggressive Mode", Default = false, Callback = function(v) Config.Surv_ParryAggressive = v end })
ParryBox:AddToggle("ParryCircle", { Text = "ESP Range Circle", Default = true, Callback = function(v) Config.Surv_ParryCircle = v end })
ParryBox:AddSlider("ParryRadius", { Text = "Parry Radius", Default = 15, Min = 5, Max = 25, Rounding = 0, Callback = function(v) Config.Surv_ParryRadius = v end })
ParryBox:AddSlider("ParryFace", { Text = "Face Sensitivity", Default = 7, Min = -10, Max = 10, Rounding = 0, Callback = function(v) Config.Surv_ParryFace = v / 10 end })
ParryBox:AddDropdown("IgnoreSkills", {
    Values = { "Hidden S1", "Abyssal S1" }, Default = {}, Multi = true, Text = "Abaikan skill tertentu",
    Callback = function(Value)
        local parsed = {}
        for k, v in pairs(Value) do
            if type(k) == "string" and v then parsed[k] = true
            elseif type(v) == "string" then parsed[v] = true end
        end
        Config.Ignored_Skills_List = parsed
    end,
})
ParryBox:AddToggle("Surv_AutoCrouch", { Text = "Auto Crouch (Dodge S1)", Default = false, Callback = function(v) Config.Surv_AutoCrouch = v end })

-- Aimlock Attack (ALFzxzzz - Mouse1)
AttackAimBox:AddToggle("AttackAim_Enabled", {
    Text = "Enable (Hold Mouse1)", Default = false,
    Tooltip = "Hold Left Mouse untuk aim lock",
    Callback = function(v) AttackAim.Enabled = v end
}):AddKeyPicker("AttackAimKey", {
    Default = "None", Text = "Toggle Keybind", Mode = "Toggle",
    Callback = function(v)
        AttackAim.Enabled = v
        Library:Notify({ Title = "Aimlock (M1)", Description = v and "Enabled" or "Disabled", Time = 2 })
    end
})
AttackAimBox:AddDropdown("AttackAim_Target", { Values = {"Survivor","Killer"}, Default = 1, Text = "Target", Callback = function(v) AttackAim.TargetMode = v end })
AttackAimBox:AddDropdown("AttackAim_Part", { Values = {"HumanoidRootPart","Head","Torso"}, Default = 1, Text = "Aim Part", Callback = function(v) AttackAim.AimPart = v end })
AttackAimBox:AddSlider("AttackAim_FOV", { Text = "FOV", Default = 250, Min = 50, Max = 1000, Rounding = 0, Callback = function(v) AttackAim.FOV = v end })
AttackAimBox:AddSlider("AttackAim_Strength", { Text = "Strength", Default = 1, Min = 0.1, Max = 1, Rounding = 2, Callback = function(v) AttackAim.Strength = v end })
AttackAimBox:AddSlider("AttackAim_Predict", { Text = "Prediction", Default = 0.12, Min = 0, Max = 1, Rounding = 2, Callback = function(v) AttackAim.PredictStrength = v end })
AttackAimBox:AddToggle("AttackAim_VisCheck", { Text = "Visibility Check", Default = true, Callback = function(v) AttackAim.VisibilityCheck = v end })
AttackAimBox:AddToggle("AttackAim_ShowFOV", { Text = "Show FOV Circle", Default = false, Callback = function(v) AttackAim.ShowFOV = v end })

-- Aimlock Attack (Wisnu - Mouse2)
WisnuAttackAimBox:AddToggle("WisnuAttackAim_Enabled", {
    Text = "Enable (Hold Mouse2)", Default = false,
    Tooltip = "Hold Right Mouse untuk aim lock",
    Callback = function(v) WisnuAttackAim.Enabled = v end
}):AddKeyPicker("WisnuAttackAimKey", {
    Default = "None", Text = "Toggle Keybind", Mode = "Toggle",
    Callback = function(v)
        WisnuAttackAim.Enabled = v
        Library:Notify({ Title = "Aimlock (M2)", Description = v and "Enabled" or "Disabled", Time = 2 })
    end
})
WisnuAttackAimBox:AddDropdown("WisnuAttackAim_Target", { Values = {"Survivor","Killer"}, Default = 1, Text = "Target", Callback = function(v) WisnuAttackAim.TargetMode = v end })
WisnuAttackAimBox:AddDropdown("WisnuAttackAim_Part", { Values = {"HumanoidRootPart","Head","Torso"}, Default = 1, Text = "Aim Part", Callback = function(v) WisnuAttackAim.AimPart = v end })
WisnuAttackAimBox:AddSlider("WisnuAttackAim_FOV", { Text = "FOV", Default = 250, Min = 50, Max = 1000, Rounding = 0, Callback = function(v) WisnuAttackAim.FOV = v end })
WisnuAttackAimBox:AddSlider("WisnuAttackAim_Strength", { Text = "Strength", Default = 1, Min = 0.1, Max = 1, Rounding = 2, Callback = function(v) WisnuAttackAim.Strength = v end })
WisnuAttackAimBox:AddSlider("WisnuAttackAim_Predict", { Text = "Prediction", Default = 0.12, Min = 0, Max = 1, Rounding = 2, Callback = function(v) WisnuAttackAim.PredictStrength = v end })
WisnuAttackAimBox:AddToggle("WisnuAttackAim_VisCheck", { Text = "Visibility Check", Default = true, Callback = function(v) WisnuAttackAim.VisibilityCheck = v end })
WisnuAttackAimBox:AddToggle("WisnuAttackAim_ShowFOV", { Text = "Show FOV Circle", Default = false, Callback = function(v) WisnuAttackAim.ShowFOV = v end })

-- Aimlock Spear Mode
SpearAimBox:AddToggle("SpearAim_Enabled", {
    Text = "Enable (Hold Mouse1)", Default = false,
    Tooltip = "Aim lock spear dengan gravity compensation",
    Callback = function(v) SpearAim.Enabled = v end
}):AddKeyPicker("SpearAimKey", {
    Default = "None", Text = "Toggle Keybind", Mode = "Toggle",
    Callback = function(v)
        SpearAim.Enabled = v
        Library:Notify({ Title = "Aimlock Spear", Description = v and "Enabled" or "Disabled", Time = 2 })
    end
})
SpearAimBox:AddDropdown("SpearAim_Target", { Values = {"Survivor","Killer"}, Default = 1, Text = "Target", Callback = function(v) SpearAim.TargetMode = v end })
SpearAimBox:AddDropdown("SpearAim_Part", { Values = {"HumanoidRootPart","Head","Torso"}, Default = 1, Text = "Aim Part", Callback = function(v) SpearAim.AimPart = v end })
SpearAimBox:AddSlider("SpearAim_FOV", { Text = "FOV", Default = 250, Min = 50, Max = 1000, Rounding = 0, Callback = function(v) SpearAim.FOV = v end })
SpearAimBox:AddSlider("SpearAim_Strength", { Text = "Strength", Default = 1, Min = 0.1, Max = 1, Rounding = 2, Callback = function(v) SpearAim.Strength = v end })
SpearAimBox:AddSlider("SpearAim_Gravity", { Text = "Spear Gravity", Default = 50, Min = 10, Max = 200, Rounding = 0, Callback = function(v) SpearAim.Gravity = v end })
SpearAimBox:AddSlider("SpearAim_Speed", { Text = "Spear Speed", Default = 100, Min = 20, Max = 300, Rounding = 0, Callback = function(v) SpearAim.Speed = v end })
SpearAimBox:AddToggle("SpearAim_VisCheck", { Text = "Visibility Check", Default = true, Callback = function(v) SpearAim.VisibilityCheck = v end })
SpearAimBox:AddToggle("SpearAim_ShowFOV", { Text = "Show FOV Circle", Default = false, Callback = function(v) SpearAim.ShowFOV = v end })

-- Dash Lock
DashLockBox:AddToggle("DashLock_Enabled", {
    Text = "Enable Dash Lock", Default = false,
    Tooltip = "Auto lock kamera ke survivor terdekat saat dash/leap",
    Callback = function(v)
        DashLockConfig.Enabled = v
        if not v then DashLock_SetActive(false) end
        Library:Notify({ Title = "Dash Lock", Description = v and "Enabled" or "Disabled", Time = 2 })
    end
})
DashLockBox:AddSlider("DashLock_Duration", { Text = "Duration (s)", Default = 1.5, Min = 0.5, Max = 3, Rounding = 1, Callback = function(v) DashLockConfig.Duration = v end })
DashLockBox:AddSlider("DashLock_Smoothness", { Text = "Smoothness", Default = 0.3, Min = 0.05, Max = 1, Rounding = 2, Callback = function(v) DashLockConfig.Smoothness = v end })
DashLockBox:AddToggle("DashLock_Freeze", {
    Text = "Freeze During Dash", Default = false,
    Callback = function(v)
        DashLockConfig.FreezeDuringDash = v
        if not v then
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed == 0 then hum.WalkSpeed = 16 end
        end
    end
})
DashLockBox:AddToggle("DashLock_Indicator", { Text = "Show Indicator", Default = true, Callback = function(v) DashLockConfig.ShowIndicator = v end })

-- ToF
ToFBox:AddToggle("ToF_SilentAim", { Text = "Silent Aim (Pistol)", Default = false, Callback = function(v) ToFAim.Enabled = v end })
ToFBox:AddToggle("ToF_BlockKnocked", { Text = "Block Aim Knocked", Default = false, Callback = function(v) ToFAim.BlockKnocked = v end })
ToFBox:AddToggle("ToF_LockAim", { Text = "Lock Aim", Default = false, Callback = function(v) ToFAim.LockAim = v end })
ToFBox:AddDivider()
ToFBox:AddDropdown("ToF_Target", { Values = {"Killer","Survivor","SCP"}, Default = 1, Text = "Target", Callback = function(v) ToFAim.TargetMode = v end })
ToFBox:AddDropdown("ToF_AimPart", { Values = {"Head","Torso","Root","HumanoidRootPart"}, Default = 2, Text = "Aim Part", Callback = function(v) ToFAim.AimPart = v end })
ToFBox:AddDivider()
ToFBox:AddToggle("ToF_UseFOV", { Text = "FOV Mode", Default = false, Callback = function(v) ToFAim.UseFOV = v end })
ToFBox:AddToggle("ToF_ShowFOV", { Text = "Show FOV Circle", Default = false, Callback = function(v) ToFAim.ShowFOV = v end })
ToFBox:AddSlider("ToF_FOVRadius", { Text = "FOV Radius", Default = 150, Min = 50, Max = 500, Rounding = 0, Callback = function(v) ToFAim.FOV = v end })
ToFBox:AddSlider("ToF_BulletSpeed", { Text = "Bullet Speed", Default = 400, Min = 100, Max = 1500, Rounding = 0, Callback = function(v) ToFAim.BulletSpeed = v end })
ToFBox:AddSlider("ToF_YOffset", { Text = "Aim Y Offset", Default = -2, Min = -10, Max = 10, Rounding = 1, Callback = function(v) ToFAim.YOffset = v end })
ToFBox:AddDivider()
ToFBox:AddToggle("ToF_HideLaser", {
    Text = "Hide Silent Laser", Default = false,
    Callback = function(v)
        ToFAim.HideLaser = v
        if State.PistolLaser then State.PistolLaser.Transparency = v and 1 or 0 end
    end
})

-- Silent Veil
VeilBox:AddToggle("Veil_SilentAim", { Text = "Silent Aim Spear (Veil)", Default = false, Callback = function(v) VeilConfig.Enabled = v end })
VeilBox:AddToggle("Veil_ShowFOV", { Text = "Show FOV Circle", Default = true, Callback = function(v) VeilConfig.ShowFOV = v end })
VeilBox:AddToggle("Veil_ShowLaser", { Text = "Show Target Laser", Default = true, Callback = function(v) VeilConfig.ShowTargetLaser = v end })
VeilBox:AddDivider()
VeilBox:AddSlider("Veil_FOV", { Text = "FOV Radius", Default = 220, Min = 50, Max = 500, Rounding = 0, Callback = function(v) VeilConfig.FOV = v end })
VeilBox:AddToggle("Veil_AutoPredict", { Text = "Auto Predict", Default = false, Callback = function(v) VeilConfig.AutoPredict = v end })
VeilBox:AddSlider("Veil_SpearSpeed", { Text = "Spear Speed", Default = 165, Min = 50, Max = 300, Rounding = 0, Callback = function(v) VeilConfig.SpearSpeed = v end })
VeilBox:AddSlider("Veil_Gravity", { Text = "Gravity", Default = math.floor(workspace.Gravity * 0.5), Min = 0, Max = 300, Rounding = 0, Callback = function(v) VeilConfig.Gravity = v end })
VeilBox:AddSlider("Veil_MaxDist", { Text = "Max Distance", Default = 200, Min = 50, Max = 200, Rounding = 0, Callback = function(v) VeilConfig.MaxDist = v end })
VeilBox:AddSlider("Veil_HorizontalFactor", { Text = "Horizontal Vector", Default = 1.0, Min = 0, Max = 5, Rounding = 2, Callback = function(v) VeilConfig.HorizontalPredictFactor = v end })
VeilBox:AddDropdown("Veil_TargetPart", { Values = {"Torso","Head","Root"}, Default = 1, Text = "Target Part", Callback = function(v) VeilConfig.TargetPart = v end })

-- Silent Flashlight
FlashBox:AddToggle("Flash_Enabled", {
    Text = "Silent Aim Flashlight", Default = false,
    Tooltip = "Aim ke killer otomatis + laser",
    Callback = function(v) Flash_SetEnabled(v) end
})
FlashBox:AddToggle("Flash_Laser", {
    Text = "Flashlight Laser", Default = true,
    Callback = function(v)
        FlashConfig.Laser = v
        if not v and FlashState.LaserBeam then FlashState.LaserBeam.Transparency = 1 end
    end
})
FlashBox:AddDropdown("Flash_TargetPart", { Values = {"Head","HumanoidRootPart","UpperTorso","Torso"}, Default = 1, Text = "Target Part", Callback = function(v) FlashConfig.TargetPart = v end })
FlashBox:AddSlider("Flash_Range", { Text = "Range", Default = 120, Min = 20, Max = 250, Rounding = 0, Callback = function(v) FlashConfig.Range = v end })
FlashBox:AddSlider("Flash_Smooth", { Text = "Smoothness", Default = 0.35, Min = 0.05, Max = 1, Rounding = 2, Callback = function(v) FlashConfig.Smooth = v end })
FlashBox:AddSlider("Flash_YOffset", { Text = "Y Offset", Default = 0, Min = -10, Max = 10, Rounding = 1, Callback = function(v) FlashConfig.YOffset = v end })

-- Silent Flask
FlaskBox:AddToggle("Flask_SilentAim", {
    Text = "Silent Aim Flask (Cure)", Default = false,
    Tooltip = "Silent aim flask ThrowFlask ke survivor terdekat",
    Callback = function(v) Flask_SetSilentAim(v) end
})
FlaskBox:AddToggle("Flask_Laser", {
    Text = "Flask Laser", Default = true,
    Callback = function(v)
        FlaskConfig.ShowLaser = v
        if not v and FlaskState.LaserPart then FlaskState.LaserPart.Transparency = 1 end
    end
})
FlaskBox:AddDropdown("Flask_TargetPart", { Values = {"HumanoidRootPart","Head","Torso"}, Default = 1, Text = "Target Part", Callback = function(v) FlaskConfig.TargetPart = v end })
FlaskBox:AddSlider("Flask_MaxDist", { Text = "Max Distance", Default = 200, Min = 20, Max = 500, Rounding = 0, Callback = function(v) FlaskConfig.MaxDist = v end })

-- ============== TAB 3: SURVIVOR =================
local SurvAutoBox    = Tabs.Survivor:AddLeftGroupbox("Auto Generator", "cpu")
local SurvVaultBox   = Tabs.Survivor:AddLeftGroupbox("Swift Vault", "zap")
local SurvEscapeBox  = Tabs.Survivor:AddLeftGroupbox("Auto Escape", "shield")
local SurvHealBox    = Tabs.Survivor:AddLeftGroupbox("Auto Heal", "heart")
local SurvPerksBox   = Tabs.Survivor:AddRightGroupbox("Fake Perks", "star")
local SurvInfoBox    = Tabs.Survivor:AddRightGroupbox("Info", "info")

SurvAutoBox:AddToggle("AutoSkillCheck", {
    Text = "Auto Skill Check", Default = false,
    Tooltip = "Otomatis eksekusi skill check generator",
    Callback = function(v) SurvivorConfig.AutoSkillCheck = v end
})
SurvAutoBox:AddDropdown("SkillCheckMode", {
    Values = { "Legit", "Instant" }, Default = 1, Text = "Skill Check Mode",
    Callback = function(v) SurvivorConfig.SkillCheckMode = v end
})
SurvAutoBox:AddDivider()
SurvAutoBox:AddToggle("GenBoostBypass", {
    Text = "Gen Boost Bypass", Default = false,
    Tooltip = "Repair semua titik generator. PC: tekan G. Mobile: tombol GEN",
    Callback = function(v) setGenBypass(v) end
})

SurvVaultBox:AddToggle("SwiftVault", { Text = "Swift Vault", Default = false, Tooltip = "Auto vault saat dekat window & bergerak", Callback = function(v) SurvivorConfig.SwiftVault = v end })
SurvVaultBox:AddToggle("SwiftVaultV2", { Text = "Swift Vault V2", Default = false, Tooltip = "Custom vault speed", Callback = function(v) Survivor_SetSwiftVaultV2(v) end })
SurvVaultBox:AddSlider("SwiftVaultSpeed", { Text = "Vault Speed", Default = 13, Min = 10, Max = 20, Rounding = 0, Callback = function(v) SurvivorConfig.SwiftVaultSpeed = v end })

SurvEscapeBox:AddToggle("FleeKiller", { Text = "Flee Killer", Default = false, Tooltip = "Auto teleport menjauh dari killer", Callback = function(v) SurvivorConfig.FleeKiller = v end })
SurvEscapeBox:AddSlider("FleeDistance", { Text = "Flee Distance", Default = 40, Min = 15, Max = 80, Rounding = 0, Callback = function(v) SurvivorConfig.FleeDistance = v end })

SurvHealBox:AddToggle("InstantHealSelf", {
    Text = "Aura Heal (Self)", Default = false,
    Tooltip = "Auto heal self via HealEvent",
    Callback = function(v)
        Survivor_SetInstantHealSelf(v)
        SelfHeal_UpdateButton()
    end
})
SurvHealBox:AddToggle("ShowHealButton", {
    Text = "Show Heal Button", Default = false,
    Tooltip = "Floating button buat toggle aura heal cepat",
    Callback = function(v)
        SurvivorConfig.ShowHealButton = v
        if v then SelfHeal_CreateButton() else SelfHeal_DestroyButton() end
    end
})
SurvHealBox:AddToggle("DragLockedHealBtn", {
    Text = "Lock Heal Button Position", Default = false,
    Callback = function(v)
        SurvivorConfig.DragLockedHealBtn = v
        SelfHealButton.Dragging = false
    end
})

SurvPerksBox:AddSlider("FP_Cooldown", { Text = "Cooldown (semua perk)", Default = 10, Min = 0, Max = 60, Rounding = 0, Callback = function(v) FakePerksState.CooldownTime = v end })
SurvPerksBox:AddDivider()
SurvPerksBox:AddToggle("FP_Flowstate", { Text = "Flowstate", Default = false, Tooltip = "+5 speed selama 3s setelah vault/slide", Callback = function(v) Survivor_ToggleFlowstate(v) end })
SurvPerksBox:AddToggle("FP_QuickRecovery", { Text = "Quick Recovery", Default = false, Tooltip = "+6 speed selama 3s setelah di-heal", Callback = function(v) Survivor_ToggleQuickRecovery(v) end })
SurvPerksBox:AddToggle("FP_PerfectLanding", { Text = "Perfect Landing", Default = false, Tooltip = "+8 speed selama 3s setelah landing", Callback = function(v) Survivor_TogglePerfectLanding(v) end })
SurvPerksBox:AddToggle("FP_AdrenalineRush", { Text = "Adrenaline Rush", Default = false, Tooltip = "+4 speed selama 5s saat HP drop ke 50", Callback = function(v) Survivor_ToggleAdrenalineRush(v) end })

SurvInfoBox:AddLabel("Auto Skill Check: Instant/Legit")
SurvInfoBox:AddLabel("Gen Boost Bypass: Hotkey G / Tombol GEN")
SurvInfoBox:AddLabel("Swift Vault: Auto vault saat dekat window")
SurvInfoBox:AddLabel("Aura Heal: Auto heal + skillcheck success")
SurvInfoBox:AddLabel("Fake Perks: client-side only")

-- ============== TAB 4: KILLER =================
local InfSkillBox     = Tabs.Killer:AddLeftGroupbox("Infinite Skill", "infinity")
local AutoKillerBox   = Tabs.Killer:AddLeftGroupbox("Auto Killer", "target")
local KillerUtilBox   = Tabs.Killer:AddRightGroupbox("Killer Utilities", "wrench")
local BlockKillerBox  = Tabs.Killer:AddRightGroupbox("Block & Counter", "shield")

InfSkillBox:AddToggle("InfAbyssalBurst", {
    Text = "Infinite Abyssal Burst (Abyss)", Default = false,
    Callback = function(v)
        KillerConfig.InfAbyssalBurst = v
        if v then StartAbyssCooldownBypass() else StopAbyssCooldownBypass() end
    end
})
InfSkillBox:AddToggle("InfHiddenSkill", {
    Text = "Infinite Skill (Hidden)", Default = false,
    Callback = function(v)
        KillerConfig.InfHiddenSkill = v
        if v then StartHiddenCooldownBypass() else StopHiddenCooldownBypass() end
    end
})
InfSkillBox:AddToggle("InfFrenzy", {
    Text = "Infinite Frenzy (Jeff)", Default = false,
    Callback = function(v)
        KillerConfig.InfFrenzy = v
        if v then StartJeffCooldownBypass() else StopJeffCooldownBypass() end
    end
})
InfSkillBox:AddDivider()
InfSkillBox:AddToggle("InfLakeMist", {
    Text = "Infinite Lake Mist (Jason)", Default = false,
    Callback = function(v)
        KillerConfig.InfLakeMist = v
        if v then StartSlasherCooldownBypass() else StopSlasherCooldownBypass() end
    end
})
InfSkillBox:AddToggle("InfPursuit", {
    Text = "Infinite Pursuit (Jason)", Default = false,
    Callback = function(v)
        KillerConfig.InfPursuit = v
        if v then StartSlasherCooldownBypass() else StopSlasherCooldownBypass() end
    end
})
InfSkillBox:AddDivider()
InfSkillBox:AddToggle("InfLunge", {
    Text = "Infinite Lunge (Basic Attack)", Default = false,
    Callback = function(v)
        KillerConfig.InfLunge = v
        if not v and KillerState.OriginalLungeBoost then
            local char = LocalPlayer.Character
            if char then
                char:SetAttribute("lungeboost", KillerState.OriginalLungeBoost)
                KillerState.OriginalLungeBoost = nil
            end
        end
    end
})

AutoKillerBox:AddToggle("AutoAttack", { Text = "Auto Attack", Default = false, Tooltip = "Auto basic attack saat survivor dekat", Callback = function(v) KillerConfig.AutoAttack = v end })
AutoKillerBox:AddSlider("AutoAttackRange", { Text = "Auto Attack Range", Default = 12, Min = 5, Max = 20, Rounding = 0, Callback = function(v) KillerConfig.AutoAttackRange = v end })

BlockKillerBox:AddToggle("AutoDropAllPallet", { Text = "Auto Drop All Pallets", Default = false, Callback = function(v) KillerConfig.AutoDropAllPallet = v end })
BlockKillerBox:AddToggle("BlockAllVaults", { Text = "Block All Vaults", Default = false, Callback = function(v) KillerConfig.BlockAllVaults = v end })
BlockKillerBox:AddToggle("CounterParry", {
    Text = "Counter Parry (Fake Attack)", Default = false,
    Callback = function(v)
        KillerConfig.CounterParry = v
        MAWWW_ToggleCounterParry(v)
    end
})

KillerUtilBox:AddToggle("NoSlowdown", { Text = "No Slowdown / Anti Stun", Default = false, Callback = function(v) KillerConfig.NoSlowdown = v end })

-- ============== TAB 5: VISUAL =================
local VisualBox = Tabs.Visual:AddLeftGroupbox("Visual Effects", "sparkles")
local POVBox    = Tabs.Visual:AddRightGroupbox("Camera / POV", "camera")

VisualBox:AddToggle("FullBright", {
    Text = "Fullbright",
    Default = false,
    Tooltip = "Terangin seluruh map (NoShadow, NoAtmosphere, ClockTime 14)",
    Callback = function(v)
        VisualConfig.FullBright = v
        Library:Notify({ Title = "Fullbright", Description = v and "Enabled" or "Disabled", Time = 2 })
    end
})

VisualBox:AddToggle("NoFog", {
    Text = "No Fog",
    Default = false,
    Tooltip = "Hilangin fog, atmosphere, blur, bloom di map & Lighting",
    Callback = function(v)
        VisualConfig.NoFog = v
        if v then
            Visual_RemoveFog()
        else
            Visual_RestoreFog()
        end
        Library:Notify({ Title = "No Fog", Description = v and "Enabled" or "Disabled", Time = 2 })
    end
})

VisualBox:AddDivider()
VisualBox:AddLabel("Reset semua efek visual")

VisualBox:AddButton({
    Text = "Reset All Visual",
    Func = function()
        VisualConfig.FullBright = false
        VisualConfig.NoFog      = false
        Visual_RestoreFog()
        pcall(function()
            Lighting.Brightness     = OriginalLighting.Brightness
            Lighting.ClockTime      = OriginalLighting.ClockTime
            Lighting.GlobalShadows  = OriginalLighting.GlobalShadows
            Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
        end)
        Library:Notify({ Title = "Visual", Description = "Reset to default", Time = 2 })
    end
})

POVBox:AddToggle("LockPOV", {
    Text = "Lock POV (First Person)",
    Default = false,
    Tooltip = "Force first person + lock kamera di kepala",
    Callback = function(v)
        VisualConfig.LockPOV = v
        Library:Notify({ Title = "Lock POV", Description = v and "Enabled" or "Disabled", Time = 2 })
    end
})

POVBox:AddSlider("LockPOVFOV", {
    Text = "POV FOV",
    Default = 90,
    Min = 40,
    Max = 120,
    Rounding = 0,
    Callback = function(v) VisualConfig.LockPOVFOV = v end
})

-- ============== TAB 6: UI SETTINGS =================
local SettingBox = Tabs.UI:AddLeftGroupbox("Menu", "wrench")

SettingBox:AddToggle("ShowCustomCursor", { Text = "Custom Cursor", Default = true, Callback = function(v) Library.ShowCustomCursor = v end })
SettingBox:AddDropdown("NotificationSide", { Values = {"Left","Right"}, Default = "Right", Text = "Notification Side", Callback = function(v) Library:SetNotifySide(v) end })
SettingBox:AddDropdown("DPIDropdown", {
    Values = {"50%","75%","85%","100%","125%","150%"}, Default = "85%", Text = "DPI Scale",
    Callback = function(v)
        v = v:gsub("%%","")
        Library:SetDPIScale(tonumber(v))
    end
})
SettingBox:AddDivider()
SettingBox:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
SettingBox:AddButton("Unload script", function() Library:Unload() end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
ThemeManager:SetFolder("WisnuFull")
SaveManager:SetFolder("WisnuFull/configs")
SaveManager:BuildConfigSection(Tabs["UI"])
ThemeManager:ApplyToTab(Tabs["UI"])
SaveManager:LoadAutoloadConfig()

-- ============================================================
-- ============== INITIAL SETUP ===============================
-- ============================================================

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if State.AutoParryAdornment then
        State.AutoParryAdornment:Destroy()
        State.AutoParryAdornment = nil
    end
    State.ChargingPistol     = false
    State.LockedPistolTarget = nil
    State.TouchPistolInput   = nil
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(UpdateInfiniteLunge)
    end
end)

for _, p in pairs(Players:GetPlayers()) do SetupPlayer(p) end
Players.PlayerAdded:Connect(SetupPlayer)

task.spawn(function()
    while true do
        task.wait(5)
        for _, p in pairs(Players:GetPlayers()) do TryAttach(p) end
    end
end)

Library:Notify({
    Title = "Wisnu v15",
    Description = "ESP + Combat + Survivor + Killer + Visual",
    Time = 3
})
