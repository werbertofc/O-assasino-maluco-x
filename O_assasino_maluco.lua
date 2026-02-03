--[[ 
    SCRIPT ATUALIZADO V2 - CRIADOR: @werbert_ofc
    Funcionalidades: 
    - Auto Gun Inteligente (Filtro de Pasta Entities)
    - ESP Nome + Chams (Assassino Vermelho)
    - UI Mobile Otimizada
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

-- Limpeza de UI Antiga
if getgenv().WerbertUI then getgenv().WerbertUI:Destroy() end

-- ==============================================================================
-- SISTEMA DE UI (Mantido e Otimizado)
-- ==============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WerbertScriptUI_V2"
if pcall(function() ScreenGui.Parent = CoreGui end) then
    getgenv().WerbertUI = ScreenGui
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    getgenv().WerbertUI = ScreenGui
end

-- Função de Arrastar
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

-- UI Principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 220)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Criador: @werbert_ofc"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

-- Botões de Controle (Fechar/Minimizar)
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

-- Ícone Minimizado
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

-- Criador de Botões Toggle
local function createToggle(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 40)
    btn.Position = UDim2.new(0.075, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = text .. " [OFF]"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

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
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end)
end

createToggle("AUTO PEGAR ARMA (Rápido)", 50, function(state) settings.autoGun = state end)
createToggle("ESP (Nome + Papéis)", 100, function(state) settings.esp = state end)

-- ==============================================================================
-- LÓGICA ATUALIZADA - AUTO GUN (Filtro de Pastas)
-- ==============================================================================

local function getTargetEntityFolder()
    -- Procura todas as pastas chamadas "Entities"
    local entitiesFolders = {}
    for _, child in pairs(Workspace:GetChildren()) do
        if child.Name == "Entities" then
            table.insert(entitiesFolders, child)
        end
    end

    -- Filtra: Queremos a pasta que NÃO tem o MapModel dentro
    for _, folder in pairs(entitiesFolders) do
        if not folder:FindFirstChild("MapModel") then
            return folder -- Achamos a pasta correta (a que spawna a arma)
        end
    end
    return nil
end

-- Loop ultra-rápido (RenderStepped) para teleporte
RunService.RenderStepped:Connect(function()
    if settings.autoGun then
        local targetFolder = getTargetEntityFolder()
        
        if targetFolder then
            local gun = targetFolder:FindFirstChild("DroppedGun")
            local char = LocalPlayer.Character
            
            -- Só teleporta se a arma existir e o personagem estiver vivo
            if gun and char and char:FindFirstChild("HumanoidRootPart") then
                -- Teleporta direto para a CFrame da arma
                char.HumanoidRootPart.CFrame = gun.CFrame
                -- A lógica "até sumir" é natural: quando você pega, ela some (vira nil), 
                -- e o script para de entrar neste 'if gun'
            end
        end
    end
end)

-- ==============================================================================
-- LÓGICA ATUALIZADA - ESP (Nomes + Cores de Papel)
-- ==============================================================================

local function createBillboard(head, nameText, color)
    if head:FindFirstChild("WerbertTag") then head.WerbertTag:Destroy() end
    
    local bg = Instance.new("BillboardGui")
    bg.Name = "WerbertTag"
    bg.Adornee = head
    bg.Size = UDim2.new(0, 100, 0, 50)
    bg.StudsOffset = Vector3.new(0, 2, 0)
    bg.AlwaysOnTop = true
    bg.Parent = head

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = nameText
    txt.TextColor3 = color
    txt.TextStrokeTransparency = 0
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 14
    txt.Parent = bg
end

local function updateESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local char = plr.Character
            local backpack = plr:FindFirstChild("Backpack")
            
            -- Cores Padrão
            local roleColor = Color3.fromRGB(255, 255, 255) -- Inocente (Branco)
            local roleText = "Inocente"
            
            -- Verifica Assassino (Vermelho)
            local hasKnife = false
            if char:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife")) then
                hasKnife = true
            end
            
            -- Verifica Xerife (Azul)
            local hasGun = false
            if char:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun")) then
                hasGun = true
            end

            -- Define Prioridade de Cores
            if hasKnife then
                roleColor = Color3.fromRGB(255, 0, 0) -- VERMELHO
                roleText = "ASSASSINO"
            elseif hasGun then
                roleColor = Color3.fromRGB(0, 0, 255) -- AZUL
                roleText = "XERIFE"
            end

            -- 1. Cria o Highlight (Ver através da parede)
            if not char:FindFirstChild("WerbertHighlight") then
                local hl = Instance.new("Highlight")
                hl.Name = "WerbertHighlight"
                hl.FillTransparency = 0.5
                hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = char
            end
            
            -- Atualiza a cor do Highlight existente
            local hl = char:FindFirstChild("WerbertHighlight")
            if hl then
                hl.FillColor = roleColor
                hl.OutlineColor = roleColor
            end

            -- 2. Cria o Nome na Cabeça
            createBillboard(char.Head, plr.Name .. "\n["..roleText.."]", roleColor)
        end
    end
end

-- Remove ESP quando desativado
local function clearESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then
            if plr.Character:FindFirstChild("WerbertHighlight") then
                plr.Character.WerbertHighlight:Destroy()
            end
            if plr.Character:FindFirstChild("Head") and plr.Character.Head:FindFirstChild("WerbertTag") then
                plr.Character.Head.WerbertTag:Destroy()
            end
        end
    end
end

-- Loop do ESP
task.spawn(function()
    while true do
        if settings.esp then
            pcall(updateESP)
        else
            clearESP()
        end
        task.wait(0.2) -- Atualiza rápido para pegar mudanças de arma
    end
end)

game.StarterGui:SetCore("SendNotification", {
    Title = "Script V2 Atualizado";
    Text = "Feito por @werbert_ofc";
    Duration = 5;
})
