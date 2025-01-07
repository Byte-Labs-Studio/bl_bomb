

---@alias TCableColours 'red' | 'yellow' | 'blue' | 'green' | 'silver' | 'brown'

---@alias TBombState 'started' | 'defused' | 'planting' | 'defusing' | nil

---@class TTimer
---@field object number The object handle of the digit object
---@field value number The number of the digit

---@class TBombConstructor
---@field id number The id of the bomb
---@field coords vector4 The position of the bomb
---@field state TBombState The state of the bomb

---@class TBomb : TBombConstructor
---@field object number The object handle of the bomb
---@field targetId number The id of the target
---@field timer TTimer[] The timers of the bomb, index is the position of the digit in a 4 digit bomb. Index 1 is the second, index 2 is the ten seconds, index 3 is the minute, index 4 is the ten minute
---@field cables TCable[] The cables of the bomb

---@class TBombClient : TBomb
---@field inRange boolean Whether the bomb is in range of the player

---@class TBombServer : TBomb

---@class TCable
---@field id number The id of the cable, index
---@field cut boolean Whether the cable is already cut
---@field colour TCableColours The colour of the cable
---@field object number? The object handle of the cable
---@field trigger boolean? Whether the cable is a trigger
---@field defuse boolean? Whether the cable is a trigger
---@field trap boolean? Whether the cable is a trigger

---@alias TUpdateTimerKey  '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' | '0' | 'Enter'