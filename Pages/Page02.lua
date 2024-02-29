local composer = require("composer")
local scene = composer.newScene()

-- Definindo largura e altura específicas
local largura, altura = 768, 1024
-- Definindo altura da metade da tela
local metade_altura = altura / 2

local startGravidade = false
local gravidade = 0

local peDeTrigo
local semente
local chao
local mySceneGroup

local function criarChao(sceneGroup)
    chao = display.newRect(sceneGroup, 0, altura - 90, largura + 800, 180)
    chao:setFillColor(0.64, 0.16, 0.16) -- Defina a cor alpha para 0 para tornar a base invisível
    chao.userData = {name = "chao"}
    physics.addBody(chao, "static") -- Definindo a base como um corpo estático
end

local function criarBarreira(sceneGroup)
    chao = display.newRect(sceneGroup, 700, altura - 280, 200, 200)
    chao:setFillColor(1, 1, 1) -- Defina a cor alpha para 0 para tornar a base invisível
    chao.userData = {name = "chao"}
    physics.addBody(chao, "static") -- Definindo a base como um corpo estático
end

-- remover depois função não preciso mais
local function criarObjeto(sceneGroup)
    local objeto = display.newRect(sceneGroup, 100, altura - 150, 50, 50)
    objeto:setFillColor(1, 0, 0)
    physics.addBody(objeto, "dynamic", {density = 1.0, friction = 0.3, bounce = 0.2})
    objeto.isSleepingAllowed = false -- Impede que o objeto durma (pode ser útil para detectar colisões)
end

local function criarSemente(sceneGroup, x, y)
    semente = display.newCircle(sceneGroup, x, y, 5)
    semente:setFillColor(0.8, 0.7, 0.5) -- Cor da semente de trigo
    semente.isSleepingAllowed = false
    semente.userData = {name = "semente"}
    physics.addBody(semente, "dynamic", {radius = 5})
    -- physics.setGravity(0, 0.5)
end

local function criarPeDeTrigo(sceneGroup)
    peDeTrigo = display.newImageRect(sceneGroup, "image/Page02/plantacao_trigo.png", largura * 0.5, altura * 0.6)
    peDeTrigo.x = largura * 0.5 - 150
    peDeTrigo.y = altura - 150 - peDeTrigo.height * 0.4
    physics.addBody(peDeTrigo, "static") -- Torna o pé de trigo um corpo estático
end

local function onCollision(event)
    if event.phase == "began" then
        local obj1 = event.object1
        local obj2 = event.object2

        print("Chamou a função onCollision, antes de entrar no primeiro IF")
        if obj1.userData and obj2.userData then
            print(obj1.userData.name)
            print(obj2.userData.name)
            print("Chamou a função onCollision, antes de entrar no segundo IF")
            -- Verificar se o objeto é uma semente e o chão
            if ((obj1.userData.name == "semente" and obj2.userData.name == "chao") or (obj1.userData.name == "chao" and obj2.userData.name == "semente")) then
                print("Entrou na verificação se é semente e chao")

                local semente

                -- Define a semente como objeto correto
                if (obj1.userData.name == "semente") then
                    semente = obj1
                else
                    semente = obj2
                end 

                -- Agende a remoção da física da semente após 15 segundos
                timer.performWithDelay(5000, function()
                    physics.removeBody(semente)
                    -- semente:removeEventListener("postCollision", onPostCollision)
                    print("Física da semente foi removida após 15 segundos")
                    -- Ajuste a posição vertical da semente para simular o plantio
                    semente.y = semente.y + 10
                    
                    local planta = display.newImageRect(mySceneGroup, "image/Page02/semente_germinada.png", 50, 100)
                    planta.x = semente.x
                    planta.y = semente.y
                    -- semente:removeSelf()
                end)
            end
        else
            print("Objetos sem userData...")
        end
    end
end

-- Adicionar o ouvinte de colisão
Runtime:addEventListener("collision", onCollision)

-- Event listener para o acelerômetro
local function onAccelerate(event, peDeTrigoX, peDeTrigoY)
    if event.isShake then
        local sceneGroup = scene.view
        print("O dispositivo está sendo agitado!")
        for i = 1, 10 do -- Gerar 10 sementes de trigo
            -- Gerar sementes em torno das coordenadas do pé de trigo
            local offsetX = math.random(-20, 20)
            local offsetY = math.random(-20, 20)
            criarSemente(sceneGroup, peDeTrigoX + offsetX, peDeTrigoY + offsetY)
        end
    end
end
Runtime:addEventListener("accelerometer", function(event)
    onAccelerate(event, peDeTrigo.x, peDeTrigo.y)
end)


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
        text = "Page 02",
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
function scene:create(event)
    local sceneGroup = self.view
    mySceneGroup = sceneGroup
    -- Adicionar um retângulo azul para simular o céu
    local ceu = display.newRect(sceneGroup, 0, 0, largura, altura)
    ceu.anchorX = 0
    ceu.anchorY = 0
    ceu:setFillColor(0.53, 0.81, 0.98) -- Cor azul do céu

    createTitulo(sceneGroup)
    -- createSubTitulo(sceneGroup)

    physics.start()
    --Criar a base (chão)
    criarChao(sceneGroup)
    -- criarObjeto(sceneGroup)
    criarPeDeTrigo(sceneGroup)
    -- criarBarreira(sceneGroup)

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
            composer.gotoScene("Pages.Page03", {effect = "slideLeft", time = 500})
        end
    end)
    adicionarTextoBotaoProximaPagina(sceneGroup)

    local buttonPaginaAnterior = display.newImageRect(sceneGroup, "image/Buttons/pagina_anterior.png", buttonSize, buttonSize)
    buttonPaginaAnterior.x = largura - buttonSize * 1.5 - 580
    buttonPaginaAnterior.y = altura - buttonSize / 2 - 30
    buttonPaginaAnterior:addEventListener("touch", function(event)
        if event.phase == "ended" then
            composer.gotoScene("Pages.Page01", {effect = "slideRight", time = 500})
        end
    end)
    adicionarTextoBotaoPaginaAnterior(sceneGroup)
end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        -- physics.start()
    elseif (phase == "did") then
        -- Code here runs when the scene is entirely on screen
    end
end

-- hide()
function scene:hide(event)

    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        physics.stop()
    elseif (phase == "did") then
        -- Code here runs immediately after the scene goes entirely off screen
    end
end

-- destroy()
function scene:destroy(event)

    local sceneGroup = self.view
    
    -- Code here runs prior to the removal of scene's view
    sceneGroup:removeSelf()
    sceneGroup = nil

end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene