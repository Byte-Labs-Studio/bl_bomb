<script lang="ts">
    import { SendEvent } from '@utils/eventsHandlers';
    import { KEYS } from './data';
    import { Send } from '@enums/events';
    import { BOMB } from '@stores/bomb';

    function keyPress(key: number | 'Enter') {
        if (!$BOMB.id) return;
        SendEvent(Send.updateTimer, {
            id: $BOMB.id,
            key,
        });
    }
</script>

{#each KEYS as { key, x, y }}
    <button
        style="left: {x}vw; top: {y}vh;"
        class=" h-[1.8vh] {key == 'Enter' ? 'w-[2.2vw]' : 'w-[1vw]'} absolute  text-txt-secondary hover:bg-gray-400 hover:opacity-10"
        on:click={() => keyPress(key)}
    />
{/each}
