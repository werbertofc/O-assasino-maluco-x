--[[ 
    WERBERT HUB V3 - MM2 EDITION
    Criador: @werbert_ofc
    Funcionalidades: Tabs, Auto Farm, Auto Gun, X-Ray, Detetor de Assassino (Lógica de Morte)
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ==============================================================================
-- CONFIGURAÇÕES E VARIÁVEIS
-- ==============================================================================
local settings = {
    autoGun = false,
    autoFarm = false,
    esp = false,
    xray = false
}

local knownKiller = nil -- Armazena quem é o assassino descoberto
local originalTransparency = {} -- Salva a transparência das paredes para o X-Ray

-- Limpeza de UI Antiga
if getgenv().WerbertUI then getgenv().WerbertUI:Destroy() end

-- ==============================================================================
-- SISTEMA DE UI (ABAS E MENU FLUTUANTE)
-- ==============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WerbertScriptUI_V3"
if pcall(function() ScreenGui.Parent = CoreGui end) then
    getgenv().WerbertUI = ScreenGui
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    getgenv().WerbertUI = ScreenGui
end

-- > FUNÇÃO DE ARRASTAR
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)
end

-- > FRAME PRINCIPAL
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 250)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Título
local Title = Instance.new("TextLabel")
Title.Text = "WERBERT HUB V3"
Title.Size = UDim2.new(1, -60, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.XAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Botões de Controle
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local MiniBtn = Instance.new("TextButton")
MiniBtn.Text = "-"
MiniBtn.Size = UDim2.new(0, 30, 0, 30)
MiniBtn.Position = UDim2.new(1, -60, 0, 0)
MiniBtn.BackgroundTransparency = 1
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 100)
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextSize = 24
MiniBtn.Parent = MainFrame

-- > SISTEMA DE ABAS (TABS)
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 30)
TabContainer.Position = UDim2.new(0, 0, 0, 35)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local PageContainer = Instance.new("Frame")
PageContainer.Size = UDim2.new(1, -20, 1, -75)
PageContainer.Position = UDim2.new(0, 10, 0, 70)
PageContainer.BackgroundTransparency = 1
PageContainer.Parent = MainFrame

local currentTab = nil

local function createTab(name, xPos)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Text = name
    tabBtn.Size = UDim2.new(0, 90, 1, 0)
    tabBtn.Position = UDim2.new(0, xPos, 0, 0)
    tabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    tabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 12
    tabBtn.Parent = TabContainer
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 2
    page.Visible = false
    page.Parent = PageContainer

    -- Layout da página
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = page

    tabBtn.MouseButton1Click:Connect(function()
        -- Reseta todas as abas
        for _, child in pairs(TabContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
                child.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
        end
        for _, child in pairs(PageContainer:GetChildren()) do
            child.Visible = false
        end
        -- Ativa a atual
        tabBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        page.Visible = true
    end)

    return page, tabBtn
end

local Page1, Tab1 = createTab("Principal", 5)
local Page2, Tab2 = createTab("Visual/Farm", 100)
local Page3, Tab3 = createTab("Sobre", 195)

-- Ativar primeira aba
Tab1.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
Tab1.TextColor3 = Color3.fromRGB(255, 255, 255)
Page1.Visible = true

-- > FUNÇÃO CRIAR TOGGLE (BOTÃO)
local function createToggle(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    btn.Text = text .. " [OFF]"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        callback(enabled)
        if enabled then
            btn.Text = text .. " [ON]"
            btn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.Text = text .. " [OFF]"
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end)
end

-- > ÍCONE MINIMIZADO
local FloatIcon = Instance.new("TextButton")
FloatIcon.Size = UDim2.new(0, 40, 0, 40)
FloatIcon.Position = UDim2.new(0.1, 0, 0.5, 0)
FloatIcon.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
FloatIcon.Text = "W"
FloatIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatIcon.Font = Enum.Font.GothamBlack
FloatIcon.TextSize = 20
FloatIcon.Visible = false
FloatIcon.Parent = ScreenGui
Instance.new("UICorner", FloatIcon).CornerRadius = UDim.new(1, 0)

MiniBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; FloatIcon.Visible = true end)
FloatIcon.MouseButton1Click:Connect(function() FloatIcon.Visible = false; MainFrame.Visible = true end)

makeDraggable(MainFrame)
makeDraggable(FloatIcon)

-- ==============================================================================
-- BOTÕES E FUNÇÕES
-- ==============================================================================

-- ABA 1: PRINCIPAL (Auto Gun e ESP)
createToggle(Page1, "AUTO GUN (Pegar Arma)", function(state) settings.autoGun = state end)
createToggle(Page1, "ESP (Nomes e Wallhack)", function(state) settings.esp = state end)

-- ABA 2: VISUAL E FARM
createToggle(Page2, "AUTO FARM MOEDAS", function(state) settings.autoFarm = state end)
createToggle(Page2, "X-RAY (Parede Invisível)", function(state) 
    settings.xray = state 
    -- Lógica do X-Ray
    if state then
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                -- Salva transparência original se ainda não salvou
                if not originalTransparency[part] then
                    originalTransparency[part] = part.Transparency
                end
                -- Deixa transparente se for parede opaca
                if part.Transparency < 0.5 and not part.Parent:FindFirstChild("Humanoid") then
                    part.Transparency = 0.6
                end
            end
        end
    else
        -- Restaura
        for part, trans in pairs(originalTransparency) do
            if part and part.Parent then
                part.Transparency = trans
            end
        end
        originalTransparency = {}
    end
end)

-- ABA 3: CRÉDITOS
local CreditLabel = Instance.new("TextLabel")
CreditLabel.Text = "Criado por: @werbert_ofc\n\nVersão: 3.0 (MM2)\nLua Otimizado"
CreditLabel.Size = UDim2.new(1, 0, 1, 0)
CreditLabel.BackgroundTransparency = 1
CreditLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
CreditLabel.Font = Enum.Font.Gotham
CreditLabel.TextSize = 14
CreditLabel.Parent = Page3

-- ==============================================================================
-- LÓGICA DO GAME
-- ==============================================================================

-- 1. DETETOR DE ASSASSINO (POR MORTE/PROXIMIDADE)
local function detectKiller()
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            local humanoid = character:WaitForChild("Humanoid")
            humanoid.Died:Connect(function()
                -- Alguém morreu!
                if not settings.esp then return end
                
                local deadPos = character.HumanoidRootPart.Position
                local closestPlayer = nil
                local shortestDistance = 20 -- Raio de busca (studs)

                -- Quem está perto do corpo?
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                        local dist = (p.Character.HumanoidRootPart.Position - deadPos).Magnitude
                        if dist < shortestDistance then
                            closestPlayer = p
                            shortestDistance = dist
                        end
                    end
                end

                if closestPlayer then
                    -- Achamos um suspeito muito provável!
                    knownKiller = closestPlayer
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "ASSASSINO DETECTADO!";
                        Text = "Suspeito: " .. closestPlayer.Name;
                        Duration = 5;
                    })
                end
            end)
        end)
    end)
    
    -- Ativa para players que já estão no jogo
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.Died:Connect(function()
                    if not settings.esp then return end
                    local deadPos = player.Character.HumanoidRootPart.Position
                    local closestPlayer = nil
                    local shortestDistance = 25 

                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= player and p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                            local dist = (p.Character.HumanoidRootPart.Position - deadPos).Magnitude
                            if dist < shortestDistance then
                                closestPlayer = p
                                shortestDistance = dist
                            end
                        end
                    end
                    if closestPlayer then knownKiller = closestPlayer end
                end)
            end
        end
    end
end
detectKiller()

-- 2. AUTO GUN (PASTAS ENTITIES)
local function getTargetEntityFolder()
    local entitiesFolders = {}
    for _, child in pairs(Workspace:GetChildren()) do
        if child.Name == "Entities" then table.insert(entitiesFolders, child) end
    end
    for _, folder in pairs(entitiesFolders) do
        if not folder:FindFirstChild("MapModel") then return folder end
    end
    return nil
end

-- 3. AUTO FARM MOEDAS (LOOP)
local function farmCoins()
    if not settings.autoFarm then return end
    
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    -- Busca moedas. No MM2 geralmente chamam Coin_Server ou estão no CoinContainer
    -- Vamos buscar genericamente por "Coin" no Workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        if settings.autoFarm and (obj.Name == "Coin_Server" or obj.Name == "Coin") and obj:IsA("BasePart") then
            if obj.Transparency == 0 then -- Só pega se estiver visível/ativa
                char.HumanoidRootPart.CFrame = obj.CFrame
                task.wait(0.2) -- Espera pegar
                return -- Pega uma por vez para não crashar
            end
        end
    end
end

-- 4. ATUALIZADOR PRINCIPAL (RenderStepped)
RunService.RenderStepped:Connect(function()
    -- Auto Gun
    if settings.autoGun then
        local targetFolder = getTargetEntityFolder()
        if targetFolder then
            local gun = targetFolder:FindFirstChild("DroppedGun")
            local char = LocalPlayer.Character
            if gun and char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = gun.CFrame
            end
        end
    end
    
    -- Auto Farm
    if settings.autoFarm then
        farmCoins()
    end
end)

-- 5. ESP LOOP
local function updateESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local char = plr.Character
            local roleColor = Color3.fromRGB(255, 255, 255) -- Inocente (Branco)
            local roleText = "Inocente"
            
            -- Detecta Arma (Xerife) - Isso geralmente funciona pois a arma é grande
            local hasGun = false
            if char:FindFirstChild("Gun") or (plr:FindFirstChild("Backpack") and plr.Backpack:FindFirstChild("Gun")) then
                hasGun = true
            end

            -- Lógica de Cores
            if plr == knownKiller then
                roleColor = Color3.fromRGB(255, 0, 0) -- VERMELHO (Detectado por morte)
                roleText = "ASSASSINO (Detectado)"
            elseif hasGun then
                roleColor = Color3.fromRGB(0, 0, 255) -- AZUL
                roleText = "XERIFE"
            elseif char:FindFirstChild("Knife") then
                -- Se por milagre a faca aparecer na mão
                roleColor = Color3.fromRGB(255, 0, 0)
                roleText = "ASSASSINO (Faca visível)"
                knownKiller = plr
            end

            -- Highlight
            if not char:FindFirstChild("WerbertHighlight") then
                local hl = Instance.new("Highlight")
                hl.Name = "WerbertHighlight"
                hl.FillTransparency = 0.5
                hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = char
            end
            
            local hl = char:FindFirstChild("WerbertHighlight")
            if hl then
                hl.FillColor = roleColor
                hl.OutlineColor = roleColor
            end

            -- Texto
            if char.Head:FindFirstChild("WerbertTag") then char.Head.WerbertTag:Destroy() end
            local bg = Instance.new("BillboardGui")
            bg.Name = "WerbertTag"
            bg.Adornee = char.Head
            bg.Size = UDim2.new(0, 100, 0, 50)
            bg.StudsOffset = Vector3.new(0, 2, 0)
            bg.AlwaysOnTop = true
            bg.Parent = char.Head
            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.Text = plr.Name .. "\n["..roleText.."]"
            txt.TextColor3 = roleColor
            txt.TextStrokeTransparency = 0
            txt.Font = Enum.Font.GothamBold
            txt.TextSize = 14
            txt.Parent = bg
        end
    end
end

-- Limpa ESP se desligado
task.spawn(function()
    while true do
        if settings.esp then
            pcall(updateESP)
        else
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character then
                    if plr.Character:FindFirstChild("WerbertHighlight") then plr.Character.WerbertHighlight:Destroy() end
                    if plr.Character:FindFirstChild("Head") and plr.Character.Head:FindFirstChild("WerbertTag") then plr.Character.Head.WerbertTag:Destroy() end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- Resetar Killer no final da rodada
Workspace.ChildRemoved:Connect(function(child)
    if child.Name == "Map" or child.Name == "Normal" then -- Geralmente o mapa reseta
        knownKiller = nil
    end
end)

game.StarterGui:SetCore("SendNotification", {
    Title = "Werbert Hub V3";
    Text = "Carregado com sucesso!";
    Duration = 5;
})
