require 'client.utils'
require 'client.ui'

-- Global table to store all bombs
--- @type table<number, Bomb>
local Bombs = {}

RegisterNUICallback(Receive.close, function(_, cb)
    SendNUIEvent(Send.visible, false)
    cb(1)
end)

RegisterNetEvent('bl_bomb:client:registerBomb', function(id, x, y, z, w)
    local Bomb = require 'client.bomb'
    Bombs[id] = Bomb:new(id, x, y, z, w)
end)

-- Event listener to remove a bomb from the server
RegisterNetEvent('bl_bomb:client:removeBomb', function(id)
    if Bombs[id] then
        Bombs[id]:destroy()
        Bombs[id] = nil
    end
end)

-- Event listener to update bomb state
RegisterNetEvent("bl_bomb:client:updateBombState", function(bombId, newState)
    if Bombs[bombId] then
        Bombs[bombId].state = newState
        print("Updated state for bomb ID:", bombId)
    end
end)