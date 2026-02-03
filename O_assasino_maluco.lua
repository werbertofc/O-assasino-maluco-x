--[[ 
    WERBERT HUB FINAL - VISUAL V1 + FUNÇÕES V5
    Criador: @werbert_ofc
    Funcionalidades: Auto Gun Inteligente, Auto Farm, ESP Killer, X-Ray
    Interface: Estilo Clássico (Compatível com Mobile)
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
    autoFarm = false,
    esp = false,
    xray = false
}

local knownKiller = nil
local originalTransparency = {}

-- Limpeza de UI Antiga
if getgenv().WerbertUI then getgenv().WerbertUI:Destroy() end

-- ==============================================================================
-- SISTEMA DE UI (BASEADO NO PRIMEIRO SCRIPT QUE FUNCIONOU)
-- ==============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WerbertHub_Final"
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
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    
    UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)
end

-- > FRAME PRINCIPAL (IGUAL AO PRIMEIRO)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 260) -- Aumentei um pouco a altura para caber os botões novos
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -130)
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
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
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
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

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

-- > BOTÃO FLUTUANTE (Minimizado)
local FloatIcon = Instance.new("TextButton")
FloatIcon.Size = UDim2.new(0, 40, 0, 40)
FloatIcon.Position = UDim2.new(0.1, 0, 0.1, 0)
FloatIcon.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
FloatIcon.Text = "W"
FloatIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatIcon.Font = Enum.Font.GothamBlack
FloatIcon.TextSize = 20
FloatIcon.Visible = false
FloatIcon.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
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

-- > FUNÇÃO CRIAR TOGGLE (A MESMA DO PRIMEIRO SCRIPT)
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

-- ==============================================================================
-- BOTÕES (MANUAIS, COMO NO PRIMEIRO SCRIPT)
-- ==============================================================================

createToggle("Auto Pegar Arma", 50, function(state) settings.autoGun = state end)
createToggle("Auto Farm Moedas", 95, function(state) settings.autoFarm = state end)
createToggle("ESP Master", 140, function(state) settings.esp = state end)
createToggle("X-Ray (Parede)", 185, function(state) 
    settings.xray = state
    -- Lógica X-Ray imediata
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

-- ==============================================================================
-- LÓGICA DO JOGO (INTELIGÊNCIA V5)
-- ==============================================================================

-- 1. DETECTOR DE ASSASSINO (Por Morte)
local function setupKillerDetection()
    local function monitor(player)
        player.CharacterAdded:Connect(function(char)
            local hum = char:WaitForChild("Humanoid", 10)
            if hum then
                hum.Died:Connect(function()
                    if not settings.esp then return end
                    local deadPos = char.HumanoidRootPart.Position
                    local suspect = nil
                    local minDist = 25 -- Distância suspeita
                    
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                            local dist = (p.Character.HumanoidRootPart.Position - deadPos).Magnitude
                            if dist < minDist then
                                minDist = dist
                                suspect = p
                            end
                        end
                    end
                    if suspect then 
                        knownKiller = suspect 
                        game.StarterGui:SetCore("SendNotification", {Title="SUSPEITO DETECTADO", Text=suspect.Name, Duration=4})
                    end
                end)
            end
        end)
    end
    for _, p in pairs(Players:GetPlayers()) do monitor(p) end
    Players.PlayerAdded:Connect(monitor)
end
setupKillerDetection()

-- 2. LOOPS (AUTO GUN + FARM)
RunService.RenderStepped:Connect(function()
    -- Auto Gun Inteligente
    if settings.autoGun then
        local folder = nil
        -- Procura a pasta Entities correta (a que não tem MapModel)
        for _, c in pairs(Workspace:GetChildren()) do
            if c.Name == "Entities" and not c:FindFirstChild("MapModel") then folder = c break end
        end
        
        if folder then
            local gun = folder:FindFirstChild("DroppedGun")
            if gun and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = gun.CFrame
            end
        end
    end
    
    -- Auto Farm Simples
    if settings.autoFarm then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(Workspace:GetDescendants()) do
                if (v.Name == "Coin_Server" or v.Name == "Coin") and v:IsA("BasePart") and v.Transparency == 0 then
                    char.HumanoidRootPart.CFrame = v.CFrame
                    break -- Pega 1 moeda por vez
                end
            end
        end
    end
end)

-- 3. ESP MASTER
task.spawn(function()
    while true do
        if settings.esp then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                    local char = plr.Character
                    local color = Color3.fromRGB(255,255,255)
                    local txt = "Inocente"
                    
                    if plr == knownKiller then
                        color = Color3.fromRGB(255,0,0)
                        txt = "ASSASSINO (SUSPEITO)"
                    elseif char:FindFirstChild("Gun") or (plr:FindFirstChild("Backpack") and plr.Backpack:FindFirstChild("Gun")) then
                        color = Color3.fromRGB(0,0,255)
                        txt = "XERIFE"
                    elseif char:FindFirstChild("Knife") then
                        color = Color3.fromRGB(255,0,0)
                        txt = "ASSASSINO"
                        knownKiller = plr
                    end
                    
                    -- Highlight
                    local hl = char:FindFirstChild("WerbertHighlight")
                    if not hl then 
                        hl = Instance.new("Highlight", char) 
                        hl.Name = "WerbertHighlight"
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    end
                    hl.FillColor = color
                    hl.OutlineColor = color
                    
                    -- Nome
                    local bg = char.Head:FindFirstChild("WerbertTag")
                    if not bg then
                        bg = Instance.new("BillboardGui", char.Head)
                        bg.Name = "WerbertTag"
                        bg.Size = UDim2.new(0,100,0,50)
                        bg.StudsOffset = Vector3.new(0,2,0)
                        bg.AlwaysOnTop = true
                        local lbl = Instance.new("TextLabel", bg)
                        lbl.Size = UDim2.new(1,0,1,0)
                        lbl.BackgroundTransparency = 1
                        lbl.Font = Enum.Font.GothamBold
                        lbl.TextSize = 14
                    end
                    bg.TextLabel.Text = plr.Name.."\n["..txt.."]"
                    bg.TextLabel.TextColor3 = color
                end
            end
        else
            -- Limpar quando desativar
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

-- Resetar ao mudar mapa
Workspace.ChildAdded:Connect(function(child)
    if child.Name == "Map" then knownKiller = nil end
end)

game.StarterGui:SetCore("SendNotification", {Title="Hub Final", Text="Carregado!", Duration=5})
