<script lang="ts">
    import { Send } from '@enums/events';
    import { BOMB, CABLES } from '@stores/bomb';
    import { SendEvent } from '@utils/eventsHandlers';
    import { fade, scale } from 'svelte/transition';

    let width: number = window.innerWidth;
    let height: number = window.innerHeight;

    let mouseX: number = 0;
    let mouseY: number = 0;

    let grabbedIndex: number | null = null;

    const POSITION: number[][] = [
        [30.2, 76.6],
        [32.2, 76.6],
        [43.7, 76.6],
        [45.9, 76.6],
    ];

    function setCable(cableid: number) {
        if (!grabbedIndex) return;
        if (!$BOMB.id) return;
        SendEvent(Send.setCable, {
            bombid: $BOMB.id,
            cableid,
        });
    }
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
    <svg
        xmlns="http://www.w3.org/2000/svg"
        class="w-screen h-screen"
        viewBox="0 0 {width} {height}"
    >
        {#each $CABLES as { id, colour }}
            {#if grabbedIndex === id}
                {@const pos = POSITION[id - 1]}
                <line
                    transition:fade={{ duration: 100 }}
                    x1="{pos[0] + 0.5}vw"
                    y1="{pos[1] + 1}vh"
                    x2={mouseX}
                    y2={mouseY}
                    stroke={colour}
                    stroke-width="0.2vh"
                    opacity="0.5"
                    stroke-dasharray="1vh 0.5vh"
                />
            {/if}
        {/each}
    </svg>

    {#each $CABLES as { id, colour, set }, i}
        {#if !set}
            {@const pos = POSITION[id - 1]}
            <button
                transition:scale|global={{ duration: 100 }}
                on:mousedown={() => {
                    grabbedIndex = id;
                    document.body.style.cursor = 'grabbing';
                }}
                class="cursor-grab h-[2vh] w-[2vh] absolute rounded-full opacity-50"
                style="left: {pos[0]}vw; top: {pos[1]}vh; background-color: {colour};"
            />
        {/if}
    {/each}

    {#if grabbedIndex !== null}
        <button
            on:mouseup={() => {
                setCable(grabbedIndex);
            }}
            transition:fade={{ duration: 100 }}
            class="w-[7vh] h-[2vh] absolute top-[48.1vh] right-[37.7vw] opacity-50"
            style="background-color: {$CABLES[grabbedIndex - 1].colour};"
        />
    {/if}
</div>
