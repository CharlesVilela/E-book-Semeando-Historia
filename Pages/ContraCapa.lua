local composer = require("composer")
local scene = composer.newScene()

-- Definindo largura e altura específicas
local largura, altura = 768, 1024
-- Definindo altura da metade da tela
local metade_altura = altura / 2

local function stopAudio()
    isAudioPlaying = false
    buttonPlay = display.newImageRect(scene.view, "image/Fone/audio_desligado.png", 140, 140)
    audio.stop()
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
            sound = audio.loadSound("audio/ContraCapa/audioContraCapa.mp3")
            audio.play(sound, {loops = -1})
        end
        buttonPlay.x = largura / 2
        buttonPlay.y = altura * 0.195 + 750
        buttonPlay:addEventListener("touch", onTouch)
    end
end

local function createAutor(sceneGroup)
    local titulo = display.newText({
        text = "Autor: Charles Vilela de Souza \n E-mail: charles.vilela@upe.br",
        font = native.newFont("Bold"),
        fontSize = 40  -- Usar uma porcentagem da largura da tela para o tamanho da fonte
    })
    titulo.x = largura * 0.5
    titulo.y = altura * 0.40
    titulo:setFillColor(0.2 * (52/255), 0.2 * (131/255), 0.2 * (235/255))
    sceneGroup:insert(titulo)
end

local function createAno(sceneGroup)
    local titulo = display.newText({
        text = "Ano: 2024",
        font = native.newFont("Bold"),
        fontSize = 40
    })
    titulo.x = largura * 0.5
    titulo.y = altura * 0.30
    titulo:setFillColor(0.2 * (52/255), 0.2 * (131/255), 0.2 * (235/255))
    sceneGroup:insert(titulo)
end

local function createOrientador(sceneGroup)
    local titulo = display.newText({
        text = "Orientador: Ewerton Mendonça",
        font = native.newFont("Bold"),
        fontSize = 40
    })
    titulo.x = largura * 0.5
    titulo.y = altura * 0.50
    titulo:setFillColor(0.2 * (52/255), 0.2 * (131/255), 0.2 * (235/255))
    sceneGroup:insert(titulo)
end

local function createDisciplina(sceneGroup)
    local titulo = display.newText({
        text = "Disciplina: Computação Gráfica \n e Sistemas Multimidia",
        font = native.newFont("Bold"),
        fontSize = 40  -- Usar uma porcentagem da largura da tela para o tamanho da fonte
    })
    titulo.x = largura * 0.5
    titulo.y = altura * 0.20
    titulo:setFillColor(0.2 * (52/255), 0.2 * (131/255), 0.2 * (235/255))
    sceneGroup:insert(titulo)
end

local function createTitulo(sceneGroup)
    local titulo = display.newText({
        text = "Titulo: Semeando Historia",
        font = native.newFont("Bold"),
        fontSize = 40  -- Usar uma porcentagem da largura da tela para o tamanho da fonte
    })
    titulo.x = largura * 0.5
    titulo.y = altura * 0.1
    titulo:setFillColor(0.2 * (52/255), 0.2 * (131/255), 0.2 * (235/255))
    sceneGroup:insert(titulo)
end

local function adicionarTextoBotaoAudio(sceneGroup)
    local textoBotaoAudio = display.newText({
        text = "Audio Ligar/Desligar",
        font = native.newFont("Bold"),
        fontSize = 25
    })
    -- Ajuste a posição do titulo para a parte superior da tela
    textoBotaoAudio.x = largura / 2
    textoBotaoAudio.y = altura - textoBotaoAudio.height / 2 - 10
    -- Define a cor do titulo
    textoBotaoAudio:setFillColor(0.53, 0.81, 0.98)
    -- Insere o titulo no grupo da cena
    sceneGroup:insert(textoBotaoAudio)
end

local function adicionarTextoBotaoProximaPagina(sceneGroup)
    local textoBotaoProximaPagina = display.newText({
        text = "VOLTAR PARA O INICIO",
        font = native.newFont("Bold"),
        fontSize = 20
    })
    -- Ajuste a posição do titulo para a parte superior da tela
    textoBotaoProximaPagina.x = largura - largura * 0.11 / 2 - 170
    textoBotaoProximaPagina.y = altura - largura * 0.11 / 2 - 20
    -- Define a cor do titulo
    textoBotaoProximaPagina:setFillColor(0.53, 0.81, 0.98)
    -- Insere o titulo no grupo da cena
    sceneGroup:insert(textoBotaoProximaPagina)
end

local function adicionarTextoBotaoPaginaAnterior(sceneGroup)
    local textoBotaoPaginaAnterior = display.newText({
        text = "Página Anterior",
        font = native.newFont("Bold"),
        fontSize = 25
    })
    -- Ajuste a posição do titulo para a parte superior da tela
    textoBotaoPaginaAnterior.x = largura - largura * 0.11 / 2 - 520
    textoBotaoPaginaAnterior.y = altura - largura * 0.11 / 2 - 20
    -- Define a cor do titulo
    textoBotaoPaginaAnterior:setFillColor(0.53, 0.81, 0.98)
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

    -- ADICIONAR O BACKGROUND NA TELA. AREA DA PAISAGEM
    local background = display.newImageRect(sceneGroup, "image/Page01/background.png", largura, altura * 0.7)
    background.anchorX = 0
    background.anchorY = 1
    background.x = 0
    background.y = altura

    createTitulo(sceneGroup)
    createDisciplina(sceneGroup)
    createAno(sceneGroup)
    createAutor(sceneGroup)
    createOrientador(sceneGroup)

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
            stopAudio()
            composer.gotoScene("Pages.Capa", {effect = "slideLeft", time = 500})
        end
    end)
    adicionarTextoBotaoProximaPagina(sceneGroup)

    local buttonPaginaAnterior = display.newImageRect(sceneGroup, "image/Buttons/pagina_anterior.png", buttonSize, buttonSize)
    buttonPaginaAnterior.x = largura - buttonSize * 1.5 - 580
    buttonPaginaAnterior.y = altura - buttonSize / 2 - 30
    buttonPaginaAnterior:addEventListener("touch", function (event)
        if event.phase == "ended" then
            stopAudio()
            composer.gotoScene("Pages.Page06", {effect = "slideRight", time = 500})
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
