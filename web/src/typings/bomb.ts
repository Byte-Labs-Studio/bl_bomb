

export type TCableColours = 'red' | 'yellow' | 'blue' | 'green' | 'silver' | 'brown'

export interface TTimer {
    id: number
    object: number
    number: number
    changed: boolean
}

export interface TCable {
    id: number
    colour: TCableColours
    set: boolean
    trigger: boolean
    object: number | undefined
}

export interface TBomb {
    id: number
    state: 'started' | 'defused' | 'planting' | 'defusing' | undefined | null
}

export interface TSetCable extends TCable {
    bombid: number;
    cableid: number;
}