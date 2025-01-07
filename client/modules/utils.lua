local bombCamera = nil

local utils = {
    focusedBomb = nil
}
--- Used to send NUI events to the UI
--- @param action string
--- @param data any
function utils.sendNUIEvent(action, data)
    SendNUIMessage({
        action = action,
        data = data
    })
end

function utils.replaceCharAtReverseIndex(str, index, replacement)
    if index < 1 or index > #str then
        error("Index out of bounds")
    end

    local forwardIndex = #str - index + 1

    return str:sub(1, forwardIndex - 1) .. replacement .. str:sub(forwardIndex + 1)
end

function utils.closeUi(detonate)
    utils.sendNUIEvent('bomb:visible', false)
    SetNuiFocus(false, false)
    LocalPlayer.state:set('atBomb', nil, true)
    RenderScriptCams(false, true, detonate and 100 or require'data.config'.transitionTime, true, false)
    utils.focusedBomb = nil

    if bombCamera and DoesCamExist(bombCamera) then
        DestroyCam(bombCamera, false)
        bombCamera = nil
    end
end

function utils.createCam(entity)
    local coords = GetEntityCoords(entity, true)
    local rot = GetEntityRotation(entity)
    local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords.x, coords.y, coords.z + 0.4, -94.0, rot.y, rot.z + 180, GetGameplayCamFov(), false, 0)
    SetCamActive(cam, true)
    bombCamera = cam

    local config = require'data.config'
    RenderScriptCams(true, true, config.transitionTime, true, true)
    Wait(config.transitionTime - 500)
end
return utils