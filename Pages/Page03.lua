local composer = require("composer")

local scene = composer.newScene()

function scene:create(event)
    local sceneGroup = self.view

    -- Importa a biblioteca love2d
    local love = require("love")

    -- Função de inicialização
    function scene:show(event)
        if event.phase == "did" then
            -- Define as coordenadas iniciais do objeto
            local objeto = { x = display.contentCenterX, y = display.contentCenterY, size = 50 }

            -- Define a aceleração gravitacional
            local gravidade = 200

            -- Função de atualização
            function moveObjeto(event)
                -- Obtém a aceleração do dispositivo
                local ax, ay, az = system.getAcceleration()

                -- Move o objeto baseado na inclinação
                objeto.x = objeto.x + ax * gravidade * event.time / 1000
                objeto.y = objeto.y + ay * gravidade * event.time / 1000

                -- Desenha o objeto
                display.remove(objetoRect)
                objetoRect = display.newRect(sceneGroup, objeto.x - objeto.size / 2, objeto.y - objeto.size / 2, objeto.size, objeto.size)
                objetoRect:setFillColor(0.5, 0.5, 1)
            end

            Runtime:addEventListener("enterFrame", moveObjeto)

            function scene:hide(event)
                if event.phase == "did" then
                    Runtime:removeEventListener("enterFrame", moveObjeto)
                end
            end

            sceneGroup:addEventListener("hide", scene)
        end
    end
end

scene:addEventListener("create", scene)

return scene
