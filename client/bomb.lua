local Data = require("client.constants")
local Bomb = {}
Bomb.__index = Bomb

--- @class Bomb
--- @field id number
--- @field coords vec4
--- @field state any
--- @field object any
--- @field targetId any
--- @field timer table<number, TTimer>
--- @field cables table<number, TCable>

-- Global table to store all bombs
--- @type table<number, Bomb>
local AllBombs = {}

--- Creates a new bomb
--- @param id number The unique ID of the bomb
--- @param x number The x position of the bomb
--- @param y number The y position of the bomb
--- @param z number The z position of the bomb
--- @param w number The heading of the bomb
--- @return Bomb
function Bomb:new(id, x, y, z, w)
    local object = self:createBomb(x, y, z)
    PlaceObjectOnGroundProperly(object)

    --- @type Bomb
    local bomb = {
        id = id,
        coords = vec4(x, y, z, w),
        state = nil,
        object = object,
        targetId = self:createTarget(x, y, z, w),
        timer = self:createTimer(x, y, z),
        cables = self:createCables(),
    }

	local self = setmetatable(bomb, Bomb)
    AllBombs[id] = bomb
    bomb:createPoint()
    TriggerServerEvent("bomb:server:requestState", id)

    return self
end

--- Creates a target for the bomb
--- @param x number
--- @param y number
--- @param z number
--- @param h number
--- @return any
function Bomb:createTarget(x, y, z, h)
    return Framework.target.addBoxZone({
        coords = vector3(x, y, z),
        size = vector3(0.5, 0.5, 0.5),
        rotation = h,
        distance = 5.0,
        debug = true,
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
        }
    })
end

--- Creates a point around the bomb
function Bomb:createPoint()
    local range = Config.range or 30
    lib.points.new({
        coords = self.coords,
        size = range,
        debug = true,
        onEnter = function()
            TriggerServerEvent('bomb:server:updatePlayerRange', self.id, GetPlayerServerId(PlayerId()), true)
        end,
        onExit = function()
            TriggerServerEvent('bomb:server:updatePlayerRange', self.id, GetPlayerServerId(PlayerId()), false)
            self:clearDataExceptPosition()
        end
    })
end

--- Opens the bomb
function Bomb:openBomb()
    print("Opening bomb")
end

--- Picks up the bomb
function Bomb:pickUp()
    TriggerServerEvent('bomb:server:removeBomb', self.id)
end

--- Destroys the bomb
function Bomb:destroy()
    DeleteObject(self.object)
    AllBombs[self.id] = nil
    self = nil
end

--- Creates a bomb object
--- @param x number
--- @param y number
--- @param z number
--- @return any
function Bomb:createBomb(x, y, z)
    local model = lib.requestModel("lev_briefcase")

    	-- The offset is to make the bomb look like it's in front of the player
	local bombOffset = -0.8
	y = y + bombOffset

	local object = CreateObject(model, x, y - bombOffset, z, true, true, false)
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
        timers[i] = {
            id = i,
            object = object,
            number = 0,
            changed = false,
        }
    end
    return timers
end

--- Randomizes cable colors
--- @param colours table<number, string>
--- @return table<number, string>
local function randomColours(colours)
    local shuffled = {}
    for i, v in ipairs(colours) do shuffled[i] = v end
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

-- Event listener to update bomb state
RegisterNetEvent("bomb:client:updateBombState")
AddEventHandler("bomb:client:updateBombState", function(bombId, newState)
    if AllBombs[bombId] then
        AllBombs[bombId].state = newState
        print("Updated state for bomb ID:", bombId)
    end
end)

-- Event listener to register a bomb from the server
RegisterNetEvent('bomb:client:registerBomb')
AddEventHandler('bomb:client:registerBomb', function(id, x, y, z, w)
    Bomb:new(id, x, y, z, w)
end)

-- Event listener to remove a bomb from the server
RegisterNetEvent('bomb:client:removeBomb')
AddEventHandler('bomb:client:removeBomb', function(id)
    if AllBombs[id] then
        AllBombs[id]:destroy()
    end
end)

return Bomb
