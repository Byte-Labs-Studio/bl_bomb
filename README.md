# Server export
```lua
---@alias TCableColours 'red' | 'yellow' | 'blue' | 'green' | 'silver' | 'brown'
---@param source number|string
---@param data {cables: {colour: TCableColours, trigger?: boolean, trap?: boolean, defuse?: boolean}, code: string}
exports.bl_bomb:giveBomb(source, data)

--example
exports.bl_bomb:giveBomb(source, {
    cables = {
        { colour = 'red', trigger = true },
        { colour = 'green', defuse = true },
        { colour = 'blue', trap = true },
        { colour = 'yellow', trap = true}
    },
    code = 1111
})
```

# Dependencies
## [bl_bridge](https://github.com/Byte-Labs-Studio/bl_bridge) / [ox_lib](https://github.com/overextended/ox_lib)

### Credit: `levlev` for props
