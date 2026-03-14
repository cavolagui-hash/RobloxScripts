-- Player
local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

-- LOGIN FRAME
local loginFrame = Instance.new("Frame")
loginFrame.Size = UDim2.new(0,300,0,180)
loginFrame.Position = UDim2.new(0.5,-150,0.5,-90)
loginFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
loginFrame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.BackgroundColor3 = Color3.fromRGB(255,0,0)
title.Text = "Wakezinn VIP Login"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Parent = loginFrame

local password = Instance.new("TextBox")
password.Size = UDim2.new(0.8,0,0,30)
password.Position = UDim2.new(0.1,0,0.4,0)
password.PlaceholderText = "Digite a senha"
password.Text = ""
password.Parent = loginFrame

local enter = Instance.new("TextButton")
enter.Size = UDim2.new(0.5,0,0,30)
enter.Position = UDim2.new(0.25,0,0.7,0)
enter.Text = "Entrar"
enter.BackgroundColor3 = Color3.fromRGB(255,0,0)
enter.TextColor3 = Color3.fromRGB(255,255,255)
enter.Parent = loginFrame

-- PAINEL
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0,250,0,180)
panel.Position = UDim2.new(0.1,0,0.3,0)
panel.BackgroundColor3 = Color3.fromRGB(0,0,0)
panel.Visible = false
panel.Parent = gui

local tab = Instance.new("TextLabel")
tab.Size = UDim2.new(1,0,0,40)
tab.BackgroundColor3 = Color3.fromRGB(255,0,0)
tab.Text = "Wakezinn VIP"
tab.TextColor3 = Color3.fromRGB(255,255,255)
tab.Parent = panel

local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(0.8,0,0,30)
espButton.Position = UDim2.new(0.1,0,0.4,0)
espButton.Text = "ESP OPONENTE"
espButton.BackgroundColor3 = Color3.fromRGB(30,30,30)
espButton.TextColor3 = Color3.fromRGB(255,255,255)
espButton.Parent = panel

local boxButton = Instance.new("TextButton")
boxButton.Size = UDim2.new(0.8,0,0,30)
boxButton.Position = UDim2.new(0.1,0,0.65,0)
boxButton.Text = "ESP BOX"
boxButton.BackgroundColor3 = Color3.fromRGB(30,30,30)
boxButton.TextColor3 = Color3.fromRGB(255,255,255)
boxButton.Parent = panel

-- SENHA
enter.MouseButton1Click:Connect(function()

	if password.Text == "wakevip777" then
		loginFrame.Visible = false
		panel.Visible = true
	else
		password.Text = ""
		password.PlaceholderText = "Senha incorreta"
	end

end)

-- BOTÕES (exemplo de ação simples)
espButton.MouseButton1Click:Connect(function()
	print("Botão ESP OPONENTE ativado")
end)

boxButton.MouseButton1Click:Connect(function()
	print("Botão ESP BOX ativado")
end)
