--========================================================--
-- ALFzxzzz HUB v0.3.2 - LITE EDITION (FULL FEATURES)
-- Optimized: Master Scheduler + Early Exit + Dedup ESP
--========================================================--

getgenv().VD = getgenv().VD or {}
local W = getgenv()

VD.PARRY_Enabled        = VD.PARRY_Enabled or false
VD.PARRY_Aggressive     = VD.PARRY_Aggressive or false
VD.PARRY_Distance       = VD.PARRY_Distance or 10
VD.PARRY_ShowCircle     = VD.PARRY_ShowCircle or false
VD.PARRY_SilentParry    = VD.PARRY_SilentParry or false
VD.PARRY_ShowFloatBtn   = VD.PARRY_ShowFloatBtn or false
VD.AutoCrouch           = VD.AutoCrouch or false
VD.KILLER_AutoAttack         = VD.KILLER_AutoAttack or false
VD.KILLER_AutoAttackRange    = VD.KILLER_AutoAttackRange or 12
VD.KILLER_AutoAttackCooldown = VD.KILLER_AutoAttackCooldown or 0.15
VD.SURV_AutoFlee        = VD.SURV_AutoFlee or false
VD.SURV_AutoFleeDist    = VD.SURV_AutoFleeDist or 40
VD.SURV_AutoFleeCooldown= VD.SURV_AutoFleeCooldown or 1.5

VD.VeilEnabled          = VD.VeilEnabled or false
VD.VeilShowFOV          = VD.VeilShowFOV ~= false
VD.VeilShowTracker      = VD.VeilShowTracker or false
VD.VeilAutoPredict      = VD.VeilAutoPredict ~= false
VD.VeilFOV              = VD.VeilFOV or 150
VD.VeilMaxDist          = VD.VeilMaxDist or 300
VD.VeilSpearSpeed       = VD.VeilSpearSpeed or 165
VD.VeilGravity          = VD.VeilGravity or 103
VD.VeilAuraSpearSpeed   = VD.VeilAuraSpearSpeed or 165
VD.VeilAuraSpearGravity = VD.VeilAuraSpearGravity or 96
VD.VeilLeadMultiplier   = VD.VeilLeadMultiplier or 1.4
VD.TOF_SilentAim    = VD.TOF_SilentAim    or false
VD.TOF_TargetMode   = VD.TOF_TargetMode   or "Killer"
VD.TOF_Key          = VD.TOF_Key          or "Q"
VD.TOF_Laser        = VD.TOF_Laser        ~= false
VD.TOF_WallCheck    = VD.TOF_WallCheck    ~= false
VD.TOF_BlockKnocked = VD.TOF_BlockKnocked ~= false

VD.Invis_Enabled       = VD.Invis_Enabled       or false
VD.Invis_ShowFloatBtn  = VD.Invis_ShowFloatBtn  or false
VD.Invis_Hotkey        = VD.Invis_Hotkey        or "G"

VD.KILLER_BypassLeap     = VD.KILLER_BypassLeap     or false
VD.KILLER_InfGrab        = VD.KILLER_InfGrab        or false
VD.KILLER_InfLakeMist    = VD.KILLER_InfLakeMist    or false
VD.KILLER_InfPursuit     = VD.KILLER_InfPursuit     or false
VD.KILLER_BypassCooldown = VD.KILLER_BypassCooldown or false
VD.KILLER_InfFrenzy      = VD.KILLER_InfFrenzy      or false

VD.KA_AutoStalk       = VD.KA_AutoStalk       or false
VD.KA_AutoStalkRange  = VD.KA_AutoStalkRange  or 150
VD.KA_AutoKillAll     = VD.KA_AutoKillAll     or false
VD.KA_DropAllPallet   = VD.KA_DropAllPallet   or false
VD.KA_BlockAllVault   = VD.KA_BlockAllVault   or false

W.InstantHealSelf = W.InstantHealSelf or false
W.AutoHealAll     = W.AutoHealAll     or false

_G.GLUTO_ACCENT     = Color3.fromRGB(120, 120, 120)
_G.GLUTO_ACCENT_BG  = Color3.fromRGB(0, 0, 0)
_G.GLUTO_NEUTRAL    = Color3.fromRGB(90, 90, 90)
_G.GLUTO_STROKE_OFF = Color3.fromRGB(25, 25, 25)
_G.GLUTO_BG_OFF     = Color3.fromRGB(0, 0, 0)


local function __Gluto_Init_Main__()

    local Players           = game:GetService("Players")
    local RunService        = game:GetService("RunService")
    local UserInputService  = game:GetService("UserInputService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace         = game:GetService("Workspace")
    local CoreGui           = game:GetService("CoreGui")
    local CollectionService = game:GetService("CollectionService")
    local TweenService      = game:GetService("TweenService")
    local GuiService        = game:GetService("GuiService")
    local HttpService       = game:GetService("HttpService")

    local LocalPlayer = Players.LocalPlayer
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local VirtualInputManager = nil
    pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)

    --========================================================--
    -- MASTER SCHEDULER
    --========================================================--
    local Scheduler = { tasks = {}, conn = nil }
    function Scheduler:Add(name, fn, interval)
        self.tasks[name] = { fn = fn, interval = interval or 0.1, lastRun = 0, enabled = true }
    end
    function Scheduler:Remove(name) self.tasks[name] = nil end
    function Scheduler:Start()
        if self.conn then return end
        self.conn = RunService.Heartbeat:Connect(function()
            local now = os.clock()
            for name, t in pairs(self.tasks) do
                if t.enabled and (now - t.lastRun) >= t.interval then
                    t.lastRun = now
                    pcall(t.fn)
                end
            end
        end)
    end
    Scheduler:Start()
    W._Scheduler = Scheduler

    local UILib
    local ok, err = pcall(function()
        UILib = loadstring(game:HttpGet("https://glutofree.vercel.app/library"))()
    end)
    if not ok or not UILib then warn("[Gluto] UI gagal load:", err); return end

    do
        local function FixText(inst)
            if not inst then return end
            if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
                local txt = inst.Text
                if txt and (string.find(txt, "Gluto Windows", 1, true) or string.find(txt, "Gluto Window", 1, true)) then
                    pcall(function()
                        inst.Text = txt:gsub("Gluto Windows", "Close Windows"):gsub("Gluto Window", "Close Windows")
                    end)
                end
            end
        end
        local function ScanAndHook(container)
            if not container then return end
            for _, d in ipairs(container:GetDescendants()) do FixText(d) end
            container.DescendantAdded:Connect(FixText)
        end
        ScanAndHook(CoreGui)
        if gethui then
            local hok, hui = pcall(gethui)
            if hok and hui then ScanAndHook(hui) end
        end
        ScanAndHook(LocalPlayer:FindFirstChild("PlayerGui"))
    end

    local NotifyColor = Color3.fromRGB(255, 255, 255)
    W.NotifyEnabled = W.NotifyEnabled ~= false

    local function ShowNotify(title, message, duration)
        if not W.NotifyEnabled then return end
        if not UILib or not UILib.MakeNotify then return end
        pcall(function()
            UILib:MakeNotify({
                Title = title or "ALFzxzzz", Description = "Info",
                Content = message or "", Color = NotifyColor,
                Time = 0.4, Delay = duration or 2, Icon = "92826170205694"
            })
        end)
    end
    local function VD_Notify(title, content, duration) ShowNotify(title, content, duration) end
    local function ForceNotify(title, message, duration)
        if not UILib or not UILib.MakeNotify then return end
        pcall(function()
            UILib:MakeNotify({
                Title = title or "ALFzxzzz", Description = "Info",
                Content = message or "", Color = NotifyColor,
                Time = 0.4, Delay = duration or 2, Icon = "92826170205694"
            })
        end)
    end

    local function TeamIs(plr, role)
        if not plr or not plr.Team or not plr.Team.Name then return false end
        local tn = string.lower(plr.Team.Name)
        if role == "Killer" then return string.find(tn, "killer", 1, true) ~= nil end
        if role == "Survivor" then return string.find(tn, "survivor", 1, true) ~= nil end
        return false
    end
    W.TeamIs = TeamIs

    local function GetRole()
        if TeamIs(LocalPlayer, "Killer") then return "Killer" end
        if TeamIs(LocalPlayer, "Survivor") then return "Survivor" end
        return nil
    end
    W.GetRole = GetRole

    W.GB_GetAllGenerators = function()
        local gens = {}
        local mf = Workspace:FindFirstChild("Map")
        if mf then
            for _, obj in ipairs(mf:GetDescendants()) do
                if obj:IsA("Model") and obj.Name == "Generator" then
                    local real = obj:GetAttribute("RepairProgress") ~= nil
                              or obj:GetAttribute("kickcount") ~= nil
                              or obj:GetAttribute("ProgressRepair") ~= nil
                    if real then table.insert(gens, obj) end
                end
            end
        end
        return gens
    end
    W.GB_GetPoints = function(m)
        local pts = {}
        if m then
            for _, o in ipairs(m:GetChildren()) do
                if o:IsA("BasePart") and string.find(o.Name, "GeneratorPoint") then
                    table.insert(pts, o)
                end
            end
        end
        return pts
    end

    --=== [AUTO CROUCH] ===--
    function IsDowned(char) local hrp = char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return true end; local state = char:GetAttribute("State"); return state == "Downed" or state == "Dead" end
    function TriggerCrouch()
        local startT = tick()
        task.spawn(function()
            local char = LocalPlayer.Character
            if not char then return end
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            pcall(function() char:SetAttribute("Crouching", true) end)
            pcall(function() ReplicatedStorage.Remotes.Mechanics.ChangeAttribute:FireServer("Crouchingserver", true) end)
            pcall(function() ReplicatedStorage.Remotes.Chase.Runevent:FireServer(char, false) end)
            if humanoid then pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Landed) end) end
            pcall(function()
                local survMob = LocalPlayer:FindFirstChildOfClass("PlayerGui"):FindFirstChild("Survivor-mob")
                if survMob then
                    local controls = survMob:FindFirstChild("Controls")
                    if controls then
                        local crouchBtn = controls:FindFirstChild("crouch")
                        if crouchBtn then firesignal(crouchBtn.MouseButton1Click) end
                    end
                end
            end)
            while tick() - startT < 1.2 do
                pcall(function() ReplicatedStorage.Remotes.Mechanics.ChangeAttribute:FireServer("Crouchingserver", true) end)
                task.wait(0.1)
            end
            pcall(function() char:SetAttribute("Crouching", false) end)
            pcall(function() ReplicatedStorage.Remotes.Mechanics.ChangeAttribute:FireServer("Crouchingserver", false) end)
            if humanoid then pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Landed) end) end
            pcall(function()
                local survMob = LocalPlayer:FindFirstChildOfClass("PlayerGui"):FindFirstChild("Survivor-mob")
                if survMob then
                    local controls = survMob:FindFirstChild("Controls")
                    if controls then
                        local crouchBtn = controls:FindFirstChild("crouch")
                        if crouchBtn then firesignal(crouchBtn.MouseButton1Click) end
                    end
                end
            end)
        end)
    end
    function IsSafeToParry(char) return not IsDowned(char) end

    local DodgeAttached = {}
    function IsKiller(p) return p.Team and p.Team.Name == "Killer" end

    function AttachParrySensor(kChar)
        if not kChar or DodgeAttached[kChar] then return end
        DodgeAttached[kChar] = true
        local humanoid = kChar:FindFirstChild("Humanoid")
        if not humanoid then humanoid = kChar:WaitForChild("Humanoid", 5); if not humanoid then return end end
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if not animator then animator = humanoid:WaitForChild("Animator", 5); if not animator then return end end
        humanoid.ChildAdded:Connect(function(child)
            if child:IsA("Animator") then DodgeAttached[kChar] = nil; AttachParrySensor(kChar) end
        end)
        kChar.AncestryChanged:Connect(function(_, parent) if not parent then DodgeAttached[kChar] = nil end end)
        animator.AnimationPlayed:Connect(function(track)
            if not VD.AutoCrouch then return end
            local animId = track.Animation and track.Animation.AnimationId or ""
            local id = animId:match("%d+")
            if id == "80411309607666" then
                local myChar = LocalPlayer.Character
                if IsDowned(myChar) then return end
                local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local kHRP = kChar:FindFirstChild("HumanoidRootPart")
                if myHRP and kHRP then
                    local dist = (myHRP.Position - kHRP.Position).Magnitude
                    if dist <= 40 then TriggerCrouch() end
                end
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
    for _, p in pairs(Players:GetPlayers()) do SetupPlayer(p) end
    Players.PlayerAdded:Connect(SetupPlayer)
    Scheduler:Add("CrouchSensorRetry", function()
        for _, p in pairs(Players:GetPlayers()) do TryAttach(p) end
    end, 5)

    --====================================================--
    -- AUTO ATTACK / AUTO FLEE
    --====================================================--
    local lastAutoAttack = 0
    function W.KA_AutoAttack()
        if not VD.KILLER_AutoAttack then return end
        if GetRole() ~= "Killer" then return end
        local now = tick()
        if now - lastAutoAttack < (VD.KILLER_AutoAttackCooldown or 0.15) then return end
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local closest, shortest = nil, VD.KILLER_AutoAttackRange or 12
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and TeamIs(plr, "Survivor") and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 35 then
                    local d = (hrp.Position - root.Position).Magnitude
                    if d <= shortest then shortest = d; closest = plr end
                end
            end
        end
        if closest then
            lastAutoAttack = now
            pcall(function()
                local attacks = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Attacks")
                local basic = attacks and attacks:FindFirstChild("BasicAttack")
                if basic then basic:FireServer(false) end
            end)
        end
    end

    local lastAutoFlee = 0
    function W.SURV_AutoFlee()
        if not VD.SURV_AutoFlee then return end
        if GetRole() ~= "Survivor" then return end
        local now = tick()
        if now - lastAutoFlee < (VD.SURV_AutoFleeCooldown or 1.5) then return end
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
        if not myRoot or not hum or hum.Health <= 0 then return end
        local killerRoot = nil
        local nearest = math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and TeamIs(plr, "Killer") and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local d = (hrp.Position - myRoot.Position).Magnitude
                    if d < nearest then nearest = d; killerRoot = hrp end
                end
            end
        end
        if not killerRoot then return end
        if nearest > (VD.SURV_AutoFleeDist or 40) then return end
        lastAutoFlee = now
        local bestPt, bestDist = nil, 0
        local mf = Workspace:FindFirstChild("Map")
        if mf then
            for _, obj in ipairs(mf:GetDescendants()) do
                if obj:IsA("BasePart") and string.find(obj.Name, "^GeneratorPoint%d+$") then
                    local d = (obj.Position - killerRoot.Position).Magnitude
                    if d > bestDist then bestDist = d; bestPt = obj end
                end
            end
        end
        if bestPt then
            pcall(function() myRoot.CFrame = bestPt.CFrame + Vector3.new(0, 5, 0) end)
            VD_Notify("Auto Flee", "Teleported away from killer!", 2)
        end
    end

    Scheduler:Add("AutoCombat", function()
        if VD.KILLER_AutoAttack then W.KA_AutoAttack() end
        if VD.SURV_AutoFlee then W.SURV_AutoFlee() end
    end, 0.1)

    --====================================================--
    -- AUTO PARRY (FULL)
    --====================================================--
    local ParryState = {
        LastParry = 0, ActiveAttackers = {},
        CircleFolder = nil, CircleDashes = {}, CircleRotCFs = {}, CircleOffsets = {},
        CircleRadius = 0, CircleBuiltForDagger = false,
        CircleLastX = math.huge, CircleLastY = math.huge, CircleLastZ = math.huge,
        CircleSpawnTime = 0, CircleSpawnDuration = 0.55,
    }
    local ParryCooldown = {
        OnCooldown = false, CooldownEnd = 0,
        WaitingForResult = false, WaitingStart = 0, WaitTimeout = 2.0,
        FallbackCooldown = 60, MaxCooldown = 90, LastFiredAt = 0,
        IsSilenced = false, JustFired = false, ManualDetect = false, ManualIgnoreWindow = 0.35
    }
    local parryResultRemote, parryFireRemote
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local items = remotes and remotes:FindFirstChild("Items")
        local dagger = items and items:FindFirstChild("Parrying Dagger")
        if dagger then
            parryResultRemote = dagger:FindFirstChild("parryResult")
            parryFireRemote = dagger:FindFirstChild("parry")
        end
    end)
    local KillerAttackAnims = {
        ["78432063483146"]="attack",["121216847022485"]="attack",["74968262036854"]="attack",
        ["132817836308238"]="attack",["82666958311998"]="attack",["111920872708571"]="attack",
        ["106871536134254"]="attack",["109402730355822"]="attack",["130593238885843"]="attack",
        ["138720291317243"]="attack",["139369275981139"]="attack",["133963973694098"]="attack",
        ["78935059863801"]="attack",
        ["118907603246885"]="lungehold",["135002183282873"]="lungehold",["113255068724446"]="lungehold",
        ["129784271201071"]="lungehold",["105374834496520"]="lungehold",["117070354890871"]="lungehold",
        ["115244153053858"]="lungehold",["110355011987939"]="lungehold",["117042998468241"]="lungehold",
        ["122812055447896"]="lungehold"
    }
    local function ParryStartCooldown(d)
        d = math.clamp(tonumber(d) or 0, 0, ParryCooldown.MaxCooldown)
        if d <= 0 then d = ParryCooldown.FallbackCooldown end
        ParryCooldown.OnCooldown = true
        ParryCooldown.CooldownEnd = os.clock() + d
        ParryCooldown.WaitingForResult = false
        ParryCooldown.JustFired = false
        ParryCooldown.ManualDetect = false
    end
    local function ParryClearCooldown()
        ParryCooldown.OnCooldown = false
        ParryCooldown.CooldownEnd = 0
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
        parryResultRemote.OnClientEvent:Connect(function(success, cd)
            if not ParryCooldown.WaitingForResult and not ParryCooldown.JustFired then return end
            local c = tonumber(cd) or 0
            if success and c > 0 then ParryStartCooldown(math.min(c, ParryCooldown.MaxCooldown))
            else ParryStartCooldown(ParryCooldown.FallbackCooldown) end
        end)
    end
    local function ParryHookSilenced(char)
        if not char then return end
        ParryCooldown.IsSilenced = CollectionService:HasTag(char, "Silenced")
    end
    CollectionService:GetInstanceAddedSignal("Silenced"):Connect(function(i)
        if i == LocalPlayer.Character then ParryCooldown.IsSilenced = true end
    end)
    CollectionService:GetInstanceRemovedSignal("Silenced"):Connect(function(i)
        if i == LocalPlayer.Character then ParryCooldown.IsSilenced = false end
    end)
    LocalPlayer.CharacterAdded:Connect(function(c) task.wait(0.5); ParryHookSilenced(c) end)
    if LocalPlayer.Character then ParryHookSilenced(LocalPlayer.Character) end

    local ParryCharCache = { Char=nil, Root=nil, Hum=nil, UpperTorso=nil, CheckInt=nil }
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
        if not ParryCharCache.UpperTorso then
            ParryCharCache.UpperTorso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        end
        if not ParryCharCache.CheckInt then ParryCharCache.CheckInt = char:FindFirstChild("CheckInterractable") end
        return ParryCharCache
    end
    local DaggerCache = { Value = false, LastCheck = 0, Interval = 0.15 }
    local function ParryIsDaggerModel(inst)
        if not inst then return false end
        return inst:IsA("Model") or inst:IsA("Tool") or inst:IsA("Accessory")
    end
    local function ParryIsEquippedDagger()
        local now = os.clock()
        if now - DaggerCache.LastCheck < DaggerCache.Interval then return DaggerCache.Value end
        DaggerCache.LastCheck = now
        local hasDagger = false
        local char = LocalPlayer.Character
        if char then
            local d = char:FindFirstChild("Parrying Dagger")
            if ParryIsDaggerModel(d) then hasDagger = true end
        end
        if not hasDagger then
            local wsChar = Workspace:FindFirstChild(LocalPlayer.Name)
            if wsChar then
                local d = wsChar:FindFirstChild("Parrying Dagger")
                if ParryIsDaggerModel(d) then hasDagger = true end
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
        if cc.Root and CollectionService:HasTag(cc.Root, "doing action") then return true end
        if cc.CheckInt then
            for i = 1, #ParryCheckAttrs do
                if cc.CheckInt:GetAttribute(ParryCheckAttrs[i]) then return true end
            end
        end
        return false
    end
    local function ParryIsLowHealth()
        local hum = ParryGetCharCache().Hum
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
        local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pGui and type(firesignal) == "function" then
            local mobRoot = pGui:FindFirstChild("Survivor-mob")
            local controls = mobRoot and mobRoot:FindFirstChild("Controls")
            if controls then
                for _, n in ipairs({"Gui-mob","action","Gui-mobile","Gui_mob","Parry","parry"}) do
                    local btn = controls:FindFirstChild(n)
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
                        didFire = true; break
                    end
                end
            end
        end
        if not didFire then
            local remote = ReplicatedStorage:FindFirstChild("Remotes")
            local items = remote and remote:FindFirstChild("Items")
            local dagger = items and items:FindFirstChild("Parrying Dagger")
            local parry = dagger and dagger:FindFirstChild("parry")
            if parry then pcall(function() parry:FireServer() end) end
        end
    end
    local function ParryExecutePC()
        if not VirtualInputManager then return end
        pcall(function()
            VirtualInputManager:SendMouseMoveEvent(0, 0, game)
            task.wait(0.005)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 2, true, game, 0)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 2, false, game, 0)
        end)
    end
    local function ParryExecuteSilent()
        if parryFireRemote then return pcall(function() parryFireRemote:FireServer() end) end
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
    UserInputService.InputBegan:Connect(function(input, gp)
        if input.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
        if gp then return end
        ParryMarkManual()
    end)
    local parryHookedButtons = setmetatable({}, {__mode = "k"})
    local function ParryTryHookMobileButton(inst)
        if not inst or not inst:IsA("GuiButton") then return end
        if parryHookedButtons[inst] then return end
        local nm = inst.Name
        if nm ~= "Gui-mob" and nm ~= "action" and nm ~= "Gui-mobile"
            and nm ~= "Gui_mob" and nm ~= "Parry" and nm ~= "parry" then return end
        parryHookedButtons[inst] = true
        inst.MouseButton1Down:Connect(ParryMarkManual)
    end
    local function ParryScanForMobileButtons(root)
        if not root then return end
        for _, d in ipairs(root:GetDescendants()) do ParryTryHookMobileButton(d) end
    end
    local function ParryAttachPlayerGui(pGui)
        if not pGui then return end
        ParryScanForMobileButtons(pGui)
        pGui.DescendantAdded:Connect(ParryTryHookMobileButton)
    end
    local existingPGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if existingPGui then ParryAttachPlayerGui(existingPGui) end
    LocalPlayer.ChildAdded:Connect(function(c)
        if c:IsA("PlayerGui") then ParryAttachPlayerGui(c) end
    end)

    local function ParryGetHitboxPart(char)
        if not char then return nil end
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
    end
    local function ParryCheckAndParry(killerChar)
        if ParryIsOnCooldown() or ParryCooldown.WaitingForResult
            or ParryCooldown.IsSilenced or not ParryIsEquippedDagger() then return end
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
            local predictedPos = killerPart.Position + flatVel * ping
            local predDist = (myRoot.Position - predictedPos).Magnitude
            if predDist <= ((VD.PARRY_Distance or 10) + 2.5) then
                if flatVel.Magnitude > 6 then
                    local dir = myRoot.Position - killerPart.Position
                    if dir.Magnitude > 0 and flatVel.Unit:Dot(dir.Unit) > 0.4 then ParryExecute(); return end
                end
            end
        end
        if dist <= (VD.PARRY_Distance or 10) then ParryExecute() end
    end
    local function ParryDestroyCircle()
        if ParryState.CircleFolder then
            pcall(function() if ParryState.CircleFolder.Parent then ParryState.CircleFolder:Destroy() end end)
        end
        ParryState.CircleFolder = nil
        ParryState.CircleDashes = {}
        ParryState.CircleRotCFs = {}
        ParryState.CircleOffsets = {}
        ParryState.CircleRadius = 0
        ParryState.CircleBuiltForDagger = false
        ParryState.CircleLastX = math.huge
        ParryState.CircleLastY = math.huge
        ParryState.CircleLastZ = math.huge
        ParryState.CircleSpawnTime = 0
    end
    getgenv()._Gluto_DestroyParryCircle = ParryDestroyCircle
    local function ParryBuildCircle(radius)
        ParryDestroyCircle()
        local folder = Instance.new("Folder")
        folder.Name = "GlutoParryCircleDashes"
        local dashCount = math.clamp(math.floor(radius * 6), 24, 120)
        local slotLength = (2 * math.pi * radius) / dashCount
        local dashLength = slotLength * 0.55
        local dashThickness = 0.03
        local dashes, rotCFs, offsets = table.create(dashCount), table.create(dashCount), table.create(dashCount)
        for i = 1, dashCount do
            local part = Instance.new("Part")
            part.Name = "Dash" .. i
            part.Anchored = true; part.CanCollide = false
            part.CanTouch = false; part.CanQuery = false; part.CastShadow = false
            part.Material = Enum.Material.Neon
            part.Color = Color3.fromRGB(255, 255, 255)
            part.Transparency = 1
            part.Size = Vector3.new(dashThickness, dashThickness, dashLength)
            part.Parent = folder
            local angle = ((i - 1) / dashCount) * math.pi * 2
            local cosA, sinA = math.cos(angle), math.sin(angle)
            rotCFs[i] = CFrame.lookAt(Vector3.zero, Vector3.new(-sinA, 0, cosA))
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
        ParryState.CircleSpawnTime = tick()
    end
    local function ParryUpdateCircle(myRoot)
        if not ParryState.CircleFolder or not ParryState.CircleFolder.Parent then return end
        local dashes = ParryState.CircleDashes
        local dashCount = #dashes
        if dashCount == 0 then return end
        local center = myRoot.Position - Vector3.new(0, (myRoot.Size.Y * 0.5) + 1.0, 0)
        local elapsed = tick() - (ParryState.CircleSpawnTime or 0)
        local spawnT = math.clamp(elapsed / (ParryState.CircleSpawnDuration or 0.55), 0, 1)
        local eased = 1 - (1 - spawnT)^3
        local scaleMult = eased
        if spawnT < 0.7 and spawnT > 0 then
            local bt = spawnT / 0.7
            scaleMult = eased + math.sin(bt * math.pi) * 0.1
        end
        local spinRot = (1 - eased) * math.pi * 2
        local spawnAlpha = 1 - eased
        local busy = ParryIsBusy()
        local onCD = ParryCooldown.OnCooldown
        local tc
        if busy then tc = Color3.fromRGB(255, 20, 20)
        elseif onCD then tc = Color3.fromRGB(255, 140, 0)
        else tc = Color3.fromRGB(255, 255, 255) end
        local targetT = 0
        if onCD then
            local period = 0.55
            local phase = (os.clock() % period) / period
            local pulse = (math.cos(phase * math.pi * 2) + 1) * 0.5
            targetT = (1 - pulse) * 0.85
        end
        local finalT = math.max(targetT, spawnAlpha)
        local dx = math.abs(center.X - ParryState.CircleLastX)
        local dy = math.abs(center.Y - ParryState.CircleLastY)
        local dz = math.abs(center.Z - ParryState.CircleLastZ)
        if dx < 0.01 and dy < 0.01 and dz < 0.01 and spawnT >= 1 then return end
        ParryState.CircleLastX = center.X
        ParryState.CircleLastY = center.Y
        ParryState.CircleLastZ = center.Z
        local rotCFs = ParryState.CircleRotCFs
        local offsets = ParryState.CircleOffsets
        local rotCF = CFrame.Angles(0, spinRot, 0)
        for i = 1, dashCount do
            local dash = dashes[i]
            if dash and dash.Parent then
                local scaledOff = offsets[i] * scaleMult
                local rotatedOff = rotCF:VectorToWorldSpace(scaledOff)
                local worldPos = Vector3.new(center.X + rotatedOff.X, center.Y, center.Z + rotatedOff.Z)
                dash.CFrame = (rotCF * rotCFs[i]) + worldPos
                dash.Color = tc
                dash.Transparency = finalT
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
        if numId ~= "" then v = KillerAttackAnims[numId]; if v then return v end end
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
        local anim = hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator", 3)
        if not anim then return end
        anim.AnimationPlayed:Connect(function(track)
            if not VD.PARRY_Enabled then return end
            if not ParryIsEquippedDagger() then return end
            local at = ParryGetAnimType(track)
            if at then
                ParryState.ActiveAttackers[plr] = { char = char, track = track, type = at, registeredAt = os.clock() }
            end
        end)
    end
    local function ParryHookKillerPlayer(plr)
        if plr == LocalPlayer then return end
        if plr.Character then ParryHookAnimatorOnChar(plr, plr.Character) end
        plr.CharacterAdded:Connect(function(char) task.wait(0.5); ParryHookAnimatorOnChar(plr, char) end)
    end
    for _, p in ipairs(Players:GetPlayers()) do ParryHookKillerPlayer(p) end
    Players.PlayerAdded:Connect(ParryHookKillerPlayer)
    local parryLastPoll = 0
    local function ParryPollAttacks()
        if not VD.PARRY_Enabled or not ParryIsEquippedDagger() then return end
        local now = os.clock()
        if now - parryLastPoll < 0.15 then return end
        parryLastPoll = now
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local char = plr.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
                            local at = ParryGetAnimType(track)
                            if at then
                                local ex = ParryState.ActiveAttackers[plr]
                                if not ex or ex.track ~= track then
                                    ParryState.ActiveAttackers[plr] = { char = char, track = track, type = at, registeredAt = now }
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    local parryLastCleanup = 0
    local function ParryCleanupAttackers()
        local now = os.clock()
        if now - parryLastCleanup < 1.0 then return end
        parryLastCleanup = now
        for plr, data in pairs(ParryState.ActiveAttackers) do
            if not plr or not plr.Parent or not data.track or not data.track.IsPlaying then
                ParryState.ActiveAttackers[plr] = nil
            end
        end
    end
    local function ParryUpdateLogic()
        if not VD.PARRY_Enabled then return end
        if not ParryIsEquippedDagger() then ParryState.ActiveAttackers = {}; return end
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
        local char = LocalPlayer.Character
        local myRoot = char and char:FindFirstChild("HumanoidRootPart")
        if VD.PARRY_ShowCircle and VD.PARRY_Enabled and ParryIsEquippedDagger() and myRoot then
            if not ParryState.CircleFolder or ParryState.CircleRadius ~= (VD.PARRY_Distance or 10) or not ParryState.CircleFolder.Parent then
                ParryBuildCircle(VD.PARRY_Distance or 10)
            end
            ParryUpdateCircle(myRoot)
        else
            if ParryState.CircleFolder then ParryDestroyCircle() end
        end
    end

    Scheduler:Add("ParryCircle", ParryUpdateCircleLogic, 0.05)
    Scheduler:Add("ParryLogic", ParryUpdateLogic, 0.08)

    --====================================================--
    -- SELF HEAL
    --====================================================--
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

    W.SelfHeal_BlockedAnimId = "95836365038528"
    W.SelfHeal_AnimMonitor = W.SelfHeal_AnimMonitor or { Conn = nil, CharHook = nil }
    function W.SelfHeal_StartAnimBlock()
        if W.SelfHeal_AnimMonitor.Conn then return end
        W.SelfHeal_AnimMonitor.Conn = RunService.Heartbeat:Connect(function()
            if not W.InstantHealSelf then return end
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local anim = hum:FindFirstChildOfClass("Animator")
            if not anim then return end
            local ok2, tracks = pcall(function() return anim:GetPlayingAnimationTracks() end)
            if not ok2 then return end
            for _, track in ipairs(tracks) do
                local aid = track.Animation and track.Animation.AnimationId or ""
                local numId = aid:match("%d+")
                if numId == W.SelfHeal_BlockedAnimId then
                    pcall(function() track:Stop(0) end)
                end
            end
        end)
        local function hookChar(char)
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local anim = hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator", 3)
            if not anim then return end
            anim.AnimationPlayed:Connect(function(track)
                if not W.InstantHealSelf then return end
                local aid = track.Animation and track.Animation.AnimationId or ""
                local numId = aid:match("%d+")
                if numId == W.SelfHeal_BlockedAnimId then
                    pcall(function() track:Stop(0) end)
                end
            end)
        end
        hookChar(LocalPlayer.Character)
        W.SelfHeal_AnimMonitor.CharHook = LocalPlayer.CharacterAdded:Connect(function(c)
            task.wait(0.3); hookChar(c)
        end)
    end
    function W.SelfHeal_StopAnimBlock()
        if W.SelfHeal_AnimMonitor.Conn then
            pcall(function() W.SelfHeal_AnimMonitor.Conn:Disconnect() end)
            W.SelfHeal_AnimMonitor.Conn = nil
        end
        if W.SelfHeal_AnimMonitor.CharHook then
            pcall(function() W.SelfHeal_AnimMonitor.CharHook:Disconnect() end)
            W.SelfHeal_AnimMonitor.CharHook = nil
        end
    end
    function W.setInstantHealSelf(v)
        W.InstantHealSelf = v
        if v then
            if W.SelfHeal_StartAnimBlock then W.SelfHeal_StartAnimBlock() end
        else
            if W.SelfHeal_StopAnimBlock then W.SelfHeal_StopAnimBlock() end
        end
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
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        if W.InstantHealSelf then W.setInstantHealSelf(true) end
        if W.AutoHealAll then W.setAutoHealAll(true) end
    end)

    --====================================================--
    -- FAKE PERKS (FULL)
    --====================================================--
    W.FP = W.FP or {
        ActiveBuffs = {}, Conns = {}, LastBuffEnd = 0, CooldownTime = 5, HB = nil,
        FlowstateOn = false, QuickRecOn = false, PerfLandOn = false, AdrenalineOn = false,
    }
    local FP = W.FP

    local function FP_Char() return LocalPlayer.Character end
    local function FP_Hum() local c = FP_Char(); return c and c:FindFirstChildOfClass("Humanoid") end

    local function FP_GetTotal()
        local t = 0
        for _,b in pairs(FP.ActiveBuffs) do if tick() < b.endTime then t = t + b.amt end end
        return t
    end

    local function FP_Apply()
        local c = FP_Char()
        local tb = FP_GetTotal()
        local h = FP_Hum()
        if c then if tb > 0 then c:SetAttribute("speedboost", 1+(tb/14)) else c:SetAttribute("speedboost", 1) end end
        if h and tb > 0 then h.WalkSpeed = 16 + tb end
    end

    local PerkGUI = {
        Gui = nil, Container = nil, Layout = nil, Cards = {},
        PerkInfo = {
            Flowstate        = { Icon = "✦", Label = "FLOWSTATE" },
            QuickRecovery    = { Icon = "✚", Label = "QUICK RECOV" },
            PerfectLanding   = { Icon = "▼", Label = "PERFECT LAND" },
            AdrenalineRush   = { Icon = "♥", Label = "ADRENALINE" },
        }
    }

    local function PerkGUI_Create()
        if PerkGUI.Gui then return end
        local parent = LocalPlayer:FindFirstChild("PlayerGui")
        if gethui then local ok2, hui = pcall(gethui); if ok2 and hui then parent = hui end end
        if not parent then return end
        local gui = Instance.new("ScreenGui")
        gui.Name = "GlutoPerkGUI"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.DisplayOrder = 50
        gui.Parent = parent
        PerkGUI.Gui = gui
        local container = Instance.new("Frame")
        container.Name = "Container"
        container.AnchorPoint = Vector2.new(1, 0)
        container.Position = UDim2.new(1, -12, 0, 100)
        container.Size = UDim2.new(0, 180, 0, 0)
        container.AutomaticSize = Enum.AutomaticSize.Y
        container.BackgroundTransparency = 1
        container.Parent = gui
        PerkGUI.Container = container
        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 6)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        layout.Parent = container
        PerkGUI.Layout = layout
    end

    local function PerkGUI_AddCard(name)
        if PerkGUI.Cards[name] then return end
        if not PerkGUI.Gui then PerkGUI_Create() end
        if not PerkGUI.Gui then return end
        local info = PerkGUI.PerkInfo[name] or { Icon = "★", Label = string.upper(name) }
        local card = Instance.new("Frame")
        card.Name = "Card_" .. name
        card.Size = UDim2.new(0, 180, 0, 38)
        card.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
        card.BackgroundTransparency = 1
        card.BorderSizePixel = 0
        card.ZIndex = 1
        card.LayoutOrder = #PerkGUI.Cards + 1
        card.Parent = PerkGUI.Container
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
        local grad = Instance.new("UIGradient")
        grad.Rotation = 135
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 24, 28)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 10)),
        })
        grad.Parent = card
        local stroke = Instance.new("UIStroke", card)
        stroke.Name = "Stroke"
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Thickness = 1.2
        stroke.Transparency = 0.2
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        local iconHolder = Instance.new("Frame")
        iconHolder.Name = "IconHolder"
        iconHolder.Size = UDim2.fromOffset(26, 26)
        iconHolder.Position = UDim2.new(0, 6, 0.5, -13)
        iconHolder.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
        iconHolder.BorderSizePixel = 0
        iconHolder.ZIndex = 3
        iconHolder.Parent = card
        Instance.new("UICorner", iconHolder).CornerRadius = UDim.new(1, 0)
        local iconGrad = Instance.new("UIGradient", iconHolder)
        iconGrad.Rotation = 135
        iconGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 38, 44)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 14, 18)),
        })
        local iconStroke = Instance.new("UIStroke", iconHolder)
        iconStroke.Color = Color3.fromRGB(255, 255, 255)
        iconStroke.Thickness = 1
        iconStroke.Transparency = 0.25
        local iconTxt = Instance.new("TextLabel")
        iconTxt.Name = "Icon"
        iconTxt.Size = UDim2.fromScale(1, 1)
        iconTxt.BackgroundTransparency = 1
        iconTxt.Font = Enum.Font.GothamBlack
        iconTxt.Text = info.Icon
        iconTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
        iconTxt.TextScaled = true
        iconTxt.ZIndex = 4
        iconTxt.Parent = iconHolder
        local nameLbl = Instance.new("TextLabel")
        nameLbl.Name = "Name"
        nameLbl.Size = UDim2.new(1, -46, 0, 12)
        nameLbl.Position = UDim2.new(0, 38, 0, 5)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.Text = info.Label
        nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLbl.TextSize = 10
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLbl.TextStrokeTransparency = 0.5
        nameLbl.ZIndex = 3
        nameLbl.Parent = card
        local timeLbl = Instance.new("TextLabel")
        timeLbl.Name = "Time"
        timeLbl.AnchorPoint = Vector2.new(1, 0)
        timeLbl.Size = UDim2.fromOffset(34, 12)
        timeLbl.Position = UDim2.new(1, -6, 0, 5)
        timeLbl.BackgroundTransparency = 1
        timeLbl.Font = Enum.Font.GothamBold
        timeLbl.Text = "3.0s"
        timeLbl.TextColor3 = Color3.fromRGB(200, 200, 210)
        timeLbl.TextSize = 9
        timeLbl.TextXAlignment = Enum.TextXAlignment.Right
        timeLbl.ZIndex = 3
        timeLbl.Parent = card
        local barBg = Instance.new("Frame")
        barBg.Name = "BarBg"
        barBg.AnchorPoint = Vector2.new(0.5, 1)
        barBg.Size = UDim2.new(1, -12, 0, 3)
        barBg.Position = UDim2.new(0.5, 0, 1, -5)
        barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
        barBg.BorderSizePixel = 0
        barBg.ZIndex = 4
        barBg.Parent = card
        Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
        local barFill = Instance.new("Frame")
        barFill.Name = "BarFill"
        barFill.Size = UDim2.new(1, 0, 1, 0)
        barFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        barFill.BorderSizePixel = 0
        barFill.ZIndex = 5
        barFill.Parent = barBg
        Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)
        PerkGUI.Cards[name] = {
            Card = card, BarFill = barFill, Stroke = stroke,
            TimeLbl = timeLbl, IconTxt = iconTxt,
        }
        card.Position = UDim2.new(0.4, 0, 0, 0)
        TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 0.05,
        }):Play()
    end

    local function PerkGUI_RemoveCard(name)
        local data = PerkGUI.Cards[name]
        if not data then return end
        PerkGUI.Cards[name] = nil
        local card = data.Card
        if not card or not card.Parent then return end
        TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0.4, 0, 0, 0),
            BackgroundTransparency = 1,
        }):Play()
        task.delay(0.28, function()
            if card and card.Parent then card:Destroy() end
        end)
    end

    Scheduler:Add("PerkGUI", function()
        local any = false
        for name in pairs(FP.ActiveBuffs) do
            any = true
            if not PerkGUI.Cards[name] then PerkGUI_AddCard(name) end
        end
        if not any and next(PerkGUI.Cards) == nil then return end
        for name, data in pairs(PerkGUI.Cards) do
            if not FP.ActiveBuffs[name] then
                PerkGUI_RemoveCard(name)
            else
                local b = FP.ActiveBuffs[name]
                if b and data.BarFill then
                    local remain = math.max(0, b.endTime - tick())
                    local dur = b.duration or 3
                    local ratio = math.clamp(remain / dur, 0, 1)
                    data.BarFill.Size = UDim2.new(ratio, 0, 1, 0)
                    data.BarFill.BackgroundColor3 = Color3.fromRGB(160, 160, 170):Lerp(Color3.fromRGB(255, 255, 255), ratio)
                    if data.TimeLbl then
                        data.TimeLbl.Text = string.format("%.1fs", remain)
                    end
                end
            end
        end
    end, 0.08)

    local function FP_EnsureHB()
        if FP.HB then return end
        FP.HB = RunService.Heartbeat:Connect(function()
            local exp = {}
            for n,b in pairs(FP.ActiveBuffs) do if tick() >= b.endTime then table.insert(exp,n) end end
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
        FP.ActiveBuffs[name] = {amt=amt, endTime=tick()+dur, duration=dur, startTime=tick()}
        FP_Apply(); FP_EnsureHB()
        VD_Notify("Fake Perks", "["..name.."] Aktif! +"..amt.." Speed ("..dur.."s)", 3)
    end

    local function FP_Clean(name)
        if FP.Conns[name] then for _,c in ipairs(FP.Conns[name]) do pcall(function() c:Disconnect() end) end FP.Conns[name] = nil end
    end
    local function FP_Reg(name, conn) if not FP.Conns[name] then FP.Conns[name] = {} end table.insert(FP.Conns[name], conn) end

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
            if w then local vb = w:FindFirstChild("Vaultbindable"); if vb and vb:IsA("BindableEvent") then FP_Reg("Flowstate", vb.Event:Connect(onV)) end end
            if p then local sb = p:FindFirstChild("Slidebindable"); if sb and sb:IsA("BindableEvent") then FP_Reg("Flowstate", sb.Event:Connect(onV)) end end
            local function hookChar(cc)
                if not cc then return end
                local cn = cc:GetAttributeChangedSignal("__VaultFireCount"):Connect(function() if FP.FlowstateOn then onV() end end)
                FP_Reg("Flowstate", cn)
            end
            hookChar(LocalPlayer.Character)
            FP_Reg("Flowstate", LocalPlayer.CharacterAdded:Connect(function(cc) if FP.FlowstateOn then cc:SetAttribute("Flowstate",true); hookChar(cc) end end))
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
            local function onH() if not FP.QuickRecOn then return end FP_TryBuff("QuickRecovery", 6, 3) end
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            local hf = r and r:FindFirstChild("Healing")
            if hf then local hd = hf:FindFirstChild("Healdone"); if hd and hd:IsA("BindableEvent") then FP_Reg("QuickRecovery", hd.Event:Connect(onH)) end end
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

    --====================================================--
    -- STUN INDICATOR (FULL)
    --====================================================--
    W.StunSounds = W.StunSounds or {
        ["Default"]="18843924331",["Clash Royale"]="114072050006157",["Blash"]="89068385567682",
        ["Coin"]="75510526696824",["Kururin Kuru"]="119896940405402",["Spongebob"]="6835794541",
        ["Fahhhh"]="123562480982353",["Cave"]="3173566193",["Aughhh"]="9095205664",
        ["Samsung"]="6879335951",["iPhone"]="4203251375",["Siren"]="130677853589923",
    }
    W.StunIndicator = W.StunIndicator or {
        Enabled = false, Cache = {}, HeartbeatConn = nil, Range = 500,
        Icon = "rbxassetid://81633822407558",
        SoundEnabled = true, SoundId = "18843924331",
        SoundVolume = 1.5, SoundRange = 500,
        SelectedSound = "Default",
    }
    local SInd = W.StunIndicator
    SInd.SelectedSound = SInd.SelectedSound or "Default"

    local function SInd_GetActiveSoundId()
        local id = W.StunSounds[SInd.SelectedSound]
        if id then return id end
        return SInd.SoundId
    end
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
            local sv = hum:FindFirstChild("StunValue")
            if sv and sv.Value > 0 then return true end
        end
        return false
    end
    local function SInd_Remove(char)
        local data = SInd.Cache[char]
        if data then
            pcall(function()
                if data.StopAnim then data.StopAnim() end
                if data.Gui then data.Gui:Destroy() end
            end)
            SInd.Cache[char] = nil
        end
    end
    local function SInd_PlaySound(char)
        if not SInd.SoundEnabled then return end
        pcall(function()
            local head = char and char:FindFirstChild("Head")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local attachTo = head or hrp
            if not attachTo then return end
            local snd = Instance.new("Sound")
            snd.Name = "GlutoStunSound"
            snd.SoundId = "rbxassetid://" .. tostring(SInd_GetActiveSoundId())
            snd.Volume = SInd.SoundVolume or 1.5
            snd.PlaybackSpeed = 1
            snd.RollOffMaxDistance = SInd.SoundRange or 500
            snd.RollOffMinDistance = 10
            snd.RollOffMode = Enum.RollOffMode.InverseTapered
            snd.Parent = attachTo
            snd:Play()
            snd.Ended:Connect(function() pcall(function() snd:Destroy() end) end)
            task.delay(5, function() pcall(function() if snd and snd.Parent then snd:Destroy() end end) end)
        end)
    end
    local function SInd_Create(char)
        if SInd.Cache[char] then return SInd.Cache[char] end
        local head = char:FindFirstChild("Head")
        if not head then return nil end

        local bbg = Instance.new("BillboardGui")
        bbg.Name = "GlutoStunIndicator"
        bbg.Size = UDim2.fromOffset(140, 42)
        bbg.StudsOffset = Vector3.new(0, 3.0, 0)
        bbg.AlwaysOnTop = true
        bbg.LightInfluence = 0
        bbg.MaxDistance = 500
        bbg.Adornee = head
        bbg.Parent = char

        local pulse1 = Instance.new("Frame")
        pulse1.Name = "Pulse1"
        pulse1.AnchorPoint = Vector2.new(0.5, 0.5)
        pulse1.Position = UDim2.new(0.5, 0, 0.5, 0)
        pulse1.Size = UDim2.fromOffset(34, 34)
        pulse1.BackgroundTransparency = 1
        pulse1.BorderSizePixel = 0
        pulse1.ZIndex = 0
        pulse1.Parent = bbg
        Instance.new("UICorner", pulse1).CornerRadius = UDim.new(1, 0)
        local p1s = Instance.new("UIStroke", pulse1)
        p1s.Color = Color3.fromRGB(255, 255, 255)
        p1s.Thickness = 1.8
        p1s.Transparency = 0.3
        p1s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local pulse2 = Instance.new("Frame")
        pulse2.Name = "Pulse2"
        pulse2.AnchorPoint = Vector2.new(0.5, 0.5)
        pulse2.Position = UDim2.new(0.5, 0, 0.5, 0)
        pulse2.Size = UDim2.fromOffset(34, 34)
        pulse2.BackgroundTransparency = 1
        pulse2.BorderSizePixel = 0
        pulse2.ZIndex = 0
        pulse2.Parent = bbg
        Instance.new("UICorner", pulse2).CornerRadius = UDim.new(1, 0)
        local p2s = Instance.new("UIStroke", pulse2)
        p2s.Color = Color3.fromRGB(200, 200, 210)
        p2s.Thickness = 1.8
        p2s.Transparency = 0.4
        p2s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local main = Instance.new("Frame")
        main.Name = "Main"
        main.Size = UDim2.new(0, 140, 0, 34)
        main.Position = UDim2.new(0, 0, 0, 4)
        main.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
        main.BackgroundTransparency = 0.05
        main.BorderSizePixel = 0
        main.ZIndex = 1
        main.Parent = bbg
        Instance.new("UICorner", main).CornerRadius = UDim.new(0, 9)

        local bodyGrad = Instance.new("UIGradient")
        bodyGrad.Rotation = 135
        bodyGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 24, 28)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 10)),
        })
        bodyGrad.Parent = main

        local mainStroke = Instance.new("UIStroke", main)
        mainStroke.Name = "MainStroke"
        mainStroke.Color = Color3.fromRGB(255, 255, 255)
        mainStroke.Thickness = 1.3
        mainStroke.Transparency = 0.15
        mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local iconHolder = Instance.new("Frame")
        iconHolder.Name = "IconHolder"
        iconHolder.Size = UDim2.fromOffset(24, 24)
        iconHolder.Position = UDim2.new(0, 5, 0.5, -12)
        iconHolder.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
        iconHolder.BorderSizePixel = 0
        iconHolder.ZIndex = 3
        iconHolder.Parent = main
        Instance.new("UICorner", iconHolder).CornerRadius = UDim.new(1, 0)

        local iconGrad = Instance.new("UIGradient", iconHolder)
        iconGrad.Rotation = 135
        iconGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 38, 44)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 14, 18)),
        })

        local iconStroke = Instance.new("UIStroke", iconHolder)
        iconStroke.Color = Color3.fromRGB(255, 255, 255)
        iconStroke.Thickness = 1
        iconStroke.Transparency = 0.25

        local starIcon = Instance.new("TextLabel")
        starIcon.Name = "StarIcon"
        starIcon.Size = UDim2.fromScale(1, 1)
        starIcon.BackgroundTransparency = 1
        starIcon.Font = Enum.Font.GothamBlack
        starIcon.Text = "★"
        starIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
        starIcon.TextScaled = true
        starIcon.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        starIcon.TextStrokeTransparency = 0.5
        starIcon.ZIndex = 4
        starIcon.Parent = iconHolder

        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, -42, 0, 12)
        title.Position = UDim2.new(0, 34, 0, 4)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamBlack
        title.Text = "STUNNED"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 11
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        title.TextStrokeTransparency = 0.5
        title.ZIndex = 3
        title.Parent = main

        local sub = Instance.new("TextLabel")
        sub.Name = "Sub"
        sub.Size = UDim2.new(1, -42, 0, 8)
        sub.Position = UDim2.new(0, 34, 0, 18)
        sub.BackgroundTransparency = 1
        sub.Font = Enum.Font.GothamBold
        sub.Text = "SILENT"
        sub.TextColor3 = Color3.fromRGB(170, 170, 180)
        sub.TextSize = 7
        sub.TextXAlignment = Enum.TextXAlignment.Left
        sub.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        sub.TextStrokeTransparency = 0.6
        sub.ZIndex = 3
        sub.Parent = main

        local accent = Instance.new("Frame")
        accent.Name = "Accent"
        accent.AnchorPoint = Vector2.new(1, 0.5)
        accent.Size = UDim2.fromOffset(2.5, 14)
        accent.Position = UDim2.new(1, -5, 0.5, 0)
        accent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        accent.BorderSizePixel = 0
        accent.ZIndex = 3
        accent.Parent = main
        Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)

        main.Size = UDim2.new(0, 0, 0, 0)
        main.BackgroundTransparency = 1

        task.spawn(function()
            task.wait(0.02)
            TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 140, 0, 34),
                BackgroundTransparency = 0.05,
            }):Play()
        end)

        local animActive = true
        local function StopAnim() animActive = false end

        task.spawn(function()
            local t = 0
            while animActive and bbg.Parent and main.Parent do
                t = t + 0.05
                local pulse = (math.sin(t * 3) + 1) * 0.5
                mainStroke.Transparency = 0.35 - pulse * 0.2
                mainStroke.Thickness = 1.2 + pulse * 0.3
                starIcon.Rotation = math.sin(t * 2) * 10
                local p1 = (t * 0.55) % 1
                pulse1.Size = UDim2.fromOffset(34 + p1 * 40, 34 + p1 * 40)
                p1s.Transparency = 0.15 + p1 * 0.75
                local p2 = ((t * 0.55) + 0.5) % 1
                pulse2.Size = UDim2.fromOffset(34 + p2 * 40, 34 + p2 * 40)
                p2s.Transparency = 0.15 + p2 * 0.75
                task.wait(0.03)
            end
        end)

        local function ExitAndDestroy()
            animActive = false
            TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
            }):Play()
            task.delay(0.28, function() pcall(function() bbg:Destroy() end) end)
        end

        SInd.Cache[char] = { Gui = bbg, Main = main, StopAnim = StopAnim, Exit = ExitAndDestroy }
        return SInd.Cache[char]
    end

    function W.SInd_SetEnabled(v)
        SInd.Enabled = v and true or false
        if SInd.Enabled then
            if SInd.HeartbeatConn then return end
            SInd.HeartbeatConn = RunService.Heartbeat:Connect(function()
                if not SInd.Enabled then return end
                local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not myRoot then return end
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and TeamIs(p, "Killer") and p.Character then
                        local char = p.Character
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local dist = (hrp.Position - myRoot.Position).Magnitude
                            local stunned = SInd_IsStunned(char)
                            local data = SInd.Cache[char]
                            local wasStunned = data ~= nil
                            if stunned and dist <= SInd.Range then
                                if not wasStunned then SInd_PlaySound(char); SInd_Create(char) end
                            else
                                if wasStunned then
                                    if data.Exit then data.Exit() else SInd_Remove(char) end
                                    SInd.Cache[char] = nil
                                end
                            end
                        end
                    end
                end
            end)
        else
            if SInd.HeartbeatConn then SInd.HeartbeatConn:Disconnect(); SInd.HeartbeatConn = nil end
            for _, data in pairs(SInd.Cache) do
                pcall(function()
                    if data.StopAnim then data.StopAnim() end
                    if data.Gui then data.Gui:Destroy() end
                end)
            end
            SInd.Cache = {}
        end
    end

    --====================================================--
    -- TROLL TELEPORT
    --====================================================--
    W.TrollTeleport = W.TrollTeleport or {
        Enabled = false, IsProcessing = false, TriggerCount = 0,
        AnimatorHook = nil, CharHook = nil,
        BlockedAnimList = { ["123812278891591"] = 1, ["74099023522626"] = 2 },
    }
    local TT = W.TrollTeleport
    local function TT_HookCharacter(char)
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local anim = hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator", 3)
        if not anim then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        anim.AnimationPlayed:Connect(function(track)
            if not TT.Enabled then return end
            if TT.IsProcessing then return end
            local aid = track.Animation and track.Animation.AnimationId or ""
            local numId = aid:match("%d+")
            local delay = numId and TT.BlockedAnimList[numId]
            if not delay then return end
            TT.IsProcessing = true
            TT.TriggerCount = TT.TriggerCount + 1
            local startCF = root.CFrame
            VD_Notify("Troll Teleport", "Trigger #" .. TT.TriggerCount .. " | Delay " .. delay .. "s", 2)
            task.spawn(function()
                if track.IsPlaying then pcall(function() track.Stopped:Wait() end) end
                task.wait(delay)
                local c = LocalPlayer.Character
                local rp = c and c:FindFirstChild("HumanoidRootPart")
                if rp and rp.Parent then pcall(function() rp.CFrame = startCF end) end
                TT.IsProcessing = false
            end)
        end)
    end
    function W.TrollTeleport_Start()
        if TT.AnimatorHook then return end
        TT.IsProcessing = false
        TT_HookCharacter(LocalPlayer.Character)
        TT.CharHook = LocalPlayer.CharacterAdded:Connect(function(c) task.wait(0.4); TT_HookCharacter(c) end)
    end
    function W.TrollTeleport_Stop()
        if TT.CharHook then pcall(function() TT.CharHook:Disconnect() end); TT.CharHook = nil end
        TT.AnimatorHook = nil
        TT.IsProcessing = false
    end
    function W.TrollTeleport_SetEnabled(v)
        TT.Enabled = v and true or false
        if TT.Enabled then W.TrollTeleport_Start() else W.TrollTeleport_Stop() end
    end

    --====================================================--
    -- INSTANT ESCAPE
    --====================================================--
    W.Escape = W.Escape or { Enabled = false, FinishLineName = "fininshline", TeleportCount = 0 }
    local Esc = W.Escape
    function W.Escape_Teleport()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then ForceNotify("Escape", "Character not found", 2); return false end
        local found = nil
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if string.lower(obj.Name) == string.lower(Esc.FinishLineName) and obj:IsA("BasePart") then
                found = obj; break
            end
        end
        if not found then ForceNotify("Escape", "Finish line not found", 2); return false end
        pcall(function() root.CFrame = found.CFrame + Vector3.new(0, 5, 0) end)
        Esc.TeleportCount = Esc.TeleportCount + 1
        VD_Notify("Instant Escape", "Teleported! (#" .. Esc.TeleportCount .. ")", 2)
        return true
    end

    --====================================================--
    -- SELECT MASKED
    --====================================================--
    W.Masked = W.Masked or { CurrentPower = "Cobra", Powers = {"Cobra", "Richter", "Brandon", "Rabbit", "Alex", "Tony"} }
    local Masked = W.Masked
    function W.Masked_Activate()
        local ev = ReplicatedStorage:FindFirstChild("Remotes", true)
            and ReplicatedStorage.Remotes:FindFirstChild("Killers", true)
            and ReplicatedStorage.Remotes.Killers:FindFirstChild("Masked", true)
            and ReplicatedStorage.Remotes.Killers.Masked:FindFirstChild("Activatepower")
        if ev then
            pcall(function() ev:FireServer(Masked.CurrentPower) end)
            VD_Notify("Select Masked", "Activated: " .. Masked.CurrentPower, 2)
        else ForceNotify("Select Masked", "Activatepower remote not found", 2) end
    end
    function W.Masked_Deactivate()
        local ev = ReplicatedStorage:FindFirstChild("Remotes", true)
            and ReplicatedStorage.Remotes:FindFirstChild("Killers", true)
            and ReplicatedStorage.Remotes.Killers:FindFirstChild("Masked", true)
            and ReplicatedStorage.Remotes.Killers.Masked:FindFirstChild("Deactivatepower")
        if ev then
            pcall(function() ev:FireServer() end)
            VD_Notify("Select Masked", "Deactivated", 2)
        else ForceNotify("Select Masked", "Deactivatepower remote not found", 2) end
    end

    --====================================================--
    -- FULL ESP SYSTEM (SINGLE LOOP with HEALTH BAR)
    --====================================================--
    W.FullESP = W.FullESP or {
        Survivor = false, Killer = false,
        Generator = false, Pallet = false, Window = false, SCP = false,
        Distance = 500,
    }
    W.FullESPStatus = W.FullESPStatus or {
        Enabled = false,
        ShowName = true, ShowDistance = true, ShowHealth = false,
        ShowAvatar = true, ShowAction = true,
        Radius = 500,
    }
    W.FullESPColors = W.FullESPColors or {
        Survivor  = Color3.fromRGB(0, 190, 255),
        Killer    = Color3.fromRGB(255, 0, 0),
        Generator = Color3.fromRGB(255, 255, 0),
        Window    = Color3.fromRGB(255, 255, 255),
        Pallet    = Color3.fromRGB(255, 165, 0),
        SCP       = Color3.fromRGB(0, 255, 0),
    }
    local FESP  = W.FullESP
    local FESPS = W.FullESPStatus
    local FESPC = W.FullESPColors

    local ESPObjects = {}
    local StatusESP  = {}
    local CachedSCP     = {}
    local CachedGen     = {}
    local CachedPallet  = {}
    local CachedWindow  = {}
    local CachedVaultTrigger = {}

    local function CacheObject(obj)
        if not obj then return end
        local ln = string.lower(obj.Name)
        if string.find(ln, "scp", 1, true) then CachedSCP[obj] = true end
        if obj.Name == "Generator" then
            CachedGen[obj] = true
        elseif obj.Name == "Pallet" or obj.Name == "Palletwrong" then
            CachedPallet[obj] = true
        end
        if obj.Name == "Window" or obj.Name == "VaultWindow" or obj.Name == "WindowVault"
           or obj.Name == "Vault" or ln == "window" then
            CachedWindow[obj] = true
        end
        if obj.Name == "VaultTrigger" or obj.Name == "VaultPoint" then
            table.insert(CachedVaultTrigger, obj)
            local parent = obj.Parent
            if obj.Name == "VaultPoint" and parent and parent.Name == "VaultTrigger" then
                parent = parent.Parent
            end
            if parent and parent ~= Workspace then
                CachedWindow[parent] = true
            end
        end
    end

    task.spawn(function()
        local objs = Workspace:GetDescendants()
        for i = 1, #objs, 300 do
            for j = i, math.min(i + 299, #objs) do CacheObject(objs[j]) end
            task.wait()
        end
    end)
    Workspace.DescendantAdded:Connect(CacheObject)
    Workspace.DescendantRemoving:Connect(function(obj)
        CachedSCP[obj] = nil; CachedGen[obj] = nil
        CachedPallet[obj] = nil; CachedWindow[obj] = nil
        local idx = table.find(CachedVaultTrigger, obj)
        if idx then table.remove(CachedVaultTrigger, idx) end
        if ESPObjects[obj] then pcall(function() ESPObjects[obj]:Destroy() end); ESPObjects[obj] = nil end
        if StatusESP[obj] then pcall(function() StatusESP[obj]:Destroy() end); StatusESP[obj] = nil end
    end)

    local function RemoveESP(obj)
        if not obj then return end
        if ESPObjects[obj] then
            pcall(function() ESPObjects[obj]:Destroy() end)
            ESPObjects[obj] = nil
        end
    end
    local function CreateESP(obj, color)
        if not obj or not obj.Parent then return end
        if ESPObjects[obj] then
            ESPObjects[obj].FillColor = color
            ESPObjects[obj].OutlineColor = color
            return
        end
        local h = Instance.new("Highlight")
        h.FillColor = color
        h.OutlineColor = color
        h.FillTransparency = 0.9
        h.OutlineTransparency = 0.3
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = obj
        ESPObjects[obj] = h
        obj.AncestryChanged:Connect(function(_, parent)
            if not parent then RemoveESP(obj) end
        end)
    end
    local function RemoveStatusESP(char)
        if StatusESP[char] then
            pcall(function() StatusESP[char]:Destroy() end)
            StatusESP[char] = nil
        end
    end
    local function StatusESP_GetAction(char, hum)
        if not char or not hum then return "IDLE", Color3.fromRGB(150, 150, 150) end
        if hum.Health <= 0 then return "DEAD", Color3.fromRGB(200, 60, 60) end
        if char:GetAttribute("IsHooked") or char:GetAttribute("isHooked") or char:GetAttribute("Hooked") then
            return "HOOKED", Color3.fromRGB(255, 60, 60)
        end
        if char:GetAttribute("IsCarried") or char:GetAttribute("isCarried") or char:GetAttribute("Carried") then
            return "CARRIED", Color3.fromRGB(255, 100, 100)
        end
        local state = char:GetAttribute("State")
        if state == "Downed" or char:GetAttribute("Knocked") == true
           or char:GetAttribute("IsDown") == true or char:GetAttribute("Downed") == true then
            return "DOWNED", Color3.fromRGB(255, 130, 60)
        end
        local ci = char:FindFirstChild("CheckInterractable")
        if ci then
            if ci:GetAttribute("isRepairing") then return "REPAIR", Color3.fromRGB(255, 220, 60) end
            if ci:GetAttribute("isHealing") then return "HEAL", Color3.fromRGB(80, 220, 120) end
            if ci:GetAttribute("isVaulting") then return "VAULT", Color3.fromRGB(120, 200, 255) end
            if ci:GetAttribute("isSliding") then return "SLIDE", Color3.fromRGB(150, 180, 255) end
            if ci:GetAttribute("isDroppingPallet") then return "PALLET", Color3.fromRGB(255, 165, 60) end
            if ci:GetAttribute("isUnhooking") then return "UNHOOK", Color3.fromRGB(180, 120, 255) end
            if ci:GetAttribute("isExiting") then return "EXIT", Color3.fromRGB(80, 255, 180) end
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local vel = root.AssemblyLinearVelocity
            local speed = Vector3.new(vel.X, 0, vel.Z).Magnitude
            if speed > 20 then return "SPRINT", Color3.fromRGB(120, 255, 200) end
            if speed > 2 then return "MOVE", Color3.fromRGB(200, 200, 220) end
        end
        return "IDLE", Color3.fromRGB(150, 150, 150)
    end

    local function CreateStatusESP(plr, char, root)
        if not FESPS.Enabled then RemoveStatusESP(char); return end
        if not root then return end
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not head or not hum then return end

        local isDown = hum.Health <= 0 or hum.Health < 2
            or char:GetAttribute("Downed") == true
            or char:GetAttribute("IsDown") == true
            or char:GetAttribute("Knocked") == true

        local dist = (head.Position - root.Position).Magnitude
        if dist > FESPS.Radius then RemoveStatusESP(char); return end

        local accentColor = Color3.fromRGB(255, 255, 255)
        if TeamIs(plr, "Killer") then accentColor = FESPC.Killer
        elseif TeamIs(plr, "Survivor") then accentColor = FESPC.Survivor end
        if isDown then accentColor = Color3.fromRGB(255, 60, 60) end

        local hpPct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
        local hpColor
        if hpPct > 0.6 then hpColor = Color3.fromRGB(80, 220, 120)
        elseif hpPct > 0.3 then hpColor = Color3.fromRGB(255, 200, 60)
        else hpColor = Color3.fromRGB(255, 80, 80) end

        local actionText, actionColor = StatusESP_GetAction(char, hum)

        local bb = StatusESP[char]
        if not bb or not bb.Parent then
            bb = Instance.new("BillboardGui")
            bb.Name = "GlutoStatusESP"
            bb.AlwaysOnTop = true
            bb.LightInfluence = 0
            bb.Adornee = head
            bb.StudsOffset = Vector3.new(0, 2.5, 0)
            bb.Size = UDim2.fromOffset(260, 40)
            bb.Parent = char

            local scaleObj = Instance.new("UIScale")
            scaleObj.Name = "DistScale"
            scaleObj.Scale = 1
            scaleObj.Parent = bb

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Name = "NameLbl"
            nameLbl.BackgroundTransparency = 1
            nameLbl.Size = UDim2.new(1, 0, 0, 16)
            nameLbl.Position = UDim2.new(0, 0, 0, 0)
            nameLbl.Font = Enum.Font.GothamBold
            nameLbl.TextSize = 13
            nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            nameLbl.TextStrokeTransparency = 0.2
            nameLbl.TextXAlignment = Enum.TextXAlignment.Center
            nameLbl.TextYAlignment = Enum.TextYAlignment.Center
            nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
            nameLbl.Parent = bb

            local pill = Instance.new("Frame")
            pill.Name = "Pill"
            pill.AnchorPoint = Vector2.new(0.5, 0)
            pill.Position = UDim2.new(0.5, 0, 0, 18)
            pill.Size = UDim2.fromOffset(120, 22)
            pill.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
            pill.BackgroundTransparency = 0.15
            pill.BorderSizePixel = 0
            pill.Parent = bb
            Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

            local pillStroke = Instance.new("UIStroke", pill)
            pillStroke.Name = "PillStroke"
            pillStroke.Color = accentColor
            pillStroke.Thickness = 1
            pillStroke.Transparency = 0.5
            pillStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            local layout = Instance.new("UIListLayout", pill)
            layout.FillDirection = Enum.FillDirection.Horizontal
            layout.Padding = UDim.new(0, 5)
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.VerticalAlignment = Enum.VerticalAlignment.Center
            layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

            local pad = Instance.new("UIPadding", pill)
            pad.PaddingLeft = UDim.new(0, 6)
            pad.PaddingRight = UDim.new(0, 8)

            local avatarHolder = Instance.new("Frame")
            avatarHolder.Name = "AvatarHolder"
            avatarHolder.Size = UDim2.fromOffset(18, 18)
            avatarHolder.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
            avatarHolder.BorderSizePixel = 0
            avatarHolder.LayoutOrder = 1
            avatarHolder.ClipsDescendants = true
            avatarHolder.Parent = pill
            Instance.new("UICorner", avatarHolder).CornerRadius = UDim.new(1, 0)

            local avatarStroke = Instance.new("UIStroke", avatarHolder)
            avatarStroke.Name = "AvatarStroke"
            avatarStroke.Color = accentColor
            avatarStroke.Thickness = 1.2
            avatarStroke.Transparency = 0.3
            avatarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            local avatarImg = Instance.new("ImageLabel")
            avatarImg.Name = "AvatarImg"
            avatarImg.Size = UDim2.fromScale(1, 1)
            avatarImg.BackgroundTransparency = 1
            avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. plr.UserId .. "&w=150&h=150"
            avatarImg.Parent = avatarHolder

            local dot = Instance.new("Frame")
            dot.Name = "Dot"
            dot.Size = UDim2.fromOffset(7, 7)
            dot.BackgroundColor3 = accentColor
            dot.BorderSizePixel = 0
            dot.LayoutOrder = 1
            dot.Visible = false
            dot.Parent = pill
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

            local distLbl = Instance.new("TextLabel")
            distLbl.Name = "DistLbl"
            distLbl.BackgroundTransparency = 1
            distLbl.Size = UDim2.fromOffset(32, 14)
            distLbl.Font = Enum.Font.GothamBold
            distLbl.TextSize = 11
            distLbl.TextColor3 = Color3.fromRGB(220, 220, 230)
            distLbl.Text = "0m"
            distLbl.LayoutOrder = 2
            distLbl.Parent = pill

            local actionLbl = Instance.new("TextLabel")
            actionLbl.Name = "ActionLbl"
            actionLbl.BackgroundTransparency = 1
            actionLbl.Size = UDim2.fromOffset(50, 14)
            actionLbl.Font = Enum.Font.GothamBold
            actionLbl.TextSize = 10
            actionLbl.TextColor3 = actionColor
            actionLbl.Text = "IDLE"
            actionLbl.LayoutOrder = 3
            actionLbl.Parent = pill

            local hpBarBg = Instance.new("Frame")
            hpBarBg.Name = "HPBarBg"
            hpBarBg.Size = UDim2.fromOffset(38, 4)
            hpBarBg.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            hpBarBg.BorderSizePixel = 0
            hpBarBg.LayoutOrder = 4
            hpBarBg.Parent = pill
            Instance.new("UICorner", hpBarBg).CornerRadius = UDim.new(1, 0)

            local hpBarFill = Instance.new("Frame")
            hpBarFill.Name = "HPBarFill"
            hpBarFill.Size = UDim2.new(1, 0, 1, 0)
            hpBarFill.BackgroundColor3 = hpColor
            hpBarFill.BorderSizePixel = 0
            hpBarFill.Parent = hpBarBg
            Instance.new("UICorner", hpBarFill).CornerRadius = UDim.new(1, 0)

            local downPill = Instance.new("Frame")
            downPill.Name = "DownPill"
            downPill.Size = UDim2.fromOffset(36, 14)
            downPill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
            downPill.BackgroundTransparency = 0.1
            downPill.BorderSizePixel = 0
            downPill.Visible = false
            downPill.LayoutOrder = 5
            downPill.Parent = pill
            Instance.new("UICorner", downPill).CornerRadius = UDim.new(1, 0)

            local downLbl = Instance.new("TextLabel")
            downLbl.Name = "DownLbl"
            downLbl.Size = UDim2.new(1, 0, 1, 0)
            downLbl.BackgroundTransparency = 1
            downLbl.Font = Enum.Font.GothamBold
            downLbl.TextSize = 9
            downLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            downLbl.Text = "DOWN"
            downLbl.Parent = downPill

            StatusESP[char] = bb
        end

        local nameLbl = bb:FindFirstChild("NameLbl")
        local pill = bb:FindFirstChild("Pill")
        if not pill then return end
        local pillStroke = pill:FindFirstChild("PillStroke")
        local avatarHolder = pill:FindFirstChild("AvatarHolder")
        local avatarImg = avatarHolder and avatarHolder:FindFirstChild("AvatarImg")
        local avatarStroke = avatarHolder and avatarHolder:FindFirstChild("AvatarStroke")
        local dot = pill:FindFirstChild("Dot")
        local distLbl = pill:FindFirstChild("DistLbl")
        local actionLbl = pill:FindFirstChild("ActionLbl")
        local hpBarBg = pill:FindFirstChild("HPBarBg")
        local hpBarFill = hpBarBg and hpBarBg:FindFirstChild("HPBarFill")
        local downPill = pill:FindFirstChild("DownPill")
        local distScale = bb:FindFirstChild("DistScale")

        if pillStroke then
            pillStroke.Color = accentColor
            pillStroke.Transparency = isDown and 0.2 or 0.5
        end
        if avatarHolder then
            avatarHolder.Visible = FESPS.ShowAvatar == true
            if avatarStroke then avatarStroke.Color = accentColor end
            if avatarImg and avatarImg.Image == "" then
                avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. plr.UserId .. "&w=150&h=150"
            end
        end
        if dot then
            dot.Visible = (FESPS.ShowAvatar ~= true)
            dot.BackgroundColor3 = accentColor
        end
        if nameLbl then
            nameLbl.Text = plr.Name
            nameLbl.Visible = FESPS.ShowName
            nameLbl.TextColor3 = isDown and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 255, 255)
        end
        if distLbl then
            distLbl.Text = string.format("%.0fm", dist)
            distLbl.Visible = FESPS.ShowDistance
        end
        if actionLbl then
            actionLbl.Text = actionText
            actionLbl.TextColor3 = actionColor
            actionLbl.Visible = FESPS.ShowAction == true
            if actionText == "IDLE" then
                actionLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
        end
        if hpBarBg and hpBarFill then
            hpBarFill.Size = UDim2.new(hpPct, 0, 1, 0)
            hpBarFill.BackgroundColor3 = hpColor
            hpBarBg.Visible = FESPS.ShowHealth == true
        end
        if downPill then downPill.Visible = isDown end

        local totalW = 14
        local count = 0
        if FESPS.ShowAvatar then totalW = totalW + 18; count = count + 1
        else totalW = totalW + 7; count = count + 1 end
        if FESPS.ShowDistance then totalW = totalW + 32; count = count + 1 end
        if FESPS.ShowAction then totalW = totalW + 50; count = count + 1 end
        if FESPS.ShowHealth then totalW = totalW + 38; count = count + 1 end
        if isDown then totalW = totalW + 36; count = count + 1 end
        totalW = totalW + math.max(count - 1, 0) * 5
        if totalW < 50 then totalW = 50 end
        if totalW > 240 then totalW = 240 end
        pill.Size = UDim2.fromOffset(totalW, 22)

        local showPill = FESPS.ShowDistance or FESPS.ShowHealth or isDown
            or FESPS.ShowAction or FESPS.ShowAvatar
        pill.Visible = showPill

        local h = 16 + (showPill and 24 or 0)
        bb.Size = UDim2.fromOffset(260, h)

        if distScale then
            local scaleVal = 1 - (dist - 50) / 500
            scaleVal = math.clamp(scaleVal, 0.5, 1.05)
            distScale.Scale = scaleVal
        end
    end

    local function GetGameValue(obj, name)
        if not obj then return nil end
        local attr = obj:GetAttribute(name)
        if attr ~= nil then return attr end
        local child = obj:FindFirstChild(name)
        if child then
            local ok, v = pcall(function() return child.Value end)
            if ok then return v end
        end
        return nil
    end
    local function UpdateGenerator(gen)
        if not gen or not gen.Parent then return end
        if not FESP.Generator then
            local o = gen:FindFirstChild("GenESP"); if o then o:Destroy() end
            local h = gen:FindFirstChild("GenHighlight"); if h then h:Destroy() end
            return
        end
        local percent = GetGameValue(gen, "RepairProgress")
            or GetGameValue(gen, "Progress")
            or GetGameValue(gen, "ProgressRepair") or 0
        local bb = gen:FindFirstChild("GenESP")
        if percent >= 100 then if bb then bb:Destroy() end; return end
        local cp = math.clamp(percent, 0, 100)
        local color = FESPC.Generator:Lerp(Color3.fromRGB(0, 255, 120), cp / 100)
        local text = string.format("[%.0f%%]", percent)
        if not bb then
            bb = Instance.new("BillboardGui")
            bb.Name = "GenESP"
            bb.Size = UDim2.new(0, 100, 0, 30)
            bb.AlwaysOnTop = true
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = color
            lbl.TextStrokeTransparency = 0
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 12
            lbl.Parent = bb
            bb.Adornee = gen
            bb.Parent = gen
        else
            local lbl = bb:FindFirstChildOfClass("TextLabel")
            if lbl then lbl.Text = text; lbl.TextColor3 = color end
        end
        local h = gen:FindFirstChild("GenHighlight") or Instance.new("Highlight")
        h.Name = "GenHighlight"
        h.Adornee = gen
        h.FillColor = color
        h.OutlineColor = color
        h.FillTransparency = 0.9
        h.OutlineTransparency = 0.3
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = gen
    end
    local function UpdateMapESP(obj, root)
        if not obj or not root or not obj.Parent then return end
        local pos
        if obj:IsA("Model") then
            if obj.PrimaryPart then pos = obj.PrimaryPart.Position
            else
                local ok, pivot = pcall(function() return obj:GetPivot().Position end)
                pos = ok and pivot or nil
                if not pos then
                    local bp = obj:FindFirstChildWhichIsA("BasePart", true)
                    if bp then pos = bp.Position end
                end
            end
        elseif obj:IsA("BasePart") then pos = obj.Position end
        if not pos then return end
        local dist = (pos - root.Position).Magnitude
        local isWindow = obj.Name == "Window" or obj.Name == "VaultWindow"
            or obj.Name == "WindowVault" or obj.Name == "Vault"
            or (obj:IsA("Model") and (obj:FindFirstChild("VaultTrigger", true) ~= nil))
        if isWindow then
            if FESP.Window and dist <= FESP.Distance then CreateESP(obj, FESPC.Window)
            else RemoveESP(obj) end
        end
        if obj.Name == "Pallet" or obj.Name == "Palletwrong" then
            if FESP.Pallet and dist <= FESP.Distance then CreateESP(obj, FESPC.Pallet)
            else RemoveESP(obj) end
        end
    end
    local function UpdateSCPEsp(root)
        if not FESP.SCP then
            for obj in pairs(CachedSCP) do RemoveESP(obj) end
            return
        end
        for obj in pairs(CachedSCP) do
            if obj and obj.Parent then
                local pos
                if obj:IsA("Model") then
                    local ok, pivot = pcall(function() return obj:GetPivot().Position end)
                    pos = ok and pivot or nil
                elseif obj:IsA("BasePart") then pos = obj.Position end
                if pos then
                    local dist = (pos - root.Position).Magnitude
                    if dist <= FESP.Distance then CreateESP(obj, FESPC.SCP)
                    else RemoveESP(obj) end
                end
            end
        end
    end

    Scheduler:Add("ESPMain", function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local char = p.Character
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local dist = (hrp.Position - root.Position).Magnitude
                        if dist <= FESP.Distance then
                            if FESP.Survivor and TeamIs(p, "Survivor") then
                                CreateESP(char, FESPC.Survivor)
                            elseif FESP.Killer and TeamIs(p, "Killer") then
                                CreateESP(char, FESPC.Killer)
                            else RemoveESP(char) end
                        else RemoveESP(char) end
                    end
                    CreateStatusESP(p, char, root)
                else RemoveESP(char); RemoveStatusESP(char) end
            end
        end
        if FESP.Generator then
            for gen in pairs(CachedGen) do UpdateGenerator(gen) end
        end
        for obj in pairs(CachedWindow) do UpdateMapESP(obj, root) end
        for obj in pairs(CachedPallet) do UpdateMapESP(obj, root) end
        UpdateSCPEsp(root)
        if FESP.Window then
            for _, obj in ipairs(CachedVaultTrigger) do
                if obj and obj.Parent then
                    local rootWindow = obj.Parent
                    if obj.Name == "VaultPoint" and rootWindow and rootWindow.Name == "VaultTrigger" then
                        rootWindow = rootWindow.Parent
                    end
                    if rootWindow and rootWindow ~= Workspace and not ESPObjects[rootWindow] then
                        UpdateMapESP(rootWindow, root)
                    end
                end
            end
        end
    end, 0.1)

    --====================================================--
    -- INVISIBLE
    --====================================================--
    W.Invisible = W.Invisible or {
        Enabled = false,
        Hotkey = Enum.KeyCode[VD.Invis_Hotkey or "G"],
        BodyParts = {}, Highlight = nil, HeartbeatConn = nil, RenderConn = nil,
        _savedCF = nil, _savedCamOff = nil,
    }
    local Invis = W.Invisible
    local function Invis_SetupCharacter()
        local char = LocalPlayer.Character
        if not char then return end
        Invis.BodyParts = {}
        if char:FindFirstChild("InvisHighlight") then char.InvisHighlight:Destroy() end
        local highlight = Instance.new("Highlight")
        highlight.Name = "InvisHighlight"
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(0, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Enabled = false
        highlight.Parent = char
        Invis.Highlight = highlight
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.Transparency == 0 then
                table.insert(Invis.BodyParts, v)
            end
        end
    end
    local function Invis_Apply(state)
        if Invis.Highlight then Invis.Highlight.Enabled = state and true or false end
        for _, v in pairs(Invis.BodyParts) do
            if v and v.Parent then v.Transparency = state and 0.5 or 0 end
        end
    end
    function W.Invisible_SetState(state)
        Invis.Enabled = state and true or false
        VD.Invis_Enabled = Invis.Enabled
        Invis_Apply(Invis.Enabled)
        if getgenv().Gluto_InvisBtn_UpdateVisual then pcall(getgenv().Gluto_InvisBtn_UpdateVisual) end
    end
    local function Invis_Restore()
        if not Invis._savedCF then return end
        local char = LocalPlayer.Character
        if char then
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if rootPart and rootPart.Parent then rootPart.CFrame = Invis._savedCF end
            if humanoid and humanoid.Parent and Invis._savedCamOff then
                humanoid.CameraOffset = Invis._savedCamOff
            end
        end
        Invis._savedCF = nil
        Invis._savedCamOff = nil
    end
    function W.Invisible_Start()
        if not LocalPlayer.Character then return end
        Invis_SetupCharacter()
        W.Invisible_SetState(true)
        if Invis.HeartbeatConn then return end
        Invis.HeartbeatConn = RunService.Heartbeat:Connect(function()
            if not Invis.Enabled then return end
            local char = LocalPlayer.Character
            if not char then return end
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not rootPart or not humanoid then return end
            if Invis._savedCF then Invis_Restore() end
            local cf     = rootPart.CFrame
            local camOff = humanoid.CameraOffset
            Invis._savedCF = cf
            Invis._savedCamOff = camOff
            rootPart.CFrame = cf * CFrame.new(0, -200000, 0)
            humanoid.CameraOffset = Vector3.new(camOff.X, camOff.Y + 200000, camOff.Z)
        end)
        Invis.RenderConn = RunService.RenderStepped:Connect(function()
            if Invis._savedCF then Invis_Restore() end
        end)
    end
    function W.Invisible_Stop()
        W.Invisible_SetState(false)
        if Invis.HeartbeatConn then pcall(function() Invis.HeartbeatConn:Disconnect() end); Invis.HeartbeatConn = nil end
        if Invis.RenderConn then pcall(function() Invis.RenderConn:Disconnect() end); Invis.RenderConn = nil end
        Invis_Restore()
    end
    function W.Invisible_SetEnabled(v)
        if v then W.Invisible_Start() else W.Invisible_Stop() end
    end
    function W.Invisible_Toggle()
        if Invis.Enabled then W.Invisible_Stop() else W.Invisible_Start() end
    end
    function W.Invisible_SetHotkey(kc)
        if kc then Invis.Hotkey = kc; VD.Invis_Hotkey = kc.Name end
    end
    task.spawn(function()
        if not LocalPlayer.Character then LocalPlayer.CharacterAdded:Wait() end
        task.wait(0.3); Invis_SetupCharacter()
    end)
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5); Invis_SetupCharacter()
        if Invis.Enabled then Invis_Apply(true) end
    end)

    --====================================================--
    -- HIDDEN LEAP BYPASS
    --====================================================--
    getgenv().Bypass_HiddenLeapBypassThread = nil
    function W.BYPASS_StartHiddenCooldownBypass()
        if getgenv().Bypass_HiddenLeapBypassThread then return end
        getgenv().Bypass_HiddenLeapBypassThread = task.spawn(function()
            local leapFunction, m2Function
            local function scanGC()
                pcall(function()
                    for _, v in pairs(getgc(true)) do
                        if type(v) == "function" and islclosure(v) then
                            local info
                            pcall(function() info = debug.getinfo(v) end)
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
            while task.wait(0.15) do
                if not VD.KILLER_BypassLeap then break end
                if not (leapFunction and m2Function) then
                    if os.clock() - lastScan >= 2 then lastScan = os.clock(); scanGC() end
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
            getgenv().Bypass_HiddenLeapBypassThread = nil
        end)
    end
    function W.BYPASS_StopHiddenCooldownBypass() end
    function W.BYPASS_SetHiddenLeap(v)
        VD.KILLER_BypassLeap = v and true or false
        if VD.KILLER_BypassLeap then W.BYPASS_StartHiddenCooldownBypass()
        else W.BYPASS_StopHiddenCooldownBypass() end
    end

    --====================================================--
    -- INF GRAB (MYERS)
    --====================================================--
    W.MyersGrabData = W.MyersGrabData or { Enabled = false, HotkeyCode = Enum.KeyCode.H }
    local MyersGrabData = W.MyersGrabData
    function W.getMyersTarget()
        local char = LocalPlayer.Character
        if not char then return nil end
        local myHRP = char:FindFirstChild("HumanoidRootPart")
        if not myHRP then return nil end
        local candidates = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    table.insert(candidates, { player = player, dist = (hrp.Position - myHRP.Position).Magnitude })
                end
            end
        end
        table.sort(candidates, function(a, b) return a.dist < b.dist end)
        for _, c in ipairs(candidates) do return c.player end
        return nil
    end
    function W.doMyersGrab()
        if not MyersGrabData.Enabled then return end
        local target = W.getMyersTarget()
        if not target or not target.Character then return end
        pcall(function() ReplicatedStorage.Remotes.Killers.Stalker.grab:FireServer(target.Character) end)
    end
    function W.setMyersGrab(v)
        MyersGrabData.Enabled = v and true or false
        VD.KILLER_InfGrab = MyersGrabData.Enabled
        if getgenv().Gluto_MGrabBtn_UpdateVisual then pcall(getgenv().Gluto_MGrabBtn_UpdateVisual) end
    end
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == MyersGrabData.HotkeyCode and MyersGrabData.Enabled then
            W.doMyersGrab()
        end
    end)

    --====================================================--
    -- SLASHER BYPASS
    --====================================================--
    getgenv().MAWWW_SlasherCooldownBypassThread = nil
    function W.MAWWW_StartSlasherCooldownBypass()
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
            while task.wait(0.15) do
                if not VD.KILLER_InfLakeMist and not VD.KILLER_InfPursuit then break end
                if not (toggleFunc and pursuitHandler) then
                    if os.clock() - lastScan >= 2 then scanGCForSlasher(); lastScan = os.clock() end
                end
                if toggleFunc and VD.KILLER_InfLakeMist then
                    pcall(function()
                        debug.setupvalue(toggleFunc, 6, false)
                        debug.setupvalue(toggleFunc, 10, false)
                    end)
                end
                if pursuitHandler and VD.KILLER_InfPursuit then
                    pcall(function()
                        debug.setupvalue(pursuitHandler, 5, false)
                        debug.setupvalue(pursuitHandler, 6, false)
                    end)
                end
            end
            getgenv().MAWWW_SlasherCooldownBypassThread = nil
        end)
    end
    function W.MAWWW_StopSlasherCooldownBypass()
        pcall(function()
            local jason = ReplicatedStorage:FindFirstChild("Remotes")
                and ReplicatedStorage.Remotes:FindFirstChild("Killers")
                and ReplicatedStorage.Remotes.Killers:FindFirstChild("Jason")
            if jason then
                if not VD.KILLER_InfLakeMist then
                    local lm = jason:FindFirstChild("LakeMist")
                    if lm then lm:FireServer(false) end
                end
                if not VD.KILLER_InfPursuit then
                    local ps = jason:FindFirstChild("Pursuit")
                    if ps then ps:FireServer(false) end
                end
            end
        end)
    end
    function W.MAWWW_SetLakeMist(v)
        VD.KILLER_InfLakeMist = v and true or false
        if VD.KILLER_InfLakeMist or VD.KILLER_InfPursuit then W.MAWWW_StartSlasherCooldownBypass()
        else W.MAWWW_StopSlasherCooldownBypass() end
    end
    function W.MAWWW_SetPursuit(v)
        VD.KILLER_InfPursuit = v and true or false
        if VD.KILLER_InfLakeMist or VD.KILLER_InfPursuit then W.MAWWW_StartSlasherCooldownBypass()
        else W.MAWWW_StopSlasherCooldownBypass() end
    end

    --====================================================--
    -- ABYSS BYPASS
    --====================================================--
    getgenv().MAWWW_AbyssCooldownBypassConnection = nil
    getgenv().MAWWW_CorruptHandlerFunc = nil
    function W.MAWWW_StartAbyssCooldownBypass()
        if not getgenv().MAWWW_CorruptHandlerFunc then
            pcall(function()
                for _, v in pairs(getgc(true)) do
                    if type(v) == "function" and islclosure(v) then
                        local constants = debug.getconstants(v)
                        if table.find(constants, "corrupt") and table.find(constants, "Immobile") then
                            getgenv().MAWWW_CorruptHandlerFunc = v
                            break
                        end
                    end
                end
            end)
        end
        if not getgenv().MAWWW_CorruptHandlerFunc then return end
        if getgenv().MAWWW_AbyssCooldownBypassConnection then
            getgenv().MAWWW_AbyssCooldownBypassConnection:Disconnect()
        end
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
    function W.MAWWW_StopAbyssCooldownBypass()
        if getgenv().MAWWW_AbyssCooldownBypassConnection then
            getgenv().MAWWW_AbyssCooldownBypassConnection:Disconnect()
            getgenv().MAWWW_AbyssCooldownBypassConnection = nil
        end
    end
    function W.MAWWW_SetAbyssBypass(v)
        VD.KILLER_BypassCooldown = v and true or false
        if VD.KILLER_BypassCooldown then W.MAWWW_StartAbyssCooldownBypass()
        else W.MAWWW_StopAbyssCooldownBypass() end
    end

    --====================================================--
    -- JEFF INF FRENZY
    --====================================================--
    getgenv().MAWWW_JeffCooldownBypassThread = nil
    function W.MAWWW_StartJeffCooldownBypass()
        if getgenv().MAWWW_JeffCooldownBypassThread then return end
        getgenv().MAWWW_JeffCooldownBypassThread = task.spawn(function()
            while task.wait(0.2) do
                if not VD.KILLER_InfFrenzy then break end
                pcall(function()
                    local char = LocalPlayer.Character
                    if char and char:GetAttribute("Frenzy") ~= true then
                        char:SetAttribute("Frenzy", true)
                    end
                end)
            end
            getgenv().MAWWW_JeffCooldownBypassThread = nil
        end)
    end
    function W.MAWWW_StopJeffCooldownBypass()
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
    function W.MAWWW_SetJeffFrenzy(v)
        VD.KILLER_InfFrenzy = v and true or false
        if VD.KILLER_InfFrenzy then W.MAWWW_StartJeffCooldownBypass()
        else W.MAWWW_StopJeffCooldownBypass() end
    end

    --====================================================--
    -- KILLER ABILITIES
    --====================================================--
    W.KillerAbilities = W.KillerAbilities or {
        AutoStalk = VD.KA_AutoStalk,
        AutoStalkRange = VD.KA_AutoStalkRange,
        AutoKillAll = VD.KA_AutoKillAll,
        DropAllPallet = VD.KA_DropAllPallet,
        BlockAllVault = VD.KA_BlockAllVault,
    }
    local KA = W.KillerAbilities
    function W.KA_GetClosestSurvivor(range, minHealth)
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return nil end
        local closest, shortest = nil, (range or math.huge)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and TeamIs(plr, "Survivor") then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > (minHealth or 30) then
                    local d = (hrp.Position - root.Position).Magnitude
                    if d <= shortest then shortest = d; closest = plr end
                end
            end
        end
        return closest
    end
    local AutoStalkConnection = nil
    function W.KA_StartAutoStalk()
        if AutoStalkConnection then return end
        AutoStalkConnection = RunService.Heartbeat:Connect(function()
            if not KA.AutoStalk then return end
            if GetRole() ~= "Killer" then return end
            local target = W.KA_GetClosestSurvivor(KA.AutoStalkRange, 30)
            if not target or not target.Character then return end
            local stalkEvent = ReplicatedStorage:FindFirstChild("Remotes", true)
                and ReplicatedStorage.Remotes:FindFirstChild("Killers", true)
                and ReplicatedStorage.Remotes.Killers:FindFirstChild("Stalker", true)
                and ReplicatedStorage.Remotes.Killers.Stalker:FindFirstChild("StartStalking")
            if stalkEvent then pcall(function() stalkEvent:FireServer(target) end) end
        end)
    end
    function W.KA_StopAutoStalk()
        if AutoStalkConnection then pcall(function() AutoStalkConnection:Disconnect() end); AutoStalkConnection = nil end
    end
    function W.KA_SetAutoStalk(v)
        KA.AutoStalk = v and true or false
        VD.KA_AutoStalk = KA.AutoStalk
        if KA.AutoStalk then W.KA_StartAutoStalk() else W.KA_StopAutoStalk() end
    end
    local KillAllTarget = nil
    function W.KA_UpdateKillAll()
        if not KA.AutoKillAll then KillAllTarget = nil; return end
        if GetRole() ~= "Killer" then KillAllTarget = nil; return end
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local tChar = KillAllTarget and KillAllTarget.Character
        if not KillAllTarget
            or not tChar
            or not tChar.Parent
            or not tChar:FindFirstChild("Humanoid")
            or tChar.Humanoid.Health <= 35 then
            KillAllTarget = W.KA_GetClosestSurvivor(math.huge, 30)
            tChar = KillAllTarget and KillAllTarget.Character
        end
        if KillAllTarget and tChar then
            local targetHRP = tChar:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local velocity  = targetHRP.AssemblyLinearVelocity
                local predict   = velocity * 0.15
                local targetPos = targetHRP.Position + predict
                local behind    = targetHRP.CFrame.LookVector * -3
                root.CFrame = CFrame.new(targetPos + behind, targetPos)
            end
            pcall(function()
                local attacks = ReplicatedStorage:FindFirstChild("Remotes")
                    and ReplicatedStorage.Remotes:FindFirstChild("Attacks")
                local basic = attacks and attacks:FindFirstChild("BasicAttack")
                if basic then basic:FireServer(false) end
            end)
        end
    end
    function W.KA_SetAutoKillAll(v)
        KA.AutoKillAll = v and true or false
        VD.KA_AutoKillAll = KA.AutoKillAll
        if not KA.AutoKillAll then KillAllTarget = nil end
    end
    local lastDropAllPallet = 0
    function W.KA_DropAllPallets()
        if not KA.DropAllPallet then return end
        if GetRole() ~= "Killer" then return end
        local now = tick()
        if now - lastDropAllPallet < 2 then return end
        lastDropAllPallet = now
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
                    if target then pcall(function() dropEvent:FireServer(target) end) end
                end
            end
        end)
    end
    function W.KA_SetDropAllPallet(v)
        KA.DropAllPallet = v and true or false
        VD.KA_DropAllPallet = KA.DropAllPallet
    end
    local lastBlockVault = 0
    function W.KA_BlockAllVaults()
        if not KA.BlockAllVault then return end
        if GetRole() ~= "Killer" then return end
        local now = tick()
        if now - lastBlockVault < 1.5 then return end
        lastBlockVault = now
        pcall(function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local vaultEvent = remotes
                and remotes:FindFirstChild("Window")
                and remotes.Window:FindFirstChild("VaultEvent")
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
                if map then
                    for _, obj in ipairs(map:GetDescendants()) do
                        if obj.Name == "VaultTrigger" and obj:IsA("BasePart") then
                            pcall(function() vaultEvent:FireServer(obj, true) end)
                        end
                    end
                end
            end
        end)
    end
    function W.KA_SetBlockAllVault(v)
        KA.BlockAllVault = v and true or false
        VD.KA_BlockAllVault = KA.BlockAllVault
    end
    Scheduler:Add("KillerAbilities", function()
        if KA.AutoKillAll   then W.KA_UpdateKillAll() end
        if KA.DropAllPallet then W.KA_DropAllPallets() end
        if KA.BlockAllVault then W.KA_BlockAllVaults() end
    end, 0.15)
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if KA.AutoStalk then pcall(W.KA_StartAutoStalk) end
    end)

    --====================================================--
    -- SILENT FLASK
    --====================================================--
    do
        VD.FLASK_SilentAim    = VD.FLASK_SilentAim    or false
        VD.FLASK_ShowBeam     = VD.FLASK_ShowBeam     ~= false
        VD.FLASK_ShowLanding  = VD.FLASK_ShowLanding  ~= false
        VD.FLASK_Predict      = VD.FLASK_Predict      ~= false
        VD.FLASK_Speed        = VD.FLASK_Speed        or 90
        VD.FLASK_Gravity      = VD.FLASK_Gravity      or 196
        VD.FLASK_LeadMult     = VD.FLASK_LeadMult     or 1.0
        VD.FLASK_Range        = VD.FLASK_Range        or 200
        VD.FLASK_BeamColor    = VD.FLASK_BeamColor    or Color3.fromRGB(255, 255, 255)
        VD.FLASK_AccentColor  = VD.FLASK_AccentColor  or Color3.fromRGB(25, 25, 25)
        local FlaskState = { Target = nil, PredictedPos = nil, BeamPart = nil, AccentPart = nil, LandingRing = nil }
        local function Flask_GetThrowRemote()
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            if not r then return nil end
            for _, obj in ipairs(r:GetDescendants()) do
                if obj:IsA("RemoteEvent") and obj.Name == "ThrowFlask" then return obj end
            end
            return nil
        end
        local function Flask_GetTarget()
            local myChar = LocalPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myRoot then return nil end
            local maxR = tonumber(VD.FLASK_Range) or 200
            local best, bd = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and TeamIs(p, "Survivor") and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    local root = p.Character:FindFirstChild("HumanoidRootPart")
                    if hum and hum.Health > 0 and root then
                        local d = (root.Position - myRoot.Position).Magnitude
                        if d <= maxR and d < bd then bd = d; best = { Player = p, Root = root, Char = p.Character } end
                    end
                end
            end
            return best
        end
        local function Flask_GetHandOrigin()
            local c = LocalPlayer.Character
            if not c then return nil end
            return c:FindFirstChild("LeftHand") or c:FindFirstChild("Left Arm")
                or c:FindFirstChild("RightHand") or c:FindFirstChild("Right Arm")
                or c:FindFirstChild("HumanoidRootPart")
        end
        local function Flask_PredictLanding(origin, targetRoot)
            local targetPos = targetRoot.Position
            local speed   = tonumber(VD.FLASK_Speed)   or 90
            local gravity = tonumber(VD.FLASK_Gravity) or 196
            local lead    = tonumber(VD.FLASK_LeadMult) or 1.0
            if not VD.FLASK_Predict then return targetPos end
            local tv = targetRoot.AssemblyLinearVelocity or Vector3.zero
            local horizVel = Vector3.new(tv.X, 0, tv.Z)
            local dist = (targetPos - origin).Magnitude
            local time = dist / speed
            local predicted = targetPos
            for _ = 1, 3 do
                predicted = targetPos + horizVel * time * lead
                local nd = (predicted - origin).Magnitude
                time = nd / speed
            end
            local drop = 0.5 * gravity * (time * time)
            return predicted + Vector3.new(0, drop, 0)
        end
        local function Flask_ClearVisuals()
            if FlaskState.BeamPart then pcall(function() FlaskState.BeamPart:Destroy() end); FlaskState.BeamPart = nil end
            if FlaskState.AccentPart then pcall(function() FlaskState.AccentPart:Destroy() end); FlaskState.AccentPart = nil end
            if FlaskState.LandingRing then pcall(function() FlaskState.LandingRing:Destroy() end); FlaskState.LandingRing = nil end
        end
        local function Flask_HideVisuals()
            if FlaskState.BeamPart then FlaskState.BeamPart.Transparency = 1 end
            if FlaskState.AccentPart then FlaskState.AccentPart.Transparency = 1 end
            if FlaskState.LandingRing then FlaskState.LandingRing.Transparency = 1 end
        end
        local function Flask_EnsureBeamParts()
            if not FlaskState.BeamPart or not FlaskState.BeamPart.Parent then
                local beam = Instance.new("Part")
                beam.Name = "GlutoFlaskBeam"; beam.Anchored = true; beam.CanCollide = false
                beam.CanTouch = false; beam.CanQuery = false; beam.CastShadow = false
                beam.Material = Enum.Material.Neon
                beam.Color = VD.FLASK_BeamColor or Color3.fromRGB(255, 255, 255)
                beam.Transparency = 0.2
                beam.Parent = Workspace
                FlaskState.BeamPart = beam
            end
            if not FlaskState.AccentPart or not FlaskState.AccentPart.Parent then
                local accent = Instance.new("Part")
                accent.Name = "GlutoFlaskBeamAccent"; accent.Anchored = true; accent.CanCollide = false
                accent.CanTouch = false; accent.CanQuery = false; accent.CastShadow = false
                accent.Material = Enum.Material.SmoothPlastic
                accent.Color = VD.FLASK_AccentColor or Color3.fromRGB(25, 25, 25)
                accent.Transparency = 0.35
                accent.Parent = Workspace
                FlaskState.AccentPart = accent
            end
            if FlaskState.BeamPart then FlaskState.BeamPart.Color = VD.FLASK_BeamColor or Color3.fromRGB(255, 255, 255) end
            if FlaskState.AccentPart then FlaskState.AccentPart.Color = VD.FLASK_AccentColor or Color3.fromRGB(25, 25, 25) end
        end
        local function Flask_UpdateBeam(origin, landing)
            Flask_EnsureBeamParts()
            local dir = landing - origin
            local dist = dir.Magnitude
            if dist < 0.1 then return end
            local mid = (origin + landing) / 2
            local cf = CFrame.lookAt(mid, landing)
            FlaskState.BeamPart.Size = Vector3.new(0.12, 0.12, dist)
            FlaskState.BeamPart.CFrame = cf
            FlaskState.BeamPart.Transparency = 0.2
            FlaskState.AccentPart.Size = Vector3.new(0.22, 0.22, dist)
            FlaskState.AccentPart.CFrame = cf
            FlaskState.AccentPart.Transparency = 0.35
        end
        local function Flask_UpdateLanding(pos)
            if not VD.FLASK_ShowLanding then
                if FlaskState.LandingRing then FlaskState.LandingRing.Transparency = 1 end
                return
            end
            if not FlaskState.LandingRing or not FlaskState.LandingRing.Parent then
                local ring = Instance.new("Part")
                ring.Name = "GlutoFlaskLanding"; ring.Shape = Enum.PartType.Cylinder
                ring.Anchored = true; ring.CanCollide = false
                ring.CanTouch = false; ring.CanQuery = false; ring.CastShadow = false
                ring.Material = Enum.Material.Neon
                ring.Color = VD.FLASK_BeamColor or Color3.fromRGB(255, 255, 255)
                ring.Size = Vector3.new(0.2, 5, 5)
                ring.Parent = Workspace
                FlaskState.LandingRing = ring
            end
            FlaskState.LandingRing.Color = VD.FLASK_BeamColor or Color3.fromRGB(255, 255, 255)
            FlaskState.LandingRing.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90))
            FlaskState.LandingRing.Transparency = 0.35
        end
        Scheduler:Add("FlaskVisual", function()
            if not VD.FLASK_SilentAim then
                Flask_HideVisuals()
                FlaskState.Target = nil
                FlaskState.PredictedPos = nil
                return
            end
            if GetRole() ~= "Killer" then Flask_HideVisuals(); return end
            local target = Flask_GetTarget()
            if not target or not target.Root then
                Flask_HideVisuals()
                FlaskState.Target = nil
                FlaskState.PredictedPos = nil
                return
            end
            local hand = Flask_GetHandOrigin()
            if not hand then return end
            local landing = Flask_PredictLanding(hand.Position, target.Root)
            FlaskState.Target = target
            FlaskState.PredictedPos = landing
            if VD.FLASK_ShowBeam then pcall(Flask_UpdateBeam, hand.Position, landing)
            else
                if FlaskState.BeamPart then FlaskState.BeamPart.Transparency = 1 end
                if FlaskState.AccentPart then FlaskState.AccentPart.Transparency = 1 end
            end
            pcall(Flask_UpdateLanding, landing)
        end, 0.033)
        task.spawn(function()
            pcall(function()
                local oldNC
                oldNC = hookmetamethod(game, "__namecall", function(self, ...)
                    if getnamecallmethod() == "FireServer"
                       and self.Name == "ThrowFlask"
                       and VD.FLASK_SilentAim
                       and GetRole() == "Killer"
                       and FlaskState.PredictedPos then
                        local args = {...}
                        if typeof(args[2]) == "Vector3" then
                            local origin = args[2]
                            local aimDir = (FlaskState.PredictedPos - origin)
                            if aimDir.Magnitude > 0.1 then
                                args[1] = aimDir.Unit
                                return oldNC(self, unpack(args))
                            end
                        elseif typeof(args[1]) == "Vector3" then
                            local hand = Flask_GetHandOrigin()
                            if hand then
                                local aimDir = (FlaskState.PredictedPos - hand.Position)
                                if aimDir.Magnitude > 0.1 then
                                    args[1] = aimDir.Unit
                                    return oldNC(self, unpack(args))
                                end
                            end
                        end
                    end
                    return oldNC(self, ...)
                end)
            end)
        end)
        W.Flask_SetEnabled = function(v)
            VD.FLASK_SilentAim = v and true or false
            if not v then Flask_ClearVisuals() end
        end
        W.Flask_SetBeamColor   = function(c) VD.FLASK_BeamColor = c end
        W.Flask_SetAccentColor = function(c) VD.FLASK_AccentColor = c end
        W.Flask_SetSpeed       = function(v) VD.FLASK_Speed = tonumber(v) or 90 end
        W.Flask_SetGravity     = function(v) VD.FLASK_Gravity = tonumber(v) or 196 end
        W.Flask_SetLead        = function(v) VD.FLASK_LeadMult = tonumber(v) or 1.0 end
        W.Flask_SetRange       = function(v) VD.FLASK_Range = tonumber(v) or 200 end
    end

    --====================================================--
    -- SPEAR AIMBOT (FULL)
    --====================================================--
    do
        VD.SPEAR_Aimbot = VD.SPEAR_Aimbot or false
        VD.SPEAR_Gravity = VD.SPEAR_Gravity or 50
        VD.SPEAR_Speed = VD.SPEAR_Speed or 100
        local SpearBtnData = {
            UI = nil, Button = nil, Active = true, DragLocked = false, Dragging = false,
            DragStart = nil, DragStartPos = nil, ManualTarget = nil, TargetIndex = 0,
            TargetLabel = nil, LeftArrow = nil, RightArrow = nil,
        }
        local function SpearAimbotCalc(targetPos)
            if not VD.SPEAR_Aimbot or GetRole() ~= "Killer" then return nil end
            local char = LocalPlayer.Character
            if not char then return nil end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return nil end
            local startPos = root.Position + Vector3.new(0, 2, 0)
            local distance = (targetPos - startPos).Magnitude
            local gravity  = VD.SPEAR_Gravity or 50
            local speed    = VD.SPEAR_Speed or 100
            local time     = distance / speed
            local drop     = 0.5 * gravity * time * time
            return targetPos + Vector3.new(0, drop, 0)
        end
        local function Spear_GetTargetList()
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local list = {}
            if not root then return list end
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and TeamIs(player, "Survivor") and player.Character then
                    local tr = player.Character:FindFirstChild("HumanoidRootPart")
                    local th = player.Character:FindFirstChildOfClass("Humanoid")
                    if tr and th and th.MaxHealth > 0 and (th.Health / th.MaxHealth) > 0.25 then
                        local dist = (tr.Position - root.Position).Magnitude
                        table.insert(list, { Player = player, Dist = dist })
                    end
                end
            end
            table.sort(list, function(a, b) return a.Dist < b.Dist end)
            local players = {}
            for _, v in ipairs(list) do table.insert(players, v.Player) end
            return players
        end
        local function Spear_UpdateTargetLabel()
            if not (SpearBtnData and SpearBtnData.TargetLabel) then return end
            if SpearBtnData.ManualTarget and SpearBtnData.ManualTarget.Parent then
                SpearBtnData.TargetLabel.Text = SpearBtnData.ManualTarget.Name
            else SpearBtnData.TargetLabel.Text = "AUTO" end
            SpearBtnData.TargetLabel.Visible = true
        end
        local function Spear_CycleTarget(direction)
            local list = Spear_GetTargetList()
            if #list == 0 then
                SpearBtnData.ManualTarget = nil
                SpearBtnData.TargetIndex = 0
                VD_Notify("Spear Aimbot", "Tidak ada target survivor.", 2)
                return
            end
            local curIdx = nil
            if SpearBtnData.ManualTarget then
                for i, p in ipairs(list) do
                    if p == SpearBtnData.ManualTarget then curIdx = i; break end
                end
            end
            local nextIdx
            if curIdx then
                nextIdx = curIdx + direction
                if nextIdx > #list then nextIdx = 1 end
                if nextIdx < 1 then nextIdx = #list end
            else nextIdx = 1 end
            SpearBtnData.TargetIndex  = nextIdx
            SpearBtnData.ManualTarget = list[nextIdx]
            VD_Notify("Spear Aimbot", "Target: " .. SpearBtnData.ManualTarget.Name, 2)
            Spear_UpdateTargetLabel()
        end
        local function Spear_UpdateAim()
            if not VD.SPEAR_Aimbot then return end
            if SpearBtnData and not SpearBtnData.Active then return end
            if GetRole() ~= "Killer" then return end
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local target = nil
            if SpearBtnData.ManualTarget then
                local p = SpearBtnData.ManualTarget
                local valid = p.Parent and TeamIs(p, "Survivor") and p.Character
                if valid then
                    local tr = p.Character:FindFirstChild("HumanoidRootPart")
                    local th = p.Character:FindFirstChildOfClass("Humanoid")
                    valid = tr and th and th.MaxHealth > 0 and (th.Health / th.MaxHealth) > 0.25
                end
                if valid then target = p
                else SpearBtnData.ManualTarget = nil; Spear_UpdateTargetLabel() end
            end
            if not target then
                local closest, closestDist = nil, math.huge
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and TeamIs(player, "Survivor") and player.Character then
                        local tr = player.Character:FindFirstChild("HumanoidRootPart")
                        local th = player.Character:FindFirstChildOfClass("Humanoid")
                        if tr and th and th.MaxHealth > 0 and (th.Health / th.MaxHealth) > 0.25 then
                            local dist = (tr.Position - root.Position).Magnitude
                            if dist < closestDist then closestDist = dist; closest = player end
                        end
                    end
                end
                target = closest
            end
            if target and target.Character then
                local tr = target.Character:FindFirstChild("HumanoidRootPart")
                if tr then
                    local aimPos = SpearAimbotCalc(tr.Position)
                    if aimPos then
                        local cam = Workspace.CurrentCamera
                        if cam then cam.CFrame = CFrame.new(cam.CFrame.Position, aimPos) end
                    end
                end
            end
        end
        local function Spear_SetupButton()
            if SpearBtnData.UI then pcall(function() SpearBtnData.UI:Destroy() end) end
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if not pg then return end
            SpearBtnData.UI = Instance.new("ScreenGui")
            SpearBtnData.UI.Name = "GlutoSpearAimbotUI"
            SpearBtnData.UI.ResetOnSpawn = false
            SpearBtnData.UI.IgnoreGuiInset = true
            SpearBtnData.UI.Parent = pg
            SpearBtnData.Button = Instance.new("TextButton")
            SpearBtnData.Button.Name = "SpearAimbotButton"
            SpearBtnData.Button.Size = UDim2.new(0, 65, 0, 65)
            SpearBtnData.Button.Position = UDim2.new(0.15, 0, 0.75, 0)
            SpearBtnData.Button.AnchorPoint = Vector2.new(0.5, 0.5)
            SpearBtnData.Button.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
            SpearBtnData.Button.BackgroundTransparency = 0.15
            SpearBtnData.Button.Text = "SPEAR\nAIM"
            SpearBtnData.Button.TextColor3 = Color3.fromRGB(255, 100, 100)
            SpearBtnData.Button.TextSize = 11
            SpearBtnData.Button.Font = Enum.Font.GothamBold
            SpearBtnData.Button.Visible = false
            SpearBtnData.Button.ZIndex = 10
            SpearBtnData.Button.Parent = SpearBtnData.UI
            Instance.new("UICorner", SpearBtnData.Button).CornerRadius = UDim.new(1, 0)
            local spearStk = Instance.new("UIStroke", SpearBtnData.Button)
            spearStk.Color = Color3.fromRGB(255, 80, 80)
            spearStk.Thickness = 2
            spearStk.Transparency = 0.2
            local lockBtn = Instance.new("TextButton")
            lockBtn.Name = "LockDrag"
            lockBtn.Size = UDim2.new(0, 22, 0, 22)
            lockBtn.Position = UDim2.new(1, -5, 0, -5)
            lockBtn.AnchorPoint = Vector2.new(1, 0)
            lockBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            lockBtn.BackgroundTransparency = 0.3
            lockBtn.Text = "L"
            lockBtn.TextSize = 10
            lockBtn.Font = Enum.Font.GothamBold
            lockBtn.TextColor3 = Color3.new(1, 1, 1)
            lockBtn.ZIndex = 11
            lockBtn.Parent = SpearBtnData.Button
            Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(1, 0)
            lockBtn.MouseButton1Click:Connect(function()
                SpearBtnData.DragLocked = not SpearBtnData.DragLocked
                lockBtn.Text = SpearBtnData.DragLocked and "X" or "L"
                lockBtn.BackgroundColor3 = SpearBtnData.DragLocked and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(60, 60, 60)
            end)
            local targetLabel = Instance.new("TextLabel")
            targetLabel.Name = "SpearTargetLabel"
            targetLabel.Size = UDim2.new(0, 90, 0, 18)
            targetLabel.Position = UDim2.new(0.5, 0, 0, -22)
            targetLabel.AnchorPoint = Vector2.new(0.5, 0)
            targetLabel.BackgroundTransparency = 1
            targetLabel.Text = "AUTO"
            targetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            targetLabel.TextSize = 12
            targetLabel.Font = Enum.Font.GothamBold
            targetLabel.TextTruncate = Enum.TextTruncate.AtEnd
            targetLabel.ZIndex = 11
            targetLabel.Visible = false
            targetLabel.Parent = SpearBtnData.Button
            SpearBtnData.TargetLabel = targetLabel
            local leftArrow = Instance.new("TextButton")
            leftArrow.Name = "SpearTargetLeft"
            leftArrow.Size = UDim2.new(0, 28, 0, 28)
            leftArrow.Position = UDim2.new(0, -34, 0.5, 0)
            leftArrow.AnchorPoint = Vector2.new(0.5, 0.5)
            leftArrow.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
            leftArrow.BackgroundTransparency = 0.15
            leftArrow.Text = "<"
            leftArrow.TextColor3 = Color3.fromRGB(158, 158, 158)
            leftArrow.TextSize = 16
            leftArrow.Font = Enum.Font.GothamBold
            leftArrow.ZIndex = 10
            leftArrow.Parent = SpearBtnData.Button
            Instance.new("UICorner", leftArrow).CornerRadius = UDim.new(1, 0)
            local leftStk = Instance.new("UIStroke", leftArrow)
            leftStk.Color = Color3.fromRGB(255, 80, 80)
            leftStk.Thickness = 1.5
            leftStk.Transparency = 0.3
            SpearBtnData.LeftArrow = leftArrow
            leftArrow.MouseButton1Click:Connect(function() Spear_CycleTarget(-1) end)
            local rightArrow = Instance.new("TextButton")
            rightArrow.Name = "SpearTargetRight"
            rightArrow.Size = UDim2.new(0, 28, 0, 28)
            rightArrow.Position = UDim2.new(1, 34, 0.5, 0)
            rightArrow.AnchorPoint = Vector2.new(0.5, 0.5)
            rightArrow.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
            rightArrow.BackgroundTransparency = 0.15
            rightArrow.Text = ">"
            rightArrow.TextColor3 = Color3.fromRGB(255, 150, 150)
            rightArrow.TextSize = 16
            rightArrow.Font = Enum.Font.GothamBold
            rightArrow.ZIndex = 10
            rightArrow.Parent = SpearBtnData.Button
            Instance.new("UICorner", rightArrow).CornerRadius = UDim.new(1, 0)
            local rightStk = Instance.new("UIStroke", rightArrow)
            rightStk.Color = Color3.fromRGB(255, 80, 80)
            rightStk.Thickness = 1.5
            rightStk.Transparency = 0.3
            SpearBtnData.RightArrow = rightArrow
            rightArrow.MouseButton1Click:Connect(function() Spear_CycleTarget(1) end)
            SpearBtnData.Button.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if SpearBtnData.DragLocked then return end
                    SpearBtnData.Dragging = true
                    SpearBtnData.DragStart = input.Position
                    SpearBtnData.DragStartPos = SpearBtnData.Button.Position
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if SpearBtnData.Dragging and not SpearBtnData.DragLocked and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local delta = input.Position - SpearBtnData.DragStart
                    SpearBtnData.Button.Position = UDim2.new(
                        SpearBtnData.DragStartPos.X.Scale, SpearBtnData.DragStartPos.X.Offset + delta.X,
                        SpearBtnData.DragStartPos.Y.Scale, SpearBtnData.DragStartPos.Y.Offset + delta.Y
                    )
                end
            end)
            SpearBtnData.Button.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    SpearBtnData.Dragging = false
                end
            end)
            SpearBtnData.Button.MouseButton1Click:Connect(function()
                SpearBtnData.Active = not SpearBtnData.Active
                if SpearBtnData.Active then
                    SpearBtnData.Button.BackgroundColor3 = Color3.fromRGB(10, 40, 10)
                    SpearBtnData.Button.TextColor3 = Color3.fromRGB(80, 255, 120)
                    spearStk.Color = Color3.fromRGB(80, 255, 120)
                    VD_Notify("Spear Aimbot", "Spear Aimbot AKTIF!", 3)
                else
                    SpearBtnData.Button.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
                    SpearBtnData.Button.TextColor3 = Color3.fromRGB(255, 100, 100)
                    spearStk.Color = Color3.fromRGB(255, 80, 80)
                    VD_Notify("Spear Aimbot", "Spear Aimbot NONAKTIF", 3)
                end
            end)
        end
        Scheduler:Add("SpearAim", function()
            if not VD.SPEAR_Aimbot then
                if SpearBtnData.Button then SpearBtnData.Button.Visible = false end
                return
            end
            Spear_UpdateAim()
            if SpearBtnData.Button then
                local shouldShow = GetRole() == "Killer"
                SpearBtnData.Button.Visible = shouldShow
                if shouldShow then Spear_UpdateTargetLabel() end
            end
        end, 0.033)
        LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            if VD.SPEAR_Aimbot then pcall(Spear_SetupButton) end
        end)
        W.SpearAimbot_SetEnabled = function(v)
            VD.SPEAR_Aimbot = v and true or false
            if v then
                SpearBtnData.Active = true
                Spear_SetupButton()
            else
                if SpearBtnData.UI then pcall(function() SpearBtnData.UI:Destroy() end); SpearBtnData.UI = nil end
                SpearBtnData.Button = nil
            end
        end
        W.SpearAimbot_SetGravity = function(v) VD.SPEAR_Gravity = tonumber(v) or 50 end
        W.SpearAimbot_SetSpeed   = function(v) VD.SPEAR_Speed   = tonumber(v) or 100 end
        W.SpearAimbot_CycleTarget = Spear_CycleTarget
    end

 --====================================================--
-- DASH LOCK v4 (Skip Down/Hooked)
--====================================================--
do
    VD.DashLockEnabled       = VD.DashLockEnabled      or false
    VD.DashLockDuration      = VD.DashLockDuration     or 1.5
    VD.DashLockSmoothness    = VD.DashLockSmoothness   or 0.3
    VD.FreezeDuringDashLock  = VD.FreezeDuringDashLock or false
    VD._DashLockActive       = false
    VD._DashLockTarget       = nil
    VD._DashLockConnection   = nil

    local DashAnimationId = "rbxassetid://98163597193511"

    -- Filter: skip survivor yang lagi down / knocked / hooked / carried
    local function IsDownOrHooked(char, hum)
        if not char or not hum then return true end
        if hum.Health <= 0 then return true end
        if hum.Health < 2 then return true end

        -- Attribute check
        if char:GetAttribute("Downed") == true then return true end
        if char:GetAttribute("IsDown") == true then return true end
        if char:GetAttribute("Knocked") == true then return true end
        if char:GetAttribute("IsKnocked") == true then return true end
        if char:GetAttribute("IsHooked") == true then return true end
        if char:GetAttribute("isHooked") == true then return true end
        if char:GetAttribute("Hooked") == true then return true end
        if char:GetAttribute("HookedState") == true then return true end
        if char:GetAttribute("IsCarried") == true then return true end
        if char:GetAttribute("isCarried") == true then return true end
        if char:GetAttribute("Carried") == true then return true end
        if char:GetAttribute("HookProgressDepleting") == true then return true end
        if char:GetAttribute("Grabbed") == true then return true end
        if char:GetAttribute("Ragdolled") == true then return true end
        if char:GetAttribute("Captured") == true then return true end

        -- State attribute check
        local state = char:GetAttribute("State")
        if state == "Downed" or state == "Dead"
           or state == "Hooked" or state == "Carried" then
            return true
        end

        -- CheckInterractable check
        local ci = char:FindFirstChild("CheckInterractable")
        if ci then
            if ci:GetAttribute("isDowned") == true then return true end
            if ci:GetAttribute("isHooked") == true then return true end
            if ci:GetAttribute("isCarried") == true then return true end
            if ci:GetAttribute("Downed") == true then return true end
            if ci:GetAttribute("Hooked") == true then return true end
            if ci:GetAttribute("Carried") == true then return true end
        end

        return false
    end

    -- Pick target: survivor terdekat yang TIDAK down/hooked
    local function DashLock_PickTarget(myRoot)
        local target = nil
        local targetDist = math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Team and player.Team.Name == "Survivors" then
                local char = player.Character
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if root and hum and hum.Health > 0 and not IsDownOrHooked(char, hum) then
                        local dist = (myRoot.Position - root.Position).Magnitude
                        if dist < targetDist then
                            targetDist = dist
                            target = root
                        end
                    end
                end
            end
        end
        return target
    end

    local function MAWWW_DashLockUpdate()
        -- Kalau toggle off → bersihin state
        if not VD.DashLockEnabled then
            if VD._DashLockActive then
                VD._DashLockActive = false
                VD._DashLockTarget = nil
                if VD.FreezeDuringDashLock then
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.WalkSpeed == 0 then
                        hum.WalkSpeed = 16
                    end
                end
            end
            return
        end

        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then
            VD._DashLockTarget = nil
            return
        end

        -- Cari target valid (skip down/hooked)
        local target = DashLock_PickTarget(myRoot)

        if not target then
            VD._DashLockTarget = nil
            -- Lepas freeze kalau gak ada target
            if VD.FreezeDuringDashLock then
                local hum = myChar:FindFirstChildOfClass("Humanoid")
                if hum and hum.WalkSpeed == 0 then
                    hum.WalkSpeed = 16
                end
            end
            return
        end

        VD._DashLockTarget = target

        local cam = Workspace.CurrentCamera
        if cam then
            local smoothFactor = VD.DashLockSmoothness or 0.3
            local targetPos = target.Position
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, targetPos), smoothFactor)

            if VD.FreezeDuringDashLock then
                local hum = myChar:FindFirstChildOfClass("Humanoid")
                if hum and hum.WalkSpeed ~= 0 then
                    hum.WalkSpeed = 0
                end
            end
        end
    end

    function W.MAWWW_SetDashLockActive(active)
        if active == VD._DashLockActive then return end
        VD._DashLockActive = active

        if active then
            if not VD._DashLockConnection then
                VD._DashLockConnection = RunService.RenderStepped:Connect(MAWWW_DashLockUpdate)
            end
            if VD.FreezeDuringDashLock then
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum and hum.WalkSpeed == 0 then
                    hum.WalkSpeed = 16
                end
            end
        else
            if VD._DashLockConnection then
                VD._DashLockConnection:Disconnect()
                VD._DashLockConnection = nil
            end
            if VD.FreezeDuringDashLock then
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum and hum.WalkSpeed == 0 then
                    hum.WalkSpeed = 16
                end
            end
            VD._DashLockTarget = nil
        end
    end

    local function HookDashDetection(char)
        if not char then return end
        local humanoid = char:WaitForChild("Humanoid", 5)
        if humanoid then
            local animator = humanoid:FindFirstChildOfClass("Animator")
            if not animator then
                animator = humanoid:WaitForChild("Animator", 5)
            end
            if animator then
                animator.AnimationPlayed:Connect(function(animationTrack)
                    if animationTrack.Animation and animationTrack.Animation.AnimationId == DashAnimationId then
                        if VD.DashLockEnabled then
                            W.MAWWW_SetDashLockActive(true)
                            task.delay(VD.DashLockDuration or 1.5, function()
                                W.MAWWW_SetDashLockActive(false)
                            end)
                        end
                    end
                end)
            end
        end
    end

    if LocalPlayer.Character then
        HookDashDetection(LocalPlayer.Character)
    end
    LocalPlayer.CharacterAdded:Connect(function(c)
        task.wait(0.5)
        HookDashDetection(c)
    end)

    W.DashLock_SetEnabled = function(v)
        VD.DashLockEnabled = v and true or false
        if not v then
            if W.MAWWW_SetDashLockActive then W.MAWWW_SetDashLockActive(false) end
        end
    end
end
    --====================================================--
    -- SWIFT VAULT (FULL)
    --====================================================--
    do
        VD.SURV_AutoVault  = VD.SURV_AutoVault  or false
        VD.SURV_FastVault  = VD.SURV_FastVault  or false
        VD.SURF_VaultSpeed = VD.SURF_VaultSpeed or 13
        local _vaultedWindows = {}
        local _lastVaultScan  = 0
        local function SwiftVault_BuildWindowGroups()
            local groups = {}
            local map = Workspace:FindFirstChild("Map")
            if not map then return groups end
            local seen = {}
            local function addPart(part)
                if not part or seen[part] then return end
                seen[part] = true
                local rootWindow = part.Parent
                if part.Name == "VaultPoint" and part.Parent and part.Parent.Name == "VaultTrigger" then
                    rootWindow = part.Parent.Parent
                elseif part.Name == "VaultTrigger" then
                    rootWindow = part.Parent
                end
                if rootWindow then
                    groups[rootWindow] = groups[rootWindow] or {}
                    local exists = false
                    for _, p in ipairs(groups[rootWindow]) do
                        if p == part then exists = true; break end
                    end
                    if not exists then table.insert(groups[rootWindow], part) end
                end
            end
            for _, obj in ipairs(map:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name == "VaultTrigger" or obj.Name == "VaultPoint") then
                    addPart(obj)
                end
            end
            return groups
        end
        local function SwiftVault_GetVTPosition(vt)
            if not vt then return nil end
            if vt:IsA("BasePart") then return vt.Position end
            if vt:IsA("Model") then
                if vt.PrimaryPart then return vt.PrimaryPart.Position end
                local bp = vt:FindFirstChildWhichIsA("BasePart", true)
                if bp then return bp.Position end
            end
            return nil
        end
        Scheduler:Add("FastVault", function()
            if not VD.SURV_FastVault then return end
            local char = LocalPlayer.Character
            if char then
                pcall(function() char:SetAttribute("vaultspeed", (VD.SURF_VaultSpeed or 13) / 10) end)
            end
        end, 0.2)
        Scheduler:Add("AutoVault", function()
            if not VD.SURV_AutoVault then return end
            if GetRole() ~= "Survivor" then return end
            if tick() - _lastVaultScan < 0.15 then return end
            _lastVaultScan = tick()
            pcall(function()
                local char   = LocalPlayer.Character
                local myRoot = char and char:FindFirstChild("HumanoidRootPart")
                local hum    = char and char:FindFirstChildOfClass("Humanoid")
                if not myRoot or not hum or hum.Health <= 0 then return end
                local vel = myRoot.AssemblyLinearVelocity
                if vel.Magnitude < 1 then return end
                local remotes   = ReplicatedStorage:FindFirstChild("Remotes")
                local winFolder = remotes and remotes:FindFirstChild("Window")
                local vaultEv   = winFolder and winFolder:FindFirstChild("VaultCommit")
                if not vaultEv then return end
                local windowGroups = SwiftVault_BuildWindowGroups()
                for rootWindow, parts in pairs(windowGroups) do
                    local allVTs = {}
                    for _, child in ipairs(rootWindow:GetChildren()) do
                        if child.Name == "VaultTrigger" then table.insert(allVTs, child) end
                    end
                    if #allVTs == 0 then continue end
                    local nearestVT, nearestVTDist = nil, math.huge
                    for _, vt in ipairs(allVTs) do
                        local pos = SwiftVault_GetVTPosition(vt)
                        if pos then
                            local d = (myRoot.Position - pos).Magnitude
                            if d < nearestVTDist then nearestVTDist = d; nearestVT = vt end
                        end
                    end
                    if not nearestVT or nearestVTDist > 6.0 then continue end
                    local lastUsed = _vaultedWindows[rootWindow] or 0
                    if tick() - lastUsed < 3.0 then continue end
                    local finalTarget = nearestVT
                    local winFold  = remotes:FindFirstChild("Window")
                    if winFold and finalTarget then
                        local vaultEvent     = winFold:FindFirstChild("VaultEvent")
                        local vaultBindable  = winFold:FindFirstChild("Vaultbindable")
                        local fastvault      = winFold:FindFirstChild("fastvault")
                        local vaultComplete1 = winFold:FindFirstChild("VaultCompleteEventpart1")
                        local vaultComplete  = winFold:FindFirstChild("VaultCompleteEvent")
                        if vaultEvent    then pcall(function() vaultEvent:FireServer(finalTarget, true) end) end
                        if vaultBindable then pcall(function() vaultBindable:Fire(finalTarget, true) end) end
                        if fastvault     then pcall(function() fastvault:FireServer(LocalPlayer) end) end
                        if vaultComplete1 then pcall(function() vaultComplete1:FireServer() end) end
                        if vaultComplete  then pcall(function() vaultComplete:FireServer(finalTarget, false) end) end
                    end
                    _vaultedWindows[rootWindow] = tick()
                    break
                end
            end)
        end, 0.1)
        LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5); _vaultedWindows = {} end)
        W.SwiftVault_SetEnabled = function(v) VD.SURV_AutoVault = v and true or false; _vaultedWindows = {} end
        W.SwiftVaultV2_SetEnabled = function(v)
            VD.SURV_FastVault = v and true or false
            if not v then
                local char = LocalPlayer.Character
                if char then pcall(function() char:SetAttribute("vaultspeed", 1) end) end
            end
        end
        W.SwiftVault_SetSpeed = function(v) VD.SURF_VaultSpeed = tonumber(v) or 13 end
    end

    --====================================================--
    -- GRAPHICS SYSTEM v2 (FULL with Potato Mode)
    --====================================================--
    do
        local Lighting    = game:GetService("Lighting")
        local WorkspaceSvc = Workspace
        W.Graphics = W.Graphics or {
            Fullbright = false, NoShadow = false, LowGraphics = false,
            NoScreenEffects = false, CleanSky = false,
            ClockTimeEnabled = false, ClockTime = 14, Brightness = 2,
            UnlimitedZoom = false, MaxZoomDistance = 1000,
            FOVEnabled = false, FOV = 70, PotatoEnabled = false,
        }
        local G = W.Graphics
        local original = {
            Brightness     = Lighting.Brightness,
            ClockTime      = Lighting.ClockTime,
            Ambient        = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            GlobalShadows  = Lighting.GlobalShadows,
            FOV            = WorkspaceSvc.CurrentCamera and WorkspaceSvc.CurrentCamera.FieldOfView or 70,
        }
        local LastState = { Fullbright = nil, NoShadow = nil, Ambient = nil, Brightness = nil, ClockTime = nil }
        local LastOptimize = { LowGraphics = nil, CleanSky = nil }
        local DisabledEffects = {}
        local ScreenEffectTypes = {
            "ColorCorrectionEffect", "DepthOfFieldEffect",
            "BlurEffect", "SunRaysEffect", "BloomEffect",
        }
        local function Graphics_Apply(force)
            if force or LastState.Fullbright ~= G.Fullbright then
                LastState.Fullbright = G.Fullbright
                if G.Fullbright then
                    Lighting.Brightness     = 2
                    Lighting.ClockTime      = 14
                    Lighting.Ambient        = Color3.fromRGB(255, 255, 255)
                    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
                else
                    Lighting.Brightness     = original.Brightness
                    Lighting.ClockTime      = original.ClockTime
                    Lighting.Ambient        = original.Ambient
                    Lighting.OutdoorAmbient = original.OutdoorAmbient
                end
            end
            if force or LastState.NoShadow ~= G.NoShadow then
                LastState.NoShadow = G.NoShadow
                Lighting.GlobalShadows = not G.NoShadow
            end
            local ambientChanged =
                LastState.Ambient    ~= G.ClockTimeEnabled or
                LastState.Brightness ~= G.Brightness or
                LastState.ClockTime  ~= G.ClockTime
            if force or ambientChanged then
                LastState.Ambient    = G.ClockTimeEnabled
                LastState.Brightness = G.Brightness
                LastState.ClockTime  = G.ClockTime
                if G.ClockTimeEnabled then
                    Lighting.ClockTime  = G.ClockTime
                    Lighting.Brightness = G.Brightness
                elseif not G.Fullbright then
                    Lighting.Brightness = original.Brightness
                    Lighting.ClockTime  = original.ClockTime
                end
            end
        end
        local function Graphics_ApplyOptimization(force)
            if force or LastOptimize.LowGraphics ~= G.LowGraphics then
                LastOptimize.LowGraphics = G.LowGraphics
                pcall(function()
                    if G.LowGraphics then settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                    else settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end
                end)
            end
            if force or LastOptimize.CleanSky ~= G.CleanSky then
                LastOptimize.CleanSky = G.CleanSky
                if G.CleanSky then
                    for _, v in ipairs(Lighting:GetChildren()) do
                        if v:IsA("Sky") then v:Destroy() end
                    end
                end
            end
        end
        local function Graphics_ApplyNoScreenEffects()
            if G.NoScreenEffects then
                for _, v in pairs(Lighting:GetChildren()) do
                    for _, t in ipairs(ScreenEffectTypes) do
                        if v:IsA(t) then
                            if DisabledEffects[v] == nil then DisabledEffects[v] = v.Enabled end
                            v.Enabled = false
                        end
                    end
                end
            else
                for obj, state in pairs(DisabledEffects) do
                    if obj and obj.Parent then obj.Enabled = state end
                end
                DisabledEffects = {}
            end
        end
        Lighting.ChildAdded:Connect(function(v)
            if not G.NoScreenEffects then return end
            task.wait()
            for _, t in ipairs(ScreenEffectTypes) do
                if v:IsA(t) then
                    if DisabledEffects[v] == nil then DisabledEffects[v] = v.Enabled end
                    v.Enabled = false
                end
            end
        end)
        local function Graphics_ApplyZoom()
            if G.UnlimitedZoom then
                LocalPlayer.CameraMaxZoomDistance = G.MaxZoomDistance
                LocalPlayer.CameraMinZoomDistance = 0
            else
                LocalPlayer.CameraMaxZoomDistance = 128
                LocalPlayer.CameraMinZoomDistance = 0.5
            end
        end
        local function Graphics_ApplyFOV()
            local cam = WorkspaceSvc.CurrentCamera
            if not cam then return end
            if G.FOVEnabled then cam.FieldOfView = G.FOV
            else cam.FieldOfView = original.FOV end
        end

        -- POTATO MODE
        local Potato_Enabled     = false
        local Potato_Busy        = false
        local Potato_Changed     = {}
        local Potato_Connections = {}
        local POTATO_BATCH_SIZE  = 40
        local POTATO_BATCH_DELAY = 1
        local function Potato_Save(obj, prop)
            if not Potato_Changed[obj] then Potato_Changed[obj] = {} end
            if Potato_Changed[obj][prop] == nil then
                local ok, val = pcall(function() return obj[prop] end)
                if ok then Potato_Changed[obj][prop] = val end
            end
        end
        local function Potato_Set(obj, prop, value)
            if not obj or not obj.Parent then return end
            Potato_Save(obj, prop)
            pcall(function() obj[prop] = value end)
        end
        local function Potato_Optimize(obj)
            if not Potato_Enabled or not obj then return end
            if obj:IsA("BasePart") then
                Potato_Set(obj, "CastShadow", false)
                Potato_Set(obj, "Reflectance", 0)
                pcall(function() Potato_Set(obj, "Material", Enum.Material.Plastic) end)
            end
            if obj:IsA("MeshPart") then
                pcall(function() Potato_Set(obj, "RenderFidelity", Enum.RenderFidelity.Performance) end)
            end
            if obj:IsA("Texture") or obj:IsA("Decal") then
                Potato_Set(obj, "Transparency", 1)
            end
            if obj:IsA("SurfaceAppearance") then
                pcall(function()
                    Potato_Set(obj, "ColorMap", "")
                    Potato_Set(obj, "MetalnessMap", "")
                    Potato_Set(obj, "NormalMap", "")
                    Potato_Set(obj, "RoughnessMap", "")
                end)
            end
            if obj:IsA("ParticleEmitter") then Potato_Set(obj, "Enabled", false) end
            if obj:IsA("Trail")          then Potato_Set(obj, "Enabled", false) end
            if obj:IsA("Beam")           then Potato_Set(obj, "Enabled", false) end
            if obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                Potato_Set(obj, "Enabled", false)
            end
            if obj:IsA("Clouds") then
                Potato_Set(obj, "Cover", 0)
                Potato_Set(obj, "Density", 0)
            end
        end
        local function Potato_LowLighting()
            Potato_Set(Lighting, "GlobalShadows", false)
            Potato_Set(Lighting, "Brightness", 1)
            pcall(function()
                Potato_Set(Lighting, "EnvironmentDiffuseScale", 0)
                Potato_Set(Lighting, "EnvironmentSpecularScale", 0)
            end)
        end
        local function Potato_LowTerrain()
            local Terrain = WorkspaceSvc:FindFirstChildOfClass("Terrain")
            if not Terrain then return end
            Potato_Set(Terrain, "Decoration", false)
            Potato_Set(Terrain, "WaterWaveSize", 0)
            Potato_Set(Terrain, "WaterWaveSpeed", 0)
            Potato_Set(Terrain, "WaterReflectance", 0)
        end
        local function Potato_ProcessMap()
            if Potato_Busy then return end
            Potato_Busy = true
            local objects = WorkspaceSvc:GetDescendants()
            local total = #objects
            local index = 1
            while Potato_Enabled and index <= total do
                local finish = math.min(index + POTATO_BATCH_SIZE - 1, total)
                for i = index, finish do
                    if not Potato_Enabled then break end
                    Potato_Optimize(objects[i])
                end
                RunService.Heartbeat:Wait()
                if index % (POTATO_BATCH_SIZE * 5) == 1 then
                    task.wait(POTATO_BATCH_DELAY / 10)
                end
                index = finish + 1
            end
            Potato_Busy = false
        end
        local function Potato_StartNewObjectHandler()
            if Potato_Connections.NewObject then return end
            Potato_Connections.NewObject = WorkspaceSvc.DescendantAdded:Connect(function(obj)
                if not Potato_Enabled then return end
                task.defer(function()
                    if Potato_Enabled then Potato_Optimize(obj) end
                end)
            end)
        end
        local function Potato_Enable()
            if Potato_Enabled then return end
            Potato_Enabled = true
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
            Potato_LowLighting()
            Potato_LowTerrain()
            Potato_StartNewObjectHandler()
            task.spawn(Potato_ProcessMap)
        end
        local function Potato_Disable()
            if not Potato_Enabled then return end
            Potato_Enabled = false
            for name, conn in pairs(Potato_Connections) do
                pcall(function() conn:Disconnect() end)
                Potato_Connections[name] = nil
            end
            task.spawn(function()
                local count = 0
                for obj, properties in pairs(Potato_Changed) do
                    if obj and obj.Parent then
                        for prop, value in pairs(properties) do
                            pcall(function() obj[prop] = value end)
                            count = count + 1
                            if count >= POTATO_BATCH_SIZE then
                                task.wait()
                                count = 0
                            end
                        end
                    end
                end
                Potato_Changed = {}
            end)
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
        end

        RunService.RenderStepped:Connect(function()
            if G.FOVEnabled then
                local cam = WorkspaceSvc.CurrentCamera
                if cam and cam.FieldOfView ~= G.FOV then cam.FieldOfView = G.FOV end
            end
        end)
        RunService.RenderStepped:Connect(function()
            if not G.UnlimitedZoom then return end
            if LocalPlayer.CameraMaxZoomDistance ~= G.MaxZoomDistance then
                LocalPlayer.CameraMaxZoomDistance = G.MaxZoomDistance
            end
            if LocalPlayer.CameraMinZoomDistance ~= 0 then
                LocalPlayer.CameraMinZoomDistance = 0
            end
        end)

        W.Graphics_Apply             = Graphics_Apply
        W.Graphics_ApplyOptimization = Graphics_ApplyOptimization
        W.Graphics_ApplyNoScreenFx   = Graphics_ApplyNoScreenEffects
        W.Graphics_ApplyZoom         = Graphics_ApplyZoom
        W.Graphics_ApplyFOV          = Graphics_ApplyFOV
        W.Potato_SetEnabled = function(v)
            G.PotatoEnabled = v and true or false
            if G.PotatoEnabled then Potato_Enable() else Potato_Disable() end
        end
        W.Potato_IsEnabled = function() return Potato_Enabled end

        LocalPlayer.CharacterAdded:Connect(function()
            task.wait(1)
            Graphics_Apply(true)
            Graphics_ApplyOptimization(true)
            Graphics_ApplyNoScreenEffects()
            Graphics_ApplyZoom()
            Graphics_ApplyFOV()
        end)
    end

    --====================================================--
    -- PALLET REFLEX (FULL)
    --====================================================--
    do
        VD.SURV_AutoPallet     = VD.SURV_AutoPallet     or false
        VD.SURV_AutoPalletDist = VD.SURV_AutoPalletDist or 20
        local _lastPalletDrop = 0
        local _usedPallets    = {}
        local function Pallet_GetKillerRoot()
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and TeamIs(plr, "Killer") and plr.Character then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then return hrp end
                end
            end
            return nil
        end
        local function Pallet_GetAllPallets()
            local list = {}
            local map = Workspace:FindFirstChild("Map")
            if not map then return list end
            for _, obj in ipairs(map:GetDescendants()) do
                if obj.Name == "Palletwrong" and (obj:IsA("Model") or obj:IsA("Folder")) then
                    table.insert(list, obj)
                end
            end
            return list
        end
        local function Pallet_IsDropped(palletModel)
            if not palletModel or not palletModel.Parent then return true end
            if _usedPallets[palletModel] then return true end
            local ok, destroyed = pcall(function() return palletModel:GetAttribute("Destroyed") end)
            if ok and destroyed == true then return true end
            local ok2, broken = pcall(function() return palletModel:GetAttribute("Broken") end)
            if ok2 and broken == true then return true end
            if not palletModel:FindFirstChildWhichIsA("BasePart", true) then return true end
            return false
        end
        local function Pallet_GetPointSlide(model)
            local slide = model:FindFirstChild("PalletPointSlide")
            if slide then return slide end
            for _, child in ipairs(model:GetDescendants()) do
                if child.Name == "PalletPointSlide" then return child end
            end
            return model:FindFirstChild("PalletPoint")
        end
        Scheduler:Add("PalletReflex", function()
            if not VD.SURV_AutoPallet then return end
            if GetRole() ~= "Survivor" then return end
            local now = tick()
            if now - _lastPalletDrop < 2.5 then return end
            pcall(function()
                local char   = LocalPlayer.Character
                local myRoot = char and char:FindFirstChild("HumanoidRootPart")
                local hum    = char and char:FindFirstChildOfClass("Humanoid")
                if not myRoot or not hum or hum.Health <= 0 then return end
                local killerRoot = Pallet_GetKillerRoot()
                if not killerRoot then return end
                if (myRoot.Position - killerRoot.Position).Magnitude > (VD.SURV_AutoPalletDist or 20) then return end
                local remotes    = ReplicatedStorage:FindFirstChild("Remotes")
                local palletFold = remotes and remotes:FindFirstChild("Pallet")
                local dropEvent  = palletFold and palletFold:FindFirstChild("PalletDropEvent")
                if not dropEvent then return end
                local bestPallet, bestDist = nil, 8
                for _, pal in ipairs(Pallet_GetAllPallets()) do
                    if not Pallet_IsDropped(pal) then
                        local refPart = pal:FindFirstChild("PalletPoint")
                            or pal:FindFirstChild("PalletPointSlide")
                            or pal:FindFirstChildWhichIsA("BasePart", true)
                        if refPart then
                            local d = (myRoot.Position - refPart.Position).Magnitude
                            if d < bestDist then bestDist = d; bestPallet = pal end
                        end
                    end
                end
                if bestPallet then
                    local fireTarget = Pallet_GetPointSlide(bestPallet)
                    if fireTarget then
                        pcall(function() dropEvent:FireServer(fireTarget) end)
                        _usedPallets[bestPallet] = true
                        _lastPalletDrop = tick()
                    end
                end
            end)
        end, 0.2)
        LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5); _usedPallets = {} end)
        W.PalletReflex_SetEnabled = function(v) VD.SURV_AutoPallet = v and true or false; _usedPallets = {} end
        W.PalletReflex_SetDistance = function(v) VD.SURV_AutoPalletDist = tonumber(v) or 20 end
    end

--====================================================--
-- SHOW HOOK COUNTER (KILLER)
--====================================================--
do
    VD.HookCounter_Enabled = VD.HookCounter_Enabled or false

    local function HookCounter_Update()
        if not VD.HookCounter_Enabled then return end
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return end

        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name:match("%-mob$") then
                local frame = gui:FindFirstChild("Frame")
                if frame then
                    for i = 1, 5 do
                        local survivorFrame = frame:FindFirstChild("Survivor" .. i)
                        local imageLabel = survivorFrame and survivorFrame:FindFirstChild("ImageLabel")
                        local textLabel = survivorFrame and survivorFrame:FindFirstChild("TextLabel")

                        if imageLabel and textLabel then
                            local counter = imageLabel:FindFirstChild("Counter")
                            if counter then
                                pcall(function()
                                    if counter.Visible ~= VD.HookCounter_Enabled then
                                        counter.Visible = VD.HookCounter_Enabled
                                    end
                                end)
                            end

                            local labelName = "Gluto_CustomHookCounter"
                            local customLabel = imageLabel:FindFirstChild(labelName)

                            if VD.HookCounter_Enabled then
                                local playerName = textLabel.Text
                                local player = nil
                                for _, p in ipairs(Players:GetPlayers()) do
                                    if p.Name == playerName or p.DisplayName == playerName then
                                        player = p
                                        break
                                    end
                                end

                                local hookCount = 0
                                if player then
                                    hookCount = player:GetAttribute("HookCount")
                                        or (player.Character and player.Character:GetAttribute("HookCount"))
                                        or 0
                                end

                                if not customLabel then
                                    customLabel = Instance.new("TextLabel")
                                    customLabel.Name = labelName
                                    customLabel.Size = UDim2.new(1, 0, 0.35, 0)
                                    customLabel.Position = UDim2.new(0, 0, 0.65, 0)
                                    customLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                                    customLabel.BackgroundTransparency = 0.5
                                    customLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                                    customLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                                    customLabel.TextStrokeTransparency = 0
                                    customLabel.TextScaled = true
                                    customLabel.Font = Enum.Font.SourceSansBold
                                    customLabel.ZIndex = 5
                                    customLabel.Parent = imageLabel
                                end

                                customLabel.Visible = true
                                if hookCount >= 3 then
                                    customLabel.Text = "DEAD"
                                    customLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
                                elseif hookCount == 2 then
                                    customLabel.Text = "Hooks: 2"
                                    customLabel.TextColor3 = Color3.fromRGB(255, 140, 0)
                                elseif hookCount == 1 then
                                    customLabel.Text = "Hooks: 1"
                                    customLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
                                else
                                    customLabel.Text = "Hooks: 0"
                                    customLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                                end
                            else
                                if customLabel then
                                    customLabel.Visible = false
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    local function HookCounter_Cleanup()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return end
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name:match("%-mob$") then
                local frame = gui:FindFirstChild("Frame")
                if frame then
                    for i = 1, 5 do
                        local survivorFrame = frame:FindFirstChild("Survivor" .. i)
                        local imageLabel = survivorFrame and survivorFrame:FindFirstChild("ImageLabel")
                        if imageLabel then
                            local customLabel = imageLabel:FindFirstChild("Gluto_CustomHookCounter")
                            if customLabel then
                                pcall(function() customLabel:Destroy() end)
                            end
                            local counter = imageLabel:FindFirstChild("Counter")
                            if counter then
                                pcall(function() counter.Visible = false end)
                            end
                        end
                    end
                end
            end
        end
    end

    Scheduler:Add("HookCounter", HookCounter_Update, 0.15)

    W.HookCounter_SetEnabled = function(v)
        VD.HookCounter_Enabled = v and true or false
        if v then
            task.spawn(function() pcall(HookCounter_Update) end)
        else
            task.spawn(function() pcall(HookCounter_Cleanup) end)
        end
    end
end



--====================================================--
-- AUTO DODGE SPEAR (SURVIVOR)
--====================================================--
do
    VD.SURV_AutoDodgeSpear = VD.SURV_AutoDodgeSpear or false

    local _lastDodge = 0
    local _dodging   = false

    local function AutoDodge_GetSpearPart(obj)
        if not obj then return nil end
        local part = obj:FindFirstChild("Hitbox")
            or obj:FindFirstChild("Spear1")
            or obj:FindFirstChild("Head")
            or obj:FindFirstChild("HitboxPart")
            or obj.PrimaryPart
        if part and part:IsA("BasePart") then return part end
        return obj:FindFirstChildWhichIsA("BasePart", true)
    end

    local function AutoDodge_HandleSpear(obj)
        if not VD.SURV_AutoDodgeSpear then return end
        if GetRole() ~= "Survivor" then return end
        if _dodging then return end
        if tick() - _lastDodge < 0.4 then return end
        if not obj or not obj.Parent then return end

        task.wait(0.04)
        if not obj.Parent then return end

        local mainPart = AutoDodge_GetSpearPart(obj)
        if not mainPart or not mainPart.Parent then return end

        task.wait()
        if not mainPart.Parent or not VD.SURV_AutoDodgeSpear then return end

        local char = LocalPlayer.Character
        local myRoot = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not myRoot or not hum or hum.Health <= 0 then return end

        local originPos = mainPart.Position
        local spearDir = mainPart.CFrame.UpVector
        local toPlayer = myRoot.Position - originPos
        local dist = toPlayer.Magnitude
        if dist < 1 or dist < 4 then return end

        local dot = spearDir:Dot(toPlayer.Unit)
        if dot < 0.75 then return end

        _dodging = true
        _lastDodge = tick()

        local spearDirFlat = Vector3.new(spearDir.X, 0, spearDir.Z)
        if spearDirFlat.Magnitude < 0.01 then spearDirFlat = Vector3.new(1, 0, 0) end
        spearDirFlat = spearDirFlat.Unit

        local perpDir = Vector3.new(-spearDirFlat.Z, 0, spearDirFlat.X)
        if math.random() > 0.5 then perpDir = -perpDir end

        local originalCF = myRoot.CFrame
        local dodgePos = myRoot.Position + perpDir * 15

        pcall(function()
            myRoot.Velocity = Vector3.zero
            myRoot.CFrame = CFrame.new(dodgePos, dodgePos + myRoot.CFrame.LookVector)
        end)

        VD_Notify("Auto Dodge Spear", "Dodged! (dist " .. math.floor(dist) .. " studs)", 1.5)

        task.wait(0.8)

        local c2 = LocalPlayer.Character
        local r2 = c2 and c2:FindFirstChild("HumanoidRootPart")
        if r2 and r2.Parent then
            pcall(function()
                r2.Velocity = Vector3.zero
                r2.CFrame = originalCF
            end)
        end

        _dodging = false
    end

    Workspace.ChildAdded:Connect(function(obj)
        if not VD.SURV_AutoDodgeSpear then return end
        if GetRole() ~= "Survivor" then return end
        if not obj or not obj:IsA("Model") and not obj:IsA("BasePart") then return end
        local lower = string.lower(obj.Name)
        if string.find(lower, "spear", 1, true)
           or string.find(lower, "projectile", 1, true) then
            task.spawn(function() pcall(AutoDodge_HandleSpear, obj) end)
        end
    end)

    W.AutoDodgeSpear_SetEnabled = function(v)
        VD.SURV_AutoDodgeSpear = v and true or false
        _dodging = false
    end
end


--====================================================--
-- INFINITE LUNGE (KILLER)
--====================================================--
do
    VD.KILLER_InfLunge = VD.KILLER_InfLunge or false
    VD._OriginalLungeBoost = nil

    Scheduler:Add("InfLunge", function()
        if GetRole() ~= "Killer" then return end
        local char = LocalPlayer.Character
        if not char then return end

        if VD.KILLER_InfLunge then
            local curr = char:GetAttribute("lungeboost")
            if curr ~= 999999 then
                if VD._OriginalLungeBoost == nil then
                    VD._OriginalLungeBoost = curr or 1
                end
                pcall(function() char:SetAttribute("lungeboost", 999999) end)
            end
        else
            if VD._OriginalLungeBoost ~= nil then
                pcall(function() char:SetAttribute("lungeboost", VD._OriginalLungeBoost) end)
                VD._OriginalLungeBoost = nil
            end
        end
    end, 0.15)

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        VD._OriginalLungeBoost = nil
        if VD.KILLER_InfLunge then
            local char = LocalPlayer.Character
            if char then
                task.wait(0.2)
                pcall(function() char:SetAttribute("lungeboost", 999999) end)
            end
        end
    end)

    W.InfLunge_SetEnabled = function(v)
        VD.KILLER_InfLunge = v and true or false
        if not v and VD._OriginalLungeBoost ~= nil then
            local char = LocalPlayer.Character
            if char then
                pcall(function() char:SetAttribute("lungeboost", VD._OriginalLungeBoost) end)
            end
            VD._OriginalLungeBoost = nil
        end
    end
end

--====================================================--
-- COUNTER PARRY / FAKE ATTACK (KILLER)
--====================================================--
do
    VD.KILLER_FakeAttack = VD.KILLER_FakeAttack or false

    local _lastFakeAttack = 0
    local _FAKE_RANGE     = 15
    local _FAKE_COOLDOWN  = 0.35
    local BAIT_ANIM_ID    = "rbxassetid://117042998468241"

    local function FakeAttack_CheckNear()
        local char = LocalPlayer.Character
        if not char then return false end
        local myRoot = char:FindFirstChild("HumanoidRootPart")
        if not myRoot then return false end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and TeamIs(p, "Survivor") and p.Character then
                local r = p.Character:FindFirstChild("HumanoidRootPart")
                local h = p.Character:FindFirstChildOfClass("Humanoid")
                if r and h and h.Health > 0 then
                    if (myRoot.Position - r.Position).Magnitude <= _FAKE_RANGE then
                        return true
                    end
                end
            end
        end
        return false
    end

    local function FakeAttack_PlayBait()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local animator = hum:FindFirstChildOfClass("Animator")
        if not animator then return end
        pcall(function()
            local bait = Instance.new("Animation")
            bait.AnimationId = BAIT_ANIM_ID
            local track = animator:LoadAnimation(bait)
            track.Priority = Enum.AnimationPriority.Action
            track:Play()
            track:AdjustWeight(0)
            task.delay(0.05, function()
                pcall(function() track:Stop(0) end)
            end)
        end)
    end

    Scheduler:Add("FakeAttack", function()
        if not VD.KILLER_FakeAttack then return end
        if GetRole() ~= "Killer" then return end
        local now = tick()
        if now - _lastFakeAttack < _FAKE_COOLDOWN then return end
        if not FakeAttack_CheckNear() then return end
        _lastFakeAttack = now
        FakeAttack_PlayBait()
    end, 0.1)

    LocalPlayer.CharacterAdded:Connect(function()
        _lastFakeAttack = 0
    end)

    W.FakeAttack_SetEnabled = function(v)
        VD.KILLER_FakeAttack = v and true or false
    end
end

--====================================================--
-- AUTO DESTROY PALLET (KILLER)
-- Auto break pallet saat deket
--====================================================--
do
    VD.KILLER_AutoDestroyPallet = VD.KILLER_AutoDestroyPallet or false

    local _lastBreak = 0
    local _isBreaking = false
    local _usedPallets = {}

    local function ADP_GetAllPallets()
        local list = {}
        local map = Workspace:FindFirstChild("Map")
        if not map then return list end
        for _, obj in ipairs(map:GetDescendants()) do
            if obj.Name == "Palletwrong" and (obj:IsA("Model") or obj:IsA("Folder")) then
                table.insert(list, obj)
            end
        end
        return list
    end

    local function ADP_IsBroken(palletModel)
        if not palletModel or not palletModel.Parent then return true end
        if _usedPallets[palletModel] then return true end
        local ok, destroyed = pcall(function() return palletModel:GetAttribute("Destroyed") end)
        if ok and destroyed == true then return true end
        local ok2, broken = pcall(function() return palletModel:GetAttribute("Broken") end)
        if ok2 and broken == true then return true end
        if not palletModel:FindFirstChildWhichIsA("BasePart", true) then return true end
        return false
    end

    local function ADP_GetPointSlide(model)
        local slide = model:FindFirstChild("PalletPointSlide")
        if slide then return slide end
        for _, child in ipairs(model:GetDescendants()) do
            if child.Name == "PalletPointSlide" then return child end
        end
        return model:FindFirstChild("PalletPoint")
    end

    local function ADP_CheckBusy(char)
        if not char then return true end
        local stunned = char:GetAttribute("IsStunned") or char:GetAttribute("isStunned")
        local immobile = char:GetAttribute("Immobile") or char:GetAttribute("immobile")
        local carrying = char:GetAttribute("IsCarrying") or char:GetAttribute("isCarrying")
        if stunned or immobile or carrying then return true end
        return false
    end

    Scheduler:Add("AutoDestroyPallet", function()
        if not VD.KILLER_AutoDestroyPallet then return end
        if GetRole() ~= "Killer" then return end
        if _isBreaking then return end

        local now = tick()
        if now - _lastBreak < 1.2 then return end

        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        if ADP_CheckBusy(char) then return end

        -- Cari pallet terdekat yang belum dihancurkan
        local bestPallet, bestDist = nil, 6
        for _, pal in ipairs(ADP_GetAllPallets()) do
            if not ADP_IsBroken(pal) then
                local refPart = pal:FindFirstChild("PalletPoint")
                    or pal:FindFirstChild("PalletPointSlide")
                    or pal:FindFirstChildWhichIsA("BasePart", true)
                if refPart then
                    local d = (root.Position - refPart.Position).Magnitude
                    if d < bestDist then
                        bestDist = d
                        bestPallet = pal
                    end
                end
            end
        end

        if not bestPallet then return end

        local fireTarget = ADP_GetPointSlide(bestPallet)
        if not fireTarget then return end

        _isBreaking = true
        _lastBreak = now

        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local palletFold = remotes and remotes:FindFirstChild("Pallet")
        local dropEvent = palletFold and palletFold:FindFirstChild("PalletDropEvent")
        local jasonFold = palletFold and palletFold:FindFirstChild("Jason")
        local destroyGlobal = jasonFold and jasonFold:FindFirstChild("Destroy-Global")
        local breakCommit = jasonFold and jasonFold:FindFirstChild("PalletBreakCommit")
        local destroySingle = jasonFold and jasonFold:FindFirstChild("Destroy")

        -- Drop dulu
        if dropEvent then
            pcall(function() dropEvent:FireServer(fireTarget) end)
            task.wait(0.1)
        end

        -- Teleport ke pallet
        pcall(function()
            root.CFrame = fireTarget.CFrame + Vector3.new(0, 2, 0)
        end)
        task.wait(0.1)

        -- Break
        if destroyGlobal  then pcall(function() destroyGlobal:FireServer(fireTarget) end) end
        if breakCommit    then pcall(function() breakCommit:FireServer(fireTarget) end) end
        if destroySingle  then pcall(function() destroySingle:FireServer(fireTarget) end) end

        _usedPallets[bestPallet] = true

        task.wait(0.15)

        -- Force unstuck
        pcall(function()
            char:SetAttribute("Immobile", nil)
            char:SetAttribute("immobile", nil)
            char:SetAttribute("IsStunned", nil)
            char:SetAttribute("isStunned", nil)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed <= 0 then hum.WalkSpeed = 16 end
        end)

        _isBreaking = false
    end, 0.2)

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        _usedPallets = {}
        _isBroken = false
        _isBreaking = false
    end)

    W.AutoDestroyPallet_SetEnabled = function(v)
        VD.KILLER_AutoDestroyPallet = v and true or false
        _usedPallets = {}
    end
end

--====================================================--
-- ANTI KNOCK (SURVIVOR)
-- Cegah knockdown / hooked / carried state
--====================================================--
do
    VD.SURV_AntiKnock = VD.SURV_AntiKnock or false
    VD._LastAntiKnock = 0

    local function AntiKnock_GetValue(obj, name)
        if not obj then return nil end
        local attr = obj:GetAttribute(name)
        if attr ~= nil then return attr end
        local child = obj:FindFirstChild(name)
        if child then
            local ok, v = pcall(function() return child.Value end)
            if ok then return v end
        end
        return nil
    end

    local function AntiKnock_IsActive(value)
        return value == true or (type(value) == "number" and value > 0)
    end

    Scheduler:Add("AntiKnock", function()
        if not VD.SURV_AntiKnock then return end
        if GetRole() ~= "Survivor" then return end

        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end

        local isKnocked = AntiKnock_IsActive(AntiKnock_GetValue(char, "Knocked"))
            or AntiKnock_IsActive(AntiKnock_GetValue(char, "IsKnocked"))
            or AntiKnock_IsActive(AntiKnock_GetValue(char, "Downed"))
            or AntiKnock_IsActive(AntiKnock_GetValue(char, "IsDown"))
        local isCarried = AntiKnock_IsActive(AntiKnock_GetValue(char, "Carried"))
            or AntiKnock_IsActive(AntiKnock_GetValue(char, "IsCarried"))
            or AntiKnock_IsActive(AntiKnock_GetValue(char, "Grabbed"))

        local state = char:GetAttribute("State")
        if state == "Downed" or state == "Dead" then isKnocked = true end

        if not isKnocked and not isCarried then return end

        local now = tick()
        if now - VD._LastAntiKnock < 0.3 then return end
        VD._LastAntiKnock = now

        -- Reset attributes
        for _, flag in ipairs({
            "Knocked", "IsKnocked", "Downed", "IsDown",
            "Carried", "IsCarried", "Grabbed",
            "Ragdolled", "Captured", "Disabled",
        }) do
            pcall(function()
                if char:GetAttribute(flag) ~= nil then char:SetAttribute(flag, false) end
                local obj = char:FindFirstChild(flag)
                if obj then
                    if obj:IsA("BoolValue") then
                        obj.Value = false
                    elseif obj:IsA("NumberValue") or obj:IsA("IntValue") then
                        obj.Value = 0
                    end
                end
            end)
        end

        pcall(function()
            if char:GetAttribute("State") == "Downed" then
                char:SetAttribute("State", "Running")
            end
        end)

        -- Fix humanoid state
        pcall(function()
            hum.PlatformStand = false
            hum.Sit = false
            hum.AutoRotate = true
            local st = hum:GetState()
            if st == Enum.HumanoidStateType.Physics
                or st == Enum.HumanoidStateType.Ragdoll
                or st == Enum.HumanoidStateType.FallingDown
                or st == Enum.HumanoidStateType.PlatformStanding then
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
            root.AssemblyLinearVelocity = Vector3.zero
            task.defer(function()
                pcall(function()
                    hum.Health = hum.MaxHealth
                    hum.WalkSpeed = math.max(hum.WalkSpeed, 16)
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end)
            end)
        end)

        VD_Notify("Anti Knock", "Anti-knock triggered!", 1)
    end, 0.1)

    W.AntiKnock_SetEnabled = function(v)
        VD.SURV_AntiKnock = v and true or false
    end
end

--====================================================--
-- AUTO BREAK GENERATOR (KILLER)
-- Auto kick generator saat deket
--====================================================--
do
    VD.KILLER_AutoBreakGene = VD.KILLER_AutoBreakGene or false

    local _lastBreakGen = 0
    local _isBreakingGen = false
    local _usedGens = {}

    local function ABG_GetAllGenerators()
        local list = {}
        local map = Workspace:FindFirstChild("Map")
        if not map then return list end
        for _, obj in ipairs(map:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Generator" then
                local isReal = obj:GetAttribute("RepairProgress") ~= nil
                    or obj:GetAttribute("kickcount") ~= nil
                    or obj:GetAttribute("ProgressRepair") ~= nil
                if isReal then table.insert(list, obj) end
            end
        end
        return list
    end

    local function ABG_GetGenPoint(genModel)
        for _, obj in ipairs(genModel:GetChildren()) do
            if obj:IsA("BasePart") and string.find(obj.Name, "GeneratorPoint") then
                return obj
            end
        end
        return nil
    end

    local function ABG_IsGenUseless(genModel)
        if not genModel or not genModel.Parent then return true end
        if _usedGens[genModel] then return true end
        local progress = genModel:GetAttribute("RepairProgress")
            or genModel:GetAttribute("repairProgress")
            or genModel:GetAttribute("ProgressRepair") or 0
        local kickcount = genModel:GetAttribute("kickcount")
            or genModel:GetAttribute("KickCount") or 0
        -- Skip kalau progress 0 (belum disentuh) atau >= 100 (udah selesai) atau kickcount > 7
        if progress <= 0 then return true end
        if progress >= 100 then return true end
        if kickcount > 7 then return true end
        return false
    end

    local function ABG_CheckBusy(char)
        if not char then return true end
        local stunned = char:GetAttribute("IsStunned") or char:GetAttribute("isStunned")
        local immobile = char:GetAttribute("Immobile") or char:GetAttribute("immobile")
        local carrying = char:GetAttribute("IsCarrying") or char:GetAttribute("isCarrying")
        local pursuit = char:GetAttribute("Pursuit") or char:GetAttribute("pursuit")
        if stunned or immobile or carrying or pursuit then return true end
        return false
    end

    Scheduler:Add("AutoBreakGen", function()
        if not VD.KILLER_AutoBreakGene then return end
        if GetRole() ~= "Killer" then return end
        if _isBreakingGen then return end

        local now = tick()
        if now - _lastBreakGen < 1.2 then return end

        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        if ABG_CheckBusy(char) then return end

        -- Cari generator terdekat yang belum di-break
        local bestGen, bestPoint, bestDist = nil, nil, 6
        for _, gen in ipairs(ABG_GetAllGenerators()) do
            if not ABG_IsGenUseless(gen) then
                local pt = ABG_GetGenPoint(gen)
                if pt then
                    local d = (root.Position - pt.Position).Magnitude
                    if d < bestDist then
                        bestDist = d
                        bestGen = gen
                        bestPoint = pt
                    end
                end
            end
        end

        if not bestGen or not bestPoint then return end

        _isBreakingGen = true
        _lastBreakGen = now

        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local genFolder = remotes and remotes:FindFirstChild("Generator")
        local breakEvent = genFolder and genFolder:FindFirstChild("BreakGenEvent")
        local breakCommit = genFolder and genFolder:FindFirstChild("BreakGenCommit")
        local breakSingle = genFolder and genFolder:FindFirstChild("Break")

        -- Teleport ke generator point
        pcall(function()
            root.CFrame = bestPoint.CFrame + Vector3.new(0, 2, 0)
        end)
        task.wait(0.15)

        -- Fire remote break
        if breakEvent  then pcall(function() breakEvent:FireServer(bestPoint) end) end
        if breakCommit then pcall(function() breakCommit:FireServer(bestPoint) end) end
        if breakSingle then pcall(function() breakSingle:FireServer(bestPoint) end) end

        _usedGens[bestGen] = true

        -- Tunggu animasi break selesai (cek attribute Immobile)
        task.wait(0.2)
        local startTime = os.clock()
        while char and char.Parent and (char:GetAttribute("Immobile") or char:GetAttribute("immobile")) do
            if os.clock() - startTime > 3 then break end
            task.wait(0.1)
        end

        -- Force unstuck
        pcall(function()
            char:SetAttribute("Immobile", nil)
            char:SetAttribute("immobile", nil)
            char:SetAttribute("IsStunned", nil)
            char:SetAttribute("isStunned", nil)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed <= 0 then hum.WalkSpeed = 16 end
        end)

        _isBreakingGen = false
    end, 0.2)

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        _usedGens = {}
        _isBreakingGen = false
        _lastBreakGen = 0
    end)

    W.AutoBreakGen_SetEnabled = function(v)
        VD.KILLER_AutoBreakGene = v and true or false
        _usedGens = {}
    end
end

--====================================================--
-- CROSSHAIR (VISUALS)
--====================================================--
do
    VD.Crosshair_Enabled  = VD.Crosshair_Enabled  or false
    VD.Crosshair_Style    = VD.Crosshair_Style    or "Dot"
    VD.Crosshair_Size     = VD.Crosshair_Size     or 4
    VD.Crosshair_Thickness= VD.Crosshair_Thickness or 2
    VD.Crosshair_Gap      = VD.Crosshair_Gap      or 6
    VD.Crosshair_Color    = VD.Crosshair_Color    or Color3.fromRGB(255, 255, 255)
    VD.Crosshair_OffsetX  = VD.Crosshair_OffsetX  or 0
    VD.Crosshair_OffsetY  = VD.Crosshair_OffsetY  or 0

    local Crosshair = { Enabled = false, Drawings = {}, LastStyle = nil, Created = false }
    local DrawingAvailable = (typeof(Drawing) == "table" and Drawing.new ~= nil)

    --===== DRAWING API VERSION (PC) =====--
    local function Crosshair_Clear()
        for _, v in pairs(Crosshair.Drawings) do
            pcall(function() v:Remove() end)
        end
        Crosshair.Drawings = {}
        Crosshair.Created = false
    end

    local function Crosshair_Create(style)
        Crosshair_Clear()
        Crosshair.Created = true

        if style == "Dot" then
            local dot = Drawing.new("Circle")
            dot.Filled = true
            dot.Visible = true
            table.insert(Crosshair.Drawings, dot)
        elseif style == "Plus" then
            for i = 1, 4 do
                local line = Drawing.new("Line")
                line.Visible = true
                table.insert(Crosshair.Drawings, line)
            end
        elseif style == "X" then
            for i = 1, 4 do
                local line = Drawing.new("Line")
                line.Visible = true
                table.insert(Crosshair.Drawings, line)
            end
        elseif style == "Circle" then
            local circle = Drawing.new("Circle")
            circle.Filled = false
            circle.Visible = true
            table.insert(Crosshair.Drawings, circle)
        end
    end

    local function Crosshair_UpdateDrawing()
        if not DrawingAvailable then return end

        if not VD.Crosshair_Enabled then
            for _, v in pairs(Crosshair.Drawings) do
                if v then v.Visible = false end
            end
            return
        end

        if Crosshair.LastStyle ~= VD.Crosshair_Style then
            Crosshair_Clear()
            Crosshair.LastStyle = VD.Crosshair_Style
        end

        if not Crosshair.Created then
            Crosshair_Create(VD.Crosshair_Style)
        end

        local cam = Workspace.CurrentCamera
        if not cam then return end

        local center = Vector2.new(
            cam.ViewportSize.X / 2 + VD.Crosshair_OffsetX,
            cam.ViewportSize.Y / 2 + VD.Crosshair_OffsetY
        )

        local color = VD.Crosshair_Color
        local size = VD.Crosshair_Size
        local thick = VD.Crosshair_Thickness
        local gap = VD.Crosshair_Gap

        if VD.Crosshair_Style == "Dot" then
            local dot = Crosshair.Drawings[1]
            if dot then
                dot.Position = center
                dot.Radius = size
                dot.Color = color
                dot.Transparency = 1
                dot.Visible = true
            end
        elseif VD.Crosshair_Style == "Plus" then
            local lines = Crosshair.Drawings
            if #lines == 4 then
                for _, l in ipairs(lines) do
                    l.Color = color
                    l.Thickness = thick
                    l.Transparency = 1
                end
                lines[1].From = center + Vector2.new(-size - gap, 0)
                lines[1].To   = center + Vector2.new(-gap, 0)
                lines[2].From = center + Vector2.new(size + gap, 0)
                lines[2].To   = center + Vector2.new(gap, 0)
                lines[3].From = center + Vector2.new(0, -size - gap)
                lines[3].To   = center + Vector2.new(0, -gap)
                lines[4].From = center + Vector2.new(0, size + gap)
                lines[4].To   = center + Vector2.new(0, gap)
            end
        elseif VD.Crosshair_Style == "X" then
            local lines = Crosshair.Drawings
            if #lines == 4 then
                local d = (size + gap) * 0.7071
                local g = gap * 0.7071
                for _, l in ipairs(lines) do
                    l.Color = color
                    l.Thickness = thick
                    l.Transparency = 1
                end
                lines[1].From = center + Vector2.new(-d, -d)
                lines[1].To   = center + Vector2.new(-g, -g)
                lines[2].From = center + Vector2.new(d, -d)
                lines[2].To   = center + Vector2.new(g, -g)
                lines[3].From = center + Vector2.new(-d, d)
                lines[3].To   = center + Vector2.new(-g, g)
                lines[4].From = center + Vector2.new(d, d)
                lines[4].To   = center + Vector2.new(g, g)
            end
        elseif VD.Crosshair_Style == "Circle" then
            local circle = Crosshair.Drawings[1]
            if circle then
                circle.Position = center
                circle.Radius = size + gap
                circle.Color = color
                circle.Thickness = thick
                circle.Transparency = 1
                circle.Visible = true
            end
        end
    end

    --===== GUI FALLBACK (mobile / kalau Drawing gak support) =====--
    local CrosshairGui = nil
    local function Crosshair_ClearGui()
        if CrosshairGui then
            pcall(function() CrosshairGui:Destroy() end)
            CrosshairGui = nil
        end
    end

    local function Crosshair_BuildGui()
        Crosshair_ClearGui()
        if not VD.Crosshair_Enabled then return end

        local parent = LocalPlayer:FindFirstChild("PlayerGui")
        if gethui then
            local ok, hui = pcall(gethui)
            if ok and hui then parent = hui end
        end
        if not parent then return end

        local gui = Instance.new("ScreenGui")
        gui.Name = "GlutoCrosshair"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 999999
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = parent
        CrosshairGui = gui

        local center = Instance.new("Frame")
        center.Name = "Center"
        center.AnchorPoint = Vector2.new(0.5, 0.5)
        center.Position = UDim2.new(0.5, VD.Crosshair_OffsetX, 0.5, VD.Crosshair_OffsetY)
        center.Size = UDim2.fromOffset(0, 0)
        center.BackgroundTransparency = 1
        center.Parent = gui

        local style = VD.Crosshair_Style
        local size = VD.Crosshair_Size
        local gap = VD.Crosshair_Gap
        local thick = VD.Crosshair_Thickness
        local color = VD.Crosshair_Color

        if style == "Dot" then
            local dot = Instance.new("Frame")
            dot.AnchorPoint = Vector2.new(0.5, 0.5)
            dot.Size = UDim2.fromOffset(size * 2, size * 2)
            dot.Position = UDim2.new(0, 0, 0, 0)
            dot.BackgroundColor3 = color
            dot.BorderSizePixel = 0
            dot.Parent = center
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        elseif style == "Plus" or style == "X" then
            local length = size * 3
            for i = 1, 4 do
                local line = Instance.new("Frame")
                line.AnchorPoint = Vector2.new(0.5, 0.5)
                line.BackgroundColor3 = color
                line.BorderSizePixel = 0
                local angle = (i - 1) * 90
                if style == "X" then angle = angle + 45 end
                line.Rotation = angle
                line.Size = UDim2.fromOffset(length, thick)
                local rad = math.rad(angle)
                local dirX, dirY = math.cos(rad), math.sin(rad)
                local dist = gap + length / 2
                line.Position = UDim2.new(0, dirX * dist, 0, dirY * dist)
                line.Parent = center
            end
        elseif style == "Circle" then
            local circle = Instance.new("Frame")
            circle.AnchorPoint = Vector2.new(0.5, 0.5)
            circle.Size = UDim2.fromOffset((size + gap) * 2, (size + gap) * 2)
            circle.Position = UDim2.new(0, 0, 0, 0)
            circle.BackgroundTransparency = 1
            circle.Parent = center
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
            local stroke = Instance.new("UIStroke", circle)
            stroke.Color = color
            stroke.Thickness = thick
        end
    end

    --===== PUBLIC API =====--
    W.Crosshair_SetEnabled = function(v)
        VD.Crosshair_Enabled = v and true or false
        if not v then
            Crosshair_Clear()
            Crosshair_ClearGui()
        else
            if DrawingAvailable then
                Crosshair_UpdateDrawing()
            else
                Crosshair_BuildGui()
            end
        end
    end
    W.Crosshair_Rebuild = function()
        if not VD.Crosshair_Enabled then return end
        if DrawingAvailable then
            Crosshair_Clear()
            Crosshair_UpdateDrawing()
        else
            Crosshair_BuildGui()
        end
    end

    --===== RUN =====--
    if DrawingAvailable then
        Scheduler:Add("Crosshair", function()
            if not VD.Crosshair_Enabled then return end
            pcall(Crosshair_UpdateDrawing)
        end, 0.016)
    else
        -- GUI fallback: rebuild when setting berubah
        local _lastCfg = ""
        Scheduler:Add("CrosshairGUIRebuild", function()
            if not VD.Crosshair_Enabled then return end
            local cfg = tostring(VD.Crosshair_Style) .. "|"
                .. tostring(VD.Crosshair_Size) .. "|"
                .. tostring(VD.Crosshair_Thickness) .. "|"
                .. tostring(VD.Crosshair_Gap) .. "|"
                .. tostring(VD.Crosshair_OffsetX) .. "|"
                .. tostring(VD.Crosshair_OffsetY) .. "|"
                .. tostring(VD.Crosshair_Color)
            if cfg ~= _lastCfg then
                _lastCfg = cfg
                Crosshair_BuildGui()
            end
        end, 0.2)
    end

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        if VD.Crosshair_Enabled then
            W.Crosshair_Rebuild()
        end
    end)
end

--====================================================--
-- TELEPORT SYSTEM (TAB BARU)
--====================================================--
do
    W.Teleport = W.Teleport or {
        SelectedPlayer = nil,
        SelectedPart = nil,
        LastTPTime = 0,
    }
    local TPS = W.Teleport

    --===== HELPER: teleport karakter ke CFrame dengan aman =====--
    local function TP_ToCFrame(cf)
        local char = LocalPlayer.Character
        if not char then return false end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return false end

        -- Cooldown biar gak spam
        local now = tick()
        if now - TPS.LastTPTime < 0.2 then return false end
        TPS.LastTPTime = now

        local originalCF = root.CFrame
        local parts = {}

        -- Save original CanCollide
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("BasePart") then
                parts[d] = d.CanCollide
                d.CanCollide = false
            end
        end

        pcall(function()
            root.Velocity = Vector3.zero
            root.CFrame = cf + Vector3.new(0, 3, 0)
        end)

        -- Restore setelah 0.3s
        task.delay(0.3, function()
            local c2 = LocalPlayer.Character
            if not c2 then return end
            for p, cc in pairs(parts) do
                if p and p.Parent then
                    pcall(function() p.CanCollide = cc end)
                end
            end
        end)

        return true
    end

    --===== GET POSITIONS =====--
    local function TP_GetAllGenerators()
        local list = {}
        local map = Workspace:FindFirstChild("Map")
        if not map then return list end
        for _, obj in ipairs(map:GetDescendants()) do
            if obj:IsA("BasePart") and string.find(obj.Name, "^GeneratorPoint%d+$") then
                table.insert(list, obj)
            end
        end
        return list
    end

    local function TP_GetAllHooks()
        local list = {}
        local map = Workspace:FindFirstChild("Map")
        if not map then return list end
        for _, obj in ipairs(map:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == "HookPoint" then
                table.insert(list, obj)
            end
        end
        return list
    end

    local function TP_GetAllGates()
        local list = {}
        local map = Workspace:FindFirstChild("Map")
        if not map then return list end
        for _, obj in ipairs(map:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name == "Gate" or obj.Name == "ExitGate") then
                local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                if part then table.insert(list, part) end
            end
        end
        return list
    end

    local function TP_GetFinishLine()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = string.lower(obj.Name)
                if n == "fininshline" or n == "finishline" then
                    return obj
                end
            end
        end
        return nil
    end

    local function TP_GetPlayerList()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                table.insert(list, p.Name)
            end
        end
        table.sort(list)
        return list
    end

    local function TP_GetPartList()
        local list = {}
        local map = Workspace:FindFirstChild("Map")
        if not map then return list end
        local seen = {}
        for _, obj in ipairs(map:GetDescendants()) do
            if obj:IsA("BasePart")
               and (obj.Name == "Generator"
                    or obj.Name == "Hook"
                    or string.find(obj.Name, "GeneratorPoint")
                    or string.find(obj.Name, "HookPoint")
                    or obj.Name == "Gate"
                    or obj.Name == "Window"
                    or obj.Name == "Palletwrong"
                    or obj.Name == "Pallet") then
                if not seen[obj.Name] then
                    seen[obj.Name] = true
                    table.insert(list, obj.Name)
                end
            end
        end
        table.sort(list)
        return list
    end

    --===== PUBLIC API =====--
    W.TP_ToGenerator = function(index)
        local gens = TP_GetAllGenerators()
        if #gens == 0 then VD_Notify("Teleport", "Generator gak ketemu", 2); return end
        local target = gens[index or 1]
        if target then
            if TP_ToCFrame(target.CFrame) then
                VD_Notify("Teleport", "TP ke Generator " .. (index or 1), 1.5)
            end
        end
    end

    W.TP_ToNearestGenerator = function()
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        local gens = TP_GetAllGenerators()
        if #gens == 0 then VD_Notify("Teleport", "Generator gak ketemu", 2); return end
        local nearest, nearestDist = nil, math.huge
        for _, g in ipairs(gens) do
            local d = (g.Position - myRoot.Position).Magnitude
            if d < nearestDist then
                nearestDist = d
                nearest = g
            end
        end
        if nearest then
            if TP_ToCFrame(nearest.CFrame) then
                VD_Notify("Teleport", "TP ke Generator terdekat", 1.5)
            end
        end
    end

    W.TP_ToHook = function()
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        local hooks = TP_GetAllHooks()
        if #hooks == 0 then VD_Notify("Teleport", "Hook gak ketemu", 2); return end
        local nearest, nearestDist = nil, math.huge
        for _, h in ipairs(hooks) do
            local d = (h.Position - myRoot.Position).Magnitude
            if d < nearestDist then
                nearestDist = d
                nearest = h
            end
        end
        if nearest then
            if TP_ToCFrame(nearest.CFrame) then
                VD_Notify("Teleport", "TP ke Hook terdekat", 1.5)
            end
        end
    end

    W.TP_ToGate = function()
        local gates = TP_GetAllGates()
        if #gates == 0 then VD_Notify("Teleport", "Gate gak ketemu", 2); return end
        if TP_ToCFrame(gates[1].CFrame) then
            VD_Notify("Teleport", "TP ke Gate", 1.5)
        end
    end

    W.TP_ToFinish = function()
        local finish = TP_GetFinishLine()
        if not finish then VD_Notify("Teleport", "Finish line gak ketemu", 2); return end
        if TP_ToCFrame(finish.CFrame) then
            VD_Notify("Teleport", "TP ke Finish Line", 1.5)
        end
    end

    W.TP_ToPlayer = function(playerName)
        if not playerName or playerName == "" then
            VD_Notify("Teleport", "Pilih player dulu", 2)
            return
        end
        local target = Players:FindFirstChild(playerName)
        if not target or not target.Character then
            VD_Notify("Teleport", "Player gak ketemu", 2)
            return
        end
        local root = target.Character:FindFirstChild("HumanoidRootPart")
        if not root then VD_Notify("Teleport", "Player root gak ketemu", 2); return end
        if TP_ToCFrame(root.CFrame) then
            VD_Notify("Teleport", "TP ke " .. playerName, 1.5)
        end
    end

    W.TP_ToPart = function(partName)
        if not partName or partName == "" then
            VD_Notify("Teleport", "Pilih part dulu", 2)
            return
        end
        local map = Workspace:FindFirstChild("Map")
        if not map then return end
        local found = nil
        for _, obj in ipairs(map:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == partName then
                found = obj
                break
            end
        end
        if not found then VD_Notify("Teleport", "Part gak ketemu", 2); return end
        if TP_ToCFrame(found.CFrame) then
            VD_Notify("Teleport", "TP ke " .. partName, 1.5)
        end
    end

    W.TP_GetPlayerList = TP_GetPlayerList
    W.TP_GetPartList = TP_GetPartList
    W.TP_ToCFrame = TP_ToCFrame
end
    --====================================================--
    -- FLOATING BUTTONS (FULL)
    --====================================================--
    local function CreateFloatingButton(cfg)
        local state = cfg.state
        state.Connections = state.Connections or {}
        local function ClearConns()
            for _, c in ipairs(state.Connections) do pcall(function() c:Disconnect() end) end
            state.Connections = {}
        end
        local function DestroyBtn()
            ClearConns()
            if state.Gui then pcall(function() state.Gui:Destroy() end); state.Gui = nil end
        end
        local function UpdateVisual()
            if not state.Gui then return end
            local main = state.Gui:FindFirstChild("MainBtn", true)
            if not main then return end
            local isOn = cfg.isOn()
            local sp = main:FindFirstChild("StatusPill")
            local st = sp and sp:FindFirstChild("StatusText")
            local sd = sp and sp:FindFirstChild("StatusDot")
            local str = main:FindFirstChild("MainStroke")
            local ic = main:FindFirstChild("IconCircle")
            local idot = ic and ic:FindFirstChild("IconDot")
            if isOn then
                TweenService:Create(main, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(0, 0, 0) }):Play()
                if ic then TweenService:Create(ic, TweenInfo.new(0.25), { BackgroundColor3 = _G.GLUTO_ACCENT, BackgroundTransparency = 0.15 }):Play() end
                if idot then TweenService:Create(idot, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(0, 0, 0) }):Play() end
                if sp then TweenService:Create(sp, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(0, 0, 0) }):Play() end
                if st then st.Text = "ON"; TweenService:Create(st, TweenInfo.new(0.25), { TextColor3 = _G.GLUTO_ACCENT }):Play() end
                if sd then TweenService:Create(sd, TweenInfo.new(0.25), { BackgroundColor3 = _G.GLUTO_ACCENT }):Play() end
                if str then TweenService:Create(str, TweenInfo.new(0.25), { Color = Color3.fromRGB(255, 255, 255) }):Play() end
            else
                TweenService:Create(main, TweenInfo.new(0.25), { BackgroundColor3 = _G.GLUTO_BG_OFF }):Play()
                if ic then TweenService:Create(ic, TweenInfo.new(0.25), { BackgroundColor3 = _G.GLUTO_NEUTRAL, BackgroundTransparency = 0.4 }):Play() end
                if idot then TweenService:Create(idot, TweenInfo.new(0.25), { BackgroundColor3 = _G.GLUTO_BG_OFF }):Play() end
                if sp then TweenService:Create(sp, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(0, 0, 0) }):Play() end
                if st then st.Text = "OFF"; TweenService:Create(st, TweenInfo.new(0.25), { TextColor3 = Color3.fromRGB(120, 120, 120) }):Play() end
                if sd then TweenService:Create(sd, TweenInfo.new(0.25), { BackgroundColor3 = _G.GLUTO_NEUTRAL }):Play() end
                if str then TweenService:Create(str, TweenInfo.new(0.25), { Color = _G.GLUTO_STROKE_OFF }):Play() end
            end
        end
        local function ToggleBtn()
            local s = not cfg.isOn()
            cfg.onToggle(s)
            UpdateVisual()
            if s then VD_Notify(cfg.notifyTitle, "Enabled", 2) end
        end
        local function CreateBtn()
            DestroyBtn()
            local parent = LocalPlayer:FindFirstChild("PlayerGui")
            if gethui then local ok2, hui = pcall(gethui); if ok2 and hui then parent = hui end end
            if not parent then return end
            local gui = Instance.new("ScreenGui")
            gui.Name = "Gluto" .. cfg.id .. "Btn"; gui.ResetOnSpawn = false
            gui.IgnoreGuiInset = true; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            gui.Parent = parent
            state.Gui = gui
            local container = Instance.new("Frame")
            container.Name = "Container"
            container.Size = UDim2.fromOffset(180, 40)
            container.Position = state.SavedPos
            container.BackgroundTransparency = 1
            container.Parent = gui
            local main = Instance.new("Frame")
            main.Name = "MainBtn"
            main.Size = UDim2.fromOffset(132, 40)
            main.BackgroundColor3 = _G.GLUTO_BG_OFF
            main.BorderSizePixel = 0; main.ZIndex = 1; main.Parent = container
            Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
            local mainStroke = Instance.new("UIStroke", main)
            mainStroke.Name = "MainStroke"
            mainStroke.Color = _G.GLUTO_STROKE_OFF
            mainStroke.Thickness = 1.2; mainStroke.Transparency = 0.2
            local ic = Instance.new("Frame")
            ic.Name = "IconCircle"
            ic.Size = UDim2.fromOffset(24, 24)
            ic.Position = UDim2.new(0, 8, 0.5, -12)
            ic.BackgroundColor3 = _G.GLUTO_NEUTRAL
            ic.BackgroundTransparency = 0.4
            ic.BorderSizePixel = 0; ic.ZIndex = 2; ic.Parent = main
            Instance.new("UICorner", ic).CornerRadius = UDim.new(1, 0)
            local idot = Instance.new("Frame")
            idot.Name = "IconDot"
            idot.Size = UDim2.fromOffset(10, 10)
            idot.Position = UDim2.new(0.5, -5, 0.5, -5)
            idot.BackgroundColor3 = _G.GLUTO_BG_OFF
            idot.BorderSizePixel = 0; idot.ZIndex = 3; idot.Rotation = cfg.iconRotation or 0
            idot.Parent = ic
            Instance.new("UICorner", idot).CornerRadius = UDim.new(0, 2)
            local ml = Instance.new("TextLabel")
            ml.Name = "MainLabel"
            ml.Size = UDim2.new(1, -70, 1, 0)
            ml.Position = UDim2.new(0, 38, 0, 0)
            ml.BackgroundTransparency = 1
            ml.Font = Enum.Font.GothamBold
            ml.Text = cfg.title
            ml.TextColor3 = Color3.fromRGB(240, 240, 245)
            ml.TextSize = 13
            ml.TextXAlignment = Enum.TextXAlignment.Left
            ml.ZIndex = 2; ml.Parent = main
            local sp = Instance.new("Frame")
            sp.Name = "StatusPill"
            sp.AnchorPoint = Vector2.new(1, 0.5)
            sp.Size = UDim2.fromOffset(42, 20)
            sp.Position = UDim2.new(1, -8, 0.5, 0)
            sp.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            sp.BorderSizePixel = 0; sp.ZIndex = 2; sp.Parent = main
            Instance.new("UICorner", sp).CornerRadius = UDim.new(1, 0)
            local sd = Instance.new("Frame")
            sd.Name = "StatusDot"
            sd.Size = UDim2.fromOffset(6, 6)
            sd.Position = UDim2.new(0, 7, 0.5, -3)
            sd.BackgroundColor3 = _G.GLUTO_NEUTRAL
            sd.BorderSizePixel = 0; sd.ZIndex = 3; sd.Parent = sp
            Instance.new("UICorner", sd).CornerRadius = UDim.new(1, 0)
            local st = Instance.new("TextLabel")
            st.Name = "StatusText"
            st.Size = UDim2.new(1, -18, 1, 0)
            st.Position = UDim2.new(0, 16, 0, 0)
            st.BackgroundTransparency = 1
            st.Font = Enum.Font.GothamBold
            st.Text = "OFF"
            st.TextColor3 = Color3.fromRGB(140, 140, 152)
            st.TextSize = 10
            st.TextXAlignment = Enum.TextXAlignment.Center
            st.ZIndex = 3; st.Parent = sp
            local lock = Instance.new("TextButton")
            lock.Name = "LockBtn"
            lock.Size = UDim2.fromOffset(40, 40)
            lock.Position = UDim2.new(1, -44, 0, 0)
            lock.BackgroundColor3 = _G.GLUTO_BG_OFF
            lock.BorderSizePixel = 0; lock.Text = ""
            lock.AutoButtonColor = false
            lock.ZIndex = 1; lock.Parent = container
            Instance.new("UICorner", lock).CornerRadius = UDim.new(0, 12)
            local ls = Instance.new("UIStroke", lock)
            ls.Color = _G.GLUTO_STROKE_OFF
            ls.Thickness = 1.2; ls.Transparency = 0.2
            ls.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            local li = Instance.new("TextLabel")
            li.Name = "LockIcon"
            li.Size = UDim2.fromScale(1, 1)
            li.BackgroundTransparency = 1
            li.Font = Enum.Font.GothamBold
            li.Text = "🔓"
            li.TextColor3 = Color3.fromRGB(180, 180, 190)
            li.TextSize = 16; li.ZIndex = 2; li.Parent = lock
            local function UpdateLockVisual()
                if state.DragLocked then
                    li.Text = "🔒"
                    TweenService:Create(ls, TweenInfo.new(0.2), { Color = _G.GLUTO_ACCENT, Transparency = 0, Thickness = 1.5 }):Play()
                    TweenService:Create(lock, TweenInfo.new(0.2), { BackgroundColor3 = _G.GLUTO_ACCENT_BG }):Play()
                    TweenService:Create(li, TweenInfo.new(0.2), { TextColor3 = _G.GLUTO_ACCENT }):Play()
                else
                    li.Text = "🔓"
                    TweenService:Create(ls, TweenInfo.new(0.2), { Color = _G.GLUTO_STROKE_OFF, Transparency = 0.2, Thickness = 1.2 }):Play()
                    TweenService:Create(lock, TweenInfo.new(0.2), { BackgroundColor3 = _G.GLUTO_BG_OFF }):Play()
                    TweenService:Create(li, TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(180, 180, 190) }):Play()
                end
            end
            local cd = Instance.new("TextButton")
            cd.Name = "ClickDetect"
            cd.Size = UDim2.fromScale(1, 1)
            cd.BackgroundTransparency = 1; cd.Text = ""
            cd.AutoButtonColor = false
            cd.ZIndex = 5; cd.Parent = main
            local drag = false
            local dStart, sPos
            local dDist = 0
            table.insert(state.Connections, cd.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dStart = inp.Position; sPos = container.Position; dDist = 0
                    if not state.DragLocked then drag = true end
                end
            end))
            table.insert(state.Connections, cd.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    if drag then drag = false; state.SavedPos = container.Position end
                    if dDist < 8 then ToggleBtn() end
                end
            end))
            table.insert(state.Connections, UserInputService.InputChanged:Connect(function(inp)
                if not drag then return end
                if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                    local d = inp.Position - dStart
                    dDist = math.abs(d.X) + math.abs(d.Y)
                    container.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
                end
            end))
            table.insert(state.Connections, lock.MouseButton1Click:Connect(function()
                state.DragLocked = not state.DragLocked
                if state.DragLocked then drag = false end
                UpdateLockVisual()
                VD_Notify(cfg.notifyTitle .. " Button", state.DragLocked and "Locked" or "Unlocked", 1)
            end))
            UpdateVisual()
            UpdateLockVisual()
        end
        state.Create = CreateBtn
        state.Destroy = DestroyBtn
        state.UpdateVisual = UpdateVisual
        state.SetEnabled = function(en)
            state.Enabled = en and true or false
            if state.Enabled then CreateBtn() else DestroyBtn() end
        end
        return state
    end

    local SelfHealBtnState = { Enabled=false, DragLocked=false, Gui=nil, SavedPos=UDim2.new(0.03,0,0.28,0), Connections={} }
    local SelfHealState = CreateFloatingButton({
        id="SelfHeal", title="Heal", notifyTitle="Self Heal", state=SelfHealBtnState,
        isOn=function() return W.InstantHealSelf end,
        onToggle=function(v) W.setInstantHealSelf(v) end, iconRotation=0,
    })
    getgenv().Gluto_SHB_SetEnabled = function(en) SelfHealState.SetEnabled(en) end
    getgenv().Gluto_SHB_UpdateVisual = function() SelfHealState.UpdateVisual() end

    W.SelfUnhook = W.SelfUnhook or {
        Enabled=false, Following=false, FollowDuration=30, FollowDistance=20,
        MonitorConn=nil, TriggerCount=0, _lastTrigger=0, _cooldown=3,
        _hookPos=nil, _hookCFrame=nil, _activeThread=nil, _wasHooked=false
    }
    local SU = W.SelfUnhook
    function W.SU_IsHooked()
        local char = LocalPlayer.Character
        if not char then return false end
        return char:GetAttribute("IsHooked") == true or char:GetAttribute("isHooked") == true
            or char:GetAttribute("Hooked") == true or char:GetAttribute("HookedState") == true
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
            if p ~= LocalPlayer and TeamIs(p, "Killer") and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then return hrp end
            end
        end
        return nil
    end
    function W.SU_Abort()
        SU.Following = false
        if SU._activeThread and coroutine.status(SU._activeThread) ~= "dead" then
            pcall(function() task.cancel(SU._activeThread) end)
        end
        SU._activeThread = nil
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
            if hrp then SU._hookPos = hrp.Position; SU._hookCFrame = hrp.CFrame end
        end
        SU._activeThread = task.spawn(function()
            local c = LocalPlayer.Character
            if not c then SU.Following = false; SU._activeThread = nil; return end
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if not hrp then SU.Following = false; SU._activeThread = nil; return end
            local re = ReplicatedStorage:FindFirstChild("Remotes")
                and ReplicatedStorage.Remotes:FindFirstChild("Generator")
                and ReplicatedStorage.Remotes.Generator:FindFirstChild("RepairEvent")
            if not W.SU_IsHooked() then SU.Following = false; SU._activeThread = nil; return end
            local tp = W.SU_GetRandomGeneratorPoint()
            if tp then
                pcall(function() hrp.Velocity = Vector3.zero; hrp.CFrame = tp.CFrame + Vector3.new(0, 3, 0) end)
                task.wait(0.15)
                if re then
                    pcall(function() re:FireServer(tp, true) end); task.wait(0.35)
                    pcall(function() re:FireServer(tp, false) end); task.wait(0.15)
                    pcall(function() re:FireServer(tp, true) end); task.wait(0.35)
                    pcall(function() re:FireServer(tp, false) end)
                end
            end
            local fUntil = tick() + (SU.FollowDuration or 30)
            local bOff = SU.FollowDistance or 20
            while tick() < fUntil and SU.Enabled do
                if not W.SU_IsHooked() then
                    SU.Following = false; SU._activeThread = nil
                    VD_Notify("Bypass Self Unhook", "Udah lepas hook - STOP", 2)
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
                        local tPos = Vector3.new(khrp.Position.X, khrp.Position.Y - bOff, khrp.Position.Z)
                        r.CFrame = CFrame.new(tPos, tPos + Vector3.new(0, 0, -1))
                    end)
                end
                task.wait(0.03)
            end
            if W.SU_IsHooked() then
                local c2 = LocalPlayer.Character
                if c2 then
                    local r2 = c2:FindFirstChild("HumanoidRootPart")
                    if r2 then
                        if SU._hookCFrame then pcall(function() r2.Velocity = Vector3.zero; r2.CFrame = SU._hookCFrame end)
                        elseif SU._hookPos then pcall(function() r2.Velocity = Vector3.zero; r2.CFrame = CFrame.new(SU._hookPos + Vector3.new(0, 3, 0)) end) end
                    end
                end
            end
            SU.Following = false; SU._activeThread = nil
        end)
    end
    function W.SU_Start()
        if SU.MonitorConn then return end
        SU._wasHooked = false
        SU.MonitorConn = RunService.Heartbeat:Connect(function()
            if not SU.Enabled then return end
            local char = LocalPlayer.Character
            if not char then return end
            local isH = W.SU_IsHooked()
            if not isH then SU._wasHooked = false; return end
            if not SU._wasHooked and not SU.Following then SU._wasHooked = true; W.SU_Trigger() end
        end)
    end
    function W.SU_Stop()
        if SU.MonitorConn then SU.MonitorConn:Disconnect(); SU.MonitorConn = nil end
        W.SU_Abort(); SU._wasHooked = false
    end
    function W.SU_SetEnabled(v)
        SU.Enabled = v
        if v then W.SU_Start() else W.SU_Stop() end
    end

    local SelfUnhookBtnState = { Enabled=false, DragLocked=false, Gui=nil, SavedPos=UDim2.new(0.03,0,0.35,0), Connections={} }
    local SelfUnhookState = CreateFloatingButton({
        id="SelfUnhook", title="Hook", notifyTitle="Self Unhook", state=SelfUnhookBtnState,
        isOn=function() return W.SelfUnhook.Enabled end,
        onToggle=function(v) W.SU_SetEnabled(v) end, iconRotation=135,
    })
    getgenv().Gluto_SUB_SetEnabled = function(en) SelfUnhookState.SetEnabled(en) end
    getgenv().Gluto_SUB_UpdateVisual = function() SelfUnhookState.UpdateVisual() end

    local TrollBtnState = { Enabled=false, DragLocked=false, Gui=nil, SavedPos=UDim2.new(0.03,0,0.42,0), Connections={} }
    local TrollState = CreateFloatingButton({
        id="TrollTP", title="T_TP", notifyTitle="Troll Teleport", state=TrollBtnState,
        isOn=function() return W.TrollTeleport.Enabled end,
        onToggle=function(v) W.TrollTeleport_SetEnabled(v) end, iconRotation=225,
    })
    getgenv().Gluto_TTB_SetEnabled = function(en) TrollState.SetEnabled(en) end
    getgenv().Gluto_TTB_UpdateVisual = function() TrollState.UpdateVisual() end

    local EscapeBtnState = { Enabled=false, DragLocked=false, Gui=nil, SavedPos=UDim2.new(0.03,0,0.49,0), Connections={} }
    local EscapeState = CreateFloatingButton({
        id="Escape", title="Escape", notifyTitle="Instant Escape", state=EscapeBtnState,
        isOn=function() return W.Escape.Enabled end,
        onToggle=function(v) W.Escape.Enabled = v; if v then W.Escape_Teleport() end end, iconRotation=45,
    })
    getgenv().Gluto_Escape_SetEnabled = function(en) EscapeState.SetEnabled(en) end
    getgenv().Gluto_Escape_UpdateVisual = function() EscapeState.UpdateVisual() end

    local ParryBtnState = { Enabled=false, DragLocked=false, Gui=nil, SavedPos=UDim2.new(0.03,0,0.56,0), Connections={} }
    local ParryStateBtn = CreateFloatingButton({
        id="Parry", title="Parry", notifyTitle="Parry", state=ParryBtnState,
        isOn=function() return VD.PARRY_Enabled end,
        onToggle=function(v) VD.PARRY_Enabled = v; if not v then ParryState.ActiveAttackers = {} end end,
        iconRotation=45,
    })
    getgenv().Gluto_ParryBtn_SetEnabled = function(en) ParryStateBtn.SetEnabled(en) end
    getgenv().Gluto_ParryBtn_UpdateVisual = function() ParryStateBtn.UpdateVisual() end

    local InvisBtnState = { Enabled=false, DragLocked=false, Gui=nil, SavedPos=UDim2.new(0.03,0,0.63,0), Connections={} }
    local InvisStateBtn = CreateFloatingButton({
        id="Invisible", title="Invis", notifyTitle="Invisible", state=InvisBtnState,
        isOn=function() return W.Invisible.Enabled end,
        onToggle=function(v) W.Invisible_SetEnabled(v) end, iconRotation=180,
    })
    getgenv().Gluto_InvisBtn_SetEnabled   = function(en) InvisStateBtn.SetEnabled(en) end
    getgenv().Gluto_InvisBtn_UpdateVisual = function() InvisStateBtn.UpdateVisual() end

    local MyersGrabBtnState = { Enabled=false, DragLocked=false, Gui=nil, SavedPos=UDim2.new(0.03,0,0.70,0), Connections={} }
    local MyersGrabBtn = CreateFloatingButton({
        id="MyersGrab", title="Grab", notifyTitle="Myers Grab", state=MyersGrabBtnState,
        isOn=function() return W.MyersGrabData.Enabled end,
        onToggle=function(v) W.setMyersGrab(v) end, iconRotation=90,
    })
    getgenv().Gluto_MGrabBtn_SetEnabled   = function(en) MyersGrabBtn.SetEnabled(en) end
    getgenv().Gluto_MGrabBtn_UpdateVisual = function() MyersGrabBtn.UpdateVisual() end

    local VeilBtnState = { Enabled=false, DragLocked=false, Gui=nil, SavedPos=UDim2.new(0.03,0,0.77,0), Connections={} }
    local VeilBtn = CreateFloatingButton({
        id="SilentVeil", title="Veil", notifyTitle="Silent Veil", state=VeilBtnState,
        isOn=function() return VD.VeilEnabled end,
        onToggle=function(v)
            VD.VeilEnabled = v
            VD_Notify("Silent Veil", v and "Enabled" or "Disabled", 2)
            if getgenv().Gluto_VeilBtn_UpdateVisual then getgenv().Gluto_VeilBtn_UpdateVisual() end
        end, iconRotation=0,
    })
    getgenv().Gluto_VeilBtn_SetEnabled   = function(en) VeilBtn.SetEnabled(en) end
    getgenv().Gluto_VeilBtn_UpdateVisual = function() VeilBtn.UpdateVisual() end

    --====================================================--
    -- AUTO SKILL CHECK (FULL)
    --====================================================--
    W.SkillCheck = W.SkillCheck or { Enabled=false, Mode="Legit", Busy=false, Connection=nil }
    local SC = W.SkillCheck
    local SC_TouchID = 8822
    local SC_ActionPath = "Survivor-mob.Controls.action.check"
    local function SC_PressSpace()
        if not VirtualInputManager then return end
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait()
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        end)
    end
    local function SC_GetActionTarget()
        local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if not pGui then return nil end
        local current = pGui
        for seg in string.gmatch(SC_ActionPath, "[^%.]+") do
            current = current and current:FindFirstChild(seg)
        end
        return current
    end
    local function SC_TriggerMobileButton()
        local b = SC_GetActionTarget()
        if b and b:IsA("GuiObject") then
            local p, s = b.AbsolutePosition, b.AbsoluteSize
            local i = GuiService:GetGuiInset()
            local cx, cy = p.X + (s.X/2) + i.X, p.Y + (s.Y/2) + i.Y
            pcall(function()
                VirtualInputManager:SendTouchEvent(SC_TouchID, 0, cx, cy)
                task.wait(0.01)
                VirtualInputManager:SendTouchEvent(SC_TouchID, 2, cx, cy)
            end)
        end
    end
    function W.SkillCheck_Start()
        if SC.Connection then SC.Connection:Disconnect(); SC.Connection = nil end
        SC.Connection = RunService.RenderStepped:Connect(function()
            if not SC.Enabled or SC.Busy then return end
            local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if not pGui then return end
            local prompt = pGui:FindFirstChild("SkillCheckPromptGui")
            if not prompt then return end
            local check = prompt:FindFirstChild("Check")
            if not check or not check.Visible then return end
            local line = check:FindFirstChild("Line")
            local goal = check:FindFirstChild("Goal")
            if not line or not goal then return end
            if SC.Mode == "Instant" then
                line.Rotation = goal.Rotation + 109
                SC.Busy = true
                task.spawn(function()
                    if UserInputService.TouchEnabled then SC_TriggerMobileButton() else SC_PressSpace() end
                    task.wait(0.2); SC.Busy = false
                end)
            else
                local lr = line.Rotation % 360
                local gr = goal.Rotation % 360
                local sR = (gr + 102) % 360
                local eR = (gr + 116) % 360
                local success = (sR > eR and (lr >= sR or lr <= eR)) or (lr >= sR and lr <= eR)
                if success then
                    SC.Busy = true
                    task.spawn(function()
                        if UserInputService.TouchEnabled then SC_TriggerMobileButton() else SC_PressSpace() end
                        task.wait(0.05); SC.Busy = false
                    end)
                end
            end
        end)
    end
    function W.SkillCheck_Stop()
        if SC.Connection then SC.Connection:Disconnect(); SC.Connection = nil end
        SC.Busy = false
    end
    function W.SkillCheck_SetEnabled(v)
        SC.Enabled = v and true or false
        if SC.Enabled then W.SkillCheck_Start() else W.SkillCheck_Stop() end
    end

    --====================================================--
    -- BYPASS GENERATOR (FULL)
    --====================================================--
    W.GenBypass = W.GenBypass or {
        Enabled=false, Button=nil, UI=nil, Cache={}, CacheTimer=0,
        Processed={}, HotkeyCode=Enum.KeyCode.B, TriggerRange=8
    }
    local GenBypass = W.GenBypass
    function W.GB_GetAllGeneratorsCached()
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
        for _, g in pairs(W.GB_GetAllGeneratorsCached()) do
            for _, p in pairs(W.GB_GetPoints(g)) do
                local d = (hrp.Position - p.Position).Magnitude
                if d < bd then bd = d; best = p end
            end
        end
        return best, bd
    end
    function W.GB_IsPromptVisible()
        local ok2, fr = pcall(function() return LocalPlayer.PlayerGui.pcprompts.Frame.GeneratorRepair end)
        return ok2 and fr and fr.Visible
    end
    function W.GB_UpdateButton()
        if GenBypass.Enabled then
            if not GenBypass._Wrap or not GenBypass.UI or not GenBypass.UI.Parent then
                W.GB_CreateButton()
                task.wait(0.05)
            end
            if GenBypass._ShowCard then GenBypass._ShowCard() end
        else
            if GenBypass._HideCard then GenBypass._HideCard() end
        end
    end
    function W.GB_CreateButton()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return end
        local old = pg:FindFirstChild("BypassGenUI"); if old then old:Destroy() end
        if GenBypass._StopAnim then pcall(GenBypass._StopAnim); GenBypass._StopAnim = nil end
        GenBypass.UI = Instance.new("ScreenGui")
        GenBypass.UI.Name = "BypassGenUI"
        GenBypass.UI.ResetOnSpawn = false
        GenBypass.UI.IgnoreGuiInset = true
        GenBypass.UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        GenBypass.UI.DisplayOrder = 100
        GenBypass.UI.Parent = pg
        local wrap = Instance.new("Frame")
        wrap.Name = "Wrap"
        wrap.AnchorPoint = Vector2.new(1, 0)
        wrap.Position = UDim2.new(1, -20, 0.48, 0)
        wrap.Size = UDim2.fromOffset(110, 110)
        wrap.BackgroundTransparency = 1
        wrap.Active = true
        wrap.ZIndex = 2
        wrap.Parent = GenBypass.UI
        local glow = Instance.new("Frame")
        glow.Name = "Glow"
        glow.AnchorPoint = Vector2.new(0.5, 0.5)
        glow.Position = UDim2.new(0.5, 0, 0.5, 0)
        glow.Size = UDim2.fromOffset(88, 88)
        glow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        glow.BackgroundTransparency = 0.85
        glow.BorderSizePixel = 0
        glow.ZIndex = 1
        glow.Parent = wrap
        Instance.new("UICorner", glow).CornerRadius = UDim.new(1, 0)
        local mainCircle = Instance.new("Frame")
        mainCircle.Name = "MainCircle"
        mainCircle.AnchorPoint = Vector2.new(0.5, 0.5)
        mainCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
        mainCircle.Size = UDim2.fromOffset(64, 64)
        mainCircle.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
        mainCircle.BackgroundTransparency = 0.05
        mainCircle.BorderSizePixel = 0
        mainCircle.ZIndex = 4
        mainCircle.Parent = wrap
        Instance.new("UICorner", mainCircle).CornerRadius = UDim.new(1, 0)
        local mainGrad = Instance.new("UIGradient")
        mainGrad.Rotation = 135
        mainGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 36)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 10)),
        })
        mainGrad.Parent = mainCircle
        local mainStroke = Instance.new("UIStroke", mainCircle)
        mainStroke.Name = "MainStroke"
        mainStroke.Color = Color3.fromRGB(255, 255, 255)
        mainStroke.Thickness = 1.6
        mainStroke.Transparency = 0.15
        mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        local genText = Instance.new("TextLabel")
        genText.Name = "GenText"
        genText.AnchorPoint = Vector2.new(0.5, 0.5)
        genText.Position = UDim2.new(0.5, 0, 0.5, 0)
        genText.Size = UDim2.fromOffset(60, 30)
        genText.BackgroundTransparency = 1
        genText.Font = Enum.Font.GothamBlack
        genText.Text = "GEN"
        genText.TextColor3 = Color3.fromRGB(255, 255, 255)
        genText.TextSize = 20
        genText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        genText.TextStrokeTransparency = 0.5
        genText.ZIndex = 7
        genText.Parent = wrap
        local actionBtn = Instance.new("TextButton")
        actionBtn.Name = "ActionBtn"
        actionBtn.Size = UDim2.fromScale(1, 1)
        actionBtn.BackgroundTransparency = 1
        actionBtn.Text = ""
        actionBtn.AutoButtonColor = false
        actionBtn.ZIndex = 10
        actionBtn.Parent = wrap
        mainCircle.Size = UDim2.fromOffset(0, 0)
        glow.Size = UDim2.fromOffset(0, 0)
        genText.TextTransparency = 1
        genText.TextStrokeTransparency = 1
        GenBypass._Wrap = wrap
        GenBypass._Glow = glow
        GenBypass._MainCircle = mainCircle
        GenBypass._MainStroke = mainStroke
        GenBypass._GenText = genText
        GenBypass._ActionBtn = actionBtn
        local function ShowCard()
            wrap.Visible = true
            TweenService:Create(glow, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(88, 88),
                BackgroundTransparency = 0.85,
            }):Play()
            TweenService:Create(mainCircle, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(64, 64),
                BackgroundTransparency = 0.05,
            }):Play()
            TweenService:Create(genText, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextTransparency = 0,
                TextStrokeTransparency = 0.5,
            }):Play()
        end
        local function HideCard()
            TweenService:Create(glow, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.fromOffset(0, 0),
                BackgroundTransparency = 1,
            }):Play()
            TweenService:Create(mainCircle, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.fromOffset(0, 0),
                BackgroundTransparency = 1,
            }):Play()
            TweenService:Create(genText, TweenInfo.new(0.2), {
                TextTransparency = 1,
                TextStrokeTransparency = 1,
            }):Play()
            task.delay(0.3, function()
                if GenBypass._StopAnim then pcall(GenBypass._StopAnim); GenBypass._StopAnim = nil end
                if GenBypass.UI then pcall(function() GenBypass.UI:Destroy() end); GenBypass.UI = nil end
                GenBypass._Wrap = nil
                GenBypass._ShowCard = nil
                GenBypass._HideCard = nil
                GenBypass._SetStatus = nil
                GenBypass._Card = nil
            end)
        end
        GenBypass._ShowCard = ShowCard
        GenBypass._HideCard = HideCard
        local animActive = true
        GenBypass._StopAnim = function() animActive = false end
        task.spawn(function()
            local t = 0
            while animActive and wrap.Parent do
                t = t + 0.035
                if GenBypass.Enabled then
                    local pulse = (math.sin(t * 3) + 1) * 0.5
                    mainStroke.Transparency = 0.35 - pulse * 0.2
                    mainStroke.Thickness = 1.6 + pulse * 0.4
                    glow.BackgroundTransparency = 0.85 - pulse * 0.12
                    glow.Size = UDim2.fromOffset(88 + pulse * 5, 88 + pulse * 5)
                    genText.Rotation = math.sin(t * 1.2) * 1.5
                end
                task.wait(0.03)
            end
        end)
        local function SetStatus(mode)
            if mode == "ready" then
                mainStroke.Color = Color3.fromRGB(120, 255, 160)
                genText.TextColor3 = Color3.fromRGB(120, 255, 160)
                glow.BackgroundColor3 = Color3.fromRGB(120, 255, 160)
            elseif mode == "busy" then
                mainStroke.Color = Color3.fromRGB(255, 200, 100)
                genText.TextColor3 = Color3.fromRGB(255, 200, 100)
                glow.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
            elseif mode == "searching" then
                mainStroke.Color = Color3.fromRGB(150, 200, 255)
                genText.TextColor3 = Color3.fromRGB(150, 200, 255)
                glow.BackgroundColor3 = Color3.fromRGB(150, 200, 255)
            else
                mainStroke.Color = Color3.fromRGB(255, 255, 255)
                genText.TextColor3 = Color3.fromRGB(255, 255, 255)
                glow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            end
        end
        GenBypass._SetStatus = SetStatus
        local drag = false
        local dStart, sPos
        local dragDist = 0
        wrap.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                drag = true; dStart = inp.Position; sPos = wrap.Position; dragDist = 0
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if not drag then return end
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                local d = inp.Position - dStart
                dragDist = math.abs(d.X) + math.abs(d.Y)
                wrap.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                drag = false
            end
        end)
        actionBtn.MouseButton1Up:Connect(function()
            if not GenBypass.Enabled then return end
            if dragDist > 6 then return end
            TweenService:Create(mainCircle, TweenInfo.new(0.08), { Size = UDim2.fromOffset(54, 54) }):Play()
            task.delay(0.1, function()
                TweenService:Create(mainCircle, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(64, 64) }):Play()
            end)
            local ripple = Instance.new("Frame")
            ripple.AnchorPoint = Vector2.new(0.5, 0.5)
            ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
            ripple.Size = UDim2.fromOffset(64, 64)
            ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ripple.BackgroundTransparency = 0.55
            ripple.BorderSizePixel = 0
            ripple.ZIndex = 3
            ripple.Parent = wrap
            Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)
            TweenService:Create(ripple, TweenInfo.new(0.6), { Size = UDim2.fromOffset(160, 160), BackgroundTransparency = 1 }):Play()
            task.delay(0.6, function() if ripple then ripple:Destroy() end end)
            SetStatus("searching")
            local bp, bd = W.GB_GetNearestPoint()
            if bp and bd <= GenBypass.TriggerRange then
                SetStatus("busy")
                task.spawn(function()
                    W.GB_DoRepair(bp)
                    task.wait(0.5)
                    SetStatus("ready")
                end)
            else
                task.wait(0.6)
                SetStatus("standby")
            end
        end)
        task.spawn(function()
            task.wait(0.1)
            if GenBypass.Enabled then ShowCard() end
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
    Scheduler:Add("GenBypassCleanup", function()
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
    end, 2)
    function W.setGenBypass(v)
        GenBypass.Enabled = v
        W.GB_UpdateButton()
    end

    --====================================================--
    -- SILENT VEIL (FULL)
    --====================================================--
    local VeilState = { target = nil, lookVector = nil, velHistory = {} }
    local VeilVisuals = {}
    pcall(function()
        if typeof(Drawing) ~= "table" or not Drawing.new then return end
        local V = VeilVisuals
        local ACCENT = _G.GLUTO_ACCENT
        local BLACK  = Color3.fromRGB(0, 0, 0)
        local WHITE  = Color3.fromRGB(255, 255, 255)
        V.FOVOuterRing = Drawing.new("Circle"); V.FOVOuterRing.Color = BLACK; V.FOVOuterRing.Thickness = 3; V.FOVOuterRing.Filled = false; V.FOVOuterRing.Transparency = 0.4; V.FOVOuterRing.Visible = false; V.FOVOuterRing.NumSides = 90
        V.FOVMainRing = Drawing.new("Circle"); V.FOVMainRing.Color = ACCENT; V.FOVMainRing.Thickness = 1.6; V.FOVMainRing.Filled = false; V.FOVMainRing.Transparency = 0.85; V.FOVMainRing.Visible = false; V.FOVMainRing.NumSides = 90
        V.FOVInnerRing = Drawing.new("Circle"); V.FOVInnerRing.Color = ACCENT; V.FOVInnerRing.Thickness = 1; V.FOVInnerRing.Filled = false; V.FOVInnerRing.Transparency = 0.35; V.FOVInnerRing.Visible = false; V.FOVInnerRing.NumSides = 90
        V.FOVCrossLines = {}; for i = 1, 4 do local line = Drawing.new("Line"); line.Color = WHITE; line.Thickness = 1.5; line.Transparency = 0.9; line.Visible = false; V.FOVCrossLines[i] = line end
        V.FOVTicks = {}; for i = 1, 4 do local line = Drawing.new("Line"); line.Color = ACCENT; line.Thickness = 2.2; line.Transparency = 0.95; line.Visible = false; V.FOVTicks[i] = line end
        V.TrackerOuterRing = Drawing.new("Circle"); V.TrackerOuterRing.Color = BLACK; V.TrackerOuterRing.Thickness = 3; V.TrackerOuterRing.Filled = false; V.TrackerOuterRing.Transparency = 0.3; V.TrackerOuterRing.NumSides = 40; V.TrackerOuterRing.Visible = false
        V.TrackerMainRing = Drawing.new("Circle"); V.TrackerMainRing.Color = ACCENT; V.TrackerMainRing.Thickness = 1.6; V.TrackerMainRing.Filled = false; V.TrackerMainRing.Transparency = 0.9; V.TrackerMainRing.NumSides = 40; V.TrackerMainRing.Visible = false
        V.TrackerDotFill = Drawing.new("Circle"); V.TrackerDotFill.Color = ACCENT; V.TrackerDotFill.Thickness = 1; V.TrackerDotFill.Filled = true; V.TrackerDotFill.Transparency = 0.9; V.TrackerDotFill.Radius = 3; V.TrackerDotFill.NumSides = 20; V.TrackerDotFill.Visible = false
        V.TrackerDotOutline = Drawing.new("Circle"); V.TrackerDotOutline.Color = BLACK; V.TrackerDotOutline.Thickness = 3; V.TrackerDotOutline.Filled = false; V.TrackerDotOutline.Transparency = 0.3; V.TrackerDotOutline.Radius = 6; V.TrackerDotOutline.NumSides = 20; V.TrackerDotOutline.Visible = false
        V.TrackerLine = Drawing.new("Line"); V.TrackerLine.Color = ACCENT; V.TrackerLine.Thickness = 1.5; V.TrackerLine.Transparency = 0.6; V.TrackerLine.Visible = false
    end)
    local function Veil_IsSurvivorVeil(p)
        if not p or not p.Team or not p.Team.Name then return false end
        return string.find(string.lower(p.Team.Name), "survivor", 1, true) ~= nil
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
    local function Veil_HideFOV()
        local V = VeilVisuals
        local OFF = Vector2.new(-9999, -9999)
        if V.FOVOuterRing then V.FOVOuterRing.Visible = false; V.FOVOuterRing.Position = OFF; V.FOVOuterRing.Radius = 0; V.FOVOuterRing.Transparency = 1 end
        if V.FOVMainRing then V.FOVMainRing.Visible = false; V.FOVMainRing.Position = OFF; V.FOVMainRing.Radius = 0; V.FOVMainRing.Transparency = 1 end
        if V.FOVInnerRing then V.FOVInnerRing.Visible = false; V.FOVInnerRing.Position = OFF; V.FOVInnerRing.Radius = 0; V.FOVInnerRing.Transparency = 1 end
        if V.FOVCrossLines then for _, s in ipairs(V.FOVCrossLines) do s.Visible = false; s.From = OFF; s.To = OFF end end
        if V.FOVTicks then for _, s in ipairs(V.FOVTicks) do s.Visible = false; s.From = OFF; s.To = OFF end end
    end
    local function Veil_HideTracker()
        local V = VeilVisuals
        local OFF = Vector2.new(-9999, -9999)
        if V.TrackerOuterRing then V.TrackerOuterRing.Visible = false; V.TrackerOuterRing.Position = OFF; V.TrackerOuterRing.Radius = 0; V.TrackerOuterRing.Transparency = 1 end
        if V.TrackerMainRing then V.TrackerMainRing.Visible = false; V.TrackerMainRing.Position = OFF; V.TrackerMainRing.Radius = 0; V.TrackerMainRing.Transparency = 1 end
        if V.TrackerDotFill then V.TrackerDotFill.Visible = false; V.TrackerDotFill.Position = OFF; V.TrackerDotFill.Radius = 0 end
        if V.TrackerDotOutline then V.TrackerDotOutline.Visible = false; V.TrackerDotOutline.Position = OFF; V.TrackerDotOutline.Radius = 0 end
        if V.TrackerLine then V.TrackerLine.Visible = false; V.TrackerLine.From = OFF; V.TrackerLine.To = OFF end
    end
    local function Veil_HideAllVisuals() Veil_HideFOV(); Veil_HideTracker() end
    local function Veil_UpdateFOVVisuals(center)
        local V = VeilVisuals
        if not V.FOVOuterRing then return end
        local radius = VD.VeilFOV or 150
        local t = tick()
        local pulse = (math.sin(t * 3) + 1) * 0.5
        local slowPulse = (math.sin(t * 1.2) + 1) * 0.5
        V.FOVOuterRing.Position = center; V.FOVOuterRing.Radius = radius + 2; V.FOVOuterRing.Transparency = 0.3 + pulse * 0.15; V.FOVOuterRing.Visible = true
        V.FOVMainRing.Position = center; V.FOVMainRing.Radius = radius; V.FOVMainRing.Transparency = 0.7 + pulse * 0.25; V.FOVMainRing.Visible = true
        V.FOVInnerRing.Position = center; V.FOVInnerRing.Radius = radius - 10; V.FOVInnerRing.Transparency = 0.25 + slowPulse * 0.2; V.FOVInnerRing.Visible = true
        local gap, armLen = 4, 12
        V.FOVCrossLines[1].From = Vector2.new(center.X, center.Y - gap); V.FOVCrossLines[1].To = Vector2.new(center.X, center.Y - gap - armLen); V.FOVCrossLines[1].Visible = true
        V.FOVCrossLines[2].From = Vector2.new(center.X, center.Y + gap); V.FOVCrossLines[2].To = Vector2.new(center.X, center.Y + gap + armLen); V.FOVCrossLines[2].Visible = true
        V.FOVCrossLines[3].From = Vector2.new(center.X - gap, center.Y); V.FOVCrossLines[3].To = Vector2.new(center.X - gap - armLen, center.Y); V.FOVCrossLines[3].Visible = true
        V.FOVCrossLines[4].From = Vector2.new(center.X + gap, center.Y); V.FOVCrossLines[4].To = Vector2.new(center.X + gap + armLen, center.Y); V.FOVCrossLines[4].Visible = true
        local tickLen = 9
        for i = 1, 4 do
            local angle = (i - 1) * math.pi / 2
            local dirX, dirY = math.cos(angle), math.sin(angle)
            V.FOVTicks[i].From = Vector2.new(center.X + dirX * radius, center.Y + dirY * radius)
            V.FOVTicks[i].To = Vector2.new(center.X + dirX * (radius - tickLen), center.Y + dirY * (radius - tickLen))
            V.FOVTicks[i].Visible = true
        end
    end
    local function Veil_UpdateTrackerVisuals(targetScreenPos, dist)
        local V = VeilVisuals
        if not V.TrackerOuterRing then return end
        local t = tick()
        local pulse = (math.sin(t * 4) + 1) * 0.5
        local baseRadius = math.clamp(1000 / math.max(dist, 1), 20, 48)
        V.TrackerOuterRing.Position = targetScreenPos; V.TrackerOuterRing.Radius = baseRadius + 3; V.TrackerOuterRing.Transparency = 0.25 + pulse * 0.15; V.TrackerOuterRing.Visible = true
        V.TrackerMainRing.Position = targetScreenPos; V.TrackerMainRing.Radius = baseRadius; V.TrackerMainRing.Transparency = 0.75 + pulse * 0.2; V.TrackerMainRing.Visible = true
        V.TrackerDotFill.Position = targetScreenPos; V.TrackerDotFill.Radius = 2.5 + pulse * 1.2; V.TrackerDotFill.Transparency = 0.85 + pulse * 0.15; V.TrackerDotFill.Visible = true
        V.TrackerDotOutline.Position = targetScreenPos; V.TrackerDotOutline.Radius = 5 + pulse * 1.5; V.TrackerDotOutline.Transparency = 0.35; V.TrackerDotOutline.Visible = true
    end
    local function Veil_UpdateAimbot()
        if GetRole() ~= "Killer" then
            VeilState.target = nil; VeilState.lookVector = nil
            Veil_HideAllVisuals(); return
        end
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        if VD.VeilShowFOV and VD.VeilEnabled then Veil_UpdateFOVVisuals(center)
        else Veil_HideFOV() end
        if not VD.VeilEnabled then VeilState.target = nil; VeilState.lookVector = nil; Veil_HideTracker(); return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local nearest, nearestPart = nil, nil
        local bestDist = VD.VeilFOV or 150
        local bestStudDist = VD.VeilMaxDist or 500
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and Veil_IsSurvivorVeil(p) and p.Character then
                local pc = p.Character
                local isDown = pc:GetAttribute("Knocked") == true or pc:GetAttribute("HookProgressDepleting") == true
                if not isDown then
                    local hum = pc:FindFirstChildOfClass("Humanoid")
                    local targetPart = pc:FindFirstChild("UpperTorso") or pc:FindFirstChild("Torso") or pc:FindFirstChild("HumanoidRootPart")
                    if hum and hum.Health > 0 and targetPart then
                        local sp, on = cam:WorldToViewportPoint(targetPart.Position)
                        if on and sp.Z > 0 then
                            local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if sd < bestDist then
                                local studDist = (targetPart.Position - hrp.Position).Magnitude
                                if studDist <= bestStudDist then bestDist = sd; nearest = p; nearestPart = targetPart end
                            end
                        end
                    end
                end
            end
        end
        if nearest and nearest.Character and nearestPart then
            local tp = nearestPart.Position
            local hand = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
            local origin = (hand and hand:IsA("BasePart")) and hand.Position or hrp.Position
            local dir = tp - origin
            local dist = dir.Magnitude
            if dist > 0.1 and dist <= (VD.VeilMaxDist or 500) then
                local isAuraActive = char:GetAttribute("special") == true
                local prof
                if isAuraActive then
                    prof = { v0 = VD.VeilAuraSpearSpeed or 165, g = VD.VeilAuraSpearGravity or 96.5, windup = 0.10, latency = 0.04, maxlead = 25, scale = VD.VeilLeadMultiplier or 1.4 }
                else
                    prof = { v0 = VD.VeilSpearSpeed or 165, g = VD.VeilGravity or 103, windup = 0.10, latency = 0.04, maxlead = 45, scale = VD.VeilLeadMultiplier or 1.4 }
                end
                local aimPoint = tp
                if VD.VeilAutoPredict then
                    local vel = Veil_getCharacterVelocity(nearest.Character)
                    if vel.Magnitude > 0.5 then
                        local h0 = Vector3.new(dir.X, 0, dir.Z)
                        local _, tFlight = Veil_solvePitch(prof, h0.Magnitude, dir.Y)
                        local ping = 0.08
                        pcall(function() ping = math.clamp(LocalPlayer:GetNetworkPing(), 0, 0.35) end)
                        local delay = tFlight + prof.windup + ping + prof.latency
                        for _ = 1, 2 do
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
                if ahDist > 0.001 then VeilState.lookVector = ah.Unit * math.cos(pitch) + Vector3.new(0, math.sin(pitch), 0)
                else VeilState.lookVector = adir.Unit end
                VeilState.target = nearest
                if VD.VeilShowTracker then
                    local sp, vis = cam:WorldToViewportPoint(tp)
                    if vis and sp.Z > 0 then
                        local screenDist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if screenDist <= (VD.VeilFOV or 150) + 100 then
                            Veil_UpdateTrackerVisuals(Vector2.new(sp.X, sp.Y), dist)
                            local bottomCenter = Vector2.new(center.X, cam.ViewportSize.Y)
                            local V = VeilVisuals
                            if V.TrackerLine then V.TrackerLine.From = bottomCenter; V.TrackerLine.To = Vector2.new(sp.X, sp.Y); V.TrackerLine.Visible = true end
                        else Veil_HideTracker() end
                    end
                else Veil_HideTracker() end
            end
        else VeilState.target = nil; VeilState.lookVector = nil; Veil_HideTracker() end
    end
    local VeilHookState = { remoteHooked = false }
    local function Veil_setupInterceptor()
        if VeilHookState.remoteHooked then return end
        if typeof(hookmetamethod) ~= "function" then return end
        task.spawn(function()
            pcall(function()
                local oldNamecall
                oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                    local method = getnamecallmethod()
                    if not checkcaller() and method == "FireServer" then
                        if self.Name == "Spearthrow" and VD.VeilEnabled and typeof(VeilState.lookVector) == "Vector3" and GetRole() == "Killer" then
                            local args = {...}
                            if typeof(args[1]) == "Vector3" then args[1] = VeilState.lookVector end
                            return oldNamecall(self, unpack(args))
                        end
                    end
                    return oldNamecall(self, ...)
                end)
                VeilHookState.remoteHooked = true
            end)
        end)
    end
    Veil_setupInterceptor()
    Scheduler:Add("VeilAim", Veil_UpdateAimbot, 0.033)

    --====================================================--
    -- SILENT FLASHLIGHT (FULL)
    --====================================================--
    do
        VD.FLASH_SilentAim  = VD.FLASH_SilentAim  or false
        VD.FLASH_Laser      = VD.FLASH_Laser      ~= false
        VD.FLASH_TargetPart = VD.FLASH_TargetPart or "Head"
        VD.FLASH_Range      = VD.FLASH_Range      or 120
        VD.FLASH_Smooth     = VD.FLASH_Smooth     or 0.35
        local FlashState = { Active = false, LaserBeam = nil, FlashlightPart = nil, Hooked = false }
        local function Flash_GetActivateRemote()
            local r = ReplicatedStorage:FindFirstChild("Remotes")
            local i = r and r:FindFirstChild("Items")
            local f = i and i:FindFirstChild("Flashlight")
            local a = f and f:FindFirstChild("Activate")
            if a and a:IsA("RemoteEvent") then return a end
            return nil
        end
        local function Flash_GetTargetPart(char)
            if not char then return nil end
            local p = char:FindFirstChild(VD.FLASH_TargetPart or "Head")
            if p and p:IsA("BasePart") then return p end
            return char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso")
                or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
        end
        local function Flash_IsAliveChar(char)
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then return false end
            return char:GetAttribute("State") ~= "Dead"
        end
        local function Flash_GetTarget()
            local myChar = LocalPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myRoot then return nil end
            local maxR = tonumber(VD.FLASH_Range) or 120
            local best, bd = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and Flash_IsAliveChar(p.Character) and TeamIs(p, "Killer") then
                    local part = Flash_GetTargetPart(p.Character)
                    if part then
                        local d = (myRoot.Position - part.Position).Magnitude
                        if d <= maxR and d < bd then bd = d; best = part end
                    end
                end
            end
            return best
        end
        local function Flash_ClearLaser()
            if FlashState.LaserBeam then pcall(function() FlashState.LaserBeam:Destroy() end); FlashState.LaserBeam = nil end
        end
        local function Flash_GetOrigin(cam)
            local src = FlashState.FlashlightPart
            if typeof and typeof(src) == "Instance" then
                if src:IsA("BasePart") then return src.Position end
                local p = src:FindFirstChildWhichIsA("BasePart", true)
                if p then return p.Position end
            end
            local c = LocalPlayer.Character
            local hand = c and (c:FindFirstChild("RightHand") or c:FindFirstChild("Right Arm") or c:FindFirstChild("HumanoidRootPart"))
            if hand and hand:IsA("BasePart") then return hand.Position end
            return cam and cam.CFrame.Position or nil
        end
        local function Flash_UpdateLaser(op, tp)
            if not FlashState.LaserBeam then
                local l = Instance.new("Part")
                l.Name = "GlutoFlashlightLaser"
                l.Anchored = true
                l.CanCollide = false; l.CanTouch = false; l.CanQuery = false; l.CastShadow = false
                l.Material = Enum.Material.Neon
                l.Color = Color3.fromRGB(255, 255, 255)
                l.Transparency = 0
                l.Parent = Workspace
                FlashState.LaserBeam = l
            end
            local d = (tp - op).Magnitude
            if d < 0.1 then return end
            local l = FlashState.LaserBeam
            l.Size = Vector3.new(0.16, 0.16, d)
            l.CFrame = CFrame.new((op + tp) / 2, tp)
            l.Transparency = 0.35
        end
        Scheduler:Add("Flashlight", function()
            if not (VD.FLASH_SilentAim and FlashState.Active) then
                if FlashState.LaserBeam then FlashState.LaserBeam.Transparency = 1 end
                return
            end
            local cam = Workspace.CurrentCamera
            local tp = Flash_GetTarget()
            if not (cam and tp) then
                if FlashState.LaserBeam then FlashState.LaserBeam.Transparency = 1 end
                return
            end
            local smooth = math.clamp(tonumber(VD.FLASH_Smooth) or 0.35, 0.05, 1)
            local op = Flash_GetOrigin(cam)
            if VD.FLASH_Laser and op then
                pcall(Flash_UpdateLaser, op, tp.Position)
            elseif FlashState.LaserBeam then
                FlashState.LaserBeam.Transparency = 1
            end
            pcall(function() cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, tp.Position), smooth) end)
            pcall(function()
                local c = LocalPlayer.Character
                local hrp = c and c:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(tp.Position.X, hrp.Position.Y, tp.Position.Z)) end
            end)
        end, 0.033)
        W.Flash_SetEnabled = function(v)
            VD.FLASH_SilentAim = v and true or false
        end
        W.Flash_SetActive = function(active, part)
            FlashState.Active = active and true or false
            if FlashState.Active and part then FlashState.FlashlightPart = part
            elseif not FlashState.Active then FlashState.FlashlightPart = nil end
            if not FlashState.Active and FlashState.LaserBeam then
                FlashState.LaserBeam.Transparency = 1
            end
        end
        W.Flash_ClearLaser = Flash_ClearLaser
        task.spawn(function()
            pcall(function()
                local remote = Flash_GetActivateRemote()
                if not remote then return end
                if typeof(hookmetamethod) ~= "function" then return end
                if FlashState.Hooked then return end
                FlashState.Hooked = true
                local oldNC
                oldNC = hookmetamethod(game, "__namecall", function(self, ...)
                    if getnamecallmethod() == "FireServer" and self == remote then
                        local args = {...}
                        pcall(function() W.Flash_SetActive(args[2] == true, args[1]) end)
                    end
                    return oldNC(self, ...)
                end)
            end)
        end)
    end

    --====================================================--
    -- LOCK POV
    --====================================================--
    local LockPOV = { Enabled = false, LockedFOV = 80, OriginalFOV = nil, Connection = nil }
    local function LockPOV_Update()
        if not LockPOV.Enabled then return end
        local cam = Workspace.CurrentCamera
        if not cam then return end
        if math.abs(cam.FieldOfView - LockPOV.LockedFOV) > 0.1 then cam.FieldOfView = LockPOV.LockedFOV end
    end
    local function LockPOV_SetEnabled(en)
        LockPOV.Enabled = en and true or false
        if LockPOV.Enabled then
            local cam = Workspace.CurrentCamera
            if cam then
                LockPOV.OriginalFOV = cam.FieldOfView
                if LockPOV.Connection then LockPOV.Connection:Disconnect(); LockPOV.Connection = nil end
                cam.FieldOfView = LockPOV.LockedFOV
                LockPOV.Connection = RunService.RenderStepped:Connect(LockPOV_Update)
            end
        else
            if LockPOV.Connection then LockPOV.Connection:Disconnect(); LockPOV.Connection = nil end
            local cam = Workspace.CurrentCamera
            if cam and LockPOV.OriginalFOV then cam.FieldOfView = LockPOV.OriginalFOV end
        end
    end
    W.LockPOV = LockPOV
    W.LockPOV_SetEnabled = LockPOV_SetEnabled

    --====================================================--
    -- TOF (FULL)
    --====================================================--
    local ToFState = {
        Connection = nil, LaserBeam = nil, TargetGui = nil,
        InputBegan = nil, InputEnded = nil, TouchInput = nil,
        IsAiming = false, SavedUIPos = UDim2.new(0.5, -100, 0, 110),
        SCPCache = {}, SCPCacheTimer = 0
    }
    local ToFKeyCodes = { None=nil, Q=Enum.KeyCode.Q, E=Enum.KeyCode.E, R=Enum.KeyCode.R, T=Enum.KeyCode.T, F=Enum.KeyCode.F, G=Enum.KeyCode.G, H=Enum.KeyCode.H, J=Enum.KeyCode.J, K=Enum.KeyCode.K, L=Enum.KeyCode.L, X=Enum.KeyCode.X, Z=Enum.KeyCode.Z }
    local function ToF_IsDowned(c)
        if not c then return true end
        local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return true end
        local h = c:FindFirstChildOfClass("Humanoid"); if h and h.Health<=0 then return true end
        if c:GetAttribute("Knocked")==true then return true end
        if c:GetAttribute("IsHooked")==true then return true end
        if c:GetAttribute("IsCarried")==true then return true end
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
        if ra then local g = ra:FindFirstChild("gun"); if g then return g end
            local e = ra:FindFirstChild("EmperorGun"); if e then return e end end
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
        return workspace:Raycast(op, d.Unit * dist, rp) == nil
    end
    local function ToF_GetSCPs()
        if tick() - ToFState.SCPCacheTimer < 0.5 then return ToFState.SCPCache end
        local nt = {}
        local mf = workspace:FindFirstChild("Map")
        if mf then
            for _, c in pairs(mf:GetDescendants()) do
                if c:IsA("Model") then
                    local a = c:GetAttributes()
                    if c:GetAttribute("CorpseCreated0492") or next(a) ~= nil then
                        local r = c:FindFirstChild("HumanoidRootPart"); if r then table.insert(nt, r) end
                    end
                end
            end
        end
        ToFState.SCPCache = nt; ToFState.SCPCacheTimer = tick()
        return nt
    end
    local function ToF_GetTarget()
        local g = ToF_GetGun(); local c = LocalPlayer.Character
        if not (g and c) then return nil,nil,nil,nil end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil,nil,nil,nil end
        local mp = hrp.Position
        local op
        if c:GetAttribute("IsCarried") then op = hrp.Position + (hrp.CFrame.LookVector * 2)
        else
            pcall(function() op = g:IsA("BasePart") and g.Position or (g:FindFirstChildOfClass("BasePart") and g:FindFirstChildOfClass("BasePart").Position) end)
            op = op or Vector3.new(mp.X, mp.Y + 1.5, mp.Z)
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
                if p ~= LocalPlayer and TeamIs(p, "Killer") and p.Character then
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
                if p ~= LocalPlayer and TeamIs(p, "Survivor") and p.Character then
                    local t = p.Character:FindFirstChild("Torso") or p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("HumanoidRootPart")
                    if t then local dt = t.Position - cam.CFrame.Position
                        if dt.Magnitude>0.1 then local dot = cl:Dot(dt.Unit); if dot>0.5 and dot>bd then bd=dot; bt=t; bc=p.Character end end end
                end
            end
            if not bt then return nil,nil,nil,nil end
            return predict(bt, bc)
        elseif mode=="Zombie" then
            local bp, bd = nil, -math.huge
            local cam = workspace.CurrentCamera
            local cl = cam.CFrame.LookVector
            for _,r in ipairs(ToF_GetSCPs()) do
                if r and r.Parent then local dt = r.Position - cam.CFrame.Position
                    if dt.Magnitude>0.1 then local dot = cl:Dot(dt.Unit); if dot>0.5 and dot>bd then bd=dot; bp=r end end end
            end
            if not bp then return nil,nil,nil,nil end
            return predict(bp, bp.Parent)
        end
        return nil,nil,nil,nil
    end
    local function ToF_UpdateLaser(op, tp)
        if not ToFState.LaserBeam then
            local l = Instance.new("Part"); l.Name="ToFLaser"; l.Anchored=true; l.CanCollide=false; l.CanTouch=false; l.CastShadow=false
            l.Material=Enum.Material.Neon; l.Color=Color3.fromRGB(255,255,255); l.Parent=workspace
            ToFState.LaserBeam = l
        end
        local d = (tp-op).Magnitude
        ToFState.LaserBeam.Size = Vector3.new(0.05,0.05,d)
        ToFState.LaserBeam.CFrame = CFrame.new((op+tp)/2, tp)
        ToFState.LaserBeam.Transparency = 0
    end
    local function ToF_ClearLaser()
        if ToFState.LaserBeam then pcall(function() ToFState.LaserBeam:Destroy() end); ToFState.LaserBeam=nil end
    end
    local function ToF_GetMobileBtn()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local sm = pg and pg:FindFirstChild("Survivor-mob")
        local ct = sm and sm:FindFirstChild("Controls")
        local gm = ct and ct:FindFirstChild("Gui-mob")
        if not gm then return nil end
        for _,n in ipairs({"attack","Attack","shoot","Shoot","fire","Fire"}) do local b = gm:FindFirstChild(n,true); if b and b:IsA("GuiObject") then return b end end
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
    local ToF_BgColor = Color3.fromRGB(18, 18, 22)
    local ToF_HoverColor = Color3.fromRGB(38, 38, 46)
    local ToF_ModeConfig = { Killer={Color=Color3.fromRGB(255,90,90),Label="KILLER",Hint="K"}, Survivors={Color=Color3.fromRGB(120,200,255),Label="SURVIVOR",Hint="J"}, Zombie={Color=Color3.fromRGB(120,255,150),Label="ZOMBIE",Hint="L"} }
    local function ToF_RefreshButtons()
        for n, b in pairs(ToF_ModeButtons) do
            if b and b.Parent then
                local isActive = n == (VD.TOF_TargetMode or "Killer")
                local cfg = ToF_ModeConfig[n]
                local ind = b:FindFirstChild("Indicator"); local lb = b:FindFirstChild("ModeLabel"); local hn = b:FindFirstChild("HintLabel"); local st = b:FindFirstChildOfClass("UIStroke")
                if isActive then
                    TweenService:Create(b, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(32, 32, 40) }):Play()
                    if ind then TweenService:Create(ind, TweenInfo.new(0.25), { Size = UDim2.new(0, 3, 0.6, 0), BackgroundColor3 = cfg.Color, BackgroundTransparency = 0 }):Play() end
                    if lb then TweenService:Create(lb, TweenInfo.new(0.25), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play() end
                    if hn then TweenService:Create(hn, TweenInfo.new(0.25), { TextColor3 = cfg.Color, TextTransparency = 0 }):Play() end
                    if st then TweenService:Create(st, TweenInfo.new(0.25), { Color = Color3.fromRGB(80, 80, 92), Transparency = 0.2 }):Play() end
                else
                    TweenService:Create(b, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(24, 24, 30) }):Play()
                    if ind then TweenService:Create(ind, TweenInfo.new(0.25), { Size = UDim2.new(0, 3, 0, 0), BackgroundTransparency = 1 }):Play() end
                    if lb then TweenService:Create(lb, TweenInfo.new(0.25), { TextColor3 = Color3.fromRGB(140, 140, 152) }):Play() end
                    if hn then TweenService:Create(hn, TweenInfo.new(0.25), { TextColor3 = Color3.fromRGB(90, 90, 100), TextTransparency = 0.3 }):Play() end
                    if st then TweenService:Create(st, TweenInfo.new(0.25), { Color = Color3.fromRGB(45, 45, 55), Transparency = 0.5 }):Play() end
                end
            end
        end
    end
    local function ToF_SetTargetMode(mode, notify)
        if mode ~= "Killer" and mode ~= "Survivors" and mode ~= "Zombie" then return end
        VD.TOF_TargetMode = mode
        ToF_RefreshButtons()
        if notify then VD_Notify("ToF Target", mode, 1) end
    end
    local function ToF_DestroyUI()
        if ToFState.TargetGui then pcall(function() ToFState.TargetGui:Destroy() end); ToFState.TargetGui = nil end
        ToF_ModeButtons = {}
    end
    local function ToF_CreateUI()
        local parent = LocalPlayer:FindFirstChild("PlayerGui")
        if gethui then local ok2, hui = pcall(gethui); if ok2 and hui then parent = hui end end
        if not parent then return end
        if ToFState.TargetGui and ToFState.TargetGui.Parent then return end
        local old = parent:FindFirstChild("ToFTargetSelector")
        if old then pcall(function() old:Destroy() end) end
        local gui = Instance.new("ScreenGui")
        gui.Name = "ToFTargetSelector"; gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = parent
        local frame = Instance.new("Frame"); frame.Name = "Main"
        frame.Size = UDim2.new(0, 200, 0, 152); frame.Position = ToFState.SavedUIPos
        frame.BackgroundColor3 = ToF_BgColor; frame.BorderSizePixel = 0; frame.Active = true
        frame.ClipsDescendants = true; frame.ZIndex = 1; frame.Parent = gui
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
        frame.BackgroundTransparency = 0.85; frame.Size = UDim2.new(0, 160, 0, 122); frame.Rotation = 5
        local outerStroke = Instance.new("UIStroke", frame); outerStroke.Color = Color3.fromRGB(60, 60, 72); outerStroke.Thickness = 1; outerStroke.Transparency = 0.3; outerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        local accentBar = Instance.new("Frame"); accentBar.Size = UDim2.new(1, -20, 0, 2); accentBar.Position = UDim2.new(0, 10, 0, 0); accentBar.BorderSizePixel = 0; accentBar.ZIndex = 2; accentBar.Parent = frame
        local acGrad = Instance.new("UIGradient", accentBar); acGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200,200,220)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)) })
        Instance.new("UICorner", accentBar).CornerRadius = UDim.new(1, 0)
        local header = Instance.new("Frame"); header.Name = "Header"; header.Size = UDim2.new(1, 0, 0, 38); header.BackgroundTransparency = 1; header.ZIndex = 2; header.Parent = frame
        local ic = Instance.new("Frame"); ic.Size = UDim2.fromOffset(22, 22); ic.Position = UDim2.new(0, 12, 0.5, -11); ic.BackgroundColor3 = Color3.fromRGB(255, 255, 255); ic.BackgroundTransparency = 0.9; ic.BorderSizePixel = 0; ic.ZIndex = 3; ic.Parent = header
        Instance.new("UICorner", ic).CornerRadius = UDim.new(1, 0)
        local ics = Instance.new("UIStroke", ic); ics.Color = Color3.fromRGB(255, 255, 255); ics.Thickness = 1.4; ics.Transparency = 0.2
        local dlH = Instance.new("Frame"); dlH.Size = UDim2.fromOffset(14, 1); dlH.Position = UDim2.new(0.5, -7, 0.5, -0.5); dlH.BackgroundColor3 = Color3.fromRGB(255, 255, 255); dlH.BackgroundTransparency = 0.4; dlH.BorderSizePixel = 0; dlH.ZIndex = 3; dlH.Parent = ic
        local dlV = Instance.new("Frame"); dlV.Size = UDim2.fromOffset(1, 14); dlV.Position = UDim2.new(0.5, -0.5, 0.5, -7); dlV.BackgroundColor3 = Color3.fromRGB(255, 255, 255); dlV.BackgroundTransparency = 0.4; dlV.BorderSizePixel = 0; dlV.ZIndex = 3; dlV.Parent = ic
        local dt = Instance.new("Frame"); dt.Size = UDim2.fromOffset(8, 8); dt.Position = UDim2.new(0.5, -4, 0.5, -4); dt.BackgroundColor3 = Color3.fromRGB(255, 255, 255); dt.BorderSizePixel = 0; dt.ZIndex = 4; dt.Parent = ic
        Instance.new("UICorner", dt).CornerRadius = UDim.new(1, 0)
        local title = Instance.new("TextLabel"); title.Size = UDim2.new(1, -140, 0, 14); title.Position = UDim2.new(0, 42, 0, 8); title.BackgroundTransparency = 1; title.Font = Enum.Font.GothamBold; title.Text = "SILENT AIM"; title.TextColor3 = Color3.fromRGB(255, 255, 255); title.TextSize = 12; title.TextXAlignment = Enum.TextXAlignment.Left; title.ZIndex = 3; title.Parent = header
        local sub = Instance.new("TextLabel"); sub.Size = UDim2.new(1, -140, 0, 10); sub.Position = UDim2.new(0, 42, 0, 22); sub.BackgroundTransparency = 1; sub.Font = Enum.Font.Gotham; sub.Text = "Twist of Fate"; sub.TextColor3 = Color3.fromRGB(140, 140, 155); sub.TextSize = 9; sub.TextXAlignment = Enum.TextXAlignment.Left; sub.ZIndex = 3; sub.Parent = header
        local sp = Instance.new("Frame"); sp.Name = "StatusPill"; sp.AnchorPoint = Vector2.new(1, 0.5); sp.Size = UDim2.fromOffset(44, 18); sp.Position = UDim2.new(1, -36, 0.5, 0); sp.BackgroundColor3 = Color3.fromRGB(30, 30, 36); sp.BorderSizePixel = 0; sp.ZIndex = 3; sp.Parent = header
        Instance.new("UICorner", sp).CornerRadius = UDim.new(1, 0)
        local sps = Instance.new("UIStroke", sp); sps.Color = Color3.fromRGB(90, 90, 105); sps.Thickness = 1; sps.Transparency = 0.3
        local sd = Instance.new("Frame"); sd.Size = UDim2.fromOffset(5, 5); sd.Position = UDim2.new(0, 7, 0.5, -2.5); sd.BackgroundColor3 = Color3.fromRGB(255, 255, 255); sd.BorderSizePixel = 0; sd.ZIndex = 4; sd.Parent = sp
        Instance.new("UICorner", sd).CornerRadius = UDim.new(1, 0)
        local st = Instance.new("TextLabel"); st.Size = UDim2.new(1, -16, 1, 0); st.Position = UDim2.new(0, 15, 0, 0); st.BackgroundTransparency = 1; st.Font = Enum.Font.GothamBold; st.Text = "LIVE"; st.TextColor3 = Color3.fromRGB(220, 220, 230); st.TextSize = 8; st.TextXAlignment = Enum.TextXAlignment.Center; st.ZIndex = 4; st.Parent = sp
        local minBtn = Instance.new("TextButton"); minBtn.Name = "MinBtn"; minBtn.AnchorPoint = Vector2.new(1, 0.5); minBtn.Size = UDim2.fromOffset(22, 22); minBtn.Position = UDim2.new(1, -8, 0.5, 0); minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 36); minBtn.BorderSizePixel = 0; minBtn.Text = ""; minBtn.AutoButtonColor = false; minBtn.ZIndex = 4; minBtn.Parent = header
        Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)
        local mS = Instance.new("UIStroke", minBtn); mS.Color = Color3.fromRGB(90, 90, 105); mS.Thickness = 1; mS.Transparency = 0.3
        local mI = Instance.new("Frame"); mI.Name = "MinIcon"; mI.AnchorPoint = Vector2.new(0.5, 0.5); mI.Size = UDim2.fromOffset(10, 2); mI.Position = UDim2.new(0.5, 0, 0.5, 0); mI.BackgroundColor3 = Color3.fromRGB(220, 220, 230); mI.BorderSizePixel = 0; mI.ZIndex = 5; mI.Parent = minBtn
        Instance.new("UICorner", mI).CornerRadius = UDim.new(1, 0)
        local sep = Instance.new("Frame"); sep.Name = "Separator"; sep.Size = UDim2.new(1, -24, 0, 1); sep.Position = UDim2.new(0, 12, 0, 38); sep.BackgroundColor3 = Color3.fromRGB(45, 45, 55); sep.BorderSizePixel = 0; sep.ZIndex = 2; sep.Parent = frame
        local body = Instance.new("Frame"); body.Name = "Body"; body.Size = UDim2.new(1, -16, 1, -56); body.Position = UDim2.new(0, 8, 0, 44); body.BackgroundTransparency = 1; body.ZIndex = 2; body.Parent = frame
        local bl = Instance.new("UIListLayout", body); bl.FillDirection = Enum.FillDirection.Vertical; bl.SortOrder = Enum.SortOrder.LayoutOrder; bl.Padding = UDim.new(0, 4)
        ToF_ModeButtons = {}
        for i, m in ipairs({ {Internal="Killer",Order=1}, {Internal="Survivors",Order=2}, {Internal="Zombie",Order=3} }) do
            local cfg = ToF_ModeConfig[m.Internal]
            local btn = Instance.new("TextButton"); btn.Name = "ModeBtn_" .. m.Internal; btn.Size = UDim2.new(1, 0, 0, 26); btn.BackgroundColor3 = Color3.fromRGB(24, 24, 30); btn.BorderSizePixel = 0; btn.Text = ""; btn.AutoButtonColor = false; btn.LayoutOrder = m.Order; btn.ZIndex = 3; btn.Parent = body
            btn.Position = UDim2.new(-0.6, 0, 0, 0); btn.BackgroundTransparency = 0.6
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            local bs = Instance.new("UIStroke", btn); bs.Color = Color3.fromRGB(45, 45, 55); bs.Thickness = 1; bs.Transparency = 0.5
            local ind = Instance.new("Frame"); ind.Name = "Indicator"; ind.AnchorPoint = Vector2.new(0, 0.5); ind.Size = UDim2.new(0, 3, 0, 0); ind.Position = UDim2.new(0, 6, 0.5, 0); ind.BackgroundColor3 = cfg.Color; ind.BackgroundTransparency = 1; ind.BorderSizePixel = 0; ind.ZIndex = 4; ind.Parent = btn
            Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)
            local cd = Instance.new("Frame"); cd.Size = UDim2.fromOffset(6, 6); cd.Position = UDim2.new(0, 14, 0.5, -3); cd.BackgroundColor3 = cfg.Color; cd.BorderSizePixel = 0; cd.ZIndex = 4; cd.Parent = btn
            Instance.new("UICorner", cd).CornerRadius = UDim.new(1, 0)
            local lb = Instance.new("TextLabel"); lb.Name = "ModeLabel"; lb.Size = UDim2.new(1, -60, 1, 0); lb.Position = UDim2.new(0, 26, 0, 0); lb.BackgroundTransparency = 1; lb.Font = Enum.Font.GothamBold; lb.Text = cfg.Label; lb.TextColor3 = Color3.fromRGB(140, 140, 152); lb.TextSize = 11; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.ZIndex = 4; lb.Parent = btn
            local hn = Instance.new("TextLabel"); hn.Name = "HintLabel"; hn.AnchorPoint = Vector2.new(1, 0.5); hn.Size = UDim2.fromOffset(20, 18); hn.Position = UDim2.new(1, -8, 0.5, 0); hn.BackgroundColor3 = Color3.fromRGB(32, 32, 40); hn.BorderSizePixel = 0; hn.Font = Enum.Font.GothamBold; hn.Text = cfg.Hint; hn.TextColor3 = Color3.fromRGB(90, 90, 100); hn.TextSize = 9; hn.TextTransparency = 0.3; hn.ZIndex = 4; hn.Parent = btn
            Instance.new("UICorner", hn).CornerRadius = UDim.new(0, 4)
            btn.MouseEnter:Connect(function() if VD.TOF_TargetMode ~= m.Internal then TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = ToF_HoverColor }):Play() end end)
            btn.MouseLeave:Connect(function() if VD.TOF_TargetMode ~= m.Internal then TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(24, 24, 30) }):Play() end end)
            btn.MouseButton1Click:Connect(function() ToF_SetTargetMode(m.Internal, false) end)
            btn.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.Touch then ToF_SetTargetMode(m.Internal, false) end end)
            ToF_ModeButtons[m.Internal] = btn
        end
        local ft = Instance.new("Frame"); ft.Name = "Footer"; ft.AnchorPoint = Vector2.new(0.5, 1); ft.Size = UDim2.new(1, -16, 0, 18); ft.Position = UDim2.new(0.5, 0, 1, -6); ft.BackgroundTransparency = 1; ft.ZIndex = 3; ft.Parent = frame
        local flb = Instance.new("TextLabel"); flb.Size = UDim2.new(1, 0, 1, 0); flb.BackgroundTransparency = 1; flb.Font = Enum.Font.Gotham; flb.Text = "Drag header • K / J / L to swap"; flb.TextColor3 = Color3.fromRGB(90, 90, 100); flb.TextSize = 8; flb.TextXAlignment = Enum.TextXAlignment.Center; flb.ZIndex = 4; flb.Parent = ft
        ToF_RefreshButtons()
        task.spawn(function()
            task.wait(0.05)
            local eO = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            TweenService:Create(frame, eO, { Size = UDim2.new(0, 200, 0, 152), BackgroundTransparency = 0, Rotation = 0 }):Play()
            task.wait(0.08)
            for i, btn in ipairs(body:GetChildren()) do
                if btn:IsA("TextButton") then
                    task.delay(i * 0.06, function()
                        TweenService:Create(btn, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0 }):Play()
                    end)
                end
            end
            task.spawn(function()
                local t0 = tick()
                while frame and frame.Parent do
                    local b = (math.sin((tick() - t0) * 1.5) + 1) * 0.5
                    if outerStroke and outerStroke.Parent then
                        outerStroke.Transparency = 0.4 - b * 0.15
                        outerStroke.Color = Color3.fromRGB(math.floor(60 + b * 20), math.floor(60 + b * 20), math.floor(72 + b * 25))
                    end
                    task.wait(0.04)
                end
            end)
        end)
        local drg = false; local ds, sps2
        header.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then ds = inp.Position; sps2 = frame.Position; drg = true end end)
        header.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then drg = false end end)
        UserInputService.InputChanged:Connect(function(inp)
            if not drg then return end
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                local d = inp.Position - ds
                local np = UDim2.new(sps2.X.Scale, sps2.X.Offset + d.X, sps2.Y.Scale, sps2.Y.Offset + d.Y)
                frame.Position = np; ToFState.SavedUIPos = np
            end
        end)
        local min = false; local origSize = UDim2.new(0, 200, 0, 152)
        minBtn.MouseButton1Click:Connect(function()
            min = not min
            if min then
                origSize = frame.Size
                TweenService:Create(frame, TweenInfo.new(0.3), { Size = UDim2.new(0, 200, 0, 38) }):Play()
                body.Visible = false; sep.Visible = false; ft.Visible = false
                TweenService:Create(mI, TweenInfo.new(0.25), { Rotation = 90 }):Play()
            else
                TweenService:Create(frame, TweenInfo.new(0.3), { Size = origSize }):Play()
                task.wait(0.15)
                body.Visible = true; sep.Visible = true; ft.Visible = true
                TweenService:Create(mI, TweenInfo.new(0.25), { Rotation = 0 }):Play()
            end
        end)
        ToFState.TargetGui = gui
    end
    local function ToF_StartConn()
        if ToFState.Connection then return end
        ToFState.Connection = RunService.Heartbeat:Connect(function()
            if ToF_IsBlocked() then ToFState.IsAiming = false; if ToFState.TouchInput then ToFState.TouchInput = nil end; if ToFState.LaserBeam then ToFState.LaserBeam.Transparency = 1 end; return end
            if not VD.TOF_SilentAim or not ToFState.IsAiming then if ToFState.LaserBeam then ToFState.LaserBeam.Transparency = 1 end; return end
            local _, _, op, tp = ToF_GetTarget()
            if op and tp then
                pcall(function()
                    local c = LocalPlayer.Character
                    local hrp = c and c:FindFirstChild("HumanoidRootPart")
                    if hrp and not c:GetAttribute("IsCarried") then hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(tp.X, hrp.Position.Y, tp.Z)) end
                end)
                if VD.TOF_Laser then ToF_UpdateLaser(op, tp)
                elseif ToFState.LaserBeam then ToFState.LaserBeam.Transparency = 1 end
            elseif ToFState.LaserBeam then ToFState.LaserBeam.Transparency = 1 end
        end)
    end
    local function ToF_StopConn()
        if ToFState.Connection then pcall(function() ToFState.Connection:Disconnect() end); ToFState.Connection = nil end
        ToFState.IsAiming = false; ToF_ClearLaser()
    end
    local SetToFSilentAim
    local function ToF_EnsureInputs()
        if not ToFState.InputBegan then
            ToFState.InputBegan = UserInputService.InputBegan:Connect(function(inp, gp)
                if gp then return end
                local k = ToFKeyCodes[VD.TOF_Key or "None"]
                if k and inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == k then SetToFSilentAim(not VD.TOF_SilentAim); return end
                if not VD.TOF_SilentAim then return end
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or (inp.UserInputType == Enum.UserInputType.Touch and ToF_IsTouchShoot(inp)) then
                    if ToF_IsBlocked() then ToFState.IsAiming = false; return end
                    ToFState.IsAiming = true
                    if inp.UserInputType == Enum.UserInputType.Touch then ToFState.TouchInput = inp end
                    return
                end
                if inp.UserInputType == Enum.UserInputType.Keyboard then
                    if inp.KeyCode == Enum.KeyCode.K then ToF_SetTargetMode("Killer", true)
                    elseif inp.KeyCode == Enum.KeyCode.J then ToF_SetTargetMode("Survivors", true)
                    elseif inp.KeyCode == Enum.KeyCode.L then ToF_SetTargetMode("Zombie", true) end
                end
            end)
        end
        if not ToFState.InputEnded then
            ToFState.InputEnded = UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or (inp.UserInputType == Enum.UserInputType.Touch and inp == ToFState.TouchInput) then
                    local wa = ToFState.IsAiming
                    ToFState.IsAiming = false
                    if inp == ToFState.TouchInput then ToFState.TouchInput = nil end
                    if ToFState.LaserBeam then ToFState.LaserBeam.Transparency = 1 end
                    if wa then if ToF_IsBlocked() then return end; ToF_Shoot() end
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
    W.ToF_ClearLaser = ToF_ClearLaser
    W.ToF_SetTargetMode = ToF_SetTargetMode
    ToF_EnsureInputs()

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if W.Invisible and W.Invisible.Hotkey and input.KeyCode == W.Invisible.Hotkey then
            W.Invisible_Toggle()
        end
    end)

    --====================================================--
    -- PLAYER UTILITY (FULL, consolidated)
    --====================================================--
    local PU = {
        SpeedEnabled = false, SpeedValue = 16,
        SkipEndScreen = false, ShiftLock = false, NoCutscene = false,
        HideSurvivorIcon = false, ShowPingFPS = false, HideName = false,
        UnlimitedZoom = false, Noclip = false,
        _Connections = {},
        _FPS = { frames = 0, last = tick(), value = 0, ping = 0 },
        _origIcons = {}, _pingGui = nil,
        _shiftLockWasActive = false, _noCutsceneHooked = false,
        _hideNameConn = nil, _origCanCollide = {},
    }
    W.PU = PU

    local function PU_ShowInstantResults()
        if not PU.SkipEndScreen then return end
        pcall(function()
            local cam = workspace.CurrentCamera
            if cam then cam.CameraType = Enum.CameraType.Custom; cam.FieldOfView = 70 end
            UserInputService.MouseIconEnabled = true
            LocalPlayer:SetAttribute("isspectating", true)
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if pg then
                local Results  = pg:FindFirstChild("Results")
                local EndScreen= pg:FindFirstChild("EndScreen")
                local Darkness = pg:FindFirstChild("Darkness")
                if Results then Results.Enabled = true end
                if EndScreen then
                    EndScreen.Enabled = true
                    local bo = EndScreen:FindFirstChild("blackout")
                    if bo then bo.BackgroundTransparency = 1 end
                end
                if Darkness then
                    Darkness.Enabled = true
                    local f2 = Darkness:FindFirstChild("Frame2")
                    if f2 then f2.BackgroundTransparency = 1 end
                end
            end
        end)
    end
    task.spawn(function()
        local gf = ReplicatedStorage:WaitForChild("Remotes", 10)
        gf = gf and gf:WaitForChild("Game", 10)
        if not gf then return end
        for _, n in ipairs({"endscreencutscene","cutsceneEnd","cutsceneEnd2","cutsceneEndwithownchar"}) do
            local ev = gf:FindFirstChild(n)
            if ev and ev:IsA("RemoteEvent") then
                table.insert(PU._Connections, ev.OnClientEvent:Connect(PU_ShowInstantResults))
            end
        end
    end)
    local function PU_SetupNoCutsceneHook()
        if PU._noCutsceneHooked then return end
        PU._noCutsceneHooked = true
        pcall(function()
            local mt = getrawmetatable(game)
            if not mt then return end
            if setreadonly then setreadonly(mt, false) end
            local oldIndex = mt.__index
            local fakeBindable = Instance.new("BindableEvent")
            local fakeRemote   = Instance.new("RemoteEvent")
            mt.__index = newcclosure(function(t, k)
                if PU.NoCutscene and not checkcaller() and typeof(t) == "Instance" then
                    local nm = t.Name
                    if nm == "cutscene" and k == "Event" then
                        local p = t.Parent
                        if p and p.Name == "Game" then return fakeBindable.Event end
                    elseif nm == "cutsceneEnd" or nm == "cutsceneEnd2"
                        or nm == "cutsceneEndwithownchar" or nm == "endscreencutscene" then
                        local p = t.Parent
                        if p and p.Name == "Game" then return fakeRemote.OnClientEvent end
                    end
                end
                return oldIndex(t, k)
            end)
            if setreadonly then setreadonly(mt, true) end
        end)
    end
    task.spawn(PU_SetupNoCutsceneHook)

    local function PU_ApplyHideSurvivorIcon()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return end
        for _, gui in ipairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name:match("%-mob$") then
                local frame = gui:FindFirstChild("Frame")
                if frame then
                    for i = 1, 5 do
                        local sf = frame:FindFirstChild("Survivor" .. i)
                        if sf then
                            local il = sf:FindFirstChild("ImageLabel")
                            local tl = sf:FindFirstChild("TextLabel")
                            if il and il:IsA("ImageLabel") then
                                if not PU._origIcons[il] then
                                    PU._origIcons[il] = { Image = il.Image, ImageTransparency = il.ImageTransparency }
                                end
                                il.Image = "rbxassetid://92826170205694"
                                il.ImageTransparency = 0
                            end
                            if tl and tl:IsA("TextLabel") then
                                if not PU._origIcons[tl] then
                                    PU._origIcons[tl] = { Text = tl.Text, TextTransparency = tl.TextTransparency }
                                end
                                tl.Text = "ALFzxzz"
                                tl.TextTransparency = 0
                            end
                        end
                    end
                end
            end
        end
    end
    local function PU_RestoreSurvivorIcon()
        for obj, data in pairs(PU._origIcons) do
            if obj and obj.Parent then
                pcall(function()
                    if data.Image ~= nil and obj:IsA("ImageLabel") then
                        obj.Image = data.Image; obj.ImageTransparency = data.ImageTransparency
                    end
                    if data.Text ~= nil and obj:IsA("TextLabel") then
                        obj.Text = data.Text; obj.TextTransparency = data.TextTransparency
                    end
                end)
            end
        end
        PU._origIcons = {}
    end
    local function PU_CreatePingFPS()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return end
        if PU._pingGui and PU._pingGui.Parent then return end
        local old = pg:FindFirstChild("GlutoPU_PingFPS")
        if old then old:Destroy() end
        local sg = Instance.new("ScreenGui")
        sg.Name = "GlutoPU_PingFPS"; sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true; sg.Parent = pg
        local frame = Instance.new("Frame")
        frame.Size = UDim2.fromOffset(120, 44)
        frame.Position = UDim2.new(0, 12, 0, 120)
        frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        frame.BackgroundTransparency = 0.1
        frame.BorderSizePixel = 0
        frame.Parent = sg
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Thickness = 1
        local lbl = Instance.new("TextLabel")
        lbl.Name = "Label"
        lbl.Size = UDim2.new(1, -12, 1, -8)
        lbl.Position = UDim2.new(0, 6, 0, 4)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 13
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextYAlignment = Enum.TextYAlignment.Center
        lbl.Text = "PING: --ms\nFPS: --"
        lbl.Parent = frame
        PU._pingGui = sg
    end
    local function PU_GetPing()
        local ok, val = pcall(function()
            local stats = game:GetService("Stats")
            local net = stats and stats:FindFirstChild("Network")
            local sv = net and net:FindFirstChild("ServerStatsItem")
            local dp = sv and sv:FindFirstChild("Data Ping")
            if dp and dp.GetValue then return math.floor(dp:GetValue() + 0.5) end
        end)
        if ok and val then return val end
        return nil
    end
    local function PU_ProcessHideName(obj)
        if not obj then return end
        local ok, isText = pcall(function()
            return obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")
        end)
        if not ok or not isText then return end
        local txt = ""
        pcall(function() txt = tostring(obj.Text or "") end)
        if txt == "" then return end
        if txt == LocalPlayer.Name or txt == LocalPlayer.DisplayName
            or txt:find(LocalPlayer.Name, 1, true) ~= nil then
            pcall(function() obj.Visible = not PU.HideName end)
        end
    end
    local function PU_SetHideName(enabled)
        PU.HideName = enabled and true or false
        if PU._hideNameConn then pcall(function() PU._hideNameConn:Disconnect() end); PU._hideNameConn = nil end
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if not pg then return end
        for _, d in ipairs(pg:GetDescendants()) do PU_ProcessHideName(d) end
        if PU.HideName then
            PU._hideNameConn = pg.DescendantAdded:Connect(function(obj) task.defer(PU_ProcessHideName, obj) end)
        end
    end
    W.PU_SetHideName = PU_SetHideName

    local function PU_RestoreNoclip()
        for part, cc in pairs(PU._origCanCollide) do
            if part and part.Parent then pcall(function() part.CanCollide = cc end) end
        end
        PU._origCanCollide = {}
    end
    W.PU_RestoreNoclip = PU_RestoreNoclip
    LocalPlayer.CharacterRemoving:Connect(function(char)
        if char == LocalPlayer.Character then PU._origCanCollide = {} end
    end)

    Scheduler:Add("PU_Main", function()
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if PU.SpeedEnabled and hum and hum.WalkSpeed ~= PU.SpeedValue then
            hum.WalkSpeed = PU.SpeedValue
        end
        if PU.Noclip and char then
            for _, d in ipairs(char:GetDescendants()) do
                if d:IsA("BasePart") then
                    if PU._origCanCollide[d] == nil then PU._origCanCollide[d] = d.CanCollide end
                    d.CanCollide = false
                end
            end
        end
        if hum and root and Workspace.CurrentCamera then
            if PU.ShiftLock then
                hum.AutoRotate = false
                PU._shiftLockWasActive = true
                local look = Workspace.CurrentCamera.CFrame.LookVector
                local flat = Vector3.new(look.X, 0, look.Z)
                if flat.Magnitude > 0.001 then
                    root.CFrame = CFrame.new(root.Position, root.Position + flat.Unit)
                end
            elseif PU._shiftLockWasActive then
                hum.AutoRotate = true
                PU._shiftLockWasActive = false
            end
        end
        if PU.UnlimitedZoom then
            if LocalPlayer.CameraMaxZoomDistance ~= math.huge then LocalPlayer.CameraMaxZoomDistance = math.huge end
            if LocalPlayer.CameraMinZoomDistance ~= 0 then LocalPlayer.CameraMinZoomDistance = 0 end
        end
        if PU.HideSurvivorIcon then PU_ApplyHideSurvivorIcon() end
    end, 0.05)

    Scheduler:Add("PU_PingFPS", function()
        if not PU.ShowPingFPS then return end
        PU._FPS.frames = PU._FPS.frames + 1
        local now = tick()
        if now - PU._FPS.last < 0.5 then return end
        PU._FPS.value = math.floor(PU._FPS.frames / (now - PU._FPS.last) + 0.5)
        PU._FPS.ping = PU_GetPing() or 0
        PU._FPS.frames = 0
        PU._FPS.last = now
        if not (PU._pingGui and PU._pingGui.Parent) then PU_CreatePingFPS() end
        local lbl = PU._pingGui and PU._pingGui:FindFirstChild("Label", true)
        if lbl then
            lbl.Text = ("PING: %sms\nFPS: %d"):format(
                PU._FPS.ping > 0 and tostring(PU._FPS.ping) or "--", PU._FPS.value)
        end
    end, 0.5)

    --====================================================--
    -- EMOTE SYSTEM (FULL)
    --====================================================--
    W.EmoteSystem = W.EmoteSystem or {
        Enabled = false, CurrentTrack = nil, CurrentSound = nil, SelectedEmote = "Friday Night",
        Options = {
            "Friday Night", "WarCry", "24 Hour Cinderella", "Applause",
            "Arm Swing", "Backflip", "California Girls", "Christmas Spirit",
            "Floating Rest", "Ghoul", "Griddy", "Kyoufuu", "OnePlays", "Vulnerable",
        },
        Data = {
            ["Friday Night"]        = { Anim = "rbxassetid://83229063951016",  Sound = "rbxassetid://85355610204255" },
            ["WarCry"]              = { Anim = "rbxassetid://82600868380136",  Sound = "rbxassetid://120101930689931" },
            ["24 Hour Cinderella"]  = { Anim = "rbxassetid://137195203725366", Sound = "rbxassetid://121099446613414" },
            ["Applause"]            = { Anim = "rbxassetid://96328361165090",  Sound = "rbxassetid://115490787020749" },
            ["Arm Swing"]           = { Anim = "rbxassetid://80552139463944",  Sound = "rbxassetid://74216458932348" },
            ["Backflip"]            = { Anim = "rbxassetid://74705617908505",  Sound = nil },
            ["California Girls"]    = { Anim = "rbxassetid://123552803041504", Sound = "rbxassetid://87899327891544" },
            ["Christmas Spirit"]    = { Anim = "rbxassetid://137859761110514", Sound = nil },
            ["Floating Rest"]       = { Anim = "rbxassetid://114593021219597", Sound = nil },
            ["Ghoul"]               = { Anim = "rbxassetid://130415594909401", Sound = "rbxassetid://123004139176580" },
            ["Griddy"]              = { Anim = "rbxassetid://75586690784894",  Sound = nil },
            ["Kyoufuu"]             = { Anim = "rbxassetid://137322894494527", Sound = "rbxassetid://129064643026442" },
            ["OnePlays"]            = { Anim = "rbxassetid://140625405103474", Sound = "rbxassetid://94749073728335" },
            ["Vulnerable"]          = { Anim = "rbxassetid://121773684313913", Sound = "rbxassetid://135265751184744" },
        },
    }
    local ES = W.EmoteSystem
    function W.EmoteSystem_Stop()
        if ES.CurrentTrack then pcall(function() ES.CurrentTrack:Stop() end); ES.CurrentTrack = nil end
        if ES.CurrentSound then pcall(function() ES.CurrentSound:Destroy() end); ES.CurrentSound = nil end
    end
    function W.EmoteSystem_Play()
        W.EmoteSystem_Stop()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end
        local data = ES.Data[ES.SelectedEmote]
        if not data then return end
        if data.Anim then
            local anim = Instance.new("Animation")
            anim.AnimationId = data.Anim
            local track = hum:LoadAnimation(anim)
            track.Looped = true
            track.Priority = Enum.AnimationPriority.Action
            track:Play()
            ES.CurrentTrack = track
        end
        if data.Sound then
            local snd = Instance.new("Sound")
            snd.SoundId = data.Sound
            snd.Looped = true
            snd.Volume = 2
            snd.Parent = hrp
            snd:Play()
            ES.CurrentSound = snd
        end
    end
    function W.EmoteSystem_SetEnabled(v)
        ES.Enabled = v and true or false
        if ES.Enabled then W.EmoteSystem_Play() else W.EmoteSystem_Stop() end
    end
    function W.EmoteSystem_SelectEmote(name)
        if ES.Data[name] then
            ES.SelectedEmote = name
            if ES.Enabled then W.EmoteSystem_Play() end
        end
    end
    LocalPlayer.CharacterRemoving:Connect(function() W.EmoteSystem_Stop() end)
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        if ES.Enabled then W.EmoteSystem_Play() end
    end)

    if type(getgenv().ConfigData) ~= "table" then getgenv().ConfigData = {} end
    ConfigData = getgenv().ConfigData
    if type(getgenv().Elements) ~= "table" then getgenv().Elements = {} end
    Elements = getgenv().Elements
    if type(AutoSaveEnabled) ~= "boolean" then AutoSaveEnabled = true end
    ActiveConfigName = ActiveConfigName or nil
    ActiveConfigPath = ActiveConfigPath or nil
    ActiveConfigMode = ActiveConfigMode or nil
    if type(SetActiveConfig) ~= "function" then
        function SetActiveConfig(name, path, enabled, mode)
            ActiveConfigName = name; ActiveConfigPath = path; AutoSaveEnabled = enabled; ActiveConfigMode = mode
        end
    end
    if type(GetConfigSnapshot) ~= "function" then
        function GetConfigSnapshot()
            local snap = {}
            for k, v in pairs(ConfigData or {}) do snap[k] = v end
            return snap
        end
    end

    --====================================================--
    -- UI (FULL)
    --====================================================--
    local uiOK, uiErr = pcall(function()
        if not UILib then error("UILib tidak tersedia.") end
        local Window = UILib:Window({
            Title = "ALFzxzzz Hub - Premium",
            LogoButtonSize = 52,
            Image = "92826170205694",
            Footer = "Version : 0.3.2 Lite",
            Color = NotifyColor,
            ShowInfo = true,
            Version = 1,
            Search = true
        })
        Window:InfoTab({
            Name = "Information", Icon = "lightbulb",
            SectionTitle = "Information",
            Banner = "rbxassetid://92826170205694",
            Version = "Premium Access",
            DiscordLink = "https://discord.gg/NvZAbsYw",
            DiscordName = "ALFzxzzz Hub - Community",
            DiscordText = "Join Server Discord ALFzxzzz Untuk Informasi Update Dan Giveaway.",
            Cards = { { Title = "Credits", Description = "Owner = ALFzxzzz\nDeveloper = Vanzxzz" } }
        })

        local SurvivorTab = Window:AddTab({ Name = "Survivor", Icon = "user" })
        local VisualsTab  = Window:AddTab({ Name = "Visuals",  Icon = "eye" })
        local KillerTab   = Window:AddTab({ Name = "Killer",   Icon = "crosshair" })
        local MiscTab     = Window:AddTab({ Name = "Misc",     Icon = "settings-2" })
local TeleportTab = Window:AddTab({ Name = "Teleport", Icon = "map-pin" })
        local ConfigTab   = Window:AddTab({ Name = "Config",   Icon = "save" })

        -- SURVIVOR
        local escSection = SurvivorTab:AddSection("Instant Escape")
        escSection:AddToggle({ Title = "Enable Escape Button", Default = false, Callback = function(v)
            if getgenv().Gluto_Escape_SetEnabled then getgenv().Gluto_Escape_SetEnabled(v) end
            if v then VD_Notify("Escape Button", "Shown", 2) end
        end })
        escSection:AddButton({ Title = "Teleport Now", Callback = function() W.Escape_Teleport() end })

        local healSection = SurvivorTab:AddSection("Self Heal")
        healSection:AddToggle({ Title = "Self Heal Progress", Default = false, Callback = function(v)
            W.setInstantHealSelf(v)
            if getgenv().Gluto_SHB_UpdateVisual then getgenv().Gluto_SHB_UpdateVisual() end
            if v then VD_Notify("Self Heal", "Enabled", 2) end
        end })
        healSection:AddToggle({ Title = "Auto Heal All", Default = false, Callback = function(v)
            W.setAutoHealAll(v)
            if v then VD_Notify("Auto Heal All", "Enabled", 2) end
        end })
        healSection:AddToggle({ Title = "Show Self Heal Button", Default = false, Callback = function(v)
            if getgenv().Gluto_SHB_SetEnabled then getgenv().Gluto_SHB_SetEnabled(v) end
            if v then VD_Notify("Self Heal Button", "Shown", 2) end
        end })

        local vaultSection = SurvivorTab:AddSection("Swift Vault")
        vaultSection:AddToggle({ Title = "Swift Vault (Auto Vault)", Content = "Auto vault window saat lu dekat & bergerak", Default = VD.SURV_AutoVault, Callback = function(v)
            W.SwiftVault_SetEnabled(v)
            VD_Notify("Swift Vault", v and "Enabled" or "Disabled", 2)
        end })
        vaultSection:AddToggle({ Title = "Swift Vault V2 (Custom Speed)", Content = "Ubah kecepatan vault via attribute", Default = VD.SURV_FastVault, Callback = function(v)
            W.SwiftVaultV2_SetEnabled(v)
            VD_Notify("Swift Vault V2", v and "Enabled" or "Disabled", 2)
        end })
        vaultSection:AddSlider({ Title = "Vault Speed", Min = 10, Max = 20, Default = VD.SURF_VaultSpeed, Increment = 1,
            Callback = function(v) W.SwiftVault_SetSpeed(v) end })
        vaultSection:AddParagraph({ Title = "Info", Content = "• Swift Vault = auto vault saat lu dekat VaultTrigger & bergerak\n• Swift Vault V2 = custom vault speed (makin tinggi = makin cepat)\n• Cooldown antar vault 3 detik biar gak spam\n\nHanya aktif kalau role lu Survivor." })

        local palletReflexSection = SurvivorTab:AddSection("Pallet Reflex")
        palletReflexSection:AddToggle({ Title = "Enable Pallet Reflex", Content = "Auto drop pallet saat killer dekat lu", Default = VD.SURV_AutoPallet, Callback = function(v)
            W.PalletReflex_SetEnabled(v)
            VD_Notify("Pallet Reflex", v and "Enabled" or "Disabled", 2)
        end })
        palletReflexSection:AddSlider({ Title = "Trigger Distance", Min = 5, Max = 50, Default = VD.SURV_AutoPalletDist, Increment = 1, Suffix = " studs",
            Callback = function(v) W.PalletReflex_SetDistance(v) end })
        palletReflexSection:AddParagraph({ Title = "Info", Content = "• Auto drop pallet saat killer masuk jarak trigger\n• Radius 8 studs dari pallet terdekat\n• Cooldown 2.5s antar drop biar gak spam\n• Pallet yang udah di-drop gak akan di-drop lagi\n\nHanya aktif kalau role lu Survivor." })

local antiKnockSection = SurvivorTab:AddSection("Anti Knock")
antiKnockSection:AddToggle({
    Title = "Enable Anti Knock",
    Content = "Cegah knockdown / downed / hooked / carried state",
    Default = VD.SURV_AntiKnock,
    Callback = function(v)
        W.AntiKnock_SetEnabled(v)
        VD_Notify("Anti Knock", v and "Enabled" or "Disabled", 2)
    end
})
antiKnockSection:AddParagraph({
    Title = "Info",
    Content = "Auto reset semua state knockdown:\n\n• Knocked / Downed\n• Carried / Grabbed\n• Ragdolled / Physics\n• Health auto-restore\n\nCooldown 0.3s antar trigger.\n\nHanya aktif kalau role lu Survivor.",
})
local dodgeSpearSection = SurvivorTab:AddSection("Auto Dodge Spear")
dodgeSpearSection:AddToggle({
    Title = "Enable Auto Dodge Spear",
    Content = "Deteksi spear & dodge otomatis",
    Default = VD.SURV_AutoDodgeSpear,
    Callback = function(v)
        W.AutoDodgeSpear_SetEnabled(v)
        VD_Notify("Auto Dodge Spear", v and "Enabled" or "Disabled", 2)
    end
})
dodgeSpearSection:AddParagraph({
    Title = "Info",
    Content = "Deteksi spear yang mengarah ke lu & teleport perpendicular 90° dari trajectory.\n\n• Dodge Distance: 15 studs\n• Threshold: 0.75\n• Cooldown: 0.4s\n• Auto return ke posisi awal\n\nHanya aktif kalau role lu Survivor.",
})
        local fleeSection = SurvivorTab:AddSection("Auto Flee Killer")
        fleeSection:AddToggle({ Title = "Enable Auto Flee Killer", Content = "Otomatis teleport menjauh dari killer", Default = VD.SURV_AutoFlee, Callback = function(v)
            VD.SURV_AutoFlee = v
            VD_Notify("Auto Flee Killer", v and "Enabled" or "Disabled", 2)
        end })
        fleeSection:AddSlider({ Title = "Detect Distance", Min = 15, Max = 150, Default = VD.SURV_AutoFleeDist, Increment = 5, Suffix = " studs",
            Callback = function(v) VD.SURV_AutoFleeDist = v end })
        fleeSection:AddSlider({ Title = "Flee Cooldown", Min = 0.5, Max = 10, Default = VD.SURV_AutoFleeCooldown, Increment = 0.5, Suffix = "s",
            Callback = function(v) VD.SURV_AutoFleeCooldown = v end })
        fleeSection:AddParagraph({ Title = "Info", Content = "Auto teleport ke GeneratorPoint terjauh dari killer saat killer masuk jarak detect.\n\nHanya aktif kalau role kamu Survivor." })

        local fpSection = SurvivorTab:AddSection("Fake Perks")
        fpSection:AddToggle({ Title = "Flowstate (Buff on Vault/Slide)", Default = false, Callback = function(v)
            W.FP_SetupFlowstate(v)
            if v then VD_Notify("Fake Perks", "Flowstate Enabled", 2) end
        end })
        fpSection:AddToggle({ Title = "Quick Recovery (Buff on Heal)", Default = false, Callback = function(v)
            W.FP_SetupQuickRecovery(v)
            if v then VD_Notify("Fake Perks", "Quick Recovery Enabled", 2) end
        end })
        fpSection:AddToggle({ Title = "Perfect Landing (Buff on Land)", Default = false, Callback = function(v)
            W.FP_SetupPerfectLanding(v)
            if v then VD_Notify("Fake Perks", "Perfect Landing Enabled", 2) end
        end })
        fpSection:AddToggle({ Title = "Adrenaline Rush (Buff on Low HP)", Default = false, Callback = function(v)
            W.FP_SetupAdrenalineRush(v)
            if v then VD_Notify("Fake Perks", "Adrenaline Rush Enabled", 2) end
        end })
        fpSection:AddSlider({ Title = "Perk Cooldown Time", Min = 0, Max = 30, Default = 5, Increment = 1, Suffix = "s",
            Callback = function(v) W.FP.CooldownTime = v; ForceNotify("Fake Perks", "Cooldown: " .. v .. "s", 2) end })
        fpSection:AddButton({ Title = "Clear All Active Buffs", Callback = function()
            for k in pairs(W.FP.ActiveBuffs) do W.FP.ActiveBuffs[k] = nil end
            local c = LocalPlayer.Character
            if c then c:SetAttribute("speedboost", 1) end
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = 16 end
            ForceNotify("Fake Perks", "All buffs cleared", 2)
        end })

        local skillSection = SurvivorTab:AddSection("Auto Generator")
        skillSection:AddToggle({ Title = "Enable Auto Skill Check", Default = false, Callback = function(v)
            W.SkillCheck_SetEnabled(v)
            if v then VD_Notify("Auto Skill Check", "Enabled", 2) end
        end })
        skillSection:AddDropdown({ Title = "Skill Check Mode", Options = {"Legit", "Instant"}, Default = "Legit",
            Callback = function(v) W.SkillCheck.Mode = v end })

        local genSection = SurvivorTab:AddSection("Bypass Generator")
        genSection:AddToggle({ Title = "Enable Bypass Generator", Default = false, Callback = function(v)
            W.setGenBypass(v)
            if v then VD_Notify("Bypass Generator", "Enabled (Hotkey: B)", 3) end
        end })
        genSection:AddSlider({ Title = "Trigger Range", Min = 3, Max = 20, Default = 8, Increment = 1, Suffix = " studs",
            Callback = function(v) W.GenBypass.TriggerRange = v end })
        genSection:AddButton({ Title = "Force Repair Nearest Generator", Callback = function()
            local bp, bd = W.GB_GetNearestPoint()
            if bp and bd <= W.GenBypass.TriggerRange then W.GB_DoRepair(bp); ForceNotify("Bypass Generator", "Forcing repair...", 2)
            else ForceNotify("Bypass Generator", "Terlalu jauh dari generator", 2) end
        end })

        local trollSection = SurvivorTab:AddSection("Troll Teleport")
        trollSection:AddToggle({ Title = "Enable Troll Teleport", Default = false, Callback = function(v)
            W.TrollTeleport_SetEnabled(v)
            if getgenv().Gluto_TTB_UpdateVisual then getgenv().Gluto_TTB_UpdateVisual() end
            if v then VD_Notify("Troll Teleport", "Enabled", 2) end
        end })
        trollSection:AddToggle({ Title = "Show Troll TP Button", Default = false, Callback = function(v)
            if getgenv().Gluto_TTB_SetEnabled then getgenv().Gluto_TTB_SetEnabled(v) end
            if v then VD_Notify("Troll TP Button", "Shown", 2) end
        end })
        trollSection:AddButton({ Title = "Reset Trigger Counter", Callback = function()
            W.TrollTeleport.TriggerCount = 0; ForceNotify("Troll TP", "Counter di-reset", 2)
        end })

        local autoCrouchSection = SurvivorTab:AddSection("Auto Crouch Dodge")
        autoCrouchSection:AddToggle({ Title = "Enable Auto Crouch Dodge", Content = "Auto crouch saat killer pakai Abyssal S1", Default = VD.AutoCrouch, Callback = function(v)
            VD.AutoCrouch = v
            VD_Notify("Auto Crouch Dodge", v and "Enabled" or "Disabled", 2)
        end })
        autoCrouchSection:AddParagraph({ Title = "Info", Content = "Auto crouch otomatis saat killer (team Killer) memainkan animasi Abyssal S1 (ID 80411309607666) dalam jarak 40 stud.\n\nIni fitur dodge S1, bukan perma-crouch.\n\nCara pakai: aktifkan toggle, main sebagai Survivor." })

        local parrySection = SurvivorTab:AddSection("Auto Parry (Parrying Dagger)")
        parrySection:AddToggle({ Title = "Enable Auto Parry", Default = VD.PARRY_Enabled, Callback = function(v)
            VD.PARRY_Enabled = v
            if not v then ParryState.ActiveAttackers = {} end
            if getgenv().Gluto_ParryBtn_UpdateVisual then getgenv().Gluto_ParryBtn_UpdateVisual() end
            if v then VD_Notify("Auto Parry", "Enabled", 2) end
        end })
        parrySection:AddToggle({ Title = "Show Parry Button", Default = false, Callback = function(v)
            VD.PARRY_ShowFloatBtn = v
            if getgenv().Gluto_ParryBtn_SetEnabled then getgenv().Gluto_ParryBtn_SetEnabled(v) end
        end })
        parrySection:AddToggle({ Title = "Auto Parry Aggressive", Default = VD.PARRY_Aggressive, Callback = function(v) VD.PARRY_Aggressive = v end })
        parrySection:AddSlider({ Title = "Parry Distance", Min = 4, Max = 30, Default = VD.PARRY_Distance, Increment = 1, Callback = function(v) VD.PARRY_Distance = v end })
        parrySection:AddToggle({ Title = "Show Parry Range", Default = VD.PARRY_ShowCircle, Callback = function(v)
            VD.PARRY_ShowCircle = v
            if not v and getgenv()._Gluto_DestroyParryCircle then pcall(getgenv()._Gluto_DestroyParryCircle) end
        end })
        parrySection:AddToggle({ Title = "Parry (no animation)", Default = VD.PARRY_SilentParry, Callback = function(v) VD.PARRY_SilentParry = v end })

        local unhookSection = SurvivorTab:AddSection("Bypass Self Unhook")
        unhookSection:AddToggle({ Title = "Enable Bypass Self Unhook", Default = false, Callback = function(v)
            W.SU_SetEnabled(v)
            if getgenv().Gluto_SUB_UpdateVisual then getgenv().Gluto_SUB_UpdateVisual() end
            if v then VD_Notify("Bypass Self Unhook", "Enabled", 2) end
        end })
        unhookSection:AddToggle({ Title = "Show Self Unhook Button", Default = false, Callback = function(v)
            if getgenv().Gluto_SUB_SetEnabled then getgenv().Gluto_SUB_SetEnabled(v) end
            if v then VD_Notify("Self Unhook Button", "Shown", 2) end
        end })
        unhookSection:AddSlider({ Title = "Follow Duration", Min = 5, Max = 120, Default = 30, Increment = 5, Suffix = "s", Callback = function(v) W.SelfUnhook.FollowDuration = v end })
        unhookSection:AddSlider({ Title = "Follow Distance", Min = 5, Max = 60, Default = 20, Increment = 1, Suffix = " studs", Callback = function(v) W.SelfUnhook.FollowDistance = v end })
        unhookSection:AddSlider({ Title = "Re-Trigger Cooldown", Min = 1, Max = 15, Default = 3, Increment = 1, Suffix = "s", Callback = function(v) W.SelfUnhook._cooldown = v end })

        local tofSection = SurvivorTab:AddSection("Silent Aim (Twist of Fate)")
        tofSection:AddToggle({ Title = "Enable Silent Aim", Default = VD.TOF_SilentAim, Callback = function(v)
            SetToFSilentAim(v)
            if v then VD_Notify("Silent Aim TOF", "Enabled - Target GUI muncul", 2) end
        end })
        tofSection:AddKeybind({ Title = "Toggle Key", Default = Enum.KeyCode.Q, Callback = function(kc) VD.TOF_Key = kc and kc.Name or "None" end })
        tofSection:AddDropdown({ Title = "Target Mode", Options = { "Killer", "Survivors", "Zombie" }, Default = "Killer", Callback = function(v) ToF_SetTargetMode(v, true) end })
        tofSection:AddToggle({ Title = "Show Laser Beam", Default = true, Callback = function(v) VD.TOF_Laser = v; if not v then ToF_ClearLaser() end end })
        tofSection:AddToggle({ Title = "Wall Check", Default = true, Callback = function(v) VD.TOF_WallCheck = v end })
        tofSection:AddToggle({ Title = "Block When Knocked", Default = true, Callback = function(v) VD.TOF_BlockKnocked = v end })

        local flashSection = SurvivorTab:AddSection("Silent Flashlight")
        flashSection:AddToggle({ Title = "Enable Silent Flashlight", Content = "Auto-aim flashlight ke Killer terdekat", Default = VD.FLASH_SilentAim, Callback = function(v)
            W.Flash_SetEnabled(v)
            VD_Notify("Silent Flashlight", v and "Enabled" or "Disabled", 2)
        end })
        flashSection:AddDropdown({ Title = "Target Part", Options = {"Head", "UpperTorso", "Torso", "HumanoidRootPart"}, Default = VD.FLASH_TargetPart,
            Callback = function(v) VD.FLASH_TargetPart = type(v) == "table" and v[1] or v or "Head" end })
        flashSection:AddSlider({ Title = "Max Range", Min = 20, Max = 250, Default = VD.FLASH_Range, Increment = 5, Suffix = " studs",
            Callback = function(v) VD.FLASH_Range = v end })
        flashSection:AddSlider({ Title = "Smoothness", Min = 0.05, Max = 1, Default = VD.FLASH_Smooth, Increment = 0.05,
            Callback = function(v) VD.FLASH_Smooth = v end })
        flashSection:AddToggle({ Title = "Show Laser", Default = VD.FLASH_Laser, Callback = function(v)
            VD.FLASH_Laser = v
            if not v and W.Flash_ClearLaser then W.Flash_ClearLaser() end
        end })
        flashSection:AddParagraph({ Title = "Info", Content = "Auto-aim flashlight ke Killer terdekat saat flashlight diaktifkan." })

        -- VISUALS
        local ESPBox = VisualsTab:AddSection("Full ESP System")
        ESPBox:AddToggle({ Title = "ESP Survivor", Default = false, Callback = function(v) FESP.Survivor = v end })
        ESPBox:AddColorPicker({ Title = "Survivor Color",  Default = FESPC.Survivor,  Save = false, Callback = function(c) FESPC.Survivor = c end })
        ESPBox:AddToggle({ Title = "ESP Killer", Default = false, Callback = function(v) FESP.Killer = v end })
        ESPBox:AddColorPicker({ Title = "Killer Color",    Default = FESPC.Killer,    Save = false, Callback = function(c) FESPC.Killer = c end })
        ESPBox:AddToggle({ Title = "ESP Generator", Default = false, Callback = function(v) FESP.Generator = v end })
        ESPBox:AddColorPicker({ Title = "Generator Color", Default = FESPC.Generator, Save = false, Callback = function(c) FESPC.Generator = c end })
        ESPBox:AddToggle({ Title = "ESP Pallet", Default = false, Callback = function(v) FESP.Pallet = v end })
        ESPBox:AddColorPicker({ Title = "Pallet Color",    Default = FESPC.Pallet,    Save = false, Callback = function(c) FESPC.Pallet = c end })
        ESPBox:AddToggle({ Title = "ESP Window", Default = false, Callback = function(v) FESP.Window = v end })
        ESPBox:AddColorPicker({ Title = "Window Color",    Default = FESPC.Window,    Save = false, Callback = function(c) FESPC.Window = c end })
        ESPBox:AddToggle({ Title = "ESP SCP", Default = false, Callback = function(v) FESP.SCP = v end })
        ESPBox:AddColorPicker({ Title = "SCP Color",       Default = FESPC.SCP,       Save = false, Callback = function(c) FESPC.SCP = c end })
        ESPBox:AddSlider({ Title = "ESP Radius", Min = 10, Max = 1000, Default = 500, Increment = 10, Callback = function(v) FESP.Distance = v end })

        local ESPStatusBox = VisualsTab:AddSection("ESP Status")
        ESPStatusBox:AddToggle({ Title = "Enable Status ESP", Default = false, Callback = function(v) FESPS.Enabled = v end })
        ESPStatusBox:AddToggle({ Title = "Show Name", Default = true, Callback = function(v) FESPS.ShowName = v end })
        ESPStatusBox:AddToggle({ Title = "Show Distance", Default = true, Callback = function(v) FESPS.ShowDistance = v end })
        ESPStatusBox:AddToggle({ Title = "Show Avatar", Default = true, Callback = function(v) FESPS.ShowAvatar = v end })
        ESPStatusBox:AddToggle({ Title = "Show Action", Content = "Tampilkan aksi player (REPAIR / VAULT / HOOKED, dll)", Default = true, Callback = function(v) FESPS.ShowAction = v end })
        ESPStatusBox:AddToggle({ Title = "Show Health Bar", Default = false, Callback = function(v) FESPS.ShowHealth = v end })
        ESPStatusBox:AddSlider({ Title = "Status Radius", Min = 20, Max = 1000, Default = 500, Increment = 10, Callback = function(v) FESPS.Radius = v end })

        local graphicsSection = VisualsTab:AddSection("Graphics")
        graphicsSection:AddToggle({ Title = "Fullbright", Default = false, Callback = function(v)
            W.Graphics.Fullbright = v; W.Graphics_Apply()
        end })
        graphicsSection:AddToggle({ Title = "No Shadow", Default = false, Callback = function(v)
            W.Graphics.NoShadow = v; W.Graphics_Apply()
        end })
        graphicsSection:AddToggle({ Title = "Low Graphics", Content = "Turunin rendering quality ke Level 1", Default = false, Callback = function(v)
            W.Graphics.LowGraphics = v; W.Graphics_ApplyOptimization()
        end })
        graphicsSection:AddToggle({ Title = "No Screen Effects", Content = "Hapus ColorCorrection / Blur / Bloom dll", Default = false, Callback = function(v)
            W.Graphics.NoScreenEffects = v; W.Graphics_ApplyNoScreenFx()
        end })
        graphicsSection:AddToggle({ Title = "Clean Sky", Content = "Hapus Sky object dari Lighting", Default = false, Callback = function(v)
            W.Graphics.CleanSky = v; W.Graphics_ApplyOptimization()
        end })
        graphicsSection:AddToggle({ Title = "Potato Mode", Content = "EXTREME low graphics - part jadi plastic, particle/trail/beam mati, terrain flat. Cocok buat device kentang.", Default = false, Callback = function(v)
            if W.Potato_SetEnabled then
                W.Potato_SetEnabled(v)
                VD_Notify("Potato Mode", v and "Enabled - Processing..." or "Disabled - Restoring...", 3)
            end
        end })
        graphicsSection:AddParagraph({ Title = "Tentang Potato Mode", Content = "Mode extreme low graphics:\n\n• Semua part jadi Plastic\n• Reflectance & Shadow off\n• Texture/Decal invisible\n• Particle / Trail / Beam / Smoke off\n• Clouds off\n• Water flat\n• Quality Level 1\n\nToggle ON: butuh 5-15 detik proses.\nToggle OFF: restore semua normal." })

        local timeSection = VisualsTab:AddSection("Clock & Ambient")
        timeSection:AddToggle({ Title = "Enable Clock / Brightness Override", Default = false, Callback = function(v)
            W.Graphics.ClockTimeEnabled = v; W.Graphics_Apply()
        end })
        timeSection:AddSlider({ Title = "Clock Time", Min = 0, Max = 24, Default = 14, Increment = 1,
            Callback = function(v) W.Graphics.ClockTime = v; W.Graphics.ClockTimeEnabled = true; W.Graphics_Apply() end })
        timeSection:AddSlider({ Title = "Brightness", Min = 0, Max = 5, Default = 2, Increment = 0.1,
            Callback = function(v) W.Graphics.Brightness = v; W.Graphics.ClockTimeEnabled = true; W.Graphics_Apply() end })

        local zoomSection = VisualsTab:AddSection("Zoom & FOV")
        zoomSection:AddToggle({ Title = "Unlimited Zoom", Default = false, Callback = function(v)
            W.Graphics.UnlimitedZoom = v; W.Graphics_ApplyZoom()
        end })
        zoomSection:AddSlider({ Title = "Max Zoom Distance", Min = 100, Max = 5000, Default = 1000, Increment = 50,
            Callback = function(v) W.Graphics.MaxZoomDistance = v; if W.Graphics.UnlimitedZoom then W.Graphics_ApplyZoom() end end })
        zoomSection:AddToggle({ Title = "Custom FOV", Default = false, Callback = function(v)
            W.Graphics.FOVEnabled = v; W.Graphics_ApplyFOV()
        end })
        zoomSection:AddSlider({ Title = "Camera FOV", Min = 40, Max = 120, Default = 70, Increment = 5,
            Callback = function(v) W.Graphics.FOV = v; if W.Graphics.FOVEnabled then W.Graphics_ApplyFOV() end end })

local crosshairSection = VisualsTab:AddSection("Crosshair")
crosshairSection:AddToggle({
    Title = "Enable Crosshair",
    Default = false,
    Callback = function(v)
        W.Crosshair_SetEnabled(v)
        if v then VD_Notify("Crosshair", "Enabled", 2)
        else VD_Notify("Crosshair", "Disabled", 2) end
    end
})
crosshairSection:AddDropdown({
    Title = "Style",
    Options = {"Dot", "Plus", "X", "Circle"},
    Default = "Dot",
    Callback = function(v)
        VD.Crosshair_Style = v
        if W.Crosshair_Rebuild then W.Crosshair_Rebuild() end
    end
})
crosshairSection:AddColorPicker({
    Title = "Color",
    Default = VD.Crosshair_Color,
    Save = false,
    Callback = function(c)
        VD.Crosshair_Color = c
        if W.Crosshair_Rebuild then W.Crosshair_Rebuild() end
    end
})
crosshairSection:AddSlider({
    Title = "Size", Min = 1, Max = 20,
    Default = VD.Crosshair_Size, Increment = 1,
    Callback = function(v)
        VD.Crosshair_Size = v
        if W.Crosshair_Rebuild then W.Crosshair_Rebuild() end
    end
})
crosshairSection:AddSlider({
    Title = "Thickness", Min = 1, Max = 8,
    Default = VD.Crosshair_Thickness, Increment = 1,
    Callback = function(v)
        VD.Crosshair_Thickness = v
        if W.Crosshair_Rebuild then W.Crosshair_Rebuild() end
    end
})
crosshairSection:AddSlider({
    Title = "Gap", Min = 0, Max = 30,
    Default = VD.Crosshair_Gap, Increment = 1,
    Callback = function(v)
        VD.Crosshair_Gap = v
        if W.Crosshair_Rebuild then W.Crosshair_Rebuild() end
    end
})
crosshairSection:AddSlider({
    Title = "Offset X", Min = -200, Max = 200,
    Default = VD.Crosshair_OffsetX, Increment = 1,
    Callback = function(v)
        VD.Crosshair_OffsetX = v
        if W.Crosshair_Rebuild then W.Crosshair_Rebuild() end
    end
})
crosshairSection:AddSlider({
    Title = "Offset Y", Min = -200, Max = 200,
    Default = VD.Crosshair_OffsetY, Increment = 1,
    Callback = function(v)
        VD.Crosshair_OffsetY = v
        if W.Crosshair_Rebuild then W.Crosshair_Rebuild() end
    end
})
        local POVSection = VisualsTab:AddSection("Lock POV v2 (Field of View)")
        POVSection:AddToggle({ Title = "Enable Lock POV", Default = false, Callback = function(v) LockPOV_SetEnabled(v); if v then VD_Notify("Lock POV", "Enabled", 2) end end })
        POVSection:AddSlider({ Title = "Locked FOV", Min = 40, Max = 120, Default = 80, Increment = 5,
            Callback = function(v)
                LockPOV.LockedFOV = v
                if LockPOV.Enabled then local cam = Workspace.CurrentCamera; if cam then cam.FieldOfView = v end end
            end })

        -- KILLER
        local autoAttackSection = KillerTab:AddSection("Auto Attack")
        autoAttackSection:AddToggle({ Title = "Enable Auto Attack", Content = "Auto fire BasicAttack saat survivor dalam range", Default = VD.KILLER_AutoAttack, Callback = function(v)
            VD.KILLER_AutoAttack = v
            VD_Notify("Auto Attack", v and "Enabled" or "Disabled", 2)
        end })
        autoAttackSection:AddSlider({ Title = "Attack Range", Min = 5, Max = 30, Default = VD.KILLER_AutoAttackRange, Increment = 1, Suffix = " studs",
            Callback = function(v) VD.KILLER_AutoAttackRange = v end })
        autoAttackSection:AddSlider({ Title = "Attack Cooldown", Min = 0.05, Max = 1, Default = VD.KILLER_AutoAttackCooldown, Increment = 0.05, Suffix = "s",
            Callback = function(v) VD.KILLER_AutoAttackCooldown = v end })
        autoAttackSection:AddParagraph({ Title = "Info", Content = "Auto fire BasicAttack ke survivor terdekat dalam range.\n\nHanya aktif kalau role kamu Killer." })

        local maskedSection = KillerTab:AddSection("Select Masked Power")
        maskedSection:AddDropdown({ Title = "Masked Power", Options = Masked.Powers, Default = Masked.CurrentPower,
            Callback = function(v)
                local val = type(v) == "table" and v[1] or v
                Masked.CurrentPower = val
                VD_Notify("Select Masked", "Selected: " .. val, 1)
            end })
        maskedSection:AddButton({ Title = "Activate Power", Callback = function() W.Masked_Activate() end })
        maskedSection:AddButton({ Title = "Deactivate Power", Callback = function() W.Masked_Deactivate() end })

        local VeilSection = KillerTab:AddSection("Silent Spear Veil (BETA)")
        VeilSection:AddToggle({ Title = "Enable Silent Veil", Default = VD.VeilEnabled, Callback = function(v)
            VD.VeilEnabled = v
            if not v then VeilState.target = nil; VeilState.lookVector = nil; Veil_HideAllVisuals() end
            if getgenv().Gluto_VeilBtn_UpdateVisual then getgenv().Gluto_VeilBtn_UpdateVisual() end
            if v then VD_Notify("Silent Veil", "Enabled", 2) end
        end })
        VeilSection:AddToggle({ Title = "Show Veil Floating Button", Default = false, Callback = function(v)
            if getgenv().Gluto_VeilBtn_SetEnabled then getgenv().Gluto_VeilBtn_SetEnabled(v) end
            VD_Notify("Silent Veil Button", v and "Shown" or "Hidden", 2)
        end })
        VeilSection:AddToggle({ Title = "Show FOV Circle", Default = VD.VeilShowFOV, Callback = function(v) VD.VeilShowFOV = v end })
        VeilSection:AddToggle({ Title = "Show Target Tracker", Default = VD.VeilShowTracker, Callback = function(v) VD.VeilShowTracker = v end })
        VeilSection:AddToggle({ Title = "Auto Predict", Default = VD.VeilAutoPredict, Callback = function(v) VD.VeilAutoPredict = v end })
        VeilSection:AddSlider({ Title = "FOV Size", Min = 50, Max = 500, Default = VD.VeilFOV, Increment = 10, Callback = function(v) VD.VeilFOV = v end })
        VeilSection:AddSlider({ Title = "Max Distance", Min = 50, Max = 300, Default = VD.VeilMaxDist, Increment = 10, Callback = function(v) VD.VeilMaxDist = v end })
        VeilSection:AddSlider({ Title = "Spear Speed", Min = 50, Max = 400, Default = VD.VeilSpearSpeed, Increment = 5, Callback = function(v) VD.VeilSpearSpeed = v end })
        VeilSection:AddSlider({ Title = "Spear Gravity", Min = 10, Max = 300, Default = VD.VeilGravity, Increment = 1, Callback = function(v) VD.VeilGravity = v end })
        VeilSection:AddSlider({ Title = "Aura Spear Speed", Min = 50, Max = 400, Default = VD.VeilAuraSpearSpeed, Increment = 5, Callback = function(v) VD.VeilAuraSpearSpeed = v end })
        VeilSection:AddSlider({ Title = "Aura Spear Gravity", Min = 10, Max = 300, Default = VD.VeilAuraSpearGravity, Increment = 1, Callback = function(v) VD.VeilAuraSpearGravity = v end })
        VeilSection:AddSlider({ Title = "Lead Multiplier", Min = 0.1, Max = 5, Default = VD.VeilLeadMultiplier, Increment = 0.1, Callback = function(v) VD.VeilLeadMultiplier = v end })

local autoBreakGenSection = KillerTab:AddSection("Auto Break Generator")
autoBreakGenSection:AddToggle({
    Title = "Enable Auto Break Generator",
    Content = "Auto kick generator saat deket (radius 6 studs)",
    Default = VD.KILLER_AutoBreakGene,
    Callback = function(v)
        W.AutoBreakGen_SetEnabled(v)
        VD_Notify("Auto Break Generator", v and "Enabled" or "Disabled", 2)
    end
})
autoBreakGenSection:AddParagraph({
    Title = "Info",
    Content = "Auto detect generator dalam radius 6 studs & kick otomatis.\n\n• Cuma jalan kalau progress > 0% (generator lagi di-repair survivor)\n• Skip kalau progress >= 100% atau kickcount > 7\n• Cooldown 1.2s antar generator\n• Force unstuck kalau karakter freeze\n\nHanya aktif kalau role lu Killer.",
})
local autoDestroySection = KillerTab:AddSection("Auto Destroy Pallet")
autoDestroySection:AddToggle({
    Title = "Enable Auto Destroy Pallet",
    Content = "Auto destroy pallet saat deket (radius 6 studs)",
    Default = VD.KILLER_AutoDestroyPallet,
    Callback = function(v)
        W.AutoDestroyPallet_SetEnabled(v)
        VD_Notify("Auto Destroy Pallet", v and "Enabled" or "Disabled", 2)
    end
})
autoDestroySection:AddParagraph({
    Title = "Info",
    Content = "Auto detect pallet dalam radius 6 studs & destroy otomatis.\n\n• Cooldown 1.2s antar pallet\n• Force unstuck kalau karakter freeze\n• Skip kalau lu sedang stunned/carrying\n\nHanya aktif kalau role lu Killer.",
})
local infLungeSection = KillerTab:AddSection("Infinite Lunge")
infLungeSection:AddToggle({
    Title = "Enable Infinite Lunge",
    Content = "Bypass lunge cooldown (basic attack spam)",
    Default = VD.KILLER_InfLunge,
    Callback = function(v)
        W.InfLunge_SetEnabled(v)
        VD_Notify("Infinite Lunge", v and "Enabled" or "Disabled", 2)
    end
})
infLungeSection:AddParagraph({
    Title = "Info",
    Content = "fitur ini berfungsi untuk bisa menahan lebih lama attack",
})

local fakeAttackSection = KillerTab:AddSection("Counter Parry (Fake Attack)")
fakeAttackSection:AddToggle({
    Title = "Enable Counter Parry",
    Content = "Play attack anim weight 0 → trigger auto-parry survivor",
    Default = VD.KILLER_FakeAttack,
    Callback = function(v)
        W.FakeAttack_SetEnabled(v)
        VD_Notify("Counter Parry", v and "Enabled" or "Disabled", 2)
    end
})
fakeAttackSection:AddParagraph({
    Title = "Info",
    Content = "Play animasi attack dengan weight 0 (invisible) di deket survivor.\n\nSurvivor dengan Auto Parry bakal kepicu & cooldown parry mereka habis.\n\nSetelah cooldown parry mereka abis, lu bisa attack beneran tanpa diparry.\n\n• Trigger Range: 15 studs\n• Spam Cooldown: 0.35s\n\nHanya aktif kalau role lu Killer.",
})
        local bypassSection = KillerTab:AddSection("Bypass No Cooldown")
        bypassSection:AddToggle({ Title = "Hidden - Leap Bypass", Content = "Bypass cooldown skill Leap/Charge", Default = false,
            Callback = function(v) W.BYPASS_SetHiddenLeap(v); if v then VD_Notify("Bypass Cooldown", "Hidden Leap: ON", 2) end end })
        bypassSection:AddToggle({ Title = "Myers - Infinite Grab", Content = "Grab tanpa cooldown (hotkey H)", Default = false,
            Callback = function(v) W.setMyersGrab(v); if v then VD_Notify("Bypass Cooldown", "Inf Grab: ON (H = grab)", 2) end end })
        bypassSection:AddToggle({ Title = "Slasher - Infinite LakeMist", Content = "Bypass cooldown Lake Mist", Default = false,
            Callback = function(v) W.MAWWW_SetLakeMist(v); if v then VD_Notify("Bypass Cooldown", "Inf LakeMist: ON", 2) end end })
        bypassSection:AddToggle({ Title = "Slasher - Infinite Pursuit", Content = "Bypass cooldown Pursuit", Default = false,
            Callback = function(v) W.MAWWW_SetPursuit(v); if v then VD_Notify("Bypass Cooldown", "Inf Pursuit: ON", 2) end end })
        bypassSection:AddToggle({ Title = "Abyss - Bypass Cooldown", Content = "Force corrupt handler upvalues", Default = false,
            Callback = function(v) W.MAWWW_SetAbyssBypass(v); if v then VD_Notify("Bypass Cooldown", "Abyss Bypass: ON", 2) end end })
        bypassSection:AddToggle({ Title = "Jeff (The Killer) - Infinite Frenzy", Content = "Frenzy mode terus aktif", Default = false,
            Callback = function(v) W.MAWWW_SetJeffFrenzy(v); if v then VD_Notify("Bypass Cooldown", "Inf Frenzy: ON", 2) end end })
        bypassSection:AddButton({ Title = "Show Grab Floating Button", SubTitle = "Toggle", Callback = function()
            if getgenv().Gluto_MGrabBtn_SetEnabled then
                W.MyersGrabData._btnVisible = not W.MyersGrabData._btnVisible
                getgenv().Gluto_MGrabBtn_SetEnabled(W.MyersGrabData._btnVisible)
                ForceNotify("Myers Grab", W.MyersGrabData._btnVisible and "Button Shown" or "Button Hidden", 2)
            end
        end })
        bypassSection:AddButton({ Title = "Auto-Fix Boolean Math", SubTitle = "Run", Callback = function()
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
            ForceNotify("Bypass Cooldown", "Boolean math failsafe applied", 2)
        end })
        bypassSection:AddParagraph({ Title = "Info", Content = "• Hidden = Leap/Charge bypass\n• Myers = Grab tanpa cooldown (hotkey H)\n• Slasher = LakeMist & Pursuit infinite\n• Abyss = Corrupt handler bypass\n• Jeff = Frenzy mode infinite\n\nNote: fitur hanya aktif kalau role kamu killer-nya" })

        local spearSection = KillerTab:AddSection("Spear Aimbot")
        spearSection:AddToggle({ Title = "Enable Spear Aimbot", Content = "Auto-aim spear ke survivor dengan gravity compensation", Default = VD.SPEAR_Aimbot, Callback = function(v)
            W.SpearAimbot_SetEnabled(v)
            VD_Notify("Spear Aimbot", v and "Enabled" or "Disabled", 2)
        end })
        spearSection:AddSlider({ Title = "Spear Gravity", Min = 10, Max = 200, Default = VD.SPEAR_Gravity, Increment = 1,
            Callback = function(v) W.SpearAimbot_SetGravity(v) end })
        spearSection:AddSlider({ Title = "Spear Speed", Min = 50, Max = 300, Default = VD.SPEAR_Speed, Increment = 5,
            Callback = function(v) W.SpearAimbot_SetSpeed(v) end })
        spearSection:AddParagraph({ Title = "Info", Content = "• Auto-aim spear (Veil) ke survivor terdekat\n• Gravity compensation = hitung drop spear\n• Floating button:\n  - Klik tombol = toggle aim ON/OFF\n  - Panah < > = ganti target manual\n  - Label di atas = nama target (AUTO = auto pilih terdekat)\n\nHanya aktif kalau role lu Killer." })

        local killerAbilitySection = KillerTab:AddSection("Killer Abilities")
        killerAbilitySection:AddToggle({ Title = "Auto Stalk (Myers)", Content = "Otomatis stalk survivor terdekat (butuh Myers)", Default = KA.AutoStalk,
            Callback = function(v) W.KA_SetAutoStalk(v); VD_Notify("Auto Stalk", v and "Enabled" or "Disabled", 2) end })
        killerAbilitySection:AddSlider({ Title = "Auto Stalk Range", Min = 20, Max = 500, Default = KA.AutoStalkRange, Increment = 10, Suffix = " studs",
            Callback = function(v) KA.AutoStalkRange = v; VD.KA_AutoStalkRange = v end })
        killerAbilitySection:AddToggle({ Title = "Auto Kill All", Content = "Teleport & attack survivor terdekat otomatis", Default = KA.AutoKillAll,
            Callback = function(v) W.KA_SetAutoKillAll(v); VD_Notify("Auto Kill All", v and "Enabled" or "Disabled", 2) end })
        killerAbilitySection:AddToggle({ Title = "Drop All Pallet", Content = "Drop semua pallet di map secara otomatis", Default = KA.DropAllPallet,
            Callback = function(v) W.KA_SetDropAllPallet(v); VD_Notify("Drop All Pallet", v and "Enabled" or "Disabled", 2) end })
        killerAbilitySection:AddToggle({ Title = "Block All Vault", Content = "Block semua vault survivor di map", Default = KA.BlockAllVault,
            Callback = function(v) W.KA_SetBlockAllVault(v); VD_Notify("Block All Vault", v and "Enabled" or "Disabled", 2) end })
        killerAbilitySection:AddButton({ Title = "instant Auto Kill (1x)", Callback = function()
            local saved = KA.AutoKillAll
            KA.AutoKillAll = true
            task.spawn(function() task.wait(0.3); KA.AutoKillAll = saved end)
            VD_Notify("Auto Kill", "Triggered once", 2)
        end })
        killerAbilitySection:AddButton({ Title = "Instant Drop All Pallet (1x)", Callback = function()
            lastDropAllPallet = 0
            pcall(W.KA_DropAllPallets)
            VD_Notify("Drop All Pallet", "Triggered", 2)
        end })
        killerAbilitySection:AddButton({ Title = "Instant Block All Vault (1x)", Callback = function()
            lastBlockVault = 0
            pcall(W.KA_BlockAllVaults)
            VD_Notify("Block All Vault", "Triggered", 2)
        end })
        killerAbilitySection:AddParagraph({ Title = "Info", Content = "• Auto Stalk = stalk survivor (Myers ability)\n• Auto Kill All = teleport behind + basic attack\n• Drop All Pallet = semua pallet otomatis di-drop\n• Block All Vault = survivor ga bisa vault\n\nSemua fitur hanya aktif kalau role kamu Killer." })

        local flaskSection = KillerTab:AddSection("Silent Flask (The Cure)")
        flaskSection:AddToggle({ Title = "Enable Silent Flask", Content = "Auto-aim flask ke survivor terdekat dengan prediksi lintasan", Default = VD.FLASK_SilentAim, Callback = function(v)
            W.Flask_SetEnabled(v)
            VD_Notify("Silent Flask", v and "Enabled" or "Disabled", 2)
        end })
        flaskSection:AddToggle({ Title = "Show Beam", Content = "Beam dari tangan ke landing point", Default = VD.FLASK_ShowBeam, Callback = function(v) VD.FLASK_ShowBeam = v and true or false end })
        flaskSection:AddToggle({ Title = "Show Landing Marker", Content = "Ring di titik flask bakal jatuh", Default = VD.FLASK_ShowLanding, Callback = function(v) VD.FLASK_ShowLanding = v and true or false end })
        flaskSection:AddToggle({ Title = "Enable Prediction", Content = "Prediksi gerakan survivor + gravity drop", Default = VD.FLASK_Predict, Callback = function(v) VD.FLASK_Predict = v and true or false end })
        flaskSection:AddColorPicker({ Title = "Beam Color", Default = VD.FLASK_BeamColor, Save = false, Callback = function(c) W.Flask_SetBeamColor(c) end })
        flaskSection:AddColorPicker({ Title = "Accent Color", Default = VD.FLASK_AccentColor, Save = false, Callback = function(c) W.Flask_SetAccentColor(c) end })
        flaskSection:AddSlider({ Title = "Flask Speed", Min = 30, Max = 200, Default = VD.FLASK_Speed, Increment = 5,
            Callback = function(v) W.Flask_SetSpeed(v) end })
        flaskSection:AddSlider({ Title = "Flask Gravity", Min = 50, Max = 400, Default = VD.FLASK_Gravity, Increment = 5,
            Callback = function(v) W.Flask_SetGravity(v) end })
        flaskSection:AddSlider({ Title = "Lead Multiplier", Min = 0, Max = 3, Default = VD.FLASK_LeadMult, Increment = 0.1,
            Callback = function(v) W.Flask_SetLead(v) end })
        flaskSection:AddSlider({ Title = "Max Range", Min = 50, Max = 500, Default = VD.FLASK_Range, Increment = 10, Suffix = " studs",
            Callback = function(v) W.Flask_SetRange(v) end })
        flaskSection:AddParagraph({ Title = "Info", Content = "• Beam = garis putih dari tangan ke titik jatuh flask\n• Accent = outline gelap (RGB 25,25,25) sesuai theme UI\n• Landing marker = ring putih di tanah tempat flask mendarat\n• Prediction = hitung gerakan survivor + gravity drop\n\nTuning Speed & Gravity kalau beam gak akurat:\n- Beam kelebihan tinggi → kecilin Gravity\n- Beam kurang tinggi → besarin Gravity\n- Beam ke belakang target → besarin Speed\n\nHanya aktif kalau role lu Killer & pegang The Cure." })

local dashLockSection = KillerTab:AddSection("Dash Lock")
dashLockSection:AddToggle({
    Title = "Enable Dash Lock",
    Content = "Camera lock ke survivor terdekat (skip down/hooked)",
    Default = VD.DashLockEnabled,
    Callback = function(v)
        W.DashLock_SetEnabled(v)
        VD_Notify("Dash Lock", v and "Enabled" or "Disabled", 2)
    end
})
dashLockSection:AddSlider({
    Title = "Dash Lock Duration (s)", Min = 0.5, Max = 3,
    Default = 1.5, Increment = 0.1,
    Callback = function(v) VD.DashLockDuration = v end
})
dashLockSection:AddSlider({
    Title = "Dash Lock Smoothness", Min = 0.05, Max = 1,
    Default = 0.3, Increment = 0.05,
    Callback = function(v) VD.DashLockSmoothness = v end
})
dashLockSection:AddToggle({
    Title = "Freeze Character during Dash Lock",
    Default = false,
    Callback = function(v)
        VD.FreezeDuringDashLock = v and true or false
        if not v then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed == 0 then hum.WalkSpeed = 16 end
        end
    end
})
dashLockSection:AddParagraph({
    Title = "Info",
    Content = "Sistem asli + filter skip:\n\n• Camera lock ke survivor terdekat saat anim dash/leap\n• Anim ID: 98163597193511\n• SKIP survivor yang sedang:\n  - Downed / Knocked\n  - Hooked / Carried\n  - Grabbed / Ragdolled\n  - Dead\n• Kalau semua survivor lagi down → camera lepas\n\nHanya aktif kalau role lu Killer.",
})

        -- MISC
local hookCounterSection = KillerTab:AddSection("Hook Counter")
hookCounterSection:AddToggle({
    Title = "Show Hook Counter",
    Content = "Nampilin jumlah hook di icon survivor (0/1/2/DEAD)",
    Default = VD.HookCounter_Enabled,
    Callback = function(v)
        W.HookCounter_SetEnabled(v)
        VD_Notify("Hook Counter", v and "Enabled" or "Disabled", 2)
    end
})
hookCounterSection:AddParagraph({
    Title = "Info",
    Content = "• Hooks: 0 = belum pernah di-hook\n• Hooks: 1 = udah 1x di-hook (kuning)\n• Hooks: 2 = udah 2x di-hook (orange)\n• DEAD = udah 3x hook, mau mati (merah)\n\nCounter muncul di atas icon survivor di GUI killer.\n\nHanya aktif kalau role kamu Killer.",
})
        local settingsSection = MiscTab:AddSection("Settings")
        settingsSection:AddToggle({ Title = "Enable Notifications", Default = true, Callback = function(v)
            W.NotifyEnabled = v
            if v then ForceNotify("Settings", "Notifications Enabled") end
        end })

        local stunSection = MiscTab:AddSection("Stun Indicator")
        stunSection:AddToggle({ Title = "Enable Stun Indicator", Default = false, Callback = function(v)
            W.SInd_SetEnabled(v)
            if v then VD_Notify("Stun Indicator", "Enabled", 2) end
        end })
        stunSection:AddDropdown({
            Title = "Stun Sound",
            Options = { "Default", "Clash Royale", "Blash", "Coin", "Kururin Kuru",
                        "Spongebob", "Fahhhh", "Cave", "Aughhh", "Samsung", "iPhone", "Siren" },
            Default = "Default",
            Callback = function(v)
                local val = type(v) == "table" and v[1] or v
                SInd.SelectedSound = val
                local id = W.StunSounds[val] or SInd.SoundId
                ForceNotify("Stun Indicator", "Sound: " .. val .. " (" .. id .. ")", 2)
            end
        })
        stunSection:AddToggle({ Title = "Stun Sound Alert", Default = true, Callback = function(v) SInd.SoundEnabled = v end })
        stunSection:AddButton({ Title = "Preview Selected Sound", Callback = function()
            pcall(function()
                local snd = Instance.new("Sound")
                snd.SoundId = "rbxassetid://" .. tostring(SInd_GetActiveSoundId())
                snd.Volume = SInd.SoundVolume or 1.5
                snd.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or Workspace
                snd:Play()
                snd.Ended:Connect(function() pcall(function() snd:Destroy() end) end)
                task.delay(5, function() pcall(function() if snd and snd.Parent then snd:Destroy() end end) end)
            end)
            ForceNotify("Stun Indicator", "Playing: " .. SInd.SelectedSound, 2)
        end })
        stunSection:AddSlider({ Title = "Stun Detect Range", Min = 50, Max = 2000, Default = 500, Increment = 25, Suffix = " studs",
            Callback = function(v) SInd.Range = v end })
        stunSection:AddSlider({ Title = "Stun Sound Volume", Min = 0, Max = 5, Default = 1.5, Increment = 0.1,
            Callback = function(v) SInd.SoundVolume = v end })

        local invisSection = MiscTab:AddSection("Invisible")
        invisSection:AddToggle({ Title = "Enable Invisible", Default = false, Callback = function(v)
            W.Invisible_SetEnabled(v)
            if getgenv().Gluto_InvisBtn_UpdateVisual then getgenv().Gluto_InvisBtn_UpdateVisual() end
            if v then VD_Notify("Invisible", "Enabled", 2) end
        end })
        invisSection:AddToggle({ Title = "Show Invisible Floating Button", Default = false, Callback = function(v)
            if getgenv().Gluto_InvisBtn_SetEnabled then getgenv().Gluto_InvisBtn_SetEnabled(v) end
            if v then VD_Notify("Invisible Button", "Shown", 2) end
        end })
        invisSection:AddKeybind({ Title = "Toggle Hotkey", Default = Enum.KeyCode.G, Callback = function(kc)
            W.Invisible_SetHotkey(kc)
            ForceNotify("Invisible", "Hotkey: " .. (kc and kc.Name or "None"), 2)
        end })

        local puSection = MiscTab:AddSection("Player Utility")
        puSection:AddToggle({ Title = "Speed Hack", Default = false, Callback = function(v)
            PU.SpeedEnabled = v and true or false
            if not v then
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = 16 end
            end
            if v then VD_Notify("Player Utility", "Speed Hack ON", 2) end
        end })
        puSection:AddSlider({ Title = "Speed Value", Min = 16, Max = 200, Default = 16, Increment = 1,
            Callback = function(v) PU.SpeedValue = v end })
        puSection:AddToggle({ Title = "Skip End Screen", Default = false, Callback = function(v)
            PU.SkipEndScreen = v and true or false
            if v then VD_Notify("Player Utility", "Skip End Screen ON", 2) end
        end })
        puSection:AddToggle({ Title = "Shift Lock", Default = false, Callback = function(v)
            PU.ShiftLock = v and true or false
            if not v and PU._shiftLockWasActive then
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum.AutoRotate = true end) end
                PU._shiftLockWasActive = false
            end
            if v then VD_Notify("Player Utility", "Shift Lock ON", 2) end
        end })
        puSection:AddToggle({ Title = "Hide Survivor Icon", Default = false, Callback = function(v)
            PU.HideSurvivorIcon = v and true or false
            if v then PU_ApplyHideSurvivorIcon() else PU_RestoreSurvivorIcon() end
            if v then VD_Notify("Player Utility", "Hide Survivor Icon ON", 2) end
        end })
        puSection:AddToggle({ Title = "Show Ping & FPS", Default = false, Callback = function(v)
            PU.ShowPingFPS = v and true or false
            if v then
                PU_CreatePingFPS()
                PU._FPS.frames = 0
                PU._FPS.last = tick()
                VD_Notify("Player Utility", "Ping & FPS ON", 2)
            elseif PU._pingGui then
                pcall(function() PU._pingGui:Destroy() end)
                PU._pingGui = nil
            end
        end })
        puSection:AddToggle({ Title = "Hide Name", Default = false, Callback = function(v)
            PU_SetHideName(v)
            if v then VD_Notify("Player Utility", "Hide Name ON", 2) end
        end })
        puSection:AddToggle({ Title = "Unlimited Zoom", Default = false, Callback = function(v)
            PU.UnlimitedZoom = v and true or false
            if not v then
                pcall(function()
                    LocalPlayer.CameraMaxZoomDistance = 128
                    LocalPlayer.CameraMinZoomDistance = 0.5
                end)
            end
            if v then VD_Notify("Player Utility", "Unlimited Zoom ON", 2) end
        end })
        puSection:AddToggle({ Title = "Noclip", Default = false, Callback = function(v)
            PU.Noclip = v and true or false
            if not v then PU_RestoreNoclip() end
            if v then VD_Notify("Player Utility", "Noclip ON", 2) end
        end })

        local emoteSection = MiscTab:AddSection("Emote")
        emoteSection:AddToggle({ Title = "Enable Emote", Default = false, Callback = function(v)
            W.EmoteSystem_SetEnabled(v)
            if v then VD_Notify("Emote", "Playing: " .. W.EmoteSystem.SelectedEmote, 2)
            else VD_Notify("Emote", "Stopped", 2) end
        end })
        emoteSection:AddDropdown({ Title = "Select Emote", Options = W.EmoteSystem.Options, Default = "Friday Night", Multi = false,
            Callback = function(v)
                local val = type(v) == "table" and v[1] or v
                W.EmoteSystem_SelectEmote(val or "Friday Night")
                VD_Notify("Emote", "Selected: " .. W.EmoteSystem.SelectedEmote, 2)
            end })
        emoteSection:AddButton({ Title = "Stop Emote", Callback = function()
            W.EmoteSystem_Stop()
            W.EmoteSystem.Enabled = false
            VD_Notify("Emote", "Stopped", 2)
        end })
        emoteSection:AddButton({ Title = "Replay Current Emote", Callback = function()
            if not W.EmoteSystem.Enabled then
                VD_Notify("Emote", "Enable dulu toggle-nya!", 2)
                return
            end
            W.EmoteSystem_Play()
            VD_Notify("Emote", "Replaying: " .. W.EmoteSystem.SelectedEmote, 2)
        end })

-- ============ TELEPORT TAB ============
local tpGensSection = TeleportTab:AddSection("Teleport To Generator")
tpGensSection:AddButton({ Title = "TP to Nearest Generator", Callback = function() W.TP_ToNearestGenerator() end })
tpGensSection:AddButton({ Title = "TP to Gen #1", Callback = function() W.TP_ToGenerator(1) end })
tpGensSection:AddButton({ Title = "TP to Gen #2", Callback = function() W.TP_ToGenerator(2) end })
tpGensSection:AddButton({ Title = "TP to Gen #3", Callback = function() W.TP_ToGenerator(3) end })
tpGensSection:AddButton({ Title = "TP to Gen #4", Callback = function() W.TP_ToGenerator(4) end })
tpGensSection:AddButton({ Title = "TP to Gen #5", Callback = function() W.TP_ToGenerator(5) end })

local tpMapSection = TeleportTab:AddSection("Teleport To Map Object")
tpMapSection:AddButton({ Title = "TP to Nearest Hook", Callback = function() W.TP_ToHook() end })
tpMapSection:AddButton({ Title = "TP to Gate", Callback = function() W.TP_ToGate() end })
tpMapSection:AddButton({ Title = "TP to Finish Line", Callback = function() W.TP_ToFinish() end })

local tpPlayerSection = TeleportTab:AddSection("Teleport To Player")
local tpPlayerDrop = tpPlayerSection:AddDropdown({
    Title = "Select Player",
    Options = W.TP_GetPlayerList(),
    Default = nil,
    Multi = false,
    Callback = function(v) W.Teleport.SelectedPlayer = v end
})
tpPlayerSection:AddButton({ Title = "Refresh Players", Callback = function()
    if tpPlayerDrop and tpPlayerDrop.SetValues then
        tpPlayerDrop:SetValues(W.TP_GetPlayerList(), nil, true)
    end
    VD_Notify("Teleport", "Player list refreshed", 1.5)
end })
tpPlayerSection:AddButton({ Title = "TP to Selected Player", Callback = function()
    W.TP_ToPlayer(W.Teleport.SelectedPlayer)
end })

local tpPartSection = TeleportTab:AddSection("Teleport To Part")
local tpPartDrop = tpPartSection:AddDropdown({
    Title = "Select Part Name",
    Options = W.TP_GetPartList(),
    Default = nil,
    Multi = false,
    Callback = function(v) W.Teleport.SelectedPart = v end
})
tpPartSection:AddButton({ Title = "Refresh Parts", Callback = function()
    if tpPartDrop and tpPartDrop.SetValues then
        tpPartDrop:SetValues(W.TP_GetPartList(), nil, true)
    end
    VD_Notify("Teleport", "Part list refreshed", 1.5)
end })
tpPartSection:AddButton({ Title = "TP to Selected Part", Callback = function()
    W.TP_ToPart(W.Teleport.SelectedPart)
end })
tpPartSection:AddParagraph({
    Title = "Info Teleport",
    Content = "• TP Generator = teleport ke generator point di map\n• TP Hook / Gate / Finish = teleport ke objek map\n• TP Player = teleport ke player lain (pilih dari dropdown)\n• TP Part = teleport ke part manapun (pilih nama part)\n\nRefresh dropdown dulu sebelum pilih, biar list-nya up-to-date.",
})
        -- CONFIG
        local cfgSection = ConfigTab:AddSection("Config Manager")
        local currentName = ""
        local selectedConfig = nil
        local configList = nil
        local function ConfigFolderPath() return "Gluto/Config" end
        local function EnsureConfigFolder()
            if isfolder and makefolder then
                if not isfolder("Gluto") then makefolder("Gluto") end
                if not isfolder(ConfigFolderPath()) then makefolder(ConfigFolderPath()) end
            end
        end
        EnsureConfigFolder()
        local function RefreshConfigList()
            local list = {}
            if listfiles then
                EnsureConfigFolder()
                local ok2, files = pcall(listfiles, ConfigFolderPath())
                if ok2 and files then
                    for _, f in ipairs(files) do
                        local n = string.match(f, "([^/\\]+)%.json$")
                        if n and n ~= "_autoload" then table.insert(list, n) end
                    end
                end
            end
            if configList and configList.SetValues then configList:SetValues(list, selectedConfig, true) end
            return list
        end
        cfgSection:AddInput({ Title = "Config Name", Placeholder = "MyConfig", Save = false, Callback = function(text) currentName = text end })
        configList = cfgSection:AddDropdown({ Title = "Saved Configs", Content = "Pilih config untuk load", Multi = false, Options = {}, Save = false, Callback = function(v) selectedConfig = v end })
        RefreshConfigList()
        cfgSection:AddButton({ Title = "Save", SubTitle = "Load", Callback = function()
            if currentName == nil or currentName == "" then ForceNotify("Config", "Isi nama config dulu!", 2); return end
            if not writefile or not HttpService then ForceNotify("Config", "Executor gak support", 2); return end
            EnsureConfigFolder()
            local snapshot = GetConfigSnapshot and GetConfigSnapshot() or (ConfigData or {})
            local okEnc, encoded = pcall(function() return HttpService:JSONEncode(snapshot) end)
            if not okEnc or not encoded then ForceNotify("Config", "Gagal encode", 2); return end
            local okW = pcall(writefile, ConfigFolderPath() .. "/" .. currentName .. ".json", encoded)
            if not okW then ForceNotify("Config", "Gagal save", 2); return end
            ForceNotify("Config", "Saved: " .. currentName, 2)
            RefreshConfigList()
        end, SubCallback = function()
            if not selectedConfig or selectedConfig == "" then ForceNotify("Config", "Pilih config dulu!", 2); return end
            if not readfile or not isfile then ForceNotify("Config", "Executor gak support", 2); return end
            local path = ConfigFolderPath() .. "/" .. selectedConfig .. ".json"
            if not isfile(path) then ForceNotify("Config", "File gak ketemu", 2); return end
            local okR, raw = pcall(readfile, path)
            if not okR or not raw then ForceNotify("Config", "Gagal baca file", 2); return end
            local okD, dec = pcall(function() return HttpService:JSONDecode(raw) end)
            if not okD or type(dec) ~= "table" then ForceNotify("Config", "File corrupt", 2); return end
            for k, v in pairs(dec) do
                if k ~= "_version" then
                    if ConfigData then ConfigData[k] = v end
                    if Elements and Elements[k] and Elements[k].Set then pcall(function() Elements[k]:Set(v, true) end) end
                end
            end
            ForceNotify("Config", "Loaded: " .. selectedConfig, 2)
        end })
        cfgSection:AddButton({ Title = "Delete", SubTitle = "Refresh List", Callback = function()
            if not selectedConfig or selectedConfig == "" then ForceNotify("Config", "Pilih config dulu!", 2); return end
            local path = ConfigFolderPath() .. "/" .. selectedConfig .. ".json"
            if isfile and delfile and isfile(path) then
                pcall(delfile, path)
                ForceNotify("Config", "Deleted: " .. selectedConfig, 2)
                selectedConfig = nil
                RefreshConfigList()
            end
        end, SubCallback = function()
            RefreshConfigList()
            ForceNotify("Config", "List refreshed", 2)
        end })
        cfgSection:AddToggle({ Title = "Auto Save", Content = "Simpan otomatis saat ada perubahan", Default = AutoSaveEnabled ~= false, Save = false,
            Callback = function(v)
                AutoSaveEnabled = v
                if SetActiveConfig and ActiveConfigName ~= nil then
                    pcall(SetActiveConfig, ActiveConfigName, ActiveConfigPath, v, ActiveConfigMode)
                end
                ForceNotify("Config", "Auto Save: " .. (v and "ON" or "OFF"), 2)
            end })
        local initAutoLoad = true
        cfgSection:AddToggle({ Title = "Auto Load", Content = "Auto load config terpilih saat start", Default = false, Save = false,
            Callback = function(v)
                if initAutoLoad then return end
                if v and selectedConfig and selectedConfig ~= "" then
                    if writefile then
                        pcall(writefile, ConfigFolderPath() .. "/_autoload.json", HttpService:JSONEncode({ Name = selectedConfig }))
                        ForceNotify("Config", "Auto Load: " .. selectedConfig, 2)
                    end
                else
                    if writefile then
                        pcall(writefile, ConfigFolderPath() .. "/_autoload.json", HttpService:JSONEncode({ Name = "" }))
                    end
                    if v then ForceNotify("Config", "Pilih config dulu", 2) end
                end
            end })
        initAutoLoad = false
        local importJsonStr = ""
        cfgSection:AddInput({ Title = "Import JSON", Placeholder = "{...}", Save = false, Callback = function(text) importJsonStr = text end })
        cfgSection:AddButton({ Title = "Import", SubTitle = "From Clipboard", Callback = function()
            if importJsonStr == "" then ForceNotify("Config", "Paste JSON dulu", 2); return end
            local okD, dec = pcall(function() return HttpService:JSONDecode(importJsonStr) end)
            if not okD or type(dec) ~= "table" then ForceNotify("Config", "JSON invalid", 2); return end
            for k, v in pairs(dec) do
                if k ~= "_version" then
                    if ConfigData then ConfigData[k] = v end
                    if Elements and Elements[k] and Elements[k].Set then pcall(function() Elements[k]:Set(v, true) end) end
                end
            end
            ForceNotify("Config", "Imported!", 2)
        end, SubCallback = function()
            if not getclipboard then ForceNotify("Config", "Clipboard gak support", 2); return end
            local clip = getclipboard()
            if not clip or clip == "" then ForceNotify("Config", "Clipboard kosong", 2); return end
            local okD, dec = pcall(function() return HttpService:JSONDecode(clip) end)
            if not okD or type(dec) ~= "table" then ForceNotify("Config", "JSON invalid", 2); return end
            for k, v in pairs(dec) do
                if k ~= "_version" then
                    if ConfigData then ConfigData[k] = v end
                    if Elements and Elements[k] and Elements[k].Set then pcall(function() Elements[k]:Set(v, true) end) end
                end
            end
            ForceNotify("Config", "Imported from clipboard!", 2)
        end })
        cfgSection:AddButton({ Title = "Export to Clipboard", Callback = function()
            if not setclipboard then ForceNotify("Config", "Clipboard gak support", 2); return end
            local snapshot = GetConfigSnapshot and GetConfigSnapshot() or (ConfigData or {})
            local okE, encoded = pcall(function() return HttpService:JSONEncode(snapshot) end)
            if okE and encoded then
                setclipboard(encoded)
                ForceNotify("Config", "Copied to clipboard!", 2)
            end
        end })

        local cfgInfoSection = ConfigTab:AddSection("Config Info")
        cfgInfoSection:AddParagraph({ Title = "Cara Pakai Config", Content = "• Save: tulis nama config, klik Save\n• Load: pilih dropdown, klik Load\n• Auto Save: simpan otomatis tiap perubahan\n• Auto Load: load config otomatis saat start\n• Import/Export: backup via JSON string" })
    end)

    if not uiOK then warn("[Gluto] Gagal membuat UI:", uiErr) end

    print("[ALFzxzzz v0.3.2 LITE FULL] Loaded! Scheduler-based optimized ✅")
    ForceNotify("ALFzxzzz LITE FULL Loaded", "v0.3.2 | Optimized Scheduler + Full Features ✅", 4)

end

__Gluto_Init_Main__()
