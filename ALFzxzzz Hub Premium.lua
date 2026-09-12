-- LOAD LIB
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

-- ============== CUSTOM THEME =================
Library.Scheme.AccentColor = Color3.fromRGB(255, 0, 0)
Library.Scheme.BackgroundColor = Color3.fromRGB(10, 10, 10)
Library.Scheme.MainColor = Color3.fromRGB(15, 15, 15)
Library.Scheme.OutlineColor = Color3.fromRGB(30, 30, 30)
Library.Scheme.FontColor = Color3.fromRGB(255, 255, 255)

-- SERVICES
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local Workspace      = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting       = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Stats          = game:GetService("Stats")
local TweenService   = game:GetService("TweenService")

local LocalPlayer  = Players.LocalPlayer
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")
local Camera       = workspace.CurrentCamera

local isMobile = UserInputService.TouchEnabled

-- ============== SHARED STATE (VD) =================
local VD = {
    TOF_SilentAim = false,
    TOF_TargetMode = "Killer",
    TOF_Key = "Q",
    TOF_Laser = true,
    TOF_WallCheck = true,
    TOF_BlockKnocked = true,

    FLASH_SilentAim = false,
    FLASH_TargetPart = "Head",
    FLASH_Range = 120,
    FLASH_Laser = true,
    FLASH_Smooth = 0.35,

    KILLER_InfLakeMist = false,
    KILLER_InfPursuit = false,
    KILLER_NoSlowdown = false,
    KILLER_AutoHook = false,
    KILLER_BypassCooldown = false,
    KILLER_BypassLeap = false,
    KILLER_InfFrenzy = false,
    KILLER_AntiBlind = false,
    KILLER_FakeAttack = false,
    BEAT_Killer = false,
    SPEED_Value = 16,
    _KillerTarget = nil,

    DashLockEnabled = false,
    DashLockSmoothness = 0.3,
    DashLockDuration = 1.5,
    FreezeDuringDashLock = false,
    _DashLockActive = false,
    _DashLockTarget = nil,
    _DashLockConnection = nil,

    SURV_FirstPerson = false,
}

local function VD_Notify(title, desc, duration)
    if Library and Library.Notify then
        Library:Notify({ Title = title, Description = desc, Time = duration or 2 })
    end
end

local function GetSafeGuiParent()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    return LocalPlayer:FindFirstChild("PlayerGui")
end

-- ============== ROLE HELPER =================
function GetRole()
    if not LocalPlayer.Team then return "Unknown" end
    local name = LocalPlayer.Team.Name
    if name == "Killer" then return "Killer"
    elseif name == "Survivors" then return "Survivor"
    else return "Spectator" end
end

-- ============== PLAYER MODS =================
local PlayerMods = {
    AntiFall = false,
    GodMode = false,
}

-- =====================================================
-- INSTANT HEAL CONFIG
-- =====================================================
InstantHealSelf = false
AutoHealAll = false
AutoSelfUnhook = false
AutoHealAllConnection = nil
InstantHealConnection = nil
AutoSelfUnhookConnection = nil

local SelfHealButton = {
    UI = nil, Button = nil, Stroke = nil,
    Dragging = false, DragStart = nil, DragStartPos = nil
}
local SelfHealButtonDragLocked = false

-- =====================================================
-- FAKE PERKS CONFIG
-- =====================================================
local FP = {
    Conns = {},
    ActiveBuffs = {},
    HB = nil,
    LastBuffEnd = 0,
    CooldownTime = 10,
    FlowstateOn = false,
    QuickRecOn = false,
    PerfLandOn = false,
    AdrenalineOn = false,
}

-- ============== AUTO CONFIG =================
local Auto = {
    SkillCheck       = false,
    SkillCheckMode   = "Legit",
    PalletDrop       = false,
    PalletDropDist   = 6,
    Flee             = false,
    FleeDist         = 50,
    FleeCooldown     = 0.1,
}

local TouchID = 8822
local ActionPath = "Survivor-mob.Controls.action.check"

-- ============== GEN BYPASS CONFIG =================
local GenBypass = {
    Enabled     = false,
    Button      = nil,
    UI          = nil,
    Cache       = {},
    CacheTimer  = 0,
    Processed   = {},
    HotkeyCode  = Enum.KeyCode.G,
    TriggerRange = 8,
}

-- ============== ESP CONFIG =================
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

local ESPItems = {
    ["Twist of Fate"]   = true,
    ["Bandage"]         = true,
    ["Motion Tracker"]  = true,
    ["Gate"]            = true,
    ["Shadow Clone"]    = true,
    ["Parrying Dagger"] = true
}

local TeamColors = {
    Killer   = Color3.fromRGB(255, 0, 0),
    Survivor = Color3.fromRGB(255, 255, 255)
}

local GeneratorColor = Color3.fromRGB(255, 230, 0)
local PalletColor    = Color3.fromRGB(74, 255, 181)
local WindowColor    = Color3.fromRGB(74, 255, 181)
local SCPColor       = Color3.fromRGB(255, 0, 0)

local ESPCache = {
    Objects    = {}, 
    Status     = {},
    SCP        = {}, 
    Generators = {},
    Windows    = {},
    Pallets    = {}
}

-- ============== CONFIG =================
local Config = {
    Surv_AutoParry = false,
    Surv_ParrySafety = false,
    Surv_ParryAggressive = false,
    Surv_ParryCircle = true,
    Surv_ParryRadius = 15,
    Surv_ParryFace = 0.7,
    Surv_AutoCrouch = false,
    Ignored_Skills_List = {}
}

local State = { 
    ParryCooldown = false,
    ParryCooldownTime = 60,
    AutoParryAdornment = nil,
    lastParry = 0,
    busy = false,
    UsedPallets = {},
    LastFlee = 0,
}

local Timers = {
    lastESPUpdate = 0,
    lastPalletScan = 0,
    lastPalletDrop = 0,
}

local Connections = {
    SkillHeartbeat = nil,
}

-- ============== PARRY SYSTEM =================
local VALID_PARRY_IDS = {
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
    ["80411309607666"] = "Abyssal S1"
}

local Attached = {}
local PARRY_DEBOUNCE = 0.2

function IsSafeToParry(char)
    if not Config.Surv_ParrySafety then return true end
    if not char then return false end
    local interactObj = char:FindFirstChild("CheckInterractable")
    if interactObj then
        if interactObj:GetAttribute("isVaulting") == true then return false end
        if interactObj:GetAttribute("isRepairing") == true then return false end
        if interactObj:GetAttribute("isUnhooking") == true then return false end
        if interactObj:GetAttribute("isHealing") == true then return false end
        if interactObj:GetAttribute("isSliding") == true then return false end
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
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
                task.wait(2)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
            end
        else
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
            task.wait(2)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
        end
    end)
end

function IsDowned(char)
    if not char then return false end
    return char:GetAttribute("Knocked") == true or char:GetAttribute("IsHooked") == true
end

function IsKiller(p) return p and p.Team and p.Team.Name == "Killer" end
function IsSurvivor(p) return p and p.Team and p.Team.Name == "Survivors" end

function tapMobileParryButton()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    local survivorMob = playerGui:FindFirstChild("Survivor-mob")
    local parryBtn = survivorMob and survivorMob:FindFirstChild("Controls") and survivorMob.Controls:FindFirstChild("Gui-mob")
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
            if mouse2press and mouse2release then mouse2press(); task.wait(0.01); mouse2release(); return end
            if MouseButton2Click then MouseButton2Click(); return end
            VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
        end)
    end
end

function ExecuteParry()
    if State.ParryCooldown then return end
    pcall(function()
        local parryRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("Items"):FindFirstChild("Parrying Dagger"):FindFirstChild("parry")
        if parryRemote then for i = 1, 10 do parryRemote:FireServer() end end
        task.spawn(tapMobileParryButton)
    end)
end

function ListenToParryResult()
    task.spawn(function()
        local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
        local dagger = remotes and remotes:WaitForChild("Items", 5):WaitForChild("Parrying Dagger", 5)
        local parryResultRemote = dagger and dagger:WaitForChild("parryResult", 5)
        if parryResultRemote then
            parryResultRemote.OnClientEvent:Connect(function(arg1, arg2)
                local cdDur = tonumber(arg2) or ((arg1 == true) and 90 or 60)
                State.ParryCooldown = true
                if State.ParryCooldownThread then task.cancel(State.ParryCooldownThread) end
                State.ParryCooldownThread = task.delay(cdDur, function() State.ParryCooldown = false end)
            end)
        end
    end)
end
ListenToParryResult()

function AttachParrySensor(kChar)
    if not kChar or Attached[kChar] then return end
    Attached[kChar] = true
    local humanoid = kChar:FindFirstChild("Humanoid")
    if not humanoid then humanoid = kChar:WaitForChild("Humanoid", 5); if not humanoid then return end end
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then animator = humanoid:WaitForChild("Animator", 5); if not animator then return end end

    humanoid.ChildAdded:Connect(function(child)
        if child:IsA("Animator") then Attached[kChar] = nil; AttachParrySensor(kChar) end
    end)
    kChar.AncestryChanged:Connect(function(_, parent)
        if not parent then Attached[kChar] = nil end
    end)

    animator.AnimationPlayed:Connect(function(track)
        local animId = track.Animation and track.Animation.AnimationId or ""
        local id = animId:match("%d+")
        local attackName = VALID_PARRY_IDS[id]
        if not attackName then return end
        
        if id == "80411309607666" and Config.Surv_AutoCrouch then
            local myChar = LocalPlayer.Character
            if IsDowned(myChar) then return end
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local kHRP = kChar:FindFirstChild("HumanoidRootPart")
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
        local kHRP = kChar:FindFirstChild("HumanoidRootPart")
        if not myHRP or not kHRP then return end
        
        local delta = myHRP.Position - kHRP.Position
        local startDistance = delta.Magnitude

        if Config.Surv_ParryAggressive then
            local aggressiveRadius = 12
            local detectionRadius = Config.Surv_ParryRadius + 5
            if startDistance > detectionRadius then return end
            if startDistance <= aggressiveRadius then ExecuteParry()
            else
                local tracker
                local startTime = os.clock()
                tracker = RunService.Heartbeat:Connect(function()
                    if os.clock() - startTime >= 1.5 or State.ParryCooldown or not myHRP or not kHRP or IsDowned(myChar) then
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
            local kPosFlat = Vector3.new(kHRP.Position.X, 0, kHRP.Position.Z)
            local flatDelta = myPosFlat - kPosFlat
            if flatDelta.Magnitude > 0 then
                local flatDirection = flatDelta.Unit
                local kLookFlat = Vector3.new(kHRP.CFrame.LookVector.X, 0, kHRP.CFrame.LookVector.Z).Unit
                local isFacing = kLookFlat:Dot(flatDirection)
                if isFacing < Config.Surv_ParryFace then return end
            end
            ExecuteParry()
        end
    end)
end

function TryAttach(p)
    if p ~= LocalPlayer and IsKiller(p) and p.Character then AttachParrySensor(p.Character) end
end

function SetupPlayer(p)
    if p == LocalPlayer then return end
    p.CharacterAdded:Connect(function() TryAttach(p) end)
    p:GetPropertyChangedSignal("Team"):Connect(function() TryAttach(p) end)
    if p.Character then TryAttach(p) end
end

-- ============== HELPERS =================
local function GetRoot()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function GetNearestKiller()
    local root = GetRoot()
    if not root then return nil, math.huge end
    local closest, shortest = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Team and plr.Team.Name == "Killer" and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist < shortest then shortest = dist; closest = hrp end
            end
        end
    end
    return closest, shortest
end

local function GetFarthestGeneratorPoint(killerRoot)
    if not killerRoot then return nil end
    local bestPoint, farthestDistance = nil, 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.match(obj.Name, "^GeneratorPoint%d+$") then
            local dist = (obj.Position - killerRoot.Position).Magnitude
            if dist > farthestDistance then farthestDistance = dist; bestPoint = obj end
        end
    end
    return bestPoint
end

local function GetNearestAliveSurvivor()
    local root = GetRoot()
    if not root then return nil end
    local closest, shortest = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 30 then
                local d = (hrp.Position - root.Position).Magnitude
                if d < shortest then shortest = d; closest = plr.Character end
            end
        end
    end
    return closest
end

-- ============== ESP PARRY CIRCLE =================
local function updateParryCircle()
    local root = GetRoot()
    if not Config.Surv_ParryCircle or not Config.Surv_AutoParry or not root then
        if State.AutoParryAdornment then State.AutoParryAdornment:Destroy(); State.AutoParryAdornment = nil end
        return
    end
    if not State.AutoParryAdornment or State.AutoParryAdornment.Parent ~= root then 
        if State.AutoParryAdornment then State.AutoParryAdornment:Destroy() end
        State.AutoParryAdornment = Instance.new("CylinderHandleAdornment")
        State.AutoParryAdornment.Name = "AutoParryCircleESP"
        State.AutoParryAdornment.Height = 0.05
        State.AutoParryAdornment.Transparency = 0.3
        State.AutoParryAdornment.Adornee = root
        State.AutoParryAdornment.Parent = root
        State.AutoParryAdornment.ZIndex = 0
        State.AutoParryAdornment.AlwaysOnTop = false 
    end
    local cR = Config.Surv_ParryRadius
    State.AutoParryAdornment.Radius = cR
    State.AutoParryAdornment.InnerRadius = math.max(0.1, cR - 0.15)
    State.AutoParryAdornment.CFrame = CFrame.new(0, -3, 0) * CFrame.Angles(math.rad(90), 0, 0)
    if State.ParryCooldown then State.AutoParryAdornment.Color3 = Color3.fromRGB(195, 0, 0)
    elseif Config.Surv_ParryAggressive then State.AutoParryAdornment.Color3 = Color3.fromRGB(255, 0, 0)
    else State.AutoParryAdornment.Color3 = Color3.fromRGB(0, 0, 0) end
end

-- =====================================================
-- AUTO SKILL CHECK
-- =====================================================
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
        local i = game:GetService("GuiService"):GetGuiInset()
        local cx, cy = p.X + (s.X/2) + i.X, p.Y + (s.Y/2) + i.Y
        pcall(function()
            VirtualInputManager:SendTouchEvent(TouchID, 0, cx, cy)
            task.wait(0.01)
            VirtualInputManager:SendTouchEvent(TouchID, 2, cx, cy)
        end)
    end
end

local function startSkillCheck()
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
                if UserInputService.TouchEnabled then TriggerMobileButton() else pressSpace() end
                task.wait(0.2) 
                State.busy = false
            end)
        else
            local lr = line.Rotation % 360
            local gr = goal.Rotation % 360
            local startRange = (gr + 102) % 360
            local endRange   = (gr + 116) % 360
            local success = (startRange > endRange and (lr >= startRange or lr <= endRange)) or (lr >= startRange and lr <= endRange)
            if success then
                State.busy = true
                task.spawn(function()
                    if UserInputService.TouchEnabled then TriggerMobileButton() else pressSpace() end
                    task.wait(0.05)
                    State.busy = false
                end)
            end
        end
    end)
end

-- =====================================================
-- ANTI FALL DAMAGE
-- =====================================================
local function SetupAntiFallDamage()
    pcall(function()
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        if not r then return end
        local m = r:FindFirstChild("Mechanics")
        local fallEvent = m and m:FindFirstChild("Fall")
        if not (fallEvent and fallEvent:IsA("RemoteEvent")) then return end
        local ok, mt = pcall(function() return getrawmetatable(game) end)
        if ok and mt and setreadonly then
            pcall(function()
                setreadonly(mt, false)
                local old = mt.__namecall
                mt.__namecall = newcclosure(function(self, ...)
                    if not checkcaller() and PlayerMods.AntiFall and self == fallEvent then
                        local method = getnamecallmethod()
                        if method == "FireServer" then return nil end
                    end
                    return old(self, ...)
                end)
                setreadonly(mt, true)
            end)
        end
    end)
end
SetupAntiFallDamage()

-- =====================================================
-- NO SLOWDOWN (KILLER)
-- =====================================================
function UpdateNoSlowdown()
    if not VD.KILLER_NoSlowdown or GetRole() ~= "Killer" then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.WalkSpeed < 16 then hum.WalkSpeed = VD.SPEED_Value or 16 end
end

function SetupAntiStunSlowdown()
    if getgenv().MAWWW_AntiStunHooked then return end
    getgenv().MAWWW_AntiStunHooked = true
    pcall(function()
        local ok, mt = pcall(function() return getrawmetatable(game) end)
        if ok and mt and setreadonly then
            pcall(function()
                setreadonly(mt, false)
                local oldNI = mt.__newindex
                local _genv = getgenv()
                mt.__newindex = newcclosure(function(t, k, v)
                    if k == "WalkSpeed" or k == "Anchored" then
                        if not checkcaller() and _genv.VD and _genv.VD.KILLER_NoSlowdown and GetRole() == "Killer" then
                            if k == "WalkSpeed" and typeof(v) == "number" and v < 16 and typeof(t) == "Instance" and t:IsA("Humanoid") then
                                return oldNI(t, k, _genv.VD.SPEED_Value or 16)
                            end
                            if k == "Anchored" and v == true and typeof(t) == "Instance" and t:IsA("BasePart") and t.Name == "HumanoidRootPart" then
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
task.spawn(SetupAntiStunSlowdown)

-- =====================================================
-- AUTO HOOK HELPERS
-- =====================================================
MAWWW_Cache = MAWWW_Cache or { Hooks = {} }
local function MAWWW_ScanHooks()
    local hooks = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name == "Hook" or obj.Name:lower():find("hook")) then
            local part = obj:FindFirstChild("HookPoint") or obj:FindFirstChild("HookHitbox") or obj:FindFirstChildWhichIsA("BasePart")
            if part then table.insert(hooks, { model = obj, part = part }) end
        end
    end
    MAWWW_Cache.Hooks = hooks
end
task.spawn(function() while true do task.wait(5); pcall(MAWWW_ScanHooks) end end)
MAWWW_ScanHooks()

-- =====================================================
-- AUTO HOOK
-- =====================================================
local IsAutoHooking = false

local function MAWWW_AutoHook()
    if not VD.KILLER_AutoHook or GetRole() ~= "Killer" then return end
    if IsAutoHooking then return end
    local root = GetRoot()
    if not root then return end
    local char = LocalPlayer.Character
    local isCarrying = false
    if char then isCarrying = char:GetAttribute("IsCarrying") or char:GetAttribute("isCarrying") end

    if isCarrying then
        local occupiedPositions = {}
        for _, v in ipairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character then
                local isHooked = v.Character:GetAttribute("IsHooked") or v.Character:GetAttribute("isHooked")
                local hrp = v.Character:FindFirstChild("HumanoidRootPart")
                if isHooked and hrp then table.insert(occupiedPositions, hrp.Position) end
            end
        end
        local closestHook, hDist = nil, math.huge
        for _, h in ipairs(MAWWW_Cache.Hooks or {}) do
            if h.part then
                local isOccupied = false
                for _, occPos in ipairs(occupiedPositions) do
                    if (h.part.Position - occPos).Magnitude < 10 then isOccupied = true; break end
                end
                if not isOccupied then
                    local hd = (h.part.Position - root.Position).Magnitude
                    if hd < hDist then hDist = hd; closestHook = h end
                end
            end
        end
        if closestHook then
            IsAutoHooking = true
            task.spawn(function()
                root.CFrame = CFrame.new(closestHook.part.Position + Vector3.new(0, 3, 0))
                task.wait(0.4)
                pcall(function()
                    local carryFolder = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Carry")
                    local event = carryFolder and carryFolder:FindFirstChild("HookEvent")
                    local commit = carryFolder and carryFolder:FindFirstChild("HookCommit")
                    local hookPoint = nil
                    if closestHook.model then hookPoint = closestHook.model:FindFirstChild("HookPoint") or closestHook.model:FindFirstChild("HookHitbox") end
                    if not hookPoint then hookPoint = closestHook.part end
                    if event and event:IsA("RemoteEvent") then event:FireServer(hookPoint) end
                    if commit and commit:IsA("RemoteEvent") then commit:FireServer(hookPoint) end
                end)
                task.wait(0.5)
                IsAutoHooking = false
            end)
        end
        return
    end

    local closestDowned, closestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsSurvivor(player) and player.Character then
            local tr  = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if tr and hum then
                local pct = (hum.MaxHealth > 0) and (hum.Health / hum.MaxHealth) or 0
                if pct <= 0.25 and pct > 0 then
                    local isHooked = false
                    for _, hh in ipairs(MAWWW_Cache.Hooks or {}) do
                        if hh.part and (hh.part.Position - tr.Position).Magnitude < 4.5 then isHooked = true; break end
                    end
                    if not isHooked then
                        local dist = (tr.Position - root.Position).Magnitude
                        if dist < closestDist then closestDist = dist; closestDowned = tr end
                    end
                end
            end
        end
    end
    if closestDowned then
        local occupiedPositions = {}
        for _, v in ipairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character then
                local isHooked = v.Character:GetAttribute("IsHooked") or v.Character:GetAttribute("isHooked")
                local hrp = v.Character:FindFirstChild("HumanoidRootPart")
                if isHooked and hrp then table.insert(occupiedPositions, hrp.Position) end
            end
        end
        local closestHook, hDist = nil, math.huge
        for _, h in ipairs(MAWWW_Cache.Hooks or {}) do
            if h.part then
                local isOccupied = false
                for _, occPos in ipairs(occupiedPositions) do
                    if (h.part.Position - occPos).Magnitude < 10 then isOccupied = true; break end
                end
                if not isOccupied then
                    local hd = (h.part.Position - closestDowned.Position).Magnitude
                    if hd < hDist then hDist = hd; closestHook = h end
                end
            end
        end
        if closestHook then
            IsAutoHooking = true
            task.spawn(function()
                root.CFrame = CFrame.new(closestDowned.Position + Vector3.new(0, 3, 0), closestDowned.Position)
                task.wait(0.3)
                pcall(function()
                    local carryFolder = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Carry")
                    local carryEvent = carryFolder and carryFolder:FindFirstChild("CarrySurvivorEvent")
                    if carryEvent and carryEvent:IsA("RemoteEvent") then carryEvent:FireServer(closestDowned.Parent) end
                end)
                task.wait(0.8)
                local currentCarrying = false
                local myChar = LocalPlayer.Character
                if myChar then currentCarrying = myChar:GetAttribute("IsCarrying") or myChar:GetAttribute("isCarrying") end
                if currentCarrying and root and root.Parent then
                    root.CFrame = CFrame.new(closestHook.part.Position + Vector3.new(0, 3, 0))
                    task.wait(0.4)
                    pcall(function()
                        local carryFolder = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Carry")
                        local event = carryFolder and carryFolder:FindFirstChild("HookEvent")
                        local commit = carryFolder and carryFolder:FindFirstChild("HookCommit")
                        local hookPoint = nil
                        if closestHook.model then hookPoint = closestHook.model:FindFirstChild("HookPoint") or closestHook.model:FindFirstChild("HookHitbox") end
                        if not hookPoint then hookPoint = closestHook.part end
                        if event and event:IsA("RemoteEvent") then event:FireServer(hookPoint) end
                        if commit and commit:IsA("RemoteEvent") then commit:FireServer(hookPoint) end
                    end)
                end
                task.wait(1)
                IsAutoHooking = false
            end)
        end
    end
end

-- =====================================================
-- BYPASS COOLDOWN (Hidden)
-- =====================================================
getgenv().MAWWW_HiddenLeapBypassThread = nil
function MAWWW_StartHiddenCooldownBypass()
    if getgenv().MAWWW_HiddenLeapBypassThread then return end
    getgenv().MAWWW_HiddenLeapBypassThread = task.spawn(function()
        local leapFunction, m2Function
        local function scanGC()
            pcall(function()
                for _, v in pairs(getgc(true)) do
                    if type(v) == "function" and islclosure(v) then
                        local info; pcall(function() info = debug.getinfo(v) end)
                        if info then
                            if info.name == "tryActivate" then leapFunction = v
                            elseif info.name == "playM2Animation" then m2Function = v end
                        end
                    end
                    if leapFunction and m2Function then break end
                end
            end)
        end
        scanGC()
        local lastScan = os.clock()
        while task.wait(0.1) do
            if not VD.KILLER_BypassLeap then break end
            if not (leapFunction and m2Function) then
                local now = os.clock()
                if now - lastScan >= 2 then lastScan = now; scanGC() end
            end
            if leapFunction then
                pcall(function()
                    for i, val in pairs(debug.getupvalues(leapFunction)) do
                        if type(val) == "boolean" and val == true then debug.setupvalue(leapFunction, i, false) end
                    end
                end)
            end
            if m2Function then
                pcall(function()
                    for i, val in pairs(debug.getupvalues(m2Function)) do
                        if type(val) == "boolean" and val == true then debug.setupvalue(m2Function, i, false) end
                    end
                end)
            end
        end
        getgenv().MAWWW_HiddenLeapBypassThread = nil
    end)
end
function MAWWW_StopHiddenCooldownBypass() end

-- =====================================================
-- BYPASS COOLDOWN (Jeff)
-- =====================================================
getgenv().MAWWW_JeffCooldownBypassThread = nil
function MAWWW_StartJeffCooldownBypass()
    if getgenv().MAWWW_JeffCooldownBypassThread then return end
    getgenv().MAWWW_JeffCooldownBypassThread = task.spawn(function()
        while task.wait() do
            if not VD.KILLER_InfFrenzy then break end
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:GetAttribute("Frenzy") ~= true then char:SetAttribute("Frenzy", true) end
            end)
        end
        getgenv().MAWWW_JeffCooldownBypassThread = nil
    end)
end
function MAWWW_StopJeffCooldownBypass()
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:GetAttribute("Frenzy") == true then
            char:SetAttribute("Frenzy", false)
            local killer = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Killers") and ReplicatedStorage.Remotes.Killers:FindFirstChild("Killer")
            if killer then
                local deact = killer:FindFirstChild("Deactivatefromclient")
                if deact then deact:FireServer() end
            end
        end
    end)
end

-- =====================================================
-- BYPASS COOLDOWN (Abyss)
-- =====================================================
getgenv().MAWWW_AbyssCooldownBypassConnection = nil
getgenv().MAWWW_CorruptHandlerFunc = nil
function MAWWW_StartAbyssCooldownBypass()
    if not getgenv().MAWWW_CorruptHandlerFunc then
        for _, v in pairs(getgc(true)) do
            if type(v) == "function" and islclosure(v) then
                local constants = debug.getconstants(v)
                if table.find(constants, "corrupt") and table.find(constants, "Immobile") then
                    getgenv().MAWWW_CorruptHandlerFunc = v
                    break
                end
            end
        end
    end
    if not getgenv().MAWWW_CorruptHandlerFunc then return end
    if getgenv().MAWWW_AbyssCooldownBypassConnection then getgenv().MAWWW_AbyssCooldownBypassConnection:Disconnect() end
    getgenv().MAWWW_AbyssCooldownBypassConnection = RunService.Heartbeat:Connect(function()
        if not VD.KILLER_BypassCooldown then return end
        if getgenv().MAWWW_CorruptHandlerFunc then
            local upvalues = debug.getupvalues(getgenv().MAWWW_CorruptHandlerFunc)
            for idx, val in pairs(upvalues) do
                if type(val) == "boolean" and val == false then
                    debug.setupvalue(getgenv().MAWWW_CorruptHandlerFunc, idx, true)
                end
            end
        end
    end)
end
function MAWWW_StopAbyssCooldownBypass()
    if getgenv().MAWWW_AbyssCooldownBypassConnection then
        getgenv().MAWWW_AbyssCooldownBypassConnection:Disconnect()
        getgenv().MAWWW_AbyssCooldownBypassConnection = nil
    end
end

-- =====================================================
-- BYPASS COOLDOWN (Slasher)
-- =====================================================
getgenv().MAWWW_SlasherCooldownBypassThread = nil
function MAWWW_StartSlasherCooldownBypass()
    if getgenv().MAWWW_SlasherCooldownBypassThread then return end
    pcall(function()
        local b = true
        local mt = debug.getmetatable(b)
        if not mt then mt = {}; debug.setmetatable(b, mt) end
        if setreadonly then setreadonly(mt, false) end
        mt.__div = function() return 0 end
        mt.__mul = function() return 0 end
        mt.__add = function() return 0 end
        mt.__sub = function() return 0 end
        if setreadonly then setreadonly(mt, true) end
    end)
    getgenv().MAWWW_SlasherCooldownBypassThread = task.spawn(function()
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
                        if hasOffset and hasLinear and hasAction and hasTweenInfo and not hasPursuit then toggleFunc = v end
                        if hasPursuit and hasTweenInfo and hasAction and hasWalkSpeed then pursuitHandler = v end
                    end
                    if toggleFunc and pursuitHandler then break end
                end
            end)
        end
        scanGCForSlasher()
        local lastScan = os.clock()
        while task.wait(0.1) do
            if not VD.KILLER_InfLakeMist and not VD.KILLER_InfPursuit then break end
            if not (toggleFunc and pursuitHandler) then
                if os.clock() - lastScan >= 2 then scanGCForSlasher(); lastScan = os.clock() end
            end
            if toggleFunc and VD.KILLER_InfLakeMist then
                pcall(function() debug.setupvalue(toggleFunc, 6, false); debug.setupvalue(toggleFunc, 10, false) end)
            end
            if pursuitHandler and VD.KILLER_InfPursuit then
                pcall(function() debug.setupvalue(pursuitHandler, 5, false); debug.setupvalue(pursuitHandler, 6, false) end)
            end
        end
        getgenv().MAWWW_SlasherCooldownBypassThread = nil
    end)
end
function MAWWW_StopSlasherCooldownBypass()
    pcall(function()
        local jason = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Killers") and ReplicatedStorage.Remotes.Killers:FindFirstChild("Jason")
        if jason then
            if not VD.KILLER_InfLakeMist then local lm = jason:FindFirstChild("LakeMist"); if lm then lm:FireServer(false) end end
            if not VD.KILLER_InfPursuit then local ps = jason:FindFirstChild("Pursuit"); if ps then ps:FireServer(false) end end
        end
    end)
end

-- =====================================================
-- ANTI BLIND (Flashlight)
-- =====================================================
function SetupAntiBlind()
    pcall(function()
        local r  = ReplicatedStorage:FindFirstChild("Remotes")
        local i  = r and r:FindFirstChild("Items")
        local fl = i and i:FindFirstChild("Flashlight")
        local gb = fl and fl:FindFirstChild("GotBlinded")
        if not (gb and gb:IsA("RemoteEvent")) then return end
        local ok, mt = pcall(function() return getrawmetatable(game) end)
        if ok and mt and setreadonly then
            pcall(function()
                setreadonly(mt, false)
                local old = mt.__namecall
                local _genv = getgenv()
                mt.__namecall = newcclosure(function(self, ...)
                    if not checkcaller() and _genv.VD and _genv.VD.KILLER_AntiBlind and self == gb then
                        local method = getnamecallmethod()
                        if method == "FireServer" and GetRole() == "Killer" then return nil end
                    end
                    return old(self, ...)
                end)
                setreadonly(mt, true)
            end)
        end
    end)
end
pcall(SetupAntiBlind)

-- =====================================================
-- BEAT GAME KILLER (Auto Kill All)
-- =====================================================
local function MAWWW_BeatGameKiller()
    if not VD.BEAT_Killer then VD._KillerTarget = nil; return end
    if GetRole() ~= "Killer" then VD._KillerTarget = nil; return end
    local root = GetRoot()
    if not root then return end

    local target        = VD._KillerTarget
    local needNewTarget = true
    if target and target.Character then
        local tr = target.Character:FindFirstChild("HumanoidRootPart")
        local th = target.Character:FindFirstChildOfClass("Humanoid")
        if tr and th and th.MaxHealth > 0 and (th.Health / th.MaxHealth) > 0.25 then
            needNewTarget = false
        else
            VD._KillerTarget = nil
        end
    end

    if needNewTarget then
        local survivors = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and IsSurvivor(player) and player.Character then
                local pr = player.Character:FindFirstChild("HumanoidRootPart")
                local ph = player.Character:FindFirstChildOfClass("Humanoid")
                if pr and ph and ph.MaxHealth > 0 and (ph.Health / ph.MaxHealth) > 0.25 then table.insert(survivors, player) end
            end
        end
        if #survivors > 0 then
            local closest, closestDist = nil, math.huge
            for _, player in ipairs(survivors) do
                local pr   = player.Character:FindFirstChild("HumanoidRootPart")
                local dist = (pr.Position - root.Position).Magnitude
                if dist < closestDist then closestDist = dist; closest = player end
            end
            VD._KillerTarget = closest
            target           = closest
        else
            VD._KillerTarget = nil; return
        end
    end

    if not target or not target.Character then return end
    local tr = target.Character:FindFirstChild("HumanoidRootPart")
    local th = target.Character:FindFirstChildOfClass("Humanoid")
    if not tr or not th then VD._KillerTarget = nil; return end
    if th.MaxHealth <= 0 or (th.Health / th.MaxHealth) <= 0.25 then VD._KillerTarget = nil; return end

    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then pcall(function() part.CanCollide = false end) end
    end

    local dir = (root.Position - tr.Position).Unit
    if dir.Magnitude ~= dir.Magnitude then dir = Vector3.new(1, 0, 0) end
    root.CFrame = CFrame.new(tr.Position + dir * 3 + Vector3.new(0, 1, 0), tr.Position)

    pcall(function()
        local r  = ReplicatedStorage:FindFirstChild("Remotes")
        local a  = r and r:FindFirstChild("Attacks")
        local ba = a and a:FindFirstChild("BasicAttack")
        if ba then ba:FireServer(false) end
    end)
end

-- =====================================================
-- KILLER FAKE ATTACK (COUNTER AUTO PARRY)
-- =====================================================
getgenv().MAWWW_FakeAttackThread = nil
function MAWWW_ToggleFakeAttack(enabled)
    if not enabled then
        if getgenv().MAWWW_FakeAttackThread then
            task.cancel(getgenv().MAWWW_FakeAttackThread)
            getgenv().MAWWW_FakeAttackThread = nil
        end
        return
    end
    if getgenv().MAWWW_FakeAttackThread then return end
    getgenv().MAWWW_FakeAttackThread = task.spawn(function()
        while VD.KILLER_FakeAttack do
            local char = LocalPlayer.Character
            if char then
                local Animator = char:FindFirstChild("Humanoid") and char.Humanoid:FindFirstChild("Animator")
                if Animator then
                    local myRoot = char:FindFirstChild("HumanoidRootPart")
                    local near = false
                    if myRoot then
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and p.Team and p.Team.Name == "Survivors" then
                                local r = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                                if r and (myRoot.Position - r.Position).Magnitude <= 15 then near = true; break end
                            end
                        end
                    end
                    if near then
                        pcall(function()
                            local bait = Instance.new("Animation")
                            bait.AnimationId = "rbxassetid://117042998468241"
                            local track = Animator:LoadAnimation(bait)
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
        getgenv().MAWWW_FakeAttackThread = nil
    end)
end

-- =====================================================
-- SELF HEAL FLOATING BUTTON
-- =====================================================
function SelfHeal_UpdateButton()
    if not SelfHealButton.Button then return end
    if InstantHealSelf then
        SelfHealButton.Button.BackgroundColor3 = Color3.fromRGB(15,15,15)
        SelfHealButton.Button.TextColor3 = Color3.fromRGB(255,0,0)
        SelfHealButton.Stroke.Color = Color3.fromRGB(255,0,0)
    else
        SelfHealButton.Button.BackgroundColor3 = Color3.fromRGB(15,15,15)
        SelfHealButton.Button.TextColor3 = Color3.fromRGB(25,25,25)
        SelfHealButton.Stroke.Color = Color3.fromRGB(25,25,25)
    end
end

function SelfHeal_DestroyButton()
    if SelfHealButton.UI then pcall(function() SelfHealButton.UI:Destroy() end) end
    SelfHealButton.UI=nil SelfHealButton.Button=nil SelfHealButton.Stroke=nil SelfHealButton.Dragging=false
end

function SelfHeal_CreateButton()
    local pg=LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui",10)
    if not pg then return end
    SelfHeal_DestroyButton()
    local gui=Instance.new("ScreenGui")
    gui.Name="SelfHealFloatingUI" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true
    gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling gui.DisplayOrder=999998 gui.Parent=pg
    SelfHealButton.UI=gui
    local btn=Instance.new("TextButton")
    btn.Name="SelfHealButton" btn.Size=UDim2.fromOffset(65,65)
    btn.Position=UDim2.new(0.78,0,0.75,0) btn.AnchorPoint=Vector2.new(0.5,0.5)
    btn.BackgroundColor3=Color3.fromRGB(25,25,25) btn.BackgroundTransparency=0.12
    btn.AutoButtonColor=false btn.Text="♥\nSELF\nHEAL"
    btn.TextColor3=Color3.fromRGB(15,15,15) btn.TextSize=11 btn.Font=Enum.Font.GothamBold
    btn.ZIndex=10 btn.Parent=gui
    Instance.new("UICorner",btn).CornerRadius=UDim.new(1,0)
    local stroke=Instance.new("UIStroke")
    stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border stroke.Thickness=2
    stroke.Transparency=0.05 stroke.Color=Color3.fromRGB(15,15,15) stroke.Parent=btn
    SelfHealButton.Button=btn SelfHealButton.Stroke=stroke SelfHeal_UpdateButton()

    btn.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            if SelfHealButtonDragLocked then return end
            SelfHealButton.Dragging=true SelfHealButton.DragStart=input.Position SelfHealButton.DragStartPos=btn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if SelfHealButton.Dragging and not SelfHealButtonDragLocked and
           (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            local d=input.Position-SelfHealButton.DragStart
            btn.Position=UDim2.new(SelfHealButton.DragStartPos.X.Scale,SelfHealButton.DragStartPos.X.Offset+d.X,
                                   SelfHealButton.DragStartPos.Y.Scale,SelfHealButton.DragStartPos.Y.Offset+d.Y)
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            SelfHealButton.Dragging=false
        end
    end)
    btn.MouseButton1Click:Connect(function()
        setInstantHealSelf(not InstantHealSelf)
        SelfHeal_UpdateButton()
    end)
end

function SelfHeal_SetDragLocked(v)
    SelfHealButtonDragLocked=v and true or false
    SelfHealButton.Dragging=false
end

-- =====================================================
-- HEAL LOGIC
-- =====================================================
function doSelfHeal()
	local char = LocalPlayer.Character
	if not char then return end
	local skillCheckRemote = ReplicatedStorage.Remotes.Healing.SkillCheckResultEvent
	pcall(function() skillCheckRemote:FireServer("success", 100, char) end)
end

function doSelfHealTrue()
	local char = LocalPlayer.Character
	if not char then return end
	local healRemote = ReplicatedStorage.Remotes.Healing.HealEvent
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	pcall(function() healRemote:FireServer(hrp, true) end)
end

function doSelfHealFalse()
	local char = LocalPlayer.Character
	if not char then return end
	local healRemote = ReplicatedStorage.Remotes.Healing.HealEvent
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	pcall(function() healRemote:FireServer(hrp, false) end)
end

function doOthersHealTrue(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then return end
	local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not targetHRP then return end
	local healRemote = ReplicatedStorage.Remotes.Healing.HealEvent
	pcall(function() healRemote:FireServer(targetHRP, true) end)
end

function doOthersHealFalse(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then return end
	local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not targetHRP then return end
	local healRemote = ReplicatedStorage.Remotes.Healing.HealEvent
	pcall(function() healRemote:FireServer(targetHRP, false) end)
end

function setInstantHealSelf(v)
    InstantHealSelf = v
    if v then
        local healActive = false
        if InstantHealConnection then InstantHealConnection:Disconnect() end
        InstantHealConnection = RunService.Heartbeat:Connect(function(dt)
            if not InstantHealSelf then return end
            local myChar = LocalPlayer.Character
            local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
            if not myHum then return end
            if myHum.Health >= myHum.MaxHealth * 0.9 then 
                if healActive then healActive = false; doSelfHealFalse() end
                return 
            end
            if healActive then
                local checkScript = myChar:FindFirstChild("CheckInterractable")
                if checkScript and not checkScript:GetAttribute("isHealing") then healActive = false end
            end
            if not healActive then healActive = true; doSelfHealTrue() end
        end)
    else
        if InstantHealConnection then InstantHealConnection:Disconnect(); InstantHealConnection = nil end
        pcall(doSelfHealFalse)
    end
end

function setAutoHealAll(v)
    AutoHealAll = v
    if v then
        local activeHeals = {}
        if AutoHealAllConnection then AutoHealAllConnection:Disconnect() end
        AutoHealAllConnection = RunService.Heartbeat:Connect(function(dt)
            if not AutoHealAll then return end
            for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					local hrp = player.Character:FindFirstChild("HumanoidRootPart")
					local hum = player.Character:FindFirstChildOfClass("Humanoid")
					if hum and hum.Health > 0 and hum.Health < hum.MaxHealth * 0.9 and hrp then
						if activeHeals[player] then
							local myChar = LocalPlayer.Character
							local checkScript = myChar and myChar:FindFirstChild("CheckInterractable")
							if checkScript and not checkScript:GetAttribute("isHealing") then activeHeals[player] = nil end
						end
						if not activeHeals[player] then activeHeals[player] = true; doOthersHealTrue(player) end
					else
						if activeHeals[player] then activeHeals[player] = nil; doOthersHealFalse(player) end
					end
				else
					if activeHeals[player] then activeHeals[player] = nil; pcall(function() doOthersHealFalse(player) end) end
				end
			end
        end)
    else
        if AutoHealAllConnection then AutoHealAllConnection:Disconnect(); AutoHealAllConnection = nil end
    end
end

-- =====================================================
-- FAKE PERKS (CLIENT-SIDE)
-- =====================================================
local function FP_Char() return LocalPlayer.Character end
local function FP_Hum() local c = FP_Char(); return c and c:FindFirstChildOfClass("Humanoid") end

local function FP_GetTotalSpeedBuff()
    local total = 0
    for name, b in pairs(FP.ActiveBuffs) do
        if tick() < b.endTime then total = total + b.amt end
    end
    return total
end

local function FP_ApplySpeedToCharacter()
    local char = FP_Char()
    local hum = FP_Hum()
    local totalBuff = FP_GetTotalSpeedBuff()
    if char then
        if totalBuff > 0 then char:SetAttribute("speedboost", 1 + (totalBuff / 14))
        else char:SetAttribute("speedboost", 1) end
    end
    if hum and totalBuff > 0 then hum.WalkSpeed = 16 + totalBuff end
end

local function FP_EnsureHB()
    if FP.HB then return end
    FP.HB = RunService.Heartbeat:Connect(function()
        local expired = {}
        for name, b in pairs(FP.ActiveBuffs) do
            if tick() >= b.endTime then table.insert(expired, name) end
        end
        for _, name in ipairs(expired) do FP.ActiveBuffs[name] = nil end
        if #expired > 0 and FP_GetTotalSpeedBuff() <= 0 then FP.LastBuffEnd = tick() end
        FP_ApplySpeedToCharacter()
        if FP_GetTotalSpeedBuff() <= 0 and next(FP.ActiveBuffs) == nil then
            if FP.HB then FP.HB:Disconnect(); FP.HB = nil end
            local char = FP_Char()
            if char then char:SetAttribute("speedboost", 1) end
        end
    end)
end

local function FP_TryBuff(name, amt, dur)
    if FP.ActiveBuffs[name] then return end
    if tick() - FP.LastBuffEnd < FP.CooldownTime and next(FP.ActiveBuffs) == nil then return end
    FP.ActiveBuffs[name] = { amt = amt, endTime = tick() + dur }
    FP_ApplySpeedToCharacter()
    FP_EnsureHB()
    VD_Notify("Fake Perks", "[" .. name .. "] Aktif! +" .. amt .. " Speed (" .. dur .. "s)", 3)
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

-- =====================================================
-- FAKE PERKS - FLOWSTATE
-- =====================================================
local function FP_SetupFlowstate(val)
    FP.FlowstateOn = val
    local char = FP_Char()
    if char then char:SetAttribute("Flowstate", val) end
    if val then
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        local w = r and r:FindFirstChild("Window")
        local p = r and r:FindFirstChild("Pallet")
        local function onVaultAction()
            if not FP.FlowstateOn then return end
            task.delay(0.5, function() if FP.FlowstateOn then FP_TryBuff("Flowstate", 5, 3) end end)
        end
        if w then
            local vb = w:FindFirstChild("Vaultbindable")
            if vb and vb:IsA("BindableEvent") then FP_Reg("Flowstate", vb.Event:Connect(onVaultAction)) end
        end
        if p then
            local sb = p:FindFirstChild("Slidebindable")
            if sb and sb:IsA("BindableEvent") then FP_Reg("Flowstate", sb.Event:Connect(onVaultAction)) end
        end
        local function hookChar(c)
            if not c then return end
            local conn = c:GetAttributeChangedSignal("__VaultFireCount"):Connect(function()
                if FP.FlowstateOn then onVaultAction() end
            end)
            FP_Reg("Flowstate", conn)
        end
        hookChar(LocalPlayer.Character)
        FP_Reg("Flowstate", LocalPlayer.CharacterAdded:Connect(function(c)
            if FP.FlowstateOn then c:SetAttribute("Flowstate", true); hookChar(c) end
        end))
        VD_Notify("Fake Perks", "Flowstate ON - +5 speed 3s setelah vault/slide", 4)
    else
        FP_Clean("Flowstate")
        FP.ActiveBuffs["Flowstate"] = nil
        local c = FP_Char()
        if c then c:SetAttribute("Flowstate", false) end
        VD_Notify("Fake Perks", "Flowstate OFF", 3)
    end
end

-- =====================================================
-- FAKE PERKS - QUICK RECOVERY
-- =====================================================
local function FP_SetupQuickRecovery(val)
    FP.QuickRecOn = val
    if val then
        local function onHealed()
            if not FP.QuickRecOn then return end
            FP_TryBuff("QuickRecovery", 6, 3)
        end
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        local healFolder = r and r:FindFirstChild("Healing")
        if healFolder then
            local hd = healFolder:FindFirstChild("Healdone")
            if hd and hd:IsA("BindableEvent") then FP_Reg("QuickRecovery", hd.Event:Connect(onHealed)) end
        end
        local function hookHealth(c)
            if not c then return end
            local hum = c:FindFirstChildOfClass("Humanoid")
            if hum then
                local lastHP = hum.Health
                local conn = hum.HealthChanged:Connect(function(newHP)
                    if not FP.QuickRecOn then return end
                    if newHP > lastHP and (newHP >= hum.MaxHealth or (newHP - lastHP) >= 15) then onHealed() end
                    lastHP = newHP
                end)
                FP_Reg("QuickRecovery", conn)
            end
        end
        hookHealth(LocalPlayer.Character)
        FP_Reg("QuickRecovery", LocalPlayer.CharacterAdded:Connect(hookHealth))
        VD_Notify("Fake Perks", "Quick Recovery ON - +6 speed 3s setelah di-heal", 4)
    else
        FP_Clean("QuickRecovery")
        FP.ActiveBuffs["QuickRecovery"] = nil
        VD_Notify("Fake Perks", "Quick Recovery OFF", 3)
    end
end

-- =====================================================
-- FAKE PERKS - PERFECT LANDING
-- =====================================================
local function FP_SetupPerfectLanding(val)
    FP.PerfLandOn = val
    if val then
        local function hookFall(c)
            if not c then return end
            local hum = c:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local wasFalling = false
            local fallStart = 0
            local conn = hum.StateChanged:Connect(function(old, new)
                if not FP.PerfLandOn then return end
                if new == Enum.HumanoidStateType.Freefall then wasFalling = true; fallStart = tick() end
                if wasFalling and (new == Enum.HumanoidStateType.Landed or new == Enum.HumanoidStateType.Running) then
                    local fallTime = tick() - fallStart
                    wasFalling = false
                    if fallTime >= 0.25 then FP_TryBuff("PerfectLanding", 8, 3) end
                end
            end)
            FP_Reg("PerfectLanding", conn)
        end
        hookFall(LocalPlayer.Character)
        FP_Reg("PerfectLanding", LocalPlayer.CharacterAdded:Connect(hookFall))
        VD_Notify("Fake Perks", "Perfect Landing ON - +8 speed 3s setelah landing", 4)
    else
        FP_Clean("PerfectLanding")
        FP.ActiveBuffs["PerfectLanding"] = nil
        VD_Notify("Fake Perks", "Perfect Landing OFF", 3)
    end
end

-- =====================================================
-- FAKE PERKS - ADRENALINE RUSH
-- =====================================================
local function FP_SetupAdrenalineRush(val)
    FP.AdrenalineOn = val
    if val then
        local function hookDamage(c)
            if not c then return end
            local hum = c:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local lastHP = hum.Health
            local conn = hum.HealthChanged:Connect(function(newHP)
                if not FP.AdrenalineOn then return end
                if newHP < lastHP and newHP <= 50 and newHP > 0 then FP_TryBuff("AdrenalineRush", 4, 5) end
                lastHP = newHP
            end)
            FP_Reg("AdrenalineRush", conn)
        end
        hookDamage(LocalPlayer.Character)
        FP_Reg("AdrenalineRush", LocalPlayer.CharacterAdded:Connect(hookDamage))
        VD_Notify("Fake Perks", "Adrenaline Rush ON - +4 speed 5s saat HP drop 50", 4)
    else
        FP_Clean("AdrenalineRush")
        FP.ActiveBuffs["AdrenalineRush"] = nil
        VD_Notify("Fake Perks", "Adrenaline Rush OFF", 3)
    end
end

-- =====================================================
-- FIRST PERSON CAMERA (Survivor)
-- =====================================================
getgenv().MAWWW_fpWasSet = false
getgenv().MAWWW_fpOriginal = nil

function RestoreFirstPersonCamera()
    if not getgenv().MAWWW_fpWasSet then return end
    getgenv().MAWWW_fpWasSet = false
    pcall(function()
        if getgenv().MAWWW_fpOriginal then
            LocalPlayer.CameraMode = getgenv().MAWWW_fpOriginal.CameraMode or Enum.CameraMode.Classic
            LocalPlayer.CameraMaxZoomDistance = getgenv().MAWWW_fpOriginal.CameraMaxZoomDistance or 128
            LocalPlayer.CameraMinZoomDistance = getgenv().MAWWW_fpOriginal.CameraMinZoomDistance or 0.5
        else
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            LocalPlayer.CameraMaxZoomDistance = 128
        end
    end)
    local char = LocalPlayer.Character
    if char then
        local head = char:FindFirstChild("Head")
        if head then head.LocalTransparencyModifier = 0 end
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Accessory") then
                local handle = obj:FindFirstChild("Handle")
                if handle then handle.LocalTransparencyModifier = 0 end
            end
        end
    end
    getgenv().MAWWW_fpOriginal = nil
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        if VD.SURV_FirstPerson then
            local isSurvivor = LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors"
            if isSurvivor then
                if not getgenv().MAWWW_fpWasSet then
                    getgenv().MAWWW_fpOriginal = {
                        CameraMode = LocalPlayer.CameraMode,
                        CameraMaxZoomDistance = LocalPlayer.CameraMaxZoomDistance,
                        CameraMinZoomDistance = LocalPlayer.CameraMinZoomDistance,
                    }
                end
                if LocalPlayer.CameraMode ~= Enum.CameraMode.LockFirstPerson then LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson end
                if LocalPlayer.CameraMaxZoomDistance ~= 0 then LocalPlayer.CameraMaxZoomDistance = 0 end
                local char = LocalPlayer.Character
                if char then
                    local head = char:FindFirstChild("Head")
                    if head then head.LocalTransparencyModifier = 1 end
                    for _, obj in ipairs(char:GetChildren()) do
                        if obj:IsA("Accessory") then
                            local handle = obj:FindFirstChild("Handle")
                            if handle then handle.LocalTransparencyModifier = 1 end
                        end
                    end
                end
                getgenv().MAWWW_fpWasSet = true
            elseif getgenv().MAWWW_fpWasSet then RestoreFirstPersonCamera() end
        elseif getgenv().MAWWW_fpWasSet then RestoreFirstPersonCamera() end
    end)
end)

-- =====================================================
-- AUTO DROP PALLET
-- =====================================================
local function HandleAutoPallet()
    if not Auto.PalletDrop then return end
    local plr = Players.LocalPlayer
    if not (plr.Team and plr.Team.Name == "Survivors") then return end
    local now = tick()
    if now - Timers.lastPalletScan < 0.2 then return end
    Timers.lastPalletScan = now
    if now - Timers.lastPalletDrop < 2.5 then return end
    local root = GetRoot()
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
        if d < bestDist then bestDist = d; bestPallet = pal end
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

-- =====================================================
-- AUTO FLEE
-- =====================================================
task.spawn(function()
    while task.wait(0.2) do
        if not Auto.Flee then continue end
        local root = GetRoot()
        if not root then continue end
        local killerRoot, distance = GetNearestKiller()
        if killerRoot and distance <= Auto.FleeDist and tick() - State.LastFlee > Auto.FleeCooldown then
            local point = GetFarthestGeneratorPoint(killerRoot)
            if point then
                State.LastFlee = tick()
                root.CFrame = point.CFrame + Vector3.new(0, 5, 0)
            end
        end
    end
end)

-- =====================================================
-- GEN BOOST BYPASS
-- =====================================================
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
            local isReal = v:GetAttribute("RepairProgress") ~= nil or v:GetAttribute("kickcount") ~= nil or v:GetAttribute("ProgressRepair") ~= nil
            if isReal then table.insert(GenBypass.Cache, v) end
        end
    end)
    return GenBypass.Cache
end

function GB_GetPoints(genModel)
    local points = {}
    pcall(function()
        for _, obj in pairs(genModel:GetChildren()) do
            if obj.Name:find("GeneratorPoint") and obj:IsA("BasePart") then table.insert(points, obj) end
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
    local RepairEvent = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Generator") and ReplicatedStorage.Remotes.Generator:FindFirstChild("RepairEvent")
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
        if hrp and hrp.Parent then hrp.Anchored = false; hrp.CFrame = originalCFrame end
    end)
    task.wait(0.1)
    pcall(function() if RepairEvent then RepairEvent:FireServer(targetPoint, false) end end)
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
    local ok, frame = pcall(function() return LocalPlayer.PlayerGui.pcprompts.Frame.GeneratorRepair end)
    return ok and frame and frame.Visible
end

function GB_UpdateButton()
    if GenBypass.Button then GenBypass.Button.Visible = GenBypass.Enabled and isMobile end
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
    GenBypass.Button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    GenBypass.Button.BackgroundTransparency = 0
    GenBypass.Button.AutoButtonColor = true
    GenBypass.Button.Visible = false
    GenBypass.Button.ZIndex = 10
    GenBypass.Button.Parent = GenBypass.UI
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = GenBypass.Button
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 0, 0)
    stroke.Thickness = 2
    stroke.Transparency = 0.2
    stroke.Parent = GenBypass.Button
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "GEN"
    lbl.TextColor3 = Color3.fromRGB(255, 0, 0)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBlack
    lbl.ZIndex = 11
    lbl.Parent = GenBypass.Button
    GenBypass.Button.MouseButton1Click:Connect(function()
        if not GenBypass.Enabled then return end
        local bestPoint, bestDist = GB_GetNearestPoint()
        if bestPoint and bestDist <= GenBypass.TriggerRange then GB_DoRepair(bestPoint) end
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
        if not bestPoint or bestDist > GenBypass.TriggerRange then return end
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
    if not bestPoint or bestDist > GenBypass.TriggerRange then return end
    if GenBypass.Processed[bestPoint.Parent] then return end
    GB_DoRepair(bestPoint)
end)

task.spawn(function()
    while true do
        task.wait(2)
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for genModel in pairs(GenBypass.Processed) do
                if not genModel or not genModel.Parent then GenBypass.Processed[genModel] = nil; continue end
                local nearAny = false
                for _, point in pairs(GB_GetPoints(genModel)) do
                    if point.Parent and (hrp.Position - point.Position).Magnitude <= 10 then nearAny = true; break end
                end
                if not nearAny then GenBypass.Processed[genModel] = nil end
            end
        end
    end
end)

local function setGenBypass(v)
    GenBypass.Enabled = v
    GB_UpdateButton()
end

-- =====================================================
-- SILENT AIM: TWIST OF FATE
-- =====================================================
local ToFState = {
    Connection = nil, LaserBeam = nil, TargetGui = nil, InputBegan = nil, InputEnded = nil,
    TouchInput = nil, IsAiming = false, SavedUIPos = UDim2.new(0.5, -120, 0, 110), SCPCache = {}, SCPCacheTimer = 0,
}

local ToFKeyCodes = { None = nil, Q = Enum.KeyCode.Q, E = Enum.KeyCode.E, R = Enum.KeyCode.R, T = Enum.KeyCode.T, F = Enum.KeyCode.F, G = Enum.KeyCode.G, H = Enum.KeyCode.H, J = Enum.KeyCode.J, K = Enum.KeyCode.K, L = Enum.KeyCode.L, X = Enum.KeyCode.X, Z = Enum.KeyCode.Z }

local function ToF_IsDowned(char)
    if not char then return true end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return true end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then return true end
    if char:GetAttribute("Knocked") == true then return true end
    if char:GetAttribute("IsHooked") == true then return true end
    if char:GetAttribute("IsCarried") == true then return true end
    if char:GetAttribute("Downed") == true then return true end
    if char:GetAttribute("IsDown") == true then return true end
    local state = char:GetAttribute("State")
    if state == "Downed" or state == "Dead" or state == "Hooked" then return true end
    return false
end

local function ToF_IsBlocked()
    if VD.TOF_BlockKnocked == false then return false end
    local char = LocalPlayer.Character
    if not char then return true end
    return ToF_IsDowned(char)
end

local function ToF_GetEvent()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local items = remotes and remotes:FindFirstChild("Items")
    local tof = items and items:FindFirstChild("Twist of Fate")
    local fire = tof and tof:FindFirstChild("Fire")
    if fire and fire:IsA("RemoteEvent") then return fire end
    return nil
end

local function ToF_GetGunObject()
    local char = LocalPlayer.Character
    if not char then return nil end
    local baseToF = char:FindFirstChild("Twist of Fate", true)
    if not baseToF then return nil end
    local rightArm = baseToF:FindFirstChild("Right Arm")
    if rightArm then
        local gunPart = rightArm:FindFirstChild("gun")
        if gunPart then return gunPart end
        local emperorGun = rightArm:FindFirstChild("EmperorGun")
        if emperorGun then return emperorGun end
    end
    return baseToF
end

local function ToF_IsTargetVisible(originPos, targetPos, targetCharacter)
    local direction = targetPos - originPos
    local distance = direction.Magnitude
    if distance < 0.1 then return true end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local excludeList = {}
    local localChar = LocalPlayer.Character
    if localChar then table.insert(excludeList, localChar) end
    if targetCharacter and targetCharacter ~= localChar then table.insert(excludeList, targetCharacter) end
    if ToFState.LaserBeam then table.insert(excludeList, ToFState.LaserBeam) end
    rayParams.FilterDescendantsInstances = excludeList
    local result = workspace:Raycast(originPos, direction.Unit * distance, rayParams)
    return result == nil
end

local function ToF_GetSCPs()
    if tick() - ToFState.SCPCacheTimer < 0.5 then return ToFState.SCPCache end
    local newTargets = {}
    local mapFolder = workspace:FindFirstChild("Map")
    if mapFolder then
        for _, container in pairs(mapFolder:GetDescendants()) do
            if container:IsA("Model") then
                local attributes = container:GetAttributes()
                if container:GetAttribute("CorpseCreated0492") or next(attributes) ~= nil then
                    local root = container:FindFirstChild("HumanoidRootPart")
                    if root then table.insert(newTargets, root) end
                end
            end
        end
    end
    ToFState.SCPCache = newTargets
    ToFState.SCPCacheTimer = tick()
    return ToFState.SCPCache
end

local function ToF_GetTargetPosition()
    local gunObj = ToF_GetGunObject()
    local char = LocalPlayer.Character
    if not (gunObj and char) then return nil, nil, nil, nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil, nil, nil end
    local myPos = hrp.Position
    local originPos
    if char:GetAttribute("IsCarried") then originPos = hrp.Position + (hrp.CFrame.LookVector * 2)
    else
        pcall(function()
            originPos = gunObj:IsA("BasePart") and gunObj.Position or (gunObj:FindFirstChildOfClass("BasePart") and gunObj:FindFirstChildOfClass("BasePart").Position)
        end)
        originPos = originPos or Vector3.new(myPos.X, myPos.Y + 1.5, myPos.Z)
    end
    local function predictTarget(torso, targetCharacter)
        local targetPos = torso.Position
        if VD.TOF_WallCheck and not ToF_IsTargetVisible(originPos, targetPos, targetCharacter) then return nil, nil, nil, nil end
        local targetVel = Vector3.new(0, 0, 0)
        local rootPart = targetCharacter and (targetCharacter:FindFirstChild("HumanoidRootPart") or torso)
        if rootPart then targetVel = rootPart.Velocity end
        local directionRaw = targetPos - originPos
        local distance = directionRaw.Magnitude
        if distance < 0.1 then return nil, nil, nil, nil end
        if distance < 5 then return directionRaw.Unit, gunObj, originPos, targetPos end
        local travelTime = distance / 400
        local predictedPos = targetPos + (targetVel * travelTime)
        for _ = 1, 2 do
            local newDist = (predictedPos - originPos).Magnitude
            travelTime = newDist / 400
            predictedPos = targetPos + (targetVel * travelTime)
        end
        local finalDirection = predictedPos - originPos
        if finalDirection.Magnitude < 0.1 then return nil, nil, nil, nil end
        return finalDirection.Unit, gunObj, originPos, predictedPos
    end
    local targetMode = VD.TOF_TargetMode or "Killer"
    if targetMode == "Killer" then
        local closestTorso, closestChar, shortestDist = nil, nil, math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Team and player.Team.Name == "Killer" and player.Character then
                local torso = player.Character:FindFirstChild("Torso") or player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("HumanoidRootPart")
                if torso then
                    local dist = (myPos - torso.Position).Magnitude
                    if dist < shortestDist then shortestDist = dist; closestTorso = torso; closestChar = player.Character end
                end
            end
        end
        if not closestTorso then return nil, nil, nil, nil end
        return predictTarget(closestTorso, closestChar)
    elseif targetMode == "Survivors" then
        local bestTorso, bestChar, bestDot = nil, nil, -math.huge
        local cam = workspace.CurrentCamera
        local camLook = cam.CFrame.LookVector
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Team and player.Team.Name == "Survivors" and player.Character then
                local torso = player.Character:FindFirstChild("Torso") or player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("HumanoidRootPart")
                if torso then
                    local dirToTarget = torso.Position - cam.CFrame.Position
                    if dirToTarget.Magnitude > 0.1 then
                        local dot = camLook:Dot(dirToTarget.Unit)
                        if dot > 0.5 and dot > bestDot then bestDot = dot; bestTorso = torso; bestChar = player.Character end
                    end
                end
            end
        end
        if not bestTorso then return nil, nil, nil, nil end
        return predictTarget(bestTorso, bestChar)
    elseif targetMode == "Zombie" then
        local bestPart, bestDot = nil, -math.huge
        local cam = workspace.CurrentCamera
        local camLook = cam.CFrame.LookVector
        for _, root in ipairs(ToF_GetSCPs()) do
            if root and root.Parent then
                local dirToTarget = root.Position - cam.CFrame.Position
                if dirToTarget.Magnitude > 0.1 then
                    local dot = camLook:Dot(dirToTarget.Unit)
                    if dot > 0.5 and dot > bestDot then bestDot = dot; bestPart = root end
                end
            end
        end
        if not bestPart then return nil, nil, nil, nil end
        return predictTarget(bestPart, bestPart.Parent)
    end
    return nil, nil, nil, nil
end

local function ToF_UpdateLaser(originPos, targetPos)
    if not ToFState.LaserBeam then
        local laser = Instance.new("Part")
        laser.Name = "ToFLaser"
        laser.Anchored = true
        laser.CanCollide = false
        laser.CanTouch = false
        laser.CastShadow = false
        laser.Material = Enum.Material.Neon
        laser.Color = Color3.fromRGB(255, 0, 0)
        laser.Parent = workspace
        ToFState.LaserBeam = laser
    end
    local dist = (targetPos - originPos).Magnitude
    ToFState.LaserBeam.Size = Vector3.new(0.05, 0.05, dist)
    ToFState.LaserBeam.CFrame = CFrame.new((originPos + targetPos) / 2, targetPos)
    ToFState.LaserBeam.Transparency = 0
end

local function ToF_ClearLaser()
    if ToFState.LaserBeam then
        pcall(function() ToFState.LaserBeam:Destroy() end)
        ToFState.LaserBeam = nil
    end
end

local function ToF_GetMobileShootButton()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local survivorMob = playerGui and playerGui:FindFirstChild("Survivor-mob")
    local controls = survivorMob and survivorMob:FindFirstChild("Controls")
    local guiMob = controls and controls:FindFirstChild("Gui-mob")
    if not guiMob then return nil end
    local directNames = { "attack", "Attack", "shoot", "Shoot", "fire", "Fire" }
    for _, name in ipairs(directNames) do
        local btn = guiMob:FindFirstChild(name, true)
        if btn and btn:IsA("GuiObject") then return btn end
    end
    for _, obj in ipairs(guiMob:GetDescendants()) do
        if obj:IsA("GuiButton") and obj.Visible then return obj end
    end
    return guiMob:IsA("GuiObject") and guiMob or nil
end

local function ToF_IsTouchOnShootButton(input)
    local shootButton = ToF_GetMobileShootButton()
    if not (shootButton and shootButton.Visible) then return false end
    local pos = input.Position
    local absPos = shootButton.AbsolutePosition
    local absSize = shootButton.AbsoluteSize
    return pos.X >= absPos.X and pos.X <= absPos.X + absSize.X and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y
end

local function ToF_DoShoot()
    if not VD.TOF_SilentAim then return end
    if ToF_IsBlocked() then return end
    local targetDirection, gunObject, originPos, targetPos = ToF_GetTargetPosition()
    if not (targetDirection and gunObject and targetPos and originPos) then return end
    local tofEvent = ToF_GetEvent()
    if not tofEvent then return end
    local freshDirection = targetPos - originPos
    if freshDirection.Magnitude < 0.1 then return end
    pcall(function() tofEvent:FireServer(gunObject, freshDirection.Unit) end)
end

local ToF_ModeButtons = {}
local function ToF_RefreshTargetButtons()
    local modes = {
        Killer = { Color3.fromRGB(35, 35, 35), Color3.fromRGB(255, 0, 0) },
        Survivors = { Color3.fromRGB(35, 35, 35), Color3.fromRGB(0, 255, 255) },
        Zombie = { Color3.fromRGB(35, 35, 35), Color3.fromRGB(0, 255, 0) },
    }
    for modeName, btn in pairs(ToF_ModeButtons) do
        if btn and btn.Parent then
            local active = modeName == (VD.TOF_TargetMode or "Killer")
            local colors = modes[modeName]
            btn.BackgroundColor3 = active and colors[1] or Color3.fromRGB(30, 32, 40)
            btn.TextColor3 = active and colors[2] or Color3.fromRGB(155, 160, 175)
        end
    end
end

local function ToF_SetTargetMode(modeName, notify)
    if modeName ~= "Killer" and modeName ~= "Survivors" and modeName ~= "Zombie" then return end
    VD.TOF_TargetMode = modeName
    ToF_RefreshTargetButtons()
    if notify then VD_Notify("Target Mode", modeName, 1) end
end

local function ToF_CreateTargetSelectorUI()
    local parent = GetSafeGuiParent()
    if not parent then return end
    if ToFState.TargetGui and ToFState.TargetGui.Parent then return end
    local old = parent:FindFirstChild("ToFTargetSelector")
    if old then pcall(function() old:Destroy() end) end
    local gui = Instance.new("ScreenGui")
    gui.Name = "ToFTargetSelector"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = parent
    local frame = Instance.new("Frame")
    frame.Name = "Main"
    frame.Size = UDim2.new(0, 180, 0, 126)
    frame.Position = ToFState.SavedUIPos
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 28)
    header.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
    header.BorderSizePixel = 0
    header.Parent = frame
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 4)
    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 10)
    headerFix.Position = UDim2.new(0, 0, 1, -10)
    headerFix.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header
    local headerDiv = Instance.new("Frame")
    headerDiv.Size = UDim2.new(1, 0, 0, 1)
    headerDiv.Position = UDim2.new(0, 0, 1, -1)
    headerDiv.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
    headerDiv.BorderSizePixel = 0
    headerDiv.Parent = header
    local dragArea = Instance.new("Frame")
    dragArea.Size = UDim2.new(1, -34, 1, 0)
    dragArea.BackgroundTransparency = 1
    dragArea.Parent = header
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 28, 1, 0)
    minimizeBtn.Position = UDim2.new(1, -30, 0, 0)
    minimizeBtn.BackgroundTransparency = 1
    minimizeBtn.Text = "-"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 14
    minimizeBtn.Parent = header
    local headerLbl = Instance.new("TextLabel")
    headerLbl.Size = UDim2.new(1, -44, 1, 0)
    headerLbl.Position = UDim2.new(0, 10, 0, 0)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Text = "TOF TARGET MODE"
    headerLbl.TextColor3 = Color3.fromRGB(255, 0, 0)
    headerLbl.Font = Enum.Font.GothamBold
    headerLbl.TextSize = 10
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Parent = header
    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(1, -16, 0, 86)
    btnContainer.Position = UDim2.new(0, 8, 0, 34)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = frame
    local layout = Instance.new("UIListLayout", btnContainer)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    local isMinimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        minimizeBtn.Text = isMinimized and "+" or "-"
        btnContainer.Visible = not isMinimized
        frame.Size = isMinimized and UDim2.new(0, 180, 0, 28) or UDim2.new(0, 180, 0, 126)
    end)
    local modes = {
        { Internal = "Killer", Display = "KILLER        K" },
        { Internal = "Survivors", Display = "SURVIVOR      J" },
        { Internal = "Zombie", Display = "ZOMBIE        L" },
    }
    ToF_ModeButtons = {}
    for i, mode in ipairs(modes) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 25)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.Text = mode.Display
        btn.TextXAlignment = Enum.TextXAlignment.Center
        btn.LayoutOrder = i
        btn.Parent = btnContainer
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = Color3.fromRGB(25, 25, 25)
        btnStroke.Thickness = 1
        btn.MouseButton1Click:Connect(function() ToF_SetTargetMode(mode.Internal, false) end)
        btn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then ToF_SetTargetMode(mode.Internal, false) end
        end)
        ToF_ModeButtons[mode.Internal] = btn
    end
    ToF_RefreshTargetButtons()
    local dragging = false
    local dragStart, startPos
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragStart = input.Position
            startPos = frame.Position
            dragging = true
        end
    end)
    dragArea.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            frame.Position = newPos
            ToFState.SavedUIPos = newPos
        end
    end)
    ToFState.TargetGui = gui
end

local function ToF_DestroyTargetSelectorUI()
    if ToFState.TargetGui then
        pcall(function() ToFState.TargetGui:Destroy() end)
        ToFState.TargetGui = nil
    end
    ToF_ModeButtons = {}
end

local function ToF_StartConnection()
    if ToFState.Connection then return end
    ToFState.Connection = RunService.Heartbeat:Connect(function()
        if ToF_IsBlocked() then
            ToFState.IsAiming = false
            if ToFState.TouchInput then ToFState.TouchInput = nil end
            if ToFState.LaserBeam then ToFState.LaserBeam.Transparency = 1 end
            return
        end
        if not VD.TOF_SilentAim or not ToFState.IsAiming then
            if ToFState.LaserBeam then ToFState.LaserBeam.Transparency = 1 end
            return
        end
        local _, _, originPos, targetPos = ToF_GetTargetPosition()
        if originPos and targetPos then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and not char:GetAttribute("IsCarried") then
                    hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z))
                end
            end)
            if VD.TOF_Laser then ToF_UpdateLaser(originPos, targetPos)
            elseif ToFState.LaserBeam then ToFState.LaserBeam.Transparency = 1 end
        elseif ToFState.LaserBeam then ToFState.LaserBeam.Transparency = 1 end
    end)
end

local function ToF_StopConnection()
    if ToFState.Connection then
        pcall(function() ToFState.Connection:Disconnect() end)
        ToFState.Connection = nil
    end
    ToFState.IsAiming = false
    ToF_ClearLaser()
end

local SetToFSilentAim

local function ToF_EnsureInputs()
    if not ToFState.InputBegan then
        ToFState.InputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            local keyCode = ToFKeyCodes[VD.TOF_Key or "None"]
            if keyCode and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == keyCode then
                SetToFSilentAim(not VD.TOF_SilentAim)
                return
            end
            if not VD.TOF_SilentAim then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or (input.UserInputType == Enum.UserInputType.Touch and ToF_IsTouchOnShootButton(input)) then
                if ToF_IsBlocked() then ToFState.IsAiming = false; return end
                ToFState.IsAiming = true
                if input.UserInputType == Enum.UserInputType.Touch then ToFState.TouchInput = input end
                return
            end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.K then ToF_SetTargetMode("Killer", true)
                elseif input.KeyCode == Enum.KeyCode.J then ToF_SetTargetMode("Survivors", true)
                elseif input.KeyCode == Enum.KeyCode.L then ToF_SetTargetMode("Zombie", true) end
            end
        end)
    end
    if not ToFState.InputEnded then
        ToFState.InputEnded = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or (input.UserInputType == Enum.UserInputType.Touch and input == ToFState.TouchInput) then
                local wasAiming = ToFState.IsAiming
                ToFState.IsAiming = false
                if input == ToFState.TouchInput then ToFState.TouchInput = nil end
                if ToFState.LaserBeam then ToFState.LaserBeam.Transparency = 1 end
                if wasAiming then
                    if ToF_IsBlocked() then return end
                    ToF_DoShoot()
                end
            end
        end)
    end
end

SetToFSilentAim = function(enabled)
    VD.TOF_SilentAim = enabled and true or false
    ToF_EnsureInputs()
    if VD.TOF_SilentAim then ToF_CreateTargetSelectorUI(); ToF_StartConnection()
    else ToF_DestroyTargetSelectorUI(); ToF_StopConnection() end
end

ToF_EnsureInputs()
getgenv().MAWWW_SetToFSilentAim = SetToFSilentAim
getgenv().MAWWW_ToFClearLaser = ToF_ClearLaser
getgenv().MAWWW_ToFSetTargetMode = ToF_SetTargetMode

-- =====================================================
-- SILENT AIM: FLASHLIGHT
-- =====================================================
local FlashState = { Connection = nil, LaserBeam = nil, FlashlightPart = nil, Active = false }

local function Flash_GetActivateRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local items = remotes and remotes:FindFirstChild("Items")
    local flashlight = items and items:FindFirstChild("Flashlight")
    local activate = flashlight and flashlight:FindFirstChild("Activate")
    if activate and activate:IsA("RemoteEvent") then return activate end
    return nil
end

local function Flash_GetTargetPart(char)
    if not char then return nil end
    local preferred = VD.FLASH_TargetPart or "Head"
    local part = char:FindFirstChild(preferred)
    if part and part:IsA("BasePart") then return part end
    return char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
end

local function Flash_IsAliveCharacter(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local state = char:GetAttribute("State")
    return state ~= "Dead"
end

local function Flash_GetTarget()
    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end
    local maxRange = tonumber(VD.FLASH_Range) or 120
    local bestPart, bestScore = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and Flash_IsAliveCharacter(player.Character) then
            local isKiller = player.Team and player.Team.Name == "Killer"
            if isKiller then
                local part = Flash_GetTargetPart(player.Character)
                if part then
                    local dist = (localRoot.Position - part.Position).Magnitude
                    if dist <= maxRange and dist < bestScore then bestScore = dist; bestPart = part end
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
    local hand = char and (char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm") or char:FindFirstChild("HumanoidRootPart"))
    if hand and hand:IsA("BasePart") then return hand.Position end
    return cam and cam.CFrame.Position or nil
end

local function Flash_UpdateLaser(originPos, targetPos)
    if not FlashState.LaserBeam then
        local laser = Instance.new("Part")
        laser.Name = "FlashlightSilentAimLaser"
        laser.Anchored = true
        laser.CanCollide = false
        laser.CanTouch = false
        laser.CastShadow = false
        laser.Material = Enum.Material.Neon
        laser.Color = Color3.fromRGB(255, 0, 0)
        laser.Transparency = 0
        laser.Parent = workspace
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
    if not (VD.FLASH_SilentAim and FlashState.Active) then
        if FlashState.LaserBeam then FlashState.LaserBeam.Transparency = 1 end
        return
    end
    local cam = workspace.CurrentCamera
    local targetPart = Flash_GetTarget()
    if not (cam and targetPart) then
        if FlashState.LaserBeam then FlashState.LaserBeam.Transparency = 1 end
        return
    end
    local targetPos = targetPart.Position
    local smooth = math.clamp(tonumber(VD.FLASH_Smooth) or 0.35, 0.05, 1)
    local originPos = Flash_GetOrigin(cam)
    if VD.FLASH_Laser and originPos then Flash_UpdateLaser(originPos, targetPos)
    elseif FlashState.LaserBeam then FlashState.LaserBeam.Transparency = 1 end
    pcall(function() cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, targetPos), smooth) end)
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)) end
    end)
end

local function Flash_StartSilentAim()
    getgenv().MAWWW_FlashlightActivateRemote = Flash_GetActivateRemote()
    if FlashState.Connection then return end
    FlashState.Connection = RunService.RenderStepped:Connect(Flash_AimStep)
end

local function Flash_StopSilentAim()
    FlashState.Active = false
    FlashState.FlashlightPart = nil
    Flash_ClearLaser()
    if FlashState.Connection then
        pcall(function() FlashState.Connection:Disconnect() end)
        FlashState.Connection = nil
    end
end

local function Flash_SetSilentAim(enabled)
    VD.FLASH_SilentAim = enabled and true or false
    if VD.FLASH_SilentAim then Flash_StartSilentAim() else Flash_StopSilentAim() end
end

getgenv().MAWWW_SetFlashlightSilentAim = Flash_SetSilentAim
getgenv().MAWWW_ClearFlashlightLaser = Flash_ClearLaser
getgenv().MAWWW_SetFlashlightAimActive = function(active, flashlightPart)
    FlashState.Active = active and true or false
    if FlashState.Active and flashlightPart then FlashState.FlashlightPart = flashlightPart
    elseif not FlashState.Active then FlashState.FlashlightPart = nil end
    if not FlashState.Active and FlashState.LaserBeam then FlashState.LaserBeam.Transparency = 1 end
end
getgenv().MAWWW_FlashlightActivateRemote = Flash_GetActivateRemote()

-- =====================================================
-- SILENT AIM: VEIL SPEAR (PREDICTION)
-- =====================================================
local VeilConfig = {
    Enabled = false, ShowFOV = true, ShowTargetLaser = true, FOV = 220, SpearSpeed = 165,
    Gravity = workspace.Gravity * 0.5, MaxDist = 200, AutoPredict = false, TargetPart = "Torso", HorizontalPredictFactor = 1.0,
}
local VeilState = {
    chargingSpear = false, touchInput = nil, attackCooldown = false, passiveCooldown = false, remoteHooked = false, lastPredictedPos = nil,
}
local VeilVelocityCache = {}
local VeilDraw = {
    FOVCircle = Drawing.new("Circle"), Highlight = Instance.new("Highlight"), Tracer = Drawing.new("Circle"),
}
VeilDraw.FOVCircle.Color = Color3.fromRGB(15, 15, 15)
VeilDraw.FOVCircle.Thickness = 1.5
VeilDraw.FOVCircle.Filled = false
VeilDraw.FOVCircle.Visible = false
VeilDraw.Highlight.Name = "VD_VeilTarget"
VeilDraw.Highlight.FillColor = Color3.fromRGB(15, 15, 15)
VeilDraw.Highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
VeilDraw.Highlight.FillTransparency = 0.5
VeilDraw.Highlight.OutlineTransparency = 0
VeilDraw.Tracer.Thickness = 2
VeilDraw.Tracer.Radius = 5
VeilDraw.Tracer.Color = Color3.fromRGB(255, 0, 0)
VeilDraw.Tracer.Filled = true
VeilDraw.Tracer.Visible = false

local function Veil_GetRealVelocity(part, playerName)
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
        if rawVelocity.Magnitude < 100 then cache.velocity = cache.velocity:Lerp(rawVelocity, 0.35) end
    end
    cache.lastPos = currentPos
    cache.lastTime = currentTime
    return cache.velocity
end

local function Veil_GetTargetPart(char)
    if VeilConfig.TargetPart == "Head" then return char:FindFirstChild("Head")
    elseif VeilConfig.TargetPart == "Root" then return char:FindFirstChild("HumanoidRootPart")
    else return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart") end
end

local function Veil_GetClosestSurvivor()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local cam = workspace.CurrentCamera
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local bestDist = VeilConfig.FOV
    local bestTarget = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team and p.Team.Name == "Survivors" and p.Character then
            local char = p.Character
            local hum  = char:FindFirstChildOfClass("Humanoid")
            local part = Veil_GetTargetPart(char)
            if hum and hum.Health > 0 and part then
                local dist3D = (part.Position - myRoot.Position).Magnitude
                if dist3D <= VeilConfig.MaxDist then
                    local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist2D < bestDist then bestDist = dist2D; bestTarget = { Player = p, Part = part } end
                    end
                end
            end
        end
    end
    return bestTarget
end

local function Veil_SetupInterceptor()
    if VeilState.remoteHooked then return end
    task.spawn(function()
        pcall(function()
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local args = {...}
                local method = getnamecallmethod()
                if not checkcaller() then
                    if string.lower(method) == "kick" then return nil end
                    if method == "FireServer" then
                        if self.Name == "Spearthrow" and VeilConfig.Enabled then return nil end
                    end
                end
                return oldNamecall(self, ...)
            end)
            VeilState.remoteHooked = true
        end)
    end)
end
Veil_SetupInterceptor()

local function Veil_Fire()
    if VeilState.attackCooldown then return end
    VeilState.attackCooldown = true
    task.delay(2, function() VeilState.attackCooldown = false end)
    local myChar = LocalPlayer.Character
    local startPart = myChar and (myChar:FindFirstChild("Head") or myChar:FindFirstChild("HumanoidRootPart"))
    if not startPart then return end
    local startPos = startPart.Position
    local targetInfo = Veil_GetClosestSurvivor()
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
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local killers = remotes:FindFirstChild("Killers")
            if killers then
                local veil = killers:FindFirstChild("Veil")
                if veil and veil:FindFirstChild("Spearthrow") then veil.Spearthrow:FireServer(aimDir, VeilConfig.SpearSpeed, startPos) end
            end
        end
    end)
    VeilDraw.FOVCircle.Color = Color3.fromRGB(15, 15, 15)
    if not VeilState.passiveCooldown then
        VeilState.passiveCooldown = true
        task.delay(30, function() VeilDraw.FOVCircle.Color = Color3.fromRGB(255, 0, 0); VeilState.passiveCooldown = false end)
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    local isTouch = input.UserInputType == Enum.UserInputType.Touch
    if gp and not isTouch then return end
    local char = LocalPlayer.Character
    local isSpearMode = char and char:GetAttribute("spearmode") == true
    if not VeilConfig.Enabled then return end
    if not isSpearMode then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then VeilState.chargingSpear = true
    elseif isTouch then
        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
        if pGui then
            local slasher = pGui:FindFirstChild("Slasher-mob")
            if slasher then
                local ctrl = slasher:FindFirstChild("Controls")
                if ctrl then
                    local attackBtn = ctrl:FindFirstChild("attack")
                    if attackBtn and attackBtn.Visible then
                        local pos = input.Position
                        local absPos = attackBtn.AbsolutePosition
                        local absSize = attackBtn.AbsoluteSize
                        if pos.X >= absPos.X and pos.X <= absPos.X + absSize.X and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y then
                            VeilState.chargingSpear = true
                            VeilState.touchInput = input
                        end
                    end
                end
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if VeilState.chargingSpear and (input == VeilState.touchInput or input.UserInputType == Enum.UserInputType.MouseButton1) then
        VeilState.chargingSpear = false
        if VeilState.touchInput == input then VeilState.touchInput = nil end
        Veil_Fire()
    end
end)

RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    local myChar = LocalPlayer.Character
    local isSpearMode = myChar and myChar:GetAttribute("spearmode") == true
    if VeilConfig.Enabled and VeilConfig.ShowFOV and isSpearMode then
        VeilDraw.FOVCircle.Visible = true
        VeilDraw.FOVCircle.Radius = VeilConfig.FOV
        VeilDraw.FOVCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    else VeilDraw.FOVCircle.Visible = false end
    if VeilState.chargingSpear and VeilConfig.Enabled and isSpearMode then
        local target = Veil_GetClosestSurvivor()
        if target and target.Part and target.Part.Parent then
            VeilDraw.Highlight.Parent = target.Part.Parent
            if VeilConfig.ShowTargetLaser then
                if not getgenv().MAWWW_SpearLaserPart then
                    local laser = Instance.new("Part")
                    laser.Name = "SpearSilentAimLaser"
                    laser.Anchored = true
                    laser.CanCollide = false
                    laser.CanTouch = false
                    laser.CastShadow = false
                    laser.Material = Enum.Material.Neon
                    laser.Color = Color3.fromRGB(255, 0, 0)
                    laser.Transparency = 0
                    laser.Parent = workspace
                    getgenv().MAWWW_SpearLaserPart = laser
                end
                local originPart = myChar and (myChar:FindFirstChild("Head") or myChar:FindFirstChild("HumanoidRootPart"))
                if originPart then
                    local originPos = originPart.Position
                    local targetPos = target.Part.Position
                    local dist = (targetPos - originPos).Magnitude
                    if dist > 0.1 then
                        local laser = getgenv().MAWWW_SpearLaserPart
                        laser.Size = Vector3.new(0.16, 0.16, dist)
                        laser.CFrame = CFrame.new((originPos + targetPos) / 2, targetPos)
                        laser.Transparency = 0.5
                    end
                end
            else
                if getgenv().MAWWW_SpearLaserPart then getgenv().MAWWW_SpearLaserPart.Transparency = 1 end
            end
        else
            VeilDraw.Highlight.Parent = nil
            if getgenv().MAWWW_SpearLaserPart then getgenv().MAWWW_SpearLaserPart.Transparency = 1 end
        end
    else
        VeilDraw.Highlight.Parent = nil
        if getgenv().MAWWW_SpearLaserPart then getgenv().MAWWW_SpearLaserPart.Transparency = 1 end
    end
    if VeilConfig.Enabled and isSpearMode and VeilState.lastPredictedPos then
        local screenPos, onScreen = cam:WorldToViewportPoint(VeilState.lastPredictedPos)
        local viewport = cam.ViewportSize
        local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
        if onScreen then VeilDraw.Tracer.Position = Vector2.new(screenPos.X, screenPos.Y)
        else
            local dx = screenPos.X - center.X
            local dy = screenPos.Y - center.Y
            if math.abs(dx) < 1 and math.abs(dy) < 1 then VeilDraw.Tracer.Position = center
            else
                local maxX = viewport.X / 2 - 10
                local maxY = viewport.Y / 2 - 10
                local scaleX = maxX / math.abs(dx)
                local scaleY = maxY / math.abs(dy)
                local scale = math.min(scaleX, scaleY)
                VeilDraw.Tracer.Position = Vector2.new(center.X + dx * scale, center.Y + dy * scale)
            end
        end
        VeilDraw.Tracer.Visible = true
    else VeilDraw.Tracer.Visible = false end
end)

-- =====================================================
-- DASH LOCK
-- =====================================================
local function DashLock_Update()
    if not VD.DashLockEnabled then
        if VD._DashLockActive then
            VD._DashLockActive = false
            VD._DashLockTarget = nil
            if VD.FreezeDuringDashLock then
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum and hum.WalkSpeed == 0 then hum.WalkSpeed = 16 end
            end
        end
        return
    end
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then VD._DashLockTarget = nil; return end
    local target = nil
    local targetDist = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team and player.Team.Name == "Survivors" then
            local char = player.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if root and hum and hum.Health > 0 then
                    local dist = (myRoot.Position - root.Position).Magnitude
                    if dist < targetDist then targetDist = dist; target = root end
                end
            end
        end
    end
    if not target then VD._DashLockTarget = nil; return end
    VD._DashLockTarget = target
    local cam = Workspace.CurrentCamera
    if cam and target then
        local smoothFactor = VD.DashLockSmoothness or 0.3
        local targetPos = target.Position
        cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, targetPos), smoothFactor)
        if VD.FreezeDuringDashLock then
            local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed ~= 0 then hum.WalkSpeed = 0 end
        end
    end
end

function MAWWW_SetDashLockActive(active)
    if active == VD._DashLockActive then return end
    VD._DashLockActive = active
    if active then
        if not VD._DashLockConnection then VD._DashLockConnection = RunService.RenderStepped:Connect(DashLock_Update) end
    else
        if VD._DashLockConnection then VD._DashLockConnection:Disconnect(); VD._DashLockConnection = nil end
        VD._DashLockTarget = nil
    end
end

local DashAnimationId = "rbxassetid://98163597193511"
local function HookDashDetection(char)
    local humanoid = char:WaitForChild("Humanoid", 5)
    if humanoid then
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            animator.AnimationPlayed:Connect(function(animationTrack)
                if animationTrack.Animation and animationTrack.Animation.AnimationId == DashAnimationId then
                    if VD.DashLockEnabled then
                        MAWWW_SetDashLockActive(true)
                        task.delay(VD.DashLockDuration or 1.5, function() MAWWW_SetDashLockActive(false) end)
                    end
                end
            end)
        end
    end
end
if LocalPlayer.Character then HookDashDetection(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(HookDashDetection)

-- =====================================================
-- LOCK POV
-- =====================================================
local LockPOV = { Enabled = false, LockedFOV = 80, SaveOriginal = true, OriginalFOV = nil, Connection = nil }

local function LockPOV_Update()
    if not LockPOV.Enabled then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    if cam.FieldOfView ~= LockPOV.LockedFOV then cam.FieldOfView = LockPOV.LockedFOV end
end

local function LockPOV_Enable()
    local cam = workspace.CurrentCamera
    if not cam then return end
    if LockPOV.SaveOriginal then LockPOV.OriginalFOV = cam.FieldOfView end
    if LockPOV.Connection then LockPOV.Connection:Disconnect(); LockPOV.Connection = nil end
    cam.FieldOfView = LockPOV.LockedFOV
    LockPOV.Connection = RunService.RenderStepped:Connect(LockPOV_Update)
    VD_Notify("Lock POV", "Enabled (" .. LockPOV.LockedFOV .. ")", 2)
end

local function LockPOV_Disable()
    if LockPOV.Connection then LockPOV.Connection:Disconnect(); LockPOV.Connection = nil end
    local cam = workspace.CurrentCamera
    if cam and LockPOV.OriginalFOV then cam.FieldOfView = LockPOV.OriginalFOV end
    VD_Notify("Lock POV", "Disabled", 2)
end

local function LockPOV_SetEnabled(enabled)
    LockPOV.Enabled = enabled and true or false
    if LockPOV.Enabled then LockPOV_Enable() else LockPOV_Disable() end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if LockPOV.Enabled then
        local cam = workspace.CurrentCamera        if cam then cam.FieldOfView = LockPOV.LockedFOV end
    end
end)

-- =====================================================
-- KORLESS MORPH
-- =====================================================
local KorlessMorph = { Enabled = false, Connection = nil }
local function ApplyKorless()
    local plr = game.Players.LocalPlayer
    local function Morph()
        repeat task.wait() until plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Right Leg")
        task.wait(0.1)
        local char = plr.Character
        pcall(function()
            char.Head.Transparency = 1
            local face = char.Head:FindFirstChild("face")
            if face then face:Destroy() end
            char["Right Leg"].Transparency = 1
            local mesh = Instance.new("MeshPart")
            mesh.Name = "KorlessHead"
            mesh.Size = Vector3.new(1.5,1.5,1.5)
            mesh.CanCollide = false
            mesh.MeshId = "rbxassetid://902942096"
            mesh.TextureID = "rbxassetid://902843398"
            mesh.CFrame = char["Right Leg"].CFrame * CFrame.new(0,0.5,0)
            mesh.Parent = char
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = char["Right Leg"]
            weld.Part1 = mesh
            weld.Parent = mesh
        end)
    end
    Morph()
    if KorlessMorph.Connection then KorlessMorph.Connection:Disconnect() end
    KorlessMorph.Connection = plr.CharacterAdded:Connect(function() task.wait(1); Morph() end)
end

-- =====================================================
-- ESP SYSTEM
-- =====================================================
for _, obj in ipairs(workspace:GetDescendants()) do
    if string.find(string.lower(obj.Name), "scp") then ESPCache.SCP[obj] = true end
    if obj.Name == "Generator" then ESPCache.Generators[obj] = true
    elseif obj.Name == "Window" then ESPCache.Windows[obj] = true
    elseif obj.Name == "Pallet" or obj.Name == "Palletwrong" then ESPCache.Pallets[obj] = true end
end
workspace.DescendantAdded:Connect(function(obj)
    local name = string.lower(obj.Name)
    if string.find(name, "scp") then ESPCache.SCP[obj] = true end
    if obj.Name == "Generator" then ESPCache.Generators[obj] = true
    elseif obj.Name == "Window" then ESPCache.Windows[obj] = true
    elseif obj.Name == "Pallet" or obj.Name == "Palletwrong" then ESPCache.Pallets[obj] = true end
end)
workspace.DescendantRemoving:Connect(function(obj)
    ESPCache.SCP[obj] = nil
    ESPCache.Generators[obj] = nil
    ESPCache.Windows[obj] = nil
    ESPCache.Pallets[obj] = nil
    if ESPCache.Objects[obj] then ESPCache.Objects[obj]:Destroy(); ESPCache.Objects[obj] = nil end
end)

local function removeESP(obj)
    if ESPCache.Objects[obj] then ESPCache.Objects[obj]:Destroy(); ESPCache.Objects[obj] = nil end
end

local function createESP(obj, color)
    if not obj then return end
    if ESPCache.Objects[obj] then
        ESPCache.Objects[obj].FillColor = color
        ESPCache.Objects[obj].OutlineColor = color
        return
    end
    local h = Instance.new("Highlight")
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = 0.9
    h.OutlineTransparency = 0.3
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = obj
    ESPCache.Objects[obj] = h
    obj.AncestryChanged:Connect(function(_, parent) if not parent then removeESP(obj) end end)
end

local function removeStatusESP(char)
    if ESPCache.Status[char] then ESPCache.Status[char]:Destroy(); ESPCache.Status[char] = nil end
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
    h.Name = "GenHighlight"
    h.Adornee = object
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = 0.9
    h.OutlineTransparency = 0.3
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = object
end

local function CreateBillboard(text, color)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "GenESP"
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.AlwaysOnTop = true
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = billboard
    return billboard
end

local function UpdateGenerator(generator)
    if not generator or not generator.Parent then return end
    if not ESP.Generator then
        local old = generator:FindFirstChild("GenESP"); if old then old:Destroy() end
        local h = generator:FindFirstChild("GenHighlight"); if h then h:Destroy() end
        return
    end
    local percent = GetGameValue(generator, "RepairProgress") or GetGameValue(generator, "Progress") or 0
    local billboard = generator:FindFirstChild("GenESP")
    if percent >= 100 then if billboard then billboard:Destroy() end; return end
    local cp = math.clamp(percent, 0, 100)
    local color = GeneratorColor:Lerp(Color3.fromRGB(0, 255, 120), cp / 100)
    local text = string.format("[%.0f%%]", percent)
    if not billboard then
        billboard = CreateBillboard(text, color)
        billboard.Adornee = generator
        billboard.Parent = generator
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
        if ESP.Window and distance <= ESP.Distance then createESP(obj, WindowColor) else removeESP(obj) end
    end
    if obj.Name == "Pallet" or obj.Name == "Palletwrong" then
        if ESP.Pallet and distance <= ESP.Distance then createESP(obj, PalletColor) else removeESP(obj) end
    end
end

local function createStatusESP(player, char, root)
    if not ESPStatus.Enabled then removeStatusESP(char); return end
    if not root then return end
    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not head or not hum then return end
    local isDown = hum.Health <= 0 or hum.Health < 2 or char:GetAttribute("Downed") == true or char:GetAttribute("IsDown") == true or char:GetAttribute("Knocked") == true
    local dist = (head.Position - root.Position).Magnitude
    if dist > ESPStatus.Radius then removeStatusESP(char); return end
    local text = ""
    if isDown then text = "[DOWN]\n" end
    if ESPStatus.ShowName then
        text = text .. player.Name
        if ESPStatus.ShowItem then
            local item = GetHeldItem(char)
            if item then text = text .. " [" .. item .. "]" end
        end
        text = text .. "\n"
    end
    if ESPStatus.ShowDistance then text = text .. string.format("Dist: %.0f\n", dist) end
    if ESPStatus.ShowHealth then text = text .. string.format("HP: %.0f\n", hum.Health) end
    if text == "" then removeStatusESP(char); return end
    local teamColor = Color3.new(1, 1, 1)
    if player.Team then
        if player.Team.Name == "Killer" then teamColor = TeamColors.Killer
        elseif player.Team.Name == "Survivors" then teamColor = TeamColors.Survivor end
    end
    if isDown then teamColor = Color3.fromRGB(255, 0, 0) end
    local billboard = ESPCache.Status[char]
    if not billboard then
        billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 120, 0, 50)
        billboard.AlwaysOnTop = true
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = teamColor
        label.TextStrokeTransparency = 0
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.Text = text
        label.Parent = billboard
        billboard.Adornee = head
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.Parent = char
        ESPCache.Status[char] = billboard
    else
        local label = billboard:FindFirstChildOfClass("TextLabel")
        if label then label.Text = text; label.TextColor3 = teamColor end
    end
end

local function UpdateSCPEsp(root)
    if not ESP.SCP then for obj in pairs(ESPCache.SCP) do removeESP(obj) end return end
    for obj in pairs(ESPCache.SCP) do
        if obj and obj.Parent then
            local pos
            if obj:IsA("Model") then pos = obj:GetPivot().Position
            elseif obj:IsA("BasePart") then pos = obj.Position end
            if pos then
                if (pos - root.Position).Magnitude <= ESP.Distance then createESP(obj, SCPColor) else removeESP(obj) end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    local root = GetRoot()
    if not root then return end
    local now = tick()
    if now - Timers.lastESPUpdate < 0.05 then return end
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
                        if ESP.Survivor and p.Team and p.Team.Name == "Survivors" then createESP(char, TeamColors.Survivor)
                        elseif ESP.Killer and p.Team and p.Team.Name == "Killer" then createESP(char, TeamColors.Killer)
                        else removeESP(char) end
                    else removeESP(char) end
                end
                createStatusESP(p, char, root)
            else removeESP(char) end
        end
    end
    if ESP.Generator then for gen in pairs(ESPCache.Generators) do UpdateGenerator(gen) end end
    for obj in pairs(ESPCache.Windows) do UpdateMapESP(obj, root) end
    for obj in pairs(ESPCache.Pallets) do UpdateMapESP(obj, root) end
    UpdateSCPEsp(root)
end)

-- ============== UI =================
local Window = Library:CreateWindow({
    Title = "Wisnu Hub",
    Footer = 'Violence District | Multi-Feature',
    Icon = "96848424314690",
    IconSize = UDim2.fromOffset(50, 50),
    NotifySide = "Right",
    EnableSidebarResize = true,
    EnableCompacting = true,
    SidebarCompacted = true,
    Size = UDim2.fromOffset(500, 700),
    CornerRadius = 20,
    AutoShow = true,
})

local Tabs = {
    Combat = Window:AddTab("Combat", "swords", "Auto Parry + Silent Aim"),
    Killer = Window:AddTab("Killer", "skull", "Killer Utilities"),
    Visuals = Window:AddTab("Visuals", "eye", "Camera & Visual Features"),
    Survivor = Window:AddTab("Survivor", "user", "Survivor Utilities"),
    UISettings = Window:AddTab("UI Settings", "settings-2", "Config, Theme, UiSetting")
}

-- ===== COMBAT TAB =====
local CombatLeft = Tabs.Combat:AddLeftGroupbox("Auto Parry", "swords")
local CombatRight = Tabs.Combat:AddRightGroupbox("Silent Aim ToF", "target")
local CombatFlashBox = Tabs.Combat:AddLeftGroupbox("Silent Aim Flashlight", "flashlight")
local CombatVeilBox = Tabs.Combat:AddRightGroupbox("Silent Aim Spear (Veil)", "sword")
local CombatDashBox = Tabs.Combat:AddLeftGroupbox("Dash Lock (Killer)", "zap")

local AutoParryToggle = CombatLeft:AddCheckbox("AutoParry", {
    Text = "Auto Parry", Default = false,
    Callback = function(Value) Config.Surv_AutoParry = Value end,
}):AddKeyPicker("AutoParryKey", {
    Default = "None", Text = "Auto Parry Key", Mode = "Toggle",
    Callback = function(Value) Config.Surv_AutoParry = Value end,
})

CombatLeft:AddCheckbox("Surv_ParrySafety", { Text = "Safety Parry", Default = false, Tooltip = "Hanya parry saat tidak vault/repair/unhook", Callback = function(Value) Config.Surv_ParrySafety = Value end })

CombatLeft:AddToggle("ParryAggressive", { Text = "Aggressive Mode", Default = false, Callback = function(Value) Config.Surv_ParryAggressive = Value end })
CombatLeft:AddToggle("ParryCircle", { Text = "ESP Range Circle", Default = true, Callback = function(Value) Config.Surv_ParryCircle = Value end })
CombatLeft:AddSlider("ParryRadius", { Text = "Parry Radius", Default = 15, Min = 5, Max = 25, Rounding = 0, Callback = function(Value) Config.Surv_ParryRadius = Value end })
CombatLeft:AddSlider("ParryFace", { Text = "Face Sensitivity", Default = 7, Min = -10, Max = 10, Rounding = 0, Callback = function(Value) Config.Surv_ParryFace = Value / 10 end })
CombatLeft:AddDropdown("IgnoreSkills", {
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
CombatLeft:AddToggle("Surv_AutoCrouch", { Text = "Auto Crouch (Dodge S1)", Default = false, Callback = function(Value) Config.Surv_AutoCrouch = Value end })

local ToFToggle = CombatRight:AddCheckbox("ToFSilentAim", {
    Text = "Enable Silent Aim", Default = false,
    Callback = function(v) SetToFSilentAim(v); VD_Notify("Silent Aim ToF", v and "Enabled" or "Disabled", 2) end,
}):AddKeyPicker("ToFSilentAimKey", {
    Default = "Q", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) SetToFSilentAim(state); VD_Notify("Silent Aim ToF", state and "Enabled" or "Disabled", 2) end,
    ChangedCallback = function(New) VD.TOF_Key = New.Name or "None" end,
})
CombatRight:AddDropdown("ToFTargetMode", { Text = "Target Mode", Values = { "Killer", "Survivors", "Zombie" }, Default = 1, Multi = false, Callback = function(v) ToF_SetTargetMode(v, true) end })
CombatRight:AddToggle("ToFLaserToggle", { Text = "Show Laser Beam", Default = true, Callback = function(v) VD.TOF_Laser = v; if not v then ToF_ClearLaser() end end })
CombatRight:AddToggle("ToFWallCheck", { Text = "Wall Check", Default = true, Callback = function(v) VD.TOF_WallCheck = v end })
CombatRight:AddToggle("ToFBlockKnocked", { Text = "Block When Knocked", Default = true, Callback = function(v) VD.TOF_BlockKnocked = v end })
CombatRight:AddLabel("Quick Hotkeys (PC):\nK = Target Killer\nJ = Target Survivor\nL = Target Zombie")

local FlashToggle = CombatFlashBox:AddCheckbox("FlashSilentAim", {
    Text = "Enable Silent Aim", Default = false,
    Callback = function(v) Flash_SetSilentAim(v); VD_Notify("Silent Aim Flashlight", v and "Enabled" or "Disabled", 2) end,
}):AddKeyPicker("FlashSilentAimKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) Flash_SetSilentAim(state); VD_Notify("Silent Aim Flashlight", state and "Enabled" or "Disabled", 2) end,
})
CombatFlashBox:AddDropdown("FlashTargetPart", { Text = "Target Part", Values = { "Head", "UpperTorso", "Torso", "HumanoidRootPart" }, Default = 1, Multi = false, Callback = function(v) VD.FLASH_TargetPart = v end })
CombatFlashBox:AddSlider("FlashRange", { Text = "Aim Range", Default = 120, Min = 20, Max = 500, Rounding = 0, Callback = function(v) VD.FLASH_Range = v end })
CombatFlashBox:AddSlider("FlashSmooth", { Text = "Smoothness", Default = 0.35, Min = 0.05, Max = 1, Rounding = 2, Callback = function(v) VD.FLASH_Smooth = v end })
CombatFlashBox:AddToggle("FlashLaserToggle", { Text = "Show Laser Beam", Default = true, Callback = function(v) VD.FLASH_Laser = v; if not v then Flash_ClearLaser() end end })

local VeilToggle = CombatVeilBox:AddCheckbox("VeilEnabled", {
    Text = "Enable Silent Aim", Default = false,
    Callback = function(v) VeilConfig.Enabled = v; VD_Notify("Silent Aim Veil Spear", v and "Enabled" or "Disabled", 2) end,
}):AddKeyPicker("VeilKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) VeilConfig.Enabled = state; VD_Notify("Silent Aim Veil Spear", state and "Enabled" or "Disabled", 2) end,
})
CombatVeilBox:AddSlider("VeilFOV", { Text = "FOV", Default = 220, Min = 50, Max = 800, Rounding = 0, Callback = function(v) VeilConfig.FOV = v end })
CombatVeilBox:AddDropdown("VeilTargetPart", { Text = "Target Part", Values = { "Torso", "Head", "Root" }, Default = 1, Multi = false, Callback = function(v) VeilConfig.TargetPart = v end })
CombatVeilBox:AddSlider("VeilSpearSpeed", { Text = "Spear Speed", Default = 165, Min = 50, Max = 400, Rounding = 0, Callback = function(v) VeilConfig.SpearSpeed = v end })
CombatVeilBox:AddSlider("VeilMaxDist", { Text = "Max Distance", Default = 200, Min = 20, Max = 200, Rounding = 0, Callback = function(v) VeilConfig.MaxDist = v end })
CombatVeilBox:AddSlider("VeilGravity", { Text = "Gravity", Default = math.floor(workspace.Gravity * 0.5), Min = 0, Max = 300, Rounding = 0, Callback = function(v) VeilConfig.Gravity = v end })
CombatVeilBox:AddToggle("VeilAutoPredict", { Text = "Auto Prediction", Default = false, Callback = function(v) VeilConfig.AutoPredict = v end })
CombatVeilBox:AddSlider("VeilPredictFactor", { Text = "Horizontal Predict", Default = 1.0, Min = 0, Max = 3, Rounding = 1, Callback = function(v) VeilConfig.HorizontalPredictFactor = v end })
CombatVeilBox:AddToggle("VeilShowFOV", { Text = "Show FOV Circle", Default = true, Callback = function(v) VeilConfig.ShowFOV = v end })
CombatVeilBox:AddToggle("VeilShowLaser", { Text = "Show Target Laser", Default = true, Callback = function(v) VeilConfig.ShowTargetLaser = v end })
CombatVeilBox:AddToggle("VeilShowTracer", { Text = "Show Prediction Tracer", Default = true, Callback = function(v) end })

local DashToggle = CombatDashBox:AddCheckbox("DashLockEnabled", {
    Text = "Enable Dash Lock", Default = false,
    Callback = function(v) VD.DashLockEnabled = v; if not v then MAWWW_SetDashLockActive(false) end; VD_Notify("Dash Lock", v and "Enabled" or "Disabled", 2) end,
}):AddKeyPicker("DashLockKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) VD.DashLockEnabled = state; if not state then MAWWW_SetDashLockActive(false) end; VD_Notify("Dash Lock", state and "Enabled" or "Disabled", 2) end,
})
CombatDashBox:AddSlider("DashLockSmooth", { Text = "Camera Smoothness", Default = 0.3, Min = 0.05, Max = 1, Rounding = 2, Callback = function(v) VD.DashLockSmoothness = v end })
CombatDashBox:AddSlider("DashLockDur", { Text = "Lock Duration", Default = 1.5, Min = 0.2, Max = 5, Rounding = 1, Callback = function(v) VD.DashLockDuration = v end })
CombatDashBox:AddToggle("DashLockFreeze", { Text = "Freeze Movement During Lock", Default = false, Callback = function(v) VD.FreezeDuringDashLock = v; if not v then local char = LocalPlayer.Character; local hum = char and char:FindFirstChildOfClass("Humanoid"); if hum and hum.WalkSpeed == 0 then hum.WalkSpeed = 16 end end end })

-- ===== KILLER TAB =====
local KillerAbilityBox = Tabs.Killer:AddLeftGroupbox("Ability Killer", "shield")
local KillerInfoBox = Tabs.Killer:AddRightGroupbox("Info", "info")

local NoSlowdownToggle = KillerAbilityBox:AddCheckbox("NoSlowdown", {
    Text = "No Slowdown", Default = false, Tooltip = "Killer tidak bisa di-slowdown",
    Callback = function(v) VD.KILLER_NoSlowdown = v; VD_Notify("No Slowdown", v and "Enabled" or "Disabled", 2) end,
}):AddKeyPicker("NoSlowdownKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) VD.KILLER_NoSlowdown = state; VD_Notify("No Slowdown", state and "Enabled" or "Disabled", 2) end,
})
KillerAbilityBox:AddSlider("SpeedValue", { Text = "Speed Value", Default = 16, Min = 16, Max = 32, Rounding = 0, Callback = function(v) VD.SPEED_Value = v end })
KillerAbilityBox:AddDivider()

local AutoHookToggle = KillerAbilityBox:AddCheckbox("AutoHook", {
    Text = "Auto Hook", Default = false, Tooltip = "Auto pickup + hook downed survivor",
    Callback = function(v) VD.KILLER_AutoHook = v; VD_Notify("Auto Hook", v and "Enabled" or "Disabled", 2) end,
}):AddKeyPicker("AutoHookKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) VD.KILLER_AutoHook = state; VD_Notify("Auto Hook", state and "Enabled" or "Disabled", 2) end,
})
KillerAbilityBox:AddDivider()

local BypassCooldownToggle = KillerAbilityBox:AddCheckbox("BypassCooldownAbyss", {
    Text = "Bypass Cooldown (Abyss)", Default = false,
    Callback = function(v) VD.KILLER_BypassCooldown = v; if v then MAWWW_StartAbyssCooldownBypass() else MAWWW_StopAbyssCooldownBypass() end; VD_Notify("Bypass Cooldown (Abyss)", v and "Enabled" or "Disabled", 2) end,
}):AddKeyPicker("BypassCooldownKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) VD.KILLER_BypassCooldown = state; if state then MAWWW_StartAbyssCooldownBypass() else MAWWW_StopAbyssCooldownBypass() end end,
})
local BypassLeapToggle = KillerAbilityBox:AddCheckbox("BypassLeapHidden", {
    Text = "Bypass Cooldown (Hidden)", Default = false,
    Callback = function(v) VD.KILLER_BypassLeap = v; if v then MAWWW_StartHiddenCooldownBypass() else MAWWW_StopHiddenCooldownBypass() end end,
}):AddKeyPicker("BypassLeapKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) VD.KILLER_BypassLeap = state; if state then MAWWW_StartHiddenCooldownBypass() else MAWWW_StopHiddenCooldownBypass() end end,
})
local InfFrenzyToggle = KillerAbilityBox:AddCheckbox("InfFrenzyJeff", {
    Text = "Bypass Cooldown (Jeff)", Default = false,
    Callback = function(v) VD.KILLER_InfFrenzy = v; if v then MAWWW_StartJeffCooldownBypass() else MAWWW_StopJeffCooldownBypass() end end,
}):AddKeyPicker("InfFrenzyKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) VD.KILLER_InfFrenzy = state; if state then MAWWW_StartJeffCooldownBypass() else MAWWW_StopJeffCooldownBypass() end end,
})
local InfLakeMistToggle = KillerAbilityBox:AddCheckbox("InfLakeMistSlasher", {
    Text = "Inf Lake Mist (Slasher)", Default = false,
    Callback = function(v) VD.KILLER_InfLakeMist = v; if v then MAWWW_StartSlasherCooldownBypass() else MAWWW_StopSlasherCooldownBypass() end end,
}):AddKeyPicker("InfLakeMistKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) VD.KILLER_InfLakeMist = state; if state then MAWWW_StartSlasherCooldownBypass() else MAWWW_StopSlasherCooldownBypass() end end,
})
local InfPursuitToggle = KillerAbilityBox:AddCheckbox("InfPursuitSlasher", {
    Text = "Inf Pursuit (Slasher)", Default = false,
    Callback = function(v) VD.KILLER_InfPursuit = v; if v then MAWWW_StartSlasherCooldownBypass() else MAWWW_StopSlasherCooldownBypass() end end,
}):AddKeyPicker("InfPursuitKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) VD.KILLER_InfPursuit = state; if state then MAWWW_StartSlasherCooldownBypass() else MAWWW_StopSlasherCooldownBypass() end end,
})

KillerAbilityBox:AddDivider()

local AntiBlindToggle = KillerAbilityBox:AddCheckbox("AntiBlind", {
    Text = "Anti Blind (Flashlight)", Default = false,
    Callback = function(v) VD.KILLER_AntiBlind = v; VD_Notify("Anti Blind", v and "Enabled" or "Disabled", 2) end,
}):AddKeyPicker("AntiBlindKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) VD.KILLER_AntiBlind = state; VD_Notify("Anti Blind", state and "Enabled" or "Disabled", 2) end,
})

KillerAbilityBox:AddDivider()

local BeatGameToggle = KillerAbilityBox:AddCheckbox("BeatGameKiller", {
    Text = "Auto Kill All (Beat Game)", Default = false,
    Callback = function(v) VD.BEAT_Killer = v; if not v then VD._KillerTarget = nil end; VD_Notify("Auto Kill All", v and "Enabled" or "Disabled", 2) end,
}):AddKeyPicker("BeatGameKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) VD.BEAT_Killer = state; if not state then VD._KillerTarget = nil end end,
})

KillerAbilityBox:AddDivider()

local FakeAttackToggle = KillerAbilityBox:AddCheckbox("FakeAttack", {
    Text = "Counter Auto Parry", Default = false,
    Callback = function(v) VD.KILLER_FakeAttack = v; MAWWW_ToggleFakeAttack(v); VD_Notify("Counter Auto Parry", v and "Enabled" or "Disabled", 2) end,
}):AddKeyPicker("FakeAttackKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) VD.KILLER_FakeAttack = state; MAWWW_ToggleFakeAttack(state) end,
})

KillerInfoBox:AddLabel("Ability Killer Features:\n- No Slowdown\n- Auto Hook\n- Bypass (Abyss/Hidden/Jeff)\n- Inf Lake Mist/Pursuit\n- Anti Blind\n- Auto Kill All\n- Counter Auto Parry")

-- ===== VISUALS TAB =====
local VisualLockPOVBox = Tabs.Visuals:AddLeftGroupbox("Lock POV (FOV)", "eye")
local VisualESPBox = Tabs.Visuals:AddRightGroupbox("ESP Cham", "scan-eye")
local VisualESPStatusBox = Tabs.Visuals:AddLeftGroupbox("ESP Status", "scan-eye")
local VisualMorphBox = Tabs.Visuals:AddRightGroupbox("Morph Avatar", "user")

local LockPOVToggle = VisualLockPOVBox:AddCheckbox("LockPOVEnabled", {
    Text = "Enable Lock POV", Default = false,
    Callback = function(v) LockPOV_SetEnabled(v) end,
}):AddKeyPicker("LockPOVKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) LockPOV_SetEnabled(state) end,
})
VisualLockPOVBox:AddSlider("LockedFOV", { Text = "Locked FOV", Default = 80, Min = 40, Max = 120, Rounding = 0, Callback = function(v) LockPOV.LockedFOV = v; if LockPOV.Enabled then local cam = workspace.CurrentCamera; if cam then cam.FieldOfView = v end end end })
VisualLockPOVBox:AddDivider()
VisualLockPOVBox:AddButton({ Text = "Preset: Normal (70)", Func = function() LockPOV.LockedFOV = 70; if Options and Options.LockedFOV then Options.LockedFOV:SetValue(70) end; if LockPOV.Enabled then local cam = workspace.CurrentCamera; if cam then cam.FieldOfView = 70 end end end })
VisualLockPOVBox:AddButton({ Text = "Preset: Wide (100)", Func = function() LockPOV.LockedFOV = 100; if Options and Options.LockedFOV then Options.LockedFOV:SetValue(100) end; if LockPOV.Enabled then local cam = workspace.CurrentCamera; if cam then cam.FieldOfView = 100 end end end })
VisualLockPOVBox:AddButton({ Text = "Preset: Ultra Wide (120)", Func = function() LockPOV.LockedFOV = 120; if Options and Options.LockedFOV then Options.LockedFOV:SetValue(120) end; if LockPOV.Enabled then local cam = workspace.CurrentCamera; if cam then cam.FieldOfView = 120 end end end })

local SurvivorESP = VisualESPBox:AddCheckbox("SurvivorESP", { Text = "ESP Survivor", Default = false, Callback = function(v) ESP.Survivor = v end })
SurvivorESP:AddColorPicker("SurvivorESPColor", { Default = TeamColors.Survivor, Title = "Survivor Color", Callback = function(color) TeamColors.Survivor = color end })
local KillerESP = VisualESPBox:AddCheckbox("KillerESP", { Text = "ESP Killer", Default = false, Callback = function(v) ESP.Killer = v end })
KillerESP:AddColorPicker("KillerESPColor", { Default = TeamColors.Killer, Title = "Killer Color", Callback = function(color) TeamColors.Killer = color end })
local ESPGeneratorToggle = VisualESPBox:AddCheckbox("ESPGenerator", { Text = "Generator", Default = false, Callback = function(v) ESP.Generator = v end })
ESPGeneratorToggle:AddColorPicker("GeneratorColor", { Default = GeneratorColor, Title = "Generator Color", Callback = function(v) GeneratorColor = v end })
local ESPSCPToggle = VisualESPBox:AddCheckbox("ESPSCP", { Text = "SCP", Default = false, Callback = function(v) ESP.SCP = v end })
ESPSCPToggle:AddColorPicker("SCPColor", { Default = SCPColor, Title = "SCP Color", Callback = function(v) SCPColor = v end })
local ESPPalletToggle = VisualESPBox:AddCheckbox("ESPPallet", { Text = "Pallet", Default = false, Callback = function(v) ESP.Pallet = v end })
ESPPalletToggle:AddColorPicker("PalletColor", { Default = PalletColor, Title = "Pallet Color", Callback = function(v) PalletColor = v end })
local ESPWindowToggle = VisualESPBox:AddCheckbox("ESPWindow", { Text = "Window", Default = false, Callback = function(v) ESP.Window = v end })
ESPWindowToggle:AddColorPicker("WindowColor", { Default = WindowColor, Title = "Window Color", Callback = function(v) WindowColor = v end })
VisualESPBox:AddSlider("ESPDistance", { Text = "ESP Radius", Default = 100, Min = 10, Max = 1000, Rounding = 0, Callback = function(v) ESP.Distance = v end })

VisualESPStatusBox:AddCheckbox("EnableStatus", { Text = "Enable Status ESP", Default = false, Callback = function(v) ESPStatus.Enabled = v end })
VisualESPStatusBox:AddCheckbox("ShowName", { Text = "Show Name", Default = true, Callback = function(v) ESPStatus.ShowName = v end })
VisualESPStatusBox:AddCheckbox("ShowItemESP", { Text = "Show Item", Default = true, Callback = function(v) ESPStatus.ShowItem = v end })
VisualESPStatusBox:AddCheckbox("ShowDistance", { Text = "Show Distance", Default = true, Callback = function(v) ESPStatus.ShowDistance = v end })
VisualESPStatusBox:AddCheckbox("ShowHealth", { Text = "Show Health", Default = false, Callback = function(v) ESPStatus.ShowHealth = v end })
VisualESPStatusBox:AddSlider("StatusRadius", { Text = "Status Radius", Default = 100, Min = 20, Max = 500, Rounding = 0, Callback = function(v) ESPStatus.Radius = v end })

VisualMorphBox:AddButton({ Text = "Apply Korless", Func = function() ApplyKorless(); VD_Notify("Morph Avatar", "Korless Applied", 2) end })

-- ===== SURVIVOR TAB =====
local SurvSkillBox = Tabs.Survivor:AddLeftGroupbox("Auto Skill Check", "check-circle")
local SurvGenBox = Tabs.Survivor:AddRightGroupbox("Bypass Generator", "zap")
local SurvAbilitiesBox = Tabs.Survivor:AddLeftGroupbox("Abilities", "shield")
local SurvFakePerksBox = Tabs.Survivor:AddRightGroupbox("Fake Perks", "star")

local AutoSkillToggle = SurvSkillBox:AddCheckbox("SkillCheck", {
    Text = "Auto Skill Check", Default = false,
    Callback = function(v)
        Auto.SkillCheck = v
        if v then startSkillCheck(); VD_Notify("Auto Skill Check", "Enabled", 2)
        else
            if Connections.SkillHeartbeat then Connections.SkillHeartbeat:Disconnect(); Connections.SkillHeartbeat = nil end
            VD_Notify("Auto Skill Check", "Disabled", 2)
        end
    end,
}):AddKeyPicker("AutoSkillKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state)
        Auto.SkillCheck = state
        if state then startSkillCheck(); VD_Notify("Auto Skill Check", "Enabled", 2)
        else
            if Connections.SkillHeartbeat then Connections.SkillHeartbeat:Disconnect(); Connections.SkillHeartbeat = nil end
            VD_Notify("Auto Skill Check", "Disabled", 2)
        end
    end,
})
SurvSkillBox:AddDropdown("SkillCheckModeDropdown", { Values = {"Legit", "Instant"}, Default = 1, Multi = false, Text = "Skill Check Mode", Callback = function(v) Auto.SkillCheckMode = v end })

local GenBypassToggle = SurvGenBox:AddCheckbox("GenBypassToggle", {
    Text = "Boost Gen Bypass", Default = false,
    Callback = function(v)
        setGenBypass(v)
        VD_Notify("Gen Bypass", v and (isMobile and "Enabled - Tekan tombol GEN di layar" or "Enabled - Tekan G saat prompt muncul") or "Disabled", 3)
    end,
}):AddKeyPicker("GenBypassKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) setGenBypass(state) end,
})

local AntiFallToggle = SurvAbilitiesBox:AddCheckbox("AntiFallDamage", {
    Text = "Anti Fall Damage", Default = false,
    Callback = function(v) PlayerMods.AntiFall = v; VD_Notify("Anti Fall Damage", v and "Enabled" or "Disabled", 2) end,
}):AddKeyPicker("AntiFallKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) PlayerMods.AntiFall = state end,
})
SurvAbilitiesBox:AddDivider()
local PalletDropToggle = SurvAbilitiesBox:AddCheckbox("PalletDrop", {
    Text = "Auto Drop Pallet", Default = false,
    Callback = function(v) Auto.PalletDrop = v end,
}):AddKeyPicker("PalletDropKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) Auto.PalletDrop = state end,
})
SurvAbilitiesBox:AddSlider("PalletDropDist", { Text = "Trigger Distance", Default = 6, Min = 3, Max = 30, Rounding = 0, Callback = function(v) Auto.PalletDropDist = v end })
SurvAbilitiesBox:AddDivider()
local FleeToggle = SurvAbilitiesBox:AddCheckbox("AutoFlee", {
    Text = "Auto Flee Killer", Default = false,
    Callback = function(v) Auto.Flee = v end,
}):AddKeyPicker("AutoFleeKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) Auto.Flee = state end,
})
SurvAbilitiesBox:AddSlider("FleeDist", { Text = "Flee Detect Distance", Default = 50, Min = 10, Max = 200, Rounding = 0, Callback = function(v) Auto.FleeDist = v end })
SurvAbilitiesBox:AddSlider("FleeCooldown", { Text = "Flee Cooldown", Default = 0.1, Min = 0.1, Max = 5, Rounding = 2, Callback = function(v) Auto.FleeCooldown = v end })
SurvAbilitiesBox:AddDivider()
local FirstPersonToggle = SurvAbilitiesBox:AddCheckbox("FirstPerson", {
    Text = "First Person (Survivor)", Default = false,
    Callback = function(v) VD.SURV_FirstPerson = v; if not v then RestoreFirstPersonCamera() end end,
}):AddKeyPicker("FirstPersonKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) VD.SURV_FirstPerson = state; if not state then RestoreFirstPersonCamera() end end,
})
SurvAbilitiesBox:AddDivider()
local SelfHealToggle = SurvAbilitiesBox:AddCheckbox("SelfHeal", {
    Text = "Self Heal", Default = false,
    Callback = function(v) setInstantHealSelf(v); SelfHeal_UpdateButton() end,
}):AddKeyPicker("SelfHealKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) setInstantHealSelf(state); SelfHeal_UpdateButton() end,
})
local HealAllToggle = SurvAbilitiesBox:AddCheckbox("HealAll", {
    Text = "Heal All", Default = false,
    Callback = function(v) setAutoHealAll(v) end,
}):AddKeyPicker("HealAllKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) setAutoHealAll(state) end,
})
local SelfHealBtnToggle = SurvAbilitiesBox:AddCheckbox("SelfHealBtn", {
    Text = "Show Self Heal Button", Default = false,
    Callback = function(v) if v then SelfHeal_CreateButton() else SelfHeal_DestroyButton() end end,
})
local SelfHealBtnLock = SurvAbilitiesBox:AddCheckbox("SelfHealBtnLock", {
    Text = "Lock Self Heal Button Drag", Default = false,
    Callback = function(v) SelfHeal_SetDragLocked(v) end,
})

SurvFakePerksBox:AddSlider("FP_Cooldown", { Text = "Cooldown (semua perks)", Default = 10, Min = 0, Max = 60, Rounding = 0, Suffix = "s", Callback = function(val) FP.CooldownTime = val end })
SurvFakePerksBox:AddDivider()
local FP_FlowstateToggle = SurvFakePerksBox:AddCheckbox("FP_Flowstate", {
    Text = "Flowstate", Default = false,
    Tooltip = "Trigger: Vault/Slide\nEffect: +5 speed for 3 seconds",
    Callback = function(val) FP_SetupFlowstate(val) end,
}):AddKeyPicker("FP_FlowstateKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) FP_SetupFlowstate(state) end,
})
local FP_QuickRecToggle = SurvFakePerksBox:AddCheckbox("FP_QuickRecovery", {
    Text = "Quick Recovery", Default = false,
    Tooltip = "Trigger: Selesai di-heal\nEffect: +6 speed for 3 seconds",
    Callback = function(val) FP_SetupQuickRecovery(val) end,
}):AddKeyPicker("FP_QuickRecoveryKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) FP_SetupQuickRecovery(state) end,
})
local FP_PerfLandToggle = SurvFakePerksBox:AddCheckbox("FP_PerfectLanding", {
    Text = "Perfect Landing", Default = false,
    Tooltip = "Trigger: Landing dari ketinggian\nEffect: +8 speed for 3 seconds",
    Callback = function(val) FP_SetupPerfectLanding(val) end,
}):AddKeyPicker("FP_PerfectLandingKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) FP_SetupPerfectLanding(state) end,
})
local FP_AdrenalineToggle = SurvFakePerksBox:AddCheckbox("FP_AdrenalineRush", {
    Text = "Adrenaline Rush", Default = false,
    Tooltip = "Trigger: HP drop ke 50\nEffect: +4 speed for 5 seconds",
    Callback = function(val) FP_SetupAdrenalineRush(val) end,
}):AddKeyPicker("FP_AdrenalineRushKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(state) FP_SetupAdrenalineRush(state) end,
})

-- ===== UI SETTINGS TAB =====
local SettingBox = Tabs.UISettings:AddLeftGroupbox("Menu", "wrench")

SettingBox:AddToggle("ShowCustomCursor", { Text = "Custom Cursor", Default = true, Callback = function(v) Library.ShowCustomCursor = v end })
SettingBox:AddDropdown("NotificationSide", { Values = {"Left","Right"}, Default = "Right", Text = "Notification Side", Callback = function(v) Library:SetNotifySide(v) end })
SettingBox:AddDropdown("DPIDropdown", { Values = {"50%","75%","85%","100%","125%","150%"}, Default = "85%", Text = "DPI Scale", Callback = function(v) v = v:gsub("%%",""); Library:SetDPIScale(tonumber(v)) end })
SettingBox:AddToggle("HeaderGlowToggle", { Text = "Glow AccentBar", Default = true, Callback = function(Value) Window:SetHeaderGlow(Value) end })
SettingBox:AddToggle("ShowProfile", { Text = "Show Profile", Default = true, Callback = function(Value) Window:SetProfileVisible(Value) end })
SettingBox:AddDivider()
SettingBox:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
SettingBox:AddButton("Unload script", function() Library:Unload() end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
ThemeManager:SetFolder("WisnuHub")
SaveManager:SetFolder("WisnuHub/configs")
SaveManager:BuildConfigSection(Tabs["UISettings"])
ThemeManager:ApplyToTab(Tabs["UISettings"])
SaveManager:LoadAutoloadConfig()

-- ============== SETUP PLAYERS =================
for _, p in pairs(Players:GetPlayers()) do SetupPlayer(p) end
Players.PlayerAdded:Connect(SetupPlayer)
task.spawn(function()
    while true do
        task.wait(5)
        for _, p in pairs(Players:GetPlayers()) do TryAttach(p) end
    end
end)

-- ============== MAIN LOOP =================
RunService.Heartbeat:Connect(function()
    HandleAutoPallet()
    UpdateNoSlowdown()
    MAWWW_AutoHook()
    MAWWW_BeatGameKiller()
end)

RunService.RenderStepped:Connect(function()
    updateParryCircle()
end)

-- ==================== NOTIFICATION ====================
Library:Notify({ Title = "Wisnu Hub", Description = "All Features Loaded!", Time = 3 })
