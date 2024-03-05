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
local sementes = {}
local balaoTexto
local isIdeia = false


local function criarChao(sceneGroup)
    chao = display.newRect(sceneGroup, 0, altura - 90, largura + 800, 180)
    chao:setFillColor(0.64, 0.16, 0.16) -- Defina a cor alpha para 0 para tornar a base invisível
    chao.userData = {name = "chao"}
    physics.addBody(chao, "static") -- Definindo a base como um corpo estático
end

local function criarBarreira(sceneGroup)
    criarBarreira = display.newRect(sceneGroup, 0, altura - 90, largura + 800, 130)
    criarBarreira:setFillColor(1, 1, 1) -- Defina a cor alpha para 0 para tornar a base invisível
    criarBarreira.userData = {name = "barreira"}
    physics.addBody(criarBarreira, "static") -- Definindo a base como um corpo estático
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
    peDeTrigo = display.newImageRect(sceneGroup, "image/Page02/plantacao_trigo.png", largura * 0.5, altura * 0.4)
    peDeTrigo.x = largura * 0.5 - 150
    peDeTrigo.y = altura - 140 - peDeTrigo.height * 0.4
    physics.addBody(peDeTrigo, "static") -- Torna o pé de trigo um corpo estático
end

local function criarImagensFasesTrigo()
     sementes = {
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
     }
end

local function exibirBalao(sceneGroup)
    -- Exibir o balão com o texto "Mexa o Dispositivo"
    balaoTexto = display.newText({
        text = "Chacoalhe \n o Dispositivo",
        x = display.contentCenterX + 130,
        y = display.contentCenterY + 150,
        font = native.systemFont,
        fontSize = 30
    })
    balaoTexto:setFillColor(1, 0, 0)  -- Cor vermelha para o texto
    sceneGroup:insert(balaoTexto)
end

local function esconderBalao()
    -- Remover o balão da cena
    if balaoTexto then
        balaoTexto:removeSelf()
        balaoTexto = nil
    end
end

local function onCollision(event)
    if event.phase == "began" then
        local obj1 = event.object1
        local obj2 = event.object2

        if obj1.userData and obj2.userData then
            -- Verificar se o objeto é uma semente e o chão
            if ((obj1.userData.name == "semente" and obj2.userData.name == "chao") or (obj1.userData.name == "chao" and obj2.userData.name == "semente")) then
                local semente
                -- Define a semente como objeto correto
                if (obj1.userData.name == "semente") then
                    semente = obj1
                else
                    semente = obj2
                end 
                -- Agende a remoção da física da semente após 15 segundos
                timer.performWithDelay(2000, function()
                    physics.removeBody(semente)                    

                    local posicao_inicial_x = semente.x
                    local posicao_inicial_y = semente.y

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
                        "image/Page02/trigo_decima_muda.png"
                    }

                    local fase_atual = 1

                    local function proximaFase()
                        -- Verificar se há uma fase posterior
                        if fase_atual < #fases_trigo then
                            -- Remover a imagem atual da semente
                            display.remove(semente)

                            -- Criar a próxima fase da imagem da semente
                            local imagem = fases_trigo[fase_atual + 1]
                            local altura_semente = 0
                            local altura_semente_original = 50 -- Altura original da semente

                            if string.find(imagem, "semente_germinada.png") then
                                altura_semente = 25
                            elseif string.find(imagem, "trigo_primeira_muda.png") then
                                altura_semente = 35
                            elseif string.find(imagem, "trigo_segunda_muda.png") then
                                altura_semente = 45
                            elseif string.find(imagem, "trigo_terceira_muda.png") then
                                altura_semente = 55
                            elseif string.find(imagem, "trigo_quarta_muda.png") then
                                altura_semente = 65
                            elseif string.find(imagem, "trigo_quinta_muda.png") then
                                altura_semente = 75
                            elseif string.find(imagem, "trigo_sexta_muda.png") then
                                altura_semente = 100
                            elseif string.find(imagem, "trigo_setima_muda.png") then
                                altura_semente = 125
                            elseif string.find(imagem, "trigo_oitava_muda.png") then
                                altura_semente = 150
                            elseif string.find(imagem, "trigo_nona_muda.png") then
                                altura_semente = 200
                            elseif string.find(imagem, "trigo_decima_muda.png") then
                                altura_semente = 250
                                local ideia = display.newImageRect("image/Page02/ideia.png", largura * 0.09, altura * 0.09) 
                                ideia.x = largura - 95
                                ideia.y = altura - altura * 0.43 -- Ajuste para a parte inferior da tela
                                mySceneGroup:insert(ideia)
                            end

                            semente = display.newImageRect(mySceneGroup, imagem, 50, altura_semente)
                            semente.x = posicao_inicial_x
                            -- Calcular a diferença na altura para ajustar a posição Y
                            local diferenca_altura = altura_semente - altura_semente_original
                            semente.y = posicao_inicial_y - diferenca_altura / 2 -- Ajuste para manter a mesma posição Y

                            -- Atualizar o contador de fase
                            fase_atual = fase_atual + 1
                        else
                            -- Se não houver mais fases, remover o ouvinte de colisão
                            Runtime:removeEventListener("collision", onCollision)
                        end
                    end
                    -- Ativar a mudança de fase a cada 5 segundos
                    timer.performWithDelay(5000, proximaFase, 10)
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
        -- Esconder o balão quando o dispositivo é movido
        esconderBalao()
        local sceneGroup = scene.view
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
            sound = audio.loadSound("audio/Page02/audioPage02.mp3")
            audio.play(sound, {loops = -1})
        end
        buttonPlay.x = largura / 2
        buttonPlay.y = altura * 0.195 + 750
        buttonPlay:addEventListener("touch", onTouch)
    end
end

local function createTitulo(sceneGroup)
    local titulo = display.newText({
        text = "Os Primórdios da Agricultura",
        font = native.newFont("Bold"),
        fontSize = 40  -- Usar uma porcentagem da largura da tela para o tamanho da fonte
    })
    titulo.x = largura * 0.5
    titulo.y = altura * 0.07
    titulo:setFillColor(0.2 * (52/255), 0.2 * (131/255), 0.2 * (235/255))
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
    subtitulo:setFillColor(0.2 * (52/255), 0.2 * (131/255), 0.2 * (235/255))
    sceneGroup:insert(subtitulo)
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
    texto = "Há cerca de doze mil anos, durante a Pré-história, alguns indivíduos de povos caçadores-coletores notaram que alguns grãos que eram coletados da natureza para a sua alimentação poderiam ser enterrados, isto é, 'semeados' a fim de produzir novas plantas iguais às que os originaram."
    criarTextoJustificado(sceneGroup, texto, display.contentCenterX, 150, largura - 60, 100, native.newFont("Bold"), 35, 40)
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
function scene:create(event)
    local sceneGroup = self.view
    mySceneGroup = sceneGroup
    -- Adicionar um retângulo azul para simular o céu
    local ceu = display.newRect(sceneGroup, 0, 0, largura, altura)
    ceu.anchorX = 0
    ceu.anchorY = 0
    ceu:setFillColor(0.53, 0.81, 0.98)-- Cor azul do céu

    -- -- Adicionar a imagem de fundo na parte inferior da tela
    -- local background = display.newImageRect(sceneGroup, "image/Page02/texto2.png", largura + 50, altura * 0.600)
    -- background.anchorX = 0
    -- background.anchorY = 1
    -- background.x = - 30
    -- background.y = altura - 400

    createTitulo(sceneGroup)
    createTexto(sceneGroup)
    -- Exibir o balão com o texto "Mexa o Dispositivo"
    exibirBalao(sceneGroup)

    local nomade = display.newImageRect("image/Page02/nomade2.png", largura * 0.4, altura * 0.4) 
    nomade.x = largura - 200
    nomade.y = altura - altura * 0.28 -- Ajuste para a parte inferior da tela
    sceneGroup:insert(nomade)

    physics.start()
    --Criar a base (chão)
    criarChao(sceneGroup)
    criarPeDeTrigo(sceneGroup)
    criarImagensFasesTrigo()

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
            composer.gotoScene("Pages.Page03", {effect = "slideLeft", time = 500})
        end
    end)
    adicionarTextoBotaoProximaPagina(sceneGroup)

    local buttonPaginaAnterior = display.newImageRect(sceneGroup, "image/Buttons/pagina_anterior.png", buttonSize, buttonSize)
    buttonPaginaAnterior.x = largura - buttonSize * 1.5 - 580
    buttonPaginaAnterior.y = altura - buttonSize / 2 - 30
    buttonPaginaAnterior:addEventListener("touch", function(event)
        if event.phase == "ended" then
            stopAudio()
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