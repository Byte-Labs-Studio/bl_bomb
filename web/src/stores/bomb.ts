import type { TCable, TTimer } from "@typings/bomb";
import { writable } from "svelte/store";

export const CABLES = writable<TCable[]>([]);

export const TIMERS = writable<TTimer[]>([]);
