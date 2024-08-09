local Constants = {}

---@class table<number, TCableColours>
Constants.CableColoursForIndex = {
    [1] = 'red',
    [2] = 'yellow',
    [3] = 'blue',
    [4] = 'green',
    [5] = 'silver',
    [6] = 'brown'
}

---@class table<TCableColours, number>
Constants.CableColours = {
    red = 0,
    yellow = 1,
    blue = 2,
    green = 3,
    silver = 4,
    brown = 5,
}

Constants.CableOffsets = {
    [1] = vec3(-0.030486, 0.102397, -0.022000),
    [2] = vec3(0.036195, 0.148199, -0.022000),
    [3] = vec3(0.024668, 0.150242, -0.022000),
    [4] = vec3(-0.001197, 0.146910, -0.022000),
}

Constants.TimerOffsets = {
    [1] = vec3(-0.082640, -0.024452, -0.011577), -- second
    [2] = vec3(-0.091994, -0.024452, -0.011577), -- ten seconds
    [3] = vec3(-0.109641, -0.024452, -0.011577), -- minute
    [4] = vec3(-0.119118, -0.024452, -0.011577), -- ten minute
}

Constants.CableUIPosition = {
    [1] = { x = 892, y = 835 },
    [2] = { x = 849, y = 835 },
    [3] = { x = 630, y = 835 },
    [4] = { x = 590, y = 835 },
}

return Constants