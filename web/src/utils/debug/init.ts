import { DebugAction } from '@typings/events'
import { toggleVisible } from './visibility'
import { DebugEventSend } from '@utils/eventsHandlers'
import { Receive } from '@enums/events'

/**
 * The initial debug actions to run on startup
 */
const InitDebug: DebugAction[] = [
    {
        label: 'Visible',
        action: () => toggleVisible(true),
        delay: 500,
    },
    {
        label: 'Set Cables',
        action: () => DebugEventSend(Receive.setCables, [
            {
              "id": 1,
              "colour": "red",
              "set": false,
              "trigger": false,
              "object": null
            },
            {
              "id": 2,
              "colour": "yellow",
              "set": false,
              "trigger": false,
              "object": null
            },
            {
              "id": 3,
              "colour": "blue",
              "set": false,
              "trigger": false,
              "object": null
            },
            {
              "id": 4,
              "colour": "green",
              "set": false,
              "trigger": false,
              "object": null
            }
          ]),
        delay: 0,
    }
]

export default InitDebug


export function InitialiseDebugSenders(): void {
    for (const debug of InitDebug) {
        setTimeout(() => {
            debug.action()
        }, debug.delay || 0)
    }
}
