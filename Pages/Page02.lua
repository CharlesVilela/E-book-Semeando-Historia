local composer = require("composer")

local scene = composer.newScene()

local largura, altura = display.actualContentWidth, display.actualContentHeight
local centerX, centerY = display.contentCenterX, display.contentCenterY

local sensor -- Variável para o sensor de inclinação
local soprarSensor -- Variável para o sensor de toque
local graos = {} -- Tabela para armazenar os grãos de trigo

-- Função para criar o pé de trigo
local function criarPe(sceneGroup)
    local tamanho_pe = 40
    local altura_pe = 420
    local pe = display.newRect(sceneGroup, centerX, altura - altura_pe / 2, tamanho_pe, altura_pe)
    pe:setFillColor(0.8, 0.7, 0.2)
end

-- Função para criar um grão de trigo
local function criarGrao()
    local grao = display.newImageRect("image/Page01/trigo.png", 20, 20)
    grao.x = math.random(largura)
    grao.y = math.random(altura * 0.6)
    return grao
end

-- Função para mover os grãos de trigo
local function moverGraos(direcao)
    for i = 1, #graos do
        local grao = graos[i]
        if direcao == "esquerda" then
            transition.to(grao, {time = math.random(1000, 3000), x = -20, y = math.random(altura * 0.6), onComplete = function()
                grao:removeSelf()
                table.remove(graos, i)
            end})
        elseif direcao == "direita" then
            transition.to(grao, {time = math.random(1000, 3000), x = largura + 20, y = math.random(altura * 0.6), onComplete = function()
                grao:removeSelf()
                table.remove(graos, i)
            end})
        end
    end
end

-- Função para adicionar um novo grão de trigo
local function adicionarGrao()
    local grao = criarGrao()
    table.insert(graos, grao)
end

-- Função para lidar com o evento de inclinação do dispositivo
local function onTilt(event)
    local xGravity = event.xGravity or 0
    if xGravity < -0.1 then
        moverGraos("esquerda")
    elseif xGravity > 0.1 then
        moverGraos("direita")
    end
end

-- Função para criar o sensor de inclinação
local function criarSensorInclinacao()
    sensor = Runtime
    sensor:addEventListener("accelerometer", onTilt)
end

-- Função para criar o sensor de toque
local function criarSensorToque()
    soprarSensor = display.newRect(display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight)
    soprarSensor.isVisible = false
    if soprarSensor then
        soprarSensor:addEventListener("touch", sensorTouchHandler)
    else
        print("Erro: falha ao criar o sensor de toque")
    end
end

-- Função para lidar com o evento de toque no sensor
local function sensorTouchHandler(event)
    if event.phase == "began" then
        adicionarGrao()
    end
    return true
end

function scene:create(event)
    local sceneGroup = self.view
    criarPe(sceneGroup)
    criarSensorInclinacao()
end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "did" then
        -- Criar sensor de toque depois que o sensor de inclinação estiver criado
        criarSensorToque()
    end
end

function scene:destroy(event)
    local sceneGroup = self.view
    sensor:removeEventListener("accelerometer", onTilt)
    if soprarSensor then
        soprarSensor:removeEventListener("touch", sensorTouchHandler)
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("destroy", scene)

return scene
