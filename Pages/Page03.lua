local composer = require("composer")

-- Definir configurações da cena
local scene = composer.newScene()
local mySceneGroup

-- Definindo largura e altura específicas
local largura, altura = 768, 1024

local physics = require("physics")
physics.start()
physics.setGravity(0, 0)

-- Ativar multitouch
system.activate("multitouch")

-- Mantenha o controle dos objetos que estão sendo tocados
local touchedObjects = {}

-- Tabela para armazenar os IDs de toque ativos
local activeTouchIDs = {}

-- Armazena as coordenadas de colisão com o chão
local coordenadasChao = {}

-- Limites em X
local limiteEsquerdo = 100
local limiteDireito = largura - 100
-- Limites em Y
local limiteSuperior = 100
local limiteInferior = altura - 300  -- Ajuste conforme necessário
local mySceneGroup
local nomade

local balaoTexto
local mySceneGroup

local function exibirBalaoTexto()
    -- local balao = display.newCircle(arado_leve.x, arado_leve.y - arado_leve.height * 0.4, 50)
    -- balao:setFillColor(1, 1, 0)  -- Cor amarela para o balão
    balaoTexto = display.newText({
        text = "Toque nas duas extremidades \n ao mesmo tempo para \n movimentar a ferramenta \n e cavar o buracos",
        x = 400, 
        y= altura - 450,
        font = native.systemFont,
        fontSize = 30
    })
    balaoTexto:setFillColor(1, 0, 0)
    mySceneGroup:insert(balaoTexto)
end

local function esconderBalao()
    print("Chamou remover Balao")
    -- Remover o balão da cena
    if balaoTexto then
        balaoTexto:removeSelf()
        balaoTexto = nil
    end
end

local function criarNomade(sceneGroup)
    nomade = display.newImageRect("image/Page01/nomade.png", largura * 0.4, altura * 0.4)
    nomade.x = 650
    nomade.y = 660
    sceneGroup:insert(nomade)
end

local function soltarSementes(coordenada)
    local numero_sementes = 1
    local semente = display.newCircle(
    coordenada.x, 
    coordenada.y + 90, 5)
    semente:setFillColor(1, 0.92, 0.016)
    mySceneGroup:insert(semente)
    -- mySceneGroup:toBack()
end

local function moverNomade(coordenadas)
    transition.to(nomade, {
        x = coordenadas.x,
        y = coordenadas.y,
        time = 1000,
        onComplete = function()
            soltarSementes(coordenadas)
        end
    })
end

-- Função para criar novos objetos nas coordenadas armazenadas em coordenadasChao
local function criarObjetosCoordenadasChao(coordenada)
    print("Chamou a função para criar novos objetos...")
    timer.performWithDelay(1, function()
        local novoObjeto = display.newRect(mySceneGroup, 
        coordenada.x, 
        coordenada.y + 90, 
        50, 50)     
        novoObjeto:setFillColor(0.6, 0.3, 0)
        
        -- Mova o novo objeto para a frente na ordem de exibição
        novoObjeto:toFront()
        -- -- Mova o nomade para a frente na ordem de exibição novamente
        nomade:toFront()
        moverNomade(coordenada)
    end)
end

-- Função para lidar com eventos de colisão com o chão
local function chaoCollision(event)
    if (event.phase == "began") then
        -- Verificar se os objetos de colisão são válidos e se um deles é o chão
        local obj1 = event.target
        local obj2 = event.other
        local coordenada
        if obj1 and obj2 then
            if obj1.userData and obj1.userData.name == "chao" then
                -- Adicionar as coordenadas do ponto de colisão do obj2
                coordenada= {x = obj2.x, y = obj2.y}
            elseif obj2.userData and obj2.userData.name == "chao" then
                -- Adicionar as coordenadas do ponto de colisão do obj1
                coordenada = {x = obj1.x, y = obj1.y}
            end
            criarObjetosCoordenadasChao(coordenada)
        end
    end
end

local function criarChao(sceneGroup)
    -- Crie um retângulo para representar o chão
    local chao = display.newRect(sceneGroup, 0, altura - 90, largura + 800, 180)
    chao:setFillColor(0.64, 0.16, 0.16)
    chao.userData = { name = "chao" }

    -- Adicione um corpo físico ao chão e torne-o estático para que os objetos não possam movê-lo
    physics.addBody(chao, "static")

    -- Adiciona um ouvinte de colisão ao chão
    chao:addEventListener("collision", chaoCollision)
end

-- Função para lidar com eventos de toque
local function touchListener(event)
    local phase = event.phase
    local target = event.target

    if phase == "began" then
        -- Adicionar o objeto à tabela de objetos tocados
        touchedObjects[target] = true

        esconderBalao()
        local count = 0
        for _ in pairs(touchedObjects) do
            count = count + 1
        end

        -- Verificar se este evento de toque está relacionado a um dos toques ativos
        local isMultiTouch = false
        if count == 2 then
            isMultiTouch = true
        end

        print(isMultiTouch)

        if isMultiTouch then
            display.getCurrentStage():setFocus(target, event.id)
            target.isFocus = true

            -- Armazenar o ID de toque ativo
            activeTouchIDs[event.id] = true

            -- Armazenar a posição inicial do toque
            target.markX = event.x - target.x
            target.markY = event.y - target.y
        end
    elseif target.isFocus then
        if phase == "moved" then
            -- Atualizar a posição do objeto
            target.x = event.x - target.markX
            target.y = event.y - target.markY

            -- Impedir que o objeto passe pelos limites laterais da tela
            if target.x < limiteEsquerdo then
                target.x = limiteEsquerdo
            elseif target.x > limiteDireito then
                target.x = limiteDireito
            end

            -- Impedir que o objeto passe pelos limites superior e inferior da tela
            if target.y < limiteSuperior then
                target.y = limiteSuperior
            elseif target.y > limiteInferior then
                target.y = limiteInferior
            end
        elseif phase == "ended" or phase == "cancelled" then
            -- Remover o foco do objeto
            display.getCurrentStage():setFocus(target, nil)
            target.isFocus = false

            -- Remover o ID de toque ativo
            activeTouchIDs[event.id] = nil

            -- Remova os objetos da tabela de objetos tocados
            for obj in pairs(touchedObjects) do
                touchedObjects[obj] = nil
            end

            -- Se não há mais objetos tocados, libere o foco
            if next(touchedObjects) == nil then
                display.getCurrentStage():setFocus(nil)
            end
        end
    end

    return true
end

local function stopAudio()
    isAudioPlaying = false
    buttonPlay = display.newImageRect(scene.view, "image/Fone/audio_desligado.png", 140, 140)
    audio.stop()
end

-- Player no audio
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
            sound = audio.loadSound("audio/Page03/audioPage03.mp3")
            audio.play(sound, {loops = -1})
        end
        buttonPlay.x = largura / 2
        buttonPlay.y = altura * 0.195 + 750
        buttonPlay:addEventListener("touch", onTouch)
    end
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
        text = "Próxima Página",
        font = native.newFont("Bold"),
        fontSize = 25
    })
    -- Ajuste a posição do titulo para a parte superior da tela
    textoBotaoProximaPagina.x = largura - largura * 0.11 / 2 - 150
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

local function createTitulo(sceneGroup)
    local titulo = display.newText({
        text = "O inicio da agricultura",
        font = native.newFont("Bold"),
        fontSize = 40  -- Usar uma porcentagem da largura da tela para o tamanho da fonte
    })
    titulo.x = largura * 0.5
    titulo.y = altura * 0.07
    titulo:setFillColor(0.2 * (52/255), 0.2 * (131/255), 0.2 * (235/255))
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
        texto:setFillColor(0.2 * (52/255), 0.2 * (131/255), 0.2 * (235/255))
        sceneGroup:insert(texto)
    end
end

-- Função para criar o texto
local function createTexto(sceneGroup)
    texto = "As plantas começaram a ser cultivadas muito próximas uma das outras. Isso porque elas podiam produzir frutos, que eram facilmente colhidos quando madurassem, o que permitia uma maior produtividade das plantas cultivadas em relação ao seu habitat natural."
    criarTextoJustificado(sceneGroup, texto, display.contentCenterX, 150, largura - 60, 100, native.newFont("Bold"), 35, 40)
end

function scene:create(event)
  local sceneGroup = self.view

  local ceu = display.newRect(sceneGroup, 0, 0, largura, altura / 2 * 1.7)
  ceu.anchorX = 0
  ceu.anchorY = 0
  ceu:setFillColor(0.53, 0.81, 0.98) -- Cor azul do céu

  createTitulo(sceneGroup)
  createTexto(sceneGroup)

  mySceneGroup = sceneGroup
  -- Criar um grupo para conter os dois retângulos
  local group = display.newGroup()
  sceneGroup:insert(group)


  -- Criar dois objetos de exibição na tela e adicioná-los ao grupo
  local newRect1 = display.newRect(group, display.contentCenterX - 200, 600, 30, 100)
  newRect1:setFillColor(0.4, 0.2, 0)
  physics.addBody(newRect1, "dynamic", { density = 1.0, friction = 0.3, bounce = 0.2 })
  exibirBalaoTexto()

  local newRect2 = display.newRect(group, display.contentCenterX - 200, 700, 30, 100)
  newRect2:setFillColor(0.4, 0.2, 0)
  physics.addBody(newRect2, "dynamic", { density = 1.0, friction = 0.3, bounce = 0.2 })

  -- Criar uma junta entre os objetos
  local joint = physics.newJoint("weld", newRect1, newRect2, newRect1.x, newRect1.y)

  -- Adicionar um ouvinte de toque a cada objeto
  newRect1:addEventListener("touch", touchListener)
  newRect2:addEventListener("touch", touchListener)
  physics.start()

  criarChao(sceneGroup)
  criarNomade(sceneGroup)

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
  buttonProximaPagina:addEventListener("touch", function(event)
      if event.phase == "ended" then
        stopAudio()
        composer.gotoScene("Pages.Page04", {effect = "slideLeft", time = 500})
      end
  end)
  adicionarTextoBotaoProximaPagina(sceneGroup)

  local buttonPaginaAnterior = display.newImageRect(sceneGroup, "image/Buttons/pagina_anterior.png", buttonSize, buttonSize)
  buttonPaginaAnterior.x = largura - buttonSize * 1.5 - 580
  buttonPaginaAnterior.y = altura - buttonSize / 2 - 30
  buttonPaginaAnterior:addEventListener("touch", function(event)
      if event.phase == "ended" then
        stopAudio()
        composer.gotoScene("Pages.Page02", {effect = "slideRight", time = 500})
      end
  end)
  adicionarTextoBotaoPaginaAnterior(sceneGroup)
  

end

function scene:destroy(event)

    -- Remova os ouvintes de toque dos objetos
    local newRect1 = sceneGroup:getChild("newRect1")
    newRect1:removeEventListener("touch", touchListener)
    local newRect2 = sceneGroup:getChild("newRect2")
    newRect2:removeEventListener("touch", touchListener)
  
    -- Remova o grupo da cena
    sceneGroup:remove(group)
  
    -- Libere as variáveis ​​para evitar vazamentos de memória
    sceneGroup = nil
    group = nil
    touchedObjects = nil
end

-- Escute o evento de cena
scene:addEventListener("create", scene)
scene:addEventListener("destroy", scene)


return scene
