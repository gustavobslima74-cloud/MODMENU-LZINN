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
    TargetPriority = false, PriorityMode = "Mais Próximo" -- "Mais Próximo", "Menor HP", "Mirando em Mim"
}

local VERSION = "v6.5.0"
local CHANGELOG_TEXT = [[
--- NOVIDADES v6.5.0 ---
[+] MIRA: Target Priority adicionado (busca em 360° fora do FOV).
[+] MIRA: Sub-modos de prioridade (Mais Próximo, Menor HP, Mirando em Mim).
[+] UI: Sistema de busca global adicionado no topo do menu.
-------------------------
--- NOVIDADES v6.4.0 ---
[+] ESP: Adicionado suporte completo para NPCs.
[+] HITBOX: Adicionado Hitbox Expander para NPCs.
-------------------------]]

local MenuAberto = false
local FOVCircle = Drawing.new("Circle")

--// GUI PRINCIPAL
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

--// SISTEMA DE NOTIFICAÇÕES
local NotifContainer = Instance.new("Frame", ScreenGui)
NotifContainer.Size = UDim2.new(0, 200, 0.5, 0)
NotifContainer.Position = UDim2.new(0.5, -100, 0.05, 0)
NotifContainer.BackgroundTransparency = 1
local NotifLayout = Instance.new("UIListLayout", NotifContainer)
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.Padding = UDim.new(0, 5)
NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function SendNotification(text, state)
    local color = state and Color3.new(0, 1, 0) or Color3.new(1, 0.2, 0.2)
    local notif = Instance.new("TextLabel", NotifContainer)
    notif.Size = UDim2.new(1, 0, 0, 25)
    notif.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    notif.TextColor3 = color
    notif.Text = text
    notif.Font = Enum.Font.GothamBold
    notif.TextSize = 11
    notif.BackgroundTransparency = 1
    notif.TextTransparency = 1
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 4)
    local stroke = Instance.new("UIStroke", notif)
    stroke.Thickness = 1
    stroke.Color = color
    stroke.Transparency = 1
    
    local tIn = TweenService:Create(notif, TweenInfo.new(0.2), {BackgroundTransparency = 0.2, TextTransparency = 0})
    local strokeIn = TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0})
    tIn:Play(); strokeIn:Play()
    
    task.delay(1.5, function()
        local tOut = TweenService:Create(notif, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1})
        local strokeOut = TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 1})
        tOut:Play(); strokeOut:Play()
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
Main.Size = UDim2.new(0,280,0,360)
Main.Position = UDim2.new(0.5, -140, 0.5, -180)
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

-- SISTEMA DE BUSCA UNIVERSAL
local SearchBar = Instance.new("TextBox", Main)
SearchBar.Size = UDim2.new(1, -20, 0, 25)
SearchBar.Position = UDim2.new(0, 10, 0, 35)
SearchBar.PlaceholderText = "🔍 Buscar função..."
SearchBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
SearchBar.TextColor3 = Color3.new(1, 1, 1)
SearchBar.Font = Enum.Font.Gotham
SearchBar.TextSize = 11
Instance.new("UICorner", SearchBar).CornerRadius = UDim.new(0, 4)

local SearchableElements = {}
local function RegisterSearchable(element, text)
    table.insert(SearchableElements, {Element = element, OriginalParent = element.Parent, Text = string.lower(text)})
end

-- ABAS E PÁGINAS
local TabsFrame = Instance.new("ScrollingFrame", Main); TabsFrame.Size = UDim2.new(1,0,0,35); TabsFrame.Position = UDim2.new(0,0,0,65); TabsFrame.BackgroundTransparency = 1; TabsFrame.ScrollBarThickness = 0; TabsFrame.CanvasSize = UDim2.new(0,0,0,0)
local TabList = Instance.new("UIListLayout", TabsFrame); TabList.FillDirection = Enum.FillDirection.Horizontal
TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() TabsFrame.CanvasSize = UDim2.new(0, TabList.AbsoluteContentSize.X, 0, 0) end)
local Pages = Instance.new("Frame", Main); Pages.Position = UDim2.new(0,0,0,100); Pages.Size = UDim2.new(1,0,1,-100); Pages.BackgroundTransparency = 1

local ActivePage = nil

-- ABA DE RESULTADOS DE BUSCA
local SearchResultsPage = Instance.new("ScrollingFrame", Pages)
SearchResultsPage.Size = UDim2.new(1,0,1,0); SearchResultsPage.BackgroundTransparency = 1; SearchResultsPage.Visible = false; SearchResultsPage.ScrollBarThickness = 2
local SRLayout = Instance.new("UIListLayout", SearchResultsPage); SRLayout.Padding = UDim.new(0,5); SRLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SRLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() SearchResultsPage.CanvasSize = UDim2.new(0,0,0,SRLayout.AbsoluteContentSize.Y + 20) end)

local function CreatePage(name)
    local btn = Instance.new("TextButton", TabsFrame); btn.Size = UDim2.new(0, 70, 1, 0); btn.Text = name; btn.BackgroundTransparency = 1; btn.TextColor3 = Color3.new(1,1,1); btn.TextSize = 10; btn.Font = Enum.Font.GothamBold
    local page = Instance.new("ScrollingFrame", Pages); page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1; page.Visible = false; page.ScrollBarThickness = 2
    local layout = Instance.new("UIListLayout", page); layout.Padding = UDim.new(0,5); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() page.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 20) end)
    
    btn.MouseButton1Click:Connect(function() 
        if SearchBar.Text ~= "" then SearchBar.Text = "" end
        for _,v in pairs(Pages:GetChildren()) do v.Visible = false end
        page.Visible = true
        ActivePage = page
    end)
    return page, btn
end

local function CreateSection(parent, name)
    local sectionBtn = Instance.new("TextButton", parent); sectionBtn.Size = UDim2.new(1,-20,0,28); sectionBtn.Text = "[ " .. name .. " ]"; sectionBtn.BackgroundColor3 = Color3.fromRGB(25,25,25); sectionBtn.TextColor3 = Color3.fromRGB(200,200,200); sectionBtn.Font = Enum.Font.GothamBold; sectionBtn.TextSize = 11; Instance.new("UICorner", sectionBtn)
    local container = Instance.new("Frame", parent); container.Size = UDim2.new(1,0,0,0); container.AutomaticSize = Enum.AutomaticSize.Y; container.BackgroundTransparency = 1; container.Visible = false
    Instance.new("UIListLayout", container).Padding = UDim.new(0,5); container.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sectionBtn.MouseButton1Click:Connect(function() container.Visible = not container.Visible; sectionBtn.BackgroundColor3 = container.Visible and Color3.fromRGB(40,40,40) or Color3.fromRGB(25,25,25) end)
    RegisterSearchable(sectionBtn, name .. " (Sessão)")
    return container
end

-- CONTROLE VISUAL
local VisualToggles = {}
local VisualSteppers = {}

local function CreateToggle(parent, text, callback, default)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1,-25,0,32); b.Text = text..": "..(default and "ON" or "OFF"); b.BackgroundColor3 = default and Color3.fromRGB(50,100,50) or Color3.fromRGB(30,30,30); b.TextColor3 = Color3.new(1,1,1); b.TextSize = 11; Instance.new("UICorner", b)
    local state = default or false
    
    VisualToggles[text] = function(v)
        state = v; b.Text = text..": "..(state and "ON" or "OFF")
        b.BackgroundColor3 = state and Color3.fromRGB(50,100,50) or Color3.fromRGB(30,30,30); callback(state)
    end
    b.MouseButton1Click:Connect(function() VisualToggles[text](not state) end)
    RegisterSearchable(b, text)
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
    RegisterSearchable(frame, text)
end

-- LOGICA DA BUSCA
SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
    local query = string.lower(SearchBar.Text)
    if query == "" then
        SearchResultsPage.Visible = false
        TabsFrame.Visible = true
        for _, data in pairs(SearchableElements) do data.Element.Parent = data.OriginalParent end
        if ActivePage then ActivePage.Visible = true end
    else
        TabsFrame.Visible = false
        for _, page in pairs(Pages:GetChildren()) do
            if page ~= SearchResultsPage then page.Visible = false end
        end
        SearchResultsPage.Visible = true
        for _, data in pairs(SearchableElements) do
            if string.find(data.Text, query) then
                data.Element.Parent = SearchResultsPage
            else
                data.Element.Parent = data.OriginalParent
            end
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
local FPSPage = CreatePage("FPS")
local InfoPage = CreatePage("INFOS")
ESPPage.Visible = true
ActivePage = ESPPage

-- SETUP ESP
CreateToggle(ESPPage, "ESP Geral (Players)", function(v) Settings.ESP = v end)
CreateToggle(ESPPage, "ESP NPC", function(v) Settings.ESPNPC = v end)
CreateToggle(ESPPage, "Skeleton ESP", function(v) Settings.SkeletonESP = v end)
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
RegisterSearchable(TpBtn, "Teleportar (Clique)")
CreateToggle(SecSel, "Auto Próximo", function(v) Settings.AutoNearest = v end)
CreateToggle(SecAct, "Grudar Atrás", function(v) Settings.StickyBehind = v end)
CreateStepper(SecAct, "Suavidade", 0.01, 1, 0.1, 0.05, function(v) Settings.StickySmoothness = v end)
CreateStepper(SecAct, "Distância", 1, 20, 3, 1, function(v) Settings.StickyDistance = v end)

-- SETUP MIRA
CreateToggle(MiraPage, "Auxílio de Mira", function(v) Settings.AimAssist = v end)

-- NOVO: TARGET PRIORITY
CreateToggle(MiraPage, "Target Priority (360°)", function(v) Settings.TargetPriority = v end)
local Modes = {"Mais Próximo", "Menor HP", "Mirando em Mim"}
local ModeBtn = Instance.new("TextButton", MiraPage)
ModeBtn.Size = UDim2.new(1,-25,0,32)
ModeBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
ModeBtn.TextColor3 = Color3.new(1,1,1)
ModeBtn.Text = "Prioridade: " .. Settings.PriorityMode
Instance.new("UICorner", ModeBtn)
RegisterSearchable(ModeBtn, "Mudar Modo de Prioridade")

ModeBtn.MouseButton1Click:Connect(function()
    local idx = table.find(Modes, Settings.PriorityMode) or 1
    idx = idx + 1
    if idx > #Modes then idx = 1 end
    Settings.PriorityMode = Modes[idx]
    ModeBtn.Text = "Prioridade: " .. Settings.PriorityMode
end)

local PartBtn = Instance.new("TextButton", MiraPage); PartBtn.Size = UDim2.new(1,-25,0,32); PartBtn.Text = "Alvo: Cabeça"; PartBtn.BackgroundColor3 = Color3.fromRGB(30,30,30); PartBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", PartBtn)
PartBtn.MouseButton1Click:Connect(function() Settings.AimPart = (Settings.AimPart == "Head" and "HumanoidRootPart" or "Head"); PartBtn.Text = "Alvo: "..(Settings.AimPart == "Head" and "Cabeça" or "Tronco") end)
RegisterSearchable(PartBtn, "Alvo Mira Corpo/Cabeca")

CreateToggle(MiraPage, "Mira em NPC", function(v) Settings.AimNPC = v end)
CreateToggle(MiraPage, "Team Check", function(v) Settings.TeamCheck = v end)
CreateToggle(MiraPage, "Wall Check", function(v) Settings.WallCheck = v end)
CreateToggle(MiraPage, "Exibir FOV", function(v) Settings.ShowFOV = v end)
CreateStepper(MiraPage, "Tamanho FOV", 10, 800, 100, 10, function(v) Settings.AimFOV = v end)
CreateStepper(MiraPage, "Suavidade", 0.01, 1, 0.1, 0.05, function(v) Settings.AimSmooth = v end)

-- SETUP HITBOX E FPS
CreateToggle(HitboxPage, "Hitbox Players", function(v) Settings.HitboxEnabled = v end)
CreateToggle(HitboxPage, "Hitbox NPC", function(v) Settings.HitboxNPC = v end)
CreateStepper(HitboxPage, "Tamanho", 2, 100, 20, 5, function(v) Settings.Hitbox = v end)
CreateStepper(HitboxPage, "Opacidade", 0, 1, 0.6, 0.1, function(v) Settings.HitboxTransparency = v end)

CreateToggle(FPSPage, "Otimizar Texturas", function(v) Settings.BoostFPS = v; for _,o in pairs(game:GetDescendants()) do if o:IsA("Texture") or o:IsA("Decal") then o.Transparency = v and 1 or 0 end end end)
CreateToggle(FPSPage, "Remover Sombras", function(v) Lighting.GlobalShadows = not v end)
CreateStepper(FPSPage, "Limite FPS", 30, 240, 120, 30, function(v) if setfpscap then setfpscap(v) end end)

local LogLabel = Instance.new("TextLabel", InfoPage); LogLabel.Size = UDim2.new(1,-20,0,0); LogLabel.AutomaticSize = Enum.AutomaticSize.Y; LogLabel.BackgroundTransparency = 1; LogLabel.TextColor3 = Color3.fromRGB(200,200,200); LogLabel.TextSize = 11; LogLabel.Font = Enum.Font.Code; LogLabel.Text = CHANGELOG_TEXT; LogLabel.TextXAlignment = Enum.TextXAlignment.Left; LogLabel.TextWrapped = true

-- ABA PRED
local SecPreset = CreateSection(PredPage, "PREDEFINIÇÕES")
local SecFloat = CreateSection(PredPage, "BOTÕES FLUTUANTES")

local BtnLegit = Instance.new("TextButton", SecPreset); BtnLegit.Size = UDim2.new(1,-25,0,32); BtnLegit.Text = "CARREGAR: LEGIT"; BtnLegit.BackgroundColor3 = Color3.fromRGB(0, 100, 50); BtnLegit.TextColor3 = Color3.new(1,1,1); BtnLegit.TextSize = 11; Instance.new("UICorner", BtnLegit)
BtnLegit.MouseButton1Click:Connect(function()
    if VisualToggles["ESP Geral (Players)"] then VisualToggles["ESP Geral (Players)"](true) end
    if VisualToggles["Chams"] then VisualToggles["Chams"](true) end
    if VisualToggles["Team Color"] then VisualToggles["Team Color"](true) end
    if VisualToggles["Auxílio de Mira"] then VisualToggles["Auxílio de Mira"](true) end
    if VisualToggles["Wall Check"] then VisualToggles["Wall Check"](true) end
    if VisualSteppers["Tamanho FOV"] then VisualSteppers["Tamanho FOV"](20) end
    if VisualSteppers["Suavidade"] then VisualSteppers["Suavidade"](0.2) end
end)
RegisterSearchable(BtnLegit, "Carregar Preset Legit")

local BtnReset = Instance.new("TextButton", SecPreset); BtnReset.Size = UDim2.new(1,-25,0,32); BtnReset.Text = "RESETAR AO PADRÃO"; BtnReset.BackgroundColor3 = Color3.fromRGB(150, 30, 30); BtnReset.TextColor3 = Color3.new(1,1,1); BtnReset.TextSize = 11; Instance.new("UICorner", BtnReset)
BtnReset.MouseButton1Click:Connect(function()
    for name, func in pairs(VisualToggles) do func(false) end
    if VisualSteppers["Tamanho FOV"] then VisualSteppers["Tamanho FOV"](100) end
    if VisualSteppers["Suavidade"] then VisualSteppers["Suavidade"](0.1) end
end)
RegisterSearchable(BtnReset, "Resetar ao Padrao")

local function SpawnFloatingButton(name, actionCallback)
    local currentFloats = 0
    for _, v in pairs(ScreenGui:GetChildren()) do
        if v.Name == "FloatBtn_" .. name then return end
        if string.match(v.Name, "^FloatBtn_") then currentFloats = currentFloats + 1 end
    end
    local floatFrame = Instance.new("Frame", ScreenGui); floatFrame.Name = "FloatBtn_" .. name; floatFrame.Size = UDim2.new(0, 50, 0, 50)
    local startX = -65 - ((currentFloats + 1) * 55); floatFrame.Position = UDim2.new(1, startX, 0, 12); floatFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); floatFrame.BackgroundTransparency = 0.2; Instance.new("UICorner", floatFrame).CornerRadius = UDim.new(1, 0)
    local btn = Instance.new("TextButton", floatFrame); btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = name; btn.TextColor3 = Color3.new(1, 1, 1); btn.TextSize = 10; btn.Font = Enum.Font.GothamBold
    local closeBtn = Instance.new("TextButton", floatFrame); closeBtn.Size = UDim2.new(0, 20, 0, 20); closeBtn.Position = UDim2.new(1, -15, 0, -5); closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.new(1,1,1); closeBtn.TextSize = 10; Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
    MakeDraggable(floatFrame, false)
    btn.MouseButton1Click:Connect(actionCallback)
    closeBtn.MouseButton1Click:Connect(function() floatFrame:Destroy() end)
end

local BtnFloatAim = Instance.new("TextButton", SecFloat); BtnFloatAim.Size = UDim2.new(1,-25,0,32); BtnFloatAim.Text = "CRIAR FLUTUANTE: AIMBOT"; BtnFloatAim.BackgroundColor3 = Color3.fromRGB(50, 50, 150); BtnFloatAim.TextColor3 = Color3.new(1,1,1); BtnFloatAim.TextSize = 11; Instance.new("UICorner", BtnFloatAim)
BtnFloatAim.MouseButton1Click:Connect(function()
    SpawnFloatingButton("AIM", function()
        local newState = not Settings.AimAssist
        if VisualToggles["Auxílio de Mira"] then VisualToggles["Auxílio de Mira"](newState) end
        SendNotification("AIMBOT: " .. (newState and "ATIVADO" or "DESATIVADO"), newState)
    end)
end)
RegisterSearchable(BtnFloatAim, "Criar Flutuante Aimbot")

local BtnFloatESP = Instance.new("TextButton", SecFloat); BtnFloatESP.Size = UDim2.new(1,-25,0,32); BtnFloatESP.Text = "CRIAR FLUTUANTE: ESP LITE"; BtnFloatESP.BackgroundColor3 = Color3.fromRGB(50, 50, 150); BtnFloatESP.TextColor3 = Color3.new(1,1,1); BtnFloatESP.TextSize = 11; Instance.new("UICorner", BtnFloatESP)
BtnFloatESP.MouseButton1Click:Connect(function()
    SpawnFloatingButton("ESP", function()
        local newState = not Settings.ESP
        if VisualToggles["ESP Geral (Players)"] then VisualToggles["ESP Geral (Players)"](newState) end
        if VisualToggles["Chams"] then VisualToggles["Chams"](newState) end
        SendNotification("ESP LITE: " .. (newState and "ATIVADO" or "DESATIVADO"), newState)
    end)
end)
RegisterSearchable(BtnFloatESP, "Criar Flutuante ESP Lite")

-- LÓGICA DE VISIBILIDADE E SKELETON
local function IsVisible(part)
    if not Settings.WallCheck then return true end
    local castPoints = {Camera.CFrame.Position, part.Position}
    local ignoreList = {LocalPlayer.Character, part.Parent}
    local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances = ignoreList
    local result = workspace:Raycast(castPoints[1], (castPoints[2] - castPoints[1]).Unit * (castPoints[1] - castPoints[2]).Magnitude, params)
    return result == nil
end

local function DrawSkeleton(character, skeletonLines, color)
    local joints = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, 
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
    }
    if not character:FindFirstChild("UpperTorso") then
        joints = {
            {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
            {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
        }
    end
    for i, l in ipairs(skeletonLines) do
        local joint = joints[i]
        if joint and character:FindFirstChild(joint[1]) and character:FindFirstChild(joint[2]) then
            local p1, v1 = Camera:WorldToViewportPoint(character[joint[1]].Position)
            local p2, v2 = Camera:WorldToViewportPoint(character[joint[2]].Position)
            if v1 and v2 then
                l.Visible = true; l.From = Vector2.new(p1.X, p1.Y); l.To = Vector2.new(p2.X, p2.Y); l.Color = color
            else l.Visible = false end
        else l.Visible = false end
    end
end

-- GERENCIAMENTO CACHE E ESP
local NPCCache = {}
local NPCESPContainer = {}
local ESPContainer = {}

local function CreateSkeletonLines()
    local lines = {}
    for i=1, 12 do local l = Drawing.new("Line"); l.Thickness = 1; l.Visible = false; l.Color = Color3.new(1,1,1); table.insert(lines, l) end
    return lines
end

local function RemoveESP(container, obj)
    if container[obj] then
        if container[obj].Box then container[obj].Box:Remove() end
        if container[obj].Name then container[obj].Name:Remove() end
        if container[obj].Dist then container[obj].Dist:Remove() end
        if container[obj].Line then container[obj].Line:Remove() end
        if container[obj].Highlight then container[obj].Highlight:Destroy() end
        if container[obj].Skeleton then for _, l in pairs(container[obj].Skeleton) do l:Remove() end end
        container[obj] = nil
    end
end

local function CreateESPObj(container, obj)
    if container[obj] then return end
    container[obj] = {
        Box = Drawing.new("Square"), Name = Drawing.new("Text"), Dist = Drawing.new("Text"),
        Line = Drawing.new("Line"), Highlight = nil, Skeleton = CreateSkeletonLines()
    }
    local e = container[obj]
    e.Box.Thickness = 1.5; e.Box.Filled = false
    e.Name.Size = 14; e.Name.Center = true; e.Name.Outline = true
    e.Dist.Size = 12; e.Dist.Center = true; e.Dist.Outline = true
    e.Line.Thickness = 1
end

Players.PlayerAdded:Connect(function(p) CreateESPObj(ESPContainer, p) end)
Players.PlayerRemoving:Connect(function(p) RemoveESP(ESPContainer, p) end)
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESPObj(ESPContainer, p) end end

task.spawn(function()
    while true do
        if Settings.AimNPC or Settings.ESPNPC or Settings.HitboxNPC then
            local tempCache = {}; local currentNPCs = {}
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 1 and not Players:GetPlayerFromCharacter(obj) then
                    table.insert(tempCache, obj); currentNPCs[obj] = true
                    if Settings.ESPNPC then CreateESPObj(NPCESPContainer, obj) end
                end
            end
            NPCCache = tempCache
            for obj, _ in pairs(NPCESPContainer) do if not currentNPCs[obj] then RemoveESP(NPCESPContainer, obj) end end
        else
            NPCCache = {}
            for obj, _ in pairs(NPCESPContainer) do RemoveESP(NPCESPContainer, obj) end
        end
        task.wait(2)
    end
end)


-- RENDER LOOP PRINCIPAL (AIMBOT E ESP)
RunService.RenderStepped:Connect(function()
    FPSLabel.Text = "FPS: " .. math.floor(1/RunService.RenderStepped:Wait())
    FOVCircle.Visible = Settings.ShowFOV; FOVCircle.Radius = Settings.AimFOV; FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2); FOVCircle.Color = stroke.Color; FOVCircle.Thickness = 1.2; FOVCircle.Filled = false

    -- LÓGICA AIMBOT + TARGET PRIORITY
    if Settings.AimAssist then
        local target = nil
        local bestValue = math.huge

        local function CheckTarget(part, humanoid, isNPC)
            if humanoid and humanoid.Health > 1 and IsVisible(part) then
                if Settings.TargetPriority then
                    -- Ignora FOV e busca em 360 Graus baseando-se no Modo
                    if Settings.PriorityMode == "Mais Próximo" then
                        local dist = (part.Position - Camera.CFrame.Position).Magnitude
                        if dist < bestValue then bestValue = dist; target = part end
                        
                    elseif Settings.PriorityMode == "Menor HP" then
                        local hp = humanoid.Health
                        if hp < bestValue then bestValue = hp; target = part end
                        
                    elseif Settings.PriorityMode == "Mirando em Mim" then
                        -- Checa se o alvo está virado aproximadamente na minha direção
                        local dirToMe = (Camera.CFrame.Position - part.Position).Unit
                        local dot = part.CFrame.LookVector:Dot(dirToMe)
                        
                        -- Se dot for próximo de 1, ele está me olhando. Pegamos o mais próximo dentre os que me olham.
                        if dot > 0.85 then 
                            local dist = (part.Position - Camera.CFrame.Position).Magnitude
                            if dist < bestValue then bestValue = dist; target = part end
                        end
                    end
                else
                    -- Sistema normal por FOV
                    local pos, vis = Camera:WorldToViewportPoint(part.Position)
                    if vis then
                        local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if mag < Settings.AimFOV and mag < bestValue then
                            bestValue = mag; target = part
                        end
                    end
                end
            end
        end

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Settings.AimPart) then
                if Settings.TeamCheck and p.Team == LocalPlayer.Team then continue end
                CheckTarget(p.Character[Settings.AimPart], p.Character:FindFirstChild("Humanoid"), false)
            end
        end
        if Settings.AimNPC then
            for _, obj in pairs(NPCCache) do
                if obj and obj.Parent and obj:FindFirstChild("Humanoid") then
                    local part = obj:FindFirstChild(Settings.AimPart) or obj:FindFirstChild("HumanoidRootPart")
                    if part then CheckTarget(part, obj.Humanoid, true) end
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

    -- RENDER ESP
    local function RenderESP(container, isNPC)
        for obj, e in pairs(container) do
            local character = isNPC and obj or (obj.Parent and obj.Character)
            if not character or not character:FindFirstChild("HumanoidRootPart") or (isNPC and not Settings.ESPNPC) then
                e.Box.Visible = false; e.Name.Visible = false; e.Dist.Visible = false; e.Line.Visible = false
                if e.Highlight then e.Highlight.Enabled = false end; for _, l in pairs(e.Skeleton) do l.Visible = false end
                continue
            end

            local hrp = character.HumanoidRootPart; local head = character:FindFirstChild("Head")
            local pos, vis = Camera:WorldToViewportPoint(hrp.Position)
            local color = isNPC and Color3.fromRGB(255, 80, 80) or ((Settings.TeamColor and obj.TeamColor) and obj.TeamColor.Color or Color3.new(1,1,1))
            
            if (isNPC and vis) or (not isNPC and Settings.ESP and vis) then
                if Settings.Boxes then e.Box.Visible = true; e.Box.Size = Vector2.new(2500/pos.Z, 3500/pos.Z); e.Box.Position = Vector2.new(pos.X - e.Box.Size.X/2, pos.Y - e.Box.Size.Y/2); e.Box.Color = color else e.Box.Visible = false end
                if Settings.Names then e.Name.Visible = true; e.Name.Text = isNPC and obj.Name or obj.DisplayName; e.Name.Position = Vector2.new(pos.X, pos.Y - (2000/pos.Z) - 20); e.Name.Color = color else e.Name.Visible = false end
                if Settings.Distance then e.Dist.Visible = true; e.Dist.Text = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude).."m"; e.Dist.Position = Vector2.new(pos.X, pos.Y + (2000/pos.Z) + 5); e.Dist.Color = Color3.new(0,1,0) else e.Dist.Visible = false end
                if Settings.Lines and head then local headPos = Camera:WorldToViewportPoint(head.Position); e.Line.Visible = true; e.Line.From = Vector2.new(Camera.ViewportSize.X/2, 0); e.Line.To = Vector2.new(headPos.X, headPos.Y); e.Line.Color = color else e.Line.Visible = false end
                
                if Settings.Highlight then
                    if not e.Highlight or e.Highlight.Parent ~= character then if e.Highlight then e.Highlight:Destroy() end e.Highlight = Instance.new("Highlight", character) end
                    e.Highlight.Enabled = true; e.Highlight.FillColor = color; e.Highlight.FillTransparency = 0.5
                elseif e.Highlight then e.Highlight.Enabled = false end

                if Settings.SkeletonESP then DrawSkeleton(character, e.Skeleton, color) else for _, l in pairs(e.Skeleton) do l.Visible = false end end
            else 
                e.Box.Visible = false; e.Name.Visible = false; e.Dist.Visible = false; e.Line.Visible = false; if e.Highlight then e.Highlight.Enabled = false end; for _, l in pairs(e.Skeleton) do l.Visible = false end
            end
        end
    end
    
    RenderESP(ESPContainer, false)
    RenderESP(NPCESPContainer, true)
end)

-- LOOP DO HITBOX EXPANDER
task.spawn(function() 
    while true do 
        for _, p in pairs(Players:GetPlayers()) do 
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then 
                local hrp = p.Character.HumanoidRootPart; 
                if Settings.HitboxEnabled then hrp.Size = Vector3.new(Settings.Hitbox, Settings.Hitbox, Settings.Hitbox); hrp.Transparency = Settings.HitboxTransparency; hrp.CanCollide = false 
                else hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 1 end 
            end 
        end
        for _, obj in pairs(NPCCache) do
            if obj and obj.Parent and obj:FindFirstChild("HumanoidRootPart") then
                local hrp = obj.HumanoidRootPart
                if Settings.HitboxNPC then hrp.Size = Vector3.new(Settings.Hitbox, Settings.Hitbox, Settings.Hitbox); hrp.Transparency = Settings.HitboxTransparency; hrp.CanCollide = false 
                else hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 1 end
            end
        end
        task.wait(0.1) 
    end 
end)

UIS.JumpRequest:Connect(function() if Settings.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid:ChangeState("Jumping") end end)

ToggleBtn.MouseButton1Up:Connect(function() 
    if Main.Visible then 
        MenuAberto = false; local tw = TweenInfo.new(0.3); local anim = TweenService:Create(Main, tw, {Size = UDim2.new(0, 280, 0, 0), BackgroundTransparency = 1}); anim:Play(); anim.Completed:Connect(function() Main.Visible = false end)
    else 
        MenuAberto = true; Main.Visible = true; Title.TextTransparency = 0; Main.Position = UDim2.new(0.5, -140, 0.5, -180)
        TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Elastic), {Size = UDim2.new(0, 280, 0, 360), BackgroundTransparency = 0.1}):Play()
    end
end)
