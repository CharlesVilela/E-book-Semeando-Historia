local composer = require("composer")
local scene = composer.newScene()

local largura, altura = 768, 1024
local tamanho_celula = largura * 0.026
local nomades = {}
local recursos = {}
local num_recursos = 5
local recursos_coletados = 0
local busca_iniciada = false
local balaoTexto
local mySceneGroup

local function exibirBalaoTexto()
    -- local balao = display.newCircle(arado_leve.x, arado_leve.y - arado_leve.height * 0.4, 50)
    -- balao:setFillColor(1, 1, 0)  -- Cor amarela para o balão
    balaoTexto = display.newText({
        text = "Toque no nomade e arraste. \n Para coletar os recursos",
        x = 300, 
        y= altura - 500,
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

local function nomadeTouchHandler(event)
    local nomade = event.target
    if event.phase == "began" then
        busca_iniciada = true
        esconderBalao()
    end
    -- Adicionei a lógica de movimento aqui
    if busca_iniciada then
        nomade.x = event.x
        nomade.y = event.y

        -- local newX = event.x
        -- local newY = event.y
        -- newX = math.max(newX, 10 + nomade.width / 2) -- Limite esquerdo
        -- newX = math.min(newX, largura - 10 - nomade.width / 2) -- Limite direito
        -- newY = math.max(newY, 400 + nomade.height / 2) -- Limite superior
        -- newY = math.min(newY, altura - 100 - nomade.height / 2) -- Limite inferior
        -- nomade.x = newX
        -- nomade.y = newY
        
    end
end

local function criarNomades()
    for i = 1, 1 do
        local nomade = display.newImageRect("image/Page01/nomade.png", largura * 0.292, altura * 0.272) 
        -- Definindo as coordenadas x e y dentro dos limites
        nomade.x = math.random(50 + nomade.width / 2, largura - 50 - nomade.width / 2) -- Limites esquerdo e direito
        nomade.y = math.random(300 + nomade.height / 2, altura - 50 - nomade.height / 2) -- Limites superior e inferior
        table.insert(nomades, nomade)
        nomade:addEventListener("touch", nomadeTouchHandler)
        exibirBalaoTexto()
    end
end

local function criarRecursos()
    local imagens = {
        "image/Page01/mamute.png",
        "image/Page01/bisao.png",
        "image/Page01/antilope.png",
        "image/Page01/coelho.png",
        "image/Page01/trigo.png",
        "image/Page01/cevada.png",
        "image/Page01/frutas_vermelhas.png",
        "image/Page01/nozes.png"
    }

    for i = 1, num_recursos do
        local x, y
        local distancia_minima = largura * 0.13

        repeat
            x = math.random(tamanho_celula, largura - tamanho_celula)
            y = math.random(altura / 2 + altura * 0.195, altura - tamanho_celula - altura * 0.195)
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
        local recurso = display.newImageRect(imagemAleatoria, 100, 100)
        recurso.x = x
        recurso.y = y
        table.insert(recursos, recurso)
    end
end

-- local function criarRecursos()
--     local imagens = {
--         "image/Page01/mamute.png",
--         "image/Page01/bisao.png",
--         "image/Page01/antilope.png",
--         "image/Page01/coelho.png",
--         "image/Page01/trigo.png",
--         "image/Page01/cevada.png",
--         "image/Page01/frutas_vermelhas.png",
--         "image/Page01/nozes.png"
--     }

--     for i = 1, num_recursos do
--         local x, y
--         local distancia_minima = largura * 0.13

--         repeat
--             x = math.random(50, largura - 50)
--             y = math.random(altura / 2 + altura * 0.195, altura - 50) -- Ajuste para gerar apenas na parte inferior
--             local muito_proximo = false
--             for j, nomade in ipairs(nomades) do
--                 local distancia_x = math.abs(nomade.x - x)
--                 local distancia_y = math.abs(nomade.y - y)
--                 if distancia_x < distancia_minima and distancia_y < distancia_minima then
--                     muito_proximo = true
--                     break
--                 end
--             end
--         until not muito_proximo

--         local imagemAleatoria = imagens[math.random(#imagens)]
--         local recurso = display.newImageRect(imagemAleatoria, 100, 100)
--         recurso.x = x
--         recurso.y = y
--         table.insert(recursos, recurso)
--     end
-- end


local function colisaoComRecursos(nomade)
    local distancia_minima = tamanho_celula * 1.5
    for i = #recursos, 1, -1 do
        local recurso = recursos[i]
        local distancia_x = math.abs(nomade.x - recurso.x)
        local distancia_y = math.abs(nomade.y - recurso.y)
        if distancia_x <= distancia_minima and distancia_y <= distancia_minima then
            recurso:removeSelf()
            table.remove(recursos, i)
            recursos_coletados = recursos_coletados + 1
        end
    end
end

local function moverNomades()
    if not busca_iniciada then
        return
    end
    
    for i, nomade in ipairs(nomades) do
        colisaoComRecursos(nomade)
    end

    if recursos_coletados == num_recursos then
        print("Todos os recursos foram coletados!")
    end
end

local function limparRecursos()
    for i = #recursos, 1, -1 do
        recursos[i]:removeSelf()
        table.remove(recursos, i)
    end
end

local function limparNomades()
    for i = #nomades, 1, -1 do
        nomades[i]:removeSelf()
        table.remove(nomades, i)
    end
end

local function stopAudio()
    if isAudioPlaying then
        isAudioPlaying = false
        buttonPlay:removeSelf()
        buttonPlay = display.newImageRect(scene.view, "image/Fone/audio_desligado.png", 140, 140)
        audio.stop()
    end
end

local function onTouch(event)
    local buttonSize = largura * 0.09
    if event.phase == "ended" then
        if isAudioPlaying then
            isAudioPlaying = false
            buttonPlay:removeSelf()
            buttonPlay = display.newImageRect(scene.view, "image/Fone/no_audio.png", buttonSize * 0.8, buttonSize * 0.8)
            audio.stop()
        else
            isAudioPlaying = true
            buttonPlay:removeSelf()
            buttonPlay = display.newImageRect(scene.view, "image/Fone/audio.png", buttonSize, buttonSize)
            sound = audio.loadSound("audio/Page01/audioPage01.mp3")
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
        fontSize = 20
    })
    textoBotaoAudio.x = largura / 2
    textoBotaoAudio.y = altura - textoBotaoAudio.height / 2 - 10
    textoBotaoAudio:setFillColor(1, 1, 1)
    sceneGroup:insert(textoBotaoAudio)
end

local function adicionarTextoBotaoProximaPagina(sceneGroup)
    local textoBotaoProximaPagina = display.newText({
        text = "Próxima Página",
        font = native.newFont("Bold"),
        fontSize = 20
    })
    textoBotaoProximaPagina.x = largura - largura * 0.11 / 2 - 130
    textoBotaoProximaPagina.y = altura - largura * 0.11 / 2 - 20
    textoBotaoProximaPagina:setFillColor(1, 1, 1)
    sceneGroup:insert(textoBotaoProximaPagina)
end

local function adicionarTextoBotaoPaginaAnterior(sceneGroup)
    local textoBotaoPaginaAnterior = display.newText({
        text = "Página Anterior",
        font = native.newFont("Bold"),
        fontSize = 20
    })
    textoBotaoPaginaAnterior.x = largura - largura * 0.11 / 2 - 540
    textoBotaoPaginaAnterior.y = altura - largura * 0.11 / 2 - 20
    textoBotaoPaginaAnterior:setFillColor(1, 1, 1)
    sceneGroup:insert(textoBotaoPaginaAnterior)
end

local function createTitulo(sceneGroup)
    local titulo = display.newText({
        text = "Antes da agricultura",
        font = native.newFont("Bold"),
        fontSize = 60
    })
    titulo.x = display.contentCenterX
    titulo.y = altura * 0.293 - 200
    titulo:setFillColor(1, 1, 1)
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

function scene:create(event)
    local sceneGroup = self.view
    mySceneGroup = sceneGroup
    local ceu = display.newRect(sceneGroup, 0, 0, largura, altura / 2 * 1.5)
    ceu.anchorX = 0
    ceu.anchorY = 0
    ceu:setFillColor(0.53, 0.81, 0.98)

    local background = display.newImageRect(sceneGroup, "image/Page01/background.png", largura, altura * 0.586)
    background.anchorX = 0
    background.anchorY = 1
    background.x = 0
    background.y = altura

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

    createTitulo(sceneGroup)
    createTexto(sceneGroup)

    local buttonProximaPagina = display.newImageRect(scene.view, "image/Buttons/proxima_pagina.png", buttonSize, buttonSize)
    buttonProximaPagina.x = largura - buttonSize / 2 - 40
    buttonProximaPagina.y = altura - buttonSize / 2 - 30
    buttonProximaPagina:addEventListener("touch", function(event)
        if event.phase == "ended" then
            stopAudio()
            composer.gotoScene("Pages.Page02", {effect = "slideLeft", time = 500})
        end
    end)
    adicionarTextoBotaoProximaPagina(sceneGroup)

    local buttonPaginaAnterior = display.newImageRect(sceneGroup, "image/Buttons/pagina_anterior.png", buttonSize, buttonSize)
    buttonPaginaAnterior.x = largura - buttonSize * 1.5 - 580
    buttonPaginaAnterior.y = altura - buttonSize / 2 - 30
    buttonPaginaAnterior:addEventListener("touch", function(event)
        if event.phase == "ended" then
            stopAudio()
            composer.gotoScene("Pages.Capa", {effect = "slideRight", time = 500})
        end
    end)
    adicionarTextoBotaoPaginaAnterior(sceneGroup)
    
    criarRecursos()
    criarNomades()
end

function scene:show(event)
    local phase = event.phase
    if phase == "will" then
        Runtime:addEventListener("enterFrame", moverNomades)
    elseif phase == "did" then
        -- Code here runs when the scene is entirely on screen
    end
end

function scene:hide(event)
    local phase = event.phase
    if phase == "will" then
        limparNomades() -- Limpar os nomades ao ocultar a cena
        limparRecursos() -- Limpar os recursos ao ocultar a cena
        Runtime:removeEventListener("enterFrame", moverNomades)
    elseif phase == "did" then
        -- Code here runs when the scene is off screen
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)

return scene
