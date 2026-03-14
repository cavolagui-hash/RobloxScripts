-- Configurações Globais
local ESP_CONFIG = {
    enabled = false,
    types = {
        box2D = true,
        line = true,
        name = true,
        health = true,
        cube3D = false
    },
    colors = {
        main = Color(0, 255, 255),    -- Ciano
        secondary = Color(255, 0, 255),-- Magenta
        cube3D = Color(255, 255, 0),  -- Amarelo
        health = Color(0, 255, 0)     -- Verde
    },
    panel = {
        x = ScrW() * 0.2,
        y = ScrH() * 0.2,
        w = ScrW() * 0.6,
        h = ScrH() * 0.6,
        draggable = true,
        visible = true
    },
    FOV = 50
}

-- Simulação de Oponentes (substitua por detecção real do jogo)
local opponents = {
    {id = 1, name = "INIMIGO 1", pos = Vector(100, 200, 0), size = Vector(32, 32, 72), health = 85},
    {id = 2, name = "INIMIGO 2", pos = Vector(-50, 150, 0), size = Vector(32, 32, 72), health = 42},
    {id = 3, name = "INIMIGO 3", pos = Vector(250, -100, 0), size = Vector(32, 32, 72), health = 100}
}

-- Inicialização Principal
hook.Add("Initialize", "CheatMenu_Init", function()
    createGlobalStyles()
    createMainPanel()
    startGameLoop()
end)

-- Criação de Estilos (Garry's Mod vgui exemplo)
function createGlobalStyles()
    -- Estilos para painel e componentes
    local skin = vgui.GetControlTable("DFrame").Skin
    skin.Colours.CheatMenu.Header = Color(30, 30, 30)
    skin.Colours.CheatMenu.Background = Color(20, 20, 20)
    skin.Colours.CheatMenu.TabActive = ESP_CONFIG.colors.main
    skin.Colours.CheatMenu.TabInactive = Color(150, 150, 150)
end

-- Criação do Painel Principal
function createMainPanel()
    local frame = vgui.Create("DFrame")
    frame:SetPos(ESP_CONFIG.panel.x, ESP_CONFIG.panel.y)
    frame:SetSize(ESP_CONFIG.panel.w, ESP_CONFIG.panel.h)
    frame:SetTitle("MENU ESP - OPONENTES")
    frame:SetDraggable(ESP_CONFIG.panel.draggable)
    frame:SetSizable(true)
    frame:ShowCloseButton(true)
    frame:SetVisible(ESP_CONFIG.panel.visible)

    -- Header com toggle RGB
    local header = vgui.Create("DPanel", frame)
    header:Dock(TOP)
    header:SetTall(40)
    header.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, ESP_CONFIG.colors.header or ESP_CONFIG.colors.main)
        draw.SimpleText("SISTEMA DE ESP - JOGO", "DermaLarge", 10, h/2, Color(0,0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local rgbToggle = vgui.Create("DButton", header)
    rgbToggle:Dock(RIGHT)
    rgbToggle:SetWide(100)
    rgbToggle:SetText("RGB: ATIVADO")
    rgbToggle.DoClick = function()
        ESP_CONFIG.colors.header = ESP_CONFIG.colors.header and nil or Color(math.random(0,255), math.random(0,255), math.random(0,255))
        rgbToggle:SetText(ESP_CONFIG.colors.header and "RGB: ALEATÓRIO" or "RGB: ATIVADO")
    end

    -- Tabs
    local tabs = vgui.Create("DPropertySheet", frame)
    tabs:Dock(FILL)

    -- Tab Aimbot
    local tabAimbot = vgui.Create("DPanel", tabs)
    tabAimbot.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, ESP_CONFIG.colors.Background) end
    
    local fovLabel = vgui.Create("DLabel", tabAimbot)
    fovLabel:SetPos(20, 20)
    fovLabel:SetText("FOV AIMBOT: " .. ESP_CONFIG.FOV .. "px")
    fovLabel:SetFont("DermaLarge")
    fovLabel:SizeToContents()

    local fovSlider = vgui.Create("DNumSlider", tabAimbot)
    fovSlider:SetPos(20, 60)
    fovSlider:SetSize(300, 30)
    fovSlider:SetMin(20)
    fovSlider:SetMax(150)
    fovSlider:SetValue(ESP_CONFIG.FOV)
    fovSlider:SetText("")
    fovSlider.OnValueChanged = function(self, val)
        ESP_CONFIG.FOV = math.Round(val)
        fovLabel:SetText("FOV AIMBOT: " .. ESP_CONFIG.FOV .. "px")
    end

    local fovCircle = vgui.Create("DPanel", tabAimbot)
    fovCircle:SetPos(20, 100)
    fovCircle:SetSize(100, 100)
    fovCircle.Paint = function(self, w, h)
        draw.NoTexture()
        surface.SetDrawColor(ESP_CONFIG.colors.main)
        surface.DrawCircle(w/2, h/2, ESP_CONFIG.FOV/2)
    end

    tabs:AddSheet("Aimbot", tabAimbot, "icon16/crosshair.png")

    -- Tab Visual (ESP Principal)
    local tabVisual = vgui.Create("DPanel", tabs)
    tabVisual.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, ESP_CONFIG.colors.Background) end

    -- Toggle Geral do ESP
    local espToggle = vgui.Create("DButton", tabVisual)
    espToggle:SetPos(20, 20)
    espToggle:SetSize(200, 40)
    espToggle:SetText(ESP_CONFIG.enabled and "ESP: ATIVADO" or "ESP: DESATIVADO")
    espToggle.DoClick = function()
        ESP_CONFIG.enabled = not ESP_CONFIG.enabled
        espToggle:SetText(ESP_CONFIG.enabled and "ESP: ATIVADO" or "ESP: DESATIVADO")
    end

    -- Seletor de Cores
    local colorLabel = vgui.Create("DLabel", tabVisual)
    colorLabel:SetPos(20, 80)
    colorLabel:SetText("COR PRINCIPAL ESP")
    colorLabel:SetFont("DermaLarge")
    colorLabel:SizeToContents()

    local colorPicker = vgui.Create("DColorMixer", tabVisual)
    colorPicker:SetPos(20, 110)
    colorPicker:SetSize(300, 200)
    colorPicker:SetColor(ESP_CONFIG.colors.main)
    colorPicker.ValueChanged = function(self, col)
        ESP_CONFIG.colors.main = col
    end

    -- Controles de Tipo de ESP
    local espTypesLabel = vgui.Create("DLabel", tabVisual)
    espTypesLabel:SetPos(350, 80)
    espTypesLabel:SetText("TIPOS DE ESP")
    espTypesLabel:SetFont("DermaLarge")
    espTypesLabel:SizeToContents()

    -- Toggle Box 2D
    local boxToggle = vgui.Create("DCheckBoxLabel", tabVisual)
    boxToggle:SetPos(350, 110)
    boxToggle:SetText("BOX 2D")
    boxToggle:SetValue(ESP_CONFIG.types.box2D and 1 or 0)
    boxToggle.OnChange = function(self, val)
        ESP_CONFIG.types.box2D = val
    end

    -- Toggle Linha Central
    local lineToggle = vgui.Create("DCheckBoxLabel", tabVisual)
    lineToggle:SetPos(350, 140)
    lineToggle:SetText("LINHA CENTRAL")
    lineToggle:SetValue(ESP_CONFIG.types.line and 1 or 0)
    lineToggle.OnChange = function(self, val)
        ESP_CONFIG.types.line = val
    end

    -- Toggle Nome
    local nameToggle = vgui.Create("DCheckBoxLabel", tabVisual)
    nameToggle:SetPos(350, 170)
    nameToggle:SetText("NOME DO INIMIGO")
    nameToggle:SetValue(ESP_CONFIG.types.name and 1 or 0)
    nameToggle.OnChange = function(self, val)
        ESP_CONFIG.types.name = val
    end

    -- Toggle Vida
    local healthToggle = vgui.Create("DCheckBoxLabel", tabVisual)
    healthToggle:SetPos(350, 200)
    healthToggle:SetText("BARRA DE VIDA")
    healthToggle:SetValue(ESP_CONFIG.types.health and 1 or 0)
    healthToggle.OnChange = function(self, val)
        ESP_CONFIG.types.health = val
    end

    -- Toggle Cubo 3D
    local cubeToggle = vgui.Create("DCheckBoxLabel", tabVisual)
    cubeToggle:SetPos(350, 230)
    cubeToggle:SetText("CUBO 3D")
    cubeToggle:SetValue(ESP_CONFIG.types.cube3D and 1 or 0)
    cubeToggle.OnChange = function(self, val)
        ESP_CONFIG.types.cube3D = val
    end

    -- Botão Ativar Todos
    local allToggle = vgui.Create("DButton", tabVisual)
    allToggle:SetPos(350, 270)
    allToggle:SetSize(150, 30)
    allToggle:SetText("ATIVAR TODOS")
    allToggle.DoClick = function()
        for k, _ in pairs(ESP_CONFIG.types) do
            ESP_CONFIG.types[k] = true
            local toggle = tabVisual:FindChildByName("DCheckBoxLabel_" .. k)
            if toggle then toggle:SetValue(1) end
        end
    end

    tabs:AddSheet("Visual (ESP)", tabVisual, "icon16/eye.png")

    -- Tab Configurações
    local tabConfig = vgui.Create("DPanel", tabs)
    tabConfig.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, ESP_CONFIG.colors.Background) end

    -- Botão Salvar Config
    local saveBtn = vgui.Create("DButton", tabConfig)
    saveBtn:SetPos(20, 20)
    saveBtn:SetSize(200, 40)
    saveBtn:SetText("SALVAR CONFIGURAÇÕES")
    saveBtn.DoClick = function()
        file.Write("esp_config.txt", util.TableToJSON(ESP_CONFIG))
        Derma_Message("Configurações salvas com sucesso!", "SUCESSO", "OK")
    end

    -- Botão Carregar Config
    local loadBtn = vgui.Create("DButton", tabConfig)
    loadBtn:SetPos(20, 70)
    loadBtn:SetSize(200, 40)
    loadBtn:SetText("CARREGAR CONFIGURAÇÕES")
    loadBtn.DoClick = function()
        if file.Exists("esp_config.txt", "DATA") then
            local data = file.Read("esp_config.txt", "DATA")
            ESP_CONFIG = util.JSONToTable(data)
            Derma_Message("Configurações carregadas com sucesso!", "SUCESSO", "OK")
            -- Atualizar componentes com novas configs
            espToggle:SetText(ESP_CONFIG.enabled and "ESP: ATIVADO" or "ESP: DESATIVADO")
            colorPicker:SetColor(ESP_CONFIG.colors.main)
            fovSlider:SetValue(ESP_CONFIG.FOV)
            fovLabel:SetText("FOV AIMBOT: " .. ESP_CONFIG.FOV .. "px")
        else
            Derma_Message("Nenhuma configuração salva encontrada!", "ERRO", "OK")
        end
    end

    tabs:AddSheet("Configurações", tabConfig, "icon16/save.png")
end

-- Loop de Renderização do ESP
function startGameLoop()
    hook.Add("PostDrawTranslucentRenderables", "ESP_Render", function()
        if not ESP_CONFIG.enabled then return end

        local localPlayer = LocalPlayer()
        if not IsValid(localPlayer) then return end

        for _, opp in pairs(opponents) do
            -- Converter posição 3D para tela 2D
            local screenPos = opp.pos:ToScreen()
            if not screenPos.visible then continue end

            -- Tamanho ajustado com base na distância
            local dist = localPlayer:GetPos():Distance(opp.pos)
            local size = math.Clamp(2000 / dist, 10, 100)
            local halfSize = size / 2

            -- Desenhar Box 2D
            if ESP_CONFIG.types.box2D then
                surface.SetDrawColor(ESP_CONFIG.colors.main)
                surface.DrawOutlinedRect(screenPos.x - halfSize, screenPos.y - size, size, size)
            end

            -- Desenhar Linha Central
            if ESP_CONFIG.types.line then
                surface.SetDrawColor(ESP_CONFIG.colors.secondary)
                surface.DrawLine(screenPos.x, ScrH()/2, screenPos.x, screenPos.y - size/2)
            end

            -- Desenhar Nome
            if ESP_CONFIG.types.name then
                draw.SimpleText(opp.name, "DermaLarge", screenPos.x, screenPos.y - size - 10, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            -- Desenhar Barra de Vida
            if ESP_CONFIG.types.health then
                local healthHeight = size * (opp.health / 100)
                surface.SetDrawColor(Color(50,50,50))
                surface.DrawRect(screenPos.x + halfSize + 5, screenPos.y - size, 5, size)
                surface.SetDrawColor(ESP_CONFIG.colors.health)
                surface.DrawRect(screenPos.x + halfSize + 5, screenPos.y - size + (size - healthHeight), 5, healthHeight)
            end

            -- Desenhar Cubo 3D
            if ESP_CONFIG.types.cube3D then
                render.SetColorMaterial()
                render.DrawWireframeBox(opp.pos, Angle(0, localPlayer:EyeAngles().y - 90, 0), -opp.size/2, opp.size/2, ESP_CONFIG.colors.cube3D)
            end
        end
    end)

    -- Atualizar posição dos oponentes (simulação de movimento)
    timer.Create("Opponent_Movement", 2, 0, function()
        for _, opp in pairs(opponents) do
            opp.pos = opp.pos + Vector(math.random(-5,5), math.random(-5,5), 0)
            opp.health = math.Clamp(opp.health + math.random(-2, 2), 0, 100)
        end
    end)
end

-- Função auxiliar para desenhar círculos (Garry's Mod)
function surface.DrawCircle(x, y, radius)
    local seg = radius * 0.1
    local cir = {}

    table.insert(cir, {x = x, y = y, u = 0.5, v = 0.5})
    for i = 0, seg do
        local a = math.rad((i / seg) * -360)
        table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a)/2 + 0.5, v = math.cos(a)/2 + 0.5})
    end

    surface.DrawPoly(cir)
end
