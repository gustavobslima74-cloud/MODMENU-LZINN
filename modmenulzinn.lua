--=============================================================
-- 🎯 KIKO MENU v7.5 — POWER EDITION
--=============================================================

print("[Kiko] Iniciando script...")

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

if setfpscap then setfpscap(240) end

--=============================================================
-- ⏱️ TIMER
--=============================================================
local SCRIPT_START_TIME = tick()

local function FormatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

--=============================================================
-- ⚙️ SETTINGS
--=============================================================
getgenv().Settings = {
    ESP = false, ESPNPC = false, TeamColor = false,
    Boxes = false, Names = false, Distance = false, Lines = false, Highlight = false,
    ESPHP = false,
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
    Fullbright = false, NoFog = false, AntiAFK = false,
    PerfTextures = false, PerfShadows = false, PerfDecals = false,
    PerfParticles = false, PerfTrails = false, PerfPostFX = false,
    PerfAnims = false, PerfGameSounds = false,
    RapidFire = false,
    ParticlesEnabled = true,
    Whitelist = {},
    SoundEnabled = true,
    Binds = {
        AimAssist   = {Mod = Enum.KeyCode.LeftAlt, Key = Enum.KeyCode.Two},
        Visuals     = {Mod = Enum.KeyCode.LeftAlt, Key = Enum.KeyCode.Three},
        Hitbox      = {Mod = Enum.KeyCode.LeftAlt, Key = Enum.KeyCode.Four},
        Panic       = {Mod = Enum.KeyCode.LeftControl, Key = Enum.KeyCode.P},
    }
}

local S = getgenv().Settings
local VERSION = "v7.5"
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
    GlobalShadows = Lighting.GlobalShadows,
}

local originalEffects = {}

--=============================================================
-- 🎨 TEMA
--=============================================================
local C = {
    Bg        = Color3.fromRGB(18, 18, 22),
    BgAlt     = Color3.fromRGB(26, 26, 32),
    BgHover   = Color3.fromRGB(38, 38, 46),
    Stroke    = Color3.fromRGB(50, 50, 60),
    Text      = Color3.fromRGB(240, 240, 245),
    Dim       = Color3.fromRGB(140, 140, 155),
    Accent    = Color3.fromRGB(220, 50, 50),
    AccentDk  = Color3.fromRGB(150, 30, 30),
    Green     = Color3.fromRGB(120, 220, 160),
    Red       = Color3.fromRGB(240, 120, 120),
    Yellow    = Color3.fromRGB(240, 200, 120),
    Purple    = Color3.fromRGB(180, 140, 240),
    Friend    = Color3.fromRGB(0, 170, 255),
    Font      = Enum.Font.Gotham,
    FontB     = Enum.Font.GothamBold,
    FontTitle = Enum.Font.GothamBold,
}

local DIM = { W = 440, H = 720, TopBar = 42, ProfileBar = 82, TabsBar = 46, Pad = 12 }

--=============================================================
-- 💾 CONFIG
--=============================================================
local CONFIG_FILE  = "kiko_menu_personal.json"
local PRESETS_FILE = "kiko_menu_presets.json"

local DefaultPersonal = {
    BgOpacity = 0.05, BgColor = {18, 18, 22}, AccentColor = {220, 50, 50},
    Blur = false, UIScale = 1.0,
}

local Personal = {}
local SavedPresets = {}

local function LoadPersonal()
    if not (writefile and readfile and isfile) then
        Personal = table.clone(DefaultPersonal); return
    end
    local ok = pcall(function()
        if isfile(CONFIG_FILE) then
            local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
            Personal = {}
            for k, v in pairs(DefaultPersonal) do
                Personal[k] = data[k] ~= nil and data[k] or v
            end
        else
            Personal = table.clone(DefaultPersonal)
        end
    end)
    if not ok then Personal = table.clone(DefaultPersonal) end
end

local function SavePersonal()
    if not writefile then return false end
    return pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(Personal)) end)
end

local function LoadPresets()
    if not (readfile and isfile) then return end
    pcall(function()
        if isfile(PRESETS_FILE) then
            SavedPresets = HttpService:JSONDecode(readfile(PRESETS_FILE)) or {}
        end
    end)
end

local function SavePresets()
    if not writefile then return false end
    return pcall(function() writefile(PRESETS_FILE, HttpService:JSONEncode(SavedPresets)) end)
end

LoadPersonal()
LoadPresets()

--=============================================================
-- 🖥️ SCREEN GUI
--=============================================================
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

print("[Kiko] GUI criada")

--=============================================================
-- 🔊 SISTEMA DE SOM
--=============================================================
local Sounds = {}
local function mkSound(n, id, v)
    local s = Instance.new("Sound")
    s.Name = n
    s.SoundId = "rbxassetid://" .. id
    s.Volume = v or 0.3
    s.Parent = SoundService
    Sounds[n] = s
end

mkSound("Hover",  "6042053626", 0.10)
mkSound("Click",  "6042053626", 0.22)
mkSound("Toggle", "6042053626", 0.25)
mkSound("Open",   "6042053626", 0.28)
mkSound("Close",  "6042053626", 0.22)
mkSound("Notify", "6042053626", 0.22)

--=============================================================
-- ✨ PARTÍCULAS
--=============================================================
local ParticleHolder = Instance.new("Frame", ScreenGui)
ParticleHolder.Size = UDim2.new(1, 0, 1, 0)
ParticleHolder.BackgroundTransparency = 1
ParticleHolder.ZIndex = 9999
ParticleHolder.Active = false

local function EmitParticles(pos, color, count)
    if not S.ParticlesEnabled then return end
    count = count or 8
    for i = 1, count do
        local p = Instance.new("Frame", ParticleHolder)
        local size = math.random(3, 6)
        p.Size = UDim2.new(0, size, 0, size)
        p.Position = UDim2.new(0, pos.X - size/2, 0, pos.Y - size/2)
        p.BackgroundColor3 = color or C.Accent
        p.BorderSizePixel = 0
        p.ZIndex = 9999
        Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
        local angle = math.random() * math.pi * 2
        local distance = math.random(30, 70)
        TweenService:Create(p, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, pos.X + math.cos(angle) * distance - size/2, 0, pos.Y + math.sin(angle) * distance - size/2),
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 1, 0, 1)
        }):Play()
        task.delay(0.55, function() p:Destroy() end)
    end
end

local function PS(n)
    if not S.SoundEnabled then return end
    local s = Sounds[n]; if s then pcall(function() s:Play() end) end
    if n == "Click" or n == "Toggle" then
        local mouse = UIS:GetMouseLocation()
        EmitParticles(Vector2.new(mouse.X, mouse.Y), C.Accent, n == "Click" and 8 or 5)
    end
end

--=============================================================
-- 👥 AMIGOS
--=============================================================
local FriendIds = {}
task.spawn(function()
    pcall(function()
        local cursor = ""
        for _ = 1, 15 do
            local url = "https://friends.roblox.com/v1/users/" .. tostring(LocalPlayer.UserId) .. "/friends?limit=200"
            if cursor ~= "" then url = url .. "&cursor=" .. cursor end
            local data = HttpService:JSONDecode(game:HttpGet(url))
            for _, f in ipairs(data.data or {}) do FriendIds[f.id] = true end
            cursor = data.nextPageCursor or ""
            if cursor == "" then break end
        end
    end)
end)

local function IsFriend(p) return p and FriendIds[p.UserId] == true end

local function SortPlayers(list)
    table.sort(list, function(a, b)
        local af = IsFriend(a) and 1 or 0
        local bf = IsFriend(b) and 1 or 0
        if af ~= bf then return af > bf end
        return string.lower(a.DisplayName) < string.lower(b.DisplayName)
    end)
    return list
end

--=============================================================
-- 🛠️ HELPERS
--=============================================================
local function Corner(i, r)
    local c = Instance.new("UICorner", i)
    c.CornerRadius = UDim.new(0, r or 8); return c
end
local function Stroke(i, col, t, tr)
    local s = Instance.new("UIStroke", i)
    s.Color = col or C.Stroke; s.Thickness = t or 1; s.Transparency = tr or 0; return s
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

local function ColorEq(a, b, tol)
    tol = tol or 0.005
    return math.abs(a.R-b.R) < tol and math.abs(a.G-b.G) < tol and math.abs(a.B-b.B) < tol
end

--=============================================================
-- 🔔 NOTIFICAÇÕES
--=============================================================
local NF = Instance.new("Frame", ScreenGui)
NF.Size = UDim2.new(0, 280, 0, 100)
NF.Position = UDim2.new(0.5, -140, 0.03, 0)
NF.BackgroundTransparency = 1; NF.ZIndex = 500
local NFL = Instance.new("UIListLayout", NF)
NFL.SortOrder = Enum.SortOrder.LayoutOrder
NFL.Padding = UDim.new(0, 5)
NFL.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function Notify(txt, ok)
    local col = ok and C.Green or C.Red
    local n = Instance.new("TextLabel", NF)
    n.Size = UDim2.new(1, 0, 0, 30)
    n.BackgroundColor3 = C.BgAlt
    n.TextColor3 = col; n.Text = txt
    n.Font = C.FontB; n.TextSize = 11
    n.BackgroundTransparency = 0.1; n.ZIndex = 501
    Corner(n, 8)
    local st = Stroke(n, col, 1.5, 0)
    n.Position = UDim2.new(0, 0, 0, -50)
    TweenService:Create(n, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()
    PS("Notify")
    task.delay(2, function()
        local t1 = TweenService:Create(n, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1, Position = UDim2.new(0, 0, 0, -30)})
        local t2 = TweenService:Create(st, TweenInfo.new(0.3), {Transparency = 1})
        t1:Play(); t2:Play()
        t1.Completed:Connect(function() n:Destroy() end)
    end)
end

--=============================================================
-- 🎨 APLICADORES
--=============================================================
local LastBgApplied, LastBgAltApplied, LastAccent, LastAccentDk
local MainScaleRef, LogoGradientRef, FloatStroke

local function ApplyBackground()
    local newBg = Color3.fromRGB(Personal.BgColor[1], Personal.BgColor[2], Personal.BgColor[3])
    local newBgAlt = newBg:Lerp(Color3.new(1,1,1), 0.055)
    local transp = Personal.BgOpacity
    for _, obj in pairs(ScreenGui:GetDescendants()) do
        if obj:IsA("Frame") or obj:IsA("TextButton") then
            local attr = obj:GetAttribute("KikoBg")
            if attr == "main" then
                obj.BackgroundColor3 = newBg; obj.BackgroundTransparency = transp
            elseif attr == "alt" then
                obj.BackgroundColor3 = newBgAlt
                obj.BackgroundTransparency = math.min(transp + 0.08, 1)
            end
        end
    end
    LastBgApplied = newBg; LastBgAltApplied = newBgAlt
end

local function ApplyAccent()
    local newAccent = Color3.fromRGB(Personal.AccentColor[1], Personal.AccentColor[2], Personal.AccentColor[3])
    local newAccentDk = newAccent:Lerp(Color3.new(0,0,0), 0.4)
    local oldAccent = LastAccent or C.Accent
    local oldAccentDk = LastAccentDk or C.AccentDk
    local function shouldSkip(obj)
        local p = obj
        while p and p ~= ScreenGui do
            if p:GetAttribute("KikoNoAccent") then return true end
            p = p.Parent
        end
        return false
    end
    for _, obj in pairs(ScreenGui:GetDescendants()) do
        if not shouldSkip(obj) then
            if obj:IsA("UIStroke") then
                if ColorEq(obj.Color, oldAccent) then obj.Color = newAccent
                elseif ColorEq(obj.Color, oldAccentDk) then obj.Color = newAccentDk end
            elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
                if ColorEq(obj.TextColor3, oldAccent) then obj.TextColor3 = newAccent end
            elseif obj:IsA("Frame") then
                if ColorEq(obj.BackgroundColor3, oldAccent) then obj.BackgroundColor3 = newAccent
                elseif ColorEq(obj.BackgroundColor3, oldAccentDk) then obj.BackgroundColor3 = newAccentDk end
            end
        end
    end
    C.Accent = newAccent; C.AccentDk = newAccentDk
    FOVCircle.Color = newAccent
    if FloatStroke then FloatStroke.Color = newAccent end
    if LogoGradientRef then
        LogoGradientRef.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, newAccent),
            ColorSequenceKeypoint.new(0.45, newAccent),
            ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(0.55, newAccent),
            ColorSequenceKeypoint.new(1, newAccent),
        })
    end
    LastAccent = newAccent; LastAccentDk = newAccentDk
end

local function ApplyScale()
    if MainScaleRef then MainScaleRef.Scale = Personal.UIScale end
end

--=============================================================
-- ⚡ PERFORMANCE (blindado com pcall)
--=============================================================
local function SetTextures(enabled)
    pcall(function()
        for _, o in pairs(game:GetDescendants()) do
            if o:IsA("Texture") then
                o.Transparency = enabled and 1 or 0
            end
        end
    end)
end

local function SetDecals(enabled)
    pcall(function()
        for _, o in pairs(game:GetDescendants()) do
            if o:IsA("Decal") then
                if enabled then
                    if not o:GetAttribute("KikoOrigTrans") then
                        o:SetAttribute("KikoOrigTrans", o.Transparency)
                    end
                    o.Transparency = 1
                else
                    local orig = o:GetAttribute("KikoOrigTrans")
                    if orig then o.Transparency = orig end
                end
            end
        end
    end)
end

local function SetShadows(enabled)
    pcall(function()
        Lighting.GlobalShadows = not enabled
    end)
end

local function SetParticles(enabled)
    pcall(function()
        for _, o in pairs(game:GetDescendants()) do
            if o:IsA("ParticleEmitter") or o:IsA("Smoke") or o:IsA("Fire")
            or o:IsA("Sparkles") then
                o.Enabled = not enabled
            end
        end
    end)
end

local function SetTrails(enabled)
    pcall(function()
        for _, o in pairs(game:GetDescendants()) do
            if o:IsA("Trail") or o:IsA("Beam") then
                o.Enabled = not enabled
            end
        end
    end)
end

local function SetPostFX(enabled)
    pcall(function()
        local types = {
            "BloomEffect", "BlurEffect", "SunRaysEffect",
            "DepthOfFieldEffect", "ColorCorrectionEffect"
        }
        for _, o in pairs(Lighting:GetChildren()) do
            for _, t in ipairs(types) do
                if o:IsA(t) then
                    if enabled then
                        if originalEffects[o] == nil then
                            originalEffects[o] = o.Enabled
                        end
                        o.Enabled = false
                    else
                        if originalEffects[o] ~= nil then
                            o.Enabled = originalEffects[o]
                        end
                    end
                end
            end
        end
        for _, o in pairs(Lighting:GetChildren()) do
            if o:IsA("Atmosphere") then
                if enabled then
                    if originalEffects[o] == nil then
                        originalEffects[o] = o.Density
                    end
                    o.Density = 0
                else
                    if originalEffects[o] ~= nil then
                        o.Density = originalEffects[o]
                    end
                end
            end
        end
    end)
end

local function SetAnimations(enabled)
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local animate = char:FindFirstChild("Animate")
        if animate then
            for _, o in pairs(animate:GetDescendants()) do
                if o:IsA("LocalScript") then
                    o.Disabled = enabled
                end
            end
        end
    end)
end

local function SetGameSounds(enabled)
    pcall(function()
        for _, o in pairs(SoundService:GetDescendants()) do
            if o:IsA("Sound") and not Sounds[o.Name] then
                if enabled then
                    if not o:GetAttribute("KikoOrigVol") then
                        o:SetAttribute("KikoOrigVol", o.Volume)
                    end
                    o.Volume = 0
                else
                    local orig = o:GetAttribute("KikoOrigVol")
                    if orig then o.Volume = orig end
                end
            end
        end
    end)
end

print("[Kiko] Funções de performance carregadas")

--=============================================================
-- 🖱️ DRAG
--=============================================================
local function MakeDraggable(g, onClickNoDrag, moveTarget)
    moveTarget = moveTarget or g
    local drag, dIn, dS, sP, moved
    g.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            drag = true; moved = false; dIn = nil
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
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then dIn = input end
    end)
    RunService.RenderStepped:Connect(function()
        if drag and dIn then
            local d = dIn.Position - dS
            if math.abs(d.X) > 5 or math.abs(d.Y) > 5 then moved = true end
            moveTarget.Position = UDim2.new(sP.X.Scale, sP.X.Offset + d.X, sP.Y.Scale, sP.Y.Offset + d.Y)
        end
    end)
end

--=============================================================
-- 🎈 BOTÃO FLUTUANTE
--=============================================================
local Float = Instance.new("Frame")
Float.Name = "KikoFloat"
Float.Size = UDim2.new(0, 52, 0, 52)
Float.Position = UDim2.new(1, -75, 0, 80)
Float.BackgroundColor3 = C.Bg
Float.ZIndex = 50
Float.Parent = ScreenGui
Corner(Float, 26)
FloatStroke = Stroke(Float, C.Accent, 2, 0.2)

local FloatIcon = Instance.new("ImageLabel", Float)
FloatIcon.Size = UDim2.new(1, -4, 1, -4)
FloatIcon.Position = UDim2.new(0, 2, 0, 2)
FloatIcon.BackgroundTransparency = 1
FloatIcon.Image = "rbxassetid://70505361093133"
FloatIcon.ScaleType = Enum.ScaleType.Crop
FloatIcon.ZIndex = 52
Corner(FloatIcon, 24)

local FloatBtn = Instance.new("TextButton", Float)
FloatBtn.Size = UDim2.new(1, 0, 1, 0)
FloatBtn.BackgroundTransparency = 1
FloatBtn.Text = ""
FloatBtn.ZIndex = 51
FloatBtn.AutoButtonColor = false

--=============================================================
-- 🪟 JANELA PRINCIPAL
--=============================================================
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, DIM.W, 0, DIM.H)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = C.Bg
Main.Visible = false; Main.ClipsDescendants = true
Main.ZIndex = 100; Main.Parent = ScreenGui
Main:SetAttribute("KikoBg", "main")
Corner(Main, 14)
Stroke(Main, C.Stroke, 1, 0.2)

MainScaleRef = Instance.new("UIScale", Main)
MainScaleRef.Scale = Personal.UIScale

--=============================================================
-- TOP BAR
--=============================================================
local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1, 0, 0, DIM.TopBar)
TopBar.BackgroundColor3 = C.BgAlt
TopBar.ZIndex = 101; TopBar.BorderSizePixel = 0
TopBar:SetAttribute("KikoBg", "alt")
Corner(TopBar, 14)
local topFix = Instance.new("Frame", TopBar)
topFix.Size = UDim2.new(1, 0, 0, 15)
topFix.Position = UDim2.new(0, 0, 1, -15)
topFix.BackgroundColor3 = C.BgAlt
topFix.BorderSizePixel = 0
topFix.ZIndex = 101
topFix:SetAttribute("KikoBg", "alt")

local Logo = Instance.new("TextLabel", TopBar)
Logo.Size = UDim2.new(1, -200, 1, 0)
Logo.Position = UDim2.new(0, 16, 0, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "🎯  KIKO MENU"
Logo.TextColor3 = C.Accent
Logo.TextSize = 16; Logo.Font = C.FontB
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.ZIndex = 102

LogoGradientRef = Instance.new("UIGradient", Logo)
LogoGradientRef.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.Accent),
    ColorSequenceKeypoint.new(0.45, C.Accent),
    ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
    ColorSequenceKeypoint.new(0.55, C.Accent),
    ColorSequenceKeypoint.new(1, C.Accent),
})
LogoGradientRef.Rotation = 0
LogoGradientRef.Offset = Vector2.new(-1, 0)

task.spawn(function()
    while Logo.Parent do
        local t = (tick() % 3.5) / 3.5
        LogoGradientRef.Offset = Vector2.new(-1 + t * 2.5, 0)
        RunService.RenderStepped:Wait()
    end
end)

local SearchIcon = Instance.new("TextButton", TopBar)
SearchIcon.Size = UDim2.new(0, 26, 0, 26)
SearchIcon.Position = UDim2.new(1, -134, 0.5, -13)
SearchIcon.BackgroundColor3 = C.Bg
SearchIcon.BackgroundTransparency = 0.4
SearchIcon.Text = "🔍"
SearchIcon.TextColor3 = C.Text
SearchIcon.TextSize = 13
SearchIcon.Font = C.FontB
SearchIcon.AutoButtonColor = false
SearchIcon.ZIndex = 105
Corner(SearchIcon, 6)
Stroke(SearchIcon, C.Stroke, 1, 0.6)

local VersionBox = Instance.new("Frame", TopBar)
VersionBox.Size = UDim2.new(0, 52, 0, 20)
VersionBox.Position = UDim2.new(1, -98, 0.5, -10)
VersionBox.BackgroundColor3 = C.Bg
VersionBox.BackgroundTransparency = 0.4
VersionBox.ZIndex = 102
VersionBox:SetAttribute("KikoBg", "main")
Corner(VersionBox, 10)
Stroke(VersionBox, C.Accent, 1, 0.4)

local VersionLbl = Instance.new("TextLabel", VersionBox)
VersionLbl.Size = UDim2.new(1, 0, 1, 0)
VersionLbl.BackgroundTransparency = 1
VersionLbl.Text = VERSION
VersionLbl.TextColor3 = C.Accent
VersionLbl.TextSize = 9
VersionLbl.Font = C.FontB
VersionLbl.TextXAlignment = Enum.TextXAlignment.Center
VersionLbl.ZIndex = 103

local CloseB = Instance.new("TextButton", TopBar)
CloseB.Size = UDim2.new(0, 26, 0, 26)
CloseB.Position = UDim2.new(1, -36, 0.5, -13)
CloseB.BackgroundColor3 = C.BgHover
CloseB.Text = "X"; CloseB.TextColor3 = C.Text
CloseB.TextSize = 14; CloseB.Font = Enum.Font.GothamBold
CloseB.AutoButtonColor = false; CloseB.ZIndex = 105
Corner(CloseB, 6)

CloseB.MouseEnter:Connect(function() 
    TweenService:Create(CloseB, TweenInfo.new(0.15), {BackgroundColor3 = C.Accent, TextColor3 = Color3.new(1,1,1)}):Play() 
end)
CloseB.MouseLeave:Connect(function() 
    TweenService:Create(CloseB, TweenInfo.new(0.15), {BackgroundColor3 = C.BgHover, TextColor3 = C.Text}):Play() 
end)

MakeDraggable(TopBar, nil, Main)

--=============================================================
-- SEARCH BAR
--=============================================================
local SearchBar = Instance.new("Frame", Main)
SearchBar.Size = UDim2.new(1, -DIM.Pad*2, 0, 0)
SearchBar.Position = UDim2.new(0, DIM.Pad, 0, DIM.TopBar + 6)
SearchBar.BackgroundColor3 = C.BgAlt
SearchBar.BackgroundTransparency = 1
SearchBar.ClipsDescendants = true
SearchBar.ZIndex = 150
SearchBar:SetAttribute("KikoBg", "alt")
Corner(SearchBar, 8)
Stroke(SearchBar, C.Accent, 1.5, 0.4)

local SearchInput = Instance.new("TextBox", SearchBar)
SearchInput.Size = UDim2.new(1, -70, 1, 0)
SearchInput.Position = UDim2.new(0, 14, 0, 0)
SearchInput.BackgroundTransparency = 1
SearchInput.Text = ""
SearchInput.PlaceholderText = "🔍  Buscar função..."
SearchInput.PlaceholderColor3 = C.Dim
SearchInput.TextColor3 = C.Text
SearchInput.TextSize = 12
SearchInput.Font = C.Font
SearchInput.TextXAlignment = Enum.TextXAlignment.Left
SearchInput.ClearTextOnFocus = false
SearchInput.ZIndex = 152

local SearchClear = Instance.new("TextButton", SearchBar)
SearchClear.Size = UDim2.new(0, 24, 0, 24)
SearchClear.Position = UDim2.new(1, -34, 0.5, -12)
SearchClear.BackgroundColor3 = C.BgHover
SearchClear.Text = "×"
SearchClear.TextColor3 = C.Text
SearchClear.TextSize = 14
SearchClear.Font = C.FontB
SearchClear.AutoButtonColor = false
SearchClear.ZIndex = 152
Corner(SearchClear, 6)

local SearchOpen = false

local function CloseSearch()
    SearchOpen = false
    TweenService:Create(SearchBar, TweenInfo.new(0.2), {
        Size = UDim2.new(1, -DIM.Pad*2, 0, 0), BackgroundTransparency = 1
    }):Play()
    SearchInput.Text = ""
    for _, obj in pairs(Content:GetDescendants()) do
        if obj:GetAttribute("KikoSearchable") then obj.Visible = true end
    end
end

local function OpenSearch()
    SearchOpen = true
    TweenService:Create(SearchBar, TweenInfo.new(0.25), {
        Size = UDim2.new(1, -DIM.Pad*2, 0, 36), BackgroundTransparency = 0
    }):Play()
    task.wait(0.15)
    SearchInput:CaptureFocus()
end

SearchIcon.MouseButton1Click:Connect(function()
    PS("Click")
    if SearchOpen then CloseSearch() else OpenSearch() end
end)
SearchClear.MouseButton1Click:Connect(function()
    PS("Click")
    SearchInput.Text = ""
    CloseSearch()
end)

--=============================================================
-- PROFILE BAR
--=============================================================
local ProfileBar = Instance.new("Frame", Main)
ProfileBar.Size = UDim2.new(1, -DIM.Pad*2, 0, DIM.ProfileBar)
ProfileBar.Position = UDim2.new(0, DIM.Pad, 0, DIM.TopBar + 8)
ProfileBar.BackgroundColor3 = C.BgAlt
ProfileBar.ZIndex = 101
ProfileBar:SetAttribute("KikoBg", "alt")
Corner(ProfileBar, 10)
Stroke(ProfileBar, C.Stroke, 1, 0.7)

local AvatarFrame = Instance.new("Frame", ProfileBar)
AvatarFrame.Size = UDim2.new(0, 58, 0, 58)
AvatarFrame.Position = UDim2.new(0, 12, 0.5, -29)
AvatarFrame.BackgroundColor3 = C.Bg
AvatarFrame.ZIndex = 102
AvatarFrame:SetAttribute("KikoBg", "main")
Corner(AvatarFrame, 29)
Stroke(AvatarFrame, C.Accent, 1.5, 0.2)

local AvatarImg = Instance.new("ImageLabel", AvatarFrame)
AvatarImg.Size = UDim2.new(1, -6, 1, -6)
AvatarImg.Position = UDim2.new(0, 3, 0, 3)
AvatarImg.BackgroundTransparency = 1
AvatarImg.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"
AvatarImg.ZIndex = 103
Corner(AvatarImg, 26)

local NameLabel = Instance.new("TextLabel", ProfileBar)
NameLabel.Text = string.upper(LocalPlayer.DisplayName)
NameLabel.Font = C.FontB
NameLabel.TextSize = 13
NameLabel.TextColor3 = C.Text
NameLabel.BackgroundTransparency = 1
NameLabel.Size = UDim2.new(1, -90, 0, 18)
NameLabel.Position = UDim2.new(0, 80, 0, 12)
NameLabel.TextXAlignment = Enum.TextXAlignment.Left
NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
NameLabel.ZIndex = 103

local StatsLbl = Instance.new("TextLabel", ProfileBar)
StatsLbl.Size = UDim2.new(1, -90, 0, 16)
StatsLbl.Position = UDim2.new(0, 80, 0, 34)
StatsLbl.BackgroundTransparency = 1
StatsLbl.Text = "FPS: 60   •   PING: 0ms   •   00:00:00"
StatsLbl.TextColor3 = C.Green
StatsLbl.TextSize = 10
StatsLbl.Font = C.FontB
StatsLbl.TextXAlignment = Enum.TextXAlignment.Left
StatsLbl.ZIndex = 103

local SubLbl = Instance.new("TextLabel", ProfileBar)
SubLbl.Size = UDim2.new(1, -90, 0, 14)
SubLbl.Position = UDim2.new(0, 80, 0, 54)
SubLbl.BackgroundTransparency = 1
SubLbl.Text = "⭐ Bem-vindo de volta, " .. LocalPlayer.DisplayName
SubLbl.TextColor3 = C.Dim
SubLbl.TextSize = 9
SubLbl.Font = C.Font
SubLbl.TextXAlignment = Enum.TextXAlignment.Left
SubLbl.ZIndex = 103

--=============================================================
-- TABS BAR
--=============================================================
local TabsBar = Instance.new("Frame", Main)
TabsBar.Size = UDim2.new(1, -DIM.Pad*2, 0, DIM.TabsBar)
TabsBar.Position = UDim2.new(0, DIM.Pad, 0, DIM.TopBar + DIM.ProfileBar + 16)
TabsBar.BackgroundColor3 = C.BgAlt
TabsBar.ZIndex = 101
TabsBar:SetAttribute("KikoBg", "alt")
Corner(TabsBar, 10)

local TabIndicator = Instance.new("Frame", TabsBar)
TabIndicator.Size = UDim2.new(0, 70, 0, 3)
TabIndicator.Position = UDim2.new(0, 8, 1, -5)
TabIndicator.BackgroundColor3 = C.Accent
TabIndicator.BorderSizePixel = 0
TabIndicator.ZIndex = 105
Corner(TabIndicator, 2)

local TabsScroll = Instance.new("ScrollingFrame", TabsBar)
TabsScroll.Size = UDim2.new(1, 0, 1, 0)
TabsScroll.BackgroundTransparency = 1
TabsScroll.BorderSizePixel = 0
TabsScroll.ScrollBarThickness = 0
TabsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TabsScroll.ScrollingDirection = Enum.ScrollingDirection.X
TabsScroll.ZIndex = 102

local TabsLayout = Instance.new("UIListLayout", TabsScroll)
TabsLayout.FillDirection = Enum.FillDirection.Horizontal
TabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabsLayout.Padding = UDim.new(0, 6)
local tabsPad = Instance.new("UIPadding", TabsScroll)
tabsPad.PaddingLeft = UDim.new(0, 8); tabsPad.PaddingRight = UDim.new(0, 8)

TabsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabsScroll.CanvasSize = UDim2.new(0, TabsLayout.AbsoluteContentSize.X + 20, 0, 0)
end)

--=============================================================
-- ÁREA DE CONTEÚDO
--=============================================================
local ContentTop = DIM.TopBar + DIM.ProfileBar + DIM.TabsBar + 24
local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -DIM.Pad*2, 1, -(ContentTop + 10))
Content.Position = UDim2.new(0, DIM.Pad, 0, ContentTop)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = C.Accent
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.ScrollingDirection = Enum.ScrollingDirection.Y
Content.ZIndex = 101

local ContentLayout = Instance.new("UIListLayout", Content)
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

--=============================================================
-- 📑 PÁGINAS
--=============================================================
local Pages, TabButtons = {}, {}
local ActivePage = nil
local PageSelect = {}

local function UpdateTabIndicator(btn)
    local btnX = btn.AbsolutePosition.X - TabsScroll.AbsolutePosition.X + TabsScroll.CanvasPosition.X
    local btnW = btn.AbsoluteSize.X
    TweenService:Create(TabIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, btnX, 1, -5),
        Size = UDim2.new(0, btnW, 0, 3)
    }):Play()
end

local function CreatePage(name, emoji)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 0, 30)
    btn.BackgroundColor3 = C.Bg
    btn.BackgroundTransparency = 0.4
    btn.Text = emoji .. "  " .. name
    btn.TextColor3 = C.Dim
    btn.TextSize = 11; btn.Font = C.FontB
    btn.AutoButtonColor = false; btn.ZIndex = 103
    btn.Parent = TabsScroll
    btn:SetAttribute("KikoBg", "main")
    Corner(btn, 8)

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 0, 0)
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.BackgroundTransparency = 1
    page.Visible = false; page.ZIndex = 102
    page.Parent = Content
    page:SetAttribute("LastScroll", 0)
    page:SetAttribute("KikoIsPage", true)
    local pl = Instance.new("UIListLayout", page)
    pl.Padding = UDim.new(0, 8)
    pl.SortOrder = Enum.SortOrder.LayoutOrder

    local function selectTab()
        PS("Click")
        if ActivePage and ActivePage ~= page then
            ActivePage:SetAttribute("LastScroll", Content.CanvasPosition.Y)
        end
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in pairs(TabButtons) do
            b:SetAttribute("KikoBg", "main")
            b.BackgroundColor3 = LastBgApplied or C.Bg
            b.BackgroundTransparency = 0.4
            b.TextColor3 = C.Dim
        end
        page.Visible = true; ActivePage = page
        btn:SetAttribute("KikoBg", "")
        btn.BackgroundColor3 = C.Accent
        btn.BackgroundTransparency = 0
        btn.TextColor3 = Color3.new(1,1,1)
        UpdateTabIndicator(btn)
        task.wait()
        Content.CanvasSize = UDim2.new(0, 0, 0, page.AbsoluteSize.Y + 20)
        local saved = page:GetAttribute("LastScroll") or 0
        Content.CanvasPosition = Vector2.new(0, saved)
    end

    btn.MouseButton1Click:Connect(selectTab)
    PageSelect[page] = selectTab

    btn.MouseEnter:Connect(function()
        if ActivePage ~= page then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = C.BgHover, BackgroundTransparency = 0}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if ActivePage ~= page then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = LastBgApplied or C.Bg, BackgroundTransparency = 0.4}):Play()
        end
    end)

    table.insert(Pages, page); table.insert(TabButtons, btn)
    return page, btn
end

--=============================================================
-- 🏷️ TÍTULOS
--=============================================================
local function CreateTitle(parent, title, emoji)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 28)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 103
    frame.Parent = parent

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = (emoji and emoji .. "  " or "") .. title
    lbl.TextColor3 = C.Accent
    lbl.TextSize = 12
    lbl.Font = C.FontTitle
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Bottom
    lbl.ZIndex = 104

    local line = Instance.new("Frame", frame)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -3)
    line.BackgroundColor3 = C.Stroke
    line.BackgroundTransparency = 0.3
    line.BorderSizePixel = 0
    line.ZIndex = 104
    return frame
end

--=============================================================
-- 🔘 COMPONENTES
--=============================================================
local VisToggles = {}
local VisSteppers = {}

local function CreateToggle(parent, text, default, callback)
    local state = default or false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = C.BgAlt
    btn.Text = ""; btn.AutoButtonColor = false
    btn.ZIndex = 103; btn.Parent = parent
    btn:SetAttribute("KikoBg", "alt")
    btn:SetAttribute("KikoSearchable", true)
    btn:SetAttribute("KikoSearchText", string.lower(text))
    Corner(btn, 8)
    Stroke(btn, C.Stroke, 1, 0.7)

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text; lbl.TextColor3 = C.Text
    lbl.TextSize = 11; lbl.Font = C.FontB
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 104

    local pill = Instance.new("Frame", btn)
    pill.Size = UDim2.new(0, 38, 0, 18)
    pill.Position = UDim2.new(1, -50, 0.5, -9)
    pill.BackgroundColor3 = state and C.Accent or C.BgHover
    pill.BorderSizePixel = 0; pill.ZIndex = 104
    Corner(pill, 9)

    local ball = Instance.new("Frame", pill)
    ball.Size = UDim2.new(0, 14, 0, 14)
    ball.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    ball.BackgroundColor3 = Color3.new(1,1,1)
    ball.BorderSizePixel = 0; ball.ZIndex = 105
    Corner(ball, 9)

    local function apply(v, noCb, noSound)
        state = v
        if not noSound then PS("Toggle") end
        TweenService:Create(pill, TweenInfo.new(0.2), {BackgroundColor3 = state and C.Accent or C.BgHover}):Play()
        TweenService:Create(ball, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        }):Play()
        if not noCb and callback then callback(state) end
    end

    VisToggles[text] = apply
    btn.MouseButton1Click:Connect(function() apply(not state) end)
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = C.BgHover}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = LastBgAltApplied or C.BgAlt}):Play() end)

    return btn, apply
end

local function CreateToggleWithConfig(parent, text, default, callback)
    local state = default or false
    local wrapper = Instance.new("Frame", parent)
    wrapper.Size = UDim2.new(1, 0, 0, 38)
    wrapper.AutomaticSize = Enum.AutomaticSize.Y
    wrapper.BackgroundTransparency = 1
    wrapper.ZIndex = 103
    local wrapperLayout = Instance.new("UIListLayout", wrapper)
    wrapperLayout.SortOrder = Enum.SortOrder.LayoutOrder
    wrapperLayout.Padding = UDim.new(0, 6)

    local btn = Instance.new("TextButton", wrapper)
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = C.BgAlt
    btn.Text = ""; btn.AutoButtonColor = false
    btn.ZIndex = 104; btn.LayoutOrder = 1
    btn:SetAttribute("KikoBg", "alt")
    btn:SetAttribute("KikoSearchable", true)
    btn:SetAttribute("KikoSearchText", string.lower(text))
    Corner(btn, 8)
    Stroke(btn, C.Stroke, 1, 0.7)

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, -100, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text; lbl.TextColor3 = C.Text
    lbl.TextSize = 11; lbl.Font = C.FontB
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 105

    local arrow = Instance.new("TextLabel", btn)
    arrow.Size = UDim2.new(0, 14, 0, 14)
    arrow.Position = UDim2.new(1, -70, 0.5, -7)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"; arrow.TextColor3 = C.Dim
    arrow.TextSize = 10; arrow.Font = C.FontB
    arrow.ZIndex = 105

    local pill = Instance.new("Frame", btn)
    pill.Size = UDim2.new(0, 38, 0, 18)
    pill.Position = UDim2.new(1, -50, 0.5, -9)
    pill.BackgroundColor3 = state and C.Accent or C.BgHover
    pill.BorderSizePixel = 0; pill.ZIndex = 105
    Corner(pill, 9)

    local ball = Instance.new("Frame", pill)
    ball.Size = UDim2.new(0, 14, 0, 14)
    ball.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    ball.BackgroundColor3 = Color3.new(1,1,1)
    ball.BorderSizePixel = 0; ball.ZIndex = 106
    Corner(ball, 9)

    local config = Instance.new("Frame", wrapper)
    config.Size = UDim2.new(1, 0, 0, 0)
    config.AutomaticSize = Enum.AutomaticSize.Y
    config.BackgroundColor3 = C.Bg
    config.BackgroundTransparency = 0.3
    config.Visible = state
    config.ZIndex = 103
    config.LayoutOrder = 2
    config:SetAttribute("KikoBg", "main")
    Corner(config, 8)
    Stroke(config, C.Stroke, 1, 0.6)
    local configLayout = Instance.new("UIListLayout", config)
    configLayout.Padding = UDim.new(0, 6)
    configLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local configPad = Instance.new("UIPadding", config)
    configPad.PaddingTop = UDim.new(0, 8)
    configPad.PaddingBottom = UDim.new(0, 8)
    configPad.PaddingLeft = UDim.new(0, 8)
    configPad.PaddingRight = UDim.new(0, 8)

    local function apply(v, noCb, noSound)
        state = v
        if not noSound then PS("Toggle") end
        TweenService:Create(pill, TweenInfo.new(0.2), {BackgroundColor3 = state and C.Accent or C.BgHover}):Play()
        TweenService:Create(ball, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        }):Play()
        config.Visible = state
        arrow.TextColor3 = state and C.Accent or C.Dim
        if not noCb and callback then callback(state) end
    end

    VisToggles[text] = apply
    btn.MouseButton1Click:Connect(function() apply(not state) end)
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = C.BgHover}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = LastBgAltApplied or C.BgAlt}):Play() end)

    return config, apply, wrapper, btn
end

local function CreateStepper(parent, text, min, max, default, step, callback)
    local val = default or min
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundColor3 = C.BgAlt
    frame.ZIndex = 103; frame.Parent = parent
    frame:SetAttribute("KikoBg", "alt")
    frame:SetAttribute("KikoSearchable", true)
    frame:SetAttribute("KikoSearchText", string.lower(text))
    Corner(frame, 8)
    Stroke(frame, C.Stroke, 1, 0.7)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -150, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text; lbl.TextColor3 = C.Text
    lbl.TextSize = 11; lbl.Font = C.FontB
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 104

    local vl = Instance.new("TextLabel", frame)
    vl.Size = UDim2.new(0, 46, 1, 0)
    vl.Position = UDim2.new(1, -114, 0, 0)
    vl.BackgroundTransparency = 1
    vl.Text = tostring(val); vl.TextColor3 = C.Accent
    vl.TextSize = 11; vl.Font = C.FontB
    vl.ZIndex = 104

    local minus = Instance.new("TextButton", frame)
    minus.Size = UDim2.new(0, 26, 0, 26)
    minus.Position = UDim2.new(1, -62, 0.5, -13)
    minus.BackgroundColor3 = C.BgHover
    minus.Text = "−"; minus.TextColor3 = C.Text; minus.TextSize = 15
    minus.Font = C.FontB; minus.AutoButtonColor = false
    minus.ZIndex = 104; Corner(minus, 8)

    local plus = Instance.new("TextButton", frame)
    plus.Size = UDim2.new(0, 26, 0, 26)
    plus.Position = UDim2.new(1, -32, 0.5, -13)
    plus.BackgroundColor3 = C.BgHover
    plus.Text = "+"; plus.TextColor3 = C.Text; plus.TextSize = 15
    plus.Font = C.FontB; plus.AutoButtonColor = false
    plus.ZIndex = 104; Corner(plus, 8)

    local function update(n, noCb)
        val = math.clamp(n, min, max)
        if val % 1 == 0 then vl.Text = tostring(math.floor(val))
        else vl.Text = string.format("%.2f", val) end
        if not noCb and callback then callback(val) end
    end

    VisSteppers[text] = update
    minus.MouseButton1Click:Connect(function() PS("Click"); update(val - step) end)
    plus.MouseButton1Click:Connect(function() PS("Click"); update(val + step) end)

    return frame, update
end

local function CreateButton(parent, text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = color or C.Accent
    btn.Text = text; btn.TextColor3 = Color3.new(1,1,1); btn.TextSize = 11
    btn.Font = C.FontB; btn.AutoButtonColor = false
    btn.ZIndex = 103; btn.Parent = parent
    btn:SetAttribute("KikoSearchable", true)
    btn:SetAttribute("KikoSearchText", string.lower(text))
    Corner(btn, 8)
    Stroke(btn, (color or C.Accent):Lerp(Color3.new(1,1,1), 0.2), 1, 0.5)

    local orig = color or C.Accent
    btn.MouseButton1Click:Connect(function() PS("Click"); if callback then callback() end end)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = orig:Lerp(Color3.new(1,1,1), 0.2)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = orig}):Play()
    end)
    return btn
end

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
-- 🔍 SEARCH HANDLER
--=============================================================
local function FindParentPage(obj)
    local p = obj
    while p and p ~= Content do
        if p:GetAttribute("KikoIsPage") then return p end
        p = p.Parent
    end
    return nil
end

local lastHighlighted = nil

SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
    local q = string.lower(SearchInput.Text)
    if lastHighlighted and lastHighlighted.Parent then
        local prevSt = lastHighlighted:FindFirstChildOfClass("UIStroke")
        if prevSt then prevSt.Color = C.Stroke; prevSt.Thickness = 1 end
    end
    lastHighlighted = nil

    if q == "" then
        for _, obj in pairs(Content:GetDescendants()) do
            if obj:GetAttribute("KikoSearchable") then obj.Visible = true end
        end
        return
    end

    local matches = {}
    for _, obj in pairs(Content:GetDescendants()) do
        if obj:GetAttribute("KikoSearchable") then
            local st = obj:GetAttribute("KikoSearchText") or ""
            local matched = string.find(st, q, 1, true) ~= nil
            obj.Visible = matched
            if matched then table.insert(matches, obj) end
        end
    end

    if #matches > 0 then
        local first = matches[1]
        local page = FindParentPage(first)
        if page and PageSelect[page] then PageSelect[page]() end
        task.defer(function()
            task.wait(0.15)
            if first and first.Parent then
                local y = first.AbsolutePosition.Y - Content.AbsolutePosition.Y + Content.CanvasPosition.Y
                TweenService:Create(Content, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    CanvasPosition = Vector2.new(0, math.max(0, y - 100))
                }):Play()
                local st = first:FindFirstChildOfClass("UIStroke")
                if st then
                    st.Color = C.Accent; st.Thickness = 3
                    lastHighlighted = first
                    task.spawn(function()
                        for i = 1, 3 do
                            task.wait(0.25)
                            if not first.Parent then return end
                            TweenService:Create(st, TweenInfo.new(0.2), {Thickness = 1.5}):Play()
                            task.wait(0.2)
                            if not first.Parent then return end
                            TweenService:Create(st, TweenInfo.new(0.2), {Thickness = 3}):Play()
                        end
                        task.wait(0.5)
                        if first.Parent then
                            TweenService:Create(st, TweenInfo.new(0.4), {Color = C.Stroke, Thickness = 1}):Play()
                        end
                    end)
                end
            end
        end)
    end
end)

--=============================================================
-- 📑 CRIAÇÃO DAS ABAS
--=============================================================
local MiraP     = CreatePage("Mira",         "🎯")
local VisualP   = CreatePage("Visual",       "👁️")
local PersoP    = CreatePage("Personagem",   "🏃")
local TPP       = CreatePage("Teleporte",    "🌀")
local HitP      = CreatePage("Hitbox",       "📦")
local DefP      = CreatePage("Defusal",      "💣")
local WLP       = CreatePage("Whitelist",    "📝")
local PresetP   = CreatePage("Presets",      "⚙️")
local BindsP    = CreatePage("Atalhos",      "⌨️")
local ServP     = CreatePage("Servidor",     "🌐")
local PerfP     = CreatePage("Desempenho",   "⚡")
local MiscP     = CreatePage("Misc",         "🧰")
local TestP     = CreatePage("Teste",        "🧪")
local PersonalP = CreatePage("Personalizar", "🎨")

print("[Kiko] Páginas criadas")

MiraP.Visible = true
ActivePage = MiraP
TabButtons[1]:SetAttribute("KikoBg", "")
TabButtons[1].BackgroundColor3 = C.Accent
TabButtons[1].BackgroundTransparency = 0
TabButtons[1].TextColor3 = Color3.new(1,1,1)

task.defer(function()
    task.wait(0.3)
    UpdateTabIndicator(TabButtons[1])
end)

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
ModeBtn.Size = UDim2.new(1, 0, 0, 38)
ModeBtn.BackgroundColor3 = C.BgAlt
ModeBtn.TextColor3 = C.Text
ModeBtn.Text = "Prioridade: " .. S.PriorityMode
ModeBtn.TextSize = 11; ModeBtn.Font = C.FontB
ModeBtn.AutoButtonColor = false; ModeBtn.ZIndex = 103
ModeBtn:SetAttribute("KikoBg", "alt")
Corner(ModeBtn, 8); Stroke(ModeBtn, C.Stroke, 1, 0.7)
ModeBtn.MouseButton1Click:Connect(function()
    PS("Click")
    local i = table.find(Modes, S.PriorityMode) or 1
    i = i + 1; if i > #Modes then i = 1 end
    S.PriorityMode = Modes[i]
    ModeBtn.Text = "Prioridade: " .. S.PriorityMode
end)

local PartBtn = Instance.new("TextButton", MiraP)
PartBtn.Size = UDim2.new(1, 0, 0, 38)
PartBtn.BackgroundColor3 = C.BgAlt
PartBtn.TextColor3 = C.Text
PartBtn.Text = "Parte Alvo: Cabeça"
PartBtn.TextSize = 11; PartBtn.Font = C.FontB
PartBtn.AutoButtonColor = false; PartBtn.ZIndex = 103
PartBtn:SetAttribute("KikoBg", "alt")
Corner(PartBtn, 8); Stroke(PartBtn, C.Stroke, 1, 0.7)
PartBtn.MouseButton1Click:Connect(function()
    PS("Click")
    S.AimPart = (S.AimPart == "Head" and "HumanoidRootPart" or "Head")
    PartBtn.Text = "Parte Alvo: " .. (S.AimPart == "Head" and "Cabeça" or "Tronco")
end)

CreateTitle(MiraP, "Filtros de Alvo", "🛡️")
CreateToggle(MiraP, "Ignorar Aliados", false, function(v) S.TeamCheck = v end)
CreateToggle(MiraP, "Ignorar Atrás de Paredes", false, function(v) S.WallCheck = v end)
CreateToggle(MiraP, "Mira em NPCs", false, function(v) S.AimNPC = v end)

--=============================================================
-- 👁️ VISUAL
--=============================================================
CreateTitle(VisualP, "ESP - Jogadores", "👁️")
CreateToggle(VisualP, "Ativar ESP", false, function(v) S.ESP = v end)
CreateToggle(VisualP, "Caixas", false, function(v) S.Boxes = v end)
CreateToggle(VisualP, "Nomes", false, function(v) S.Names = v end)
CreateToggle(VisualP, "Distância", false, function(v) S.Distance = v end)
CreateToggle(VisualP, "Linhas", false, function(v) S.Lines = v end)
CreateToggle(VisualP, "Cor do Time", false, function(v) S.TeamColor = v end)
CreateToggle(VisualP, "Destaque (Chams)", false, function(v) S.Highlight = v end)
CreateToggle(VisualP, "Barra de Vida (HP)", false, function(v) S.ESPHP = v end)

CreateTitle(VisualP, "ESP - NPCs", "🤖")
CreateToggle(VisualP, "Ativar ESP em NPCs", false, function(v) S.ESPNPC = v end)

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
CreateStepper(cfgFly, "Multiplicador", 1, 10, 1, 1, function(v) getgenv().speeds = v end)

local upDownFrame = Instance.new("Frame", cfgFly)
upDownFrame.Size = UDim2.new(1, 0, 0, 38)
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

CreateTitle(PersoP, "Câmera", "🎥")
CreateToggle(PersoP, "Terceira Pessoa", false, function(v) S.ForceThirdPerson = v end)

--=============================================================
-- 🌀 TELEPORTE
--=============================================================
CreateTitle(TPP, "Jogadores Online", "👥")

local SelBox = Instance.new("Frame", TPP)
SelBox.Size = UDim2.new(1, 0, 0, 30)
SelBox.BackgroundColor3 = C.BgAlt
SelBox.BackgroundTransparency = 0.2
SelBox.ZIndex = 103
SelBox:SetAttribute("KikoBg", "alt")
Corner(SelBox, 8); Stroke(SelBox, C.Green, 1, 0.5)

local SelLab = Instance.new("TextLabel", SelBox)
SelLab.Size = UDim2.new(1, -20, 1, 0)
SelLab.Position = UDim2.new(0, 10, 0, 0)
SelLab.BackgroundTransparency = 1
SelLab.Text = "🎯 Alvo: Nenhum"
SelLab.TextColor3 = C.Green
SelLab.TextSize = 11; SelLab.Font = C.FontB
SelLab.TextXAlignment = Enum.TextXAlignment.Left
SelLab.ZIndex = 104

local plist = Instance.new("ScrollingFrame", TPP)
plist.Size = UDim2.new(1, 0, 0, 220)
plist.BackgroundColor3 = C.Bg
plist.BackgroundTransparency = 0.3
plist.BorderSizePixel = 0
plist.ScrollBarThickness = 3
plist.ScrollBarImageColor3 = C.Accent
plist.CanvasSize = UDim2.new(0, 0, 0, 0)
plist.ZIndex = 103
plist:SetAttribute("KikoBg", "main")
Corner(plist, 10); Stroke(plist, C.Stroke, 1, 0.5)
local pll = Instance.new("UIListLayout", plist)
pll.Padding = UDim.new(0, 6); pll.SortOrder = Enum.SortOrder.LayoutOrder
local plistPad = Instance.new("UIPadding", plist)
plistPad.PaddingTop = UDim.new(0, 6); plistPad.PaddingBottom = UDim.new(0, 6)
plistPad.PaddingLeft = UDim.new(0, 6); plistPad.PaddingRight = UDim.new(0, 6)
pll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    plist.CanvasSize = UDim2.new(0, 0, 0, pll.AbsoluteContentSize.Y + 14)
end)

local currentSelectedBtn = nil

local function UpList()
    for _, v in pairs(plist:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    currentSelectedBtn = nil
    local sorted = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(sorted, p) end
    end
    SortPlayers(sorted)

    if #sorted == 0 then
        local empty = Instance.new("TextLabel", plist)
        empty.Size = UDim2.new(1, 0, 0, 60)
        empty.BackgroundTransparency = 1
        empty.Text = "Nenhum jogador no servidor"
        empty.TextColor3 = C.Dim; empty.TextSize = 11; empty.Font = C.Font
        empty.ZIndex = 104
        return
    end

    for _, p in ipairs(sorted) do
        local isFr = IsFriend(p)
        local card = Instance.new("TextButton", plist)
        card.Size = UDim2.new(1, -4, 0, 44)
        card.BackgroundColor3 = C.BgAlt
        card.BackgroundTransparency = 0.15
        card.Text = ""; card.AutoButtonColor = false
        card.ZIndex = 104
        card:SetAttribute("KikoBg", "alt")
        Corner(card, 8)
        local cardStroke = Stroke(card, isFr and C.Friend or C.Stroke, 1, 0.6)

        local av = Instance.new("Frame", card)
        av.Size = UDim2.new(0, 32, 0, 32)
        av.Position = UDim2.new(0, 8, 0.5, -16)
        av.BackgroundColor3 = C.Bg
        av.BackgroundTransparency = 0.2
        av.ZIndex = 105
        Corner(av, 16); Stroke(av, isFr and C.Friend or C.Accent, 1.5, 0.4)

        local avImg = Instance.new("ImageLabel", av)
        avImg.Size = UDim2.new(1, -4, 1, -4)
        avImg.Position = UDim2.new(0, 2, 0, 2)
        avImg.BackgroundTransparency = 1
        avImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(p.UserId) .. "&w=100&h=100"
        avImg.ZIndex = 106
        Corner(avImg, 14)

        local dn = Instance.new("TextLabel", card)
        dn.Size = UDim2.new(1, -100, 0, 16)
        dn.Position = UDim2.new(0, 48, 0, 6)
        dn.BackgroundTransparency = 1
        dn.Text = p.DisplayName
        dn.TextColor3 = isFr and Color3.fromRGB(180, 220, 255) or C.Text
        dn.TextSize = 11; dn.Font = C.FontB
        dn.TextXAlignment = Enum.TextXAlignment.Left
        dn.TextTruncate = Enum.TextTruncate.AtEnd
        dn.ZIndex = 105

        local un = Instance.new("TextLabel", card)
        un.Size = UDim2.new(1, -100, 0, 12)
        un.Position = UDim2.new(0, 48, 0, 24)
        un.BackgroundTransparency = 1
        un.Text = "@" .. p.Name
        un.TextColor3 = C.Dim; un.TextSize = 9; un.Font = C.Font
        un.TextXAlignment = Enum.TextXAlignment.Left
        un.TextTruncate = Enum.TextTruncate.AtEnd
        un.ZIndex = 105

        if isFr then
            local frBadge = Instance.new("TextLabel", card)
            frBadge.Size = UDim2.new(0, 22, 0, 22)
            frBadge.Position = UDim2.new(1, -34, 0.5, -11)
            frBadge.BackgroundColor3 = C.Friend
            frBadge.BackgroundTransparency = 0.1
            frBadge.Text = "⭐"; frBadge.TextColor3 = Color3.new(1,1,1)
            frBadge.TextSize = 12; frBadge.Font = C.FontB
            frBadge.ZIndex = 106
            Corner(frBadge, 11)
        end

        card.MouseEnter:Connect(function()
            TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = C.BgHover}):Play()
        end)
        card.MouseLeave:Connect(function()
            if currentSelectedBtn ~= card then
                TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = LastBgAltApplied or C.BgAlt}):Play()
            end
        end)

        card.MouseButton1Click:Connect(function()
            PS("Click")
            S.SelectedPlayer = p
            SelLab.Text = "🎯 Alvo: " .. (isFr and "⭐ " or "") .. p.DisplayName
            if currentSelectedBtn and currentSelectedBtn ~= card then
                local prevStroke = currentSelectedBtn:FindFirstChildOfClass("UIStroke")
                TweenService:Create(currentSelectedBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = LastBgAltApplied or C.BgAlt
                }):Play()
                if prevStroke then
                    TweenService:Create(prevStroke, TweenInfo.new(0.2), {Color = C.Stroke, Transparency = 0.6}):Play()
                end
            end
            currentSelectedBtn = card
            TweenService:Create(card, TweenInfo.new(0.2), {BackgroundColor3 = C.Accent, BackgroundTransparency = 0.1}):Play()
            TweenService:Create(cardStroke, TweenInfo.new(0.2), {Color = C.Accent, Transparency = 0}):Play()
        end)
    end
end
UpList()
Players.PlayerAdded:Connect(function() task.wait(0.5); UpList() end)
Players.PlayerRemoving:Connect(function() task.wait(0.5); UpList() end)
task.delay(4, UpList)

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
-- 📝 WHITELIST
--=============================================================
local wlDesc = Instance.new("TextLabel", WLP)
wlDesc.Size = UDim2.new(1, 0, 0, 46)
wlDesc.BackgroundColor3 = C.BgAlt
wlDesc.BackgroundTransparency = 0.4
wlDesc.Text = "  ℹ️  Jogadores na whitelist NÃO serão afetados por Aimbot, Silent, Hitbox e Auto TP. Clique no card para adicionar/remover."
wlDesc.TextColor3 = C.Dim; wlDesc.TextSize = 10; wlDesc.Font = C.Font
wlDesc.TextWrapped = true
wlDesc.TextXAlignment = Enum.TextXAlignment.Left
wlDesc.TextYAlignment = Enum.TextYAlignment.Center
wlDesc.ZIndex = 103
wlDesc:SetAttribute("KikoBg", "alt")
Corner(wlDesc, 8); Stroke(wlDesc, C.Stroke, 1, 0.5)

local wlCountLabel = Instance.new("TextLabel", WLP)
wlCountLabel.Size = UDim2.new(1, 0, 0, 22)
wlCountLabel.BackgroundTransparency = 1
wlCountLabel.Text = "✓ Salvos: 0 jogadores"
wlCountLabel.TextColor3 = C.Accent
wlCountLabel.TextSize = 12; wlCountLabel.Font = C.FontB
wlCountLabel.TextXAlignment = Enum.TextXAlignment.Left
wlCountLabel.ZIndex = 104

local wlActions = Instance.new("Frame", WLP)
wlActions.Size = UDim2.new(1, 0, 0, 34)
wlActions.BackgroundTransparency = 1
wlActions.ZIndex = 103

local wlRefreshBtn = Instance.new("TextButton", wlActions)
wlRefreshBtn.Size = UDim2.new(0.48, 0, 1, 0)
wlRefreshBtn.BackgroundColor3 = C.Accent
wlRefreshBtn.Text = "🔄 Atualizar"
wlRefreshBtn.TextColor3 = Color3.new(1,1,1)
wlRefreshBtn.TextSize = 11; wlRefreshBtn.Font = C.FontB
wlRefreshBtn.AutoButtonColor = false; wlRefreshBtn.ZIndex = 104
Corner(wlRefreshBtn, 8)

local wlClearBtn = Instance.new("TextButton", wlActions)
wlClearBtn.Size = UDim2.new(0.48, 0, 1, 0)
wlClearBtn.Position = UDim2.new(0.52, 0, 0, 0)
wlClearBtn.BackgroundColor3 = C.AccentDk
wlClearBtn.Text = "🗑 Limpar"
wlClearBtn.TextColor3 = Color3.new(1,1,1)
wlClearBtn.TextSize = 11; wlClearBtn.Font = C.FontB
wlClearBtn.AutoButtonColor = false; wlClearBtn.ZIndex = 104
Corner(wlClearBtn, 8)

local wlScroll = Instance.new("ScrollingFrame", WLP)
wlScroll.Size = UDim2.new(1, 0, 0, 380)
wlScroll.BackgroundColor3 = C.Bg
wlScroll.BackgroundTransparency = 0.3
wlScroll.BorderSizePixel = 0
wlScroll.ScrollBarThickness = 3
wlScroll.ScrollBarImageColor3 = C.Accent
wlScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
wlScroll.ZIndex = 103
wlScroll:SetAttribute("KikoBg", "main")
Corner(wlScroll, 10); Stroke(wlScroll, C.Stroke, 1, 0.5)

local wlLayout = Instance.new("UIListLayout", wlScroll)
wlLayout.Padding = UDim.new(0, 6); wlLayout.SortOrder = Enum.SortOrder.LayoutOrder
local wlPad = Instance.new("UIPadding", wlScroll)
wlPad.PaddingTop = UDim.new(0, 6); wlPad.PaddingBottom = UDim.new(0, 6)
wlPad.PaddingLeft = UDim.new(0, 6); wlPad.PaddingRight = UDim.new(0, 6)
wlLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    wlScroll.CanvasSize = UDim2.new(0, 0, 0, wlLayout.AbsoluteContentSize.Y + 14)
end)

local function UpdateWLCount()
    local count = 0
    for _, v in pairs(S.Whitelist) do if v then count = count + 1 end end
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
        empty.TextColor3 = C.Dim; empty.TextSize = 11; empty.Font = C.Font
        empty.ZIndex = 104
        UpdateWLCount(); return
    end

    for _, p in ipairs(sorted) do
        local isWL = S.Whitelist[p.UserId] and true or false
        local isFr = IsFriend(p)

        local card = Instance.new("TextButton", wlScroll)
        card.Size = UDim2.new(1, -4, 0, 52)
        card.BackgroundColor3 = isWL and Color3.fromRGB(0, 120, 60) or C.BgAlt
        card.BackgroundTransparency = isWL and 0.2 or 0.3
        card.Text = ""; card.AutoButtonColor = false
        card.ZIndex = 104
        card:SetAttribute("KikoBg", isWL and "" or "alt")
        Corner(card, 10)
        Stroke(card, isWL and C.Green or (isFr and C.Friend or C.Stroke), 1.5, isWL and 0.2 or 0.5)

        local af = Instance.new("Frame", card)
        af.Size = UDim2.new(0, 40, 0, 40)
        af.Position = UDim2.new(0, 8, 0.5, -20)
        af.BackgroundColor3 = C.Bg
        af.BackgroundTransparency = 0.2
        af.ZIndex = 105
        Corner(af, 20); Stroke(af, isWL and C.Green or (isFr and C.Friend or C.Accent), 1.5, 0.3)

        local ai = Instance.new("ImageLabel", af)
        ai.Size = UDim2.new(1, -4, 1, -4)
        ai.Position = UDim2.new(0, 2, 0, 2)
        ai.BackgroundTransparency = 1
        ai.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(p.UserId) .. "&w=150&h=150"
        ai.ZIndex = 106
        Corner(ai, 19)

        local dn = Instance.new("TextLabel", card)
        dn.Size = UDim2.new(1, -180, 0, 16)
        dn.Position = UDim2.new(0, 56, 0, 8)
        dn.BackgroundTransparency = 1
        dn.Text = p.DisplayName
        dn.TextColor3 = isWL and Color3.fromRGB(180, 255, 200) or (isFr and Color3.fromRGB(180, 220, 255) or C.Text)
        dn.TextSize = 11; dn.Font = C.FontB
        dn.TextXAlignment = Enum.TextXAlignment.Left
        dn.TextTruncate = Enum.TextTruncate.AtEnd
        dn.ZIndex = 105

        local un = Instance.new("TextLabel", card)
        un.Size = UDim2.new(1, -180, 0, 14)
        un.Position = UDim2.new(0, 56, 0, 26)
        un.BackgroundTransparency = 1
        un.Text = "@" .. p.Name
        un.TextColor3 = isWL and Color3.fromRGB(200, 255, 220) or C.Dim
        un.TextSize = 9; un.Font = C.Font
        un.TextXAlignment = Enum.TextXAlignment.Left
        un.TextTruncate = Enum.TextTruncate.AtEnd
        un.ZIndex = 105

        local badge = Instance.new("TextLabel", card)
        badge.Size = UDim2.new(0, 60, 0, 20)
        badge.Position = UDim2.new(1, -68, 0.5, -10)
        badge.BackgroundColor3 = isWL and Color3.fromRGB(0, 220, 110) or C.BgHover
        badge.BackgroundTransparency = isWL and 0 or 0.3
        badge.Text = isWL and "✓ SALVO" or "LIVRE"
        badge.TextColor3 = isWL and Color3.new(1,1,1) or C.Dim
        badge.TextSize = 9; badge.Font = C.FontB
        badge.ZIndex = 105
        Corner(badge, 6)

        card.MouseButton1Click:Connect(function()
            PS("Toggle")
            S.Whitelist[p.UserId] = not S.Whitelist[p.UserId]
            local state = S.Whitelist[p.UserId]
            card:SetAttribute("KikoBg", state and "" or "alt")
            TweenService:Create(card, TweenInfo.new(0.25), {
                BackgroundColor3 = state and Color3.fromRGB(0, 120, 60) or (LastBgAltApplied or C.BgAlt),
                BackgroundTransparency = state and 0.2 or (Personal.BgOpacity + 0.08)
            }):Play()
            local cs = card:FindFirstChildOfClass("UIStroke")
            if cs then
                TweenService:Create(cs, TweenInfo.new(0.25), {
                    Color = state and C.Green or (isFr and C.Friend or C.Stroke),
                    Transparency = state and 0.2 or 0.5
                }):Play()
            end
            dn.TextColor3 = state and Color3.fromRGB(180, 255, 200) or (isFr and Color3.fromRGB(180, 220, 255) or C.Text)
            un.TextColor3 = state and Color3.fromRGB(200, 255, 220) or C.Dim
            badge.BackgroundColor3 = state and Color3.fromRGB(0, 220, 110) or C.BgHover
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
task.delay(4, BuildWLUI)

--=============================================================
-- ⚙️ PRESETS
--=============================================================
CreateTitle(PresetP, "Config Presets", "💾")

local presetNameBox = Instance.new("Frame", PresetP)
presetNameBox.Size = UDim2.new(1, 0, 0, 36)
presetNameBox.BackgroundColor3 = C.BgAlt
presetNameBox.ZIndex = 103
presetNameBox:SetAttribute("KikoBg", "alt")
Corner(presetNameBox, 8); Stroke(presetNameBox, C.Stroke, 1, 0.7)

local presetInput = Instance.new("TextBox", presetNameBox)
presetInput.Size = UDim2.new(1, -20, 1, 0)
presetInput.Position = UDim2.new(0, 14, 0, 0)
presetInput.BackgroundTransparency = 1
presetInput.Text = ""
presetInput.PlaceholderText = "Nome do preset (ex: PvP, Farm...)"
presetInput.PlaceholderColor3 = C.Dim
presetInput.TextColor3 = C.Text
presetInput.TextSize = 11
presetInput.Font = C.Font
presetInput.TextXAlignment = Enum.TextXAlignment.Left
presetInput.ClearTextOnFocus = false
presetInput.ZIndex = 104

local function GetSaveableFlags()
    local keys = {
        "ESP","ESPNPC","TeamColor","Boxes","Names","Distance","Lines","Highlight","ESPHP",
        "AimAssist","AimFOV","AimSmooth","ShowFOV","WallCheck","TeamCheck","AimNPC",
        "TargetPriority","PriorityMode","AimPrediction","PredictionVelocity","TriggerBot",
        "UseSpeed","Speed","InfiniteJump","ForceThirdPerson","StickyBehind","StickySmoothness",
        "StickyDistance","HitboxEnabled","Hitbox","HitboxTransparency","HitboxNPC",
        "AutoTeamColorCheck","ColorAimbot",
        "PerfTextures","PerfShadows","PerfDecals","PerfParticles","PerfTrails",
        "PerfPostFX","PerfAnims","PerfGameSounds",
        "RapidFire","Fullbright","NoFog","AntiAFK",
    }
    local out = {}
    for _, k in ipairs(keys) do out[k] = S[k] end
    return out
end

local function ApplyFlags(flags)
    for k, v in pairs(flags) do S[k] = v end
    local map = {
        ESP = "Ativar ESP", Boxes = "Caixas", Names = "Nomes", Distance = "Distância",
        Lines = "Linhas", TeamColor = "Cor do Time", Highlight = "Destaque (Chams)",
        ESPHP = "Barra de Vida (HP)", ESPNPC = "Ativar ESP em NPCs",
        AimAssist = "Ativar Assistência", ShowFOV = "Exibir FOV na Tela",
        TargetPriority = "Prioridade 360°", AimPrediction = "Predição de Movimento",
        TriggerBot = "Atirar Automaticamente", TeamCheck = "Ignorar Aliados",
        WallCheck = "Ignorar Atrás de Paredes", AimNPC = "Mira em NPCs",
        UseSpeed = "Modificar Velocidade", InfiniteJump = "Pulo Infinito",
        ForceThirdPerson = "Terceira Pessoa", StickyBehind = "Grudar Atrás",
        HitboxEnabled = "Aumentar Hitbox (Jogadores)", HitboxNPC = "Aumentar Hitbox (NPCs)",
        AutoTeamColorCheck = "Detectar Time Automaticamente", ColorAimbot = "Mira Apenas em Inimigos",
        AntiAFK = "Anti-AFK", Fullbright = "Visão Total (Fullbright)", NoFog = "Remover Névoa",
        PerfTextures = "Remover Texturas", PerfShadows = "Remover Sombras",
        PerfDecals = "Remover Decals", PerfParticles = "Desligar Partículas",
        PerfTrails = "Desligar Trails e Beams", PerfPostFX = "Desligar Post-Processing",
        PerfAnims = "Desligar Animações", PerfGameSounds = "Silenciar Sons do Jogo",
        RapidFire = "Tiros Rápidos",
    }
    for flagKey, label in pairs(map) do
        if VisToggles[label] then VisToggles[label](flags[flagKey] == true, true, true) end
    end
    local stepMap = {
        AimFOV = "Campo de Visão (FOV)", AimSmooth = "Suavidade",
        PredictionVelocity = "Força da Predição", Speed = "Velocidade",
        StickySmoothness = "Suavidade", StickyDistance = "Distância",
        Hitbox = "Tamanho", HitboxTransparency = "Opacidade",
    }
    for flagKey, label in pairs(stepMap) do
        if VisSteppers[label] and flags[flagKey] ~= nil then
            VisSteppers[label](flags[flagKey], true)
        end
    end
end

local presetActionRow = Instance.new("Frame", PresetP)
presetActionRow.Size = UDim2.new(1, 0, 0, 36)
presetActionRow.BackgroundTransparency = 1
presetActionRow.ZIndex = 103

local savePresetBtn = Instance.new("TextButton", presetActionRow)
savePresetBtn.Size = UDim2.new(0.48, 0, 1, 0)
savePresetBtn.BackgroundColor3 = C.Green
savePresetBtn.Text = "💾 Salvar Preset"
savePresetBtn.TextColor3 = Color3.new(0,0,0)
savePresetBtn.TextSize = 11; savePresetBtn.Font = C.FontB
savePresetBtn.AutoButtonColor = false; savePresetBtn.ZIndex = 104
Corner(savePresetBtn, 8)

local presetListFrame = Instance.new("Frame", PresetP)
presetListFrame.Size = UDim2.new(1, 0, 0, 220)
presetListFrame.BackgroundColor3 = C.Bg
presetListFrame.BackgroundTransparency = 0.3
presetListFrame.ZIndex = 103
presetListFrame:SetAttribute("KikoBg", "main")
Corner(presetListFrame, 10); Stroke(presetListFrame, C.Stroke, 1, 0.5)

local presetScroll = Instance.new("ScrollingFrame", presetListFrame)
presetScroll.Size = UDim2.new(1, 0, 1, 0)
presetScroll.BackgroundTransparency = 1
presetScroll.BorderSizePixel = 0
presetScroll.ScrollBarThickness = 3
presetScroll.ScrollBarImageColor3 = C.Accent
presetScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
presetScroll.ZIndex = 104

local presetLayout = Instance.new("UIListLayout", presetScroll)
presetLayout.Padding = UDim.new(0, 5); presetLayout.SortOrder = Enum.SortOrder.LayoutOrder
local presetPad = Instance.new("UIPadding", presetScroll)
presetPad.PaddingTop = UDim.new(0, 6); presetPad.PaddingBottom = UDim.new(0, 6)
presetPad.PaddingLeft = UDim.new(0, 6); presetPad.PaddingRight = UDim.new(0, 6)
presetLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    presetScroll.CanvasSize = UDim2.new(0, 0, 0, presetLayout.AbsoluteContentSize.Y + 14)
end)

function RebuildPresetList()
    for _, v in pairs(presetScroll:GetChildren()) do
        if v:IsA("TextButton") or v:IsA("Frame") then v:Destroy() end
    end
    local names = {}
    for n, _ in pairs(SavedPresets) do table.insert(names, n) end
    table.sort(names)

    if #names == 0 then
        local empty = Instance.new("TextLabel", presetScroll)
        empty.Size = UDim2.new(1, 0, 0, 40)
        empty.BackgroundTransparency = 1
        empty.Text = "Nenhum preset salvo ainda"
        empty.TextColor3 = C.Dim; empty.TextSize = 10; empty.Font = C.Font
        empty.ZIndex = 105
        return
    end

    for _, name in ipairs(names) do
        local row = Instance.new("Frame", presetScroll)
        row.Size = UDim2.new(1, -4, 0, 36)
        row.BackgroundColor3 = C.BgAlt
        row.BackgroundTransparency = 0.15
        row.ZIndex = 105
        row:SetAttribute("KikoBg", "alt")
        Corner(row, 6)

        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1, -140, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = "💾 " .. name
        lbl.TextColor3 = C.Text; lbl.TextSize = 11; lbl.Font = C.FontB
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.ZIndex = 106

        local loadBtn = Instance.new("TextButton", row)
        loadBtn.Size = UDim2.new(0, 56, 0, 26)
        loadBtn.Position = UDim2.new(1, -122, 0.5, -13)
        loadBtn.BackgroundColor3 = C.Accent
        loadBtn.Text = "Carregar"; loadBtn.TextColor3 = Color3.new(1,1,1)
        loadBtn.TextSize = 10; loadBtn.Font = C.FontB
        loadBtn.AutoButtonColor = false; loadBtn.ZIndex = 106
        Corner(loadBtn, 6)

        local delBtn = Instance.new("TextButton", row)
        delBtn.Size = UDim2.new(0, 56, 0, 26)
        delBtn.Position = UDim2.new(1, -60, 0.5, -13)
        delBtn.BackgroundColor3 = C.AccentDk
        delBtn.Text = "Apagar"; delBtn.TextColor3 = Color3.new(1,1,1)
        delBtn.TextSize = 10; delBtn.Font = C.FontB
        delBtn.AutoButtonColor = false; delBtn.ZIndex = 106
        Corner(delBtn, 6)

        loadBtn.MouseButton1Click:Connect(function()
            PS("Click")
            ApplyFlags(SavedPresets[name])
            Notify("Preset '" .. name .. "' carregado!", true)
        end)
        delBtn.MouseButton1Click:Connect(function()
            PS("Click")
            SavedPresets[name] = nil
            SavePresets()
            RebuildPresetList()
            Notify("Preset '" .. name .. "' apagado", true)
        end)
    end
end

savePresetBtn.MouseButton1Click:Connect(function()
    PS("Click")
    local name = presetInput.Text
    if name == "" then
        Notify("Digite um nome para o preset", false); return
    end
    SavedPresets[name] = GetSaveableFlags()
    if SavePresets() then
        Notify("Preset '" .. name .. "' salvo!", true)
        presetInput.Text = ""
        RebuildPresetList()
    else
        Notify("Executor sem writefile", false)
    end
end)

RebuildPresetList()

--=============================================================
-- ⌨️ ATALHOS
--=============================================================
local listening = nil
local function KeyName(mod, key)
    local m = ""
    if mod == Enum.KeyCode.LeftAlt or mod == Enum.KeyCode.RightAlt then m = "Alt + "
    elseif mod == Enum.KeyCode.LeftControl or mod == Enum.KeyCode.RightControl then m = "Ctrl + "
    elseif mod == Enum.KeyCode.LeftShift or mod == Enum.KeyCode.RightShift then m = "Shift + " end
    return m .. (key and key.Name or "None")
end

local function BindRow(parent, label, key)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 38)
    f.BackgroundColor3 = C.BgAlt
    f.ZIndex = 103
    f:SetAttribute("KikoBg", "alt")
    Corner(f, 8); Stroke(f, C.Stroke, 1, 0.7)

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0.5, 0, 1, 0)
    l.Position = UDim2.new(0, 14, 0, 0)
    l.BackgroundTransparency = 1
    l.TextColor3 = C.Text; l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = C.FontB
    l.Text = label; l.ZIndex = 104

    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(0.45, 0, 0.7, 0)
    b.Position = UDim2.new(0.5, 0, 0.15, 0)
    b.BackgroundColor3 = C.BgHover
    b.TextColor3 = C.Green; b.TextSize = 11
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
BindRow(BindsP, "Aimbot", "AimAssist")
BindRow(BindsP, "ESP (Visual)", "Visuals")
BindRow(BindsP, "Hitbox", "Hitbox")
BindRow(BindsP, "Panic (Desligar Tudo)", "Panic")
CreateLabel(BindsP,
    "• Ctrl Direito / Delete = abrir menu.\n" ..
    "• Ctrl+P = Desligar tudo (Panic).\n" ..
    "• Esc = cancelar captura de tecla.", 50)

--=============================================================
-- 🌐 SERVIDOR
--=============================================================
CreateTitle(ServP, "Trocar de Servidor", "🌐")

CreateButton(ServP, "🔄 Reconectar (Mesmo Servidor)", Color3.fromRGB(0, 100, 150), function()
    Notify("Reconectando...", true)
    task.wait(0.5)
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
end)

CreateButton(ServP, "🎲 Servidor Aleatório", Color3.fromRGB(150, 100, 0), function()
    Notify("Procurando servidor aleatório...", true)
    pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"
        local data = HttpService:JSONDecode(game:HttpGet(url))
        local valid = {}
        for _, srv in ipairs(data.data) do
            if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then table.insert(valid, srv) end
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
-- ⚡ DESEMPENHO
--=============================================================
CreateTitle(PerfP, "Otimização Visual", "⚡")

CreateToggle(PerfP, "Remover Texturas", false, function(v)
    S.PerfTextures = v
    SetTextures(v)
end)

CreateToggle(PerfP, "Remover Sombras", false, function(v)
    S.PerfShadows = v
    SetShadows(v)
end)

CreateToggle(PerfP, "Remover Decals", false, function(v)
    S.PerfDecals = v
    SetDecals(v)
end)

CreateToggle(PerfP, "Desligar Partículas", false, function(v)
    S.PerfParticles = v
    SetParticles(v)
end)

CreateToggle(PerfP, "Desligar Trails e Beams", false, function(v)
    S.PerfTrails = v
    SetTrails(v)
end)

CreateTitle(PerfP, "Otimização de Ambiente", "🌍")

CreateToggle(PerfP, "Desligar Post-Processing", false, function(v)
    S.PerfPostFX = v
    SetPostFX(v)
end)

CreateTitle(PerfP, "Otimização de Sistema", "🔧")

CreateToggle(PerfP, "Desligar Animações", false, function(v)
    S.PerfAnims = v
    SetAnimations(v)
end)

CreateToggle(PerfP, "Silenciar Sons do Jogo", false, function(v)
    S.PerfGameSounds = v
    SetGameSounds(v)
end)

CreateStepper(PerfP, "Limite de FPS", 30, 360, 240, 30, function(v)
    if setfpscap then setfpscap(v) end
end)

CreateTitle(PerfP, "Modo Turbo", "🚀")

CreateButton(PerfP, "🚀 ATIVAR MODO ULTRA PERFORMANCE", Color3.fromRGB(180, 60, 200), function()
    local toEnable = {
        "Remover Texturas", "Remover Sombras", "Remover Decals",
        "Desligar Partículas", "Desligar Trails e Beams",
        "Desligar Post-Processing", "Desligar Animações",
    }
    for _, name in ipairs(toEnable) do
        if VisToggles[name] then VisToggles[name](true) end
    end
    if setfpscap then setfpscap(240) end
    Notify("🚀 Modo Ultra Performance ativado!", true)
end)

CreateButton(PerfP, "🔄 Desativar Modo Turbo", Color3.fromRGB(150, 30, 30), function()
    local toDisable = {
        "Remover Texturas", "Remover Sombras", "Remover Decals",
        "Desligar Partículas", "Desligar Trails e Beams",
        "Desligar Post-Processing", "Desligar Animações", "Silenciar Sons do Jogo",
    }
    for _, name in ipairs(toDisable) do
        if VisToggles[name] then VisToggles[name](false) end
    end
    Notify("Modo Turbo desativado", true)
end)

CreateTitle(PerfP, "Info", "ℹ️")
CreateLabel(PerfP,
    "• Texturas/Decals/Partículas reaplicam a cada 2s\n" ..
    "• Afeta o jogo inteiro (bom pra FPS em PCs fracos)\n" ..
    "• Post-Processing remove Bloom, Blur, DOF, SunRays\n" ..
    "• Use o Turbo pra ativar tudo de uma vez", 70)

--=============================================================
-- 🧰 MISC
--=============================================================
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
        Lighting.FogEnd = 100000; Lighting.FogStart = 100000
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

CreateTitle(MiscP, "Zona de Perigo", "⚠️")
CreateButton(MiscP, "🚨 DESATIVAR TUDO E FECHAR", Color3.fromRGB(220, 20, 20), function()
    PanicShutdown()
end)

CreateTitle(MiscP, "Sobre", "ℹ️")
CreateLabel(MiscP,
    "🎯 Kiko Menu " .. VERSION .. "\n\n" ..
    "Atalhos:\n" ..
    "• Ctrl Direito / Delete — abrir/fechar\n" ..
    "• Ctrl+P — Panic (desliga tudo)\n" ..
    "• Arraste o topo para mover o menu\n" ..
    "• Timer conta desde o momento da execução", 100)

--=============================================================
-- 🧪 ABA DE TESTE
--=============================================================
CreateTitle(TestP, "Tiros Rápidos", "⚔️")

CreateToggle(TestP, "Tiros Rápidos (Rapid Fire)", false, function(v)
    S.RapidFire = v
    if v then
        Notify("⚔️ Tiros Rápidos ativado", true)
    else
        Notify("Tiros Rápidos desativado", false)
    end
end)

CreateLabel(TestP,
    "• Reduz FireRate / Cooldown / FireDelay das armas\n" ..
    "• Reaplica automaticamente a cada 0.3 segundos\n" ..
    "• Não funciona em jogos com rate limit no servidor", 50)

-- Loop do Rapid Fire (CORRIGIDO)
task.spawn(function()
    while true do
        task.wait(0.3)
        if S.RapidFire then
            local char = LocalPlayer.Character
            if char then
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        pcall(function()
                            for _, v in pairs(tool:GetDescendants()) do
                                if v:IsA("NumberValue") then
                                    local lowered = string.lower(v.Name)
                                    local clean = string.gsub(lowered, "[_%s%-]", "")
                                    if clean == "firerate" or clean == "cooldown"
                                    or clean == "firedelay" or clean == "rate"
                                    or clean == "delay" or clean == "firecooldown" then
                                        if v.Value > 0.005 then
                                            if v:GetAttribute("KikoOrigVal") == nil then
                                                v:SetAttribute("KikoOrigVal", v.Value)
                                            end
                                            v.Value = 0.005
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
            end
        end
    end
end)

CreateTitle(TestP, "Info de Estado", "📊")

local infoLabel = Instance.new("TextLabel", TestP)
infoLabel.Size = UDim2.new(1, 0, 0, 120)
infoLabel.BackgroundColor3 = C.BgAlt
infoLabel.BackgroundTransparency = 0.3
infoLabel.Text = ""
infoLabel.TextColor3 = C.Text
infoLabel.TextSize = 11
infoLabel.Font = Enum.Font.Code
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.TextWrapped = true
infoLabel.ZIndex = 104
infoLabel:SetAttribute("KikoBg", "alt")
Corner(infoLabel, 8); Stroke(infoLabel, C.Stroke, 1, 0.5)
local infoPad = Instance.new("UIPadding", infoLabel)
infoPad.PaddingTop = UDim.new(0, 8)
infoPad.PaddingLeft = UDim.new(0, 10)
infoPad.PaddingRight = UDim.new(0, 10)

task.spawn(function()
    while true do
        task.wait(0.5)
        infoLabel.Text = string.format(
            "  Uptime:     %s\n  FPS:        %d\n  Jogadores:  %d\n  PlaceID:    %d\n  Presets:    %d",
            FormatTime(tick() - SCRIPT_START_TIME),
            currentFPS or 60,
            #Players:GetPlayers(),
            game.PlaceId,
            (function() local n=0 for _ in pairs(SavedPresets) do n=n+1 end return n end)()
        )
    end
end)

--=============================================================
-- 🎨 PERSONALIZAÇÃO
--=============================================================
CreateTitle(PersonalP, "Aparência do Menu", "🎨")

CreateLabel(PersonalP, "💡 Opacidade do fundo (0 = transparente, 1 = sólido)", 18)
CreateStepper(PersonalP, "Opacidade do Fundo", 0, 1, Personal.BgOpacity, 0.05, function(v)
    Personal.BgOpacity = v
    ApplyBackground()
    SavePersonal()
end)

CreateToggle(PersonalP, "Efeito Blur no Fundo", Personal.Blur, function(v)
    Personal.Blur = v
    pcall(function()
        if v then
            if not Lighting:FindFirstChild("KikoBlur") then
                local b = Instance.new("BlurEffect", Lighting)
                b.Name = "KikoBlur"; b.Size = 12
            end
        else
            local b = Lighting:FindFirstChild("KikoBlur")
            if b then b:Destroy() end
        end
    end)
    SavePersonal()
end)

CreateToggle(PersonalP, "Partículas ao Clicar", true, function(v)
    S.ParticlesEnabled = v
    SavePersonal()
end)

CreateTitle(PersonalP, "Cores do Fundo", "🌈")
CreateLabel(PersonalP, "Selecione uma opção abaixo:", 18)

local bgColors = {
    {name = "Preto",   rgb = {10, 10, 12}},
    {name = "Escuro",  rgb = {18, 18, 22}},
    {name = "Grafite", rgb = {30, 30, 35}},
    {name = "Azulado", rgb = {15, 20, 35}},
    {name = "Roxo",    rgb = {25, 15, 35}},
    {name = "Verde",   rgb = {15, 25, 18}},
}

local bgRow1 = Instance.new("Frame", PersonalP)
bgRow1.Size = UDim2.new(1, 0, 0, 42)
bgRow1.BackgroundTransparency = 1
bgRow1.ZIndex = 103
local bgRow2 = Instance.new("Frame", PersonalP)
bgRow2.Size = UDim2.new(1, 0, 0, 42)
bgRow2.BackgroundTransparency = 1
bgRow2.ZIndex = 103

local function MakeColorBtn(parent, data, xPos, isAccentBtn, refsTable)
    local demoColor = Color3.fromRGB(data.rgb[1], data.rgb[2], data.rgb[3])
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.31, 0, 1, 0)
    btn.Position = UDim2.new(xPos, 0, 0, 0)
    btn.BackgroundColor3 = C.BgAlt
    btn.BackgroundTransparency = 0.15
    btn.Text = ""; btn.AutoButtonColor = false
    btn.ZIndex = 104
    btn:SetAttribute("KikoBg", "alt")
    btn:SetAttribute("KikoNoAccent", true)
    Corner(btn, 8)
    local st = Stroke(btn, C.Stroke, 1, 0.5)
    st:SetAttribute("KikoNoAccent", true)

    local preview = Instance.new("Frame", btn)
    preview.Size = UDim2.new(0, 22, 0, 22)
    preview.Position = UDim2.new(0, 10, 0.5, -11)
    preview.BackgroundColor3 = demoColor
    preview.ZIndex = 105
    preview:SetAttribute("KikoNoAccent", true)
    Corner(preview, 11)
    local prevSt = Stroke(preview, Color3.new(1,1,1), 1.5, 0.6)
    prevSt:SetAttribute("KikoNoAccent", true)

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, -42, 1, 0)
    lbl.Position = UDim2.new(0, 38, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = data.name
    lbl.TextColor3 = C.Text; lbl.TextSize = 11; lbl.Font = C.FontB
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 105
    lbl:SetAttribute("KikoNoAccent", true)

    local check = Instance.new("TextLabel", btn)
    check.Size = UDim2.new(0, 16, 0, 16)
    check.Position = UDim2.new(1, -20, 0, 4)
    check.BackgroundTransparency = 1
    check.Text = "✓"; check.TextColor3 = demoColor
    check.TextSize = 14; check.Font = C.FontB
    check.Visible = false; check.ZIndex = 106
    check:SetAttribute("KikoNoAccent", true)

    local function setSelected(sel)
        check.Visible = sel
        if sel then
            TweenService:Create(st, TweenInfo.new(0.2), {Color = demoColor, Transparency = 0, Thickness = 2}):Play()
        else
            TweenService:Create(st, TweenInfo.new(0.2), {Color = C.Stroke, Transparency = 0.5, Thickness = 1}):Play()
        end
    end
    refsTable[#refsTable+1] = setSelected

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = C.BgHover, BackgroundTransparency = 0}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = LastBgAltApplied or C.BgAlt,
            BackgroundTransparency = Personal.BgOpacity + 0.08
        }):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        PS("Click")
        for _, fn in pairs(refsTable) do fn(false) end
        setSelected(true)
        if isAccentBtn then
            Personal.AccentColor = data.rgb
            ApplyAccent()
        else
            Personal.BgColor = data.rgb
            ApplyBackground()
        end
        SavePersonal()
    end)

    local cur = isAccentBtn and Personal.AccentColor or Personal.BgColor
    if cur[1] == data.rgb[1] and cur[2] == data.rgb[2] and cur[3] == data.rgb[3] then
        setSelected(true)
    end
end

local bgRefsRow1, bgRefsRow2 = {}, {}
for i = 1, 3 do MakeColorBtn(bgRow1, bgColors[i], (i-1) * 0.345, false, bgRefsRow1) end
for i = 4, 6 do MakeColorBtn(bgRow2, bgColors[i], (i-4) * 0.345, false, bgRefsRow2) end

CreateTitle(PersonalP, "Cor de Destaque", "🎯")
CreateLabel(PersonalP, "Cor dos botões, textos e detalhes:", 18)

local accentColors = {
    {name = "Vermelho", rgb = {220, 50, 50}},
    {name = "Azul",     rgb = {80, 140, 240}},
    {name = "Verde",    rgb = {60, 200, 120}},
    {name = "Roxo",     rgb = {170, 90, 230}},
    {name = "Dourado",  rgb = {230, 180, 60}},
    {name = "Rosa",     rgb = {240, 100, 170}},
}

local acRow1 = Instance.new("Frame", PersonalP)
acRow1.Size = UDim2.new(1, 0, 0, 42)
acRow1.BackgroundTransparency = 1
acRow1.ZIndex = 103
local acRow2 = Instance.new("Frame", PersonalP)
acRow2.Size = UDim2.new(1, 0, 0, 42)
acRow2.BackgroundTransparency = 1
acRow2.ZIndex = 103

local acRefsRow1, acRefsRow2 = {}, {}
for i = 1, 3 do MakeColorBtn(acRow1, accentColors[i], (i-1) * 0.345, true, acRefsRow1) end
for i = 4, 6 do MakeColorBtn(acRow2, accentColors[i], (i-4) * 0.345, true, acRefsRow2) end

CreateTitle(PersonalP, "Layout", "📐")
CreateLabel(PersonalP, "Escala do menu (0.7x a 1.4x):", 18)
CreateStepper(PersonalP, "Escala da UI", 0.7, 1.4, Personal.UIScale, 0.05, function(v)
    Personal.UIScale = v
    ApplyScale()
    SavePersonal()
end)

CreateTitle(PersonalP, "Gerenciar", "💾")

local mgrRow = Instance.new("Frame", PersonalP)
mgrRow.Size = UDim2.new(1, 0, 0, 38)
mgrRow.BackgroundTransparency = 1
mgrRow.ZIndex = 103

local saveBtn = Instance.new("TextButton", mgrRow)
saveBtn.Size = UDim2.new(0.48, 0, 1, 0)
saveBtn.BackgroundColor3 = C.Green
saveBtn.Text = "💾 Salvar"
saveBtn.TextColor3 = Color3.new(0,0,0)
saveBtn.TextSize = 11; saveBtn.Font = C.FontB
saveBtn.AutoButtonColor = false; saveBtn.ZIndex = 104
Corner(saveBtn, 8)
saveBtn.MouseButton1Click:Connect(function()
    PS("Click")
    if SavePersonal() then Notify("💾 Personalização salva!", true)
    else Notify("Executor sem writefile", false) end
end)

local resetBtn = Instance.new("TextButton", mgrRow)
resetBtn.Size = UDim2.new(0.48, 0, 1, 0)
resetBtn.Position = UDim2.new(0.52, 0, 0, 0)
resetBtn.BackgroundColor3 = C.AccentDk
resetBtn.Text = "🔄 Resetar Padrão"
resetBtn.TextColor3 = Color3.new(1,1,1)
resetBtn.TextSize = 11; resetBtn.Font = C.FontB
resetBtn.AutoButtonColor = false; resetBtn.ZIndex = 104
Corner(resetBtn, 8)
resetBtn.MouseButton1Click:Connect(function()
    PS("Click")
    Personal = table.clone(DefaultPersonal)
    Personal.BgColor = {18, 18, 22}
    Personal.AccentColor = {220, 50, 50}
    ApplyBackground()
    ApplyAccent()
    ApplyScale()
    if SavePersonal() then Notify("Personalização resetada!", true) end
end)

CreateLabel(PersonalP,
    "💡 Alterações são salvas automaticamente\n" ..
    "📁 Arquivos: kiko_menu_personal.json e kiko_menu_presets.json\n" ..
    "🔧 Requer executor com writefile/readfile", 60)

print("[Kiko] Abas construídas")

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
-- 🚨 PANIC
--=============================================================
function PanicShutdown()
    for k, v in pairs(S) do
        if type(v) == "boolean" and k ~= "SoundEnabled" then S[k] = false end
    end
    for _, f in pairs(VisToggles) do pcall(function() f(false, true, true) end) end
    pcall(function()
        FOVCircle.Visible = false
        if Lighting:FindFirstChild("KikoBlur") then Lighting:FindFirstChild("KikoBlur"):Destroy() end
        Lighting.Brightness = originalLighting.Brightness
        Lighting.Ambient = originalLighting.Ambient
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.FogStart = originalLighting.FogStart
        Lighting.GlobalShadows = originalLighting.GlobalShadows
    end)
    Notify("🚨 PANIC — Desligando tudo...", false)
    task.wait(0.4)
    pcall(function() FOVCircle:Remove() end)
    pcall(function() ScreenGui:Destroy() end)
    print("[Kiko MENU] 🚨 Panic executado — script encerrado.")
end

--=============================================================
-- 🔄 TOGGLE MENU
--=============================================================
local function ToggleMenu()
    if MenuAberto then
        PS("Close")
        MenuAberto = false
        TweenService:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, DIM.W - 20, 0, DIM.H - 20)
        }):Play()
        local fade = TweenService:Create(Main, TweenInfo.new(0.22), {BackgroundTransparency = Personal.BgOpacity + 0.4})
        fade:Play()
        fade.Completed:Connect(function()
            Main.Visible = false
            Main.BackgroundTransparency = Personal.BgOpacity
            Main.Size = UDim2.new(0, DIM.W, 0, DIM.H)
        end)
    else
        PS("Open")
        MenuAberto = true
        Main.Visible = true
        Main.BackgroundTransparency = Personal.BgOpacity + 0.4
        Main.Size = UDim2.new(0, DIM.W - 20, 0, DIM.H - 20)
        TweenService:Create(Main, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = Personal.BgOpacity,
            Size = UDim2.new(0, DIM.W, 0, DIM.H)
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
-- ⌨️ INPUTS
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
                elseif bk == "Panic" then
                    PanicShutdown()
                end
            end
        end
    end
end)

--=============================================================
-- 🤖 NPC CACHE + ESP
--=============================================================
local NPCCache = {}
local ESPCont = {}
local NPCESPCont = {}

local function CreateSkelLines()
    local lines = {}
    for i = 1, 12 do
        local l = Drawing.new("Line")
        l.Thickness = 1; l.Visible = false; l.Color = Color3.new(1,1,1)
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
        if cont[obj].HPBar then cont[obj].HPBar:Remove() end
        if cont[obj].HPBack then cont[obj].HPBack:Remove() end
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
        HPBack = Drawing.new("Square"),
        HPBar = Drawing.new("Square"),
        Highlight = nil,
        Skeleton = CreateSkelLines()
    }
    local e = cont[obj]
    e.Box.Thickness = 1.5; e.Box.Filled = false
    e.Name.Size = 14; e.Name.Center = true; e.Name.Outline = true
    e.Dist.Size = 12; e.Dist.Center = true; e.Dist.Outline = true
    e.Line.Thickness = 1
    e.HPBack.Filled = true; e.HPBack.Color = Color3.fromRGB(30, 30, 30)
    e.HPBar.Filled = true
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
-- 📊 STATS
--=============================================================
local currentFPS = 60
task.spawn(function()
    local frames = 0
    local t0 = tick()
    while true do
        RunService.RenderStepped:Wait()
        frames = frames + 1
        local now = tick()
        if now - t0 >= 0.5 then
            currentFPS = math.floor(frames / (now - t0))
            frames = 0; t0 = now
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        local elapsed = tick() - SCRIPT_START_TIME
        local ping = 0
        pcall(function()
            ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        StatsLbl.Text = "FPS: "..currentFPS.."   •   PING: "..ping.."ms   •   "..FormatTime(elapsed)
    end
end)

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

task.spawn(function()
    while true do
        task.wait(2)
        if S.PerfTextures then SetTextures(true) end
        if S.PerfDecals then SetDecals(true) end
        if S.PerfParticles then SetParticles(true) end
        if S.PerfTrails then SetTrails(true) end
    end
end)

--=============================================================
-- 🎨 APLICAR PERSONALIZAÇÃO INICIAL
--=============================================================
LastBgApplied = C.Bg
LastBgAltApplied = C.BgAlt
LastAccent = C.Accent
LastAccentDk = C.AccentDk

task.defer(function()
    task.wait(0.1)
    ApplyBackground()
    ApplyAccent()
    ApplyScale()
    if TabButtons[1] then
        TabButtons[1]:SetAttribute("KikoBg", "")
        TabButtons[1].BackgroundColor3 = C.Accent
        TabButtons[1].BackgroundTransparency = 0
        TabButtons[1].TextColor3 = Color3.new(1,1,1)
    end
end)

--=============================================================
-- 🎯 MAIN LOOP
--=============================================================
RunService.RenderStepped:Connect(function()
    if MenuAberto then
        UIS.MouseIconEnabled = true
        UIS.MouseBehavior = Enum.MouseBehavior.Default
    end

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
                e.HPBar.Visible = false; e.HPBack.Visible = false
                if e.Highlight then e.Highlight.Enabled = false end
                continue
            end
            local hrp = ch.HumanoidRootPart
            local hum = ch:FindFirstChildOfClass("Humanoid")
            local head = ch:FindFirstChild("Head")
            local pos, vis = Camera:WorldToViewportPoint(hrp.Position)
            local col = Color3.new(1,1,1)
            if isNPC then col = Color3.fromRGB(255, 80, 80)
            elseif S.AutoTeamColorCheck then col = GetTeamColor(obj)
            elseif S.TeamColor and obj.TeamColor then col = obj.TeamColor.Color end

            if (isNPC and vis) or (not isNPC and S.ESP and vis) then
                local boxSize = Vector2.new(2500/pos.Z, 3500/pos.Z)
                local boxPos = Vector2.new(pos.X - boxSize.X/2, pos.Y - boxSize.Y/2)

                if S.Boxes then
                    e.Box.Visible = true
                    e.Box.Size = boxSize
                    e.Box.Position = boxPos
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

                if S.ESPHP and hum then
                    local pct = hum.Health / hum.MaxHealth
                    if pct < 0.999 then
                        local hpW = math.min(80, boxSize.X)
                        local hpH = 4
                        local hpX = pos.X - hpW/2
                        local hpY = boxPos.Y - 10
                        e.HPBack.Visible = true
                        e.HPBack.Size = Vector2.new(hpW, hpH)
                        e.HPBack.Position = Vector2.new(hpX, hpY)
                        e.HPBack.Color = Color3.fromRGB(30, 30, 30)
                        e.HPBar.Visible = true
                        e.HPBar.Size = Vector2.new(hpW * pct, hpH)
                        e.HPBar.Position = Vector2.new(hpX, hpY)
                        if pct > 0.6 then e.HPBar.Color = Color3.fromRGB(80, 220, 100)
                        elseif pct > 0.3 then e.HPBar.Color = Color3.fromRGB(240, 200, 60)
                        else e.HPBar.Color = Color3.fromRGB(220, 60, 60) end
                    else
                        e.HPBar.Visible = false
                        e.HPBack.Visible = false
                    end
                else
                    e.HPBar.Visible = false
                    e.HPBack.Visible = false
                end

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
                e.HPBar.Visible = false; e.HPBack.Visible = false
                if e.Highlight then e.Highlight.Enabled = false end
            end
        end
    end
    RenderCont(ESPCont, false)
    RenderCont(NPCESPCont, true)
end)

--=============================================================
-- 📦 LOOP HITBOX + AUTO NEAREST
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
        Text = VERSION .. " — Power Edition!",
        Duration = 4,
    })
end)

print("[Kiko MENU " .. VERSION .. "] ✅ Carregado com sucesso!")
