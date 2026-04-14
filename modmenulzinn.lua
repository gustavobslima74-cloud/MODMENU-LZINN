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
ToggleBtn.Size = UDim2.new(0,55,0,55)
ToggleBtn.Position = UDim2.new(0,20,0.6,0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20,20,20)
ToggleBtn.Image = "rbxassetid://70505361093133"
ToggleBtn.ScaleType = Enum.ScaleType.Fit
ToggleBtn.Draggable = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1,0)

-- MAIN
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,320,0,380)
Main.Position = UDim2.new(0.5,-160,0.5,-190)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.BackgroundTransparency = 0.2
Main.Visible = false
Instance.new("UICorner", Main)

-- BORDA RGB
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
    btn.Size = UDim2.new(0.33,0,1,0)
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
local HitboxPage = CreatePage("HITBOX")
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

    bar.InputBegan:Connect(function(i)
        if i.UserInputType.Name:find("Mouse") or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)

    bar.InputEnded:Connect(function()
        dragging = false
    end)

    UIS.InputChanged:Connect(function(i)
        if dragging then
            local pos = math.clamp((i.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
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

-- HITBOX TAB
Toggle(HitboxPage,"Hitbox",function(v) Settings.HitboxEnabled=v end)

local ValueLabel = Instance.new("TextButton", HitboxPage)
ValueLabel.Size = UDim2.new(1,0,0,35)
ValueLabel.Text = "Size: 10"

local Plus = Instance.new("TextButton", HitboxPage)
Plus.Size = UDim2.new(0.48,0,0,35)
Plus.Text = "+"

local Minus = Instance.new("TextButton", HitboxPage)
Minus.Size = UDim2.new(0.48,0,0,35)
Minus.Text = "-"

Plus.MouseButton1Click:Connect(function()
    Settings.Hitbox = math.clamp(Settings.Hitbox+1,10,50)
    ValueLabel.Text = "Size: "..Settings.Hitbox
end)

Minus.MouseButton1Click:Connect(function()
    Settings.Hitbox = math.clamp(Settings.Hitbox-1,10,50)
    ValueLabel.Text = "Size: "..Settings.Hitbox
end)

ValueLabel.MouseButton1Click:Connect(function()
    local input = tonumber(game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChildOfClass("TextBox"))
end)

Slider(HitboxPage,"Opacidade",0.05,1,function(v)
    Settings.HitboxTransparency = v
end)

-- OPEN
ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- ESP + HITBOX LOOP
RunService.RenderStepped:Connect(function()
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart

            if Settings.HitboxEnabled then
                hrp.Size = Vector3.new(Settings.Hitbox,Settings.Hitbox,Settings.Hitbox)
                hrp.Transparency = Settings.HitboxTransparency
                hrp.Material = Enum.Material.Neon
                hrp.CanCollide = false
            end
        end
    end

    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            if Settings.UseSpeed then hum.WalkSpeed = Settings.Speed end
            if Settings.UseJump then hum.JumpPower = Settings.JumpPower end
        end
    end
end)

-- INFINITE JUMP
UIS.JumpRequest:Connect(function()
    if Settings.InfiniteJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- CRÉDITOS
local Credit = Instance.new("TextLabel", Main)
Credit.Size = UDim2.new(1,0,0,20)
Credit.Position = UDim2.new(0,0,1,-20)
Credit.Text = "LQB KIKO | v2.3"
Credit.BackgroundTransparency = 1
Credit.TextScaled = true

task.spawn(function()
    while true do
        for i=0,1,0.01 do
            Credit.TextColor3 = Color3.fromHSV(i,1,1)
            task.wait()
        end
    end
end)
