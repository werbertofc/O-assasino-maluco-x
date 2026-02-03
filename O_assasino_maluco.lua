--[[ 
    WERBERT HUB V7 - DETECÇÃO EXATA (PASTA CHARACTERS)
    Criador: @werbert_ofc
    Novidade: Busca a faca direto na pasta 'Characters' do Workspace
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
local knownSheriff = nil
local originalTransparency = {}

-- Limpa UI antiga
if getgenv().WerbertUI then getgenv().WerbertUI:Destroy() end

-- ==============================================================================
-- MENU VISUAL (ESTILO V1 - O QUE FUNCIONA)
-- ==============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WerbertHub_V7"
if pcall(function() ScreenGui.Parent = CoreGui end) then
    getgenv().WerbertUI = ScreenGui
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    getgenv().WerbertUI = ScreenGui
end

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

-- Frame Principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 280)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Criador: @werbert_ofc"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

-- Botões de Janela
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

local MiniBtn = Instance.new("TextButton")
MiniBtn.Text = "-"
MiniBtn.Size = UDim2.new(0, 30, 0, 30)
MiniBtn.Position = UDim2.new(1, -60, 0, 0)
MiniBtn.BackgroundTransparency = 1
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 100)
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextSize = 24
MiniBtn.Parent = MainFrame

-- Botão Minimizado
local FloatIcon = Instance.new("TextButton")
FloatIcon.Size = UDim2.new(0, 45, 0, 45)
FloatIcon.Position = UDim2.new(0.1, 0, 0.2, 0)
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

-- Criador de Botões
local function createToggle(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 40)
    btn.Position = UDim2.new(0.075, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

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
-- LÓGICA V7 - AGORA USANDO A PASTA "CHARACTERS"
-- ==============================================================================

-- Função auxiliar para encontrar o personagem correto na pasta Characters
local function getCharacterFromSpecialFolder(playerName)
    local charFolder = Workspace:FindFirstChild("Characters")
    if charFolder then
        return charFolder:FindFirstChild(playerName)
    end
    return nil -- Se não achar a pasta ou o player
end

-- 1. DETECTOR DE ASSASSINO (LÓGICA DA FACA NA MÃO)
task.spawn(function()
    while true do
        if settings.esp then
            local charFolder = Workspace:FindFirstChild("Characters")
            
            if charFolder then
                -- Varre todos os filhos da pasta Characters
                for _, char in pairs(charFolder:GetChildren()) do
                    local player = Players:FindFirstChild(char.Name)
                    
                    if player and player ~= LocalPlayer then
                        -- Verifica se tem a FACA equipada
                        if char:FindFirstChild("Knife") then
                            knownKiller = player
                            -- Notificação única (se ainda não sabia)
                            game.StarterGui:SetCore("SendNotification", {Title="ASSASSINO REVELADO"; Text=player.Name .. " puxou a faca!"; Duration=3;})
                        end

                        -- Verifica se tem a ARMA equipada
                        if char:FindFirstChild("Gun") or char:FindFirstChild("Revolver") then
                            knownSheriff = player
                        end
                    end
                end
            end
        end
        task.wait(0.2) -- Verifica 5 vezes por segundo (rápido!)
    end
end)

-- 2. AUTO FARM MOEDAS (ANTI-RUBBERBAND)
task.spawn(function()
    while true do
        if settings.autoFarm then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local foundCoin = false
                
                for _, v in pairs(Workspace:GetDescendants()) do
                    if (v.Name == "Coin_Server" or v.Name == "Coin") and v:IsA("BasePart") and v.Transparency == 0 then
                        hrp.CFrame = v.CFrame
                        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) -- FREIA O PERSONAGEM
                        foundCoin = true
                        break 
                    end
                end
                
                if foundCoin then
                    task.wait(0.15) -- Tempo pro servidor processar
                else
                    task.wait(0.5)
                end
            else
                task.wait(1)
            end
        else
            task.wait(0.5)
        end
    end
end)

-- 3. AUTO GUN (PASTA ENTITIES)
RunService.RenderStepped:Connect(function()
    if settings.autoGun then
        local targetFolder = nil
        for _, c in pairs(Workspace:GetChildren()) do
            if c.Name == "Entities" and not c:FindFirstChild("MapModel") then
                targetFolder = c
                break
            end
        end
        
        if targetFolder then
            local gun = targetFolder:FindFirstChild("DroppedGun")
            local char = LocalPlayer.Character
            if gun and char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = gun.CFrame
                char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,0,0) -- FREIA
            end
        end
    end
end)

-- 4. ESP VISUAL (USANDO A PASTA CHARACTERS PARA RENDERIZAR)
task.spawn(function()
    while true do
        if settings.esp then
            -- O ESP precisa desenhar no personagem VISUAL do jogo. 
            -- Se o jogo usa a pasta Characters para lógica, o modelo visual deve ser o mesmo.
            
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    -- Tenta pegar o char da pasta especial OU o padrão do Roblox
                    local char = getCharacterFromSpecialFolder(plr.Name) or plr.Character

                    if char and char:FindFirstChild("Head") then
                        local color = Color3.fromRGB(255, 255, 255)
                        local txt = "Inocente"
                        
                        -- Lógica de Cores
                        if plr == knownKiller then
                            color = Color3.fromRGB(255, 0, 0)
                            txt = "ASSASSINO"
                        elseif plr == knownSheriff then
                            color = Color3.fromRGB(0, 0, 255)
                            txt = "XERIFE"
                        elseif char:FindFirstChild("Knife") then
                             -- Redundância: se achar a faca agora, marca também
                            color = Color3.fromRGB(255, 0, 0)
                            txt = "ASSASSINO"
                            knownKiller = plr
                        elseif char:FindFirstChild("Gun") then
                            color = Color3.fromRGB(0, 0, 255)
                            txt = "XERIFE"
                            knownSheriff = plr
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
                        
                        -- Nome na cabeça
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
                            lbl.TextStrokeTransparency = 0
                        end
                        bg.TextLabel.Text = plr.Name.."\n["..txt.."]"
                        bg.TextLabel.TextColor3 = color
                    end
                end
            end
        else
            -- Limpeza
            for _, plr in pairs(Players:GetPlayers()) do
                local char = getCharacterFromSpecialFolder(plr.Name) or plr.Character
                if char then
                    if char:FindFirstChild("WerbertHighlight") then char.WerbertHighlight:Destroy() end
                    if char:FindFirstChild("Head") and char.Head:FindFirstChild("WerbertTag") then char.Head.WerbertTag:Destroy() end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- 5. X-RAY
local function toggleXray(state)
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
end

-- ==============================================================================
-- BOTÕES
-- ==============================================================================

createToggle("AUTO GUN (Pegar Arma)", 50, function(state) settings.autoGun = state end)
createToggle("AUTO FARM (Moedas)", 100, function(state) settings.autoFarm = state end)
createToggle("ESP (Wallhack)", 150, function(state) settings.esp = state end)
createToggle("X-RAY (Visão)", 200, function(state) settings.xray = state; toggleXray(state) end)

-- Resetar ao mudar mapa
Workspace.ChildAdded:Connect(function(child)
    if child.Name == "Map" then 
        knownKiller = nil
        knownSheriff = nil
    end
end)

game.StarterGui:SetCore("SendNotification", {Title="Hub V7 Carregado", Text="Busca na pasta CHARACTERS ativa!", Duration=5})
