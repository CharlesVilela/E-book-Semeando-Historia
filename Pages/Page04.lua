local composer = require("composer")

-- Definição da cena
local scene = composer.newScene()

-- Altura da área onde os cafanhotos podem aparecer (parte inferior) com espaço de 500 pixels
local bottomAreaHeight = display.contentHeight - 500

-- Tamanho inicial da plantação de trigo
local trigoWidth = 1000
local trigoHeight = 400 -- Altura aumentada da plantação de trigo

-- Variável para controlar se a plantação de trigo foi devorada
local trigoDevorado = false

-- Posição da nova plantação de trigo
local newTrigoX = display.contentWidth / 2
local newTrigoY = bottomAreaHeight + trigoHeight / 2

local objeto1, objeto2, objeto3, novoObjeto
local objetoProximo = false
local countNovoObjeto = 0

-- Função para criar cafanhotos
local function criarCafanhotos()
    -- Verifica se ainda há trigo
    if not trigoDevorado then
        local cafanhoto = display.newImageRect("image/Page04/gafanhoto.png", 50, 50)
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
                        trigoDevorado = true  -- Define que a plantação de trigo foi devorada
                    end
                    trigo.width = trigoWidth
                end
            end
        })
    else
        -- Se não houver trigo, faça os gafanhotos voarem para fora da tela
        for i = scene.view.numChildren, 1, -1 do
            local child = scene.view[i]
            if child and child.x and child.y then
                transition.to(child, { x = -100, y = -100, time = 1000, onComplete = function() display.remove(child) end })
            end
        end
    end
end


-- Função para exibir cafanhotos continuamente
local function exibirCafanhotosContinuamente()
    criarCafanhotos()
    -- Verifica se ainda há trigo antes de chamar a função novamente
    if not trigoDevorado then
        timer.performWithDelay(500, exibirCafanhotosContinuamente)
    end
end

local function criarPlantacaoDeTrigo(sceneGroup)
    -- Criando a plantação de trigo com espaço entre a borda inferior de 500 pixels
    trigo = display.newImageRect("image/Page04/plantacao_trigo.png", trigoWidth, trigoHeight)
    trigo.x = newTrigoX
    trigo.y = newTrigoY
    sceneGroup:insert(trigo)
end

-- Função para afastar os gafanhotos quando os objetos são juntados
local function afastarGafanhotos()
    if not trigoDevorado then
        for i = scene.view.numChildren, 1, -1 do
            local child = scene.view[i]
            if child.x and child.y then
                transition.to(child, { x = display.contentWidth + 100, y = display.contentHeight + 100, time = 1000, onComplete = function() display.remove(child) end })
            end
        end
    end
end

-- Verificar se o novo objeto está próximo da plantação de trigo
local function verificarProximidadeComTrigo(novoObjeto, trigo)
    print("Chamou a função verificarProximidadeComTrigo")
    if novoObjeto and trigo then
        local threshold2 = 100 -- Distância de proximidade
        local distanciaXTrigo = math.abs(trigo.x - novoObjeto.x)
        local distanciaYTrigo = math.abs(trigo.y - novoObjeto.y)
        if distanciaXTrigo < threshold2 and distanciaYTrigo < threshold2 then
            print("Afastando os gafanhotos...")
            afastarGafanhotos()  -- Remover os gafanhotos
        end
    end
end

-- Função para calcular a distância entre dois pontos
local function calcularDistancia(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

-- Função para verificar se os três objetos estão próximos um do outro
local function verificarProximidade(objeto1, objeto2, objeto3, threshold)
    local distancia1_2 = calcularDistancia(objeto1.x, objeto1.y, objeto2.x, objeto2.y)
    local distancia1_3 = calcularDistancia(objeto1.x, objeto1.y, objeto3.x, objeto3.y)
    local distancia2_3 = calcularDistancia(objeto2.x, objeto2.y, objeto3.x, objeto3.y)

    if distancia1_2 < threshold and distancia1_3 < threshold and distancia2_3 < threshold then
        objetoProximo = true
        print("Os objetos estão proximos")
    else
        print("Os objetos não estão proximos")
        objetoProximo = false
    end
end

-- Função para manipular o toque nos objetos
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

            -- Definindo a distância de proximidade
            local threshold = 50

            if objetoProximo == false then
                -- Verificando a proximidade dos objetos
                verificarProximidade(objeto1, objeto2, objeto3, threshold)
            end

            if objetoProximo and countNovoObjeto < 1 then
                print("entrou no if novoObjeto")
                -- Remover os três objetos
                display.remove(objeto1)
                display.remove(objeto2)
                display.remove(objeto3)
                -- Criando os objetos que devem ser juntados
                novoObjeto = display.newRect(sceneGroup, 100, 100, 50, 50)
                novoObjeto:setFillColor(1, 0, 1)
                countNovoObjeto = countNovoObjeto + 1
                novoObjeto:addEventListener("touch", function(event) toque(event, sceneGroup) end)  
                verificarProximidadeComTrigo(novoObjeto, trigo)
            end

        elseif event.phase == "ended" or event.phase == "cancelled" then
            display.getCurrentStage():setFocus(nil)
            target.isFocus = false
        end
    end
    return true
end

function scene:create(event)
    local sceneGroup = self.view

    -- Criando a plantação de trigo
    criarPlantacaoDeTrigo(sceneGroup)

    -- Criando os objetos que devem ser juntados
    objeto1 = display.newRect(sceneGroup, 100, 100, 50, 50)
    objeto1:setFillColor(1, 0, 0)
    objeto1:addEventListener("touch", function(event) toque(event, sceneGroup) end)

    objeto2 = display.newRect(sceneGroup, 200, 100, 50, 50)
    objeto2:setFillColor(0, 1, 0)
    objeto2:addEventListener("touch", function(event) toque(event, sceneGroup) end)

    objeto3 = display.newRect(sceneGroup, 150, 200, 50, 50)
    objeto3:setFillColor(0, 0, 1)
    objeto3:addEventListener("touch", function(event) toque(event, sceneGroup) end)


end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        exibirCafanhotosContinuamente()
    elseif phase == "did" then
        -- código a ser executado após a cena ser mostrada
    end
end

function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- código a ser executado antes da cena ser escondida
    elseif phase == "did" then
        -- código a ser executado após a cena ser escondida
    end
end

function scene:destroy(event)
    local sceneGroup = self.view
    -- código para limpar a cena, se necessário
end

-- Escutadores de eventos da cena
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
