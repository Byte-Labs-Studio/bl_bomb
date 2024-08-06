local ActiveBombs = {}
local Config = require 'shared.config'

Framework.core.RegisterUsableItem(Config.itemName, function(source)
    local xPlayer = Framework.core.GetPlayerFromId(source)
    local coords = xPlayer.getCoords()
    local heading = xPlayer.getHeading()

    local id = math.random(1, 10000)
    ActiveBombs[id] = {
        id = id,
        timeStarted = os.time(),
        position = vec4(coords.x, coords.y, coords.z, heading),
        state = nil,
        cableStates = {},
        playersInRange = {}
    }

    TriggerClientEvent('bomb:client:registerBomb', -1, id, coords.x, coords.y, coords.z, heading)
end)

RegisterNetEvent('bomb:server:updatePlayerRange', function(bombId, playerId, inRange)
    if ActiveBombs[bombId] then
        if inRange then
            ActiveBombs[bombId].playersInRange[playerId] = true
        else
            ActiveBombs[bombId].playersInRange[playerId] = nil
        end
    end
end)

RegisterNetEvent('bomb:server:updateBombState', function(bombId, newState)
    if ActiveBombs[bombId] then
        ActiveBombs[bombId].state = newState
        TriggerClientEvent('bomb:client:updateBombState', -1, bombId, newState)
    end
end)

RegisterNetEvent('bomb:server:removeBomb', function(bombId)
    if ActiveBombs[bombId] then
        ActiveBombs[bombId] = nil
        TriggerClientEvent('bomb:client:removeBomb', -1, bombId)
    end
end)