local Data = require("client.constants")
local Bomb = {}
Bomb.__index = Bomb

--- Creates a new bomb
---@param x number The x position of the bomb
---@param y number The y position of the bomb
---@param z number The z position of the bomb
---@param w number The heading of the bomb
function Bomb:new(x, y, z, w)
    local object = self:createBomb(x, y, z)
	PlaceObjectOnGroundProperly(object)

    ---@class TBomb
    local bomb = {
        id = math.random(1, 10000),
        coords = vec4(x, y, z, w),
        state = nil,
        object = object,
        targetId = self:createTarget(x, y, z, w),
        timer = self:createTimer(x, y, z),
        cables = self:createCables(),
    }

	local self = setmetatable(bomb, Bomb)

	return self
end

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

function Bomb:openBomb()
    print("Opening bomb")
end

function Bomb:pickUp()
    
end

function Bomb:destroy()
    DeleteObject(self.object)

    self = nil
end


function Bomb:createBomb(x, y, z)
	local model = lib.requestModel("lev_briefcase")

	-- The offset is to make the bomb look like it's in front of the player
	local bombOffset = -0.8
	y = y + bombOffset

	local object = CreateObject(model, x, y - bombOffset, z, true, true, false)

	PlaceObjectOnGroundProperly(object)

	return object
end

function Bomb:createTimer(x, y, z)
	local offsets = Data.TimerOffsets

	---@type TTimer[]
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

local function randomColours(colours)
	local shuffled = {}

	-- First, create a copy of the original table
	for i, v in ipairs(colours) do
		shuffled[i] = v
	end

	-- Then, perform the Fisher-Yates shuffle on the copy
	for i = #shuffled, 2, -1 do
		local j = math.random(1, i)
		shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
	end

	return shuffled
end

function Bomb:createCables() 
    local colours = randomColours(Data.CableColoursForIndex)

    ---@type TCable[]
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
