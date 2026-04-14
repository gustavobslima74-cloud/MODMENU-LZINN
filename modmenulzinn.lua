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

    UseSpeed = false,
    Speed = 16,

    UseJump = false,
    JumpPower = 50,

    InfiniteJump = false
}

--// GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0,55,0,55)
ToggleBtn.Position = UDim2.new(0,20,0.6,0)
ToggleBtn.Text = "HUB"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
ToggleBtn.Draggable = true
Instance.new("UICorner", ToggleBtn)

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,300,0,360)
Main.Position = UDim2.new(0.5,-150,0.5,-180)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.BackgroundTransparency = 0.2
Main.Visible = false
Instance.new("UICorner", Main)

-- RGB BORDA
local stroke = Instance.new("UIStroke", Main)
stroke.Thickness = 2
task.spawn(function()
    while true do
        for i=0,1,0.01 do
            stroke.Color = Color3.fromHSV(i,1,1)
            task.wait()
        end
    end
end)

-- ABAS
local Tabs = Instance.new("Frame", Main)
Tabs.Size = UDim2.new(1,0,0,40)

local LayoutTabs = Instance.new("UIListLayout", Tabs)
LayoutTabs.FillDirection = Enum.FillDirection.Horizontal

local Pages = Instance.new("Frame", Main)
Pages.Size = UDim2.new(1,0,1,-40)
Pages.Position = UDim2.new(0,0,0,40)

local function CreatePage(name)
    local btn = Instance.new("TextButton", Tabs)
    btn.Size = UDim2.new(0.5,0,1,0)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    btn.TextColor3 = Color3.new(1,1,1)

    local page = Instance.new("Frame", Pages)
    page.Size = UDim2.new(1,0,1,0)
    page.Visible = false

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0,8)

    btn.MouseButton1Click:Connect(function()
        for _,v in pairs(Pages:GetChildren()) do
            if v:IsA("Frame") then v.Visible = false end
        end
        page.Visible = true
    end)

    return page
end

local ESPPage = CreatePage("ESP")
local PlayerPage = CreatePage("PLAYER")
ESPPage.Visible = true

-- TOGGLE
local function Toggle(parent,text,callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1,0,0,35)
    b.Text = text..": OFF"
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextColor3 = Color3.new(1,1,1)

    local state = false
    b.MouseButton1Click:Connect(function()
        state = not state
        b.Text = text..": "..(state and "ON" or "OFF")
        callback(state)
    end)
end

-- SLIDER
local function Slider(parent,text,min,max,callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1,0,0,50)
    frame.BackgroundColor3 = Color3.fromRGB(40,40,40)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,0,0,20)
    label.Text = text..": "..min
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)

    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(1,-10,0,10)
    bar.Position = UDim2.new(0,5,0,30)
    bar.BackgroundColor3 = Color3.fromRGB(60,60,60)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(0,0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(0,170,255)

    local dragging = false

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)

    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging then
            local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            fill.Size = UDim2.new(pos,0,1,0)

            local value = math.floor(min + (max-min)*pos)
            label.Text = text..": "..value
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

-- ABRIR/FECHAR
ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- ESP SISTEMA
local ESPContainer = {}

local function CreateESP(player)
    if player == LocalPlayer then return end

    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Color = Color3.new(1,0,0)
    Box.Filled = false

    local Name = Drawing.new("Text")
    Name.Size = 13
    Name.Center = true
    Name.Outline = true

    local Dist = Drawing.new("Text")
    Dist.Size = 13
    Dist.Center = true
    Dist.Outline = true

    ESPContainer[player] = {Box=Box,Name=Name,Dist=Dist}
end

for _,p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

RunService.RenderStepped:Connect(function()
    for p,esp in pairs(ESPContainer) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and Settings.ESP then
            local hrp = p.Character.HumanoidRootPart
            local pos,vis = Camera:WorldToViewportPoint(hrp.Position)

            if vis then
                local size = (Camera:WorldToViewportPoint(hrp.Position+Vector3.new(0,3,0)).Y - pos.Y)

                esp.Box.Visible = Settings.Boxes
                if Settings.Boxes then
                    esp.Box.Size = Vector2.new(size*1.5,size*2)
                    esp.Box.Position = Vector2.new(pos.X - esp.Box.Size.X/2,pos.Y - esp.Box.Size.Y/2)
                end

                esp.Name.Visible = Settings.Names
                if Settings.Names then
                    esp.Name.Text = p.DisplayName
                    esp.Name.Position = Vector2.new(pos.X,pos.Y-size)
                end

                esp.Dist.Visible = Settings.Distance
                if Settings.Distance then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position-hrp.Position).Magnitude
                    esp.Dist.Text = math.floor(dist).."m"
                    esp.Dist.Position = Vector2.new(pos.X,pos.Y+size/2)
                end

                if Settings.Highlight then
                    if not p.Character:FindFirstChild("Highlight") then
                        Instance.new("Highlight",p.Character)
                    end
                end
            else
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Dist.Visible = false
            end
        else
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Dist.Visible = false
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

UIS.JumpRequest:Connect(function()
    if Settings.InfiniteJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- CRÉDITOS
local Credit = Instance.new("TextLabel", Main)
Credit.Size = UDim2.new(1,0,0,20)
Credit.Position = UDim2.new(0,0,1,-20)
Credit.BackgroundTransparency = 1
Credit.Text = "LQB KIKO | v2.2"
Credit.TextScaled = true

task.spawn(function()
    while true do
        for i=0,1,0.01 do
            Credit.TextColor3 = Color3.fromHSV(i,1,1)
            task.wait()
        end
    end
end)
