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
local limiteInferior = altura - 220  -- Ajuste conforme necessário
local mySceneGroup

-- Função para criar novos objetos nas coordenadas armazenadas em coordenadasChao
local function criarObjetosCoordenadasChao(coordenada)
    print("Chamou a função para criar novos objetos...")
    timer.performWithDelay(1, function()
        local novoObjeto = display.newRect(mySceneGroup, 
        coordenada.x, 
        coordenada.y + 130, 
        50, 50)     
        novoObjeto:setFillColor(0.6, 0.3, 0)
        -- physics.addBody(novoObjeto, "static", { density = 1.0, friction = 0.3, bounce = 0.2 })
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

    if phase == "began" then
        -- Adicionar o objeto à tabela de objetos tocados
        touchedObjects[target] = true

        local count = 0
        for _ in pairs(touchedObjects) do
            count = count + 1
        end

        print(count)

        -- Verificar se este evento de toque está relacionado a um dos toques ativos
        local isMultiTouch = false

        if count == 2 then
            isMultiTouch = true
        end

        print(isMultiTouch)

        if true then
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

function scene:create(event)
  local sceneGroup = self.view

  mySceneGroup = sceneGroup
  -- Criar um grupo para conter os dois retângulos
  local group = display.newGroup()
  sceneGroup:insert(group)

  criarChao(sceneGroup)

  -- Criar dois objetos de exibição na tela e adicioná-los ao grupo
  local newRect1 = display.newRect(group, display.contentCenterX + 200, 250, 50, 200)
  newRect1:setFillColor(1, 0, 0.3)
  physics.addBody(newRect1, "dynamic", { density = 1.0, friction = 0.3, bounce = 0.2 })
  
  local newRect2 = display.newRect(group, display.contentCenterX + 200, 450, 50, 200)
  newRect2:setFillColor(0.3, 0, 1)
  physics.addBody(newRect2, "dynamic", { density = 1.0, friction = 0.3, bounce = 0.2 })

  -- Criar uma junta entre os objetos
  local joint = physics.newJoint("weld", newRect1, newRect2, newRect1.x, newRect1.y)

  createTitulo(sceneGroup)

  -- Adicionar um ouvinte de toque a cada objeto
  newRect1:addEventListener("touch", touchListener)
  newRect2:addEventListener("touch", touchListener)

  physics.start()

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
