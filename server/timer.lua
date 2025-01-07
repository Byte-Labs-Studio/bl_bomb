local activeTimers = {}
local function startTimer(duration, callback, timerId)
    activeTimers[timerId] = true

    Citizen.CreateThreadNow(function()
        local startTime = os.time()
        while os.time() - startTime < duration do
            if not activeTimers[timerId] then
                return
            end
            Wait(100)
        end

        if activeTimers[timerId] then
            callback()
        end

        activeTimers[timerId] = nil
    end)

    return timerId
end

local function stopTimer(timerId)
    activeTimers[timerId] = false
end

return {
    startTimer = startTimer,
    stopTimer = stopTimer,
}