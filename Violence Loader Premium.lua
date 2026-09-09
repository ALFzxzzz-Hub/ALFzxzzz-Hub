--// ALFzxzzz HUB • PREMIUM LOADER
--// USER ID WHITELIST VERSION

--==================================================
-- SERVICES
--==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

--==================================================
-- USER ID WHITELIST
--==================================================

local AllowedUserIds = {

    -- Masukkan UserId yang boleh melihat GUI
    [9512602743] = true,
    [8276632447] = true,
    [11595157054] = true,

    -- Contoh:
    -- [987654321] = true,

}

--==================================================
-- USER ID CHECK
--==================================================

if not AllowedUserIds[Player.UserId] then
    return
end

--==================================================
-- CONFIG
--==================================================

-- Logo utama HUB
local LOGO_IMAGE = "rbxassetid://92826170205694"

-- Icon khusus Violence District
local VIOLENCE_DISTRICT_ICON =
    "rbxassetid://96884965458374"

--==================================================
-- SCRIPT LIST
--==================================================

local Scripts = {

    {
        Title = "Violence District",

        Description = "Premium Version Script",

        Icon = VIOLENCE_DISTRICT_ICON,

        Load = function()

            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/ALFzxzzz-Hub/ALFzxzzz-Hub/refs/heads/main/ALFzxzzz%20Hub%20Premium.lua"
            ))()

        end
    }

}

--==================================================
-- COLORS
--==================================================

local WHITE = Color3.fromRGB(
    255,
    255,
    255
)

local TEXT = Color3.fromRGB(
    235,
    235,
    235
)

local SUBTEXT = Color3.fromRGB(
    155,
    155,
    160
)

local BACKGROUND = Color3.fromRGB(
    12,
    12,
    14
)

local WINDOW = Color3.fromRGB(
    20,
    20,
    23
)

local CARD = Color3.fromRGB(
    27,
    27,
    30
)

local CARD2 = Color3.fromRGB(
    32,
    32,
    35
)

local STROKE = Color3.fromRGB(
    128,
    128,
    128
)

--==================================================
-- GUI HELPERS
--==================================================

local function New(Class, Properties)

    local Object = Instance.new(Class)

    for Property, Value in pairs(Properties) do

        Object[Property] = Value

    end

    return Object

end

local function Corner(Object, Radius)

    New("UICorner", {

        Parent = Object,

        CornerRadius = UDim.new(
            0,
            Radius
        )

    })

end

local function Stroke(
    Object,
    Color,
    Thickness,
    Transparency
)

    return New("UIStroke", {

        Parent = Object,

        Color = Color or STROKE,

        Thickness = Thickness or 1,

        Transparency = Transparency or 0

    })

end

local function Tween(
    Object,
    Time,
    Properties
)

    return TweenService:Create(

        Object,

        TweenInfo.new(

            Time,

            Enum.EasingStyle.Quint,

            Enum.EasingDirection.Out

        ),

        Properties

    ):Play()

end

--==================================================
-- REMOVE OLD GUI
--==================================================

pcall(function()

    local Old =
        Player.PlayerGui:FindFirstChild(
            "ALFzxzzzPremiumLoader"
        )

    if Old then
        Old:Destroy()
    end

end)

--==================================================
-- SCREEN GUI
--==================================================

local ScreenGui = New("ScreenGui", {

    Parent = Player.PlayerGui,

    Name = "ALFzxzzzPremiumLoader",

    ResetOnSpawn = false,

    IgnoreGuiInset = true,

    ZIndexBehavior =
        Enum.ZIndexBehavior.Sibling

})

--==================================================
-- LOADING SCREEN
--==================================================

local LoadingScreen = New("Frame", {

    Parent = ScreenGui,

    Size = UDim2.fromScale(
        1,
        1
    ),

    BackgroundColor3 =
        BACKGROUND,

    BorderSizePixel = 0

})

local LoadingLogo = New("ImageLabel", {

    Parent = LoadingScreen,

    Size = UDim2.fromOffset(
        72,
        72
    ),

    Position = UDim2.new(
        0.5,
        0,
        0.42,
        0
    ),

    AnchorPoint = Vector2.new(
        0.5,
        0.5
    ),

    BackgroundTransparency = 1,

    Image = LOGO_IMAGE,

    ScaleType =
        Enum.ScaleType.Fit

})

local LoadingTitle = New("TextLabel", {

    Parent = LoadingScreen,

    Size = UDim2.fromOffset(
        300,
        35
    ),

    Position = UDim2.new(
        0.5,
        0,
        0.52,
        0
    ),

    AnchorPoint = Vector2.new(
        0.5,
        0.5
    ),

    BackgroundTransparency = 1,

    Text = "ALFzxzzz HUB",

    Font = Enum.Font.GothamBold,

    TextSize = 21,

    TextColor3 = WHITE

})

local LoadingStatus = New("TextLabel", {

    Parent = LoadingScreen,

    Size = UDim2.fromOffset(
        300,
        25
    ),

    Position = UDim2.new(
        0.5,
        0,
        0.58,
        0
    ),

    AnchorPoint = Vector2.new(
        0.5,
        0.5
    ),

    BackgroundTransparency = 1,

    Text = "Initializing...",

    Font = Enum.Font.Gotham,

    TextSize = 12,

    TextColor3 = SUBTEXT

})

local LoadingBarBack = New("Frame", {

    Parent = LoadingScreen,

    Size = UDim2.fromOffset(
        220,
        4
    ),

    Position = UDim2.new(
        0.5,
        0,
        0.65,
        0
    ),

    AnchorPoint = Vector2.new(
        0.5,
        0.5
    ),

    BackgroundColor3 = CARD2,

    BorderSizePixel = 0

})

Corner(
    LoadingBarBack,
    4
)

local LoadingBar = New("Frame", {

    Parent = LoadingBarBack,

    Size = UDim2.new(
        0,
        0,
        1,
        0
    ),

    BackgroundColor3 = WHITE,

    BorderSizePixel = 0

})

Corner(
    LoadingBar,
    4
)

--==================================================
-- MAIN WINDOW
--==================================================

local Main = New("Frame", {

    Parent = ScreenGui,

    Size = UDim2.fromOffset(
        420,
        440
    ),

    Position = UDim2.new(
        0.5,
        0,
        0.5,
        0
    ),

    AnchorPoint = Vector2.new(
        0.5,
        0.5
    ),

    BackgroundColor3 =
        WINDOW,

    BorderSizePixel = 0,

    Visible = false

})

Corner(
    Main,
    14
)

Stroke(
    Main,
    Color3.fromRGB(
        55,
        55,
        60
    ),
    1,
    0
)

--==================================================
-- HEADER
--==================================================

local Header = New("Frame", {

    Parent = Main,

    Size = UDim2.new(
        1,
        0,
        0,
        74
    ),

    BackgroundTransparency = 1,

    BorderSizePixel = 0

})

local HeaderLogo = New("ImageLabel", {

    Parent = Header,

    Size = UDim2.fromOffset(
        44,
        44
    ),

    Position = UDim2.new(
        0,
        18,
        0.5,
        0
    ),

    AnchorPoint = Vector2.new(
        0,
        0.5
    ),

    BackgroundTransparency = 1,

    Image = LOGO_IMAGE,

    ScaleType =
        Enum.ScaleType.Fit

})

local HeaderTitle = New("TextLabel", {

    Parent = Header,

    Size = UDim2.fromOffset(
        250,
        24
    ),

    Position = UDim2.new(
        0,
        74,
        0,
        15
    ),

    BackgroundTransparency = 1,

    Text = "ALFzxzzz HUB",

    TextXAlignment =
        Enum.TextXAlignment.Left,

    Font = Enum.Font.GothamBold,

    TextSize = 17,

    TextColor3 = TEXT

})

local HeaderSubtitle = New("TextLabel", {

    Parent = Header,

    Size = UDim2.fromOffset(
        250,
        20
    ),

    Position = UDim2.new(
        0,
        74,
        0,
        38
    ),

    BackgroundTransparency = 1,

    Text = "Premium Script Loader",

    TextXAlignment =
        Enum.TextXAlignment.Left,

    Font = Enum.Font.Gotham,

    TextSize = 11,

    TextColor3 = SUBTEXT

})

local HeaderLine = New("Frame", {

    Parent = Header,

    Size = UDim2.new(
        1,
        -36,
        0,
        1
    ),

    Position = UDim2.new(
        0,
        18,
        1,
        -1
    ),

    BackgroundColor3 = STROKE,

    BorderSizePixel = 0

})

--==================================================
-- LOADER PAGE
--==================================================

local LoaderPage = New("Frame", {

    Parent = Main,

    Size = UDim2.new(
        1,
        0,
        1,
        -74
    ),

    Position = UDim2.new(
        0,
        0,
        0,
        74
    ),

    BackgroundTransparency = 1,

    Visible = true

})

--==================================================
-- ACCESS CARD
--==================================================

local AccessCard = New("Frame", {

    Parent = LoaderPage,

    Size = UDim2.new(
        1,
        -40,
        0,
        72
    ),

    Position = UDim2.new(
        0,
        20,
        0,
        16
    ),

    BackgroundColor3 = CARD,

    BorderSizePixel = 0

})

Corner(
    AccessCard,
    10
)

Stroke(
    AccessCard,
    STROKE,
    1,
    0
)

local AccessTitle = New("TextLabel", {

    Parent = AccessCard,

    Size = UDim2.new(
        1,
        -28,
        0,
        20
    ),

    Position = UDim2.new(
        0,
        14,
        0,
        11
    ),

    BackgroundTransparency = 1,

    Text = "ACCESS • PREMIUM",

    TextXAlignment =
        Enum.TextXAlignment.Left,

    Font = Enum.Font.GothamBold,

    TextSize = 10,

    TextColor3 = WHITE

})

local AccessDescription = New("TextLabel", {

    Parent = AccessCard,

    Size = UDim2.new(
        1,
        -28,
        0,
        20
    ),

    Position = UDim2.new(
        0,
        14,
        0,
        35
    ),

    BackgroundTransparency = 1,

    Text = "Premium scripts unlocked",

    TextXAlignment =
        Enum.TextXAlignment.Left,

    Font = Enum.Font.Gotham,

    TextSize = 10,

    TextColor3 = SUBTEXT

})

--==================================================
-- SCRIPT TITLE
--==================================================

local ScriptTitle = New("TextLabel", {

    Parent = LoaderPage,

    Size = UDim2.new(
        1,
        -40,
        0,
        25
    ),

    Position = UDim2.new(
        0,
        20,
        0,
        100
    ),

    BackgroundTransparency = 1,

    Text = "Available Scripts",

    TextXAlignment =
        Enum.TextXAlignment.Left,

    Font = Enum.Font.GothamBold,

    TextSize = 13,

    TextColor3 = TEXT

})

local ScriptCount = New("TextLabel", {

    Parent = LoaderPage,

    Size = UDim2.fromOffset(
        100,
        25
    ),

    Position = UDim2.new(
        1,
        -120,
        0,
        100
    ),

    BackgroundTransparency = 1,

    Text =
        tostring(#Scripts)
        .. " Script",

    TextXAlignment =
        Enum.TextXAlignment.Right,

    Font = Enum.Font.Gotham,

    TextSize = 10,

    TextColor3 = SUBTEXT

})

--==================================================
-- SCRIPT SCROLL
--==================================================

local ScriptScroll = New("ScrollingFrame", {

    Parent = LoaderPage,

    Size = UDim2.new(
        1,
        -40,
        0,
        260
    ),

    Position = UDim2.new(
        0,
        20,
        0,
        130
    ),

    BackgroundTransparency = 1,

    BorderSizePixel = 0,

    ScrollBarThickness = 2,

    ScrollBarImageColor3 =
        Color3.fromRGB(
            100,
            100,
            105
        ),

    CanvasSize = UDim2.new(
        0,
        0,
        0,
        0
    ),

    AutomaticCanvasSize =
        Enum.AutomaticSize.Y

})

local ScriptLayout = New("UIListLayout", {

    Parent = ScriptScroll,

    Padding = UDim.new(
        0,
        8
    ),

    SortOrder =
        Enum.SortOrder.LayoutOrder

})

local ScriptPadding = New("UIPadding", {

    Parent = ScriptScroll,

    PaddingBottom =
        UDim.new(
            0,
            4
        )

})

--==================================================
-- BUILD SCRIPT ITEMS
--==================================================

local function BuildScripts()

    for Index, Data in ipairs(Scripts) do

        local Item = New("Frame", {

            Parent = ScriptScroll,

            Size = UDim2.new(
                1,
                0,
                0,
                70
            ),

            BackgroundColor3 = CARD,

            BorderSizePixel = 0,

            LayoutOrder = Index

        })

        Corner(
            Item,
            10
        )

        Stroke(
            Item,
            Color3.fromRGB(
                52,
                52,
                57
            ),
            1,
            0
        )

        --==================================================
        -- SCRIPT ICON
        --==================================================

        local Icon = New("ImageLabel", {

            Parent = Item,

            Size = UDim2.fromOffset(
                40,
                40
            ),

            Position = UDim2.new(
                0,
                12,
                0.5,
                0
            ),

            AnchorPoint = Vector2.new(
                0,
                0.5
            ),

            BackgroundColor3 =
                WINDOW,

            BackgroundTransparency = 0,

            BorderSizePixel = 0,

            Image =
                Data.Icon
                or LOGO_IMAGE,

            ScaleType =
                Enum.ScaleType.Fit

        })

        Corner(
            Icon,
            8
        )

        --==================================================
        -- TITLE
        --==================================================

        local Title = New("TextLabel", {

            Parent = Item,

            Size = UDim2.new(
                1,
                -170,
                0,
                22
            ),

            Position = UDim2.new(
                0,
                64,
                0,
                13
            ),

            BackgroundTransparency = 1,

            Text = Data.Title,

            TextXAlignment =
                Enum.TextXAlignment.Left,

            Font = Enum.Font.GothamBold,

            TextSize = 11,

            TextColor3 = TEXT

        })

        --==================================================
        -- DESCRIPTION
        --==================================================

        local Description = New("TextLabel", {

            Parent = Item,

            Size = UDim2.new(
                1,
                -170,
                0,
                20
            ),

            Position = UDim2.new(
                0,
                64,
                0,
                36
            ),

            BackgroundTransparency = 1,

            Text = Data.Description,

            TextXAlignment =
                Enum.TextXAlignment.Left,

            Font = Enum.Font.Gotham,

            TextSize = 9,

            TextColor3 = SUBTEXT

        })

        --==================================================
        -- LOAD BUTTON
        --==================================================

        local LoadButton = New("TextButton", {

            Parent = Item,

            Size = UDim2.fromOffset(
                62,
                30
            ),

            Position = UDim2.new(
                1,
                -74,
                0.5,
                0
            ),

            AnchorPoint = Vector2.new(
                0,
                0.5
            ),

            BackgroundColor3 = WHITE,

            BackgroundTransparency = 0.92,

            BorderSizePixel = 0,

            Text = "LOAD",

            Font = Enum.Font.GothamBold,

            TextSize = 9,

            TextColor3 = WHITE,

            AutoButtonColor = false

        })

        Corner(
            LoadButton,
            8
        )

        local LoadStroke = New("UIStroke", {

            Parent = LoadButton,

            Color =
                Color3.fromRGB(
                    180,
                    180,
                    185
                ),

            Thickness = 1,

            Transparency = 0

        })

        --==================================================
        -- HOVER
        --==================================================

        LoadButton.MouseEnter:Connect(function()

            Tween(
                LoadButton,
                0.15,
                {
                    BackgroundTransparency = 0.82
                }
            )

            Tween(
                LoadStroke,
                0.15,
                {
                    Color =
                        Color3.fromRGB(
                            235,
                            235,
                            235
                        )
                }
            )

        end)

        LoadButton.MouseLeave:Connect(function()

            Tween(
                LoadButton,
                0.15,
                {
                    BackgroundTransparency = 0.92
                }
            )

            Tween(
                LoadStroke,
                0.15,
                {
                    Color =
                        Color3.fromRGB(
                            180,
                            180,
                            185
                        )
                }
            )

        end)

        --==================================================
        -- LOAD SCRIPT
        --==================================================

        LoadButton.MouseButton1Click:Connect(function()

            if LoadButton:GetAttribute(
                "Loading"
            ) then

                return

            end

            LoadButton:SetAttribute(
                "Loading",
                true
            )

            LoadButton.Text =
                "LOADING..."

            LoadButton.TextSize = 7

            local Success, ErrorMessage =
                pcall(function()

                    Data.Load()

                end)

            if Success then

                LoadButton.Text =
                    "LOADED"

                LoadButton.TextSize = 8

                task.wait(0.25)

                if ScreenGui then
                    ScreenGui:Destroy()
                end

            else

                LoadButton:SetAttribute(
                    "Loading",
                    false
                )

                LoadButton.Text =
                    "ERROR"

                LoadButton.TextSize = 8

                warn(
                    "[ALFzxzzz HUB] Failed to load "
                    .. Data.Title
                    .. ": "
                    .. tostring(
                        ErrorMessage
                    )
                )

                task.wait(1)

                LoadButton.Text = "LOAD"
                LoadButton.TextSize = 9

            end

        end)

    end

end

BuildScripts()

--==================================================
-- DRAG SYSTEM
--==================================================

local Dragging = false
local DragStart
local StartPosition

Header.InputBegan:Connect(function(Input)

    if Input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or Input.UserInputType ==
        Enum.UserInputType.Touch then

        Dragging = true

        DragStart =
            Input.Position

        StartPosition =
            Main.Position

    end

end)

Header.InputEnded:Connect(function(Input)

    if Input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or Input.UserInputType ==
        Enum.UserInputType.Touch then

        Dragging = false

    end

end)

UserInputService.InputChanged:Connect(function(Input)

    if not Dragging then
        return
    end

    if Input.UserInputType ~=
        Enum.UserInputType.MouseMovement
        and Input.UserInputType ~=
        Enum.UserInputType.Touch then

        return

    end

    local Delta =
        Input.Position - DragStart

    Main.Position = UDim2.new(

        StartPosition.X.Scale,

        StartPosition.X.Offset
            + Delta.X,

        StartPosition.Y.Scale,

        StartPosition.Y.Offset
            + Delta.Y

    )

end)

--==================================================
-- LOADING ANIMATION
--==================================================

task.spawn(function()

    local Steps = {

        {
            20,
            "Initializing..."
        },

        {
            40,
            "Checking User ID..."
        },

        {
            60,
            "Loading configuration..."
        },

        {
            80,
            "Preparing scripts..."
        },

        {
            100,
            "Ready!"
        }

    }

    for _, Step in ipairs(Steps) do

        Tween(

            LoadingBar,

            0.35,

            {

                Size = UDim2.new(

                    Step[1] / 100,

                    0,

                    1,

                    0

                )

            }

        )

        LoadingStatus.Text =
            Step[2]

        task.wait(0.35)

    end

    task.wait(0.25)

    LoadingScreen.Visible = false

    Main.Visible = true

end)
