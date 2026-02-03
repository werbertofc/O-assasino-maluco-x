--[[ 
    SCRIPT PERSONALIZADO - CRIADOR: @werbert_ofc
    Funcionalidades: Auto Gun, ESP (Murderer/Sheriff), UI Minimizável Móvel
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Configurações Globais
local settings = {
    autoGun = false,
    esp = false
}

-- Limpeza de UI Antiga (para não duplicar se executar 2x)
if getgenv().WerbertUI then getgenv().WerbertUI:Destroy() end

-- ==============================================================================
-- SISTEMA DE UI (INTERFACE GRÁFICA)
-- ==============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WerbertScriptUI"
-- Tenta colocar no CoreGui para segurança, se não der, vai no PlayerGui
if pcall(function() ScreenGui.Parent = CoreGui end) then
    getgenv().WerbertUI = ScreenGui
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    getgenv().WerbertUI = ScreenGui
end

-- > FUNÇÃO DE ARRASTAR (Dragify)
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
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- > FRAME PRINCIPAL (Menu Aberto)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 200) -- Tamanho do menu
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- Bordas arredondadas
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Título / Créditos
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Criador: @werbert_ofc"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

-- Botão Fechar (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Botão Minimizar (-)
local MiniBtn = Instance.new("TextButton")
MiniBtn.Text = "-"
MiniBtn.Size = UDim2.new(0, 30, 0, 30)
MiniBtn.Position = UDim2.new(1, -60, 0, 0)
MiniBtn.BackgroundTransparency = 1
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 100)
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextSize = 24
MiniBtn.Parent = MainFrame

-- > BOTÃO FLUTUANTE (Minimizado 40x40)
local FloatIcon = Instance.new("TextButton")
FloatIcon.Size = UDim2.new(0, 40, 0, 40)
FloatIcon.Position = UDim2.new(0.1, 0, 0.1, 0)
FloatIcon.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
FloatIcon.Text = "W"
FloatIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatIcon.Font = Enum.Font.GothamBlack
FloatIcon.TextSize = 20
FloatIcon.Visible = false -- Começa invisível
FloatIcon.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0) -- Redondo
FloatCorner.Parent = FloatIcon

-- Lógica de Minimizar/Restaurar
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

-- > BOTÕES DE FUNÇÃO

-- Função Auxiliar para Criar Toggle
local function createToggle(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, 0, 0, 35)
    btn.Position = UDim2.new(0.1, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = MainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        callback(enabled)
        if enabled then
            btn.Text = text .. ": ON"
            btn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        else
            btn.Text = text .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end
    end)
end

-- Botão 1: Pegar Arma
createToggle("Auto Pegar Arma", 50, function(state)
    settings.autoGun = state
end)

-- Botão 2: ESP
createToggle("ESP (Ver Players)", 100, function(state)
    settings.esp = state
end)

-- ==============================================================================
-- LÓGICA DO SCRIPT
-- ==============================================================================

-- Função para achar a DroppedGun nas pastas Entities
local function findDroppedGun()
    -- Procura em todos os filhos do Workspace chamados "Entities"
    local possibleFolders = {}
    
    for _, child in pairs(Workspace:GetChildren()) do
        if child.Name == "Entities" then
            table.insert(possibleFolders, child)
        end
    end

    -- Procura a arma dentro dessas pastas encontradas
    for _, folder in pairs(possibleFolders) do
        local gun = folder:FindFirstChild("DroppedGun")
        if gun then return gun end
    end
    
    return nil
end

-- Loop de Teleporte (Auto Gun)
RunService.RenderStepped:Connect(function()
    if settings.autoGun then
        local gun = findDroppedGun()
        local character = LocalPlayer.Character
        
        if gun and character and character:FindFirstChild("HumanoidRootPart") then
            -- Teleporta para a arma
            character.HumanoidRootPart.CFrame = gun.CFrame
        end
    end
end)

-- Sistema de ESP
local function clearESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then
            local oldHighlight = plr.Character:FindFirstChild("WerbertHighlight")
            if oldHighlight then oldHighlight:Destroy() end
        end
    end
end

-- Loop de ESP (Atualiza a cada 1 segundo para performance)
task.spawn(function()
    while true do
        task.wait(0.5) -- Verifica a cada meio segundo
        if not settings.esp then
            clearESP()
        else
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local backpack = plr:FindFirstChild("Backpack")
                    local character = plr.Character
                    
                    -- Remove ESP antigo para atualizar status
                    local existing = character:FindFirstChild("WerbertHighlight")
                    if existing then existing:Destroy() end

                    local roleColor = nil
                    
                    if backpack then
                        if backpack:FindFirstChild("Knife") then
                            -- É o Assassino (Vermelho)
                            roleColor = Color3.fromRGB(255, 0, 0) 
                        elseif backpack:FindFirstChild("Gun") or character:FindFirstChild("Gun") then -- Verifica mão e mochila
                            -- É o Xerife (Azul)
                            roleColor = Color3.fromRGB(0, 0, 255)
                        end
                    end
                    
                    -- Se identificou um papel especial, aplica o Highlight
                    if roleColor then
                        local hl = Instance.new("Highlight")
                        hl.Name = "WerbertHighlight"
                        hl.FillColor = roleColor
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.5
                        hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Ver através das paredes
                        hl.Adornee = character
                        hl.Parent = character
                    end
                end
            end
        end
    end
end)

-- Notificação de carregamento
game.StarterGui:SetCore("SendNotification", {
    Title = "Script Carregado";
    Text = "Criado por @werbert_ofc";
    Duration = 5;
})

