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

-- BOTÃO
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

-- TÍTULO
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "LQB KIKO | v2.6.2"
Title.BackgroundTransparency = 1
Title.TextScaled = true

task.spawn(function()
    while true do
        Title.TextColor3 = Color3.fromHSV(tick()%5/5,1,1)
        task.wait()
    end
end)

-- ABAS (SEM FUNDO)
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

-- FUNÇÃO DE ATUALIZAR TAMANHO (CORRETA)
local function UpdateSize(page)
    task.wait()

    local total = 0
    for _,v in pairs(page:GetChildren()) do
        if v:IsA("TextButton") or v:IsA("TextLabel") or v:IsA("Frame") then
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
    page.Size = UDim2.new(1,0,0,0)
    page.Visible = false
    page.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0,8)

    -- 🔥 ATUALIZA AUTOMÁTICO SEMPRE QUE MUDAR
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.Size = UDim2.new(1,0,0, layout.AbsoluteContentSize.Y)
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

-- 🔥 GARANTE TAMANHO INICIAL CORRETO
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
Toggle(PlayerPage,"Speed",function(v) Settings.UseSpeed=v end)
Toggle(PlayerPage,"Jump",function(v) Settings.UseJump=v end)
Toggle(PlayerPage,"Pulo Infinito",function(v) Settings.InfiniteJump=v end)

-- HITBOX TAB
Toggle(HitboxPage,"Hitbox",function(v) Settings.HitboxEnabled=v end)

-- TAMANHO
local HitboxParts = {}

RunService.RenderStepped:Connect(function()
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            
            local hrp = p.Character.HumanoidRootPart

            if Settings.HitboxEnabled then
                
                if not HitboxParts[p] then
                    local part = Instance.new("BoxHandleAdornment")
                    part.Adornee = hrp
                    part.AlwaysOnTop = true
                    part.ZIndex = 5
                    part.Color3 = Color3.fromRGB(255,0,0)
                    part.Transparency = 0.5
                    part.Size = Vector3.new(10,10,10)
                    part.Parent = hrp

                    HitboxParts[p] = part
                end

                local hb = HitboxParts[p]

                -- TAMANHO
                hb.Size = Vector3.new(Settings.Hitbox,Settings.Hitbox,Settings.Hitbox)

                -- OPACIDADE (FUNCIONA DE VERDADE)
                local t = math.floor(Settings.HitboxTransparency / 0.05 + 0.5) * 0.05
                hb.Transparency = t

                -- RGB OPCIONAL (fica bonito)
                hb.Color3 = Color3.fromHSV(tick()%5/5,1,1)

            else
                if HitboxParts[p] then
                    HitboxParts[p]:Destroy()
                    HitboxParts[p] = nil
                end
            end
        end
    end
end)

-- ESP SISTEMA (CORRIGIDO + CHAMS RGB)
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

    local Distance = Drawing.new("Text")
    Distance.Size = 13
    Distance.Center = true
    Distance.Outline = true
    Distance.Color = Color3.fromRGB(0,255,0)

    ESPContainer[player] = {Box=Box,Name=Name,Distance=Distance,Highlight=nil}
end

for _,p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

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

                -- CHAMS RGB
                if Settings.Highlight then
                    if not esp.Highlight then
                        local hl = Instance.new("Highlight")
                        hl.FillTransparency = 0.5
                        hl.Parent = player.Character
                        esp.Highlight = hl
                    end
                    local hue = tick()%5/5
                    esp.Highlight.FillColor = Color3.fromHSV(hue,1,1)
                    esp.Highlight.OutlineColor = Color3.fromHSV(hue,1,1)
                else
                    if esp.Highlight then
                        esp.Highlight:Destroy()
                        esp.Highlight = nil
                    end
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
end)

-- HITBOX FIX
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
                    part.Material = Enum.Material.ForceField
                    part.Color = Color3.fromRGB(255,0,0)
                    part.Parent = workspace
                    HitboxParts[p] = part
                end

                local hb = HitboxParts[p]
                hb.Size = Vector3.new(Settings.Hitbox,Settings.Hitbox,Settings.Hitbox)
                hb.CFrame = hrp.CFrame
                hb.Transparency = math.floor(Settings.HitboxTransparency / 0.05 + 0.5) * 0.05

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
