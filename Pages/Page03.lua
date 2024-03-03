local composer = require("composer")
local scene = composer.newScene()

-- Definindo largura e altura específicas
local largura, altura = 768, 1024
-- Definindo altura da metade da tela
local metade_altura = altura / 2

local touch1_startX, touch1_startY, touch2_startX, touch2_startY -- Variáveis para armazenar as posições iniciais dos dedos
local shovel -- Referência para a pá (retângulo)

-- Activate multitouch
system.activate( "multitouch" )

local function criarChao(sceneGroup)
    chao = display.newRect(sceneGroup, 0, altura - 90, largura + 800, 180)
    chao:setFillColor(0.64, 0.16, 0.16) -- Defina a cor alpha para 0 para tornar a base invisível
    chao.userData = {name = "chao"}
    physics.addBody(chao, "static") -- Definindo a base como um corpo estático
end

local function calculateAngle(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    local angle = math.atan2(dy, dx) * 180 / math.pi
    return angle
end

local shovel -- Agora a pá é uma variável global para que possa ser acessada em diferentes partes do código

local function onTouchCavarChao(event)
    if event.numTouches == 2 then
        if event.phase == "began" then
            -- Initialize touch positions
            touch1_startX, touch1_startY = event.xStart, event.yStart
            touch2_startX, touch2_startY = event.xStart2, event.yStart2
            
            -- Create shovel at the average position of the touches
            local shovelX = (event.xStart + event.xStart2) / 2
            local shovelY = (event.yStart + event.yStart2) / 2
            shovel = display.newRect(shovelX, shovelY, 30, 100)
            shovel:setFillColor(0.8, 0.8, 0.8)
            shovel.anchorY = 0.5
            scene.view:insert(shovel) -- Insert shovel into the scene's view
            
            -- Set focus on shovel to handle multitouch
            display.getCurrentStage():setFocus(shovel, event.id)
            shovel.isFocus = true
        elseif event.phase == "moved" and shovel then -- Check if shovel exists
            -- Calculate angle between touches
            local angle = calculateAngle(event.x, event.y, event.x2, event.y2)

            -- Move shovel based on the average movement of the touches
            local shovelX = (event.x + event.x2) / 2
            local shovelY = (event.y + event.y2) / 2
            shovel.x, shovel.y = shovelX, shovelY
            
            -- Adjust shovel size and rotation based on the touches
            shovel.height = math.max(30, math.abs(event.y2 - event.y), math.abs(event.yStart2 - touch2_startY))
            shovel:setRotation(angle)
        elseif event.phase == "ended" or event.phase == "cancelled" then
            -- Release focus on shovel
            display.getCurrentStage():setFocus(shovel, nil)
            shovel.isFocus = false
            -- Remove shovel from the scene
            shovel:removeSelf()
            shovel = nil
        end
    end
    return true
end

-- Adicione o event listener de toque para detectar o movimento de cavar
Runtime:addEventListener("touch", onTouchCavarChao)



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
        text = "Page 03",
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
    criarChao(sceneGroup)

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
            composer.gotoScene("Pages.Page04", {effect = "slideLeft", time = 500})
        end
    end)
    adicionarTextoBotaoProximaPagina(sceneGroup)

    local buttonPaginaAnterior = display.newImageRect(sceneGroup, "image/Buttons/pagina_anterior.png", buttonSize, buttonSize)
    buttonPaginaAnterior.x = largura - buttonSize * 1.5 - 580
    buttonPaginaAnterior.y = altura - buttonSize / 2 - 30
    buttonPaginaAnterior:addEventListener("touch", function (event)
        if event.phase == "ended" then
            composer.gotoScene("Pages.Page02", {effect = "slideRight", time = 500})
        end
    end)
    adicionarTextoBotaoPaginaAnterior(sceneGroup)
end 
  
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
  
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
  
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
