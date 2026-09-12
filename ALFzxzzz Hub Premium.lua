-- made By Hypol-X
local Library = loadstring(game:HttpGetAsync("https://pastefy.app/YoX4PJmf/raw"))()

-- // 2. Set Whitelisted Users for Paid Access Library.
Library.WhitelistedUsers = {
	"Username", "Username1", "Username2", "Username3", "Username4"
}

-- ==========================================
-- // SERVICES & SETUP
-- ==========================================
local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local UserInputService    = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace           = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

local isMobile = UserInputService.TouchEnabled

-- ==========================================
-- // AUTO PARRY CONFIG
-- ==========================================
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

local State = {
	ParryCooldown       = false,
	ParryCooldownTime   = 60,
	AutoParryAdornment  = nil,
	lastParry           = 0,
	ParryActive         = false,
	ParryCooldownThread = nil,
	busy                = false
}

local PARRY_DEBOUNCE = 0.2
local Attached = {}

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

-- ==========================================
-- // AUTO SKILLCHECK CONFIG
-- ==========================================
local Auto = {
	SkillCheck       = false,
	SkillCheckMode   = "Legit",
	PalletDrop       = false,
	PalletDropDist   = 6
}

local SkillState = { busy = false }
local TouchID = 8822
local ActionPath = "Survivor-mob.Controls.action.check"

-- ==========================================
-- // AUTO DROP PALLET CONFIG
-- ==========================================
local PalletState = {
	UsedPallets = {},
	LastScan    = 0,
	LastDrop    = 0
}

local ESPCache = {
	Pallets = {}
}

for _, obj in ipairs(workspace:GetDescendants()) do
	if obj.Name == "Pallet" or obj.Name == "Palletwrong" then
		ESPCache.Pallets[obj] = true
	end
end

workspace.DescendantAdded:Connect(function(obj)
	if obj.Name == "Pallet" or obj.Name == "Palletwrong" then
		ESPCache.Pallets[obj] = true
	end
end)

workspace.DescendantRemoving:Connect(function(obj)
	ESPCache.Pallets[obj] = nil
end)

-- ==========================================
-- // SILENT AIM CONFIG
-- ==========================================
local AimConfig = {
	Aim_Silent          = false,
	Pistol_BlockKnocked = false,
	Flash_Silent        = false,
	Flash_YOffset       = 8,
	LockAim             = false,
	Pistol_Target       = "Killer",
	Pistol_FOVMode      = false,
	Pistol_ShowFOV      = false,
	Pistol_FOV          = 150,
	AIM_TargetPart      = "Torso",
	HideSilentLaser     = false,
}

local AimState = {
	isChargingPistol        = false,
	lockedPistolTarget      = nil,
	currentTouchPistolInput = nil,
	pistolLaser             = nil,
	isAimingFlash           = false,
}

-- ==========================================
-- // HEALING CONFIG
-- ==========================================
local InstantHealSelf  = false
local AutoHealAll      = false
local InstantHealConnection  = nil
local AutoHealAllConnection  = nil

local SelfHealButton = {
	UI = nil, Button = nil, Stroke = nil,
	Dragging = false, DragStart = nil, DragStartPos = nil
}
local SelfHealButtonDragLocked = false

-- ==========================================
-- // MYERS GRAB CONFIG
-- ==========================================
local MyersGrabData = {
	Enabled    = false,
	UI         = nil,
	Button     = nil,
	DragLocked = false,
	Dragging   = false,
	DragStart  = nil,
	DragStartPos = nil,
	HotkeyCode = Enum.KeyCode.H,
}

-- ==========================================
-- // ABYSS / HIDDEN / DASH / KILLALL / AUTOHOOK CONFIG
-- ==========================================
local AbyssBypass    = { Enabled = false, HandlerFunc = nil, Connection = nil, ScanTried = false }
local HiddenBypass   = { Enabled = false, Thread = nil, LeapFunction = nil, M2Function = nil }
local DashLock       = { Enabled = false, FreezeDuringDash = false, Smoothness = 0.3, Duration = 1.5, Connection = nil, Target = nil, Active = false, DashAnimationId = "rbxassetid://98163597193511" }
local AutoKillAll    = { Enabled = false, Thread = nil, Target = nil, Range = 500 }
local AutoHook       = { Enabled = false, Thread = nil, IsHooking = false, Cache = { Hooks = {} }, CacheTimer = 0 }

-- ==========================================
-- // VEIL / VELOCITY
-- ==========================================
local VeilConfig = {
	Enabled = false, ShowFOV = true, ShowTargetLaser = true, FOV = 220, SpearSpeed = 165,
	Gravity = workspace.Gravity * 0.5, MaxDist = 200, AutoPredict = false,
	TargetPart = "Torso", HorizontalPredictFactor = 1.0,
}
local VeilState = { chargingSpear = false, touchInput = nil, attackCooldown = false, passiveCooldown = false, remoteHooked = false, lastPredictedPos = nil }
local VeilVelocityCache = {}
local VeilDraw = { FOVCircle = Drawing.new("Circle"), Highlight = Instance.new("Highlight"), Tracer = Drawing.new("Circle") }
VeilDraw.FOVCircle.Color = Color3.fromRGB(138, 43, 226); VeilDraw.FOVCircle.Thickness = 1.5; VeilDraw.FOVCircle.Filled = false; VeilDraw.FOVCircle.Visible = false
VeilDraw.Highlight.Name = "VD_VeilTarget"; VeilDraw.Highlight.FillColor = Color3.fromRGB(0,0,0); VeilDraw.Highlight.OutlineColor = Color3.fromRGB(138, 43, 226); VeilDraw.Highlight.FillTransparency = 0.5; VeilDraw.Highlight.OutlineTransparency = 0
VeilDraw.Tracer.Thickness = 2; VeilDraw.Tracer.Radius = 5; VeilDraw.Tracer.Color = Color3.fromRGB(25,25,25); VeilDraw.Tracer.Filled = true; VeilDraw.Tracer.Visible = false

-- ==========================================
-- // HELPER FUNCTIONS
-- ==========================================
local function getRoot()
	return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end
local function IsDowned(char)
	if not char then return false end
	return char:GetAttribute("Knocked") == true or char:GetAttribute("IsHooked") == true or char:GetAttribute("IsCarried") == true
end
local function IsKiller(p) return p and p.Team and p.Team.Name == "Killer" end
local function IsSurvivor(p) return p and p.Team and p.Team.Name == "Survivors" end
local function GetRole()
	if not LocalPlayer.Team then return "Unknown" end
	local name = LocalPlayer.Team.Name
	if name == "Killer" then return "Killer"
	elseif name == "Survivors" then return "Survivor"
	else return "Spectator" end
end
local function GetNearestKiller()
	local root = getRoot(); if not root then return nil, math.huge end
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

-- ==========================================
-- // AUTO PARRY FUNCTIONS
-- ==========================================
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
				VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game); task.wait(2); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
			end
		else
			VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game); task.wait(2); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
		end
	end)
end

function tapMobileParryButton()
	local playerGui = LocalPlayer:FindFirstChild("PlayerGui"); if not playerGui then return end
	local survivorMob = playerGui:FindFirstChild("Survivor-mob")
	local parryBtn = survivorMob and survivorMob:FindFirstChild("Controls") and survivorMob.Controls:FindFirstChild("Gui-mob")
	if parryBtn and parryBtn.Visible then
		if firesignal then pcall(function() firesignal(parryBtn.MouseButton1Down); task.wait(0.01); firesignal(parryBtn.MouseButton1Up) end) end
	else
		pcall(function()
			if mouse2click then mouse2click() return end
			if mouse2press and mouse2release then mouse2press(); task.wait(0.01); mouse2release(); return end
			if MouseButton2Click then MouseButton2Click() return end
			VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0); task.wait(0.01); VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
		end)
	end
end

function ExecuteParry()
	if State.ParryCooldown then return end
	pcall(function()
		local parryRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Items") and ReplicatedStorage.Remotes.Items:FindFirstChild("Parrying Dagger") and ReplicatedStorage.Remotes.Items["Parrying Dagger"]:FindFirstChild("parry")
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
	local humanoid = kChar:FindFirstChild("Humanoid"); if not humanoid then humanoid = kChar:WaitForChild("Humanoid", 5); if not humanoid then return end end
	local animator = humanoid:FindFirstChildOfClass("Animator"); if not animator then animator = humanoid:WaitForChild("Animator", 5); if not animator then return end end
	humanoid.ChildAdded:Connect(function(child) if child:IsA("Animator") then Attached[kChar] = nil; AttachParrySensor(kChar) end end)
	kChar.AncestryChanged:Connect(function(_, parent) if not parent then Attached[kChar] = nil end end)
	animator.AnimationPlayed:Connect(function(track)
		local animId = track.Animation and track.Animation.AnimationId or ""
		local id = animId:match("%d+")
		local attackName = VALID_PARRY_IDS[id]
		if not attackName then return end
		if id == "80411309607666" and Config.Surv_AutoCrouch then
			local myChar = LocalPlayer.Character; if IsDowned(myChar) then return end
			local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart"); local kHRP = kChar:FindFirstChild("HumanoidRootPart")
			if myHRP and kHRP and (myHRP.Position - kHRP.Position).Magnitude <= 40 then TriggerCrouch() end
			return
		end
		if not Config.Surv_AutoParry then return end
		if State.ParryCooldown then return end
		if Config.Ignored_Skills_List and Config.Ignored_Skills_List[attackName] then return end
		local myChar = LocalPlayer.Character; if IsDowned(myChar) or not IsSafeToParry(myChar) then return end
		local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart"); local kHRP = kChar:FindFirstChild("HumanoidRootPart")
		if not myHRP or not kHRP then return end
		local startDistance = (myHRP.Position - kHRP.Position).Magnitude
		if Config.Surv_ParryAggressive then
			local aggressiveRadius = 12; local detectionRadius = Config.Surv_ParryRadius + 5
			if startDistance > detectionRadius then return end
			if startDistance <= aggressiveRadius then ExecuteParry()
			else
				local tracker; local startTime = os.clock()
				tracker = RunService.Heartbeat:Connect(function()
					if os.clock() - startTime >= 1.5 or State.ParryCooldown or not myHRP or not kHRP or IsDowned(myChar) then if tracker then tracker:Disconnect() end return end
					if (myHRP.Position - kHRP.Position).Magnitude <= aggressiveRadius then ExecuteParry(); if tracker then tracker:Disconnect() end end
				end)
			end
		else
			if startDistance > Config.Surv_ParryRadius then return end
			local myPosFlat = Vector3.new(myHRP.Position.X, 0, myHRP.Position.Z); local kPosFlat = Vector3.new(kHRP.Position.X, 0, kHRP.Position.Z)
			local flatDelta = myPosFlat - kPosFlat
			if flatDelta.Magnitude > 0 then
				local flatDirection = flatDelta.Unit; local kLookFlat = Vector3.new(kHRP.CFrame.LookVector.X, 0, kHRP.CFrame.LookVector.Z).Unit
				if kLookFlat:Dot(flatDirection) < Config.Surv_ParryFace then return end
			end
			ExecuteParry()
		end
	end)
end

function TryAttach(p) if p ~= LocalPlayer and IsKiller(p) and p.Character then AttachParrySensor(p.Character) end end
function SetupPlayer(p)
	if p == LocalPlayer then return end
	p.CharacterAdded:Connect(function() TryAttach(p) end)
	p:GetPropertyChangedSignal("Team"):Connect(function() TryAttach(p) end)
	if p.Character then TryAttach(p) end
end
for _, p in pairs(Players:GetPlayers()) do SetupPlayer(p) end
Players.PlayerAdded:Connect(SetupPlayer)
task.spawn(function() while true do task.wait(5); for _, p in pairs(Players:GetPlayers()) do TryAttach(p) end end end)

-- ==========================================
-- // GEN BYPASS
-- ==========================================
local GenBypass = { Enabled = false, Button = nil, UI = nil, Cache = {}, CacheTimer = 0, Processed = {}, HotkeyCode = Enum.KeyCode.G }

local function GB_GetAllGenerators()
	local now = tick(); if now - GenBypass.CacheTimer < 5 then return GenBypass.Cache end
	GenBypass.Cache = {}; GenBypass.CacheTimer = now
	local mapFolder = workspace:FindFirstChild("Map"); if not mapFolder then return GenBypass.Cache end
	pcall(function()
		for _, v in pairs(mapFolder:GetDescendants()) do
			if v:IsA("Model") and v.Name == "Generator" then
				if v:GetAttribute("RepairProgress") ~= nil or v:GetAttribute("kickcount") ~= nil or v:GetAttribute("ProgressRepair") ~= nil then
					table.insert(GenBypass.Cache, v)
				end
			end
		end
	end)
	return GenBypass.Cache
end

local function GB_GetPoints(genModel)
	local points = {}
	pcall(function() for _, obj in pairs(genModel:GetChildren()) do if obj.Name:find("GeneratorPoint") and obj:IsA("BasePart") then table.insert(points, obj) end end end)
	return points
end

local function GB_WaitRepairing(point, timeout)
	local start = tick()
	while tick() - start < (timeout or 1) do
		if point:GetAttribute("IsRepairing") == true then return true end
		task.wait(0.05)
	end
	return false
end

local function GB_DoRepair(targetPoint)
	local genModel = targetPoint.Parent
	if GenBypass.Processed[genModel] then return end
	GenBypass.Processed[genModel] = true
	local character = LocalPlayer.Character; local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if not hrp then GenBypass.Processed[genModel] = nil return end
	local RepairEvent = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Generator") and ReplicatedStorage.Remotes.Generator:FindFirstChild("RepairEvent")
	local originalCFrame = hrp.CFrame
	pcall(function()
		for _, point in pairs(GB_GetPoints(genModel)) do
			if point ~= targetPoint and point.Parent then
				hrp.Anchored = true; hrp.CFrame = point.CFrame; task.wait(0.15)
				pcall(function() if RepairEvent then RepairEvent:FireServer(point, true) end end)
				if not GB_WaitRepairing(point, 0.8) then
					pcall(function() if RepairEvent then RepairEvent:FireServer(point, false) end end)
					task.wait(0.1); hrp.CFrame = point.CFrame; task.wait(0.15)
					pcall(function() if RepairEvent then RepairEvent:FireServer(point, true) end end)
					GB_WaitRepairing(point, 0.5)
				end
				hrp.Anchored = false; task.wait(0.05)
			end
		end
	end)
	pcall(function() if hrp and hrp.Parent then hrp.Anchored = false; hrp.CFrame = originalCFrame end end)
	task.wait(0.1)
	pcall(function() if RepairEvent then RepairEvent:FireServer(targetPoint, false) end end)
end

local function GB_GetNearestPoint()
	local character = LocalPlayer.Character; local hrp = character and character:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
	local bestPoint, bestDist = nil, math.huge
	for _, gen in pairs(GB_GetAllGenerators()) do
		for _, point in pairs(GB_GetPoints(gen)) do
			local d = (hrp.Position - point.Position).Magnitude
			if d < bestDist then bestDist = d; bestPoint = point end
		end
	end
	return bestPoint, bestDist
end

local function GB_IsPromptVisible()
	local ok, frame = pcall(function() return LocalPlayer.PlayerGui.pcprompts.Frame.GeneratorRepair end)
	return ok and frame and frame.Visible
end

local function GB_UpdateButton() if GenBypass.Button then GenBypass.Button.Visible = GenBypass.Enabled and isMobile end end

local function GB_CreateButton()
	local oldUI = LocalPlayer.PlayerGui:FindFirstChild("BypassGenUI"); if oldUI then oldUI:Destroy() end
	GenBypass.UI = Instance.new("ScreenGui"); GenBypass.UI.Name = "BypassGenUI"; GenBypass.UI.ResetOnSpawn = false; GenBypass.UI.IgnoreGuiInset = true; GenBypass.UI.Parent = LocalPlayer:WaitForChild("PlayerGui")
	GenBypass.Button = Instance.new("ImageButton"); GenBypass.Button.Size = UDim2.new(0, 60, 0, 60); GenBypass.Button.Position = UDim2.new(0.88, 0, 0.55, 0); GenBypass.Button.AnchorPoint = Vector2.new(0.5, 0.5)
	GenBypass.Button.BackgroundColor3 = Color3.fromRGB(20, 20, 20); GenBypass.Button.BackgroundTransparency = 0.1; GenBypass.Button.AutoButtonColor = true; GenBypass.Button.Visible = false; GenBypass.Button.ZIndex = 10; GenBypass.Button.Parent = GenBypass.UI
	Instance.new("UICorner", GenBypass.Button).CornerRadius = UDim.new(1, 0)
	local s = Instance.new("UIStroke", GenBypass.Button); s.Color = Color3.fromRGB(138, 43, 226); s.Thickness = 2; s.Transparency = 0.2
	local lbl = Instance.new("TextLabel", GenBypass.Button); lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1; lbl.Text = "GEN"; lbl.TextColor3 = Color3.fromRGB(138, 43, 226); lbl.TextScaled = true; lbl.Font = Enum.Font.GothamBlack; lbl.ZIndex = 11
	GenBypass.Button.MouseButton1Click:Connect(function()
		if not GenBypass.Enabled then return end
		local bestPoint, bestDist = GB_GetNearestPoint()
		if bestPoint and bestDist <= 8 then GB_DoRepair(bestPoint) end
	end)
end
GB_CreateButton()
LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5); GB_CreateButton(); GB_UpdateButton() end)

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

local function setGenBypass(v) GenBypass.Enabled = v; GB_UpdateButton() end

-- ==========================================
-- // AUTO SKILLCHECK FUNCTIONS
-- ==========================================
local function pressSpace()
	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
	task.wait()
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
end

local function GetActionTarget()
	local current = PlayerGui
	for segment in string.gmatch(ActionPath, "[^%.]+") do current = current and current:FindFirstChild(segment) end
	return current
end

local function TriggerMobileButton()
	local b = GetActionTarget()
	if b and b:IsA("GuiObject") then
		local p, s = b.AbsolutePosition, b.AbsoluteSize
		local i = game:GetService("GuiService"):GetGuiInset()
		local cx, cy = p.X + (s.X/2) + i.X, p.Y + (s.Y/2) + i.Y
		pcall(function()
			VirtualInputManager:SendTouchEvent(TouchID, 0, cx, cy); task.wait(0.01); VirtualInputManager:SendTouchEvent(TouchID, 2, cx, cy)
		end)
	end
end

local skillConn = nil
local function startSkillCheck()
	if skillConn then skillConn:Disconnect() end
	skillConn = RunService.RenderStepped:Connect(function()
		if not Auto.SkillCheck or SkillState.busy then return end
		local prompt = PlayerGui:FindFirstChild("SkillCheckPromptGui"); if not prompt then return end
		local check = prompt:FindFirstChild("Check"); if not check or not check.Visible then return end
		local line = check:FindFirstChild("Line"); local goal = check:FindFirstChild("Goal"); if not line or not goal then return end
		if Auto.SkillCheckMode == "Instant" then
			line.Rotation = goal.Rotation + 109; SkillState.busy = true
			task.spawn(function()
				if UserInputService.TouchEnabled then TriggerMobileButton() else pressSpace() end
				task.wait(0.2); SkillState.busy = false
			end)
		else
			local lr = line.Rotation % 360; local gr = goal.Rotation % 360
			local startRange = (gr + 102) % 360; local endRange = (gr + 116) % 360
			local success = (startRange > endRange and (lr >= startRange or lr <= endRange)) or (lr >= startRange and lr <= endRange)
			if success then
				SkillState.busy = true
				task.spawn(function()
					if UserInputService.TouchEnabled then TriggerMobileButton() else pressSpace() end
					task.wait(0.05); SkillState.busy = false
				end)
			end
		end
	end)
end

-- ==========================================
-- // AUTO DROP PALLET
-- ==========================================
local function findPalletPointSlide(model)
	local slide = model:FindFirstChild("PalletPointSlide"); if slide then return slide end
	for _, child in ipairs(model:GetDescendants()) do if child.Name == "PalletPointSlide" then return child end end
	return model:FindFirstChild("PalletPoint")
end

local function HandleAutoPallet()
	if not Auto.PalletDrop then return end
	local plr = Players.LocalPlayer; if not (plr.Team and plr.Team.Name == "Survivors") then return end
	local now = tick()
	if now - PalletState.LastScan < 0.2 then return end
	PalletState.LastScan = now
	if now - PalletState.LastDrop < 2.5 then return end
	local root = getRoot(); if not root then return end
	local hum = plr.Character:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health <= 0 then return end
	local killerRoot, killerDist = GetNearestKiller(); if not killerRoot or killerDist > Auto.PalletDropDist then return end
	local remotes = ReplicatedStorage:FindFirstChild("Remotes"); local palletFold = remotes and remotes:FindFirstChild("Pallet"); local dropEvent = palletFold and palletFold:FindFirstChild("PalletDropEvent")
	if not dropEvent then return end
	local bestPallet = nil; local bestDist = 8
	for pal, _ in pairs(ESPCache.Pallets) do
		if not pal or PalletState.UsedPallets[pal] then continue end
		local refPart = pal:FindFirstChild("PalletPoint") or pal:FindFirstChild("PalletPointSlide"); if not refPart then continue end
		local ok, pos = pcall(function() return refPart.Position end); if not ok or not pos then continue end
		local d = (root.Position - pos).Magnitude
		if d < bestDist then bestDist = d; bestPallet = pal end
	end
	if bestPallet then
		local fireTarget = findPalletPointSlide(bestPallet)
		if fireTarget then
			pcall(function() dropEvent:FireServer(fireTarget) end)
			PalletState.UsedPallets[bestPallet] = true
			PalletState.LastDrop = now
		end
	end
end

RunService.Heartbeat:Connect(HandleAutoPallet)
LocalPlayer.CharacterAdded:Connect(function() PalletState.UsedPallets = {} end)

-- ==========================================
-- // HEALING (fungsi-fungsi utama tetap ada)
-- ==========================================
local function doSelfHealTrue()
	local char = LocalPlayer.Character; if not char then return end
	local healRemote = ReplicatedStorage.Remotes.Healing.HealEvent
	local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
	pcall(function() healRemote:FireServer(hrp, true) end)
end
local function doSelfHealFalse()
	local char = LocalPlayer.Character; if not char then return end
	local healRemote = ReplicatedStorage.Remotes.Healing.HealEvent
	local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
	pcall(function() healRemote:FireServer(hrp, false) end)
end
local function doOthersHealTrue(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then return end
	local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart"); if not targetHRP then return end
	local healRemote = ReplicatedStorage.Remotes.Healing.HealEvent
	pcall(function() healRemote:FireServer(targetHRP, true) end)
end
local function doOthersHealFalse(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then return end
	local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart"); if not targetHRP then return end
	local healRemote = ReplicatedStorage.Remotes.Healing.HealEvent
	pcall(function() healRemote:FireServer(targetHRP, false) end)
end
local function setInstantHealSelf(v)
	InstantHealSelf = v
	if v then
		local healActive = false
		if InstantHealConnection then InstantHealConnection:Disconnect() end
		InstantHealConnection = RunService.Heartbeat:Connect(function()
			if not InstantHealSelf then return end
			local myChar = LocalPlayer.Character
			local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
			if not myHum then return end
			if myHum.Health >= myHum.MaxHealth * 0.9 then if healActive then healActive = false; doSelfHealFalse() end return end
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
local function setAutoHealAll(v)
	AutoHealAll = v
	if v then
		local activeHeals = {}
		if AutoHealAllConnection then AutoHealAllConnection:Disconnect() end
		AutoHealAllConnection = RunService.Heartbeat:Connect(function()
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

-- ==========================================
-- // AUTO KILL ALL
-- ==========================================
local function AutoKillAll_ScanHook()
	local hooks = {}
	pcall(function()
		local mapFolder = workspace:FindFirstChild("Map"); if not mapFolder then return end
		for _, obj in ipairs(mapFolder:GetDescendants()) do
			if obj:IsA("Model") and obj.Name:lower():find("hook") then
				local part = obj:FindFirstChild("HookPoint") or obj:FindFirstChildWhichIsA("BasePart")
				if part then table.insert(hooks, { model = obj, part = part }) end
			end
		end
	end)
	return hooks
end

local function AutoKillAll_Loop()
	while AutoKillAll.Enabled do
		task.wait(0.1)
		if GetRole() ~= "Killer" then AutoKillAll.Target = nil; continue end
		local root = getRoot(); if not root then continue end
		local target = AutoKillAll.Target
		local needNewTarget = true
		if target and target.Character then
			local tr = target.Character:FindFirstChild("HumanoidRootPart")
			local th = target.Character:FindFirstChildOfClass("Humanoid")
			if tr and th and th.MaxHealth > 0 and (th.Health / th.MaxHealth) > 0.25 then needNewTarget = false else AutoKillAll.Target = nil end
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
					local pr = player.Character:FindFirstChild("HumanoidRootPart")
					local dist = (pr.Position - root.Position).Magnitude
					if dist < closestDist then closestDist = dist; closest = player end
				end
				AutoKillAll.Target = closest; target = closest
			else AutoKillAll.Target = nil; continue end
		end
		if not target or not target.Character then continue end
		local tr = target.Character:FindFirstChild("HumanoidRootPart")
		local th = target.Character:FindFirstChildOfClass("Humanoid")
		if not tr or not th then AutoKillAll.Target = nil; continue end
		if th.MaxHealth <= 0 or (th.Health / th.MaxHealth) <= 0.25 then AutoKillAll.Target = nil; continue end
		for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") then pcall(function() part.CanCollide = false end) end
		end
		local dir = (root.Position - tr.Position).Unit
		if dir.Magnitude ~= dir.Magnitude then dir = Vector3.new(1, 0, 0) end
		root.CFrame = CFrame.new(tr.Position + dir * 3 + Vector3.new(0, 1, 0), tr.Position)
		pcall(function()
			local r = ReplicatedStorage:FindFirstChild("Remotes")
			local a = r and r:FindFirstChild("Attacks")
			local ba = a and a:FindFirstChild("BasicAttack")
			if ba then ba:FireServer(false) end
		end)
	end
	AutoKillAll.Thread = nil
end

local function setAutoKillAll(v)
	AutoKillAll.Enabled = v
	if v then
		if AutoKillAll.Thread then return end
		AutoKillAll.Thread = task.spawn(AutoKillAll_Loop)
		Library:Notify({ Title = "Auto Kill All", Description = "Aktif", Duration = 2 })
	else
		AutoKillAll.Target = nil
		Library:Notify({ Title = "Auto Kill All", Description = "Dinonaktifkan", Duration = 2 })
	end
end

-- ==========================================
-- // AUTO HOOK
-- ==========================================
local function AutoHook_RefreshCache()
	local now = tick()
	if now - AutoHook.CacheTimer < 5 then return end
	AutoHook.Cache.Hooks = AutoKillAll_ScanHook()
	AutoHook.CacheTimer = now
end

local function AutoHook_Loop()
	while AutoHook.Enabled do
		task.wait(0.3)
		if GetRole() ~= "Killer" then continue end
		if AutoHook.IsHooking then continue end
		local root = getRoot(); if not root then continue end
		AutoHook_RefreshCache()
		local char = LocalPlayer.Character
		local isCarrying = false
		if char then isCarrying = char:GetAttribute("IsCarrying") or char:GetAttribute("isCarrying") end
		local occupiedPositions = {}
		for _, v in ipairs(Players:GetPlayers()) do
			if v ~= LocalPlayer and v.Character then
				local isHooked = v.Character:GetAttribute("IsHooked") or v.Character:GetAttribute("isHooked")
				local hrp = v.Character:FindFirstChild("HumanoidRootPart")
				if isHooked and hrp then table.insert(occupiedPositions, hrp.Position) end
			end
		end
		local function findNearestEmptyHook(originPos)
			local closestHook, hDist = nil, math.huge
			for _, h in ipairs(AutoHook.Cache.Hooks) do
				if h.part then
					local isOccupied = false
					for _, occPos in ipairs(occupiedPositions) do
						if (h.part.Position - occPos).Magnitude < 10 then isOccupied = true; break end
					end
					if not isOccupied then
						local hd = (h.part.Position - originPos).Magnitude
						if hd < hDist then hDist = hd; closestHook = h end
					end
				end
			end
			return closestHook
		end
		if isCarrying then
			local closestHook = findNearestEmptyHook(root.Position)
			if closestHook then
				AutoHook.IsHooking = true
				task.spawn(function()
					root.CFrame = CFrame.new(closestHook.part.Position + Vector3.new(0, 3, 0)); task.wait(0.4)
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
					task.wait(0.5); AutoHook.IsHooking = false
				end)
			end
			continue
		end
		local closestDowned, closestDist = nil, math.huge
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and IsSurvivor(player) and player.Character then
				local tr = player.Character:FindFirstChild("HumanoidRootPart")
				local hum = player.Character:FindFirstChildOfClass("Humanoid")
				if tr and hum then
					local pct = (hum.MaxHealth > 0) and (hum.Health / hum.MaxHealth) or 0
					if pct <= 0.25 and pct > 0 then
						local isHooked = false
						for _, hh in ipairs(AutoHook.Cache.Hooks) do
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
			local closestHook = findNearestEmptyHook(closestDowned.Position)
			if closestHook then
				AutoHook.IsHooking = true
				task.spawn(function()
					root.CFrame = CFrame.new(closestDowned.Position + Vector3.new(0, 3, 0), closestDowned.Position); task.wait(0.3)
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
						root.CFrame = CFrame.new(closestHook.part.Position + Vector3.new(0, 3, 0)); task.wait(0.4)
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
					task.wait(1); AutoHook.IsHooking = false
				end)
			end
		end
	end
	AutoHook.Thread = nil
end

local function setAutoHook(v)
	AutoHook.Enabled = v
	if v then
		if AutoHook.Thread then return end
		AutoHook.Thread = task.spawn(AutoHook_Loop)
		Library:Notify({ Title = "Auto Hook", Description = "Aktif", Duration = 2 })
	else
		Library:Notify({ Title = "Auto Hook", Description = "Dinonaktifkan", Duration = 2 })
	end
end

-- ==========================================
-- // ABYSS BYPASS
-- ==========================================
local function Abyss_FindHandler()
	if AbyssBypass.HandlerFunc then return true end
	for _, v in pairs(getgc(true)) do
		if type(v) == "function" and islclosure(v) then
			local ok, constants = pcall(debug.getconstants, v)
			if ok and constants and table.find(constants, "corrupt") and table.find(constants, "Immobile") then
				AbyssBypass.HandlerFunc = v; return true
			end
		end
	end
	return false
end
local function Abyss_StartBypass()
	if not AbyssBypass.HandlerFunc then Abyss_FindHandler() end
	if not AbyssBypass.HandlerFunc then
		Library:Notify({ Title = "Abyss Bypass", Description = "corruptHandler tidak ditemukan!", Duration = 3 })
		return
	end
	if AbyssBypass.Connection then AbyssBypass.Connection:Disconnect(); AbyssBypass.Connection = nil end
	AbyssBypass.Connection = RunService.Heartbeat:Connect(function()
		if not AbyssBypass.Enabled then return end
		if AbyssBypass.HandlerFunc then
			local ok, upvalues = pcall(debug.getupvalues, AbyssBypass.HandlerFunc)
			if ok and upvalues then
				for idx, val in pairs(upvalues) do
					if type(val) == "boolean" and val == false then pcall(debug.setupvalue, AbyssBypass.HandlerFunc, idx, true) end
				end
			end
		end
	end)
end
local function Abyss_StopBypass()
	if AbyssBypass.Connection then AbyssBypass.Connection:Disconnect(); AbyssBypass.Connection = nil end
end
local function setAbyssBypass(v)
	AbyssBypass.Enabled = v
	if v then
		Abyss_StartBypass()
		if AbyssBypass.HandlerFunc then Library:Notify({ Title = "Abyss Bypass", Description = "Aktif", Duration = 2 }) end
	else
		Abyss_StopBypass()
		Library:Notify({ Title = "Abyss Bypass", Description = "Dinonaktifkan", Duration = 2 })
	end
end

-- ==========================================
-- // HIDDEN BYPASS
-- ==========================================
local function Hidden_ScanGC()
	local found = false
	pcall(function()
		for _, v in pairs(getgc(true)) do
			if type(v) == "function" and islclosure(v) then
				local ok, info = pcall(debug.getinfo, v)
				if ok and info then
					if info.name == "tryActivate" and not HiddenBypass.LeapFunction then HiddenBypass.LeapFunction = v; found = true
					elseif info.name == "playM2Animation" and not HiddenBypass.M2Function then HiddenBypass.M2Function = v; found = true end
				end
			end
			if HiddenBypass.LeapFunction and HiddenBypass.M2Function then break end
		end
	end)
	return found
end
local function Hidden_StartBypass()
	if HiddenBypass.Thread then return end
	HiddenBypass.Thread = task.spawn(function()
		Hidden_ScanGC()
		local lastScan = os.clock()
		while true do
			task.wait(0.1)
			if not HiddenBypass.Enabled then break end
			if not (HiddenBypass.LeapFunction and HiddenBypass.M2Function) then
				local now = os.clock()
				if now - lastScan >= 2 then lastScan = now; Hidden_ScanGC() end
			end
			if HiddenBypass.LeapFunction then
				pcall(function()
					for i, val in pairs(debug.getupvalues(HiddenBypass.LeapFunction)) do
						if type(val) == "boolean" and val == true then debug.setupvalue(HiddenBypass.LeapFunction, i, false) end
					end
				end)
			end
			if HiddenBypass.M2Function then
				pcall(function()
					for i, val in pairs(debug.getupvalues(HiddenBypass.M2Function)) do
						if type(val) == "boolean" and val == true then debug.setupvalue(HiddenBypass.M2Function, i, false) end
					end
				end)
			end
		end
		HiddenBypass.Thread = nil
	end)
end
local function setHiddenBypass(v)
	HiddenBypass.Enabled = v
	if v then
		Hidden_StartBypass()
		task.wait(0.5)
		Library:Notify({ Title = "Hidden Bypass", Description = "Aktif", Duration = 2 })
	else
		if HiddenBypass.Thread then HiddenBypass.Thread = nil end
		Library:Notify({ Title = "Hidden Bypass", Description = "Dinonaktifkan", Duration = 2 })
	end
end

-- ==========================================
-- // DASH LOCK
-- ==========================================
local function DashLock_GetNearestSurvivor()
	local myChar = LocalPlayer.Character; local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart"); if not myRoot then return nil end
	local target = nil; local targetDist = math.huge
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Team and player.Team.Name == "Survivors" then
			local char = player.Character
			if char then
				local root = char:FindFirstChild("HumanoidRootPart"); local hum = char:FindFirstChildOfClass("Humanoid")
				if root and hum and hum.Health > 0 then
					local dist = (myRoot.Position - root.Position).Magnitude
					if dist < targetDist then targetDist = dist; target = root end
				end
			end
		end
	end
	return target
end
local function DashLock_RestoreWalkSpeed()
	local char = LocalPlayer.Character; local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum and hum.WalkSpeed == 0 then hum.WalkSpeed = 16 end
end
local function DashLock_Update()
	if not DashLock.Enabled then
		if DashLock.Active then
			DashLock.Active = false; DashLock.Target = nil
			if DashLock.FreezeDuringDash then DashLock_RestoreWalkSpeed() end
		end
		return
	end
	local myChar = LocalPlayer.Character; local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then DashLock.Target = nil; return end
	local target = DashLock_GetNearestSurvivor()
	if not target then DashLock.Target = nil; return end
	DashLock.Target = target
	local cam = Workspace.CurrentCamera
	if cam and target then
		local targetPos = target.Position
		cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, targetPos), DashLock.Smoothness)
		if DashLock.FreezeDuringDash then
			local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
			if hum and hum.WalkSpeed ~= 0 then hum.WalkSpeed = 0 end
		end
	end
end
local function DashLock_SetActive(active)
	if active == DashLock.Active then return end
	DashLock.Active = active
	if active then
		if not DashLock.Connection then DashLock.Connection = RunService.RenderStepped:Connect(DashLock_Update) end
		if DashLock.FreezeDuringDash then DashLock_RestoreWalkSpeed() end
	else
		if DashLock.Connection then DashLock.Connection:Disconnect(); DashLock.Connection = nil end
		if DashLock.FreezeDuringDash then DashLock_RestoreWalkSpeed() end
		DashLock.Target = nil
	end
end
local function DashLock_HookDashDetection(char)
	local humanoid = char:WaitForChild("Humanoid", 5)
	if humanoid then
		local animator = humanoid:FindFirstChildOfClass("Animator")
		if animator then
			animator.AnimationPlayed:Connect(function(animationTrack)
				if animationTrack.Animation and animationTrack.Animation.AnimationId == DashLock.DashAnimationId then
					if DashLock.Enabled then
						DashLock_SetActive(true)
						task.delay(DashLock.Duration, function() DashLock_SetActive(false) end)
					end
				end
			end)
		end
	end
end
if LocalPlayer.Character then DashLock_HookDashDetection(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(DashLock_HookDashDetection)

-- ==========================================
-- // VEIL SYSTEM
-- ==========================================
local function Veil_GetRealVelocity(part, playerName)
	if not part then return Vector3.zero end
	local currentPos = part.Position; local currentTime = tick()
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
	cache.lastPos = currentPos; cache.lastTime = currentTime
	return cache.velocity
end
local function veil_getTargetPart(char)
	if VeilConfig.TargetPart == "Head" then return char:FindFirstChild("Head")
	elseif VeilConfig.TargetPart == "Root" then return char:FindFirstChild("HumanoidRootPart")
	else return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart") end
end
local function veil_getClosestSurvivor()
	local myChar = LocalPlayer.Character; local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart"); if not myRoot then return nil end
	local cam = workspace.CurrentCamera; local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
	local bestDist = VeilConfig.FOV; local bestTarget = nil
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Team and p.Team.Name == "Survivors" and p.Character then
			local char = p.Character; local hum = char:FindFirstChildOfClass("Humanoid"); local part = veil_getTargetPart(char)
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
local function veil_setupInterceptor()
	if VeilState.remoteHooked then return end
	task.spawn(function()
		pcall(function()
			local oldNamecall
			oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
				local method = getnamecallmethod()
				if not checkcaller() then
					if string.lower(method) == "kick" then return nil end
					if method == "FireServer" and self.Name == "Spearthrow" and VeilConfig.Enabled then return nil end
				end
				return oldNamecall(self, ...)
			end)
			VeilState.remoteHooked = true
		end)
	end)
end
veil_setupInterceptor()
local function veil_fire()
	if VeilState.attackCooldown then return end
	VeilState.attackCooldown = true
	task.delay(2, function() VeilState.attackCooldown = false end)
	local myChar = LocalPlayer.Character
	local startPart = myChar and (myChar:FindFirstChild("Head") or myChar:FindFirstChild("HumanoidRootPart")); if not startPart then return end
	local startPos = startPart.Position
	local targetInfo = veil_getClosestSurvivor()
	local aimDir
	if targetInfo and targetInfo.Part then
		local targetPart = targetInfo.Part; local targetPlayer = targetInfo.Player; local targetPos = targetPart.Position
		local velocity = Veil_GetRealVelocity(targetPart, targetPlayer.Name)
		local horizontalVel = Vector3.new(velocity.X, 0, velocity.Z); local speed = horizontalVel.Magnitude
		local distance = (targetPos - startPos).Magnitude
		local timeToHit = distance / VeilConfig.SpearSpeed
		local horizontalPrediction = Vector3.zero
		if speed > 4 and VeilConfig.AutoPredict then
			horizontalPrediction = horizontalVel * timeToHit * VeilConfig.HorizontalPredictFactor
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
				if veil and veil:FindFirstChild("Spearthrow") then
					veil.Spearthrow:FireServer(aimDir, VeilConfig.SpearSpeed, startPos)
				end
			end
		end
	end)
	VeilDraw.FOVCircle.Color = Color3.fromRGB(90, 0, 150)
	if not VeilState.passiveCooldown then
		VeilState.passiveCooldown = true
		task.delay(30, function() VeilDraw.FOVCircle.Color = Color3.fromRGB(138, 43, 226); VeilState.passiveCooldown = false end)
	end
end
UserInputService.InputBegan:Connect(function(input, gp)
	local isTouch = input.UserInputType == Enum.UserInputType.Touch
	if gp and not isTouch then return end
	local char = LocalPlayer.Character
	local isSpearMode = char and char:GetAttribute("spearmode") == true
	if not VeilConfig.Enabled or not isSpearMode then return end
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
						local pos = input.Position; local absPos = attackBtn.AbsolutePosition; local absSize = attackBtn.AbsoluteSize
						if pos.X >= absPos.X and pos.X <= absPos.X + absSize.X and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y then
							VeilState.chargingSpear = true; VeilState.touchInput = input
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
		veil_fire()
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
		local target = veil_getClosestSurvivor()
		if target and target.Part and target.Part.Parent then
			VeilDraw.Highlight.Parent = target.Part.Parent
			if VeilConfig.ShowTargetLaser then
				if not getgenv().MAWWW_SpearLaserPart then
					local laser = Instance.new("Part")
					laser.Name = "SpearSilentAimLaser"; laser.Anchored = true; laser.CanCollide = false; laser.CanTouch = false; laser.CastShadow = false
					laser.Material = Enum.Material.Neon; laser.Color = Color3.fromRGB(25, 24, 25); laser.Transparency = 0; laser.Parent = workspace
					getgenv().MAWWW_SpearLaserPart = laser
				end
				local originPart = myChar and (myChar:FindFirstChild("Head") or myChar:FindFirstChild("HumanoidRootPart"))
				if originPart then
					local originPos = originPart.Position; local targetPos = target.Part.Position
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
		local viewport = cam.ViewportSize; local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
		if onScreen then VeilDraw.Tracer.Position = Vector2.new(screenPos.X, screenPos.Y)
		else
			local dx = screenPos.X - center.X; local dy = screenPos.Y - center.Y
			if math.abs(dx) < 1 and math.abs(dy) < 1 then VeilDraw.Tracer.Position = center
			else
				local maxX = viewport.X / 2 - 10; local maxY = viewport.Y / 2 - 10
				local scaleX = maxX / math.abs(dx); local scaleY = maxY / math.abs(dy)
				local scale = math.min(scaleX, scaleY)
				VeilDraw.Tracer.Position = Vector2.new(center.X + dx * scale, center.Y + dy * scale)
			end
		end
		VeilDraw.Tracer.Visible = true
	else VeilDraw.Tracer.Visible = false end
end)

-- ==========================================
-- // AUTO PARRY CIRCLE ESP
-- ==========================================
RunService.RenderStepped:Connect(function()
	local hrp = getRoot(); if not hrp then return end
	if Config.Surv_ParryCircle and Config.Surv_AutoParry then
		if not State.AutoParryAdornment or State.AutoParryAdornment.Parent ~= hrp then
			if State.AutoParryAdornment then State.AutoParryAdornment:Destroy() end
			State.AutoParryAdornment = Instance.new("CylinderHandleAdornment")
			State.AutoParryAdornment.Name = "AutoParryCircleESP"; State.AutoParryAdornment.Height = 0.05; State.AutoParryAdornment.Transparency = 0.3
			State.AutoParryAdornment.Adornee = hrp; State.AutoParryAdornment.Parent = hrp; State.AutoParryAdornment.ZIndex = 0; State.AutoParryAdornment.AlwaysOnTop = false
		end
		local cR = Config.Surv_ParryRadius
		State.AutoParryAdornment.Radius = cR; State.AutoParryAdornment.InnerRadius = math.max(0.1, cR - 0.15)
		State.AutoParryAdornment.CFrame = CFrame.new(0, -3, 0) * CFrame.Angles(math.rad(90), 0, 0)
		if State.ParryCooldown then State.AutoParryAdornment.Color3 = Color3.fromRGB(255, 128, 0)
		elseif Config.Surv_ParryAggressive then State.AutoParryAdornment.Color3 = Color3.fromRGB(255, 0, 0)
		else State.AutoParryAdornment.Color3 = Color3.fromRGB(0, 255, 255) end
	elseif State.AutoParryAdornment then
		State.AutoParryAdornment:Destroy(); State.AutoParryAdornment = nil
	end
end)

-- ==========================================
-- // MAIN WINDOW
-- ==========================================
local Window = Library:CreateWindow({
	Title = "ZyronX Ui Library",
	Subtitle = "Made By Hypol-X",
	SubtitleColor = Color3.fromRGB(190, 140, 255),
	Logo = "rbxassetid://82367817676382",
	LogoSize = 32,
	SphereText = false,
	SphereWords = "ZX",
	SphereImage = "rbxassetid://82367817676382",
	SphereIconSize = 38
})

local MainTab    = Window:CreateTab("Main", true, false)
local SurvivorPage = MainTab:CreatePage("Survivor")
local KillerTab  = Window:CreateTab("Killer", false, false)
local KillerPage = KillerTab:CreatePage("Killer")
local VisualTab  = Window:CreateTab("Visual", false, false)
local VisualPage = VisualTab:CreatePage("Visual")

-- ==========================================
-- // VISUAL PAGE - HIGHLIGHT ESP V2
-- ==========================================
local MAWWW_ESPState = {
	PlayerMasterESP = false,
	WorldMasterESP  = false,
	ESPFillTransparency = 0.85,
	ESPOutlineTransparency = 0.3,
	ESPTextSize = 8,
	SurvivorESP = false, KillerESP = false, SpectatorESP = false,
	Nametags = false, DistanceESP = false, SurvivorItemsESP = false,
	SurvivorColor  = Color3.fromRGB(191, 191, 191),
	KillerColor    = Color3.fromRGB(255, 255, 255),
	SpectatorColor = Color3.fromRGB(255, 255, 255),
	GeneratorESP = false, HookESP = false, GateESP = false, WindowESP = false, PalletESP = false, SCPZombieESP = false,
	WorldNametags = false, WorldDistanceESP = false,
	GeneratorColor = Color3.fromRGB(255, 170, 0),
	HookColor      = Color3.fromRGB(255, 0, 0),
	GateColor      = Color3.fromRGB(255, 225, 0),
	WindowColor    = Color3.fromRGB(255, 255, 255),
	PalletColor    = Color3.fromRGB(255, 140, 0),
	SCPZombieColor = Color3.fromRGB(128, 0, 128),
}

local MAWWW_WorldReg = { Generator = {}, Hook = {}, Gate = {}, Window = {}, Palletwrong = {}, SCPZombie = {} }
local MAWWW_MapAdd, MAWWW_MapRem = {}, {}
local MAWWW_PlayerConns = {}
local MAWWW_Connections = {}
local MAWWW_PalletState = setmetatable({}, { __mode = "k" })
local MAWWW_WindowState = setmetatable({}, { __mode = "k" })
local MAWWW_InstanceIds = setmetatable({}, { __mode = "k" })
local MAWWW_MawwwtId = 0
local MAWWW_PlayerLoopThread = nil
local MAWWW_WorldLoopThread = nil
local MAWWW_ESPFolder = nil
local MAWWW_Dead = false

local MAWWW_DisplayNames = {
	["Motion Tracker"] = true, ["Gate"] = true, ["Flashlight"] = true, ["Bandage"] = true,
	["Parrying Dagger"] = true, ["Adrenaline Shot"] = true, ["Twist of Fate"] = true,
	["Shadow Clone"] = true, ["Holy Water"] = true, ["WaxBound Candle"] = true,
	["Riot Shield"] = true, ["Emperor"] = true, ["AWP"] = true,
}

local function MAWWW_Alive(inst)
	if not inst then return false end
	local ok, parent = pcall(function() return inst.Parent end)
	return ok and parent ~= nil
end
local function MAWWW_Clamp(n, lo, hi)
	n = tonumber(n) or lo; if n < lo then return lo end; if n > hi then return hi end; return n
end
local function MAWWW_PlayerKey(player)
	local id = player and player.UserId
	if id and id ~= 0 then return tostring(id) end
	return tostring(player and player.Name or "Unknown")
end
local function MAWWW_EspId(inst)
	if not inst then return "nil" end
	local id = MAWWW_InstanceIds[inst]; if id then return id end
	MAWWW_MawwwtId = MAWWW_MawwwtId + 1
	id = tostring(MAWWW_MawwwtId); MAWWW_InstanceIds[inst] = id
	return id
end
local function MAWWW_GetESPParent()
	local okCore, core = pcall(function() return game:GetService("CoreGui") end)
	if okCore and core then return core end
	if gethui then
		local okHui, hui = pcall(gethui)
		if okHui and hui then return hui end
	end
	local playerGui = LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")
	if playerGui then return playerGui end
	return Workspace
end
local function MAWWW_GetESPFolder()
	if MAWWW_ESPFolder and MAWWW_ESPFolder.Parent then return MAWWW_ESPFolder end
	local parent = MAWWW_GetESPParent()
	local old = parent:FindFirstChild("MawwwHub_VisualESP") or parent:FindFirstChild("ZiaanHub_ESP")
	if old then old:Destroy() end
	local folder = Instance.new("Folder"); folder.Name = "MawwwHub_VisualESP"; folder.Parent = parent
	MAWWW_ESPFolder = folder
	return folder
end
local function MAWWW_ClearPrefix(prefix, keepName)
	local folder = MAWWW_GetESPFolder(); local keptExact = false
	for _, child in ipairs(folder:GetChildren()) do
		if child.Name:sub(1, #prefix) == prefix then
			if child.Name == keepName and not keptExact then keptExact = true
			else child:Destroy() end
		end
	end
end
local function MAWWW_ValidPart(part) return part and MAWWW_Alive(part) and part:IsA("BasePart") end
local function MAWWW_FirstBasePart(inst)
	if not MAWWW_Alive(inst) then return nil end
	if inst:IsA("BasePart") then return inst end
	if inst:IsA("Model") then
		if inst.PrimaryPart and inst.PrimaryPart:IsA("BasePart") and MAWWW_Alive(inst.PrimaryPart) then return inst.PrimaryPart end
		local part = inst:FindFirstChildWhichIsA("BasePart", true)
		if MAWWW_ValidPart(part) then return part end
	end
	if inst:IsA("Tool") then
		local handle = inst:FindFirstChild("Handle") or inst:FindFirstChildWhichIsA("BasePart")
		if MAWWW_ValidPart(handle) then return handle end
	end
	return nil
end
local function MAWWW_GetRole(player)
	local teamName = player.Team and player.Team.Name and player.Team.Name:lower() or ""
	if teamName:find("killer") then return "Killer" end
	if teamName:find("survivor") then return "Survivor" end
	if teamName:find("spect") then return "Spectator" end
	return "Survivor"
end
local function MAWWW_PlayerRoleEnabled(player)
	local role = MAWWW_GetRole(player)
	if role == "Killer" then return MAWWW_ESPState.KillerESP end
	if role == "Spectator" then return MAWWW_ESPState.SpectatorESP end
	return MAWWW_ESPState.SurvivorESP
end
local function MAWWW_PlayerColor(player)
	local role = MAWWW_GetRole(player)
	if role == "Killer" then return MAWWW_ESPState.KillerColor end
	if role == "Spectator" then return MAWWW_ESPState.SpectatorColor end
	return MAWWW_ESPState.SurvivorColor
end
local function MAWWW_EnsureHighlight(name, adornee, color, isPlayer)
	if not (adornee and MAWWW_Alive(adornee)) then return nil end
	local folder = MAWWW_GetESPFolder()
	MAWWW_ClearPrefix(name, name)
	local hl = folder:FindFirstChild(name)
	if not hl then
		hl = Instance.new("Highlight"); hl.Name = name; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = folder
	end
	hl.Adornee = adornee; hl.FillColor = color; hl.OutlineColor = color
	if isPlayer then
		hl.FillTransparency = MAWWW_ESPState.ESPFillTransparency
		hl.OutlineTransparency = MAWWW_ESPState.ESPOutlineTransparency
	else
		hl.FillTransparency = 0.98; hl.OutlineTransparency = 0.5
	end
	hl.Enabled = true
	return hl
end
local function MAWWW_DestroyChild(name)
	local folder = MAWWW_GetESPFolder(); local child = folder:FindFirstChild(name)
	if child then child:Destroy() end
end
local function MAWWW_ClearPlayerESP(player)
	if not player or player == LocalPlayer then return end
	local key = MAWWW_PlayerKey(player)
	MAWWW_DestroyChild("MAWWW_PlayerHL_" .. key)
	MAWWW_DestroyChild("MAWWW_PlayerTag_" .. key)
	MAWWW_DestroyChild("MAWWW_PlayerItem_" .. key)
end
local function MAWWW_ClearAllPlayerESP()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then MAWWW_ClearPlayerESP(player) end
	end
end
local function MAWWW_GetSurvivorItem(player)
	local character = player.Character; if not character then return nil end
	for _, obj in ipairs(character:GetDescendants()) do
		if obj:IsA("Tool") or obj:IsA("Accessory") or obj:IsA("Model") then
			if MAWWW_DisplayNames[obj.Name] then return obj.Name end
		end
	end
	return nil
end
local function MAWWW_GetItemImageId(itemName)
	local itemsFolder = ReplicatedStorage:FindFirstChild("Items"); if not itemsFolder then return nil end
	local itemObj = itemsFolder:FindFirstChild(itemName); if not itemObj then return nil end
	if itemObj:IsA("Decal") or itemObj:IsA("Texture") then return itemObj.Texture end
	local texture = itemObj:FindFirstChildWhichIsA("Decal", true) or itemObj:FindFirstChildWhichIsA("Texture", true)
	if texture then return texture.Texture end
	local namedTexture = itemObj:FindFirstChild("Texture", true)
	if namedTexture and (namedTexture:IsA("Decal") or namedTexture:IsA("Texture")) then return namedTexture.Texture end
	return nil
end
local function MAWWW_SetBillboardLine(parent, index, count, data)
	local label = parent:FindFirstChild("Line" .. index)
	if not label then
		label = Instance.new("TextLabel"); label.Name = "Line" .. index
		label.BackgroundTransparency = 1; label.BorderSizePixel = 0
		label.Font = Enum.Font.Gotham; label.TextStrokeTransparency = 0.65; label.TextStrokeColor3 = Color3.new(0, 0, 0)
		label.Parent = parent
	end
	label.Size = UDim2.new(1, 0, 1 / count, 0)
	label.Position = UDim2.new(0, 0, (index - 1) / count, 0)
	label.TextSize = MAWWW_ESPState.ESPTextSize
	label.TextColor3 = data.Color
	label.Text = data.Text
end
local function MAWWW_PruneBillboardLines(parent, count)
	for _, child in ipairs(parent:GetChildren()) do
		if child:IsA("TextLabel") then
			local index = tonumber(child.Name:match("%d+"))
			if index and index > count then child:Destroy() end
		end
	end
end
local function MAWWW_UpdatePlayerTag(player, character, head, color)
	local key = MAWWW_PlayerKey(player); local tagName = "MAWWW_PlayerTag_" .. key
	local folder = MAWWW_GetESPFolder()
	MAWWW_ClearPrefix("MAWWW_PlayerTag_" .. key, tagName)
	if not MAWWW_ValidPart(head) then MAWWW_DestroyChild(tagName); return end
	local lines = {}
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local targetRoot = character and character:FindFirstChild("HumanoidRootPart")
	local distanceText = ""
	if MAWWW_ESPState.DistanceESP and root and targetRoot then
		distanceText = "[" .. tostring(math.floor((root.Position - targetRoot.Position).Magnitude)) .. "m]"
	end
	local nameText = MAWWW_ESPState.Nametags and player.Name or ""
	local mainLine = ""
	if nameText ~= "" and distanceText ~= "" then mainLine = nameText .. " " .. distanceText
	elseif nameText ~= "" then mainLine = nameText
	elseif distanceText ~= "" then mainLine = distanceText end
	if mainLine ~= "" then table.insert(lines, { Text = mainLine, Color = color }) end
	if #lines == 0 then MAWWW_DestroyChild(tagName); return end
	local tag = folder:FindFirstChild(tagName)
	if not tag then
		tag = Instance.new("BillboardGui"); tag.Name = tagName
		tag.AlwaysOnTop = true; tag.LightInfluence = 0; tag.MaxDistance = 0; tag.Parent = folder
	end
	tag.Adornee = head; tag.Enabled = true
	tag.Size = UDim2.new(0, 220, 0, #lines * 20)
	tag.StudsOffset = Vector3.new(0, 2.65, 0)
	for i, data in ipairs(lines) do MAWWW_SetBillboardLine(tag, i, #lines, data) end
	MAWWW_PruneBillboardLines(tag, #lines)
end
local function MAWWW_UpdatePlayerItemIcon(player, torso)
	local key = MAWWW_PlayerKey(player); local iconName = "MAWWW_PlayerItem_" .. key
	local folder = MAWWW_GetESPFolder()
	MAWWW_ClearPrefix("MAWWW_PlayerItem_" .. key, iconName)
	if not MAWWW_ValidPart(torso) then MAWWW_DestroyChild(iconName); return end
	local itemName = MAWWW_GetSurvivorItem(player)
	local imageId = itemName and MAWWW_GetItemImageId(itemName) or nil
	if not imageId then MAWWW_DestroyChild(iconName); return end
	local icon = folder:FindFirstChild(iconName)
	if not icon then
		icon = Instance.new("BillboardGui"); icon.Name = iconName
		icon.AlwaysOnTop = true; icon.LightInfluence = 0; icon.MaxDistance = 0
		icon.Size = UDim2.fromOffset(20, 20); icon.StudsOffset = Vector3.new(0, 0, -1.6); icon.Parent = folder
		local image = Instance.new("ImageLabel"); image.Name = "ImageLabel"; image.BackgroundTransparency = 1; image.Size = UDim2.fromScale(1, 1); image.Parent = icon
	end
	icon.Adornee = torso; icon.Enabled = true
	local image = icon:FindFirstChild("ImageLabel")
	if image then image.Image = imageId end
end
local function MAWWW_ApplyPlayerESP(player)
	if MAWWW_Dead or not player or player == LocalPlayer then return end
	local character = player.Character
	if not (character and MAWWW_Alive(character)) then MAWWW_ClearPlayerESP(player); return end
	local key = MAWWW_PlayerKey(player)
	local enabled = MAWWW_ESPState.PlayerMasterESP and MAWWW_PlayerRoleEnabled(player)
	if not enabled then MAWWW_ClearPlayerESP(player); return end
	local color = MAWWW_PlayerColor(player)
	local head = character:FindFirstChild("Head")
	local torso = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	MAWWW_EnsureHighlight("MAWWW_PlayerHL_" .. key, character, color, true)
	MAWWW_UpdatePlayerTag(player, character, head, color)
	if MAWWW_GetRole(player) == "Survivor" and MAWWW_ESPState.SurvivorItemsESP then
		MAWWW_UpdatePlayerItemIcon(player, torso)
	else MAWWW_DestroyChild("MAWWW_PlayerItem_" .. key) end
end
local function MAWWW_RefreshAllPlayers()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then pcall(MAWWW_ApplyPlayerESP, player) end
	end
end
local function MAWWW_StartPlayerLoop()
	if MAWWW_PlayerLoopThread then return end
	MAWWW_PlayerLoopThread = task.spawn(function()
		while not MAWWW_Dead and MAWWW_ESPState.PlayerMasterESP do
			MAWWW_RefreshAllPlayers(); task.wait(0.25)
		end
		MAWWW_PlayerLoopThread = nil
	end)
end
local function MAWWW_WatchPlayer(player)
	if player == LocalPlayer then return end
	if MAWWW_PlayerConns[player] then
		for _, conn in ipairs(MAWWW_PlayerConns[player]) do if conn then pcall(function() conn:Disconnect() end) end end
	end
	MAWWW_PlayerConns[player] = {}
	table.insert(MAWWW_PlayerConns[player], player.CharacterAdded:Connect(function()
		MAWWW_ClearPlayerESP(player)
		task.delay(0.15, function() if not MAWWW_Dead then pcall(MAWWW_ApplyPlayerESP, player) end end)
	end))
	table.insert(MAWWW_PlayerConns[player], player.CharacterRemoving:Connect(function() MAWWW_ClearPlayerESP(player) end))
	table.insert(MAWWW_PlayerConns[player], player:GetPropertyChangedSignal("Team"):Connect(function()
		MAWWW_ClearPlayerESP(player); pcall(MAWWW_ApplyPlayerESP, player)
	end))
	if player.Character then pcall(MAWWW_ApplyPlayerESP, player) end
end
local function MAWWW_UnwatchPlayer(player)
	MAWWW_ClearPlayerESP(player)
	if MAWWW_PlayerConns[player] then
		for _, conn in ipairs(MAWWW_PlayerConns[player]) do if conn then pcall(function() conn:Disconnect() end) end end
	end
	MAWWW_PlayerConns[player] = nil
end
local function MAWWW_PickWorldPart(model, cat)
	if not (model and MAWWW_Alive(model)) then return nil end
	if cat == "Generator" then
		local hitbox = model:FindFirstChild("HitBox", true) or model:FindFirstChild("GeneratorPoint", true)
		if MAWWW_ValidPart(hitbox) then return hitbox end
	elseif cat == "Palletwrong" then
		local candidates = { model:FindFirstChild("HumanoidRootPart", true), model:FindFirstChild("PrimaryPartPallet", true), model:FindFirstChild("Primary1", true), model:FindFirstChild("Primary2", true), model:FindFirstChild("PalletPoint", true), model:FindFirstChild("PalletPointSlide", true) }
		for _, part in ipairs(candidates) do if MAWWW_ValidPart(part) then return part end end
	elseif cat == "Window" then
		local vault = model:FindFirstChild("VaultPoint", true) or model:FindFirstChild("VaultTrigger", true)
		if MAWWW_ValidPart(vault) then return vault end
	elseif cat == "SCPZombie" then
		local root = model:FindFirstChild("HumanoidRootPart", true)
		if MAWWW_ValidPart(root) then return root end
		local torso = model:FindFirstChild("UpperTorso", true) or model:FindFirstChild("Torso", true)
		if MAWWW_ValidPart(torso) then return torso end
		return nil
	end
	return MAWWW_FirstBasePart(model)
end
local function MAWWW_GeneratorLabel(model)
	local pct = tonumber(model:GetAttribute("RepairProgress")) or 0
	if pct >= 0 and pct <= 1.001 then pct = pct * 100 end
	pct = MAWWW_Clamp(pct, 0, 100)
	local repairers = tonumber(model:GetAttribute("PlayersRepairingCount")) or 0
	local paused = model:GetAttribute("ProgressPaused") == true
	local kickcount = tonumber(model:GetAttribute("kickcount")) or 0
	local abyss50 = model:GetAttribute("Abyss50Triggered") == true
	local parts = { "Gen " .. tostring(math.floor(pct + 0.5)) .. "%" }
	if repairers > 0 then table.insert(parts, "(" .. repairers .. "p)") end
	if paused then table.insert(parts, "Pause") end
	if abyss50 then table.insert(parts, "Warn") end
	if kickcount > 0 then table.insert(parts, "K:" .. kickcount) end
	local hue = MAWWW_Clamp((pct / 100) * 0.33, 0, 0.33)
	return table.concat(parts, " "), Color3.fromHSV(hue, 1, 1)
end
local function MAWWW_HasBasePart(model)
	if not (model and MAWWW_Alive(model)) then return false end
	return model:FindFirstChildWhichIsA("BasePart", true) ~= nil
end
local function MAWWW_IsPalletGone(model)
	if not MAWWW_Alive(model) then return true end
	if not model:IsDescendantOf(Workspace) then return true end
	if MAWWW_PalletState[model] == "DEST" then return true end
	local ok, destroyed = pcall(function() return model:GetAttribute("Destroyed") end)
	if ok and destroyed == true then return true end
	return not MAWWW_HasBasePart(model)
end
local function MAWWW_WorldKey(cat, model) return "MAWWW_World_" .. cat .. "_" .. MAWWW_EspId(model) end
local function MAWWW_ClearWorldVisual(cat, model)
	if not model then return end
	MAWWW_DestroyChild(MAWWW_WorldKey(cat, model) .. "_HL")
	MAWWW_DestroyChild(MAWWW_WorldKey(cat, model) .. "_Tag")
end
local function MAWWW_RemoveWorldEntry(cat, model)
	if not MAWWW_WorldReg[cat] or not MAWWW_WorldReg[cat][model] then return end
	MAWWW_ClearWorldVisual(cat, model)
	MAWWW_WorldReg[cat][model] = nil
end
local function MAWWW_EnsureWorldEntry(cat, model)
	if not MAWWW_Alive(model) or not MAWWW_WorldReg[cat] or MAWWW_WorldReg[cat][model] then return end
	if cat == "Palletwrong" and MAWWW_IsPalletGone(model) then return end
	local part = MAWWW_PickWorldPart(model, cat)
	if not MAWWW_ValidPart(part) then return end
	MAWWW_WorldReg[cat][model] = { part = part }
end
local function MAWWW_RegisterWorldDescendant(obj)
	if not MAWWW_Alive(obj) then return end
	local validCats = { Generator = true, Hook = true, Gate = true, Window = true, Palletwrong = true }
	if obj:IsA("Model") then
		if validCats[obj.Name] then MAWWW_EnsureWorldEntry(obj.Name, obj); return end
		local lower = obj.Name:lower()
		if lower:find("scp") or lower:find("zombie") then MAWWW_EnsureWorldEntry("SCPZombie", obj) end
		return
	end
	if obj:IsA("BasePart") then
		local parent = obj.Parent
		while parent and parent ~= Workspace do
			if parent:IsA("Model") then
				if validCats[parent.Name] then MAWWW_EnsureWorldEntry(parent.Name, parent); return end
				local lower = parent.Name:lower()
				if lower:find("scp") or lower:find("zombie") then MAWWW_EnsureWorldEntry("SCPZombie", parent); return end
			end
			parent = parent.Parent
		end
	end
end
local function MAWWW_UnregisterWorldDescendant(obj)
	if not obj then return end
	local validCats = { Generator = true, Hook = true, Gate = true, Window = true, Palletwrong = true }
	if obj:IsA("Model") then
		if validCats[obj.Name] then MAWWW_RemoveWorldEntry(obj.Name, obj); return end
		local lower = obj.Name:lower()
		if lower:find("scp") or lower:find("zombie") then MAWWW_RemoveWorldEntry("SCPZombie", obj) end
		return
	end
	if obj:IsA("BasePart") then
		for cat, models in pairs(MAWWW_WorldReg) do
			for model, entry in pairs(models) do
				if entry.part == obj then MAWWW_RemoveWorldEntry(cat, model) end
			end
		end
	end
end
local function MAWWW_AttachESPRoot(root)
	if not root or MAWWW_MapAdd[root] then return end
	MAWWW_MapAdd[root] = root.DescendantAdded:Connect(MAWWW_RegisterWorldDescendant)
	MAWWW_MapRem[root] = root.DescendantRemoving:Connect(MAWWW_UnregisterWorldDescendant)
	for _, descendant in ipairs(root:GetDescendants()) do MAWWW_RegisterWorldDescendant(descendant) end
end
local function MAWWW_RefreshESPRoots()
	for _, conn in pairs(MAWWW_MapAdd) do if conn then pcall(function() conn:Disconnect() end) end end
	for _, conn in pairs(MAWWW_MapRem) do if conn then pcall(function() conn:Disconnect() end) end end
	MAWWW_MapAdd, MAWWW_MapRem = {}, {}
	for cat, models in pairs(MAWWW_WorldReg) do
		for model in pairs(models) do MAWWW_ClearWorldVisual(cat, model) end
		MAWWW_WorldReg[cat] = {}
	end
	local map = Workspace:FindFirstChild("Map"); local map1 = Workspace:FindFirstChild("Map1")
	if map then MAWWW_AttachESPRoot(map) end
	if map1 then MAWWW_AttachESPRoot(map1) end
end
local function MAWWW_LabelForPallet(model)
	local state = MAWWW_PalletState[model] or "UP"
	if state == "DOWN" then return "Pallet (down)" end
	if state == "DEST" then return "Pallet (destroyed)" end
	if state == "SLIDE" then return "Pallet (slide)" end
	return "Pallet"
end
local function MAWWW_LabelForWindow(model)
	local state = MAWWW_WindowState[model] or "READY"
	if state == "BUSY" then return "Window (busy)" end
	return "Window"
end
local function MAWWW_AnyWorldEnabled()
	return MAWWW_ESPState.WorldMasterESP and (MAWWW_ESPState.GeneratorESP or MAWWW_ESPState.HookESP or MAWWW_ESPState.GateESP or MAWWW_ESPState.WindowESP or MAWWW_ESPState.PalletESP or MAWWW_ESPState.SCPZombieESP)
end
local function MAWWW_WorldCategoryData(cat)
	if cat == "Generator" then return MAWWW_ESPState.GeneratorESP, MAWWW_ESPState.GeneratorColor end
	if cat == "Hook" then return MAWWW_ESPState.HookESP, MAWWW_ESPState.HookColor end
	if cat == "Gate" then return MAWWW_ESPState.GateESP, MAWWW_ESPState.GateColor end
	if cat == "Window" then return MAWWW_ESPState.WindowESP, MAWWW_ESPState.WindowColor end
	if cat == "Palletwrong" then return MAWWW_ESPState.PalletESP, MAWWW_ESPState.PalletColor end
	if cat == "SCPZombie" then return MAWWW_ESPState.SCPZombieESP, MAWWW_ESPState.SCPZombieColor end
	return false, Color3.new(1, 1, 1)
end
local function MAWWW_UpdateWorldTag(cat, model, part, color)
	local key = MAWWW_WorldKey(cat, model); local tagName = key .. "_Tag"
	local folder = MAWWW_GetESPFolder()
	MAWWW_ClearPrefix(tagName, tagName)
	if not MAWWW_ValidPart(part) then MAWWW_DestroyChild(tagName); return end
	local lines = {}
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local distanceText = ""
	if MAWWW_ESPState.WorldDistanceESP and root then
		distanceText = "[" .. tostring(math.floor((root.Position - part.Position).Magnitude)) .. "m]"
	end
	local nameText = ""; local labelColor = color
	if MAWWW_ESPState.WorldNametags then
		if cat == "Generator" then local txt, genColor = MAWWW_GeneratorLabel(model); nameText = txt; labelColor = genColor
		elseif cat == "Palletwrong" then nameText = MAWWW_LabelForPallet(model)
		elseif cat == "Window" then nameText = MAWWW_LabelForWindow(model)
		elseif cat == "SCPZombie" then nameText = model.Name
		else nameText = cat end
	end
	local mainLine = ""
	if nameText ~= "" and distanceText ~= "" then mainLine = nameText .. " " .. distanceText
	elseif nameText ~= "" then mainLine = nameText
	elseif distanceText ~= "" then mainLine = distanceText end
	if mainLine ~= "" then table.insert(lines, { Text = mainLine, Color = labelColor }) end
	if #lines == 0 then MAWWW_DestroyChild(tagName); return end
	local tag = folder:FindFirstChild(tagName)
	if not tag then
		tag = Instance.new("BillboardGui"); tag.Name = tagName
		tag.AlwaysOnTop = true; tag.LightInfluence = 0; tag.MaxDistance = 0; tag.Parent = folder
	end
	tag.Adornee = part; tag.Enabled = true
	tag.Size = UDim2.new(0, 220, 0, #lines * 20)
	tag.StudsOffset = Vector3.new(0, 2.5, 0)
	for i, data in ipairs(lines) do MAWWW_SetBillboardLine(tag, i, #lines, data) end
	MAWWW_PruneBillboardLines(tag, #lines)
end
local function MAWWW_ClearAllWorldESP()
	for cat, models in pairs(MAWWW_WorldReg) do
		for model in pairs(models) do MAWWW_ClearWorldVisual(cat, model) end
	end
end
local function MAWWW_StartWorldLoop()
	if MAWWW_WorldLoopThread then return end
	MAWWW_WorldLoopThread = task.spawn(function()
		while not MAWWW_Dead and MAWWW_AnyWorldEnabled() do
			for cat, models in pairs(MAWWW_WorldReg) do
				local enabled, color = MAWWW_WorldCategoryData(cat)
				if enabled and MAWWW_ESPState.WorldMasterESP then
					local n = 0
					for model, entry in pairs(models) do
						if cat == "Palletwrong" and MAWWW_IsPalletGone(model) then
							MAWWW_RemoveWorldEntry(cat, model)
						elseif model and MAWWW_Alive(model) then
							local part = entry.part
							if not MAWWW_ValidPart(part) or (model:IsA("Model") and not part:IsDescendantOf(model)) then
								entry.part = MAWWW_PickWorldPart(model, cat); part = entry.part
							end
							if MAWWW_ValidPart(part) then
								local key = MAWWW_WorldKey(cat, model)
								MAWWW_EnsureHighlight(key .. "_HL", model, color, false)
								MAWWW_UpdateWorldTag(cat, model, part, color)
							else MAWWW_RemoveWorldEntry(cat, model) end
						else MAWWW_RemoveWorldEntry(cat, model) end
						n = n + 1
						if n % 60 == 0 then task.wait() end
					end
				else
					for model in pairs(models) do MAWWW_ClearWorldVisual(cat, model) end
				end
			end
			task.wait(0.25)
		end
		MAWWW_WorldLoopThread = nil	end)
end
local function MAWWW_Selected(selected, name)
	if type(selected) ~= "table" then return false end
	if selected[name] ~= nil then return selected[name] == true end
	for _, value in pairs(selected) do if value == name then return true end end
	return false
end

-- Init World ESP roots
for _, player in ipairs(Players:GetPlayers()) do MAWWW_WatchPlayer(player) end
table.insert(MAWWW_Connections, Players.PlayerAdded:Connect(MAWWW_WatchPlayer))
table.insert(MAWWW_Connections, Players.PlayerRemoving:Connect(MAWWW_UnwatchPlayer))
table.insert(MAWWW_Connections, Workspace.ChildAdded:Connect(function(child)
	if child.Name == "Map" or child.Name == "Map1" then
		MAWWW_AttachESPRoot(child)
		if MAWWW_ESPState.WorldMasterESP and MAWWW_AnyWorldEnabled() then MAWWW_StartWorldLoop() end
	end
end))
table.insert(MAWWW_Connections, Workspace.ChildRemoved:Connect(function(child)
	if child.Name == "Map" or child.Name == "Map1" then MAWWW_RefreshESPRoots() end
end))
MAWWW_RefreshESPRoots()

-- ==========================================
-- // VISUAL UI
-- ==========================================
local VisSettingsCard = VisualPage:CreateSection("Highlight ESP Settings")

VisSettingsCard:AddSlider("ESP Fill Transparency", 0, 1, MAWWW_ESPState.ESPFillTransparency, function(v)
	MAWWW_ESPState.ESPFillTransparency = v
	MAWWW_RefreshAllPlayers()
end, {
	Title = "ESP Fill Transparency",
	Description = "Transparansi bagian isi highlight (0 = solid, 1 = transparan).",
	Example = "Atur sesuai selera biar gak terlalu tebal."
})

VisSettingsCard:AddSlider("ESP Outline Transparency", 0, 1, MAWWW_ESPState.ESPOutlineTransparency, function(v)
	MAWWW_ESPState.ESPOutlineTransparency = v
	MAWWW_RefreshAllPlayers()
end, {
	Title = "ESP Outline Transparency",
	Description = "Transparansi garis tepi highlight.",
	Example = "Set 0.3 default untuk garis tepi yang jelas."
})

VisSettingsCard:AddSlider("ESP Text Size", 8, 22, MAWWW_ESPState.ESPTextSize, function(v)
	MAWWW_ESPState.ESPTextSize = v
	MAWWW_RefreshAllPlayers()
end, {
	Title = "ESP Text Size",
	Description = "Ukuran teks nametag & distance ESP.",
	Example = "8 default, naikkan kalau susah dibaca."
})

-- Player ESP
local PlayerESPCard = VisualPage:CreateSection("Player Highlight ESP")

PlayerESPCard:AddToggle("Enable Player ESP", false, function(state)
	MAWWW_ESPState.PlayerMasterESP = state
	if state then
		MAWWW_StartPlayerLoop()
		MAWWW_RefreshAllPlayers()
	else
		MAWWW_ClearAllPlayerESP()
	end
end, {
	Title = "Enable Player ESP",
	Description = "Master toggle untuk Player ESP.",
	Example = "Aktifkan dulu sebelum pilih role di bawah."
})

PlayerESPCard:AddDropdown("Select Player ESP",
	{"Survivor ESP", "Killer ESP", "Spectator ESP", "Survivor Items ESP"},
	true,
	function(selected)
		MAWWW_ESPState.SurvivorESP      = MAWWW_Selected(selected, "Survivor ESP")
		MAWWW_ESPState.KillerESP        = MAWWW_Selected(selected, "Killer ESP")
		MAWWW_ESPState.SpectatorESP     = MAWWW_Selected(selected, "Spectator ESP")
		MAWWW_ESPState.SurvivorItemsESP = MAWWW_Selected(selected, "Survivor Items ESP")
		if MAWWW_ESPState.PlayerMasterESP then
			MAWWW_StartPlayerLoop()
			MAWWW_RefreshAllPlayers()
		else MAWWW_ClearAllPlayerESP() end
	end,
	{
		Title = "Select Player ESP",
		Description = "Pilih role mana yang mau di-ESP.",
		Example = "Bisa pilih lebih dari satu (multi-select)."
	}
)

PlayerESPCard:AddToggle("Player Nametags", false, function(state)
	MAWWW_ESPState.Nametags = state
	if MAWWW_ESPState.PlayerMasterESP then MAWWW_StartPlayerLoop(); MAWWW_RefreshAllPlayers() else MAWWW_ClearAllPlayerESP() end
end, {
	Title = "Player Nametags",
	Description = "Tampilkan nama player di atas kepala.",
	Example = "Kombinasikan dengan Distance ESP untuk info lengkap."
})

PlayerESPCard:AddToggle("Player Distance ESP", false, function(state)
	MAWWW_ESPState.DistanceESP = state
	if MAWWW_ESPState.PlayerMasterESP then MAWWW_StartPlayerLoop(); MAWWW_RefreshAllPlayers() else MAWWW_ClearAllPlayerESP() end
end, {
	Title = "Player Distance ESP",
	Description = "Tampilkan jarak player dari kamu dalam meter.",
	Example = "Berguna untuk tahu seberapa dekat killer."
})

PlayerESPCard:AddColorPicker("Survivor Color", MAWWW_ESPState.SurvivorColor, function(color)
	MAWWW_ESPState.SurvivorColor = color; MAWWW_RefreshAllPlayers()
end, {
	Title = "Survivor Color",
	Description = "Warna highlight untuk survivor.",
	Example = "Default cyan."
})

PlayerESPCard:AddColorPicker("Killer Color", MAWWW_ESPState.KillerColor, function(color)
	MAWWW_ESPState.KillerColor = color; MAWWW_RefreshAllPlayers()
end, {
	Title = "Killer Color",
	Description = "Warna highlight untuk killer.",
	Example = "Default merah."
})

PlayerESPCard:AddColorPicker("Spectator Color", MAWWW_ESPState.SpectatorColor, function(color)
	MAWWW_ESPState.SpectatorColor = color; MAWWW_RefreshAllPlayers()
end, {
	Title = "Spectator Color",
	Description = "Warna highlight untuk spectator.",
	Example = "Default putih."
})

-- World ESP
local WorldESPCard = VisualPage:CreateSection("World Highlight ESP")

WorldESPCard:AddToggle("Enable World ESP", false, function(state)
	MAWWW_ESPState.WorldMasterESP = state
	if state then
		MAWWW_RefreshESPRoots()
		if MAWWW_AnyWorldEnabled() then MAWWW_StartWorldLoop() end
	else MAWWW_ClearAllWorldESP() end
end, {
	Title = "Enable World ESP",
	Description = "Master toggle untuk World ESP.",
	Example = "Aktifkan dulu sebelum pilih objek di bawah."
})

WorldESPCard:AddDropdown("Select World Objects",
	{"Generators", "Hooks", "Gates", "Windows", "Pallets", "SCP / Zombie"},
	true,
	function(selected)
		MAWWW_ESPState.GeneratorESP = MAWWW_Selected(selected, "Generators")
		MAWWW_ESPState.HookESP      = MAWWW_Selected(selected, "Hooks")
		MAWWW_ESPState.GateESP      = MAWWW_Selected(selected, "Gates")
		MAWWW_ESPState.WindowESP    = MAWWW_Selected(selected, "Windows")
		MAWWW_ESPState.PalletESP    = MAWWW_Selected(selected, "Pallets")
		MAWWW_ESPState.SCPZombieESP = MAWWW_Selected(selected, "SCP / Zombie")
		if MAWWW_ESPState.WorldMasterESP and MAWWW_AnyWorldEnabled() then
			MAWWW_RefreshESPRoots()
			MAWWW_StartWorldLoop()
		else MAWWW_ClearAllWorldESP() end
	end,
	{
		Title = "Select World Objects",
		Description = "Pilih objek map mana yang mau di-ESP.",
		Example = "Multi-select, bisa pilih banyak sekaligus."
	}
)

WorldESPCard:AddToggle("World Nametags", false, function(state)
	MAWWW_ESPState.WorldNametags = state
	if MAWWW_ESPState.WorldMasterESP and MAWWW_AnyWorldEnabled() then MAWWW_StartWorldLoop() else MAWWW_ClearAllWorldESP() end
end, {
	Title = "World Nametags",
	Description = "Tampilkan nama objek (Gen 45%, Pallet, dll) di atasnya.",
	Example = "Generator label otomatis nampilkan % progress."
})

WorldESPCard:AddToggle("World Distance ESP", false, function(state)
	MAWWW_ESPState.WorldDistanceESP = state
	if MAWWW_ESPState.WorldMasterESP and MAWWW_AnyWorldEnabled() then MAWWW_StartWorldLoop() else MAWWW_ClearAllWorldESP() end
end, {
	Title = "World Distance ESP",
	Description = "Tampilkan jarak objek world dari kamu.",
	Example = "Berguna untuk tahu jarak generator terdekat."
})

WorldESPCard:AddColorPicker("Generator Color", MAWWW_ESPState.GeneratorColor, function(color) MAWWW_ESPState.GeneratorColor = color end, { Title = "Generator Color", Description = "Warna highlight generator.", Example = "Default oranye." })
WorldESPCard:AddColorPicker("Hook Color",      MAWWW_ESPState.HookColor,      function(color) MAWWW_ESPState.HookColor = color end,      { Title = "Hook Color",      Description = "Warna highlight hook.",      Example = "Default merah." })
WorldESPCard:AddColorPicker("Gate Color",      MAWWW_ESPState.GateColor,      function(color) MAWWW_ESPState.GateColor = color end,      { Title = "Gate Color",      Description = "Warna highlight gate.",      Example = "Default kuning." })
WorldESPCard:AddColorPicker("Window Color",    MAWWW_ESPState.WindowColor,    function(color) MAWWW_ESPState.WindowColor = color end,    { Title = "Window Color",    Description = "Warna highlight window.",    Example = "Default putih." })
WorldESPCard:AddColorPicker("Pallet Color",    MAWWW_ESPState.PalletColor,    function(color) MAWWW_ESPState.PalletColor = color end,    { Title = "Pallet Color",    Description = "Warna highlight pallet.",    Example = "Default oranye." })
WorldESPCard:AddColorPicker("SCP / Zombie Color", MAWWW_ESPState.SCPZombieColor, function(color) MAWWW_ESPState.SCPZombieColor = color end, { Title = "SCP / Zombie Color", Description = "Warna highlight SCP / zombie.", Example = "Default ungu." })

-- ==========================================
-- // KILLER UI - AUTO KILL ALL
-- ==========================================
local KillAllCard = KillerPage:CreateSection("Auto Kill All")
KillAllCard:AddToggle("Auto Kill All", false, function(state) setAutoKillAll(state) end, {
	Title = "Auto Kill All", Description = "Auto chase & attack survivor terdekat.", Example = "Aktifkan saat jadi Killer."
})

-- AUTO HOOK
local AutoHookCard = KillerPage:CreateSection("Auto Hook")
AutoHookCard:AddToggle("Auto Hook", false, function(state) setAutoHook(state) end, {
	Title = "Auto Hook", Description = "Auto pickup & hook survivor downed.", Example = "Aktifkan saat jadi Killer."
})

-- DASH LOCK
local DashLockCard = KillerPage:CreateSection("Dash Lock")
DashLockCard:AddToggle("Dash Lock", false, function(state) DashLock.Enabled = state; if not state then DashLock_SetActive(false) end end, {
	Title = "Dash Lock", Description = "Auto-lock kamera ke survivor terdekat saat dash.", Example = "Untuk Killer Hidden."
})
DashLockCard:AddToggle("Freeze During Dash", false, function(state) DashLock.FreezeDuringDash = state end, { Title = "Freeze During Dash", Description = "Kunci WalkSpeed ke 0 saat dash." })
DashLockCard:AddSlider("Smoothness", 0.05, 1, 0.3, function(val) DashLock.Smoothness = val end, { Title = "Camera Smoothness", Description = "Kecepatan kamera follow target." })
DashLockCard:AddSlider("Duration", 0.5, 5, 1.5, function(val) DashLock.Duration = val end, { Title = "Lock Duration", Description = "Durasi lock setelah dash." })

-- HIDDEN BYPASS
local HiddenCard = KillerPage:CreateSection("Bypass No Cooldown Hidden")
HiddenCard:AddToggle("Bypass Cooldown Hidden", false, function(state) setHiddenBypass(state) end, { Title = "Bypass Cooldown Hidden", Description = "Scan tryActivate & playM2Animation, paksa boolean jadi false." })
HiddenCard:AddButton("Refresh Hidden Scan", function()
	HiddenBypass.LeapFunction = nil; HiddenBypass.M2Function = nil
	local found = Hidden_ScanGC()
	Library:Notify({ Title = "Hidden Bypass", Description = found and "Function ditemukan!" or "Function tidak ditemukan.", Duration = 2 })
end, { Title = "Refresh Hidden Scan", Description = "Force scan ulang memori." })

-- ABYSS BYPASS
local AbyssCard = KillerPage:CreateSection("Bypass No Cooldown Abyss")
AbyssCard:AddToggle("Bypass Cooldown Abyss", false, function(state) setAbyssBypass(state) end, { Title = "Bypass Cooldown Abyss", Description = "Scan corruptHandler & paksa boolean true." })
AbyssCard:AddButton("Refresh Handler Scan", function()
	AbyssBypass.HandlerFunc = nil; AbyssBypass.ScanTried = false
	local found = Abyss_FindHandler()
	Library:Notify({ Title = "Abyss Bypass", Description = found and "Handler ditemukan!" or "Handler tidak ditemukan.", Duration = 2 })
end, { Title = "Refresh Handler Scan", Description = "Force scan ulang memori." })

-- MYERS GRAB
local MyersCard = KillerPage:CreateSection("Bypass No Cooldown Myers")
MyersCard:AddToggle("Infinite Grab Myers", false, function(state)
	MyersGrabData.Enabled = state
	if MyersGrabData.Button then MyersGrabData.Button.Visible = state end
	if state then Library:Notify({ Title = "Myers Grab", Description = isMobile and "Klik tombol GRAB!" or "Tekan H!", Duration = 3 }) end
end, { Title = "Infinite Grab Myers", Description = "Auto grab survivor tanpa cooldown." })

-- SILENT SPEAR (VEIL)
local VeilCard = KillerPage:CreateSection("Silent Spear (Veil)")
VeilCard:AddToggle("Silent Spear", false, function(state) VeilConfig.Enabled = state end, { Title = "Silent Spear", Description = "Aimbot spear Veil dengan prediction." })
VeilCard:AddToggle("Auto Predict", false, function(state) VeilConfig.AutoPredict = state end, { Title = "Auto Predict", Description = "Prediksi velocity horizontal." })
VeilCard:AddToggle("Show FOV", true, function(state) VeilConfig.ShowFOV = state end, { Title = "Show FOV", Description = "Tampilkan FOV circle." })
VeilCard:AddToggle("Show Target Laser", true, function(state) VeilConfig.ShowTargetLaser = state end, { Title = "Show Target Laser", Description = "Tampilkan garis laser target." })
VeilCard:AddDropdown("Target Part", {"Torso", "Head", "Root"}, false, function(part) VeilConfig.TargetPart = part end, { Title = "Target Part", Description = "Bagian tubuh target." })
VeilCard:AddSlider("FOV Radius", 50, 500, 220, function(val) VeilConfig.FOV = val end, { Title = "FOV Radius", Description = "Radius FOV circle." })
VeilCard:AddSlider("Spear Speed", 50, 400, 165, function(val) VeilConfig.SpearSpeed = val end, { Title = "Spear Speed", Description = "Kecepatan spear." })
VeilCard:AddSlider("Gravity", 10, 200, workspace.Gravity * 0.5, function(val) VeilConfig.Gravity = val end, { Title = "Gravity", Description = "Gravitasi drop prediction." })
VeilCard:AddSlider("Max Distance", 50, 500, 200, function(val) VeilConfig.MaxDist = val end, { Title = "Max Distance", Description = "Jarak maksimal aim." })
VeilCard:AddSlider("Horizontal Predict", 0, 3, 1, function(val) VeilConfig.HorizontalPredictFactor = val end, { Title = "Horizontal Predict", Description = "Multiplier prediksi horizontal." })

-- SURVIVOR PAGE (ringkas - fitur yang sudah ada)
local HealCard = SurvivorPage:CreateSection("Healing")
HealCard:AddToggle("Self Heal Progress", false, function(state) setInstantHealSelf(state) end, { Title = "Self Heal Progress", Description = "Auto heal saat HP < 90%." })
HealCard:AddToggle("Auto Heal All", false, function(state) setAutoHealAll(state) end, { Title = "Auto Heal All", Description = "Auto heal semua survivor." })

local SilentAimCard = SurvivorPage:CreateSection("Silent Aim (ToF/Pistol)")
SilentAimCard:AddToggle("Silent Aim", false, function(state) AimConfig.Aim_Silent = state end, { Title = "Silent Aim", Description = "Aim otomatis tanpa ubah kamera." })
SilentAimCard:AddToggle("Lock Aim", false, function(state) AimConfig.LockAim = state end, { Title = "Lock Aim", Description = "Kunci kamera saat charging." })
SilentAimCard:AddDropdown("Aim Target", {"Killer", "Survivor"}, false, function(t) AimConfig.Pistol_Target = t end, { Title = "Aim Target", Description = "Pilih target." })
SilentAimCard:AddDropdown("Aim Part", {"Torso", "Head", "Root"}, false, function(p) AimConfig.AIM_TargetPart = p end, { Title = "Aim Part", Description = "Bagian tubuh." })
SilentAimCard:AddToggle("Block When Knocked", false, function(state) AimConfig.Pistol_BlockKnocked = state end, { Title = "Block When Knocked", Description = "Matikan saat down." })
SilentAimCard:AddToggle("Hide Laser", false, function(state) AimConfig.HideSilentLaser = state end, { Title = "Hide Laser", Description = "Sembunyikan laser." })
SilentAimCard:AddToggle("Flash Silent Aim", false, function(state) AimConfig.Flash_Silent = state end, { Title = "Flash Silent Aim", Description = "Auto aim flash." })
SilentAimCard:AddSlider("Flash Y Offset", -20, 20, 8, function(val) AimConfig.Flash_YOffset = val end, { Title = "Flash Y Offset", Description = "Offset ketinggian flash." })
SilentAimCard:AddToggle("FOV Mode", false, function(state) AimConfig.Pistol_FOVMode = state end, { Title = "FOV Mode", Description = "Batasi target dalam FOV." })
SilentAimCard:AddToggle("Show FOV", false, function(state) AimConfig.Pistol_ShowFOV = state end, { Title = "Show FOV", Description = "Tampilkan FOV circle." })
SilentAimCard:AddSlider("FOV Radius", 50, 500, 150, function(val) AimConfig.Pistol_FOV = val end, { Title = "FOV Radius", Description = "Radius FOV." })

local ParryCard = SurvivorPage:CreateSection("Auto Parry")
ParryCard:AddToggle("Auto Parry", false, function(state) Config.Surv_AutoParry = state end, { Title = "Auto Parry", Description = "Auto parry berdasarkan animasi killer." })
ParryCard:AddToggle("Safety Parry", false, function(state) Config.Surv_ParrySafety = state end, { Title = "Safety Parry", Description = "Skip parry saat interaksi." })
ParryCard:AddToggle("Aggressive Mode", false, function(state) Config.Surv_ParryAggressive = state end, { Title = "Aggressive Mode", Description = "Parry tanpa cek facing." })
ParryCard:AddToggle("ESP Range Circle", true, function(state) Config.Surv_ParryCircle = state end, { Title = "ESP Range Circle", Description = "Tampilkan radius parry." })
ParryCard:AddSlider("Parry Radius", 5, 25, 15, function(val) Config.Surv_ParryRadius = val end, { Title = "Parry Radius", Description = "Range parry." })
ParryCard:AddSlider("Face Sensitivity", -10, 10, 7, function(val) Config.Surv_ParryFace = val / 10 end, { Title = "Face Sensitivity", Description = "Sensitivitas facing." })
ParryCard:AddToggle("Auto Crouch", false, function(state) Config.Surv_AutoCrouch = state end, { Title = "Auto Crouch", Description = "Auto jongkok saat Abyssal S1." })

local SkillCard = SurvivorPage:CreateSection("Auto SkillCheck")
SkillCard:AddToggle("Auto Skill Check", false, function(state) Auto.SkillCheck = state; if state then startSkillCheck() end end, { Title = "Auto Skill Check", Description = "Auto selesaikan skill check." })
SkillCard:AddDropdown("Skill Check Mode", {"Legit", "Instant"}, false, function(mode) Auto.SkillCheckMode = mode end, { Title = "Skill Check Mode", Description = "Legit atau Instant." })

local PalletCard = SurvivorPage:CreateSection("Auto Drop Pallet")
PalletCard:AddToggle("Auto Drop Pallet", false, function(state) Auto.PalletDrop = state end, { Title = "Auto Drop Pallet", Description = "Auto drop pallet saat killer dekat." })
PalletCard:AddSlider("Pallet Distance", 5, 50, 6, function(val) Auto.PalletDropDist = val end, { Title = "Pallet Trigger Distance", Description = "Jarak trigger pallet." })

local GenCard = SurvivorPage:CreateSection("Gen Boost Bypass")
GenCard:AddToggle("Gen Boost Bypass", false, function(state)
	setGenBypass(state)
	if state then Library:Notify({ Title = "Gen Boost Bypass", Description = isMobile and "Klik tombol GEN!" or "Tekan G!", Duration = 3 }) end
end, { Title = "Gen Boost Bypass", Description = "Bypass generator repair." })
GenCard:AddButton("Refresh Generator Cache", function()
	GenBypass.Cache = {}; GenBypass.CacheTimer = 0
	local gens = GB_GetAllGenerators()
	Library:Notify({ Title = "Refresh Cache", Description = "Ditemukan " .. #gens .. " generator.", Duration = 2 })
end, { Title = "Refresh Generator Cache", Description = "Force rescan generator." })
