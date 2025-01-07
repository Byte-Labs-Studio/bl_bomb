<script lang="ts">
    import { Send } from '@enums/events';
    import { CABLES } from '@stores/bomb';
    import { SendEvent } from '@utils/eventsHandlers';
    import { scale } from 'svelte/transition';
    import Fa from 'svelte-fa';
    import { faScissors } from '@fortawesome/free-solid-svg-icons';
    let width: number = window.innerWidth;
    let height: number = window.innerHeight;

    let mouseX: number = 0;
    let mouseY: number = 0;

    let grabbedIndex: number | null = null;

    const POSITION: number[][] = [
        [62, 60.6],
        [59.2, 60.6],
        [58, 60.6],
        [60.8, 60.6],
    ];

    // function setCable(cableid: number) {
    //     if (!grabbedIndex) return;

    //     SendEvent(Send.setCable, cableid);
    // }
</script>

<svelte:window
    on:mousemove={e => {
        mouseX = e.clientX;
        mouseY = e.clientY;
    }}
    on:mouseup={() => {
        grabbedIndex = null;
        document.body.style.cursor = 'default';
    }}
/>

<div
    bind:clientHeight={height}
    bind:clientWidth={width}
    class="w-screen h-screen absolute top-0 left-0"
>
    {#each $CABLES as { id, colour, cut }}
        {#if !cut}
            {@const pos = POSITION[id - 1]}
            <button
                style="left: {pos[0]}vw; top: {pos[1]}vh; color: {colour}"
                class="absolute"
                on:click={() => {
                    SendEvent(Send.setCable, id);
                }}
            >
                <Fa icon={faScissors} class="opacity-70 hover:cursor-pointer" />
            </button>
        {/if}
    {/each}
</div>
