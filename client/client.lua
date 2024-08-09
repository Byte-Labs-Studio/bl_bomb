require 'client.utils'
require 'client.ui'

local Bombs = {}

RegisterNUICallback(Receive.close, function(_, cb)
    SendNUIEvent(Send.visible, false)
    cb(1)
end)

RegisterNetEvent('bl_bomb:client:registerBomb', function(id, x, y, z, w)
    local Bomb = require 'client.bomb'
    Bombs[id] = Bomb:new(id, x, y, z, w)
end)

RegisterNetEvent('bl_bomb:client:removeBomb', function(id)
    if Bombs[id] then
        Bombs[id]:destroy()
        Bombs[id] = nil
    end
end)

RegisterNetEvent('bl_bomb:client:useItem', function(x, y, z, w)
    local newId = math.random(1, 10000)
    Bombs[newId] = Bomb:new(newId, x, y, z, w)
end)