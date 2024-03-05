local composer = require("composer")
local scene = composer.newScene()

-- Definindo largura e altura específicas
local largura, altura = 768, 1024
-- Definindo altura da metade da tela
local metade_altura = altura / 2

local largura_grama = largura + 800
local largura_minima_grama = 100 -- Largura mínima que a grama pode ter

local mySceneGroup
local arado_leve
local grama
local boi
local joint
local imagem_boi
local boiJoinDefined = false
local criouNovoBoi = false
local novoBoi
local balaoTextoArado
local balaoTextoBoi

local funcaoMoverBoi

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

local function exibirBalaoTextoArado()
    -- local balao = display.newCircle(arado_leve.x, arado_leve.y - arado_leve.height * 0.4, 50)
    -- balao:setFillColor(1, 1, 0)  -- Cor amarela para o balão
    balaoTextoArado = display.newText({
        text = "Arado leve",
        x = arado_leve.x - 150, 
        y= arado_leve.y - arado_leve.height * 0.4,
        font = native.systemFont,
        fontSize = 30
    })
    balaoTextoArado:setFillColor(1, 0, 0)
    mySceneGroup:insert(balaoTextoArado)
end

local function esconderBalaoArado()
    print("Chamou remover Balao")
    -- Remover o balão da cena
    if balaoTextoArado then
        balaoTextoArado:removeSelf()
        balaoTextoArado = nil
    end
end

local function exibirBalaoTextoBoi()
    -- local balao = display.newCircle(arado_leve.x, arado_leve.y - arado_leve.height * 0.4, 50)
    -- balao:setFillColor(1, 1, 0)  -- Cor amarela para o balão
    balaoTextoBoi = display.newText({
        text = "Toque no boi. \n Leve-o para Arador",
        x = boi.x + 200, 
        y= boi.y - boi.height * 0.4,
        font = native.systemFont,
        fontSize = 30
    })
    balaoTextoBoi:setFillColor(1, 0, 0)
    mySceneGroup:insert(balaoTextoBoi)
end

local function esconderBalaoBoi()
    print("Chamou remover Balao")
    -- Remover o balão da cena
    if balaoTextoBoi then
        balaoTextoBoi:removeSelf()
        balaoTextoBoi = nil
    end
end

local function exibirBalaoTextoNovoBoi()
    -- local balao = display.newCircle(arado_leve.x, arado_leve.y - arado_leve.height * 0.4, 50)
    -- balao:setFillColor(1, 1, 0)  -- Cor amarela para o balão
    balaoTextoBoi = display.newText({
        text = "Toque no boi. \n Para arar a terra",
        x = boi.x - 300, 
        y= boi.y - boi.height * 0.4,
        font = native.systemFont,
        fontSize = 30
    })
    balaoTextoBoi:setFillColor(1, 0, 0)
    mySceneGroup:insert(balaoTextoBoi)
end

local function esconderBalaoNovoBoi()
    print("Chamou remover Balao")
    -- Remover o balão da cena
    if balaoTextoBoi then
        balaoTextoBoi:removeSelf()
        balaoTextoBoi = nil
    end
end

local function onTouchArado(event)
    local arado = event.target
    local halfWidth = arado.width / 2

    if event.phase == "began" then
        esconderBalaoArado()
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
    arado_leve = display.newImageRect(sceneGroup, "image/Page04/arado_leve.png", largura * 0.2, altura * 0.2)
    arado_leve.x = largura * 0.5 + 280
    arado_leve.y = altura - 140 - arado_leve.height * 0.4
    exibirBalaoTextoArado()
    physics.addBody(arado_leve, "dynamic")
    arado_leve:addEventListener("touch", onTouchArado)
end

local function cortarGrama()

    local arado_center_x = arado_leve.x
    local grama_left = grama.x - grama.width / 2
    local grama_right = grama.x + grama.width / 2
        
    if arado_center_x > grama_left and arado_center_x < grama_right then
        local delta_x = novoBoi.x - arado_leve.x -- calcula o deslocamento horizontal entre o boi e o arado
        local velocidade_corte = 0.09 -- ajuste a velocidade de corte conforme necessário
            
        largura_grama = largura_grama - (delta_x * velocidade_corte) -- reduz a largura da grama com base no movimento horizontal
        grama.width = largura_grama
        grama.x = grama.x + (delta_x * velocidade_corte) -- ajusta a posição da grama para mantê-la centrada em relação ao arado
        print("Cortando a grama...", largura_grama)
    end
end

local function moverNovoBoi(event)
    local velocidade = 50

    if novoBoi.isMovingLeft then
        novoBoi:setLinearVelocity(-velocidade, 0) -- Altere as coordenadas de velocidade conforme necessário
        cortarGrama()
    elseif novoBoi.isMovingRight then
        novoBoi:setLinearVelocity(velocidade, 0) -- Define a velocidade como zero quando não estiver tocando no boi
    else
        novoBoi:setLinearVelocity(0, 0)
    end
end

local function onTouchNovoBoi(event)
    local novoBoi = event.target

    if event.phase == "began" then
        esconderBalaoNovoBoi()
        novoBoi.isMovingLeft = false
        novoBoi.isMovingRight = false

        -- Determina se o toque está a esquerda ou a direita do boi
        local touchX = event.x
        local boiCenterX = novoBoi.x
        if touchX < boiCenterX then
            novoBoi.isMovingLeft = true
            -- verificarProximidadeNovoBoi()
        else
            novoBoi.isMovingRight = true
            -- verificarProximidade()
        end        
    elseif event.phase == "ended" or event.phase == "cancelled" then
        novoBoi.isMovingLeft = false
        novoBoi.isMovingRight = false
    end

    -- Verifica se o boi está dentro dos limites da tela ao longo do eixo X
    local limiteEsquerdo = novoBoi.width / 2
    local limiteDireito = largura - novoBoi.width / 2
    if novoBoi.x < limiteEsquerdo then
        novoBoi.x = limiteEsquerdo
    elseif novoBoi.x > limiteDireito then
        novoBoi.x = limiteDireito
    end
    return true
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

local function criarNovoBoi()
    Runtime:removeEventListener("enterFrame", moverBoi)
    boi:removeSelf()
    imagem_boi = "image/Page04/boi_esquerda.png"
    novoBoi = display.newImageRect(mySceneGroup, imagem_boi, largura * 0.2, altura * 0.2) -- Cria uma nova imagem do boi
    print(imagem_boi)
    novoBoi.x = largura * 0.7 -- Ajusta a posição conforme necessário
    novoBoi.y = altura - 140 - arado_leve.height * 0.9
    physics.addBody(novoBoi, "dynamic")
    mySceneGroup:insert(novoBoi)
    exibirBalaoTextoNovoBoi()
    novoBoi:addEventListener("touch", onTouchNovoBoi)
    Runtime:addEventListener("enterFrame", moverNovoBoi)
end

local function verificarProximidade()    
    local distanciaLimite = 300

    local distanciaX = math.abs(boi.x - arado_leve.x)
    local distanciaY = math.abs(boi.y - arado_leve.y)
    local proximidade = distanciaX < distanciaLimite

    if proximidade and not joint then
        boiJoinDefined = true
        criarNovoBoi()
        -- Criar uma junta entre os objetos apenas se não houver uma já criada
        joint = physics.newJoint("weld", novoBoi, arado_leve, boi.x, arado_leve.y)
    end
    return proximidade
end

local function onTouchBoi(event)
    local boi = event.target

    if event.phase == "began" then
        esconderBalaoBoi()
        boi.isMovingLeft = false
        boi.isMovingRight = false

        -- Determina se o toque está a esquerda ou a direita do boi
        local touchX = event.x
        local boiCenterX = boi.x
        if touchX < boiCenterX then
            boi.isMovingLeft = true
            verificarProximidade()
        else
            boi.isMovingRight = true
            verificarProximidade()
        end        
    elseif event.phase == "ended" or event.phase == "cancelled" then
        boi.isMovingLeft = false
        boi.isMovingRight = false
    end

    -- Verifica se o boi está dentro dos limites da tela ao longo do eixo X
    local limiteEsquerdo = boi.width / 2
    local limiteDireito = largura - boi.width / 2
    if boi.x < limiteEsquerdo then
        boi.x = limiteEsquerdo
    elseif boi.x > limiteDireito then
        boi.x = limiteDireito
    end

    if criouNovoBoi then
        print("Criou novo boi ", criouNovoBoi)
        boi:addEventListener("touch", onTouchBoi)
        Runtime:addEventListener("enterFrame", moverBoi)
    end
    print("Criou novo boi ", criouNovoBoi)
    return true
end

local function criarBoi(sceneGroup)
    boi = display.newImageRect(sceneGroup, imagem_boi, largura * 0.2, altura * 0.2)
    boi.x = largura * 0.5 - 200
    boi.y = altura - 140 - arado_leve.height * 0.9
    physics.addBody(boi, "dynamic")
    sceneGroup:insert(boi)
    exibirBalaoTextoBoi()
    
    boi:addEventListener("touch", onTouchBoi)
    Runtime:addEventListener("enterFrame", moverBoi)
end

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
            sound = audio.loadSound("audio/Page04/audioPage04.mp3")
            audio.play(sound, {loops = -1})
        end
        buttonPlay.x = largura / 2
        buttonPlay.y = altura * 0.195 + 750
        buttonPlay:addEventListener("touch", onTouch)
    end
end

local function createTitulo(sceneGroup)
    local titulo = display.newText({
        text = "Desenvolvimento de Ferramentas",
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
    texto = "Durante a revolução agrícola, o desenvolvimento de ferramentas específicas foi crucial para avanços na agricultura. No sistema de Alqueive e Tração Leve, arados leves e instrumentos de aração revolucionaram o processo de plantio, permitindo uma agricultura mais intensiva e eficiente. Essas ferramentas foram projetadas para facilitar a preparação do solo, promovendo uma distribuição uniforme de sementes e aumentando a produtividade. O sistema de alqueive e tração leve representou um marco na história agrícola, marcando uma transição significativa em direção a métodos mais eficazes de cultivo."
    criarTextoJustificado(sceneGroup, texto, display.contentCenterX, 130, largura - 60, 100, native.newFont("Bold"), 30, 35)
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

-- create()
function scene:create( event )
    local sceneGroup = self.view
    mySceneGroup = sceneGroup
    -- Adicionar um retângulo azul para simular o céu
    local ceu = display.newRect(sceneGroup, 0, 0, largura, altura)
    ceu.anchorX = 0
    ceu.anchorY = 0
    ceu:setFillColor(0.53, 0.81, 0.98) -- Cor azul do céu

    createTitulo(sceneGroup)
    createTexto(sceneGroup)

    physics.start()
    physics.setGravity(0, 0)

    imagem_boi = "image/Page04/boi_direita.png"

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
            stopAudio()
            composer.gotoScene("Pages.Page05", {effect = "slideLeft", time = 500})
        end
    end)
    adicionarTextoBotaoProximaPagina(sceneGroup)

    local buttonPaginaAnterior = display.newImageRect(sceneGroup, "image/Buttons/pagina_anterior.png", buttonSize, buttonSize)
    buttonPaginaAnterior.x = largura - buttonSize * 1.5 - 580
    buttonPaginaAnterior.y = altura - buttonSize / 2 - 30
    buttonPaginaAnterior:addEventListener("touch", function (event)
        if event.phase == "ended" then
            stopAudio()
            composer.gotoScene("Pages.Page03", {effect = "slideRight", time = 500})
        end
    end)
    adicionarTextoBotaoPaginaAnterior(sceneGroup)

    print("Verifica boiJoinDefined em create")
    if boiJoinDefined then

        criarNovoBoi()
    end

end 
  
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
  
    if ( phase == "will" ) then
        print("Verifica boiJoinDefined em show")
        if boiJoinDefined then
            criarNovoBoi()
        end
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
