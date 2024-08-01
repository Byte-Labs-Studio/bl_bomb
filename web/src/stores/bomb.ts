import type { TBomb, TCable, TTimer } from "@typings/bomb";
import { writable } from "svelte/store";



export const CABLES = writable<TCable[]>([]);

export const TIMERS = writable<TTimer[]>([]);

export const BOMB = writable<TBomb>({
    id: 0,
    state: null,
});