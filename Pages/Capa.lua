local composer = require("composer")
local scene = composer.newScene()

local largura, altura = display.actualContentWidth, display.actualContentHeight
-- Definindo altura da metade da tela
local metade_altura = altura / 2

local function createTitulo(sceneGroup)
    local titulo = display.newText({
        text = "Semeando a Historia",
        font = native.newFont("Bold"),
        fontSize = 85
    })
    titulo.x = display.contentCenterX
    titulo.y = 300
    titulo:setFillColor(1, 1, 1)
    sceneGroup:insert(titulo)
end

local function createSubTitulo(sceneGroup)
    local subtitulo = display.newText({
        text = "Autor: Charles Vilela de Souza \n Ano: 2024",
        font = native.newFont("Bold"),
        fontSize = 70
    })
    subtitulo.x = display.contentCenterX
    subtitulo.y = 450
    subtitulo:setFillColor(1, 1, 1)
    sceneGroup:insert(subtitulo)
end

-- create()
function scene:create( event )
    local sceneGroup = self.view
    -- Adicionar um retângulo azul para simular o céu
    local ceu = display.newRect(sceneGroup, 0, 0, largura, metade_altura * 2)
    ceu.anchorX = 0
    ceu.anchorY = 0
    ceu:setFillColor(0.53, 0.81, 0.98) -- Cor azul do céu

    createTitulo(sceneGroup)
    createSubTitulo(sceneGroup)

    -- Area dos botoes de passar página
    local buttonProximaPagina = display.newImageRect(sceneGroup, "image/Buttons/proxima_pagina.png", 200, 200)
    buttonProximaPagina.x = largura - 250 / 2 - 20
    buttonProximaPagina.y = altura - 250 / 2 - 20

    buttonProximaPagina:addEventListener("touch", function (event)
        if event.phase == "ended" then
            composer.gotoScene("Pages.Page01", {effect = "slideLeft", time = 500})
        end
    end)
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
  -- -----------------------------------------------------------------------------------
  
  return scene