-- Script para Roblox: wakezyn iPhone Mod Menu
-- Localização: StarterGui

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Configurações principais do painel
local MOD_MENU_NAME = "wakezyn iPhone"
local PANEL_SIZE = UDim2.new(0, 100, 0, 100)
local PANEL_DEFAULT_POS = UDim2.new(0, 50, 0, 50)
local PANEL_MAIN_COLOR = Color3.new(1, 0, 0) -- Vermelho
local PANEL_DRAG_SPEED = 5 -- Velocidade rápida de movimento
local MATRIX_EFFECT_SPEED = 0.15

-- Estado do painel
local isMenuVisible = true -- Menu visível por padrão sem login
local isMatrixActive = true
local isRGBEnabled = false
local currentTab = "Player"
local selectedTarget = nil
local inputFingerCount = 0

-- Cores configuráveis
local currentLineColor = Color3.new(0, 1, 0) -- Verde padrão
local currentSkeletonColor = Color3.new(1, 1, 0) -- Amarelo padrão
local currentBoxColor = Color3.new(0, 0, 1) -- Azul padrão
local currentRGBSpeed = 0.05

-- Variáveis de funcionalidades
local speedValue = 16 -- Velocidade padrão do jogador
local aimbotMode = "ao olhar" -- Modo padrão
local isSpeedActive = false
local isLineESPActive = false
local isSkeletonESPActive = false
local isBoxESPActive = false
local isAimbotActive = false

-- Criação da GUI principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = MOD_MENU_NAME
ScreenGui.Parent = LocalPlayer.PlayerGui

-- Painel principal do menu
local MainPanel = Instance.new("Frame")
MainPanel.Name = "MainPanel"
MainPanel.Size = PANEL_SIZE
MainPanel.Position = PANEL_DEFAULT_POS
MainPanel.BackgroundColor3 = PANEL_MAIN_COLOR
MainPanel.BorderColor3 = Color3.new(0, 0, 0)
MainPanel.BorderSizePixel = 2
MainPanel.Visible = isMenuVisible
MainPanel.Parent = ScreenGui

-- Botão de arrasto do painel
local DragButton = Instance.new("TextButton")
DragButton.Name = "DragButton"
DragButton.Text = MOD_MENU_NAME
DragButton.Size = UDim2.new(1, 0, 0, 20)
DragButton.Position = UDim2.new(0, 0, 0, 0)
DragButton.BackgroundColor3 = Color3.new(0.8, 0, 0)
DragButton.TextColor3 = Color3.new(1, 1, 1)
DragButton.Font = Enum.Font.SourceSansBold
DragButton.TextSize = 12
DragButton.Parent = MainPanel

-- Tabs do menu
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, 0, 0, 20)
TabContainer.Position = UDim2.new(0, 0, 0, 20)
TabContainer.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
TabContainer.Parent = MainPanel

local PlayerTab = Instance.new("TextButton")
PlayerTab.Name = "PlayerTab"
PlayerTab.Text = "PLAYER"
PlayerTab.Size = UDim2.new(1/3, 0, 1, 0)
PlayerTab.Position = UDim2.new(0, 0, 0, 0)
PlayerTab.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
PlayerTab.TextColor3 = Color3.new(1, 1, 1)
PlayerTab.Parent = TabContainer

local ESPTab = Instance.new("TextButton")
ESPTab.Name = "ESPTab"
ESPTab.Text = "ESP"
ESPTab.Size = UDim2.new(1/3, 0, 1, 0)
ESPTab.Position = UDim2.new(1/3, 0, 0, 0)
ESPTab.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
ESPTab.TextColor3 = Color3.new(1, 1, 1)
ESPTab.Parent = TabContainer

local AimbotTab = Instance.new("TextButton")
AimbotTab.Name = "AimbotTab"
AimbotTab.Text = "AIMBOT"
AimbotTab.Size = UDim2.new(1/3, 0, 1, 0)
AimbotTab.Position = UDim2.new(2/3, 0, 0, 0)
AimbotTab.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
AimbotTab.TextColor3 = Color3.new(1, 1, 1)
AimbotTab.Parent = TabContainer

-- Área de conteúdo das tabs
local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, 0, 1, -40)
ContentArea.Position = UDim2.new(0, 0, 0, 40)
ContentArea.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
ContentArea.CanvasSize = UDim2.new(1, 0, 3, 0)
ContentArea.ScrollBarThickness = 5
ContentArea.Parent = MainPanel

-- Painel de configurações de cores e efeitos
local ConfigPanel = Instance.new("Frame")
ConfigPanel.Name = "ConfigPanel"
ConfigPanel.Size = UDim2.new(1, 0, 0, 30)
ConfigPanel.Position = UDim2.new(0, 0, 1, -30)
ConfigPanel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
ConfigPanel.Parent = MainPanel

local ColorButton = Instance.new("TextButton")
ColorButton.Text = "Mudar Cores"
ColorButton.Size = UDim2.new(0.4, 0, 0, 25)
ColorButton.Position = UDim2.new(0.05, 0, 0.5, -12.5)
ColorButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
ColorButton.TextColor3 = Color3.new(1, 1, 1)
ColorButton.Parent = ConfigPanel

local RGBToggle = Instance.new("TextButton")
RGBToggle.Text = "RGB: Desativado"
RGBToggle.Size = UDim2.new(0.4, 0, 0, 25)
RGBToggle.Position = UDim2.new(0.55, 0, 0.5, -12.5)
RGBToggle.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
RGBToggle.TextColor3 = Color3.new(1, 1, 1)
RGBToggle.Parent = ConfigPanel

-- Conteúdo da Tab PLAYER
local PlayerContent = Instance.new("Frame")
PlayerContent.Name = "PlayerContent"
PlayerContent.Size = UDim2.new(1, 0, 0, 150)
PlayerContent.Position = UDim2.new(0, 0, 0, 0)
PlayerContent.BackgroundTransparency = 1
PlayerContent.Parent = ContentArea

-- Speed Player
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Text = "SPEED PLAYER: "..speedValue
SpeedLabel.Size = UDim2.new(1, 0, 0, 20)
SpeedLabel.Position = UDim2.new(0, 0, 0, 10)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.TextColor3 = Color3.new(1, 1, 1)
SpeedLabel.TextSize = 12
SpeedLabel.Parent = PlayerContent

local SpeedSlider = Instance.new("ScrollingFrame")
SpeedSlider.Name = "SpeedSlider"
SpeedSlider.Size = UDim2.new(0.8, 0, 0, 15)
SpeedSlider.Position = UDim2.new(0.1, 0, 0, 35)
SpeedSlider.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
SpeedSlider.ClipsDescendants = true
SpeedSlider.CanvasSize = UDim2.new(99, 0, 0, 0)
SpeedSlider.Parent = PlayerContent

local SliderKnob = Instance.new("Frame")
SliderKnob.Size = UDim2.new(0, 5, 0, 15)
SliderKnob.Position = UDim2.new(0, 0, 0, 0)
SliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
SliderKnob.Parent = SpeedSlider

local SpeedToggle = Instance.new("TextButton")
SpeedToggle.Text = "Ativar"
SpeedToggle.Size = UDim2.new(0.4, 0, 0, 20)
SpeedToggle.Position = UDim2.new(0.3, 0, 0, 55)
SpeedToggle.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
SpeedToggle.TextColor3 = Color3.new(1, 1, 1)
SpeedToggle.Parent = PlayerContent

-- TP Player
local TPLabel = Instance.new("TextLabel")
TPLabel.Text = "TP PLAYER"
TPLabel.Size = UDim2.new(1, 0, 0, 20)
TPLabel.Position = UDim2.new(0, 0, 0, 85)
TPLabel.BackgroundTransparency = 1
TPLabel.TextColor3 = Color3.new(1, 1, 1)
TPLabel.TextSize = 12
TPLabel.Parent = PlayerContent

local TargetDropdown = Instance.new("TextButton")
TargetDropdown.Text = "Selecionar Alvo"
TargetDropdown.Size = UDim2.new(0.8, 0, 0, 20)
TargetDropdown.Position = UDim2.new(0.1, 0, 0, 110)
TargetDropdown.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
TargetDropdown.TextColor3 = Color3.new(1, 1, 1)
TargetDropdown.Parent = PlayerContent

local TPToggle = Instance.new("TextButton")
TPToggle.Text = "Teletransportar"
TPToggle.Size = UDim2.new(0.4, 0, 0, 20)
TPToggle.Position = UDim2.new(0.3, 0, 0, 135)
TPToggle.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
TPToggle.TextColor3 = Color3.new(1, 1, 1)
TPToggle.Parent = PlayerContent

-- Conteúdo da Tab ESP
local ESPContent = Instance.new("Frame")
ESPContent.Name = "ESPContent"
ESPContent.Size = UDim2.new(1, 0, 0, 180)
ESPContent.Position = UDim2.new(0, 0, 0, 0)
ESPContent.BackgroundTransparency = 1
ESPContent.Visible = false
ESPContent.Parent = ContentArea

-- ESP Linha
local LineESPLabel = Instance.new("TextLabel")
LineESPLabel.Text = "ESP LINHA"
LineESPLabel.Size = UDim2.new(1, 0, 0, 20)
LineESPLabel.Position = UDim2.new(0, 0, 0, 10)
LineESPLabel.BackgroundTransparency = 1
LineESPLabel.TextColor3 = Color3.new(1, 1, 1)
LineESPLabel.TextSize = 12
LineESPLabel.Parent = ESPContent

local LineESPToggle = Instance.new("TextButton")
LineESPToggle.Text = "Ativar"
LineESPToggle.Size = UDim2.new(0.4, 0, 0, 20)
LineESPToggle.Position = UDim2.new(0.3, 0, 0, 35)
LineESPToggle.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
LineESPToggle.TextColor3 = Color3.new(1, 1, 1)
LineESPToggle.Parent = ESPContent

-- ESP Esqueleto
local SkeletonESPLabel = Instance.new("TextLabel")
SkeletonESPLabel.Text = "ESP ESQUELETO 🦴"
SkeletonESPLabel.Size = UDim2.new(1, 0, 0, 20)
SkeletonESPLabel.Position = UDim2.new(0, 0, 0, 65)
SkeletonESPLabel.BackgroundTransparency = 1
SkeletonESPLabel.TextColor3 = Color3.new(1, 1, 1)
SkeletonESPLabel.TextSize = 12
SkeletonESPLabel.Parent = ESPContent

local SkeletonESPToggle = Instance.new("TextButton")
SkeletonESPToggle.Text = "Ativar"
SkeletonESPToggle.Size = UDim2.new(0.4, 0, 0, 20)
SkeletonESPToggle.Position = UDim2.new(0.3, 0, 0, 90)
SkeletonESPToggle.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
SkeletonESPToggle.TextColor3 = Color3.new(1, 1, 1)
SkeletonESPToggle.Parent = ESPContent

-- ESP Box
local BoxESPLabel = Instance.new("TextLabel")
BoxESPLabel.Text = "ESP BOX"
BoxESPLabel.Size = UDim2.new(1, 0, 0, 20)
BoxESPLabel.Position = UDim2.new(0, 0, 0, 120)
BoxESPLabel.BackgroundTransparency = 1
BoxESPLabel.TextColor3 = Color3.new(1, 1, 1)
BoxESPLabel.TextSize = 12
BoxESPLabel.Parent = ESPContent

local BoxESPToggle = Instance.new("TextButton")
BoxESPToggle.Text = "Ativar"
BoxESPToggle.Size = UDim2.new(0.4, 0, 0, 20)
BoxESPToggle.Position = UDim2.new(0.3, 0, 0, 145)
BoxESPToggle.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
BoxESPToggle.TextColor3 = Color3.new(1, 1, 1)
BoxESPToggle.Parent = ESPContent

-- Conteúdo da Tab AIMBOT
local AimbotContent = Instance.new("Frame")
AimbotContent.Name = "AimbotContent"
AimbotContent.Size = UDim2.new(1, 0, 0, 120)
AimbotContent.Position = UDim2.new(0, 0, 0, 0)
AimbotContent.BackgroundTransparency = 1
AimbotContent.Visible = false
AimbotContent.Parent = ContentArea

-- Aimbot Players
local AimbotLabel = Instance.new("TextLabel")
AimbotLabel.Text = "AIMBOT PLAYERS"
AimbotLabel.Size = UDim2.new(1, 0, 0, 20)
AimbotLabel.Position = UDim2.new(0, 0, 0, 10)
AimbotLabel.BackgroundTransparency = 1
AimbotLabel.TextColor3 = Color3.new(1, 1, 1)
AimbotLabel.TextSize = 12
AimbotLabel.Parent = AimbotContent

local AimbotToggle = Instance.new("TextButton")
AimbotToggle.Text = "Ativar"
AimbotToggle.Size = UDim2.new(0.4, 0, 0, 20)
AimbotToggle.Position = UDim2.new(0.3, 0, 0, 35)
AimbotToggle.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
AimbotToggle.TextColor3 = Color3.new(1, 1, 1)
AimbotToggle.Parent = AimbotContent

local ModeLabel = Instance.new("TextLabel")
ModeLabel.Text = "Modo: "..aimbotMode
ModeLabel.Size = UDim2.new(1, 0, 0, 20)
ModeLabel.Position = UDim2.new(0, 0, 0, 65)
ModeLabel.BackgroundTransparency = 1
ModeLabel.TextColor3 = Color3.new(1, 1, 1)
ModeLabel.TextSize = 12
ModeLabel.Parent = AimbotContent

local ModeSwitch = Instance.new("TextButton")
