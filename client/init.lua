local Bombs = {}

RegisterNetEvent('bl_bomb:client:registerBomb', function(data)
    local Bomb = require 'client.modules.bomb'
    Bombs[data.id] = Bomb:new(data)
end)

RegisterNUICallback('bomb:close', function(_, cb)
    cb(1)
    require 'client.modules.utils'.closeUi()
end)

RegisterNUICallback('bomb:setCable', function(value, cb)
    cb(1)
    local bomb = require 'client.modules.utils'.focusedBomb
    if not bomb then return end

    TriggerServerEvent('bl_bomb:server:cutCable', bomb.id, value)
end)

RegisterNetEvent('bl_bomb:client:holdBriefCase', require 'client.modules.briefcase'.holdBriefCase)

RegisterNUICallback('bomb:updateTimer', function(value, cb)
    cb(1)
    local utils = require 'client.modules.utils'
    local bomb = utils.focusedBomb
    if not bomb then return end
    if bomb.active then
        bomb:disableBomb(value)
        return
    end

    if value == 'Enter' then
        Framework.notify({
            title = ('use code to desactivate: %s'):format(bomb.code),
            type = 'inform',
            duration = 10000
        })
        local timerDuration = bomb.timerDuration and tonumber(bomb.timerDuration)
        if not timerDuration then return end

        utils.sendNUIEvent('bomb:setCables', bomb.cables)
        bomb.timerDuration = nil
        bomb.editedIndex = nil

        TriggerServerEvent('bl_bomb:server:startBombTimer', {
            id = bomb.id,
            duration = timerDuration,
            startTime = GetGameTimer()
        })
    else
        bomb:insertNumber(value)
    end
end)

RegisterNetEvent('bl_bomb:client:cutCable', function(bombId, value)
    local bomb = Bombs[bombId]
    if not bomb then return end

    bomb:cutCable(value)
end)

RegisterNetEvent('bl_bomb:client:registerBombs', function(data)
    local Bomb = require('client.modules.bomb')
    for k,v in pairs(data) do
        Bombs[k] = Bomb:new(v)
    end
end)

RegisterNetEvent('bl_bomb:client:removeBomb', function(id)
    local bomb = Bombs[id]
    if not bomb then return end

    bomb:destroyAll()
    Bombs[id] = nil
end)

-- Event listener to update bomb state
RegisterNetEvent("bl_bomb:client:startBombTimer", function(data)
    local bomb = Bombs[data.id]
    if not bomb then return end
    bomb:startTimerCountdown(data.duration)
end)
