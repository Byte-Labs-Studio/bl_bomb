lib.load('data.utils')
lib.load('data.ui')

-- Global table to store all bombs
--- @type table<number, Bomb>
local Bombs = {}

RegisterNUICallback(Receive.close, function(_, cb)
    SendNUIEvent(Send.visible, false)
    cb(1)
end)

RegisterNetEvent('bl_bomb:client:registerBomb', function(data)
    local coords, id in data
    local Bomb = lib.load('client.modules.bomb')
    Bombs[id] = Bomb:new(id, coords.x, coords.y, coords.z, coords.w)
end)

-- Event listener to remove a bomb from the server
RegisterNetEvent('bl_bomb:client:removeBomb', function(id)
    local bomb = Bombs[id]
    if bomb then
        bomb:destroy()
        Bombs[id] = nil
    end
end)

-- Event listener to update bomb state
RegisterNetEvent("bl_bomb:client:updateBombState", function(bombId, newState)
    local bomb = Bombs[bombId]
    if bomb then
        bomb.state = newState
        print("Updated state for bomb ID:", bombId)
    end
end)
