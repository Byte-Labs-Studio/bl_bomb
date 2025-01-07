local bomb = {}

---@class table<TCableColours, number>
bomb.variationColors = { -- https://docs.fivem.net/natives/?_0x971DA0055324D033 colors
    red = 0,
    yellow = 1,
    blue = 2,
    green = 3,
    silver = 4,
    brown = 5,
}

bomb.cableOffsets = {
    vec2(-0.030486, 0.101397),
    vec2(0.035195, 0.146397),
    vec2(0.025195, 0.146397),
    vec2(-0.004195, 0.144397),
}

bomb.timerOffsets = {
    vec2(-0.089641, -0.024452), -- second
    vec2(-0.079994, -0.024452), -- ten seconds
    vec2(-0.070640, -0.024452), -- minute
    vec2(-0.108118, -0.024452), -- ten minute
    vec2(-0.118118, -0.024452), -- hundred minute
}

bomb.cablesModels = {
    `lev_briefcase_cable_1`,
    `lev_briefcase_cable_2`,
    `lev_briefcase_cable_3`,
    `lev_briefcase_cable_4`,
}

bomb.cutCablesModels = {
    `lev_briefcase_cable_1_cut`,
    `lev_briefcase_cable_2_cut`,
    `lev_briefcase_cable_3_cut`,
    `lev_briefcase_cable_4_cut`,
}

bomb.numModels = {
    [0] = `lev_num0`,
    `lev_num1`,
    `lev_num2`,
    `lev_num3`,
    `lev_num4`,
    `lev_num5`,
    `lev_num6`,
    `lev_num7`,
    `lev_num8`,
    `lev_num9`,
}

return bomb