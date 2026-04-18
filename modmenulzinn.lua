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
    HitboxEnabled = false, Hitbox = 20, HitboxTransparency = 0.6, HitboxNPC = false,
    UseSpeed = false, Speed = 16, UseJump = false, JumpPower = 50, InfiniteJump = false,
    ForceThirdPerson = false, BoostFPS = false, RemoveShadows = false,
    SelectedPlayer = nil, AutoNearest = false, StickyBehind = false, StickySmoothness = 0.1, StickyDistance = 3,
    AimAssist = false, AimPart = "Head", AimFOV = 100, AimSmooth = 0.1, ShowFOV = false, WallCheck = false, TeamCheck = false,
    AimNPC = false, ESPNPC = false, SkeletonESP = false,
    
    -- NOVAS CONFIGS
    TargetPriority = false, PriorityMode = "Distância", Priority360 = true,
    UITheme = "Escuro", BorderColor = "Roxo", RGBBorder = false
}

local VERSION = "v6.5.0"
local CHANGELOG_TEXT = [[
--- NOVIDADES v6.5.0 ---
[+] MIRA: Target Priority (Distância, Menor HP, Mirando em Mim).
[+] MIRA: Detecção 360 graus para o Target Priority.
[+] MENU: Barra de pesquisa integrada (busca rápida de funções).
[+] NOVA ABA 'UI': Temas Escuro/Claro e customização da cor da borda (incluindo RGB).
-------------------------
--- NOVIDADES v6.4.0 ---
[+] ESP: Suporte completo e Hitbox Expander para NPCs.
-------------------------]]

local MenuAberto = false
local FOVCircle = Drawing.new("Circle")

--// GUI PRINCIPAL
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

--// SISTEMA DE NOTIFICAÇÕES
local NotifContainer = Instance.new("Frame", ScreenGui)
NotifContainer.Size = UDim2.new(0, 200, 0.5, 0); NotifContainer.Position = UDim2.new(0.5, -100, 0.05, 0); NotifContainer.BackgroundTransparency = 1
local NotifLayout = Instance.new("UIListLayout", NotifContainer); NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder; NotifLayout.Padding = UDim.new(0, 5); NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local function SendNotification(text, state)
    local color = state and Color3.new(0, 1, 0) or Color3.new(1, 0.2, 0.2)
    local notif = Instance.new("TextLabel", NotifContainer)
    notif.Size = UDim2.new(1, 0, 0, 25); notif.BackgroundColor3 = Color3.fromRGB(20, 20, 20); notif.TextColor3 = color; notif.Text = text; notif.Font = Enum.Font.GothamBold; notif.TextSize = 11; notif.BackgroundTransparency = 1; notif.TextTransparency = 1; Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 4)
    local stroke = Instance.new("UIStroke", notif); stroke.Thickness = 1; stroke.Color = color; stroke.Transparency = 1
    TweenService:Create(notif, TweenInfo.new(0.2), {BackgroundTransparency = 0.2, TextTransparency = 0}):Play(); TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
    task.delay(1.5, function()
        local tOut = TweenService:Create(notif, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1})
        TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 1}):Play(); tOut:Play()
        tOut.Completed:Connect(function() notif:Destroy() end)
    end)
end

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

local ToggleBtn = Instance.new("ImageButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0,45,0,45); ToggleBtn.Position = UDim2.new(1,-65,0,15); ToggleBtn.BackgroundColor3 = Color3.fromRGB(20,20,20); ToggleBtn.Image = "rbxassetid://70505361093133"
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1,0); MakeDraggable(ToggleBtn, false)

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,280,0,360) -- Aumentado para caber a barra de pesquisa
Main.Position = UDim2.new(0.5, -140, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(10,10,10); Main.ClipsDescendants = true; Main.Visible = false; Main.BackgroundTransparency = 1
Instance.new("UICorner", Main); MakeDraggable(Main, true)
local stroke = Instance.new("UIStroke", Main); stroke.Thickness = 2; stroke.Transparency = 1; stroke.Color = Color3.fromRGB(150, 0, 255)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,35); Title.BackgroundTransparency = 1; Title.TextSize = 16; Title.Font = Enum.Font.Code; Title.TextTransparency = 0; Title.TextColor3 = Color3.fromRGB(150, 0, 255)

local FPSLabel = Instance.new("TextLabel", Main); FPSLabel.Size = UDim2.new(0,50,0,35); FPSLabel.Position = UDim2.new(1,-60,0,0); FPSLabel.Text = "FPS: 0"; FPSLabel.BackgroundTransparency = 1; FPSLabel.TextColor3 = Color3.new(0,1,0); FPSLabel.TextSize = 11; FPSLabel.Font = Enum.Font.Code; FPSLabel.TextTransparency = 1

--// BARRA DE PESQUISA (NOVO)
local SearchBar = Instance.new("TextBox", Main)
SearchBar.Size = UDim2.new(1, -20, 0, 25); SearchBar.Position = UDim2.new(0, 10, 0, 35)
SearchBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); SearchBar.TextColor3 = Color3.new(1,1,1); SearchBar.PlaceholderText = "🔍 Buscar função..."
SearchBar.Text = ""; SearchBar.Font = Enum.Font.Gotham; SearchBar.TextSize = 11
Instance.new("UICorner", SearchBar).CornerRadius = UDim.new(0, 4)

local SearchCache = {} -- Armazena itens para o sistema de pesquisa

-- ABAS E LAYOUT AJUSTADO
local TabsFrame = Instance.new("ScrollingFrame", Main); TabsFrame.Size = UDim2.new(1,0,0,35); TabsFrame.Position = UDim2.new(0,0,0,65); TabsFrame.BackgroundTransparency = 1; TabsFrame.ScrollBarThickness = 0; TabsFrame.CanvasSize = UDim2.new(0,0,0,0)
local TabList = Instance.new("UIListLayout", TabsFrame); TabList.FillDirection = Enum.FillDirection.Horizontal
TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() TabsFrame.CanvasSize = UDim2.new(0, TabList.AbsoluteContentSize.X, 0, 0) end)
local Pages = Instance.new("Frame", Main); Pages.Position = UDim2.new(0,0,0,100); Pages.Size = UDim2.new(1,0,1,-100); Pages.BackgroundTransparency = 1

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
    table.insert(SearchCache, {Element = sectionBtn, Name = name, Container = container})
    return container
end

-- CONTROLES VISUAIS
local VisualToggles = {}; local VisualSteppers = {}

local function CreateToggle(parent, text, callback, default)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1,-25,0,32); b.Text = text..": "..(default and "ON" or "OFF"); b.BackgroundColor3 = default and Color3.fromRGB(50,100,50) or Color3.fromRGB(30,30,30); b.TextColor3 = Color3.new(1,1,1); b.TextSize = 11; Instance.new("UICorner", b)
    local state = default or false
    VisualToggles[text] = function(v)
        state = v; b.Text = text..": "..(state and "ON" or "OFF"); b.BackgroundColor3 = state and Color3.fromRGB(50,100,50) or Color3.fromRGB(30,30,30); callback(state)
    end
    b.MouseButton1Click:Connect(function() VisualToggles[text](not state) end)
    table.insert(SearchCache, {Element = b, Name = text, Type = "Toggle", Parent = parent})
    return b
end

local function CreateStepper(parent, text, min, max, default, step, callback)
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(1,-25,0,55); frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame); label.Size = UDim2.new(1,0,0,20); label.Text = text..": "..default; label.TextColor3 = Color3.new(1,1,1); label.BackgroundTransparency = 1; label.TextSize = 11
    local minus = Instance.new("TextButton", frame); minus.Size = UDim2.new(0,35,0,25); minus.Position = UDim2.new(0,40,0,20); minus.Text = "-"; minus.BackgroundColor3 = Color3.fromRGB(40,40,40); minus.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", minus)
    local plus = Instance.new("TextButton", frame); plus.Size = UDim2.new(0,35,0,25); plus.Position = UDim2.new(0,140,0,20); plus.Text = "+"; plus.BackgroundColor3 = Color3.fromRGB(40,40,40); plus.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", plus)
    local val = default
    local function up(n) val = math.clamp(n, min, max); label.Text = text..": "..string.format("%.2f", val); callback(val) end
    VisualSteppers[text] = up
    minus.MouseButton1Click:Connect(function() up(val - step) end)
    plus.MouseButton1Click:Connect(function() up(val + step) end)
    table.insert(SearchCache, {Element = frame, Name = text, Type = "Stepper", Parent = parent})
end

-- NOVO: CYCLER / DROPDOWN (Usado para os Temas e Priority)
local function CreateCycler(parent, text, options, default, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1,-25,0,32); b.BackgroundColor3 = Color3.fromRGB(40,40,80); b.TextColor3 = Color3.new(1,1,1); b.TextSize = 11; Instance.new("UICorner", b)
    local currentIndex = 1
    for i, v in ipairs(options) do if v == default then currentIndex = i break end end
    b.Text = text .. ": " .. options[currentIndex]
    b.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #options then currentIndex = 1 end
        b.Text = text .. ": " .. options[currentIndex]
        callback(options[currentIndex])
    end)
    table.insert(SearchCache, {Element = b, Name = text, Type = "Cycler", Parent = parent})
end

-- LÓGICA DE BUSCA
SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
    local q = string.lower(SearchBar.Text)
    for _, item in pairs(SearchCache) do
        if q == "" then
            item.Element.Visible = true
        elseif string.find(string.lower(item.Name), q) then
            item.Element.Visible = true
            if item.Parent and item.Parent.Name ~= "Main" then item.Parent.Visible = true end -- Abre as seções/abas se achar algo
        else
            item.Element.Visible = false
        end
    end
end)

-- ABAS
local ESPPage = CreatePage("ESP")
local PlayerPage = CreatePage("PLAYER")
local TPPage = CreatePage("TP")
local MiraPage = CreatePage("MIRA")
local HitboxPage = CreatePage("HITBOX")
local PredPage = CreatePage("PRED")
local UIPage = CreatePage("UI") -- NOVA ABA
local FPSPage = CreatePage("FPS")
local InfoPage = CreatePage("INFOS")
ESPPage.Visible = true

-- SETUP ESP E OUTROS
CreateToggle(ESPPage, "ESP Geral (Players)", function(v) Settings.ESP = v end)
CreateToggle(ESPPage, "ESP NPC", function(v) Settings.ESPNPC = v end)
CreateToggle(ESPPage, "Skeleton ESP", function(v) Settings.SkeletonESP = v end)
CreateToggle(ESPPage, "Team Color", function(v) Settings.TeamColor = v end)
CreateToggle(ESPPage, "Boxes", function(v) Settings.Boxes = v end)
CreateToggle(ESPPage, "Names", function(v) Settings.Names = v end)
CreateToggle(ESPPage, "Distance", function(v) Settings.Distance = v end)
CreateToggle(ESPPage, "Lines", function(v) Settings.Lines = v end)
CreateToggle(ESPPage, "Chams", function(v) Settings.Highlight = v end)

CreateToggle(PlayerPage, "Third Person", function(v) Settings.ForceThirdPerson = v end)
CreateToggle(PlayerPage, "Velocidade", function(v) Settings.UseSpeed = v end)
CreateStepper(PlayerPage, "Speed", 16, 500, 16, 5, function(v) Settings.Speed = v end)
CreateToggle(PlayerPage, "Pulo Infinito", function(v) Settings.InfiniteJump = v end)

local SecSel = CreateSection(TPPage, "SELEÇÃO"); local SecAct = CreateSection(TPPage, "AÇÕES")
local SelLab = Instance.new("TextLabel", SecSel); SelLab.Size = UDim2.new(1,-20,0,30); SelLab.Text = "Alvo: Nenhum"; SelLab.TextColor3 = Color3.new(0,1,0); SelLab.BackgroundTransparency = 1; SelLab.TextSize = 11
local PListF = Instance.new("Frame", SecSel); PListF.Size = UDim2.new(1,-20,0,100); PListF.BackgroundColor3 = Color3.fromRGB(20,20,20)
local PLScr = Instance.new("ScrollingFrame", PListF); PLScr.Size = UDim2.new(1,0,1,0); PLScr.BackgroundTransparency = 1; PLScr.ScrollBarThickness = 2; Instance.new("UIListLayout", PLScr).Padding = UDim.new(0,2)
local function UpList() for _,v in pairs(PLScr:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end; for _,p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then local b = Instance.new("TextButton", PLScr); b.Size = UDim2.new(1,0,0,25); b.Text = p.DisplayName; b.BackgroundColor3 = Color3.fromRGB(35,35,35); b.TextColor3 = Color3.new(1,1,1); b.TextSize = 10; b.MouseButton1Click:Connect(function() Settings.SelectedPlayer = p; SelLab.Text = "Alvo: "..p.DisplayName end) end end; PLScr.CanvasSize = UDim2.new(0,0,0,PLScr.UIListLayout.AbsoluteContentSize.Y) end
Players.PlayerAdded:Connect(UpList); Players.PlayerRemoving:Connect(UpList); UpList()
local TpBtn = Instance.new("TextButton", SecAct); TpBtn.Size = UDim2.new(1,-20,0,35); TpBtn.Text = "TELEPORTAR (CLIQUE)"; TpBtn.BackgroundColor3 = Color3.fromRGB(0,80,150); TpBtn.TextColor3 = Color3.new(1,1,1); TpBtn.TextSize = 11; Instance.new("UICorner", TpBtn); TpBtn.MouseButton1Click:Connect(function() if Settings.SelectedPlayer and Settings.SelectedPlayer.Character then LocalPlayer.Character.HumanoidRootPart.CFrame = Settings.SelectedPlayer.Character.HumanoidRootPart.CFrame end end)
CreateToggle(SecAct, "Grudar Atrás", function(v) Settings.StickyBehind = v end)

-- SETUP MIRA E TARGET PRIORITY (NOVO)
local SecAimMain = CreateSection(MiraPage, "PRINCIPAL")
local SecAimPrio = CreateSection(MiraPage, "TARGET PRIORITY")

CreateToggle(SecAimMain, "Auxílio de Mira", function(v) Settings.AimAssist = v end)
local PartBtn = Instance.new("TextButton", SecAimMain); PartBtn.Size = UDim2.new(1,-25,0,32); PartBtn.Text = "Alvo: Cabeça"; PartBtn.BackgroundColor3 = Color3.fromRGB(30,30,30); PartBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", PartBtn)
PartBtn.MouseButton1Click:Connect(function() Settings.AimPart = (Settings.AimPart == "Head" and "HumanoidRootPart" or "Head"); PartBtn.Text = "Alvo: "..(Settings.AimPart == "Head" and "Cabeça" or "Tronco") end)
CreateToggle(SecAimMain, "Mira em NPC", function(v) Settings.AimNPC = v end)
CreateToggle(SecAimMain, "Exibir FOV", function(v) Settings.ShowFOV = v end)
CreateStepper(SecAimMain, "Tamanho FOV", 10, 800, 100, 10, function(v) Settings.AimFOV = v end)

CreateToggle(SecAimPrio, "Ativar Target Priority", function(v) Settings.TargetPriority = v end)
CreateToggle(SecAimPrio, "Detecção 360º (Ignorar FOV)", function(v) Settings.Priority360 = v end, true)
CreateCycler(SecAimPrio, "Modo de Prioridade", {"Distância", "Menor HP", "Mirando em Mim"}, "Distância", function(v) Settings.PriorityMode = v end)

-- SETUP UI (NOVO)
local SecUITheme = CreateSection(UIPage, "TEMA E CORES")
CreateCycler(SecUITheme, "Tema do Menu", {"Escuro", "Claro"}, "Escuro", function(v)
    Settings.UITheme = v
    if v == "Claro" then
        Main.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
        SearchBar.BackgroundColor3 = Color3.fromRGB(200, 200, 200); SearchBar.TextColor3 = Color3.new(0,0,0)
    else
        Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        SearchBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); SearchBar.TextColor3 = Color3.new(1,1,1)
    end
end)
CreateCycler(SecUITheme, "Cor da Borda", {"Roxo", "Vermelho", "Azul", "Verde", "RGB"}, "Roxo", function(v)
    Settings.BorderColor = v
    Settings.RGBBorder = (v == "RGB")
    if v == "Roxo" then stroke.Color = Color3.fromRGB(150, 0, 255); Title.TextColor3 = Color3.fromRGB(150, 0, 255)
    elseif v == "Vermelho" then stroke.Color = Color3.fromRGB(255, 50, 50); Title.TextColor3 = Color3.fromRGB(255, 50, 50)
    elseif v == "Azul" then stroke.Color = Color3.fromRGB(50, 150, 255); Title.TextColor3 = Color3.fromRGB(50, 150, 255)
    elseif v == "Verde" then stroke.Color = Color3.fromRGB(50, 255, 50); Title.TextColor3 = Color3.fromRGB(50, 255, 50)
    end
end)

-- HITBOX E FPS
CreateToggle(HitboxPage, "Hitbox Players", function(v) Settings.HitboxEnabled = v end)
CreateToggle(HitboxPage, "Hitbox NPC", function(v) Settings.HitboxNPC = v end)
CreateStepper(HitboxPage, "Tamanho", 2, 100, 20, 5, function(v) Settings.Hitbox = v end)
CreateToggle(FPSPage, "Otimizar Texturas", function(v) Settings.BoostFPS = v; for _,o in pairs(game:GetDescendants()) do if o:IsA("Texture") or o:IsA("Decal") then o.Transparency = v and 1 or 0 end end end)

local LogLabel = Instance.new("TextLabel", InfoPage); LogLabel.Size = UDim2.new(1,-20,0,0); LogLabel.AutomaticSize = Enum.AutomaticSize.Y; LogLabel.BackgroundTransparency = 1; LogLabel.TextColor3 = Color3.fromRGB(200,200,200); LogLabel.TextSize = 11; LogLabel.Font = Enum.Font.Code; LogLabel.Text = CHANGELOG_TEXT; LogLabel.TextXAlignment = Enum.TextXAlignment.Left; LogLabel.TextWrapped = true

-- LÓGICA DE CACHE NPC E VISIBILIDADE
local function IsVisible(part)
    if not Settings.WallCheck then return true end
    local castPoints = {Camera.CFrame.Position, part.Position}; local ignoreList = {LocalPlayer.Character, part.Parent}
    local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances = ignoreList
    return workspace:Raycast(castPoints[1], (castPoints[2] - castPoints[1]).Unit * (castPoints[1] - castPoints[2]).Magnitude, params) == nil
end

local NPCCache = {}
task.spawn(function()
    while true do
        if Settings.AimNPC or Settings.ESPNPC or Settings.HitboxNPC then
            local tempCache = {}
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 1 and not Players:GetPlayerFromCharacter(obj) then table.insert(tempCache, obj) end
            end
            NPCCache = tempCache
        else NPCCache = {} end
        task.wait(2)
    end
end)

-- RENDER LOOP PRINCIPAL (AIMBOT, ESP E RGB BORDER)
RunService.RenderStepped:Connect(function()
    FPSLabel.Text = "FPS: " .. math.floor(1/RunService.RenderStepped:Wait())
    FOVCircle.Visible = Settings.ShowFOV; FOVCircle.Radius = Settings.AimFOV; FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2); FOVCircle.Color = stroke.Color; FOVCircle.Thickness = 1.2; FOVCircle.Filled = false

    -- Lógica de Cor RGB na Borda
    if Settings.RGBBorder then
        local rgbColor = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        stroke.Color = rgbColor
        Title.TextColor3 = rgbColor
    end

    -- LÓGICA AIMBOT COM TARGET PRIORITY
    if Settings.AimAssist then
        local target = nil
        local bestValue = math.huge
        local maxDistFOV = Settings.AimFOV
        
        -- Combina Players e NPCs em uma lista única se necessário
        local possibleTargets = {}
        for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(possibleTargets, p.Character) end end
        if Settings.AimNPC then for _, npc in pairs(NPCCache) do table.insert(possibleTargets, npc) end end

        for _, char in pairs(possibleTargets) do
            if char and char:FindFirstChild(Settings.AimPart) then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 1 then
                    -- Team Check apenas para Players
                    local pObj = Players:GetPlayerFromCharacter(char)
                    if Settings.TeamCheck and pObj and pObj.Team == LocalPlayer.Team then continue end
                    
                    local part = char[Settings.AimPart]
                    local pos, vis = Camera:WorldToViewportPoint(part.Position)
                    
                    if vis and IsVisible(part) then
                        local screenMag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        
                        -- Se NÃO for 360º, precisa estar dentro do FOV na tela
                        if (not Settings.TargetPriority or not Settings.Priority360) and screenMag > maxDistFOV then continue end

                        local val = screenMag -- Padrão (Sem Priority)
                        
                        if Settings.TargetPriority then
                            if Settings.PriorityMode == "Distância" then
                                val = (part.Position - Camera.CFrame.Position).Magnitude
                            elseif Settings.PriorityMode == "Menor HP" then
                                val = humanoid.Health
                            elseif Settings.PriorityMode == "Mirando em Mim" then
                                local head = char:FindFirstChild("Head")
                                if head then
                                    local look = head.CFrame.LookVector
                                    local dir = (Camera.CFrame.Position - head.Position).Unit
                                    local dot = look:Dot(dir)
                                    val = -dot -- Menor valor = mais próximo de 1 (olhando direto)
                                end
                            end
                        end

                        if val < bestValue then
                            bestValue = val
                            target = part
                        end
                    end
                end
            end
        end

        if target then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Settings.AimSmooth) end
    end
end)

ToggleBtn.MouseButton1Up:Connect(function() 
    if Main.Visible then 
        MenuAberto = false; TweenService:Create(Main, TweenInfo.new(0.3), {Size = UDim2.new(0, 280, 0, 0), BackgroundTransparency = 1}):Play()
        task.delay(0.3, function() if not MenuAberto then Main.Visible = false end end)
    else 
        MenuAberto = true; Main.Visible = true; Title.TextTransparency = 0; Main.Position = UDim2.new(0.5, -140, 0.5, -180)
        TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Elastic), {Size = UDim2.new(0, 280, 0, 360), BackgroundTransparency = (Settings.UITheme == "Claro" and 0 or 0.1)}):Play()
    end
end)
