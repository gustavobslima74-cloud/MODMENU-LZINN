--// SERVIÇOS
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

--// UNLOCK FPS
if setfpscap then setfpscap(120) end

--// CONFIG
getgenv().Settings = {
    ESP = false, Boxes = false, Names = false, Distance = false, Highlight = false, Lines = false, TeamColor = false,
    HitboxEnabled = false, Hitbox = 20, HitboxTransparency = 0.6,
    UseSpeed = false, Speed = 16, UseJump = false, JumpPower = 50, InfiniteJump = false,
    ForceThirdPerson = false, BoostFPS = false, RemoveShadows = false,
    SelectedPlayer = nil, AutoNearest = false, StickyBehind = false, StickySmoothness = 0.1, StickyDistance = 3,
    -- AIM SETTINGS (v5.0)
    AimAssist = false, AimPart = "Head", AimFOV = 100, AimSmooth = 0.1, ShowFOV = false, WallCheck = true
}

local VERSION = "v5.0"
local CHANGELOG_TEXT = [[
--- NOVIDADES v5.0 ---
[+] ABA MIRA: Sistema de Auxílio de Mira (Aimbot) funcional.
[+] FOV: Círculo visual customizável no centro da tela.
[+] FILTRO: Opção de focar apenas em inimigos.
[+] AJUSTES: Seleção de alvo (Cabeça/Tronco) e Suavidade.
-------------------------]]

local MenuAberto = false
local FOVCircle = Drawing.new("Circle")

--// FUNÇÃO DRAG
local function MakeDraggable(gui, isMenu)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if not isMenu and MenuAberto then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = gui.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if not isMenu and MenuAberto then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--// GUI PRINCIPAL
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local ToggleBtn = Instance.new("ImageButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0,60,0,60); ToggleBtn.Position = UDim2.new(0,20,0.6,0); ToggleBtn.BackgroundColor3 = Color3.fromRGB(20,20,20); ToggleBtn.Image = "rbxassetid://70505361093133"
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1,0); MakeDraggable(ToggleBtn, false)

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,300,0,350); Main.Position = UDim2.new(0.5, -150, 0.5, -175); Main.BackgroundColor3 = Color3.fromRGB(10,10,10); Main.ClipsDescendants = true; Main.Visible = false; Main.BackgroundTransparency = 1
Instance.new("UICorner", Main); MakeDraggable(Main, true)

local stroke = Instance.new("UIStroke", Main)
stroke.Thickness = 2; stroke.Transparency = 1; task.spawn(function() while true do stroke.Color = Color3.fromHSV(tick()%5/5,1,1); task.wait() end end)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,35); Title.Text = "LQB KIKO | " .. VERSION; Title.BackgroundTransparency = 1; Title.TextColor3 = Color3.new(1,1,1); Title.TextSize = 16; Title.Font = Enum.Font.GothamBold; Title.TextTransparency = 1

local FPSLabel = Instance.new("TextLabel", Main)
FPSLabel.Size = UDim2.new(0,50,0,35); FPSLabel.Position = UDim2.new(1,-60,0,0); FPSLabel.Text = "FPS: 0"; FPSLabel.BackgroundTransparency = 1; FPSLabel.TextColor3 = Color3.new(0,1,0); FPSLabel.TextSize = 12; FPSLabel.Font = Enum.Font.Code; FPSLabel.TextTransparency = 1

-- ABAS (SCROLL HORIZONTAL)
local TabsFrame = Instance.new("ScrollingFrame", Main)
TabsFrame.Size = UDim2.new(1,0,0,35); TabsFrame.Position = UDim2.new(0,0,0,35); TabsFrame.BackgroundTransparency = 1; TabsFrame.ScrollBarThickness = 0; TabsFrame.CanvasSize = UDim2.new(0,0,0,0)
local TabList = Instance.new("UIListLayout", TabsFrame); TabList.FillDirection = Enum.FillDirection.Horizontal
TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() TabsFrame.CanvasSize = UDim2.new(0, TabList.AbsoluteContentSize.X, 0, 0) end)

local Pages = Instance.new("Frame", Main)
Pages.Position = UDim2.new(0,0,0,70); Pages.Size = UDim2.new(1,0,1,-70); Pages.BackgroundTransparency = 1

local function CreatePage(name)
    local btn = Instance.new("TextButton", TabsFrame); btn.Size = UDim2.new(0, 75, 1, 0); btn.Text = name; btn.BackgroundTransparency = 1; btn.TextColor3 = Color3.new(1,1,1); btn.TextSize = 11; btn.Font = Enum.Font.GothamBold
    local page = Instance.new("ScrollingFrame", Pages); page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1; page.Visible = false; page.ScrollBarThickness = 3
    local layout = Instance.new("UIListLayout", page); layout.Padding = UDim.new(0,5); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() page.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 20) end)
    btn.MouseButton1Click:Connect(function() for _,v in pairs(Pages:GetChildren()) do v.Visible = false end; page.Visible = true end)
    return page, btn
end

-- ABAS
local ESPPage, eb = CreatePage("ESP")
local PlayerPage, pb = CreatePage("PLAYER")
local TPPage, tpb = CreatePage("TP")
local MiraPage, mb = CreatePage("MIRA")
local HitboxPage, hb = CreatePage("HITBOX")
local FPSPage, fb = CreatePage("FPS")
local InfoPage, ib = CreatePage("INFOS")
ESPPage.Visible = true

-- COMPONENTES UI
local function CreateToggle(parent, text, callback, default)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1,-20,0,35); b.Text = text..": "..(default and "ON" or "OFF"); b.BackgroundColor3 = default and Color3.fromRGB(50,100,50) or Color3.fromRGB(30,30,30); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    local state = default or false
    b.MouseButton1Click:Connect(function() state = not state; b.Text = text..": "..(state and "ON" or "OFF"); b.BackgroundColor3 = state and Color3.fromRGB(50,100,50) or Color3.fromRGB(30,30,30); callback(state) end)
end

local function CreateStepper(parent, text, min, max, default, step, callback)
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(1,-20,0,60); frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame); label.Size = UDim2.new(1,0,0,25); label.Text = text..": "..default; label.TextColor3 = Color3.new(1,1,1); label.BackgroundTransparency = 1
    local minus = Instance.new("TextButton", frame); minus.Size = UDim2.new(0,40,0,30); minus.Position = UDim2.new(0,50,0,25); minus.Text = "-"; minus.BackgroundColor3 = Color3.fromRGB(40,40,40); minus.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", minus)
    local plus = Instance.new("TextButton", frame); plus.Size = UDim2.new(0,40,0,30); plus.Position = UDim2.new(0,180,0,25); plus.Text = "+"; plus.BackgroundColor3 = Color3.fromRGB(40,40,40); plus.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", plus)
    local val = default; local function up(n) val = math.clamp(n, min, max); label.Text = text..": "..string.format("%.2f", val); callback(val) end
    minus.MouseButton1Click:Connect(function() up(val - step) end); plus.MouseButton1Click:Connect(function() up(val + step) end)
end

-- ABA MIRA (v5.0)
CreateToggle(MiraPage, "Auxílio de Mira", function(v) Settings.AimAssist = v end)

local PartBtn = Instance.new("TextButton", MiraPage)
PartBtn.Size = UDim2.new(1,-20,0,35); PartBtn.Text = "Alvo: Cabeça"; PartBtn.BackgroundColor3 = Color3.fromRGB(30,30,30); PartBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", PartBtn)
PartBtn.MouseButton1Click:Connect(function()
    if Settings.AimPart == "Head" then
        Settings.AimPart = "HumanoidRootPart"; PartBtn.Text = "Alvo: Tronco"
    else
        Settings.AimPart = "Head"; PartBtn.Text = "Alvo: Cabeça"
    end
end)

CreateToggle(MiraPage, "Exibir FOV", function(v) Settings.ShowFOV = v end)
CreateStepper(MiraPage, "Tamanho FOV", 10, 800, 100, 10, function(v) Settings.AimFOV = v end)
CreateStepper(MiraPage, "Suavidade", 0.01, 1, 0.1, 0.05, function(v) Settings.AimSmooth = v end)

-- [RESTAURANTE DAS OUTRAS FUNÇÕES]
CreateToggle(ESPPage, "ESP Geral", function(v) Settings.ESP = v end)
CreateToggle(ESPPage, "Team Color", function(v) Settings.TeamColor = v end)
CreateToggle(ESPPage, "Boxes", function(v) Settings.Boxes = v end)
CreateToggle(ESPPage, "Names", function(v) Settings.Names = v end)
CreateToggle(ESPPage, "Distance", function(v) Settings.Distance = v end)

CreateToggle(PlayerPage, "Third Person", function(v) Settings.ForceThirdPerson = v end)
CreateStepper(PlayerPage, "Velocidade", 16, 500, 16, 5, function(v) Settings.Speed = v end)

CreateToggle(HitboxPage, "Enabled", function(v) Settings.HitboxEnabled = v end)
CreateStepper(HitboxPage, "Tamanho", 2, 100, 20, 5, function(v) Settings.Hitbox = v end)

CreateToggle(FPSPage, "Otimizar", function(v) Settings.BoostFPS = v; for _,o in pairs(game:GetDescendants()) do if o:IsA("Texture") or o:IsA("Decal") then o.Transparency = v and 1 or 0 end end end)

-- LÓGICA AIMBOT
local function GetClosestPlayer()
    local target = nil
    local dist = Settings.AimFOV
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Settings.AimPart) then
            -- Filtro de Inimigo (Verifica se estão no mesmo time)
            if Settings.TeamColor and p.Team == LocalPlayer.Team then continue end
            
            local pos, vis = Camera:WorldToViewportPoint(p.Character[Settings.AimPart].Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                if mag < dist then
                    dist = mag
                    target = p
                end
            end
        end
    end
    return target
end

-- RENDER LOOP (MIRA + FOV + ESP)
RunService.RenderStepped:Connect(function()
    -- FPS & Camera
    FPSLabel.Text = "FPS: " .. math.floor(1/RunService.RenderStepped:Wait())
    if Settings.ForceThirdPerson then LocalPlayer.CameraMode = Enum.CameraMode.Classic; LocalPlayer.CameraMaxZoomDistance = 50 else LocalPlayer.CameraMaxZoomDistance = 128 end

    -- FOV Circle
    FOVCircle.Visible = Settings.ShowFOV
    FOVCircle.Radius = Settings.AimFOV
    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Color = Color3.new(1,1,1)
    FOVCircle.Thickness = 1
    FOVCircle.Filled = false

    -- Aimbot Logic
    if Settings.AimAssist then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(Settings.AimPart) then
            local targetPos = target.Character[Settings.AimPart].Position
            local camPos = Camera.CFrame.Position
            -- Suavidade com Lerp na CFrame da câmera
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(camPos, targetPos), Settings.AimSmooth)
        end
    end
    
    -- Sticky/TP
    if Settings.StickyBehind and Settings.SelectedPlayer and Settings.SelectedPlayer.Character then
        local hrp = Settings.SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame:Lerp(hrp.CFrame * CFrame.new(0, 0, Settings.StickyDistance), Settings.StickySmoothness) end
    end
end)

-- [ESP MANTIDO v4.9.2]
local ESPContainer = {}
local function RemoveESP(p) if ESPContainer[p] then for _,v in pairs(ESPContainer[p]) do if typeof(v) == "table" then v:Remove() end end if ESPContainer[p].Highlight then ESPContainer[p].Highlight:Destroy() end ESPContainer[p] = nil end end
local function CreateESP(p) if p == LocalPlayer then return end RemoveESP(p); ESPContainer[p] = {Box = Drawing.new("Square"), Name = Drawing.new("Text"), Dist = Drawing.new("Text"), Line = Drawing.new("Line"), Highlight = nil}; local e = ESPContainer[p]; e.Box.Thickness = 1.5; e.Box.Filled = false; e.Name.Size = 16; e.Name.Center = true; e.Name.Outline = true; e.Dist.Size = 14; e.Dist.Center = true; e.Dist.Outline = true; e.Line.Thickness = 1 end
Players.PlayerAdded:Connect(CreateESP); Players.PlayerRemoving:Connect(RemoveESP); for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end

RunService.RenderStepped:Connect(function()
    if not Settings.ESP then for _,e in pairs(ESPContainer) do e.Box.Visible = false; e.Name.Visible = false; e.Dist.Visible = false; e.Line.Visible = false; if e.Highlight then e.Highlight.Enabled = false end end return end
    for p, e in pairs(ESPContainer) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart; local pos, vis = Camera:WorldToViewportPoint(hrp.Position)
            local color = (Settings.TeamColor and p.TeamColor) and p.TeamColor.Color or Color3.new(1,1,1)
            if vis then
                if Settings.Boxes then e.Box.Visible = true; e.Box.Size = Vector2.new(2500/pos.Z, 3500/pos.Z); e.Box.Position = Vector2.new(pos.X - e.Box.Size.X/2, pos.Y - e.Box.Size.Y/2); e.Box.Color = color else e.Box.Visible = false end
                if Settings.Names then e.Name.Visible = true; e.Name.Text = p.DisplayName; e.Name.Position = Vector2.new(pos.X, pos.Y - (2000/pos.Z) - 20); e.Name.Color = color else e.Name.Visible = false end
                if Settings.Distance then e.Dist.Visible = true; e.Dist.Text = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude).."m"; e.Dist.Position = Vector2.new(pos.X, pos.Y + (2000/pos.Z) + 5); e.Dist.Color = Color3.new(0,1,0) else e.Dist.Visible = false end
                if Settings.Highlight then if not e.Highlight or e.Highlight.Parent ~= p.Character then if e.Highlight then e.Highlight:Destroy() end e.Highlight = Instance.new("Highlight", p.Character) end e.Highlight.Enabled = true; e.Highlight.FillColor = color; e.Highlight.FillTransparency = 0.5 else if e.Highlight then e.Highlight.Enabled = false end end
            else e.Box.Visible = false; e.Name.Visible = false; e.Dist.Visible = false; if e.Highlight then e.Highlight.Enabled = false end end
        end
    end
end)

ToggleBtn.MouseButton1Up:Connect(function() 
    if Main.Visible then 
        MenuAberto = false; local tw = TweenInfo.new(0.3); local anim = TweenService:Create(Main, tw, {Size = UDim2.new(0, 300, 0, 0), BackgroundTransparency = 1}); anim:Play(); anim.Completed:Connect(function() Main.Visible = false end)
    else 
        MenuAberto = true; Main.Visible = true; TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Elastic), {Size = UDim2.new(0, 300, 0, 350), BackgroundTransparency = 0.1}):Play()
    end
end)
