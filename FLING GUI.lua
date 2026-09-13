--[[ 
    FLING GUI PLAYER - PREMIUM EDITION
    Theme: Red / Black / Gray
    Features:
    - Premium modern GUI with minimize
    - Multi-target selection
    - Continuous flinging
    - Smooth animations & hover effects
    - Clean & tidy layout
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer

-- Color Palette
local Colors = {
    Background   = Color3.fromRGB(15, 15, 17),
    Panel        = Color3.fromRGB(22, 22, 26),
    PanelLight   = Color3.fromRGB(32, 32, 38),
    PanelHover   = Color3.fromRGB(42, 42, 50),
    Accent       = Color3.fromRGB(225, 35, 50),
    AccentDark   = Color3.fromRGB(140, 15, 25),
    AccentGlow   = Color3.fromRGB(255, 70, 85),
    TextPrimary  = Color3.fromRGB(240, 240, 245),
    TextMuted    = Color3.fromRGB(140, 140, 150),
    Success      = Color3.fromRGB(40, 200, 90),
    SuccessDark  = Color3.fromRGB(25, 130, 55),
    Danger       = Color3.fromRGB(200, 40, 50),
    DangerDark   = Color3.fromRGB(130, 20, 30),
    Border       = Color3.fromRGB(45, 45, 52),
    Inactive     = Color3.fromRGB(60, 60, 68),
}

-- ============ GUI ROOT ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlingGUIPlayer"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- ============ MAIN FRAME ============
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 480)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -240)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Colors.Accent
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.4
MainStroke.Parent = MainFrame

-- Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0, -20, 0, -20)
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.ZIndex = -1
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
Shadow.Parent = MainFrame

-- ============ TITLE BAR ============
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 46)
TitleBar.BackgroundColor3 = Colors.Panel
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 14)
TitleBarCorner.Parent = TitleBar

local TitleBarMask = Instance.new("Frame")
TitleBarMask.Size = UDim2.new(1, 0, 0, 14)
TitleBarMask.Position = UDim2.new(0, 0, 1, -14)
TitleBarMask.BackgroundColor3 = Colors.Panel
TitleBarMask.BorderSizePixel = 0
TitleBarMask.Parent = TitleBar

-- Gradient Accent Line
local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(1, 0, 0, 2)
AccentLine.Position = UDim2.new(0, 0, 1, -2)
AccentLine.BackgroundColor3 = Colors.Accent
AccentLine.BorderSizePixel = 0
AccentLine.ZIndex = 3
AccentLine.Parent = TitleBar

local AccentGradient = Instance.new("UIGradient")
AccentGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Colors.AccentDark),
    ColorSequenceKeypoint.new(0.5, Colors.AccentGlow),
    ColorSequenceKeypoint.new(1, Colors.AccentDark),
})
AccentGradient.Parent = AccentLine

-- Logo
local LogoIcon = Instance.new("Frame")
LogoIcon.Size = UDim2.new(0, 26, 0, 26)
LogoIcon.Position = UDim2.new(0, 14, 0.5, -13)
LogoIcon.BackgroundColor3 = Colors.Accent
LogoIcon.BorderSizePixel = 0
LogoIcon.Parent = TitleBar

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(0, 7)
LogoCorner.Parent = LogoIcon

local LogoGradient = Instance.new("UIGradient")
LogoGradient.Rotation = 45
LogoGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Colors.AccentGlow),
    ColorSequenceKeypoint.new(1, Colors.AccentDark),
})
LogoGradient.Parent = LogoIcon

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "F"
LogoText.TextColor3 = Colors.TextPrimary
LogoText.Font = Enum.Font.GothamBlack
LogoText.TextSize = 16
LogoText.Parent = LogoIcon

-- Title Text
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Position = UDim2.new(0, 48, 0, 6)
Title.Size = UDim2.new(1, -140, 0, 18)
Title.BackgroundTransparency = 1
Title.Text = "FLING GUI PLAYER"
Title.TextColor3 = Colors.TextPrimary
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Position = UDim2.new(0, 48, 0, 22)
SubTitle.Size = UDim2.new(1, -140, 0, 14)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "PREMIUM EDITION"
SubTitle.TextColor3 = Colors.Accent
SubTitle.Font = Enum.Font.GothamMedium
SubTitle.TextSize = 9
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = TitleBar

-- Control Buttons
local function createControlButton(text, xOffset, hoverColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 28, 0, 28)
    btn.Position = UDim2.new(1, xOffset, 0.5, -14)
    btn.BackgroundColor3 = Colors.PanelLight
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Colors.TextMuted
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.Parent = TitleBar

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = hoverColor,
            TextColor3 = Colors.TextPrimary,
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Colors.PanelLight,
            TextColor3 = Colors.TextMuted,
        }):Play()
    end)
    return btn
end

local CloseButton = createControlButton("✕", -38, Colors.Danger)
local MinimizeButton = createControlButton("—", -70, Colors.Inactive)

-- ============ CONTENT CONTAINER ============
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "Content"
ContentFrame.Position = UDim2.new(0, 0, 0, 46)
ContentFrame.Size = UDim2.new(1, 0, 1, -46)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- ============ STATUS BAR ============
local StatusFrame = Instance.new("Frame")
StatusFrame.Position = UDim2.new(0, 14, 0, 12)
StatusFrame.Size = UDim2.new(1, -28, 0, 38)
StatusFrame.BackgroundColor3 = Colors.Panel
StatusFrame.BorderSizePixel = 0
StatusFrame.Parent = ContentFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 9)
StatusCorner.Parent = StatusFrame

local StatusStroke = Instance.new("UIStroke")
StatusStroke.Color = Colors.Border
StatusStroke.Thickness = 1
StatusStroke.Parent = StatusFrame

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 9, 0, 9)
StatusDot.Position = UDim2.new(0, 14, 0.5, -4.5)
StatusDot.BackgroundColor3 = Colors.TextMuted
StatusDot.BorderSizePixel = 0
StatusDot.Parent = StatusFrame

local StatusDotCorner = Instance.new("UICorner")
StatusDotCorner.CornerRadius = UDim.new(1, 0)
StatusDotCorner.Parent = StatusDot

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Position = UDim2.new(0, 32, 0, 0)
StatusLabel.Size = UDim2.new(1, -40, 1, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Select targets to fling"
StatusLabel.TextColor3 = Colors.TextPrimary
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 13
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusFrame

-- ============ SELECTION PANEL ============
local SelectionFrame = Instance.new("Frame")
SelectionFrame.Position = UDim2.new(0, 14, 0, 60)
SelectionFrame.Size = UDim2.new(1, -28, 0, 250)
SelectionFrame.BackgroundColor3 = Colors.Panel
SelectionFrame.BorderSizePixel = 0
SelectionFrame.Parent = ContentFrame

local SelectionCorner = Instance.new("UICorner")
SelectionCorner.CornerRadius = UDim.new(0, 9)
SelectionCorner.Parent = SelectionFrame

local SelectionStroke = Instance.new("UIStroke")
SelectionStroke.Color = Colors.Border
SelectionStroke.Thickness = 1
SelectionStroke.Parent = SelectionFrame

-- Header
local SelHeader = Instance.new("Frame")
SelHeader.Size = UDim2.new(1, 0, 0, 28)
SelHeader.BackgroundColor3 = Colors.PanelLight
SelHeader.BorderSizePixel = 0
SelHeader.Parent = SelectionFrame

local SelHeaderCorner = Instance.new("UICorner")
SelHeaderCorner.CornerRadius = UDim.new(0, 9)
SelHeaderCorner.Parent = SelHeader

local SelHeaderMask = Instance.new("Frame")
SelHeaderMask.Size = UDim2.new(1, 0, 0, 10)
SelHeaderMask.Position = UDim2.new(0, 0, 1, -10)
SelHeaderMask.BackgroundColor3 = Colors.PanelLight
SelHeaderMask.BorderSizePixel = 0
SelHeaderMask.Parent = SelHeader

local SelHeaderText = Instance.new("TextLabel")
SelHeaderText.Position = UDim2.new(0, 14, 0, 0)
SelHeaderText.Size = UDim2.new(1, -28, 1, 0)
SelHeaderText.BackgroundTransparency = 1
SelHeaderText.Text = "PLAYER LIST"
SelHeaderText.TextColor3 = Colors.TextMuted
SelHeaderText.Font = Enum.Font.GothamBold
SelHeaderText.TextSize = 10
SelHeaderText.TextXAlignment = Enum.TextXAlignment.Left
SelHeaderText.Parent = SelHeader

local SelHeaderCount = Instance.new("TextLabel")
SelHeaderCount.Position = UDim2.new(1, -80, 0, 0)
SelHeaderCount.Size = UDim2.new(0, 66, 1, 0)
SelHeaderCount.BackgroundTransparency = 1
SelHeaderCount.Text = "0 online"
SelHeaderCount.TextColor3 = Colors.Accent
SelHeaderCount.Font = Enum.Font.GothamBold
SelHeaderCount.TextSize = 10
SelHeaderCount.TextXAlignment = Enum.TextXAlignment.Right
SelHeaderCount.Parent = SelHeader

-- Scrolling frame
local PlayerScrollFrame = Instance.new("ScrollingFrame")
PlayerScrollFrame.Position = UDim2.new(0, 8, 0, 34)
PlayerScrollFrame.Size = UDim2.new(1, -16, 1, -42)
PlayerScrollFrame.BackgroundTransparency = 1
PlayerScrollFrame.BorderSizePixel = 0
PlayerScrollFrame.ScrollBarThickness = 4
PlayerScrollFrame.ScrollBarImageColor3 = Colors.Accent
PlayerScrollFrame.ScrollBarImageTransparency = 0.3
PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScrollFrame.Parent = SelectionFrame

local PlayerListLayout = Instance.new("UIListLayout")
PlayerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
PlayerListLayout.Padding = UDim.new(0, 4)
PlayerListLayout.Parent = PlayerScrollFrame

-- ============ ACTION BUTTONS ============
local function createActionButton(text, pos, size, baseColor, hoverColor, textColor)
    local btn = Instance.new("TextButton")
    btn.Position = pos
    btn.Size = size
    btn.BackgroundColor3 = baseColor
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = textColor or Colors.TextPrimary
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.Parent = ContentFrame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 9)
    c.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = hoverColor
    stroke.Thickness = 0
    stroke.Transparency = 0.4
    stroke.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = hoverColor }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.15), { Thickness = 1.5 }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = baseColor }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.15), { Thickness = 0 }):Play()
    end)
    return btn
end

local StartButton = createActionButton(
    "▶  START FLING",
    UDim2.new(0, 14, 0, 320),
    UDim2.new(0.5, -19, 0, 44),
    Colors.SuccessDark, Colors.Success
)

local StopButton = createActionButton(
    "■  STOP FLING",
    UDim2.new(0.5, 5, 0, 320),
    UDim2.new(0.5, -19, 0, 44),
    Colors.DangerDark, Colors.Danger
)

-- Select/Deselect All
local SelectAllButton = createActionButton(
    "SELECT ALL",
    UDim2.new(0, 14, 0, 374),
    UDim2.new(0.5, -19, 0, 34),
    Colors.PanelLight, Colors.PanelHover,
    Colors.TextMuted
)
SelectAllButton.TextSize = 11

local DeselectAllButton = createActionButton(
    "DESELECT ALL",
    UDim2.new(0.5, 5, 0, 374),
    UDim2.new(0.5, -19, 0, 34),
    Colors.PanelLight, Colors.PanelHover,
    Colors.TextMuted
)
DeselectAllButton.TextSize = 11

-- Footer
local Footer = Instance.new("TextLabel")
Footer.Position = UDim2.new(0, 0, 1, -24)
Footer.Size = UDim2.new(1, 0, 0, 18)
Footer.BackgroundTransparency = 1
Footer.Text = "made by KILASIK • based on zqyDSUWX"
Footer.TextColor3 = Colors.TextMuted
Footer.Font = Enum.Font.GothamMedium
Footer.TextSize = 9
Footer.Parent = ContentFrame

-- ============ VARIABLES ============
local SelectedTargets = {}
local PlayerCheckboxes = {}
local FlingActive = false
local Minimized = false
getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight

-- ============ PLAYER LIST ============
local function RefreshPlayerList()
    for _, child in pairs(PlayerScrollFrame:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then
            child:Destroy()
        end
    end
    PlayerCheckboxes = {}

    local PlayerList = Players:GetPlayers()
    table.sort(PlayerList, function(a, b) return a.Name:lower() < b.Name:lower() end)

    local order = 0
    local onlineCount = 0
    for _, player in ipairs(PlayerList) do
        if player ~= Player then
            onlineCount = onlineCount + 1
            order = order + 1

            local PlayerEntry = Instance.new("TextButton")
            PlayerEntry.Name = player.Name
            PlayerEntry.Size = UDim2.new(1, -4, 0, 34)
            PlayerEntry.BackgroundColor3 = Colors.PanelLight
            PlayerEntry.BorderSizePixel = 0
            PlayerEntry.Text = ""
            PlayerEntry.AutoButtonColor = false
            PlayerEntry.LayoutOrder = order
            PlayerEntry.Parent = PlayerScrollFrame

            local EntryCorner = Instance.new("UICorner")
            EntryCorner.CornerRadius = UDim.new(0, 7)
            EntryCorner.Parent = PlayerEntry

            -- Checkbox
            local Checkbox = Instance.new("Frame")
            Checkbox.Size = UDim2.new(0, 20, 0, 20)
            Checkbox.Position = UDim2.new(0, 10, 0.5, -10)
            Checkbox.BackgroundColor3 = Colors.Background
            Checkbox.BorderSizePixel = 0
            Checkbox.Parent = PlayerEntry

            local CheckCorner = Instance.new("UICorner")
            CheckCorner.CornerRadius = UDim.new(0, 5)
            CheckCorner.Parent = Checkbox

            local CheckStroke = Instance.new("UIStroke")
            CheckStroke.Color = Colors.Border
            CheckStroke.Thickness = 1.5
            CheckStroke.Parent = Checkbox

            local Checkmark = Instance.new("TextLabel")
            Checkmark.Size = UDim2.new(1, 0, 1, 0)
            Checkmark.BackgroundTransparency = 1
            Checkmark.Text = "✓"
            Checkmark.TextColor3 = Colors.Accent
            Checkmark.TextSize = 14
            Checkmark.Font = Enum.Font.GothamBold
            Checkmark.Visible = SelectedTargets[player.Name] ~= nil
            Checkmark.Parent = Checkbox

            -- Name
            local NameLabel = Instance.new("TextLabel")
            NameLabel.Size = UDim2.new(1, -50, 1, 0)
            NameLabel.Position = UDim2.new(0, 40, 0, 0)
            NameLabel.BackgroundTransparency = 1
            NameLabel.Text = player.Name
            NameLabel.TextColor3 = Colors.TextPrimary
            NameLabel.TextSize = 13
            NameLabel.Font = Enum.Font.GothamMedium
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
            NameLabel.Parent = PlayerEntry

            -- Hover
            PlayerEntry.MouseEnter:Connect(function()
                TweenService:Create(PlayerEntry, TweenInfo.new(0.15), {
                    BackgroundColor3 = Colors.PanelHover
                }):Play()
            end)
            PlayerEntry.MouseLeave:Connect(function()
                TweenService:Create(PlayerEntry, TweenInfo.new(0.15), {
                    BackgroundColor3 = Colors.PanelLight
                }):Play()
            end)

            -- Toggle
            PlayerEntry.MouseButton1Click:Connect(function()
                if SelectedTargets[player.Name] then
                    SelectedTargets[player.Name] = nil
                    Checkmark.Visible = false
                    TweenService:Create(CheckStroke, TweenInfo.new(0.15), {
                        Color = Colors.Border
                    }):Play()
                else
                    SelectedTargets[player.Name] = player
                    Checkmark.Visible = true
                    TweenService:Create(CheckStroke, TweenInfo.new(0.15), {
                        Color = Colors.Accent
                    }):Play()
                end
                UpdateStatus()
            end)

            if SelectedTargets[player.Name] then
                CheckStroke.Color = Colors.Accent
            end

            PlayerCheckboxes[player.Name] = {
                Entry = PlayerEntry,
                Checkmark = Checkmark,
                CheckStroke = CheckStroke,
            }
        end
    end

    SelHeaderCount.Text = onlineCount .. " online"
    PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, PlayerListLayout.AbsoluteContentSize.Y + 10)
end

-- ============ UTILITIES ============
local function CountSelectedTargets()
    local c = 0
    for _ in pairs(SelectedTargets) do c = c + 1 end
    return c
end

local function UpdateStatus()
    local count = CountSelectedTargets()
    if FlingActive then
        StatusLabel.Text = "Flinging " .. count .. " target(s)..."
        StatusLabel.TextColor3 = Colors.AccentGlow
        StatusDot.BackgroundColor3 = Colors.Accent
    else
        StatusLabel.Text = count .. " target(s) selected"
        StatusLabel.TextColor3 = Colors.TextPrimary
        StatusDot.BackgroundColor3 = (count > 0) and Colors.Success or Colors.TextMuted
    end
end

local function ToggleAllPlayers(select)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player then
            local data = PlayerCheckboxes[player.Name]
            if data then
                if select then
                    SelectedTargets[player.Name] = player
                    data.Checkmark.Visible = true
                    TweenService:Create(data.CheckStroke, TweenInfo.new(0.15), {
                        Color = Colors.Accent
                    }):Play()
                else
                    SelectedTargets[player.Name] = nil
                    data.Checkmark.Visible = false
                    TweenService:Create(data.CheckStroke, TweenInfo.new(0.15), {
                        Color = Colors.Border
                    }):Play()
                end
            end
        end
    end
    UpdateStatus()
end

local function Message(Title, Text, Time)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = Title,
            Text = Text,
            Duration = Time or 5
        })
    end)
end

-- ============ FLING LOGIC ============
local function SkidFling(TargetPlayer)
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    if not TCharacter then return end

    local THumanoid, TRootPart, THead, Accessory, Handle
    if TCharacter:FindFirstChildOfClass("Humanoid") then
        THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    end
    if THumanoid and THumanoid.RootPart then
        TRootPart = THumanoid.RootPart
    end
    if TCharacter:FindFirstChild("Head") then THead = TCharacter.Head end
    if TCharacter:FindFirstChildOfClass("Accessory") then
        Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    end
    if Accessory and Accessory:FindFirstChild("Handle") then
        Handle = Accessory.Handle
    end

    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then
            getgenv().OldPos = RootPart.CFrame
        end
        if THumanoid and THumanoid.Sit then
            return Message("Error", TargetPlayer.Name .. " is sitting", 2)
        end
        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif Handle then
            workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then
            workspace.CurrentCamera.CameraSubject = THumanoid
        end
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then return end

        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end

        local SFBasePart = function(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                end
            until Time + TimeToWait < tick() or not FlingActive

            workspace.FallenPartsDestroyHeight = 0/0
            local BV = Instance.new("BodyVelocity")
            BV.Parent = RootPart
            BV.Velocity = Vector3.new(0, 0, 0)
            BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

            if TRootPart then SFBasePart(TRootPart)
            elseif THead then SFBasePart(THead)
            elseif Handle then SFBasePart(Handle)
            else return Message("Error", TargetPlayer.Name .. " has no valid parts", 2) end

            BV:Destroy()
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            workspace.CurrentCamera.CameraSubject = Humanoid

            if getgenv().OldPos then
                repeat
                    RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                    Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                    Humanoid:ChangeState("GettingUp")
                    for _, part in pairs(Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new()
                        end
                    end
                    task.wait()
                until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
                workspace.FallenPartsDestroyHeight = getgenv().FPDH
            end
        end

        if TRootPart then SFBasePart(TRootPart)
        elseif THead then SFBasePart(THead)
        elseif Handle then SFBasePart(Handle)
        else return Message("Error", TargetPlayer.Name .. " has no valid parts", 2) end
    else
        return Message("Error", "Your character is not ready", 2)
    end
end

-- ============ FLING CONTROLS ============
local function StartFling()
    if FlingActive then return end
    local count = CountSelectedTargets()
    if count == 0 then
        StatusLabel.Text = "No targets selected!"
        StatusLabel.TextColor3 = Colors.Danger
        task.wait(1)
        UpdateStatus()
        return
    end
    FlingActive = true
    UpdateStatus()
    Message("Started", "Flinging " .. count .. " targets", 2)

    spawn(function()
        while FlingActive do
            local validTargets = {}
            for name, player in pairs(SelectedTargets) do
                if player and player.Parent then
                    validTargets[name] = player
                else
                    SelectedTargets[name] = nil
                    local cb = PlayerCheckboxes[name]
                    if cb then cb.Checkmark.Visible = false end
                end
            end
            for _, player in pairs(validTargets) do
                if FlingActive then
                    SkidFling(player)
                    task.wait(0.1)
                else
                    break
                end
            end
            UpdateStatus()
            task.wait(0.5)
        end
    end)
end

local function StopFling()
    if not FlingActive then return end
    FlingActive = false
    UpdateStatus()
    Message("Stopped", "Fling has been stopped", 2)
end

-- ============ MINIMIZE ============
local OriginalSize = MainFrame.Size

local function ToggleMinimize()
    Minimized = not Minimized
    if Minimized then
        ContentFrame.Visible = false
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 340, 0, 46)
        }):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = OriginalSize
        }):Play()
        task.wait(0.2)
        ContentFrame.Visible = true
    end
end

MinimizeButton.MouseButton1Click:Connect(ToggleMinimize)

-- ============ DRAGGING ============
local dragging, dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- ============ BUTTON CONNECTIONS ============
StartButton.MouseButton1Click:Connect(StartFling)
StopButton.MouseButton1Click:Connect(StopFling)
SelectAllButton.MouseButton1Click:Connect(function() ToggleAllPlayers(true) end)
DeselectAllButton.MouseButton1Click:Connect(function() ToggleAllPlayers(false) end)
CloseButton.MouseButton1Click:Connect(function()
    StopFling()
    ScreenGui:Destroy()
end)

-- ============ PLAYER EVENTS ============
Players.PlayerAdded:Connect(function() task.wait(0.5) RefreshPlayerList() end)
Players.PlayerRemoving:Connect(function(player)
    SelectedTargets[player.Name] = nil
    RefreshPlayerList()
    UpdateStatus()
end)

-- ============ INIT ============
RefreshPlayerList()
UpdateStatus()
Message("Loaded", "FLING GUI PLAYER loaded!", 3)
