--========================================================--
--  ALFzxzzz Hub  |  Rayfield Gen2  |  Full Script v25-FIX4
--  + Visuals: Fullbright / No Shadow / Low Graphics / Clean Sky / Lock POV
--  + Auto Parry V2 (Main), Auto Crouch (Survivor)
--========================================================--

--========================================================--
-- 1. SERVICES
--========================================================--
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local Workspace         = game:GetService("Workspace")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Lighting          = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService        = game:GetService("GuiService")

local LocalPlayer       = Players.LocalPlayer
local Player            = LocalPlayer
local PlayerGui         = LocalPlayer:WaitForChild("PlayerGui")
local Camera            = Workspace.CurrentCamera
local isMobile          = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

--========================================================--
-- 2. LOAD RAYFIELD GEN2
--========================================================--
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

--========================================================--
-- 3. GLOBAL CONFIG
--========================================================--
getgenv().VD = getgenv().VD or {}
getgenv().W  = getgenv().W  or {}
local VD = getgenv().VD
local W  = getgenv().W
W.Timers = W.Timers or { lastESPUpdate = 0, lastPalletScan = 0, lastPalletDrop = 0 }
W.Auto = W.Auto or { SkillCheck = false, SkillCheckMode = "Legit", PalletDrop = false, PalletDropDist = 6 }
W.State = W.State or { busy = false, UsedPallets = {} }
W.Connections = W.Connections or { SkillHeartbeat = nil }
W.Killer = W.Killer or { BlockVaults = false }

local Auto = W.Auto
local State = W.State
local Connections = W.Connections
local Timers = W.Timers
local Killer = W.Killer

W.FP = W.FP or {
    Conns = {}, ActiveBuffs = {}, HB = nil,
    LastBuffEnd = 0, CooldownTime = 10,
    FlowstateOn = false, QuickRecOn = false,
    PerfLandOn = false, AdrenalineOn = false,
}
local FP = W.FP

W.InstantHealSelf = false
W.AutoHealAll = false
W.InstantHealConnection = nil
W.AutoHealAllConnection = nil

W.SelfUnhook = W.SelfUnhook or {
    Enabled = false, Following = false,
    FollowDuration = 30, FollowDistance = 20,
    MonitorConn = nil, TriggerCount = 0,
    _lastTrigger = 0, _cooldown = 3,
    _hookPos = nil, _hookCFrame = nil,
    _activeThread = nil, _wasHooked = false,
}
local SU = W.SelfUnhook

local Defaults = {
    VeilEnabled=false, VeilShowFOV=true, VeilShowTracker=false, VeilAutoPredict=true,
    VeilWallCheck=true, VeilDebug=false,
    VeilFOV=150, VeilMaxDist=500, VeilSpearSpeed=165, VeilGravity=103,
    VeilAuraSpearSpeed=165, VeilAuraSpearGravity=96, VeilLeadMultiplier=1.4,
    PARRY_Enabled=false, PARRY_Aggressive=false, PARRY_Distance=10,
    PARRY_ShowCircle=false, PARRY_SilentParry=false,
    TOF_SilentAim=false, TOF_Laser=true, TOF_WallCheck=false,
    TOF_TargetMode="Killer", TOF_Key="None", TOF_BlockKnocked=true,
    GB_Enabled=false,
    FP_Cooldown=10,
}
for k, v in pairs(Defaults) do if VD[k] == nil then VD[k] = v end end

--========================================================--
-- 3b. VISUAL CONFIG (FULLBRIGHT / NOSHADOW / LOW GFX / CLEAN SKY)
--========================================================--
W.Visual = W.Visual or {
    Fullbright      = false,
    NoShadow        = false,
    LowGraphics     = false,
    CleanSky        = false,
}
local Visual = W.Visual

W.OriginalLighting = W.OriginalLighting or {
    Brightness     = Lighting.Brightness,
    ClockTime      = Lighting.ClockTime,
    Ambient        = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    GlobalShadows  = Lighting.GlobalShadows,
}
local OriginalLighting = W.OriginalLighting

W.LastVisualState = W.LastVisualState or {
    Fullbright   = nil,
    NoShadow     = nil,
}
local LastVisualState = W.LastVisualState

W.LastOptimizationState = W.LastOptimizationState or {
    LowGraphics = nil,
    CleanSky    = nil,
}
local LastOptimizationState = W.LastOptimizationState

W.DisabledEffects = W.DisabledEffects or {}
local DisabledEffects = W.DisabledEffects

W.CleanSkyBackup = W.CleanSkyBackup or {} -- Backup sky properties

local ScreenEffectTypes = {
    "ColorCorrectionEffect",
    "DepthOfFieldEffect",
    "BlurEffect",
    "SunRaysEffect",
    "BloomEffect",
}

--========================================================--
-- 3c. LOCK POV CONFIG (Lock Field Of View)
--========================================================--
W.LockPOV = W.LockPOV or {
    Enabled     = false,
    FOV         = 80,
    Conn        = nil,
    OriginalFOV = nil,
}
local LockPOV = W.LockPOV

function W.LockPOV_SetEnabled(v)
    v = v and true or false
    LockPOV.Enabled = v
    local cam = Workspace.CurrentCamera
    if not cam then return end

    if v then
        if not LockPOV.OriginalFOV then
            LockPOV.OriginalFOV = cam.FieldOfView
        end
        if LockPOV.Conn then LockPOV.Conn:Disconnect() end
        LockPOV.Conn = RunService.RenderStepped:Connect(function()
            if not LockPOV.Enabled then return end
            local c = Workspace.CurrentCamera
            if c then
                pcall(function() c.FieldOfView = LockPOV.FOV end)
            end
        end)
    else
        if LockPOV.Conn then
            pcall(function() LockPOV.Conn:Disconnect() end)
            LockPOV.Conn = nil
        end
        if cam and LockPOV.OriginalFOV then
            pcall(function() cam.FieldOfView = LockPOV.OriginalFOV end)
        end
    end
end

--========================================================--
-- 4. HELPERS
--========================================================--
local function notify(title, content, duration)
    pcall(function()
        Rayfield:Notify({
            Title = tostring(title or "Notification"),
            Content = tostring(content or ""),
            Duration = tonumber(duration) or 3,
        })
    end)
end
getgenv().notify = notify
getgenv().VD_Notify = notify

local function GetRole()
    local ok, role = pcall(function()
        local char = Player.Character
        if char then
            local attr = char:GetAttribute("Role")
            if attr and type(attr) == "string" then return attr end
        end
        local plrAttr = Player:GetAttribute("Role")
        if plrAttr and type(plrAttr) == "string" then return plrAttr end
        if Player.Team and Player.Team.Name then
            local n = string.lower(Player.Team.Name)
            if string.find(n, "killer", 1, true) then return "Killer" end
            if string.find(n, "survivor", 1, true) then return "Survivor" end
        end
        return "Unknown"
    end)
    if ok then return role end
    return "Unknown"
end
getgenv().GetRole = GetRole

local function GetSafeGuiParent()
    local ok, parent = pcall(function()
        if gethui then return gethui() end
        if get_hidden_gui then return get_hidden_gui() end
        local cg = game:GetService("CoreGui")
        if cg then return cg end
    end)
    if ok and parent then return parent end
    return Player:WaitForChild("PlayerGui", 5)
end
getgenv().GetSafeGuiParent = GetSafeGuiParent

local function getRoot()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
W.getRoot = getRoot
W.GetRoot = getRoot

local function GetNearestKiller()
    local root = getRoot()
    if not root then return nil, math.huge end
    local closest, shortest = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local isKiller = false
            if plr.Team and plr.Team.Name and string.find(string.lower(plr.Team.Name), "killer", 1, true) then
                isKiller = true
            end
            if isKiller and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local d = (hrp.Position - root.Position).Magnitude
                    if d < shortest then
                        shortest = d
                        closest = hrp
                    end
                end
            end
        end
    end
    return closest, shortest
end
W.GetNearestKiller = GetNearestKiller

--========================================================--
-- 4b. VISUAL APPLY FUNCTIONS
--========================================================--
local function applyVisual(force)
    if force or LastVisualState.Fullbright ~= Visual.Fullbright then
        LastVisualState.Fullbright = Visual.Fullbright
        if Visual.Fullbright then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        else
            Lighting.Brightness = OriginalLighting.Brightness
            Lighting.ClockTime  = OriginalLighting.ClockTime
            Lighting.Ambient    = OriginalLighting.Ambient
            Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
        end
    end

    if force or LastVisualState.NoShadow ~= Visual.NoShadow then
        LastVisualState.NoShadow = Visual.NoShadow
        Lighting.GlobalShadows = not Visual.NoShadow
    end
end

local function applyOptimization(force)
    if force or LastOptimizationState.LowGraphics ~= Visual.LowGraphics then
        LastOptimizationState.LowGraphics = Visual.LowGraphics
        pcall(function()
            settings().Rendering.QualityLevel = Visual.LowGraphics
                and Enum.QualityLevel.Level01
                or  Enum.QualityLevel.Automatic
        end)
    end

    if force or LastOptimizationState.CleanSky ~= Visual.CleanSky then
        LastOptimizationState.CleanSky = Visual.CleanSky
        if Visual.CleanSky then
            -- Destroy existing Sky children (backup first)
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("Sky") then
                    table.insert(W.CleanSkyBackup, v)
                    v.Parent = nil -- unpin instead of destroy (safer for restore)
                end
            end
        else
            -- Restore backup skies
            for _, sky in ipairs(W.CleanSkyBackup) do
                if sky and sky.Parent == nil then
                    pcall(function() sky.Parent = Lighting end)
                end
            end
            W.CleanSkyBackup = {}
        end
    end
end

local function applyNoScreenEffects()
    if Visual.NoScreenEffects then
        for _, v in pairs(Lighting:GetChildren()) do
            for _, t in pairs(ScreenEffectTypes) do
                if v:IsA(t) then DisabledEffects[v] = v.Enabled; v.Enabled = false end
            end
        end
    else
        for obj, s in pairs(DisabledEffects) do
            if obj and obj.Parent then obj.Enabled = s end
        end
        DisabledEffects = {}
        W.DisabledEffects = {}
    end
end

-- Auto-disable new screen effects added after toggle
Lighting.ChildAdded:Connect(function(v)
    if not Visual.NoScreenEffects then return end
    task.wait()
    for _, t in pairs(ScreenEffectTypes) do
        if v:IsA(t) then DisabledEffects[v] = v.Enabled; v.Enabled = false end
    end
end)

--========================================================--
-- 5. CREATE WINDOW
--========================================================--
local Window = Rayfield:CreateWindow({
    name = "ALFzxzzz Hub",
    subtitle = "v25-FIX4 | Rayfield Gen2 Edition",
    icon = 89487315403118,
    sidebarLayout = true,
    theme = "default",
    autoSave = true,
    folder = "ALFzxzzz_Hub",
})

--========================================================--
-- 5b. FLOATING BUTTON SYSTEM
--========================================================--
local FloatingButtons = {}
local FB_OFF_COLOR = Color3.fromRGB(75, 75, 75)
local FB_ON_COLOR  = Color3.fromRGB(0, 255, 100)

local function CreateFloatingButton(cfg)
    local state = {
        DragLocked = false, Gui = nil,
        StrokeConn = nil, InputChangedConn = nil, InputEndedConn = nil,
        ToggleDragConn = nil, LockDragConn = nil,
        LockImg = "rbxassetid://6723197051",
        UnlockImg = "rbxassetid://121881483558170",
        SavedPos = cfg.Pos or UDim2.new(0.05, 0, 0.2, 0),
        CurrentColor = FB_OFF_COLOR,
        LockColor = FB_OFF_COLOR,
    }
    local function GetEnabled() return cfg.GetState and cfg.GetState() or false end
    local function UpdateVisual()
        if not state.Gui then return end
        local btn = state.Gui:FindFirstChild("ToggleBtn", true)
        if not btn then return end
        local on = GetEnabled()
        if on then
            btn.Text = cfg.Title .. " [ON]"
            btn.TextColor3 = FB_ON_COLOR
            state.CurrentColor = FB_ON_COLOR
        else
            btn.Text = cfg.Title .. " [OFF]"
            btn.TextColor3 = FB_OFF_COLOR
            state.CurrentColor = FB_OFF_COLOR
        end
    end
    local function UpdateLockVisual()
        if not state.Gui then return end
        local lockBtn = state.Gui:FindFirstChild("LockBtn", true)
        if not lockBtn then return end
        local img = lockBtn:FindFirstChild("LockIcon")
        if not img then return end
        if state.DragLocked then
            img.Image = state.LockImg
            img.ImageColor3 = FB_ON_COLOR
            state.LockColor = FB_ON_COLOR
        else
            img.Image = state.UnlockImg
            img.ImageColor3 = FB_OFF_COLOR
            state.LockColor = FB_OFF_COLOR
        end
    end
    local function Toggle()
        local newState = not GetEnabled()
        if cfg.SetState then cfg.SetState(newState) end
        UpdateVisual()
        notify(cfg.NotifyTitle or cfg.Title, newState and "Enabled" or "Disabled", 2)
    end
    local function ToggleLock()
        state.DragLocked = not state.DragLocked
        UpdateLockVisual()
    end
    local function Destroy()
        if state.ToggleDragConn then state.ToggleDragConn:Disconnect(); state.ToggleDragConn = nil end
        if state.LockDragConn then state.LockDragConn:Disconnect(); state.LockDragConn = nil end
        if state.InputChangedConn then state.InputChangedConn:Disconnect(); state.InputChangedConn = nil end
        if state.InputEndedConn then state.InputEndedConn:Disconnect(); state.InputEndedConn = nil end
        if state.StrokeConn then state.StrokeConn:Disconnect(); state.StrokeConn = nil end
        if state.Gui then state.Gui:Destroy(); state.Gui = nil end
    end
    local function Create()
        Destroy()
        local parent = GetSafeGuiParent()
        if not parent then return end
        state.Gui = Instance.new("ScreenGui")
        state.Gui.Name = "ALFzxzzz_" .. cfg.Id .. "Gui"
        state.Gui.ResetOnSpawn = false
        state.Gui.IgnoreGuiInset = true
        state.Gui.Parent = parent

        local holder = Instance.new("Frame")
        holder.Name = "Holder"; holder.Parent = state.Gui
        holder.Size = UDim2.fromOffset(180, 42)
        holder.Position = state.SavedPos
        holder.BackgroundTransparency = 1; holder.Active = false

        local btn = Instance.new("TextButton")
        btn.Name = "ToggleBtn"; btn.Parent = holder
        btn.Size = UDim2.fromOffset(140, 42); btn.Position = UDim2.fromOffset(0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        btn.Text = cfg.Title .. " [OFF]"
        btn.Font = Enum.Font.GothamBold; btn.TextSize = 12
        btn.TextColor3 = FB_OFF_COLOR
        btn.BorderSizePixel = 0; btn.Active = true; btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

        local stroke = Instance.new("UIStroke")
        stroke.Name = "AnimStroke"; stroke.Parent = btn
        stroke.Thickness = 1.6; stroke.Transparency = 0.1
        stroke.Color = FB_OFF_COLOR
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local lockBtn = Instance.new("TextButton")
        lockBtn.Name = "LockBtn"; lockBtn.Parent = holder
        lockBtn.Size = UDim2.fromOffset(36, 42); lockBtn.Position = UDim2.fromOffset(144, 0)
        lockBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        lockBtn.Text = ""; lockBtn.BorderSizePixel = 0
        lockBtn.Active = true; lockBtn.AutoButtonColor = false
        Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(0, 10)

        local lockIcon = Instance.new("ImageLabel")
        lockIcon.Name = "LockIcon"; lockIcon.Parent = lockBtn
        lockIcon.BackgroundTransparency = 1
        lockIcon.Size = UDim2.fromScale(0.62, 0.62)
        lockIcon.Position = UDim2.fromScale(0.5, 0.5)
        lockIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        lockIcon.Image = state.UnlockImg; lockIcon.ImageColor3 = FB_OFF_COLOR
        lockIcon.ScaleType = Enum.ScaleType.Fit

        local lockStroke = Instance.new("UIStroke")
        lockStroke.Name = "LockStroke"; lockStroke.Parent = lockBtn
        lockStroke.Thickness = 1.6; lockStroke.Transparency = 0.1
        lockStroke.Color = FB_OFF_COLOR
        lockStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local pulseT = 0
        state.StrokeConn = RunService.RenderStepped:Connect(function(dt)
            if not state.Gui or not state.Gui.Parent then return end
            pulseT = (pulseT + dt * 2.8) % (math.pi * 2)
            local glow = math.sin(pulseT) * 0.5 + 0.5
            local thickness = 1.6 + glow * 0.6
            local transparency = 0.3 - glow * 0.2
            if stroke and stroke.Parent then
                if stroke.Color ~= state.CurrentColor then stroke.Color = state.CurrentColor end
                stroke.Thickness = thickness; stroke.Transparency = transparency
            end
            if lockStroke and lockStroke.Parent then
                if lockStroke.Color ~= state.LockColor then lockStroke.Color = state.LockColor end
                lockStroke.Thickness = thickness; lockStroke.Transparency = transparency
            end
        end)

        local dragging = false
        local startedOnBtn = false
        local dragStart, startPos
        local movedDistance = 0
        local CLICK_THRESHOLD = 6

        state.ToggleDragConn = btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                startedOnBtn = true; movedDistance = 0
                dragStart = input.Position; startPos = holder.Position
                dragging = not state.DragLocked
            end
        end)

        state.InputChangedConn = UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                local dist = math.abs(delta.X) + math.abs(delta.Y)
                if dist > movedDistance then movedDistance = dist end
                holder.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)

        state.InputEndedConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if startedOnBtn and movedDistance < CLICK_THRESHOLD then Toggle() end
                dragging = false; startedOnBtn = false
            end
        end)

        state.LockDragConn = lockBtn.MouseButton1Click:Connect(ToggleLock)
        UpdateVisual(); UpdateLockVisual()
    end
    FloatingButtons[cfg.Id] = { Create = Create, Destroy = Destroy, Toggle = Toggle, UpdateVisual = UpdateVisual }
    return FloatingButtons[cfg.Id]
end

CreateFloatingButton({
    Id = "SelfHeal", Title = "SELF HEAL",
    Pos = UDim2.new(0.03, 0, 0.22, 0),
    GetState = function() return W.InstantHealSelf end,
    SetState = function(v) W.setInstantHealSelf(v) end,
    NotifyTitle = "Self Heal",
})
CreateFloatingButton({
    Id = "Flowstate", Title = "FLOWSTATE",
    Pos = UDim2.new(0.03, 0, 0.29, 0),
    GetState = function() return FP.FlowstateOn end,
    SetState = function(v) W.FP_SetupFlowstate(v) end,
    NotifyTitle = "Fake Perks",
})
CreateFloatingButton({
    Id = "Parry", Title = "AUTO PARRY",
    Pos = UDim2.new(0.03, 0, 0.36, 0),
    GetState = function() return VD.PARRY_Enabled end,
    SetState = function(v) VD.PARRY_Enabled = v end,
    NotifyTitle = "Auto Parry",
})
CreateFloatingButton({
    Id = "ParryV2", Title = "PARRY V2",
    Pos = UDim2.new(0.03, 0, 0.43, 0),
    GetState = function() return W.ParryV2 and W.ParryV2.Enabled end,
    SetState = function(v)
        if W.ParryV2 then
            if v then W.ParryV2_Start() else W.ParryV2_Stop() end
        end
    end,
    NotifyTitle = "Auto Parry V2",
})
CreateFloatingButton({
    Id = "SelfUnhook", Title = "SELF UNHOOK",
    Pos = UDim2.new(0.03, 0, 0.50, 0),
    GetState = function() return W.SelfUnhook and W.SelfUnhook.Enabled end,
    SetState = function(v) W.SU_SetEnabled(v) end,
    NotifyTitle = "Bypass Self Unhook",
})
CreateFloatingButton({
    Id = "AutoPallet", Title = "AUTO PALLET",
    Pos = UDim2.new(0.03, 0, 0.57, 0),
    GetState = function() return Auto.PalletDrop end,
    SetState = function(v) Auto.PalletDrop = v end,
    NotifyTitle = "Auto Drop Pallet",
})

--========================================================--
-- 6. TAB 1 : MAIN
--========================================================--
local MainTab = Window:CreateTab({ name = "Main", icon = 93364949241311 })

--========================================================--
-- 6a. SILENT VEIL V1
--========================================================--
local VeilState = { target = nil, lookVector = nil, velHistory = {}, lastFire = 0 }
local VeilVisuals = {}

pcall(function()
    if typeof(Drawing) == "table" and Drawing.new then
        VeilVisuals.FOVCircleOutline = Drawing.new("Circle")
        VeilVisuals.FOVCircleOutline.Color = Color3.fromRGB(0, 0, 0)
        VeilVisuals.FOVCircleOutline.Thickness = 3
        VeilVisuals.FOVCircleOutline.Filled = false
        VeilVisuals.FOVCircleOutline.Transparency = 0.3
        VeilVisuals.FOVCircleOutline.Visible = false

        VeilVisuals.FOVCircleFill = Drawing.new("Circle")
        VeilVisuals.FOVCircleFill.Color = Color3.fromRGB(0, 255, 0)
        VeilVisuals.FOVCircleFill.Thickness = 1
        VeilVisuals.FOVCircleFill.Filled = false
        VeilVisuals.FOVCircleFill.Transparency = 0.5
        VeilVisuals.FOVCircleFill.Visible = false

        VeilVisuals.TrackerCircleOutline = Drawing.new("Circle")
        VeilVisuals.TrackerCircleOutline.Color = Color3.fromRGB(0, 0, 0)
        VeilVisuals.TrackerCircleOutline.Thickness = 3
        VeilVisuals.TrackerCircleOutline.Filled = false
        VeilVisuals.TrackerCircleOutline.Transparency = 0.3
        VeilVisuals.TrackerCircleOutline.Visible = false

        VeilVisuals.TrackerCircleFill = Drawing.new("Circle")
        VeilVisuals.TrackerCircleFill.Color = Color3.fromRGB(0, 255, 0)
        VeilVisuals.TrackerCircleFill.Thickness = 1
        VeilVisuals.TrackerCircleFill.Filled = false
        VeilVisuals.TrackerCircleFill.Transparency = 0.5
        VeilVisuals.TrackerCircleFill.Visible = false

        VeilVisuals.TrackerLine = Drawing.new("Line")
        VeilVisuals.TrackerLine.Color = Color3.fromRGB(0, 255, 0)
        VeilVisuals.TrackerLine.Thickness = 2
        VeilVisuals.TrackerLine.Transparency = 0.5
        VeilVisuals.TrackerLine.Visible = false
    end
end)

local function Veil_IsSurvivorVeil(p)
    if not p or not p.Team or not p.Team.Name then return false end
    return string.find(string.lower(p.Team.Name), "survivor", 1, true) ~= nil
end

local function Veil_IsKillerRole()
    local char = Player.Character
    if char then
        local r = char:GetAttribute("Role")
        if type(r) == "string" and string.find(string.lower(r), "killer", 1, true) then return true end
    end
    local plr = Player:GetAttribute("Role")
    if type(plr) == "string" and string.find(string.lower(plr), "killer", 1, true) then return true end
    if Player.Team and Player.Team.Name then
        return string.find(string.lower(Player.Team.Name), "killer", 1, true) ~= nil
    end
    return false
end

local function Veil_solvePitch(p, d, dy)
    d = math.max(d, 0.1)
    local s2 = p.v0 * p.v0
    local root = s2 * s2 - p.g * (p.g * d * d + 2 * dy * s2)
    if root < 0 then root = 0 end
    local tanTheta = (s2 - math.sqrt(root)) / (p.g * d)
    local theta = math.atan(tanTheta)
    local t = d / (p.v0 * math.cos(theta))
    return theta, t
end

local function Veil_getCharacterVelocity(char)
    local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
    if not root or not root:IsA("BasePart") then return Vector3.zero end
    local now = os.clock()
    local last = VeilState.velHistory[char]
    local measured = Vector3.zero
    if last and now - last.t > 0.02 then
        measured = (root.Position - last.pos) / (now - last.t)
        if measured.Magnitude > 150 then measured = last.smooth or Vector3.zero end
    end
    local smooth = last and last.smooth or measured
    smooth = smooth:Lerp(measured, 0.65)
    VeilState.velHistory[char] = { pos = root.Position, t = now, smooth = smooth }
    if smooth.Magnitude < 1 then return Vector3.zero end
    return Vector3.new(smooth.X, 0, smooth.Z)
end

Players.PlayerRemoving:Connect(function(p)
    if p.Character then VeilState.velHistory[p.Character] = nil end
end)

local function Veil_HideAllVisuals()
    if VeilVisuals.FOVCircleFill then VeilVisuals.FOVCircleFill.Visible = false end
    if VeilVisuals.FOVCircleOutline then VeilVisuals.FOVCircleOutline.Visible = false end
    if VeilVisuals.TrackerCircleFill then VeilVisuals.TrackerCircleFill.Visible = false end
    if VeilVisuals.TrackerCircleOutline then VeilVisuals.TrackerCircleOutline.Visible = false end
    if VeilVisuals.TrackerLine then VeilVisuals.TrackerLine.Visible = false end
end

local function Veil_HideTracker()
    if VeilVisuals.TrackerCircleFill then VeilVisuals.TrackerCircleFill.Visible = false end
    if VeilVisuals.TrackerCircleOutline then VeilVisuals.TrackerCircleOutline.Visible = false end
    if VeilVisuals.TrackerLine then VeilVisuals.TrackerLine.Visible = false end
end

local veilRayParams = RaycastParams.new()
veilRayParams.FilterType = Enum.RaycastFilterType.Exclude

local function Veil_IsVisible(origin, targetPos, targetChar)
    if not VD.VeilWallCheck then return true end
    local excl = {}
    local myChar = Player.Character
    if myChar then table.insert(excl, myChar) end
    if targetChar and targetChar ~= myChar then table.insert(excl, targetChar) end
    veilRayParams.FilterDescendantsInstances = excl
    local dir = targetPos - origin
    local dist = dir.Magnitude
    if dist < 0.1 then return true end
    local result = Workspace:Raycast(origin, dir.Unit * dist, veilRayParams)
    return result == nil
end

local function Veil_GetFireOrigin(char)
    if not char then return nil end
    local spear = char:FindFirstChild("Spear", true) or char:FindFirstChild("spear", true)
    if spear then
        if spear:IsA("BasePart") then return spear.Position end
        local sp = spear:FindFirstChildWhichIsA("BasePart", true)
        if sp then return sp.Position end
    end
    local hand = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
    if hand and hand:IsA("BasePart") then return hand.Position end
    local head = char:FindFirstChild("Head")
    if head and head:IsA("BasePart") then return head.Position end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp.Position + Vector3.new(0, 1.5, 0) end
    return nil
end

local VeilSpearRemotes = {}
local function Veil_ScanRemotes()
    VeilSpearRemotes = {}
    pcall(function()
        local function scan(container, depth)
            if depth > 4 then return end
            for _, obj in ipairs(container:GetChildren()) do
                if obj:IsA("RemoteEvent") then
                    local n = string.lower(obj.Name)
                    if n == "spearthrow" or n == "throw" or n == "firespear"
                        or n == "spear" or n == "throwspear" or n == "spearthrowevent"
                        or string.find(n, "spear", 1, true)
                        or string.find(n, "throw", 1, true) then
                        table.insert(VeilSpearRemotes, obj)
                    end
                elseif obj:IsA("Folder") or obj:IsA("Model") then
                    scan(obj, depth + 1)
                end
            end
        end
        scan(ReplicatedStorage, 0)
    end)
    if VD.VeilDebug then
        print("[Silent Veil] Detected spear remotes:", #VeilSpearRemotes)
        for _, r in ipairs(VeilSpearRemotes) do
            print("  -> " .. r:GetFullName())
        end
    end
end
task.spawn(Veil_ScanRemotes)

local function Veil_IsSpearRemote(obj)
    if not obj then return false end
    for _, r in ipairs(VeilSpearRemotes) do
        if r == obj then return true end
    end
    local n = string.lower(obj.Name)
    return n == "spearthrow" or string.find(n, "spear", 1, true) ~= nil
end

local function Veil_UpdateAimbot()
    if not Veil_IsKillerRole() then
        VeilState.target = nil
        VeilState.lookVector = nil
        Veil_HideAllVisuals()
        return
    end

    local cam = Workspace.CurrentCamera
    if not cam then return end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

    if VD.VeilShowFOV and VD.VeilEnabled then
        if VeilVisuals.FOVCircleOutline then
            VeilVisuals.FOVCircleOutline.Position = center
            VeilVisuals.FOVCircleOutline.Radius = VD.VeilFOV or 150
            VeilVisuals.FOVCircleOutline.Visible = true
        end
        if VeilVisuals.FOVCircleFill then
            VeilVisuals.FOVCircleFill.Position = center
            VeilVisuals.FOVCircleFill.Radius = VD.VeilFOV or 150
            VeilVisuals.FOVCircleFill.Visible = true
        end
    else
        if VeilVisuals.FOVCircleOutline then VeilVisuals.FOVCircleOutline.Visible = false end
        if VeilVisuals.FOVCircleFill then VeilVisuals.FOVCircleFill.Visible = false end
    end

    if not VD.VeilEnabled then
        VeilState.target = nil
        VeilState.lookVector = nil
        Veil_HideAllVisuals()
        return
    end
    if not VD.VeilShowTracker then
        Veil_HideTracker()
    end

    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then Veil_HideTracker(); return end

    local origin = Veil_GetFireOrigin(char)
    if not origin then Veil_HideTracker(); return end

    local nearest = nil
    local nearestPart = nil
    local bestDist = VD.VeilFOV or 150
    local bestStudDist = VD.VeilMaxDist or 500

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and Veil_IsSurvivorVeil(p) and p.Character then
            local pc = p.Character
            local isDown = pc:GetAttribute("Knocked") == true
                        or pc:GetAttribute("HookProgressDepleting") == true
                        or pc:GetAttribute("IsHooked") == true
                        or pc:GetAttribute("Downed") == true
            if not isDown then
                local hum = pc:FindFirstChildOfClass("Humanoid")
                local targetPart = pc:FindFirstChild("UpperTorso")
                                or pc:FindFirstChild("Torso")
                                or pc:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and targetPart then
                    local studDist = (targetPart.Position - origin).Magnitude
                    if studDist <= bestStudDist then
                        local sp, on = cam:WorldToViewportPoint(targetPart.Position)
                        if on and sp.Z > 0 then
                            local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if sd < bestDist then
                                if Veil_IsVisible(origin, targetPart.Position, pc) then
                                    bestDist = sd
                                    nearest = p
                                    nearestPart = targetPart
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if not (nearest and nearestPart) then
        VeilState.target = nil
        VeilState.lookVector = nil
        Veil_HideTracker()
        return
    end

    local tp = nearestPart.Position
    local dir = tp - origin
    local dist = dir.Magnitude

    if dist <= 0.1 then
        Veil_HideTracker()
        return
    end

    local isAuraActive = char:GetAttribute("special") == true
    local prof
    if isAuraActive then
        prof = {
            v0 = VD.VeilAuraSpearSpeed or 165,
            g = VD.VeilAuraSpearGravity or 96.5,
            windup = 0.10, latency = 0.04,
            maxlead = 25, scale = VD.VeilLeadMultiplier or 1.4
        }
    else
        prof = {
            v0 = VD.VeilSpearSpeed or 165,
            g = VD.VeilGravity or 103,
            windup = 0.10, latency = 0.04,
            maxlead = 45, scale = VD.VeilLeadMultiplier or 1.4
        }
    end

    local aimPoint = tp
    if VD.VeilAutoPredict then
        local vel = Veil_getCharacterVelocity(nearest.Character)
        if vel.Magnitude > 0.5 then
            local h0 = Vector3.new(dir.X, 0, dir.Z)
            local _, tFlight = Veil_solvePitch(prof, h0.Magnitude, dir.Y)
            local ping = 0.08
            pcall(function() ping = math.clamp(Player:GetNetworkPing(), 0, 0.35) end)
            local delay = tFlight + prof.windup + ping + prof.latency
            for _ = 1, 3 do
                local lead = vel * delay * prof.scale
                local maxLead = math.clamp(dist * 0.6, 3, prof.maxlead)
                if lead.Magnitude > maxLead then lead = lead.Unit * maxLead end
                aimPoint = tp + lead
                local ad = aimPoint - origin
                local ah = Vector3.new(ad.X, 0, ad.Z)
                local _, t2 = Veil_solvePitch(prof, math.max(ah.Magnitude, 0.1), ad.Y)
                delay = t2 + prof.windup + ping + prof.latency
            end
        end
    end

    local adir = aimPoint - origin
    local ah = Vector3.new(adir.X, 0, adir.Z)
    local ahDist = ah.Magnitude
    local pitch = Veil_solvePitch(prof, ahDist, adir.Y)

    if ahDist > 0.001 then
        VeilState.lookVector = ah.Unit * math.cos(pitch)
                             + Vector3.new(0, math.sin(pitch), 0)
    else
        VeilState.lookVector = adir.Unit
    end
    VeilState.target = nearest

    if VD.VeilShowTracker then
        local sp, vis = cam:WorldToViewportPoint(tp)
        local shouldShow = vis and sp.Z > 0
        if shouldShow then
            local screenDist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
            if screenDist > (VD.VeilFOV or 150) then
                shouldShow = false
            end
        end

        if shouldShow then
            local bottomCenter = Vector2.new(center.X, cam.ViewportSize.Y)
            if VeilVisuals.TrackerLine then
                VeilVisuals.TrackerLine.From = bottomCenter
                VeilVisuals.TrackerLine.To = Vector2.new(sp.X, sp.Y)
                VeilVisuals.TrackerLine.Visible = true
            end
            local radius = math.clamp(1000 / math.max(dist, 1), 10, 40)
            if VeilVisuals.TrackerCircleOutline then
                VeilVisuals.TrackerCircleOutline.Position = Vector2.new(sp.X, sp.Y)
                VeilVisuals.TrackerCircleOutline.Radius = radius
                VeilVisuals.TrackerCircleOutline.Visible = true
            end
            if VeilVisuals.TrackerCircleFill then
                VeilVisuals.TrackerCircleFill.Position = Vector2.new(sp.X, sp.Y)
                VeilVisuals.TrackerCircleFill.Radius = radius
                VeilVisuals.TrackerCircleFill.Visible = true
            end
        else
            Veil_HideTracker()
        end
    else
        Veil_HideTracker()
    end
end

local VeilHookState = { remoteHooked = false, interceptCount = 0 }
local function Veil_setupInterceptor()
    if VeilHookState.remoteHooked then return end
    if typeof(hookmetamethod) ~= "function" then return end
    task.spawn(function()
        pcall(function()
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                if not checkcaller() and method == "FireServer" then
                    if VD.VeilEnabled and typeof(VeilState.lookVector) == "Vector3" then
                        if Veil_IsSpearRemote(self) then
                            local args = {...}
                            local replaced = false
                            for i = 1, math.min(#args, 3) do
                                if typeof(args[i]) == "Vector3" then
                                    args[i] = VeilState.lookVector
                                    replaced = true
                                    break
                                end
                            end
                            if replaced then
                                VeilHookState.interceptCount = VeilHookState.interceptCount + 1
                                if VD.VeilDebug then
                                    print(string.format("[Silent Veil] FIRE #%d -> %s",
                                        VeilHookState.interceptCount, self:GetFullName()))
                                end
                                return oldNamecall(self, table.unpack(args))
                            end
                        end
                    end
                end
                return oldNamecall(self, ...)
            end)
            VeilHookState.remoteHooked = true
            if VD.VeilDebug then print("[Silent Veil] Interceptor hooked successfully!") end
        end)
    end)
end
Veil_setupInterceptor()

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F10 and VD.VeilDebug then
        Veil_ScanRemotes()
        notify("Silent Veil", "Remotes rescan done (" .. #VeilSpearRemotes .. " found)", 2)
    end
end)

RunService.RenderStepped:Connect(function() pcall(Veil_UpdateAimbot) end)

MainTab:CreateSection({ name = "Aimbot Veil V1 (Spear)" })
MainTab:CreateToggle({
    name = "Enable Silent Veil V1", value = VD.VeilEnabled,
    callback = function(v)
        VD.VeilEnabled = v
        if v then
            Veil_ScanRemotes()
            notify("Silent Veil V1", "Enabled (" .. #VeilSpearRemotes .. " remotes detected)", 3)
        else
            notify("Silent Veil V1", "Disabled", 2)
            Veil_HideAllVisuals()
        end
    end,
})
MainTab:CreateToggle({ name = "V1 Show FOV Circle", value = VD.VeilShowFOV, callback = function(v) VD.VeilShowFOV = v end })
MainTab:CreateToggle({
    name = "V1 Show Target Tracker", value = VD.VeilShowTracker,
    callback = function(v)
        VD.VeilShowTracker = v
        if not v then Veil_HideTracker() end
    end,
})
MainTab:CreateToggle({ name = "V1 Auto Predict", value = VD.VeilAutoPredict, callback = function(v) VD.VeilAutoPredict = v end })
MainTab:CreateToggle({ name = "V1 Wall Check", value = VD.VeilWallCheck, callback = function(v) VD.VeilWallCheck = v end })
MainTab:CreateToggle({
    name = "V1 Debug Mode (F10 = rescan)", value = VD.VeilDebug,
    callback = function(v)
        VD.VeilDebug = v
        if v then Veil_ScanRemotes() end
    end,
})
MainTab:CreateSlider({ name = "V1 FOV Size", range = {50, 500}, increment = 10, value = VD.VeilFOV, callback = function(v) VD.VeilFOV = v end })
MainTab:CreateSlider({ name = "V1 Max Distance", range = {50, 1000}, increment = 10, value = VD.VeilMaxDist, callback = function(v) VD.VeilMaxDist = v end })
MainTab:CreateSlider({ name = "V1 Spear Speed", range = {50, 400}, increment = 5, value = VD.VeilSpearSpeed, callback = function(v) VD.VeilSpearSpeed = v end })
MainTab:CreateSlider({ name = "V1 Spear Gravity", range = {10, 300}, increment = 1, value = VD.VeilGravity, callback = function(v) VD.VeilGravity = v end })
MainTab:CreateSlider({ name = "V1 Aura Spear Speed", range = {50, 400}, increment = 5, value = VD.VeilAuraSpearSpeed, callback = function(v) VD.VeilAuraSpearSpeed = v end })
MainTab:CreateSlider({ name = "V1 Aura Spear Gravity", range = {10, 300}, increment = 1, value = VD.VeilAuraSpearGravity, callback = function(v) VD.VeilAuraSpearGravity = v end })
MainTab:CreateSlider({ name = "V1 Lead Multiplier", range = {0.1, 5}, increment = 0.1, value = VD.VeilLeadMultiplier, callback = function(v) VD.VeilLeadMultiplier = v end })

--========================================================--
-- 6b. AUTO PARRY V1
--========================================================--
local ParryState = {
    LastParry = 0, ActiveAttackers = {},
    CircleFolder = nil, CircleDashes = {}, CircleRotCFs = {}, CircleOffsets = {},
    CircleRadius = 0, CircleBuiltForDagger = false,
    CircleLastX = math.huge, CircleLastY = math.huge, CircleLastZ = math.huge,
    CircleLastAlpha = -1, CircleLastR = -1, CircleLastG = -1, CircleLastB = -1,
}

local ParryCooldown = {
    OnCooldown = false, CooldownEnd = 0, CooldownDuration = 0,
    WaitingForResult = false, WaitingStart = 0, WaitTimeout = 2.0,
    FallbackCooldown = 60, MaxCooldown = 90,
    LastFiredAt = 0, IsSilenced = false, JustFired = false,
    ManualDetect = false, ManualIgnoreWindow = 0.35,
}

local parryResultRemote = nil
local parryFireRemote = nil
pcall(function()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        local items = remotes:FindFirstChild("Items")
        if items then
            local dagger = items:FindFirstChild("Parrying Dagger")
            if dagger then
                parryResultRemote = dagger:FindFirstChild("parryResult")
                parryFireRemote = dagger:FindFirstChild("parry")
            end
        end
    end
end)

local KillerAttackAnims = {
    ["78432063483146"]="attack", ["121216847022485"]="attack",
    ["74968262036854"]="attack", ["132817836308238"]="attack",
    ["82666958311998"]="attack", ["111920872708571"]="attack",
    ["106871536134254"]="attack", ["109402730355822"]="attack",
    ["130593238885843"]="attack", ["138720291317243"]="attack",
    ["139369275981139"]="attack", ["133963973694098"]="attack",
    ["78935059863801"]="attack",
    ["118907603246885"]="lungehold", ["135002183282873"]="lungehold",
    ["113255068724446"]="lungehold", ["129784271201071"]="lungehold",
    ["105374834496520"]="lungehold", ["117070354890871"]="lungehold",
    ["115244153053858"]="lungehold", ["110355011987939"]="lungehold",
    ["117042998468241"]="lungehold", ["122812055447896"]="lungehold",
}

local function ParryStartCooldown(duration)
    duration = math.clamp(tonumber(duration) or 0, 0, ParryCooldown.MaxCooldown)
    if duration <= 0 then duration = ParryCooldown.FallbackCooldown end
    ParryCooldown.OnCooldown = true
    ParryCooldown.CooldownDuration = duration
    ParryCooldown.CooldownEnd = os.clock() + duration
    ParryCooldown.WaitingForResult = false
    ParryCooldown.JustFired = false
    ParryCooldown.ManualDetect = false
end

local function ParryClearCooldown()
    ParryCooldown.OnCooldown = false
    ParryCooldown.CooldownEnd = 0
    ParryCooldown.CooldownDuration = 0
    ParryCooldown.WaitingForResult = false
    ParryCooldown.JustFired = false
    ParryCooldown.ManualDetect = false
end

local function ParryIsOnCooldown()
    if not ParryCooldown.OnCooldown then return false end
    if os.clock() >= ParryCooldown.CooldownEnd then ParryClearCooldown(); return false end
    return true
end

if parryResultRemote then
    parryResultRemote.OnClientEvent:Connect(function(success, cooldown)
        if not ParryCooldown.WaitingForResult and not ParryCooldown.JustFired then return end
        local cd = tonumber(cooldown) or 0
        if success and cd > 0 then ParryStartCooldown(math.min(cd, ParryCooldown.MaxCooldown))
        else ParryStartCooldown(ParryCooldown.FallbackCooldown) end
    end)
end

local function ParryHookSilenced(char)
    if not char then return end
    ParryCooldown.IsSilenced = CollectionService:HasTag(char, "Silenced")
end

CollectionService:GetInstanceAddedSignal("Silenced"):Connect(function(inst)
    if inst == LocalPlayer.Character then ParryCooldown.IsSilenced = true end
end)
CollectionService:GetInstanceRemovedSignal("Silenced"):Connect(function(inst)
    if inst == LocalPlayer.Character then ParryCooldown.IsSilenced = false end
end)

LocalPlayer.CharacterAdded:Connect(function(char) task.wait(0.5); ParryHookSilenced(char) end)
if LocalPlayer.Character then ParryHookSilenced(LocalPlayer.Character) end

local ParryCharCache = { Char = nil, Root = nil, Hum = nil, UpperTorso = nil, CheckInt = nil }
local function ParryGetCharCache()
    local char = LocalPlayer.Character
    if char ~= ParryCharCache.Char then
        ParryCharCache.Char = char
        ParryCharCache.Root = nil; ParryCharCache.Hum = nil
        ParryCharCache.UpperTorso = nil; ParryCharCache.CheckInt = nil
    end
    if not char then return ParryCharCache end
    if not ParryCharCache.Root then ParryCharCache.Root = char:FindFirstChild("HumanoidRootPart") end
    if not ParryCharCache.Hum then ParryCharCache.Hum = char:FindFirstChildOfClass("Humanoid") end
    if not ParryCharCache.UpperTorso then ParryCharCache.UpperTorso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") end
    if not ParryCharCache.CheckInt then ParryCharCache.CheckInt = char:FindFirstChild("CheckInterractable") end
    return ParryCharCache
end

local DaggerCache = { Value = false, LastCheck = 0, Interval = 0.15 }
local function ParryIsDaggerModel(inst)
    if not inst then return false end
    if inst:IsA("Model") then return true end
    if inst:IsA("Tool") or inst:IsA("Accessory") then return true end
    return false
end
local function ParryIsEquippedDagger()
    local now = os.clock()
    if now - DaggerCache.LastCheck < DaggerCache.Interval then return DaggerCache.Value end
    DaggerCache.LastCheck = now
    local hasDagger = false
    local char = LocalPlayer.Character
    if char then
        local dagger = char:FindFirstChild("Parrying Dagger")
        if ParryIsDaggerModel(dagger) then hasDagger = true end
    end
    if not hasDagger then
        local wsChar = Workspace:FindFirstChild(LocalPlayer.Name)
        if wsChar then
            local wsDagger = wsChar:FindFirstChild("Parrying Dagger")
            if ParryIsDaggerModel(wsDagger) then hasDagger = true end
        end
    end
    DaggerCache.Value = hasDagger
    return hasDagger
end

LocalPlayer.CharacterAdded:Connect(function() DaggerCache.Value = false; DaggerCache.LastCheck = 0 end)

local ParryCheckAttrs = {"isVaulting","isSliding","isDroppingPallet","isRepairing","isHealing","isUnhooking","isExiting"}
local function ParryIsBusy()
    local cc = ParryGetCharCache()
    if not cc.Char then return true end
    if LocalPlayer:GetAttribute("IsDead") then return true end
    if cc.Char:GetAttribute("IsCarried") then return true end
    if cc.Char:GetAttribute("IsHooked") then return true end
    local root = cc.Root
    if root and CollectionService:HasTag(root, "doing action") then return true end
    local ci = cc.CheckInt
    if ci then
        for i = 1, #ParryCheckAttrs do
            if ci:GetAttribute(ParryCheckAttrs[i]) then return true end
        end
    end
    return false
end

local function ParryIsLowHealth()
    local cc = ParryGetCharCache()
    local hum = cc.Hum
    if not hum then return false end
    return hum.Health < hum.MaxHealth * 0.5
end

local function ParryCanFire()
    if not ParryIsEquippedDagger() then return false end
    if ParryCooldown.IsSilenced then return false end
    if ParryIsOnCooldown() then return false end
    if ParryCooldown.WaitingForResult then return false end
    if ParryIsBusy() then return false end
    if ParryIsLowHealth() then return false end
    return true
end

local function ParryExecuteMobile()
    local didFire = false
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui and type(firesignal) == "function" then
        local mobRoot = pGui:FindFirstChild("Survivor-mob")
        local controls = mobRoot and mobRoot:FindFirstChild("Controls")
        if controls then
            local candidatePaths = {"Gui-mob", "action", "Gui-mobile", "Gui_mob", "Parry", "parry"}
            for _, btnName in ipairs(candidatePaths) do
                local btn = controls:FindFirstChild(btnName)
                if btn and btn:IsA("GuiButton") then
                    pcall(function()
                        firesignal(btn.MouseButton1Down)
                        task.delay(0.05, function()
                            if btn and btn.Parent then
                                firesignal(btn.MouseButton1Up)
                                firesignal(btn.MouseButton1Click)
                            end
                        end)
                    end)
                    didFire = true
                    break
                end
            end
        end
    end
    if not didFire and parryFireRemote then
        pcall(function() parryFireRemote:FireServer() end)
    end
end

local function ParryExecutePC()
    pcall(function()
        VirtualInputManager:SendMouseMoveEvent(0, 0, game)
        task.wait(0.005)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 2, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 2, false, game, 0)
    end)
end

local function ParryExecuteSilent()
    if parryFireRemote then
        pcall(function() parryFireRemote:FireServer() end)
        return true
    end
    return false
end

local function ParryExecute()
    if not ParryCanFire() then return end
    ParryState.LastParry = os.clock()
    ParryCooldown.LastFiredAt = os.clock()
    ParryCooldown.WaitingForResult = true
    ParryCooldown.WaitingStart = os.clock()
    ParryCooldown.JustFired = true
    ParryCooldown.ManualDetect = false
    if VD.PARRY_SilentParry then ParryExecuteSilent(); return end
    if isMobile then ParryExecuteMobile() else ParryExecutePC() end
end

local function ParryMarkManual()
    if not ParryIsEquippedDagger() then return end
    if ParryCooldown.IsSilenced then return end
    if os.clock() - ParryCooldown.LastFiredAt < ParryCooldown.ManualIgnoreWindow then return end
    if ParryCooldown.OnCooldown or ParryCooldown.WaitingForResult then return end
    ParryCooldown.WaitingForResult = true
    ParryCooldown.WaitingStart = os.clock()
    ParryCooldown.JustFired = true
    ParryCooldown.ManualDetect = true
    ParryCooldown.LastFiredAt = os.clock()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
    if gameProcessed then return end
    ParryMarkManual()
end)

local function ParryGetHitboxPart(char)
    if not char then return nil end
    return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
end

local function ParryCheckAndParry(killerChar)
    if ParryIsOnCooldown() then return end
    if ParryCooldown.WaitingForResult then return end
    if ParryCooldown.IsSilenced then return end
    if not ParryIsEquippedDagger() then return end
    local cc = ParryGetCharCache()
    local myRoot = cc.UpperTorso or cc.Root
    local killerPart = ParryGetHitboxPart(killerChar)
    if not myRoot or not killerPart then return end
    local dist = (myRoot.Position - killerPart.Position).Magnitude
    if VD.PARRY_Aggressive then
        local ping = math.clamp(LocalPlayer:GetNetworkPing(), 0, 0.3)
        local killerRoot = killerChar:FindFirstChild("HumanoidRootPart") or killerPart
        local killerVel = killerRoot.AssemblyLinearVelocity
        local flatVel = Vector3.new(killerVel.X, 0, killerVel.Z)
        local predictedPos = killerPart.Position + (flatVel * ping)
        local predictedDist = (myRoot.Position - predictedPos).Magnitude
        if predictedDist <= ((VD.PARRY_Distance or 10) + 2.5) then
            local dirToMe = (myRoot.Position - killerPart.Position).Unit
            if flatVel.Magnitude > 6 and flatVel.Unit:Dot(dirToMe) > 0.4 then
                ParryExecute(); return
            end
        end
    end
    if dist <= (VD.PARRY_Distance or 10) then ParryExecute() end
end

local function ParryDestroyCircle()
    if ParryState.CircleFolder then
        pcall(function()
            if ParryState.CircleFolder and ParryState.CircleFolder.Parent then
                ParryState.CircleFolder:Destroy()
            end
        end)
    end
    ParryState.CircleFolder = nil
    ParryState.CircleDashes = {}
    ParryState.CircleRotCFs = {}
    ParryState.CircleOffsets = {}
    ParryState.CircleRadius = 0
    ParryState.CircleBuiltForDagger = false
    ParryState.CircleLastX = math.huge; ParryState.CircleLastY = math.huge; ParryState.CircleLastZ = math.huge
    ParryState.CircleLastAlpha = -1; ParryState.CircleLastR = -1; ParryState.CircleLastG = -1; ParryState.CircleLastB = -1
end
getgenv().ALFzxzzz_Parry_DestroyCircle = ParryDestroyCircle

local function ParryBuildCircle(radius)
    ParryDestroyCircle()
    local folder = Instance.new("Folder")
    folder.Name = "ALFzxzzz_ParryCircleDashes"
    local dashCount = math.clamp(math.floor(radius * 6), 24, 120)
    local slotLength = (2 * math.pi * radius) / dashCount
    local dashLength = slotLength * 0.55
    local dashThickness = 0.03
    local dashes = table.create(dashCount)
    local rotCFs = table.create(dashCount)
    local offsets = table.create(dashCount)
    for i = 1, dashCount do
        local part = Instance.new("Part")
        part.Name = "Dash" .. i
        part.Anchored = true; part.CanCollide = false; part.CanTouch = false
        part.CanQuery = false; part.CastShadow = false
        part.Material = Enum.Material.Neon
        part.Color = Color3.fromRGB(255, 255, 255)
        part.Transparency = 0
        part.Size = Vector3.new(dashThickness, dashThickness, dashLength)
        part.Parent = folder
        local angle = ((i - 1) / dashCount) * math.pi * 2
        local cosA = math.cos(angle); local sinA = math.sin(angle)
        local tangent = Vector3.new(-sinA, 0, cosA)
        rotCFs[i] = CFrame.lookAt(Vector3.zero, tangent)
        offsets[i] = Vector3.new(cosA * radius, 0, sinA * radius)
        dashes[i] = part
    end
    folder.Parent = Workspace
    ParryState.CircleFolder = folder
    ParryState.CircleDashes = dashes
    ParryState.CircleRotCFs = rotCFs
    ParryState.CircleOffsets = offsets
    ParryState.CircleRadius = radius
    ParryState.CircleBuiltForDagger = true
end

local parryRayParams = RaycastParams.new()
parryRayParams.FilterType = Enum.RaycastFilterType.Exclude

local function ParryUpdateCircle(myRoot)
    if not ParryState.CircleFolder or not ParryState.CircleFolder.Parent then return end
    local dashes = ParryState.CircleDashes
    local dashCount = #dashes
    if dashCount == 0 then return end

    local char = LocalPlayer.Character
    parryRayParams.FilterDescendantsInstances = { char }
    local rayResult = Workspace:Raycast(myRoot.Position, Vector3.new(0, -20, 0), parryRayParams)
    local floorY
    if rayResult then
        floorY = rayResult.Position.Y + 0.05
    else
        floorY = myRoot.Position.Y - ((myRoot.Size.Y * 0.5) + 2.6)
    end
    local center = Vector3.new(myRoot.Position.X, floorY, myRoot.Position.Z)

    local busy = ParryIsBusy()
    local onCooldown = ParryCooldown.OnCooldown
    local targetColor
    if busy then targetColor = Color3.fromRGB(255, 20, 20)
    elseif onCooldown then targetColor = Color3.fromRGB(255, 140, 0)
    else targetColor = Color3.fromRGB(255, 255, 255) end
    local targetTransparency = 0
    if onCooldown then
        local period = 0.55
        local phase = (os.clock() % period) / period
        local pulse = (math.cos(phase * math.pi * 2) + 1) * 0.5
        targetTransparency = (1 - pulse) * 0.85
    end
    local dx = math.abs(center.X - ParryState.CircleLastX)
    local dy = math.abs(center.Y - ParryState.CircleLastY)
    local dz = math.abs(center.Z - ParryState.CircleLastZ)
    local dA = math.abs(targetTransparency - ParryState.CircleLastAlpha)
    local r, g, b = targetColor.R * 255, targetColor.G * 255, targetColor.B * 255
    local dR = math.abs(r - ParryState.CircleLastR)
    local dG = math.abs(g - ParryState.CircleLastG)
    local dB = math.abs(b - ParryState.CircleLastB)
    if dx < 0.01 and dy < 0.01 and dz < 0.01 and dA < 0.005 and dR < 2 and dG < 2 and dB < 2 then return end
    ParryState.CircleLastX = center.X; ParryState.CircleLastY = center.Y; ParryState.CircleLastZ = center.Z
    ParryState.CircleLastAlpha = targetTransparency
    ParryState.CircleLastR = r; ParryState.CircleLastG = g; ParryState.CircleLastB = b
    local rotCFs = ParryState.CircleRotCFs
    local offsets = ParryState.CircleOffsets
    for i = 1, dashCount do
        local dash = dashes[i]
        if dash and dash.Parent then
            local off = offsets[i]
            local worldPos = Vector3.new(center.X + off.X, center.Y, center.Z + off.Z)
            dash.CFrame = rotCFs[i] + worldPos
            dash.Color = targetColor
            dash.Transparency = targetTransparency
        end
    end
end

local function ParryGetAnimType(track)
    if not track or not track.Animation then return nil end
    local animId = track.Animation.AnimationId or ""
    local numId = animId:match("%d+") or ""
    local name = string.lower(track.Animation.Name or "")
    local v = KillerAttackAnims[animId]
    if v then return v end
    if numId ~= "" then
        v = KillerAttackAnims[numId]
        if v then return v end
    end
    if string.find(name, "lunge", 1, true) or string.find(name, "charge", 1, true) then return "lungehold" end
    if string.find(name, "attack", 1, true) or string.find(name, "slash", 1, true)
        or string.find(name, "swing", 1, true) or string.find(name, "stab", 1, true)
        or string.find(name, "melee", 1, true) then return "attack" end
    return nil
end

local function ParryHookAnimatorOnChar(plr, char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator", 3)
    if not animator then return end
    animator.AnimationPlayed:Connect(function(track)
        if not VD.PARRY_Enabled then return end
        if not ParryIsEquippedDagger() then return end
        local animType = ParryGetAnimType(track)
        if animType then
            ParryState.ActiveAttackers[plr] = {
                char = char, track = track, type = animType, registeredAt = os.clock()
            }
        end
    end)
end

local function ParryHookKillerPlayer(plr)
    if plr == LocalPlayer then return end
    if plr.Character then ParryHookAnimatorOnChar(plr, plr.Character) end
    plr.CharacterAdded:Connect(function(char) task.wait(0.5); ParryHookAnimatorOnChar(plr, char) end)
end

for _, plr in ipairs(Players:GetPlayers()) do ParryHookKillerPlayer(plr) end
Players.PlayerAdded:Connect(ParryHookKillerPlayer)

local parryLastPoll = 0
local PARRY_POLL_INTERVAL = 0.15
local function ParryPollAttacks()
    if not VD.PARRY_Enabled then return end
    if not ParryIsEquippedDagger() then return end
    local now = os.clock()
    if now - parryLastPoll < PARRY_POLL_INTERVAL then return end
    parryLastPoll = now
    local allPlayers = Players:GetPlayers()
    for i = 1, #allPlayers do
        local plr = allPlayers[i]
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    local tracks = hum:GetPlayingAnimationTracks()
                    for j = 1, #tracks do
                        local track = tracks[j]
                        local animType = ParryGetAnimType(track)
                        if animType then
                            local existing = ParryState.ActiveAttackers[plr]
                            if not existing or existing.track ~= track then
                                ParryState.ActiveAttackers[plr] = {
                                    char = char, track = track, type = animType, registeredAt = now
                                }
                            end
                        end
                    end
                end
            end
        end
    end
end

local parryLastCleanup = 0
local PARRY_CLEANUP_INTERVAL = 1.0
local function ParryCleanupAttackers()
    local now = os.clock()
    if now - parryLastCleanup < PARRY_CLEANUP_INTERVAL then return end
    parryLastCleanup = now
    for plr, data in pairs(ParryState.ActiveAttackers) do
        if not plr or not plr.Parent or not data.track or not data.track.IsPlaying then
            ParryState.ActiveAttackers[plr] = nil
        end
    end
end

local function ParryUpdateLogic()
    local myChar = LocalPlayer.Character
    if not myChar then return end
    if not VD.PARRY_Enabled then return end
    if not ParryIsEquippedDagger() then
        if next(ParryState.ActiveAttackers) then ParryState.ActiveAttackers = {} end
        return
    end
    if ParryCooldown.WaitingForResult then
        if os.clock() - ParryCooldown.WaitingStart > ParryCooldown.WaitTimeout then
            if ParryCooldown.ManualDetect then
                ParryCooldown.WaitingForResult = false
                ParryCooldown.JustFired = false
                ParryCooldown.ManualDetect = false
            else
                ParryStartCooldown(ParryCooldown.FallbackCooldown)
            end
        end
    end
    if ParryIsOnCooldown() or ParryCooldown.WaitingForResult then return end
    ParryPollAttacks()
    ParryCleanupAttackers()
    for plr, data in pairs(ParryState.ActiveAttackers) do
        if plr and plr.Parent and data.track and data.track.IsPlaying then
            local shouldCheck = false
            if data.type == "attack" then
                if data.track.TimePosition < 0.35 then shouldCheck = true end
            elseif data.type == "lungehold" then
                shouldCheck = true
            end
            if shouldCheck then
                ParryCheckAndParry(data.char)
                if ParryCooldown.WaitingForResult then break end
            end
        else
            ParryState.ActiveAttackers[plr] = nil
        end
    end
end

local function ParryUpdateCircleLogic()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local hasDagger = ParryIsEquippedDagger()
    if VD.PARRY_ShowCircle and VD.PARRY_Enabled and hasDagger and myRoot then
        if not ParryState.CircleFolder
            or ParryState.CircleRadius ~= (VD.PARRY_Distance or 10)
            or not ParryState.CircleFolder.Parent then
            ParryBuildCircle(VD.PARRY_Distance or 10)
        end
        ParryUpdateCircle(myRoot)
    else
        if ParryState.CircleFolder then ParryDestroyCircle() end
    end
end

local PARRY_LOGIC_INTERVAL  = 0.05
local PARRY_CIRCLE_INTERVAL = 0.033
local parryLastLogic  = 0
local parryLastCircle = 0
RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if now - parryLastCircle >= PARRY_CIRCLE_INTERVAL then
        parryLastCircle = now
        pcall(ParryUpdateCircleLogic)
    end
    if now - parryLastLogic >= PARRY_LOGIC_INTERVAL then
        parryLastLogic = now
        pcall(ParryUpdateLogic)
    end
end)

MainTab:CreateSection({ name = "Auto Parry V1 (Parrying Dagger)" })
MainTab:CreateToggle({
    name = "Enable Auto Parry V1",
    value = VD.PARRY_Enabled,
    callback = function(v)
        VD.PARRY_Enabled = v
        notify("Auto Parry V1", v and "Enabled" or "Disabled", 2)
    end,
})
MainTab:CreateToggle({
    name = "Auto Parry V1 Aggressive",
    value = VD.PARRY_Aggressive,
    callback = function(v) VD.PARRY_Aggressive = v end,
})
MainTab:CreateSlider({
    name = "Parry V1 Distance",
    range = {4, 30}, increment = 1, value = VD.PARRY_Distance,
    callback = function(v) VD.PARRY_Distance = v end,
})
MainTab:CreateToggle({
    name = "Show Parry V1 Range",
    value = VD.PARRY_ShowCircle,
    callback = function(v)
        VD.PARRY_ShowCircle = v
        if not v and getgenv().ALFzxzzz_Parry_DestroyCircle then
            pcall(getgenv().ALFzxzzz_Parry_DestroyCircle)
        end
    end,
})
MainTab:CreateToggle({
    name = "Silent Parry V1 (Legit)",
    value = VD.PARRY_SilentParry,
    callback = function(v) VD.PARRY_SilentParry = v end,
})

--========================================================--
-- 6b2. AUTO PARRY V2 (MAIN ONLY)
--========================================================--
W.ParryV2 = W.ParryV2 or {
    Enabled = false,
    Aggressive = false,
    Radius = 15,
    FaceSensitivity = 0.7,
    SafetyParry = false,
    ShowCircle = true,
    CircleColor = Color3.fromRGB(0, 255, 255),
    IgnoredSkills = {},
    Cooldown = false,
    CooldownThread = nil,
    LastParry = 0,
    Debounce = 0.2,
    Active = false,
    Adornment = nil,
    Attached = {},
    ResultConn = nil,
    MonitorConn = nil,
    CircleConn = nil,
}
local ParryV2 = W.ParryV2

local PARRY_V2_IDS = {
    ["122812055447896"] = "Veil lunge",
    ["133963973694098"] = "Mayers Basic",
    ["117042998468241"] = "Mayers lunge",
    ["135002183282873"] = "cure lunge",
    ["121216847022485"] = "cure Basic",
    ["132817836308238"] = "Jeff Basic",
    ["129784271201071"] = "Jeff lunge",
    ["82666958311998"] = "Jeff Frenzy",
    ["78432063483146"] = "Abyssal Basic",
    ["118907603246885"] = "Abyssal lunge",
    ["139369275981139"] = "Jason Basic",
    ["110355011987939"] = "Jason lunge",
    ["111920872708571"] = "Masked Basic",
    ["105374834496520"] = "Masked lunge",
    ["138720291317243"] = "Masked Tony",
    ["106871536134254"] = "Masked Alex",
    ["130593238885843"] = "Masked Cobra",
    ["115244153053858"] = "Masked Cobra lunge",
    ["74968262036854"] = "Hidden Basic",
    ["113255068724446"] = "Hidden lunge",
    ["98163597193511"] = "Hidden S1",
    ["80411309607666"] = "Abyssal S1",
}
local PARRY_V2_CROUCH_IDS = { ["80411309607666"] = true }

local ParryV2FireRemote = nil
local ParryV2ResultRemote = nil
pcall(function()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        local items = remotes:FindFirstChild("Items")
        if items then
            local dagger = items:FindFirstChild("Parrying Dagger")
            if dagger then
                ParryV2FireRemote = dagger:FindFirstChild("parry")
                ParryV2ResultRemote = dagger:FindFirstChild("parryResult")
            end
        end
    end
end)

local function ParryV2_IsSafeToParry(char)
    if not ParryV2.SafetyParry then return true end
    if not char then return false end
    local ci = char:FindFirstChild("CheckInterractable")
    if ci then
        if ci:GetAttribute("isVaulting") == true then return false end
        if ci:GetAttribute("isRepairing") == true then return false end
        if ci:GetAttribute("isUnhooking") == true then return false end
        if ci:GetAttribute("isHealing") == true then return false end
        if ci:GetAttribute("isSliding") == true then return false end
    end
    return true
end

local function ParryV2_TapMobile()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not pGui then return false end
    local mob = pGui:FindFirstChild("Survivor-mob")
    local btn = mob and mob:FindFirstChild("Controls") and mob.Controls:FindFirstChild("Gui-mob")
    if btn and btn.Visible and type(firesignal) == "function" then
        pcall(function()
            firesignal(btn.MouseButton1Down)
            task.wait(0.01)
            firesignal(btn.MouseButton1Up)
        end)
        return true
    end
    return false
end

local function ParryV2_Execute()
    if not ParryV2.Enabled then return end
    if ParryV2.Cooldown then return end
    local now = tick()
    if now - ParryV2.LastParry < ParryV2.Debounce then return end
    ParryV2.LastParry = now
    ParryV2.Active = true
    task.delay(0.3, function() ParryV2.Active = false end)
    pcall(function()
        if ParryV2FireRemote then
            for i = 1, 10 do ParryV2FireRemote:FireServer() end
        end
    end)
    task.spawn(function()
        if not ParryV2_TapMobile() then
            pcall(function()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
                task.wait(0.01)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
            end)
        end
    end)
end

local function ParryV2_ListenResult()
    if ParryV2.ResultConn then return end
    if not ParryV2ResultRemote then return end
    ParryV2.ResultConn = ParryV2ResultRemote.OnClientEvent:Connect(function(arg1, arg2)
        local cdDur = tonumber(arg2) or ((arg1 == true) and 90 or 60)
        ParryV2.Cooldown = true
        if ParryV2.CooldownThread then task.cancel(ParryV2.CooldownThread) end
        ParryV2.CooldownThread = task.delay(cdDur, function()
            ParryV2.Cooldown = false
        end)
    end)
end
ParryV2_ListenResult()

local function ParryV2_AttachSensor(kChar)
    if not kChar or ParryV2.Attached[kChar] then return end
    ParryV2.Attached[kChar] = true
    local hum = kChar:FindFirstChildOfClass("Humanoid")
    if not hum then
        hum = kChar:WaitForChild("Humanoid", 5)
        if not hum then return end
    end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = hum:WaitForChild("Animator", 5)
        if not animator then return end
    end

    hum.ChildAdded:Connect(function(child)
        if child:IsA("Animator") then
            ParryV2.Attached[kChar] = nil
            ParryV2_AttachSensor(kChar)
        end
    end)
    kChar.AncestryChanged:Connect(function(_, parent)
        if not parent then ParryV2.Attached[kChar] = nil end
    end)

    animator.AnimationPlayed:Connect(function(track)
        if not ParryV2.Enabled then return end
        local animId = track.Animation and track.Animation.AnimationId or ""
        local id = animId:match("%d+")
        if not id then return end
        local attackName = PARRY_V2_IDS[id]
        if not attackName then return end

        if PARRY_V2_CROUCH_IDS[id] then return end

        if ParryV2.Cooldown then return end
        if ParryV2.IgnoredSkills and ParryV2.IgnoredSkills[attackName] then return end

        local myChar = LocalPlayer.Character
        if not myChar or myChar:GetAttribute("Knocked") or myChar:GetAttribute("IsHooked") then return end
        if not ParryV2_IsSafeToParry(myChar) then return end
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        local kHRP = kChar:FindFirstChild("HumanoidRootPart")
        if not myHRP or not kHRP then return end

        local delta = myHRP.Position - kHRP.Position
        local startDistance = delta.Magnitude

        if ParryV2.Aggressive then
            local aggressiveRadius = 12
            local detectionRadius = ParryV2.Radius + 5
            if startDistance > detectionRadius then return end
            if startDistance <= aggressiveRadius then
                ParryV2_Execute()
            else
                local tracker
                local startTime = os.clock()
                tracker = RunService.Heartbeat:Connect(function()
                    if os.clock() - startTime >= 1.5 or ParryV2.Cooldown
                        or not myHRP or not myHRP.Parent
                        or not kHRP or not kHRP.Parent
                        or myChar:GetAttribute("Knocked") then
                        if tracker then tracker:Disconnect() end
                        return
                    end
                    local cd = (myHRP.Position - kHRP.Position).Magnitude
                    if cd <= aggressiveRadius then
                        ParryV2_Execute()
                        if tracker then tracker:Disconnect() end
                    end
                end)
            end
        else
            if startDistance > ParryV2.Radius then return end
            local myFlat = Vector3.new(myHRP.Position.X, 0, myHRP.Position.Z)
            local kFlat  = Vector3.new(kHRP.Position.X, 0, kHRP.Position.Z)
            local flatDelta = myFlat - kFlat
            if flatDelta.Magnitude > 0 then
                local flatDir = flatDelta.Unit
                local kLook = Vector3.new(kHRP.CFrame.LookVector.X, 0, kHRP.CFrame.LookVector.Z).Unit
                local isFacing = kLook:Dot(flatDir)
                if isFacing < ParryV2.FaceSensitivity then return end
            end
            ParryV2_Execute()
        end
    end)
end

local function ParryV2_TryAttach(p)
    if p == LocalPlayer then return end
    local isKiller = p.Team and p.Team.Name == "Killer"
    if isKiller and p.Character then ParryV2_AttachSensor(p.Character) end
end

local function ParryV2_SetupPlayer(p)
    if p == LocalPlayer then return end
    p.CharacterAdded:Connect(function() task.wait(0.5); ParryV2_TryAttach(p) end)
    p:GetPropertyChangedSignal("Team"):Connect(function() ParryV2_TryAttach(p) end)
    if p.Character then ParryV2_TryAttach(p) end
end

local function ParryV2_UpdateCircle()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    if not myRoot or not ParryV2.Enabled or not ParryV2.ShowCircle then
        if ParryV2.Adornment then
            pcall(function() ParryV2.Adornment:Destroy() end)
            ParryV2.Adornment = nil
        end
        return
    end

    if not ParryV2.Adornment or ParryV2.Adornment.Parent ~= myRoot then
        if ParryV2.Adornment then
            pcall(function() ParryV2.Adornment:Destroy() end)
        end
        ParryV2.Adornment = Instance.new("CylinderHandleAdornment")
        ParryV2.Adornment.Name = "ParryV2RangeCircle"
        ParryV2.Adornment.Height = 0.05
        ParryV2.Adornment.Transparency = 0.3
        ParryV2.Adornment.Adornee = myRoot
        ParryV2.Adornment.Parent = myRoot
        ParryV2.Adornment.ZIndex = 0
        ParryV2.Adornment.AlwaysOnTop = false
    end

    local radius = ParryV2.Radius
    ParryV2.Adornment.Radius = radius
    ParryV2.Adornment.InnerRadius = math.max(0.1, radius - 0.15)
    ParryV2.Adornment.CFrame = CFrame.new(0, -3, 0) * CFrame.Angles(math.rad(90), 0, 0)

    if ParryV2.Cooldown then
        ParryV2.Adornment.Color3 = Color3.fromRGB(255, 128, 0)
    elseif ParryV2.Aggressive then
        ParryV2.Adornment.Color3 = Color3.fromRGB(255, 0, 0)
    else
        ParryV2.Adornment.Color3 = ParryV2.CircleColor or Color3.fromRGB(0, 255, 255)
    end
end

function W.ParryV2_Start()
    ParryV2.Enabled = true
    ParryV2_ListenResult()
    for _, p in ipairs(Players:GetPlayers()) do ParryV2_SetupPlayer(p) end
    if not ParryV2.MonitorConn then
        ParryV2.MonitorConn = Players.PlayerAdded:Connect(ParryV2_SetupPlayer)
    end
    if not ParryV2.CircleConn then
        ParryV2.CircleConn = RunService.Heartbeat:Connect(function()
            pcall(ParryV2_UpdateCircle)
        end)
    end
    task.spawn(function()
        while ParryV2.Enabled do
            task.wait(5)
            if not ParryV2.Enabled then break end
            for _, p in ipairs(Players:GetPlayers()) do ParryV2_TryAttach(p) end
        end
    end)
end

function W.ParryV2_Stop()
    ParryV2.Enabled = false
    ParryV2.Attached = {}
    if ParryV2.Adornment then
        pcall(function() ParryV2.Adornment:Destroy() end)
        ParryV2.Adornment = nil
    end
    if ParryV2.CircleConn then
        pcall(function() ParryV2.CircleConn:Disconnect() end)
        ParryV2.CircleConn = nil
    end
end

MainTab:CreateSection({ name = "Auto Parry V2 (Wisnu Sensor)" })
MainTab:CreateToggle({
    name = "Enable Auto Parry V2", value = ParryV2.Enabled,
    callback = function(v)
        if v then W.ParryV2_Start() else W.ParryV2_Stop() end
        if FloatingButtons.ParryV2 then FloatingButtons.ParryV2.UpdateVisual() end
        notify("Auto Parry V2", v and "Enabled (Sensor attached)" or "Disabled", 2)
    end,
})
MainTab:CreateToggle({
    name = "Parry V2 Aggressive Mode", value = ParryV2.Aggressive,
    callback = function(v) ParryV2.Aggressive = v end,
})
MainTab:CreateSlider({
    name = "Parry V2 Radius", range = {5, 30}, increment = 1, value = ParryV2.Radius,
    callback = function(v) ParryV2.Radius = v end,
})
MainTab:CreateSlider({
    name = "Parry V2 Face Sensitivity (x10)", range = {-10, 10}, increment = 1,
    value = math.floor(ParryV2.FaceSensitivity * 10),
    callback = function(v) ParryV2.FaceSensitivity = v / 10 end,
})
MainTab:CreateToggle({
    name = "Parry V2 Safety (Skip While Busy)", value = ParryV2.SafetyParry,
    callback = function(v) ParryV2.SafetyParry = v end,
})
MainTab:CreateToggle({
    name = "Parry V2 Show Range Circle", value = ParryV2.ShowCircle,
    callback = function(v) ParryV2.ShowCircle = v end,
})
MainTab:CreateColorPicker({
    name = "Parry V2 Circle Color", color = ParryV2.CircleColor,
    callback = function(c) ParryV2.CircleColor = c end,
})
MainTab:CreateDropdown({
    name = "Parry V2 Ignored Skills",
    options = {"Hidden S1", "Abyssal S1"},
    currentOption = {},
    multiple = true,
    callback = function(opt)
        local parsed = {}
        if type(opt) == "table" then
            for _, v in ipairs(opt) do parsed[v] = true end
        elseif type(opt) == "string" then
            parsed[opt] = true
        end
        ParryV2.IgnoredSkills = parsed
    end,
})

--========================================================--
-- 6c. STUN INDICATOR
--========================================================--
W.StunIndicator = W.StunIndicator or {
    Enabled = false, Cache = {}, HeartbeatConn = nil, Range = 500,
    Icon = "rbxassetid://81633822407558",
    SoundEnabled = true, SoundId = "18843924331",
    SoundVolume = 1.5, SoundRange = 500,
}

local function SInd_IsStunned(char)
    if not char then return false end
    if char:GetAttribute("IsStunned") == true then return true end
    if char:GetAttribute("isStunned") == true then return true end
    if char:GetAttribute("Stunned") == true then return true end
    if char:GetAttribute("stunned") == true then return true end
    if char:GetAttribute("IsStun") == true then return true end
    if char:GetAttribute("Stun") == true then return true end
    local ci = char:FindFirstChild("CheckInterractable")
    if ci then
        if ci:GetAttribute("isStunned") == true then return true end
        if ci:GetAttribute("Stunned") == true then return true end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local stunValue = hum:FindFirstChild("StunValue")
        if stunValue and stunValue.Value > 0 then return true end
    end
    return false
end

local function SInd_Remove(char)
    local gui = W.StunIndicator.Cache[char]
    if gui then pcall(function() gui:Destroy() end); W.StunIndicator.Cache[char] = nil end
end

local function SInd_PlaySound(char)
    if not W.StunIndicator.SoundEnabled then return end
    pcall(function()
        local head = char and char:FindFirstChild("Head")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local attachTo = head or hrp
        if not attachTo then return end
        local sound = Instance.new("Sound")
        sound.Name = "ALFzxzzzStunSound"
        sound.SoundId = "rbxassetid://" .. tostring(W.StunIndicator.SoundId)
        sound.Volume = W.StunIndicator.SoundVolume or 1.5
        sound.PlaybackSpeed = 1
        sound.RollOffMaxDistance = W.StunIndicator.SoundRange or 500
        sound.RollOffMinDistance = 10
        sound.RollOffMode = Enum.RollOffMode.InverseTapered
        sound.Parent = attachTo
        sound:Play()
        sound.Ended:Connect(function() pcall(function() sound:Destroy() end) end)
        task.delay(5, function() pcall(function() if sound and sound.Parent then sound:Destroy() end end) end)
    end)
end

local function SInd_Create(char)
    if W.StunIndicator.Cache[char] then return W.StunIndicator.Cache[char] end
    local head = char:FindFirstChild("Head")
    if not head then return nil end
    local bbg = Instance.new("BillboardGui")
    bbg.Name = "ALFzxzzzStunIndicator"
    bbg.Size = UDim2.new(0, 90, 0, 32)
    bbg.StudsOffset = Vector3.new(0, 3, 0)
    bbg.AlwaysOnTop = true
    bbg.LightInfluence = 0
    bbg.Adornee = head
    bbg.Parent = char

    local container = Instance.new("Frame")
    container.Size = UDim2.fromScale(1, 1)
    container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    container.BackgroundTransparency = 0.15
    container.BorderSizePixel = 0
    container.Parent = bbg
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 220, 0)
    stroke.Thickness = 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = container

    local iconFrame = Instance.new("Frame")
    iconFrame.Size = UDim2.fromOffset(22, 22)
    iconFrame.Position = UDim2.new(0, 5, 0.5, -11)
    iconFrame.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = container
    Instance.new("UICorner", iconFrame).CornerRadius = UDim.new(1, 0)

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.fromScale(0.85, 0.85)
    img.Position = UDim2.fromScale(0.5, 0.5)
    img.AnchorPoint = Vector2.new(0.5, 0.5)
    img.BackgroundTransparency = 1
    img.Image = W.StunIndicator.Icon
    img.ScaleType = Enum.ScaleType.Fit
    img.Parent = iconFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -32, 0.55, 0)
    label.Position = UDim2.new(0, 30, 0, 3)
    label.BackgroundTransparency = 1
    label.Text = "STUNNED"
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(255, 220, 0)
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -32, 0.3, 0)
    sub.Position = UDim2.new(0, 30, 0.58, 0)
    sub.BackgroundTransparency = 1
    sub.Text = "Killer Stunned"
    sub.Font = Enum.Font.GothamBold
    sub.TextSize = 8
    sub.TextColor3 = Color3.fromRGB(255, 255, 255)
    sub.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    sub.TextStrokeTransparency = 0
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = container

    task.spawn(function()
        local pulseT = 0
        while bbg.Parent and W.StunIndicator.Enabled do
            pulseT = (pulseT + 0.05) % (math.pi * 2)
            local glow = 0.7 + math.sin(pulseT) * 0.3
            if stroke and stroke.Parent then
                stroke.Thickness = 1.2 + math.sin(pulseT) * 0.8
                stroke.Color = Color3.fromRGB(math.floor(200 + glow * 55), math.floor(150 + glow * 70), 0)
            end
            task.wait(0.03)
        end
    end)

    W.StunIndicator.Cache[char] = bbg
    return bbg
end

W.SInd_SetEnabled = function(v)
    W.StunIndicator.Enabled = v
    if v then
        if W.StunIndicator.HeartbeatConn then return end
        W.StunIndicator.HeartbeatConn = RunService.Heartbeat:Connect(function()
            if not W.StunIndicator.Enabled then return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Team and p.Team.Name == "Killer" and p.Character then
                    local char = p.Character
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local myRoot = getRoot()
                    if hrp and myRoot then
                        local dist = (hrp.Position - myRoot.Position).Magnitude
                        local stunned = SInd_IsStunned(char)
                        local wasStunned = W.StunIndicator.Cache[char] ~= nil
                        if stunned and dist <= W.StunIndicator.Range then
                            if not wasStunned then SInd_PlaySound(char) end
                            SInd_Create(char)
                        else
                            SInd_Remove(char)
                        end
                    end
                end
            end
        end)
    else
        if W.StunIndicator.HeartbeatConn then
            W.StunIndicator.HeartbeatConn:Disconnect()
            W.StunIndicator.HeartbeatConn = nil
        end
        for _, gui in pairs(W.StunIndicator.Cache) do pcall(function() gui:Destroy() end) end
        W.StunIndicator.Cache = {}
    end
end

MainTab:CreateSection({ name = "Stun Indicator" })
MainTab:CreateToggle({
    name = "Enable Stun Indicator", value = W.StunIndicator.Enabled,
    callback = function(v)
        W.SInd_SetEnabled(v)
        notify("Stun Indicator", v and "Enabled" or "Disabled", 2)
    end,
})
MainTab:CreateToggle({ name = "Stun Sound Alert", value = W.StunIndicator.SoundEnabled, callback = function(v) W.StunIndicator.SoundEnabled = v end })
MainTab:CreateSlider({ name = "Stun Detect Range", range = {50, 2000}, increment = 25, value = W.StunIndicator.Range, callback = function(v) W.StunIndicator.Range = v end })
MainTab:CreateSlider({ name = "Stun Sound Volume", range = {0, 5}, increment = 0.1, value = W.StunIndicator.SoundVolume, callback = function(v) W.StunIndicator.SoundVolume = v end })

--========================================================--
-- 6d. SILENT AIM TOF V1
--========================================================--
local ToFState = {
    Connection = nil, LaserBeam = nil, TargetGui = nil,
    InputBegan = nil, InputEnded = nil, TouchInput = nil,
    IsAiming = false,
    SavedUIPos = UDim2.new(0.5, -120, 0, 110),
    SCPCache = {}, SCPCacheTimer = 0,
}

local ToFKeyCodes = {
    None=nil, Q=Enum.KeyCode.Q, E=Enum.KeyCode.E, R=Enum.KeyCode.R, T=Enum.KeyCode.T,
    F=Enum.KeyCode.F, G=Enum.KeyCode.G, H=Enum.KeyCode.H, J=Enum.KeyCode.J, K=Enum.KeyCode.K,
    L=Enum.KeyCode.L, X=Enum.KeyCode.X, Z=Enum.KeyCode.Z,
}

local function ToF_IsDowned(c)
    if not c then return true end
    local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return true end
    local h = c:FindFirstChildOfClass("Humanoid"); if h and h.Health<=0 then return true end
    if c:GetAttribute("Knocked")==true then return true end
    if c:GetAttribute("IsHooked")==true then return true end
    if c:GetAttribute("IsCarried")==true then return true end
    if c:GetAttribute("Downed")==true then return true end
    if c:GetAttribute("IsDown")==true then return true end
    local s = c:GetAttribute("State")
    if s=="Downed" or s=="Dead" or s=="Hooked" then return true end
    return false
end

local function ToF_IsBlocked()
    if VD.TOF_BlockKnocked == false then return false end
    local c = LocalPlayer.Character
    if not c then return true end
    return ToF_IsDowned(c)
end

local function ToF_GetEvent()
    local r = ReplicatedStorage:FindFirstChild("Remotes")
    local i = r and r:FindFirstChild("Items")
    local t = i and i:FindFirstChild("Twist of Fate")
    local f = t and t:FindFirstChild("Fire")
    if f and f:IsA("RemoteEvent") then return f end
    return nil
end

local function ToF_GetGun()
    local c = LocalPlayer.Character
    if not c then return nil end
    local b = c:FindFirstChild("Twist of Fate", true)
    if not b then return nil end
    local ra = b:FindFirstChild("Right Arm")
    if ra then
        local g = ra:FindFirstChild("gun"); if g then return g end
        local e = ra:FindFirstChild("EmperorGun"); if e then return e end
    end
    return b
end

local function ToF_IsVisible(op, tp, tc)
    local d = tp - op; local dist = d.Magnitude
    if dist < 0.1 then return true end
    local rp = RaycastParams.new(); rp.FilterType = Enum.RaycastFilterType.Exclude
    local ex = {}
    local lc = LocalPlayer.Character
    if lc then table.insert(ex, lc) end
    if tc and tc ~= lc then table.insert(ex, tc) end
    if ToFState.LaserBeam then table.insert(ex, ToFState.LaserBeam) end
    rp.FilterDescendantsInstances = ex
    local res = workspace:Raycast(op, d.Unit * dist, rp)
    return res == nil
end

local function ToF_GetSCPs()
    if tick()-ToFState.SCPCacheTimer < 0.5 then return ToFState.SCPCache end
    local nt = {}
    local mf = workspace:FindFirstChild("Map")
    if mf then
        for _,c in pairs(mf:GetDescendants()) do
            if c:IsA("Model") then
                local a = c:GetAttributes()
                if c:GetAttribute("CorpseCreated0492") or next(a)~=nil then
                    local r = c:FindFirstChild("HumanoidRootPart"); if r then table.insert(nt, r) end
                end
            end
        end
    end
    ToFState.SCPCache = nt; ToFState.SCPCacheTimer = tick()
    return nt
end

local function ToF_GetTarget()
    local g = ToF_GetGun()
    local c = LocalPlayer.Character
    if not (g and c) then return nil,nil,nil,nil end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil,nil,nil,nil end
    local mp = hrp.Position
    local op
    if c:GetAttribute("IsCarried") then op = hrp.Position + (hrp.CFrame.LookVector*2)
    else
        pcall(function() op = g:IsA("BasePart") and g.Position or (g:FindFirstChildOfClass("BasePart") and g:FindFirstChildOfClass("BasePart").Position) end)
        op = op or Vector3.new(mp.X, mp.Y+1.5, mp.Z)
    end
    local function predict(t, tc)
        local tp = t.Position
        if VD.TOF_WallCheck and not ToF_IsVisible(op, tp, tc) then return nil,nil,nil,nil end
        local tv = Vector3.new(0,0,0)
        local rp = tc and (tc:FindFirstChild("HumanoidRootPart") or t)
        if rp then tv = rp.Velocity end
        local dr = tp - op; local d = dr.Magnitude
        if d < 0.1 then return nil,nil,nil,nil end
        if d < 5 then return dr.Unit, g, op, tp end
        local tt = d/400
        local pp = tp + (tv*tt)
        for _=1,2 do local nd = (pp-op).Magnitude; tt = nd/400; pp = tp + (tv*tt) end
        local fd = pp - op
        if fd.Magnitude < 0.1 then return nil,nil,nil,nil end
        return fd.Unit, g, op, pp
    end
    local mode = VD.TOF_TargetMode or "Killer"
    if mode=="Killer" then
        local bt, bc, bs = nil, nil, math.huge
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Team and p.Team.Name=="Killer" and p.Character then
                local t = p.Character:FindFirstChild("Torso") or p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("HumanoidRootPart")
                if t then local d = (mp-t.Position).Magnitude; if d < bs then bs=d; bt=t; bc=p.Character end end
            end
        end
        if not bt then return nil,nil,nil,nil end
        return predict(bt, bc)
    elseif mode=="Survivors" then
        local bt, bc, bd = nil, nil, -math.huge
        local cam = workspace.CurrentCamera
        local cl = cam.CFrame.LookVector
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Team and p.Team.Name=="Survivors" and p.Character then
                local t = p.Character:FindFirstChild("Torso") or p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("HumanoidRootPart")
                if t then
                    local dt = t.Position - cam.CFrame.Position
                    if dt.Magnitude>0.1 then local dot = cl:Dot(dt.Unit); if dot>0.5 and dot>bd then bd=dot; bt=t; bc=p.Character end end
                end
            end
        end
        if not bt then return nil,nil,nil,nil end
        return predict(bt, bc)
    elseif mode=="Zombie" then
        local bp, bd = nil, -math.huge
        local cam = workspace.CurrentCamera
        local cl = cam.CFrame.LookVector
        for _,r in ipairs(ToF_GetSCPs()) do
            if r and r.Parent then
                local dt = r.Position - cam.CFrame.Position
                if dt.Magnitude>0.1 then local dot = cl:Dot(dt.Unit); if dot>0.5 and dot>bd then bd=dot; bp=r end end
            end
        end
        if not bp then return nil,nil,nil,nil end
        return predict(bp, bp.Parent)
    end
    return nil,nil,nil,nil
end

local function ToF_UpdateLaser(op, tp)
    if not ToFState.LaserBeam then
        local l = Instance.new("Part"); l.Name="ToFLaser"; l.Anchored=true; l.CanCollide=false; l.CanTouch=false; l.CastShadow=false
        l.Material=Enum.Material.Neon; l.Color=Color3.fromRGB(255,0,0); l.Parent=workspace
        ToFState.LaserBeam = l
    end
    local d = (tp-op).Magnitude
    ToFState.LaserBeam.Size = Vector3.new(0.05,0.05,d)
    ToFState.LaserBeam.CFrame = CFrame.new((op+tp)/2, tp)
    ToFState.LaserBeam.Transparency = 0
end

function W.ToF_ClearLaser() if ToFState.LaserBeam then pcall(function() ToFState.LaserBeam:Destroy() end); ToFState.LaserBeam=nil end end

local function ToF_GetMobileBtn()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local sm = pg and pg:FindFirstChild("Survivor-mob")
    local ct = sm and sm:FindFirstChild("Controls")
    local gm = ct and ct:FindFirstChild("Gui-mob")
    if not gm then return nil end
    local dns = {"attack","Attack","shoot","Shoot","fire","Fire"}
    for _,n in ipairs(dns) do local b = gm:FindFirstChild(n,true); if b and b:IsA("GuiObject") then return b end end
    for _,o in ipairs(gm:GetDescendants()) do if o:IsA("GuiButton") and o.Visible then return o end end
    return gm:IsA("GuiObject") and gm or nil
end

local function ToF_IsTouchShoot(input)
    local sb = ToF_GetMobileBtn()
    if not (sb and sb.Visible) then return false end
    local p = input.Position; local ap = sb.AbsolutePosition; local az = sb.AbsoluteSize
    return p.X>=ap.X and p.X<=ap.X+az.X and p.Y>=ap.Y and p.Y<=ap.Y+az.Y
end

local function ToF_Shoot()
    if not VD.TOF_SilentAim then return end
    if ToF_IsBlocked() then return end
    local td, g, op, tp = ToF_GetTarget()
    if not (td and g and tp and op) then return end
    local e = ToF_GetEvent()
    if not e then return end
    local fd = tp - op
    if fd.Magnitude < 0.1 then return end
    pcall(function() e:FireServer(g, fd.Unit) end)
end

local ToF_ModeButtons = {}
local function ToF_RefreshButtons()
    local m = { Killer={Color3.fromRGB(35,35,35),Color3.fromRGB(255,0,0)}, Survivors={Color3.fromRGB(35,35,35),Color3.fromRGB(0,255,255)}, Zombie={Color3.fromRGB(35,35,35),Color3.fromRGB(0,255,0)} }
    for n,b in pairs(ToF_ModeButtons) do
        if b and b.Parent then
            local a = n == (VD.TOF_TargetMode or "Killer")
            local c = m[n]
            b.BackgroundColor3 = a and c[1] or Color3.fromRGB(30,32,40)
            b.TextColor3 = a and c[2] or Color3.fromRGB(155,160,175)
        end
    end
end

function W.ToF_SetTargetMode(mode, notifyEnabled)
    if mode~="Killer" and mode~="Survivors" and mode~="Zombie" then return end
    VD.TOF_TargetMode = mode
    ToF_RefreshButtons()
    if notifyEnabled then notify("Target Mode", mode, 1) end
end
local ToF_SetTargetMode = W.ToF_SetTargetMode

local function ToF_CreateUI()
    local parent = GetSafeGuiParent()
    if not parent then return end
    if ToFState.TargetGui and ToFState.TargetGui.Parent then return end
    local old = parent:FindFirstChild("ToFTargetSelector"); if old then pcall(function() old:Destroy() end) end
    local gui = Instance.new("ScreenGui"); gui.Name = "ToFTargetSelector"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true; gui.Parent=parent
    local frame = Instance.new("Frame"); frame.Size = UDim2.new(0,180,0,126); frame.Position = ToFState.SavedUIPos
    frame.BackgroundColor3 = Color3.fromRGB(15,15,15); frame.BorderSizePixel=0; frame.Active=true; frame.Parent=gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)
    local st = Instance.new("UIStroke", frame); st.Color=Color3.fromRGB(255,0,0); st.Thickness=1
    local header = Instance.new("Frame"); header.Size=UDim2.new(1,0,0,28); header.BackgroundColor3=Color3.fromRGB(24,26,34); header.BorderSizePixel=0; header.Parent=frame
    Instance.new("UICorner", header).CornerRadius = UDim.new(0,4)
    local drag = Instance.new("Frame"); drag.Size=UDim2.new(1,-34,1,0); drag.BackgroundTransparency=1; drag.Parent=header
    local min = Instance.new("TextButton"); min.Size=UDim2.new(0,28,1,0); min.Position=UDim2.new(1,-30,0,0); min.BackgroundTransparency=1; min.Text="-"; min.TextColor3=Color3.fromRGB(255,0,0); min.Font=Enum.Font.GothamBold; min.TextSize=14; min.Parent=header
    local hlbl = Instance.new("TextLabel"); hlbl.Size=UDim2.new(1,-44,1,0); hlbl.Position=UDim2.new(0,10,0,0); hlbl.BackgroundTransparency=1; hlbl.Text="TOF TARGET MODE"; hlbl.TextColor3=Color3.fromRGB(255,0,0); hlbl.Font=Enum.Font.GothamBold; hlbl.TextSize=10; hlbl.TextXAlignment=Enum.TextXAlignment.Left; hlbl.Parent=header
    local bc = Instance.new("Frame"); bc.Size=UDim2.new(1,-16,0,86); bc.Position=UDim2.new(0,8,0,34); bc.BackgroundTransparency=1; bc.Parent=frame
    local lay = Instance.new("UIListLayout", bc); lay.FillDirection=Enum.FillDirection.Vertical; lay.SortOrder=Enum.SortOrder.LayoutOrder; lay.Padding=UDim.new(0,5)
    local isMin = false
    min.MouseButton1Click:Connect(function() isMin = not isMin; min.Text = isMin and "+" or "-"; bc.Visible = not isMin; frame.Size = isMin and UDim2.new(0,180,0,28) or UDim2.new(0,180,0,126) end)
    local modes = { {Internal="Killer",Display="KILLER        K"}, {Internal="Survivors",Display="SURVIVOR      J"}, {Internal="Zombie",Display="ZOMBIE        L"} }
    ToF_ModeButtons = {}
    for i,m in ipairs(modes) do
        local b = Instance.new("TextButton"); b.Size = UDim2.new(1,0,0,25); b.BorderSizePixel=0; b.Font=Enum.Font.GothamBold; b.TextSize=11; b.Text=m.Display; b.TextXAlignment=Enum.TextXAlignment.Center; b.LayoutOrder=i; b.Parent=bc
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,4)
        local bs = Instance.new("UIStroke", b); bs.Color=Color3.fromRGB(25,25,25); bs.Thickness=1
        b.MouseButton1Click:Connect(function() ToF_SetTargetMode(m.Internal, false) end)
        b.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.Touch then ToF_SetTargetMode(m.Internal, false) end end)
        ToF_ModeButtons[m.Internal] = b
    end
    ToF_RefreshButtons()
    local drg = false; local ds, sp
    drag.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then ds=inp.Position; sp=frame.Position; drg=true end end)
    drag.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then drg=false end end)
    UserInputService.InputChanged:Connect(function(inp)
        if not drg then return end
        if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then
            local d = inp.Position - ds
            local np = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
            frame.Position = np; ToFState.SavedUIPos = np
        end
    end)
    ToFState.TargetGui = gui
end

local function ToF_DestroyUI()
    if ToFState.TargetGui then pcall(function() ToFState.TargetGui:Destroy() end); ToFState.TargetGui=nil end
    ToF_ModeButtons = {}
end

local function ToF_StartConn()
    if ToFState.Connection then return end
    ToFState.Connection = RunService.Heartbeat:Connect(function()
        if ToF_IsBlocked() then ToFState.IsAiming=false; if ToFState.TouchInput then ToFState.TouchInput=nil end; if ToFState.LaserBeam then ToFState.LaserBeam.Transparency=1 end; return end
        if not VD.TOF_SilentAim or not ToFState.IsAiming then if ToFState.LaserBeam then ToFState.LaserBeam.Transparency=1 end; return end
        local _,_,op,tp = ToF_GetTarget()
        if op and tp then
            pcall(function()
                local c = LocalPlayer.Character
                local hrp = c and c:FindFirstChild("HumanoidRootPart")
                if hrp and not c:GetAttribute("IsCarried") then hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(tp.X, hrp.Position.Y, tp.Z)) end
            end)
            if VD.TOF_Laser then ToF_UpdateLaser(op, tp)
            elseif ToFState.LaserBeam then ToFState.LaserBeam.Transparency=1 end
        elseif ToFState.LaserBeam then ToFState.LaserBeam.Transparency=1 end
    end)
end

local function ToF_StopConn()
    if ToFState.Connection then pcall(function() ToFState.Connection:Disconnect() end); ToFState.Connection=nil end
    ToFState.IsAiming=false
    W.ToF_ClearLaser()
end

local SetToFSilentAim
local function ToF_EnsureInputs()
    if not ToFState.InputBegan then
        ToFState.InputBegan = UserInputService.InputBegan:Connect(function(inp, gp)
            if gp then return end
            local k = ToFKeyCodes[VD.TOF_Key or "None"]
            if k and inp.UserInputType==Enum.UserInputType.Keyboard and inp.KeyCode==k then SetToFSilentAim(not VD.TOF_SilentAim); return end
            if not VD.TOF_SilentAim then return end
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or (inp.UserInputType==Enum.UserInputType.Touch and ToF_IsTouchShoot(inp)) then
                if ToF_IsBlocked() then ToFState.IsAiming=false; return end
                ToFState.IsAiming = true
                if inp.UserInputType==Enum.UserInputType.Touch then ToFState.TouchInput = inp end
                return
            end
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                if inp.KeyCode==Enum.KeyCode.K then ToF_SetTargetMode("Killer", true)
                elseif inp.KeyCode==Enum.KeyCode.J then ToF_SetTargetMode("Survivors", true)
                elseif inp.KeyCode==Enum.KeyCode.L then ToF_SetTargetMode("Zombie", true) end
            end
        end)
    end
    if not ToFState.InputEnded then
        ToFState.InputEnded = UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or (inp.UserInputType==Enum.UserInputType.Touch and inp==ToFState.TouchInput) then
                local wa = ToFState.IsAiming
                ToFState.IsAiming = false
                if inp==ToFState.TouchInput then ToFState.TouchInput=nil end
                if ToFState.LaserBeam then ToFState.LaserBeam.Transparency=1 end
                if wa then if ToF_IsBlocked() then return end; ToF_Shoot() end
            end
        end)
    end
end

SetToFSilentAim = function(en)
    VD.TOF_SilentAim = en and true or false
    ToF_EnsureInputs()
    if VD.TOF_SilentAim then ToF_CreateUI(); ToF_StartConn() else ToF_DestroyUI(); ToF_StopConn() end
end
W.SetToFSilentAim = SetToFSilentAim
ToF_EnsureInputs()

MainTab:CreateSection({ name = "Silent Aim TOF V1 (Twist of Fate)" })
MainTab:CreateToggle({
    name = "Enable Silent Aim TOF", value = VD.TOF_SilentAim,
    callback = function(v)
        SetToFSilentAim(v)
        notify("Silent Aim TOF", v and "Enabled" or "Disabled", 2)
    end,
})
MainTab:CreateToggle({ name = "TOF Show Laser", value = VD.TOF_Laser, callback = function(v) VD.TOF_Laser = v; if not v then W.ToF_ClearLaser() end end })
MainTab:CreateToggle({ name = "TOF Wall Check", value = VD.TOF_WallCheck, callback = function(v) VD.TOF_WallCheck = v end })
MainTab:CreateToggle({ name = "TOF Block When Knocked", value = VD.TOF_BlockKnocked, callback = function(v) VD.TOF_BlockKnocked = v end })
MainTab:CreateDropdown({
    name = "TOF Target Mode",
    options = {"Killer", "Survivors", "Zombie"},
    currentOption = VD.TOF_TargetMode or "Killer",
    callback = function(opt)
        local val = type(opt) == "table" and opt[1] or opt
        W.ToF_SetTargetMode(val, false)
    end,
})
MainTab:CreateDropdown({
    name = "TOF Toggle Key",
    options = {"None", "Q", "E", "R", "T", "F", "G", "H", "J", "K", "L", "X", "Z"},
    currentOption = VD.TOF_Key or "None",
    callback = function(opt)
        local val = type(opt) == "table" and opt[1] or opt
        VD.TOF_Key = val
    end,
})

--========================================================--
-- 6e. SILENT AIM TOF V2 (PISTOL + FLASH)
--========================================================--
local AimConfig = {
    Aim_Silent = false,
    Pistol_BlockKnocked = false,
    Flash_Silent = false,
    Flash_YOffset = 8,
    LockAim = false,
    Pistol_Target = "Killer",
    Pistol_FOVMode = false,
    Pistol_ShowFOV = false,
    Pistol_FOV = 150,
    AIM_TargetPart = "Torso",
    HideSilentLaser = false,
}

local isChargingPistol = false
local lockedPistolTarget = nil
local currentTouchPistolInput = nil
local pistolLaser = nil
local isAimingFlash = false

local function ToF2_IsDowned(char)
    if not char then return false end
    return char:GetAttribute("Knocked") == true
        or char:GetAttribute("IsHooked") == true
        or char:GetAttribute("IsCarried") == true
end

local function ToF2_IsKiller(p)
    return p and p.Team and p.Team.Name == "Killer"
end

local function getTargetPartObject(char)
    if AimConfig.AIM_TargetPart == "Head" then
        return char:FindFirstChild("Head")
    elseif AimConfig.AIM_TargetPart == "Root" or AimConfig.AIM_TargetPart == "HumanoidRootPart" then
        return char:FindFirstChild("HumanoidRootPart")
    else
        return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
    end
end

local function getPistolTarget()
    local closestDist = (AimConfig.Pistol_ShowFOV and AimConfig.Pistol_FOVMode) and AimConfig.Pistol_FOV or math.huge
    local bestTarget = nil
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    if AimConfig.Pistol_BlockKnocked and ToF2_IsDowned(myChar) then return nil end

    local cam = workspace.CurrentCamera
    local mouseLocation = UserInputService:GetMouseLocation()

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local isValidTarget = false
            if AimConfig.Pistol_Target == "Killer" and ToF2_IsKiller(p) then
                isValidTarget = true
            elseif AimConfig.Pistol_Target == "Survivor" and not ToF2_IsKiller(p) then
                isValidTarget = true
            end

            if isValidTarget then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 and not ToF2_IsDowned(p.Character) then
                    local targetPart = getTargetPartObject(p.Character)
                    if targetPart then
                        local screenPos, onScreen = cam:WorldToViewportPoint(targetPart.Position)
                        if onScreen or not AimConfig.Pistol_FOVMode then
                            local dist = AimConfig.Pistol_FOVMode
                                and (Vector2.new(screenPos.X, screenPos.Y) - mouseLocation).Magnitude
                                or (targetPart.Position - myHRP.Position).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                bestTarget = targetPart
                            end
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

local function getKillerTargetForFlash()
    local bestTarget = nil
    local closestDist = math.huge
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and ToF2_IsKiller(p) and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp and not ToF2_IsDowned(p.Character) then
                local dist = (hrp.Position - myHRP.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    bestTarget = hrp
                end
            end
        end
    end
    return bestTarget
end

local function executeSilentAimFire()
    local targetPart = getPistolTarget()
    local myChar = LocalPlayer.Character
    if AimConfig.Pistol_BlockKnocked and ToF2_IsDowned(myChar) then return end
    if targetPart and myChar then
        local myPart = myChar:FindFirstChild("HumanoidRootPart")
        if myPart then
            local twistOfFate = myChar:FindFirstChild("Twist of Fate")
            if twistOfFate then
                local weaponArg = twistOfFate
                local rightArm = twistOfFate:FindFirstChild("Right Arm")
                if rightArm then
                    if rightArm:FindFirstChild("EmperorGun") then
                        weaponArg = rightArm:FindFirstChild("EmperorGun")
                    elseif rightArm:FindFirstChild("gun") then
                        weaponArg = rightArm:FindFirstChild("gun")
                    else
                        weaponArg = rightArm
                    end
                end
                local startPos = myPart.Position
                local targetPos = targetPart.Position
                local targetVel = targetPart.AssemblyLinearVelocity
                targetVel = Vector3.new(targetVel.X, 0, targetVel.Z)
                local distance = (targetPos - startPos).Magnitude
                local bulletSpeed = 400
                local timeToHit = distance / bulletSpeed
                local predictedPos = targetPos + (targetVel * timeToHit)
                local offset = Vector3.new(0, -2, 0)
                local aimDirection = ((predictedPos + offset) - startPos).Unit
                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                if remotes and remotes:FindFirstChild("Items") and remotes.Items:FindFirstChild("Twist of Fate") and remotes.Items["Twist of Fate"]:FindFirstChild("Fire") then
                    remotes.Items["Twist of Fate"].Fire:FireServer(weaponArg, aimDirection)
                end
            end
        end
    end
end

local function CreatePistolLaser()
    if pistolLaser then return end
    pistolLaser = Instance.new("Part")
    pistolLaser.Name = "VD_PistolLaser"
    pistolLaser.Material = Enum.Material.Neon
    pistolLaser.Color = Color3.fromRGB(255, 0, 0)
    pistolLaser.CanCollide = false
    pistolLaser.Anchored = true
    pistolLaser.CastShadow = false
    pistolLaser.Size = Vector3.new(0.05, 0.05, 1)
    pistolLaser.Transparency = 0
end
CreatePistolLaser()

local PistolFOVCircle
pcall(function()
    PistolFOVCircle = Drawing.new("Circle")
    PistolFOVCircle.Color = Color3.fromRGB(255, 255, 255)
    PistolFOVCircle.Thickness = 1.5
    PistolFOVCircle.Filled = false
    PistolFOVCircle.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    local isTouch = (input.UserInputType == Enum.UserInputType.Touch)
    if gameProcessed and not isTouch then return end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if AimConfig.Aim_Silent then
            isChargingPistol = true
            lockedPistolTarget = getPistolTarget()
        end
        if AimConfig.Flash_Silent then
            isAimingFlash = true
        end
    end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if AimConfig.Aim_Silent and isChargingPistol then
            executeSilentAimFire()
        end
    end

    if isTouch then
        if AimConfig.Aim_Silent or AimConfig.Flash_Silent then
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                local survivorMob = playerGui:FindFirstChild("Survivor-mob")
                if survivorMob then
                    local controls = survivorMob:FindFirstChild("Controls")
                    if controls then
                        local targetBtn = controls:FindFirstChild("Gui-mob")
                        if targetBtn and targetBtn.Visible then
                            local pos = input.Position
                            local absPos = targetBtn.AbsolutePosition
                            local absSize = targetBtn.AbsoluteSize
                            if pos.X >= absPos.X and pos.X <= (absPos.X + absSize.X) and pos.Y >= absPos.Y and pos.Y <= (absPos.Y + absSize.Y) then
                                if AimConfig.Aim_Silent then
                                    isChargingPistol = true
                                    currentTouchPistolInput = input
                                    lockedPistolTarget = getPistolTarget()
                                end
                                if AimConfig.Flash_Silent then
                                    isAimingFlash = true
                                    currentTouchPistolInput = input
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    local isTouchEnd = (input.UserInputType == Enum.UserInputType.Touch)

    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if isChargingPistol then
            isChargingPistol = false
            lockedPistolTarget = nil
        end
        if isAimingFlash then
            isAimingFlash = false
        end
    end

    if isTouchEnd and input == currentTouchPistolInput then
        if isChargingPistol then
            isChargingPistol = false
            currentTouchPistolInput = nil
            executeSilentAimFire()
            lockedPistolTarget = nil
        end
        if isAimingFlash then
            isAimingFlash = false
            currentTouchPistolInput = nil
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.K then
        AimConfig.Pistol_Target = "Killer"
        notify("TOF V2", "Target: Killer", 1)
    elseif input.KeyCode == Enum.KeyCode.J then
        AimConfig.Pistol_Target = "Survivor"
        notify("TOF V2", "Target: Survivor", 1)
    elseif input.KeyCode == Enum.KeyCode.L then
        AimConfig.Pistol_Target = "SCP"
        notify("TOF V2", "Target: SCP", 1)
    end
end)

RunService.RenderStepped:Connect(function()
    if isAimingFlash and AimConfig.Flash_Silent then
        local targetPart = getKillerTargetForFlash()
        if targetPart then
            local myChar = LocalPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local targetPos = targetPart.Position + Vector3.new(0, AimConfig.Flash_YOffset, 0)
            local cam = Camera
            cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, targetPos), 0.5)
            if myHRP then
                local goalHrp = CFrame.lookAt(myHRP.Position, Vector3.new(targetPos.X, myHRP.Position.Y, targetPos.Z))
                myHRP.CFrame = myHRP.CFrame:Lerp(goalHrp, 0.5)
            end
        end
    end

    if isChargingPistol then
        if lockedPistolTarget and AimConfig.LockAim and lockedPistolTarget.Parent and lockedPistolTarget.Parent:FindFirstChild("Humanoid") and lockedPistolTarget.Parent.Humanoid.Health > 0 then
            local cam = Camera
            local targetCFrame = CFrame.lookAt(cam.CFrame.Position, lockedPistolTarget.Position)
            cam.CFrame = cam.CFrame:Lerp(targetCFrame, 0.15)
        else
            lockedPistolTarget = getPistolTarget()
        end
    end

    if isChargingPistol and AimConfig.Aim_Silent then
        local targetPart = getPistolTarget()
        if targetPart then
            CreatePistolLaser()
            local myChar = LocalPlayer.Character
            local leftArm = myChar and (myChar:FindFirstChild("Left Arm") or myChar:FindFirstChild("LeftHand"))
            local startPos = leftArm and leftArm.Position or (myChar and myChar:GetPivot().Position or Vector3.new())
            local targetPos = targetPart.Position
            local targetVel = targetPart.AssemblyLinearVelocity
            targetVel = Vector3.new(targetVel.X, 0, targetVel.Z)
            local distance = (targetPos - startPos).Magnitude
            local bulletSpeed = 400
            local timeToHit = distance / bulletSpeed
            local predictedPos = targetPos + (targetVel * timeToHit)
            local offset = Vector3.new(0, -1.2, 0)
            local endPos = predictedPos + offset
            if pistolLaser then
                pistolLaser.Parent = workspace
                pistolLaser.Transparency = AimConfig.HideSilentLaser and 1 or 0
                local newDist = (endPos - startPos).Magnitude
                if newDist > 0 then
                    pistolLaser.Size = Vector3.new(0.05, 0.05, newDist)
                    pistolLaser.CFrame = CFrame.new(startPos, endPos) * CFrame.new(0, 0, -newDist / 2)
                end
            end
        else
            if pistolLaser and pistolLaser.Parent then
                pistolLaser.Parent = nil
            end
        end
    else
        if pistolLaser and pistolLaser.Parent then
            pistolLaser.Parent = nil
        end
    end

    if PistolFOVCircle then
        if AimConfig.Aim_Silent and AimConfig.Pistol_ShowFOV and AimConfig.Pistol_FOVMode then
            PistolFOVCircle.Visible = true
            PistolFOVCircle.Radius = AimConfig.Pistol_FOV
            PistolFOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local target = getPistolTarget()
            PistolFOVCircle.Color = target and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 100)
        else
            PistolFOVCircle.Visible = false
        end
    end
end)

MainTab:CreateSection({ name = "Silent Aim TOF V2 (Pistol + Flash)" })
MainTab:CreateToggle({
    name = "V2 Enable Silent Aim Pistol",
    value = AimConfig.Aim_Silent,
    callback = function(v)
        AimConfig.Aim_Silent = v
        notify("TOF V2", "Silent Aim Pistol " .. (v and "Enabled" or "Disabled"), 2)
    end,
})
MainTab:CreateToggle({ name = "V2 Lock Aim", value = AimConfig.LockAim, callback = function(v) AimConfig.LockAim = v end })
MainTab:CreateToggle({ name = "V2 Pistol FOV Mode", value = AimConfig.Pistol_FOVMode, callback = function(v) AimConfig.Pistol_FOVMode = v end })
MainTab:CreateToggle({ name = "V2 Pistol Show FOV", value = AimConfig.Pistol_ShowFOV, callback = function(v) AimConfig.Pistol_ShowFOV = v end })
MainTab:CreateToggle({ name = "V2 Pistol Block When Knocked", value = AimConfig.Pistol_BlockKnocked, callback = function(v) AimConfig.Pistol_BlockKnocked = v end })
MainTab:CreateToggle({ name = "V2 Hide Silent Laser", value = AimConfig.HideSilentLaser, callback = function(v) AimConfig.HideSilentLaser = v end })
MainTab:CreateSlider({ name = "V2 Pistol FOV Size", range = {50, 500}, increment = 10, value = AimConfig.Pistol_FOV, callback = function(v) AimConfig.Pistol_FOV = v end })
MainTab:CreateDropdown({
    name = "V2 Pistol Target",
    options = {"Killer", "Survivor", "SCP"},
    currentOption = AimConfig.Pistol_Target,
    callback = function(opt)
        local val = type(opt) == "table" and opt[1] or opt
        AimConfig.Pistol_Target = val
    end,
})
MainTab:CreateDropdown({
    name = "V2 Aim Target Part",
    options = {"Torso", "Head", "Root"},
    currentOption = AimConfig.AIM_TargetPart,
    callback = function(opt)
        local val = type(opt) == "table" and opt[1] or opt
        AimConfig.AIM_TargetPart = val
    end,
})
MainTab:CreateToggle({
    name = "V2 Flash Silent Aim",
    value = AimConfig.Flash_Silent,
    callback = function(v)
        AimConfig.Flash_Silent = v
        notify("TOF V2", "Flash Silent Aim " .. (v and "Enabled" or "Disabled"), 2)
    end,
})
MainTab:CreateSlider({ name = "V2 Flash Y Offset", range = {0, 20}, increment = 1, value = AimConfig.Flash_YOffset, callback = function(v) AimConfig.Flash_YOffset = v end })

--========================================================--
-- 7. TAB 2 : VISUALS
--========================================================--
local VisualsTab = Window:CreateTab({ name = "Visuals", icon = 16149070644 })

W.ESP = W.ESP or { Survivor=false, Killer=false, Generator=false, Pallet=false, Window=false, SCP=false, Distance=100 }
W.ESPStatus = W.ESPStatus or { Enabled=false, ShowAvatarIcon=false, ShowName=true, ShowDistance=true, ShowHealth=false, ShowItem=true, Radius=100 }
W.ESPItems = W.ESPItems or {
    ["Twist of Fate"]=true, ["Bandage"]=true, ["Motion Tracker"]=true,
    ["Gate"]=true, ["Shadow Clone"]=true, ["Parrying Dagger"]=true,
}
W.TeamColors = W.TeamColors or { Killer=Color3.fromRGB(255,0,0), Survivor=Color3.fromRGB(255,255,255) }
W.GeneratorColor = W.GeneratorColor or Color3.fromRGB(255,230,0)
W.PalletColor = W.PalletColor or Color3.fromRGB(74,255,181)
W.WindowColor = W.WindowColor or Color3.fromRGB(74,255,181)
W.SCPColor = W.SCPColor or Color3.fromRGB(255,0,0)
W.ESPCache = W.ESPCache or {
    Objects={}, Status={}, SCP={}, Generators={}, Windows={}, Pallets={},
    ExitPos=nil, ExitPart=nil,
}

local ESP = W.ESP
local ESPStatus = W.ESPStatus
local ESPItems = W.ESPItems
local TeamColors = W.TeamColors
local ESPCache = W.ESPCache

for _, o in ipairs(Workspace:GetDescendants()) do
    if string.find(string.lower(o.Name), "scp") then ESPCache.SCP[o] = true end
    if o.Name == "Generator" then ESPCache.Generators[o] = true
    elseif o.Name == "Window" then ESPCache.Windows[o] = true
    elseif o.Name == "Pallet" or o.Name == "Palletwrong" then ESPCache.Pallets[o] = true end
end

Workspace.DescendantAdded:Connect(function(o)
    local n = string.lower(o.Name)
    if string.find(n, "scp") then ESPCache.SCP[o] = true end
    if o.Name == "Generator" then ESPCache.Generators[o] = true
    elseif o.Name == "Window" then ESPCache.Windows[o] = true
    elseif o.Name == "Pallet" or o.Name == "Palletwrong" then ESPCache.Pallets[o] = true end
end)

Workspace.DescendantRemoving:Connect(function(o)
    ESPCache.SCP[o] = nil; ESPCache.Generators[o] = nil
    ESPCache.Windows[o] = nil; ESPCache.Pallets[o] = nil
    if ESPCache.Objects[o] then ESPCache.Objects[o]:Destroy(); ESPCache.Objects[o] = nil end
end)

local function rmESP(o)
    if ESPCache.Objects[o] then ESPCache.Objects[o]:Destroy(); ESPCache.Objects[o] = nil end
end

local function crESP(o, col)
    if not o then return end
    if ESPCache.Objects[o] then
        ESPCache.Objects[o].FillColor = col
        ESPCache.Objects[o].OutlineColor = col
        return
    end
    local h = Instance.new("Highlight")
    h.FillColor = col
    h.OutlineColor = col
    h.FillTransparency = 0.9
    h.OutlineTransparency = 0.3
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = o
    ESPCache.Objects[o] = h
    o.AncestryChanged:Connect(function(_, p) if not p then rmESP(o) end end)
end

local function rmSESP(c)
    if ESPCache.Status[c] then ESPCache.Status[c]:Destroy(); ESPCache.Status[c] = nil end
end

local function GetItem(c)
    if not c then return nil end
    for _, o in ipairs(c:GetChildren()) do
        if ESPItems[o.Name] then return o.Name end
        if o:IsA("Tool") and ESPItems[o.Name] then return o.Name end
    end
    return nil
end

local function GV(o, n)
    if not o then return nil end
    local a = o:GetAttribute(n); if a ~= nil then return a end
    local ch = o:FindFirstChild(n)
    if ch then local ok, v = pcall(function() return ch.Value end); if ok then return v end end
    return nil
end

local function AGH(o, col)
    local h = o:FindFirstChild("GenHighlight") or Instance.new("Highlight")
    h.Name = "GenHighlight"
    h.Adornee = o
    h.FillColor = col
    h.OutlineColor = col
    h.FillTransparency = 0.9
    h.OutlineTransparency = 0.3
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = o
end

local function CB(text, col)
    local b = Instance.new("BillboardGui")
    b.Name = "GenESP"
    b.Size = UDim2.new(0, 100, 0, 30)
    b.AlwaysOnTop = true
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = col
    l.TextStrokeTransparency = 0
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.Parent = b
    return b
end

local function UGen(g)
    if not g or not g.Parent then return end
    if not ESP.Generator then
        local o = g:FindFirstChild("GenESP"); if o then o:Destroy() end
        local h = g:FindFirstChild("GenHighlight"); if h then h:Destroy() end
        return
    end
    local p = GV(g, "RepairProgress") or GV(g, "Progress") or 0
    local b = g:FindFirstChild("GenESP")
    if p >= 100 then if b then b:Destroy() end; return end
    local cp = math.clamp(p, 0, 100)
    local col = W.GeneratorColor:Lerp(Color3.fromRGB(0, 255, 120), cp/100)
    local tx = string.format("[%.0f%%]", p)
    if not b then
        b = CB(tx, col); b.Adornee = g; b.Parent = g
    else
        local lb = b:FindFirstChildOfClass("TextLabel")
        if lb then lb.Text = tx; lb.TextColor3 = col end
    end
    AGH(g, col)
end

local function UMESP(o, r)
    if not o or not r then return end
    local ps
    if o:IsA("Model") then ps = o:GetPivot().Position
    elseif o:IsA("BasePart") then ps = o.Position end
    if not ps then return end
    local d = (ps - r.Position).Magnitude
    if o.Name == "Window" then
        if ESP.Window and d <= ESP.Distance then crESP(o, W.WindowColor) else rmESP(o) end
    end
    if o.Name == "Pallet" or o.Name == "Palletwrong" then
        if ESP.Pallet and d <= ESP.Distance then crESP(o, W.PalletColor) else rmESP(o) end
    end
end

local function CSESP(p, c, r)
    if not ESPStatus.Enabled then rmSESP(c); return end
    if not r then return end
    local h = c:FindFirstChild("Head")
    local hu = c:FindFirstChildOfClass("Humanoid")
    if not h or not hu then return end
    local isD = hu.Health <= 0 or hu.Health < 2
             or c:GetAttribute("Downed") == true
             or c:GetAttribute("IsDown") == true
             or c:GetAttribute("Knocked") == true
    local d = (h.Position - r.Position).Magnitude
    if d > ESPStatus.Radius then rmSESP(c); return end
    local t = ""
    if isD then t = "[DOWN]\n" end
    if ESPStatus.ShowName then
        t = t .. p.Name
        if ESPStatus.ShowItem then
            local it = GetItem(c)
            if it then t = t .. " [" .. it .. "]" end
        end
        t = t .. "\n"
    end
    if ESPStatus.ShowDistance then t = t .. string.format("Dist: %.0f\n", d) end
    if ESPStatus.ShowHealth then t = t .. string.format("HP: %.0f\n", hu.Health) end
    if t == "" and not ESPStatus.ShowAvatarIcon then rmSESP(c); return end

    local tc = Color3.new(1, 1, 1)
    if p.Team then
        if p.Team.Name == "Killer" then tc = TeamColors.Killer
        elseif p.Team.Name == "Survivors" then tc = TeamColors.Survivor end
    end
    if isD then tc = Color3.fromRGB(255, 0, 0) end

    local b = ESPCache.Status[c]
    if not b then
        b = Instance.new("BillboardGui")
        b.Size = UDim2.new(0, 160, 0, 80)
        b.AlwaysOnTop = true
        b.Adornee = h
        b.StudsOffset = Vector3.new(0, 2.5, 0)
        b.Parent = c

        local avatarFrame = Instance.new("Frame")
        avatarFrame.Name = "AvatarFrame"
        avatarFrame.Size = UDim2.fromOffset(26, 26)
        avatarFrame.Position = UDim2.new(0.5, 0, 0, 0)
        avatarFrame.AnchorPoint = Vector2.new(0.5, 0)
        avatarFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        avatarFrame.BorderSizePixel = 0
        avatarFrame.Visible = false
        avatarFrame.Parent = b
        Instance.new("UICorner", avatarFrame).CornerRadius = UDim.new(1, 0)

        local avatarStroke = Instance.new("UIStroke")
        avatarStroke.Name = "AvatarStroke"
        avatarStroke.Thickness = 1.5
        avatarStroke.Color = tc
        avatarStroke.Transparency = 0
        avatarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        avatarStroke.Parent = avatarFrame

        local avatarImg = Instance.new("ImageLabel")
        avatarImg.Name = "AvatarImg"
        avatarImg.Size = UDim2.fromScale(1, 1)
        avatarImg.BackgroundTransparency = 1
        avatarImg.ScaleType = Enum.ScaleType.Crop
        avatarImg.Parent = avatarFrame
        Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(1, 0)

        local lb = Instance.new("TextLabel")
        lb.Name = "InfoLabel"
        lb.Size = UDim2.new(1, 0, 1, 0)
        lb.Position = UDim2.new(0, 0, 0, 0)
        lb.BackgroundTransparency = 1
        lb.TextColor3 = tc
        lb.TextStrokeTransparency = 0
        lb.Font = Enum.Font.GothamBold
        lb.TextSize = 12
        lb.Text = t
        lb.TextXAlignment = Enum.TextXAlignment.Center
        lb.TextYAlignment = Enum.TextYAlignment.Top
        lb.Parent = b

        ESPCache.Status[c] = b
    end

    local lb = b:FindFirstChild("InfoLabel")
    local avatarFrame = b:FindFirstChild("AvatarFrame")
    if ESPStatus.ShowAvatarIcon then
        if lb then lb.Text = t; lb.TextColor3 = tc; lb.Position = UDim2.new(0, 0, 0, 30) end
        if avatarFrame then
            avatarFrame.Visible = true
            local img = avatarFrame:FindFirstChild("AvatarImg")
            local stroke = avatarFrame:FindFirstChild("AvatarStroke")
            if stroke then stroke.Color = tc end
            if img and img:GetAttribute("LoadedUserId") ~= p.UserId then
                img:SetAttribute("LoadedUserId", p.UserId)
                img.Image = ""
                task.spawn(function()
                    local ok, thumb = pcall(function()
                        return Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                    end)
                    if ok and thumb and img and img.Parent then img.Image = thumb end
                end)
            end
        end
    else
        if lb then lb.Text = t; lb.TextColor3 = tc; lb.Position = UDim2.new(0, 0, 0, 0) end
        if avatarFrame then avatarFrame.Visible = false end
    end
end

local function USCP(r)
    if not ESP.SCP then
        for o in pairs(ESPCache.SCP) do rmESP(o) end
        return
    end
    for o in pairs(ESPCache.SCP) do
        if o and o.Parent then
            local ps
            if o:IsA("Model") then ps = o:GetPivot().Position
            elseif o:IsA("BasePart") then ps = o.Position end
            if ps then
                if (ps - r.Position).Magnitude <= ESP.Distance then crESP(o, W.SCPColor) else rmESP(o) end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    local r = getRoot()
    if not r then return end
    local now = tick()
    if now - W.Timers.lastESPUpdate < 0.05 then return end
    W.Timers.lastESPUpdate = now
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local c = p.Character
            local h = c:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then
                local hrp = c:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local d = (hrp.Position - r.Position).Magnitude
                    if d <= ESP.Distance then
                        if ESP.Survivor and p.Team and p.Team.Name == "Survivors" then
                            crESP(c, TeamColors.Survivor)
                        elseif ESP.Killer and p.Team and p.Team.Name == "Killer" then
                            crESP(c, TeamColors.Killer)
                        else
                            rmESP(c)
                        end
                    else rmESP(c) end
                end
                CSESP(p, c, r)
            else rmESP(c) end
        end
    end
    if ESP.Generator then
        for g in pairs(ESPCache.Generators) do UGen(g) end
    end
    for o in pairs(ESPCache.Windows) do UMESP(o, r) end
    for o in pairs(ESPCache.Pallets) do UMESP(o, r) end
    USCP(r)

    -- ===== VISUAL APPLY (throttled same as ESP) =====
    pcall(function() applyVisual() end)
    pcall(function() applyOptimization() end)
    pcall(function() applyNoScreenEffects() end)
end)

VisualsTab:CreateSection({ name = "ESP Cham" })
VisualsTab:CreateToggle({ name = "ESP Survivor", value = false, callback = function(v) W.ESP.Survivor = v end })
VisualsTab:CreateColorPicker({ name = "Survivor Color", color = W.TeamColors.Survivor, callback = function(c) W.TeamColors.Survivor = c end })
VisualsTab:CreateToggle({ name = "ESP Killer", value = false, callback = function(v) W.ESP.Killer = v end })
VisualsTab:CreateColorPicker({ name = "Killer Color", color = W.TeamColors.Killer, callback = function(c) W.TeamColors.Killer = c end })
VisualsTab:CreateToggle({ name = "ESP Generator", value = false, callback = function(v) W.ESP.Generator = v end })
VisualsTab:CreateColorPicker({ name = "Generator Color", color = W.GeneratorColor, callback = function(c) W.GeneratorColor = c end })
VisualsTab:CreateToggle({ name = "ESP SCP", value = false, callback = function(v) W.ESP.SCP = v end })
VisualsTab:CreateColorPicker({ name = "SCP Color", color = W.SCPColor, callback = function(c) W.SCPColor = c end })
VisualsTab:CreateToggle({ name = "ESP Pallet", value = false, callback = function(v) W.ESP.Pallet = v end })
VisualsTab:CreateColorPicker({ name = "Pallet Color", color = W.PalletColor, callback = function(c) W.PalletColor = c end })
VisualsTab:CreateToggle({ name = "ESP Window", value = false, callback = function(v) W.ESP.Window = v end })
VisualsTab:CreateColorPicker({ name = "Window Color", color = W.WindowColor, callback = function(c) W.WindowColor = c end })
VisualsTab:CreateSlider({ name = "ESP Radius", range = {10, 1000}, increment = 10, value = 100, callback = function(v) W.ESP.Distance = v end })

VisualsTab:CreateSection({ name = "ESP Status" })
VisualsTab:CreateToggle({ name = "Enable Status ESP", value = false, callback = function(v) W.ESPStatus.Enabled = v end })
VisualsTab:CreateToggle({ name = "Show Avatar Icon", value = false, callback = function(v) W.ESPStatus.ShowAvatarIcon = v end })
VisualsTab:CreateToggle({ name = "Show Name", value = true, callback = function(v) W.ESPStatus.ShowName = v end })
VisualsTab:CreateToggle({ name = "Show Item", value = true, callback = function(v) W.ESPStatus.ShowItem = v end })
VisualsTab:CreateToggle({ name = "Show Distance", value = true, callback = function(v) W.ESPStatus.ShowDistance = v end })
VisualsTab:CreateToggle({ name = "Show Health", value = false, callback = function(v) W.ESPStatus.ShowHealth = v end })
VisualsTab:CreateSlider({ name = "Status Radius", range = {20, 500}, increment = 10, value = 100, callback = function(v) W.ESPStatus.Radius = v end })

--========================================================--
-- 7b. VISUAL EFFECTS (NEW)
--========================================================--
VisualsTab:CreateSection({ name = "Visual Effects" })

VisualsTab:CreateToggle({
    name = "Fullbright",
    value = Visual.Fullbright,
    callback = function(v)
        Visual.Fullbright = v
        pcall(function() applyVisual(true) end)
        notify("Visual", "Fullbright " .. (v and "ON" or "OFF"), 2)
    end,
})

VisualsTab:CreateToggle({
    name = "No Shadow",
    value = Visual.NoShadow,
    callback = function(v)
        Visual.NoShadow = v
        pcall(function() applyVisual(true) end)
        notify("Visual", "No Shadow " .. (v and "ON" or "OFF"), 2)
    end,
})

VisualsTab:CreateToggle({
    name = "Low Graphics",
    value = Visual.LowGraphics,
    callback = function(v)
        Visual.LowGraphics = v
        pcall(function() applyOptimization(true) end)
        notify("Visual", "Low Graphics " .. (v and "ON" or "OFF"), 2)
    end,
})

VisualsTab:CreateToggle({
    name = "Clean Sky",
    value = Visual.CleanSky,
    callback = function(v)
        Visual.CleanSky = v
        pcall(function() applyOptimization(true) end)
        notify("Visual", "Clean Sky " .. (v and "ON" or "OFF"), 2)
    end,
})

--========================================================--
-- 7c. LOCK POV (Lock Field Of View)
--========================================================--
VisualsTab:CreateSection({ name = "Lock POV" })

VisualsTab:CreateToggle({
    name = "Lock POV (Lock FOV)",
    value = LockPOV.Enabled,
    callback = function(v)
        W.LockPOV_SetEnabled(v)
        notify("Lock POV", v and "Enabled (FOV locked)" or "Disabled", 2)
    end,
})

VisualsTab:CreateSlider({
    name = "Lock POV — FOV Value",
    range = {30, 120}, increment = 1, value = LockPOV.FOV,
    callback = function(v)
        LockPOV.FOV = v
        local cam = Workspace.CurrentCamera
        if cam and LockPOV.Enabled then
            pcall(function() cam.FieldOfView = v end)
        end
    end,
})

VisualsTab:CreateButton({
    name = "Reset FOV to Default (70)",
    callback = function()
        LockPOV.FOV = 70
        local cam = Workspace.CurrentCamera
        if cam and LockPOV.Enabled then
            pcall(function() cam.FieldOfView = 70 end)
        end
        notify("Lock POV", "FOV reset to 70", 2)
    end,
})

--========================================================--
-- 8. TAB 3 : SURVIVOR
--========================================================--
local SurvivorTab = Window:CreateTab({ name = "Survivor", icon = 11984980776 })

--========================================================--
-- 8a. GEN BYPASS
--========================================================--
W.GenBypass = W.GenBypass or {
    Enabled = false, Button = nil, UI = nil, Cache = {}, CacheTimer = 0,
    Processed = {}, HotkeyCode = Enum.KeyCode.G, TriggerRange = 8,
}
local GenBypass = W.GenBypass

function W.GB_GetAllGenerators()
    local now = tick()
    if now - GenBypass.CacheTimer < 5 then return GenBypass.Cache end
    GenBypass.Cache = {}
    GenBypass.CacheTimer = now
    local mf = Workspace:FindFirstChild("Map")
    if not mf then return GenBypass.Cache end
    pcall(function()
        for _, v in pairs(mf:GetDescendants()) do
            if not v:IsA("Model") then continue end
            if v.Name ~= "Generator" then continue end
            local real = v:GetAttribute("RepairProgress") ~= nil
                      or v:GetAttribute("kickcount") ~= nil
                      or v:GetAttribute("ProgressRepair") ~= nil
            if real then table.insert(GenBypass.Cache, v) end
        end
    end)
    return GenBypass.Cache
end

function W.GB_GetPoints(m)
    local pts = {}
    pcall(function()
        for _, o in pairs(m:GetChildren()) do
            if o.Name:find("GeneratorPoint") and o:IsA("BasePart") then table.insert(pts, o) end
        end
    end)
    return pts
end

function W.GB_WaitRepairing(pt, t)
    local s = tick()
    while tick() - s < (t or 1) do
        if pt:GetAttribute("IsRepairing") == true then return true end
        task.wait(0.05)
    end
    return false
end

function W.GB_DoRepair(tp)
    local gm = tp.Parent
    if GenBypass.Processed[gm] then return end
    GenBypass.Processed[gm] = true
    local c = LocalPlayer.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    if not hrp then GenBypass.Processed[gm] = nil; return end
    local re = ReplicatedStorage:FindFirstChild("Remotes")
        and ReplicatedStorage.Remotes:FindFirstChild("Generator")
        and ReplicatedStorage.Remotes.Generator:FindFirstChild("RepairEvent")
    local og = hrp.CFrame
    pcall(function()
        for _, p in pairs(W.GB_GetPoints(gm)) do
            if p ~= tp and p.Parent then
                hrp.Anchored = true
                hrp.CFrame = p.CFrame
                task.wait(0.15)
                pcall(function() if re then re:FireServer(p, true) end end)
                if not W.GB_WaitRepairing(p, 0.8) then
                    pcall(function() if re then re:FireServer(p, false) end end)
                    task.wait(0.1)
                    hrp.CFrame = p.CFrame
                    task.wait(0.15)
                    pcall(function() if re then re:FireServer(p, true) end end)
                    W.GB_WaitRepairing(p, 0.5)
                end
                hrp.Anchored = false
                task.wait(0.05)
            end
        end
    end)
    pcall(function()
        if hrp and hrp.Parent then hrp.Anchored = false; hrp.CFrame = og end
    end)
    task.wait(0.1)
    pcall(function() if re then re:FireServer(tp, false) end end)
end

function W.GB_GetNearestPoint()
    local c = LocalPlayer.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local best, bd = nil, math.huge
    for _, g in pairs(W.GB_GetAllGenerators()) do
        for _, p in pairs(W.GB_GetPoints(g)) do
            local d = (hrp.Position - p.Position).Magnitude
            if d < bd then bd = d; best = p end
        end
    end
    return best, bd
end

function W.GB_IsPromptVisible()
    local ok, fr = pcall(function() return LocalPlayer.PlayerGui.pcprompts.Frame.GeneratorRepair end)
    return ok and fr and fr.Visible
end

function W.GB_UpdateButton()
    if GenBypass.Button then GenBypass.Button.Visible = GenBypass.Enabled and isMobile end
end

function W.GB_CreateButton()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return end
    local old = pg:FindFirstChild("BypassGenUI")
    if old then old:Destroy() end
    GenBypass.UI = Instance.new("ScreenGui")
    GenBypass.UI.Name = "BypassGenUI"
    GenBypass.UI.ResetOnSpawn = false
    GenBypass.UI.IgnoreGuiInset = true
    GenBypass.UI.Parent = pg

    GenBypass.Button = Instance.new("ImageButton")
    GenBypass.Button.Name = "BypassGenButton"
    GenBypass.Button.Size = UDim2.new(0, 60, 0, 60)
    GenBypass.Button.Position = UDim2.new(0.88, 0, 0.55, 0)
    GenBypass.Button.AnchorPoint = Vector2.new(0.5, 0.5)
    GenBypass.Button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    GenBypass.Button.BackgroundTransparency = 0
    GenBypass.Button.AutoButtonColor = true
    GenBypass.Button.Visible = false
    GenBypass.Button.ZIndex = 10
    GenBypass.Button.Parent = GenBypass.UI

    local co = Instance.new("UICorner"); co.CornerRadius = UDim.new(0, 8); co.Parent = GenBypass.Button
    local st = Instance.new("UIStroke"); st.Color = Color3.fromRGB(0, 255, 0); st.Thickness = 2; st.Transparency = 0.2; st.Parent = GenBypass.Button
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, 0, 1, 0); lb.BackgroundTransparency = 1
    lb.Text = "GEN"; lb.TextColor3 = Color3.fromRGB(35, 35, 35); lb.TextScaled = true
    lb.Font = Enum.Font.GothamBlack; lb.ZIndex = 11; lb.Parent = GenBypass.Button

    GenBypass.Button.MouseButton1Click:Connect(function()
        if not GenBypass.Enabled then return end
        local bp, bd = W.GB_GetNearestPoint()
        if bp and bd <= GenBypass.TriggerRange then W.GB_DoRepair(bp) end
    end)
end
W.GB_CreateButton()

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    W.GB_CreateButton()
    W.GB_UpdateButton()
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp or isMobile then return end
    if input.KeyCode == GenBypass.HotkeyCode and GenBypass.Enabled then
        if not W.GB_IsPromptVisible() then return end
        local bp, bd = W.GB_GetNearestPoint()
        if not bp or bd > GenBypass.TriggerRange then return end
        if GenBypass.Processed[bp.Parent] then return end
        W.GB_DoRepair(bp)
    end
end)

task.spawn(function()
    while true do
        task.wait(2)
        local c = LocalPlayer.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if hrp then
            for gm in pairs(GenBypass.Processed) do
                if not gm or not gm.Parent then GenBypass.Processed[gm] = nil; continue end
                local near = false
                for _, p in pairs(W.GB_GetPoints(gm)) do
                    if p.Parent and (hrp.Position - p.Position).Magnitude <= 10 then near = true; break end
                end
                if not near then GenBypass.Processed[gm] = nil end
            end
        end
    end
end)

function W.setGenBypass(v)
    GenBypass.Enabled = v
    W.GB_UpdateButton()
end

--========================================================--
-- 8a2. BYPASS SELF UNHOOK
--========================================================--
function W.SU_IsHooked()
    local char = LocalPlayer.Character
    if not char then return false end
    return char:GetAttribute("IsHooked") == true
        or char:GetAttribute("isHooked") == true
        or char:GetAttribute("Hooked") == true
        or char:GetAttribute("HookedState") == true
end

function W.SU_GetRandomGeneratorPoint()
    local gens = W.GB_GetAllGenerators()
    if not gens or #gens == 0 then return nil end
    local valid = {}
    for _, g in ipairs(gens) do
        if g and g.Parent then
            for _, p in ipairs(W.GB_GetPoints(g)) do
                if p and p.Parent then table.insert(valid, p) end
            end
        end
    end
    if #valid == 0 then return nil end
    return valid[math.random(1, #valid)]
end

function W.SU_GetKillerHRP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team and p.Team.Name == "Killer" and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then return hrp end
        end
    end
    return nil
end

function W.SU_Abort()
    SU.Following = false
    if SU._activeThread then
        pcall(function() task.cancel(SU._activeThread) end)
        SU._activeThread = nil
    end
end

function W.SU_Trigger()
    if SU.Following then return end
    local now = tick()
    if now - SU._lastTrigger < SU._cooldown then return end
    if not W.SU_IsHooked() then return end
    SU._lastTrigger = now
    SU.Following = true
    SU.TriggerCount = SU.TriggerCount + 1
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            SU._hookPos = hrp.Position
            SU._hookCFrame = hrp.CFrame
        end
    end
    SU._activeThread = task.spawn(function()
        local c = LocalPlayer.Character
        if not c then SU.Following = false; SU._activeThread = nil; return end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hrp then SU.Following = false; SU._activeThread = nil; return end
        local repairEvent = ReplicatedStorage:FindFirstChild("Remotes")
            and ReplicatedStorage.Remotes:FindFirstChild("Generator")
            and ReplicatedStorage.Remotes.Generator:FindFirstChild("RepairEvent")
        if not W.SU_IsHooked() then SU.Following = false; SU._activeThread = nil; return end
        local targetPt = W.SU_GetRandomGeneratorPoint()
        if targetPt then
            pcall(function() hrp.Velocity = Vector3.zero; hrp.CFrame = targetPt.CFrame + Vector3.new(0, 3, 0) end)
            task.wait(0.15)
            if repairEvent then
                pcall(function() repairEvent:FireServer(targetPt, true) end); task.wait(0.35)
                pcall(function() repairEvent:FireServer(targetPt, false) end); task.wait(0.15)
                pcall(function() repairEvent:FireServer(targetPt, true) end); task.wait(0.35)
                pcall(function() repairEvent:FireServer(targetPt, false) end)
            end
        end
        local followUntil = tick() + (SU.FollowDuration or 30)
        local belowOffset = SU.FollowDistance or 20
        while tick() < followUntil and SU.Enabled do
            if not W.SU_IsHooked() then
                SU.Following = false
                SU._activeThread = nil
                notify("Bypass Self Unhook", "Udah lepas hook - STOP", 2)
                return
            end
            local cc = LocalPlayer.Character
            if not cc then break end
            local r = cc:FindFirstChild("HumanoidRootPart")
            if not r then break end
            local khrp = W.SU_GetKillerHRP()
            if khrp then
                pcall(function()
                    r.Velocity = Vector3.zero
                    local targetPos = Vector3.new(khrp.Position.X, khrp.Position.Y - belowOffset, khrp.Position.Z)
                    r.CFrame = CFrame.new(targetPos, targetPos + Vector3.new(0, 0, -1))
                end)
            end
            task.wait(0.03)
        end
        if W.SU_IsHooked() then
            local c2 = LocalPlayer.Character
            if c2 then
                local r2 = c2:FindFirstChild("HumanoidRootPart")
                if r2 then
                    if SU._hookCFrame then
                        pcall(function() r2.Velocity = Vector3.zero; r2.CFrame = SU._hookCFrame end)
                    elseif SU._hookPos then
                        pcall(function() r2.Velocity = Vector3.zero; r2.CFrame = CFrame.new(SU._hookPos + Vector3.new(0, 3, 0)) end)
                    end
                end
            end
        end
        SU.Following = false
        SU._activeThread = nil
    end)
end

function W.SU_Start()
    if SU.MonitorConn then return end
    SU._wasHooked = false
    SU.MonitorConn = RunService.Heartbeat:Connect(function()
        if not SU.Enabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local isHooked = W.SU_IsHooked()
        if not isHooked then SU._wasHooked = false; return end
        if not SU._wasHooked and not SU.Following then
            SU._wasHooked = true
            W.SU_Trigger()
        end
    end)
end

function W.SU_Stop()
    if SU.MonitorConn then SU.MonitorConn:Disconnect(); SU.MonitorConn = nil end
    W.SU_Abort()
    SU._wasHooked = false
end

function W.SU_SetEnabled(v)
    SU.Enabled = v
    if v then W.SU_Start() else W.SU_Stop() end
end

--========================================================--
-- 8a3. AUTO DROP PALLET
--========================================================--
local function HandleAutoPallet()
    if not Auto.PalletDrop then return end

    local plr = Players.LocalPlayer
    if not (plr.Team and plr.Team.Name == "Survivors") then return end

    local now = tick()
    if now - Timers.lastPalletScan < 0.2 then return end
    Timers.lastPalletScan = now

    if now - Timers.lastPalletDrop < 2.5 then return end

    local root = getRoot()
    if not root then return end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local killerRoot, killerDist = GetNearestKiller()
    if not killerRoot or killerDist > Auto.PalletDropDist then return end

    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local palletFold = remotes and remotes:FindFirstChild("Pallet")
    local dropEvent = palletFold and palletFold:FindFirstChild("PalletDropEvent")
    if not dropEvent then return end

    local bestPallet = nil
    local bestDist = 8

    local function findPalletPointSlide(model)
        local slide = model:FindFirstChild("PalletPointSlide")
        if slide then return slide end
        for _, child in ipairs(model:GetDescendants()) do
            if child.Name == "PalletPointSlide" then return child end
        end
        return model:FindFirstChild("PalletPoint")
    end

    for pal, _ in pairs(ESPCache.Pallets) do
        if not pal or State.UsedPallets[pal] then continue end

        local refPart = pal:FindFirstChild("PalletPoint") or pal:FindFirstChild("PalletPointSlide")
        if not refPart then continue end

        local ok, pos = pcall(function() return refPart.Position end)
        if not ok or not pos then continue end

        local d = (root.Position - pos).Magnitude
        if d < bestDist then
            bestDist = d
            bestPallet = pal
        end
    end

    if bestPallet then
        local fireTarget = findPalletPointSlide(bestPallet)
        if fireTarget then
            pcall(function() dropEvent:FireServer(fireTarget) end)
            State.UsedPallets[bestPallet] = true
            Timers.lastPalletDrop = now
        end
    end
end

RunService.Heartbeat:Connect(function()
    pcall(HandleAutoPallet)
end)

--========================================================--
-- 8a4. AUTO CROUCH (STANDALONE - TOGGLE ONLY)
--========================================================--
W.AutoCrouch = W.AutoCrouch or {
    Enabled = false,
    CrouchDuration = 2,
    TriggerRange = 40,
    LastCrouch = 0,
    MonitorConn = nil,
}
local AC = W.AutoCrouch

local function AC_DoCrouch()
    local now = tick()
    if now - AC.LastCrouch < 1 then return end
    AC.LastCrouch = now
    pcall(function()
        local b = LocalPlayer:FindFirstChild("PlayerGui")
        for segment in string.gmatch("Survivor-mob.Controls.crouch.icon", "[^%.]+") do
            if b then b = b:FindFirstChild(segment) end
        end
        if b and b:IsA("GuiObject") and b.Visible and b.Parent and b.Parent:IsA("GuiButton") then
            local btn = b.Parent
            if UserInputService.TouchEnabled and type(firesignal) == "function" then
                firesignal(btn.MouseButton1Click)
                task.wait(AC.CrouchDuration)
                firesignal(btn.MouseButton1Click)
            else
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
                task.wait(AC.CrouchDuration)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
            end
        else
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
            task.wait(AC.CrouchDuration)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
        end
    end)
end

W.AutoCrouch_Start = function()
    if AC.MonitorConn then return end
    AC.MonitorConn = RunService.Heartbeat:Connect(function()
        if not AC.Enabled then return end
        local myChar = LocalPlayer.Character
        if not myChar then return end
        if myChar:GetAttribute("Knocked") or myChar:GetAttribute("IsHooked") then return end
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Team and p.Team.Name == "Killer" and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    local animator = hum:FindFirstChildOfClass("Animator")
                    if animator then
                        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                            local id = track.Animation and track.Animation.AnimationId:match("%d+")
                            if id == "80411309607666" then
                                local kHRP = p.Character:FindFirstChild("HumanoidRootPart")
                                if kHRP and (myHRP.Position - kHRP.Position).Magnitude <= AC.TriggerRange then
                                    AC_DoCrouch()
                                    return
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

W.AutoCrouch_Stop = function()
    if AC.MonitorConn then AC.MonitorConn:Disconnect(); AC.MonitorConn = nil end
end

--========================================================--
-- 8b. AUTO SKILL CHECK
--========================================================--
local SkillCheckRemote = nil
pcall(function()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        local gen = remotes:FindFirstChild("Generator")
        if gen then
            SkillCheckRemote = gen:FindFirstChild("SkillCheckResultEvent")
        end
    end
end)

local TouchID    = 8822
local ActionPath = "Survivor-mob.Controls.action.check"

local function pressSpace()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    task.wait()
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
end

local function GetActionTarget()
    local current = PlayerGui
    for segment in string.gmatch(ActionPath, "[^%.]+") do
        current = current and current:FindFirstChild(segment)
    end
    return current
end

local function TriggerMobileButton()
    local b = GetActionTarget()
    if b and b:IsA("GuiObject") then
        local p, s = b.AbsolutePosition, b.AbsoluteSize
        local i = GuiService:GetGuiInset()
        local cx, cy = p.X + (s.X/2) + i.X, p.Y + (s.Y/2) + i.Y
        pcall(function()
            VirtualInputManager:SendTouchEvent(TouchID, 0, cx, cy)
            task.wait(0.01)
            VirtualInputManager:SendTouchEvent(TouchID, 2, cx, cy)
        end)
    end
end

W.startSkillCheck = function()
    if Connections.SkillHeartbeat then Connections.SkillHeartbeat:Disconnect() end
    Connections.SkillHeartbeat = RunService.RenderStepped:Connect(function()
        if not Auto.SkillCheck or State.busy then return end

        local prompt = PlayerGui:FindFirstChild("SkillCheckPromptGui")
        if not prompt then return end

        local check = prompt:FindFirstChild("Check")
        if not check or not check.Visible then return end

        local line = check:FindFirstChild("Line")
        local goal = check:FindFirstChild("Goal")
        if not line or not goal then return end

        if Auto.SkillCheckMode == "Instant" then
            line.Rotation = goal.Rotation + 109
            State.busy = true
            task.spawn(function()
                if UserInputService.TouchEnabled then
                    TriggerMobileButton()
                else
                    pressSpace()
                end
                task.wait(0.2)
                State.busy = false
            end)
        else
            local lr = line.Rotation % 360
            local gr = goal.Rotation % 360
            local startRange = (gr + 102) % 360
            local endRange   = (gr + 116) % 360
            local success = (startRange > endRange and (lr >= startRange or lr <= endRange))
                         or (lr >= startRange and lr <= endRange)

            if success then
                State.busy = true
                task.spawn(function()
                    if UserInputService.TouchEnabled then TriggerMobileButton()
                    else pressSpace() end
                    task.wait(0.05)
                    State.busy = false
                end)
            end
        end
    end)
end

--========================================================--
-- 8c. SELF HEAL
--========================================================--
function W.doSelfHealTrue()
    local c = LocalPlayer.Character
    if not c then return end
    local hr = ReplicatedStorage.Remotes.Healing.HealEvent
    local hp = c:FindFirstChild("HumanoidRootPart")
    if not hp then return end
    pcall(function() hr:FireServer(hp, true) end)
end

function W.doSelfHealFalse()
    local c = LocalPlayer.Character
    if not c then return end
    local hr = ReplicatedStorage.Remotes.Healing.HealEvent
    local hp = c:FindFirstChild("HumanoidRootPart")
    if not hp then return end
    pcall(function() hr:FireServer(hp, false) end)
end

function W.doOthersHealTrue(tp)
    if not tp or not tp.Character then return end
    local hrp = tp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hr = ReplicatedStorage.Remotes.Healing.HealEvent
    pcall(function() hr:FireServer(hrp, true) end)
end

function W.doOthersHealFalse(tp)
    if not tp or not tp.Character then return end
    local hrp = tp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hr = ReplicatedStorage.Remotes.Healing.HealEvent
    pcall(function() hr:FireServer(hrp, false) end)
end

function W.setInstantHealSelf(v)
    W.InstantHealSelf = v
    if v then
        local ha = false
        if W.InstantHealConnection then W.InstantHealConnection:Disconnect() end
        W.InstantHealConnection = RunService.Heartbeat:Connect(function()
            if not W.InstantHealSelf then return end
            local c = LocalPlayer.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if not h then return end
            if h.Health >= h.MaxHealth * 0.9 then
                if ha then ha = false; W.doSelfHealFalse() end
                return
            end
            if ha then
                local ci = c:FindFirstChild("CheckInterractable")
                if ci and not ci:GetAttribute("isHealing") then ha = false end
            end
            if not ha then ha = true; W.doSelfHealTrue() end
        end)
    else
        if W.InstantHealConnection then W.InstantHealConnection:Disconnect(); W.InstantHealConnection = nil end
        pcall(W.doSelfHealFalse)
    end
end

function W.setAutoHealAll(v)
    W.AutoHealAll = v
    if v then
        local ah = {}
        if W.AutoHealAllConnection then W.AutoHealAllConnection:Disconnect() end
        W.AutoHealAllConnection = RunService.Heartbeat:Connect(function()
            if not W.AutoHealAll then return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    local hu = p.Character:FindFirstChildOfClass("Humanoid")
                    if hu and hu.Health > 0 and hu.Health < hu.MaxHealth * 0.9 and hrp then
                        if ah[p] then
                            local c = LocalPlayer.Character
                            local ci = c and c:FindFirstChild("CheckInterractable")
                            if ci and not ci:GetAttribute("isHealing") then ah[p] = nil end
                        end
                        if not ah[p] then ah[p] = true; W.doOthersHealTrue(p) end
                    else
                        if ah[p] then ah[p] = nil; W.doOthersHealFalse(p) end
                    end
                else
                    if ah[p] then ah[p] = nil; pcall(function() W.doOthersHealFalse(p) end) end
                end
            end
        end)
    else
        if W.AutoHealAllConnection then W.AutoHealAllConnection:Disconnect(); W.AutoHealAllConnection = nil end
    end
end

--========================================================--
-- 8d. FAKE PERKS
--========================================================--
local function FP_Char() return LocalPlayer.Character end
local function FP_Hum() local c = FP_Char(); return c and c:FindFirstChildOfClass("Humanoid") end

local function FP_GetTotal()
    local t = 0
    for _, b in pairs(FP.ActiveBuffs) do if tick() < b.endTime then t = t + b.amt end end
    return t
end

local function FP_Apply()
    local c = FP_Char()
    local tb = FP_GetTotal()
    local h = FP_Hum()
    if c then
        if tb > 0 then c:SetAttribute("speedboost", 1 + (tb / 14))
        else c:SetAttribute("speedboost", 1) end
    end
    if h and tb > 0 then h.WalkSpeed = 16 + tb end
end

local function FP_EnsureHB()
    if FP.HB then return end
    FP.HB = RunService.Heartbeat:Connect(function()
        local exp = {}
        for n, b in pairs(FP.ActiveBuffs) do if tick() >= b.endTime then table.insert(exp, n) end end
        for _, n in ipairs(exp) do FP.ActiveBuffs[n] = nil end
        if #exp > 0 and FP_GetTotal() <= 0 then FP.LastBuffEnd = tick() end
        FP_Apply()
        if FP_GetTotal() <= 0 and next(FP.ActiveBuffs) == nil then
            if FP.HB then FP.HB:Disconnect(); FP.HB = nil end
            local c = FP_Char()
            if c then c:SetAttribute("speedboost", 1) end
        end
    end)
end

local function FP_TryBuff(name, amt, dur)
    if FP.ActiveBuffs[name] then return end
    if tick() - FP.LastBuffEnd < FP.CooldownTime and next(FP.ActiveBuffs) == nil then return end
    FP.ActiveBuffs[name] = { amt = amt, endTime = tick() + dur }
    FP_Apply(); FP_EnsureHB()
    notify("Fake Perks", "[" .. name .. "] Aktif! +" .. amt .. " Speed (" .. dur .. "s)", 3)
end

local function FP_Clean(name)
    if FP.Conns[name] then
        for _, c in ipairs(FP.Conns[name]) do pcall(function() c:Disconnect() end) end
        FP.Conns[name] = nil
    end
end
local function FP_Reg(name, conn)
    if not FP.Conns[name] then FP.Conns[name] = {} end
    table.insert(FP.Conns[name], conn)
end

function W.FP_SetupFlowstate(val)
    FP.FlowstateOn = val
    local c = FP_Char()
    if c then c:SetAttribute("Flowstate", val) end
    if val then
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        local w = r and r:FindFirstChild("Window")
        local p = r and r:FindFirstChild("Pallet")
        local function onV()
            if not FP.FlowstateOn then return end
            task.delay(0.5, function() if FP.FlowstateOn then FP_TryBuff("Flowstate", 5, 3) end end)
        end
        if w then
            local vb = w:FindFirstChild("Vaultbindable")
            if vb and vb:IsA("BindableEvent") then FP_Reg("Flowstate", vb.Event:Connect(onV)) end
        end
        if p then
            local sb = p:FindFirstChild("Slidebindable")
            if sb and sb:IsA("BindableEvent") then FP_Reg("Flowstate", sb.Event:Connect(onV)) end
        end
        local function hookChar(cc)
            if not cc then return end
            local cn = cc:GetAttributeChangedSignal("__VaultFireCount"):Connect(function()
                if FP.FlowstateOn then onV() end
            end)
            FP_Reg("Flowstate", cn)
        end
        hookChar(LocalPlayer.Character)
        FP_Reg("Flowstate", LocalPlayer.CharacterAdded:Connect(function(cc)
            if FP.FlowstateOn then cc:SetAttribute("Flowstate", true); hookChar(cc) end
        end))
    else
        FP_Clean("Flowstate")
        FP.ActiveBuffs["Flowstate"] = nil
        local c2 = FP_Char()
        if c2 then c2:SetAttribute("Flowstate", false) end
    end
end

function W.FP_SetupQuickRecovery(val)
    FP.QuickRecOn = val
    if val then
        local function onH()
            if not FP.QuickRecOn then return end
            FP_TryBuff("QuickRecovery", 6, 3)
        end
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        local hf = r and r:FindFirstChild("Healing")
        if hf then
            local hd = hf:FindFirstChild("Healdone")
            if hd and hd:IsA("BindableEvent") then FP_Reg("QuickRecovery", hd.Event:Connect(onH)) end
        end
        local function hookH(cc)
            if not cc then return end
            local h = cc:FindFirstChildOfClass("Humanoid")
            if h then
                local lh = h.Health
                local cn = h.HealthChanged:Connect(function(nh)
                    if not FP.QuickRecOn then return end
                    if nh > lh and (nh >= h.MaxHealth or (nh - lh) >= 15) then onH() end
                    lh = nh
                end)
                FP_Reg("QuickRecovery", cn)
            end
        end
        hookH(LocalPlayer.Character)
        FP_Reg("QuickRecovery", LocalPlayer.CharacterAdded:Connect(hookH))
    else
        FP_Clean("QuickRecovery")
        FP.ActiveBuffs["QuickRecovery"] = nil
    end
end

function W.FP_SetupPerfectLanding(val)
    FP.PerfLandOn = val
    if val then
        local function hookF(cc)
            if not cc then return end
            local h = cc:FindFirstChildOfClass("Humanoid")
            if not h then return end
            local wf, fs = false, 0
            local cn = h.StateChanged:Connect(function(_, n)
                if not FP.PerfLandOn then return end
                if n == Enum.HumanoidStateType.Freefall then wf = true; fs = tick() end
                if wf and (n == Enum.HumanoidStateType.Landed or n == Enum.HumanoidStateType.Running) then
                    local ft = tick() - fs
                    wf = false
                    if ft >= 0.25 then FP_TryBuff("PerfectLanding", 8, 3) end
                end
            end)
            FP_Reg("PerfectLanding", cn)
        end
        hookF(LocalPlayer.Character)
        FP_Reg("PerfectLanding", LocalPlayer.CharacterAdded:Connect(hookF))
    else
        FP_Clean("PerfectLanding")
        FP.ActiveBuffs["PerfectLanding"] = nil
    end
end

function W.FP_SetupAdrenalineRush(val)
    FP.AdrenalineOn = val
    if val then
        local function hookD(cc)
            if not cc then return end
            local h = cc:FindFirstChildOfClass("Humanoid")
            if not h then return end
            local lh = h.Health
            local cn = h.HealthChanged:Connect(function(nh)
                if not FP.AdrenalineOn then return end
                if nh < lh and nh <= 50 and nh > 0 then FP_TryBuff("AdrenalineRush", 4, 5) end
                lh = nh
            end)
            FP_Reg("AdrenalineRush", cn)
        end
        hookD(LocalPlayer.Character)
        FP_Reg("AdrenalineRush", LocalPlayer.CharacterAdded:Connect(hookD))
    else
        FP_Clean("AdrenalineRush")
        FP.ActiveBuffs["AdrenalineRush"] = nil
    end
end

--========================================================--
-- 8e. UI — SURVIVOR TAB
--========================================================--
SurvivorTab:CreateSection({ name = "Bypass Generator" })
SurvivorTab:CreateToggle({
    name = "Enable Bypass Generator",
    value = GenBypass.Enabled,
    callback = function(v)
        W.setGenBypass(v)
        if v then notify("Bypass Generator", "Enabled - Repairs instant", 3)
        else notify("Bypass Generator", "Disabled", 2) end
    end,
})

SurvivorTab:CreateSection({ name = "Bypass Self Unhook" })
SurvivorTab:CreateToggle({
    name = "Enable Bypass Self Unhook",
    value = false,
    callback = function(v)
        W.SU_SetEnabled(v)
        if v then notify("Bypass Self Unhook", "Enabled - auto follow killer", 3)
        else notify("Bypass Self Unhook", "Disabled", 2) end
    end,
})

SurvivorTab:CreateSection({ name = "Auto Drop Pallet" })
SurvivorTab:CreateToggle({
    name = "Enable Auto Drop Pallet",
    value = Auto.PalletDrop,
    callback = function(v)
        Auto.PalletDrop = v
        if FloatingButtons and FloatingButtons.AutoPallet then FloatingButtons.AutoPallet.UpdateVisual() end
        if v then notify("Auto Drop Pallet", "Enabled - auto drop saat killer dekat", 3)
        else
            State.UsedPallets = {}
            notify("Auto Drop Pallet", "Disabled", 2)
        end
    end,
})
SurvivorTab:CreateSlider({
    name = "Auto Pallet Trigger Distance",
    range = {3, 20}, increment = 1, value = Auto.PalletDropDist or 6,
    callback = function(v) Auto.PalletDropDist = v end,
})

SurvivorTab:CreateSection({ name = "Auto Crouch (Dodge S1)" })
SurvivorTab:CreateToggle({
    name = "Enable Auto Crouch",
    value = AC.Enabled,
    callback = function(v)
        AC.Enabled = v
        if v then W.AutoCrouch_Start() else W.AutoCrouch_Stop() end
        notify("Auto Crouch", v and "Enabled" or "Disabled", 2)
    end,
})

SurvivorTab:CreateSection({ name = "Auto Skill Check" })
SurvivorTab:CreateToggle({
    name = "Auto Skill Check",
    value = Auto.SkillCheck,
    callback = function(v)
        Auto.SkillCheck = v
        if v then
            W.startSkillCheck()
            notify("Auto Skill Check", "Enabled", 2)
        else
            if Connections.SkillHeartbeat then
                Connections.SkillHeartbeat:Disconnect()
                Connections.SkillHeartbeat = nil
            end
            notify("Auto Skill Check", "Disabled", 2)
        end
    end,
})
SurvivorTab:CreateDropdown({
    name = "Skill Check Mode",
    options = {"Legit", "Instant"},
    currentOption = Auto.SkillCheckMode or "Legit",
    callback = function(opt)
        local val = type(opt) == "table" and opt[1] or opt
        Auto.SkillCheckMode = val
        notify("Skill Check Mode", val, 2)
    end,
})

SurvivorTab:CreateSection({ name = "Self Heal" })
SurvivorTab:CreateToggle({
    name = "Instant Self Heal",
    value = false,
    callback = function(v)
        W.setInstantHealSelf(v)
        if FloatingButtons and FloatingButtons.SelfHeal then FloatingButtons.SelfHeal.UpdateVisual() end
        if v then notify("Self Heal", "Instant Self Heal Enabled", 2)
        else notify("Self Heal", "Instant Self Heal Disabled", 2) end
    end,
})
SurvivorTab:CreateToggle({
    name = "Auto Heal All Survivors",
    value = false,
    callback = function(v)
        W.setAutoHealAll(v)
        if v then notify("Self Heal", "Auto Heal All Enabled", 2)
        else notify("Self Heal", "Auto Heal All Disabled", 2) end
    end,
})

SurvivorTab:CreateSection({ name = "Fake Perks" })
SurvivorTab:CreateSlider({
    name = "Perk Cooldown (semua perk)",
    range = {0, 60}, increment = 1, value = FP.CooldownTime or 10,
    callback = function(v)
        FP.CooldownTime = v
        VD.FP_Cooldown = v
    end,
})
SurvivorTab:CreateToggle({
    name = "Flowstate (Vault Speed Boost)",
    value = false,
    callback = function(v)
        W.FP_SetupFlowstate(v)
        if FloatingButtons and FloatingButtons.Flowstate then FloatingButtons.Flowstate.UpdateVisual() end
        if v then notify("Fake Perks", "Flowstate Enabled", 2)
        else notify("Fake Perks", "Flowstate Disabled", 2) end
    end,
})
SurvivorTab:CreateToggle({
    name = "Quick Recovery (Fast Heal)",
    value = false,
    callback = function(v)
        W.FP_SetupQuickRecovery(v)
        if v then notify("Fake Perks", "Quick Recovery Enabled", 2)
        else notify("Fake Perks", "Quick Recovery Disabled", 2) end
    end,
})
SurvivorTab:CreateToggle({
    name = "Perfect Landing (Fall = Speed)",
    value = false,
    callback = function(v)
        W.FP_SetupPerfectLanding(v)
        if v then notify("Fake Perks", "Perfect Landing Enabled", 2)
        else notify("Fake Perks", "Perfect Landing Disabled", 2) end
    end,
})
SurvivorTab:CreateToggle({
    name = "Adrenaline Rush (Low HP = Speed)",
    value = false,
    callback = function(v)
        W.FP_SetupAdrenalineRush(v)
        if v then notify("Fake Perks", "Adrenaline Rush Enabled", 2)
        else notify("Fake Perks", "Adrenaline Rush Disabled", 2) end
    end,
})

SurvivorTab:CreateSection({ name = "Floating Button GUI" })
SurvivorTab:CreateToggle({
    name = "Show Self Heal Button",
    value = false,
    callback = function(v)
        if v then
            if FloatingButtons.SelfHeal then FloatingButtons.SelfHeal.Create() end
            notify("Floating Button", "Self Heal Button shown", 2)
        else
            if FloatingButtons.SelfHeal then FloatingButtons.SelfHeal.Destroy() end
            notify("Floating Button", "Self Heal Button hidden", 2)
        end
    end,
})
SurvivorTab:CreateToggle({
    name = "Show Flowstate Button",
    value = false,
    callback = function(v)
        if v then
            if FloatingButtons.Flowstate then FloatingButtons.Flowstate.Create() end
            notify("Floating Button", "Flowstate Button shown", 2)
        else
            if FloatingButtons.Flowstate then FloatingButtons.Flowstate.Destroy() end
            notify("Floating Button", "Flowstate Button hidden", 2)
        end
    end,
})
SurvivorTab:CreateToggle({
    name = "Show Parry Button",
    value = false,
    callback = function(v)
        if v then
            if FloatingButtons.Parry then FloatingButtons.Parry.Create() end
            notify("Floating Button", "Parry Button shown", 2)
        else
            if FloatingButtons.Parry then FloatingButtons.Parry.Destroy() end
            notify("Floating Button", "Parry Button hidden", 2)
        end
    end,
})
SurvivorTab:CreateToggle({
    name = "Show Parry V2 Button",
    value = false,
    callback = function(v)
        if v then
            if FloatingButtons.ParryV2 then FloatingButtons.ParryV2.Create() end
            notify("Floating Button", "Parry V2 Button shown", 2)
        else
            if FloatingButtons.ParryV2 then FloatingButtons.ParryV2.Destroy() end
            notify("Floating Button", "Parry V2 Button hidden", 2)
        end
    end,
})
SurvivorTab:CreateToggle({
    name = "Show Self Unhook Button",
    value = false,
    callback = function(v)
        if v then
            if FloatingButtons.SelfUnhook then FloatingButtons.SelfUnhook.Create() end
            notify("Floating Button", "Self Unhook Button shown", 2)
        else
            if FloatingButtons.SelfUnhook then FloatingButtons.SelfUnhook.Destroy() end
            notify("Floating Button", "Self Unhook Button hidden", 2)
        end
    end,
})
SurvivorTab:CreateToggle({
    name = "Show Auto Pallet Button",
    value = false,
    callback = function(v)
        if v then
            if FloatingButtons.AutoPallet then FloatingButtons.AutoPallet.Create() end
            notify("Floating Button", "Auto Pallet Button shown", 2)
        else
            if FloatingButtons.AutoPallet then FloatingButtons.AutoPallet.Destroy() end
            notify("Floating Button", "Auto Pallet Button hidden", 2)
        end
    end,
})

--========================================================--
-- 9. TAB 4 : KILLER
--========================================================--
local KillerTab = Window:CreateTab({ name = "Killer", icon = 10974441727 })

W.KillerBypass = W.KillerBypass or {
    HiddenLeap = false, MyersStalk = false, JeffFrenzy = false, AbyssCorrupt = false,
    _hiddenThread = nil, _myersConn = nil, _jeffThread = nil, _abyssConn = nil, _abyssFunc = nil,
}
local KB = W.KillerBypass

function W.KB_StartHiddenBypass()
    if KB._hiddenThread then return end
    KB._hiddenThread = task.spawn(function()
        local lf, m2f
        local function scan()
            pcall(function()
                for _, v in pairs(getgc(true)) do
                    if type(v) == "function" and islclosure(v) then
                        local info; pcall(function() info = debug.getinfo(v) end)
                        if info then
                            if info.name == "tryActivate" then lf = v
                            elseif info.name == "playM2Animation" then m2f = v end
                        end
                    end
                    if lf and m2f then break end
                end
            end)
        end
        scan()
        local last = os.clock()
        while task.wait(0.1) do
            if not KB.HiddenLeap then break end
            if not (lf and m2f) then
                local now = os.clock()
                if now - last >= 2 then last = now; scan() end
            end
            if lf then
                pcall(function()
                    for i, val in pairs(debug.getupvalues(lf)) do
                        if type(val) == "boolean" and val == true then
                            debug.setupvalue(lf, i, false)
                        end
                    end
                end)
            end
            if m2f then
                pcall(function()
                    for i, val in pairs(debug.getupvalues(m2f)) do
                        if type(val) == "boolean" and val == true then
                            debug.setupvalue(m2f, i, false)
                        end
                    end
                end)
            end
        end
        KB._hiddenThread = nil
    end)
end
function W.KB_StopHiddenBypass()
    if KB._hiddenThread then pcall(function() task.cancel(KB._hiddenThread) end); KB._hiddenThread = nil end
end

function W.KB_StartMyersBypass()
    if KB._myersConn then return end
    KB._myersConn = RunService.Heartbeat:Connect(function()
        if not KB.MyersStalk then return end
        local c = LocalPlayer.Character
        if not c then return end
        pcall(function()
            for _, attr in ipairs({"StalkCooldown","Tier3Cooldown","Tier2Cooldown","StalkCD","StalkTimer","StalkBuffCD"}) do
                local v = c:GetAttribute(attr)
                if type(v) == "number" and v > 0 then c:SetAttribute(attr, 0) end
                if type(v) == "boolean" and v == true then c:SetAttribute(attr, false) end
            end
        end)
    end)
end
function W.KB_StopMyersBypass()
    if KB._myersConn then KB._myersConn:Disconnect(); KB._myersConn = nil end
end

function W.KB_StartJeffBypass()
    if KB._jeffThread then return end
    KB._jeffThread = task.spawn(function()
        while task.wait() do
            if not KB.JeffFrenzy then break end
            pcall(function()
                local c = LocalPlayer.Character
                if c and c:GetAttribute("Frenzy") ~= true then
                    c:SetAttribute("Frenzy", true)
                end
            end)
        end
        KB._jeffThread = nil
    end)
end
function W.KB_StopJeffBypass()
    if KB._jeffThread then pcall(function() task.cancel(KB._jeffThread) end); KB._jeffThread = nil end
    pcall(function()
        local c = LocalPlayer.Character
        if c and c:GetAttribute("Frenzy") == true then
            c:SetAttribute("Frenzy", false)
            local k = ReplicatedStorage:FindFirstChild("Remotes")
                and ReplicatedStorage.Remotes:FindFirstChild("Killers")
                and ReplicatedStorage.Remotes.Killers:FindFirstChild("Killer")
            if k then
                local d = k:FindFirstChild("Deactivatefromclient")
                if d then d:FireServer() end
            end
        end
    end)
end

function W.KB_StartAbyssBypass()
    if not KB._abyssFunc then
        pcall(function()
            for _, v in pairs(getgc(true)) do
                if type(v) == "function" and islclosure(v) then
                    local ct = debug.getconstants(v)
                    if table.find(ct, "corrupt") and table.find(ct, "Immobile") then
                        KB._abyssFunc = v
                        break
                    end
                end
            end
        end)
    end
    if not KB._abyssFunc then
        notify("Bypass Abyss", "Gagal nemu function. Coba lagi nanti.", 3)
        return
    end
    if KB._abyssConn then KB._abyssConn:Disconnect() end
    KB._abyssConn = RunService.Heartbeat:Connect(function()
        if not KB.AbyssCorrupt then return end
        if KB._abyssFunc then
            pcall(function()
                local uv = debug.getupvalues(KB._abyssFunc)
                for idx, val in pairs(uv) do
                    if type(val) == "boolean" and val == false then
                        debug.setupvalue(KB._abyssFunc, idx, true)
                    end
                end
            end)
        end
    end)
end
function W.KB_StopAbyssBypass()
    if KB._abyssConn then KB._abyssConn:Disconnect(); KB._abyssConn = nil end
end

--========================================================--
-- 9a. BLOCK ALL VAULT
--========================================================--
local function HandleBlockVaults()
    if not Killer.BlockVaults then return end
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
end

RunService.Heartbeat:Connect(function()
    if Killer.BlockVaults then
        pcall(HandleBlockVaults)
    end
end)

--========================================================--
-- 9a2. AUTO STALK
--========================================================--
W.AutoStalk = W.AutoStalk or {
    Enabled = false,
    StalkRange = 150,
    Target = nil,
    Conn = nil,
}
local AS = W.AutoStalk

local function AS_GetClosestSurvivor()
    local root = getRoot()
    if not root then return nil end
    local closest, shortest = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 30 then
                local d = (hrp.Position - root.Position).Magnitude
                if d <= AS.StalkRange and d < shortest then
                    shortest = d; closest = plr
                end
            end
        end
    end
    return closest
end

local function AS_GetStalkRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then return nil end
    local killers = remotes:FindFirstChild("Killers")
    if not killers then return nil end
    local stalker = killers:FindFirstChild("Stalker")
    if not stalker then return nil end
    return stalker:FindFirstChild("StartStalking")
end

W.AutoStalk_Start = function()
    if AS.Conn then return end
    AS.Conn = RunService.Heartbeat:Connect(function()
        if not AS.Enabled then return end
        local target = AS_GetClosestSurvivor()
        if not target or not target.Character then return end
        local ev = AS_GetStalkRemote()
        if ev then pcall(function() ev:FireServer(target) end) end
    end)
end

W.AutoStalk_Stop = function()
    if AS.Conn then AS.Conn:Disconnect(); AS.Conn = nil end
end

--========================================================--
-- 9a3. SELECT MASKED
--========================================================--
W.Masked = W.Masked or {
    Enabled = false,
    CurrentPower = "Cobra",
    Powers = {"Cobra", "Richter", "Brandon", "Rabbit", "Alex"},
}
local Masked = W.Masked

function W.Masked_Activate()
    local ev = ReplicatedStorage:FindFirstChild("Remotes")
        and ReplicatedStorage.Remotes:FindFirstChild("Killers")
        and ReplicatedStorage.Remotes.Killers:FindFirstChild("Masked")
        and ReplicatedStorage.Remotes.Killers.Masked:FindFirstChild("Activatepower")
    if ev then
        pcall(function() ev:FireServer(Masked.CurrentPower) end)
        notify("Select Masked", "Activated: " .. Masked.CurrentPower, 2)
    else
        notify("Select Masked", "Activatepower remote not found!", 2)
    end
end

function W.Masked_Deactivate()
    local ev = ReplicatedStorage:FindFirstChild("Remotes")
        and ReplicatedStorage.Remotes:FindFirstChild("Killers")
        and ReplicatedStorage.Remotes.Killers:FindFirstChild("Masked")
        and ReplicatedStorage.Remotes.Killers.Masked:FindFirstChild("Deactivatepower")
    if ev then
        pcall(function() ev:FireServer() end)
        notify("Select Masked", "Deactivated", 2)
    else
        notify("Select Masked", "Deactivatepower remote not found!", 2)
    end
end

--========================================================--
-- 9b. UI — KILLER TAB
--========================================================--
KillerTab:CreateSection({ name = "Bypass Cooldown (Hidden)" })
KillerTab:CreateToggle({
    name = "Bypass Hidden Leap Cooldown", value = false,
    callback = function(v)
        KB.HiddenLeap = v
        if v then W.KB_StartHiddenBypass(); notify("Bypass Hidden", "Leap cooldown bypassed", 2)
        else W.KB_StopHiddenBypass(); notify("Bypass Hidden", "Disabled", 2) end
    end,
})

KillerTab:CreateSection({ name = "Bypass Cooldown (Myers)" })
KillerTab:CreateToggle({
    name = "Bypass Myers Stalk Cooldown", value = false,
    callback = function(v)
        KB.MyersStalk = v
        if v then W.KB_StartMyersBypass(); notify("Bypass Myers", "Stalk cooldown bypassed", 2)
        else W.KB_StopMyersBypass(); notify("Bypass Myers", "Disabled", 2) end
    end,
})

KillerTab:CreateSection({ name = "Bypass Cooldown (Jeff)" })
KillerTab:CreateToggle({
    name = "Bypass Jeff Frenzy Cooldown", value = false,
    callback = function(v)
        KB.JeffFrenzy = v
        if v then W.KB_StartJeffBypass(); notify("Bypass Jeff", "Frenzy cooldown bypassed", 2)
        else W.KB_StopJeffBypass(); notify("Bypass Jeff", "Disabled", 2) end
    end,
})

KillerTab:CreateSection({ name = "Bypass Cooldown (Abyss)" })
KillerTab:CreateToggle({
    name = "Bypass Abyss Corrupt Cooldown", value = false,
    callback = function(v)
        KB.AbyssCorrupt = v
        if v then W.KB_StartAbyssBypass(); notify("Bypass Abyss", "Corrupt cooldown bypassed", 2)
        else W.KB_StopAbyssBypass(); notify("Bypass Abyss", "Disabled", 2) end
    end,
})

KillerTab:CreateSection({ name = "Auto Stalk (Myers)" })
KillerTab:CreateToggle({
    name = "Enable Auto Stalk",
    value = AS.Enabled,
    callback = function(v)
        AS.Enabled = v
        if v then W.AutoStalk_Start() else W.AutoStalk_Stop() end
        notify("Auto Stalk", v and "Enabled" or "Disabled", 2)
    end,
})
KillerTab:CreateSlider({
    name = "Auto Stalk Range", range = {30, 500}, increment = 10, value = AS.StalkRange,
    callback = function(v) AS.StalkRange = v end,
})

KillerTab:CreateSection({ name = "Select Masked (Power)" })
KillerTab:CreateDropdown({
    name = "Masked Power",
    options = Masked.Powers,
    currentOption = Masked.CurrentPower,
    callback = function(opt)
        local val = type(opt) == "table" and opt[1] or opt
        Masked.CurrentPower = val
        notify("Select Masked", "Selected: " .. val, 1)
    end,
})
KillerTab:CreateButton({
    name = "Activate Power",
    callback = function() W.Masked_Activate() end,
})
KillerTab:CreateButton({
    name = "Deactivate Power",
    callback = function() W.Masked_Deactivate() end,
})

KillerTab:CreateSection({ name = "Block Vaults" })
KillerTab:CreateToggle({
    name = "Block All Vaults",
    value = Killer.BlockVaults,
    callback = function(v)
        Killer.BlockVaults = v
        if v then
            notify("Block Vaults", "Enabled - Entity Blocker aktif", 3)
            pcall(HandleBlockVaults)
        else
            notify("Block Vaults", "Disabled", 2)
        end
    end,
})

--========================================================--
-- 10. EXPORT & CLEANUP
--========================================================--
getgenv().ALFzxzzz_Veil_HideAllVisuals = Veil_HideAllVisuals

local function restoreVisuals()
    pcall(function()
        Visual.Fullbright = false
        Visual.NoShadow = false
        Visual.LowGraphics = false
        Visual.CleanSky = false
        applyVisual(true)
        applyOptimization(true)
        applyNoScreenEffects()
    end)
end

local function onUnload()
    pcall(function()
        if W.LockPOV_SetEnabled then W.LockPOV_SetEnabled(false) end
    end)
    pcall(Veil_HideAllVisuals)
    pcall(restoreVisuals)
    pcall(function()
        if getgenv().ALFzxzzz_Parry_DestroyCircle then getgenv().ALFzxzzz_Parry_DestroyCircle() end
    end)
    pcall(function()
        if W.ParryV2_Stop then W.ParryV2_Stop() end
    end)
    pcall(function()
        if W.AutoCrouch_Stop then W.AutoCrouch_Stop() end
    end)
    pcall(function()
        if W.AutoStalk_Stop then W.AutoStalk_Stop() end
    end)
    pcall(function()
        if W.StunIndicator.HeartbeatConn then
            W.StunIndicator.HeartbeatConn:Disconnect()
            W.StunIndicator.HeartbeatConn = nil
        end
        for _, gui in pairs(W.StunIndicator.Cache) do pcall(function() gui:Destroy() end) end
        W.StunIndicator.Cache = {}
    end)
    pcall(function()
        if ToFState.Connection then ToFState.Connection:Disconnect() end
        if ToFState.InputBegan then ToFState.InputBegan:Disconnect() end
        if ToFState.InputEnded then ToFState.InputEnded:Disconnect() end
        if ToFState.LaserBeam then ToFState.LaserBeam:Destroy() end
        if ToFState.TargetGui then ToFState.TargetGui:Destroy() end
    end)
    pcall(function()
        if pistolLaser then pistolLaser:Destroy() end
        if PistolFOVCircle then PistolFOVCircle:Remove() end
    end)
    pcall(function()
        for _, obj in pairs(W.ESPCache.Objects) do pcall(function() obj:Destroy() end) end
        for _, obj in pairs(W.ESPCache.Status) do pcall(function() obj:Destroy() end) end
        W.ESPCache.Objects = {}
        W.ESPCache.Status = {}
    end)
    pcall(function()
        if GenBypass.UI then GenBypass.UI:Destroy() end
        GenBypass.Processed = {}
        GenBypass.Cache = {}
    end)
    pcall(function()
        if Connections.SkillHeartbeat then
            Connections.SkillHeartbeat:Disconnect()
            Connections.SkillHeartbeat = nil
        end
    end)
    pcall(function()
        for name in pairs(FP.Conns) do FP_Clean(name) end
        if FP.HB then FP.HB:Disconnect(); FP.HB = nil end
        FP.ActiveBuffs = {}
        local c = LocalPlayer.Character
        if c then c:SetAttribute("speedboost", 1); c:SetAttribute("Flowstate", false) end
    end)
    pcall(function()
        if W.InstantHealConnection then W.InstantHealConnection:Disconnect(); W.InstantHealConnection = nil end
        if W.AutoHealAllConnection then W.AutoHealAllConnection:Disconnect(); W.AutoHealAllConnection = nil end
        W.InstantHealSelf = false
        W.AutoHealAll = false
        pcall(W.doSelfHealFalse)
    end)
    pcall(function()
        if FloatingButtons then
            for _, fb in pairs(FloatingButtons) do
                if fb.Destroy then fb.Destroy() end
            end
        end
    end)
    pcall(function()
        if W.KB_StopHiddenBypass then W.KB_StopHiddenBypass() end
        if W.KB_StopMyersBypass then W.KB_StopMyersBypass() end
        if W.KB_StopJeffBypass then W.KB_StopJeffBypass() end
        if W.KB_StopAbyssBypass then W.KB_StopAbyssBypass() end
    end)
    pcall(function()
        if W.SU_Stop then W.SU_Stop() end
    end)
    pcall(function()
        Killer.BlockVaults = false
        Auto.PalletDrop = false
        State.UsedPallets = {}
        Timers.lastPalletScan = 0
        Timers.lastPalletDrop = 0
    end)
end

if Rayfield.OnClose then
    pcall(function() Rayfield.OnClose:Connect(onUnload) end)
end

notify("ALFzxzzz Hub v25-FIX4", "Loaded! + Visual Effects + Lock POV ✅", 5)
print("[ALFzxzzz Hub v25-FIX4] + Fullbright / No Shadow / Low Graphics / Clean Sky / Lock POV")
