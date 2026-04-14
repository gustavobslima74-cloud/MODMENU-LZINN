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

--// GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

-- BOTÃO
local ToggleBtn = Instance.new("ImageButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0,60,0,60)
ToggleBtn.Position = UDim2.new(0,20,0.6,0)
ToggleBtn.Image = "rbxassetid://70505361093133"
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.ClipsDescendants = true
ToggleBtn.Draggable = true

local corner = Instance.new("UICorner", ToggleBtn)
corner.CornerRadius = UDim.new(1,0)

-- MAIN
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,300,0,200)
Main.Position = UDim2.new(0.5,-150,0.5,-100)
Main.BackgroundColor3 = Color3.fromRGB(0,0,0)
Main.BackgroundTransparency = 0.1
Main.Visible = false
Instance.new("UICorner", Main)

-- BORDA RGB
local stroke = Instance.new("UIStroke", Main)
stroke.Thickness = 2
task.spawn(function()
    while true do
        stroke.Color = Color3.fromHSV(tick()%5/5,1,1)
        task.wait()
    end
end)

-- DRAG
Main.Active = true
Main.Draggable = true

-- TÍTULO
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "LQB KIKO | v2.7"
Title.BackgroundTransparency = 1
Title.TextScaled = true

task.spawn(function()
    while true do
        Title.TextColor3 = Color3.fromHSV(tick()%5/5,1,1)
        task.wait()
    end
end)

-- ABAS
local Tabs = Instance.new("Frame", Main)
Tabs.Size = UDim2.new(1,0,0,30)
Tabs.Position = UDim2.new(0,0,0,30)
Tabs.BackgroundTransparency = 1

local LayoutTabs = Instance.new("UIListLayout", Tabs)
LayoutTabs.FillDirection = Enum.FillDirection.Horizontal

local Pages = Instance.new("Frame", Main)
Pages.Position = UDim2.new(0,0,0,60)
Pages.Size = UDim2.new(1,0,0,0)
Pages.BackgroundTransparency = 1

local function UpdateSize(page)
    task.wait()
    local total = 0
    for _,v in pairs(page:GetChildren()) do
        if v:IsA("GuiObject") then
            total += v.AbsoluteSize.Y + 8
        end
    end
    Main.Size = UDim2.new(0,300,0,total + 100)
end

local function CreatePage(name)
    local btn = Instance.new("TextButton", Tabs)
    btn.Size = UDim2.new(0.33,0,1,0)
    btn.Text = name
    btn.BackgroundTransparency = 1
    btn.TextColor3 = Color3.new(1,1,1)

    local page = Instance.new("Frame", Pages)
    page.BackgroundTransparency = 1
    page.Visible = false

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0,8)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.Size = UDim2.new(1,0,0,layout.AbsoluteContentSize.Y)
        UpdateSize(page)
    end)

    btn.MouseButton1Click:Connect(function()
        for _,v in pairs(Pages:GetChildren()) do
            if v:IsA("Frame") then v.Visible = false end
        end
        page.Visible = true
        UpdateSize(page)
    end)

    return page
end

local ESPPage = CreatePage("ESP")
local PlayerPage = CreatePage("PLAYER")
local HitboxPage = CreatePage("HITBOX")
ESPPage.Visible = true
task.wait()
UpdateSize(ESPPage)

-- TOGGLE
local function Toggle(parent,text,callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1,0,0,40)
    b.Text = text..": OFF"
    b.BackgroundColor3 = Color3.fromRGB(15,15,15)
    b.TextColor3 = Color3.new(1,1,1)

    local state = false
    b.MouseButton1Click:Connect(function()
        state = not state
        b.Text = text..": "..(state and "ON" or "OFF")
        callback(state)
    end)
end

-- ESP TAB
Toggle(ESPPage,"ESP",function(v) Settings.ESP=v end)
Toggle(ESPPage,"Boxes",function(v) Settings.Boxes=v end)
Toggle(ESPPage,"Names",function(v) Settings.Names=v end)
Toggle(ESPPage,"Distance",function(v) Settings.Distance=v end)
Toggle(ESPPage,"Chams",function(v) Settings.Highlight=v end)

-- PLAYER TAB
-- VELOCIDADE
Toggle(PlayerPage,"Velocidade",function(v)
    Settings.UseSpeed = v
end)

local SpeedLabel = Instance.new("TextLabel", PlayerPage)
SpeedLabel.Size = UDim2.new(1,0,0,30)
SpeedLabel.Text = "Velocidade: 16"
SpeedLabel.TextColor3 = Color3.new(1,1,1)
SpeedLabel.BackgroundTransparency = 1

local SpeedMinus = Instance.new("TextButton", PlayerPage)
SpeedMinus.Size = UDim2.new(0.5,0,0,35)
SpeedMinus.Text = "-"

local SpeedPlus = Instance.new("TextButton", PlayerPage)
SpeedPlus.Size = UDim2.new(0.5,0,0,35)
SpeedPlus.Text = "+"

SpeedMinus.MouseButton1Click:Connect(function()
    Settings.Speed = math.clamp(Settings.Speed-1,16,200)
    SpeedLabel.Text = "Velocidade: "..Settings.Speed
end)

SpeedPlus.MouseButton1Click:Connect(function()
    Settings.Speed = math.clamp(Settings.Speed+1,16,200)
    SpeedLabel.Text = "Velocidade: "..Settings.Speed
end)

-- PULO
Toggle(PlayerPage,"Pulo",function(v)
    Settings.UseJump = v
end)

local JumpLabel = Instance.new("TextLabel", PlayerPage)
JumpLabel.Size = UDim2.new(1,0,0,30)
JumpLabel.Text = "Pulo: 50"
JumpLabel.TextColor3 = Color3.new(1,1,1)
JumpLabel.BackgroundTransparency = 1

local JumpMinus = Instance.new("TextButton", PlayerPage)
JumpMinus.Size = UDim2.new(0.5,0,0,35)
JumpMinus.Text = "-"

local JumpPlus = Instance.new("TextButton", PlayerPage)
JumpPlus.Size = UDim2.new(0.5,0,0,35)
JumpPlus.Text = "+"

JumpMinus.MouseButton1Click:Connect(function()
    Settings.JumpPower = math.clamp(Settings.JumpPower-5,50,200)
    JumpLabel.Text = "Pulo: "..Settings.JumpPower
end)

JumpPlus.MouseButton1Click:Connect(function()
    Settings.JumpPower = math.clamp(Settings.JumpPower+5,50,200)
    JumpLabel.Text = "Pulo: "..Settings.JumpPower
end)

-- INFINITE JUMP
Toggle(PlayerPage,"Pulo Infinito",function(v)
    Settings.InfiniteJump = v
end)
-- HITBOX TAB
Toggle(HitboxPage,"Hitbox",function(v) Settings.HitboxEnabled=v end)

local SizeLabel = Instance.new("TextLabel", HitboxPage)
SizeLabel.Size = UDim2.new(1,0,0,30)
SizeLabel.Text = "Tamanho: 20"
SizeLabel.TextColor3 = Color3.new(1,1,1)
SizeLabel.BackgroundTransparency = 1

local Minus = Instance.new("TextButton", HitboxPage)
Minus.Size = UDim2.new(0.5,0,0,35)
Minus.Text = "-"

local Plus = Instance.new("TextButton", HitboxPage)
Plus.Size = UDim2.new(0.5,0,0,35)
Plus.Text = "+"

Minus.MouseButton1Click:Connect(function()
    Settings.Hitbox = math.clamp(Settings.Hitbox-1,10,50)
    SizeLabel.Text = "Tamanho: "..Settings.Hitbox
end)

Plus.MouseButton1Click:Connect(function()
    Settings.Hitbox = math.clamp(Settings.Hitbox+1,10,50)
    SizeLabel.Text = "Tamanho: "..Settings.Hitbox
end)

-- OPACIDADE
local OpLabel = Instance.new("TextLabel", HitboxPage)
OpLabel.Size = UDim2.new(1,0,0,30)
OpLabel.Text = "Opacidade: 0.60"
OpLabel.BackgroundTransparency = 1
OpLabel.TextColor3 = Color3.new(1,1,1)

local Bar = Instance.new("Frame", HitboxPage)
Bar.Size = UDim2.new(1,0,0,10)
Bar.BackgroundColor3 = Color3.fromRGB(50,50,50)

local Fill = Instance.new("Frame", Bar)
Fill.Size = UDim2.new(0.6,0,1,0)
Fill.BackgroundColor3 = Color3.fromRGB(0,170,255)

local dragging = false

Bar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then dragging = true end
end)

Bar.InputEnded:Connect(function()
    dragging = false
end)

UIS.InputChanged:Connect(function(i)
    if dragging then
        local pos = math.clamp((i.Position.X - Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X,0,1)
        Fill.Size = UDim2.new(pos,0,1,0)

        local value = 0.05 + (1-0.05)*pos
        value = math.floor(value / 0.05 + 0.5) * 0.05
        Settings.HitboxTransparency = value
        OpLabel.Text = "Opacidade: "..string.format("%.2f", value)
    end
end)

-- ESP LOOP
local ESPContainer = {}
local function CreateESP(p)
    if p == LocalPlayer then return end

    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Color = Color3.fromRGB(255,0,0)
    Box.Filled = false -- 🔥 ISSO AQUI RESOLVE
    Box.Transparency = 1

    local Name = Drawing.new("Text")
    Name.Size = 13
    Name.Center = true
    Name.Outline = true
    Name.Color = Color3.new(1,1,1)

    local Distance = Drawing.new("Text")
    Distance.Size = 13
    Distance.Center = true
    Distance.Outline = true
    Distance.Color = Color3.fromRGB(0,255,0)

    ESPContainer[p] = {
        Box = Box,
        Name = Name,
        Distance = Distance,
        Highlight = nil
    }
end

for _,p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

RunService.RenderStepped:Connect(function()
    for p,esp in pairs(ESPContainer) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and Settings.ESP then
            
            local hrp = p.Character.HumanoidRootPart
            local pos,vis = Camera:WorldToViewportPoint(hrp.Position)

            if vis then
                local dist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
                and math.floor((LocalPlayer.Character.HumanoidRootPart.Position-hrp.Position).Magnitude) or 0

                esp.Box.Visible = Settings.Boxes
                local scale = (Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0,3,0)).Y - pos.Y)

                esp.Box.Size = Vector2.new(scale*1.5, scale*2)
                esp.Box.Position = Vector2.new(
pos.X - esp.Box.Size.X/2,
pos.Y - esp.Box.Size.Y/2
))
                esp.Box.Position = Vector2.new(pos.X,pos.Y)

                esp.Name.Visible = Settings.Names
                esp.Name.Text = p.DisplayName
                esp.Name.Position = Vector2.new(pos.X,pos.Y-40)

                esp.Distance.Visible = Settings.Distance
                esp.Distance.Text = dist.."m"
                esp.Distance.Position = Vector2.new(pos.X,pos.Y+20)
                esp.Distance.Color = Color3.fromRGB(0,255,0)

            else
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Distance.Visible = false
            end

        else
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
        end
    end
end)

-- REMOVE ESP quando player sair
Players.PlayerRemoving:Connect(function(p)
    if ESPContainer[p] then
        for _,v in pairs(ESPContainer[p]) do
            if typeof(v) == "userdata" then
                pcall(function() v:Remove() end)
            end
        end
        ESPContainer[p] = nil
    end
end)

-- HITBOX REAL
task.spawn(function()
    while true do
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")

                if hrp then
                    pcall(function()
                        if Settings.HitboxEnabled then
                            hrp.Size = Vector3.new(Settings.Hitbox,Settings.Hitbox,Settings.Hitbox)
                            hrp.Transparency = Settings.HitboxTransparency
                            hrp.CanCollide = false
                        else
                            -- RESET LIMPO
                            hrp.Size = Vector3.new(2,2,1)
                            hrp.Transparency = 0
                            hrp.CanCollide = true
                        end
                    end)
                end
            end
        end
        task.wait(0.12)
    end
end)

-- OPEN
ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid

        if Settings.UseSpeed then
            hum.WalkSpeed = Settings.Speed
        else
            hum.WalkSpeed = 16
        end

        if Settings.UseJump then
            hum.JumpPower = Settings.JumpPower
        else
            hum.JumpPower = 50
        end
    end
end)

UIS.JumpRequest:Connect(function()
    if Settings.InfiniteJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

