local Data = lib.load('data.constants')
local Config = lib.load('data.config')
local Bomb = {}
Bomb.__index = Bomb

--- Creates a new bomb
--- @param id number The unique ID of the bomb
--- @param x number The x position of the bomb
--- @param y number The y position of the bomb
--- @param z number The z position of the bomb
--- @param w number The heading of the bomb
--- @return Bomb
function Bomb:new(id, x, y, z, w)
    local object = self:createBomb(x, y, z)
    ---@class TBomb
    local bomb = {
        id = id,
        coords = vector4(x, y, z, w),
        state = nil,
        object = object,
        targetId = self:createTarget(object),
        timer = self:createTimer(x, y, z),
        cables = self:createCables(),
        tickTime = GetGameTimer(),
        timerEnd = GetGameTimer() + (Config.timerDuration or 30) * 1000,
        point = self:createPoint(vector3(x, y, z))
    }

    self = setmetatable(bomb, Bomb)

    TriggerServerEvent("bl_bomb:server:requestState", id)

    return self
end

--- Creates a target for the bomb
--- @return any
function Bomb:createTarget(object)
    return Framework.target.addLocalEntity({
        entity = object,
        options = {
            {
                label = "Take a closer look",
                icon = "fa-regular fa-eye",
                onSelect = function()
                    self:openBomb()
                end
            },
            {
                label = "Pick up",
                icon = "fa-regular fa-hand",
                canInteract = function()
                    return not self.state
                end,
                onSelect = function()
                    self:pickUp()
                end
            }
        },
    })
end

--- Creates a point around the bomb
--- @return any
function Bomb:createPoint(coords)
    if not coords then
        return nil
    end

    local range = Config.range or 30
    return lib.points.new({
        coords = coords,
        distance = range,
        debug = true,
        onEnter = function()
            TriggerServerEvent('bl_bomb:server:updatePlayerRange', self.id, true)
        end,
        onExit = function()
            TriggerServerEvent('bl_bomb:server:updatePlayerRange', self.id, false)
            self:clearDataExceptPosition()
        end
    })
end

--- Opens the bomb
function Bomb:openBomb()
    SendNUIEvent(Send.visible, true)
    SetNuiFocus(true, true)
end

--- Picks up the bomb
function Bomb:pickUp()
    TriggerServerEvent('bl_bomb:server:removeBomb', self.id)
end

--- Destroys the bomb
function Bomb:destroy()
    if self.object then
        DeleteObject(self.object)
        self.object = nil
    end
    if self.targetId then
        Framework.target.removeZone(self.targetId)
        self.targetId = nil
    end
    self.timer = nil
    self.cables = nil
    self.state = nil
end

--- Creates a bomb object
--- @param x number
--- @param y number
--- @param z number
--- @return any
function Bomb:createBomb(x, y, z)
    local model = lib.requestModel(`lev_briefcase`)

    -- The offset is to make the bomb look like it's in front of the player
    local bombOffset = -0.8
    y = y + bombOffset

    local object = CreateObject(model, x, y - bombOffset, z, true, true, false)
    while not DoesEntityExist(object) do
        Wait(100)
    end
    SetModelAsNoLongerNeeded(model)
    PlaceObjectOnGroundProperly(object)
    return object
end

--- Creates timers for the bomb
--- @param x number
--- @param y number
--- @param z number
--- @return table<number, TTimer>
function Bomb:createTimer(x, y, z)
    local offsets = Data.TimerOffsets
    --- @type table<number, TTimer>
    local timers = {}
    for i = 1, 4 do
        local hash = "lev_num" .. i
        local model = lib.requestModel(hash)
        local offset = offsets[i]
        local buttonx = x + offset.x
        local buttony = y + offset.y
        local buttonz = z + offset.z
        local object = CreateObject(model, buttonx, buttony, buttonz, true, true, false)
        while not DoesEntityExist(object) do
            Wait(100)
        end
        SetModelAsNoLongerNeeded(model)
        timers[i] = {
            id = i,
            object = object,
            number = 0,
            changed = false,
        }
    end

    self:startTimerCountdown()

    return timers
end

--- Starts the bomb's timer countdown
function Bomb:startTimerCountdown()
    local function tick()
        if not self.tickTime or self:getSecondsLeft() <= 0 then
            self:detonate()
            return
        end
        self:handleTimerTick()
        SetTimeout(1000, tick)
    end
    tick()
end

--- Handles the timer tick
function Bomb:handleTimerTick()
    local currentTime = GetGameTimer()
    local timeElapsed = (currentTime - self.tickTime) / 1000
    local secondsLeft = self:getSecondsLeft()

    if timeElapsed >= 1 then
        self.tickTime = currentTime

        local sound = secondsLeft <= 10 and "Beep_Red" or "Beep_Blue"
        PlaySoundFromEntity(-1, sound, self.object, "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", false, 0)

        if secondsLeft <= 0 then
            self:detonate()
        end
    end

    if secondsLeft < 10 then
        Wait(500)
        PlaySoundFromEntity(-1, "Beep_Red", self.object, "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", false, 0)
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
    if not self.coords then
        return
    end
    local explosionType = 2
    local explosionRadius = 5.0
    local isAudible = true
    local isInvisible = false
    local cameraShake = 1.0
    AddExplosion(self.coords.x, self.coords.y, self.coords.z, explosionType, explosionRadius, isAudible, isInvisible, cameraShake)
    local playerCoords = GetEntityCoords(cache.ped)
    local distance = #(self.coords - playerCoords)
    if distance < 10 then
        SetEntityHealth(cache.ped, 0)
    end
    self:destroy()
end

--- Randomizes cable colors
--- @param colours table<number, string> The list of colors to randomize
--- @return table<number, string> The shuffled list of colors
local function randomColours(colours)
    local shuffled = table.clone(colours)
    for i = #shuffled, 2, -1 do
        local j = math.random(1, i)
        shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
    end
    return shuffled
end

--- Creates cables for the bomb
--- @return table<number, TCable>
function Bomb:createCables()
    local colours = randomColours(Data.CableColoursForIndex)

    --- @type table<number, TCable>
    local cables = {}
    for i = 1, 4 do
        local colour = colours[i]
        local offset = Data.CableUIPosition[i]
        cables[i] = {
            id = i,
            colour = colour,
            set = false,
            trigger = false,
            object = nil,
        }
    end
    return cables
end

--- Clears bomb data except its position
function Bomb:clearDataExceptPosition()
    self.state = nil
    self.timer = {}
    self.cables = {}
end

return Bomb
