import { Receive } from "@enums/events"
import { DebugEventCallback } from "@typings/events"
import { ReceiveEvent } from "./eventsHandlers"
import { TCable } from "@typings/bomb"
import { CABLES } from "@stores/bomb"

const AlwaysListened: DebugEventCallback[] = [
    {
        action: Receive.visible,
        handler: (data: string) => {
            // console.log("This is always listened to because it is in the AlwaysListened array.")
        }
    },
    {
        action: Receive.setCables,
        handler: (data: TCable[]) => {
            CABLES.set(data)
        }
    },
    {
        action: Receive.cutCable,
        handler: (colour: string) => {
            CABLES.update(cables =>
                cables.map((cable, i) => {
                    if (cable.colour === colour) return { ...cable, cut: true }
                    return cable;
                })
            );
        }
    }
]

export default AlwaysListened



export function InitialiseListen() {
    for (const debug of AlwaysListened) {
        ReceiveEvent(debug.action, debug.handler);
    }
}