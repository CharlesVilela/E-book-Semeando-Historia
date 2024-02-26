local composer = require("composer")
local scene = composer.newScene()

local largura, altura = display.actualContentWidth, display.actualContentHeight

-- Definindo altura da metade da tela
local metade_altura = altura / 2

local bottomAreaHeight = display.contentHeight - 500
local trigoWidth = 1000
local trigoHeight = 400
local trigoDevorado = false
local gerarGafanhotos = true
local newTrigoX = display.contentWidth / 2
local newTrigoY = bottomAreaHeight + trigoHeight / 2

local objeto1, objeto2, objeto3, novoObjeto
local objetoProximo = false
local countNovoObjeto = 0
local isAfastarGafanhotos = false
local isCriadoObjetoNovo = false

local trigo

local function criarCafanhotos()
    if not trigoDevorado and gerarGafanhotos then
        local cafanhoto = display.newImageRect("image/Page05/gafanhoto.png", 50, 50)
        cafanhoto.x = math.random(display.contentWidth)
        cafanhoto.y = math.random(bottomAreaHeight, display.contentHeight)

        local trigoX, trigoY = newTrigoX, newTrigoY

        local dirX, dirY = trigoX - cafanhoto.x, trigoY - cafanhoto.y
        local magnitude = math.sqrt(dirX^2 + dirY^2)
        dirX, dirY = dirX / magnitude, dirY / magnitude

        local speed = math.random(50, 100)

        transition.to(cafanhoto, {
            x = trigoX,
            y = trigoY,
            time = (magnitude / speed) * 1000,
            onComplete = function()
                if cafanhoto then
                    display.remove(cafanhoto)
                    trigoWidth = trigoWidth - 5
                    if trigoWidth <= 0 then
                        trigoWidth = 0
                        trigoDevorado = true
                    end
                    if trigo then
                        trigo.width = trigoWidth
                    end
                end
            end
        })
    else
        for i = scene.view.numChildren, 1, -1 do
            local child = scene.view[i]
            if child and child.x and child.y then
                transition.to(child, { x = -100, y = -100, time = 1000, onComplete = function() display.remove(child) end })
            end
        end
    end
end

local function exibirGafanhotosContinuamente()
    if isAfastarGafanhotos == false and trigoDevorado == false then
        criarCafanhotos()
        if not trigoDevorado then
            timer.performWithDelay(500, exibirGafanhotosContinuamente)
        end
    end
end

-- Função para remover os gafanhotos da tela
local function removerGafanhotos()
    for i = scene.view.numChildren, 1, -1 do
        local child = scene.view[i]
        if child and child.tipo == "gafanhoto" then
            display.remove(child)
        end
    end
end

local function criarPlantacaoDeTrigo(sceneGroup)
    trigo = display.newImageRect(sceneGroup, "image/Page05/plantacao_trigo.png", trigoWidth, trigoHeight)
    trigo.x = newTrigoX
    trigo.y = newTrigoY - 100
end

local function afastarGafanhotos()
    if not trigoDevorado then
        for i = scene.view.numChildren, 1, -1 do
            local child = scene.view[i]
            if child.x and child.y and child.tipo == "gafanhoto" then
                local targetX, targetY
                if isAfastarGafanhotos then
                    if child.x > display.contentWidth / 2 then
                        targetX = -100
                    else
                        targetX = display.contentWidth + 100
                    end
                    if child.y > display.contentHeight / 2 then
                        targetY = -100
                    else
                        targetY = display.contentHeight + 100
                    end
                else
                    targetX = display.contentWidth + 100
                    targetY = display.contentHeight + 100
                end
                transition.to(child, { x = targetX, y = targetY, time = 1000, onComplete = function() display.remove(child) end })
            end
        end
    end
end

local function verificarProximidadeComTrigo(novoObjeto, trigo)
    if novoObjeto and trigo then
        local threshold2 = 100
        local distanciaXTrigo = math.abs(trigo.x - novoObjeto.x)
        local distanciaYTrigo = math.abs(trigo.y - novoObjeto.y)
        if distanciaXTrigo < threshold2 and distanciaYTrigo < threshold2 then
            isAfastarGafanhotos = true
            afastarGafanhotos()
        end
    end
end

local function calcularDistancia(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

local function verificarProximidade(objeto1, objeto2, objeto3, threshold)
    local distancia1_2 = calcularDistancia(objeto1.x, objeto1.y, objeto2.x, objeto2.y)
    local distancia1_3 = calcularDistancia(objeto1.x, objeto1.y, objeto3.x, objeto3.y)
    local distancia2_3 = calcularDistancia(objeto2.x, objeto2.y, objeto3.x, objeto3.y)

    if distancia1_2 < threshold and distancia1_3 < threshold and distancia2_3 < threshold then
        objetoProximo = true
    else
        objetoProximo = false
    end
end

local function toque(event, sceneGroup)
    local target = event.target
    if event.phase == "began" then
        display.getCurrentStage():setFocus(target)
        target.isFocus = true
        target.markX = target.x
        target.markY = target.y
    elseif target.isFocus then
        if event.phase == "moved" then
            target.x = event.x - event.xStart + target.markX
            target.y = event.y - event.yStart + target.markY

            local threshold = 50

            if objetoProximo == false then
                verificarProximidade(objeto1, objeto2, objeto3, threshold)
            end

            if objetoProximo and countNovoObjeto < 1 then
                display.remove(objeto1)
                display.remove(objeto2)
                display.remove(objeto3)

                local halfScreenHeight = display.contentHeight / 2
                novoObjeto = display.newImageRect(sceneGroup, "image/Page05/pote.png", 100, 100)
                novoObjeto.x = 100
                novoObjeto.y = halfScreenHeight * 1.35

                local imagemAcompanhante = display.newImageRect(sceneGroup, "image/Page05/fumaca.png", 200, 200)
                imagemAcompanhante.x = novoObjeto.x
                imagemAcompanhante.y = novoObjeto.y - novoObjeto.height * 0.5 - 50

                novoObjeto:addEventListener("touch", function(event)
                    local target = event.target
                    if event.phase == "began" then
                        display.getCurrentStage():setFocus(target)
                        target.isFocus = true
                        target.markX = target.x
                        target.markY = target.y
                    elseif target.isFocus then
                        if event.phase == "moved" then
                            target.x = event.x - event.xStart + target.markX
                            target.y = event.y - event.yStart + target.markY

                            imagemAcompanhante.x = target.x
                            imagemAcompanhante.y = target.y - target.height * 0.5 - 50

                            countNovoObjeto = countNovoObjeto + 1
                            isCriadoObjetoNovo = true
                            verificarProximidadeComTrigo(novoObjeto, trigo)
                        elseif event.phase == "ended" or event.phase == "cancelled" then
                            display.getCurrentStage():setFocus(nil)
                            target.isFocus = false
                        end
                    end
                    return true
                end)
                countNovoObjeto = countNovoObjeto + 1
                isCriadoObjetoNovo = true
            end
        elseif event.phase == "ended" or event.phase == "cancelled" then
            display.getCurrentStage():setFocus(nil)
            target.isFocus = false
        end
    end
    return true
end

local function stopAudio()
    isAudioPlaying = false
    buttonPlay:removeSelf()
    buttonPlay = display.newImageRect(scene.view, "image/Fone/audio_desligado.png", 140, 140)
    audio.stop()
end

local function onTouch(event)
    if event.phase == "ended" then
        if isAudioPlaying then
            stopAudio()
        else
            isAudioPlaying = true
            buttonPlay:removeSelf()
            buttonPlay = display.newImageRect(scene.view, "image/Fone/audio_ligado.png", 250, 140)
            sound = audio.loadSound("audio/Page01/audioPage01.mp3")
            audio.play(sound, {loops = -1})
        end
        buttonPlay.x = display.contentWidth - 150
        buttonPlay.y = 200
        buttonPlay:addEventListener("touch", onTouch)
    end
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

local function createTitulo(sceneGroup)
    local titulo = display.newText({
        text = "Controle de Pragas \n e Doenças",
        font = native.newFont("Bold"),
        fontSize = 85
    })
    titulo.x = display.contentCenterX
    titulo.y = 300
    titulo:setFillColor(1, 1, 1)
    sceneGroup:insert(titulo)
end

local function createTexto(sceneGroup)
    local texto = "Defensivos agrícolas remontam à antiguidade. Sumérios (4.500 anos) usavam enxofre; chineses (3.200 anos), mercúrio e arsênico. Chineses entenderam microrganismos e ajustes de plantio para evitar pragas há 2.500 anos. Gregos e romanos usavam fumigantes. Chineses lideraram controle biológico com formigas. Na Europa pós-Império Romano, houve declínio do conhecimento biológico em favor da fé religiosa, revertido na Renascença. No século 17, ressurgiu interesse pelo controle biológico e introdução de defensivos agrícolas naturais."
    criarTextoJustificado(sceneGroup, texto, display.contentCenterX, 450, largura - 40, 500, native.newFont("Bold"), 50, 55)
end

function scene:create(event)
    local sceneGroup = self.view

    -- Adicionar um retângulo azul para simular o céu
    local ceu = display.newRect(sceneGroup, 0, 0, largura, metade_altura * 2)
    ceu.anchorX = 0
    ceu.anchorY = 0
    ceu:setFillColor(0.53, 0.81, 0.98) -- Cor azul do céu
    
    
    local background = display.newImageRect(sceneGroup, "image/Page01/background.png", largura, altura * 0.5)
    background.anchorX = 0
    background.anchorY = 1
    background.x = 0
    background.y = altura

    createTitulo(sceneGroup)
    createTexto(sceneGroup)
    criarPlantacaoDeTrigo(sceneGroup)

    local halfScreenHeight = display.contentHeight / 2

    objeto1 = display.newImageRect(sceneGroup, "image/Page05/pote.png", 100, 100)
    objeto1.x = 200
    objeto1.y = halfScreenHeight * 1.35
    objeto1:addEventListener("touch", function(event) toque(event, sceneGroup) end)

    objeto2 = display.newImageRect(sceneGroup, "image/Page05/enxofre.png", 100, 100)
    objeto2.x = 400
    objeto2.y = halfScreenHeight * 1.35
    objeto2:addEventListener("touch", function(event) toque(event, sceneGroup) end)

    objeto3 = display.newImageRect(sceneGroup, "image/Page05/tocha.png", 100, 100)
    objeto3.x = 600
    objeto3.y = halfScreenHeight * 1.35
    objeto3:addEventListener("touch", function(event) toque(event, sceneGroup) end)

    if isAudioPlaying then
        buttonPlay = display.newImageRect(sceneGroup, "image/Fone/audio_ligado.png", 301, 167)
    else
        buttonPlay = display.newImageRect(sceneGroup, "image/Fone/audio_desligado.png", 140, 140)
    end
    buttonPlay.x = display.contentWidth - 150
    buttonPlay.y = 200
    buttonPlay:addEventListener("touch", onTouch)

    local buttonProximaPagina = display.newImageRect(sceneGroup, "image/Buttons/proxima_pagina.png", 200, 200)
    buttonProximaPagina.x = largura - 250 / 2 - 20
    buttonProximaPagina.y = altura - 250 / 2 - 20

    buttonProximaPagina:addEventListener("touch", function (event)
        if event.phase == "ended" then
            composer.gotoScene("Pages.Page01", {effect = "slideLeft", time = 500})
        end
    end)

    local buttonPaginaAnterior = display.newImageRect(sceneGroup, "image/Buttons/pagina_anterior.png", 200, 200)
    buttonPaginaAnterior.x = largura - 950
    buttonPaginaAnterior.y = altura - 250 / 2 - 20

    buttonPaginaAnterior:addEventListener("touch", function (event)
        if event.phase == "ended" then
            composer.gotoScene("Pages.Page01", {effect = "slideRight", time = 500})
        end
    end)

end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        exibirGafanhotosContinuamente()
    elseif phase == "did" then
    end
end

function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- composer.removeScene("Pages.Page05")
        gerarGafanhotos = false
        removerGafanhotos()
        stopAudio()
    elseif phase == "did" then
    end
end

function scene:destroy(event)
    local sceneGroup = self.view

    objeto1:removeEventListener("touch", toque)
    objeto2:removeEventListener("touch", toque)
    objeto3:removeEventListener("touch", toque)
    buttonPlay:removeEventListener("touch", onTouch)

    display.remove(objeto1)
    display.remove(objeto2)
    display.remove(objeto3)
    display.remove(buttonPlay)
    objeto1 = nil
    objeto2 = nil
    objeto3 = nil
    buttonPlay = nil
    audio.stop()

    gerarGafanhotos = false

    removerGafanhotos()

    for i = sceneGroup.numChildren, 1, -1 do
        local child = sceneGroup[i]
        display.remove(child)
    end
    composer.removeScene("scene")
    sceneGroup = nil
    
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene

-- What adjustments would you like to make to this code?
