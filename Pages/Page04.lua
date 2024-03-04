local composer = require("composer")
local scene = composer.newScene()

-- Definindo largura e altura específicas
local largura, altura = 768, 1024
-- Definindo altura da metade da tela
local metade_altura = altura / 2

local largura_grama = largura + 800
local largura_minima_grama = 100 -- Largura mínima que a grama pode ter


local arado_leve
local grama
local boi
local joint

local physics = require("physics")

local function criarChao(sceneGroup)
    -- Crie um retângulo para representar o chão
    local chao = display.newRect(sceneGroup, 0, altura - 90, largura + 800, 180)
    chao:setFillColor(0.64, 0.16, 0.16)
    chao.userData = { name = "chao" }

    -- Adicione um corpo físico ao chão e torne-o estático para que os objetos não possam movê-lo
    physics.addBody(chao, "static")

    -- -- Adiciona um ouvinte de colisão ao chão
    -- chao:addEventListener("collision", chaoCollision)
end

local function criarGrama(sceneGroup)
    -- Crie um retângulo para representar o chão
    grama = display.newRect(sceneGroup, 0, altura - 200, largura_grama, 40)
    grama:setFillColor(0.2, 0.7, 0.2)
    grama.userData = { name = "grama" }

    sceneGroup:insert(grama)

    -- Adicione um corpo físico ao chão e torne-o estático para que os objetos não possam movê-lo
    physics.addBody(grama, "static")
end

local function onTouchArado(event)
    local arado = event.target
    local halfWidth = arado.width / 2

    if event.phase == "began" then
        display.getCurrentStage():setFocus(arado)
        arado.touchOffsetX = event.x - arado.x
        arado.touchOffsetY = event.y - arado.y
    elseif event.phase == "moved" then
        -- Calcula a nova posição do arado
        local newX = event.x - arado.touchOffsetX
        local newY = event.y - arado.touchOffsetY

        -- Verifica se o novo X está dentro dos limites da tela
        if newX - halfWidth >= 0 and newX + halfWidth <= largura then
            arado.x = newX
        end

        -- Verifica se o novo Y está dentro dos limites da tela
        if newY - halfWidth >= 0 and newY + halfWidth <= altura then
            arado.y = newY
        end
    elseif event.phase == "ended" or event.phase == "cancelled" then
        display.getCurrentStage():setFocus(nil)
    end

    return true
end

local function criarArado_leve(sceneGroup)
    arado_leve = display.newImageRect(sceneGroup, "image/Page04/arado_leve.png", largura * 0.3, altura * 0.2)
    arado_leve.x = largura * 0.5 + 200
    arado_leve.y = altura - 140 - arado_leve.height * 0.4
    physics.addBody(arado_leve, "dynamic")
    arado_leve:addEventListener("touch", onTouchArado)
end

local function cortarGrama()

    local arado_center_x = arado_leve.x
    local grama_left = grama.x - grama.width / 2
    local grama_right = grama.x + grama.width / 2
        
    if arado_center_x > grama_left and arado_center_x < grama_right then
        local delta_x = event.x - event.xStart -- calcula o deslocamento horizontal
        local velocidade_corte = 0.09 -- ajuste a velocidade de corte conforme necessário
            
        largura_grama = largura_grama - (delta_x * velocidade_corte) -- reduz a largura da grama com base no movimento horizontal
        grama.width = largura_grama
        grama.x = grama.x + (delta_x * velocidade_corte) -- ajusta a posição da grama para mantê-la centrada em relação ao arado
        print("Cortando a grama...", largura_grama)
    end
end

local function verificarProximidade()
    print("Chamou a função Verificar Aproximidade...")
    
    local distanciaLimite = 300

    local distanciaX = math.abs(boi.x - arado_leve.x)
    local distanciaY = math.abs(boi.y - arado_leve.y)

    print("Distância boi:", boi.x)
    print("Distância arado:", arado_leve.x)
    print("DistanciaX ", distanciaX)

    local proximidade = distanciaX < distanciaLimite

    if proximidade and not joint then
        -- Criar uma junta entre os objetos apenas se não houver uma já criada
        joint = physics.newJoint("weld", boi, arado_leve, boi.x, arado_leve.y)
    elseif not proximidade and joint then
        -- Remover a junta se não houver mais proximidade
        joint:removeSelf()
        joint = nil
    end

    print("Proximidade:", proximidade)
    return proximidade
end

local function moverBoi(event)
    local velocidade = 50
    
    if boi.isMovingLeft then
        boi:setLinearVelocity(-velocidade, 0) -- Altere as coordenadas de velocidade conforme necessário
    elseif boi.isMovingRight then
        boi:setLinearVelocity(velocidade, 0) -- Define a velocidade como zero quando não estiver tocando no boi
    else
        boi:setLinearVelocity(0, 0)
    end
end

local function onTouchBoi(event)
    local boi = event.target

    if event.phase == "began" then
        boi.isMovingLeft = false
        boi.isMovingRight = false

        print("Chamou onTouchBoi...")

        -- Determina se o toque está a esquerda ou a direita do boi
        local touchX = event.x
        local boiCenterX = boi.x
        if touchX < boiCenterX then
            boi.isMovingLeft = true
            verificarProximidade()
        else
            boi.isMovingRight = true
            local proximidade = verificarProximidade()
            if proximidade then
                cortarGrama()
            end
        end
        print("isMovingLeft ", boi.isMovingLeft)
        print("isMovingRight ", boi.isMovingRight)
    elseif event.phase == "ended" or event.phase == "cancelled" then
        boi.isMovingLeft = false
        boi.isMovingRight = false
    end
    return true
end

-- local function moverBoiParaArado()
--     local distanciaLimite = 100
    
--     -- Verifica se o boi está próximo o suficiente do arado
--     if verificarProximidade() then
--         -- Calcula a nova posição do arado
--         local novaPosicaoX = boi.x
--         local novaPosicaoY = boi.y
        
--         -- Verifica se a nova posição está dentro dos limites da tela
--         if novaPosicaoX - arado_leve.width / 2 >= 0 and novaPosicaoX + arado_leve.width / 2 <= largura then
--             arado_leve.x = novaPosicaoX
--         end
--         if novaPosicaoY - arado_leve.height / 2 >= 0 and novaPosicaoY + arado_leve.height / 2 <= altura then
--             arado_leve.y = novaPosicaoY
--         end
--     end
-- end

local function criarBoi(sceneGroup)
    boi = display.newImageRect(sceneGroup, "image/Page04/boi.png", largura * 0.3, altura * 0.2)
    boi.x = largura * 0.5 - 200
    boi.y = altura - 140 - arado_leve.height * 0.4
    physics.addBody(boi, "dynamic")
    sceneGroup:insert(boi)
    
    boi:addEventListener("touch", onTouchBoi)
    Runtime:addEventListener("enterFrame", moverBoi)
end

local function onTouch(event)
    local buttonSize = largura * 0.09
    if event.phase == "ended" then
        if isAudioPlaying then
            isAudioPlaying = false
            buttonPlay:removeSelf()  -- Remove o botão atual
            buttonPlay = display.newImageRect(scene.view, "image/Fone/no_audio.png", buttonSize * 0.8, buttonSize * 0.8)
            audio.stop()
        else
            isAudioPlaying = true
            buttonPlay:removeSelf()  -- Remove o botão atual
            buttonPlay = display.newImageRect(scene.view, "image/Fone/audio.png", buttonSize, buttonSize)
            sound = audio.loadSound("audio/Page01/audioPage01.mp3")
            audio.play(sound, {loops = -1})
        end
        buttonPlay.x = largura / 2
        buttonPlay.y = altura * 0.195 + 750
        buttonPlay:addEventListener("touch", onTouch)
    end
end

local function createTitulo(sceneGroup)
    local titulo = display.newText({
        text = "Page 04",
        font = native.newFont("Bold"),
        fontSize = largura * 0.1  -- Usar uma porcentagem da largura da tela para o tamanho da fonte
    })
    titulo.x = largura * 0.5
    titulo.y = altura * 0.3
    titulo:setFillColor(1, 1, 1)
    sceneGroup:insert(titulo)
end

local function createSubTitulo(sceneGroup)
    local subtitulo = display.newText({
        text = "Autor: Charles Vilela de Souza \n Ano: 2024",
        font = native.newFont("Bold"),
        fontSize = largura * 0.05  -- Usar uma porcentagem da largura da tela para o tamanho da fonte
    })
    subtitulo.x = largura * 0.5
    subtitulo.y = altura * 0.45
    subtitulo:setFillColor(1, 1, 1)
    sceneGroup:insert(subtitulo)
end

local function adicionarTextoBotaoAudio(sceneGroup)
    local textoBotaoAudio = display.newText({
        text = "Audio Ligar/Desligar",
        font = native.newFont("Bold"),
        fontSize = 20
    })
    -- Ajuste a posição do titulo para a parte superior da tela
    textoBotaoAudio.x = largura / 2
    textoBotaoAudio.y = altura - textoBotaoAudio.height / 2 - 10
    -- Define a cor do titulo
    textoBotaoAudio:setFillColor(1, 1, 1)
    -- Insere o titulo no grupo da cena
    sceneGroup:insert(textoBotaoAudio)
end

local function adicionarTextoBotaoProximaPagina(sceneGroup)
    local textoBotaoProximaPagina = display.newText({
        text = "Próxima Página",
        font = native.newFont("Bold"),
        fontSize = 20
    })
    -- Ajuste a posição do titulo para a parte superior da tela
    textoBotaoProximaPagina.x = largura - largura * 0.11 / 2 - 130
    textoBotaoProximaPagina.y = altura - largura * 0.11 / 2 - 20
    -- Define a cor do titulo
    textoBotaoProximaPagina:setFillColor(1, 1, 1)
    -- Insere o titulo no grupo da cena
    sceneGroup:insert(textoBotaoProximaPagina)
end

local function adicionarTextoBotaoPaginaAnterior(sceneGroup)
    local textoBotaoPaginaAnterior = display.newText({
        text = "Página Anterior",
        font = native.newFont("Bold"),
        fontSize = 20
    })
    -- Ajuste a posição do titulo para a parte superior da tela
    textoBotaoPaginaAnterior.x = largura - largura * 0.11 / 2 - 540
    textoBotaoPaginaAnterior.y = altura - largura * 0.11 / 2 - 20
    -- Define a cor do titulo
    textoBotaoPaginaAnterior:setFillColor(1, 1, 1)
    -- Insere o titulo no grupo da cena
    sceneGroup:insert(textoBotaoPaginaAnterior)
end

-- create()
function scene:create( event )
    local sceneGroup = self.view
    -- Adicionar um retângulo azul para simular o céu
    local ceu = display.newRect(sceneGroup, 0, 0, largura, altura)
    ceu.anchorX = 0
    ceu.anchorY = 0
    ceu:setFillColor(0.53, 0.81, 0.98) -- Cor azul do céu

    createTitulo(sceneGroup)
    -- createSubTitulo(sceneGroup)

    physics.start()
    physics.setGravity(0, 9.8)

    criarChao(sceneGroup)
    criarGrama(sceneGroup)
    criarArado_leve(sceneGroup)
    criarBoi(sceneGroup)

    -- ADICIONANDO O BOTÃO DE AUDIO
    local buttonSize = largura * 0.09
    if isAudioPlaying then
        buttonPlay = display.newImageRect(sceneGroup, "image/Fone/audio.png", buttonSize, buttonSize)
    else
        buttonPlay = display.newImageRect(sceneGroup, "image/Fone/no_audio.png", buttonSize * 0.8, buttonSize * 0.8)
    end
    buttonPlay.x = largura / 2
    buttonPlay.y = altura * 0.195 + 750
    buttonPlay:addEventListener("touch", onTouch)
    adicionarTextoBotaoAudio(sceneGroup)

    -- Ajustando o tamanho dos botões de navegação
    local buttonSize = largura * 0.09
    local buttonProximaPagina = display.newImageRect(scene.view, "image/Buttons/proxima_pagina.png", buttonSize, buttonSize)
    buttonProximaPagina.x = largura - buttonSize / 2 - 40
    buttonProximaPagina.y = altura - buttonSize / 2 - 30
    buttonProximaPagina:addEventListener("touch", function (event)
        if event.phase == "ended" then
            composer.gotoScene("Pages.Page05", {effect = "slideLeft", time = 500})
        end
    end)
    adicionarTextoBotaoProximaPagina(sceneGroup)

    local buttonPaginaAnterior = display.newImageRect(sceneGroup, "image/Buttons/pagina_anterior.png", buttonSize, buttonSize)
    buttonPaginaAnterior.x = largura - buttonSize * 1.5 - 580
    buttonPaginaAnterior.y = altura - buttonSize / 2 - 30
    buttonPaginaAnterior:addEventListener("touch", function (event)
        if event.phase == "ended" then
            composer.gotoScene("Pages.Page03", {effect = "slideRight", time = 500})
        end
    end)
    adicionarTextoBotaoPaginaAnterior(sceneGroup)
end 
  
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
  
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        -- Verifica a proximidade entre o boi e o arado_leve
        -- Runtime:addEventListener("enterFrame", function()
        --     if verificarProximidade() then
        --         print("Boi chegou no arado...")
        --         -- moverBoiParaArado()
        --     end
        -- end)
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
    end
  end
  
  
  -- hide()
  function scene:hide( event )
  
    local sceneGroup = self.view
    local phase = event.phase
  
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
    end
  end
  
  
  -- destroy()
  function scene:destroy( event )
  
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
    sceneGroup:removeSelf()
    sceneGroup = nil
  
  end
  
  
  -- -----------------------------------------------------------------------------------
  -- Scene event function listeners
  -- -----------------------------------------------------------------------------------
  scene:addEventListener( "create", scene )
  scene:addEventListener( "show", scene )
  scene:addEventListener( "hide", scene )
  scene:addEventListener( "destroy", scene )

return scene
