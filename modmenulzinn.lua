--// SERVIÇOS
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--// CONFIG
getgenv().Settings = {
    ESP = false,
    Boxes = false,
    Names = true,
    Distance = true,
    Highlight = false,

    HitboxEnabled = false,
    Hitbox = 20,
    HitboxTransparency = 0.6,

    UseSpeed = false,
    Speed = 16,

    UseJump = false,
    JumpPower = 50,

    InfiniteJump = false
}

--// VARIÁVEIS DE CONTROLE
local MenuAberto = false

--// FUNÇÃO DRAG MELHORADA (COM TRAVA)
local function MakeDraggable(gui, isMenu)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        -- Se for o botão e o menu estiver aberto, não deixa arrastar
        if not isMenu and MenuAberto then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if not isMenu and MenuAberto then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
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

-- BOTÃO ABRIR
local ToggleBtn = Instance.new("ImageButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0,60,0,60)
ToggleBtn.Position = UDim2.new(0,20,0.6,0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20,20,20)
ToggleBtn.Image = "rbxassetid://70505361093133"
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1,0)
MakeDraggable(ToggleBtn, false) -- Inicia livre

-- JANELA
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,300,0,380)
Main.Position = UDim2.new(0.5, -150, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(10,10,10)
Main.ClipsDescendants = true
Main.Visible = false
Main.BackgroundTransparency = 1
Instance.new("UICorner", Main)
MakeDraggable(Main, true) -- Menu sempre arrastável

local stroke = Instance.new("UIStroke", Main)
stroke.Thickness = 2
stroke.Transparency = 1
task.spawn(function()
    while true do
        stroke.Color = Color3.fromHSV(tick()%5/5,1,1)
        task.wait()
    end
end)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,35)
Title.Text = "LQB KIKO | v3.5"
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextTransparency = 1

-- ABAS
local Tabs = Instance.new("Frame", Main)
Tabs.Size = UDim2.new(1,0,0,30)
Tabs.Position = UDim2.new(0,0,0,35)
Tabs.BackgroundTransparency = 1
Instance.new("UIListLayout", Tabs).FillDirection = Enum.FillDirection.Horizontal

local Pages = Instance.new("Frame", Main)
Pages.Position = UDim2.new(0,0,0,70)
Pages.Size = UDim2.new(1,0,1,-70)
Pages.BackgroundTransparency = 1

local function CreatePage(name)
    local btn = Instance.new("TextButton", Tabs)
    btn.Size = UDim2.new(0.33,0,1,0)
    btn.Text = name
    btn.BackgroundTransparency = 1
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextTransparency = 1

    local page = Instance.new("ScrollingFrame", Pages)
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 3
    
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0,5)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
    end)
    
    btn.MouseButton1Click:Connect(function()
        for _,v in pairs(Pages:GetChildren()) do v.Visible = false end
        page.Visible = true
    end)
    return page, btn
end

local ESPPage, eb = CreatePage("ESP")
local PlayerPage, pb = CreatePage("PLAYER")
local HitboxPage, hb = CreatePage("HITBOX")
ESPPage.Visible = true

-- COMPONENTES UI (MANTIDOS)
local function CreateToggle(parent, text, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1,-20,0,35)
    b.Text = text..": OFF"
    b.BackgroundColor3 = Color3.fromRGB(30,30,30)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    local state = false
    b.MouseButton1Click:Connect(function()
        state = not state
        b.Text = text..": "..(state and "ON" or "OFF")
        b.BackgroundColor3 = state and Color3.fromRGB(50,100,50) or Color3.fromRGB(30,30,30)
        callback(state)
    end)
end

local function CreateStepper(parent, text, min, max, default, step, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1,-20,0,60)
    frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,0,0,25)
    label.Text = text..": "..default
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    local minus = Instance.new("TextButton", frame)
    minus.Size = UDim2.new(0.4,0,0,30)
    minus.Position = UDim2.new(0.05,0,0,25)
    minus.Text = "-"
    minus.BackgroundColor3 = Color3.fromRGB(40,40,40)
    minus.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", minus); local plus = Instance.new("TextButton", frame)
    plus.Size = UDim2.new(0.4,0,0,30); plus.Position = UDim2.new(0.55,0,0,25)
    plus.Text = "+"; plus.BackgroundColor3 = Color3.fromRGB(40,40,40); plus.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", plus)
    local val = default
    local function up(n) val = math.clamp(n, min, max); label.Text = text..": "..val; callback(val) end
    minus.MouseButton1Click:Connect(function() up(val - step) end); plus.MouseButton1Click:Connect(function() up(val + step) end)
end

-- SETUP ABAS
CreateToggle(ESPPage, "ESP Geral", function(v) Settings.ESP = v end)
CreateToggle(ESPPage, "Boxes", function(v) Settings.Boxes = v end)
CreateToggle(ESPPage, "Names", function(v) Settings.Names = v end)
CreateToggle(ESPPage, "Distance", function(v) Settings.Distance = v end)
CreateToggle(ESPPage, "Chams", function(v) Settings.Highlight = v end)

CreateToggle(PlayerPage, "Ativar Velocidade", function(v) Settings.UseSpeed = v end)
CreateStepper(PlayerPage, "Speed", 16, 500, 16, 1, function(v) Settings.Speed = v end)
CreateToggle(PlayerPage, "Ativar Pulo", function(v) Settings.UseJump = v end)
CreateStepper(PlayerPage, "Jump Power", 50, 500, 50, 1, function(v) Settings.JumpPower = v end)
CreateToggle(PlayerPage, "Pulo Infinito", function(v) Settings.InfiniteJump = v end)

CreateToggle(HitboxPage, "Hitbox Expander", function(v) Settings.HitboxEnabled = v end)
CreateStepper(HitboxPage, "Tamanho", 2, 100, 20, 5, function(v) Settings.Hitbox = v end)
CreateStepper(HitboxPage, "Opacidade %", 0, 100, 60, 10, function(v) Settings.HitboxTransparency = v/100 end)

-- ANIMAÇÕES
local function OpenUI()
    MenuAberto = true
    Main.Visible = true
    Main.Position = UDim2.new(0.5, -150, 0.5, -190) -- Volta pro centro
    
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    TweenService:Create(Main, tweenInfo, {Size = UDim2.new(0, 300, 0, 380), BackgroundTransparency = 0.1}):Play()
    TweenService:Create(stroke, tweenInfo, {Transparency = 0}):Play()
    TweenService:Create(Title, tweenInfo, {TextTransparency = 0}):Play()
    TweenService:Create(eb, tweenInfo, {TextTransparency = 0}):Play()
    TweenService:Create(pb, tweenInfo, {TextTransparency = 0}):Play()
    TweenService:Create(hb, tweenInfo, {TextTransparency = 0}):Play()
end

local function CloseUI()
    MenuAberto = false
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    local anim = TweenService:Create(Main, tweenInfo, {Size = UDim2.new(0, 300, 0, 0), BackgroundTransparency = 1})
    TweenService:Create(stroke, tweenInfo, {Transparency = 1}):Play()
    TweenService:Create(Title, tweenInfo, {TextTransparency = 1}):Play()
    TweenService:Create(eb, tweenInfo, {TextTransparency = 1}):Play()
    TweenService:Create(pb, tweenInfo, {TextTransparency = 1}):Play()
    TweenService:Create(hb, tweenInfo, {TextTransparency = 1}):Play()
    anim:Play()
    anim.Completed:Connect(function() Main.Visible = false end)
end

-- [LÓGICA ESP E HITBOX - MANTIDAS DA 3.4]
local ESPContainer = {}
local function CreateESP(p)
    if p == LocalPlayer then return end
    ESPContainer[p] = {Box = Drawing.new("Square"), Name = Drawing.new("Text"), Dist = Drawing.new("Text"), Highlight = nil}
    local e = ESPContainer[p]; e.Box.Thickness = 1.5; e.Box.Filled = false; e.Box.Color = Color3.new(1,1,1)
    e.Name.Size = 16; e.Name.Center = true; e.Name.Outline = true; e.Name.Color = Color3.new(1,1,1)
    e.Dist.Size = 14; e.Dist.Center = true; e.Dist.Outline = true; e.Dist.Color = Color3.new(0,1,0)
end
local function RemoveESP(p)
    if ESPContainer[p] then
        ESPContainer[p].Box:Remove(); ESPContainer[p].Name:Remove(); ESPContainer[p].Dist:Remove()
        if ESPContainer[p].Highlight then ESPContainer[p].Highlight:Destroy() end
        ESPContainer[p] = nil
    end
end
Players.PlayerAdded:Connect(CreateESP); Players.PlayerRemoving:Connect(RemoveESP)
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end

RunService.RenderStepped:Connect(function()
    if Settings.UseSpeed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.Speed
    end
    if Settings.UseJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = Settings.JumpPower
    end
    for p, e in pairs(ESPContainer) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and Settings.ESP then
            local hrp = p.Character.HumanoidRootPart
            local pos, vis = Camera:WorldToViewportPoint(hrp.Position)
            if vis then
                if Settings.Boxes then
                    local sizeX = 2500 / pos.Z; local sizeY = 3500 / pos.Z
                    e.Box.Visible = true; e.Box.Size = Vector2.new(sizeX, sizeY); e.Box.Position = Vector2.new(pos.X - sizeX/2, pos.Y - sizeY/2)
                else e.Box.Visible = false end
                e.Name.Visible = Settings.Names; e.Name.Text = p.DisplayName; e.Name.Position = Vector2.new(pos.X, pos.Y - (2000/pos.Z) - 20)
                e.Dist.Visible = Settings.Distance; e.Dist.Text = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude).."m"; e.Dist.Position = Vector2.new(pos.X, pos.Y + (2000/pos.Z) + 5)
                if Settings.Highlight then
                    if not e.Highlight or e.Highlight.Parent ~= p.Character then
                        if e.Highlight then e.Highlight:Destroy() end
                        e.Highlight = Instance.new("Highlight", p.Character)
                    end
                    e.Highlight.Enabled = true; e.Highlight.FillColor = Color3.fromHSV(tick()%5/5, 1, 1)
                elseif e.Highlight then e.Highlight.Enabled = false end
            else e.Box.Visible = false; e.Name.Visible = false; e.Dist.Visible = false; if e.Highlight then e.Highlight.Enabled = false end end
        else e.Box.Visible = false; e.Name.Visible = false; e.Dist.Visible = false; if e.Highlight then e.Highlight:Destroy(); e.Highlight = nil end end
    end
end)

UIS.JumpRequest:Connect(function()
    if Settings.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end
end)

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

-- CLICK
ToggleBtn.MouseButton1Click:Connect(function()
    ToggleBtn:TweenSize(UDim2.new(0,50,0,50), "Out", "Quad", 0.1, true)
    task.wait(0.1)
    ToggleBtn:TweenSize(UDim2.new(0,60,0,60), "Out", "Elastic", 0.4, true)
    if Main.Visible then CloseUI() else OpenUI() end
end)
