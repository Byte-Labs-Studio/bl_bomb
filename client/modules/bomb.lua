local data
local Bomb = lib.class('Bomb')
local entities = {}

--- Creates a new bomb
--- @param bombData {position: vector4, id: number, code: number, cables: TCable[], cuttedCables: table<string, boolean>, duration: number} The heading of the bomb
function Bomb:constructor(bombData)
    self.coords = bombData.position.xyz
    self.heading = bombData.position.w
    self.id = bombData.id
    self.code = bombData.code
    self.point = self:createPoint()
    self.cables = bombData.cables

    local cutted = bombData.cuttedCables
    if cutted then
        for i = 1, 4 do
            self.cables[i].cut = cutted[tostring(i)]
        end
    end
    local duration = bombData.duration
    if duration then
        self.timerEnd = GetGameTimer() + ((duration * 60) or 30) * 1000
    end
end

--- Creates a point around the bomb
--- @return table|nil
function Bomb:createPoint()
    local coords = self.coords
    local range = 30
    return lib.points.new({
        coords = coords,
        distance = range,
        debug = true,
        onEnter = function()
            data = require 'data.bomb'

            self.timer = {}
            self.object = self:createBomb()
            self.targetId = self:createTarget()
            self:createCables()
            if self.timerEnd then
                self:startTimerCountdown()
            else
                self:resetTimer()
            end
        end,
        onExit = function()
            self:destroyOnLeave()
        end
    })
end

--- Creates a target for the bomb
--- @return number
function Bomb:createTarget()
    local object = self.object
    return Framework.target.addLocalEntity({
        entity = object,
        options = {
            {
                label = "Take a closer look",
                icon = "fa-regular fa-eye",
                distance = 2,
                onSelect = function()
                    self:openBomb()
                end
            },
            {
                label = "Pick up",
                icon = "fa-regular fa-hand",
                distance = 2,
                canInteract = function()
                    return not self.active
                end,
                onSelect = function()
                    TriggerServerEvent('bl_bomb:server:removeBomb', self.id)
                end
            }
        },
    })
end

--- Opens the bomb
function Bomb:openBomb()
    local utils = require 'client.modules.utils'
    local sendNUIEvent = utils.sendNUIEvent
    utils.createCam(self.object)

    LocalPlayer.state:set('atBomb', self.id, true)

    sendNUIEvent('bomb:visible', true)
    if self.active and self.cables then
        sendNUIEvent('bomb:setCables', self.cables)
    end
    SetNuiFocus(true, true)
    utils.focusedBomb = self
end

--- Destroys the bomb
function Bomb:destroyOnLeave()
    local briefObject = self.object
    if briefObject then
        DeleteObject(briefObject)
        self.object = nil
    end
    if self.targetId then
        Framework.target.removeZone(self.targetId)
        self.targetId = nil
    end
    for _,v in pairs(self.timer or {}) do
        local object = v.object
        if object then
            DeleteObject(object)
        end
    end
    for _,v in pairs(self.cables or {}) do
        local object = v.object
        if object then
            DeleteObject(object)
        end
    end
    self.timer = nil
    self.active = nil
    self.cables = nil
end

function Bomb:destroyAll()
    self:destroyOnLeave()

    self.coords = nil
    self.heading = nil
    self.id = nil
    self.code = nil
    self.point:remove()
    self.point = nil
    self.soundId = nil

    collectgarbage('collect')
end

--- Creates a bomb object
--- @return number
function Bomb:createBomb()
    local coords = self.coords
    local model = lib.requestModel(require'data.config'.briefCase.open)
    local object = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(object, self.heading+180)
    entities[object] = true
    SetModelAsNoLongerNeeded(model)
    PlaceObjectOnGroundProperly(object)
    return object
end

--- Creates cables for the bomb
--- @return table<number, TCable>
function Bomb:createCables()
    local coords = self.coords
    local variationColors = data.variationColors
    local offset = data.cableOffsets
    local cablesModel = data.cablesModels
    local cutCablesModels = data.cutCablesModels
    --- @type table<number, TCable>
    local cables = self.cables

    for i = 1, 4 do
        local cable = cables[i]
        local model = lib.requestModel(cable.cut and cutCablesModels[i] or cablesModel[i])
        local cableOffset = offset[i]
        local object = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)

        AttachEntityToEntity(object, self.object, -1, cableOffset.x, cableOffset.y, 0.0, 0, 0, 0, false, false, false, false, 2, true)
        SetModelAsNoLongerNeeded(model)
        SetObjectTextureVariant(object, variationColors[cable.colour])
        entities[object] = true

        cable.id = i
        cable.colour = cable.colour
        cable.object = object
    end
    return cables
end

function Bomb:playerInRange()
    return self.object
end

function Bomb:cutCable(id)
    local cable = self.cables[id]
    if not cable or cable.cut then return end

    cable.cut = true

    if cable.defuse then
        require'client.modules.utils'.sendNUIEvent('bomb:setCables', {})
        self:resetTimer()
        if LocalPlayer.state.atBomb then
            Framework.notify({
                title = 'Bomb defused!',
                type = 'success',
            })
        end
    elseif cable.trigger then
        self:detonate()
        return
    elseif cable.trap then
        require'client.modules.utils'.sendNUIEvent('bomb:cutCable', cable.colour)
        local deductTime = require 'data.config'.trapCableDeductTime
        self.timerEnd -= deductTime
        if LocalPlayer.state.atBomb then
            Framework.notify({
                title = ('The trap cable, timer was reduced by %s seconds.'):format(deductTime / 1000),
                type = 'inform',
            })
        end
    end
    if not self:playerInRange() then return end

    DeleteObject(cable.object)
    local coords = self.coords
    local model = lib.requestModel(data.cutCablesModels[id])
    local cableOffset = data.cableOffsets[id]
    local object = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
    AttachEntityToEntity(object, self.object, -1, cableOffset.x, cableOffset.y, 0.0, 0, 0, 0, false, false, false, false, 2, true)

    SetObjectTextureVariant(object, data.variationColors[cable.colour])
    SetModelAsNoLongerNeeded(model)
    cable.object = object
end

function Bomb:createNumber(index, number)
    local oldObject = self.timer[tostring(index)]?.object
    if oldObject then
        entities[oldObject] = nil
        DeleteEntity(oldObject)
    end
    local model = lib.requestModel(data.numModels[number])
    local offset = data.timerOffsets[index]
    if not offset then return end

    local coords = self.coords
    local object = CreateObject(model, coords.x + offset.x, coords.y + offset.y, coords.z, false, false, false)
    AttachEntityToEntity(object, self.object, -1, offset.x, offset.y, -0.01, 0, 0, 0, false, false, false, false, 2, true)

    SetModelAsNoLongerNeeded(model)

    entities[object] = true
    return object
end

function Bomb:resetTimer()
    local timer = self.timer
    self.active = false
    self.timerEnd = nil
    for i=1, 5 do
        local object = self:createNumber(i, 0)
        timer[tostring(i)] = {
            value = 0,
            object = object
        }
    end
end

function Bomb:insertNumber(number)
    local index = self.editedIndex and self.editedIndex-1 or 3
    if index <= 0 then
        index = 3
    end
    local object = self:createNumber(index, number)
    if not object then return end

    if not self.timerDuration then
        self.timerDuration = '000'
    end

    self.timerDuration = require'client.modules.utils'.replaceCharAtReverseIndex(self.timerDuration, index, number)
    self.editedIndex = index
    self.timer[tostring(index)] = {
        value = number,
        object = object
    }
end

--- Starts the bomb's timer countdown
---@param duration? number
function Bomb:startTimerCountdown(duration)
    self.active = true
    self.timerEnd = self.timerEnd or (GetGameTimer() + ((duration * 60) or 30) * 1000)
    if not self:playerInRange() then return end

    Citizen.CreateThreadNow(function()
        while self.active do
            pcall(function()
                self:handleTimerTick()
            end)
            Wait(950)
        end
    end)

    Citizen.CreateThreadNow(function()
        self.soundId = GetSoundId()
        while self.active do
            self:handleTimerSound()
            Wait(500)
        end
    end)
end

function Bomb:disableBomb(value)
    self.value = (self.value or '')..tostring(value)
    local insertedValue = tonumber(self.value)
    if #self.value ~= 4 or not insertedValue then return end
    if insertedValue ~= self.code then
        Framework.notify({
            title = 'Wrong Code',
            type = 'error',
        })
        self.value = ''
        return
    end

    local validate = lib.callback.await('bl_bomb:server:validCode', false, {
        code = insertedValue,
        id = self.id
    })
    if validate then
        Framework.notify({
            title = 'Bomb desactivated!',
            type = 'success',
        })
        self:resetTimer()
        require'client.modules.utils'.sendNUIEvent('bomb:setCables', {})
    else
        self.value = ''
    end
end

function Bomb:handleTimerSound()
    local secondsLeft = self:getSecondsLeft()
    local soundId = self.soundId

    Wait(secondsLeft > 10 and 2000 or (secondsLeft / 2) * 50)
    PlaySoundFromEntity(soundId, "IDLE_BEEP", self.object, "EPSILONISM_04_SOUNDSET", false, 20)
end

--- Handles the timer tick
function Bomb:handleTimerTick()
    local secondsLeft = self:getSecondsLeft()
    local minutes = tostring(math.floor(secondsLeft / 60))
    local seconds = tostring(secondsLeft % 60)
    local timer = self.timer
    if not timer then return end

    local function updateObject(charValue, index)
        if charValue == "" then charValue = "0" end

        local stringIndex = tostring(index)
        local v = timer[stringIndex]
        local numberVal = tonumber(charValue)
        if numberVal and v?.value ~= numberVal then
            timer[stringIndex] = {
                object = self:createNumber(index, numberVal),
                value = numberVal,
            }
        end
    end
    for i = 1, 3 do -- minutes
        local charValue = string.sub(minutes, i, i)
        updateObject(charValue, i)
    end
    for i = 1, 2 do -- seconds
        local charValue = string.sub(seconds, i, i)
        local position = i + 3
        if tonumber(seconds) < 10 then
            position += 1
        end
        position = position == 6 and 4 or position
        updateObject(charValue, position)
    end

    if secondsLeft <= 0 then
        self.active = false

        local soundId = self.soundId
        StopSound(soundId)
        ReleaseSoundId(soundId)

        self:detonate()
    end
end

--- Gets the seconds left on the timer
--- @return number
function Bomb:getSecondsLeft()
    local currentTime = GetGameTimer()
    local remainingTime = self.timerEnd - currentTime
    return remainingTime > 0 and math.floor(remainingTime / 1000) or 0
end

--- Detonates the bomb
function Bomb:detonate()
    local coords = self.coords
    if not coords then
        return
    end
    if LocalPlayer.state.atBomb then
        require'client.modules.utils'.closeUi(true)
    end

    local explosionType = 2
    local explosionRadius = 5.0
    local isAudible = true
    local isInvisible = false
    local cameraShake = 1.0
    AddExplosion(coords.x, coords.y, coords.z, explosionType, explosionRadius, isAudible, isInvisible, cameraShake)

    local ped = cache.ped
    local playerCoords = GetEntityCoords(ped)
    local distance = #(coords - playerCoords)
    if distance < require 'data.config'.deathRange then
        SetEntityHealth(ped, 0)
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    for entity in pairs(entities) do
        DeleteEntity(entity)
    end
end)

return Bomb
