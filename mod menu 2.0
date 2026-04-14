--// SERVIÇOS
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

--// CONFIG
getgenv().Settings = {
    ESP = false,
    Boxes = false,
    Names = true,
    Distance = true,
    Highlight = false,
    TeamCheck = true,

    FOV = 150,
    ShowFOV = false,
    AimPart = "Head",

    Speed = 16,
    UseSpeed = false,

    JumpPower = 50,
    UseJump = false,
    InfiniteJump = false
}

--// GUI BASE
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.ResetOnSpawn = false

-- BOTÃO
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0,55,0,55)
ToggleBtn.Position = UDim2.new(0,20,0.6,0)
ToggleBtn.Text = "HUB"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.TextScaled = true
ToggleBtn.Draggable = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1,0)

-- MAIN
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,0,0,0)
Main.Position = UDim2.new(0.5,-150,0.5,-180)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.Visible = false
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

-- ABAS
local Tabs = Instance.new("Frame", Main)
Tabs.Size = UDim2.new(1,0,0,40)
Tabs.BackgroundTransparency = 1

local Pages = Instance.new("Frame", Main)
Pages.Size = UDim2.new(1,0,1,-40)
Pages.Position = UDim2.new(0,0,0,40)
Pages.BackgroundTransparency = 1

local function NewPage(name)
    local btn = Instance.new("TextButton", Tabs)
    btn.Size = UDim2.new(0.33,0,1,0)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    btn.TextColor3 = Color3.new(1,1,1)

    local page = Instance.new("Frame", Pages)
    page.Size = UDim2.new(1,0,1,0)
    page.Visible = false
    page.BackgroundTransparency = 1

    btn.MouseButton1Click:Connect(function()
        for _,v in pairs(Pages:GetChildren()) do v.Visible = false end
        page.Visible = true
    end)

    return page
end

local ESPPage = NewPage("ESP")
local AimPage = NewPage("MIRA")
local PlayerPage = NewPage("PLAYER")

ESPPage.Visible = true

--// FUNÇÕES UI
local function Toggle(parent,text,callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.9,0,0,35)
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

local function Slider(parent,text,min,max,callback)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(0.9,0,0,40)
    f.BackgroundColor3 = Color3.fromRGB(40,40,40)

    local label = Instance.new("TextLabel", f)
    label.Size = UDim2.new(1,0,0.5,0)
    label.Text = text..": "..min
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1

    local val = min
    f.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            val = math.clamp(val + 10, min, max)
            label.Text = text..": "..val
            callback(val)
        end
    end)
end

--// ESP TAB
Toggle(ESPPage,"ESP",function(v) Settings.ESP = v end)
Toggle(ESPPage,"Boxes",function(v) Settings.Boxes = v end)
Toggle(ESPPage,"Names",function(v) Settings.Names = v end)
Toggle(ESPPage,"Distance",function(v) Settings.Distance = v end)
Toggle(ESPPage,"Chams",function(v) Settings.Highlight = v end)
Toggle(ESPPage,"Team Check",function(v) Settings.TeamCheck = v end)

--// MIRA TAB
Toggle(AimPage,"Mostrar FOV",function(v) Settings.ShowFOV = v end)
Slider(AimPage,"FOV",50,300,function(v) Settings.FOV = v end)

Toggle(AimPage,"Cabeça",function(v)
    Settings.AimPart = v and "Head" or "HumanoidRootPart"
end)

--// PLAYER TAB
Toggle(PlayerPage,"Speed",function(v) Settings.UseSpeed = v end)
Slider(PlayerPage,"Velocidade",16,100,function(v) Settings.Speed = v end)

Toggle(PlayerPage,"Jump",function(v) Settings.UseJump = v end)
Slider(PlayerPage,"Altura Pulo",50,150,function(v) Settings.JumpPower = v end)

Toggle(PlayerPage,"Pulo Infinito",function(v) Settings.InfiniteJump = v end)

--// OPEN/CLOSE
local open = false
ToggleBtn.MouseButton1Click:Connect(function()
    open = not open
    if open then
        Main.Visible = true
        TweenService:Create(Main,TweenInfo.new(0.25),{Size=UDim2.new(0,300,0,360)}):Play()
    else
        TweenService:Create(Main,TweenInfo.new(0.25),{Size=UDim2.new(0,0,0,0)}):Play()
        task.wait(0.25)
        Main.Visible = false
    end
end)

--// FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.new(1,1,1)
FOVCircle.Thickness = 1
FOVCircle.Filled = false

--// ESP
local ESP = {}

local function CreateESP(p)
    if p == LocalPlayer then return end

    local Box = Drawing.new("Square")
    local Name = Drawing.new("Text")
    local Dist = Drawing.new("Text")

    ESP[p] = {Box=Box,Name=Name,Dist=Dist}
end

for _,p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

-- LOOP
game:GetService("RunService").RenderStepped:Connect(function()
    -- FOV
    FOVCircle.Visible = Settings.ShowFOV
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Position = UIS:GetMouseLocation()

    for p,esp in pairs(ESP) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and Settings.ESP then
            local hrp = p.Character.HumanoidRootPart
            local pos,vis = Camera:WorldToViewportPoint(hrp.Position)

            if vis then
                local teamColor = (Settings.TeamCheck and p.Team == LocalPlayer.Team)
                    and Color3.fromRGB(0,255,0)
                    or Color3.fromRGB(255,0,0)

                esp.Box.Visible = Settings.Boxes
                esp.Box.Color = teamColor

                esp.Name.Visible = Settings.Names
                esp.Name.Text = p.DisplayName
                esp.Name.Color = teamColor
                esp.Name.Position = Vector2.new(pos.X,pos.Y-30)

                esp.Dist.Visible = Settings.Distance
                esp.Dist.Text = math.floor((LocalPlayer.Character.HumanoidRootPart.Position-hrp.Position).Magnitude).."m"
                esp.Dist.Position = Vector2.new(pos.X,pos.Y+20)

                if Settings.Highlight then
                    if not p.Character:FindFirstChild("Highlight") then
                        local h = Instance.new("Highlight",p.Character)
                        h.FillColor = teamColor
                    end
                end
            end
        end
    end

    -- PLAYER MODS
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
