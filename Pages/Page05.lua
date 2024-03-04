local composer = require("composer")
local scene = composer.newScene()

local largura, altura = 768, 1024

local bottomAreaHeight = display.contentHeight - 500
local trigoWidth = 650
local trigoHeight = 200
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
local balaoTexto

local function criarCafanhotos()
    if not trigoDevorado and gerarGafanhotos then
        local cafanhoto = display.newImageRect("image/Page05/gafanhoto.png", 50, 50)
        cafanhoto.x = math.random(display.contentWidth)
        cafanhoto.y = math.random(bottomAreaHeight, display.contentHeight)

        local trigoX, trigoY = newTrigoX, newTrigoY

        -- Calcular a direção correta para a nova posição do trigo
        trigoY = trigoY + trigoHeight / 2 + 80 -- Ajuste para considerar a altura do trigo
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
    trigo.y = newTrigoY + 180
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

-- Função para atualizar o texto do balão do objeto1
local function atualizarTextoBalao(objeto1, balaoTexto)
    -- Verifica se os objetos 2 e 3 estão na área do objeto1
    local areaInteracao = 50 -- Área de interação entre os objetos
    local distanciaObjeto2 = math.sqrt((objeto1.x - objeto2.x)^2 + (objeto1.y - objeto2.y)^2)
    local distanciaObjeto3 = math.sqrt((objeto1.x - objeto3.x)^2 + (objeto1.y - objeto3.y)^2)

    if distanciaObjeto2 < areaInteracao and distanciaObjeto3 < areaInteracao then
        balaoTexto.text = "Coloque os itens dentro de mim"
    elseif distanciaObjeto2 < areaInteracao then
        balaoTexto.text = "Por favor, coloque a tocha dentro de mim"
    -- elseif distanciaObjeto3 < areaInteracao then
    --     balaoTexto.text = "Por favor, me arraste até a plantação"
    else
        balaoTexto.text = "Por favor, coloque o enxofre dentro de mim"
    end

    print(isCriadoObjetoNovo)
    if isCriadoObjetoNovo then
        balaoTexto.text = "Por favor, me arraste até a plantação"
    end
end

local function toque(event, sceneGroup, objeto)
    local target = event.target
    if event.phase == "began" then
        display.getCurrentStage():setFocus(target)
        target.isFocus = true
        target.markX = target.x
        target.markY = target.y
        atualizarTextoBalao(objeto, balaoTexto)
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
                novoObjeto.y = halfScreenHeight * 1.2

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
                atualizarTextoBalao(objeto, balaoTexto)
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
            sound = audio.loadSound("audio/Page05/audioPage05.mp3")
            audio.play(sound, {loops = -1})
        end
        buttonPlay.x = largura / 2
        buttonPlay.y = altura * 0.195 + 750
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
        text = "Controle de Pragas e Doenças",
        font = native.newFont("Bold"),
        fontSize = 40
    })
    -- Ajuste a posição do titulo para a parte superior da tela
    titulo.x = display.contentCenterX
    titulo.y = altura * 0.293 - 200
    -- Define a cor do titulo
    titulo:setFillColor(1, 1, 1)
    -- Insere o titulo no grupo da cena
    sceneGroup:insert(titulo)
end

-- Função para criar o texto
local function createTexto(sceneGroup)
    local texto = "Defensivos agrícolas remontam à antiguidade. Sumérios (4.500 anos) usavam enxofre; chineses (3.200 anos), mercúrio e arsênico. Chineses entenderam microrganismos e ajustes de plantio para evitar pragas há 2.500 anos. Gregos e romanos usavam fumigantes. Chineses lideraram controle biológico com formigas. Na Europa pós-Império Romano, houve declínio do conhecimento biológico em favor da fé religiosa, revertido na Renascença. No século 17, ressurgiu interesse pelo controle biológico e introdução de defensivos agrícolas naturais."
    criarTextoJustificado(sceneGroup, texto, display.contentCenterX, 170, largura - 40, 500, native.newFont("Bold"), 30, 30)
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


function scene:create(event)
    local sceneGroup = self.view

    -- ADICIONAR O CEU NA TELA
    local ceu = display.newRect(sceneGroup, 0, 0, largura, altura)
    ceu.anchorX = 0
    ceu.anchorY = 0
    ceu:setFillColor(0.53, 0.81, 0.98) 

    -- ADICIONAR O BACKGROUND NA TELA. AREA DA PAISAGEM
    local background = display.newImageRect(sceneGroup, "image/Page01/background.png", largura, altura * 0.7)
    background.anchorX = 0
    background.anchorY = 1
    background.x = 0
    background.y = altura

    createTitulo(sceneGroup)
    createTexto(sceneGroup)
    criarPlantacaoDeTrigo(sceneGroup)

    local halfScreenHeight = display.contentHeight / 2
    
    -- AREA CRIAR OS TRÊS OBJETOS DE ARRASTAR NA TELA
    objeto1 = display.newImageRect(sceneGroup, "image/Page05/pote.png", 100, 100)
    objeto1.x = 200
    objeto1.y = halfScreenHeight * 1.2
    objeto1:addEventListener("touch", function(event) toque(event, sceneGroup, objeto1) end)

    balaoTexto = display.newText({
        parent = sceneGroup,
        text = "Arraste os itens para dentro de mim",
        x = objeto1.x + 20,
        y = objeto1.y - 70,
        width = 170,
        height = 0,
        font = native.newFont("Bold"),
        fontSize = 16
    })
    balaoTexto:setFillColor(1, 0, 0)

    -- Crie um objeto de retângulo para representar o balão de texto
    local balaoRetangulo = display.newRoundedRect(
        sceneGroup, -- Defina o grupo da cena como o pai do retângulo
        balaoTexto.x, -- Posição x do balão de texto
        balaoTexto.y, -- Posição y do balão de texto
        balaoTexto.width + 20, -- Largura do balão de texto + margem
        balaoTexto.height + 20, -- Altura do balão de texto + margem
        10 -- Raio dos cantos do retângulo
    )
    balaoRetangulo:setFillColor(0.7, 0.7, 0.7) -- Cor de preenchimento do balão de texto
    balaoRetangulo.strokeWidth = 2 -- Largura da borda do retângulo
    balaoRetangulo:setStrokeColor(0) -- Cor da borda do retângulo

    -- Defina a ordem de exibição para que o balão de texto fique acima do objeto1
    balaoTexto:toFront()
    -- balaoRetangulo:toFront()

    objeto2 = display.newImageRect(sceneGroup, "image/Page05/enxofre.png", 100, 100)
    objeto2.x = 400
    objeto2.y = halfScreenHeight * 1.2
    objeto2:addEventListener("touch", function(event) toque(event, sceneGroup, objeto1) end)

    objeto3 = display.newImageRect(sceneGroup, "image/Page05/tocha.png", 100, 100)
    objeto3.x = 600
    objeto3.y = halfScreenHeight * 1.2
    objeto3:addEventListener("touch", function(event) toque(event, sceneGroup, objeto1) end)


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
            composer.gotoScene("Pages.Page06", {effect = "slideLeft", time = 500})
        end
    end)
    adicionarTextoBotaoProximaPagina(sceneGroup)

    local buttonPaginaAnterior = display.newImageRect(sceneGroup, "image/Buttons/pagina_anterior.png", buttonSize, buttonSize)
    buttonPaginaAnterior.x = largura - buttonSize * 1.5 - 580
    buttonPaginaAnterior.y = altura - buttonSize / 2 - 30
    buttonPaginaAnterior:addEventListener("touch", function (event)
        if event.phase == "ended" then
            stopAudio()
            composer.gotoScene("Pages.Page04", {effect = "slideRight", time = 500})
        end
    end)
    adicionarTextoBotaoPaginaAnterior(sceneGroup)
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
        -- removerTextoBotao()
        -- Remover o texto do botão antes de fazer a transição para a próxima página
        display.remove(textoBotaoProximaPagina)
        textoBotaoProximaPagina = nil
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

    -- display.remove(textoBotaoProximaPagina)

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
