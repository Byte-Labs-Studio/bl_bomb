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
    local position = vec4(coords.x, coords.y, coords.z, heading)
    ActiveBombs[id] = {
        id = id,
        timeStarted = os.time(),
        position = position,
        state = nil,
        cableStates = {},
        playersInRange = {}
    }
    TriggerClientEvent('bl_bomb:client:registerBomb', -1, {
        id = id,
        coords = position
    })
end)

local function getBombState(bombId)
    local bomb = ActiveBombs[bombId]
    return bomb and {
        id = bomb.id,
        position = bomb.position,
        state = bomb.state,
        cableStates = bomb.cableStates,
        playersInRange = bomb.playersInRange
    } or nil
end

RegisterNetEvent('bl_bomb:server:updatePlayerRange', function(source, bombId, inRange)
    if not ActiveBombs[bombId] then return end

    local playerId = source
    ActiveBombs[bombId].playersInRange[playerId] = inRange and true or nil
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

RegisterServerEvent("bl_bomb:server:requestState", function(bombId)
    local bombState = getBombState(bombId)
    TriggerClientEvent("bl_bomb:client:updateBombState", source, bombId, bombState)
end)
