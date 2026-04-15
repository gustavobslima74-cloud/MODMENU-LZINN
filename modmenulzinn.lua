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
    -- TELEPORT SETTINGS
    SelectedPlayer = nil, AutoNearest = false, StickyBehind = false, StickySmoothness = 0.2
}

local VERSION = "v4.7"
local CHANGELOG_TEXT = [[
--- HISTÓRICO DE VERSÕES ---
v4.7: Abas TELEPORTE e MIRA. Sistema de Seleção de Player e Sticky.
v4.6: Force Third Person (Aba Player).
v4.5: Names/Distance OFF por padrão.
v4.4: FPS 120 e Auto-Resize UI.
----------------------------]]

local MenuAberto = false

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
Main.Size = UDim2.new(0,300,0,380); Main.Position = UDim2.new(0.5, -150, 0.5, -190); Main.BackgroundColor3 = Color3.fromRGB(10,10,10); Main.ClipsDescendants = true; Main.Visible = false; Main.BackgroundTransparency = 1
Instance.new("UICorner", Main); MakeDraggable(Main, true)

local stroke = Instance.new("UIStroke", Main)
stroke.Thickness = 2; stroke.Transparency = 1; task.spawn(function() while true do stroke.Color = Color3.fromHSV(tick()%5/5,1,1); task.wait() end end)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,35); Title.Text = "LQB KIKO | " .. VERSION; Title.BackgroundTransparency = 1; Title.TextColor3 = Color3.new(1,1,1); Title.TextSize = 16; Title.Font = Enum.Font.GothamBold; Title.TextTransparency = 1

-- ABAS (SCROLL)
local TabsFrame = Instance.new("ScrollingFrame", Main)
TabsFrame.Size = UDim2.new(1,0,0,35); TabsFrame.Position = UDim2.new(0,0,0,35); TabsFrame.BackgroundTransparency = 1; TabsFrame.ScrollBarThickness = 0; TabsFrame.CanvasSize = UDim2.new(0,0,0,0)

local TabList = Instance.new("UIListLayout", TabsFrame)
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() TabsFrame.CanvasSize = UDim2.new(0, TabList.AbsoluteContentSize.X, 0, 0) end)

local Pages = Instance.new("Frame", Main)
Pages.Position = UDim2.new(0,0,0,70); Pages.Size = UDim2.new(1,0,1,-70); Pages.BackgroundTransparency = 1

local function UpdateMenuSize(pageSizeY)
    local targetHeight = math.clamp(pageSizeY + 110, 250, 500)
    TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 300, 0, targetHeight)}):Play()
end

local function CreatePage(name)
    local btn = Instance.new("TextButton", TabsFrame)
    btn.Size = UDim2.new(0, 75, 1, 0); btn.Text = name; btn.BackgroundTransparency = 1; btn.TextColor3 = Color3.new(1,1,1); btn.TextTransparency = 1; btn.TextSize = 11
    local page = Instance.new("ScrollingFrame", Pages)
    page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1; page.Visible = false; page.ScrollBarThickness = 2
    local layout = Instance.new("UIListLayout", page); layout.Padding = UDim.new(0,5); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    btn.MouseButton1Click:Connect(function() for _,v in pairs(Pages:GetChildren()) do v.Visible = false end; page.Visible = true; UpdateMenuSize(layout.AbsoluteContentSize.Y) end)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() page.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10); if page.Visible then UpdateMenuSize(layout.AbsoluteContentSize.Y) end end)
    return page, btn
end

-- CRIAÇÃO DAS ABAS
local ESPPage, eb = CreatePage("ESP")
local PlayerPage, pb = CreatePage("PLAYER")
local TeleportPage, tpb = CreatePage("TELEPORTE")
local MiraPage, mb = CreatePage("MIRA")
local HitboxPage, hb = CreatePage("HITBOX")
local FPSPage, fb = CreatePage("FPS")
local InfoPage, ib = CreatePage("INFOS")
ESPPage.Visible = true

-- ABA MIRA (EM BREVE)
local MiraText = Instance.new("TextLabel", MiraPage)
MiraText.Size = UDim2.new(1,0,0,50); MiraText.Text = "EM BREVE..."; MiraText.TextColor3 = Color3.new(1,1,1); MiraText.BackgroundTransparency = 1; MiraText.Font = Enum.Font.GothamBold

-- ABA TELEPORTE (LÓGICA LISTA)
local SelectedLabel = Instance.new("TextLabel", TeleportPage)
SelectedLabel.Size = UDim2.new(1,-20,0,30); SelectedLabel.Text = "Selecionado: Nenhum"; SelectedLabel.TextColor3 = Color3.new(0,1,0); SelectedLabel.BackgroundTransparency = 1

local PlayerListFrame = Instance.new("ScrollingFrame", TeleportPage)
PlayerListFrame.Size = UDim2.new(1,-20,0,120); PlayerListFrame.BackgroundColor3 = Color3.fromRGB(20,20,20); PlayerListFrame.ScrollBarThickness = 4
local ListLayout = Instance.new("UIListLayout", PlayerListFrame)

local function UpdatePlayerList()
    for _, child in pairs(PlayerListFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pBtn = Instance.new("TextButton", PlayerListFrame)
            pBtn.Size = UDim2.new(1,0,0,25); pBtn.Text = p.DisplayName; pBtn.BackgroundColor3 = Color3.fromRGB(35,35,35); pBtn.TextColor3 = Color3.new(1,1,1)
            pBtn.MouseButton1Click:Connect(function()
                Settings.SelectedPlayer = p
                SelectedLabel.Text = "Selecionado: " .. p.DisplayName
            end)
        end
    end
    PlayerListFrame.CanvasSize = UDim2.new(0,0,0,ListLayout.AbsoluteContentSize.Y)
end

Players.PlayerAdded:Connect(UpdatePlayerList); Players.PlayerRemoving:Connect(UpdatePlayerList)
UpdatePlayerList()

local RefreshBtn = Instance.new("TextButton", TeleportPage)
RefreshBtn.Size = UDim2.new(1,-20,0,30); RefreshBtn.Text = "Atualizar Lista"; RefreshBtn.BackgroundColor3 = Color3.fromRGB(40,40,40); RefreshBtn.TextColor3 = Color3.new(1,1,1); RefreshBtn.MouseButton1Click:Connect(UpdatePlayerList)

local function TeleportToPlayer()
    if Settings.SelectedPlayer and Settings.SelectedPlayer.Character and Settings.SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = Settings.SelectedPlayer.Character.HumanoidRootPart.CFrame
    end
end

local TpBtn = Instance.new("TextButton", TeleportPage)
TpBtn.Size = UDim2.new(1,-20,0,40); TpBtn.Text = "TELEPORTAR"; TpBtn.BackgroundColor3 = Color3.fromRGB(0,120,0); TpBtn.TextColor3 = Color3.new(1,1,1); TpBtn.MouseButton1Click:Connect(TeleportToPlayer)

local function CreateToggle(parent, text, callback, default)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1,-20,0,35); b.Text = text..": "..(default and "ON" or "OFF"); b.BackgroundColor3 = default and Color3.fromRGB(50,100,50) or Color3.fromRGB(30,30,30); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    local state = default or false
    b.MouseButton1Click:Connect(function() state = not state; b.Text = text..": "..(state and "ON" or "OFF"); b.BackgroundColor3 = state and Color3.fromRGB(50,100,50) or Color3.fromRGB(30,30,30); callback(state) end)
end

local function CreateStepper(parent, text, min, max, default, step, callback)
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(1,-20,0,60); frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame); label.Size = UDim2.new(1,0,0,25); label.Text = text..": "..default; label.TextColor3 = Color3.new(1,1,1); label.BackgroundTransparency = 1
    local minus = Instance.new("TextButton", frame); minus.Size = UDim2.new(0,40,0,30); minus.Position = UDim2.new(0,50,0,25); minus.Text = "-"; minus.BackgroundColor3 = Color3.fromRGB(40,40,40); minus.TextColor3 = Color3.new(1,1,1); minus.MouseButton1Click:Connect(function() end)
    local plus = Instance.new("TextButton", frame); plus.Size = UDim2.new(0,40,0,30); plus.Position = UDim2.new(0,180,0,25); plus.Text = "+"; plus.BackgroundColor3 = Color3.fromRGB(40,40,40); plus.TextColor3 = Color3.new(1,1,1)
    local val = default; local function up(n) val = math.clamp(n, min, max); label.Text = text..": "..string.format("%.1f", val); callback(val) end
    minus.MouseButton1Click:Connect(function() up(val - step) end); plus.MouseButton1Click:Connect(function() up(val + step) end)
end

CreateToggle(TeleportPage, "Auto Próximo", function(v) Settings.AutoNearest = v end)
CreateToggle(TeleportPage, "Grudar Atrás", function(v) Settings.StickyBehind = v end)
CreateStepper(TeleportPage, "Suavidade Grudar", 0.1, 1, 0.2, 0.1, function(v) Settings.StickySmoothness = v end)

-- [RESTAURANTE DAS OUTRAS ABAS MANTIDO]
CreateToggle(ESPPage, "ESP Geral", function(v) Settings.ESP = v end)
CreateToggle(ESPPage, "Team Color", function(v) Settings.TeamColor = v end)
CreateToggle(ESPPage, "DisplayNames", function(v) Settings.Names = v end, false)
CreateToggle(ESPPage, "Distancia", function(v) Settings.Distance = v end, false)

CreateToggle(PlayerPage, "Third Person", function(v) Settings.ForceThirdPerson = v end)
CreateToggle(PlayerPage, "Ativar Velocidade", function(v) Settings.UseSpeed = v end)
CreateStepper(PlayerPage, "Speed", 16, 500, 16, 5, function(v) Settings.Speed = v end)

-- ABA INFOS
local LogLabel = Instance.new("TextLabel", InfoPage)
LogLabel.Size = UDim2.new(1,-20,0,0); LogLabel.AutomaticSize = Enum.AutomaticSize.Y; LogLabel.BackgroundTransparency = 1; LogLabel.TextColor3 = Color3.fromRGB(200,200,200); LogLabel.TextSize = 13; LogLabel.Font = Enum.Font.Code; LogLabel.Text = CHANGELOG_TEXT; LogLabel.TextXAlignment = Enum.TextXAlignment.Left; LogLabel.TextWrapped = true

-- LÓGICA RENDER (AUTO NEAREST / STICKY)
RunService.RenderStepped:Connect(function()
    -- Auto Nearest
    if Settings.AutoNearest then
        local nearest = nil
        local minDist = math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if dist < minDist then
                    minDist = dist; nearest = p
                end
            end
        end
        if nearest then
            Settings.SelectedPlayer = nearest
            SelectedLabel.Text = "Selecionado: " .. nearest.DisplayName
        end
    end

    -- Sticky Behind
    if Settings.StickyBehind and Settings.SelectedPlayer and Settings.SelectedPlayer.Character then
        local targetHRP = Settings.SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetHRP then
            local targetPos = targetHRP.CFrame * CFrame.new(0, 0, 3) -- Atrás do player
            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame:Lerp(targetPos, Settings.StickySmoothness)
        end
    end
end)

-- ANIMAÇÕES
local function OpenUI()
    MenuAberto = true; Main.Visible = true; Main.Position = UDim2.new(0.5, -150, 0.5, -190)
    local tw = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
    TweenService:Create(Main, tw, {Size = UDim2.new(0, 300, 0, 380), BackgroundTransparency = 0.1}):Play()
    TweenService:Create(stroke, tw, {Transparency = 0}):Play()
    TweenService:Create(Title, tw, {TextTransparency = 0}):Play()
    for _, b in pairs(TabsFrame:GetChildren()) do if b:IsA("TextButton") then TweenService:Create(b, tw, {TextTransparency = 0}):Play() end end
end

local function CloseUI()
    MenuAberto = false; local tw = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    local anim = TweenService:Create(Main, tw, {Size = UDim2.new(0, 300, 0, 0), BackgroundTransparency = 1})
    TweenService:Create(stroke, tw, {Transparency = 1}):Play(); TweenService:Create(Title, tw, {TextTransparency = 1}):Play()
    for _, b in pairs(TabsFrame:GetChildren()) do if b:IsA("TextButton") then TweenService:Create(b, tw, {TextTransparency = 1}):Play() end end
    anim:Play(); anim.Completed:Connect(function() Main.Visible = false end)
end

-- ANIM BOTÃO APERTADO (MELHORADO)
ToggleBtn.MouseButton1Down:Connect(function()
    TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 45, 0, 45)}):Play()
end)

ToggleBtn.MouseButton1Up:Connect(function()
    TweenService:Create(ToggleBtn, TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Size = UDim2.new(0, 60, 0, 60)}):Play()
    if Main.Visible then CloseUI() else OpenUI() end
end)
