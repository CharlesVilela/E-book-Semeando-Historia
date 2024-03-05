local composer = require("composer")
local scene = composer.newScene()
local mySceneGroup

local largura, altura = 768, 1024 -- Definindo largura e altura
local margem_lateral = 200
local margem_inferior = 150
local count_colhidos = 0
local tamanho_celula = largura * 0.026
local num_casas = 0

local larguraTela = display.contentWidth
local alturaTela = display.contentHeight

local margemX = 150
local margemInferior = 250

local casasCriadas = {}

local sementes = {} -- Lista para armazenar todas as sementes
local fases_trigo = {
    "image/Page02/semente_germinada.png",
    "image/Page02/trigo_primeira_muda.png",
    "image/Page02/trigo_segunda_muda.png",
    "image/Page02/trigo_terceira_muda.png",
    "image/Page02/trigo_quarta_muda.png",
    "image/Page02/trigo_quinta_muda.png",
    "image/Page02/trigo_sexta_muda.png",
    "image/Page02/trigo_setima_muda.png",
    "image/Page02/trigo_oitava_muda.png",
    "image/Page02/trigo_nona_muda.png",
    "image/Page02/trigo_decima_muda.png",
    "image/Page02/trigo_maduro.png" -- Nova fase: trigo maduro
}

local isValide = true
local timers = {}
local balaoTexto

-- local function verificarSobreposicao(x, largura, casasCriadas)
--     for i, casa in ipairs(casasCriadas) do
--         if math.abs(x - casa.x) < (largura + margemX) then
--             return true
--         end
--     end
--     return false
-- end

local function exibirBalaoTexto()
    -- local balao = display.newCircle(arado_leve.x, arado_leve.y - arado_leve.height * 0.4, 50)
    -- balao:setFillColor(1, 1, 0)  -- Cor amarela para o balão
    balaoTexto = display.newText({
        text = "Espere o trigo ficar maduro \n para colhe-lo e aumentar \n a população",
        x = 450, 
        y= 450,
        font = native.systemFont,
        fontSize = 30
    })
    balaoTexto:setFillColor(1, 0, 0)
    mySceneGroup:insert(balaoTexto)
end

local function esconderBalaoTexto()
    print("Chamou remover Balao")
    -- Remover o balão da cena
    if balaoTexto then
        balaoTexto:removeSelf()
        balaoTexto = nil
    end
end

local function criarCasas(sceneGroup)
    print("Chamou para criar casas...")
    
    -- Definindo o tamanho da casa
    local larguraCasa = largura * 0.1
    local alturaCasa = altura * 0.1
    
    -- Definindo os limites para a posição X
    local margemLateral = 100
    local minX = margemLateral
    local maxX = largura - margemLateral - larguraCasa
    
    -- Definindo a margem inferior
    local margemInferior = 180
    
    -- Criando a casa
    local casa = display.newImageRect("image/Page06/casa.png", larguraCasa, alturaCasa)
    
    -- Definindo a posição X aleatória dentro dos limites definidos
    casa.x = math.random(minX, maxX)
    
    -- Definindo a posição Y aleatória, respeitando a parte inferior da tela
    local minY = altura - margemInferior - alturaCasa / 2
    local maxY = altura - margemInferior - alturaCasa
    if minY < 0 then minY = 0 end
    if maxY < 0 then maxY = 0 end
    
    if minY <= maxY then
        casa.y = math.random(minY, maxY)
    else
        casa.y = minY
    end
    
    num_casas = num_casas + 1
    sceneGroup:insert(casa)
end

local function proximaFase(semente)
    if sementes[semente] then 
        local fase = sementes[semente].fase or 1
        if fase <= #fases_trigo then
            local imagem = fases_trigo[fase]
            local altura_semente = 0

            -- Cálculo da altura da semente de acordo com a fase
            if fase > 1 then
                altura_semente = 35 + (fase - 2) * 10
            end

            -- Removendo a imagem atual da semente
            if sementes[semente].imagem then
                display.remove(sementes[semente].imagem)
            end

            -- Criando a próxima fase da imagem da semente
            sementes[semente].imagem = display.newImageRect(imagem, 50, altura_semente)
            sementes[semente].imagem.x = sementes[semente].x
            sementes[semente].imagem.y = sementes[semente].y
            sementes[semente].fase = fase + 1

            -- Ativar próxima fase, a menos que seja a última
            if fase < #fases_trigo - 1 then
                timer.performWithDelay(1000, function()
                    proximaFase(semente)
                end)
            else
                sementes[semente].ultimaFase = true
                sementes[semente].maduro = true
            end
        -- else
        --     -- Se o trigo estiver maduro, mostrar mensagem de colheita
        end
    end
end

-- local function iniciarCrescimento(mySceneGroup)
    
--     if isValide then
--         for i = 1, 5 do
--             local semente = display.newImageRect("image/Page02/semente_germinada.png", 50, 50)
--             semente.x = math.random(margem_lateral, largura - margem_lateral)
--             semente.y = altura - margem_inferior
--             sementes[semente] = {x = semente.x, y = semente.y, fase = 1, ultimaFase = false}
--             proximaFase(semente)
--             semente:addEventListener("tap", function(event)
--                 -- Colher o trigo
--                 local sementeClicada = event.target
--                 if sementeClicada and sementes[sementeClicada] and sementes[sementeClicada].maduro then
--                     -- native.showAlert("Colher", "Você colheu o trigo!", {"OK"})
--                     display.remove(sementes[sementeClicada].imagem)
--                     sementes[sementeClicada] = nil
--                     local colhidos = true
--                     count_colhidos = count_colhidos + 1
                    
--                     for key, _ in pairs(sementes) do
--                         if not sementes[key].maduro then
--                             colhidos = false
--                             break
--                         end
--                     end
--                     if colhidos then
--                         -- Reiniciar o processo
--                         timer.performWithDelay(3000, function ()
--                             -- for semente, _ in pairs(sementes) do
--                             --     display.remove(sementes[semente].imagem)
--                             --     sementes[semente] = nil
--                             -- end
    
--                             if count_colhidos % 2 == 1 and num_casas < 7 then
--                                 criarCasas(mySceneGroup)
--                             end
    
--                             if count_colhidos <= 30 then
--                                 iniciarCrescimento(mySceneGroup)
--                             end
--                         end)
--                     end
--                 end
--             end)
--         end
--     end
-- end

local function iniciarCrescimento(mySceneGroup)
    
    if isValide then
        for i = 1, 5 do
            local semente = display.newImageRect(mySceneGroup, "image/Page02/semente_germinada.png", 50, 50)
            semente.x = math.random(margem_lateral, largura - margem_lateral)
            semente.y = altura - margem_inferior
            sementes[semente] = {x = semente.x, y = semente.y, fase = 1, ultimaFase = false}
            -- Criando temporizador para próxima fase
            local timerID = timer.performWithDelay(1000, function()
                proximaFase(semente)
            end)
            table.insert(timers, timerID)  -- Armazenar o ID do temporizador
            semente:addEventListener("tap", function(event)
                -- Colher o trigo
                local sementeClicada = event.target
                if sementeClicada and sementes[sementeClicada] and sementes[sementeClicada].maduro then
                    -- native.showAlert("Colher", "Você colheu o trigo!", {"OK"})
                    display.remove(sementes[sementeClicada].imagem)
                    sementes[sementeClicada] = nil
                    local colhidos = true
                    count_colhidos = count_colhidos + 1
                    esconderBalaoTexto()
                    
                    
                    for key, _ in pairs(sementes) do
                        if not sementes[key].maduro then
                            colhidos = false
                            break
                        end
                    end
                    if colhidos then
                        -- Reiniciar o processo
                        timer.performWithDelay(3000, function ()
                            -- for semente, _ in pairs(sementes) do
                            --     display.remove(sementes[semente].imagem)
                            --     sementes[semente] = nil
                            -- end
    
                            if count_colhidos % 2 == 1 and num_casas < 7 then
                                criarCasas(mySceneGroup)
                            end
    
                            if count_colhidos <= 30 then
                                iniciarCrescimento(mySceneGroup)
                            end
                        end)
                    end
                end
            end)
        end
    end
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
            sound = audio.loadSound("audio/Page06/audioPage06.mp3")
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
        texto:setFillColor(0.2 * (52/255), 0.2 * (131/255), 0.2 * (235/255))
        sceneGroup:insert(texto)
    end
end

local function createTitulo(sceneGroup)

    local titulo = display.newText({
        text = "Inicio de uma vida sedentaria",
        font = native.newFont("Bold"),
        fontSize = 40
    })
    -- Ajuste a posição do titulo para a parte superior da tela
    titulo.x = display.contentCenterX
    titulo.y = altura * 0.293 - 200
    -- Define a cor do titulo
    titulo:setFillColor(0.2 * (52/255), 0.2 * (131/255), 0.2 * (235/255))
    -- Insere o titulo no grupo da cena
    sceneGroup:insert(titulo)
end

-- Função para criar o texto
local function createTexto(sceneGroup)
    local texto = "A agricultura e consequentemente o sedentarismo impactaram profundamente a vida humana. Foi por conta disso que houve um aumento significativo no número de seres humanos. As práticas anteriores, de caça e coleta, impediam o crescimento demográfico, enquanto o sedentarismo promoveu um aumento populacional."
    criarTextoJustificado(sceneGroup, texto, display.contentCenterX, 170, largura - 40, 500, native.newFont("Bold"), 30, 30)
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

local function removerSementes()
    -- Remover todas as sementes de trigo
    for semente, _ in pairs(sementes) do
        display.remove(sementes[semente].imagem)
        sementes[semente] = nil
    end
end

function scene:create(event)
    local sceneGroup = self.view
    mySceneGroup = sceneGroup
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
    createTexto(sceneGroup)

    exibirBalaoTexto()

    -- Iniciar o crescimento do trigo
    iniciarCrescimento(sceneGroup)

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
            -- isValide = false
            -- removerSementes()
            composer.gotoScene("Pages.ContraCapa", {effect = "slideLeft", time = 500})
        end
    end)
    adicionarTextoBotaoProximaPagina(sceneGroup)

    local buttonPaginaAnterior = display.newImageRect(sceneGroup, "image/Buttons/pagina_anterior.png", buttonSize, buttonSize)
    buttonPaginaAnterior.x = largura - buttonSize * 1.5 - 580
    buttonPaginaAnterior.y = altura - buttonSize / 2 - 30
    buttonPaginaAnterior:addEventListener("touch", function (event)
        if event.phase == "ended" then
            -- isValide = false
            -- removerSementes()
            composer.gotoScene("Pages.Page05", {effect = "slideRight", time = 500})
        end
    end)
    adicionarTextoBotaoPaginaAnterior(sceneGroup)

end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        
    elseif (phase == "did") then
        -- Code here runs when the scene is entirely on screen
    end
end

function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        removerSementes()
        isValide = false

         -- Cancelar todos os temporizadores
         for _, timerID in ipairs(timers) do
            timer.cancel(timerID)
        end
        timers = {}  -- Limpar a tabela de temporizadores

    elseif (phase == "did") then
        
        -- Code here runs immediately after the scene goes entirely off screen
    end
end

function scene:destroy(event)
    local sceneGroup = self.view

    if event.phase == "did" then
        isValide = false
        removerSementes()

        sceneGroup:removeSelf()
        sceneGroup = nil
    end

    -- -- Remover todas as sementes de trigo
    -- for semente, _ in pairs(sementes) do
    --     display.remove(sementes[semente].imagem)
    --     sementes[semente] = nil
    -- end

    -- Code here runs prior to the removal of scene's view
    
end

-- Scene event function listeners
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
