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

-- BOTÃO (CIRCULAR CORRIGIDO)
local ToggleBtn = Instance.new("ImageButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0,60,0,60)
ToggleBtn.Position = UDim2.new(0,20,0.6,0)
ToggleBtn.Image = "rbxassetid://70505361093133"
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.ClipsDescendants = true
ToggleBtn.Active = true
ToggleBtn.Draggable = true

local btnCorner = Instance.new("UICorner", ToggleBtn)
btnCorner.CornerRadius = UDim.new(1,0)

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
Title.Text = "LQB KIKO | v2.8 FIX"
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
    end)

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
Toggle(PlayerPage,"Speed",function(v) Settings.UseSpeed=v end)
Toggle(PlayerPage,"Jump",function(v) Settings.UseJump=v end)
Toggle(PlayerPage,"Infinite Jump",function(v) Settings.InfiniteJump=v end)

-- ESP STORAGE
local ESP = {}

local function CreateESP(p)
    if p == LocalPlayer then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Color = Color3.fromRGB(255,0,0)
    box.Transparency = 1

    local name = Drawing.new("Text")
    name.Center = true
    name.Outline = true
    name.Size = 13

    local dist = Drawing.new("Text")
    dist.Center = true
    dist.Outline = true
    dist.Size = 13
    dist.Color = Color3.fromRGB(0,255,0)

    ESP[p] = {box=box,name=name,dist=dist,hl=nil}
end

for _,p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

Players.PlayerRemoving:Connect(function(p)
    if ESP[p] then
        for _,v in pairs(ESP[p]) do
            if typeof(v) == "userdata" then pcall(function() v:Remove() end) end
        end
        ESP[p] = nil
    end
end)

-- ESP LOOP (CORRIGIDO LIMPO)
RunService.RenderStepped:Connect(function()
    for p,data in pairs(ESP) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and Settings.ESP then

            local hrp = p.Character.HumanoidRootPart
            local pos,vis = Camera:WorldToViewportPoint(hrp.Position)

            if vis then
                local head = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0,3,0))
                local leg = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))

                local h = math.abs(head.Y-leg.Y)
                local w = h/2

                data.box.Visible = Settings.Boxes
                data.box.Size = Vector2.new(w,h)
                data.box.Position = Vector2.new(pos.X-w/2,pos.Y-h/2)

                data.name.Visible = Settings.Names
                data.name.Text = p.DisplayName
                data.name.Position = Vector2.new(pos.X,pos.Y-h/2-15)

                data.dist.Visible = Settings.Distance
                data.dist.Text =
                    (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
                    and math.floor((LocalPlayer.Character.HumanoidRootPart.Position-hrp.Position).Magnitude).."m"
                    or "0m"

                data.dist.Position = Vector2.new(pos.X,pos.Y+h/2)
                data.dist.Color = Color3.fromRGB(0,255,0)

            else
                data.box.Visible = false
                data.name.Visible = false
                data.dist.Visible = false
            end
        end
    end
end)

-- HITBOX LIMPO (SEM BUG VISUAL)
task.spawn(function()
    while true do
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
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

-- SPEED / JUMP FIX
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if hum then
        hum.WalkSpeed = Settings.UseSpeed and Settings.Speed or 16
        hum.JumpPower = Settings.UseJump and Settings.JumpPower or 50
    end
end)

UIS.JumpRequest:Connect(function()
    if Settings.InfiniteJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

-- OPEN BUTTON
ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)
