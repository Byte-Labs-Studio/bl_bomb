local activeBombs = {}
local config = require 'data.config'
local core = Framework.core
local holdingBomb = {}

--- Randomizes cable colors
--- @return TCable[] The shuffled list of colors
local function randomizeColours()
    local colours = table.clone(require 'data.bomb'.variationColors)
    local keys = {}

    for key in pairs(colours) do
        keys[#keys+1] = {
            colour = key
        }
    end
    for i = #keys, 1, -1 do
        local j = math.random(1, i)
        keys[i], keys[j] = keys[j], keys[i]
    end

    for i = 1, #keys do
        if i > 4 then
            keys[i] = nil
        end
    end

    keys[1].trigger = true
    keys[2].defuse = true

    return keys
end

local function generateUniqueBombId()
    local id
    repeat
        id = math.random(1, 10000)
    until not activeBombs[id]
    return id
end

local function validAction(src, id)
    local bomb = activeBombs[id]
    if not bomb then return end

    return #(GetEntityCoords(GetPlayerPed(src)) - bomb.position.xyz) <= 2 and bomb
end

---comment
---@param source any
---@param data {cables: {colour: string, trigger?: boolean, trap?: boolean, defuse?: boolean}, code: string}
exports('giveBomb', function(source, data)
    local player = core.GetPlayer(source)
    if not player then return end

    player.addItem('bomb_suitcase', 1, data)
end)

local function removeBomb(bombId)
    activeBombs[bombId] = nil
    TriggerClientEvent('bl_bomb:client:removeBomb', -1, bombId)
end

core.RegisterUsableItem(config.itemName, function(src, slot, metadata)
    metadata = metadata or {}
    metadata.slot = slot
    holdingBomb[src] = metadata or {}
    TriggerClientEvent('bl_bomb:client:holdBriefCase', src)
end)

RegisterNetEvent('bl_bomb:server:placeBomb', function(coords)
    local src = source
    local metadata = holdingBomb[src]
    if not metadata then return end

    local player = core.GetPlayer(src)
    if not player then return end

    player.removeItem(config.itemName, 1, metadata.slot)
    metadata.slot = nil

    local ped = GetPlayerPed(src)
    local id = generateUniqueBombId()
    local duration = metadata.duration
    local data = {
        id = id,
        position = vec4(coords.x, coords.y, coords.z, GetEntityHeading(ped)),
        code = metadata.code or math.random(1000, 9999),
        cables = metadata.cables or randomizeColours(),
        duration = duration,
        startTime = duration and os.time(),
        timer = duration and require 'server.timer'.startTimer(duration * 60, function()
            local bomb = activeBombs[id]
            if not bomb then return end
            removeBomb(id)
        end, id),

        cuttedCables = {}
    }

    activeBombs[id] = data
    TriggerClientEvent('bl_bomb:client:registerBomb', -1, data)
end)

AddEventHandler('bl_bridge:server:playerLoaded', function(source)
    TriggerClientEvent('bl_bomb:client:registerBombs', source, activeBombs)
end)

lib.callback.register('bl_bomb:server:validCode', function(src, data)
    local bomb = validAction(src, data.id)
    if not bomb then return end

    return bomb.code == data.code
end)

RegisterNetEvent('bl_bomb:server:cutCable', function(bombId, value)
    local src = source
    local bomb = validAction(src, bombId)
    if not bomb then return end

    bomb.cuttedCables[tostring(value)] = true

    -- since i don't use networked entities, i can't use statebag to only update players in ranges, need better design
    -- i think either listen to the player onEnter / onExit and save to saver or make briefcase networked
    TriggerClientEvent('bl_bomb:client:cutCable', -1, bombId, value)

    local cable = bomb.cables[value]
    if cable.trigger then
        Wait(500)
        TriggerClientEvent('bl_bomb:client:removeBomb', -1, bombId)
    elseif cable.trap then
        local id = bomb.id
        local timer = require 'server.timer'
        timer.stopTimer(id)
        Wait(150)

        local left = (bomb.duration * 60) - (os.time() - bomb.startTime)
        timer.startTimer(left - (config.trapCableDeductTime / 1000), function()
            bomb = activeBombs[id]
            if not bomb then return end
            removeBomb(id)
        end, id)
    elseif cable.defuse then
        require 'server.timer'.stopTimer(bomb.id)
    end
end)

RegisterNetEvent('bl_bomb:server:removeBomb', function(bombId)
    local src = source
    local bomb = validAction(src, bombId)

    if not bomb then return end

    activeBombs[bombId] = nil
    TriggerClientEvent('bl_bomb:client:removeBomb', -1, bombId)
end)

RegisterNetEvent('bl_bomb:server:startBombTimer', function(data)
    local src = source
    local bomb = validAction(src, data.id)
    if not bomb then return end
    local id = data.id

    bomb.startTime = os.time()
    bomb.duration = data.duration
    require 'server.timer'.startTimer(data.duration * 60, function()
        bomb = activeBombs[id]
        if not bomb then return end
        removeBomb(id)
    end, id)
    TriggerClientEvent('bl_bomb:client:startBombTimer', -1, data)
end)
