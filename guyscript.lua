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
ToggleOff = Color3.fromRGB(40, 40, 45),
PurpleTab = Color3.fromRGB(128, 0, 255) -- Cor roxa para a aba
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

local ScreenGui = Create("ScreenGui", {Name = "WAKEZINN", Parent = game.CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Global})

-- ================================================
--              TELA DE LOGIN MODIFICADA
-- ================================================

local KeyFrame = Create("Frame", {
    Size = UDim2.new(0, 300, 0, 300), -- Tamanho quadrado (300x300)
    Position = UDim2.new(0.5, -150, 0.5, -150),
    BackgroundColor3 = Color3.fromRGB(15, 15, 20),
    ZIndex = 100,
    Parent = ScreenGui,
    BorderSizePixel = 0
})
Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = KeyFrame}) -- Cantos levemente arredondados para estilo

-- Aba roxa superior
local PurpleTab = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 45),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = C.PurpleTab,
    ZIndex = 101,
    Parent = KeyFrame
})
Create("UICorner", {
    CornerRadius = UDim.new(0, 8),
    Parent = PurpleTab,
    -- Apenas cantos superiores arredondados para combinar com o frame principal
    UDim.new(0, 8), UDim.new(0, 8), UDim.new(0, 0), UDim.new(0, 0)
})

-- Título na aba roxa
local KeyTitle = Create("TextLabel", {
    Text = "WAKEZINN - KEY SYSTEM",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    ZIndex = 102,
    Parent = PurpleTab
})

-- Campo de entrada da key
local KeyInput = Create("TextBox", {
    PlaceholderText = "Digite a Key aqui...",
    Size = UDim2.new(0.8, 0, 0, 40),
    Position = UDim2.new(0.1, 0, 0.35, 0),
    BackgroundColor3 = Color3.fromRGB(30, 30, 35),
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.Gotham,
    TextSize = 14,
    ZIndex = 101,
    Parent = KeyFrame
})
Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = KeyInput})

-- Botão de entrada
local KeyBtn = Create("TextButton", {
    Text = "ENTRAR",
    Size = UDim2.new(0.8, 0, 0, 4
