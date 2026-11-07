# TheoTown FPS Counter

A lightweight TheoTown Lua plugin that displays an FPS estimate, frame time, rolling average, low-water FPS, and a live history graph.

## Project files

- `plugin.manifest` — plugin metadata.
- `fps_counter.json` — TheoTown script draft definition.
- `main.lua` — frame sampling and overlay rendering.

## Installation

1. Download or clone this repository.
2. Copy the three plugin files into a folder named `FPS Counter` inside TheoTown's plugins directory.
3. Restart TheoTown or reload plugins if your build supports it.
4. Open a city. The overlay appears in the upper-right corner.

The JSON definition and Lua script must remain together in the same plugin folder. The manifest is also placed alongside them.

## Measurement notes

TheoTown calls `script:update()` once per frame while a city is open. This plugin measures the time between those callbacks using `Runtime.getTime()`, then derives an FPS estimate from the measured interval.

This is a **Lua callback cadence estimate**, not a direct GPU or display-present measurement. `Runtime.getTime()` is documented as a Unix timestamp in milliseconds, so timer resolution and clock adjustments can affect readings. Actual behavior and overhead still need to be checked in-game, especially on Android.

The history graph retains up to 60 samples, captured at approximately 100 ms intervals. The average and low values use a rolling five-second sample window.

## API references

- [TheoTown Lua API introduction](https://doc.theotown.com/topics/00-intro.md.html)
- [Script module](https://doc.theotown.com/modules/Script.html)
- [Runtime module](https://doc.theotown.com/modules/Runtime.html)
- [Drawing module](https://doc.theotown.com/modules/Drawing.html)
- [TheoTown plugin manifest guide](https://forum.theotown.com/viewtopic.php?t=2964)

## Compatibility status

The callback names and drawing functions used here are present in the published TheoTown Lua API documentation. This repository has not yet been runtime-tested against your installed Android beta. Treat this as the first test build, not a verified in-game release.
