--[[ 
    WERBERT HUB V4 - CORRIGIDO
    Criador: @werbert_ofc
    Funcionalidades: Menu com Scroll, Auto Gun, Auto Farm, ESP Killer, X-Ray
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

local knownKiller = nil 
local originalTransparency = {}

-- Limpeza de UI Antiga
if getgenv().WerbertUI then getgenv().WerbertUI:Destroy() end

-- ==============================================================================
-- SISTEMA DE UI ROBUSTO (SEM ABAS BUGADAS)
-- ==============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WerbertScriptUI_V4"
-- Proteção básica de detecção e parenting
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

-- > MENU PRINCIPAL
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 320) -- Aumentei a altura
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Título
local TitleHeader = Instance.new("Frame")
TitleHeader.Size = UDim2.new(1, 0, 0, 40)
TitleHeader.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleHeader.BorderSizePixel = 0
TitleHeader.Parent = MainFrame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleHeader

-- Correção visual para o cabeçalho não ficar redondo embaixo
local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 10)
HeaderFix.Position = UDim2.new(0, 0, 1, -10)
HeaderFix.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = TitleHeader

local TitleText = Instance.new("TextLabel")
TitleText.Text = "WERBERT HUB V4"
TitleText.Size = UDim2.new(1, -50, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.TextColor3 = Color3.fromRGB(0, 255, 150)
TitleText.Font = Enum.Font.GothamBlack
TitleText.TextSize = 16
TitleText.XAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleHeader

-- Botões de Janela
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 35, 1, 0)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = TitleHeader
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local MiniBtn = Instance.new("TextButton")
MiniBtn.Text = "-"
MiniBtn.Size = UDim2.new(0, 35, 1, 0)
MiniBtn.Position = UDim2.new(1, -70, 0, 0)
MiniBtn.BackgroundTransparency = 1
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 100)
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextSize = 24
MiniBtn.Parent = TitleHeader

-- > CONTAINER DE SCROLL (ONDE FICAM OS BOTÕES)
local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Size = UDim2.new(1, -20, 1, -50)
ScrollContainer.Position = UDim2.new(0, 10, 0, 45)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.ScrollBarThickness = 4
ScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0) -- Ajuste automático
ScrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollContainer

-- > ÍCONE MINIMIZADO
local FloatIcon = Instance.new("TextButton")
FloatIcon.Size = UDim2.new(0, 45, 0, 45)
FloatIcon.Position = UDim2.new(0.1, 0, 0.3, 0)
FloatIcon.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
FloatIcon.Text = "W"
FloatIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatIcon.Font = Enum.Font.GothamBlack
FloatIcon.TextSize = 24
FloatIcon.Visible = false
FloatIcon.Parent = ScreenGui
local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatIcon

-- Lógica Minimizar/Maximizar
MiniBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatIcon.Visible = true
end)

FloatIcon.MouseButton1Click:Connect(function()
    FloatIcon.Visible = false
    MainFrame.Visible = true
end)

makeDraggable(MainFrame)
makeDraggable(FloatIcon)

-- > FUNÇÃO PARA CRIAR BOTÕES
local function createButton(text, description, callback)
    local btnFrame = Instance.new("Frame")
    btnFrame.Size = UDim2.new(1, -10, 0, 50)
    btnFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btnFrame.Parent = ScrollContainer
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btnFrame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = btnFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = text
    titleLabel.Size = UDim2.new(1, -50, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.XAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = btnFrame
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Text = description
    descLabel.Size = UDim2.new(1, -50, 0, 20)
    descLabel.Position = UDim2.new(0, 10, 0, 22)
    descLabel.BackgroundTransparency = 1
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 11
    descLabel.XAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = btnFrame
    
    local statusIndicator = Instance.new("Frame")
    statusIndicator.Size = UDim2.new(0, 10, 0, 10)
    statusIndicator.Position = UDim2.new(1, -20, 0.5, -5)
    statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- Vermelho (OFF)
    statusIndicator.Parent = btnFrame
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(1, 0)
    statusCorner.Parent = statusIndicator
    
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        callback(enabled)
        if enabled then
            statusIndicator.BackgroundColor3 = Color3.fromRGB(50, 255, 50) -- Verde (ON)
            titleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
        else
            statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- Vermelho (OFF)
            titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
end

-- ==============================================================================
-- CRIANDO OS BOTÕES NO MENU
-- ==============================================================================

createButton("AUTO GUN", "Teleporta para arma ao cair", function(state) 
    settings.autoGun = state 
end)

createButton("AUTO FARM MOEDAS", "Coleta moedas pelo mapa", function(state) 
    settings.autoFarm = state 
end)

createButton("ESP MASTER", "Wallhack + Nomes + Assassino", function(state) 
    settings.esp = state 
end)

createButton("X-RAY", "Deixa paredes invisíveis", function(state) 
    settings.xray = state
    if state then
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                if not originalTransparency[part] then originalTransparency[part] = part.Transparency end
                if part.Transparency < 0.5 and not part.Parent:FindFirstChild("Humanoid") then
                    part.Transparency = 0.6
                end
            end
        end
    else
        for part, trans in pairs(originalTransparency) do
            if part and part.Parent then part.Transparency = trans end
        end
        originalTransparency = {}
    end
end)

-- Créditos no final do scroll
local Credits = Instance.new("TextLabel")
Credits.Text = "Criado por @werbert_ofc"
Credits.Size = UDim2.new(1, 0, 0, 30)
Credits.BackgroundTransparency = 1
Credits.TextColor3 = Color3.fromRGB(100, 100, 100)
Credits.Font = Enum.Font.Gotham
Credits.TextSize = 12
Credits.Parent = ScrollContainer

-- ==============================================================================
-- LÓGICA DO JOGO
-- ==============================================================================

-- 1. DETECTOR DE ASSASSINO (POR MORTE)
local function detectKiller()
    local function onCharacterAdded(char)
        local humanoid = char:WaitForChild("Humanoid", 10)
        if humanoid then
            humanoid.Died:Connect(function()
                if not settings.esp then return end
                local deadPos = char.HumanoidRootPart.Position
                local closestPlayer = nil
                local shortestDistance = 25 

                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                        local dist = (p.Character.HumanoidRootPart.Position - deadPos).Magnitude
                        if dist < shortestDistance then
                            closestPlayer = p
                            shortestDistance = dist
                        end
                    end
                end
                if closestPlayer then 
                    knownKiller = closestPlayer 
                    game.StarterGui:SetCore("SendNotification", {Title="SUSPEITO DETECTADO"; Text=closestPlayer.Name; Duration=3;})
                end
            end)
        end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then onCharacterAdded(p.Character) end
        p.CharacterAdded:Connect(onCharacterAdded)
    end
    Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(onCharacterAdded) end)
end
detectKiller()

-- 2. LOOPS (AUTO GUN + FARM)
RunService.RenderStepped:Connect(function()
    -- Auto Gun
    if settings.autoGun then
        local targetFolder = nil
        for _, child in pairs(Workspace:GetChildren()) do
            if child.Name == "Entities" and not child:FindFirstChild("MapModel") then
                targetFolder = child
                break
            end
        end
        
        if targetFolder then
            local gun = targetFolder:FindFirstChild("DroppedGun")
            if gun and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = gun.CFrame
            end
        end
    end
    
    -- Auto Farm (Lento para evitar kick)
    if settings.autoFarm then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(Workspace:GetDescendants()) do
                if (v.Name == "Coin_Server" or v.Name == "Coin") and v:IsA("BasePart") and v.Transparency == 0 then
                    char.HumanoidRootPart.CFrame = v.CFrame
                    break -- Pega 1 por frame
                end
            end
        end
    end
end)

-- 3. ESP VISUAL
task.spawn(function()
    while true do
        if settings.esp then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                    local char = plr.Character
                    local roleColor = Color3.fromRGB(255, 255, 255)
                    local roleText = "Inocente"
                    
                    if plr == knownKiller then
                        roleColor = Color3.fromRGB(255, 0, 0)
                        roleText = "ASSASSINO (SUSPEITO)"
                    elseif char:FindFirstChild("Gun") or (plr:FindFirstChild("Backpack") and plr.Backpack:FindFirstChild("Gun")) then
                        roleColor = Color3.fromRGB(0, 0, 255)
                        roleText = "XERIFE"
                    elseif char:FindFirstChild("Knife") or (plr:FindFirstChild("Backpack") and plr.Backpack:FindFirstChild("Knife")) then
                         -- Caso raro de conseguir ver a faca
                        roleColor = Color3.fromRGB(255, 0, 0)
                        roleText = "ASSASSINO"
                        knownKiller = plr
                    end

                    -- Highlight
                    local hl = char:FindFirstChild("WerbertHighlight")
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "WerbertHighlight"
                        hl.FillTransparency = 0.5
                        hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = char
                    end
                    hl.FillColor = roleColor
                    hl.OutlineColor = roleColor
                    
                    -- Texto
                    local bg = char.Head:FindFirstChild("WerbertTag")
                    if not bg then
                        bg = Instance.new("BillboardGui")
                        bg.Name = "WerbertTag"
                        bg.Size = UDim2.new(0, 100, 0, 50)
                        bg.StudsOffset = Vector3.new(0, 2, 0)
                        bg.AlwaysOnTop = true
                        bg.Parent = char.Head
                        
                        local txt = Instance.new("TextLabel")
                        txt.Name = "Label"
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.TextStrokeTransparency = 0
                        txt.Font = Enum.Font.GothamBold
                        txt.TextSize = 14
                        txt.Parent = bg
                    end
                    bg.Label.Text = plr.Name .. "\n["..roleText.."]"
                    bg.Label.TextColor3 = roleColor
                end
            end
        else
            -- Limpar ESP se desligado
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

-- Limpar conhecido ao resetar mapa
Workspace.ChildAdded:Connect(function(child)
    if child.Name == "Map" then knownKiller = nil end
end)
