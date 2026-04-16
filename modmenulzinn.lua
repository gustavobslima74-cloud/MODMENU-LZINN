--// SERVIÇOS
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

--// UNLOCK FPS
if setfpscap then setfpscap(120) end

--// CONFIG
getgenv().Settings = {
    ESP = false, Boxes = false, Names = false, Distance = false, Highlight = false, Lines = false, TeamColor = false,
    HitboxEnabled = false, Hitbox = 20, HitboxTransparency = 0.6,
    UseSpeed = false, Speed = 16, UseJump = false, JumpPower = 50, InfiniteJump = false,
    ForceThirdPerson = false, BoostFPS = false, RemoveShadows = false,
    SelectedPlayer = nil, AutoNearest = false, StickyBehind = false, StickySmoothness = 0.1, StickyDistance = 3,
    AimAssist = false, AimPart = "Head", AimFOV = 100, AimSmooth = 0.1, ShowFOV = false, WallCheck = false, TeamCheck = false,
    AimNPC = false,
    
    -- NOVAS CONFIGS (TESTE / TROLL)
    SkeletonESP = false, OutlineChams = false, NoSpread = false,
    Fling = false, AntiFling = false, FakeLag = false
}

local VERSION = "v6.1.0-TESTE"
local CHANGELOG_TEXT = [[
--- BUILD DE TESTE ---
[+] Aguardando aprovação para v6.2
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
ToggleBtn.Size = UDim2.new(0,45,0,45); ToggleBtn.Position = UDim2.new(1,-65,0,15); ToggleBtn.BackgroundColor3 = Color3.fromRGB(20,20,20); ToggleBtn.Image = "rbxassetid://70505361093133"
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1,0); MakeDraggable(ToggleBtn, false)

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,280,0,320)
Main.Position = UDim2.new(0.5, -140, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(10,10,10); Main.ClipsDescendants = true; Main.Visible = false; Main.BackgroundTransparency = 1
Instance.new("UICorner", Main); MakeDraggable(Main, true)
local stroke = Instance.new("UIStroke", Main); stroke.Thickness = 2; stroke.Transparency = 1

-- TÍTULO HACKER
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,35); Title.BackgroundTransparency = 1; Title.TextSize = 16; Title.Font = Enum.Font.Code; Title.TextTransparency = 0

local function hackerEffect()
    local realText = "Kiko MENU | " .. VERSION
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*"
    task.spawn(function()
        while true do
            local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
            Title.TextColor3 = color; stroke.Color = color
            if MenuAberto then
                if math.random(1, 25) == 1 then
                    local rand = ""; for i=1,#realText do rand ..= chars:sub(math.random(1,#chars), math.random(1,#chars)) end
                    Title.Text = rand; task.wait(0.05)
                end
                Title.Text = realText
            end
            task.wait(0.05)
        end
    end)
end
hackerEffect()

local FPSLabel = Instance.new("TextLabel", Main); FPSLabel.Size = UDim2.new(0,50,0,35); FPSLabel.Position = UDim2.new(1,-60,0,0); FPSLabel.Text = "FPS: 0"; FPSLabel.BackgroundTransparency = 1; FPSLabel.TextColor3 = Color3.new(0,1,0); FPSLabel.TextSize = 11; FPSLabel.Font = Enum.Font.Code; FPSLabel.TextTransparency = 1

-- ABAS
local TabsFrame = Instance.new("ScrollingFrame", Main); TabsFrame.Size = UDim2.new(1,0,0,35); TabsFrame.Position = UDim2.new(0,0,0,35); TabsFrame.BackgroundTransparency = 1; TabsFrame.ScrollBarThickness = 0; TabsFrame.CanvasSize = UDim2.new(0,0,0,0)
local TabList = Instance.new("UIListLayout", TabsFrame); TabList.FillDirection = Enum.FillDirection.Horizontal
TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() TabsFrame.CanvasSize = UDim2.new(0, TabList.AbsoluteContentSize.X, 0, 0) end)
local Pages = Instance.new("Frame", Main); Pages.Position = UDim2.new(0,0,0,70); Pages.Size = UDim2.new(1,0,1,-70); Pages.BackgroundTransparency = 1

local function CreatePage(name)
    local btn = Instance.new("TextButton", TabsFrame); btn.Size = UDim2.new(0, 70, 1, 0); btn.Text = name; btn.BackgroundTransparency = 1; btn.TextColor3 = Color3.new(1,1,1); btn.TextSize = 10; btn.Font = Enum.Font.GothamBold
    local page = Instance.new("ScrollingFrame", Pages); page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1; page.Visible = false; page.ScrollBarThickness = 2
    local layout = Instance.new("UIListLayout", page); layout.Padding = UDim.new(0,5); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() page.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 20) end)
    btn.MouseButton1Click:Connect(function() for _,v in pairs(Pages:GetChildren()) do v.Visible = false end; page.Visible = true end)
    return page, btn
end

local function CreateSection(parent, name)
    local sectionBtn = Instance.new("TextButton", parent); sectionBtn.Size = UDim2.new(1,-20,0,28); sectionBtn.Text = "[ " .. name .. " ]"; sectionBtn.BackgroundColor3 = Color3.fromRGB(25,25,25); sectionBtn.TextColor3 = Color3.fromRGB(200,200,200); sectionBtn.Font = Enum.Font.GothamBold; sectionBtn.TextSize = 11; Instance.new("UICorner", sectionBtn)
    local container = Instance.new("Frame", parent); container.Size = UDim2.new(1,0,0,0); container.AutomaticSize = Enum.AutomaticSize.Y; container.BackgroundTransparency = 1; container.Visible = false
    Instance.new("UIListLayout", container).Padding = UDim.new(0,5); container.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sectionBtn.MouseButton1Click:Connect(function() container.Visible = not container.Visible; sectionBtn.BackgroundColor3 = container.Visible and Color3.fromRGB(40,40,40) or Color3.fromRGB(25,25,25) end)
    return container
end

-- CONTROLE VISUAL
local VisualToggles = {}
local VisualSteppers = {}

local function CreateToggle(parent, text, callback, default)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1,-25,0,32); b.Text = text..": "..(default and "ON" or "OFF"); b.BackgroundColor3 = default and Color3.fromRGB(50,100,50) or Color3.fromRGB(30,30,30); b.TextColor3 = Color3.new(1,1,1); b.TextSize = 11; Instance.new("UICorner", b)
    local state = default or false
    
    VisualToggles[text] = function(v)
        state = v
        b.Text = text..": "..(state and "ON" or "OFF")
        b.BackgroundColor3 = state and Color3.fromRGB(50,100,50) or Color3.fromRGB(30,30,30)
        callback(state)
    end
    
    b.MouseButton1Click:Connect(function() VisualToggles[text](not state) end)
end

local function CreateStepper(parent, text, min, max, default, step, callback)
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(1,-25,0,55); frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame); label.Size = UDim2.new(1,0,0,20); label.Text = text..": "..default; label.TextColor3 = Color3.new(1,1,1); label.BackgroundTransparency = 1; label.TextSize = 11
    local minus = Instance.new("TextButton", frame); minus.Size = UDim2.new(0,35,0,25); minus.Position = UDim2.new(0,40,0,20); minus.Text = "-"; minus.BackgroundColor3 = Color3.fromRGB(40,40,40); minus.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", minus)
    local plus = Instance.new("TextButton", frame); plus.Size = UDim2.new(0,35,0,25); plus.Position = UDim2.new(0,140,0,20); plus.Text = "+"; plus.BackgroundColor3 = Color3.fromRGB(40,40,40); plus.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", plus)
    
    local val = default
    local function up(n) 
        val = math.clamp(n, min, max); label.Text = text..": "..string.format("%.2f", val); callback(val) 
    end
    VisualSteppers[text] = up
    
    minus.MouseButton1Click:Connect(function() up(val - step) end)
    plus.MouseButton1Click:Connect(function() up(val + step) end)
end

-- ABAS
local ESPPage = CreatePage("ESP")
local PlayerPage = CreatePage("PLAYER")
local TPPage = CreatePage("TP")
local MiraPage = CreatePage("MIRA")
local HitboxPage = CreatePage("HITBOX")
local PredPage = CreatePage("PRED")
local TestPage = CreatePage("TESTE") -- NOVA ABA
local FPSPage = CreatePage("FPS")
local InfoPage = CreatePage("INFOS")
ESPPage.Visible = true

-- SETUP ESP
CreateToggle(ESPPage, "ESP Geral", function(v) Settings.ESP = v end)
CreateToggle(ESPPage, "Team Color", function(v) Settings.TeamColor = v end)
CreateToggle(ESPPage, "Boxes", function(v) Settings.Boxes = v end)
CreateToggle(ESPPage, "Names", function(v) Settings.Names = v end)
CreateToggle(ESPPage, "Distance", function(v) Settings.Distance = v end)
CreateToggle(ESPPage, "Lines", function(v) Settings.Lines = v end)
CreateToggle(ESPPage, "Chams", function(v) Settings.Highlight = v end)

-- SETUP PLAYER
CreateToggle(PlayerPage, "Third Person", function(v) Settings.ForceThirdPerson = v end)
CreateToggle(PlayerPage, "Velocidade", function(v) Settings.UseSpeed = v end)
CreateStepper(PlayerPage, "Speed", 16, 500, 16, 5, function(v) Settings.Speed = v end)
CreateToggle(PlayerPage, "Pulo Infinito", function(v) Settings.InfiniteJump = v end)

-- SETUP TP
local SecSel = CreateSection(TPPage, "SELEÇÃO"); local SecAct = CreateSection(TPPage, "AÇÕES")
local SelLab = Instance.new("TextLabel", SecSel); SelLab.Size = UDim2.new(1,-20,0,30); SelLab.Text = "Alvo: Nenhum"; SelLab.TextColor3 = Color3.new(0,1,0); SelLab.BackgroundTransparency = 1; SelLab.TextSize = 11
local PListF = Instance.new("Frame", SecSel); PListF.Size = UDim2.new(1,-20,0,100); PListF.BackgroundColor3 = Color3.fromRGB(20,20,20)
local PLScr = Instance.new("ScrollingFrame", PListF); PLScr.Size = UDim2.new(1,0,1,0); PLScr.BackgroundTransparency = 1; PLScr.ScrollBarThickness = 2; Instance.new("UIListLayout", PLScr).Padding = UDim.new(0,2)
local function UpList() for _,v in pairs(PLScr:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end; for _,p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then local b = Instance.new("TextButton", PLScr); b.Size = UDim2.new(1,0,0,25); b.Text = p.DisplayName; b.BackgroundColor3 = Color3.fromRGB(35,35,35); b.TextColor3 = Color3.new(1,1,1); b.TextSize = 10; b.MouseButton1Click:Connect(function() Settings.SelectedPlayer = p; SelLab.Text = "Alvo: "..p.DisplayName end) end end; PLScr.CanvasSize = UDim2.new(0,0,0,PLScr.UIListLayout.AbsoluteContentSize.Y) end
Players.PlayerAdded:Connect(UpList); Players.PlayerRemoving:Connect(UpList); UpList()
local TpBtn = Instance.new("TextButton", SecAct); TpBtn.Size = UDim2.new(1,-20,0,35); TpBtn.Text = "TELEPORTAR (CLIQUE)"; TpBtn.BackgroundColor3 = Color3.fromRGB(0,80,150); TpBtn.TextColor3 = Color3.new(1,1,1); TpBtn.TextSize = 11; Instance.new("UICorner", TpBtn); TpBtn.MouseButton1Click:Connect(function() if Settings.SelectedPlayer and Settings.SelectedPlayer.Character then LocalPlayer.Character.HumanoidRootPart.CFrame = Settings.SelectedPlayer.Character.HumanoidRootPart.CFrame end end)
CreateToggle(SecSel, "Auto Próximo", function(v) Settings.AutoNearest = v end)
CreateToggle(SecAct, "Grudar Atrás", function(v) Settings.StickyBehind = v end)
CreateStepper(SecAct, "Suavidade", 0.01, 1, 0.1, 0.05, function(v) Settings.StickySmoothness = v end)
CreateStepper(SecAct, "Distância", 1, 20, 3, 1, function(v) Settings.StickyDistance = v end)

-- SETUP MIRA
CreateToggle(MiraPage, "Auxílio de Mira", function(v) Settings.AimAssist = v end)
local PartBtn = Instance.new("TextButton", MiraPage); PartBtn.Size = UDim2.new(1,-25,0,32); PartBtn.Text = "Alvo: Cabeça"; PartBtn.BackgroundColor3 = Color3.fromRGB(30,30,30); PartBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", PartBtn)
PartBtn.MouseButton1Click:Connect(function() Settings.AimPart = (Settings.AimPart == "Head" and "HumanoidRootPart" or "Head"); PartBtn.Text = "Alvo: "..(Settings.AimPart == "Head" and "Cabeça" or "Tronco") end)
CreateToggle(MiraPage, "Mira em NPC", function(v) Settings.AimNPC = v end)
CreateToggle(MiraPage, "Team Check", function(v) Settings.TeamCheck = v end)
CreateToggle(MiraPage, "Wall Check", function(v) Settings.WallCheck = v end)
CreateToggle(MiraPage, "Exibir FOV", function(v) Settings.ShowFOV = v end)
CreateStepper(MiraPage, "Tamanho FOV", 10, 800, 100, 10, function(v) Settings.AimFOV = v end)
CreateStepper(MiraPage, "Suavidade", 0.01, 1, 0.1, 0.05, function(v) Settings.AimSmooth = v end)

-- SETUP HITBOX E FPS
CreateToggle(HitboxPage, "Enabled", function(v) Settings.HitboxEnabled = v end)
CreateStepper(HitboxPage, "Tamanho", 2, 100, 20, 5, function(v) Settings.Hitbox = v end)
CreateStepper(HitboxPage, "Opacidade", 0, 1, 0.6, 0.1, function(v) Settings.HitboxTransparency = v end)
CreateToggle(FPSPage, "Otimizar Texturas", function(v) Settings.BoostFPS = v; for _,o in pairs(game:GetDescendants()) do if o:IsA("Texture") or o:IsA("Decal") then o.Transparency = v and 1 or 0 end end end)
CreateToggle(FPSPage, "Remover Sombras", function(v) Lighting.GlobalShadows = not v end)
CreateStepper(FPSPage, "Limite FPS", 30, 240, 120, 30, function(v) if setfpscap then setfpscap(v) end end)

-- SETUP ABA TESTE E TROLL (NOVO)
local SecTestConfigs = CreateSection(TestPage, "CONFIGURAÇÕES")
local SecTestVisuals = CreateSection(TestPage, "VISUAIS & COMBATE")
local SecTestTroll = CreateSection(TestPage, "TROLL")

-- Save/Load System
local BtnSave = Instance.new("TextButton", SecTestConfigs); BtnSave.Size = UDim2.new(1,-25,0,32); BtnSave.Text = "SALVAR CONFIGURAÇÕES"; BtnSave.BackgroundColor3 = Color3.fromRGB(0, 100, 50); BtnSave.TextColor3 = Color3.new(1,1,1); BtnSave.TextSize = 11; Instance.new("UICorner", BtnSave)
local BtnLoad = Instance.new("TextButton", SecTestConfigs); BtnLoad.Size = UDim2.new(1,-25,0,32); BtnLoad.Text = "CARREGAR CONFIGURAÇÕES"; BtnLoad.BackgroundColor3 = Color3.fromRGB(0, 80, 150); BtnLoad.TextColor3 = Color3.new(1,1,1); BtnLoad.TextSize = 11; Instance.new("UICorner", BtnLoad)

BtnSave.MouseButton1Click:Connect(function()
    if writefile then 
        writefile("KikoMenuConfig.json", HttpService:JSONEncode(Settings))
        BtnSave.Text = "SALVO COM SUCESSO!"; task.wait(1); BtnSave.Text = "SALVAR CONFIGURAÇÕES"
    end
end)
BtnLoad.MouseButton1Click:Connect(function()
    if readfile and isfile and isfile("KikoMenuConfig.json") then
        local success, decoded = pcall(function() return HttpService:JSONDecode(readfile("KikoMenuConfig.json")) end)
        if success then 
            for k, v in pairs(decoded) do Settings[k] = v end
            BtnLoad.Text = "CARREGADO!"; task.wait(1); BtnLoad.Text = "CARREGAR CONFIGURAÇÕES"
        end
    end
end)

CreateToggle(SecTestVisuals, "Skeleton ESP", function(v) Settings.SkeletonESP = v end)
CreateToggle(SecTestVisuals, "Outline Chams", function(v) Settings.OutlineChams = v end)
CreateToggle(SecTestVisuals, "No Spread", function(v) Settings.NoSpread = v end) -- Requer script custom para funcionar de verdade

CreateToggle(SecTestTroll, "Fling Player", function(v) Settings.Fling = v end)
CreateToggle(SecTestTroll, "Anti Fling", function(v) Settings.AntiFling = v end)
CreateToggle(SecTestTroll, "Fake Lag", function(v) Settings.FakeLag = v end)


local LogLabel = Instance.new("TextLabel", InfoPage); LogLabel.Size = UDim2.new(1,-20,0,0); LogLabel.AutomaticSize = Enum.AutomaticSize.Y; LogLabel.BackgroundTransparency = 1; LogLabel.TextColor3 = Color3.fromRGB(200,200,200); LogLabel.TextSize = 11; LogLabel.Font = Enum.Font.Code; LogLabel.Text = CHANGELOG_TEXT; LogLabel.TextXAlignment = Enum.TextXAlignment.Left; LogLabel.TextWrapped = true

-- LÓGICA ESP E LIMPEZA ANTI-GHOST (ATUALIZADA COM SKELETON)
local ESPContainer = {}

local function CreateSkeletonLines()
    local lines = {}
    for i=1, 12 do 
        local l = Drawing.new("Line"); l.Thickness = 1; l.Visible = false; l.Color = Color3.new(1,1,1)
        table.insert(lines, l)
    end
    return lines
end

local function RemoveESP(p)
    if ESPContainer[p] then
        if ESPContainer[p].Box then ESPContainer[p].Box:Remove() end
        if ESPContainer[p].Name then ESPContainer[p].Name:Remove() end
        if ESPContainer[p].Dist then ESPContainer[p].Dist:Remove() end
        if ESPContainer[p].Line then ESPContainer[p].Line:Remove() end
        if ESPContainer[p].Highlight then ESPContainer[p].Highlight:Destroy() end
        if ESPContainer[p].Skeleton then for _, l in pairs(ESPContainer[p].Skeleton) do l:Remove() end end
        ESPContainer[p] = nil
    end
end

local function CreateESP(p)
    if p == LocalPlayer then return end
    RemoveESP(p)
    ESPContainer[p] = {
        Box = Drawing.new("Square"), Name = Drawing.new("Text"), Dist = Drawing.new("Text"),
        Line = Drawing.new("Line"), Highlight = nil, Skeleton = CreateSkeletonLines()
    }
    local e = ESPContainer[p]
    e.Box.Thickness = 1.5; e.Box.Filled = false
    e.Name.Size = 14; e.Name.Center = true; e.Name.Outline = true
    e.Dist.Size = 12; e.Dist.Center = true; e.Dist.Outline = true
    e.Line.Thickness = 1
end

Players.PlayerAdded:Connect(CreateESP); Players.PlayerRemoving:Connect(RemoveESP)
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end

-- LÓGICA DE WALLCHECK E NPC CACHE
local function IsVisible(part)
    if not Settings.WallCheck then return true end
    local castPoints = {Camera.CFrame.Position, part.Position}
    local ignoreList = {LocalPlayer.Character, part.Parent}
    local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances = ignoreList
    local result = workspace:Raycast(castPoints[1], (castPoints[2] - castPoints[1]).Unit * (castPoints[1] - castPoints[2]).Magnitude, params)
    return result == nil
end

local NPCCache = {}
task.spawn(function()
    while true do
        if Settings.AimNPC then
            local tempCache = {}
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 1 and not Players:GetPlayerFromCharacter(obj) then
                    table.insert(tempCache, obj)
                end
            end
            NPCCache = tempCache
        else NPCCache = {} end
        task.wait(2)
    end
end)

-- RENDER LOOP PRINCIPAL
local fakeLagTick = 0
local FlingVelocity = nil

RunService.RenderStepped:Connect(function()
    FPSLabel.Text = "FPS: " .. math.floor(1/RunService.RenderStepped:Wait())
    FOVCircle.Visible = Settings.ShowFOV; FOVCircle.Radius = Settings.AimFOV; FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2); FOVCircle.Color = stroke.Color; FOVCircle.Thickness = 1.2; FOVCircle.Filled = false

    -- LÓGICA FLING
    if Settings.Fling and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        if not FlingVelocity then
            FlingVelocity = Instance.new("BodyAngularVelocity")
            FlingVelocity.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            FlingVelocity.AngularVelocity = Vector3.new(0, 99999, 0)
            FlingVelocity.Parent = hrp
        end
        if Settings.SelectedPlayer and Settings.SelectedPlayer.Character and Settings.SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = Settings.SelectedPlayer.Character.HumanoidRootPart.CFrame
        end
    else
        if FlingVelocity then FlingVelocity:Destroy(); FlingVelocity = nil end
    end

    -- LÓGICA FAKE LAG
    if Settings.FakeLag and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        fakeLagTick = fakeLagTick + 1
        if fakeLagTick % 15 == 0 then
            LocalPlayer.Character.HumanoidRootPart.Anchored = true
            task.delay(0.05, function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.Anchored = false end end)
        end
    end

    if Settings.AimAssist then
        local target, minDist = nil, Settings.AimFOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Settings.AimPart) then
                local humanoid = p.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 1 then
                    if Settings.TeamCheck and p.Team == LocalPlayer.Team then continue end
                    local part = p.Character[Settings.AimPart]
                    local pos, vis = Camera:WorldToViewportPoint(part.Position)
                    if vis and IsVisible(part) then
                        local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if mag < minDist then minDist, target = mag, part end
                    end
                end
            end
        end
        if Settings.AimNPC then
            for _, obj in pairs(NPCCache) do
                if obj and obj.Parent and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 1 then
                    local part = obj:FindFirstChild(Settings.AimPart) or obj:FindFirstChild("HumanoidRootPart")
                    if part then
                        local pos, vis = Camera:WorldToViewportPoint(part.Position)
                        if vis and IsVisible(part) then
                            local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                            if mag < minDist then minDist, target = mag, part end
                        end
                    end
                end
            end
        end
        if target then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Settings.AimSmooth) end
    end

    if Settings.StickyBehind and Settings.SelectedPlayer and Settings.SelectedPlayer.Character then
        local hrp = Settings.SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame:Lerp(hrp.CFrame * CFrame.new(0, 0, Settings.StickyDistance), Settings.StickySmoothness) end
    end
    
    if Settings.ForceThirdPerson then LocalPlayer.CameraMode = Enum.CameraMode.Classic; LocalPlayer.CameraMaxZoomDistance = 100 else LocalPlayer.CameraMaxZoomDistance = 128 end
    if Settings.UseSpeed and LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = Settings.Speed end

    for p, e in pairs(ESPContainer) do
        if not p or not p.Parent or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then
            e.Box.Visible = false; e.Name.Visible = false; e.Dist.Visible = false; e.Line.Visible = false
            if e.Highlight then e.Highlight.Enabled = false end
            for _, l in pairs(e.Skeleton) do l.Visible = false end
            continue
        end

        -- Lógica Anti Fling (Impede que players colidam com você)
        if Settings.AntiFling and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.CanCollide = false
        end

        local hrp = p.Character.HumanoidRootPart; local head = p.Character:FindFirstChild("Head")
        local pos, vis = Camera:WorldToViewportPoint(hrp.Position)
        local color = (Settings.TeamColor and p.TeamColor) and p.TeamColor.Color or Color3.new(1,1,1)

        if Settings.ESP and vis then
            if Settings.Boxes then e.Box.Visible = true; e.Box.Size = Vector2.new(2500/pos.Z, 3500/pos.Z); e.Box.Position = Vector2.new(pos.X - e.Box.Size.X/2, pos.Y - e.Box.Size.Y/2); e.Box.Color = color else e.Box.Visible = false end
            if Settings.Names then e.Name.Visible = true; e.Name.Text = p.DisplayName; e.Name.Position = Vector2.new(pos.X, pos.Y - (2000/pos.Z) - 20); e.Name.Color = color else e.Name.Visible = false end
            if Settings.Distance then e.Dist.Visible = true; e.Dist.Text = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude).."m"; e.Dist.Position = Vector2.new(pos.X, pos.Y + (2000/pos.Z) + 5); e.Dist.Color = Color3.new(0,1,0) else e.Dist.Visible = false end
            if Settings.Lines and head then local headPos = Camera:WorldToViewportPoint(head.Position); e.Line.Visible = true; e.Line.From = Vector2.new(Camera.ViewportSize.X/2, 0); e.Line.To = Vector2.new(headPos.X, headPos.Y); e.Line.Color = color else e.Line.Visible = false end
            
            if Settings.Highlight then
                if not e.Highlight or e.Highlight.Parent ~= p.Character then if e.Highlight then e.Highlight:Destroy() end e.Highlight = Instance.new("Highlight", p.Character) end
                e.Highlight.Enabled = true; e.Highlight.FillColor = color; e.Highlight.FillTransparency = 0.5
                e.Highlight.OutlineColor = color
                -- Nova Lógica Outline Chams
                e.Highlight.OutlineTransparency = Settings.OutlineChams and 0 or 1
            elseif e.Highlight then e.Highlight.Enabled = false end
            
            -- Lógica Skeleton ESP Básica
            if Settings.SkeletonESP then
                local joints = {
                    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, 
                    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
                    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
                    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
                    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
                }
                
                -- Fallback para R6
                if not p.Character:FindFirstChild("UpperTorso") then
                    joints = {
                        {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
                        {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
                    }
                end

                for i, l in ipairs(e.Skeleton) do
                    local joint = joints[i]
                    if joint and p.Character:FindFirstChild(joint[1]) and p.Character:FindFirstChild(joint[2]) then
                        local p1, v1 = Camera:WorldToViewportPoint(p.Character[joint[1]].Position)
                        local p2, v2 = Camera:WorldToViewportPoint(p.Character[joint[2]].Position)
                        if v1 and v2 then
                            l.Visible = true; l.From = Vector2.new(p1.X, p1.Y); l.To = Vector2.new(p2.X, p2.Y); l.Color = color
                        else l.Visible = false end
                    else l.Visible = false end
                end
            else
                for _, l in pairs(e.Skeleton) do l.Visible = false end
            end
        else 
            e.Box.Visible = false; e.Name.Visible = false; e.Dist.Visible = false; e.Line.Visible = false; if e.Highlight then e.Highlight.Enabled = false end 
            for _, l in pairs(e.Skeleton) do l.Visible = false end
        end
    end
end)

task.spawn(function() while true do for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local hrp = p.Character.HumanoidRootPart; if Settings.HitboxEnabled then hrp.Size = Vector3.new(Settings.Hitbox, Settings.Hitbox, Settings.Hitbox); hrp.Transparency = Settings.HitboxTransparency; hrp.CanCollide = false else hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 1 end end end; task.wait(0.1) end end)
UIS.JumpRequest:Connect(function() if Settings.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid:ChangeState("Jumping") end end)

ToggleBtn.MouseButton1Up:Connect(function() 
    if Main.Visible then 
        MenuAberto = false; local tw = TweenInfo.new(0.3); local anim = TweenService:Create(Main, tw, {Size = UDim2.new(0, 280, 0, 0), BackgroundTransparency = 1}); anim:Play(); anim.Completed:Connect(function() Main.Visible = false end)
    else 
        MenuAberto = true; Main.Visible = true; Title.TextTransparency = 0; Main.Position = UDim2.new(0.5, -140, 0.5, -160)
        TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Elastic), {Size = UDim2.new(0, 280, 0, 320), BackgroundTransparency = 0.1}):Play()
    end
end)
