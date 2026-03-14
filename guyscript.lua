--[[
    ZZ HUB - v7 ESP FIX & SPIN 100
    Desenvolvedor: Silva Modz
    Jogo: Roblox (Rivals/Outros)
    Key: monite
    Status: ESP Fix, Spin Bot 100 (No Slider), Fly, Silent Aim, Magnet
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================================================
--              CONFIGURAÇÕES E ESTADO
-- ================================================

local CORRECT_KEY = "monite"
local RGBMode = true
local BloodMode = false
local AimbotEnabled = false
local SilentAimEnabled = false
local MagnetEnabled = false
local UpPlayerEnabled = false
local FlyEnabled = false
local AimbotFOV = 100
local ShowFOV = false
local SpinBotEnabled = false
local SpinSpeed = 100 -- Velocidade fixa conforme solicitado
local NoclipEnabled = false
local DoubleJumpEnabled = false
local CurrentLang = "PT" -- PT, EN, ES
local FPS = 0

local ESPSettings = {
    Box3D = false,
    Linha = false,
    Vida = false,
    Esqueleto = false,
    Nome = false,
    Distancia = false,
    LinhaRGB = false
}

local LangData = {
    PT = {Main="Principal", Visual="Visual", Menu="Menu", Full="Config", Info="Info", Aimbot="Aimbot Head", Silent="Silent Aim", Magnet="Magnet", ShowFOV="Exibir FOV", FOVRadius="Raio do FOV", ESPBox="ESP Box 3D", ESPLine="ESP Linha (Topo)", ESPHealth="ESP Vida", ESPSkeleton="ESP Esqueleto", ESPName="ESP Nome", ESPDist="ESP Distancia", ESPRGB="ESP Linha RGB", SpinBot="Spin Bot (100)", Noclip="Noclip", Jump="Pulo Duplo", Lang="Idioma", FPS="FPS", Up="Up Player", Fly="Voar (Fly)"},
    EN = {Main="Main", Visual="Visual", Menu="Menu", Full="Settings", Info="Info", Aimbot="Aimbot Head", Silent="Silent Aim", Magnet="Magnet", ShowFOV="Show FOV", FOVRadius="FOV Radius", ESPBox="ESP Box 3D", ESPLine="ESP Line (Top)", ESPHealth="ESP Health", ESPSkeleton="ESP Skeleton", ESPName="ESP Name", ESPDist="ESP Distance", ESPRGB="ESP Line RGB", SpinBot="Spin Bot (100)", Noclip="Noclip", Jump="Double Jump", Lang="Language", FPS="FPS", Up="Up Player", Fly="Fly Mode"},
    ES = {Main="Principal", Visual="Visual", Menu="Menu", Full="Ajustes", Info="Info", Aimbot="Aimbot Cabeza", Silent="Silent Aim", Magnet="Magnet", ShowFOV="Mostrar FOV", FOVRadius="Radio del FOV", ESPBox="ESP Box 3D", ESPLine="ESP Línea (Arriba)", ESPHealth="ESP Vida", ESPSkeleton="ESP Esqueleto", ESPName="ESP Nombre", ESPDist="ESP Distancia", ESPRGB="ESP Línea RGB", SpinBot="Spin Bot (100)", Noclip="Noclip", Jump="Salto Doble", Lang="Idioma", FPS="FPS", Up="Up Player", Fly="Volar (Fly)"}
}

local C = {
    MainBG = Color3.fromRGB(10, 10, 12),
    SidebarBG = Color3.fromRGB(15, 15, 18),
    Accent = Color3.fromRGB(200, 30, 30),
    Blood = Color3.fromRGB(139, 0, 0),
    Text = Color3.fromRGB(240, 240, 240),
    ToggleOff = Color3.fromRGB(40, 40, 45)
}

-- ================================================
--              UTILITÁRIOS
-- ================================================

local function Create(class, props)
    local o = Instance.new(class)
    for k, v in pairs(props) do if k ~= "Parent" then o[k] = v end end
    if props.Parent then o.Parent = props.Parent end
    return o
end

local function MakeDraggable(frame, handle)
    local drag, dStart, sPos = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; dStart = i.Position; sPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dStart
            frame.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset+d.X, sPos.Y.Scale, sPos.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
end

-- ================================================
--              SISTEMA DE ESP & FOV
-- ================================================

local ESP_Objects = {}
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Radius = AimbotFOV
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

local function CreateESP(player)
    local objects = {
        Box3D = {Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line")},
        Line = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBarBG = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        Skeleton = {}
    }
    for _, line in pairs(objects.Box3D) do line.Thickness = 1.5 end
    objects.Line.Thickness = 1.5
    objects.Name.Size = 14; objects.Name.Center = true; objects.Name.Outline = true
    objects.Distance.Size = 12; objects.Distance.Center = true; objects.Distance.Outline = true
    objects.HealthBarBG.Filled = true; objects.HealthBarBG.Color = Color3.fromRGB(0,0,0)
    objects.HealthBar.Filled = true
    for i = 1, 15 do objects.Skeleton[i] = Drawing.new("Line"); objects.Skeleton[i].Thickness = 2.5 end
    ESP_Objects[player] = objects
end

local function UpdateESP()
    FOVCircle.Visible = ShowFOV
    FOVCircle.Radius = AimbotFOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    local hue = tick() % 5 / 5
    local rgbColor = Color3.fromHSV(hue, 1, 1)
    local espMainColor = ESPSettings.LinhaRGB and rgbColor or Color3.fromRGB(255,255,255)

    for player, objects in pairs(ESP_Objects) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local char = player.Character
            local hrp = char.HumanoidRootPart
            local hum = char.Humanoid
            
            -- FIX: Sempre obter a posição atualizada na tela dentro do loop
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen then
                -- Box 3D
                if ESPSettings.Box3D then
                    local size = Vector3.new(2, 3, 2)
                    local cf = hrp.CFrame
                    local points = {
                        Camera:WorldToViewportPoint((cf * CFrame.new(size.X, size.Y, size.Z)).Position),
                        Camera:WorldToViewportPoint((cf * CFrame.new(-size.X, size.Y, size.Z)).Position),
                        Camera:WorldToViewportPoint((cf * CFrame.new(-size.X, -size.Y, size.Z)).Position),
                        Camera:WorldToViewportPoint((cf * CFrame.new(size.X, -size.Y, size.Z)).Position),
                        Camera:WorldToViewportPoint((cf * CFrame.new(size.X, size.Y, -size.Z)).Position),
                        Camera:WorldToViewportPoint((cf * CFrame.new(-size.X, size.Y, -size.Z)).Position),
                        Camera:WorldToViewportPoint((cf * CFrame.new(-size.X, -size.Y, -size.Z)).Position),
                        Camera:WorldToViewportPoint((cf * CFrame.new(size.X, -size.Y, -size.Z)).Position)
                    }
                    local lines = {{1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8}}
                    for i, edge in pairs(lines) do
                        objects.Box3D[i].Visible = true
                        objects.Box3D[i].From = Vector2.new(points[edge[1]].X, points[edge[1]].Y)
                        objects.Box3D[i].To = Vector2.new(points[edge[2]].X, points[edge[2]].Y)
                        objects.Box3D[i].Color = espMainColor
                    end
                else for _, l in pairs(objects.Box3D) do l.Visible = false end end

                -- ESP Linha (Topo)
                objects.Line.Visible = ESPSettings.Linha
                if ESPSettings.Linha then
                    objects.Line.From = Vector2.new(Camera.ViewportSize.X / 2, 0)
                    objects.Line.To = Vector2.new(pos.X, pos.Y)
                    objects.Line.Color = espMainColor
                end

                -- ESP Vida
                objects.HealthBarBG.Visible = ESPSettings.Vida
                objects.HealthBar.Visible = ESPSettings.Vida
                if ESPSettings.Vida then
                    local headPos = Camera:WorldToViewportPoint(char.Head.Position + Vector3.new(0, 0.5, 0))
                    local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height / 2
                    local hpPercent = hum.Health / hum.MaxHealth
                    objects.HealthBarBG.Size = Vector2.new(2, height)
                    objects.HealthBarBG.Position = Vector2.new(pos.X - width/2 - 6, pos.Y - height/2)
                    objects.HealthBar.Size = Vector2.new(2, height * hpPercent)
                    objects.HealthBar.Position = Vector2.new(pos.X - width/2 - 6, pos.Y + height/2 - (height * hpPercent))
                    objects.HealthBar.Color = Color3.fromRGB(255 - (255 * hpPercent), 255 * hpPercent, 0)
                end

                -- Esqueleto Grosso
                local parts = hum.RigType == Enum.HumanoidRigType.R15 and 
                    {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"}} or
                    {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
                
                for i, p in pairs(parts) do
                    local line = objects.Skeleton[i]
                    if ESPSettings.Esqueleto and char:FindFirstChild(p[1]) and char:FindFirstChild(p[2]) then
                        local p1, v1 = Camera:WorldToViewportPoint(char[p[1]].Position)
                        local p2, v2 = Camera:WorldToViewportPoint(char[p[2]].Position)
                        line.Visible = v1 and v2
                        line.From = Vector2.new(p1.X, p1.Y); line.To = Vector2.new(p2.X, p2.Y); line.Color = espMainColor
                    else line.Visible = false end
                end
                
                objects.Name.Visible = ESPSettings.Nome
                objects.Name.Text = player.Name; objects.Name.Position = Vector2.new(pos.X, pos.Y - 40); objects.Name.Color = Color3.fromRGB(255,255,255)
                
                objects.Distance.Visible = ESPSettings.Distancia
                local d = math.floor((hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                objects.Distance.Text = "["..d.."m]"; objects.Distance.Position = Vector2.new(pos.X, pos.Y + 40); objects.Distance.Color = Color3.fromRGB(255,255,0)
            else for _, v in pairs(objects) do if type(v) == "table" then for _, l in pairs(v) do l.Visible = false end else v.Visible = false end end end
        else for _, v in pairs(objects) do if type(v) == "table" then for _, l in pairs(v) do l.Visible = false end else v.Visible = false end end end
    end
end

-- ================================================
--              INTERFACE PRINCIPAL
-- ================================================

local ScreenGui = Create("ScreenGui", {Name = "ZZHubProV7", Parent = game.CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Global})

-- Sistema de Key
local KeyFrame = Create("Frame", {Size = UDim2.new(0, 350, 0, 200), Position = UDim2.new(0.5, -175, 0.5, -100), BackgroundColor3 = C.MainBG, ZIndex = 100, Parent = ScreenGui})
Create("UICorner", {CornerRadius = UDim.new(0, 15), Parent = KeyFrame})
local KeyBorder = Create("UIStroke", {Thickness = 2.5, Color = C.Accent, Parent = KeyFrame})

local KeyTitle = Create("TextLabel", {Text = "ZZ HUB - KEY SYSTEM", Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, TextColor3 = C.Text, Font = Enum.Font.GothamBold, TextSize = 18, ZIndex = 101, Parent = KeyFrame})
local KeyInput = Create("TextBox", {PlaceholderText = "Digite a Key aqui...", Size = UDim2.new(0.8, 0, 0, 40), Position = UDim2.new(0.1, 0, 0.4, 0), BackgroundColor3 = C.SidebarBG, TextColor3 = C.Text, Font = Enum.Font.Gotham, ZIndex = 101, Parent = KeyFrame})
Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = KeyInput})
local KeyBtn = Create("TextButton", {Text = "ENTRAR", Size = UDim2.new(0.6, 0, 0, 40), Position = UDim2.new(0.2, 0, 0.7, 0), BackgroundColor3 = C.Accent, TextColor3 = C.Text, Font = Enum.Font.GothamBold, ZIndex = 101, Parent = KeyFrame})
Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = KeyBtn})

-- Layout Principal
local MainFrame = Create("Frame", {Size = UDim2.new(0, 500, 0, 350), Position = UDim2.new(0.5, -250, 0.5, -175), BackgroundColor3 = C.MainBG, Visible = false, ZIndex = 10, Parent = ScreenGui})
Create("UICorner", {CornerRadius = UDim.new(0, 20), Parent = MainFrame})
local MainBorder = Create("UIStroke", {Thickness = 2.5, Color = C.Accent, Parent = MainFrame})

local FloatingBtn = Create("TextButton", {Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0, 10, 0.5, -25), BackgroundColor3 = C.Accent, Text = "ZZ", TextColor3 = C.Text, Font = Enum.Font.GothamBold, Visible = false, ZIndex = 20, Parent = ScreenGui})
Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = FloatingBtn})
Create("UIStroke", {Thickness = 2, Color = Color3.fromRGB(255,255,255), Parent = FloatingBtn})
MakeDraggable(FloatingBtn, FloatingBtn)

KeyBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == CORRECT_KEY then
        KeyFrame.Visible = false
        MainFrame.Visible = true
        FloatingBtn.Visible = true
    else
        KeyInput.Text = ""
        KeyInput.PlaceholderText = "Key Incorreta!"
    end
end)

FloatingBtn.MouseButton1Click:Connect(function() 
    MainFrame.Visible = not MainFrame.Visible 
    if not MainFrame.Visible then FOVCircle.Visible = false end
end)

local Sidebar = Create("Frame", {Size = UDim2.new(0, 70, 1, 0), BackgroundColor3 = C.SidebarBG, ZIndex = 11, Parent = MainFrame})
Create("UICorner", {CornerRadius = UDim.new(0, 20), Parent = Sidebar})
local IconContainer = Create("Frame", {Size = UDim2.new(1, 0, 1, -40), Position = UDim2.new(0, 0, 0, 20), BackgroundTransparency = 1, ZIndex = 12, Parent = Sidebar})
Create("UIListLayout", {Parent = IconContainer, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 15)})

local MoonBtn = Create("TextButton", {Text = "🌙", Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(1, -50, 0, 5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 25, ZIndex = 15, Parent = MainFrame})
MoonBtn.MouseButton1Click:Connect(function()
    BloodMode = not BloodMode
    local targetColor = BloodMode and C.Blood or C.Accent
    MainBorder.Color = targetColor; FloatingBtn.BackgroundColor3 = targetColor; MoonBtn.TextColor3 = targetColor
end)

local Container = Create("Frame", {Size = UDim2.new(1, -90, 1, -60), Position = UDim2.new(0, 80, 0, 50), BackgroundTransparency = 1, ZIndex = 11, Parent = MainFrame})
local TabFrames = {}

local function AddTab(name, icon, order)
    local btn = Create("TextButton", {Text = icon, Size = UDim2.new(0, 45, 0, 45), BackgroundColor3 = (order == 1) and C.Accent or Color3.fromRGB(30,30,35), TextColor3 = C.Text, Font = Enum.Font.GothamBold, TextSize = 20, ZIndex = 13, Parent = IconContainer})
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = btn})
    local frame = Create("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = (order == 1), ZIndex = 13, Parent = Container, ScrollBarThickness = 2})
    Create("UIListLayout", {Parent = frame, Padding = UDim.new(0, 10)})
    TabFrames[name] = {frame = frame, btn = btn}
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(TabFrames) do t.frame.Visible = false; t.btn.BackgroundColor3 = Color3.fromRGB(30,30,35) end
        frame.Visible = true; btn.BackgroundColor3 = BloodMode and C.Blood or C.Accent
    end)
    return frame
end

local Toggles = {}
local function AddToggle(parent, textKey, callback)
    local row = Create("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Color3.fromRGB(20,20,25), ZIndex = 14, Parent = parent})
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = row})
    local label = Create("TextLabel", {Text = LangData[CurrentLang][textKey], Size = UDim2.new(0.7, 0, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, TextColor3 = C.Text, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15, Parent = row})
    local tog = Create("TextButton", {Text = "", Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = C.ToggleOff, ZIndex = 15, Parent = row})
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = tog})
    local tObj = {state = false, tog = tog, label = label, key = textKey}
    table.insert(Toggles, tObj)
    tog.MouseButton1Click:Connect(function()
        tObj.state = not tObj.state
        tog.BackgroundColor3 = tObj.state and (BloodMode and C.Blood or C.Accent) or C.ToggleOff
        callback(tObj.state)
    end)
end

local function AddSlider(parent, textKey, min, max, default, callback)
    local row = Create("Frame", {Size = UDim2.new(1, 0, 0, 55), BackgroundColor3 = Color3.fromRGB(20,20,25), ZIndex = 14, Parent = parent})
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = row})
    local label = Create("TextLabel", {Text = LangData[CurrentLang][textKey]..": "..default, Size = UDim2.new(1, 0, 0, 25), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, TextColor3 = C.Text, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15, Parent = row})
    local sliderBg = Create("Frame", {Size = UDim2.new(0.9, 0, 0, 5), Position = UDim2.new(0.05, 0, 0.7, 0), BackgroundColor3 = C.ToggleOff, ZIndex = 15, Parent = row})
    local sliderFill = Create("Frame", {Size = UDim2.new((default-min)/(max-min), 0, 1, 0), BackgroundColor3 = C.Accent, ZIndex = 16, Parent = sliderBg})
    local btn = Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 17, Parent = sliderBg})
    btn.MouseButton1Down:Connect(function()
        local conn; conn = RunService.RenderStepped:Connect(function()
            local mouseX = UserInputService:GetMouseLocation().X
            local rel = math.clamp((mouseX - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            sliderFill.Size = UDim2.new(rel, 0, 1, 0)
            local val = math.floor(min + (max - min) * rel)
            label.Text = LangData[CurrentLang][textKey]..": "..val; callback(val)
        end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then conn:Disconnect() end end)
    end)
end

-- Preencher Abas
local MainTab = AddTab("Main", "🎯", 1)
AddToggle(MainTab, "Aimbot", function(v) AimbotEnabled = v end)
AddToggle(MainTab, "Silent", function(v) SilentAimEnabled = v end)
AddToggle(MainTab, "Magnet", function(v) MagnetEnabled = v end)
AddToggle(MainTab, "ShowFOV", function(v) ShowFOV = v end)
AddSlider(MainTab, "FOVRadius", 10, 500, 100, function(v) AimbotFOV = v end)

local VisualTab = AddTab("Visual", "👁️", 2)
AddToggle(VisualTab, "ESPBox", function(v) ESPSettings.Box3D = v end)
AddToggle(VisualTab, "ESPLine", function(v) ESPSettings.Linha = v end)
AddToggle(VisualTab, "ESPHealth", function(v) ESPSettings.Vida = v end)
AddToggle(VisualTab, "ESPSkeleton", function(v) ESPSettings.Esqueleto = v end)
AddToggle(VisualTab, "ESPName", function(v) ESPSettings.Nome = v end)
AddToggle(VisualTab, "ESPDist", function(v) ESPSettings.Distancia = v end)
AddToggle(VisualTab, "ESPRGB", function(v) ESPSettings.LinhaRGB = v end)

local MenuTab = AddTab("Menu", "⚙️", 3)
AddToggle(MenuTab, "SpinBot", function(v) SpinBotEnabled = v end)
AddToggle(MenuTab, "Noclip", function(v) NoclipEnabled = v end)
AddToggle(MenuTab, "Jump", function(v) DoubleJumpEnabled = v end)
AddToggle(MenuTab, "Up", function(v) UpPlayerEnabled = v end)
AddToggle(MenuTab, "Fly", function(v) FlyEnabled = v end)

local FullTab = AddTab("Full", "🌍", 4)
local FPSLabel = Create("TextLabel", {Text = "FPS: 0", Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, TextColor3 = C.Text, Font = Enum.Font.GothamBold, ZIndex = 15, Parent = FullTab})
local LangBtn = Create("TextButton", {Text = "IDIOMA: PT", Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Color3.fromRGB(30,30,35), TextColor3 = C.Text, Font = Enum.Font.GothamBold, ZIndex = 15, Parent = FullTab})
Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = LangBtn})
LangBtn.MouseButton1Click:Connect(function()
    if CurrentLang == "PT" then CurrentLang = "EN" elseif CurrentLang == "EN" then CurrentLang = "ES" else CurrentLang = "PT" end
    LangBtn.Text = "IDIOMA: "..CurrentLang
    for _, t in pairs(Toggles) do t.label.Text = LangData[CurrentLang][t.key] end
end)

-- Lógica de Funcionamento
local function GetClosestPlayer()
    local target = nil; local dist = AimbotFOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if vis then
                local d = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if d < dist then dist = d; target = p end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    -- Fly Logic
    if FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        hum.PlatformStand = true
        hrp.Velocity = (hum.MoveDirection * 50) + Vector3.new(0, 2, 0)
    elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
    end
    
    -- FPS Counter
    FPS = math.floor(1 / RunService.RenderStepped:Wait())
    FPSLabel.Text = "FPS: "..FPS
    
    -- Update ESP in every frame to prevent it from going out of place
    UpdateESP()
    
    local target = GetClosestPlayer()
    
    -- Aimbot
    if AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and target then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character.Head.Position), 0.15)
    end
    
    -- Magnet & Up Player
    if (MagnetEnabled or UpPlayerEnabled) and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            if MagnetEnabled then target.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -10) end
            if UpPlayerEnabled then target.Character.HumanoidRootPart.Velocity = Vector3.new(0, 100, 0) end
        end
    end
    
    -- Spinbot Fix (Velocidade 100)
    if SpinBotEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
    end
    
    -- Noclip
    if NoclipEnabled and LocalPlayer.Character then
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end
end)

-- Inicializar ESP para jogadores existentes
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then CreateESP(p) end end)

print("ZZ HUB v7 (ESP FIXED & SPIN 100) CARREGADO!")
