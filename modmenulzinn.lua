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

    Hitbox = 10,
    HitboxEnabled = false,
    HitboxTransparency = 0.5,

    UseSpeed = false,
    Speed = 16,

    UseJump = false,
    JumpPower = 50,

    InfiniteJump = false
}

--// GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

-- BOTÃO PNG
local ToggleBtn = Instance.new("ImageButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0,60,0,60)
ToggleBtn.Position = UDim2.new(0,20,0.6,0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
ToggleBtn.Image = "rbxassetid://70505361093133"
ToggleBtn.ScaleType = Enum.ScaleType.Fit
ToggleBtn.Draggable = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1,0)

-- MAIN
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,330,0,420)
Main.Position = UDim2.new(0.5,-165,0.5,-210)
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

-- DRAG MOBILE
local dragging = false
local dragStart, startPos

Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

Main.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- CRÉDITOS TOPO
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "LQB KIKO | v2.5"
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
Tabs.Size = UDim2.new(1,0,0,40)
Tabs.Position = UDim2.new(0,0,0,30)
Tabs.BackgroundTransparency = 1

local LayoutTabs = Instance.new("UIListLayout", Tabs)
LayoutTabs.FillDirection = Enum.FillDirection.Horizontal

local Pages = Instance.new("Frame", Main)
Pages.Size = UDim2.new(1,0,1,-70)
Pages.Position = UDim2.new(0,0,0,70)
Pages.BackgroundTransparency = 1

local function CreatePage(name)
    local btn = Instance.new("TextButton", Tabs)
    btn.Size = UDim2.new(0.33,0,1,0)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(15,15,15)
    btn.TextColor3 = Color3.new(1,1,1)

    local page = Instance.new("ScrollingFrame", Pages)
    page.Size = UDim2.new(1,0,1,0)
    page.CanvasSize = UDim2.new(0,0,2,0)
    page.ScrollBarThickness = 4
    page.Visible = false
    page.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0,8)

    btn.MouseButton1Click:Connect(function()
        for _,v in pairs(Pages:GetChildren()) do
            if v:IsA("ScrollingFrame") then v.Visible = false end
        end
        page.Visible = true
    end)

    return page
end

local ESPPage = CreatePage("ESP")
local PlayerPage = CreatePage("PLAYER")
local HitboxPage = CreatePage("HITBOX")
ESPPage.Visible = true

-- TOGGLE
local function Toggle(parent,text,callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1,0,0,40)
    b.Text = text..": OFF"
    b.BackgroundColor3 = Color3.fromRGB(20,20,20)
    b.TextColor3 = Color3.new(1,1,1)

    local state = false
    b.MouseButton1Click:Connect(function()
        state = not state
        b.Text = text..": "..(state and "ON" or "OFF")
        callback(state)
    end)
end

-- SLIDER (0.05 STEP)
local function Slider(parent,text,min,max,callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1,0,0,50)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,0,0,20)
    label.Text = text..": "..min
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)

    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(1,-10,0,10)
    bar.Position = UDim2.new(0,5,0,30)
    bar.BackgroundColor3 = Color3.fromRGB(50,50,50)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(0,0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(0,170,255)

    local dragging = false

    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)

    bar.InputEnded:Connect(function() dragging = false end)

    UIS.InputChanged:Connect(function(i)
        if dragging then
            local pos = math.clamp((i.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            fill.Size = UDim2.new(pos,0,1,0)

            local value = min + (max-min)*pos
            value = math.floor(value / 0.05 + 0.5) * 0.05
            value = math.clamp(value,min,max)

            label.Text = text..": "..string.format("%.2f", value)
            callback(value)
        end
    end)
end

-- ESP TAB
Toggle(ESPPage,"ESP",function(v) Settings.ESP=v end)
Toggle(ESPPage,"Boxes",function(v) Settings.Boxes=v end)
Toggle(ESPPage,"Names",function(v) Settings.Names=v end)
Toggle(ESPPage,"Distance",function(v) Settings.Distance=v end)
Toggle(ESPPage,"Chams",function(v) Settings.Highlight=v end)

-- PLAYER TAB
Toggle(PlayerPage,"Speed",function(v) Settings.UseSpeed=v end)
Slider(PlayerPage,"Velocidade",16,100,function(v) Settings.Speed=v end)

Toggle(PlayerPage,"Jump",function(v) Settings.UseJump=v end)
Slider(PlayerPage,"Pulo",50,150,function(v) Settings.JumpPower=v end)

Toggle(PlayerPage,"Pulo Infinito",function(v) Settings.InfiniteJump=v end)

-- HITBOX TAB
Toggle(HitboxPage,"Hitbox",function(v) Settings.HitboxEnabled=v end)

-- ESP SISTEMA (CORRIGIDO)
local ESPContainer = {}

local function CreateESP(player)
    if player == LocalPlayer then return end

    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Color = Color3.fromRGB(255,0,0)
    Box.Filled = false

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

    ESPContainer[player] = {Box=Box,Name=Name,Distance=Distance,Highlight=nil}
end

for _,p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

-- LOOP
RunService.RenderStepped:Connect(function()
    for player, esp in pairs(ESPContainer) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and Settings.ESP then
            local hrp = player.Character.HumanoidRootPart
            local pos, vis = Camera:WorldToViewportPoint(hrp.Position)

            if vis then
                local size = (Camera:WorldToViewportPoint(hrp.Position+Vector3.new(0,3,0)).Y - pos.Y)

                esp.Box.Visible = Settings.Boxes
                if Settings.Boxes then
                    esp.Box.Size = Vector2.new(size*1.5,size*2)
                    esp.Box.Position = Vector2.new(pos.X - esp.Box.Size.X/2,pos.Y - esp.Box.Size.Y/2)
                end

                esp.Name.Visible = Settings.Names
                if Settings.Names then
                    esp.Name.Text = player.DisplayName
                    esp.Name.Position = Vector2.new(pos.X,pos.Y-size)
                end

                esp.Distance.Visible = Settings.Distance
                if Settings.Distance then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                    esp.Distance.Text = math.floor(dist).."m"
                    esp.Distance.Position = Vector2.new(pos.X,pos.Y+size/2)
                end
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

    -- PLAYER
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            if Settings.UseSpeed then hum.WalkSpeed = Settings.Speed end
            if Settings.UseJump then hum.JumpPower = Settings.JumpPower end
        end
    end
end)

-- HITBOX FAKE
local HitboxParts = {}

RunService.RenderStepped:Connect(function()
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart

            if Settings.HitboxEnabled then
                if not HitboxParts[p] then
                    local part = Instance.new("Part")
                    part.Anchored = true
                    part.CanCollide = false
                    part.Material = Enum.Material.Neon
                    part.Color = Color3.fromRGB(255,0,0)
                    part.Parent = workspace
                    HitboxParts[p] = part
                end

                local hb = HitboxParts[p]
                hb.Size = Vector3.new(Settings.Hitbox,Settings.Hitbox,Settings.Hitbox)
                hb.CFrame = hrp.CFrame
                hb.Transparency = Settings.HitboxTransparency
            else
                if HitboxParts[p] then
                    HitboxParts[p]:Destroy()
                    HitboxParts[p] = nil
                end
            end
        end
    end
end)

-- OPEN
ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- INFINITE JUMP
UIS.JumpRequest:Connect(function()
    if Settings.InfiniteJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)
