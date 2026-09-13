--[[
============================================================
  WISNU HUB - Multi Feature
  File 1/4 : Core + Parry + Killer (Part A)
============================================================
--]]

-- LOAD LIB
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

Library.Scheme.AccentColor = Color3.fromRGB(255, 0, 0)
Library.Scheme.BackgroundColor = Color3.fromRGB(10, 10, 10)
Library.Scheme.MainColor = Color3.fromRGB(15, 15, 15)
Library.Scheme.OutlineColor = Color3.fromRGB(255, 0, 0)
Library.Scheme.FontColor = Color3.fromRGB(255, 255, 255)

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

-- GLOBAL EXPOSE
_G.Wisnu = _G.Wisnu or {}
local W = _G.Wisnu

W.repo = repo
W.Library = Library
W.ThemeManager = ThemeManager
W.SaveManager = SaveManager
W.Players = Players
W.RunService = RunService
W.Workspace = Workspace
W.ReplicatedStorage = ReplicatedStorage
W.Lighting = Lighting
W.UserInputService = UserInputService
W.VirtualInputManager = VirtualInputManager
W.LocalPlayer = LocalPlayer
W.PlayerGui = PlayerGui
W.Camera = Camera
W.isMobile = isMobile

-- SHARED STATE
W.VD = {
    TOF_SilentAim = false, TOF_TargetMode = "Killer", TOF_Key = "Q", TOF_Laser = true, TOF_WallCheck = true, TOF_BlockKnocked = true,
    FLASH_SilentAim = false, FLASH_TargetPart = "Head", FLASH_Range = 120, FLASH_Laser = true, FLASH_Smooth = 0.35,
    KILLER_InfLakeMist = false, KILLER_InfPursuit = false, KILLER_NoSlowdown = false, KILLER_AutoHook = false,
    KILLER_BypassCooldown = false, KILLER_BypassLeap = false, KILLER_InfFrenzy = false, KILLER_AntiBlind = false,
    KILLER_FakeAttack = false, KILLER_BlockVaults = false, BEAT_Killer = false, SPEED_Value = 16, _KillerTarget = nil,
    DashLockEnabled = false, DashLockSmoothness = 0.3, DashLockDuration = 1.5, FreezeDuringDashLock = false,
    _DashLockActive = false, _DashLockTarget = nil, _DashLockConnection = nil,
    SURV_FirstPerson = false,
    SURV_WalkSpeedEnabled = false, SURV_WalkSpeedValue = 16,
    SURV_JumpPowerEnabled = false, SURV_JumpPowerValue = 50,
}
local VD = W.VD

function W.VD_Notify(title, desc, duration)
    if Library and Library.Notify then
        Library:Notify({ Title = title, Description = desc, Time = duration or 2 })
    end
end
local VD_Notify = W.VD_Notify

function W.GetSafeGuiParent()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    return LocalPlayer:FindFirstChild("PlayerGui")
end
local GetSafeGuiParent = W.GetSafeGuiParent

function W.GetRole()
    if not LocalPlayer.Team then return "Unknown" end
    local name = LocalPlayer.Team.Name
    if name == "Killer" then return "Killer"
    elseif name == "Survivors" then return "Survivor"
    else return "Spectator" end
end
local GetRole = W.GetRole

W.PlayerMods = { AntiFall = false, GodMode = false }
local PlayerMods = W.PlayerMods

-- INSTANT HEAL CONFIG
W.InstantHealSelf = false
W.AutoHealAll = false
W.InstantHealConnection = nil
W.AutoHealAllConnection = nil

W.SelfHealButton = { UI=nil, Button=nil, Stroke=nil, Dragging=false, DragStart=nil, DragStartPos=nil }
W.SelfHealButtonDragLocked = false

-- FAKE PERKS CONFIG
W.FP = {
    Conns = {}, ActiveBuffs = {}, HB = nil, LastBuffEnd = 0, CooldownTime = 10,
    FlowstateOn = false, QuickRecOn = false, PerfLandOn = false, AdrenalineOn = false,
}

-- AUTO STALK
W.AutoStalk = { Enabled = false, StalkRange = 150, Target = nil }

-- AUTO
W.Auto = {
    SkillCheck = false, SkillCheckMode = "Legit", PalletDrop = false, PalletDropDist = 6,
    Flee = false, FleeDist = 50, FleeCooldown = 0.1,
}

-- GEN BYPASS
W.GenBypass = {
    Enabled = false, Button = nil, UI = nil, Cache = {}, CacheTimer = 0, Processed = {},
    HotkeyCode = Enum.KeyCode.G, TriggerRange = 8,
}

-- ESP CONFIG
W.ESP = { Survivor=false, Killer=false, Generator=false, Pallet=false, Window=false, SCP=false, Distance=100 }
W.ESPStatus = { Enabled=false, ShowName=true, ShowDistance=true, ShowHealth=false, ShowItem=true, Radius=100 }
W.ESPItems = { ["Twist of Fate"]=true, ["Bandage"]=true, ["Motion Tracker"]=true, ["Gate"]=true, ["Shadow Clone"]=true, ["Parrying Dagger"]=true }
W.TeamColors = { Killer=Color3.fromRGB(255,0,0), Survivor=Color3.fromRGB(255,255,255) }
W.GeneratorColor = Color3.fromRGB(255,230,0)
W.PalletColor = Color3.fromRGB(74,255,181)
W.WindowColor = Color3.fromRGB(74,255,181)
W.SCPColor = Color3.fromRGB(255,0,0)

W.ESPCache = { Objects={}, Status={}, SCP={}, Generators={}, Windows={}, Pallets={} }
local ESPCache = W.ESPCache
local ESPItems = W.ESPItems
local TeamColors = W.TeamColors
local ESPStatus = W.ESPStatus

W.Config = {
    Surv_AutoParry = false, Surv_ParrySafety = false, Surv_ParryAggressive = false,
    Surv_ParryCircle = true, Surv_ParryRadius = 15, Surv_ParryFace = 0.7,
    Surv_AutoCrouch = false, Ignored_Skills_List = {},
}
W.State = {
    ParryCooldown = false, ParryCooldownTime = 60, AutoParryAdornment = nil,
    lastParry = 0, busy = false, UsedPallets = {}, LastFlee = 0,
}
W.Timers = { lastESPUpdate = 0, lastPalletScan = 0, lastPalletDrop = 0, lastVaultBlock = 0 }
W.Connections = { SkillHeartbeat = nil, Stalk = nil, WalkSpeed = nil }

local Config = W.Config
local State = W.State
local Timers = W.Timers
local Connections = W.Connections

-- VALID PARRY IDS
W.VALID_PARRY_IDS = {
    ["122812055447896"]="Veil lunge", ["133963973694098"]="Mayers Basic", ["117042998468241"]="Mayers lunge",
    ["135002183282873"]="cure lunge", ["121216847022485"]="cure Basic", ["132817836308238"]="Jeff Basic",
    ["129784271201071"]="Jeff lunge", ["82666958311998"]="Jeff Frenzy", ["78432063483146"]="Abyssal Basic",
    ["118907603246885"]="Abyssal lunge", ["139369275981139"]="Jason Basic", ["110355011987939"]="Jason lunge",
    ["111920872708571"]="Masked Basic", ["105374834496520"]="Masked lunge", ["138720291317243"]="Masked Tony",
    ["106871536134254"]="Masked Alex", ["130593238885843"]="Masked Cobra", ["115244153053858"]="Masked Cobra lunge",
    ["74968262036854"]="Hidden Basic", ["113255068724446"]="Hidden lunge", ["98163597193511"]="Hidden S1",
    ["80411309607666"]="Abyssal S1"
}
local VALID_PARRY_IDS = W.VALID_PARRY_IDS
local Attached = {}
W.Attached = Attached

function W.IsSafeToParry(char)
    if not Config.Surv_ParrySafety then return true end
    if not char then return false end
    local i = char:FindFirstChild("CheckInterractable")
    if i then
        if i:GetAttribute("isVaulting")==true then return false end
        if i:GetAttribute("isRepairing")==true then return false end
        if i:GetAttribute("isUnhooking")==true then return false end
        if i:GetAttribute("isHealing")==true then return false end
        if i:GetAttribute("isSliding")==true then return false end
    end
    return true
end
local IsSafeToParry = W.IsSafeToParry

function W.TriggerCrouch()
    pcall(function()
        local b = LocalPlayer:FindFirstChild("PlayerGui")
        for seg in string.gmatch("Survivor-mob.Controls.crouch.icon","[^%.]+") do
            if b then b = b:FindFirstChild(seg) end
        end
        if b and b:IsA("GuiObject") and b.Visible and b.Parent and b.Parent:IsA("GuiButton") then
            local btn = b.Parent
            if UserInputService.TouchEnabled and type(firesignal)=="function" then
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

function W.IsDowned(char)
    if not char then return false end
    return char:GetAttribute("Knocked")==true or char:GetAttribute("IsHooked")==true
end
local IsDowned = W.IsDowned

function W.IsKiller(p) return p and p.Team and p.Team.Name=="Killer" end
function W.IsSurvivor(p) return p and p.Team and p.Team.Name=="Survivors" end
local IsKiller = W.IsKiller
local IsSurvivor = W.IsSurvivor

function W.tapMobileParryButton()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return end
    local sm = pg:FindFirstChild("Survivor-mob")
    local pb = sm and sm:FindFirstChild("Controls") and sm.Controls:FindFirstChild("Gui-mob")
    if pb and pb.Visible and firesignal then
        pcall(function()
            firesignal(pb.MouseButton1Down); task.wait(0.01); firesignal(pb.MouseButton1Up)
        end)
    else
        pcall(function()
            if mouse2click then mouse2click(); return end
            if mouse2press and mouse2release then mouse2press(); task.wait(0.01); mouse2release(); return end
            if MouseButton2Click then MouseButton2Click(); return end
            VirtualInputManager:SendMouseButtonEvent(0,0,1,true,game,0)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(0,0,1,false,game,0)
        end)
    end
end

function W.ExecuteParry()
    if State.ParryCooldown then return end
    pcall(function()
        local pr = ReplicatedStorage:FindFirstChild("Remotes")
            and ReplicatedStorage.Remotes:FindFirstChild("Items")
            and ReplicatedStorage.Remotes.Items:FindFirstChild("Parrying Dagger")
            and ReplicatedStorage.Remotes.Items["Parrying Dagger"]:FindFirstChild("parry")
        if pr then for i=1,10 do pr:FireServer() end end
        task.spawn(W.tapMobileParryButton)
    end)
end
local ExecuteParry = W.ExecuteParry

function W.AttachParrySensor(kChar)
    if not kChar or Attached[kChar] then return end
    Attached[kChar] = true
    local hum = kChar:FindFirstChild("Humanoid") or kChar:WaitForChild("Humanoid",5)
    if not hum then return end
    local anim = hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator",5)
    if not anim then return end

    hum.ChildAdded:Connect(function(c)
        if c:IsA("Animator") then Attached[kChar]=nil; W.AttachParrySensor(kChar) end
    end)
    kChar.AncestryChanged:Connect(function(_,p)
        if not p then Attached[kChar]=nil end
    end)

    anim.AnimationPlayed:Connect(function(track)
        local animId = track.Animation and track.Animation.AnimationId or ""
        local id = animId:match("%d+")
        local name = VALID_PARRY_IDS[id]
        if not name then return end

        if id=="80411309607666" and Config.Surv_AutoCrouch then
            local mc = LocalPlayer.Character
            if IsDowned(mc) then return end
            local mh = mc and mc:FindFirstChild("HumanoidRootPart")
            local kh = kChar:FindFirstChild("HumanoidRootPart")
            if mh and kh then
                local d = (mh.Position - kh.Position).Magnitude
                if d <= 40 then W.TriggerCrouch() end
            end
            return
        end

        if not Config.Surv_AutoParry then return end
        if State.ParryCooldown then return end
        if Config.Ignored_Skills_List[name] then return end

        local mc = LocalPlayer.Character
        if IsDowned(mc) or not IsSafeToParry(mc) then return end
        local mh = mc and mc:FindFirstChild("HumanoidRootPart")
        local kh = kChar:FindFirstChild("HumanoidRootPart")
        if not mh or not kh then return end

        local startDist = (mh.Position - kh.Position).Magnitude
        if Config.Surv_ParryAggressive then
            local ar = 12
            local dr = Config.Surv_ParryRadius + 5
            if startDist > dr then return end
            if startDist <= ar then ExecuteParry()
            else
                local tracker
                local t0 = os.clock()
                tracker = RunService.Heartbeat:Connect(function()
                    if os.clock()-t0 >= 1.5 or State.ParryCooldown or not mh or not kh or IsDowned(mc) then
                        if tracker then tracker:Disconnect() end
                        return
                    end
                    if (mh.Position - kh.Position).Magnitude <= ar then
                        ExecuteParry()
                        if tracker then tracker:Disconnect() end
                    end
                end)
            end
        else
            if startDist > Config.Surv_ParryRadius then return end
            local mf = Vector3.new(mh.Position.X,0,mh.Position.Z)
            local kf = Vector3.new(kh.Position.X,0,kh.Position.Z)
            local fd = mf - kf
            if fd.Magnitude > 0 then
                local fdir = fd.Unit
                local kl = Vector3.new(kh.CFrame.LookVector.X,0,kh.CFrame.LookVector.Z).Unit
                if kl:Dot(fdir) < Config.Surv_ParryFace then return end
            end
            ExecuteParry()
        end
    end)
end

function W.TryAttach(p)
    if p ~= LocalPlayer and IsKiller(p) and p.Character then W.AttachParrySensor(p.Character) end
end

function W.SetupPlayer(p)
    if p == LocalPlayer then return end
    p.CharacterAdded:Connect(function() W.TryAttach(p) end)
    p:GetPropertyChangedSignal("Team"):Connect(function() W.TryAttach(p) end)
    if p.Character then W.TryAttach(p) end
end

-- HELPERS
function W.GetRoot()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end
local GetRoot = W.GetRoot

function W.GetNearestKiller()
    local root = GetRoot()
    if not root then return nil, math.huge end
    local closest, shortest = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Team and plr.Team.Name=="Killer" and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - root.Position).Magnitude
                if d < shortest then shortest=d; closest=hrp end
            end
        end
    end
    return closest, shortest
end
local GetNearestKiller = W.GetNearestKiller

function W.GetFarthestGeneratorPoint(kRoot)
    if not kRoot then return nil end
    local best, farthest = nil, 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.match(obj.Name,"^GeneratorPoint%d+$") then
            local d = (obj.Position - kRoot.Position).Magnitude
            if d > farthest then farthest=d; best=obj end
        end
    end
    return best
end
local GetFarthestGeneratorPoint = W.GetFarthestGeneratorPoint

-- ANTI FALL DAMAGE
function W.SetupAntiFallDamage()
    pcall(function()
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        if not r then return end
        local m = r:FindFirstChild("Mechanics")
        local fe = m and m:FindFirstChild("Fall")
        if not (fe and fe:IsA("RemoteEvent")) then return end
        local ok, mt = pcall(function() return getrawmetatable(game) end)
        if ok and mt and setreadonly then
            pcall(function()
                setreadonly(mt, false)
                local old = mt.__namecall
                mt.__namecall = newcclosure(function(self, ...)
                    if not checkcaller() and PlayerMods.AntiFall and self == fe then
                        if getnamecallmethod()=="FireServer" then return nil end
                    end
                    return old(self, ...)
                end)
                setreadonly(mt, true)
            end)
        end
    end)
end
W.SetupAntiFallDamage()

-- NO SLOWDOWN
function W.UpdateNoSlowdown()
    if not VD.KILLER_NoSlowdown or GetRole() ~= "Killer" then return end
    local c = LocalPlayer.Character
    if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    if h and h.WalkSpeed < 16 then h.WalkSpeed = VD.SPEED_Value or 16 end
end
local UpdateNoSlowdown = W.UpdateNoSlowdown

function W.SetupAntiStunSlowdown()
    if getgenv().MAWWW_AntiStunHooked then return end
    getgenv().MAWWW_AntiStunHooked = true
    pcall(function()
        local ok, mt = pcall(function() return getrawmetatable(game) end)
        if ok and mt and setreadonly then
            pcall(function()
                setreadonly(mt, false)
                local oldNI = mt.__newindex
                local g = getgenv()
                mt.__newindex = newcclosure(function(t,k,v)
                    if k=="WalkSpeed" or k=="Anchored" then
                        if not checkcaller() and g.VD and g.VD.KILLER_NoSlowdown and W.GetRole()=="Killer" then
                            if k=="WalkSpeed" and typeof(v)=="number" and v<16 and typeof(t)=="Instance" and t:IsA("Humanoid") then
                                return oldNI(t,k,g.VD.SPEED_Value or 16)
                            end
                            if k=="Anchored" and v==true and typeof(t)=="Instance" and t:IsA("BasePart") and t.Name=="HumanoidRootPart" then
                                return oldNI(t,k,false)
                            end
                        end
                    end
                    return oldNI(t,k,v)
                end)
                setreadonly(mt, true)
            end)
        end
    end)
end
task.spawn(W.SetupAntiStunSlowdown)

-- AUTO HOOK
W.MAWWW_Cache = W.MAWWW_Cache or { Hooks = {} }
local function MAWWW_ScanHooks()
    local hooks = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name=="Hook" or obj.Name:lower():find("hook")) then
            local p = obj:FindFirstChild("HookPoint") or obj:FindFirstChild("HookHitbox") or obj:FindFirstChildWhichIsA("BasePart")
            if p then table.insert(hooks, {model=obj, part=p}) end
        end
    end
    W.MAWWW_Cache.Hooks = hooks
end
task.spawn(function() while true do task.wait(5); pcall(MAWWW_ScanHooks) end end)
MAWWW_ScanHooks()

local IsAutoHooking = false
function W.MAWWW_AutoHook()
    if not VD.KILLER_AutoHook or GetRole()~="Killer" then return end
    if IsAutoHooking then return end
    local root = GetRoot()
    if not root then return end
    local char = LocalPlayer.Character
    local carry = false
    if char then carry = char:GetAttribute("IsCarrying") or char:GetAttribute("isCarrying") end

    if carry then
        local occ = {}
        for _,v in ipairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character then
                local hk = v.Character:GetAttribute("IsHooked") or v.Character:GetAttribute("isHooked")
                local hrp = v.Character:FindFirstChild("HumanoidRootPart")
                if hk and hrp then table.insert(occ, hrp.Position) end
            end
        end
        local bestH, bestD = nil, math.huge
        for _,h in ipairs(W.MAWWW_Cache.Hooks or {}) do
            if h.part then
                local isOcc = false
                for _,op in ipairs(occ) do if (h.part.Position-op).Magnitude<10 then isOcc=true; break end end
                if not isOcc then
                    local hd = (h.part.Position - root.Position).Magnitude
                    if hd < bestD then bestD=hd; bestH=h end
                end
            end
        end
        if bestH then
            IsAutoHooking = true
            task.spawn(function()
                root.CFrame = CFrame.new(bestH.part.Position + Vector3.new(0,3,0))
                task.wait(0.4)
                pcall(function()
                    local cf = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Carry")
                    local ev = cf and cf:FindFirstChild("HookEvent")
                    local cm = cf and cf:FindFirstChild("HookCommit")
                    local hp = nil
                    if bestH.model then hp = bestH.model:FindFirstChild("HookPoint") or bestH.model:FindFirstChild("HookHitbox") end
                    if not hp then hp = bestH.part end
                    if ev and ev:IsA("RemoteEvent") then ev:FireServer(hp) end
                    if cm and cm:IsA("RemoteEvent") then cm:FireServer(hp) end
                end)
                task.wait(0.5)
                IsAutoHooking = false
            end)
        end
        return
    end

    local closest, cdist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player~=LocalPlayer and IsSurvivor(player) and player.Character then
            local tr = player.Character:FindFirstChild("HumanoidRootPart")
            local hu = player.Character:FindFirstChildOfClass("Humanoid")
            if tr and hu then
                local pct = (hu.MaxHealth>0) and (hu.Health/hu.MaxHealth) or 0
                if pct<=0.25 and pct>0 then
                    local isHooked = false
                    for _,hh in ipairs(W.MAWWW_Cache.Hooks or {}) do
                        if hh.part and (hh.part.Position-tr.Position).Magnitude<4.5 then isHooked=true; break end
                    end
                    if not isHooked then
                        local d = (tr.Position-root.Position).Magnitude
                        if d < cdist then cdist=d; closest=tr end
                    end
                end
            end
        end
    end
    if closest then
        local occ = {}
        for _,v in ipairs(Players:GetPlayers()) do
            if v~=LocalPlayer and v.Character then
                local hk = v.Character:GetAttribute("IsHooked") or v.Character:GetAttribute("isHooked")
                local hrp = v.Character:FindFirstChild("HumanoidRootPart")
                if hk and hrp then table.insert(occ, hrp.Position) end
            end
        end
        local bestH, bestD = nil, math.huge
        for _,h in ipairs(W.MAWWW_Cache.Hooks or {}) do
            if h.part then
                local isOcc = false
                for _,op in ipairs(occ) do if (h.part.Position-op).Magnitude<10 then isOcc=true; break end end
                if not isOcc then
                    local hd = (h.part.Position - closest.Position).Magnitude
                    if hd < bestD then bestD=hd; bestH=h end
                end
            end
        end
        if bestH then
            IsAutoHooking = true
            task.spawn(function()
                root.CFrame = CFrame.new(closest.Position + Vector3.new(0,3,0), closest.Position)
                task.wait(0.3)
                pcall(function()
                    local cf = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Carry")
                    local ev = cf and cf:FindFirstChild("CarrySurvivorEvent")
                    if ev and ev:IsA("RemoteEvent") then ev:FireServer(closest.Parent) end
                end)
                task.wait(0.8)
                local c2 = false
                local mc = LocalPlayer.Character
                if mc then c2 = mc:GetAttribute("IsCarrying") or mc:GetAttribute("isCarrying") end
                if c2 and root and root.Parent then
                    root.CFrame = CFrame.new(bestH.part.Position + Vector3.new(0,3,0))
                    task.wait(0.4)
                    pcall(function()
                        local cf = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Carry")
                        local ev = cf and cf:FindFirstChild("HookEvent")
                        local cm = cf and cf:FindFirstChild("HookCommit")
                        local hp = nil
                        if bestH.model then hp = bestH.model:FindFirstChild("HookPoint") or bestH.model:FindFirstChild("HookHitbox") end
                        if not hp then hp = bestH.part end
                        if ev and ev:IsA("RemoteEvent") then ev:FireServer(hp) end
                        if cm and cm:IsA("RemoteEvent") then cm:FireServer(hp) end
                    end)
                end
                task.wait(1)
                IsAutoHooking = false
            end)
        end
    end
end
local MAWWW_AutoHook = W.MAWWW_AutoHook

-- PLACEHOLDER FUNCS (implemented in file 2/3)
W.Placeholder = {}

print("[Wisnu Hub] File 1/4 loaded ✓")
-- PART 1 END

--[[
============================================================
  WISNU HUB - File 2/4 : Bypass Cooldowns + Beat Game + Heal
============================================================
--]]

local W = _G.Wisnu
if not W then warn("[Wisnu Hub] File 1 harus dijalankan dulu!") return end

local Players = W.Players
local RunService = W.RunService
local ReplicatedStorage = W.ReplicatedStorage
local LocalPlayer = W.LocalPlayer
local Library = W.Library
local VD = W.VD
local VD_Notify = W.VD_Notify
local GetRole = W.GetRole
local GetRoot = W.GetRoot
local IsSurvivor = W.IsSurvivor

-- BYPASS COOLDOWN HIDDEN
getgenv().MAWWW_HiddenLeapBypassThread = nil
function MAWWW_StartHiddenCooldownBypass()
    if getgenv().MAWWW_HiddenLeapBypassThread then return end
    getgenv().MAWWW_HiddenLeapBypassThread = task.spawn(function()
        local lf, m2f
        local function scan()
            pcall(function()
                for _,v in pairs(getgc(true)) do
                    if type(v)=="function" and islclosure(v) then
                        local info; pcall(function() info=debug.getinfo(v) end)
                        if info then
                            if info.name=="tryActivate" then lf=v
                            elseif info.name=="playM2Animation" then m2f=v end
                        end
                    end
                    if lf and m2f then break end
                end
            end)
        end
        scan()
        local last = os.clock()
        while task.wait(0.1) do
            if not VD.KILLER_BypassLeap then break end
            if not (lf and m2f) then
                local now = os.clock()
                if now-last>=2 then last=now; scan() end
            end
            if lf then pcall(function()
                for i,val in pairs(debug.getupvalues(lf)) do
                    if type(val)=="boolean" and val==true then debug.setupvalue(lf,i,false) end
                end
            end) end
            if m2f then pcall(function()
                for i,val in pairs(debug.getupvalues(m2f)) do
                    if type(val)=="boolean" and val==true then debug.setupvalue(m2f,i,false) end
                end
            end) end
        end
        getgenv().MAWWW_HiddenLeapBypassThread = nil
    end)
end
W.MAWWW_StartHiddenCooldownBypass = MAWWW_StartHiddenCooldownBypass
function MAWWW_StopHiddenCooldownBypass() end
W.MAWWW_StopHiddenCooldownBypass = MAWWW_StopHiddenCooldownBypass

-- BYPASS JEFF
getgenv().MAWWW_JeffCooldownBypassThread = nil
function MAWWW_StartJeffCooldownBypass()
    if getgenv().MAWWW_JeffCooldownBypassThread then return end
    getgenv().MAWWW_JeffCooldownBypassThread = task.spawn(function()
        while task.wait() do
            if not VD.KILLER_InfFrenzy then break end
            pcall(function()
                local c = LocalPlayer.Character
                if c and c:GetAttribute("Frenzy") ~= true then c:SetAttribute("Frenzy", true) end
            end)
        end
        getgenv().MAWWW_JeffCooldownBypassThread = nil
    end)
end
W.MAWWW_StartJeffCooldownBypass = MAWWW_StartJeffCooldownBypass
function MAWWW_StopJeffCooldownBypass()
    pcall(function()
        local c = LocalPlayer.Character
        if c and c:GetAttribute("Frenzy")==true then
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
W.MAWWW_StopJeffCooldownBypass = MAWWW_StopJeffCooldownBypass

-- BYPASS ABYSS
getgenv().MAWWW_AbyssCooldownBypassConnection = nil
getgenv().MAWWW_CorruptHandlerFunc = nil
function MAWWW_StartAbyssCooldownBypass()
    if not getgenv().MAWWW_CorruptHandlerFunc then
        for _,v in pairs(getgc(true)) do
            if type(v)=="function" and islclosure(v) then
                local ct = debug.getconstants(v)
                if table.find(ct,"corrupt") and table.find(ct,"Immobile") then
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
            local uv = debug.getupvalues(getgenv().MAWWW_CorruptHandlerFunc)
            for idx,val in pairs(uv) do
                if type(val)=="boolean" and val==false then debug.setupvalue(getgenv().MAWWW_CorruptHandlerFunc, idx, true) end
            end
        end
    end)
end
W.MAWWW_StartAbyssCooldownBypass = MAWWW_StartAbyssCooldownBypass
function MAWWW_StopAbyssCooldownBypass()
    if getgenv().MAWWW_AbyssCooldownBypassConnection then
        getgenv().MAWWW_AbyssCooldownBypassConnection:Disconnect()
        getgenv().MAWWW_AbyssCooldownBypassConnection = nil
    end
end
W.MAWWW_StopAbyssCooldownBypass = MAWWW_StopAbyssCooldownBypass

-- BYPASS SLASHER
getgenv().MAWWW_SlasherCooldownBypassThread = nil
function MAWWW_StartSlasherCooldownBypass()
    if getgenv().MAWWW_SlasherCooldownBypassThread then return end
    pcall(function()
        local b = true
        local mt = debug.getmetatable(b)
        if not mt then mt={}; debug.setmetatable(b,mt) end
        if setreadonly then setreadonly(mt,false) end
        mt.__div = function() return 0 end
        mt.__mul = function() return 0 end
        mt.__add = function() return 0 end
        mt.__sub = function() return 0 end
        if setreadonly then setreadonly(mt,true) end
    end)
    getgenv().MAWWW_SlasherCooldownBypassThread = task.spawn(function()
        local tf, ph = nil, nil
        local function scan()
            pcall(function()
                for _,v in pairs(getgc(true)) do
                    if type(v)=="function" and islclosure(v) then
                        local cs = debug.getconstants(v)
                        local hO,hL,hA,hT,hP,hW = false,false,false,false,false,false
                        for _,c in pairs(cs) do
                            if c=="Offset" then hO=true end
                            if c=="Linear" then hL=true end
                            if c=="action" then hA=true end
                            if c=="TweenInfo" then hT=true end
                            if c=="Pursuit" then hP=true end
                            if c=="WalkSpeed" then hW=true end
                        end
                        if hO and hL and hA and hT and not hP then tf=v end
                        if hP and hT and hA and hW then ph=v end
                    end
                    if tf and ph then break end
                end
            end)
        end
        scan()
        local last = os.clock()
        while task.wait(0.1) do
            if not VD.KILLER_InfLakeMist and not VD.KILLER_InfPursuit then break end
            if not (tf and ph) then
                if os.clock()-last>=2 then scan(); last=os.clock() end
            end
            if tf and VD.KILLER_InfLakeMist then
                pcall(function() debug.setupvalue(tf,6,false); debug.setupvalue(tf,10,false) end)
            end
            if ph and VD.KILLER_InfPursuit then
                pcall(function() debug.setupvalue(ph,5,false); debug.setupvalue(ph,6,false) end)
            end
        end
        getgenv().MAWWW_SlasherCooldownBypassThread = nil
    end)
end
W.MAWWW_StartSlasherCooldownBypass = MAWWW_StartSlasherCooldownBypass
function MAWWW_StopSlasherCooldownBypass()
    pcall(function()
        local j = ReplicatedStorage:FindFirstChild("Remotes")
            and ReplicatedStorage.Remotes:FindFirstChild("Killers")
            and ReplicatedStorage.Remotes.Killers:FindFirstChild("Jason")
        if j then
            if not VD.KILLER_InfLakeMist then local lm=j:FindFirstChild("LakeMist"); if lm then lm:FireServer(false) end end
            if not VD.KILLER_InfPursuit then local ps=j:FindFirstChild("Pursuit"); if ps then ps:FireServer(false) end end
        end
    end)
end
W.MAWWW_StopSlasherCooldownBypass = MAWWW_StopSlasherCooldownBypass

-- ANTI BLIND
function W.SetupAntiBlind()
    pcall(function()
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        local i = r and r:FindFirstChild("Items")
        local fl = i and i:FindFirstChild("Flashlight")
        local gb = fl and fl:FindFirstChild("GotBlinded")
        if not (gb and gb:IsA("RemoteEvent")) then return end
        local ok, mt = pcall(function() return getrawmetatable(game) end)
        if ok and mt and setreadonly then
            pcall(function()
                setreadonly(mt, false)
                local old = mt.__namecall
                local g = getgenv()
                mt.__namecall = newcclosure(function(self, ...)
                    if not checkcaller() and g.VD and g.VD.KILLER_AntiBlind and self==gb then
                        if getnamecallmethod()=="FireServer" and W.GetRole()=="Killer" then return nil end
                    end
                    return old(self, ...)
                end)
                setreadonly(mt, true)
            end)
        end
    end)
end
W.SetupAntiBlind()

-- BLOCK ALL VAULTS
function W.HandleBlockVaults()
    if not VD.KILLER_BlockVaults then return end
    if GetRole() ~= "Killer" then return end
    local r = ReplicatedStorage:FindFirstChild("Remotes")
    local ve = r and r:FindFirstChild("Window") and r.Window:FindFirstChild("VaultEvent")
    if not ve then return end
    local map = workspace:FindFirstChild("Map")
    local vf = map and map:FindFirstChild("Vaults")
    if vf then
        for _,v in ipairs(vf:GetChildren()) do
            for _,p in ipairs(v:GetChildren()) do
                if p:IsA("BasePart") then pcall(function() ve:FireServer(p,true) end) end
            end
        end
    else
        for w in pairs(W.ESPCache.Windows) do
            if w and w.Parent then
                for _,ch in ipairs(w:GetDescendants()) do
                    if ch:IsA("BasePart") then pcall(function() ve:FireServer(ch,true) end) end
                end
            end
        end
    end
end
local HandleBlockVaults = W.HandleBlockVaults

-- AUTO STALK
function W.getClosestSurvivorForStalk()
    local root = GetRoot()
    if not root then return nil end
    local c, s = nil, math.huge
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            local hr = p.Character:FindFirstChild("HumanoidRootPart")
            if h and hr and h.Health > 30 then
                local d = (hr.Position - root.Position).Magnitude
                if d <= W.AutoStalk.StalkRange and d < s then s=d; c=p end
            end
        end
    end
    return c
end

function W.startAutoStalk()
    if W.Connections.Stalk then return end
    W.Connections.Stalk = RunService.Heartbeat:Connect(function()
        if not W.AutoStalk.Enabled then return end
        local t = W.getClosestSurvivorForStalk()
        if not t or not t.Character then return end
        local se = ReplicatedStorage:FindFirstChild("Remotes", true)
            and ReplicatedStorage.Remotes:FindFirstChild("Killers", true)
            and ReplicatedStorage.Remotes.Killers:FindFirstChild("Stalker", true)
            and ReplicatedStorage.Remotes.Killers.Stalker:FindFirstChild("StartStalking")
        if se then pcall(function() se:FireServer(t) end) end
    end)
end
function W.stopAutoStalk()
    if W.Connections.Stalk then W.Connections.Stalk:Disconnect(); W.Connections.Stalk = nil end
end

-- BEAT GAME KILLER
function W.MAWWW_BeatGameKiller()
    if not VD.BEAT_Killer then VD._KillerTarget = nil; return end
    if GetRole() ~= "Killer" then VD._KillerTarget = nil; return end
    local root = GetRoot()
    if not root then return end

    local target = VD._KillerTarget
    local need = true
    if target and target.Character then
        local tr = target.Character:FindFirstChild("HumanoidRootPart")
        local th = target.Character:FindFirstChildOfClass("Humanoid")
        if tr and th and th.MaxHealth > 0 and (th.Health/th.MaxHealth) > 0.25 then
            need = false
        else
            VD._KillerTarget = nil
        end
    end

    if need then
        local survs = {}
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and IsSurvivor(p) and p.Character then
                local pr = p.Character:FindFirstChild("HumanoidRootPart")
                local ph = p.Character:FindFirstChildOfClass("Humanoid")
                if pr and ph and ph.MaxHealth>0 and (ph.Health/ph.MaxHealth)>0.25 then table.insert(survs,p) end
            end
        end
        if #survs > 0 then
            local c, cd = nil, math.huge
            for _,p in ipairs(survs) do
                local pr = p.Character:FindFirstChild("HumanoidRootPart")
                local d = (pr.Position-root.Position).Magnitude
                if d < cd then cd=d; c=p end
            end
            VD._KillerTarget = c
            target = c
        else
            VD._KillerTarget = nil; return
        end
    end

    if not target or not target.Character then return end
    local tr = target.Character:FindFirstChild("HumanoidRootPart")
    local th = target.Character:FindFirstChildOfClass("Humanoid")
    if not tr or not th then VD._KillerTarget=nil; return end
    if th.MaxHealth<=0 or (th.Health/th.MaxHealth)<=0.25 then VD._KillerTarget=nil; return end

    for _,part in ipairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then pcall(function() part.CanCollide=false end) end
    end

    local dir = (root.Position - tr.Position).Unit
    if dir.Magnitude ~= dir.Magnitude then dir = Vector3.new(1,0,0) end
    root.CFrame = CFrame.new(tr.Position + dir*3 + Vector3.new(0,1,0), tr.Position)

    pcall(function()
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        local a = r and r:FindFirstChild("Attacks")
        local ba = a and a:FindFirstChild("BasicAttack")
        if ba then ba:FireServer(false) end
    end)
end
local MAWWW_BeatGameKiller = W.MAWWW_BeatGameKiller

-- FAKE ATTACK (Counter Auto Parry)
getgenv().MAWWW_FakeAttackThread = nil
function W.MAWWW_ToggleFakeAttack(enabled)
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
            local c = LocalPlayer.Character
            if c then
                local A = c:FindFirstChild("Humanoid") and c.Humanoid:FindFirstChild("Animator")
                if A then
                    local mr = c:FindFirstChild("HumanoidRootPart")
                    local near = false
                    if mr then
                        for _,p in ipairs(Players:GetPlayers()) do
                            if p~=LocalPlayer and p.Team and p.Team.Name=="Survivors" then
                                local r = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                                if r and (mr.Position-r.Position).Magnitude<=15 then near=true; break end
                            end
                        end
                    end
                    if near then
                        pcall(function()
                            local ba = Instance.new("Animation")
                            ba.AnimationId = "rbxassetid://117042998468241"
                            local tr = A:LoadAnimation(ba)
                            tr:Play(); tr:AdjustWeight(0); task.wait(0.05); tr:Stop()
                        end)
                    end
                end
            end
            task.wait(0.3)
        end
        getgenv().MAWWW_FakeAttackThread = nil
    end)
end
local MAWWW_ToggleFakeAttack = W.MAWWW_ToggleFakeAttack

-- HEAL LOGIC
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
            if h.Health >= h.MaxHealth*0.9 then
                if ha then ha=false; W.doSelfHealFalse() end
                return
            end
            if ha then
                local ci = c:FindFirstChild("CheckInterractable")
                if ci and not ci:GetAttribute("isHealing") then ha=false end
            end
            if not ha then ha=true; W.doSelfHealTrue() end
        end)
    else
        if W.InstantHealConnection then W.InstantHealConnection:Disconnect(); W.InstantHealConnection=nil end
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
            for _,p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    local hu = p.Character:FindFirstChildOfClass("Humanoid")
                    if hu and hu.Health>0 and hu.Health<hu.MaxHealth*0.9 and hrp then
                        if ah[p] then
                            local c = LocalPlayer.Character
                            local ci = c and c:FindFirstChild("CheckInterractable")
                            if ci and not ci:GetAttribute("isHealing") then ah[p]=nil end
                        end
                        if not ah[p] then ah[p]=true; W.doOthersHealTrue(p) end
                    else
                        if ah[p] then ah[p]=nil; W.doOthersHealFalse(p) end
                    end
                else
                    if ah[p] then ah[p]=nil; pcall(function() W.doOthersHealFalse(p) end) end
                end
            end
        end)
    else
        if W.AutoHealAllConnection then W.AutoHealAllConnection:Disconnect(); W.AutoHealAllConnection=nil end
    end
end

print("[Wisnu Hub] File 2/4 loaded ✓")
-- PART 2 END

--[[
============================================================
  WISNU HUB - File 3/4 : Fake Perks + Movement + Gen
============================================================
--]]

local W = _G.Wisnu
if not W then warn("[Wisnu Hub] File 1 harus dijalankan dulu!") return end

local Players = W.Players
local RunService = W.RunService
local ReplicatedStorage = W.ReplicatedStorage
local LocalPlayer = W.LocalPlayer
local UserInputService = W.UserInputService
local VD = W.VD
local VD_Notify = W.VD_Notify
local GetRoot = W.GetRoot
local GetNearestKiller = W.GetNearestKiller
local GetFarthestGeneratorPoint = W.GetFarthestGeneratorPoint
local isMobile = W.isMobile
local ESPCache = W.ESPCache

-- FAKE PERKS CORE
local FP = W.FP
local function FP_Char() return LocalPlayer.Character end
local function FP_Hum() local c = FP_Char(); return c and c:FindFirstChildOfClass("Humanoid") end

local function FP_GetTotal()
    local t = 0
    for _,b in pairs(FP.ActiveBuffs) do
        if tick() < b.endTime then t = t + b.amt end
    end
    return t
end

local function FP_Apply()
    local c, h = FP_Char(), FP_Hum()
    local tb = FP_GetTotal()
    if c then
        if tb > 0 then c:SetAttribute("speedboost", 1+(tb/14))
        else c:SetAttribute("speedboost", 1) end
    end
    if h and tb > 0 then h.WalkSpeed = 16 + tb end
end

local function FP_EnsureHB()
    if FP.HB then return end
    FP.HB = RunService.Heartbeat:Connect(function()
        local exp = {}
        for n,b in pairs(FP.ActiveBuffs) do
            if tick() >= b.endTime then table.insert(exp,n) end
        end
        for _,n in ipairs(exp) do FP.ActiveBuffs[n]=nil end
        if #exp > 0 and FP_GetTotal()<=0 then FP.LastBuffEnd = tick() end
        FP_Apply()
        if FP_GetTotal()<=0 and next(FP.ActiveBuffs)==nil then
            if FP.HB then FP.HB:Disconnect(); FP.HB=nil end
            local c = FP_Char()
            if c then c:SetAttribute("speedboost",1) end
        end
    end)
end

local function FP_TryBuff(name, amt, dur)
    if FP.ActiveBuffs[name] then return end
    if tick()-FP.LastBuffEnd < FP.CooldownTime and next(FP.ActiveBuffs)==nil then return end
    FP.ActiveBuffs[name] = {amt=amt, endTime=tick()+dur}
    FP_Apply()
    FP_EnsureHB()
    VD_Notify("Fake Perks", "["..name.."] Aktif! +"..amt.." Speed ("..dur.."s)", 3)
end

local function FP_Clean(name)
    if FP.Conns[name] then
        for _,c in ipairs(FP.Conns[name]) do pcall(function() c:Disconnect() end) end
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
            task.delay(0.5, function() if FP.FlowstateOn then FP_TryBuff("Flowstate",5,3) end end)
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
            if FP.FlowstateOn then cc:SetAttribute("Flowstate",true); hookChar(cc) end
        end))
        VD_Notify("Fake Perks", "Flowstate ON - +5 speed 3s setelah vault/slide", 4)
    else
        FP_Clean("Flowstate")
        FP.ActiveBuffs["Flowstate"] = nil
        local c2 = FP_Char()
        if c2 then c2:SetAttribute("Flowstate", false) end
        VD_Notify("Fake Perks", "Flowstate OFF", 3)
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
                    if nh > lh and (nh>=h.MaxHealth or (nh-lh)>=15) then onH() end
                    lh = nh
                end)
                FP_Reg("QuickRecovery", cn)
            end
        end
        hookH(LocalPlayer.Character)
        FP_Reg("QuickRecovery", LocalPlayer.CharacterAdded:Connect(hookH))
        VD_Notify("Fake Perks", "Quick Recovery ON - +6 speed 3s setelah di-heal", 4)
    else
        FP_Clean("QuickRecovery")
        FP.ActiveBuffs["QuickRecovery"] = nil
        VD_Notify("Fake Perks", "Quick Recovery OFF", 3)
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
            local cn = h.StateChanged:Connect(function(_,n)
                if not FP.PerfLandOn then return end
                if n == Enum.HumanoidStateType.Freefall then wf=true; fs=tick() end
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
        VD_Notify("Fake Perks", "Perfect Landing ON - +8 speed 3s setelah landing", 4)
    else
        FP_Clean("PerfectLanding")
        FP.ActiveBuffs["PerfectLanding"] = nil
        VD_Notify("Fake Perks", "Perfect Landing OFF", 3)
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
        VD_Notify("Fake Perks", "Adrenaline Rush ON - +4 speed 5s saat HP drop 50", 4)
    else
        FP_Clean("AdrenalineRush")
        FP.ActiveBuffs["AdrenalineRush"] = nil
        VD_Notify("Fake Perks", "Adrenaline Rush OFF", 3)
    end
end

-- FIRST PERSON
getgenv().MAWWW_fpWasSet = false
getgenv().MAWWW_fpOriginal = nil

function W.RestoreFirstPersonCamera()
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
    local c = LocalPlayer.Character
    if c then
        local h = c:FindFirstChild("Head")
        if h then h.LocalTransparencyModifier = 0 end
        for _,o in ipairs(c:GetChildren()) do
            if o:IsA("Accessory") then
                local hd = o:FindFirstChild("Handle")
                if hd then hd.LocalTransparencyModifier = 0 end
            end
        end
    end
    getgenv().MAWWW_fpOriginal = nil
end
local RestoreFirstPersonCamera = W.RestoreFirstPersonCamera

RunService.RenderStepped:Connect(function()
    pcall(function()
        if VD.SURV_FirstPerson then
            local isSurv = LocalPlayer.Team and LocalPlayer.Team.Name=="Survivors"
            if isSurv then
                if not getgenv().MAWWW_fpWasSet then
                    getgenv().MAWWW_fpOriginal = {
                        CameraMode = LocalPlayer.CameraMode,
                        CameraMaxZoomDistance = LocalPlayer.CameraMaxZoomDistance,
                        CameraMinZoomDistance = LocalPlayer.CameraMinZoomDistance,
                    }
                end
                if LocalPlayer.CameraMode ~= Enum.CameraMode.LockFirstPerson then LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson end
                if LocalPlayer.CameraMaxZoomDistance ~= 0 then LocalPlayer.CameraMaxZoomDistance = 0 end
                local c = LocalPlayer.Character
                if c then
                    local h = c:FindFirstChild("Head")
                    if h then h.LocalTransparencyModifier = 1 end
                    for _,o in ipairs(c:GetChildren()) do
                        if o:IsA("Accessory") then
                            local hd = o:FindFirstChild("Handle")
                            if hd then hd.LocalTransparencyModifier = 1 end
                        end
                    end
                end
                getgenv().MAWWW_fpWasSet = true
            elseif getgenv().MAWWW_fpWasSet then RestoreFirstPersonCamera() end
        elseif getgenv().MAWWW_fpWasSet then RestoreFirstPersonCamera() end
    end)
end)

-- WALKSPEED & JUMPPOWER
W.KillerAnims = {
    ["rbxassetid://105374834496520"]=true, ["rbxassetid://113255068724446"]=true,
    ["rbxassetid://118907603246885"]=true, ["rbxassetid://129784271201071"]=true,
    ["rbxassetid://117042998468241"]=true, ["rbxassetid://122812055447896"]=true,
    ["rbxassetid://78935059863801"]=true, ["rbxassetid://74968262036854"]=true,
    ["rbxassetid://78432063483146"]=true, ["rbxassetid://132817836308238"]=true,
    ["rbxassetid://133963973694098"]=true, ["rbxassetid://111920872708571"]=true,
    ["rbxassetid://80411309607666"]=true, ["rbxassetid://98163597193511"]=true,
    ["rbxassetid://82666958311998"]=true, ["rbxassetid://110355011987939"]=true,
    ["rbxassetid://139369275981139"]=true, ["rbxassetid://135002183282873"]=true,
    ["rbxassetid://121216847022485"]=true, ["rbxassetid://130593238885843"]=true,
    ["rbxassetid://117070354890871"]=true, ["rbxassetid://106871536134254"]=true,
    ["rbxassetid://138720291317243"]=true,
}
local KillerAnims = W.KillerAnims

function W.applyJumpPower()
    if not VD.SURV_JumpPowerEnabled then return end
    local c = LocalPlayer.Character
    if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    if h then h.JumpPower = VD.SURV_JumpPowerValue end
end
local applyJumpPower = W.applyJumpPower

function W.shouldDisableWalkSpeed()
    local c = LocalPlayer.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    if h then
        local a = h:FindFirstChildOfClass("Animator")
        if a then
            for _,t in ipairs(a:GetPlayingAnimationTracks()) do
                local an = t.Animation
                if an and an.AnimationId then
                    if an.AnimationId=="rbxassetid://127096285501517" then return true end
                    if an.AnimationId=="rbxassetid://112166042383605" then return true end
                    if an.AnimationId=="http://www.roblox.com/asset/?id=126965695851149" then return true end
                    if an.AnimationId=="http://www.roblox.com/asset/?id=135084204086504" then return true end
                    if an.AnimationId=="rbxassetid://123047897844134" then return true end
                    local id = an.AnimationId:match("%d+")
                    if id and KillerAnims["rbxassetid://"..id] then return true end
                end
            end
        end
        if h.Health <= 0 or h.Health < 2
            or c:GetAttribute("Downed")==true
            or c:GetAttribute("IsDown")==true
            or c:GetAttribute("Knocked")==true then
            return true
        end
    end
    return false
end

function W.applyWalkSpeed()
    if W.Connections.WalkSpeed then W.Connections.WalkSpeed:Disconnect(); W.Connections.WalkSpeed=nil end
    W.Connections.WalkSpeed = RunService.Heartbeat:Connect(function()
        if not VD.SURV_WalkSpeedEnabled then return end
        local c = LocalPlayer.Character
        if not c then return end
        local h = c:FindFirstChildOfClass("Humanoid")
        if not h then return end
        if W.shouldDisableWalkSpeed() then return end
        if h.WalkSpeed ~= VD.SURV_WalkSpeedValue then h.WalkSpeed = VD.SURV_WalkSpeedValue end
    end)
end
local applyWalkSpeed = W.applyWalkSpeed

-- AUTO DROP PALLET
function W.HandleAutoPallet()
    if not W.Auto.PalletDrop then return end
    local plr = Players.LocalPlayer
    if not (plr.Team and plr.Team.Name=="Survivors") then return end
    local now = tick()
    if now - W.Timers.lastPalletScan < 0.2 then return end
    W.Timers.lastPalletScan = now
    if now - W.Timers.lastPalletDrop < 2.5 then return end
    local root = GetRoot()
    if not root then return end
    local h = plr.Character:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return end
    local kr, kd = GetNearestKiller()
    if not kr or kd > W.Auto.PalletDropDist then return end
    local r = ReplicatedStorage:FindFirstChild("Remotes")
    local pf = r and r:FindFirstChild("Pallet")
    local de = pf and pf:FindFirstChild("PalletDropEvent")
    if not de then return end
    local best, bd = nil, 8
    local function fSlide(m)
        local s = m:FindFirstChild("PalletPointSlide")
        if s then return s end
        for _,ch in ipairs(m:GetDescendants()) do if ch.Name=="PalletPointSlide" then return ch end end
        return m:FindFirstChild("PalletPoint")
    end
    for pal,_ in pairs(ESPCache.Pallets) do
        if not pal or W.State.UsedPallets[pal] then continue end
        local rp = pal:FindFirstChild("PalletPoint") or pal:FindFirstChild("PalletPointSlide")
        if not rp then continue end
        local ok, pos = pcall(function() return rp.Position end)
        if not ok or not pos then continue end
        local d = (root.Position - pos).Magnitude
        if d < bd then bd=d; best=pal end
    end
    if best then
        local ft = fSlide(best)
        if ft then
            pcall(function() de:FireServer(ft) end)
            W.State.UsedPallets[best] = true
            W.Timers.lastPalletDrop = now
        end
    end
end
local HandleAutoPallet = W.HandleAutoPallet

-- AUTO FLEE
task.spawn(function()
    while task.wait(0.2) do
        if not W.Auto.Flee then continue end
        local root = GetRoot()
        if not root then continue end
        local kr, d = GetNearestKiller()
        if kr and d <= W.Auto.FleeDist and tick()-W.State.LastFlee > W.Auto.FleeCooldown then
            local pt = GetFarthestGeneratorPoint(kr)
            if pt then
                W.State.LastFlee = tick()
                root.CFrame = pt.CFrame + Vector3.new(0,5,0)
            end
        end
    end
end)

-- GEN BYPASS
local GenBypass = W.GenBypass

function W.GB_GetAllGenerators()
    local now = tick()
    if now - GenBypass.CacheTimer < 5 then return GenBypass.Cache end
    GenBypass.Cache = {}
    GenBypass.CacheTimer = now
    local mf = workspace:FindFirstChild("Map")
    if not mf then return GenBypass.Cache end
    pcall(function()
        for _,v in pairs(mf:GetDescendants()) do
            if not v:IsA("Model") then continue end
            if v.Name ~= "Generator" then continue end
            local real = v:GetAttribute("RepairProgress")~=nil or v:GetAttribute("kickcount")~=nil or v:GetAttribute("ProgressRepair")~=nil
            if real then table.insert(GenBypass.Cache, v) end
        end
    end)
    return GenBypass.Cache
end

function W.GB_GetPoints(m)
    local pts = {}
    pcall(function()
        for _,o in pairs(m:GetChildren()) do
            if o.Name:find("GeneratorPoint") and o:IsA("BasePart") then table.insert(pts,o) end
        end
    end)
    return pts
end

function W.GB_WaitRepairing(pt, t)
    local s = tick()
    while tick()-s < (t or 1) do
        if pt:GetAttribute("IsRepairing")==true then return true end
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
    if not hrp then GenBypass.Processed[gm]=nil; return end
    local re = ReplicatedStorage:FindFirstChild("Remotes") 
        and ReplicatedStorage.Remotes:FindFirstChild("Generator")
        and ReplicatedStorage.Remotes.Generator:FindFirstChild("RepairEvent")
    local og = hrp.CFrame
    pcall(function()
        for _,p in pairs(W.GB_GetPoints(gm)) do
            if p ~= tp and p.Parent then
                hrp.Anchored = true
                hrp.CFrame = p.CFrame
                task.wait(0.15)
                pcall(function() if re then re:FireServer(p,true) end end)
                if not W.GB_WaitRepairing(p, 0.8) then
                    pcall(function() if re then re:FireServer(p,false) end end)
                    task.wait(0.1)
                    hrp.CFrame = p.CFrame
                    task.wait(0.15)
                    pcall(function() if re then re:FireServer(p,true) end end)
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
    pcall(function() if re then re:FireServer(tp,false) end end)
end

function W.GB_GetNearestPoint()
    local c = LocalPlayer.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local best, bd = nil, math.huge
    for _,g in pairs(W.GB_GetAllGenerators()) do
        for _,p in pairs(W.GB_GetPoints(g)) do
            local d = (hrp.Position-p.Position).Magnitude
            if d < bd then bd=d; best=p end
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
    local old = LocalPlayer.PlayerGui:FindFirstChild("BypassGenUI")
    if old then old:Destroy() end
    GenBypass.UI = Instance.new("ScreenGui")
    GenBypass.UI.Name = "BypassGenUI"
    GenBypass.UI.ResetOnSpawn = false
    GenBypass.UI.IgnoreGuiInset = true
    GenBypass.UI.Parent = LocalPlayer:WaitForChild("PlayerGui")
    GenBypass.Button = Instance.new("ImageButton")
    GenBypass.Button.Name = "BypassGenButton"
    GenBypass.Button.Size = UDim2.new(0,60,0,60)
    GenBypass.Button.Position = UDim2.new(0.88,0,0.55,0)
    GenBypass.Button.AnchorPoint = Vector2.new(0.5,0.5)
    GenBypass.Button.BackgroundColor3 = Color3.fromRGB(20,20,20)
    GenBypass.Button.BackgroundTransparency = 0
    GenBypass.Button.AutoButtonColor = true
    GenBypass.Button.Visible = false
    GenBypass.Button.ZIndex = 10
    GenBypass.Button.Parent = GenBypass.UI
    local co = Instance.new("UICorner"); co.CornerRadius = UDim.new(0,4); co.Parent = GenBypass.Button
    local st = Instance.new("UIStroke"); st.Color = Color3.fromRGB(255,0,0); st.Thickness=2; st.Transparency=0.2; st.Parent=GenBypass.Button
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1,0,1,0); lb.BackgroundTransparency=1
    lb.Text = "GEN"; lb.TextColor3 = Color3.fromRGB(255,0,0); lb.TextScaled = true
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
                if not gm or not gm.Parent then GenBypass.Processed[gm]=nil; continue end
                local near = false
                for _,p in pairs(W.GB_GetPoints(gm)) do
                    if p.Parent and (hrp.Position-p.Position).Magnitude<=10 then near=true; break end
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

print("[Wisnu Hub] File 3/4 loaded ✓")
-- PART 3 END

--[[
============================================================
  WISNU HUB - File 4/4 : Aim, Visuals, ESP, UI, Main Loop
============================================================
--]]

local W = _G.Wisnu
if not W then warn("[Wisnu Hub] File 1 harus dijalankan dulu!") return end

local Library = W.Library
local ThemeManager = W.ThemeManager
local SaveManager = W.SaveManager
local Options = W.Library.Options
local Players = W.Players
local RunService = W.RunService
local ReplicatedStorage = W.ReplicatedStorage
local LocalPlayer = W.LocalPlayer
local UserInputService = W.UserInputService
local VD = W.VD
local VD_Notify = W.VD_Notify
local GetRole = W.GetRole
local GetRoot = W.GetRoot
local IsSurvivor = W.IsSurvivor
local isMobile = W.isMobile
local GetSafeGuiParent = W.GetSafeGuiParent

-- ToF SILENT AIM
local ToFState = {
    Connection = nil, LaserBeam = nil, TargetGui = nil, InputBegan = nil, InputEnded = nil,
    TouchInput = nil, IsAiming = false, SavedUIPos = UDim2.new(0.5,-120,0,110), SCPCache = {}, SCPCacheTimer = 0,
}
local ToFKeyCodes = { None=nil, Q=Enum.KeyCode.Q, E=Enum.KeyCode.E, R=Enum.KeyCode.R, T=Enum.KeyCode.T, F=Enum.KeyCode.F, G=Enum.KeyCode.G, H=Enum.KeyCode.H, J=Enum.KeyCode.J, K=Enum.KeyCode.K, L=Enum.KeyCode.L, X=Enum.KeyCode.X, Z=Enum.KeyCode.Z }

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
    if VD.TOF_BlockKnocked==false then return false end
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
                    local r = c:FindFirstChild("HumanoidRootPart")
                    if r then table.insert(nt, r) end
                end
            end
        end
    end
    ToFState.SCPCache = nt
    ToFState.SCPCacheTimer = tick()
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
        pcall(function()
            op = g:IsA("BasePart") and g.Position or (g:FindFirstChildOfClass("BasePart") and g:FindFirstChildOfClass("BasePart").Position)
        end)
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
        for _=1,2 do
            local nd = (pp-op).Magnitude
            tt = nd/400
            pp = tp + (tv*tt)
        end
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
                if t then
                    local d = (mp-t.Position).Magnitude
                    if d < bs then bs=d; bt=t; bc=p.Character end
                end
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
                    if dt.Magnitude>0.1 then
                        local dot = cl:Dot(dt.Unit)
                        if dot>0.5 and dot>bd then bd=dot; bt=t; bc=p.Character end
                    end
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
                if dt.Magnitude>0.1 then
                    local dot = cl:Dot(dt.Unit)
                    if dot>0.5 and dot>bd then bd=dot; bp=r end
                end
            end
        end
        if not bp then return nil,nil,nil,nil end
        return predict(bp, bp.Parent)
    end
    return nil,nil,nil,nil
end

local function ToF_UpdateLaser(op, tp)
    if not ToFState.LaserBeam then
        local l = Instance.new("Part")
        l.Name="ToFLaser"; l.Anchored=true; l.CanCollide=false; l.CanTouch=false; l.CastShadow=false
        l.Material=Enum.Material.Neon; l.Color=Color3.fromRGB(255,0,0); l.Parent=workspace
        ToFState.LaserBeam = l
    end
    local d = (tp-op).Magnitude
    ToFState.LaserBeam.Size = Vector3.new(0.05,0.05,d)
    ToFState.LaserBeam.CFrame = CFrame.new((op+tp)/2, tp)
    ToFState.LaserBeam.Transparency = 0
end

function W.ToF_ClearLaser()
    if ToFState.LaserBeam then pcall(function() ToFState.LaserBeam:Destroy() end); ToFState.LaserBeam=nil end
end

local function ToF_GetMobileBtn()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local sm = pg and pg:FindFirstChild("Survivor-mob")
    local ct = sm and sm:FindFirstChild("Controls")
    local gm = ct and ct:FindFirstChild("Gui-mob")
    if not gm then return nil end
    local dns = {"attack","Attack","shoot","Shoot","fire","Fire"}
    for _,n in ipairs(dns) do
        local b = gm:FindFirstChild(n,true); if b and b:IsA("GuiObject") then return b end
    end
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
    local m = {
        Killer = {Color3.fromRGB(35,35,35), Color3.fromRGB(255,0,0)},
        Survivors = {Color3.fromRGB(35,35,35), Color3.fromRGB(0,255,255)},
        Zombie = {Color3.fromRGB(35,35,35), Color3.fromRGB(0,255,0)},
    }
    for n,b in pairs(ToF_ModeButtons) do
        if b and b.Parent then
            local a = n == (VD.TOF_TargetMode or "Killer")
            local c = m[n]
            b.BackgroundColor3 = a and c[1] or Color3.fromRGB(30,32,40)
            b.TextColor3 = a and c[2] or Color3.fromRGB(155,160,175)
        end
    end
end

function W.ToF_SetTargetMode(mode, notify)
    if mode~="Killer" and mode~="Survivors" and mode~="Zombie" then return end
    VD.TOF_TargetMode = mode
    ToF_RefreshButtons()
    if notify then VD_Notify("Target Mode", mode, 1) end
end
local ToF_SetTargetMode = W.ToF_SetTargetMode

local function ToF_CreateUI()
    local parent = GetSafeGuiParent()
    if not parent then return end
    if ToFState.TargetGui and ToFState.TargetGui.Parent then return end
    local old = parent:FindFirstChild("ToFTargetSelector"); if old then pcall(function() old:Destroy() end) end
    local gui = Instance.new("ScreenGui")
    gui.Name = "ToFTargetSelector"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true; gui.Parent=parent
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,180,0,126); frame.Position = ToFState.SavedUIPos
    frame.BackgroundColor3 = Color3.fromRGB(15,15,15); frame.BorderSizePixel=0; frame.Active=true; frame.Parent=gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)
    local st = Instance.new("UIStroke", frame); st.Color=Color3.fromRGB(255,0,0); st.Thickness=1

    local header = Instance.new("Frame"); header.Size=UDim2.new(1,0,0,28)
    header.BackgroundColor3=Color3.fromRGB(24,26,34); header.BorderSizePixel=0; header.Parent=frame
    Instance.new("UICorner", header).CornerRadius = UDim.new(0,4)
    local hFix = Instance.new("Frame"); hFix.Size=UDim2.new(1,0,0,10); hFix.Position=UDim2.new(0,0,1,-10)
    hFix.BackgroundColor3=Color3.fromRGB(25,25,25); hFix.BorderSizePixel=0; hFix.Parent=header
    local hDiv = Instance.new("Frame"); hDiv.Size=UDim2.new(1,0,0,1); hDiv.Position=UDim2.new(0,0,1,-1)
    hDiv.BackgroundColor3=Color3.fromRGB(48,48,48); hDiv.BorderSizePixel=0; hDiv.Parent=header
    local drag = Instance.new("Frame"); drag.Size=UDim2.new(1,-34,1,0); drag.BackgroundTransparency=1; drag.Parent=header
    local min = Instance.new("TextButton"); min.Size=UDim2.new(0,28,1,0); min.Position=UDim2.new(1,-30,0,0)
    min.BackgroundTransparency=1; min.Text="-"; min.TextColor3=Color3.fromRGB(255,0,0)
    min.Font=Enum.Font.GothamBold; min.TextSize=14; min.Parent=header
    local hlbl = Instance.new("TextLabel"); hlbl.Size=UDim2.new(1,-44,1,0); hlbl.Position=UDim2.new(0,10,0,0)
    hlbl.BackgroundTransparency=1; hlbl.Text="TOF TARGET MODE"; hlbl.TextColor3=Color3.fromRGB(255,0,0)
    hlbl.Font=Enum.Font.GothamBold; hlbl.TextSize=10; hlbl.TextXAlignment=Enum.TextXAlignment.Left; hlbl.Parent=header

    local bc = Instance.new("Frame"); bc.Size=UDim2.new(1,-16,0,86); bc.Position=UDim2.new(0,8,0,34)
    bc.BackgroundTransparency=1; bc.Parent=frame
    local lay = Instance.new("UIListLayout", bc); lay.FillDirection=Enum.FillDirection.Vertical
    lay.SortOrder=Enum.SortOrder.LayoutOrder; lay.Padding=UDim.new(0,5)
    local isMin = false
    min.MouseButton1Click:Connect(function()
        isMin = not isMin; min.Text = isMin and "+" or "-"
        bc.Visible = not isMin
        frame.Size = isMin and UDim2.new(0,180,0,28) or UDim2.new(0,180,0,126)
    end)

    local modes = {
        {Internal="Killer", Display="KILLER        K"},
        {Internal="Survivors", Display="SURVIVOR      J"},
        {Internal="Zombie", Display="ZOMBIE        L"},
    }
    ToF_ModeButtons = {}
    for i,m in ipairs(modes) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1,0,0,25); b.BorderSizePixel=0
        b.Font=Enum.Font.GothamBold; b.TextSize=11; b.Text=m.Display
        b.TextXAlignment=Enum.TextXAlignment.Center; b.LayoutOrder=i; b.Parent=bc
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,4)
        local bs = Instance.new("UIStroke", b); bs.Color=Color3.fromRGB(25,25,25); bs.Thickness=1
        b.MouseButton1Click:Connect(function() ToF_SetTargetMode(m.Internal, false) end)
        b.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.Touch then ToF_SetTargetMode(m.Internal, false) end end)
        ToF_ModeButtons[m.Internal] = b
    end
    ToF_RefreshButtons()

    local drg = false; local ds, sp
    drag.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            ds=inp.Position; sp=frame.Position; drg=true
        end
    end)
    drag.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then drg=false end
    end)
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
        if ToF_IsBlocked() then
            ToFState.IsAiming=false
            if ToFState.TouchInput then ToFState.TouchInput=nil end
            if ToFState.LaserBeam then ToFState.LaserBeam.Transparency=1 end
            return
        end
        if not VD.TOF_SilentAim or not ToFState.IsAiming then
            if ToFState.LaserBeam then ToFState.LaserBeam.Transparency=1 end
            return
        end
        local _,_,op,tp = ToF_GetTarget()
        if op and tp then
            pcall(function()
                local c = LocalPlayer.Character
                local hrp = c and c:FindFirstChild("HumanoidRootPart")
                if hrp and not c:GetAttribute("IsCarried") then
                    hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(tp.X, hrp.Position.Y, tp.Z))
                end
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
            if k and inp.UserInputType==Enum.UserInputType.Keyboard and inp.KeyCode==k then
                SetToFSilentAim(not VD.TOF_SilentAim); return
            end
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
                if wa then
                    if ToF_IsBlocked() then return end
                    ToF_Shoot()
                end
            end
        end)
    end
end

SetToFSilentAim = function(en)
    VD.TOF_SilentAim = en and true or false
    ToF_EnsureInputs()
    if VD.TOF_SilentAim then ToF_CreateUI(); ToF_StartConn()
    else ToF_DestroyUI(); ToF_StopConn() end
end
W.SetToFSilentAim = SetToFSilentAim
ToF_EnsureInputs()

-- FLASHLIGHT SILENT AIM
local FlashState = { Connection=nil, LaserBeam=nil, FlashlightPart=nil, Active=false }

local function Flash_GetActivateRemote()
    local r = ReplicatedStorage:FindFirstChild("Remotes")
    local i = r and r:FindFirstChild("Items")
    local f = i and i:FindFirstChild("Flashlight")
    local a = f and f:FindFirstChild("Activate")
    if a and a:IsA("RemoteEvent") then return a end
    return nil
end

local function Flash_GetTargetPart(c)
    if not c then return nil end
    local pr = VD.FLASH_TargetPart or "Head"
    local p = c:FindFirstChild(pr)
    if p and p:IsA("BasePart") then return p end
    return c:FindFirstChild("Head") or c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso") or c:FindFirstChild("HumanoidRootPart")
end

local function Flash_IsAlive(c)
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if not h or h.Health<=0 then return false end
    local s = c:GetAttribute("State")
    return s ~= "Dead"
end

local function Flash_GetTarget()
    local lc = LocalPlayer.Character
    local lr = lc and lc:FindFirstChild("HumanoidRootPart")
    if not lr then return nil end
    local mr = tonumber(VD.FLASH_Range) or 120
    local bp, bsc = nil, math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character and Flash_IsAlive(p.Character) then
            local isK = p.Team and p.Team.Name=="Killer"
            if isK then
                local pt = Flash_GetTargetPart(p.Character)
                if pt then
                    local d = (lr.Position-pt.Position).Magnitude
                    if d<=mr and d<bsc then bsc=d; bp=pt end
                end
            end
        end
    end
    return bp
end

function W.Flash_ClearLaser()
    if FlashState.LaserBeam then pcall(function() FlashState.LaserBeam:Destroy() end); FlashState.LaserBeam=nil end
end

local function Flash_GetOrigin(cam)
    local s = FlashState.FlashlightPart
    if typeof and typeof(s)=="Instance" then
        if s:IsA("BasePart") then return s.Position end
        local p = s:FindFirstChildWhichIsA("BasePart", true)
        if p then return p.Position end
    end
    local c = LocalPlayer.Character
    local h = c and (c:FindFirstChild("RightHand") or c:FindFirstChild("Right Arm") or c:FindFirstChild("HumanoidRootPart"))
    if h and h:IsA("BasePart") then return h.Position end
    return cam and cam.CFrame.Position or nil
end

local function Flash_UpdateLaser(op, tp)
    if not FlashState.LaserBeam then
        local l = Instance.new("Part")
        l.Name="FlashlightSilentAimLaser"; l.Anchored=true; l.CanCollide=false; l.CanTouch=false; l.CastShadow=false
        l.Material=Enum.Material.Neon; l.Color=Color3.fromRGB(255,0,0); l.Transparency=0; l.Parent=workspace
        FlashState.LaserBeam = l
    end
    local d = (tp-op).Magnitude
    if d < 0.1 then return end
    FlashState.LaserBeam.Size = Vector3.new(0.16,0.16,d)
    FlashState.LaserBeam.CFrame = CFrame.new((op+tp)/2, tp)
    FlashState.LaserBeam.Transparency = 0
end

local function Flash_Step()
    if not (VD.FLASH_SilentAim and FlashState.Active) then
        if FlashState.LaserBeam then FlashState.LaserBeam.Transparency=1 end
        return
    end
    local cam = workspace.CurrentCamera
    local tp = Flash_GetTarget()
    if not (cam and tp) then
        if FlashState.LaserBeam then FlashState.LaserBeam.Transparency=1 end
        return
    end
    local tpos = tp.Position
    local sm = math.clamp(tonumber(VD.FLASH_Smooth) or 0.35, 0.05, 1)
    local op = Flash_GetOrigin(cam)
    if VD.FLASH_Laser and op then Flash_UpdateLaser(op, tpos)
    elseif FlashState.LaserBeam then FlashState.LaserBeam.Transparency=1 end
    pcall(function() cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, tpos), sm) end)
    pcall(function()
        local c = LocalPlayer.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(tpos.X, hrp.Position.Y, tpos.Z)) end
    end)
end

local function Flash_Start()
    getgenv().MAWWW_FlashlightActivateRemote = Flash_GetActivateRemote()
    if FlashState.Connection then return end
    FlashState.Connection = RunService.RenderStepped:Connect(Flash_Step)
end
local function Flash_Stop()
    FlashState.Active=false; FlashState.FlashlightPart=nil; W.Flash_ClearLaser()
    if FlashState.Connection then pcall(function() FlashState.Connection:Disconnect() end); FlashState.Connection=nil end
end

function W.Flash_SetSilentAim(en)
    VD.FLASH_SilentAim = en and true or false
    if VD.FLASH_SilentAim then Flash_Start() else Flash_Stop() end
end
local Flash_SetSilentAim = W.Flash_SetSilentAim

getgenv().MAWWW_SetFlashlightSilentAim = Flash_SetSilentAim
getgenv().MAWWW_ClearFlashlightLaser = W.Flash_ClearLaser
getgenv().MAWWW_SetFlashlightAimActive = function(active, part)
    FlashState.Active = active and true or false
    if FlashState.Active and part then FlashState.FlashlightPart = part
    elseif not FlashState.Active then FlashState.FlashlightPart = nil end
    if not FlashState.Active and FlashState.LaserBeam then FlashState.LaserBeam.Transparency=1 end
end
getgenv().MAWWW_FlashlightActivateRemote = Flash_GetActivateRemote()

-- VEIL SPEAR
local VeilConfig = { Enabled=false, ShowFOV=true, ShowTargetLaser=true, FOV=220, SpearSpeed=165, Gravity=workspace.Gravity*0.5, MaxDist=200, AutoPredict=false, TargetPart="Torso", HorizontalPredictFactor=1.0 }
local VeilState = { chargingSpear=false, touchInput=nil, attackCooldown=false, passiveCooldown=false, remoteHooked=false, lastPredictedPos=nil }
local VeilVelocityCache = {}
local VeilDraw = { FOVCircle=Drawing.new("Circle"), Highlight=Instance.new("Highlight"), Tracer=Drawing.new("Circle") }
VeilDraw.FOVCircle.Color = Color3.fromRGB(255,0,0); VeilDraw.FOVCircle.Thickness=1.5; VeilDraw.FOVCircle.Filled=false; VeilDraw.FOVCircle.Visible=false
VeilDraw.Highlight.Name="VD_VeilTarget"; VeilDraw.Highlight.FillColor=Color3.fromRGB(15,15,15); VeilDraw.Highlight.OutlineColor=Color3.fromRGB(255,0,0); VeilDraw.Highlight.FillTransparency=0.5; VeilDraw.Highlight.OutlineTransparency=0
VeilDraw.Tracer.Thickness=2; VeilDraw.Tracer.Radius=5; VeilDraw.Tracer.Color=Color3.fromRGB(0,0,0); VeilDraw.Tracer.Filled=true; VeilDraw.Tracer.Visible=false

local function Veil_GetVel(part, pname)
    if not part then return Vector3.zero end
    local cp = part.Position; local ct = tick()
    if not VeilVelocityCache[pname] then
        VeilVelocityCache[pname] = {lastPos=cp, lastTime=ct, velocity=Vector3.zero}
        return Vector3.zero
    end
    local cache = VeilVelocityCache[pname]
    local dt = ct - cache.lastTime
    if dt > 0.01 then
        dt = math.min(dt, 0.12)
        local rv = (cp - cache.lastPos)/dt
        if rv.Magnitude < 100 then cache.velocity = cache.velocity:Lerp(rv, 0.35) end
    end
    cache.lastPos = cp; cache.lastTime = ct
    return cache.velocity
end

local function Veil_GetTargetPart(c)
    if VeilConfig.TargetPart=="Head" then return c:FindFirstChild("Head")
    elseif VeilConfig.TargetPart=="Root" then return c:FindFirstChild("HumanoidRootPart")
    else return c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso") or c:FindFirstChild("HumanoidRootPart") end
end

local function Veil_GetClosestSurvivor()
    local mc = LocalPlayer.Character
    local mr = mc and mc:FindFirstChild("HumanoidRootPart")
    if not mr then return nil end
    local cam = workspace.CurrentCamera
    local ctr = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    local bd = VeilConfig.FOV
    local bt = nil
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team and p.Team.Name=="Survivors" and p.Character then
            local c = p.Character
            local h = c:FindFirstChildOfClass("Humanoid")
            local pt = Veil_GetTargetPart(c)
            if h and h.Health>0 and pt then
                local d3 = (pt.Position-mr.Position).Magnitude
                if d3 <= VeilConfig.MaxDist then
                    local sp, onS = cam:WorldToViewportPoint(pt.Position)
                    if onS then
                        local d2 = (Vector2.new(sp.X, sp.Y)-ctr).Magnitude
                        if d2 < bd then bd=d2; bt={Player=p, Part=pt} end
                    end
                end
            end
        end
    end
    return bt
end

local function Veil_SetupInterceptor()
    if VeilState.remoteHooked then return end
    task.spawn(function()
        pcall(function()
            local old
            old = hookmetamethod(game, "__namecall", function(self, ...)
                local m = getnamecallmethod()
                if not checkcaller() then
                    if string.lower(m)=="kick" then return nil end
                    if m=="FireServer" then
                        if self.Name=="Spearthrow" and VeilConfig.Enabled then return nil end
                    end
                end
                return old(self, ...)
            end)
            VeilState.remoteHooked = true
        end)
    end)
end
Veil_SetupInterceptor()

local function Veil_Fire()
    if VeilState.attackCooldown then return end
    VeilState.attackCooldown = true
    task.delay(2, function() VeilState.attackCooldown=false end)
    local mc = LocalPlayer.Character
    local sp = mc and (mc:FindFirstChild("Head") or mc:FindFirstChild("HumanoidRootPart"))
    if not sp then return end
    local spos = sp.Position
    local ti = Veil_GetClosestSurvivor()
    local dir
    if ti and ti.Part then
        local tp = ti.Part
        local tpl = ti.Player
        local tpos = tp.Position
        local vel = Veil_GetVel(tp, tpl.Name)
        local hv = Vector3.new(vel.X, 0, vel.Z)
        local spd = hv.Magnitude
        local dist = (tpos-spos).Magnitude
        local tth = dist / VeilConfig.SpearSpeed
        local hp = Vector3.zero
        if spd > 4 and VeilConfig.AutoPredict then
            hp = hv * tth * VeilConfig.HorizontalPredictFactor
        end
        local pp = tpos + hp
        local ag = math.max(0, dist-8)
        local g = VeilConfig.AutoPredict and ag or VeilConfig.Gravity
        local drop = 0.5 * g * (tth^2)
        local fp = pp + Vector3.new(0, drop, 0)
        dir = (fp-spos).Unit
        VeilState.lastPredictedPos = fp
    else
        dir = workspace.CurrentCamera.CFrame.LookVector
        VeilState.lastPredictedPos = nil
    end
    pcall(function()
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        if r then
            local k = r:FindFirstChild("Killers")
            if k then
                local v = k:FindFirstChild("Veil")
                if v and v:FindFirstChild("Spearthrow") then
                    v.Spearthrow:FireServer(dir, VeilConfig.SpearSpeed, spos)
                end
            end
        end
    end)
    VeilDraw.FOVCircle.Color = Color3.fromRGB(255,0,0)
    if not VeilState.passiveCooldown then
        VeilState.passiveCooldown = true
        task.delay(30, function() VeilDraw.FOVCircle.Color = Color3.fromRGB(255,0,0); VeilState.passiveCooldown=false end)
    end
end

UserInputService.InputBegan:Connect(function(inp, gp)
    local isT = inp.UserInputType==Enum.UserInputType.Touch
    if gp and not isT then return end
    local c = LocalPlayer.Character
    local isSM = c and c:GetAttribute("spearmode")==true
    if not VeilConfig.Enabled then return end
    if not isSM then return end
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then VeilState.chargingSpear = true
    elseif isT then
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            local sl = pg:FindFirstChild("Slasher-mob")
            if sl then
                local ct = sl:FindFirstChild("Controls")
                if ct then
                    local ab = ct:FindFirstChild("attack")
                    if ab and ab.Visible then
                        local p = inp.Position; local ap = ab.AbsolutePosition; local as_ = ab.AbsoluteSize
                        if p.X>=ap.X and p.X<=ap.X+as_.X and p.Y>=ap.Y and p.Y<=ap.Y+as_.Y then
                            VeilState.chargingSpear = true
                            VeilState.touchInput = inp
                        end
                    end
                end
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(inp, gp)
    if VeilState.chargingSpear and (inp==VeilState.touchInput or inp.UserInputType==Enum.UserInputType.MouseButton1) then
        VeilState.chargingSpear = false
        if VeilState.touchInput==inp then VeilState.touchInput=nil end
        Veil_Fire()
    end
end)

RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    local mc = LocalPlayer.Character
    local isSM = mc and mc:GetAttribute("spearmode")==true
    if VeilConfig.Enabled and VeilConfig.ShowFOV and isSM then
        VeilDraw.FOVCircle.Visible = true
        VeilDraw.FOVCircle.Radius = VeilConfig.FOV
        VeilDraw.FOVCircle.Position = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    else VeilDraw.FOVCircle.Visible = false end
    if VeilState.chargingSpear and VeilConfig.Enabled and isSM then
        local t = Veil_GetClosestSurvivor()
        if t and t.Part and t.Part.Parent then
            VeilDraw.Highlight.Parent = t.Part.Parent
            if VeilConfig.ShowTargetLaser then
                if not getgenv().MAWWW_SpearLaserPart then
                    local l = Instance.new("Part")
                    l.Name="SpearSilentAimLaser"; l.Anchored=true; l.CanCollide=false; l.CanTouch=false; l.CastShadow=false
                    l.Material=Enum.Material.Neon; l.Color=Color3.fromRGB(255,0,0); l.Transparency=0; l.Parent=workspace
                    getgenv().MAWWW_SpearLaserPart = l
                end
                local op = mc and (mc:FindFirstChild("Head") or mc:FindFirstChild("HumanoidRootPart"))
                if op then
                    local opos = op.Position; local tpos = t.Part.Position
                    local d = (tpos-opos).Magnitude
                    if d > 0.1 then
                        local l = getgenv().MAWWW_SpearLaserPart
                        l.Size = Vector3.new(0.16,0.16,d)
                        l.CFrame = CFrame.new((opos+tpos)/2, tpos)
                        l.Transparency = 0.5
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
    if VeilConfig.Enabled and isSM and VeilState.lastPredictedPos then
        local sp, os = cam:WorldToViewportPoint(VeilState.lastPredictedPos)
        local vp = cam.ViewportSize
        local ctr = Vector2.new(vp.X/2, vp.Y/2)
        if os then VeilDraw.Tracer.Position = Vector2.new(sp.X, sp.Y)
        else
            local dx = sp.X - ctr.X; local dy = sp.Y - ctr.Y
            if math.abs(dx)<1 and math.abs(dy)<1 then VeilDraw.Tracer.Position = ctr
            else
                local mx = vp.X/2-10; local my = vp.Y/2-10
                local sx = mx/math.abs(dx); local sy = my/math.abs(dy)
                local s = math.min(sx, sy)
                VeilDraw.Tracer.Position = Vector2.new(ctr.X+dx*s, ctr.Y+dy*s)
            end
        end
        VeilDraw.Tracer.Visible = true
    else VeilDraw.Tracer.Visible = false end
end)

-- DASH LOCK
local DashLock = { Enabled=false }
local function DashLockUpdate()
    if not VD.DashLockEnabled then
        if VD._DashLockActive then
            VD._DashLockActive = false; VD._DashLockTarget = nil
            if VD.FreezeDuringDashLock then
                local c = LocalPlayer.Character
                local h = c and c:FindFirstChildOfClass("Humanoid")
                if h and h.WalkSpeed==0 then h.WalkSpeed = 16 end
            end
        end
        return
    end
    local mc = LocalPlayer.Character
    local mr = mc and mc:FindFirstChild("HumanoidRootPart")
    if not mr then VD._DashLockTarget = nil; return end
    local t, td = nil, math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Team and p.Team.Name=="Survivors" then
            local c = p.Character
            if c then
                local r = c:FindFirstChild("HumanoidRootPart")
                local h = c:FindFirstChildOfClass("Humanoid")
                if r and h and h.Health>0 then
                    local d = (mr.Position-r.Position).Magnitude
                    if d < td then td=d; t=r end
                end
            end
        end
    end
    if not t then VD._DashLockTarget = nil; return end
    VD._DashLockTarget = t
    local cam = workspace.CurrentCamera
    if cam and t then
        local sm = VD.DashLockSmoothness or 0.3
        local tp = t.Position
        cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, tp), sm)
        if VD.FreezeDuringDashLock then
            local h = mc and mc:FindFirstChildOfClass("Humanoid")
            if h and h.WalkSpeed ~= 0 then h.WalkSpeed = 0 end
        end
    end
end

function W.MAWWW_SetDashLockActive(active)
    if active==VD._DashLockActive then return end
    VD._DashLockActive = active
    if active then
        if not VD._DashLockConnection then VD._DashLockConnection = RunService.RenderStepped:Connect(DashLockUpdate) end
    else
        if VD._DashLockConnection then VD._DashLockConnection:Disconnect(); VD._DashLockConnection=nil end
        VD._DashLockTarget = nil
    end
end

local function HookDash(char)
    local h = char:WaitForChild("Humanoid", 5)
    if h then
        local a = h:FindFirstChildOfClass("Animator")
        if a then
            a.AnimationPlayed:Connect(function(t)
                if t.Animation and t.Animation.AnimationId=="rbxassetid://98163597193511" then
                    if VD.DashLockEnabled then
                        W.MAWWW_SetDashLockActive(true)
                        task.delay(VD.DashLockDuration or 1.5, function() W.MAWWW_SetDashLockActive(false) end)
                    end
                end
            end)
        end
    end
end
if LocalPlayer.Character then HookDash(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(HookDash)

-- LOCK POV
local LockPOV = { Enabled=false, LockedFOV=80, SaveOriginal=true, OriginalFOV=nil, Connection=nil }
local function LockPOV_Upd()
    if not LockPOV.Enabled then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    if cam.FieldOfView ~= LockPOV.LockedFOV then cam.FieldOfView = LockPOV.LockedFOV end
end
function W.LockPOV_SetEnabled(en)
    LockPOV.Enabled = en and true or false
    if LockPOV.Enabled then
        local cam = workspace.CurrentCamera
        if cam then
            if LockPOV.SaveOriginal then LockPOV.OriginalFOV = cam.FieldOfView end
            if LockPOV.Connection then LockPOV.Connection:Disconnect(); LockPOV.Connection=nil end
            cam.FieldOfView = LockPOV.LockedFOV
            LockPOV.Connection = RunService.RenderStepped:Connect(LockPOV_Upd)
            VD_Notify("Lock POV", "Enabled ("..LockPOV.LockedFOV..")", 2)
        end
    else
        if LockPOV.Connection then LockPOV.Connection:Disconnect(); LockPOV.Connection=nil end
        local cam = workspace.CurrentCamera
        if cam and LockPOV.OriginalFOV then cam.FieldOfView = LockPOV.OriginalFOV end
        VD_Notify("Lock POV", "Disabled", 2)
    end
end
local LockPOV_SetEnabled = W.LockPOV_SetEnabled
W.LockPOV = LockPOV

-- KORLESS
function W.ApplyKorless()
    local plr = game.Players.LocalPlayer
    local function Morph()
        repeat task.wait() until plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Right Leg")
        task.wait(0.1)
        local c = plr.Character
        pcall(function()
            c.Head.Transparency = 1
            local f = c.Head:FindFirstChild("face"); if f then f:Destroy() end
            c["Right Leg"].Transparency = 1
            local m = Instance.new("MeshPart")
            m.Name="KorlessHead"; m.Size=Vector3.new(1.5,1.5,1.5); m.CanCollide=false
            m.MeshId="rbxassetid://902942096"; m.TextureID="rbxassetid://902843398"
            m.CFrame = c["Right Leg"].CFrame * CFrame.new(0,0.5,0)
            m.Parent = c
            local w = Instance.new("WeldConstraint")
            w.Part0 = c["Right Leg"]; w.Part1 = m; w.Parent = m
        end)
    end
    Morph()
    if W.KorlessConn then W.KorlessConn:Disconnect() end
    W.KorlessConn = plr.CharacterAdded:Connect(function() task.wait(1); Morph() end)
end

-- ESP
local ESP = W.ESP
local ESPCache = W.ESPCache
local ESPItems = W.ESPItems
local TeamColors = W.TeamColors
local ESPStatus = W.ESPStatus

for _,o in ipairs(workspace:GetDescendants()) do
    if string.find(string.lower(o.Name), "scp") then ESPCache.SCP[o]=true end
    if o.Name=="Generator" then ESPCache.Generators[o]=true
    elseif o.Name=="Window" then ESPCache.Windows[o]=true
    elseif o.Name=="Pallet" or o.Name=="Palletwrong" then ESPCache.Pallets[o]=true end
end
workspace.DescendantAdded:Connect(function(o)
    local n = string.lower(o.Name)
    if string.find(n, "scp") then ESPCache.SCP[o]=true end
    if o.Name=="Generator" then ESPCache.Generators[o]=true
    elseif o.Name=="Window" then ESPCache.Windows[o]=true
    elseif o.Name=="Pallet" or o.Name=="Palletwrong" then ESPCache.Pallets[o]=true end
end)
workspace.DescendantRemoving:Connect(function(o)
    ESPCache.SCP[o]=nil; ESPCache.Generators[o]=nil; ESPCache.Windows[o]=nil; ESPCache.Pallets[o]=nil
    if ESPCache.Objects[o] then ESPCache.Objects[o]:Destroy(); ESPCache.Objects[o]=nil end
end)

local function rmESP(o)
    if ESPCache.Objects[o] then ESPCache.Objects[o]:Destroy(); ESPCache.Objects[o]=nil end
end
local function crESP(o, col)
    if not o then return end
    if ESPCache.Objects[o] then ESPCache.Objects[o].FillColor=col; ESPCache.Objects[o].OutlineColor=col; return end
    local h = Instance.new("Highlight")
    h.FillColor=col; h.OutlineColor=col; h.FillTransparency=0.9; h.OutlineTransparency=0.3
    h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.Parent=o
    ESPCache.Objects[o]=h
    o.AncestryChanged:Connect(function(_,p) if not p then rmESP(o) end end)
end
local function rmSESP(c)
    if ESPCache.Status[c] then ESPCache.Status[c]:Destroy(); ESPCache.Status[c]=nil end
end
local function GetItem(c)
    if not c then return nil end
    for _,o in ipairs(c:GetChildren()) do
        if ESPItems[o.Name] then return o.Name end
        if o:IsA("Tool") and ESPItems[o.Name] then return o.Name end
    end
    return nil
end
local function GV(o,n)
    if not o then return nil end
    local a = o:GetAttribute(n); if a~=nil then return a end
    local ch = o:FindFirstChild(n)
    if ch then local ok,v = pcall(function() return ch.Value end); if ok then return v end end
    return nil
end
local function AGH(o, col)
    local h = o:FindFirstChild("GenHighlight") or Instance.new("Highlight")
    h.Name="GenHighlight"; h.Adornee=o; h.FillColor=col; h.OutlineColor=col
    h.FillTransparency=0.9; h.OutlineTransparency=0.3; h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.Parent=o
end
local function CB(text, col)
    local b = Instance.new("BillboardGui")
    b.Name="GenESP"; b.Size=UDim2.new(0,100,0,30); b.AlwaysOnTop=true
    local l = Instance.new("TextLabel")
    l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.Text=text
    l.TextColor3=col; l.TextStrokeTransparency=0; l.Font=Enum.Font.GothamBold; l.TextSize=12; l.Parent=b
    return b
end
local function UGen(g)
    if not g or not g.Parent then return end
    if not ESP.Generator then
        local o = g:FindFirstChild("GenESP"); if o then o:Destroy() end
        local h = g:FindFirstChild("GenHighlight"); if h then h:Destroy() end
        return
    end
    local p = GV(g,"RepairProgress") or GV(g,"Progress") or 0
    local b = g:FindFirstChild("GenESP")
    if p>=100 then if b then b:Destroy() end; return end
    local cp = math.clamp(p,0,100)
    local col = W.GeneratorColor:Lerp(Color3.fromRGB(0,255,120), cp/100)
    local tx = string.format("[%.0f%%]", p)
    if not b then
        b = CB(tx, col); b.Adornee=g; b.Parent=g
    else
        local lb = b:FindFirstChildOfClass("TextLabel")
        if lb then lb.Text=tx; lb.TextColor3=col end
    end
    AGH(g, col)
end
local function UMESP(o, r)
    if not o or not r then return end
    local ps
    if o:IsA("Model") then ps = o:GetPivot().Position
    elseif o:IsA("BasePart") then ps = o.Position end
    if not ps then return end
    local d = (ps-r.Position).Magnitude
    if o.Name=="Window" then
        if ESP.Window and d<=ESP.Distance then crESP(o, W.WindowColor) else rmESP(o) end
    end
    if o.Name=="Pallet" or o.Name=="Palletwrong" then
        if ESP.Pallet and d<=ESP.Distance then crESP(o, W.PalletColor) else rmESP(o) end
    end
end
local function CSESP(p, c, r)
    if not ESPStatus.Enabled then rmSESP(c); return end
    if not r then return end
    local h = c:FindFirstChild("Head")
    local hu = c:FindFirstChildOfClass("Humanoid")
    if not h or not hu then return end
    local isD = hu.Health<=0 or hu.Health<2 or c:GetAttribute("Downed")==true or c:GetAttribute("IsDown")==true or c:GetAttribute("Knocked")==true
    local d = (h.Position - r.Position).Magnitude
    if d > ESPStatus.Radius then rmSESP(c); return end
    local t = ""
    if isD then t = "[DOWN]\n" end
    if ESPStatus.ShowName then
        t = t .. p.Name
        if ESPStatus.ShowItem then local it = GetItem(c); if it then t = t.." ["..it.."]" end end
        t = t.."\n"
    end
    if ESPStatus.ShowDistance then t = t..string.format("Dist: %.0f\n", d) end
    if ESPStatus.ShowHealth then t = t..string.format("HP: %.0f\n", hu.Health) end
    if t=="" then rmSESP(c); return end
    local tc = Color3.new(1,1,1)
    if p.Team then
        if p.Team.Name=="Killer" then tc = TeamColors.Killer
        elseif p.Team.Name=="Survivors" then tc = TeamColors.Survivor end
    end
    if isD then tc = Color3.fromRGB(255,0,0) end
    local b = ESPCache.Status[c]
    if not b then
        b = Instance.new("BillboardGui")
        b.Size = UDim2.new(0,120,0,50); b.AlwaysOnTop=true
        local lb = Instance.new("TextLabel")
        lb.Size=UDim2.new(1,0,1,0); lb.BackgroundTransparency=1; lb.TextColor3=tc
        lb.TextStrokeTransparency=0; lb.Font=Enum.Font.GothamBold; lb.TextSize=12; lb.Text=t; lb.Parent=b
        b.Adornee=h; b.StudsOffset=Vector3.new(0,2.5,0); b.Parent=c
        ESPCache.Status[c] = b
    else
        local lb = b:FindFirstChildOfClass("TextLabel")
        if lb then lb.Text=t; lb.TextColor3=tc end
    end
end
local function USCP(r)
    if not ESP.SCP then for o in pairs(ESPCache.SCP) do rmESP(o) end return end
    for o in pairs(ESPCache.SCP) do
        if o and o.Parent then
            local ps
            if o:IsA("Model") then ps = o:GetPivot().Position
            elseif o:IsA("BasePart") then ps = o.Position end
            if ps then
                if (ps-r.Position).Magnitude <= ESP.Distance then crESP(o, W.SCPColor) else rmESP(o) end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    local r = GetRoot()
    if not r then return end
    local now = tick()
    if now - W.Timers.lastESPUpdate < 0.05 then return end
    W.Timers.lastESPUpdate = now
    for _,p in pairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character then
            local c = p.Character
            local h = c:FindFirstChildOfClass("Humanoid")
            if h and h.Health>0 then
                local hrp = c:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local d = (hrp.Position-r.Position).Magnitude
                    if d <= ESP.Distance then
                        if ESP.Survivor and p.Team and p.Team.Name=="Survivors" then crESP(c, TeamColors.Survivor)
                        elseif ESP.Killer and p.Team and p.Team.Name=="Killer" then crESP(c, TeamColors.Killer)
                        else rmESP(c) end
                    else rmESP(c) end
                end
                CSESP(p, c, r)
            else rmESP(c) end
        end
    end
    if ESP.Generator then for g in pairs(ESPCache.Generators) do UGen(g) end end
    for o in pairs(ESPCache.Windows) do UMESP(o, r) end
    for o in pairs(ESPCache.Pallets) do UMESP(o, r) end
    USCP(r)
end)

-- UI
local Window = Library:CreateWindow({
    Title = "Wisnu Hub",
    Footer = 'Violence District | Multi-Feature',
    Icon = "81633822407558",
    IconSize = UDim2.fromOffset(45,45),
    NotifySide = "Right",
    EnableSidebarResize = true,
    EnableCompacting = true,
    SidebarCompacted = true,
    Size = UDim2.fromOffset(500,400),
    CornerRadius = 4,
    AutoShow = true,
})

local Tabs = {
    Combat = Window:AddTab("Combat", "swords", "Auto Parry + Silent Aim"),
    Killer = Window:AddTab("Killer", "skull", "Killer Utilities"),
    Visuals = Window:AddTab("Visuals", "eye", "Camera & Visual Features"),
    Survivor = Window:AddTab("Survivor", "user", "Survivor Utilities"),
    UISettings = Window:AddTab("UI Settings", "settings-2", "Config, Theme, UiSetting"),
}

-- COMBAT TAB
local CombatLeft = Tabs.Combat:AddLeftGroupbox("Auto Parry", "swords")
local CombatRight = Tabs.Combat:AddRightGroupbox("Silent Aim ToF", "target")
local CombatFlashBox = Tabs.Combat:AddLeftGroupbox("Silent Aim Flashlight", "flashlight")
local CombatVeilBox = Tabs.Combat:AddRightGroupbox("Silent Aim Spear (Veil)", "sword")
local CombatDashBox = Tabs.Combat:AddLeftGroupbox("Dash Lock (Killer)", "zap")

local Config = W.Config

CombatLeft:AddCheckbox("AutoParry", {
    Text = "Auto Parry", Default = false,
    Callback = function(v) Config.Surv_AutoParry = v end,
}):AddKeyPicker("AutoParryKey", { Default="None", Text="Auto Parry Key", Mode="Toggle", Callback=function(v) Config.Surv_AutoParry = v end })

CombatLeft:AddCheckbox("Surv_ParrySafety", { Text = "Safety Parry", Default = false, Callback = function(v) Config.Surv_ParrySafety = v end })
CombatLeft:AddToggle("ParryAggressive", { Text = "Aggressive Mode", Default = false, Callback = function(v) Config.Surv_ParryAggressive = v end })
CombatLeft:AddToggle("ParryCircle", { Text = "ESP Range Circle", Default = true, Callback = function(v) Config.Surv_ParryCircle = v end })
CombatLeft:AddSlider("ParryRadius", { Text = "Parry Radius", Default = 15, Min = 5, Max = 25, Rounding = 0, Callback = function(v) Config.Surv_ParryRadius = v end })
CombatLeft:AddSlider("ParryFace", { Text = "Face Sensitivity", Default = 7, Min = -10, Max = 10, Rounding = 0, Callback = function(v) Config.Surv_ParryFace = v / 10 end })
CombatLeft:AddDropdown("IgnoreSkills", {
    Values = { "Hidden S1", "Abyssal S1" }, Default = {}, Multi = true, Text = "Abaikan skill tertentu",
    Callback = function(val)
        local p = {}
        for k, v in pairs(val) do
            if type(k)=="string" and v then p[k]=true
            elseif type(v)=="string" then p[v]=true end
        end
        Config.Ignored_Skills_List = p
    end,
})
CombatLeft:AddToggle("Surv_AutoCrouch", { Text = "Auto Crouch (Dodge S1)", Default = false, Callback = function(v) Config.Surv_AutoCrouch = v end })

CombatRight:AddCheckbox("ToFSilentAim", {
    Text = "Enable Silent Aim", Default = false,
    Callback = function(v) W.SetToFSilentAim(v); VD_Notify("Silent Aim ToF", v and "Enabled" or "Disabled", 2) end,
}):AddKeyPicker("ToFSilentAimKey", {
    Default = "Q", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(s) W.SetToFSilentAim(s); VD_Notify("Silent Aim ToF", s and "Enabled" or "Disabled", 2) end,
    ChangedCallback = function(New) VD.TOF_Key = New.Name or "None" end,
})
CombatRight:AddDropdown("ToFTargetMode", { Text = "Target Mode", Values = {"Killer","Survivors","Zombie"}, Default = 1, Multi = false, Callback = function(v) W.ToF_SetTargetMode(v, true) end })
CombatRight:AddToggle("ToFLaserToggle", { Text = "Show Laser Beam", Default = true, Callback = function(v) VD.TOF_Laser = v; if not v then W.ToF_ClearLaser() end end })
CombatRight:AddToggle("ToFWallCheck", { Text = "Wall Check", Default = true, Callback = function(v) VD.TOF_WallCheck = v end })
CombatRight:AddToggle("ToFBlockKnocked", { Text = "Block When Knocked", Default = true, Callback = function(v) VD.TOF_BlockKnocked = v end })
CombatRight:AddLabel("Quick Hotkeys (PC):\nK = Killer\nJ = Survivor\nL = Zombie")

CombatFlashBox:AddCheckbox("FlashSilentAim", {
    Text = "Enable Silent Aim", Default = false,
    Callback = function(v) W.Flash_SetSilentAim(v); VD_Notify("Silent Aim Flashlight", v and "Enabled" or "Disabled", 2) end,
}):AddKeyPicker("FlashSilentAimKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(s) W.Flash_SetSilentAim(s); VD_Notify("Silent Aim Flashlight", s and "Enabled" or "Disabled", 2) end,
})
CombatFlashBox:AddDropdown("FlashTargetPart", { Text = "Target Part", Values = {"Head","UpperTorso","Torso","HumanoidRootPart"}, Default = 1, Multi = false, Callback = function(v) VD.FLASH_TargetPart = v end })
CombatFlashBox:AddSlider("FlashRange", { Text = "Aim Range", Default = 120, Min = 20, Max = 500, Rounding = 0, Callback = function(v) VD.FLASH_Range = v end })
CombatFlashBox:AddSlider("FlashSmooth", { Text = "Smoothness", Default = 0.35, Min = 0.05, Max = 1, Rounding = 2, Callback = function(v) VD.FLASH_Smooth = v end })
CombatFlashBox:AddToggle("FlashLaserToggle", { Text = "Show Laser Beam", Default = true, Callback = function(v) VD.FLASH_Laser = v; if not v then W.Flash_ClearLaser() end end })

CombatVeilBox:AddCheckbox("VeilEnabled", {
    Text = "Enable Silent Aim", Default = false,
    Callback = function(v) VeilConfig.Enabled = v; VD_Notify("Silent Aim Veil Spear", v and "Enabled" or "Disabled", 2) end,
}):AddKeyPicker("VeilKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(s) VeilConfig.Enabled = s; VD_Notify("Silent Aim Veil Spear", s and "Enabled" or "Disabled", 2) end,
})
CombatVeilBox:AddSlider("VeilFOV", { Text = "FOV", Default = 220, Min = 50, Max = 800, Rounding = 0, Callback = function(v) VeilConfig.FOV = v end })
CombatVeilBox:AddDropdown("VeilTargetPart", { Text = "Target Part", Values = {"Torso","Head","Root"}, Default = 1, Multi = false, Callback = function(v) VeilConfig.TargetPart = v end })
CombatVeilBox:AddSlider("VeilSpearSpeed", { Text = "Spear Speed", Default = 165, Min = 50, Max = 400, Rounding = 0, Callback = function(v) VeilConfig.SpearSpeed = v end })
CombatVeilBox:AddSlider("VeilMaxDist", { Text = "Max Distance", Default = 200, Min = 20, Max = 200, Rounding = 0, Callback = function(v) VeilConfig.MaxDist = v end })
CombatVeilBox:AddSlider("VeilGravity", { Text = "Gravity", Default = math.floor(workspace.Gravity*0.5), Min = 0, Max = 300, Rounding = 0, Callback = function(v) VeilConfig.Gravity = v end })
CombatVeilBox:AddToggle("VeilAutoPredict", { Text = "Auto Prediction", Default = false, Callback = function(v) VeilConfig.AutoPredict = v end })
CombatVeilBox:AddSlider("VeilPredictFactor", { Text = "Horizontal Predict", Default = 1.0, Min = 0, Max = 3, Rounding = 1, Callback = function(v) VeilConfig.HorizontalPredictFactor = v end })
CombatVeilBox:AddToggle("VeilShowFOV", { Text = "Show FOV Circle", Default = true, Callback = function(v) VeilConfig.ShowFOV = v end })
CombatVeilBox:AddToggle("VeilShowLaser", { Text = "Show Target Laser", Default = true, Callback = function(v) VeilConfig.ShowTargetLaser = v end })
CombatVeilBox:AddToggle("VeilShowTracer", { Text = "Show Prediction Tracer", Default = true, Callback = function(v) end })

CombatDashBox:AddCheckbox("DashLockEnabled", {
    Text = "Enable Dash Lock", Default = false,
    Callback = function(v) VD.DashLockEnabled = v; if not v then W.MAWWW_SetDashLockActive(false) end; VD_Notify("Dash Lock", v and "Enabled" or "Disabled", 2) end,
}):AddKeyPicker("DashLockKey", {
    Default = "None", Text = "Toggle Key", Mode = "Toggle",
    Callback = function(s) VD.DashLockEnabled = s; if not s then W.MAWWW_SetDashLockActive(false) end end,
})
CombatDashBox:AddSlider("DashLockSmooth", { Text = "Camera Smoothness", Default = 0.3, Min = 0.05, Max = 1, Rounding = 2, Callback = function(v) VD.DashLockSmoothness = v end })
CombatDashBox:AddSlider("DashLockDur", { Text = "Lock Duration", Default = 1.5, Min = 0.2, Max = 5, Rounding = 1, Callback = function(v) VD.DashLockDuration = v end })
CombatDashBox:AddToggle("DashLockFreeze", { Text = "Freeze Movement During Lock", Default = false, Callback = function(v)
    VD.FreezeDuringDashLock = v
    if not v then
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h and h.WalkSpeed==0 then h.WalkSpeed=16 end
    end
end })

-- KILLER TAB
local KillerAbilityBox = Tabs.Killer:AddLeftGroupbox("Ability Killer", "shield")
local KillerInfoBox = Tabs.Killer:AddRightGroupbox("Info", "info")

KillerAbilityBox:AddCheckbox("NoSlowdown", {
    Text = "No Slowdown", Default = false,
    Callback = function(v) VD.KILLER_NoSlowdown = v; VD_Notify("No Slowdown", v and "Enabled" or "Disabled", 2) end,
}):AddKeyPicker("NoSlowdownKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s) VD.KILLER_NoSlowdown = s end })
KillerAbilityBox:AddSlider("SpeedValue", { Text = "Speed Value", Default = 16, Min = 16, Max = 32, Rounding = 0, Callback = function(v) VD.SPEED_Value = v end })
KillerAbilityBox:AddDivider()

KillerAbilityBox:AddCheckbox("AutoHook", {
    Text = "Auto Hook", Default = false,
    Callback = function(v) VD.KILLER_AutoHook = v; VD_Notify("Auto Hook", v and "Enabled" or "Disabled", 2) end,
}):AddKeyPicker("AutoHookKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s) VD.KILLER_AutoHook = s end })
KillerAbilityBox:AddDivider()

KillerAbilityBox:AddCheckbox("BypassCooldownAbyss", {
    Text = "Bypass Cooldown (Abyss)", Default = false,
    Callback = function(v) VD.KILLER_BypassCooldown = v; if v then W.MAWWW_StartAbyssCooldownBypass() else W.MAWWW_StopAbyssCooldownBypass() end end,
}):AddKeyPicker("BypassCooldownKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s) VD.KILLER_BypassCooldown=s; if s then W.MAWWW_StartAbyssCooldownBypass() else W.MAWWW_StopAbyssCooldownBypass() end end })
KillerAbilityBox:AddCheckbox("BypassLeapHidden", {
    Text = "Bypass Cooldown (Hidden)", Default = false,
    Callback = function(v) VD.KILLER_BypassLeap = v; if v then W.MAWWW_StartHiddenCooldownBypass() else W.MAWWW_StopHiddenCooldownBypass() end end,
}):AddKeyPicker("BypassLeapKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s) VD.KILLER_BypassLeap=s; if s then W.MAWWW_StartHiddenCooldownBypass() else W.MAWWW_StopHiddenCooldownBypass() end end })
KillerAbilityBox:AddCheckbox("InfFrenzyJeff", {
    Text = "Bypass Cooldown (Jeff)", Default = false,
    Callback = function(v) VD.KILLER_InfFrenzy = v; if v then W.MAWWW_StartJeffCooldownBypass() else W.MAWWW_StopJeffCooldownBypass() end end,
}):AddKeyPicker("InfFrenzyKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s) VD.KILLER_InfFrenzy=s; if s then W.MAWWW_StartJeffCooldownBypass() else W.MAWWW_StopJeffCooldownBypass() end end })
KillerAbilityBox:AddCheckbox("InfLakeMistSlasher", {
    Text = "Inf Lake Mist (Slasher)", Default = false,
    Callback = function(v) VD.KILLER_InfLakeMist = v; if v then W.MAWWW_StartSlasherCooldownBypass() else W.MAWWW_StopSlasherCooldownBypass() end end,
}):AddKeyPicker("InfLakeMistKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s) VD.KILLER_InfLakeMist=s; if s then W.MAWWW_StartSlasherCooldownBypass() else W.MAWWW_StopSlasherCooldownBypass() end end })
KillerAbilityBox:AddCheckbox("InfPursuitSlasher", {
    Text = "Inf Pursuit (Slasher)", Default = false,
    Callback = function(v) VD.KILLER_InfPursuit = v; if v then W.MAWWW_StartSlasherCooldownBypass() else W.MAWWW_StopSlasherCooldownBypass() end end,
}):AddKeyPicker("InfPursuitKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s) VD.KILLER_InfPursuit=s; if s then W.MAWWW_StartSlasherCooldownBypass() else W.MAWWW_StopSlasherCooldownBypass() end end })
KillerAbilityBox:AddDivider()

KillerAbilityBox:AddCheckbox("AntiBlind", {
    Text = "Anti Blind (Flashlight)", Default = false,
    Callback = function(v) VD.KILLER_AntiBlind = v; VD_Notify("Anti Blind", v and "Enabled" or "Disabled", 2) end,
}):AddKeyPicker("AntiBlindKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s) VD.KILLER_AntiBlind=s end })
KillerAbilityBox:AddDivider()

KillerAbilityBox:AddCheckbox("BlockVaults", {
    Text = "Block All Vaults", Default = false,
    Callback = function(v) VD.KILLER_BlockVaults = v; VD_Notify("Block Vaults", v and "Enabled" or "Disabled", 2) end,
}):AddKeyPicker("BlockVaultsKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s) VD.KILLER_BlockVaults=s end })
KillerAbilityBox:AddDivider()

KillerAbilityBox:AddCheckbox("AutoStalk", {
    Text = "Auto Stalk (Myers)", Default = false,
    Callback = function(v)
        W.AutoStalk.Enabled = v
        if v then W.startAutoStalk() else W.stopAutoStalk() end
        VD_Notify("Auto Stalk", v and "Enabled" or "Disabled", 2)
    end,
}):AddKeyPicker("AutoStalkKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s)
    W.AutoStalk.Enabled = s
    if s then W.startAutoStalk() else W.stopAutoStalk() end
end })
KillerAbilityBox:AddSlider("StalkRange", { Text = "Stalk Range", Default = 150, Min = 20, Max = 500, Rounding = 0, Callback = function(v) W.AutoStalk.StalkRange = v end })
KillerAbilityBox:AddDivider()

KillerAbilityBox:AddCheckbox("BeatGameKiller", {
    Text = "Auto Kill All (Beat Game)", Default = false,
    Callback = function(v) VD.BEAT_Killer = v; if not v then VD._KillerTarget = nil end end,
}):AddKeyPicker("BeatGameKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s) VD.BEAT_Killer=s; if not s then VD._KillerTarget=nil end end })
KillerAbilityBox:AddDivider()

KillerAbilityBox:AddCheckbox("FakeAttack", {
    Text = "Counter Auto Parry", Default = false,
    Callback = function(v) VD.KILLER_FakeAttack = v; W.MAWWW_ToggleFakeAttack(v) end,
}):AddKeyPicker("FakeAttackKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s) VD.KILLER_FakeAttack=s; W.MAWWW_ToggleFakeAttack(s) end })

KillerInfoBox:AddLabel("Fitur Killer:\n- No Slowdown\n- Auto Hook\n- Bypass (Abyss/Hidden/Jeff/Slasher)\n- Anti Blind\n- Block All Vaults\n- Auto Stalk\n- Auto Kill All\n- Counter Auto Parry")

-- VISUALS TAB
local VisualLockPOVBox = Tabs.Visuals:AddLeftGroupbox("Lock POV (FOV)", "eye")
local VisualESPBox = Tabs.Visuals:AddRightGroupbox("ESP Cham", "scan-eye")
local VisualESPStatusBox = Tabs.Visuals:AddLeftGroupbox("ESP Status", "scan-eye")
local VisualMorphBox = Tabs.Visuals:AddRightGroupbox("Morph Avatar", "user")

VisualLockPOVBox:AddCheckbox("LockPOVEnabled", {
    Text = "Enable Lock POV", Default = false,
    Callback = function(v) LockPOV_SetEnabled(v) end,
}):AddKeyPicker("LockPOVKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s) LockPOV_SetEnabled(s) end })
VisualLockPOVBox:AddSlider("LockedFOV", { Text = "Locked FOV", Default = 80, Min = 40, Max = 120, Rounding = 0, Callback = function(v)
    W.LockPOV.LockedFOV = v
    if W.LockPOV.Enabled then local cam = workspace.CurrentCamera; if cam then cam.FieldOfView = v end end
end })
VisualLockPOVBox:AddDivider()
VisualLockPOVBox:AddButton({ Text="Preset: Normal (70)", Func=function() W.LockPOV.LockedFOV=70; if Options and Options.LockedFOV then Options.LockedFOV:SetValue(70) end; if W.LockPOV.Enabled then local c=workspace.CurrentCamera; if c then c.FieldOfView=70 end end end })
VisualLockPOVBox:AddButton({ Text="Preset: Wide (100)", Func=function() W.LockPOV.LockedFOV=100; if Options and Options.LockedFOV then Options.LockedFOV:SetValue(100) end; if W.LockPOV.Enabled then local c=workspace.CurrentCamera; if c then c.FieldOfView=100 end end end })
VisualLockPOVBox:AddButton({ Text="Preset: Ultra Wide (120)", Func=function() W.LockPOV.LockedFOV=120; if Options and Options.LockedFOV then Options.LockedFOV:SetValue(120) end; if W.LockPOV.Enabled then local c=workspace.CurrentCamera; if c then c.FieldOfView=120 end end end })

local SurvESPCB = VisualESPBox:AddCheckbox("SurvivorESP", { Text = "ESP Survivor", Default = false, Callback = function(v) W.ESP.Survivor = v end })
SurvESPCB:AddColorPicker("SurvivorESPColor", { Default = W.TeamColors.Survivor, Title = "Survivor Color", Callback = function(c) W.TeamColors.Survivor = c end })
local KillerESPCB = VisualESPBox:AddCheckbox("KillerESP", { Text = "ESP Killer", Default = false, Callback = function(v) W.ESP.Killer = v end })
KillerESPCB:AddColorPicker("KillerESPColor", { Default = W.TeamColors.Killer, Title = "Killer Color", Callback = function(c) W.TeamColors.Killer = c end })
local GenESPCB = VisualESPBox:AddCheckbox("ESPGenerator", { Text = "Generator", Default = false, Callback = function(v) W.ESP.Generator = v end })
GenESPCB:AddColorPicker("GeneratorColor", { Default = W.GeneratorColor, Title = "Generator Color", Callback = function(v) W.GeneratorColor = v end })
local SCPESPCB = VisualESPBox:AddCheckbox("ESPSCP", { Text = "SCP", Default = false, Callback = function(v) W.ESP.SCP = v end })
SCPESPCB:AddColorPicker("SCPColor", { Default = W.SCPColor, Title = "SCP Color", Callback = function(v) W.SCPColor = v end })
local PalletESPCB = VisualESPBox:AddCheckbox("ESPPallet", { Text = "Pallet", Default = false, Callback = function(v) W.ESP.Pallet = v end })
PalletESPCB:AddColorPicker("PalletColor", { Default = W.PalletColor, Title = "Pallet Color", Callback = function(v) W.PalletColor = v end })
local WindowESPCB = VisualESPBox:AddCheckbox("ESPWindow", { Text = "Window", Default = false, Callback = function(v) W.ESP.Window = v end })
WindowESPCB:AddColorPicker("WindowColor", { Default = W.WindowColor, Title = "Window Color", Callback = function(v) W.WindowColor = v end })
VisualESPBox:AddSlider("ESPDistance", { Text = "ESP Radius", Default = 100, Min = 10, Max = 1000, Rounding = 0, Callback = function(v) W.ESP.Distance = v end })

VisualESPStatusBox:AddCheckbox("EnableStatus", { Text = "Enable Status ESP", Default = false, Callback = function(v) W.ESPStatus.Enabled = v end })
VisualESPStatusBox:AddCheckbox("ShowName", { Text = "Show Name", Default = true, Callback = function(v) W.ESPStatus.ShowName = v end })
VisualESPStatusBox:AddCheckbox("ShowItemESP", { Text = "Show Item", Default = true, Callback = function(v) W.ESPStatus.ShowItem = v end })
VisualESPStatusBox:AddCheckbox("ShowDistance", { Text = "Show Distance", Default = true, Callback = function(v) W.ESPStatus.ShowDistance = v end })
VisualESPStatusBox:AddCheckbox("ShowHealth", { Text = "Show Health", Default = false, Callback = function(v) W.ESPStatus.ShowHealth = v end })
VisualESPStatusBox:AddSlider("StatusRadius", { Text = "Status Radius", Default = 100, Min = 20, Max = 500, Rounding = 0, Callback = function(v) W.ESPStatus.Radius = v end })

VisualMorphBox:AddButton({ Text = "Apply Korless", Func = function() W.ApplyKorless(); VD_Notify("Morph Avatar", "Korless Applied", 2) end })

-- SURVIVOR TAB
local SurvSkillBox = Tabs.Survivor:AddLeftGroupbox("Auto Skill Check", "check-circle")
local SurvGenBox = Tabs.Survivor:AddRightGroupbox("Bypass Generator", "zap")
local SurvAbilitiesBox = Tabs.Survivor:AddLeftGroupbox("Abilities", "shield")
local SurvFakePerksBox = Tabs.Survivor:AddRightGroupbox("Fake Perks", "star")

SurvSkillBox:AddCheckbox("SkillCheck", {
    Text = "Auto Skill Check", Default = false,
    Callback = function(v)
        W.Auto.SkillCheck = v
        if v then
            if not W.Connections.SkillHeartbeat then
                W.Connections.SkillHeartbeat = W.RunService.RenderStepped:Connect(function()
                    if not W.Auto.SkillCheck or W.State.busy then return end
                    local pg = W.PlayerGui
                    local pr = pg:FindFirstChild("SkillCheckPromptGui"); if not pr then return end
                    local ch = pr:FindFirstChild("Check"); if not ch or not ch.Visible then return end
                    local ln = ch:FindFirstChild("Line"); local gl = ch:FindFirstChild("Goal")
                    if not ln or not gl then return end
                    if W.Auto.SkillCheckMode == "Instant" then
                        ln.Rotation = gl.Rotation + 109
                        W.State.busy = true
                        task.spawn(function()
                            if W.UserInputService.TouchEnabled then
                                W.VirtualInputManager:SendTouchEvent(8822, 0, 0, 0)
                            else
                                W.VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                                task.wait()
                                W.VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                            end
                            task.wait(0.2)
                            W.State.busy = false
                        end)
                    end
                end)
            end
        else
            if W.Connections.SkillHeartbeat then W.Connections.SkillHeartbeat:Disconnect(); W.Connections.SkillHeartbeat=nil end
        end
    end,
})
SurvSkillBox:AddDropdown("SkillCheckModeDropdown", { Values = {"Legit","Instant"}, Default = 1, Multi = false, Text = "Skill Check Mode", Callback = function(v) W.Auto.SkillCheckMode = v end })

SurvGenBox:AddCheckbox("GenBypassToggle", {
    Text = "Boost Gen Bypass", Default = false,
    Callback = function(v) W.setGenBypass(v) end,
}):AddKeyPicker("GenBypassKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s) W.setGenBypass(s) end })

SurvAbilitiesBox:AddCheckbox("AntiFallDamage", {
    Text = "Anti Fall Damage", Default = false,
    Callback = function(v) W.PlayerMods.AntiFall = v end,
}):AddKeyPicker("AntiFallKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s) W.PlayerMods.AntiFall=s end })
SurvAbilitiesBox:AddDivider()
SurvAbilitiesBox:AddCheckbox("PalletDrop", {
    Text = "Auto Drop Pallet", Default = false,
    Callback = function(v) W.Auto.PalletDrop = v end,
}):AddKeyPicker("PalletDropKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s) W.Auto.PalletDrop=s end })
SurvAbilitiesBox:AddSlider("PalletDropDist", { Text = "Trigger Distance", Default = 6, Min = 3, Max = 30, Rounding = 0, Callback = function(v) W.Auto.PalletDropDist = v end })
SurvAbilitiesBox:AddDivider()
SurvAbilitiesBox:AddCheckbox("AutoFlee", {
    Text = "Auto Flee Killer", Default = false,
    Callback = function(v) W.Auto.Flee = v end,
}):AddKeyPicker("AutoFleeKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s) W.Auto.Flee=s end })
SurvAbilitiesBox:AddSlider("FleeDist", { Text = "Flee Detect Distance", Default = 50, Min = 10, Max = 200, Rounding = 0, Callback = function(v) W.Auto.FleeDist = v end })
SurvAbilitiesBox:AddSlider("FleeCooldown", { Text = "Flee Cooldown", Default = 0.1, Min = 0.1, Max = 5, Rounding = 2, Callback = function(v) W.Auto.FleeCooldown = v end })
SurvAbilitiesBox:AddDivider()
SurvAbilitiesBox:AddCheckbox("FirstPerson", {
    Text = "First Person (Survivor)", Default = false,
    Callback = function(v) VD.SURV_FirstPerson = v; if not v then W.RestoreFirstPersonCamera() end end,
}):AddKeyPicker("FirstPersonKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s) VD.SURV_FirstPerson=s; if not s then W.RestoreFirstPersonCamera() end end })
SurvAbilitiesBox:AddDivider()
SurvAbilitiesBox:AddCheckbox("SelfHeal", {
    Text = "Self Heal", Default = false,
    Callback = function(v) W.setInstantHealSelf(v) end,
}):AddKeyPicker("SelfHealKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s) W.setInstantHealSelf(s) end })
SurvAbilitiesBox:AddCheckbox("HealAll", {
    Text = "Heal All", Default = false,
    Callback = function(v) W.setAutoHealAll(v) end,
}):AddKeyPicker("HealAllKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s) W.setAutoHealAll(s) end })
SurvAbilitiesBox:AddDivider()

SurvAbilitiesBox:AddCheckbox("WalkSpeed", {
    Text = "Walk Speed", Default = false,
    Tooltip = "Override WalkSpeed (auto-stop saat vault/downed)",
    Callback = function(v)
        VD.SURV_WalkSpeedEnabled = v
        if v then W.applyWalkSpeed()
        else
            if W.Connections.WalkSpeed then W.Connections.WalkSpeed:Disconnect(); W.Connections.WalkSpeed=nil end
            local c = LocalPlayer.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = 16 end
        end
    end,
}):AddKeyPicker("WalkSpeedKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s)
    VD.SURV_WalkSpeedEnabled = s
    if s then W.applyWalkSpeed()
    else
        if W.Connections.WalkSpeed then W.Connections.WalkSpeed:Disconnect(); W.Connections.WalkSpeed=nil end
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = 16 end
    end
end })

SurvAbilitiesBox:AddSlider("WalkSpeedValue", { Text = "Walk Speed Value", Default = 16, Min = 16, Max = 32, Rounding = 1, Callback = function(v)
    VD.SURV_WalkSpeedValue = v
    if VD.SURV_WalkSpeedEnabled then W.applyWalkSpeed() end
end })

SurvAbilitiesBox:AddCheckbox("JumpPower", {
    Text = "Jump Power", Default = false,
    Callback = function(v)
        VD.SURV_JumpPowerEnabled = v
        if v then W.applyJumpPower()
        else
            local c = LocalPlayer.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if h then h.JumpPower = 50 end
        end
    end,
}):AddKeyPicker("JumpPowerKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s)
    VD.SURV_JumpPowerEnabled = s
    if s then W.applyJumpPower()
    else
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then h.JumpPower = 50 end
    end
end })

SurvAbilitiesBox:AddSlider("JumpPowerValue", { Text = "Jump Power Value", Default = 50, Min = 0, Max = 200, Rounding = 0, Callback = function(v)
    VD.SURV_JumpPowerValue = v
    if VD.SURV_JumpPowerEnabled then W.applyJumpPower() end
end })

SurvFakePerksBox:AddSlider("FP_Cooldown", { Text = "Cooldown (semua perks)", Default = 10, Min = 0, Max = 60, Rounding = 0, Suffix = "s", Callback = function(val) W.FP.CooldownTime = val end })
SurvFakePerksBox:AddDivider()
SurvFakePerksBox:AddCheckbox("FP_Flowstate", {
    Text = "Flowstate", Default = false, Tooltip = "Trigger: Vault/Slide\nEffect: +5 speed 3s",
    Callback = function(v) W.FP_SetupFlowstate(v) end,
}):AddKeyPicker("FP_FlowstateKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s) W.FP_SetupFlowstate(s) end })
SurvFakePerksBox:AddCheckbox("FP_QuickRecovery", {
    Text = "Quick Recovery", Default = false, Tooltip = "Trigger: Selesai di-heal\nEffect: +6 speed 3s",
    Callback = function(v) W.FP_SetupQuickRecovery(v) end,
}):AddKeyPicker("FP_QuickRecoveryKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s) W.FP_SetupQuickRecovery(s) end })
SurvFakePerksBox:AddCheckbox("FP_PerfectLanding", {
    Text = "Perfect Landing", Default = false, Tooltip = "Trigger: Landing dari ketinggian\nEffect: +8 speed 3s",
    Callback = function(v) W.FP_SetupPerfectLanding(v) end,
}):AddKeyPicker("FP_PerfectLandingKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s) W.FP_SetupPerfectLanding(s) end })
SurvFakePerksBox:AddCheckbox("FP_AdrenalineRush", {
    Text = "Adrenaline Rush", Default = false, Tooltip = "Trigger: HP drop ke 50\nEffect: +4 speed 5s",
    Callback = function(v) W.FP_SetupAdrenalineRush(v) end,
}):AddKeyPicker("FP_AdrenalineRushKey", { Default="None", Text="Toggle Key", Mode="Toggle", Callback=function(s) W.FP_SetupAdrenalineRush(s) end })

-- UI SETTINGS
local SettingBox = Tabs.UISettings:AddLeftGroupbox("Menu", "wrench")
SettingBox:AddToggle("ShowCustomCursor", { Text = "Custom Cursor", Default = true, Callback = function(v) Library.ShowCustomCursor = v end })
SettingBox:AddDropdown("NotificationSide", { Values = {"Left","Right"}, Default = "Right", Text = "Notification Side", Callback = function(v) Library:SetNotifySide(v) end })
SettingBox:AddDropdown("DPIDropdown", { Values = {"50%","75%","85%","100%","125%","150%"}, Default = "85%", Text = "DPI Scale", Callback = function(v) v = v:gsub("%%",""); Library:SetDPIScale(tonumber(v)) end })
SettingBox:AddToggle("HeaderGlowToggle", { Text = "Glow AccentBar", Default = true, Callback = function(v) Window:SetHeaderGlow(v) end })
SettingBox:AddToggle("ShowProfile", { Text = "Show Profile", Default = true, Callback = function(v) Window:SetProfileVisible(v) end })
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

-- SETUP PLAYERS
for _, p in pairs(Players:GetPlayers()) do W.SetupPlayer(p) end
Players.PlayerAdded:Connect(W.SetupPlayer)
task.spawn(function()
    while true do
        task.wait(5)
        for _, p in pairs(Players:GetPlayers()) do W.TryAttach(p) end
    end
end)

-- MAIN LOOP
RunService.Heartbeat:Connect(function()
    W.HandleAutoPallet()
    W.UpdateNoSlowdown()
    W.MAWWW_AutoHook()
    W.MAWWW_BeatGameKiller()
    local now = tick()
    if VD.KILLER_BlockVaults and now - W.Timers.lastVaultBlock >= 1.5 then
        W.Timers.lastVaultBlock = now
        W.HandleBlockVaults()
    end
end)

RunService.RenderStepped:Connect(function()
    if W.State.AutoParryAdornment then
        local root = GetRoot()
        if root and Config.Surv_ParryCircle and Config.Surv_AutoParry then
            local cR = Config.Surv_ParryRadius
            W.State.AutoParryAdornment.Radius = cR
            W.State.AutoParryAdornment.InnerRadius = math.max(0.1, cR-0.15)
            W.State.AutoParryAdornment.CFrame = CFrame.new(0,-3,0) * CFrame.Angles(math.rad(90),0,0)
        else
            W.State.AutoParryAdornment:Destroy()
            W.State.AutoParryAdornment = nil
        end
    elseif Config.Surv_ParryCircle and Config.Surv_AutoParry then
        local root = GetRoot()
        if root then
            W.State.AutoParryAdornment = Instance.new("CylinderHandleAdornment")
            W.State.AutoParryAdornment.Name = "AutoParryCircleESP"
            W.State.AutoParryAdornment.Height = 0.05
            W.State.AutoParryAdornment.Transparency = 0.3
            W.State.AutoParryAdornment.Adornee = root
            W.State.AutoParryAdornment.Parent = root
            W.State.AutoParryAdornment.ZIndex = 0
            W.State.AutoParryAdornment.AlwaysOnTop = false
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.8)
    if VD.SURV_WalkSpeedEnabled then W.applyWalkSpeed() end
    if VD.SURV_JumpPowerEnabled then W.applyJumpPower() end
end)

Library:Notify({ Title = "Wisnu Hub", Description = "All Features Loaded!", Time = 3 })
print("[Wisnu Hub] File 4/4 loaded ✓ — All systems GO!")
-- PART 4 END
