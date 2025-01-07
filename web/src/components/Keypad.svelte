<script lang="ts">
    import { SendEvent } from '@utils/eventsHandlers';
    import { keyPadPosition } from './data';
    import { Send } from '@enums/events';

    type KeyValue = number | 'Enter';
    const keys: KeyValue[] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 'Enter', 0];

    function keyPress(key: number | 'Enter') {
        SendEvent(Send.updateTimer, key);
    }
</script>


<div style="left: {keyPadPosition.x}vw; top: {keyPadPosition.y}vh;" class="absolute grid grid-cols-3 w-[3.6vw] gap-[0.3vw]">
{#each keys as value, key}
    <button
        class="h-[1.8vh] {value == 'Enter' ? 'w-[2.2vw] col-span-2' : 'w-[1vw]'} text-txt-secondary hover:bg-gray-400 hover:opacity-10"
        on:click={() => keyPress(value)}
    />
{/each}
</div>