--[[ 
    WERBERT HUB V5 - VERSÃO CORRIGIDA (SEM SCROLL)
    Criador: @werbert_ofc
    Correção: Interface Simplificada para garantir renderização no Mobile
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ==============================================================================
-- CONFIGURAÇÕES
-- ==============================================================================
local settings = {
    autoGun = false,
    autoFarm = false,
    esp = false,
    xray = false
}

local knownKiller = nil 
local originalTransparency = {}

-- Limpa UI antiga
if getgenv().WerbertUI then getgenv().WerbertUI:Destroy() end

-- ==============================================================================
-- INTERFACE GRÁFICA (SIMPLIFICADA AO MÁXIMO)
-- ==============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WerbertScriptUI_V5"
-- Tenta colocar no CoreGui (mais seguro), se não der, vai no PlayerGui
if pcall(function() ScreenGui.Parent = CoreGui end) then
    getgenv().WerbertUI = ScreenGui
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    getgenv().WerbertUI = ScreenGui
end

-- > FUNÇÃO DE ARRASTAR (Mobile Friendly)
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

-- > FUNDO DO MENU
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 300) -- Tamanho fixo
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -150) -- Centralizado
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- TÍTULO (FIXO NO TOPO)
local Title = Instance.new("TextLabel")
Title.Text = "WERBERT HUB V5"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.Parent = MainFrame

-- BOTÃO FECHAR (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
CloseBtn.Font = Enum.Font.GothamBlack
CloseBtn.TextSize = 20
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- BOTÃO MINIMIZAR (-)
local MiniBtn = Instance.new("TextButton")
MiniBtn.Text = "_"
MiniBtn.Size = UDim2.new(0, 40, 0, 40)
MiniBtn.Position = UDim2.new(1, -80, 0, 0)
MiniBtn.BackgroundTransparency = 1
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniBtn.Font = Enum.Font.GothamBlack
MiniBtn.TextSize = 20
MiniBtn.Parent = MainFrame

-- > ÁREA DOS BOTÕES (CONTAINER FIXO)
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -20, 1, -50) -- Ocupa o resto do menu
Container.Position = UDim2.new(0, 10, 0, 50) -- Abaixo do título
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10) -- Espaço entre botões
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = Container

-- > ÍCONE MINIMIZADO (FLUTUANTE)
local FloatIcon = Instance.new("TextButton")
FloatIcon.Size = UDim2.new(0, 50, 0, 50)
FloatIcon.Position = UDim2.new(0.1, 0, 0.3, 0)
FloatIcon.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
FloatIcon.Text = "W"
FloatIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatIcon.Font = Enum.Font.GothamBlack
FloatIcon.TextSize = 24
FloatIcon.Visible = false
FloatIcon.Parent = ScreenGui
-- Borda arredondada no ícone (simples)
local FloatRound = Instance.new("UICorner")
FloatRound.CornerRadius = UDim.new(1,0) 
FloatRound.Parent = FloatIcon

-- Lógica Minimizar/Restaurar
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

-- > FUNÇÃO CRIAR BOTÃO SIMPLES
local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 45) -- Altura fixa
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45) -- Cinza escuro
    btn.Text = text .. " [OFF]"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = Container
    
    -- Bordinha arredondada
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        callback(enabled)
        if enabled then
            btn.Text = text .. " [ON]"
            btn.BackgroundColor3 = Color3.fromRGB(0, 200, 100) -- Verde
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.Text = text .. " [OFF]"
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45) -- Cinza
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end)
end

-- ==============================================================================
-- ADICIONANDO OS BOTÕES (AGORA ELES VÃO APARECER!)
-- ==============================================================================

createButton("AUTO GUN (Pegar Arma)", function(state) settings.autoGun = state end)
createButton("AUTO FARM (Moedas)", function(state) settings.autoFarm = state end)
createButton("ESP (Ver Pelas Paredes)", function(state) settings.esp = state end)
createButton("X-RAY (Paredes Invisíveis)", function(state) 
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

-- CRÉDITOS NO FINAL
local Cred = Instance.new("TextLabel")
Cred.Text = "Criado por @werbert_ofc"
Cred.Size = UDim2.new(1,0,0,20)
Cred.BackgroundTransparency = 1
Cred.TextColor3 = Color3.fromRGB(150,150,150)
Cred.Font = Enum.Font.Gotham
Cred.TextSize = 12
Cred.Parent = Container

-- ==============================================================================
-- LÓGICA DO SCRIPT (MANUTENÇÃO DAS FUNÇÕES)
-- ==============================================================================

-- 1. DETETOR DE ASSASSINO
local function setupKillerDetection()
    local function monitor(player)
        player.CharacterAdded:Connect(function(char)
            local hum = char:WaitForChild("Humanoid", 10)
            if hum then
                hum.Died:Connect(function()
                    if not settings.esp then return end
                    local deadPos = char.HumanoidRootPart.Position
                    local suspect = nil
                    local minDist = 25
                    
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
                        game.StarterGui:SetCore("SendNotification", {Title="SUSPEITO!", Text=suspect.Name, Duration=3})
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
    if settings.autoGun then
        local folder = nil
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
    
    if settings.autoFarm then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(Workspace:GetDescendants()) do
                if (v.Name == "Coin_Server" or v.Name == "Coin") and v:IsA("BasePart") and v.Transparency == 0 then
                    char.HumanoidRootPart.CFrame = v.CFrame
                    break
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
                    local color = Color3.fromRGB(255,255,255)
                    local txt = "Inocente"
                    
                    if plr == knownKiller then
                        color = Color3.fromRGB(255,0,0)
                        txt = "SUSPEITO"
                    elseif char:FindFirstChild("Gun") or (plr:FindFirstChild("Backpack") and plr.Backpack:FindFirstChild("Gun")) then
                        color = Color3.fromRGB(0,0,255)
                        txt = "XERIFE"
                    elseif char:FindFirstChild("Knife") then
                        color = Color3.fromRGB(255,0,0)
                        txt = "ASSASSINO"
                        knownKiller = plr
                    end
                    
                    local hl = char:FindFirstChild("WerbertHighlight")
                    if not hl then 
                        hl = Instance.new("Highlight", char) 
                        hl.Name = "WerbertHighlight"
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    end
                    hl.FillColor = color
                    hl.OutlineColor = color
                    
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
            -- Limpeza
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

game.StarterGui:SetCore("SendNotification", {Title="Hub V5 Ativado", Text="Menu Corrigido!", Duration=5})
