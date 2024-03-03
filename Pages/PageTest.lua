local composer = require("composer")

-- Definir configurações da cena
local scene = composer.newScene()
local mySceneGroup

-- Definindo largura e altura específicas
local largura, altura = 768, 1024

-- Ativar multitouch
system.activate("multitouch")

-- Mantenha o controle dos objetos que estão sendo tocados
local touchedObjects = {}

local function createTitulo(sceneGroup)

    local titulo = display.newText({
        text = "Multiplos toques",
        font = native.newFont("Bold"),
        fontSize = 60
    })
    -- Ajuste a posição do titulo para a parte superior da tela
    titulo.x = display.contentCenterX
    titulo.y = altura * 0.293 - 200
    -- Define a cor do titulo
    titulo:setFillColor(1, 1, 1)
    -- Insere o titulo no grupo da cena
    sceneGroup:insert(titulo)
end

-- Função para lidar com eventos de toque
local function touchListener(event)
    local phase = event.phase
    local target = event.target

    local group = target.parent -- Obtenha o grupo pai do objeto

    if phase == "began" then
        -- Adicione o objeto à tabela de objetos tocados
        touchedObjects[target] = event.id
        display.getCurrentStage():setFocus(target, event.id)
        target.isFocus = true

        -- Armazene a posição inicial do toque
        target.markX = event.x - target.x
        target.markY = event.y - target.y

        -- Verifique se pelo menos dois objetos estão sendo tocados
        local count = 0
        for _ in pairs(touchedObjects) do
            count = count + 1
        end

        if count == 2 then
            -- Armazene a posição inicial do toque para o grupo de objetos
            group.markX = (target.x + event.x) * 0.5
            group.markY = (target.y + event.y) * 0.5
        end
    elseif target.isFocus then
        if phase == "moved" then
            -- Verifique se pelo menos dois objetos estão sendo tocados
            local count = 0
            for _ in pairs(touchedObjects) do
                count = count + 1
            end

            if count == 2 then
                -- Calcule o deslocamento total
                local dx = event.x - group.markX
                local dy = event.y - group.markY

                -- Mova o grupo de objetos
                group.x = group.x + dx
                group.y = group.y + dy

                -- Atualize a posição inicial do toque para o próximo movimento
                group.markX = event.x
                group.markY = event.y
            end
        elseif phase == "ended" or phase == "cancelled" then
            -- Remova o objeto da tabela de objetos tocados
            touchedObjects[target] = nil
            display.getCurrentStage():setFocus(target, nil)
            target.isFocus = false
        end
    end

    return true
end



function scene:create(event)
    local sceneGroup = self.view

    mySceneGroup = sceneGroup
    -- Criar um grupo para conter os dois retângulos
    local group = display.newGroup()
    sceneGroup:insert(group)

    -- Criar dois objetos de exibição na tela e adicioná-los ao grupo
    local newRect1 = display.newRect(group, display.contentCenterX - 20, 240, 120, 120)
    newRect1:setFillColor(1, 0, 0.3)
    local newRect2 = display.newRect(group, display.contentCenterX + 100, 240, 120, 120)
    newRect2:setFillColor(0.3, 0, 1)

    -- createTitulo(sceneGroup)

    -- Adicionar um ouvinte de toque a cada objeto
    newRect1:addEventListener("touch", touchListener)
    newRect2:addEventListener("touch", touchListener)
end

-- Não é necessário uma função "scene:show" neste exemplo

-- Não é necessário uma função "scene:hide" neste exemplo

-- Não é necessário uma função "scene:destroy" neste exemplo

-- Escute o evento de cena
scene:addEventListener("create", scene)

return scene
