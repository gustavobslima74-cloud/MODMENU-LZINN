--// SERVIÇOS
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

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

--// GUI PRINCIPAL
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

-- BOTÃO ABRIR (CÍRCULO PERFEITO)
local ToggleBtn = Instance.new("ImageButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0,60,0,60)
ToggleBtn.Position = UDim2.new(0,20,0.6,0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20,20,20)
ToggleBtn.Image = "rbxassetid://70505361093133"
ToggleBtn.ClipsDescendants = true

local btnCorner = Instance.new("UICorner", ToggleBtn)
btnCorner.CornerRadius = UDim.new(1,0)

-- JANELA PRINCIPAL
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,300,0,350)
Main.Position = UDim2.new(0.5,-150,0.5,-150)
Main.BackgroundColor3 = Color3.fromRGB(10,10,10)
Main.Visible = false
Instance.new("UICorner", Main)

local stroke = Instance.new("UIStroke", Main)
stroke.Thickness = 2
task.spawn(function()
    while true do
        stroke.Color = Color3.fromHSV(tick()%5/5,1,1)
        task.wait()
    end
end)

-- TÍTULO
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,35)
Title.Text = "LQB KIKO | v2.9"
Title.BackgroundTransparency = 1
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
task.spawn(function()
    while true do
        Title.TextColor3 = Color3.fromHSV(tick()%5/5,1,1)
        task.wait()
    end
end)

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

    local page = Instance.new("ScrollingFrame", Pages)
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.CanvasSize = UDim2.new(0,0,0,400)
    page.ScrollBarThickness = 2
    Instance.new("UIListLayout", page).Padding = UDim.new(0,5)
    
    btn.MouseButton1Click:Connect(function()
        for _,v in pairs(Pages:GetChildren()) do v.Visible = false end
        page.Visible = true
    end)
    return page
end

local ESPPage = CreatePage("ESP")
local PlayerPage = CreatePage("PLAYER")
local HitboxPage = CreatePage("HITBOX")
ESPPage.Visible = true

-- COMPONENTES DE UI
local function CreateToggle(parent, text, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1,-10,0,35)
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

local function CreateStepper(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1,-10,0,60)
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
    Instance.new("UICorner", minus)

    local plus = Instance.new("TextButton", frame)
    plus.Size = UDim2.new(0.4,0,0,30)
    plus.Position = UDim2.new(0.55,0,0,25)
    plus.Text = "+"
    plus.BackgroundColor3 = Color3.fromRGB(40,40,40)
    plus.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", plus)

    local val = default
    local function up(n)
        val = math.clamp(n, min, max)
        label.Text = text..": "..val
        callback(val)
    end
    minus.MouseButton1Click:Connect(function() up(val - 1) end)
    plus.MouseButton1Click:Connect(function() up(val + 1) end)
end

-- CONFIGURAÇÃO DOS BOTÕES
CreateToggle(ESPPage, "ESP", function(v) Settings.ESP = v end)
CreateToggle(ESPPage, "Boxes", function(v) Settings.Boxes = v end)
CreateToggle(ESPPage, "Names", function(v) Settings.Names = v end)
CreateToggle(ESPPage, "Distance", function(v) Settings.Distance = v end)
CreateToggle(ESPPage, "Chams", function(v) Settings.Highlight = v end)

CreateToggle(PlayerPage, "Velocidade", function(v) Settings.UseSpeed = v end)
CreateStepper(PlayerPage, "Speed", 16, 300, 16, function(v) Settings.Speed = v end)
CreateToggle(PlayerPage, "Pulo", function(v) Settings.UseJump = v end)
CreateStepper(PlayerPage, "Pulo", 50, 300, 50, function(v) Settings.JumpPower = v end)
CreateToggle(PlayerPage, "Pulo Infinito", function(v) Settings.InfiniteJump = v end)

CreateToggle(HitboxPage, "Hitbox Expander", function(v) Settings.HitboxEnabled = v end)
CreateStepper(HitboxPage, "Tamanho", 2, 60, 20, function(v) Settings.Hitbox = v end)
CreateStepper(HitboxPage, "Opacidade %", 0, 100, 60, function(v) Settings.HitboxTransparency = v/100 end)

--// LÓGICA ESP
local ESPContainer = {}
local function RemoveESP(p)
    if ESPContainer[p] then
        for _, obj in pairs(ESPContainer[p]) do
            if typeof(obj) == "table" and obj.Remove then obj:Remove() 
            elseif typeof(obj) == "Instance" then obj:Destroy() end
        end
        ESPContainer[p] = nil
    end
end

local function CreateESP(p)
    if p == LocalPlayer then return end
    ESPContainer[p] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Dist = Drawing.new("Text")
    }
    local e = ESPContainer[p]
    e.Box.Thickness = 1
    e.Box.Color = Color3.new(1,1,1)
    e.Name.Size = 16
    e.Name.Center = true
    e.Name.Outline = true
    e.Name.Color = Color3.new(1,1,1)
    e.Dist.Size = 14
    e.Dist.Center = true
    e.Dist.Outline = true
    e.Dist.Color = Color3.fromRGB(0, 255, 0) -- DISTANCIA VERDE
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end

RunService.RenderStepped:Connect(function()
    if Settings.UseSpeed and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.Speed
    end
    if Settings.UseJump and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = Settings.JumpPower
    end

    for p, e in pairs(ESPContainer) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and Settings.ESP then
            local hrp = p.Character.HumanoidRootPart
            local pos, vis = Camera:WorldToViewportPoint(hrp.Position)
            if vis then
                e.Box.Visible = Settings.Boxes
                e.Box.Size = Vector2.new(1500/pos.Z, 2000/pos.Z)
                e.Box.Position = Vector2.new(pos.X - e.Box.Size.X/2, pos.Y - e.Box.Size.Y/2)
                
                e.Name.Visible = Settings.Names
                e.Name.Text = p.DisplayName
                e.Name.Position = Vector2.new(pos.X, pos.Y - (e.Box.Size.Y/2) - 18)

                e.Dist.Visible = Settings.Distance
                e.Dist.Text = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude).."m"
                e.Dist.Position = Vector2.new(pos.X, pos.Y + (e.Box.Size.Y/2) + 5)
            else e.Box.Visible = false e.Name.Visible = false e.Dist.Visible = false end
        else e.Box.Visible = false e.Name.Visible = false e.Dist.Visible = false end
    end
end)

-- PULO INFINITO
UIS.JumpRequest:Connect(function()
    if Settings.InfiniteJump and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end
end)

-- HITBOX LOOP
task.spawn(function()
    while true do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                if Settings.HitboxEnabled then
                    hrp.Size = Vector3.new(Settings.Hitbox, Settings.Hitbox, Settings.Hitbox)
                    hrp.Transparency = Settings.HitboxTransparency
                    hrp.CanCollide = false
                else
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                end
            end
        end
        task.wait(0.1)
    end
end)

ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
