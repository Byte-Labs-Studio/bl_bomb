local ActiveBombs = {}
local Config = require 'shared.config'
local core = Framework.core

local function generateUniqueBombId()
    local id
    repeat
        id = math.random(1, 10000)
    until not ActiveBombs[id]
    return id
end

core.RegisterUsableItem(Config.itemName, function(src)
    if not src then return end

    local player = core.GetPlayer(src)
    if not player then return end
    local ped = GetPlayerPed(src)

    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    local id = generateUniqueBombId()
    ActiveBombs[id] = {
        id = id,
        timeStarted = os.time(),
        position = vec4(coords.x, coords.y, coords.z, heading),
        state = nil,
        cableStates = {},
        playersInRange = {}
    }

    TriggerClientEvent('bl_bomb:client:registerBomb', -1, id, coords.x, coords.y, coords.z, heading)
end)

RegisterNetEvent('bl_bomb:server:updatePlayerRange', function(bombId, playerId, inRange)
    if ActiveBombs[bombId] then
        if inRange then
            ActiveBombs[bombId].playersInRange[playerId] = true
        else
            ActiveBombs[bombId].playersInRange[playerId] = nil
        end
    end
end)

RegisterNetEvent('bl_bomb:server:updateBombState', function(bombId, newState)
    if ActiveBombs[bombId] then
        ActiveBombs[bombId].state = newState
        TriggerClientEvent('bl_bomb:client:updateBombState', -1, bombId, newState)
    end
end)

RegisterNetEvent('bl_bomb:server:removeBomb', function(bombId)
    if ActiveBombs[bombId] then
        ActiveBombs[bombId] = nil
        TriggerClientEvent('bl_bomb:client:removeBomb', -1, bombId)
    end
end)