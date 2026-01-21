--print("Hello, World!")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local playersDataStore = DataStoreService:GetDataStore("PlayerDataStore")

-- ID da GamePass VIP
local VIPGamePassId = 845710045 -- Substitua pelo ID da sua GamePass

-- ID do dono do jogo
local donoDoJogo = game.CreatorId -- Obtém o ID do dono

game.Players.PlayerAdded:Connect(function(plr)
    -- Carregar dados do jogador
    local savedData
    local success, result = pcall(function()
        return playersDataStore:GetAsync(tostring(plr.UserId)) -- Carrega os dados salvos do jogador
    end)
    
    if success and result then
        savedData = result
    else
        savedData = {patente = "Civil", team = "N/A"} -- Definir dados padrão se falhar
    end
    
    -- Criando a pasta 'leaderstats' para armazenar a patente
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = plr
    
    -- Criando a variável de patente e carregando o valor salvo
    local patente = Instance.new("StringValue")
    patente.Name = "Patente"
    patente.Value = savedData.patente -- Carrega a patente salva ou a padrão
    patente.Parent = leaderstats
    
    -- Criando a variável de time e carregando o valor salvo
    local teamName = savedData.team
    local team = game.Teams:FindFirstChild(teamName) or game.Teams:FindFirstChild("N/A") -- Garante que o time existe
    plr.Team = team -- Atribui o time ao jogador
    
    -- Criando Overhead ao adicionar personagem
    plr.CharacterAdded:Connect(function(char)
        local head = char:FindFirstChild("Head")
        if not head then return end -- Prevenir erro se o personagem não tiver cabeça
            
            -- Criando a BillboardGui (Overhead)
            local billboardGui = Instance.new("BillboardGui")
            billboardGui.Parent = head
            billboardGui.Adornee = head
            billboardGui.Size = UDim2.new(0, 150, 0, 60)
            billboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
            billboardGui.MaxDistance = 14
            billboardGui.AlwaysOnTop = false
            
            -- Criando um Frame para organizar os textos
            local frame = Instance.new("Frame", billboardGui)
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundTransparency = 1
            
            -- Função para criar um TextLabel
            local function criarLabel(parent, text, size, position)
                local label = Instance.new("TextLabel")
                label.Parent = parent
                label.Size = size
                label.Position = position or UDim2.new(0, 0, 0, 0)
                label.BackgroundTransparency = 1
                label.Text = text
                label.TextStrokeTransparency = 0.7
                label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                label.TextSize = 16
                label.Font = Enum.Font.SpecialElite
                return label
            end
            
            -- Verificar se é dono ou VIP
            local isDono = plr.UserId == donoDoJogo
            local isVIP = false
            
            -- Verifica se o jogador tem a GamePass VIP
            local success, result = pcall(function()
                return MarketplaceService:UserOwnsGamePassAsync(plr.UserId, VIPGamePassId)
            end)
            if success and result then
                isVIP = true
            end
            
            -- Determinar o nome exibido
            local nomeExibido = plr.Name
            if isDono then
                nomeExibido = plr.Name .. " - [Larry👑] "
            elseif isVIP then
                nomeExibido = plr.Name .. " [VIP]"
            end
            
            -- Criando textos na Overhead
            local nomeText = criarLabel(frame, nomeExibido, UDim2.new(1, 0, 0.33, 0))
            local patenteText = criarLabel(frame, patente.Value, UDim2.new(1, 0, 0.33, 0), UDim2.new(0, 0, 0.33, 0))
            local timeText = criarLabel(frame, plr.Team and plr.Team.Name or "N/A", UDim2.new(1, 0, 0.33, 0), UDim2.new(0, 0, 0.66, 0))
            
            -- Atualiza a patente quando mudar
            patente:GetPropertyChangedSignal("Value"):Connect(function()
                patenteText.Text = patente.Value
            end)
            
            -- Função para efeito RGB
            local function aplicarEfeitoRGB(label)
                spawn(function()
                    while label.Parent do
                        for i = 0, 1, 0.01 do
                            label.TextColor3 = Color3.fromHSV(i, 1, 1)
                            wait(0.03)
                        end
                    end
                end)
            end
            
            -- Aplica RGB para Dono e VIP
            if isDono or isVIP then
                aplicarEfeitoRGB(nomeText)
                aplicarEfeitoRGB(patenteText)
                aplicarEfeitoRGB(timeText)
            else
                -- Atualiza a cor do time
                local function atualizarTime()
                    local teamColor = plr.Team and plr.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)
                    nomeText.TextColor3 = teamColor
                    patenteText.TextColor3 = teamColor
                    timeText.TextColor3 = teamColor
                    timeText.Text = plr.Team and plr.Team.Name or "N/A"
                end
                
                -- Atualizar ao mudar de time
                atualizarTime()
                plr:GetPropertyChangedSignal("Team"):Connect(atualizarTime)
            end
        end)
    end)
    
    game.Players.PlayerRemoving:Connect(function(plr)
        -- Salvar os dados do jogador ao sair
        local dadosParaSalvar = {
        patente = plr.leaderstats and plr.leaderstats.Patente.Value or "Civil",
        team = plr.Team and plr.Team.Name or "N/A"
        }
        
        local success, errorMessage = pcall(function()
            playersDataStore:SetAsync(tostring(plr.UserId), dadosParaSalvar)
        end)
        
        if not success then
            warn("Erro ao salvar dados para o jogador " .. plr.Name .. ": " .. errorMessage)
        end
    end)
