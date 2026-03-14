-- WAKEZINN VIP PANEL

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local senhaCorreta = "wakevip777"

local espHeadAtivo = false
local espBoxAtivo = false

-- GUI

local gui = Instance.new("ScreenGui")
gui.Parent = game.CoreGui

-- LOGIN FRAME

local login = Instance.new("Frame")
login.Size = UDim2.new(0,300,0,150)
login.Position = UDim2.new(0.5,-150,0.5,-75)
login.BackgroundColor3 = Color3.fromRGB(0,0,0)
login.Parent = gui

local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1,0,0,40)
titulo.BackgroundColor3 = Color3.fromRGB(255,0,0)
titulo.Text = "Wakezinn VIP Login"
titulo.TextColor3 = Color3.new(1,1,1)
titulo.Parent = login

local caixaSenha = Instance.new("TextBox")
caixaSenha.Size = UDim2.new(0.8,0,0,30)
caixaSenha.Position = UDim2.new(0.1,0,0.4,0)
caixaSenha.PlaceholderText = "Digite a senha"
caixaSenha.Parent = login

local entrar = Instance.new("TextButton")
entrar.Size = UDim2.new(0.5,0,0,30)
entrar.Position = UDim2.new(0.25,0,0.7,0)
entrar.Text = "Entrar"
entrar.BackgroundColor3 = Color3.fromRGB(255,0,0)
entrar.TextColor3 = Color3.new(1,1,1)
entrar.Parent = login

-- PAINEL

local painel = Instance.new("Frame")
painel.Size = UDim2.new(0,250,0,150)
painel.Position = UDim2.new(0.02,0,0.3,0)
painel.BackgroundColor3 = Color3.fromRGB(0,0,0)
painel.Visible = false
painel.Parent = gui

local tab = Instance.new("TextLabel")
tab.Size = UDim2.new(1,0,0,30)
tab.BackgroundColor3 = Color3.fromRGB(255,0,0)
tab.Text = "Wakezinn VIP"
tab.TextColor3 = Color3.new(1,1,1)
tab.Parent = painel

-- BOTÃO ESP OPONENTE

local espHead = Instance.new("TextButton")
espHead.Size = UDim2.new(0.8,0,0,30)
espHead.Position = UDim2.new(0.1,0,0.3,0)
espHead.Text = "ESP OPONENTE : OFF"
espHead.BackgroundColor3 = Color3.fromRGB(40,40,40)
espHead.TextColor3 = Color3.new(1,1,1)
espHead.Parent = painel

-- BOTÃO ESP BOX

local espBox = Instance.new("TextButton")
espBox.Size = UDim2.new(0.8,0,0,30)
espBox.Position = UDim2.new(0.1,0,0.6,0)
espBox.Text = "ESP BOX : OFF"
espBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
espBox.TextColor3 = Color3.new(1,1,1)
espBox.Parent = painel

-- LOGIN

entrar.MouseButton1Click:Connect(function()

if caixaSenha.Text == senhaCorreta then
login.Visible = false
painel.Visible = true
end

end)

-- ESP OPONENTE (linha na cabeça)

local function criarLinha(player)

if player == LocalPlayer then return end

local linha = Drawing.new("Line")
linha.Color = Color3.fromRGB(255,0,0)
linha.Thickness = 2

RunService.RenderStepped:Connect(function()

if espHeadAtivo and player.Character and player.Character:FindFirstChild("Head") then

local head = player.Character.Head
local pos,vis = Camera:WorldToViewportPoint(head.Position)

if vis then

linha.From = Vector2.new(pos.X,pos.Y)
linha.To = Vector2.new(pos.X,pos.Y - 40)
linha.Visible = true

else
linha.Visible = false
end

else
linha.Visible = false
end

end)

end

-- ESP BOX

function createESP(player)

if player == LocalPlayer then return end

local box = Drawing.new("Square")
box.Color = Color3.fromRGB(255,255,255)
box.Thickness = 2
box.Filled = false

RunService.RenderStepped:Connect(function()

if espBoxAtivo and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then

local root = player.Character.HumanoidRootPart
local pos,visible = Camera:WorldToViewportPoint(root.Position)

if visible then

local size = Vector2.new(40,60)

box.Size = size
box.Position = Vector2.new(pos.X - size.X/2,pos.Y - size.Y/2)
box.Visible = true

else
box.Visible = false
end

else
box.Visible = false
end

end)

end

-- BOTÕES

espHead.MouseButton1Click:Connect(function()

espHeadAtivo = not espHeadAtivo

if espHeadAtivo then
espHead.Text = "ESP OPONENTE : ON"
else
espHead.Text = "ESP OPONENTE : OFF"
end

end)

espBox.MouseButton1Click:Connect(function()

espBoxAtivo = not espBoxAtivo

if espBoxAtivo then
espBox.Text = "ESP BOX : ON"
else
espBox.Text = "ESP BOX : OFF"
end

end)

-- PLAYER LOOP

for _,player in pairs(Players:GetPlayers()) do
criarLinha(player)
createESP(player)
end

Players.PlayerAdded:Connect(function(player)

criarLinha(player)
createESP(player)

end)
