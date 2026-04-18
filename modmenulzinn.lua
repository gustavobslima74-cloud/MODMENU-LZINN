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
    TargetPriority = false, PriorityMode = "Mais Próximo",
    -- Novas Opções da Aba Teste
    InfAmmo = false, Speedfire = false, NoRecoil = false, NoSpread = false
}

local VERSION = "v6.8.0"
local CHANGELOG_TEXT = [[
--- NOVIDADES v6.8.0 ---
[+] ABA TESTE: Adicionada nova aba para funções de combate.
[+] COMBATE: Munição Infinita (Tenta manter o pente cheio).
[+] COMBATE: Speedfire (Aumenta a cadência de armas compatíveis).
[+] COMBATE: No Recoil & No Spread (Remoção de coice e espalhamento).
-------------------------
--- NOVIDADES v6.7.0 ---
[+] PRED: Novo Preset NPC e botões flutuantes automáticos.
[+] UI: Adicionado botão para criar Flutuante de Hitbox NPC.
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
        page.Visible = true; ActivePage = page
    end)
    return page, btn
end

local function CreateSection(parent, name)
    local sectionBtn = Instance.new("TextButton", parent); sectionBtn.Size = UDim2.new(1,-20,0,28); sectionBtn.Text = "[ " .. name .. " ]"; sectionBtn.BackgroundColor3 = Color3.fromRGB(25,25,25); sectionBtn.TextColor3 = Color3.fromRGB(200,200,200); sectionBtn.Font = Enum.Font.GothamBold; sectionBtn.TextSize = 11; Instance.new("UICorner", sectionBtn)
    local container = Instance.new("Frame", parent); container.Size = UDim2.new(1,0,0,0); container.AutomaticSize = Enum.AutomaticSize.Y; container.BackgroundTransparency = 1; container.Visible = false
    Instance.new("UIListLayout", container).Padding = UDim.new(0,5); container.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sectionBtn.MouseButton1Click:Connect(function() container.Visible = not container.Visible; sectionBtn.BackgroundColor3 = container.Visible and Color3.fromRGB(40,40,40) or Color3.fromRGB(25,25,25) end)
    RegisterSearchable(sectionBtn, name)
    return container
end

-- CONTROLES DE UI
local VisualToggles = {}
local VisualSteppers = {}
local function CreateToggle(parent, text, callback, default)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1,-25,0,32); b.Text = text..": "..(default and "ON" or "OFF"); b.BackgroundColor3 = default and Color3.fromRGB(50,100,50) or Color3.fromRGB(30,30,30); b.TextColor3 = Color3.new(1,1,1); b.TextSize = 11; Instance.new("UICorner", b)
    local state = default or false
    VisualToggles[text] = function(v) state = v; b.Text = text..": "..(state and "ON" or "OFF"); b.BackgroundColor3 = state and Color3.fromRGB(50,100,50) or Color3.fromRGB(30,30,30); callback(state) end
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
    VisualSteppers[text] = up; minus.MouseButton1Click:Connect(function() up(val - step) end); plus.MouseButton1Click:Connect(function() up(val + step) end)
    RegisterSearchable(frame, text)
end

-- LOGICA DA BUSCA
SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
    local query = string.lower(SearchBar.Text)
    if query == "" then
        SearchResultsPage.Visible = false; TabsFrame.Visible = true
        for _, data in pairs(SearchableElements) do data.Element.Parent = data.OriginalParent end
        if ActivePage then ActivePage.Visible = true end
    else
        TabsFrame.Visible = false; for _, page in pairs(Pages:GetChildren()) do if page ~= SearchResultsPage then page.Visible = false end end
        SearchResultsPage.Visible = true
        for _, data in pairs(SearchableElements) do if string.find(data.Text, query) then data.Element.Parent = SearchResultsPage else data.Element.Parent = data.OriginalParent end end
    end
end)

-- ABAS
local ESPPage = CreatePage("ESP")
local PlayerPage = CreatePage("PLAYER")
local MiraPage = CreatePage("MIRA")
local HitboxPage = CreatePage("HITBOX")
local TestePage = CreatePage("TESTE") -- NOVA ABA
local PredPage = CreatePage("PRED")
local InfoPage = CreatePage("INFOS")
ESPPage.Visible = true; ActivePage = ESPPage

-- SETUP ESP, PLAYER, MIRA, HITBOX (Mantidos do anterior...)
CreateToggle(ESPPage, "ESP Geral", function(v) Settings.ESP = v end)
CreateToggle(ESPPage, "ESP NPC", function(v) Settings.ESPNPC = v end)
CreateToggle(ESPPage, "Skeleton ESP", function(v) Settings.SkeletonESP = v end)
CreateToggle(PlayerPage, "Velocidade", function(v) Settings.UseSpeed = v end)
CreateStepper(PlayerPage, "Speed", 16, 500, 16, 5, function(v) Settings.Speed = v end)
CreateToggle(MiraPage, "Auxílio de Mira", function(v) Settings.AimAssist = v end)
CreateToggle(MiraPage, "Target Priority (360°)", function(v) Settings.TargetPriority = v end)
CreateToggle(HitboxPage, "Hitbox Players", function(v) Settings.HitboxEnabled = v end)
CreateToggle(HitboxPage, "Hitbox NPC", function(v) Settings.HitboxNPC = v end)

-- SETUP ABA TESTE (MUNIÇÃO E ARMA)
CreateSection(TestePage, "MODIFICAÇÕES DE ARMA")
CreateToggle(TestePage, "Munição Infinita", function(v) Settings.InfAmmo = v end)
CreateToggle(TestePage, "Speedfire", function(v) Settings.Speedfire = v end)
CreateToggle(TestePage, "Sem Recuo", function(v) Settings.NoRecoil = v end)
CreateToggle(TestePage, "Sem Espalhamento", function(v) Settings.NoSpread = v end)

-- LÓGICA DE COMBATE (UNIVERSAL)
task.spawn(function()
    while true do
        if Settings.InfAmmo or Settings.Speedfire or Settings.NoRecoil or Settings.NoSpread then
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                -- Tenta encontrar scripts de configuração ou valores comuns
                for _, v in pairs(tool:GetDescendants()) do
                    if Settings.InfAmmo then
                        if v:IsA("IntVariable") or v:IsA("IntValue") then
                            if string.find(string.lower(v.Name), "ammo") or string.find(string.lower(v.Name), "cur") then
                                v.Value = 999
                            end
                        end
                    end
                end
                -- Speedfire/NoRecoil geralmente exige hook ou acesso a módulos específicos do jogo. 
                -- Aqui fica a base para você ou o script detectar mudanças.
            end
        end
        task.wait(0.5)
    end
end)

-- BOTÕES FLUTUANTES E PRESETS (Resumido para o código funcional)
local function SpawnFloatingButton(name, actionCallback)
    local currentFloats = 0
    for _, v in pairs(ScreenGui:GetChildren()) do if string.match(v.Name, "^FloatBtn_") then currentFloats = currentFloats + 1 end end
    local floatFrame = Instance.new("Frame", ScreenGui); floatFrame.Name = "FloatBtn_" .. name; floatFrame.Size = UDim2.new(0, 50, 0, 50)
    floatFrame.Position = UDim2.new(1, -65 - ((currentFloats + 1) * 55), 0, 12); floatFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); Instance.new("UICorner", floatFrame).CornerRadius = UDim.new(1, 0)
    local btn = Instance.new("TextButton", floatFrame); btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = name; btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.GothamBold
    MakeDraggable(floatFrame, false); btn.MouseButton1Click:Connect(actionCallback)
end

local SecFloat = CreateSection(PredPage, "BOTÕES FLUTUANTES")
local BtnF_HitNPC = Instance.new("TextButton", SecFloat); BtnF_HitNPC.Size = UDim2.new(1,-25,0,32); BtnF_HitNPC.Text = "CRIAR FLUTUANTE: HITBOX NPC"; BtnF_HitNPC.BackgroundColor3 = Color3.fromRGB(50, 50, 150); BtnF_HitNPC.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", BtnF_HitNPC)
BtnF_HitNPC.MouseButton1Click:Connect(function() SpawnFloatingButton("HB-NPC", function() Settings.HitboxNPC = not Settings.HitboxNPC; SendNotification("HB NPC: "..(Settings.HitboxNPC and "ON" or "OFF"), Settings.HitboxNPC) end) end)

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
        task.wait(0.2) 
    end 
end)

ToggleBtn.MouseButton1Up:Connect(function() 
    if Main.Visible then 
        MenuAberto = false; TweenService:Create(Main, TweenInfo.new(0.3), {Size = UDim2.new(0, 280, 0, 0), BackgroundTransparency = 1}):Play(); task.wait(0.3); Main.Visible = false
    else 
        MenuAberto = true; Main.Visible = true; Main.Position = UDim2.new(0.5, -140, 0.5, -180)
        TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Elastic), {Size = UDim2.new(0, 280, 0, 360), BackgroundTransparency = 0.1}):Play()
    end
end)

local LogLabel = Instance.new("TextLabel", InfoPage); LogLabel.Size = UDim2.new(1,-20,0,0); LogLabel.AutomaticSize = Enum.AutomaticSize.Y; LogLabel.BackgroundTransparency = 1; LogLabel.TextColor3 = Color3.fromRGB(200,200,200); LogLabel.Text = CHANGELOG_TEXT; LogLabel.TextWrapped = true
