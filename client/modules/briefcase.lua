local briefCase = nil

local placeControl = lib.addKeybind({
    name = 'place_briefcase',
    description = 'Place the briefcase',
    defaultKey = 'H',
    disabled = true,
})

local stashControl = lib.addKeybind({
    name = 'stash_briefcase',
    description = 'Stash the briefcase',
    defaultKey = 'G',
    disabled = true,
})

local function removeBriefCase()
    if briefCase and DoesEntityExist(briefCase) then
        SetEntityAsMissionEntity(briefCase, true, true)
        DeleteEntity(briefCase)
    end
end

local function holdBriefCase()
    if cache.vehicle then return end

    if briefCase and DoesEntityExist(briefCase) then return end

    local model = require 'data.config'.briefCase.closed
    lib.requestModel(model)

    local ped = cache.ped
    local coords = GetEntityCoords(ped)
    briefCase = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)
    SetModelAsNoLongerNeeded(model)
    AttachEntityToEntity(briefCase,ped, GetPedBoneIndex(ped, 4089),0.0,0.0,0.0,110.0,150.0,100.0,false,false,false,true,2,true)

    lib.showTextUI('[H] Place, [G] Stash')

    local function handleClick()
        removeBriefCase()
        lib.hideTextUI()
        stashControl:disable(true)
        placeControl:disable(true)
    end

    stashControl:disable(false)
    stashControl.onReleased = handleClick

    placeControl:disable(false)
    placeControl.onReleased = function(self)
        if self.clicked then return end

        self.clicked = true
        coords = GetEntityCoords(ped)
        local off = GetEntityForwardVector(ped)
        local position = vec3(coords.x + (off.x / 1.3), coords.y + (off.y/ 1.3), coords.z - 0.9)

        SetTimeout(300, function()
            DetachEntity(briefCase, true, true)
            SetEntityCoords(briefCase, position.x, position.y, position.z, false, false, false, false)
            local rot = GetEntityRotation(ped)
            SetEntityRotation(briefCase, 90.0, rot.y, rot.z, 2, true)
        end)

        if not lib.progressBar({
            duration = 2000,
            label = 'Placing...',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
            },
            anim = {
                flag = 2,
                dict = 'missheistdockssetup1ig_10@idle_c',
                clip = 'talk_pipe_c_worker1'
            },
        }) then self.clicked = false return end

        TriggerServerEvent('bl_bomb:server:placeBomb', vec3(coords.x + off.x, coords.y + off.y, position.z))
        handleClick()
        self.clicked = false
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    removeBriefCase()
end)

return {
    holdBriefCase = holdBriefCase
}