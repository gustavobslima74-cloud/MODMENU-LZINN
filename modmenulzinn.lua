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

    ShowFOV = false,
    FOV = 150,

    Speed = 16,
    UseSpeed = false,

    JumpPower = 50,
    UseJump = false,
    InfiniteJump = false
}

--// GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0,55,0,55)
ToggleBtn.Position = UDim2.new(0,20,0.6,0)
ToggleBtn.Text = "HUB"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Draggable = true
Instance.new("UICorner", ToggleBtn)

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,300,0,360)
Main.Position = UDim2.new(0.5,-150,0.5,-180)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.Visible = false
Instance.new("UICorner", Main)

--// TABS BAR
local TabsBar = Instance.new("Frame", Main)
TabsBar.Size = UDim2.new(1,0,0,40)
TabsBar.BackgroundColor3 = Color3.fromRGB(25,25,25)

local TabsLayout = Instance.new("UIListLayout", TabsBar)
TabsLayout.FillDirection = Enum.FillDirection.Horizontal

--// PAGES
local Pages = Instance.new("Frame", Main)
Pages.Size = UDim2.new(1,0,1,-40)
Pages.Position = UDim2.new(0,0,0,40)

-- FUNÇÃO CRIAR PÁGINA
local function CreatePage(name)
    local Button = Instance.new("TextButton", TabsBar)
    Button.Size = UDim2.new(0.33,0,1,0)
    Button.Text = name
    Button.BackgroundColor3 = Color3.fromRGB(35,35,35)
    Button.TextColor3 = Color3.new(1,1,1)

    local Page = Instance.new("Frame", Pages)
    Page.Size = UDim2.new(1,0,1,0)
    Page.Visible = false

    local Layout = Instance.new("UIListLayout", Page)
    Layout.Padding = UDim.new(0,8)

    Button.MouseButton1Click:Connect(function()
        for _,v in pairs(Pages:GetChildren()) do
            if v:IsA("Frame") then v.Visible = false end
        end
        Page.Visible = true
    end)

    return Page
end

local ESPPage = CreatePage("ESP")
local AimPage = CreatePage("MIRA")
local PlayerPage = CreatePage("PLAYER")

ESPPage.Visible = true

--// TOGGLE
local function CreateToggle(parent,text,callback)
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

--// SLIDER REAL
local function CreateSlider(parent,text,min,max,callback)
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)

    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
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

--// ESP TAB
CreateToggle(ESPPage,"ESP",function(v) Settings.ESP=v end)
CreateToggle(ESPPage,"Boxes",function(v) Settings.Boxes=v end)
CreateToggle(ESPPage,"Names",function(v) Settings.Names=v end)
CreateToggle(ESPPage,"Distance",function(v) Settings.Distance=v end)
CreateToggle(ESPPage,"Chams",function(v) Settings.Highlight=v end)
CreateToggle(ESPPage,"TeamCheck",function(v) Settings.TeamCheck=v end)

--// MIRA TAB
CreateToggle(AimPage,"Mostrar FOV",function(v) Settings.ShowFOV=v end)
CreateSlider(AimPage,"FOV",50,300,function(v) Settings.FOV=v end)

--// PLAYER TAB
CreateToggle(PlayerPage,"Speed",function(v) Settings.UseSpeed=v end)
CreateSlider(PlayerPage,"Velocidade",16,100,function(v) Settings.Speed=v end)

CreateToggle(PlayerPage,"Jump",function(v) Settings.UseJump=v end)
CreateSlider(PlayerPage,"Pulo",50,150,function(v) Settings.JumpPower=v end)

CreateToggle(PlayerPage,"Pulo Infinito",function(v) Settings.InfiniteJump=v end)

--// ABRIR/FECHAR
local open=false
ToggleBtn.MouseButton1Click:Connect(function()
    open = not open
    Main.Visible = open
end)

--// FOV
local circle = Drawing.new("Circle")

game:GetService("RunService").RenderStepped:Connect(function()
    circle.Visible = Settings.ShowFOV
    circle.Radius = Settings.FOV
    circle.Position = UIS:GetMouseLocation()

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
