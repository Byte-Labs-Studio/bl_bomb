require 'client.utils'
require 'client.ui'

local Bombs = {}

RegisterNUICallback(Receive.close, function(_, cb)
    SendNUIEvent(Send.visible, false)
    cb(1)
end)

RegisterNetEvent('bl_bomb:client:registerBomb', function(id)
    local Bomb = require 'client.bomb'
    Bombs[id] = Bomb:new(id)
end)

RegisterNetEvent('bl_bomb:client:removeBomb', function(id)
    Bombs[id]:destroy()
    Bombs[id] = nil
end)

RegisterNetEvent('bl_bomb:client:useItem', function()
    local Bomb = require 'client.bomb'
    Bombs[id] = Bomb:new()
end)