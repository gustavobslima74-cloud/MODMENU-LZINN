--=============================================================
-- 🎯 KIKO MENU v5.11 — FONTE TOP + AMIGOS
--=============================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

if setfpscap then setfpscap(120) end

getgenv().Settings = {
    ESP = false, ESPNPC = false, TeamColor = false,
    Boxes = false, Names = false, Distance = false, Lines = false, Highlight = false,
    AimAssist = false, AimPart = "Head", AimFOV = 100, AimSmooth = 0.1,
    ShowFOV = false, WallCheck = false, TeamCheck = false, AimNPC = false,
    TargetPriority = false, PriorityMode = "Mais Próximo",
    AimPrediction = false, PredictionVelocity = 0.1, TriggerBot = false,
    UseSpeed = false, Speed = 16, InfiniteJump = false,
    FlyMode = false,
    ForceThirdPerson = false,
    SelectedPlayer = nil, AutoNearest = false, StickyBehind = false,
    StickySmoothness = 0.1, StickyDistance = 3,
    HitboxEnabled = false, Hitbox = 20, HitboxTransparency = 0.6, HitboxNPC = false,
    AutoTeamColorCheck = false, ColorAimbot = false, ColorAimbotTarget = nil,
    BoostFPS = false, RemoveShadows = false, Fullbright = false, NoFog = false,
    AntiAFK = false,
    Whitelist = {},
    SoundEnabled = true,
    Binds = {
        AimAssist   = {Mod = Enum.KeyCode.LeftAlt, Key = Enum.KeyCode.Two},
        Visuals     = {Mod = Enum.KeyCode.LeftAlt, Key = Enum.KeyCode.Three},
        Hitbox      = {Mod = Enum.KeyCode.LeftAlt, Key = Enum.KeyCode.Four},
    }
}

local S = getgenv().Settings
local VERSION = "v5.11"
local MenuAberto = false
local FOVCircle = Drawing.new("Circle")
local isHoldingTarget = false

if getgenv().nowe == nil then getgenv().nowe = false end
if getgenv().speeds == nil then getgenv().speeds = 1 end
if getgenv().tpwalking == nil then getgenv().tpwalking = false end

local flyUp = false
local flyDown = false

local originalLighting = {
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    FogColor = Lighting.FogColor,
}

local C = {
    Bg        = Color3.fromRGB(18, 18, 22),
    BgAlt     = Color3.fromRGB(26, 26, 32),
    BgHover   = Color3.fromRGB(38, 38, 46),
    Stroke    = Color3.fromRGB(50, 50, 60),
    Text      = Color3.fromRGB(240, 240, 245),
    Dim       = Color3.fromRGB(140, 140, 155),
    Accent    = Color3.fromRGB(120, 180, 255),
    Green     = Color3.fromRGB(120, 220, 160),
    Red       = Color3.fromRGB(240, 120, 120),
    Yellow    = Color3.fromRGB(240, 200, 120),
    Purple    = Color3.fromRGB(180, 140, 240),
    Friend    = Color3.fromRGB(0, 170, 255),
    Font      = Enum.Font.Gotham,
    FontB     = Enum.Font.GothamBold,
    FontTitle = Enum.Font.Michroma,    -- ⭐ fonte top SÓ nas sub-abas
}

local parentGui
pcall(function() parentGui = game:GetService("CoreGui") end)
if not parentGui then parentGui = LocalPlayer:WaitForChild("PlayerGui") end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KikoMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = parentGui

--=============================================================
-- ⭐ CACHE DE AMIGOS
--=============================================================
local FriendIds = {}
local FriendsLoaded = false
task.spawn(function()
    pcall(function()
        local cursor = ""
        for _ = 1, 15 do
            local url = "https://friends.roblox.com/v1/users/" .. tostring(LocalPlayer.UserId) .. "/friends?limit=200"
            if cursor ~= "" then url = url .. "&cursor=" .. cursor end
            local data = HttpService:JSONDecode(game:HttpGet(url))
            for _, f in ipairs(data.data or {}) do
                FriendIds[f.id] = true
            end
            cursor = data.nextPageCursor or ""
            if cursor == "" then break end
        end
        FriendsLoaded = true
    end)
end)

local function IsFriend(p)
    return p and FriendIds[p.UserId] == true
end

local function SortPlayers(list)
    table.sort(list, function(a, b)
        local af = IsFriend(a) and 1 or 0
        local bf = IsFriend(b) and 1 or 0
        if af ~= bf then return af > bf end
        return string.lower(a.DisplayName) < string.lower(b.DisplayName)
    end)
    return list
end

local function Corner(i, r)
    local c = Instance.new("UICorner", i)
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end
local function Stroke(i, col, t, tr)
    local s = Instance.new("UIStroke", i)
    s.Color = col or C.Stroke; s.Thickness = t or 1; s.Transparency = tr or 0
    return s
end

local Sounds = {}
local function mkSound(n, id, v)
    local s = Instance.new("Sound")
    s.Name = n; s.SoundId = "rbxassetid://" .. id; s.Volume = v or 0.3
    s.Parent = SoundService
    Sounds[n] = s
end
mkSound("Hover", "12221967", 0.10)
mkSound("Click", "12221972", 0.20)
mkSound("Toggle", "12221975", 0.25)
mkSound("Open", "12221973", 0.30)
mkSound("Close", "12221971", 0.25)
mkSound("Section", "12221974", 0.25)

local function PS(n)
    if not S.SoundEnabled then return end
    local s = Sounds[n]; if s then pcall(function() s:Play() end) end
end

local function GetTeamColor(p)
    if not p or not p.Character then return Color3.new(1,1,1) end
    local ch = p.Character
    local h = ch:FindFirstChild("Head")
    if h then
        for _, v in pairs(h:GetDescendants()) do
            if v:IsA("TextLabel") and v.Text ~= "" then return v.TextColor3 end
        end
    end
    for _, v in pairs(ch:GetDescendants()) do
        if v:IsA("TextLabel") and (string.find(string.lower(v.Text), string.lower(p.Name))
        or string.find(string.lower(v.Text), string.lower(p.DisplayName))) then
            return v.TextColor3
        end
    end
    local bc = ch:FindFirstChildOfClass("BodyColors")
    if bc then return bc.TorsoColor3 end
    if p.Team then return p.Team.TeamColor.Color end
    if p.TeamColor then return p.TeamColor.Color end
    return Color3.new(1,1,1)
end

local NF = Instance.new("Frame", ScreenGui)
NF.Size = UDim2.new(0, 220, 0, 100)
NF.Position = UDim2.new(0.5, -110, 0.05, 0)
NF.BackgroundTransparency = 1; NF.ZIndex = 500
local NFL = Instance.new("UIListLayout", NF)
NFL.SortOrder = Enum.SortOrder.LayoutOrder
NFL.Padding = UDim.new(0, 5)
NFL.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function Notify(txt, ok)
    local col = ok and C.Green or C.Red
    local n = Instance.new("TextLabel", NF)
    n.Size = UDim2.new(1, 0, 0, 26)
    n.BackgroundColor3 = C.BgAlt
    n.TextColor3 = col; n.Text = txt
    n.Font = C.FontB; n.TextSize = 11
    n.BackgroundTransparency = 0.2; n.ZIndex = 501
    Corner(n, 6)
    local st = Stroke(n, col, 1, 0)
    task.delay(1.8, function()
        local t1 = TweenService:Create(n, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1})
        local t2 = TweenService:Create(st, TweenInfo.new(0.3), {Transparency = 1})
        t1:Play(); t2:Play()
        t1.Completed:Connect(function() n:Destroy() end)
    end)
end

local function MakeDraggable(g, onClickNoDrag, blockWhenOpen, moveTarget)
    moveTarget = moveTarget or g
    local drag, dIn, dS, sP, moved
    g.InputBegan:Connect(function(input)
        if blockWhenOpen and MenuAberto then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            drag = true; moved = false
            dIn = nil
            dS = input.Position; sP = moveTarget.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    drag = false
                    if not moved and onClickNoDrag then onClickNoDrag() end
                end
            end)
        end
    end)
    g.InputChanged:Connect(function(input)
        if blockWhenOpen and MenuAberto then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then dIn = input end
    end)
    RunService.RenderStepped:Connect(function()
        if drag and dIn then
            local d = dIn.Position - dS
            if math.abs(d.X) > 5 or math.abs(d.Y) > 5 then moved = true end
            moveTarget.Position = UDim2.new(
                sP.X.Scale, sP.X.Offset + d.X,
                sP.Y.Scale, sP.Y.Offset + d.Y)
        end
    end)
end

-- BOTÃO FLUTUANTE
local Float = Instance.new("Frame")
Float.Name = "KikoFloat"
Float.Size = UDim2.new(0, 46, 0, 46)
Float.Position = UDim2.new(1, -70, 0, 80)
Float.BackgroundColor3 = C.Bg
Float.ZIndex = 50
Float.Parent = ScreenGui
Corner(Float, 23)
local FloatStroke = Stroke(Float, C.Accent, 2, 0.2)

local FloatIcon = Instance.new("ImageLabel", Float)
FloatIcon.Size = UDim2.new(1, 0, 1, 0)
FloatIcon.BackgroundTransparency = 1
FloatIcon.Image = "rbxassetid://70505361093133"
FloatIcon.ScaleType = Enum.ScaleType.Crop
FloatIcon.ZIndex = 52
local iconCorner = Instance.new("UICorner", FloatIcon)
iconCorner.CornerRadius = UDim.new(1, 0)

local FloatBtn = Instance.new("TextButton", Float)
FloatBtn.Size = UDim2.new(1, 0, 1, 0)
FloatBtn.BackgroundTransparency = 1
FloatBtn.Text = ""
FloatBtn.ZIndex = 51
FloatBtn.AutoButtonColor = false

-- MAIN
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 340, 0, 440)
Main.Position = UDim2.new(0.5, -170, 0.5, -220)
Main.BackgroundColor3 = C.Bg
Main.Visible = false; Main.ClipsDescendants = true
Main.ZIndex = 100; Main.Parent = ScreenGui
Corner(Main, 12)
Stroke(Main, C.Stroke, 1, 0.2)

-- HEADER
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = C.BgAlt
Header.ZIndex = 101; Header.BorderSizePixel = 0
Corner(Header, 12)

local Logo = Instance.new("TextLabel", Header)
Logo.Size = UDim2.new(1, -170, 1, 0)
Logo.Position = UDim2.new(0, 16, 0, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "🎯  KIKO MENU"; Logo.TextColor3 = C.Text
Logo.TextSize = 15; Logo.Font = C.FontB
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.ZIndex = 102
Logo.Active = true

local FPSLbl = Instance.new("TextLabel", Header)
FPSLbl.Size = UDim2.new(0, 45, 1, 0)
FPSLbl.Position = UDim2.new(1, -140, 0, 0)
FPSLbl.BackgroundTransparency = 1
FPSLbl.Text = "FPS: 0"; FPSLbl.TextColor3 = C.Green
FPSLbl.TextSize = 10; FPSLbl.Font = C.Font
FPSLbl.TextXAlignment = Enum.TextXAlignment.Right
FPSLbl.ZIndex = 102

local SearchIcon = Instance.new("TextButton", Header)
SearchIcon.Size = UDim2.new(0, 28, 0, 28)
SearchIcon.Position = UDim2.new(1, -72, 0, 7)
SearchIcon.BackgroundColor3 = C.BgHover
SearchIcon.Text = "🔍"; SearchIcon.TextColor3 = C.Text
SearchIcon.TextSize = 14; SearchIcon.Font = Enum.Font.GothamBold
SearchIcon.AutoButtonColor = false; SearchIcon.ZIndex = 105
Corner(SearchIcon, 6)

local CloseB = Instance.new("TextButton", Header)
CloseB.Size = UDim2.new(0, 28, 0, 28)
CloseB.Position = UDim2.new(1, -38, 0, 7)
CloseB.BackgroundColor3 = C.BgHover
CloseB.Text = "X"; CloseB.TextColor3 = C.Text
CloseB.TextSize = 16; CloseB.Font = Enum.Font.GothamBold
CloseB.AutoButtonColor = false; CloseB.ZIndex = 105
Corner(CloseB, 6)

CloseB.MouseEnter:Connect(function() TweenService:Create(CloseB, TweenInfo.new(0.12), {BackgroundColor3 = C.Red, TextColor3 = Color3.new(1,1,1)}):Play() end)
CloseB.MouseLeave:Connect(function() TweenService:Create(CloseB, TweenInfo.new(0.12), {BackgroundColor3 = C.BgHover, TextColor3 = C.Text}):Play() end)

MakeDraggable(Logo, nil, false, Main)

-- SEARCH BOX
local SearchBox = Instance.new("TextBox", Main)
SearchBox.Size = UDim2.new(1, -24, 0, 38)
SearchBox.Position = UDim2.new(0, 12, 0, 50)
SearchBox.BackgroundColor3 = C.BgAlt
SearchBox.TextColor3 = C.Text
SearchBox.PlaceholderText = "🔍  Buscar função pelo nome..."
SearchBox.PlaceholderColor3 = C.Dim
SearchBox.Font = C.Font
SearchBox.TextSize = 12
SearchBox.Text = ""
SearchBox.ClearTextOnFocus = false
SearchBox.Visible = false
SearchBox.ZIndex = 110
Corner(SearchBox, 10)
Stroke(SearchBox, C.Accent, 1.5, 0)

-- TABS
local TabsBar = Instance.new("Frame", Main)
TabsBar.Size = UDim2.new(1, -24, 0, 38)
TabsBar.Position = UDim2.new(0, 12, 0, 50)
TabsBar.BackgroundColor3 = C.BgAlt
TabsBar.ZIndex = 101
Corner(TabsBar, 10)

local TabsScroll = Instance.new("ScrollingFrame", TabsBar)
TabsScroll.Size = UDim2.new(1, 0, 1, 0)
TabsScroll.BackgroundTransparency = 1
TabsScroll.ScrollBarThickness = 0
TabsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TabsScroll.ScrollingDirection = Enum.ScrollingDirection.X
TabsScroll.ZIndex = 102

local TabsLayout = Instance.new("UIListLayout", TabsScroll)
TabsLayout.FillDirection = Enum.FillDirection.Horizontal
TabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabsLayout.Padding = UDim.new(0, 4)
local padT = Instance.new("UIPadding", TabsScroll)
padT.PaddingLeft = UDim.new(0, 6); padT.PaddingRight = UDim.new(0, 6)

TabsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabsScroll.CanvasSize = UDim2.new(0, TabsLayout.AbsoluteContentSize.X + 20, 0, 0)
end)

-- CONTENT
local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -24, 1, -108)
Content.Position = UDim2.new(0, 12, 0, 96)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = C.Stroke
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.ScrollingDirection = Enum.ScrollingDirection.Y
Content.ZIndex = 101

local ContentLayout = Instance.new("UIListLayout", Content)
ContentLayout.Padding = UDim.new(0, 6)

-- PÁGINAS
local Pages, TabButtons = {}, {}
local ActivePage = nil

local function CreatePage(name, emoji)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 88, 1, -8)
    btn.BackgroundColor3 = C.Bg
    btn.Text = emoji .. "  " .. name
    btn.TextColor3 = C.Dim
    btn.TextSize = 11; btn.Font = C.FontB
    btn.AutoButtonColor = false; btn.ZIndex = 103
    btn.Parent = TabsScroll
    Corner(btn, 8)

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 0, 0)
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.BackgroundTransparency = 1
    page.Visible = false; page.ZIndex = 102
    page.Parent = Content
    local pl = Instance.new("UIListLayout", page)
    pl.Padding = UDim.new(0, 6)
    pl.SortOrder = Enum.SortOrder.LayoutOrder

    btn.MouseButton1Click:Connect(function()
        PS("Click")
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in pairs(TabButtons) do
            b.BackgroundColor3 = C.Bg; b.TextColor3 = C.Dim
        end
        page.Visible = true; ActivePage = page
        btn.BackgroundColor3 = C.BgHover; btn.TextColor3 = C.Accent
        Content.CanvasPosition = Vector2.new(0, 0)
        task.wait()
        Content.CanvasSize = UDim2.new(0, 0, 0, page.AbsoluteSize.Y + 20)
    end)
    btn.MouseEnter:Connect(function()
        PS("Hover")
        if ActivePage ~= page then btn.BackgroundColor3 = C.BgHover end
    end)
    btn.MouseLeave:Connect(function()
        if ActivePage ~= page then btn.BackgroundColor3 = C.Bg end
    end)

    table.insert(Pages, page); table.insert(TabButtons, btn)
    return page, btn
end

-- SEARCH INDEX
local SearchIndex = {}
local function RegSearch(element, text, parentToggle)
    table.insert(SearchIndex, {
        element = element,
        isConfig = parentToggle ~= nil,
        parentToggle = parentToggle,
        searchText = string.lower(text),
    })
end

--=============================================================
-- TÍTULO (não colapsável) — agora com FONTE TOP
--=============================================================
local function CreateTitle(parent, title, emoji)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 103
    frame.Parent = parent

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = (emoji and emoji .. "  " or "") .. title
    lbl.TextColor3 = C.Dim
    lbl.TextSize = 12
    lbl.Font = C.FontTitle          -- ⭐ FONTE TOP
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Bottom
    lbl.ZIndex = 104

    local line = Instance.new("Frame", frame)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -4)
    line.BackgroundColor3 = C.Stroke
    line.BackgroundTransparency = 0.4
    line.BorderSizePixel = 0
    line.ZIndex = 104

    return frame
end

--=============================================================
-- TOGGLE SIMPLES
--=============================================================
local VisToggles = {}
local VisSteppers = {}

local function CreateToggle(parent, text, default, callback)
    local state = default or false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = C.Bg
    btn.Text = ""; btn.AutoButtonColor = false
    btn.ZIndex = 103; btn.Parent = parent
    Corner(btn, 8)

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text; lbl.TextColor3 = C.Text
    lbl.TextSize = 11; lbl.Font = C.Font
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 104

    local pill = Instance.new("Frame", btn)
    pill.Size = UDim2.new(0, 34, 0, 18)
    pill.Position = UDim2.new(1, -46, 0.5, -9)
    pill.BackgroundColor3 = state and C.Green or C.BgHover
    pill.BorderSizePixel = 0; pill.ZIndex = 104
    Corner(pill, 10)

    local ball = Instance.new("Frame", pill)
    ball.Size = UDim2.new(0, 14, 0, 14)
    ball.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    ball.BackgroundColor3 = Color3.new(1,1,1)
    ball.BorderSizePixel = 0; ball.ZIndex = 105
    Corner(ball, 10)

    local function apply(v, noCb, noSound)
        state = v
        if not noSound then PS("Toggle") end
        pill.BackgroundColor3 = state and C.Green or C.BgHover
        ball.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        if not noCb and callback then callback(state) end
    end

    VisToggles[text] = apply
    btn.MouseButton1Click:Connect(function() apply(not state) end)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = C.BgHover end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = C.Bg end)

    RegSearch(btn, text)
    return btn, apply
end

--=============================================================
-- TOGGLE COM CONFIG
--=============================================================
local function CreateToggleWithConfig(parent, text, default, callback)
    local state = default or false

    local wrapper = Instance.new("Frame", parent)
    wrapper.Size = UDim2.new(1, 0, 0, 34)
    wrapper.AutomaticSize = Enum.AutomaticSize.Y
    wrapper.BackgroundTransparency = 1
    wrapper.ZIndex = 103

    local wrapperLayout = Instance.new("UIListLayout", wrapper)
    wrapperLayout.SortOrder = Enum.SortOrder.LayoutOrder
    wrapperLayout.Padding = UDim.new(0, 4)

    local btn = Instance.new("TextButton", wrapper)
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = C.Bg
    btn.Text = ""; btn.AutoButtonColor = false
    btn.ZIndex = 104
    btn.LayoutOrder = 1
    Corner(btn, 8)

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text; lbl.TextColor3 = C.Text
    lbl.TextSize = 11; lbl.Font = C.Font
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 105

    local arrow = Instance.new("TextLabel", btn)
    arrow.Size = UDim2.new(0, 14, 0, 14)
    arrow.Position = UDim2.new(1, -64, 0.5, -7)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▾"
    arrow.TextColor3 = C.Dim
    arrow.TextSize = 12
    arrow.Font = C.FontB
    arrow.ZIndex = 105

    local pill = Instance.new("Frame", btn)
    pill.Size = UDim2.new(0, 34, 0, 18)
    pill.Position = UDim2.new(1, -46, 0.5, -9)
    pill.BackgroundColor3 = state and C.Green or C.BgHover
    pill.BorderSizePixel = 0; pill.ZIndex = 105
    Corner(pill, 10)

    local ball = Instance.new("Frame", pill)
    ball.Size = UDim2.new(0, 14, 0, 14)
    ball.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    ball.BackgroundColor3 = Color3.new(1,1,1)
    ball.BorderSizePixel = 0; ball.ZIndex = 106
    Corner(ball, 10)

    local config = Instance.new("Frame", wrapper)
    config.Size = UDim2.new(1, 0, 0, 0)
    config.AutomaticSize = Enum.AutomaticSize.Y
    config.BackgroundColor3 = C.BgAlt
    config.BackgroundTransparency = 0.35
    config.Visible = state
    config.ZIndex = 103
    config.LayoutOrder = 2
    Corner(config, 8)
    Stroke(config, C.Stroke, 1, 0.6)

    local configLayout = Instance.new("UIListLayout", config)
    configLayout.Padding = UDim.new(0, 4)
    configLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local configPad = Instance.new("UIPadding", config)
    configPad.PaddingTop = UDim.new(0, 8)
    configPad.PaddingBottom = UDim.new(0, 8)
    configPad.PaddingLeft = UDim.new(0, 8)
    configPad.PaddingRight = UDim.new(0, 8)

    local function apply(v, noCb, noSound)
        state = v
        if not noSound then PS("Toggle") end
        pill.BackgroundColor3 = state and C.Green or C.BgHover
        ball.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        config.Visible = state
        arrow.TextColor3 = state and C.Accent or C.Dim
        if not noCb and callback then callback(state) end
    end

    VisToggles[text] = apply
    btn.MouseButton1Click:Connect(function() apply(not state) end)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = C.BgHover end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = C.Bg end)

    RegSearch(btn, text)
    wrapper:SetAttribute("ToggleName", text)

    return config, apply, wrapper, btn
end

--=============================================================
-- STEPPER
--=============================================================
local function CreateStepper(parent, text, min, max, default, step, callback)
    local val = default or min
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.BackgroundColor3 = C.Bg
    frame.ZIndex = 103; frame.Parent = parent
    Corner(frame, 8)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -110, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text; lbl.TextColor3 = C.Text
    lbl.TextSize = 11; lbl.Font = C.Font
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 104

    local vl = Instance.new("TextLabel", frame)
    vl.Size = UDim2.new(0, 44, 1, 0)
    vl.Position = UDim2.new(1, -104, 0, 0)
    vl.BackgroundTransparency = 1
    vl.Text = tostring(val); vl.TextColor3 = C.Accent
    vl.TextSize = 11; vl.Font = C.FontB
    vl.ZIndex = 104

    local minus = Instance.new("TextButton", frame)
    minus.Size = UDim2.new(0, 24, 0, 24)
    minus.Position = UDim2.new(1, -56, 0.5, -12)
    minus.BackgroundColor3 = C.BgHover
    minus.Text = "−"; minus.TextColor3 = C.Text; minus.TextSize = 14
    minus.Font = C.FontB; minus.AutoButtonColor = false
    minus.ZIndex = 104; Corner(minus, 6)

    local plus = Instance.new("TextButton", frame)
    plus.Size = UDim2.new(0, 24, 0, 24)
    plus.Position = UDim2.new(1, -28, 0.5, -12)
    plus.BackgroundColor3 = C.BgHover
    plus.Text = "+"; plus.TextColor3 = C.Text; plus.TextSize = 14
    plus.Font = C.FontB; plus.AutoButtonColor = false
    plus.ZIndex = 104; Corner(plus, 6)

    local function update(n, noCb)
        val = math.clamp(n, min, max)
        if val % 1 == 0 then vl.Text = tostring(math.floor(val))
        else vl.Text = string.format("%.2f", val) end
        if not noCb and callback then callback(val) end
    end

    VisSteppers[text] = update
    minus.MouseButton1Click:Connect(function() PS("Click"); update(val - step) end)
    plus.MouseButton1Click:Connect(function() PS("Click"); update(val + step) end)

    RegSearch(frame, text)
    return frame, update
end

--=============================================================
-- BUTTON
--=============================================================
local function CreateButton(parent, text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = color or C.Accent
    btn.Text = text; btn.TextColor3 = Color3.new(1,1,1); btn.TextSize = 11
    btn.Font = C.FontB; btn.AutoButtonColor = false
    btn.ZIndex = 103; btn.Parent = parent
    Corner(btn, 8)

    local orig = color or C.Accent
    btn.MouseButton1Click:Connect(function() PS("Click"); if callback then callback() end end)
    btn.MouseEnter:Connect(function()
        PS("Hover")
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = orig:Lerp(Color3.new(1,1,1), 0.15)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = orig}):Play()
    end)
    RegSearch(btn, text)
    return btn
end

--=============================================================
-- LABEL
--=============================================================
local function CreateLabel(parent, text, h)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(1, 0, 0, h or 20)
    l.BackgroundTransparency = 1
    l.Text = text; l.TextColor3 = C.Dim
    l.TextSize = 10; l.Font = C.Font
    l.TextWrapped = true; l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Top
    l.ZIndex = 104
    return l
end

--=============================================================
-- ABAS
--=============================================================
local MiraP    = CreatePage("Mira",       "🎯")
local WLP      = CreatePage("Whitelist",  "📝")
local VisualP  = CreatePage("Visual",     "👁️")
local PersoP   = CreatePage("Personagem", "🏃")
local TPP      = CreatePage("Teleporte",  "🌀")
local HitP     = CreatePage("Hitbox",     "📦")
local DefP     = CreatePage("Defusal",    "💣")
local PresetP  = CreatePage("Presets",    "⚙️")
local BindsP   = CreatePage("Atalhos",    "⌨️")
local ServP    = CreatePage("Servidor",   "🌐")
local MiscP    = CreatePage("Misc",       "🧰")

MiraP.Visible = true
ActivePage = MiraP
TabButtons[1].BackgroundColor3 = C.BgHover
TabButtons[1].TextColor3 = C.Accent

local aimbotBtn, espBtn, hitboxBtn

--=============================================================
-- 🎯 MIRA
--=============================================================
CreateTitle(MiraP, "Assistência de Mira", "🎯")
local cfgAim, aimApply, aimWrap, aimBtnT = CreateToggleWithConfig(MiraP, "Ativar Assistência", false, function(v) S.AimAssist = v end)
aimbotBtn = aimBtnT
CreateStepper(cfgAim, "Campo de Visão (FOV)", 10, 800, 100, 10, function(v) S.AimFOV = v end)
CreateStepper(cfgAim, "Suavidade", 0.01, 1, 0.1, 0.05, function(v) S.AimSmooth = v end)
CreateToggle(cfgAim, "Exibir FOV na Tela", false, function(v) S.ShowFOV = v end)

CreateTitle(MiraP, "Avançado", "🧠")
CreateToggle(MiraP, "Prioridade 360°", false, function(v) S.TargetPriority = v end)
local cfgPred = CreateToggleWithConfig(MiraP, "Predição de Movimento", false, function(v) S.AimPrediction = v end)
CreateStepper(cfgPred, "Força da Predição", 0.05, 1, 0.1, 0.05, function(v) S.PredictionVelocity = v end)
CreateToggle(MiraP, "Atirar Automaticamente", false, function(v) S.TriggerBot = v end)

local Modes = {"Mais Próximo", "Menor Vida", "Mirando em Mim"}
local ModeBtn = Instance.new("TextButton", MiraP)
ModeBtn.Size = UDim2.new(1, 0, 0, 34)
ModeBtn.BackgroundColor3 = C.Bg
ModeBtn.TextColor3 = C.Text
ModeBtn.Text = "Prioridade: " .. S.PriorityMode
ModeBtn.TextSize = 11; ModeBtn.Font = C.Font
ModeBtn.AutoButtonColor = false; ModeBtn.ZIndex = 103
Corner(ModeBtn, 8)
ModeBtn.MouseButton1Click:Connect(function()
    PS("Click")
    local i = table.find(Modes, S.PriorityMode) or 1
    i = i + 1; if i > #Modes then i = 1 end
    S.PriorityMode = Modes[i]
    ModeBtn.Text = "Prioridade: " .. S.PriorityMode
end)
RegSearch(ModeBtn, "Prioridade")

local PartBtn = Instance.new("TextButton", MiraP)
PartBtn.Size = UDim2.new(1, 0, 0, 34)
PartBtn.BackgroundColor3 = C.Bg
PartBtn.TextColor3 = C.Text
PartBtn.Text = "Parte Alvo: Cabeça"
PartBtn.TextSize = 11; PartBtn.Font = C.Font
PartBtn.AutoButtonColor = false; PartBtn.ZIndex = 103
Corner(PartBtn, 8)
PartBtn.MouseButton1Click:Connect(function()
    PS("Click")
    S.AimPart = (S.AimPart == "Head" and "HumanoidRootPart" or "Head")
    PartBtn.Text = "Parte Alvo: " .. (S.AimPart == "Head" and "Cabeça" or "Tronco")
end)
RegSearch(PartBtn, "Parte Alvo")

CreateTitle(MiraP, "Filtros de Alvo", "🛡️")
CreateToggle(MiraP, "Ignorar Aliados", false, function(v) S.TeamCheck = v end)
CreateToggle(MiraP, "Ignorar Atrás de Paredes", false, function(v) S.WallCheck = v end)
CreateToggle(MiraP, "Mira em NPCs", false, function(v) S.AimNPC = v end)

--=============================================================
-- 📝 WHITELIST
--=============================================================
local wlDesc = Instance.new("TextLabel", WLP)
wlDesc.Size = UDim2.new(1, 0, 0, 46)
wlDesc.BackgroundColor3 = C.BgAlt
wlDesc.BackgroundTransparency = 0.4
wlDesc.Text = "  ℹ️  Jogadores na whitelist NÃO serão afetados por Aimbot, Silent, Hitbox e Auto TP. Clique no card para adicionar/remover."
wlDesc.TextColor3 = C.Dim
wlDesc.TextSize = 10; wlDesc.Font = C.Font
wlDesc.TextWrapped = true
wlDesc.TextXAlignment = Enum.TextXAlignment.Left
wlDesc.TextYAlignment = Enum.TextYAlignment.Center
wlDesc.ZIndex = 103
Corner(wlDesc, 8)
Stroke(wlDesc, C.Stroke, 1, 0.5)

local wlCountLabel = Instance.new("TextLabel", WLP)
wlCountLabel.Size = UDim2.new(1, 0, 0, 22)
wlCountLabel.BackgroundTransparency = 1
wlCountLabel.Text = "✓ Salvos: 0 jogadores"
wlCountLabel.TextColor3 = C.Accent
wlCountLabel.TextSize = 11; wlCountLabel.Font = C.FontB
wlCountLabel.TextXAlignment = Enum.TextXAlignment.Left
wlCountLabel.ZIndex = 104

local wlActions = Instance.new("Frame", WLP)
wlActions.Size = UDim2.new(1, 0, 0, 30)
wlActions.BackgroundTransparency = 1
wlActions.ZIndex = 103

local wlRefreshBtn = Instance.new("TextButton", wlActions)
wlRefreshBtn.Size = UDim2.new(0.48, 0, 1, 0)
wlRefreshBtn.BackgroundColor3 = C.Accent
wlRefreshBtn.Text = "🔄 Atualizar Lista"
wlRefreshBtn.TextColor3 = Color3.new(1,1,1)
wlRefreshBtn.TextSize = 11; wlRefreshBtn.Font = C.FontB
wlRefreshBtn.AutoButtonColor = false; wlRefreshBtn.ZIndex = 104
Corner(wlRefreshBtn, 8)

local wlClearBtn = Instance.new("TextButton", wlActions)
wlClearBtn.Size = UDim2.new(0.48, 0, 1, 0)
wlClearBtn.Position = UDim2.new(0.52, 0, 0, 0)
wlClearBtn.BackgroundColor3 = C.Red
wlClearBtn.Text = "🗑 Limpar Todos"
wlClearBtn.TextColor3 = Color3.new(1,1,1)
wlClearBtn.TextSize = 11; wlClearBtn.Font = C.FontB
wlClearBtn.AutoButtonColor = false; wlClearBtn.ZIndex = 104
Corner(wlClearBtn, 8)

local wlScroll = Instance.new("ScrollingFrame", WLP)
wlScroll.Size = UDim2.new(1, 0, 0, 340)
wlScroll.BackgroundColor3 = C.Bg
wlScroll.BackgroundTransparency = 0.4
wlScroll.BorderSizePixel = 0
wlScroll.ScrollBarThickness = 3
wlScroll.ScrollBarImageColor3 = C.Accent
wlScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
wlScroll.ZIndex = 103
Corner(wlScroll, 10)
Stroke(wlScroll, C.Stroke, 1, 0.5)

local wlLayout = Instance.new("UIListLayout", wlScroll)
wlLayout.Padding = UDim.new(0, 6)
wlLayout.SortOrder = Enum.SortOrder.LayoutOrder
local wlPad = Instance.new("UIPadding", wlScroll)
wlPad.PaddingTop = UDim.new(0, 6); wlPad.PaddingBottom = UDim.new(0, 6)
wlPad.PaddingLeft = UDim.new(0, 6); wlPad.PaddingRight = UDim.new(0, 6)
wlLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    wlScroll.CanvasSize = UDim2.new(0, 0, 0, wlLayout.AbsoluteContentSize.Y + 14)
end)

local function UpdateWLCount()
    local count = 0
    for _, v in pairs(S.Whitelist) do
        if v then count = count + 1 end
    end
    wlCountLabel.Text = "✓ Salvos: " .. count .. " jogador" .. (count == 1 and "" or "es")
end

local function BuildWLUI()
    for _, v in pairs(wlScroll:GetChildren()) do
        if v:IsA("Frame") or v:IsA("TextButton") then v:Destroy() end
    end

    local sorted = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(sorted, p) end
    end
    SortPlayers(sorted)

    if #sorted == 0 then
        local empty = Instance.new("TextLabel", wlScroll)
        empty.Size = UDim2.new(1, 0, 0, 60)
        empty.BackgroundTransparency = 1
        empty.Text = "Nenhum jogador no servidor"
        empty.TextColor3 = C.Dim
        empty.TextSize = 11; empty.Font = C.Font
        empty.ZIndex = 104
        UpdateWLCount()
        return
    end

    for _, p in ipairs(sorted) do
        local isWL = S.Whitelist[p.UserId] and true or false
        local isFr = IsFriend(p)

        local card = Instance.new("TextButton", wlScroll)
        card.Size = UDim2.new(1, -4, 0, 56)
        card.BackgroundColor3 = isWL and Color3.fromRGB(0, 180, 90) or C.BgHover
        card.BackgroundTransparency = isWL and 0.15 or 0.3
        card.Text = ""; card.AutoButtonColor = false
        card.ZIndex = 104
        Corner(card, 10)
        Stroke(card, isWL and C.Green or (isFr and C.Friend or C.Stroke), 1.5, isWL and 0.2 or 0.5)

        local avatarFrame = Instance.new("Frame", card)
        avatarFrame.Size = UDim2.new(0, 42, 0, 42)
        avatarFrame.Position = UDim2.new(0, 7, 0.5, -21)
        avatarFrame.BackgroundColor3 = C.Bg
        avatarFrame.BackgroundTransparency = 0.2
        avatarFrame.ZIndex = 105
        Corner(avatarFrame, 21)
        Stroke(avatarFrame, isWL and C.Green or (isFr and C.Friend or C.Accent), 1.5, 0.3)

        local avatarImg = Instance.new("ImageLabel", avatarFrame)
        avatarImg.Size = UDim2.new(1, -4, 1, -4)
        avatarImg.Position = UDim2.new(0, 2, 0, 2)
        avatarImg.BackgroundTransparency = 1
        avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(p.UserId) .. "&w=150&h=150"
        avatarImg.ZIndex = 106
        Corner(avatarImg, 20)

        local dn = Instance.new("TextLabel", card)
        dn.Size = UDim2.new(1, -140, 0, 18)
        dn.Position = UDim2.new(0, 56, 0, 8)
        dn.BackgroundTransparency = 1
        dn.Text = p.DisplayName
        dn.TextColor3 = isWL and Color3.fromRGB(180, 255, 200) or (isFr and Color3.fromRGB(180, 220, 255) or C.Text)
        dn.TextSize = 12; dn.Font = C.FontB
        dn.TextXAlignment = Enum.TextXAlignment.Left
        dn.ZIndex = 105

        local un = Instance.new("TextLabel", card)
        un.Size = UDim2.new(1, -140, 0, 14)
        un.Position = UDim2.new(0, 56, 0, 28)
        un.BackgroundTransparency = 1
        un.Text = "@" .. p.Name
        un.TextColor3 = isWL and Color3.fromRGB(200, 255, 220) or C.Dim
        un.TextSize = 10; un.Font = C.Font
        un.TextXAlignment = Enum.TextXAlignment.Left
        un.ZIndex = 105

        if isFr then
            local frTag = Instance.new("TextLabel", card)
            frTag.Size = UDim2.new(0, 52, 0, 16)
            frTag.Position = UDim2.new(0, 56, 1, -20)
            frTag.BackgroundColor3 = C.Friend
            frTag.BackgroundTransparency = 0.05
            frTag.Text = "⭐ AMIGO"
            frTag.TextColor3 = Color3.new(1,1,1)
            frTag.TextSize = 8; frTag.Font = C.FontB
            frTag.ZIndex = 105
            Corner(frTag, 4)
        end

        local badge = Instance.new("TextLabel", card)
        badge.Size = UDim2.new(0, 62, 0, 20)
        badge.Position = UDim2.new(1, -70, 0.5, -10)
        badge.BackgroundColor3 = isWL and Color3.fromRGB(0, 220, 110) or C.BgAlt
        badge.BackgroundTransparency = isWL and 0 or 0.3
        badge.Text = isWL and "✓ SALVO" or "LIVRE"
        badge.TextColor3 = isWL and Color3.new(1,1,1) or C.Dim
        badge.TextSize = 9; badge.Font = C.FontB
        badge.ZIndex = 105
        Corner(badge, 6)

        card.MouseButton1Click:Connect(function()
            PS("Click")
            S.Whitelist[p.UserId] = not S.Whitelist[p.UserId]
            local state = S.Whitelist[p.UserId]
            TweenService:Create(card, TweenInfo.new(0.2), {
                BackgroundColor3 = state and Color3.fromRGB(0, 180, 90) or C.BgHover,
                BackgroundTransparency = state and 0.15 or 0.3
            }):Play()
            local cs = card:FindFirstChildOfClass("UIStroke")
            if cs then
                TweenService:Create(cs, TweenInfo.new(0.2), {
                    Color = state and C.Green or (isFr and C.Friend or C.Stroke),
                    Transparency = state and 0.2 or 0.5
                }):Play()
            end
            dn.TextColor3 = state and Color3.fromRGB(180, 255, 200) or (isFr and Color3.fromRGB(180, 220, 255) or C.Text)
            un.TextColor3 = state and Color3.fromRGB(200, 255, 220) or C.Dim
            badge.BackgroundColor3 = state and Color3.fromRGB(0, 220, 110) or C.BgAlt
            badge.BackgroundTransparency = state and 0 or 0.3
            badge.Text = state and "✓ SALVO" or "LIVRE"
            badge.TextColor3 = state and Color3.new(1,1,1) or C.Dim
            UpdateWLCount()
        end)
    end
    UpdateWLCount()
end

wlRefreshBtn.MouseButton1Click:Connect(function() PS("Click"); BuildWLUI() end)
wlClearBtn.MouseButton1Click:Connect(function() PS("Click"); S.Whitelist = {}; BuildWLUI(); Notify("Whitelist limpa!", true) end)
Players.PlayerAdded:Connect(function() task.wait(0.5); BuildWLUI() end)
Players.PlayerRemoving:Connect(function() task.wait(0.5); BuildWLUI() end)
task.defer(function() task.wait(1); BuildWLUI() end)
task.delay(4, function() BuildWLUI() end)
task.delay(8, function() BuildWLUI() end)

--=============================================================
-- 👁️ VISUAL
--=============================================================
CreateTitle(VisualP, "Jogadores", "👁️")
local cfgESP, espApply, espWrap, espBtnT = CreateToggleWithConfig(VisualP, "Ativar ESP", false, function(v) S.ESP = v end)
espBtn = espBtnT
CreateToggle(cfgESP, "Caixas", false, function(v) S.Boxes = v end)
CreateToggle(cfgESP, "Nomes", false, function(v) S.Names = v end)
CreateToggle(cfgESP, "Distância", false, function(v) S.Distance = v end)
CreateToggle(cfgESP, "Linhas", false, function(v) S.Lines = v end)
CreateToggle(cfgESP, "Cor do Time", false, function(v) S.TeamColor = v end)
CreateToggle(cfgESP, "Destaque (Chams)", false, function(v) S.Highlight = v end)

CreateTitle(VisualP, "NPCs", "🤖")
CreateToggle(VisualP, "ESP em NPCs", false, function(v) S.ESPNPC = v end)

--=============================================================
-- 🏃 PERSONAGEM
--=============================================================
CreateTitle(PersoP, "Velocidade", "⚡")
local cfgSpeed = CreateToggleWithConfig(PersoP, "Modificar Velocidade", false, function(v) S.UseSpeed = v end)
CreateStepper(cfgSpeed, "Velocidade", 16, 500, 16, 5, function(v) S.Speed = v end)

CreateTitle(PersoP, "Pulo", "🦘")
CreateToggle(PersoP, "Pulo Infinito", false, function(v) S.InfiniteJump = v end)

CreateTitle(PersoP, "Modo Voo", "🕊️")
local cfgFly = CreateToggleWithConfig(PersoP, "Ativar Modo Voo", false, function(v)
    S.FlyMode = v
    if v then flyOn() else flyOff() end
end)
CreateStepper(cfgFly, "Multiplicador de Velocidade", 1, 10, 1, 1, function(v) getgenv().speeds = v end)

local upDownFrame = Instance.new("Frame", cfgFly)
upDownFrame.Size = UDim2.new(1, 0, 0, 34)
upDownFrame.BackgroundTransparency = 1
upDownFrame.ZIndex = 103

local upBtn = Instance.new("TextButton", upDownFrame)
upBtn.Size = UDim2.new(0.5, -3, 1, 0)
upBtn.BackgroundColor3 = C.Green
upBtn.Text = "⬆  SUBIR"; upBtn.TextColor3 = Color3.new(0,0,0)
upBtn.TextSize = 11; upBtn.Font = C.FontB
upBtn.AutoButtonColor = false; upBtn.ZIndex = 104
Corner(upBtn, 8)

local downBtn = Instance.new("TextButton", upDownFrame)
downBtn.Size = UDim2.new(0.5, -3, 1, 0)
downBtn.Position = UDim2.new(0.5, 3, 0, 0)
downBtn.BackgroundColor3 = C.Red
downBtn.Text = "⬇  DESCER"; downBtn.TextColor3 = Color3.new(0,0,0)
downBtn.TextSize = 11; downBtn.Font = C.FontB
downBtn.AutoButtonColor = false; downBtn.ZIndex = 104
Corner(downBtn, 8)

upBtn.MouseButton1Down:Connect(function() PS("Click"); flyUp = true end)
upBtn.MouseButton1Up:Connect(function() flyUp = false end)
upBtn.MouseLeave:Connect(function() flyUp = false end)
downBtn.MouseButton1Down:Connect(function() PS("Click"); flyDown = true end)
downBtn.MouseButton1Up:Connect(function() flyDown = false end)
downBtn.MouseLeave:Connect(function() flyDown = false end)

task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if flyUp then hrp.CFrame = hrp.CFrame * CFrame.new(0, 1, 0) end
                if flyDown then hrp.CFrame = hrp.CFrame * CFrame.new(0, -1, 0) end
            end
        end
    end
end)

CreateLabel(cfgFly, "Use WASD pra voar. Segure SUBIR/DESCER pra mover verticalmente.", 30)

CreateTitle(PersoP, "Câmera", "🎥")
CreateToggle(PersoP, "Terceira Pessoa", false, function(v) S.ForceThirdPerson = v end)

--=============================================================
-- 🌀 TELEPORTE
--=============================================================
CreateTitle(TPP, "Jogadores Online", "👥")
local SelLab = CreateLabel(TPP, "🎯 Alvo: Nenhum", 25)
SelLab.TextColor3 = C.Green

local plist = Instance.new("ScrollingFrame", TPP)
plist.Size = UDim2.new(1, 0, 0, 140)
plist.BackgroundColor3 = C.Bg
plist.BorderSizePixel = 0
plist.ScrollBarThickness = 2
plist.CanvasSize = UDim2.new(0, 0, 0, 0)
plist.ZIndex = 103
Corner(plist, 8)
local pll = Instance.new("UIListLayout", plist)
pll.Padding = UDim.new(0, 2)

local function UpList()
    for _, v in pairs(plist:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    local sorted = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(sorted, p) end
    end
    SortPlayers(sorted)

    for _, p in ipairs(sorted) do
        local isFr = IsFriend(p)
        local b = Instance.new("TextButton", plist)
        b.Size = UDim2.new(1, -4, 0, 25)
        b.Text = (isFr and "⭐ " or "") .. p.DisplayName
        b.BackgroundColor3 = isFr and Color3.fromRGB(0, 90, 150) or C.BgHover
        b.TextColor3 = isFr and Color3.fromRGB(180, 220, 255) or C.Text
        b.TextSize = 10; b.Font = C.Font
        b.AutoButtonColor = false; b.ZIndex = 104
        Corner(b, 6)
        b.MouseButton1Click:Connect(function()
            S.SelectedPlayer = p
            SelLab.Text = "🎯 Alvo: " .. (isFr and "⭐ " or "") .. p.DisplayName
        end)
    end
    plist.CanvasSize = UDim2.new(0, 0, 0, pll.AbsoluteContentSize.Y)
end
UpList()
Players.PlayerAdded:Connect(UpList)
Players.PlayerRemoving:Connect(UpList)
task.delay(4, UpList)
task.delay(8, UpList)

CreateTitle(TPP, "Ações", "🌀")
CreateButton(TPP, "📡 Teleportar até Alvo", C.Accent, function()
    if S.SelectedPlayer and S.SelectedPlayer.Character and LocalPlayer.Character then
        LocalPlayer.Character.HumanoidRootPart.CFrame = S.SelectedPlayer.Character.HumanoidRootPart.CFrame
        Notify("Teleportado até " .. S.SelectedPlayer.DisplayName, true)
    else
        Notify("Nenhum alvo selecionado", false)
    end
end)
CreateToggle(TPP, "Selecionar Mais Próximo (Auto)", false, function(v) S.AutoNearest = v end)
local cfgSticky = CreateToggleWithConfig(TPP, "Grudar Atrás", false, function(v) S.StickyBehind = v end)
CreateStepper(cfgSticky, "Suavidade", 0.01, 1, 0.1, 0.05, function(v) S.StickySmoothness = v end)
CreateStepper(cfgSticky, "Distância", 1, 20, 3, 1, function(v) S.StickyDistance = v end)

--=============================================================
-- 📦 HITBOX
--=============================================================
CreateTitle(HitP, "Hitbox", "📦")
local cfgHb, hbApply, hbWrap, hbBtnT = CreateToggleWithConfig(HitP, "Aumentar Hitbox (Jogadores)", false, function(v) S.HitboxEnabled = v end)
hitboxBtn = hbBtnT
CreateStepper(cfgHb, "Tamanho", 2, 100, 20, 5, function(v) S.Hitbox = v end)
CreateStepper(cfgHb, "Opacidade", 0, 1, 0.6, 0.1, function(v) S.HitboxTransparency = v end)

CreateToggle(HitP, "Aumentar Hitbox (NPCs)", false, function(v) S.HitboxNPC = v end)

--=============================================================
-- 💣 DEFUSAL
--=============================================================
CreateTitle(DefP, "ESP por Time", "💣")
CreateToggle(DefP, "Detectar Time Automaticamente", false, function(v) S.AutoTeamColorCheck = v end)

CreateTitle(DefP, "Mira por Time", "🎯")
local DefLab = CreateLabel(DefP, "🎯 Alvo Inimigo: Nenhum", 25)
DefLab.TextColor3 = C.Text
CreateToggle(DefP, "Mira Apenas em Inimigos", false, function(v) S.ColorAimbot = v end)
CreateButton(DefP, "🔵 Definir Alvo: Time Azul", Color3.fromRGB(72,171,229), function()
    S.ColorAimbotTarget = Color3.fromRGB(72,171,229)
    DefLab.Text = "🎯 Alvo Inimigo: Time Azul"
    DefLab.TextColor3 = Color3.fromRGB(72,171,229)
    Notify("Alvo definido: Time Azul", true)
end)
CreateButton(DefP, "🔴 Definir Alvo: Time Vermelho", Color3.fromRGB(229,72,72), function()
    S.ColorAimbotTarget = Color3.fromRGB(229,72,72)
    DefLab.Text = "🎯 Alvo Inimigo: Time Vermelho"
    DefLab.TextColor3 = Color3.fromRGB(229,72,72)
    Notify("Alvo definido: Time Vermelho", true)
end)

--=============================================================
-- ⚙️ PRESETS
--=============================================================
CreateTitle(PresetP, "Predefinições", "⚙️")

CreateButton(PresetP, "🎯 Carregar: Modo Legit", Color3.fromRGB(0, 100, 50), function()
    if VisToggles["Ativar ESP"] then VisToggles["Ativar ESP"](true) end
    if VisToggles["Destaque (Chams)"] then VisToggles["Destaque (Chams)"](true) end
    if VisToggles["Cor do Time"] then VisToggles["Cor do Time"](true) end
    if VisToggles["Ativar Assistência"] then VisToggles["Ativar Assistência"](true) end
    if VisToggles["Ignorar Atrás de Paredes"] then VisToggles["Ignorar Atrás de Paredes"](true) end
    if VisSteppers["Campo de Visão (FOV)"] then VisSteppers["Campo de Visão (FOV)"](20) end
    if VisSteppers["Suavidade"] then VisSteppers["Suavidade"](0.2) end
    Notify("Preset Legit carregado!", true)
end)

CreateButton(PresetP, "🤖 Carregar: Modo NPC", Color3.fromRGB(150, 50, 0), function()
    if VisToggles["ESP em NPCs"] then VisToggles["ESP em NPCs"](true) end
    if VisToggles["Destaque (Chams)"] then VisToggles["Destaque (Chams)"](true) end
    if VisToggles["Ativar Assistência"] then VisToggles["Ativar Assistência"](true) end
    if VisToggles["Mira em NPCs"] then VisToggles["Mira em NPCs"](true) end
    if VisToggles["Prioridade 360°"] then VisToggles["Prioridade 360°"](true) end
    if VisToggles["Ignorar Atrás de Paredes"] then VisToggles["Ignorar Atrás de Paredes"](true) end
    if VisToggles["Aumentar Hitbox (NPCs)"] then VisToggles["Aumentar Hitbox (NPCs)"](true) end
    Notify("Preset NPC carregado!", true)
end)

CreateButton(PresetP, "🔄 Resetar Tudo", Color3.fromRGB(150, 30, 30), function()
    for _, f in pairs(VisToggles) do f(false, true, true) end
    Notify("Tudo resetado", true)
end)

CreateTitle(PresetP, "Botões Flutuantes", "🔘")

local function CountFloats()
    local n = 0
    for _, v in pairs(ScreenGui:GetChildren()) do
        if string.find(v.Name, "^FloatBtn_") then n = n + 1 end
    end
    return n
end

local function SpawnFloat(name, cb)
    for _, v in pairs(ScreenGui:GetChildren()) do
        if v.Name == "FloatBtn_" .. name then return end
    end
    local idx = CountFloats()
    local offsetX = -130 - (idx * 55)

    local ff = Instance.new("Frame", ScreenGui)
    ff.Name = "FloatBtn_" .. name
    ff.Size = UDim2.new(0, 50, 0, 50)
    ff.Position = UDim2.new(1, offsetX, 0, 80)
    ff.BackgroundColor3 = C.BgAlt
    ff.ZIndex = 60
    Corner(ff, 25)
    Stroke(ff, C.Accent, 1.5, 0.3)

    local icon = Instance.new("TextLabel", ff)
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = name; icon.TextColor3 = C.Text
    icon.TextSize = 9; icon.Font = C.FontB
    icon.ZIndex = 62

    local b = Instance.new("TextButton", ff)
    b.Size = UDim2.new(1, 0, 1, 0)
    b.BackgroundTransparency = 1
    b.Text = ""; b.ZIndex = 61
    b.AutoButtonColor = false

    local close = Instance.new("TextButton", ff)
    close.Size = UDim2.new(0, 18, 0, 18)
    close.Position = UDim2.new(1, -12, 0, -6)
    close.BackgroundColor3 = C.Red
    close.Text = "×"; close.TextColor3 = Color3.new(1,1,1); close.TextSize = 10
    close.AutoButtonColor = false; close.ZIndex = 63
    Corner(close, 10)

    local dragging, startMouse, startFrame, moved
    b.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; moved = false
            startMouse = UIS:GetMouseLocation()
            startFrame = ff.Position
        end
    end)
    RunService.RenderStepped:Connect(function()
        if not dragging then return end
        local now = UIS:GetMouseLocation()
        local d = now - startMouse
        if math.abs(d.X) > 5 or math.abs(d.Y) > 5 then moved = true end
        if moved then
            ff.Position = UDim2.new(
                startFrame.X.Scale, startFrame.X.Offset + d.X,
                startFrame.Y.Scale, startFrame.Y.Offset + d.Y)
        end
    end)
    b.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if dragging and not moved then cb() end
            dragging = false; moved = false
        end
    end)
    close.MouseButton1Click:Connect(function() ff:Destroy() end)
end

CreateButton(PresetP, "Criar Botão: Mira", Color3.fromRGB(50, 50, 150), function()
    SpawnFloat("AIM", function()
        local n = not S.AimAssist
        if VisToggles["Ativar Assistência"] then VisToggles["Ativar Assistência"](n) end
        Notify("MIRA: " .. (n and "ON" or "OFF"), n)
    end)
end)
CreateButton(PresetP, "Criar Botão: Visual", Color3.fromRGB(50, 50, 150), function()
    SpawnFloat("VIS", function()
        local n = not S.ESP
        if VisToggles["Ativar ESP"] then VisToggles["Ativar ESP"](n) end
        if VisToggles["Destaque (Chams)"] then VisToggles["Destaque (Chams)"](n) end
        Notify("VISUAL: " .. (n and "ON" or "OFF"), n)
    end)
end)
CreateButton(PresetP, "Criar Botão: Hitbox", Color3.fromRGB(50, 50, 150), function()
    SpawnFloat("HB", function()
        local n = not S.HitboxEnabled
        if VisToggles["Aumentar Hitbox (Jogadores)"] then VisToggles["Aumentar Hitbox (Jogadores)"](n) end
        Notify("HITBOX: " .. (n and "ON" or "OFF"), n)
    end)
end)

--=============================================================
-- ⌨️ ATALHOS
--=============================================================
local listening = nil
local function KeyName(mod, key)
    local m = ""
    if mod == Enum.KeyCode.LeftAlt or mod == Enum.KeyCode.RightAlt then m = "Alt + "
    elseif mod == Enum.KeyCode.LeftControl or mod == Enum.KeyCode.RightControl then m = "Ctrl + "
    elseif mod == Enum.KeyCode.LeftShift or mod == Enum.KeyCode.RightShift then m = "Shift + " end
    return m .. (key.Name or "None")
end

local function BindRow(parent, label, key, btn)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 35)
    f.BackgroundColor3 = C.Bg
    f.ZIndex = 103
    Corner(f, 8)

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0.6, 0, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.TextColor3 = C.Text; l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = C.FontB
    l.Text = label; l.ZIndex = 104

    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(0.4, -10, 0.8, 0)
    b.Position = UDim2.new(0.6, 0, 0.1, 0)
    b.BackgroundColor3 = C.BgHover
    b.TextColor3 = C.Green; b.TextSize = 10
    b.Font = C.FontB; b.AutoButtonColor = false
    b.ZIndex = 104
    Corner(b, 6)

    local bind = S.Binds[key]
    b.Text = KeyName(bind.Mod, bind.Key)
    b.MouseButton1Click:Connect(function()
        PS("Click")
        b.Text = "Pressione..."
        b.TextColor3 = Color3.fromRGB(255, 200, 0)
        listening = {Key = key, UI = b}
    end)
end

CreateTitle(BindsP, "Configurar Teclas", "⌨️")
BindRow(BindsP, "Aimbot", "AimAssist", aimbotBtn)
BindRow(BindsP, "ESP (Visual)", "Visuals", espBtn)
BindRow(BindsP, "Hitbox", "Hitbox", hitboxBtn)
CreateLabel(BindsP,
    "• Ctrl Direito / Delete = abrir menu.\n" ..
    "• Esc = cancelar captura de tecla.", 40)

--=============================================================
-- 🌐 SERVIDOR
--=============================================================
CreateTitle(ServP, "Trocar de Servidor", "🌐")

CreateButton(ServP, "🔄 Reconectar (Mesmo Servidor)", Color3.fromRGB(0, 100, 150), function()
    Notify("Reconectando...", true)
    task.wait(0.5)
    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)
end)

CreateButton(ServP, "🎲 Servidor Aleatório", Color3.fromRGB(150, 100, 0), function()
    Notify("Procurando servidor aleatório...", true)
    pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"
        local data = HttpService:JSONDecode(game:HttpGet(url))
        local valid = {}
        for _, srv in ipairs(data.data) do
            if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then
                table.insert(valid, srv)
            end
        end
        if #valid > 0 then
            local pick = valid[math.random(1, #valid)]
            Notify("Servidor encontrado! Teleportando...", true)
            task.wait(0.5)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, pick.id, LocalPlayer)
        else
            Notify("Nenhum servidor disponível", false)
        end
    end)
end)

CreateButton(ServP, "🔥 Servidor Mais Cheio", Color3.fromRGB(200, 60, 0), function()
    Notify("Procurando servidor mais cheio...", true)
    pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Desc&limit=100"
        local data = HttpService:JSONDecode(game:HttpGet(url))
        local best, bestCount = nil, 0
        for _, srv in ipairs(data.data) do
            if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then
                if srv.playing > bestCount then best = srv; bestCount = srv.playing end
            end
        end
        if best then
            Notify("Servidor: " .. best.playing .. "/" .. best.maxPlayers, true)
            task.wait(0.5)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, best.id, LocalPlayer)
        else
            Notify("Nenhum servidor disponível", false)
        end
    end)
end)

CreateButton(ServP, "🍃 Servidor Mais Vazio", Color3.fromRGB(0, 130, 90), function()
    Notify("Procurando servidor mais vazio...", true)
    pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"
        local data = HttpService:JSONDecode(game:HttpGet(url))
        local best, bestCount = nil, math.huge
        for _, srv in ipairs(data.data) do
            if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then
                if srv.playing < bestCount then best = srv; bestCount = srv.playing end
            end
        end
        if best then
            Notify("Servidor: " .. best.playing .. "/" .. best.maxPlayers, true)
            task.wait(0.5)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, best.id, LocalPlayer)
        else
            Notify("Nenhum servidor disponível", false)
        end
    end)
end)

--=============================================================
-- 🧰 MISC
--=============================================================
CreateTitle(MiscP, "Desempenho", "⚡")
CreateToggle(MiscP, "Remover Texturas", false, function(v)
    S.BoostFPS = v
    for _, o in pairs(game:GetDescendants()) do
        if o:IsA("Texture") or o:IsA("Decal") then o.Transparency = v and 1 or 0 end
    end
end)
CreateToggle(MiscP, "Remover Sombras", false, function(v)
    S.RemoveShadows = v
    Lighting.GlobalShadows = not v
end)
CreateStepper(MiscP, "Limite de FPS", 30, 240, 120, 30, function(v)
    if setfpscap then setfpscap(v) end
end)

CreateTitle(MiscP, "Ambiente", "☀️")
CreateToggle(MiscP, "Visão Total (Fullbright)", false, function(v)
    S.Fullbright = v
    if v then
        Lighting.Brightness = 3
        Lighting.Ambient = Color3.fromRGB(180, 180, 180)
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
    else
        Lighting.Brightness = originalLighting.Brightness
        Lighting.Ambient = originalLighting.Ambient
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    end
end)
CreateToggle(MiscP, "Remover Névoa", false, function(v)
    S.NoFog = v
    if v then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
    else
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.FogStart = originalLighting.FogStart
    end
end)

CreateTitle(MiscP, "Utilidades", "🔧")
CreateToggle(MiscP, "Anti-AFK", false, function(v)
    S.AntiAFK = v
    if v then Notify("Anti-AFK ativado", true) end
end)
CreateButton(MiscP, "♻️ Resetar Personagem", Color3.fromRGB(150, 80, 0), function()
    local ch = LocalPlayer.Character
    if ch then
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0; Notify("Personagem resetado", true) end
    end
end)
CreateButton(MiscP, "🧹 Limpar Notificações", Color3.fromRGB(80, 80, 80), function()
    for _, v in pairs(NF:GetChildren()) do
        if v:IsA("TextLabel") then v:Destroy() end
    end
end)

CreateTitle(MiscP, "Áudio", "🔊")
CreateToggle(MiscP, "Sons do Menu", true, function(v) S.SoundEnabled = v end)

CreateTitle(MiscP, "Sobre", "ℹ️")
CreateLabel(MiscP,
    "🎯 Kiko Menu " .. VERSION .. "\n\n" ..
    "Atalhos:\n" ..
    "• Ctrl Direito / Delete — abrir/fechar\n" ..
    "• 🔍 — buscar função pelo nome\n" ..
    "• Arraste o título para mover o menu", 130)

--=============================================================
-- 🔍 SISTEMA DE BUSCA
--=============================================================
SearchIcon.MouseButton1Click:Connect(function()
    PS("Click")
    SearchBox.Visible = not SearchBox.Visible
    if SearchBox.Visible then SearchBox:CaptureFocus()
    else SearchBox.Text = "" end
end)

SearchBox.FocusLost:Connect(function(enterPressed)
    if not enterPressed and SearchBox.Text == "" then SearchBox.Visible = false end
end)

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = string.lower(SearchBox.Text)
    if q == "" then
        for _, e in pairs(SearchIndex) do
            if not e.isConfig then e.element.Visible = true end
        end
        return
    end

    local matchedToggle = {}
    for _, e in pairs(SearchIndex) do
        local m = string.find(e.searchText, q, 1, true) ~= nil
        e._matched = m
        if m and e.isConfig and e.parentToggle then
            matchedToggle[e.parentToggle] = true
        end
    end

    for _, e in pairs(SearchIndex) do
        if not e.isConfig then
            e.element.Visible = e._matched or matchedToggle[e.element] or false
        end
    end
end)

--=============================================================
-- 🕊️ FLY
--=============================================================
function flyOn()
    local speaker = LocalPlayer
    getgenv().nowe = true
    local speeds = getgenv().speeds

    for i = 1, speeds do
        spawn(function()
            local hb = RunService.Heartbeat
            getgenv().tpwalking = true
            local chr = LocalPlayer.Character
            local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
            while getgenv().tpwalking and hb:Wait() and chr and hum and hum.Parent do
                if hum.MoveDirection.Magnitude > 0 then chr:TranslateBy(hum.MoveDirection) end
            end
        end)
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Animate") then
        LocalPlayer.Character.Animate.Disabled = true
    end
    local Char = LocalPlayer.Character
    local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
    for i, v in next, Hum:GetPlayingAnimationTracks() do v:AdjustSpeed(0) end

    local hum = speaker.Character.Humanoid
    hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Running, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
    hum:ChangeState(Enum.HumanoidStateType.Swimming)

    if LocalPlayer.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
        local plr = LocalPlayer
        local torso = plr.Character.Torso
        local ctrl = {f=0,b=0,l=0,r=0}; local lastctrl = {f=0,b=0,l=0,r=0}
        local maxspeed = 50; local speed = 0
        local bg = Instance.new("BodyGyro", torso)
        bg.P = 9e4; bg.maxTorque = Vector3.new(9e9, 9e9, 9e9); bg.cframe = torso.CFrame
        local bv = Instance.new("BodyVelocity", torso)
        bv.velocity = Vector3.new(0,0.1,0); bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        plr.Character.Humanoid.PlatformStand = true
        while getgenv().nowe == true or plr.Character.Humanoid.Health == 0 do
            RunService.RenderStepped:Wait()
            if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                speed = speed+.5+(speed/maxspeed)
                if speed > maxspeed then speed = maxspeed end
            elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
                speed = speed-1; if speed < 0 then speed = 0 end
            end
            if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                bv.velocity = ((Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - Workspace.CurrentCamera.CoordinateFrame.p))*speed
                lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
            elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
                bv.velocity = ((Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - Workspace.CurrentCamera.CoordinateFrame.p))*speed
            else bv.velocity = Vector3.new(0,0,0) end
            bg.cframe = Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
        end
        bg:Destroy(); bv:Destroy()
        plr.Character.Humanoid.PlatformStand = false
        LocalPlayer.Character.Animate.Disabled = false
        getgenv().tpwalking = false
    else
        local plr = LocalPlayer
        local UpperTorso = plr.Character.UpperTorso
        local ctrl = {f=0,b=0,l=0,r=0}; local lastctrl = {f=0,b=0,l=0,r=0}
        local maxspeed = 50; local speed = 0
        local bg = Instance.new("BodyGyro", UpperTorso)
        bg.P = 9e4; bg.maxTorque = Vector3.new(9e9, 9e9, 9e9); bg.cframe = UpperTorso.CFrame
        local bv = Instance.new("BodyVelocity", UpperTorso)
        bv.velocity = Vector3.new(0,0.1,0); bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        plr.Character.Humanoid.PlatformStand = true
        while getgenv().nowe == true or plr.Character.Humanoid.Health == 0 do
            wait()
            if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                speed = speed+.5+(speed/maxspeed)
                if speed > maxspeed then speed = maxspeed end
            elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
                speed = speed-1; if speed < 0 then speed = 0 end
            end
            if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                bv.velocity = ((Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - Workspace.CurrentCamera.CoordinateFrame.p))*speed
                lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
            elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
                bv.velocity = ((Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - Workspace.CurrentCamera.CoordinateFrame.p))*speed
            else bv.velocity = Vector3.new(0,0,0) end
            bg.cframe = Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
        end
        bg:Destroy(); bv:Destroy()
        plr.Character.Humanoid.PlatformStand = false
        LocalPlayer.Character.Animate.Disabled = false
        getgenv().tpwalking = false
    end

    Notify("🕊️ Modo Voo ATIVADO", true)
end

function flyOff()
    local speaker = LocalPlayer
    getgenv().nowe = false; getgenv().tpwalking = false
    flyUp = false; flyDown = false
    if speaker.Character and speaker.Character:FindFirstChildOfClass("Humanoid") then
        local h = speaker.Character.Humanoid
        h:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
        h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        h:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
        h:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        h:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
        h:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        h:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
        h:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
        h:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
        h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        h:SetStateEnabled(Enum.HumanoidStateType.Running, true)
        h:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)
        h:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        h:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, true)
        h:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
        h:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
    end
    Notify("🕊️ Modo Voo DESATIVADO", false)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.7)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = false
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Animate") then
        LocalPlayer.Character.Animate.Disabled = false
    end
    getgenv().nowe = false; getgenv().tpwalking = false
    flyUp = false; flyDown = false
end)

--=============================================================
-- TOGGLE MENU
--=============================================================
local function ToggleMenu()
    if MenuAberto then
        PS("Close")
        MenuAberto = false
        local anim = TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            BackgroundTransparency = 1, Size = UDim2.new(0, 330, 0, 430)
        })
        anim:Play()
        anim.Completed:Connect(function()
            Main.Visible = false
            Main.BackgroundTransparency = 0
            Main.Size = UDim2.new(0, 340, 0, 440)
        end)
    else
        PS("Open")
        MenuAberto = true
        Main.Visible = true
        Main.BackgroundTransparency = 1
        Main.Size = UDim2.new(0, 330, 0, 430)
        TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0, Size = UDim2.new(0, 340, 0, 440)
        }):Play()
    end
end

CloseB.MouseButton1Click:Connect(function() PS("Click"); ToggleMenu() end)

do
    local fbDragging = false
    local fbStartMouse = nil
    local fbStartFrame = nil
    local fbMoved = false

    FloatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            fbDragging = true; fbMoved = false
            fbStartMouse = UIS:GetMouseLocation()
            fbStartFrame = Float.Position
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if not fbDragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local wasMoved = fbMoved
        fbDragging = false; fbMoved = false
        if not wasMoved then PS("Click"); ToggleMenu() end
    end)

    RunService.RenderStepped:Connect(function()
        if not fbDragging then return end
        local now = UIS:GetMouseLocation()
        local d = now - fbStartMouse
        if math.abs(d.X) > 5 or math.abs(d.Y) > 5 then fbMoved = true end
        if fbMoved then
            Float.Position = UDim2.new(
                fbStartFrame.X.Scale, fbStartFrame.X.Offset + d.X,
                fbStartFrame.Y.Scale, fbStartFrame.Y.Offset + d.Y)
        end
    end)
end

--=============================================================
-- INPUTS
--=============================================================
UIS.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Delete then
        ToggleMenu()
        return
    end

    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.Escape then
            local b = S.Binds[listening.Key]
            listening.UI.Text = KeyName(b.Mod, b.Key)
            listening.UI.TextColor3 = C.Green
            listening = nil
            return
        end
        if input.KeyCode == Enum.KeyCode.LeftAlt or input.KeyCode == Enum.KeyCode.RightAlt
        or input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl
        or input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then return end

        local mod = nil
        if UIS:IsKeyDown(Enum.KeyCode.LeftAlt) or UIS:IsKeyDown(Enum.KeyCode.RightAlt) then mod = Enum.KeyCode.LeftAlt
        elseif UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl) then mod = Enum.KeyCode.LeftControl
        elseif UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.RightShift) then mod = Enum.KeyCode.LeftShift end

        S.Binds[listening.Key] = {Mod = mod, Key = input.KeyCode}
        listening.UI.Text = KeyName(mod, input.KeyCode)
        listening.UI.TextColor3 = C.Green
        Notify("Atalho atualizado!", true)
        listening = nil
        return
    end

    if gp or listening then return end

    for bk, bi in pairs(S.Binds) do
        if input.KeyCode == bi.Key then
            local modOK = true
            if bi.Mod == Enum.KeyCode.LeftAlt and not (UIS:IsKeyDown(Enum.KeyCode.LeftAlt) or UIS:IsKeyDown(Enum.KeyCode.RightAlt)) then modOK = false end
            if bi.Mod == Enum.KeyCode.LeftControl and not (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl)) then modOK = false end
            if bi.Mod == Enum.KeyCode.LeftShift and not (UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.RightShift)) then modOK = false end
            if bi.Mod == nil and (UIS:IsKeyDown(Enum.KeyCode.LeftAlt) or UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.LeftShift)) then modOK = false end

            if modOK then
                if bk == "AimAssist" then
                    local n = not S.AimAssist
                    if VisToggles["Ativar Assistência"] then VisToggles["Ativar Assistência"](n, true, true) end
                    S.AimAssist = n
                    Notify("MIRA: " .. (n and "ON" or "OFF"), n)
                elseif bk == "Visuals" then
                    local n = not S.ESP
                    if VisToggles["Ativar ESP"] then VisToggles["Ativar ESP"](n, true, true) end
                    S.ESP = n
                    if VisToggles["Destaque (Chams)"] then VisToggles["Destaque (Chams)"](n, true, true) end
                    S.Highlight = n
                    Notify("VISUAL: " .. (n and "ON" or "OFF"), n)
                elseif bk == "Hitbox" then
                    local n = not S.HitboxEnabled
                    if VisToggles["Aumentar Hitbox (Jogadores)"] then VisToggles["Aumentar Hitbox (Jogadores)"](n, true, true) end
                    S.HitboxEnabled = n
                    Notify("HITBOX: " .. (n and "ON" or "OFF"), n)
                end
            end
        end
    end
end)

--=============================================================
-- NPC CACHE
--=============================================================
local NPCCache = {}
local ESPCont = {}
local NPCESPCont = {}

local function CreateSkelLines()
    local lines = {}
    for i = 1, 12 do
        local l = Drawing.new("Line")
        l.Thickness = 1; l.Visible = false
        l.Color = Color3.new(1,1,1)
        table.insert(lines, l)
    end
    return lines
end

local function RemoveESP(cont, obj)
    if cont[obj] then
        if cont[obj].Box then cont[obj].Box:Remove() end
        if cont[obj].Name then cont[obj].Name:Remove() end
        if cont[obj].Dist then cont[obj].Dist:Remove() end
        if cont[obj].Line then cont[obj].Line:Remove() end
        if cont[obj].Highlight then cont[obj].Highlight:Destroy() end
        if cont[obj].Skeleton then for _, l in pairs(cont[obj].Skeleton) do l:Remove() end end
        cont[obj] = nil
    end
end

local function CreateESPObj(cont, obj)
    if cont[obj] then return end
    cont[obj] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Dist = Drawing.new("Text"),
        Line = Drawing.new("Line"),
        Highlight = nil,
        Skeleton = CreateSkelLines()
    }
    local e = cont[obj]
    e.Box.Thickness = 1.5; e.Box.Filled = false
    e.Name.Size = 14; e.Name.Center = true; e.Name.Outline = true
    e.Dist.Size = 12; e.Dist.Center = true; e.Dist.Outline = true
    e.Line.Thickness = 1
end

Players.PlayerAdded:Connect(function(p) CreateESPObj(ESPCont, p) end)
Players.PlayerRemoving:Connect(function(p) RemoveESP(ESPCont, p) end)
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESPObj(ESPCont, p) end
end

task.spawn(function()
    while true do
        if S.AimNPC or S.ESPNPC or S.HitboxNPC then
            local tmp = {}; local cur = {}
            for _, o in pairs(workspace:GetDescendants()) do
                if o:IsA("Model") and o:FindFirstChild("Humanoid")
                and o.Humanoid.Health > 1
                and not Players:GetPlayerFromCharacter(o) then
                    table.insert(tmp, o); cur[o] = true
                    if S.ESPNPC then CreateESPObj(NPCESPCont, o) end
                end
            end
            NPCCache = tmp
            for o, _ in pairs(NPCESPCont) do
                if not cur[o] then RemoveESP(NPCESPCont, o) end
            end
        else
            NPCCache = {}
            for o, _ in pairs(NPCESPCont) do RemoveESP(NPCESPCont, o) end
        end
        task.wait(2)
    end
end)

local function IsVisible(part)
    if not S.WallCheck then return true end
    local o = Camera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
    local r = workspace:Raycast(o, part.Position - o, params)
    return r == nil
end

--=============================================================
-- UPDATE CANVAS
--=============================================================
task.spawn(function()
    while true do
        RunService.RenderStepped:Wait()
        if ActivePage and Content then
            local desired = ActivePage.AbsoluteSize.Y + 20
            if Content.CanvasSize.Y.Offset ~= desired then
                Content.CanvasSize = UDim2.new(0, 0, 0, desired)
            end
        end
    end
end)

--=============================================================
-- MAIN LOOP
--=============================================================
RunService.RenderStepped:Connect(function()
    if MenuAberto then
        UIS.MouseIconEnabled = true
        UIS.MouseBehavior = Enum.MouseBehavior.Default
    end
    FPSLbl.Text = "FPS: " .. math.floor(1/RunService.RenderStepped:Wait())
    FOVCircle.Visible = S.ShowFOV and S.AimAssist
    FOVCircle.Radius = S.AimFOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Color = C.Accent
    FOVCircle.Thickness = 1.2
    FOVCircle.Filled = false

    local targetFound = false

    if S.AimAssist then
        local target, targetPos, best = nil, nil, math.huge
        local function Check(part, hum)
            if hum and hum.Health > 1 and IsVisible(part) then
                local pos = part.Position
                if S.AimPrediction then pos = pos + (part.AssemblyLinearVelocity * S.PredictionVelocity) end
                if S.TargetPriority then
                    if S.PriorityMode == "Mais Próximo" then
                        local d = (pos - Camera.CFrame.Position).Magnitude
                        if d < best then best = d; target = part; targetPos = pos end
                    elseif S.PriorityMode == "Menor Vida" then
                        local hp = hum.Health
                        if hp < best then best = hp; target = part; targetPos = pos end
                    end
                else
                    local p2, vis = Camera:WorldToViewportPoint(pos)
                    if vis then
                        local m = (Vector2.new(p2.X, p2.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if m < S.AimFOV and m < best then best = m; target = part; targetPos = pos end
                    end
                end
            end
        end

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(S.AimPart) then
                if S.Whitelist[p.UserId] then continue end
                if S.ColorAimbot and S.ColorAimbotTarget then
                    local tc = GetTeamColor(p)
                    local diff = math.abs(S.ColorAimbotTarget.R - tc.R) + math.abs(S.ColorAimbotTarget.G - tc.G) + math.abs(S.ColorAimbotTarget.B - tc.B)
                    if diff > 0.2 then continue end
                elseif S.AutoTeamColorCheck then
                    local mine = GetTeamColor(LocalPlayer)
                    local tc = GetTeamColor(p)
                    local diff = math.abs(mine.R - tc.R) + math.abs(mine.G - tc.G) + math.abs(mine.B - tc.B)
                    if diff < 0.2 then continue end
                elseif S.TeamCheck and p.Team == LocalPlayer.Team then continue end
                Check(p.Character[S.AimPart], p.Character:FindFirstChild("Humanoid"))
            end
        end
        if S.AimNPC then
            for _, o in pairs(NPCCache) do
                if o and o.Parent and o:FindFirstChild("Humanoid") then
                    local pt = o:FindFirstChild(S.AimPart) or o:FindFirstChild("HumanoidRootPart")
                    if pt then Check(pt, o.Humanoid) end
                end
            end
        end

        if target and targetPos then
            targetFound = true
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), S.AimSmooth)
            if S.TriggerBot and mouse1press then
                if not MenuAberto and not GuiService.MenuIsOpen then
                    if not isHoldingTarget then isHoldingTarget = true; mouse1press() end
                else
                    if isHoldingTarget and mouse1release then mouse1release(); isHoldingTarget = false end
                end
            end
        end
    end

    if not targetFound and isHoldingTarget then
        if mouse1release then mouse1release() end
        isHoldingTarget = false
    end

    if S.StickyBehind and S.SelectedPlayer and S.SelectedPlayer.Character then
        local hrp = S.SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame =
                LocalPlayer.Character.HumanoidRootPart.CFrame:Lerp(
                    hrp.CFrame * CFrame.new(0, 0, S.StickyDistance), S.StickySmoothness)
        end
    end

    if S.ForceThirdPerson then
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        LocalPlayer.CameraMaxZoomDistance = 100
    end

    if S.UseSpeed and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = S.Speed end
    end

    local function RenderCont(cont, isNPC)
        for obj, e in pairs(cont) do
            local ch = isNPC and obj or (obj.Parent and obj.Character)
            if not ch or not ch:FindFirstChild("HumanoidRootPart") or (isNPC and not S.ESPNPC) then
                e.Box.Visible = false; e.Name.Visible = false
                e.Dist.Visible = false; e.Line.Visible = false
                if e.Highlight then e.Highlight.Enabled = false end
                continue
            end
            local hrp = ch.HumanoidRootPart
            local head = ch:FindFirstChild("Head")
            local pos, vis = Camera:WorldToViewportPoint(hrp.Position)
            local col = Color3.new(1,1,1)
            if isNPC then col = Color3.fromRGB(255, 80, 80)
            elseif S.AutoTeamColorCheck then col = GetTeamColor(obj)
            elseif S.TeamColor and obj.TeamColor then col = obj.TeamColor.Color end

            if (isNPC and vis) or (not isNPC and S.ESP and vis) then
                if S.Boxes then
                    e.Box.Visible = true
                    e.Box.Size = Vector2.new(2500/pos.Z, 3500/pos.Z)
                    e.Box.Position = Vector2.new(pos.X - e.Box.Size.X/2, pos.Y - e.Box.Size.Y/2)
                    e.Box.Color = col
                else e.Box.Visible = false end
                if S.Names then
                    e.Name.Visible = true
                    e.Name.Text = isNPC and obj.Name or obj.DisplayName
                    e.Name.Position = Vector2.new(pos.X, pos.Y - (2000/pos.Z) - 20)
                    e.Name.Color = col
                else e.Name.Visible = false end
                if S.Distance then
                    e.Dist.Visible = true
                    e.Dist.Text = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude) .. "m"
                    e.Dist.Position = Vector2.new(pos.X, pos.Y + (2000/pos.Z) + 5)
                    e.Dist.Color = C.Green
                else e.Dist.Visible = false end
                if S.Lines and head then
                    local hp = Camera:WorldToViewportPoint(head.Position)
                    e.Line.Visible = true
                    e.Line.From = Vector2.new(Camera.ViewportSize.X/2, 0)
                    e.Line.To = Vector2.new(hp.X, hp.Y)
                    e.Line.Color = col
                else e.Line.Visible = false end
                if S.Highlight then
                    if not e.Highlight or e.Highlight.Parent ~= ch then
                        if e.Highlight then e.Highlight:Destroy() end
                        e.Highlight = Instance.new("Highlight", ch)
                    end
                    e.Highlight.Enabled = true
                    e.Highlight.FillColor = col
                    e.Highlight.FillTransparency = 0.5
                elseif e.Highlight then e.Highlight.Enabled = false end
            else
                e.Box.Visible = false; e.Name.Visible = false
                e.Dist.Visible = false; e.Line.Visible = false
                if e.Highlight then e.Highlight.Enabled = false end
            end
        end
    end
    RenderCont(ESPCont, false)
    RenderCont(NPCESPCont, true)
end)

--=============================================================
-- LOOP HITBOX + AUTO NEAREST
--=============================================================
task.spawn(function()
    while true do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if S.HitboxEnabled and not S.Whitelist[p.UserId] then
                        hrp.Size = Vector3.new(S.Hitbox, S.Hitbox, S.Hitbox)
                        hrp.Transparency = S.HitboxTransparency
                        hrp.CanCollide = false
                    else
                        hrp.Size = Vector3.new(2, 2, 1)
                        hrp.Transparency = 1
                    end
                end
            end
        end
        for _, o in pairs(NPCCache) do
            if o and o.Parent then
                local hrp = o:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if S.HitboxNPC then
                        hrp.Size = Vector3.new(S.Hitbox, S.Hitbox, S.Hitbox)
                        hrp.Transparency = S.HitboxTransparency
                        hrp.CanCollide = false
                    else
                        hrp.Size = Vector3.new(2, 2, 1)
                        hrp.Transparency = 1
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        if S.AutoNearest and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myPos = LocalPlayer.Character.HumanoidRootPart.Position
            local closest, minDist = nil, math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if not S.Whitelist[p.UserId]
                    and p.Character:FindFirstChild("Humanoid")
                    and p.Character.Humanoid.Health > 0 then
                        local d = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
                        if d < minDist then minDist = d; closest = p end
                    end
                end
            end
            if closest and S.SelectedPlayer ~= closest then
                S.SelectedPlayer = closest
                SelLab.Text = "🎯 Alvo: " .. closest.DisplayName .. " (Auto)"
            end
        end
        task.wait(0.2)
    end
end)

UIS.JumpRequest:Connect(function()
    if S.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end
end)

task.spawn(function()
    while true do
        task.wait(60)
        if S.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
end)

task.spawn(function()
    while true do
        TweenService:Create(FloatStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {Transparency = 0}):Play()
        task.wait(1.5)
        TweenService:Create(FloatStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {Transparency = 0.6}):Play()
        task.wait(1.5)
    end
end)

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "🎯 Kiko Menu",
        Text = "v5.11 — Fonte top + Amigos!",
        Duration = 4,
    })
end)

print("[Kiko MENU " .. VERSION .. "] ✅ Carregado com sucesso!")
