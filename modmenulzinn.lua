--// SERVIÇOS
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

--// UNLOCK FPS (Executa ao carregar)
if setfpscap then setfpscap(120) end

--// CONFIG
getgenv().Settings = {
    ESP = false, Boxes = false, Names = false, Distance = false, Highlight = false, Lines = false, TeamColor = false,
    HitboxEnabled = false, Hitbox = 20, HitboxTransparency = 0.6,
    UseSpeed = false, Speed = 16, UseJump = false, JumpPower = 50, InfiniteJump = false,
    BoostFPS = false, RemoveShadows = false, FPSCap = 120 -- Alterado para 120 padrão
}

local VERSION = "v4.4"
local CHANGELOG_TEXT = [[
--- HISTÓRICO DE VERSÕES ---
v4.4: FPS Padrão definido para 120. Unlock FPS no Start.
v4.3: Restaurado botões de Distância e Nomes. Fix na aba Infos.
v4.2: Aba FPS e Otimização de Texturas.
v4.1: UI Inteligente e Auto-Resize.
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

local FPSLabel = Instance.new("TextLabel", Main)
FPSLabel.Size = UDim2.new(0,50,0,35); FPSLabel.Position = UDim2.new(1,-60,0,0); FPSLabel.Text = "FPS: 0"; FPSLabel.BackgroundTransparency = 1; FPSLabel.TextColor3 = Color3.new(0,1,0); FPSLabel.TextSize = 12; FPSLabel.Font = Enum.Font.Code; FPSLabel.TextTransparency = 1

-- ABAS (SCROLL)
local TabsFrame = Instance.new("ScrollingFrame", Main)
TabsFrame.Size = UDim2.new(1,0,0,35); TabsFrame.Position = UDim2.new(0,0,0,35); TabsFrame.BackgroundTransparency = 1; TabsFrame.ScrollBarThickness = 0; TabsFrame.CanvasSize = UDim2.new(0,0,0,0)

local TabList = Instance.new("UIListLayout", TabsFrame)
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabsFrame.CanvasSize = UDim2.new(0, TabList.AbsoluteContentSize.X, 0, 0)
end)

local Pages = Instance.new("Frame", Main)
Pages.Position = UDim2.new(0,0,0,70); Pages.Size = UDim2.new(1,0,1,-70); Pages.BackgroundTransparency = 1

local function UpdateMenuSize(pageSizeY)
    local targetHeight = math.clamp(pageSizeY + 110, 200, 500)
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

local ESPPage, eb = CreatePage("ESP")
local PlayerPage, pb = CreatePage("PLAYER")
local HitboxPage, hb = CreatePage("HITBOX")
local FPSPage, fb = CreatePage("FPS")
local InfoPage, ib = CreatePage("INFOS")
ESPPage.Visible = true

-- COMPONENTES UI
local function CreateToggle(parent, text, callback, default)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1,-20,0,35); b.Text = text..": "..(default and "ON" or "OFF"); b.BackgroundColor3 = default and Color3.fromRGB(50,100,50) or Color3.fromRGB(30,30,30); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    local state = default or false
    b.MouseButton1Click:Connect(function()
        state = not state
        b.Text = text..": "..(state and "ON" or "OFF")
        b.BackgroundColor3 = state and Color3.fromRGB(50,100,50) or Color3.fromRGB(30,30,30)
        callback(state)
    end)
end

local function CreateStepper(parent, text, min, max, default, step, callback)
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(1,-20,0,60); frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame); label.Size = UDim2.new(1,0,0,25); label.Text = text..": "..default; label.TextColor3 = Color3.new(1,1,1); label.BackgroundTransparency = 1
    local minus = Instance.new("TextButton", frame); minus.Size = UDim2.new(0,40,0,30); minus.Position = UDim2.new(0.2,0,0,25); minus.Text = "-"; minus.BackgroundColor3 = Color3.fromRGB(40,40,40); minus.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", minus)
    local plus = Instance.new("TextButton", frame); plus.Size = UDim2.new(0,40,0,30); plus.Position = UDim2.new(0.6,0,0,25); plus.Text = "+"; plus.BackgroundColor3 = Color3.fromRGB(40,40,40); plus.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", plus)
    local val = default; local function up(n) val = math.clamp(n, min, max); label.Text = text..": "..val; callback(val) end
    minus.MouseButton1Click:Connect(function() up(val - step) end); plus.MouseButton1Click:Connect(function() up(val + step) end)
end

-- SETUP ABAS
CreateToggle(ESPPage, "ESP Geral", function(v) Settings.ESP = v end)
CreateToggle(ESPPage, "Team Color", function(v) Settings.TeamColor = v end)
CreateToggle(ESPPage, "Boxes", function(v) Settings.Boxes = v end)
CreateToggle(ESPPage, "DisplayNames", function(v) Settings.Names = v end, true)
CreateToggle(ESPPage, "Distancia", function(v) Settings.Distance = v end, true)
CreateToggle(ESPPage, "Lines", function(v) Settings.Lines = v end)
CreateToggle(ESPPage, "Chams", function(v) Settings.Highlight = v end)

CreateToggle(PlayerPage, "Ativar Velocidade", function(v) Settings.UseSpeed = v end)
CreateStepper(PlayerPage, "Speed", 16, 500, 16, 5, function(v) Settings.Speed = v end)
CreateToggle(PlayerPage, "Ativar Pulo", function(v) Settings.UseJump = v end)
CreateStepper(PlayerPage, "Jump Power", 50, 500, 50, 5, function(v) Settings.JumpPower = v end)
CreateToggle(PlayerPage, "Pulo Infinito", function(v) Settings.InfiniteJump = v end)

CreateToggle(HitboxPage, "Hitbox Expander", function(v) Settings.HitboxEnabled = v end)
CreateStepper(HitboxPage, "Tamanho", 2, 100, 20, 5, function(v) Settings.Hitbox = v end)
CreateStepper(HitboxPage, "Opacidade %", 0, 100, 60, 10, function(v) Settings.HitboxTransparency = v/100 end)

CreateToggle(FPSPage, "Otimizar Texturas", function(v) 
    Settings.BoostFPS = v
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("Texture") or obj:IsA("Decal") then obj.Transparency = v and 1 or 0 end
    end
end)
CreateToggle(FPSPage, "Remover Sombras", function(v) Lighting.GlobalShadows = not v end)
CreateStepper(FPSPage, "Limite FPS", 30, 240, 120, 30, function(v) if setfpscap then setfpscap(v) end end)

-- ABA INFOS
local LogLabel = Instance.new("TextLabel", InfoPage)
LogLabel.Size = UDim2.new(1,-20,0,0); LogLabel.AutomaticSize = Enum.AutomaticSize.Y; LogLabel.BackgroundTransparency = 1; LogLabel.TextColor3 = Color3.fromRGB(200,200,200); LogLabel.TextSize = 13; LogLabel.Font = Enum.Font.Code; LogLabel.Text = CHANGELOG_TEXT; LogLabel.TextXAlignment = Enum.TextXAlignment.Left; LogLabel.TextWrapped = true

-- LÓGICA ESP
local ESPContainer = {}
local function CreateESP(p)
    if p == LocalPlayer then return end
    ESPContainer[p] = {Box = Drawing.new("Square"), Name = Drawing.new("Text"), Dist = Drawing.new("Text"), Line = Drawing.new("Line"), Highlight = nil}
    local e = ESPContainer[p]; e.Box.Thickness = 1.5; e.Box.Filled = false; e.Name.Size = 16; e.Name.Center = true; e.Name.Outline = true; e.Dist.Size = 14; e.Dist.Center = true; e.Dist.Outline = true; e.Line.Thickness = 1
end
local function RemoveESP(p)
    if ESPContainer[p] then
        ESPContainer[p].Box:Remove(); ESPContainer[p].Name:Remove(); ESPContainer[p].Dist:Remove(); ESPContainer[p].Line:Remove()
        if ESPContainer[p].Highlight then ESPContainer[p].Highlight:Destroy() end
        ESPContainer[p] = nil
    end
end
Players.PlayerAdded:Connect(CreateESP); Players.PlayerRemoving:Connect(RemoveESP)
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end

-- RENDER LOOP
local lastUpdate = tick()
local frameCount = 0
RunService.RenderStepped:Connect(function()
    frameCount += 1
    local now = tick()
    if now - lastUpdate >= 1 then
        FPSLabel.Text = "FPS: "..frameCount
        frameCount = 0
        lastUpdate = now
    end

    if Settings.UseSpeed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = Settings.Speed end
    if Settings.UseJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = Settings.JumpPower end
    
    for p, e in pairs(ESPContainer) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and Settings.ESP then
            local hrp = p.Character.HumanoidRootPart; local pos, vis = Camera:WorldToViewportPoint(hrp.Position)
            local color = (Settings.TeamColor and p.TeamColor) and p.TeamColor.Color or Color3.new(1,1,1)
            if vis then
                if Settings.Boxes then e.Box.Visible = true; e.Box.Size = Vector2.new(2500/pos.Z, 3500/pos.Z); e.Box.Position = Vector2.new(pos.X - e.Box.Size.X/2, pos.Y - e.Box.Size.Y/2); e.Box.Color = color else e.Box.Visible = false end
                if Settings.Names then e.Name.Visible = true; e.Name.Text = p.DisplayName; e.Name.Position = Vector2.new(pos.X, pos.Y - (2000/pos.Z) - 20); e.Name.Color = color else e.Name.Visible = false end
                if Settings.Distance then e.Dist.Visible = true; e.Dist.Text = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude).."m"; e.Dist.Position = Vector2.new(pos.X, pos.Y + (2000/pos.Z) + 5); e.Dist.Color = Color3.new(0,1,0) else e.Dist.Visible = false end
                if Settings.Lines then local head = p.Character:FindFirstChild("Head"); if head then local hpos = Camera:WorldToViewportPoint(head.Position); e.Line.Visible = true; e.Line.From = Vector2.new(Camera.ViewportSize.X/2, 0); e.Line.To = Vector2.new(hpos.X, hpos.Y); e.Line.Color = color end else e.Line.Visible = false end
                if Settings.Highlight then
                    if not e.Highlight or e.Highlight.Parent ~= p.Character then if e.Highlight then e.Highlight:Destroy() end e.Highlight = Instance.new("Highlight", p.Character) end
                    e.Highlight.Enabled = true; e.Highlight.FillColor = color; e.Highlight.FillTransparency = 0.5
                elseif e.Highlight then e.Highlight.Enabled = false end
            else e.Box.Visible = false; e.Name.Visible = false; e.Dist.Visible = false; e.Line.Visible = false; if e.Highlight then e.Highlight.Enabled = false end end
        else e.Box.Visible = false; e.Name.Visible = false; e.Dist.Visible = false; e.Line.Visible = false; if e.Highlight then e.Highlight:Destroy(); e.Highlight = nil end end
    end
end)

-- HITBOX / PULO
task.spawn(function()
    while true do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                if Settings.HitboxEnabled then
                    hrp.Size = Vector3.new(Settings.Hitbox, Settings.Hitbox, Settings.Hitbox)
                    hrp.Transparency = Settings.HitboxTransparency; hrp.CanCollide = false
                else hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 1 end
            end
        end
        task.wait(0.1)
    end
end)
UIS.JumpRequest:Connect(function() if Settings.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid:ChangeState("Jumping") end end)

-- ANIMAÇÕES
local function OpenUI()
    MenuAberto = true; Main.Visible = true; Main.Position = UDim2.new(0.5, -150, 0.5, -190)
    local tw = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    TweenService:Create(Main, tw, {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(stroke, tw, {Transparency = 0}):Play()
    TweenService:Create(Title, tw, {TextTransparency = 0}):Play()
    TweenService:Create(FPSLabel, tw, {TextTransparency = 0}):Play()
    for _, b in pairs(TabsFrame:GetChildren()) do if b:IsA("TextButton") then TweenService:Create(b, tw, {TextTransparency = 0}):Play() end end
    UpdateMenuSize(ESPPage.UIListLayout.AbsoluteContentSize.Y)
end

local function CloseUI()
    MenuAberto = false; local tw = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    local anim = TweenService:Create(Main, tw, {Size = UDim2.new(0, 300, 0, 0), BackgroundTransparency = 1})
    TweenService:Create(stroke, tw, {Transparency = 1}):Play(); TweenService:Create(Title, tw, {TextTransparency = 1}):Play(); TweenService:Create(FPSLabel, tw, {TextTransparency = 1}):Play()
    for _, b in pairs(TabsFrame:GetChildren()) do if b:IsA("TextButton") then TweenService:Create(b, tw, {TextTransparency = 1}):Play() end end
    anim:Play(); anim.Completed:Connect(function() Main.Visible = false end)
end

ToggleBtn.MouseButton1Click:Connect(function() if Main.Visible then CloseUI() else OpenUI() end end)
