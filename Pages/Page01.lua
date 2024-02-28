local composer = require("composer")
local scene = composer.newScene()

-- Definindo largura e altura específicas
local largura, altura = 768, 1024

-- Definindo tamanho da célula e velocidade com base na largura da tela
local tamanho_celula = largura * 0.026
local velocidade = largura * 0.0065

local nomades = {}
local recursos = {}
local num_recursos = 5
local direcao = "parado" -- Começa parado
local recursos_coletados = 0
local busca_iniciada = false
local isAudioPlaying = false
local buttonPlay

-- Definindo altura da metade da tela
local metade_altura = altura / 2

local function nomadeTouchHandler(event)
    local nomade = event.target
    if event.phase == "began" and not busca_iniciada then
        busca_iniciada = true

         -- Remover o balão se ele existir
        for i, nomade in ipairs(nomades) do
            if nomade.balao then
                nomade.balao:removeSelf()
                nomade.balao = nil
            end
        end
    end
end

local function criarNomades()
    for i = 1, 1 do
        local nomade = display.newImageRect("image/Page01/nomade.png", largura * 0.292, altura * 0.272) 
        nomade.x = math.random(tamanho_celula, largura - tamanho_celula)
        nomade.y = altura - altura * 0.136 -- Ajuste para a parte inferior da tela
        table.insert(nomades, nomade)

        -- Adicionar manipulador de eventos "touch" ao nomade
        nomade:addEventListener("touch", nomadeTouchHandler)

        -- Criar o balão
        local balao = display.newRoundedRect(nomade.x, nomade.y - altura * 0.136, largura * 0.26, altura * 0.078, altura * 0.039)
        balao:setFillColor(0.8,0.8,0.8)

        -- Texto do balão
        local textoBalao = display.newText({
            text = "Toque",
            x = balao.x,
            y = balao.y,
            font = native.newFont("Bold"),
            fontSize = altura * 0.045
        })

        -- Posicionar o texto no centro do balão
        textoBalao:setFillColor(0)

        -- Inserir o balão e o texto no grupo do nomade
        nomade.balao = display.newGroup()
        nomade.balao:insert(balao)
        nomade.balao:insert(textoBalao)

        -- Adicionar nomade.balao a cena
        scene.view:insert(nomade.balao)
    end
end


local function criarRecursos()
    -- Lista de caminhos das imagens dos recursos
    local imagens = {
        "image/Page01/mamute.png",
        "image/Page01/bisao.png",
        "image/Page01/antilope.png",
        "image/Page01/coelho.png",
        "image/Page01/trigo.png",
        "image/Page01/cevada.png",
        "image/Page01/frutas_vermelhas.png",
        "image/Page01/nozes.png"
        -- Adicione mais caminhos de imagem conforme necessário
    }

    for i = 1, num_recursos do
        local x, y
        local distancia_minima = largura * 0.13 -- Distância mínima entre recursos e nomades

        repeat
            x = math.random(tamanho_celula, largura - tamanho_celula)
            y = math.random(altura / 2 + altura * 0.195, altura - tamanho_celula - altura * 0.195)
            
            -- Verificar se a posição gerada está muito próxima de um nomade
            local muito_proximo = false
            for j, nomade in ipairs(nomades) do
                local distancia_x = math.abs(nomade.x - x)
                local distancia_y = math.abs(nomade.y - y)
                if distancia_x < distancia_minima and distancia_y < distancia_minima then
                    muito_proximo = true
                    break
                end
            end
        until not muito_proximo

        local imagemAleatoria = imagens[math.random(#imagens)]
        -- Carregar a imagem do recurso
        local recurso = display.newImageRect(imagemAleatoria, 100, 100)
        recurso.x = x
        recurso.y = y
        
        -- Adicionar o recurso à tabela de recursos
        table.insert(recursos, recurso)
    end
end

-- Função para verificar colisão e coletar recursos
local function colisaoComRecursos(nomade)
    local distancia_minima = tamanho_celula * 1.5 -- Distância mínima para considerar a coleta
    for i, recurso in ipairs(recursos) do
        local distancia_x = math.abs(nomade.x - recurso.x)
        local distancia_y = math.abs(nomade.y - recurso.y)
        if distancia_x <= distancia_minima and distancia_y <= distancia_minima then
            recurso:removeSelf()
            table.remove(recursos, i)
            recursos_coletados = recursos_coletados + 1 -- Atualiza contador de recursos coletados
            return true
        end
    end
end

-- Função para o laço do jogo
local function moverNomades()
    if not busca_iniciada then
        return -- Se a busca não foi iniciada, não faz nada
    end
    
    for i, nomade in ipairs(nomades) do
        local recurso_proximo
        local distancia_minima = tamanho_celula * 1.5 -- Distância mínima para considerar a coleta
        local menor_distancia = math.huge -- Inicializar com um valor muito grande
        for j, recurso in ipairs(recursos) do
            local distancia_x = math.abs(nomade.x - recurso.x)
            local distancia_y = math.abs(nomade.y - recurso.y)
            local distancia = math.sqrt(distancia_x * distancia_x + distancia_y * distancia_y)
            if distancia < menor_distancia then
                menor_distancia = distancia
                recurso_proximo = recurso
            end
        end
        
        if recurso_proximo then
            -- Move o nomade na direção do recurso mais próximo
            if nomade.x < recurso_proximo.x then
                nomade.x = nomade.x + velocidade
            elseif nomade.x > recurso_proximo.x then
                nomade.x = nomade.x - velocidade
            end
            if nomade.y < recurso_proximo.y then
                nomade.y = nomade.y + velocidade
            elseif nomade.y > recurso_proximo.y then
                nomade.y = nomade.y - velocidade
            end
            
            -- Verifica se o nomade alcançou o recurso mais próximo
            local distancia_x = math.abs(nomade.x - recurso_proximo.x)
            local distancia_y = math.abs(nomade.y - recurso_proximo.y)
            if distancia_x <= distancia_minima and distancia_y <= distancia_minima then
                colisaoComRecursos(nomade)
            end
        end
    end

    -- Verificar se todos os recursos foram coletados
    if recursos_coletados == num_recursos then
        print("Todos os recursos foram coletados!")
        -- Adicione qualquer outra ação que você queira executar quando todos os recursos forem coletados
        
    end
end

local function toqueListener(event)
    if event.phase == "began" and not busca_iniciada then
        busca_iniciada = true

         -- Remover o balão se ele existir
        for i, nomade in ipairs(nomades) do
            if nomade.balao then
                nomade.balao:removeSelf()
                nomade.balao = nil
            end
        end
    end
end

local function gameLoop(event)
    moverNomades()
end

-- Adicionando listeners
-- Runtime:addEventListener("touch", toqueListener)
Runtime:addEventListener("enterFrame", gameLoop)

local function createTitulo(sceneGroup)

    local titulo = display.newText({
        text = "Antes da agricultura",
        font = native.newFont("Bold"),
        fontSize = 60
    })
    -- Ajuste a posição do titulo para a parte superior da tela
    titulo.x = display.contentCenterX
    titulo.y = altura * 0.293 - 200
    -- Define a cor do titulo
    titulo:setFillColor(1, 1, 1)
    -- Insere o titulo no grupo da cena
    sceneGroup:insert(titulo)
end

local function criarTextoJustificado(sceneGroup, text, x, y, width, height, font, fontSize, lineHeight)
    local words = {}
    for word in text:gmatch("%S+") do
        table.insert(words, word)
    end

    local lines = {}
    local line = ""
    local lineWidth = 0
    local spaceWidth = fontSize * 0.3 -- Estimativa da largura do espaço entre palavras

    for i, word in ipairs(words) do
        local wordWidth = string.len(word) * (fontSize * 0.5) -- Estimativa da largura da palavra

        if lineWidth + wordWidth < width then
            line = line .. " " .. word
            lineWidth = lineWidth + wordWidth + spaceWidth
        else
            table.insert(lines, line)
            line = word
            lineWidth = wordWidth
        end
    end
    table.insert(lines, line)

    for i, line in ipairs(lines) do
        local texto = display.newText({
            text = line,
            x = x,
            y = y + (i - 1) * lineHeight,
            width = width,
            font = font,
            fontSize = fontSize,
            align = "justify"
        })
        texto:setFillColor(1, 1, 1)
        sceneGroup:insert(texto)
    end
end

-- Função para criar o texto
local function createTexto(sceneGroup)
    texto = "Nos primórdios, as pessoas eram predominantemente nômades. E a agricultura marcou o começo do sedentarismo humano, diretamente ligado às primeiras civilizações. Antes, para sobreviver, as pessoas se alimentavam caçando, coletando frutos e plantas."
    criarTextoJustificado(sceneGroup, texto, display.contentCenterX, 200, largura - 40, 500, native.newFont("Bold"), 30, 55)
end

-- Player no audio
local function onTouch(event)
    if event.phase == "ended" then
        if isAudioPlaying then
            isAudioPlaying = false
            buttonPlay:removeSelf()  -- Remove o botão atual
            buttonPlay = display.newImageRect(scene.view, "image/Fone/audio_desligado2.png", largura * 0.182, largura * 0.182)
            audio.stop()
        else
            isAudioPlaying = true
            buttonPlay:removeSelf()  -- Remove o botão atual
            buttonPlay = display.newImageRect(scene.view, "image/Fone/audio_ligado2.png", largura * 0.391, largura * 0.217)
            sound = audio.loadSound("audio/Page01/audioPage01.mp3")
            audio.play(sound, {loops = -1})
        end
        buttonPlay.x = largura / 2
        buttonPlay.y = altura * 0.195 + 750
        buttonPlay:addEventListener("touch", onTouch)
    end
end

-- Função para criar a cena
function scene:create(event)
    local sceneGroup = self.view

    local ceu = display.newRect(sceneGroup, 0, 0, largura, altura / 2 * 1.5)
    ceu.anchorX = 0
    ceu.anchorY = 0
    ceu:setFillColor(0.53, 0.81, 0.98) -- Cor azul do céu

    -- Adicionar a imagem de fundo na parte inferior da tela
    local background = display.newImageRect(sceneGroup, "image/Page01/background.png", largura, altura * 0.586)
    background.anchorX = 0
    background.anchorY = 1
    background.x = 0
    background.y = altura

    -- ADICIONANDO O BOTÃO DE AUDIO
    local buttonSize = largura * 0.15
    if isAudioPlaying then
        buttonPlay = display.newImageRect(sceneGroup, "image/Fone/audio_ligado2.png", buttonSize, buttonSize)
    else
        buttonPlay = display.newImageRect(sceneGroup, "image/Fone/audio_desligado2.png", buttonSize, buttonSize)
    end
    buttonPlay.x = largura / 2
    buttonPlay.y = altura * 0.195 + 750
    buttonPlay:addEventListener("touch", onTouch)

    createTitulo(sceneGroup)
    createTexto(sceneGroup)

    -- Ajustando o tamanho dos botões de navegação
    local buttonSize = largura * 0.15
    local buttonProximaPagina = display.newImageRect(scene.view, "image/Buttons/proxima_pagina.png", buttonSize, buttonSize)
    buttonProximaPagina.x = largura - buttonSize / 2 - 40
    buttonProximaPagina.y = altura - buttonSize / 2

    buttonProximaPagina:addEventListener("touch", function (event)
        if event.phase == "ended" then
            composer.gotoScene("Pages.Page02", {effect = "slideLeft", time = 500})
        end
    end)

    local buttonPaginaAnterior = display.newImageRect(sceneGroup, "image/Buttons/pagina_anterior.png", buttonSize, buttonSize)
    buttonPaginaAnterior.x = largura - buttonSize * 1.5 - 500
    buttonPaginaAnterior.y = altura - buttonSize / 2
    buttonPaginaAnterior:addEventListener("touch", function (event)
        if event.phase == "ended" then
            composer.gotoScene("Pages.Capa", {effect = "slideRight", time = 500})
        end
    end)


    criarNomades()
    criarRecursos()

    -- Garantir que os objetos do jogo são inseridos na cena
    for i, nomade in ipairs(nomades) do
        sceneGroup:insert(nomade)
    end
    for i, recurso in ipairs(recursos) do
        sceneGroup:insert(recurso)
    end
end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- O código para executar quando a cena está fora da tela
    elseif phase == "did" then
        -- O código para executar quando a cena está na tela
    end
end

function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- O código para executar quando a cena está prestes a sair da tela
    elseif phase == "did" then
        -- O código para executar imediatamente após a cena sair da tela
    end
end

function scene:destroy(event)
    local sceneGroup = self.view

    -- Limpar nomades
    for i = #nomades, 1, -1 do
        nomades[i]:removeSelf()
        nomades[i] = nil
    end

    -- Limpar recursos
    for i = #recursos, 1, -1 do
        recursos[i]:removeSelf()
        recursos[i] = nil
    end

    -- Limpar botão de áudio
    buttonPlay:removeEventListener("touch", onTouch)
    buttonPlay:removeSelf()
    buttonPlay = nil
end

-- Listeners de cena
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
