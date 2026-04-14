--// SERVIÇOS
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--// CONFIG
getgenv().Settings = {
    ESP = false, Boxes = false, Names = true, Distance = true, Highlight = false, Lines = false, TeamColor = false,
    HitboxEnabled = false, Hitbox = 20, HitboxTransparency = 0.6,
    UseSpeed = false, Speed = 16, UseJump = false, JumpPower = 50, InfiniteJump = false,
    
    -- NOVAS CONFIGS COMBAT
    NoStun = false, NoFreeze = false, NoKnockback = false,
    
    -- NOVAS CONFIGS AIM
    AimAssist = false, AimFOV = 100, ShowFOV = false, AimSmoothing = 5
}

local VERSION = "v3.9"
local CHANGELOG_TEXT = [[
--- HISTÓRICO DE VERSÕES ---
v3.9: Novas Abas COMBAT e AIM. Adicionado NoStun/Freeze e Círculo de FOV.
v3.8: ESP Team Color (Coloração automática).
v3.7: Ajuste de Texto (TextWrapped).
v3.6: Aba INFOS e ESP Lines.
----------------------------]]

local MenuAberto = false
local FOVCircle = Drawing.new("Circle") -- Círculo do FOV

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
Title.Size = UDim2.new(1,0,0,35); Title.Text = "LQB KIKO | " .. VERSION; Title.BackgroundTransparency = 1; Title.TextColor3 = Color3.new(1,1,1); Title.TextSize = 18; Title.Font = Enum.Font.GothamBold; Title.TextTransparency = 1

-- ABAS (Ajustado para 0.16 para caber 6 abas pequenas ou scroll)
local Tabs = Instance.new("ScrollingFrame", Main)
Tabs.Size = UDim2.new(1,0,0,35); Tabs.Position = UDim2.new(0,0,0,35); Tabs.BackgroundTransparency = 1; Tabs.CanvasSize = UDim2.new(1.5,0,0,0); Tabs.ScrollBarThickness = 0
Instance.new("UIListLayout", Tabs).FillDirection = Enum.FillDirection.Horizontal

local Pages = Instance.new("Frame", Main)
Pages.Position = UDim2.new(0,0,0,70); Pages.Size = UDim2.new(1,0,1,-70); Pages.BackgroundTransparency = 1

local function CreatePage(name)
    local btn = Instance.new("TextButton", Tabs)
    btn.Size = UDim2.new(0, 80, 1, 0); btn.Text = name; btn.BackgroundTransparency = 1; btn.TextColor3 = Color3.new(1,1,1); btn.TextTransparency = 1; btn.TextSize = 11
    local page = Instance.new("ScrollingFrame", Pages)
    page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1; page.Visible = false; page.ScrollBarThickness = 3
    local layout = Instance.new("UIListLayout", page); layout.Padding = UDim.new(0,5); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() page.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10) end)
    btn.MouseButton1Click:Connect(function() for _,v in pairs(Pages:GetChildren()) do v.Visible = false end; page.Visible = true end)
    return page, btn
end

local ESPPage, eb = CreatePage("ESP")
local PlayerPage, pb = CreatePage("PLAYER")
local CombatPage, cb = CreatePage("COMBAT")
local AimPage, ab = CreatePage("AIM")
local HitboxPage, hb = CreatePage("HITBOX")
local InfoPage, ib = CreatePage("INFOS")
ESPPage.Visible = true

-- ABA INFOS
local LogLabel = Instance.new("TextLabel", InfoPage)
LogLabel.Size = UDim2.new(1,-20,0,0); LogLabel.AutomaticSize = Enum.AutomaticSize.Y; LogLabel.BackgroundTransparency = 1; LogLabel.TextColor3 = Color3.fromRGB(200,200,200); LogLabel.TextSize = 13; LogLabel.Font = Enum.Font.Code; LogLabel.Text = CHANGELOG_TEXT; LogLabel.TextXAlignment = Enum.TextXAlignment.Left; LogLabel.TextWrapped = true

-- COMPONENTES UI
local function CreateToggle(parent, text, callback)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1,-20,0,35); b.Text = text..": OFF"; b.BackgroundColor3 = Color3.fromRGB(30,30,30); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    local state = false; b.MouseButton1Click:Connect(function() state = not state; b.Text = text..": "..(state and "ON" or "OFF"); b.BackgroundColor3 = state and Color3.fromRGB(50,100,50) or Color3.fromRGB(30,30,30); callback(state) end)
end
local function CreateStepper(parent, text, min, max, default, step, callback)
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(1,-20,0,60); frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame); label.Size = UDim2.new(1,0,0,25); label.Text = text..": "..default; label.TextColor3 = Color3.new(1,1,1); label.BackgroundTransparency = 1
    local minus = Instance.new("TextButton", frame); minus.Size = UDim2.new(0.4,0,0,30); minus.Position = UDim2.new(0.05,0,0,25); minus.Text = "-"; minus.BackgroundColor3 = Color3.fromRGB(40,40,40); minus.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", minus)
    local plus = Instance.new("TextButton", frame); plus.Size = UDim2.new(0.4,0,0,30); plus.Position = UDim2.new(0.55,0,0,25); plus.Text = "+"; plus.BackgroundColor3 = Color3.fromRGB(40,40,40); plus.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", plus)
    local val = default; local function up(n) val = math.clamp(n, min, max); label.Text = text..": "..val; callback(val) end
    minus.MouseButton1Click:Connect(function() up(val - step) end); plus.MouseButton1Click:Connect(function() up(val + step) end)
end

-- SETUP ABAS
CreateToggle(ESPPage, "ESP Geral", function(v) Settings.ESP = v end)
CreateToggle(ESPPage, "Team Color", function(v) Settings.TeamColor = v end)
CreateToggle(ESPPage, "Lines", function(v) Settings.Lines = v end)

CreateToggle(CombatPage, "No Stun", function(v) Settings.NoStun = v end)
CreateToggle(CombatPage, "No Freeze", function(v) Settings.NoFreeze = v end)
CreateToggle(CombatPage, "No Knockback", function(v) Settings.NoKnockback = v end)

CreateToggle(AimPage, "Assistência de Mira", function(v) Settings.AimAssist = v end)
CreateToggle(AimPage, "Exibir FOV", function(v) Settings.ShowFOV = v end)
CreateStepper(AimPage, "Tamanho FOV", 50, 500, 100, 10, function(v) Settings.AimFOV = v end)

-- ANIMAÇÕES ABRIR/FECHAR
local function OpenUI()
    MenuAberto = true; Main.Visible = true; Main.Position = UDim2.new(0.5, -150, 0.5, -190)
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    TweenService:Create(Main, tweenInfo, {Size = UDim2.new(0, 300, 0, 380), BackgroundTransparency = 0.1}):Play()
    TweenService:Create(stroke, tweenInfo, {Transparency = 0}):Play()
    TweenService:Create(Title, tweenInfo, {TextTransparency = 0}):Play()
    for _, b in pairs(Tabs:GetChildren()) do if b:IsA("TextButton") then TweenService:Create(b, tweenInfo, {TextTransparency = 0}):Play() end end
end
local function CloseUI()
    MenuAberto = false; local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    local anim = TweenService:Create(Main, tweenInfo, {Size = UDim2.new(0, 300, 0, 0), BackgroundTransparency = 1})
    TweenService:Create(stroke, tweenInfo, {Transparency = 1}):Play()
    TweenService:Create(Title, tweenInfo, {TextTransparency = 1}):Play()
    for _, b in pairs(Tabs:GetChildren()) do if b:IsA("TextButton") then TweenService:Create(b, tweenInfo, {TextTransparency = 1}):Play() end end
    anim:Play(); anim.Completed:Connect(function() Main.Visible = false end)
end

-- LÓGICA DE COMBATE (NO STUN / FREEZE)
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char then
        if Settings.NoStun and char:FindFirstChild("Stun") then char.Stun:Destroy() end
        if Settings.NoFreeze and char:FindFirstChild("Freeze") then char.Freeze:Destroy() end
        -- No Knockback: Frequentemente requer zerar a velocidade da Velocity/BodyVelocity
        if Settings.NoKnockback and char:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(char.HumanoidRootPart:GetChildren()) do
                if v:IsA("BodyVelocity") or v:IsA("BodyForce") then v:Destroy() end
            end
        end
    end
    
    -- Atualizar FOV Circle
    FOVCircle.Visible = Settings.ShowFOV
    FOVCircle.Radius = Settings.AimFOV
    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Color = Color3.new(1,1,1)
    FOVCircle.Thickness = 1
end)

-- CLICK E LOOP ESP MANTIDOS DAS VERSÕES ANTERIORES
ToggleBtn.MouseButton1Click:Connect(function()
    ToggleBtn:TweenSize(UDim2.new(0,50,0,50), "Out", "Quad", 0.1, true)
    task.wait(0.1); ToggleBtn:TweenSize(UDim2.new(0,60,0,60), "Out", "Elastic", 0.4, true)
    if Main.Visible then CloseUI() else OpenUI() end
end)
