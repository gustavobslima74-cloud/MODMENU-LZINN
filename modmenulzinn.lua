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

-- BOTÃO REDONDO
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
Main.Active = true
Main.Draggable = true
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

-- TÍTULO
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "LQB KIKO | v2.8"
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
Pages.BackgroundTransparency = 1

local function UpdateSize(page)
    task.wait()
    Main.Size = UDim2.new(0,300,0,page.AbsoluteSize.Y + 100)
end

local function CreatePage(name)
    local btn = Instance.new("TextButton", Tabs)
    btn.Size = UDim2.new(0.33,0,1,0)
    btn.Text = name
    btn.BackgroundTransparency = 1
    btn.TextColor3 = Color3.new(1,1,1)

    local page = Instance.new("Frame", Pages)
    page.Size = UDim2.new(1,0,0,0)
    page.Visible = false
    page.BackgroundTransparency = 1

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

-- ESP
Toggle(ESPPage,"ESP",function(v) Settings.ESP=v end)
Toggle(ESPPage,"Boxes",function(v) Settings.Boxes=v end)
Toggle(ESPPage,"Names",function(v) Settings.Names=v end)
Toggle(ESPPage,"Distance",function(v) Settings.Distance=v end)
Toggle(ESPPage,"Chams",function(v) Settings.Highlight=v end)

-- PLAYER
Toggle(PlayerPage,"Velocidade",function(v) Settings.UseSpeed=v end)
Toggle(PlayerPage,"Pulo",function(v) Settings.UseJump=v end)
Toggle(PlayerPage,"Pulo Infinito",function(v) Settings.InfiniteJump=v end)

-- ESP SYSTEM
local ESPContainer = {}

local function CreateESP(p)
    if p == LocalPlayer then return end

    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Filled = false
    Box.Color = Color3.fromRGB(255,0,0)
    Box.Transparency = 1

    local Name = Drawing.new("Text")
    Name.Size = 13
    Name.Center = true
    Name.Outline = true

    local Distance = Drawing.new("Text")
    Distance.Size = 13
    Distance.Center = true
    Distance.Outline = true
    Distance.Color = Color3.fromRGB(0,255,0)

    ESPContainer[p] = {Box=Box,Name=Name,Distance=Distance,Highlight=nil}
end

for _,p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

RunService.RenderStepped:Connect(function()
    for p,esp in pairs(ESPContainer) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and Settings.ESP then
            local hrp = p.Character.HumanoidRootPart
            local pos,vis = Camera:WorldToViewportPoint(hrp.Position)

            if vis then
                local head = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0,3,0))
                local leg = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
                local h = math.abs(head.Y-leg.Y)
                local w = h/2

                esp.Box.Visible = Settings.Boxes
                esp.Box.Size = Vector2.new(w,h)
                esp.Box.Position = Vector2.new(pos.X-w/2,pos.Y-h/2)

                esp.Name.Visible = Settings.Names
                esp.Name.Text = p.DisplayName
                esp.Name.Position = Vector2.new(pos.X,pos.Y-h/2-15)

                esp.Distance.Visible = Settings.Distance
                local dist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
                and math.floor((LocalPlayer.Character.HumanoidRootPart.Position-hrp.Position).Magnitude) or 0
                esp.Distance.Text = dist.."m"
                esp.Distance.Position = Vector2.new(pos.X,pos.Y+h/2)
                esp.Distance.Color = Color3.fromRGB(0,255,0)

                if Settings.Highlight then
                    if not esp.Highlight then
                        esp.Highlight = Instance.new("Highlight",p.Character)
                    end
                    esp.Highlight.FillColor = Color3.fromHSV(tick()%5/5,1,1)
                elseif esp.Highlight then
                    esp.Highlight:Destroy()
                    esp.Highlight=nil
                end
            else
                esp.Box.Visible=false
                esp.Name.Visible=false
                esp.Distance.Visible=false
            end
        else
            esp.Box.Visible=false
            esp.Name.Visible=false
            esp.Distance.Visible=false
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if ESPContainer[p] then
        for _,v in pairs(ESPContainer[p]) do
            if typeof(v)=="userdata" then pcall(function() v:Remove() end) end
        end
        ESPContainer[p]=nil
    end
end)

-- HITBOX
task.spawn(function()
    while true do
        for _,p in pairs(Players:GetPlayers()) do
            if p~=LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if Settings.HitboxEnabled then
                        hrp.Size = Vector3.new(Settings.Hitbox,Settings.Hitbox,Settings.Hitbox)
                        hrp.Transparency = Settings.HitboxTransparency
                        hrp.CanCollide = false
                    else
                        hrp.Size = Vector3.new(2,2,1)
                        hrp.Transparency = 0
                        hrp.CanCollide = true
                    end
                end
            end
        end
        task.wait(0.12)
    end
end)

-- SPEED / JUMP
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid

        hum.WalkSpeed = Settings.UseSpeed and Settings.Speed or 16
        hum.JumpPower = Settings.UseJump and Settings.JumpPower or 50
    end
end)

UIS.JumpRequest:Connect(function()
    if Settings.InfiniteJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- OPEN
ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)
