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
    -- NOVAS FUNÇÕES v6.5.0
    TargetPriorityEnabled = false,
    PriorityMode = "Distância", -- "Distância", "Menor HP", "Focado em Mim"
}

local VERSION = "v6.5.0"
local MenuAberto = false
local FOVCircle = Drawing.new("Circle")
local AllUIElements = {} -- Para o sistema de busca

--// GUI PRINCIPAL
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

--// SISTEMA DE NOTIFICAÇÕES (Mesma lógica anterior)
local NotifContainer = Instance.new("Frame", ScreenGui)
NotifContainer.Size = UDim2.new(0, 200, 0.5, 0); NotifContainer.Position = UDim2.new(0.5, -100, 0.05, 0); NotifContainer.BackgroundTransparency = 1
local NotifLayout = Instance.new("UIListLayout", NotifContainer); NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function SendNotification(text, state)
    local color = state and Color3.new(0, 1, 0) or Color3.new(1, 0.2, 0.2)
    local notif = Instance.new("TextLabel", NotifContainer)
    notif.Size = UDim2.new(1, 0, 0, 25); notif.BackgroundColor3 = Color3.fromRGB(20, 20, 20); notif.TextColor3 = color; notif.Text = text; notif.Font = Enum.Font.GothamBold; notif.TextSize = 11
    Instance.new("UICorner", notif); local stroke = Instance.new("UIStroke", notif); stroke.Color = color
    task.delay(1.5, function() notif:Destroy() end)
end

--// FUNÇÃO DRAG
local function MakeDraggable(gui, isMenu)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if not isMenu and MenuAberto then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = gui.Position end
    end)
    gui.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,280,0,350); Main.Position = UDim2.new(0.5, -140, 0.5, -175); Main.BackgroundColor3 = Color3.fromRGB(10,10,10); Main.Visible = false; Main.ClipsDescendants = true
Instance.new("UICorner", Main); MakeDraggable(Main, true)
local stroke = Instance.new("UIStroke", Main); stroke.Thickness = 2

-- BARRA DE BUSCA (NOVO)
local SearchFrame = Instance.new("Frame", Main)
SearchFrame.Size = UDim2.new(1, -20, 0, 25); SearchFrame.Position = UDim2.new(0, 10, 0, 40); SearchFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", SearchFrame)
local SearchInput = Instance.new("TextBox", SearchFrame)
SearchInput.Size = UDim2.new(1, -10, 1, 0); SearchInput.Position = UDim2.new(0, 5, 0, 0); SearchInput.BackgroundTransparency = 1; SearchInput.PlaceholderText = "Buscar função..."; SearchInput.Text = ""; SearchInput.TextColor3 = Color3.new(1,1,1); SearchInput.TextSize = 12; SearchInput.Font = Enum.Font.Gotham

-- TÍTULO
local Title = Instance.new("TextLabel", Main); Title.Size = UDim2.new(1,0,0,35); Title.BackgroundTransparency = 1; Title.Text = "Kiko MENU | " .. VERSION; Title.TextColor3 = Color3.new(1,1,1); Title.Font = Enum.Font.Code

-- PAGINAÇÃO
local Pages = Instance.new("Frame", Main); Pages.Position = UDim2.new(0,0,0,105); Pages.Size = UDim2.new(1,0,1,-105); Pages.BackgroundTransparency = 1
local TabsFrame = Instance.new("ScrollingFrame", Main); TabsFrame.Size = UDim2.new(1,0,0,30); TabsFrame.Position = UDim2.new(0,0,0,70); TabsFrame.BackgroundTransparency = 1; TabsFrame.ScrollBarThickness = 0
local TabList = Instance.new("UIListLayout", TabsFrame); TabList.FillDirection = Enum.FillDirection.Horizontal

local function CreatePage(name)
    local btn = Instance.new("TextButton", TabsFrame); btn.Size = UDim2.new(0, 60, 1, 0); btn.Text = name; btn.BackgroundTransparency = 1; btn.TextColor3 = Color3.new(0.6,0.6,0.6); btn.TextSize = 10; btn.Font = Enum.Font.GothamBold
    local page = Instance.new("ScrollingFrame", Pages); page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1; page.Visible = false; page.ScrollBarThickness = 2
    local layout = Instance.new("UIListLayout", page); layout.Padding = UDim.new(0,5); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    btn.MouseButton1Click:Connect(function() 
        for _,v in pairs(Pages:GetChildren()) do v.Visible = false end
        for _,v in pairs(TabsFrame:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.new(0.6,0.6,0.6) end end
        page.Visible = true; btn.TextColor3 = Color3.new(1,1,1)
    end)
    return page
end

local function CreateToggle(parent, text, callback, default)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1,-25,0,32); b.Text = text..": "..(default and "ON" or "OFF"); b.BackgroundColor3 = default and Color3.fromRGB(50,100,50) or Color3.fromRGB(30,30,30); b.TextColor3 = Color3.new(1,1,1); b.TextSize = 11; Instance.new("UICorner", b)
    local state = default or false
    local function update(v) state = v; b.Text = text..": "..(state and "ON" or "OFF"); b.BackgroundColor3 = state and Color3.fromRGB(50,100,50) or Color3.fromRGB(30,30,30); callback(state) end
    b.MouseButton1Click:Connect(function() update(not state) end)
    table.insert(AllUIElements, {Instance = b, Name = text:lower(), Page = parent})
    return update
end

-- SISTEMA DE BUSCA LÓGICA
SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
    local query = SearchInput.Text:lower()
    for _, item in pairs(AllUIElements) do
        if query == "" then
            item.Instance.Visible = true
        else
            if item.Name:find(query) then
                item.Instance.Visible = true
                item.Page.Visible = true -- Abre a aba automaticamente
            else
                item.Instance.Visible = false
            end
        end
    end
end)

-- ABAS
local MiraPage = CreatePage("MIRA")
local ESPPage = CreatePage("ESP")
local PlayerPage = CreatePage("PLAYER")

-- [ NOVO ] SEÇÃO PRIORIDADE DE MIRA
local SecPriority = Instance.new("Frame", MiraPage); SecPriority.Size = UDim2.new(1,0,0,0); SecPriority.AutomaticSize = Enum.AutomaticSize.Y; SecPriority.BackgroundTransparency = 1
local SecLayout = Instance.new("UIListLayout", SecPriority); SecLayout.Padding = UDim.new(0,5); SecLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

CreateToggle(MiraPage, "Auxílio de Mira", function(v) Settings.AimAssist = v end)
CreateToggle(MiraPage, "Ativar Prioridade", function(v) Settings.TargetPriorityEnabled = v; SecPriority.Visible = v end, false)

local PriorityBtn = Instance.new("TextButton", SecPriority); PriorityBtn.Size = UDim2.new(1,-25,0,32); PriorityBtn.Text = "Prioridade: Distância"; PriorityBtn.BackgroundColor3 = Color3.fromRGB(40,40,40); PriorityBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", PriorityBtn)
PriorityBtn.MouseButton1Click:Connect(function()
    if Settings.PriorityMode == "Distância" then Settings.PriorityMode = "Menor HP"
    elseif Settings.PriorityMode == "Menor HP" then Settings.PriorityMode = "Focado em Mim"
    else Settings.PriorityMode = "Distância" end
    PriorityBtn.Text = "Prioridade: " .. Settings.PriorityMode
end)

-- LÓGICA DE PRIORIDADE 360° E MODOS
local function GetBestTarget()
    local target, bestVal = nil, math.huge
    local potentialTargets = {}

    -- Coleta Players e NPCs
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            if Settings.TeamCheck and p.Team == LocalPlayer.Team then continue end
            table.insert(potentialTargets, p.Character)
        end
    end
    if Settings.AimNPC then
        for _, npc in pairs(workspace:GetDescendants()) do
            if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 and not Players:GetPlayerFromCharacter(npc) then
                table.insert(potentialTargets, npc)
            end
        end
    end

    for _, char in pairs(potentialTargets) do
        local part = char:FindFirstChild(Settings.AimPart) or char:FindFirstChild("HumanoidRootPart")
        if not part then continue end
        
        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
        
        -- Se Prioridade OFF: Apenas quem está no FOV (na frente)
        if not Settings.TargetPriorityEnabled then
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if mag < Settings.AimFOV and mag < bestVal then
                    bestVal, target = mag, part
                end
            end
        else
            -- Se Prioridade ON: Detecta atrás (360°)
            local dist = (part.Position - Camera.CFrame.Position).Magnitude
            
            if Settings.PriorityMode == "Distância" then
                if dist < bestVal then bestVal, target = dist, part end
                
            elseif Settings.PriorityMode == "Menor HP" then
                local hp = char.Humanoid.Health
                if hp < bestVal then bestVal, target = hp, part end
                
            elseif Settings.PriorityMode == "Focado em Mim" then
                -- Verifica se o inimigo está olhando para o LocalPlayer
                local enemyLook = char.HumanoidRootPart.CFrame.LookVector
                local toMe = (LocalPlayer.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Unit
                local dot = enemyLook:Dot(toMe) -- 1.0 = olhando diretamente
                if dot > 0.7 then -- Se estiver "mirando" em mim
                    if dist < bestVal then bestVal, target = dist, part end
                end
            end
        end
    end
    return target
end

-- RENDER LOOP (Simplificado para o exemplo)
RunService.RenderStepped:Connect(function()
    if Settings.AimAssist then
        local target = GetBestTarget()
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Settings.AimSmooth)
        end
    end
end)

-- Botão de Abrir
local ToggleBtn = Instance.new("ImageButton", ScreenGui); ToggleBtn.Size = UDim2.new(0,45,0,45); ToggleBtn.Position = UDim2.new(1,-65,0,15); ToggleBtn.BackgroundColor3 = Color3.fromRGB(20,20,20); Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1,0)
ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible; MenuAberto = Main.Visible end)

--- NOVIDADES v6.5.0 ---
-- [+] AIM: Adicionado Target Priority (Distância, HP e Focado em Mim).
-- [+] AIM: Agora detecta alvos em 360° quando a prioridade está ativa.
-- [+] UI: Sistema de busca global adicionado no topo do menu.
-- [+] UI: Refatoração para suporte a busca em tempo real entre abas.
-------------------------
